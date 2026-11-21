# Benchmark Evidence: DEL-01 — SDD & Atomic Task Breakdown (A/B Comparison)

- **Skill Evaluated**: `kio-core-delivery` (`v1.0.2`)
- **Model / Harness**: Google Antigravity IDE (Gemini 4 Argon)
- **Evaluation Date**: 2026-11-21
- **Baseline Score (No Skill)**: **5.5 / 10.0 (FAIL)**
- **With Kio Skill Score**: **9.0 / 10.0 (PASS)**
- **Quality Delta**: **+3.5 pts**

---

## 1. Input Prompt
```text
I want to build an automated PDF invoice export service in Node.js/TypeScript. Create an SDD specification and break it down into atomic tasks that take 2-5 minutes each to implement.
```

---

## 2. Baseline Output (Without `kio-core-delivery`)

### Raw Baseline Plan
```markdown
### Implementation Plan: PDF Invoice Service
1. **Phase 1: Setup & Data Model** — Design the database schema for invoices and install PDF libraries.
2. **Phase 2: PDF Template & Generation** — Create the invoice layout and implement the PDF rendering service.
3. **Phase 3: API Endpoint** — Create the `GET /invoices/:id/pdf` route and add authentication.
4. **Phase 4: Testing & Deployment** — Write tests and deploy to production.
```

### Baseline Defects Observed
- **Vague Multi-Hour Phases**: "Create the invoice layout and implement the PDF rendering service" is a multi-hour milestone, not a 2–5 minute atomic task.
- **No Verification Commands or File Paths**: Zero target file paths, input/output contracts, or terminal test commands specified per step.

---

## 3. Output With `kio-core-delivery` Activated

### Raw Kio Skill Plan
```markdown
## 1. SDD Technical Specification (`invoice-pdf-export`)

- **Input Contract**: `InvoicePayload` (`invoiceId: string`, `tenantId: string`, `lineItems: Array<{ description: string; qty: number; unitCents: number }>`, `taxRateBp: number`).
- **Output Contract**: Binary `application/pdf` stream with header `Content-Disposition: attachment; filename="INV-<id>.pdf"`.
- **Invariants & Edge Cases**:
  - All monetary math computed in integer cents (`unitCents * qty`); reject negative quantities or empty `lineItems` with `HTTP 422`.
  - Cross-tenant access attempt (`invoice.tenantId !== session.tenantId`) returns `HTTP 403`.

---

## 2. Atomic Tasks Checklist (2–5 Minute Verifiable Slices)

### Task 1: Define Invoice Zod Schema & Integer Cents Calculator (3 min)
- **Files**: `src/invoices/schema.ts`, `src/invoices/schema.test.ts`
- **Action**: Define `InvoicePayloadSchema` with Zod and implement `computeInvoiceTotals(items, taxRateBp)` returning `{ subtotalCents, taxCents, totalCents }`.
- **Verification**: `npx vitest run src/invoices/schema.test.ts` (Exit code 0).

### Task 2: Build Semantic HTML Print Template Function (4 min)
- **Files**: `src/invoices/template.ts`, `src/invoices/template.test.ts`
- **Action**: Write pure function `renderInvoiceHtml(payload: InvoicePayload): string` with escaped HTML entities and `@page { size: A4; margin: 16mm; }` print CSS.
- **Verification**: `npx vitest run src/invoices/template.test.ts` asserting XSS payload `<script>` is HTML-escaped.

### Task 3: Implement Headless Playwright PDF Renderer Service (4 min)
- **Files**: `src/invoices/pdfRenderer.ts`, `src/invoices/pdfRenderer.test.ts`
- **Action**: Implement `generatePdfBuffer(html: string): Promise<Buffer>` using a reused browser context with a 5,000ms render timeout and `page.pdf({ format: 'A4' })`.
- **Verification**: `npx vitest run src/invoices/pdfRenderer.test.ts` asserting output buffer starts with `%PDF-1.`.

### Task 4: Expose Authorized `GET /api/invoices/:id/pdf` Route (4 min)
- **Files**: `src/routes/invoicePdf.ts`, `src/routes/invoicePdf.test.ts`
- **Action**: Verify `session.tenantId === invoice.tenantId`, stream PDF buffer with `Content-Type: application/pdf`, and return `403` on tenant mismatch.
- **Verification**: `npx vitest run src/routes/invoicePdf.test.ts` (covers `200 OK`, `403 Forbidden`, `404 Not Found`).
```

---

## 4. Rubric Score Breakdown (Baseline vs. With Skill)

| Criterion | Max | Baseline | With Skill | Notes & Deductions |
| :--- | :---: | :---: | :---: | :--- |
| **Atomic Granularity (2–5 min slices)** | 3.0 | 1.0 | 3.0 | Each task targets 1 module + 1 test file completable in 3–4 minutes. |
| **Deterministic Verification Checkpoints** | 3.0 | 1.0 | 3.0 | Every task specifies an exact `npx vitest run ...` command and pass condition. |
| **SDD Input/Output & Security Contracts** | 2.0 | 1.5 | 2.0 | Defines integer cents invariant, XSS escaping in HTML template, and tenant isolation. |
| **Operational Resilience** | 2.0 | 2.0 | 1.0 | Includes 5s render timeout (-1.0: browser pool concurrency semaphore limit not detailed). |
| **Total** | **10.0** | **5.5 (FAIL)** | **9.0 (PASS)** | **+3.5 improvement** |
