"""Tests for payment_apply.apply_payment on SQLite (always) and PostgreSQL (when
KIO_TEST_PG_DSN is set, e.g. "host=127.0.0.1 port=5432 user=postgres dbname=kio_test")."""
import os
import sqlite3
import sys
import tempfile
import threading
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import payment_apply as pa  # noqa: E402

PG_DSN = os.environ.get("KIO_TEST_PG_DSN")


class Base:
    dialect = "sqlite"

    def connect(self):
        raise NotImplementedError

    def setUp(self):
        self.db = self.connect()
        self.reset()
        self.exec("INSERT INTO orders(id, total, currency, status) VALUES ('o1', 50000, 'VND', 'pending')")

    def tearDown(self):
        self.db.close()

    def reset(self):
        cur = self.db.cursor()
        for t in ("payment_events", "orders"):
            cur.execute(f"DROP TABLE IF EXISTS {t}")
        self.db.commit()
        pa.create_schema(self.db, self.dialect)

    def exec(self, sql, args=()):
        cur = self.db.cursor()
        cur.execute(sql.replace("?", pa.DIALECTS[self.dialect]["ph"]), args)
        self.db.commit()
        return cur

    def one(self, sql, args=()):
        cur = self.db.cursor()
        cur.execute(sql.replace("?", pa.DIALECTS[self.dialect]["ph"]), args)
        row = cur.fetchone()
        self.db.commit()
        return row

    def apply(self, *args, **kw):
        return pa.apply_payment(self.db, *args, dialect=self.dialect, **kw)

    def status(self):
        return self.one("SELECT status FROM orders WHERE id = 'o1'")[0]

    def outcome(self, provider, event_id):
        row = self.one("SELECT outcome FROM payment_events WHERE provider = ? AND event_id = ?", (provider, event_id))
        return row and row[0]

    # --- behaviour -------------------------------------------------------
    def test_apply_then_retry_is_duplicate(self):
        self.assertEqual(self.apply("momo", "t1", "o1", 50000), "applied")
        self.assertEqual(self.apply("momo", "t1", "o1", 50000), "duplicate")
        self.assertEqual(self.status(), "paid")
        self.assertEqual(self.one("SELECT COUNT(*) FROM payment_events")[0], 1)

    def test_amount_mismatch_does_not_consume_the_key(self):
        # The bug this file fixes: recording the event before the amount check made the
        # corrected re-delivery look like a duplicate, and the order stayed pending forever.
        self.assertEqual(self.apply("payos", "t2", "o1", 49999), "amount_mismatch")
        self.assertEqual(self.status(), "pending")
        self.assertEqual(self.outcome("payos", "t2"), "amount_mismatch")
        self.exec("UPDATE orders SET total = 49999 WHERE id = 'o1'")  # support fixes the order
        self.assertEqual(self.apply("payos", "t2", "o1", 49999), "applied")
        self.assertEqual(self.status(), "paid")
        self.assertEqual(self.outcome("payos", "t2"), "applied")

    def test_currency_mismatch_is_rejected(self):
        self.assertEqual(self.apply("stripe", "t3", "o1", 50000, currency="USD"), "amount_mismatch")
        self.assertEqual(self.status(), "pending")

    def test_unknown_order_writes_nothing(self):
        self.assertEqual(self.apply("vnpay", "t4", "nope", 1), "unknown_order")
        self.assertEqual(self.one("SELECT COUNT(*) FROM payment_events")[0], 0)

    def test_second_event_for_paid_order_is_already_settled(self):
        self.assertEqual(self.apply("momo", "a", "o1", 50000), "applied")
        self.assertEqual(self.apply("momo", "b", "o1", 50000), "already_settled")  # double payment
        self.assertEqual(self.outcome("momo", "b"), "order_not_pending")
        self.assertEqual(self.status(), "paid")

    def test_refunded_order_is_not_revived(self):
        self.exec("UPDATE orders SET status = 'refunded' WHERE id = 'o1'")
        self.assertEqual(self.apply("stripe", "t5", "o1", 50000), "already_settled")
        self.assertEqual(self.status(), "refunded")

    def test_error_rolls_back(self):
        class Boom(Exception):
            pass
        db = self.db

        class FailingCursor:
            def __init__(self):
                self.c = db.cursor()

            def execute(self, sql, args=()):
                if sql.startswith("UPDATE orders"):
                    raise Boom()
                return self.c.execute(sql, args)

            def __getattr__(self, k):
                return getattr(self.c, k)

        class Conn:  # proxy: fail the order update after the event row was written
            def cursor(self):
                return FailingCursor()

            def __getattr__(self, k):
                return getattr(db, k)

        with self.assertRaises(Boom):
            pa.apply_payment(Conn(), "momo", "t6", "o1", 50000, dialect=self.dialect)
        self.assertIsNone(self.outcome("momo", "t6"))
        self.assertEqual(self.status(), "pending")

    def test_concurrent_deliveries_apply_once(self):
        results, errors = [], []

        def worker(event_id):
            try:
                conn = self.connect()
                results.append(pa.apply_payment(conn, "momo", event_id, "o1", 50000, dialect=self.dialect))
                conn.close()
            except Exception as e:  # pragma: no cover - surfaced below
                errors.append(e)

        threads = [threading.Thread(target=worker, args=(eid,)) for eid in ("same", "same", "same", "other")]
        for t in threads:
            t.start()
        for t in threads:
            t.join()
        self.assertEqual(errors, [])
        self.assertEqual(results.count("applied"), 1, results)
        self.assertEqual(self.status(), "paid")


class SQLiteTests(Base, unittest.TestCase):
    dialect = "sqlite"

    @classmethod
    def setUpClass(cls):
        cls.tmp = tempfile.TemporaryDirectory()
        cls.path = os.path.join(cls.tmp.name, "pay.db")

    @classmethod
    def tearDownClass(cls):
        cls.tmp.cleanup()

    def connect(self):
        conn = sqlite3.connect(self.path, isolation_level=None, timeout=10, check_same_thread=False)
        conn.execute("PRAGMA foreign_keys = ON")
        return conn


@unittest.skipUnless(PG_DSN, "set KIO_TEST_PG_DSN to run the PostgreSQL tests")
class PostgresTests(Base, unittest.TestCase):
    dialect = "postgres"

    def connect(self):
        import psycopg
        return psycopg.connect(PG_DSN)


if __name__ == "__main__":
    unittest.main()
