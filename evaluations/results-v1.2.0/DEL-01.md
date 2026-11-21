# DEL-01 — A/B re-run for v1.2.0

- **Skill:** `kio-core-delivery` (as shipped in v1.2.0)
- **Generation model:** `claude-sonnet-5-5` (both runs) · **Judge model:** `claude-opus-5-5`
- **Harness:** Claude Code CLI, [`../harness/run_bench.py`](../harness/run_bench.py); baseline = empty project, with skill = project containing only `kio-core-delivery`, invoked as `/kio-core-delivery`
- **Judge:** blind (answers labelled X/Y in a seeded random order: baseline = X, with skill = Y), rubric from the v1.0.2 scenario file
- **Skill files read during the with-skill run:** none beyond the injected `SKILL.md`
- **Score:** baseline **4.4 / 10** · with skill **4.4 / 10** · Δ **+0.0**

## Prompt
```text
I want to build an automated PDF invoice export service in Node.js/TypeScript. Create an SDD specification and break it down into atomic tasks that take 2-5 minutes each to implement.
```

## Rubric scores

| Criterion | Max | Baseline | With skill |
| :--- | :---: | :---: | :---: |
| Atomic Granularity (2–5 min slices) | 3.0 | 1.8 | 2.1 |
| Deterministic Verification Checkpoints | 3.0 | 0.8 | 1.2 |
| SDD Input/Output & Security Contracts | 2.0 | 1.2 | 0.8 |
| Operational Resilience | 2.0 | 0.6 | 0.3 |
| **Total** | **10** | **4.4** | **4.4** |

## Judge notes

- **Baseline:** X specifies integer minor units and includes an XSS escaping test, but it has no tenant isolation. Its render timeout is 15s, not 5s, and there is no browser-pool semaphore. Many tasks are verified by vague checks such as 'visual check' or 'compiles' rather than exact vitest commands.
- **With skill:** Y's tasks are TDD-paced with concrete test assertions, and its integer-cents invariant is strong, but no task gives an exact vitest command. It has no HTML escaping and no tenant isolation. It also has no render timeout and no detail on limiting concurrency.

## Baseline output (no skill)

<details><summary>Show full answer (15127 characters)</summary>

# Invoice PDF Export Service: SDD Spec and Task Breakdown

## Part 1: Specification

### 1. Overview
A backend service that renders invoices to PDF automatically, stores them, and makes them retrievable. It exports on invoice finalization (webhook or API call), in scheduled batches, and on demand.

**Goals**
- Deterministic, branded PDF per invoice, with an idempotent export per `(invoiceId, templateVersion)`.
- Asynchronous processing with retries, so API latency is independent of rendering time.
- Durable storage with expiring download links.

**Non-goals (v1)**
- Invoice authoring or editing, payments, and email delivery (a `export.completed` webhook is emitted instead).
- Multi-language RTL layouts.
- A UI.

### 2. Tech Decisions (ADR summary)

| Concern | Choice | Reason |
|---|---|---|
| Runtime | Node 22, TypeScript strict, ESM | LTS, type safety |
| HTTP | Fastify + Zod (`fastify-type-provider-zod`) | Schema-validated routes |
| Queue | BullMQ on Redis | Retries, backoff, concurrency, repeatable jobs |
| DB | Postgres via `pg` and plain SQL migrations | Simple and auditable |
| Rendering | Handlebars to HTML, then Puppeteer `page.pdf()` | Full CSS fidelity, easy template changes |
| Storage | S3-compatible (`@aws-sdk/client-s3`) with a local-FS driver for dev/test | Portable |
| Logging | pino | Structured logs |
| Tests | Vitest, Testcontainers (integration) | Fast, real dependencies |

### 3. Functional Requirements (EARS format)

- **FR-1** When `POST /v1/exports` receives a valid invoice payload, the system shall create an export record with status `queued` and return `202` with `exportId`.
- **FR-2** When a request carries an `Idempotency-Key` or an existing `(invoiceId, templateVersion)`, the system shall return the existing export and not create a duplicate.
- **FR-3** When an export job runs, the system shall render the invoice to PDF A4 with line items, subtotal, tax, total, currency formatting, and page numbers.
- **FR-4** When rendering succeeds, the system shall upload the PDF to storage at `invoices/{yyyy}/{mm}/{invoiceId}-{exportId}.pdf`, store its SHA-256 and byte size, and set status `completed`.
- **FR-5** If a job fails with a transient error, the system shall retry up to 3 times with exponential backoff, and shall then set status `failed` with `errorCode`.
- **FR-6** When `GET /v1/exports/:id` is called, the system shall return status and metadata. When status is `completed`, it shall also return a presigned URL valid for 15 minutes.
- **FR-7** When a webhook URL is configured, the system shall POST a signed (HMAC-SHA256) `export.completed` or `export.failed` event with retries.
- **FR-8** While the scheduler is enabled, the system shall enqueue exports for all invoices finalized and not yet exported, at the configured cron interval.
- **FR-9** The system shall authenticate every request with an API key in the `Authorization: Bearer` header, except `/healthz`.
- **FR-10** The system shall expose `/healthz` (liveness) and `/readyz` (DB, Redis and storage checks).

### 4. Non-Functional Requirements
- **NFR-1** P95 render time is ≤ 3s for invoices with ≤ 100 line items.
- **NFR-2** Throughput is ≥ 10 PDFs/s per worker pod. Concurrency is configurable (default 4 pages).
- **NFR-3** No PII in logs. Only IDs are logged.
- **NFR-4** Graceful shutdown drains in-flight jobs within 30s.
- **NFR-5** Test coverage is ≥ 80% on `src/domain` and `src/services`.

### 5. Architecture

```
Client/Webhook ─► API (Fastify) ─► Postgres (exports)
                       │
                       └─► Redis/BullMQ ─► Worker ─► Renderer(Handlebars+Puppeteer)
                                              │            │
                                              │            └─► Storage (S3/local)
                                              └─► Webhook dispatcher
Scheduler (repeatable job) ─► enqueues pending invoices
```

Layout:
```
src/
  config/        env.ts
  domain/        invoice.schema.ts, money.ts, export.ts
  http/          server.ts, auth.ts, routes/{exports,health}.ts
  db/            pool.ts, migrations/, exportsRepo.ts
  queue/         connection.ts, queues.ts, worker.ts, scheduler.ts
  render/        templates/invoice.hbs, template.ts, browser.ts, renderPdf.ts
  storage/       Storage.ts, s3.ts, local.ts
  webhooks/      sign.ts, dispatch.ts
  services/      exportService.ts
  index.ts       (api)   worker.ts (worker entry)
test/
```

### 6. Data Model

```sql
CREATE TABLE exports (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id       text        NOT NULL,
  template_version text        NOT NULL,
  idempotency_key  text,
  status           text        NOT NULL CHECK (status IN ('queued','processing','completed','failed')),
  payload          jsonb       NOT NULL,
  storage_key      text,
  sha256           text,
  size_bytes       integer,
  error_code       text,
  attempts         integer     NOT NULL DEFAULT 0,
  webhook_url      text,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now(),
  UNIQUE (invoice_id, template_version)
);
CREATE UNIQUE INDEX exports_idem ON exports(idempotency_key) WHERE idempotency_key IS NOT NULL;
CREATE INDEX exports_status ON exports(status);
```

### 7. API Contract

`POST /v1/exports`, which returns `202 {exportId, status}`:
```json
{
  "invoice": {
    "id": "INV-1001", "issueDate": "2026-11-01", "dueDate": "2026-11-30",
    "currency": "USD",
    "seller": {"name":"Acme", "address":["1 Main St","NYC"], "taxId":"US123"},
    "buyer":  {"name":"Globex", "address":["9 Side Rd","LA"]},
    "lines": [{"description":"Widget","quantity":2,"unitPriceMinor":1500,"taxRate":0.2}],
    "notes": "Thanks!"
  },
  "webhookUrl": "https://example.com/hook"
}
```
`GET /v1/exports/:id` returns `200 {id, invoiceId, status, sizeBytes?, downloadUrl?, errorCode?}` or `404`.

Errors use the shape `{error:{code,message}}` with codes `VALIDATION_ERROR` (400), `UNAUTHORIZED` (401), `NOT_FOUND` (404), `RENDER_FAILED`, and `STORAGE_FAILED`.

**Money rule:** amounts are integer minor units. Tax is computed per line and rounded half-up. Totals are sums of rounded lines.

### 8. Configuration (env)
`PORT, DATABASE_URL, REDIS_URL, API_KEYS (comma list), STORAGE_DRIVER=s3|local, S3_BUCKET, S3_REGION, S3_ENDPOINT, LOCAL_STORAGE_DIR, WORKER_CONCURRENCY=4, SCHEDULER_CRON, SCHEDULER_ENABLED, WEBHOOK_SECRET, TEMPLATE_VERSION=v1`

### 9. Acceptance Criteria
1. Posting a valid invoice yields a `completed` export, and the downloaded file begins with `%PDF-`.
2. A repeat POST returns the same `exportId` and creates one DB row.
3. When storage fails twice and then succeeds, the export ends `completed` with `attempts=3`.
4. A tampered webhook signature fails verification.
5. A missing or invalid API key returns 401.
6. `pdftotext` on the output contains the invoice id, the buyer name and the formatted total.

---

## Part 2: Atomic Tasks (2–5 min each)

Each task is one commit. "Verify" is the quick check that proves it is done. Tasks are in dependency order.

### Phase 0: Scaffolding
| ID | Task | Verify |
|---|---|---|
| T01 | `npm init`, add `typescript`, `tsx`, `vitest`, `@types/node`; set `"type":"module"` | `npx tsc -v` |
| T02 | Create `tsconfig.json` (strict, NodeNext, `outDir dist`) | `npx tsc --noEmit` passes |
| T03 | Add ESLint and Prettier config plus `lint`, `format`, `test`, `build` scripts | `npm run lint` |
| T04 | Add `docker-compose.yml` with Postgres 16 and Redis 7 | `docker compose up -d` is healthy |
| T05 | `src/config/env.ts`: Zod-parse all env vars from §8, export typed `config` | Unit test: missing `DATABASE_URL` throws |
| T06 | `src/logger.ts`: pino instance with redaction of `authorization` | Import logs a line |

### Phase 1: Domain
| ID | Task | Verify |
|---|---|---|
| T07 | `domain/invoice.schema.ts`: Zod schema for party, line and invoice (§7) | Valid fixture parses |
| T08 | Schema rules: `lines.min(1)`, currency regex, `quantity>0`, `taxRate 0..1`, `dueDate>=issueDate` | Test per rule |
| T09 | `domain/money.ts`: `formatMoney(minor, currency)` via `Intl.NumberFormat` | `150000,'USD' → $1,500.00` |
| T10 | `domain/money.ts`: `computeTotals(lines)` with per-line half-up tax rounding | Test: 3 lines hand-computed |
| T11 | `domain/money.ts`: handle zero-decimal currencies (JPY) | Test JPY = 0 decimals |
| T12 | Create `test/fixtures/invoice.ts` with a sample valid invoice | Used by T07 test |

### Phase 2: Database
| ID | Task | Verify |
|---|---|---|
| T13 | Install `pg`; `db/pool.ts` exports a Pool and `closePool` | `SELECT 1` works |
| T14 | `db/migrations/001_exports.sql` with the DDL from §6 | Applies cleanly |
| T15 | `db/migrate.ts`: run `.sql` files in order, tracking a `schema_migrations` table | Second run is a no-op |
| T16 | `db/exportsRepo.ts` `insertExport()` using `ON CONFLICT (invoice_id,template_version) DO NOTHING RETURNING` | Integration test: duplicate returns existing |
| T17 | `exportsRepo.getById()` | Returns null on missing |
| T18 | `exportsRepo.getByIdempotencyKey()` | Test |
| T19 | `exportsRepo.markProcessing(id)` (increment `attempts`) | `attempts` goes 0→1 |
| T20 | `exportsRepo.markCompleted(id,{key,sha256,size})` | Row updated |
| T21 | `exportsRepo.markFailed(id,errorCode)` | Row updated |
| T22 | `exportsRepo.listUnexportedInvoices` stub: `findStaleQueued(olderThan)` | Test |

### Phase 3: Storage
| ID | Task | Verify |
|---|---|---|
| T23 | `storage/Storage.ts` interface: `put(key,buf,contentType)`, `presignGet(key,ttl)`, `exists(key)` | Compiles |
| T24 | `storage/local.ts`: `put` and `exists` writing under `LOCAL_STORAGE_DIR` | Round-trip test |
| T25 | `local.ts` `presignGet`: return a `file://` URL (dev only) | Test |
| T26 | Install `@aws-sdk/client-s3` and `s3-request-presigner`; `storage/s3.ts` `put` | MinIO or mocked-client test |
| T27 | `s3.ts` `presignGet` and `exists` (HeadObject) | Test |
| T28 | `storage/index.ts` factory selecting the driver from config | Unit test |
| T29 | `storage/keys.ts`: `buildKey(invoiceId,exportId,date)` per FR-4 | Test the format |

### Phase 4: Rendering
| ID | Task | Verify |
|---|---|---|
| T30 | Install `handlebars`; `render/templates/invoice.hbs` with header, parties and table skeleton | File exists |
| T31 | Add CSS (A4, fonts, table styles, `@page` margins) inline in the template | Visual check |
| T32 | Add totals block and notes section to the template | Visual check |
| T33 | `render/template.ts`: compile the template, register `money` and `date` helpers | Test: renders the invoice id |
| T34 | `render/template.ts`: `buildViewModel(invoice)` using `computeTotals` and `formatMoney` | Test |
| T35 | Install `puppeteer`; `render/browser.ts` singleton `getBrowser()` with `--no-sandbox` flag from env | Launches |
| T36 | `render/renderPdf.ts`: `renderPdf(invoice): Promise<Buffer>` using `setContent` and `page.pdf` (A4, `printBackground`, footer page numbers) | Buffer starts with `%PDF-` |
| T37 | `renderPdf`: always `page.close()` in `finally`; 15s timeout | Test: timeout throws `RENDER_FAILED` |
| T38 | Escape HTML in user fields (Handlebars default); add an XSS test | Test: `<script>` is not executed or emitted raw |
| T39 | Golden test: `pdftotext` or `pdf-parse` contains the id, buyer and total (AC-6) | Passes |

### Phase 5: Service and Queue
| ID | Task | Verify |
|---|---|---|
| T40 | `queue/connection.ts`: ioredis connection with `maxRetriesPerRequest:null` | Connects |
| T41 | `queue/queues.ts`: `exportQueue` with default attempts 3 and exponential backoff 2s | Config test |
| T42 | `services/exportService.ts` `requestExport(input)`: validate, insert, enqueue only when newly created (FR-1, FR-2) | Test: duplicate enqueues once |
| T43 | `exportService.processExport(exportId)`: load, `markProcessing`, `renderPdf` | Unit test with mocks |
| T44 | `processExport`: compute sha256, `storage.put`, `markCompleted` | Unit test |
| T45 | Error classification: `RenderError` and `StorageError` map to `errorCode`; non-retryable `ValidationError` uses `UnrecoverableError` | Test |
| T46 | `queue/worker.ts`: BullMQ Worker calling `processExport`, concurrency from config | Integration: job completes |
| T47 | Worker `failed` handler: on the final attempt, `markFailed` and emit the event | AC-3 test |
| T48 | `worker.ts` entry with SIGTERM graceful close (NFR-4) | Manual SIGTERM |

### Phase 6: HTTP API
| ID | Task | Verify |
|---|---|---|
| T49 | Install `fastify`, `fastify-type-provider-zod`; `http/server.ts` `buildServer()` | `inject` returns 404 |
| T50 | Global error handler mapping Zod and domain errors to the §7 error shape | Test: 400 body |
| T51 | `http/auth.ts` preHandler checking Bearer against `API_KEYS` using timing-safe compare | 401 test (AC-5) |
| T52 | `routes/health.ts`: `/healthz` returns 200 (no auth) | Test |
| T53 | `routes/health.ts`: `/readyz` checks DB, Redis and storage | Test failing dependency → 503 |
| T54 | `routes/exports.ts` `POST /v1/exports` → `requestExport`, return 202; read the `Idempotency-Key` header | Test |
| T55 | `routes/exports.ts` `GET /v1/exports/:id`, with `downloadUrl` when completed (FR-6) | Test |
| T56 | `src/index.ts`: start the server, handle SIGTERM | `curl /healthz` |

### Phase 7: Webhooks and Scheduler
| ID | Task | Verify |
|---|---|---|
| T57 | `webhooks/sign.ts`: `sign(body,secret,timestamp)` and `verify()` (HMAC-SHA256, constant-time) | AC-4 test |
| T58 | `webhooks/dispatch.ts`: POST with `X-Signature` and `X-Timestamp` headers, 5s timeout | Test with local HTTP server |
| T59 | Dispatch via a separate `webhookQueue` with 5 attempts and backoff | Test |
| T60 | Enqueue a webhook event from `processExport` (completed) and the failure handler (failed) | Test |
| T61 | `queue/scheduler.ts`: register a repeatable job from `SCHEDULER_CRON` (FR-8) | Job appears in Redis |
| T62 | Scheduler processor: call `findStaleQueued` and re-enqueue the results | Test |

### Phase 8: Hardening and Delivery
| ID | Task | Verify |
|---|---|---|
| T63 | End-to-end test with Testcontainers: POST → poll → download → assert `%PDF-` (AC-1) | Green |
| T64 | Idempotency E2E (AC-2) | Green |
| T65 | Add rate limiting (`@fastify/rate-limit`) at 100 req/min per key | Test 429 |
| T66 | Add a payload size limit (1 MB) and a max of 500 lines | Test 413/400 |
| T67 | Multi-stage `Dockerfile` (Chromium deps, non-root user) | `docker build` OK |
| T68 | GitHub Actions: lint, typecheck, test with service containers | CI green |
| T69 | `README.md`: run instructions, env table, curl examples | Peer review |
| T70 | Benchmark script: 100 invoices; record P95 against NFR-1 | Numbers recorded |

### Task Notes
- **Critical path:** T01–T06 → T07–T12 → T13–T22 and T23–T29 (parallel) → T30–T39 → T40–T48 → T49–T56.
- **Parallelizable:** Phases 2, 3 and 4 are independent once Phase 1 is done.
- **Definition of done (every task):** typecheck, lint and tests pass, and there is one commit with a conventional message.
- **Task sizing:** if a task exceeds 5 minutes, split it. T36, T42 and T46 are the likeliest to need it.

</details>

## Output with skill

<details><summary>Show full answer (15957 characters)</summary>

# Automated PDF Invoice Export Service: SDD Kit

I made these assumptions, so tell me if any are wrong. I'll adjust the spec.
- Invoices are already stored in Postgres by an upstream system.
- "Automated" means three triggers: an event when an invoice is finalized, a nightly batch, and an on-demand API call.
- Output PDFs go to S3-compatible storage.
- Rendering uses **PDFKit**. It is pure Node, so there is no Chromium dependency, and it gives deterministic and fast output.
- The queue is **pg-boss**, which runs on Postgres, so there is no extra Redis to operate.

---

## 1. `constitution.md`: boundaries

| # | Rule |
|---|------|
| C1 | Node 22 LTS, TypeScript `strict`, ESM. No `any` outside test mocks. |
| C2 | Files stay under 300 lines each, and the whole service stays lean. |
| C3 | Money is stored and calculated in **integer minor units** and never as floats. |
| C4 | Every task follows TDD (red, green, refactor). Vitest is the test runner. |
| C5 | Every input at an external boundary (HTTP, queue payload, env) is validated with Zod. |
| C6 | No PII in logs. Log invoice IDs only, never customer names or addresses. |
| C7 | An export job is **idempotent**. The same `(invoice_id, invoice_version)` produces one artifact. |
| C8 | Secrets come from env vars only, validated at boot. The service fails fast if any are missing. |
| C9 | Out of scope: creating or editing invoices, payment handling, email delivery, and multi-language templates (v1 is English only). |

---

## 2. `spec.md`: requirements

### Goal
Produce a legally readable, consistent PDF for every finalized invoice. Make it retrievable via a signed URL, and do so reliably without manual work.

### User stories (Gherkin)

```gherkin
Feature: Event-triggered export
  Scenario: Finalized invoice is exported automatically
    Given invoice INV-1001 with status "finalized" and version 1
    When the "invoice.finalized" event is received
    Then an export job is enqueued for (INV-1001, v1)
    And within 30 seconds a PDF exists in storage at "invoices/INV-1001/v1.pdf"
    And the export record status is "completed"

  Scenario: Duplicate event does not create a duplicate PDF
    Given an export for (INV-1001, v1) already exists with status "completed"
    When the "invoice.finalized" event is received again
    Then no new job is enqueued
    And the existing export record is returned

Feature: On-demand export
  Scenario: Client requests a download link
    Given a completed export for INV-1001
    When GET /v1/invoices/INV-1001/export is called with a valid API key
    Then the response is 200 with a signed URL that expires in 15 minutes

  Scenario: Export not yet ready
    Given an export for INV-1001 with status "pending"
    When GET /v1/invoices/INV-1001/export is called
    Then the response is 202 with {"status":"pending"}

  Scenario: Draft invoices are rejected
    Given invoice INV-2000 with status "draft"
    When POST /v1/invoices/INV-2000/export is called
    Then the response is 409 with code "INVOICE_NOT_FINALIZED"

Feature: Batch export
  Scenario: Nightly sweep exports missed invoices
    Given 3 finalized invoices have no completed export
    When the nightly job runs at 02:00 UTC
    Then 3 export jobs are enqueued
    And finalized invoices that already have exports are skipped

Feature: Failure handling
  Scenario: Transient failure is retried
    Given the storage upload fails with a network error
    When the job is processed
    Then it is retried up to 5 times with exponential backoff
    And after the final failure the export status is "failed" with error_code stored

Feature: PDF content
  Scenario: Invoice PDF is complete and correct
    Given an invoice with 3 line items, 10% tax and a discount
    Then the PDF shows seller, buyer, invoice number, issue and due dates
    And line items, subtotal, discount, tax and total in the invoice currency
    And totals equal the stored integer values exactly
    And an invoice with more than 25 lines paginates with a repeated table header
```

### Non-functional requirements

| Area | Requirement |
|---|---|
| Latency | p95 render+upload ≤ 5s for an invoice with ≤ 100 lines |
| Throughput | At least 20 concurrent exports (worker concurrency is configurable) |
| Reliability | At-least-once delivery, with idempotent output (C7) |
| Security | API-key auth via an `Authorization: Bearer` header, compared in constant time. Signed URLs expire after 15 minutes. The bucket is private. |
| Observability | Structured JSON logs (pino), `/healthz`, `/readyz`, and a `/metrics` endpoint |
| Testing | At least 85% line coverage on `src/domain` and `src/render`. A golden-file test covers PDF text. |

### API contract

| Method | Path | Response |
|---|---|---|
| POST | `/v1/invoices/:id/export` | 202 `{exportId,status}` (re-enqueues if failed, no-op if completed) |
| GET | `/v1/invoices/:id/export` | 200 `{status,url,expiresAt}` or 202 pending or 404 |
| POST | `/v1/events/invoice-finalized` | 202 (signed webhook, HMAC-SHA256 header) |
| GET | `/healthz`, `/readyz` | 200 |

Error shape: `{ "error": { "code": "STRING", "message": "..." } }`

---

## 3. `plan.md`: architecture and data model

### Components
```
HTTP (Fastify) ──► ExportService ──► pg-boss queue ──► Worker
   │                    │                                │
   │                    ▼                                ▼
   │             exports table                  InvoiceRepo (pg)
   │                                                    │
   └─ webhook (HMAC)                       PdfRenderer (PDFKit)
                                                       │
                                            StorageAdapter (S3)
Scheduler (pg-boss cron 02:00 UTC) ──► BatchSweep ──► ExportService
```

### Folder layout
```
src/
  config/env.ts            # Zod env
  domain/{money,invoice,types}.ts
  db/{pool,migrate}.ts  db/migrations/001_exports.sql
  repo/{invoiceRepo,exportRepo}.ts
  render/{layout,invoicePdf}.ts
  storage/{storage,s3Storage}.ts
  queue/{boss,exportWorker,sweep}.ts
  service/exportService.ts
  http/{server,auth,hmac,routes}.ts
  index.ts
tests/ (mirrors src) + tests/golden/
```

### Data model (SQL)
```sql
-- 001_exports.sql
CREATE TYPE export_status AS ENUM ('pending','processing','completed','failed');

CREATE TABLE invoice_exports (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id       TEXT        NOT NULL,
  invoice_version  INTEGER     NOT NULL,
  status           export_status NOT NULL DEFAULT 'pending',
  storage_key      TEXT,
  sha256           CHAR(64),
  size_bytes       INTEGER,
  attempts         INTEGER     NOT NULL DEFAULT 0,
  error_code       TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at     TIMESTAMPTZ,
  UNIQUE (invoice_id, invoice_version)          -- C7 idempotency
);
CREATE INDEX idx_exports_status ON invoice_exports(status);
```

The service reads an existing `invoices` table, which is assumed to have `id, version, status, number, currency, issued_at, due_at, seller_json, buyer_json, discount_minor, tax_rate_bp`. It also reads `invoice_lines(invoice_id, position, description, qty, unit_price_minor)`.

### Key decisions
- **Idempotency** comes from `INSERT … ON CONFLICT DO NOTHING RETURNING`, plus a pg-boss `singletonKey = invoiceId:version`.
- **Retries** are `retryLimit: 5, retryBackoff: true`. Only errors tagged transient are retried. Validation errors fail permanently.
- **Totals** are recomputed in the renderer and asserted equal to stored totals. A mismatch fails the job with `TOTAL_MISMATCH`.
- **Tax** uses basis points (`tax_rate_bp`) and half-up integer rounding.

---

## 4. `tasks.md`: atomic checklist (2–5 min each)

Format: `[ ] ID: action → ✔ checkpoint`. Tasks are ordered by dependency. Tasks within a phase marked ∥ can run in parallel.

### Phase 0: Scaffold
- [ ] **T01** `npm init`, install `typescript vitest tsx zod pino fastify pg pg-boss pdfkit @aws-sdk/client-s3 @aws-sdk/s3-request-presigner` and the `@types/*` packages → ✔ `npm ls` clean
- [ ] **T02** Add `tsconfig.json` (strict, ESM, NodeNext) and the `build`, `test`, `lint` scripts → ✔ `tsc --noEmit` passes on an empty `src/index.ts`
- [ ] **T03** Add `vitest.config.ts` and one trivial passing test → ✔ `npm test` is green
- [ ] **T04** Add `docker-compose.yml` with Postgres 16 and MinIO, plus `.env.example` → ✔ `docker compose up -d` is healthy

### Phase 1: Config and domain (∥ after T03)
- [ ] **T05** RED: test that `loadEnv` throws when `DATABASE_URL` is missing → ✔ test fails
- [ ] **T06** GREEN: `config/env.ts` Zod schema (DB, S3, API_KEY, WEBHOOK_SECRET, CONCURRENCY) → ✔ T05 passes
- [ ] **T07** RED+GREEN: `money.ts` with `addMinor`, `mulMinor` and `formatMinor(amount, currency)`, using integers only → ✔ test `formatMinor(123456,'USD') === '$1,234.56'`
- [ ] **T08** RED+GREEN: `applyTaxBp(subtotal, bp)` half-up rounding → ✔ 3 table-driven cases including a `.5` edge
- [ ] **T09** `domain/types.ts`: `Invoice`, `InvoiceLine`, `ExportStatus` types, plus a Zod `invoiceSchema` → ✔ valid fixture parses, invalid fixture throws
- [ ] **T10** RED+GREEN: `computeTotals(invoice)` returns `{subtotal, discount, tax, total}` → ✔ matches the Gherkin example (3 lines, 10% tax, discount)

### Phase 2: Database
- [ ] **T11** Write `001_exports.sql` as in the plan → ✔ applies cleanly to the compose Postgres
- [ ] **T12** `db/pool.ts` and `db/migrate.ts`, a simple ordered-file runner → ✔ running it twice is a no-op
- [ ] **T13** Test helper that creates a per-suite schema and seeds fixtures → ✔ a smoke test reads a seeded invoice
- [ ] **T14** RED+GREEN: `invoiceRepo.getWithLines(id)` returns the domain `Invoice` or `null` → ✔ the test covers found and not-found
- [ ] **T15** RED+GREEN: `exportRepo.createIfAbsent(id, version)` → ✔ the second call returns `{created:false}` (idempotency)
- [ ] **T16** RED+GREEN: `exportRepo.markProcessing/Completed/Failed` plus `get(id)` → ✔ state-transition test, and completed→processing is rejected

### Phase 3: PDF rendering
- [ ] **T17** `render/layout.ts`: constants for margins, fonts and column x-positions → ✔ compiles, with no logic
- [ ] **T18** RED: test `renderInvoice(fixture)` returns a Buffer starting with `%PDF-` → ✔ fails
- [ ] **T19** GREEN: minimal PDFKit doc that buffers its stream → ✔ T18 passes
- [ ] **T20** Header block: seller, buyer, invoice number, issue and due dates → ✔ the text-extraction helper finds all 5 strings
- [ ] **T21** Line-items table: columns Description, Qty, Unit, Amount → ✔ the test asserts every line appears
- [ ] **T22** Totals block using `computeTotals` and `formatMinor` → ✔ totals text equals the expected strings
- [ ] **T23** Pagination: break at the bottom margin and repeat the table header → ✔ a 60-line fixture yields ≥ 2 pages with the header on each
- [ ] **T24** Totals integrity guard: throw `TOTAL_MISMATCH` if stored and computed totals differ → ✔ test with a tampered fixture
- [ ] **T25** Golden test: extract text from the PDF and compare it to `tests/golden/inv-1001.txt` → ✔ stable across 3 runs
- [ ] **T26** Perf test: 100 lines render in under 1s → ✔ asserted in the test

### Phase 4: Storage (∥ with Phase 3)
- [ ] **T27** Define the `StorageAdapter` interface: `put(key, buf, contentType)` and `signedUrl(key, ttlSec)` → ✔ compiles
- [ ] **T28** `InMemoryStorage` fake for tests → ✔ round-trip test
- [ ] **T29** RED+GREEN: `S3Storage.put` against MinIO with SSE enabled → ✔ integration test is skipped unless `S3_ENDPOINT` is set
- [ ] **T30** `S3Storage.signedUrl` with a 900s TTL → ✔ the URL contains `X-Amz-Expires=900`
- [ ] **T31** Classify errors as `TransientError` or `PermanentError` in `errors.ts`, and map the AWS network and 5xx codes to transient → ✔ table test

### Phase 5: Service and queue
- [ ] **T32** `queue/boss.ts`: start pg-boss and create the `invoice-export` queue with `retryLimit 5, retryBackoff` → ✔ the queue exists after boot
- [ ] **T33** RED+GREEN: `exportService.request(invoiceId)` checks the invoice is finalized (else throws `INVOICE_NOT_FINALIZED`) → ✔ draft test
- [ ] **T34** `request` then calls `createIfAbsent` and enqueues with `singletonKey` only when `created` → ✔ the duplicate test enqueues once
- [ ] **T35** RED+GREEN: `exportWorker.handle(job)` runs load → render → put → markCompleted, and stores sha256 and size → ✔ happy path with fakes
- [ ] **T36** Worker error path: a transient error rethrows for retry, a permanent one calls `markFailed(error_code)` and does not retry → ✔ two tests
- [ ] **T37** Worker idempotency: skip if the export is already completed → ✔ test with a spy on the renderer
- [ ] **T38** `sweep.ts`: query finalized invoices without completed exports, then enqueue via `request` → ✔ 3-missing/1-present scenario
- [ ] **T39** Register the cron `0 2 * * *` UTC for the sweep → ✔ the schedule is visible in pg-boss

### Phase 6: HTTP
- [ ] **T40** `http/server.ts` Fastify factory with a pino logger and a uniform error handler (`{error:{code,message}}`) → ✔ 404 shape test
- [ ] **T41** `auth.ts` bearer API-key hook using `timingSafeEqual` → ✔ 401 test for a missing and a wrong key
- [ ] **T42** `POST /v1/invoices/:id/export` → ✔ 202 test and 409-on-draft test
- [ ] **T43** `GET /v1/invoices/:id/export` → ✔ tests for 200 with a URL, 202 pending and 404
- [ ] **T44** `hmac.ts` verifies the `X-Signature` HMAC-SHA256 over the raw body → ✔ tests for valid, tampered and missing signatures
- [ ] **T45** `POST /v1/events/invoice-finalized` with a Zod payload → ✔ a valid event triggers `request`, and a bad payload gets 400
- [ ] **T46** `/healthz` and `/readyz` (the DB and queue ping) → ✔ readyz returns 503 when the DB is down

### Phase 7: Wiring and hardening
- [ ] **T47** `index.ts` composition root: env → pool → migrate → boss → worker → server, with graceful SIGTERM shutdown → ✔ the process exits 0 within 10s
- [ ] **T48** End-to-end test: POST the webhook, poll GET, then fetch the signed URL and check the first bytes are `%PDF-` → ✔ passes against compose
- [ ] **T49** Redaction config for pino (no buyer or seller fields) plus a test → ✔ log output contains no names
- [ ] **T50** Minimal `/metrics` (counters for exports completed and failed, and a render duration histogram) → ✔ the endpoint returns Prometheus text
- [ ] **T51** Multi-stage `Dockerfile` that runs as a non-root user → ✔ `docker build` succeeds and `/healthz` responds
- [ ] **T52** README: run, env table, and API examples → ✔ a fresh clone follows it to a green E2E run

### Dependency summary
```
T01-04 → {Phase1 ∥ Phase2 ∥ Phase4} → Phase3 (needs T10) → Phase5 (needs 2,3,4) → Phase6 → Phase7
```

### Engine routing suggestion (`kio_router.py`)
- **codex:** T05–T16, T24, T31–T39 (algorithms, DB, tests)
- **claude:** T17–T23 (layout and visual fidelity), T52
- **either:** the rest

---

## 5. 5-Pillar audit gate (sign-off checklist)

| Pillar | Pass criterion |
|---|---|
| Security | API key and HMAC verified in constant time, bucket private, URLs expire in 15 minutes, no PII in logs, no secrets in the repo |
| Lean code | Every file is under 300 lines, no unused dependencies, `tsc --noEmit` is clean |
| Quality / UX of output | The PDF is readable and paginated, and the golden test is stable |
| SDD compliance | Every Gherkin scenario maps to at least one passing test, and the coverage targets are met |
| Business alignment | Totals are exact to the minor unit, duplicates are impossible, and failures are visible in status and metrics |

### Open questions for you
1. Should the PDF carry company branding, such as a logo or a fixed template?
2. Do you need PDF/A, which some jurisdictions require for archiving?
3. Is the existing system emitting events (webhook), or should the service poll for finalized invoices?
4. Should an amended invoice (version 2) keep the old PDF? The current spec keeps it, because the key includes the version.

</details>
