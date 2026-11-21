---
name: kio-backend-cloud
description: "Architect secure REST/GraphQL APIs, PostgreSQL schemas with Supabase RLS, idempotent payment webhooks, and multi-stage Docker deployments. Use when building backend services, databases, or cloud infrastructure."
author: Toan Pham / Kio System
version: 1.0.2
---

# ⚙️ Kio Backend, Database & Cloud Engineering (`kio-backend-cloud`)

The server-side engineering, database, and cloud infrastructure skill of the Kio System. Integrates 6 core backend modules:

---

## 🧭 Core 6 Backend Modules Matrix

| Module | Reference Guide | Core Mission & Deliverables |
| :--- | :--- | :--- |
| **1. Fullstack API & Payments** | `references/api-payments.md` | OWASP-compliant REST/GraphQL API design, OAuth2/JWT/RBAC authentication, payment gateways & Idempotent Webhooks (Stripe, PayPal, VietQR/PayOS, VNPay, MoMo), S3/R2 presigned URLs, and background worker queues. |
| **2. Enterprise Database** | `references/database-rls.md` | PostgreSQL, Supabase Row-Level Security (RLS), query optimization with `EXPLAIN ANALYZE`, composite indexing, zero-downtime schema migrations, and high-performance Redis caching. |
| **3. Cloud DevOps & IaC** | `references/devops-docker.md` | Terraform Infrastructure as Code (AWS/GCP/Azure), containerization with multi-stage Docker builds, GitHub Actions CI/CD automation, and zero-downtime deployments. |
| **4. AI/ML & Hybrid RAG** | `references/ai-rag.md` | Production-grade RAG pipelines (Hybrid Search: BM25 + pgvector HNSW, contextual chunking, Cohere/BGE re-ranking), PEFT/QLoRA fine-tuning via Hugging Face, and vector evaluation. |
| **5. MCP Server Builder** | `references/mcp-server.md` | Authors production Model Context Protocol (MCP) servers using Python (FastMCP) or Node/TypeScript (MCP SDK) following protocol specifications. |
| **6. Project Scaffolding** | Port Scanning & Setup | Automated scaffolding for modern fullstack architectures (Next.js, FastAPI, WP FSE Docker) with integrated port collision detection across `8080–8999`. |

---

## 🛡️ Architecture & Security Standards (OWASP & Kio Lean Architecture)

1. **Zero Secret Exposure**: Zero credentials, JWT secrets, or API keys committed to source control. 100% loaded from environment variables (`.env`).
2. **Idempotent Webhooks**: All payment webhooks must maintain an `idempotency_keys` table or transactional log to guarantee safe handling of retries and network duplicates.
3. **Database Performance Tuning**: All tables exceeding 10,000 rows must feature composite indexes on filter/sort columns. Eliminate Sequential Scans using `EXPLAIN ANALYZE`.
4. **Kio Lean Architecture (< 700 Lines/File)**: Strict layered architecture: `Routes/Controllers` ➔ `Services` ➔ `Repositories/Models`. No file exceeds 700 lines of code.
