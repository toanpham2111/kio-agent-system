#!/usr/bin/env python3
"""Kio reference implementation: apply a verified payment webhook exactly once.

Works on PostgreSQL (psycopg 3, psycopg2) and SQLite (stdlib sqlite3) with the
same SQL: `INSERT ... ON CONFLICT ... DO UPDATE ... WHERE` is supported by both
(SQLite >= 3.24). Only the placeholder style and the row lock differ, and those
live in DIALECTS. Port the flow, not the driver.

Order of operations (the reason this file exists):

1. Lock the order row (`SELECT ... FOR UPDATE` on Postgres, `BEGIN IMMEDIATE`
   on SQLite) so two deliveries of different events cannot both mark it paid.
2. Compare amount AND currency with the order BEFORE touching the event's
   idempotency key. A mismatch is stored with outcome `amount_mismatch` for
   audit, but it does NOT consume the key: if the gateway (or support, after
   fixing the order) re-delivers the same event, it is evaluated again.
3. Only a successful apply writes outcome `applied`. That row is the
   idempotency key: a later delivery of the same (provider, event_id) is a
   duplicate and changes nothing.
4. The order update is guarded (`status = 'pending'`) and its rowcount is
   checked. If another event already settled the order, the event is stored as
   `order_not_pending` and the caller gets `already_settled`, which usually
   means a double payment to refund, not a silent success.

Signature checks live in payment_signatures.py; call apply_payment() only after
the signature verified.
"""
from __future__ import annotations

import time
from typing import Any

OUTCOMES = ("applied", "amount_mismatch", "order_not_pending")
RESULTS = ("applied", "duplicate", "amount_mismatch", "unknown_order", "already_settled")

# Portable DDL: integer minor units, epoch seconds, text outcome with CHECK.
# On Postgres you may prefer bigint/timestamptz/jsonb payload; keep the keys.
SCHEMA = """
CREATE TABLE IF NOT EXISTS orders (
  id       TEXT PRIMARY KEY,
  total    BIGINT NOT NULL,
  currency TEXT NOT NULL DEFAULT 'VND',
  status   TEXT NOT NULL CHECK (status IN ('pending','paid','failed','refunded'))
);
CREATE TABLE IF NOT EXISTS payment_events (
  provider    TEXT   NOT NULL,
  event_id    TEXT   NOT NULL,
  order_id    TEXT   NOT NULL REFERENCES orders(id),
  amount      BIGINT NOT NULL,
  currency    TEXT   NOT NULL,
  outcome     TEXT   NOT NULL CHECK (outcome IN ('applied','amount_mismatch','order_not_pending')),
  received_at BIGINT NOT NULL,
  PRIMARY KEY (provider, event_id)
);
"""

DIALECTS: dict[str, dict[str, str]] = {
    "postgres": {"ph": "%s", "lock": " FOR UPDATE", "begin": ""},
    "sqlite": {"ph": "?", "lock": "", "begin": "BEGIN IMMEDIATE"},
}

_UPSERT = (
    "INSERT INTO payment_events(provider, event_id, order_id, amount, currency, outcome, received_at) "
    "VALUES (?, ?, ?, ?, ?, ?, ?) "
    "ON CONFLICT (provider, event_id) DO UPDATE SET "
    "order_id = excluded.order_id, amount = excluded.amount, currency = excluded.currency, "
    "outcome = excluded.outcome, received_at = excluded.received_at "
    "WHERE payment_events.outcome <> 'applied'"
)


def create_schema(conn: Any, dialect: str = "sqlite") -> None:
    cur = conn.cursor()
    for stmt in filter(None, (s.strip() for s in SCHEMA.split(";"))):
        cur.execute(stmt)
    conn.commit()


def apply_payment(conn: Any, provider: str, event_id: str, order_id: str, amount: int,
                  currency: str = "VND", dialect: str = "sqlite") -> str:
    """Apply one verified event. Returns one of RESULTS.

    `conn` is a DB-API connection. For SQLite open it with
    `sqlite3.connect(path, isolation_level=None)` so this function controls the
    transaction; for psycopg leave autocommit off (the default).
    """
    d = DIALECTS[dialect]

    def q(sql: str) -> str:
        return sql.replace("?", d["ph"])

    cur = conn.cursor()
    if d["begin"]:
        cur.execute(d["begin"])
    try:
        cur.execute(q("SELECT 1 FROM payment_events WHERE provider = ? AND event_id = ? AND outcome = 'applied'"),
                    (provider, event_id))
        if cur.fetchone():
            result = "duplicate"
        else:
            cur.execute(q("SELECT total, currency, status FROM orders WHERE id = ?" + d["lock"]), (order_id,))
            row = cur.fetchone()
            now = int(time.time())
            if row is None:
                result = "unknown_order"  # nothing to reference; log provider + event_id and alert
            elif int(row[0]) != int(amount) or str(row[1]).upper() != currency.upper():
                cur.execute(q(_UPSERT), (provider, event_id, order_id, amount, currency, "amount_mismatch", now))
                result = "amount_mismatch"
            else:
                cur.execute(q(_UPSERT), (provider, event_id, order_id, amount, currency, "applied", now))
                if cur.rowcount == 0:  # a concurrent delivery applied it first
                    result = "duplicate"
                else:
                    cur.execute(q("UPDATE orders SET status = 'paid' WHERE id = ? AND status = 'pending'"),
                                (order_id,))
                    if cur.rowcount == 1:
                        result = "applied"
                    else:
                        cur.execute(q("UPDATE payment_events SET outcome = 'order_not_pending' "
                                      "WHERE provider = ? AND event_id = ?"), (provider, event_id))
                        result = "already_settled"
        if d["begin"]:
            cur.execute("COMMIT")
        else:
            conn.commit()
        return result
    except BaseException:
        if d["begin"]:
            cur.execute("ROLLBACK")
        else:
            conn.rollback()
        raise
