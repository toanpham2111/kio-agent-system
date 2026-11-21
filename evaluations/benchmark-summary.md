# 📊 Kio Skill Benchmark Summary (A/B Comparative Evaluation Report)

This document summarizes the **A/B Comparative Benchmark Evidence (Baseline Without Skill vs. With Kio Skill)** across all 7 Master Skills in the Kio System. Each scenario was executed using the exact same prompt under two conditions: **Baseline (No Skill Installed)** and **With Kio Skill (`SKILL.md` Loaded)**, preserving full raw code outputs, observed baseline defects, and objective rubric score breakdowns with transparent deductions.

---

## 🆕 v1.2.0 Re-run (current results)

- **Kio version:** `v1.2.0` (frontend, backend, QA and growth skills at 3.0.0; core-delivery, wordpress-fse and cognitive unchanged since 1.0.2)
- **Harness:** Claude Code CLI, script in [`harness/run_bench.py`](harness/run_bench.py). Baseline = empty project; with skill = project containing only that skill, invoked as `/<skill>`.
- **Models:** generation `claude-sonnet-5-5` (both runs); judge `claude-opus-5-5`, **blind** (answers shown as X/Y in a seeded random order), scoring against each scenario's existing rubric.
- **Runs:** one run per condition (n = 1), 2026-11-21, total cost ≈ US$4.24.

| Scenario | Skill (version) | Baseline | With skill | Δ | Evidence |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `BE-01` Supabase RLS multi-tenant | `kio-backend-cloud` 3.0.0 | 8.8 | 9.1 | +0.3 | [`results-v1.2.0/BE-01.md`](results-v1.2.0/BE-01.md) |
| `BE-02` Docker multi-stage build | `kio-backend-cloud` 3.0.0 | 9.9 | 8.9 | -1.0 | [`results-v1.2.0/BE-02.md`](results-v1.2.0/BE-02.md) |
| `COG-01` First-principles trade-off | `kio-cognitive` 1.0.2 | 7.3 | 6.8 | -0.5 | [`results-v1.2.0/COG-01.md`](results-v1.2.0/COG-01.md) |
| `DEL-01` Atomic task breakdown | `kio-core-delivery` 1.0.2 | 4.4 | 4.4 | +0.0 | [`results-v1.2.0/DEL-01.md`](results-v1.2.0/DEL-01.md) |
| `FE-01` SaaS dashboard | `kio-frontend-craft` 3.0.0 | 4.6 | 8.4 | +3.8 | [`results-v1.2.0/FE-01.md`](results-v1.2.0/FE-01.md) |
| `FE-02` Mobile defensive spacing | `kio-frontend-craft` 3.0.0 | 8.1 | 8.3 | +0.2 | [`results-v1.2.0/FE-02.md`](results-v1.2.0/FE-02.md) |
| `GRO-01` CRO funnel & Schema.org | `kio-growth-marketing` 3.0.0 | 7.0 | 6.4 | -0.6 | [`results-v1.2.0/GRO-01.md`](results-v1.2.0/GRO-01.md) |
| `QA-01` 4-quadrant test matrix | `kio-qa-security` 3.0.0 | 8.0 | 9.5 | +1.5 | [`results-v1.2.0/QA-01.md`](results-v1.2.0/QA-01.md) |
| `QA-02` Vitest & disciplined mocking | `kio-qa-security` 3.0.0 | 8.6 | 9.1 | +0.5 | [`results-v1.2.0/QA-02.md`](results-v1.2.0/QA-02.md) |
| `WP-01` Native Gutenberg pattern | `kio-wordpress-fse` 1.0.2 | 9.4 | 9.2 | -0.2 | [`results-v1.2.0/WP-01.md`](results-v1.2.0/WP-01.md) |
| **Average** | | **7.61** | **8.01** | **+0.40** | |

**Reading these numbers honestly**
- Improved in 5/10 (BE-01, FE-01, FE-02, QA-01, QA-02); unchanged in 1 (DEL-01); lower in 4/10 (BE-02, COG-01, GRO-01, WP-01). The clearest gain is `FE-01` (+3.8): the skill's spacing, no-purple, 44 px target and empty-state rules are exactly what the rubric checks.
- The average gap (**+0.40**) is far smaller than the v1.0.2 report (+3.75). A strong current model already scores 7.6/10 without any skill, and with n = 1 a single run can move a score by ±1 point.
- The rubrics were written from the v1.0.2 "with skill" answers, so they sometimes reward specific choices rather than correctness. Example: `BE-02` lost a point for running as the built-in `node` user instead of creating a `nextjs` user, although both are non-root.
- In 7/10 with-skill runs the model answered from the injected `SKILL.md` without opening any `references/` file, so these runs mostly measure the routers, not the deep references.
- Next steps: rubrics that test correctness rather than one reference answer, 3+ runs per condition, and scenarios that need the deep references (payments, MCP, CodeQL, SEO engine).

---

## 🗄️ v1.0.2 report (historical, different harness)

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
