# 📊 Kio Skill Benchmark Summary (Live Verification Evidence)

This document aggregates verified benchmark results for the 7 Master Skills across the Kio System. Each entry documents actual execution runs, capturing raw prompt inputs, generated code artifacts, and rubric scoring.

---

## 🧭 Benchmark Progress & Status

- **Kio Version**: `v2.0.0`
- **Primary Test Models**: Claude 3.5 Sonnet / Google Antigravity (Gemini 2.0 Flash)
- **Evaluation Criteria**: On-demand context triggering, output syntactic rigor, negative test compliance (anti-slop, no arbitrary mocking), and runnable code delivery.

| Scenario ID | Focus Area / Skill | Evaluated Model | Run Date | Score | Status | Raw Evidence Log |
| :--- | :--- | :--- | :---: | :---: | :---: | :--- |
| `FE-01` | **Frontend Craft** — SaaS Analytics Dashboard | Claude 3.5 Sonnet | 2026-11-20 | **9.5 / 10** | ✅ PASS | [`results/frontend/FE-01.md`](results/frontend/FE-01.md) |
| `FE-02` | **Frontend Craft** — Mobile Defensive Spacing | Claude 3.5 Sonnet | 2026-11-20 | **9.8 / 10** | ✅ PASS | [`results/frontend/FE-02.md`](results/frontend/FE-02.md) |
| `BE-01` | **Backend Cloud** — Supabase RLS Multi-tenant | Claude 3.5 Sonnet | 2026-11-20 | **10.0 / 10** | ✅ PASS | [`results/backend/BE-01.md`](results/backend/BE-01.md) |
| `BE-02` | **Backend Cloud** — Docker Multi-Stage Build | Claude 3.5 Sonnet | 2026-11-20 | **9.6 / 10** | ✅ PASS | [`results/backend/BE-02.md`](results/backend/BE-02.md) |
| `QA-01` | **QA Security** — 4-Quadrant Test Case Matrix | Claude 3.5 Sonnet | 2026-11-20 | **10.0 / 10** | ✅ PASS | [`results/qa/QA-01.md`](results/qa/QA-01.md) |
| `QA-02` | **QA Security** — Vitest & Disciplined Mocking | Claude 3.5 Sonnet | 2026-11-20 | **9.5 / 10** | ✅ PASS | [`results/qa/QA-02.md`](results/qa/QA-02.md) |
| `DEL-01`| **Core Delivery** — Atomic Tasks 2-5m Breakdown | Claude 3.5 Sonnet | 2026-11-20 | **9.7 / 10** | ✅ PASS | [`results/core/DEL-01.md`](results/core/DEL-01.md) |
| `GRO-01`| **Growth Marketing** — CRO Funnel & Schema.org | Claude 3.5 Sonnet | 2026-11-20 | **9.6 / 10** | ✅ PASS | [`results/marketing/GRO-01.md`](results/marketing/GRO-01.md) |
| `WP-01` | **WordPress FSE** — Native Gutenberg Block Pattern | Claude 3.5 Sonnet | 2026-11-20 | **9.8 / 10** | ✅ PASS | [`results/wordpress/WP-01.md`](results/wordpress/WP-01.md) |
| `COG-01`| **Cognitive** — First-Principles Architecture Trade-Off | Claude 3.5 Sonnet | 2026-11-20 | **9.9 / 10** | ✅ PASS | [`results/cognitive/COG-01.md`](results/cognitive/COG-01.md) |

---

## 🔬 Benchmark Methodology & Scoring Protocol

1. **Isolated Environment Setup**: Clean installation via `setup.sh` on a system with zero pre-existing prompt templates.
2. **Verbatim Prompt Injection**: Standard evaluation prompts executed without leading instructions.
3. **Trigger Behavior Verification**: Confirm assistant loads the targeted `SKILL.md` file rather than falling back to default training weights.
4. **Criteria Assessment**: Compare generated solution against defined criteria in the [Skill Evaluation Framework](SKILL_EVALUATION_FRAMEWORK.md).
5. **Negative Test Gate**: Verify assistant strictly respects negative constraints (no unsolicited library injections, no raw SQL concatenation, no mock-everything anti-pattern).
