import hashlib
import hmac
import sqlite3
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import payment_signatures as ps  # noqa: E402


class StripeTests(unittest.TestCase):
    secret = "whsec_test"
    body = b'{"id":"evt_1","type":"checkout.session.completed"}'

    def test_valid_signature(self):
        header = ps.stripe_sign(self.body, self.secret, 1_700_000_000)
        self.assertTrue(ps.stripe_verify(self.body, header, self.secret, now=1_700_000_100))

    def test_reserialised_body_fails(self):
        header = ps.stripe_sign(self.body, self.secret, 1_700_000_000)
        reformatted = b'{"id": "evt_1", "type": "checkout.session.completed"}'
        self.assertFalse(ps.stripe_verify(reformatted, header, self.secret, now=1_700_000_100))

    def test_replay_outside_tolerance_fails(self):
        header = ps.stripe_sign(self.body, self.secret, 1_700_000_000)
        self.assertFalse(ps.stripe_verify(self.body, header, self.secret, now=1_700_000_301))

    def test_any_v1_matches(self):
        good = ps.stripe_sign(self.body, self.secret, 1_700_000_000)
        header = good.replace("v1=", "v1=deadbeef,v1=")
        self.assertTrue(ps.stripe_verify(self.body, header, self.secret, now=1_700_000_000))

    def test_garbage_header(self):
        self.assertFalse(ps.stripe_verify(self.body, "nonsense", self.secret))


class VNPayTests(unittest.TestCase):
    secret = "VNPAYSECRET"
    params = {"vnp_Amount": "1000000", "vnp_TxnRef": "ORDER 1", "vnp_ResponseCode": "00",
              "vnp_OrderInfo": "Thanh toan don hang", "vnp_TmnCode": "DEMO", "other": "x"}

    def test_hash_data_sorted_encoded_and_filtered(self):
        data = ps.vnpay_hash_data({**self.params, "vnp_SecureHash": "abc", "vnp_Empty": ""})
        self.assertEqual(data, "vnp_Amount=1000000&vnp_OrderInfo=Thanh+toan+don+hang&"
                               "vnp_ResponseCode=00&vnp_TmnCode=DEMO&vnp_TxnRef=ORDER+1")

    def test_roundtrip_and_tamper(self):
        signed = {**self.params, "vnp_SecureHash": ps.vnpay_sign(self.params, self.secret)}
        self.assertTrue(ps.vnpay_verify(signed, self.secret))
        self.assertFalse(ps.vnpay_verify({**signed, "vnp_Amount": "1"}, self.secret))

    def test_sha512_length(self):
        self.assertEqual(len(ps.vnpay_sign(self.params, self.secret)), 128)


class MoMoTests(unittest.TestCase):
    body = {"partnerCode": "MOMO", "orderId": "o1", "requestId": "r1", "amount": 50000,
            "orderInfo": "pay", "orderType": "momo_wallet", "transId": 123, "resultCode": 0,
            "message": "Successful.", "payType": "qr", "responseTime": 1700000000000,
            "extraData": ""}

    def test_raw_string_order(self):
        raw = ps.momo_ipn_raw(self.body, "AK")
        self.assertTrue(raw.startswith("accessKey=AK&amount=50000&extraData=&message=Successful."))
        self.assertTrue(raw.endswith("&resultCode=0&transId=123"))

    def test_verify(self):
        sig = hmac.new(b"SK", ps.momo_ipn_raw(self.body, "AK").encode(), hashlib.sha256).hexdigest()
        self.assertTrue(ps.momo_verify({**self.body, "signature": sig}, "AK", "SK"))
        self.assertFalse(ps.momo_verify({**self.body, "amount": 1, "signature": sig}, "AK", "SK"))


class PayOSTests(unittest.TestCase):
    def test_verify(self):
        data = {"orderCode": 123, "amount": 3000, "description": "VQRIO123", "reference": "TF1",
                "accountNumber": "12345678", "code": "00", "desc": "success", "counterAccountName": None}
        sig = hmac.new(b"CK", ps.payos_data_string(data).encode(), hashlib.sha256).hexdigest()
        self.assertIn("counterAccountName=&", ps.payos_data_string(data))
        self.assertTrue(ps.payos_verify({"data": data, "signature": sig}, "CK"))
        self.assertFalse(ps.payos_verify({"data": {**data, "amount": 1}, "signature": sig}, "CK"))
        self.assertFalse(ps.payos_verify({"signature": sig}, "CK"))


class IdempotencyTests(unittest.TestCase):
    def setUp(self):
        self.db = sqlite3.connect(":memory:")
        self.db.executescript(ps.SCHEMA)
        self.db.execute("INSERT INTO orders VALUES ('o1', 50000, 'pending')")

    def status(self):
        return self.db.execute("SELECT status FROM orders WHERE id='o1'").fetchone()[0]

    def test_retry_is_duplicate(self):
        self.assertEqual(ps.apply_payment(self.db, "momo", "t1", "o1", 50000), "applied")
        self.assertEqual(ps.apply_payment(self.db, "momo", "t1", "o1", 50000), "duplicate")
        self.assertEqual(self.status(), "paid")
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM payment_events").fetchone()[0], 1)

    def test_amount_mismatch_leaves_order_pending(self):
        self.assertEqual(ps.apply_payment(self.db, "payos", "t2", "o1", 49999), "amount_mismatch")
        self.assertEqual(self.status(), "pending")

    def test_unknown_order(self):
        self.assertEqual(ps.apply_payment(self.db, "vnpay", "t3", "nope", 1), "unknown_order")

    def test_paid_order_not_downgraded(self):
        self.db.execute("UPDATE orders SET status='refunded' WHERE id='o1'")
        self.assertEqual(ps.apply_payment(self.db, "stripe", "t4", "o1", 50000), "applied")
        self.assertEqual(self.status(), "refunded")


if __name__ == "__main__":
    unittest.main()
