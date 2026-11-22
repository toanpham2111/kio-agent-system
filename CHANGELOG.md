# 📜 Changelog

All notable changes to the **Kio** project are documented here following the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) standard and adhering to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.3.2] - 2026-11-22 — Lighter Mobile Images & Seafood Test Re-run

### 🎨 `kio-frontend-craft`
- **`stock_images.py` adds 480 / 768 px image steps** (previously 640 / 1024 / 1600) and compresses the `--eager` hero at quality 62 (others 75). Reason: a 380 px slot on a 1.75–2× phone screen needs ~700 px, and without a 768 step the browser downloads the 1024 file.
- **New rule: mobile LCP image ≤ ~80 KB**, `srcset` with 480 / 768 px steps, only the hero loads eagerly (SKILL.md rule 4, `references/web-performance.md`).
- `test_stock_images.py` now checks the image steps and compression quality; all 150 frontend tests pass.

### 🧪 Seafood site re-run (no hand edits)
- The skill loaded fonts without blocking and added a favicon on its own. Lighthouse desktop 100/100/100/100, mobile 92/100/100/100; blind judge 86 vs 78 for the baseline; 0 misaligned rows, 0 edge overflow.
- Mobile Performance 92 came from a 184 KB hero; adding a 768 px step (60 KB) gives 99. That fix ships in this release.
- The README now states plainly that the earlier 100/100/100/100 came from a **2-line hand fix** (with `manual-fix.diff` and the fixed page to check), not from a skill run.

---

## [1.3.1] - 2026-11-22 — Core Delivery Upgrade

### 👑 `kio-core-delivery` 3.0.0
- **New router** (VI/EN): request triage (hotfix / bounded change / new feature), routing table, overlap rules, workflows and quality gates.
- **Restored and added guides:** Socratic brainstorming, Visual Companion, Spec-Kit SDD (`spec-kit.md`, `spec-driven.md`), writing and executing plans, parallel subagent dispatch, Git worktrees, multi-CLI routing, 5-pillar executive audit, spec/plan reviewer prompts.
- **Templates:** 5 Spec-Kit templates, 9 command workflows (`templates/commands/`), 7 on-disk planning templates (`task_plan.md`, `findings.md`, `progress.md`…).
- **On-disk planning (planning-with-files):** 20 scripts (`scripts/planning/`: init-session, check-complete, plan-doctor, attest, ledger, inject…); paths adjusted for the Kio layout (`kio-core-delivery/scripts/planning/`); init-session, check-complete, plan-doctor and gate-stop smoke-tested.
- **Credits:** `superpowers` (Jesse Vincent), GitHub Spec-Kit, `planning-with-files` (Ahmad Adi), all MIT, in the skill's and the root `THIRD_PARTY_NOTICES.md`.

---

## [1.3.0] - 2026-11-22 — Automatic Stock Photos & Layout Checks for Frontend

### 🎨 `kio-frontend-craft`
- **Free stock photos:** `scripts/stock_images.py` finds and fetches images from Unsplash / Pexels (with a key) or Openverse (no key), emits ready `<img>` tags with `srcset`, `width`/`height`, `alt`, lazy loading and WebP variants, and writes credits to `CREDITS.html`. Each provider's rules are built in (Unsplash hotlink + download event, Pexels/Openverse download). Photos showing another brand are rejected on a brand's page. Live-tested through Openverse.
- **No HTML entities:** write `&`, `©`, `–` and accented letters directly; `&amp;`, `&nbsp;`, `&copy;`, `&#…;` are banned, with a `grep` check before delivery.
- **No mobile edge spill:** grids declare `grid-cols-1` on mobile, child columns get `min-w-0`, and `overflow-hidden` may not hide a spill (found in the Ngo Gia test: a 368 px column in a 343 px gutter).
- **Rows stay aligned (rule 10):** numbers above labels in stat rows, equal-height cards with price/CTA at the bottom, button labels never wrap, `tabular-nums` for figures.
- **`scripts/layout-check.js`:** console check at 375 px and 1440 px reporting `overflow`, `misaligned` and `wrappedButtons`; validated on five pages with no false positives.
- 150 tests pass (13 new for stock photos).

### 🧪 Real-world test on the home page
- The README gains a section comparing a seafood shop site built by Sonnet 5.5 without a skill and with `kio-frontend-craft`: desktop/mobile screenshots, blind judge score (75 → 86/100), Lighthouse, SEO and layout checks, time, tokens and cost. Details and data in `evaluations/showcase/seafood-v1.3/`.
- **Lighthouse 100/100/100/100 as a rule:** Google Fonts load non-blocking (preload + onload with a `noscript` fallback), a favicon is always declared, the hero image has correct `srcset`/`sizes`. On the seafood page: Performance 98 → 100, Best Practices 96 → 100.
- `layout-check.js` ignores full-bleed background media (`absolute` and as wide as its parent), previously reported as edge overflow.

### 🔧 Process
- `docs/RELEASE_WORKFLOW.md` adds a README and repository About review for every change; `CLAUDE.md` records the convention for agents.

---

## [1.2.0] - 2026-11-21 — QA & Security Upgrade, Release-Pinned Installer, Complete Attribution

### 🧪 `kio-qa-security` 3.0.0
- **Restored content lost in the skill consolidation:** TDD and systematic debugging (root-cause tracing, defense in depth, condition-based waiting, `find-polluter.sh`, TDD pressure scenarios), the 4 pstack deep-review modes (blast-radius, interrogate, arena, correct), the Playwright E2E guide, and the CodeQL/Semgrep workflows and scripts with their test suite.
- **New:** `references/codeql/SKILL.md` (two-stage review, 5-layer checklist, "each Bash call is a fresh shell", CodeQL database discovery). 168/173 script tests pass; 2 more pass with Semgrep installed; 3 need an upstream `workflows/codeql-build.js` that was never shipped.
- **New router** (VI/EN), full English editions, `THIRD_PARTY_NOTICES.md`.

- **Answer language:** the benchmark showed the Vietnamese `SKILL.md` made the model answer an English prompt in Vietnamese (QA-01). The FE/BE/QA routers now tell the model to answer in the user's language (growth already did). Added after the benchmark run.

### 🛡️ Installer
- `curl | bash` / `irm | iex` install the **latest release tag** instead of `main`; choose another version with `KIO_REF`.
- Failed updates are no longer swallowed: the git error is printed, the summary says the old copy is still in use, and the installer exits `2`; a failed fresh clone/download exits `1`.
- `release.sh` refuses to tag unless local `main` equals `origin/main`.

### 🙏 Attribution
- 79 sub-skills record their original `author` (Corey Haines, AgriciDaniel, puneetindersingh) with `maintainer: Kio System`; the 5 SEO `original_author` credits are restored.
- 21 SEO `LICENSE.txt` files carry the upstream copyright plus a Kio "Modifications" line.
- The root `THIRD_PARTY_NOTICES.md` is now a complete index: adds Vercel, Anthropic, Profound, Knowatoa, ConversionKit, rowbound, Ploy, Phosphor, Google Fonts, pstack, Trail of Bits; inspirations: Ivan Falco, Gooseworks, spec-kit, Alibaba open-code-review.

### 🧪 Benchmarks
- Re-ran all 10 A/B scenarios on Claude Code (Sonnet 5.5 generation, blind Opus 5.5 judge, n = 1): average 7.61 → 8.01 (+0.40); 5 scenarios improved (FE-01 +3.8), 1 unchanged, 4 lower. The v1.0.2 results are kept as a historical section. Harness: `evaluations/harness/run_bench.py`; evidence: `evaluations/results-v1.2.0/`.

---

## [1.1.0] - 2026-11-21 — Kio Skill Routers & Restored Content

### 🎨 `kio-frontend-craft` 3.0.0
- **Restored content lost in the skill consolidation** (from git history): 64 React/Next.js rules and the full guide, `ui-ux/pro-rules.md`, `ui-ux/quick-reference.md`, Web Performance, PDF → HTML, Mobile (React Native/Expo, SwiftUI, offline).
- **New references:** 9-pass `/unslop` SOP, Lenis smooth scroll (checked against `lenis` 1.3.27).
- **New router** (VI/EN), overlap rules, workflows; `THIRD_PARTY_NOTICES.md`.
- 137 tests + data validation pass; PDF → HTML pipeline verified end to end.

### ⚙️ `kio-backend-cloud` 3.0.0
- **Restored lost content:** API & payments, database, DevOps, AI/ML, MCP builder, project scaffolding.
- **Payments & idempotent webhooks:** `references/payments-webhooks.md` (Stripe, PayPal, VNPay, MoMo, PayOS, SePay) + tested reference `scripts/payment_signatures.py` (15 tests).
- **MCP:** 4 new guides (best practices, Python, TypeScript, evaluation) for `mcp` Python 2.x (`MCPServer`) and the TypeScript SDK 1.32; examples executed.
- **Expanded 9 thin references** and fixed `trivy-action@master`, `curl` healthchecks on slim images, RLS update policy without `WITH CHECK`, weak Redis lock tokens, Terraform state locking. SQL verified on PostgreSQL 16.
- **New router** (VI/EN); `THIRD_PARTY_NOTICES.md` (Apache 2.0 for the MCP builder part).

### 📈 `kio-growth-marketing` 3.0.0
- **New router** (`SKILL.md`, `SKILL.md`): routing table for all 79 sub-skills (53 modules + 26 SEO Engine sub-skills), 17 merge rules for overlapping modules, 7 multi-module workflows and module name resolution.
- **SEO Engine runs**: added the missing `seo-subskills/requirements.txt`, remapped `${CLAUDE_PLUGIN_ROOT}/skills/` to Kio's `subskills/` layout, added script-running instructions.
- **Internal links**: rewrote 150 external GitHub links as relative links, fixed 25 broken links.
- **Branding & licensing**: all 79 sub-skills keep their original `author` with `maintainer: Kio System`, the 5 SEO `original_author` credits are restored, and the SEO `LICENSE.txt` files carry the upstream copyright plus a "Modifications" line; open-source credits (MIT / CC BY 4.0) consolidated in `THIRD_PARTY_NOTICES.md`; fixed misattributed book/framework citations.
- Fixed the English SEO Engine file (broken command, non-existent `seo-report` sub-skill).

---

## [1.0.2] - 2026-11-21 — Piped Installer Auto-Clone, Version Unification, A/B Benchmarks & Open-Source Attribution

### 🚀 One-Line Piped Installer Enhancement (`setup.sh` & `setup.ps1`)
- **Automated Repository Fetching in Piped Mode (`curl | bash` & `irm | iex`)**:
  - When executed via a one-line pipe where no local `skills/` checkout exists in the current directory, the installer automatically clones `toanpham2111/kio-agent-system` into `~/.kio/repo` (with a tarball/zip fallback if `git` is unavailable) before creating symlinks.
  - Subsequent piped runs automatically sync the latest changes in `~/.kio/repo` via `git pull --ff-only`.
  - Enhanced `verify_kio_ownership` to validate symlinks pointing to local checkouts, `~/.kio/repo`, or verified manifest targets.

### 🧹 Internal Link Hygiene, Concise Skill Descriptions & Version Alignment
- **Unified Version `v1.0.2`**: Synchronized version numbers across GitHub Releases, all 7 `SKILL.md` frontmatters, and all evaluation reports in `evaluations/`.
- **Token-Optimized `description` Frontmatter**: Condensed every skill's YAML `description` to 1–2 high-signal sentences specifying exact activation triggers and removed phantom sub-engine identifiers.
- **Internal Link Cleanup Across 150 Files**: Updated all internal module and tool registry links within `skills/` to resolve cleanly inside `toanpham2111/kio-agent-system`.
- **Open-Source Attribution & License Compliance**: Added [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) and a **Credits & Third-Party Open Source Acknowledgments** section in `README.md` preserving upstream MIT license notices.

### 🧪 A/B Comparative Benchmark Overhaul (`evaluations/`)
- **Side-by-Side Baseline (No Skill) vs. With Kio Skill Evidence**: Updated all 10 benchmark logs in `evaluations/results/` with full raw Baseline and With-Skill code outputs, defect analysis, and objective rubric scoring (average score improved from `5.40/10` to `9.15/10`, `+3.75` delta).

---

## [1.0.1] - 2026-11-21 — Installer Security & Ownership Verification Patch

### 🛡️ Security Fixes
- **Strict Ownership & Target Verification**:
  - Eliminated loose OR condition (`is_kio_symlink || is_in_manifest`).
  - Enforced strict actual target resolution (`realpath` / `Junction Target`) matching the expected Kio skill directory before updating or removing any link.
  - Automatically detects and prunes stale records in `~/.kio/manifest.json` if a user has redirected a symlink to an external personal path, preserving 100% of user links.
  - Fixed directory boundary checks in `setup.ps1`, replacing loose `StartsWith()` with exact full-path folder matching.

---

## [1.0.0] - 2026-11-21 — First Official Public Production Release

This marks the first official stable release of **Kio — Open Source AI Skills Collection for Modern Software Engineering**.

### 🧰 The 7 Core Engineering Skills
- **Modular Master Skills**: Standardized on the open Agent Skill Standard (`SKILL.md` format):
  - `kio-frontend-craft`: 79 design styles, 192 curated palettes, 60fps Lenis smooth scroll, defensive spacing.
  - `kio-backend-cloud`: REST/GraphQL patterns, Supabase RLS security, Docker multi-stage builds, webhook idempotency.
  - `kio-qa-security`: 4-quadrant test case matrices, Vitest/Pytest boilerplates, Playwright visual testing, anti-bot defense.
  - `kio-core-delivery`: 2-5 minute atomic task breakdowns, specification-driven development (SDD).
  - `kio-growth-marketing`: 53 CRO conversion frameworks, 25 technical SEO modules & Schema.org JSON-LD.
  - `kio-wordpress-fse`: S0-S8 industrial pipeline for clean, 100% native Gutenberg block theme creation.
  - `kio-cognitive`: First-principles architectural trade-off analysis and decision walkthroughs.

### 🛡️ Non-Destructive Installer & Symlink Safety
- **Ownership Manifest System**: Centralized tracking of all Kio-installed links in `~/.kio/manifest.json`.
- **Realpath & Target Destination Inspection**:
  - Both `setup.sh` (Linux/macOS/WSL) and `setup.ps1` (Windows PowerShell) verify symlink/junction destinations before refreshing.
  - Guarantees 100% preservation of personal user folders and custom symlinks sharing the same name.
  - Clean `--uninstall` strictly removes only verified Kio links.
- **Granular CLI Options**: Supports full install (`all`), individual skills (`--skill frontend,qa`), list (`--list`), and interactive mode (`--interactive`).

### 🧪 Evaluation Framework & Live Benchmark Evidence
- **21 Independent Test Scenarios**: Complete testing specification in [`evaluations/SKILL_EVALUATION_FRAMEWORK.md`](evaluations/SKILL_EVALUATION_FRAMEWORK.md) including rigorous negative test cases.
- **Raw Evidence Logs (`evaluations/results/`)**: Verbatim prompts, generated code, and rubric evaluations for scenarios across skills (`FE-01`, `FE-02`, `BE-01`, `BE-02`, `QA-01`, `QA-02`, `DEL-01`, `GRO-01`, `WP-01`, `COG-01`).
- **Benchmark Summary Report**: [`evaluations/benchmark-summary.md`](evaluations/benchmark-summary.md).

### 📖 Onboarding Experience & Developer Documentation
- **2-Minute Quickstart**: 3-step immediate trial guide with tested copy-paste prompts.
- **Per-Skill Usage Reference**: Prompts and expected outputs documented for each skill.
- **Transparent Compatibility Matrix**: 4 verified tiers across Claude Code, Cursor, Codex, Antigravity, and Windsurf on Linux, macOS, and Windows / WSL.
- **Troubleshooting & FAQ**: Guidance on Windows Developer Mode, symlink permissions, IDE cache reloads, and token safety.

### 🤝 Community Governance & Open Source License
- **Contribution Guidelines**: [`CONTRIBUTING.md`](CONTRIBUTING.md) & [`CONTRIBUTING.md`](CONTRIBUTING.md).
- **Security Policy**: [`SECURITY.md`](SECURITY.md).
- **Code of Conduct**: [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).
- **License**: Official MIT License.
