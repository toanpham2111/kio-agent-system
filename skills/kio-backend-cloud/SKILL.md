---
name: kio-backend-cloud
description: "Kio Master Backend, Database, Cloud & AI/ML Powerhouse — Unifies Fullstack API Design (REST/GraphQL), Modern Auth (OAuth2/RBAC), Payment Gateways & Idempotent Webhooks (Stripe, PayPal, VietQR), Cloud Storage (S3/R2 Presigned URLs), Enterprise Database Engineering (PostgreSQL, Supabase RLS, EXPLAIN ANALYZE, Redis), Cloud DevOps & IaC (Docker multi-stage, Terraform, GitHub Actions CI/CD), Production AI/ML & Hybrid RAG (pgvector, QLoRA, Hugging Face), MCP Server Engineering, and Automated Project Scaffolding with Port Collision Detection."
author: Toan Pham / Kio System
version: 2.0.0
---

# ⚙️ Kio Master Backend, Database, Cloud & AI/ML Powerhouse (`kio-backend-cloud`)

The unified server-side engineering, database, and cloud AI powerhouse of the Kio System. Integrates 6 core infrastructure and backend engines:

---

## 🧭 Core 6 Backend Engines Matrix

| Engine | Functional Module | Core Mission & Deliverables |
| :--- | :--- | :--- |
| **1. Fullstack API & Payments** | `kio-backend-api` | OWASP-compliant REST/GraphQL API design, OAuth2/JWT/RBAC authentication, payment gateways & Idempotent Webhooks (Stripe, PayPal, VietQR/PayOS, VNPay, MoMo), S3/R2 presigned URLs, and background worker queues. |
| **2. Enterprise Database** | `kio-database` | PostgreSQL, Supabase Row-Level Security (RLS), query optimization with `EXPLAIN ANALYZE`, composite indexing, zero-downtime schema migrations, and high-performance Redis caching. |
| **3. Cloud DevOps & IaC** | `kio-devops` | Terraform Infrastructure as Code (AWS/GCP/Azure), containerization with multi-stage Docker builds, GitHub Actions CI/CD automation, and zero-downtime deployments. |
| **4. AI/ML & Hybrid RAG** | `kio-ai-ml` | Production-grade RAG pipelines (Hybrid Search: BM25 + pgvector HNSW, contextual chunking, Cohere/BGE re-ranking), PEFT/QLoRA fine-tuning via Hugging Face, and vector evaluation. |
| **5. MCP Server Builder** | `kio-mcp-builder` | Authors production Model Context Protocol (MCP) servers using Python (FastMCP) or Node/TypeScript (MCP SDK) following protocol specifications. |
| **6. Project Scaffolding** | `kio-create-project` | Automated scaffolding for modern fullstack architectures (Next.js, FastAPI, WP FSE Docker) with integrated port collision detection across `8080–8999`. |

---

## 🛡️ Architecture & Security Standards (OWASP & Kio Lean Architecture)

1. **Zero Secret Exposure**: Zero credentials, JWT secrets, or API keys committed to source control. 100% loaded from environment variables (`.env`).
2. **Idempotent Webhooks**: All payment webhooks must maintain an `idempotency_keys` table or transactional log to guarantee safe handling of retries and network duplicates.
3. **Database Performance Tuning**: All tables exceeding 10,000 rows must feature composite indexes on filter/sort columns. Eliminate Sequential Scans using `EXPLAIN ANALYZE`.
4. **Kio Lean Architecture (< 700 Lines/File)**: Strict layered architecture: `Routes/Controllers` ➔ `Services` ➔ `Repositories/Models`. No file exceeds 700 lines of code.
