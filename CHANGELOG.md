# 📜 Changelog

All notable changes to the **Kio** project are documented here following the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) standard and adhering to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- **Contribution Guidelines**: [`CONTRIBUTING.md`](CONTRIBUTING.md) & [`CONTRIBUTING.en.md`](CONTRIBUTING.en.md).
- **Security Policy**: [`SECURITY.md`](SECURITY.md).
- **Code of Conduct**: [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).
- **License**: Official MIT License.
