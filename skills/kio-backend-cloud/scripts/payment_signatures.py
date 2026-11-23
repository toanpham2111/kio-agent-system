#!/usr/bin/env python3
"""Kio reference implementation: payment webhook signature checks + idempotency.

Stdlib only. Mirrors the rules in references/payments-webhooks.md so an agent can
port them to any stack and test the port against the same vectors.

Gateways covered:
  * Stripe   - `Stripe-Signature: t=<ts>,v1=<hex>` over "<ts>.<raw body>", HMAC-SHA256
  * VNPay    - vnp_* params (minus vnp_SecureHash/vnp_SecureHashType), sorted,
               URL-encoded, joined with "&", HMAC-SHA512 with vnp_HashSecret
  * MoMo     - fixed-order "key=value&..." raw string, HMAC-SHA256 with secretKey
  * PayOS    - webhook `data` object, keys sorted, "key=value&...", HMAC-SHA256
               with the checksum key, compared to `signature`

Always confirm field lists against the gateway's current docs before shipping:
gateways add fields, and a missing field silently breaks the signature.
"""
from __future__ import annotations

import hashlib
import hmac
import sqlite3
import time
from typing import Any, Mapping
from urllib.parse import quote_plus


def _hmac_hex(key: str, message: str, digest=hashlib.sha256) -> str:
    return hmac.new(key.encode(), message.encode(), digest).hexdigest()


def _safe_equal(a: str, b: str) -> bool:
    return hmac.compare_digest(a.lower(), b.lower())


# --- Stripe -----------------------------------------------------------------
def stripe_sign(payload: bytes, secret: str, timestamp: int) -> str:
    sig = _hmac_hex(secret, f"{timestamp}.{payload.decode()}")
    return f"t={timestamp},v1={sig}"


def stripe_verify(payload: bytes, header: str, secret: str,
                  tolerance: int = 300, now: int | None = None) -> bool:
    """Verify against the RAW body. Re-serialised JSON will never match."""
    parts: dict[str, list[str]] = {}
    for item in header.split(","):
        if "=" in item:
            k, v = item.split("=", 1)
            parts.setdefault(k.strip(), []).append(v.strip())
    try:
        ts = int(parts["t"][0])
    except (KeyError, ValueError):
        return False
    now = int(time.time()) if now is None else now
    if abs(now - ts) > tolerance:  # replay protection
        return False
    expected = _hmac_hex(secret, f"{ts}.{payload.decode()}")
    return any(_safe_equal(expected, v) for v in parts.get("v1", []))


# --- VNPay ------------------------------------------------------------------
def vnpay_hash_data(params: Mapping[str, str]) -> str:
    items = sorted((k, v) for k, v in params.items()
                   if k.startswith("vnp_") and k not in ("vnp_SecureHash", "vnp_SecureHashType")
                   and v not in (None, ""))
    return "&".join(f"{k}={quote_plus(str(v))}" for k, v in items)


def vnpay_sign(params: Mapping[str, str], hash_secret: str) -> str:
    return _hmac_hex(hash_secret, vnpay_hash_data(params), hashlib.sha512)


def vnpay_verify(params: Mapping[str, str], hash_secret: str) -> bool:
    received = params.get("vnp_SecureHash", "")
    return bool(received) and _safe_equal(vnpay_sign(params, hash_secret), received)


# --- MoMo (IPN) -------------------------------------------------------------
MOMO_IPN_FIELDS = ("accessKey", "amount", "extraData", "message", "orderId", "orderInfo",
                   "orderType", "partnerCode", "payType", "requestId", "responseTime",
                   "resultCode", "transId")


def momo_ipn_raw(body: Mapping[str, Any], access_key: str) -> str:
    values = {**body, "accessKey": access_key}
    return "&".join(f"{k}={values.get(k, '')}" for k in MOMO_IPN_FIELDS)


def momo_verify(body: Mapping[str, Any], access_key: str, secret_key: str) -> bool:
    received = str(body.get("signature", ""))
    return bool(received) and _safe_equal(_hmac_hex(secret_key, momo_ipn_raw(body, access_key)), received)


# --- PayOS ------------------------------------------------------------------
def payos_data_string(data: Mapping[str, Any]) -> str:
    def fmt(v: Any) -> str:
        return "" if v is None else str(v)
    return "&".join(f"{k}={fmt(data[k])}" for k in sorted(data))


def payos_verify(webhook: Mapping[str, Any], checksum_key: str) -> bool:
    data, received = webhook.get("data"), str(webhook.get("signature", ""))
    if not isinstance(data, Mapping) or not received:
        return False
    return _safe_equal(_hmac_hex(checksum_key, payos_data_string(data)), received)


# --- Idempotency ------------------------------------------------------------
SCHEMA = """
CREATE TABLE IF NOT EXISTS payment_events (
  provider    TEXT NOT NULL,
  event_id    TEXT NOT NULL,
  order_id    TEXT NOT NULL,
  amount      INTEGER NOT NULL,
  received_at INTEGER NOT NULL,
  PRIMARY KEY (provider, event_id)
);
CREATE TABLE IF NOT EXISTS orders (
  id     TEXT PRIMARY KEY,
  total  INTEGER NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('pending','paid','failed','refunded'))
);
"""


def apply_payment(db: sqlite3.Connection, provider: str, event_id: str,
                  order_id: str, amount: int) -> str:
    """Record the event and mark the order paid in ONE transaction.

    Returns "applied", "duplicate", "amount_mismatch" or "unknown_order".
    The unique key makes retries safe; the status guard makes it monotonic.
    """
    with db:  # BEGIN ... COMMIT / ROLLBACK
        row = db.execute("SELECT total, status FROM orders WHERE id = ?", (order_id,)).fetchone()
        if row is None:
            return "unknown_order"
        total, _status = row
        if amount != total:
            return "amount_mismatch"
        cur = db.execute(
            "INSERT OR IGNORE INTO payment_events(provider, event_id, order_id, amount, received_at) "
            "VALUES (?, ?, ?, ?, ?)", (provider, event_id, order_id, amount, int(time.time())))
        if cur.rowcount == 0:
            return "duplicate"
        db.execute("UPDATE orders SET status = 'paid' WHERE id = ? AND status = 'pending'", (order_id,))
        return "applied"


if __name__ == "__main__":
    import doctest
    raise SystemExit(doctest.testmod().failed)
