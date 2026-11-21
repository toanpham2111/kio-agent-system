# 📊 Kio Skill Benchmark Summary (A/B Comparative Evaluation Report)

This document summarizes the **A/B Comparative Benchmark Evidence (Baseline Without Skill vs. With Kio Skill)** across all 7 Master Skills in the Kio System. Each scenario was executed using the exact same prompt under two conditions: **Baseline (No Skill Installed)** and **With Kio Skill (`SKILL.md` Loaded)**, preserving full raw code outputs, observed baseline defects, and objective rubric score breakdowns with transparent deductions.

---

## 🧭 Comparative Evaluation Overview

- **Kio Version**: `v1.0.2`
- **Evaluation Harness & Model**: Google Antigravity IDE (Gemini 4 Argon)
- **Methodology**: Direct A/B behavioral comparison (Without Skill vs. With Skill), full raw output capture, negative test verification, and rubric scoring defined in the [Skill Evaluation Framework](SKILL_EVALUATION_FRAMEWORK.md).

| Scenario | Domain / Skill | Model Evaluated | Run Date | Baseline (No Skill) | With Kio Skill | Quality Delta (`+Δ`) | Raw A/B Evidence Log |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `FE-01` | **Frontend Craft** — SaaS Dashboard | Gemini 4 Argon | 2026-11-21 | 5.5 / 10 (FAIL) | **9.0 / 10 (PASS)** | **+3.5** | [`results/frontend/FE-01.md`](results/frontend/FE-01.md) |
| `FE-02` | **Frontend Craft** — Mobile Defensive Spacing | Gemini 4 Argon | 2026-11-21 | 6.0 / 10 (FAIL) | **9.2 / 10 (PASS)** | **+3.2** | [`results/frontend/FE-02.md`](results/frontend/FE-02.md) |
| `BE-01` | **Backend Cloud** — Supabase RLS Multi-tenant | Gemini 4 Argon | 2026-11-21 | 5.0 / 10 (FAIL) | **9.4 / 10 (PASS)** | **+4.4** | [`results/backend/BE-01.md`](results/backend/BE-01.md) |
| `BE-02` | **Backend Cloud** — Docker Multi-Stage Build | Gemini 4 Argon | 2026-11-21 | 5.5 / 10 (FAIL) | **9.1 / 10 (PASS)** | **+3.6** | [`results/backend/BE-02.md`](results/backend/BE-02.md) |
| `QA-01` | **QA Security** — 4-Quadrant Test Case Matrix | Gemini 4 Argon | 2026-11-21 | 5.5 / 10 (FAIL) | **9.3 / 10 (PASS)** | **+3.8** | [`results/qa/QA-01.md`](results/qa/QA-01.md) |
| `QA-02` | **QA Security** — Vitest & Disciplined Mocking | Gemini 4 Argon | 2026-11-21 | 4.5 / 10 (FAIL) | **9.1 / 10 (PASS)** | **+4.6** | [`results/qa/QA-02.md`](results/qa/QA-02.md) |
| `DEL-01`| **Core Delivery** — Atomic Tasks 2-5m Breakdown | Gemini 4 Argon | 2026-11-21 | 5.5 / 10 (FAIL) | **9.0 / 10 (PASS)** | **+3.5** | [`results/core/DEL-01.md`](results/core/DEL-01.md) |
| `GRO-01`| **Growth Marketing** — CRO Funnel & Schema.org | Gemini 4 Argon | 2026-11-21 | 5.5 / 10 (FAIL) | **8.9 / 10 (PASS)** | **+3.4** | [`results/marketing/GRO-01.md`](results/marketing/GRO-01.md) |
| `WP-01` | **WordPress FSE** — Native Gutenberg Block Pattern | Gemini 4 Argon | 2026-11-21 | 5.0 / 10 (FAIL) | **9.2 / 10 (PASS)** | **+4.2** | [`results/wordpress/WP-01.md`](results/wordpress/WP-01.md) |
| `COG-01`| **Cognitive** — First-Principles Architecture Trade-Off | Gemini 4 Argon | 2026-11-21 | 6.0 / 10 (FAIL) | **9.3 / 10 (PASS)** | **+3.3** | [`results/cognitive/COG-01.md`](results/cognitive/COG-01.md) |
| **Average** | **All 10 Evaluated Scenarios** | **Gemini 4 Argon** | **2026-11-21** | **5.40 / 10** | **9.15 / 10** | **+3.75** | **10/10 Raw A/B Logs** |

---

## 🔬 A/B Testing & Rubric Scoring Protocol

1. **Baseline Run (Without Skill)**: Submit the raw user prompt in a clean session with no Kio skills installed. Record the complete raw output and document common failure modes (e.g., missing RLS `WITH CHECK` policies, `0px` mobile edge-bleed, generic purple AI gradients, mocking the unit under test in Vitest, or running Docker containers as `root`).
2. **Skill-Enabled Run (With Kio Skill)**: Install Kio via `setup.sh`, submit the exact same prompt so the assistant triggers the corresponding `SKILL.md`, and capture the full raw output.
3. **Objective 10-Point Rubric Scoring**: Score both Baseline and With-Skill outputs across 4 weighted criteria, explicitly documenting point deductions (`-0.3` to `-1.0`) wherever auxiliary files or secondary edge cases were abbreviated.
