# Payments & Idempotent Webhooks (Stripe, PayPal, VNPay, MoMo, PayOS/VietQR, SePay)

Kio reference for taking money safely. Read together with `api-and-payments.md` (rules) — this file is the implementation. A runnable, tested reference lives in [`../scripts/payment_signatures.py`](../scripts/payment_signatures.py) (`python3 -m pytest scripts/tests`); port it, then run your port against the same vectors.

## 1. The payment state machine

```
pending ──(verified webhook, amount matches)──▶ paid ──(refund webhook)──▶ refunded
   └──(verified failure / expiry job)────────▶ failed
```

- **The webhook / IPN is the source of truth, never the browser redirect.** The return URL (`vnp_ReturnUrl`, MoMo `redirectUrl`, Stripe `success_url`) only shows a "processing" page and polls your own API.
- Transitions are **monotonic**: `UPDATE ... WHERE status = 'pending'`. A late or replayed "success" must never revive a `refunded` or `failed` order.
- Store money as **integer minor units** (VND has none: `50000` = 50.000 ₫; USD cents). Never floats.

## 2. Handler skeleton (every gateway)

1. Read the **raw body** (bytes) before any JSON parser touches it.
2. Verify the signature with a **constant-time compare** (`crypto.timingSafeEqual`, `hmac.compare_digest`, `hash_equals`). Reject with 400/401 and log the provider + event id only.
3. Look up the order by **your** reference (`vnp_TxnRef`, `orderId`, `orderCode`, Stripe `metadata.order_id` / `client_reference_id`).
4. Check **amount and currency** equal the order total. Mismatch → do not mark paid, alert.
5. In **one DB transaction**: insert `(provider, event_id)` into `payment_events` (unique key), then update the order with the status guard. Unique-violation = duplicate → return success without side effects.
6. Respond in the format the gateway expects **fast** (< 5 s); push emails, fulfilment and invoices to a queue after commit.

```sql
CREATE TABLE payment_events (
  provider    text        NOT NULL,
  event_id    text        NOT NULL,          -- Stripe evt_..., MoMo transId, VNPay vnp_TransactionNo, PayOS reference
  order_id    uuid        NOT NULL REFERENCES orders(id),
  amount      bigint      NOT NULL,
  payload     jsonb       NOT NULL,          -- raw event for audits / replays
  received_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (provider, event_id)
);
```

```ts
// Postgres + node-postgres: idempotent apply
await db.query('BEGIN');
const ins = await db.query(
  `INSERT INTO payment_events (provider, event_id, order_id, amount, payload)
   VALUES ($1,$2,$3,$4,$5) ON CONFLICT DO NOTHING`, [provider, eventId, orderId, amount, payload]);
if (ins.rowCount === 0) { await db.query('ROLLBACK'); return ok(); }        // duplicate retry
await db.query(`UPDATE orders SET status='paid', paid_at=now()
                WHERE id=$1 AND status='pending' AND total=$2`, [orderId, amount]);
await db.query('COMMIT');
```

## 3. Gateway specifics

### Stripe
- Verify with the SDK on the raw body: `stripe.webhooks.constructEvent(rawBody, req.headers['stripe-signature'], STRIPE_WEBHOOK_SECRET)`. Express: `express.raw({ type: 'application/json' })` on that route only. Next.js App Router: `await req.text()`.
- The header is `t=<unix>,v1=<hmac_sha256("<t>.<raw body>")>`; reject timestamps older than the tolerance (default 300 s) to stop replays.
- Fulfil on `checkout.session.completed` (check `payment_status === 'paid'`) or `payment_intent.succeeded`; handle `checkout.session.async_payment_succeeded/failed` for delayed methods; `charge.refunded` for refunds.
- Send an **`Idempotency-Key`** header on every create call (PaymentIntent, refund) so your own retries never double-charge.
- Events can arrive out of order: re-fetch the object (`stripe.checkout.sessions.retrieve`) when state matters.

### PayPal
- Verify with `POST /v1/notifications/verify-webhook-signature` (send `transmission_id`, `transmission_time`, `cert_url`, `auth_algo`, `transmission_sig`, `webhook_id`, `webhook_event`) and require `verification_status === "SUCCESS"`.
- Capture server-side (`POST /v2/checkout/orders/{id}/capture`) and fulfil on `PAYMENT.CAPTURE.COMPLETED`; dedupe on the event `id`.

### VNPay
- Signature: take all `vnp_*` params **except** `vnp_SecureHash` and `vnp_SecureHashType`, drop empty values, sort keys ascending, URL-encode values (spaces as `+`), join `k=v` with `&`, then `HMAC-SHA512(vnp_HashSecret)`; compare to `vnp_SecureHash`.
- `vnp_Amount` is the amount **× 100**. Success needs `vnp_ResponseCode == "00"` **and** `vnp_TransactionStatus == "00"`.
- The IPN must answer JSON: `{"RspCode":"00","Message":"Confirm Success"}`; `97` invalid signature, `01` order not found, `04` invalid amount, `02` already confirmed (duplicate).

### MoMo
- IPN signature = `HMAC-SHA256(secretKey)` over the raw string in this fixed order: `accessKey, amount, extraData, message, orderId, orderInfo, orderType, partnerCode, payType, requestId, responseTime, resultCode, transId` (`key=value` joined by `&`).
- `resultCode == 0` is success (`9000` = authorised, capture pending). Dedupe on `transId`. Reply HTTP **204** quickly.

### PayOS (VietQR)
- Webhook body `{ code, desc, success, data, signature }`. Signature = `HMAC-SHA256(checksumKey)` over `data` with keys **sorted** and joined as `key=value&...` (null → empty string). The official SDK's `verifyPaymentWebhookData` does this.
- Match `data.orderCode` and `data.amount`; dedupe on `data.reference`. Confirm the webhook URL once with `confirm-webhook`.

### SePay / Casso (bank-transfer watchers)
- They forward bank transactions; there is no card-style signature. Authenticate with the **API key header** they send (`Authorization: Apikey <key>` for SePay) over HTTPS, allowlist their IPs if offered.
- Put a unique payment code in the transfer content (e.g. `KIO1234`), parse it from `content`, and require `transferType == "in"` and `transferAmount == order.total`. Dedupe on the transaction `id`.

## 4. Testing checklist

- [ ] Valid signature → order `paid`, one `payment_events` row.
- [ ] Same event twice → second call is a no-op and still returns the gateway's success response.
- [ ] Tampered amount or body → rejected, order stays `pending`.
- [ ] Re-serialised JSON body → rejected (proves you verify the raw body).
- [ ] Stale Stripe timestamp → rejected.
- [ ] Success after refund → order stays `refunded`.
- [ ] Local testing: `stripe listen --forward-to localhost:3000/api/webhooks/stripe`; VNPay/MoMo/PayOS sandboxes + a tunnel (cloudflared / ngrok).

## 5. Never

- Never trust client-sent amounts, prices or "paid" flags.
- Never log full card data, secrets, or full webhook payloads with personal data outside the audit table.
- Never ship a webhook route without signature verification "for now".
- Gateways change field lists: re-check the current official docs before going live.
