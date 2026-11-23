<p align="center">
  <img src="assets/kio-logo.png" alt="Kio logo" width="260" />
</p>

<div align="center">

<h1>Kio: 7 expert skills for your AI coding tool</h1>

<p>Left alone, an AI coding assistant gives generic answers. Kio is an open-source set of skills that gives it the process, references, scripts and checklists of seven fields, so it works like a specialist and shows the checks it ran. It runs inside the tool you already use (Claude Code, Cursor, Codex, Antigravity): no server, no daemon, no API key.</p>

<p align="center">
  <a href="https://github.com/toanpham2111/kio-agent-system/actions/workflows/installers.yml"><img src="https://img.shields.io/github/actions/workflow/status/toanpham2111/kio-agent-system/installers.yml?branch=main&style=for-the-badge&label=CI" alt="CI status"></a>
  <a href="https://github.com/toanpham2111/kio-agent-system/releases/latest"><img src="https://img.shields.io/github/v/release/toanpham2111/kio-agent-system?style=for-the-badge&label=release&color=2f6feb" alt="Latest release"></a>
  <a href="#-license-credits--contributing"><img src="https://img.shields.io/badge/License-MIT_%2B_exceptions-yellow.svg?style=for-the-badge" alt="License: MIT with exceptions"></a>
  <a href="skills/"><img src="https://img.shields.io/badge/skills-7-2ea043.svg?style=for-the-badge" alt="7 skills"></a>
</p>

<p align="center">
  <strong>
    <a href="#-2-minute-quickstart">Quickstart</a> · <a href="#-the-7-core-engineering-skills">Skills</a> · <a href="#️-quick-commands-slash-commands">Commands</a> · <a href="#-results--benchmarks">Results</a> · <a href="#-documentation">Docs</a> · <a href="SECURITY.md">Security</a>
  </strong>
</p>

<p align="center">
  <img src="assets/kio-agent-skills-overview.jpg" alt="KIO Agent Skills Overview: 7 Master Engineering Skills" width="800" />
</p>

</div>

---

## ⚡ 2-Minute Quickstart

**Before you begin:** one AI coding tool that reads skills (Claude Code, Cursor, Codex or Antigravity). `git` is recommended; without it the installer downloads a ZIP. On Windows, if the one-line install fails in a locked-down PowerShell, see [Troubleshooting](#-troubleshooting--faq).

You do not need to read through thousands of documentation files to start using Kio. Get up and running in 3 simple steps:

### Step 1: Install Kio on your machine (takes under 10 seconds)
Open your terminal and run the one-line command:
```bash
# Linux / macOS / WSL:
curl -fsSL https://raw.githubusercontent.com/toanpham2111/kio-agent-system/main/setup.sh | bash

# Windows PowerShell:
irm https://raw.githubusercontent.com/toanpham2111/kio-agent-system/main/setup.ps1 | iex
```

### Step 2: Open your AI coding assistant
Launch your favorite AI tool: `claude`, `cursor`, `codex`, or `agy`. The tool will automatically detect the linked `SKILL.md` files in its configuration directory.

### Step 3: Copy and test an immediate prompt

Try pasting one of these tested prompts into your AI:

> **Frontend Test Prompt**:  
> *"Design a 3-tier SaaS pricing table in React with Tailwind CSS. Apply a tech-focused color palette with high contrast meeting WCAG AA standards, add micro-interactions on hover, and ensure defensive spacing that never bleeds on mobile."*

> **QA & Testing Test Prompt**:  
> *"Generate a 4-quadrant test case matrix (Happy Path, Boundary, Edge Case, Failure Mode) and write complete Vitest unit tests for a shopping cart checkout function with coupon discounts and tax calculations."*

<p align="center"><img src="assets/kio-how-it-works.svg" alt="How a request flows through Kio: you ask, Kio picks one skill, the router sends the agent to the reference it must read, the result comes with evidence" width="900" /></p>

**Immediate Result**: Your AI tool automatically detects and activates the matching Kio skill, producing clean, production-grade output without messy templates or generic AI styling.

---

## 📑 Table of Contents

- [2-Minute Quickstart](#-2-minute-quickstart)
- [Why use Kio? (the 10-second version)](#-why-use-kio-the-10-second-version)
- [What is Kio?](#-what-is-kio)
- [The 7 Core Engineering Skills](#-the-7-core-engineering-skills)
- [Quick Commands (Slash Commands)](#️-quick-commands-slash-commands)
- [Results & Benchmarks](#-results--benchmarks)
- [Installation Guide](#-installation-guide)
- [How Skills Work in Your IDE](#️-how-skills-work-in-your-ide)
- [Compatibility Matrix](#-compatibility-matrix)
- [Troubleshooting & FAQ](#-troubleshooting--faq)
- [Documentation](#-documentation)
- [Community](#-community)
- [Security](#-security)
- [License, Credits & Contributing](#-license-credits--contributing)

---

## 🎯 Why use Kio? (the 10-second version)

| Without a skill | With Kio |
|---|---|
| Generic, "AI-looking" layouts; the main order button failed contrast (2.8:1) | 0 contrast failures, 0 mobile overflow |
| The order form showed "success" but sent nothing | The form validates and sends the order |
| Blind judge score **75–78** | Blind judge score **86** |
| Faster and cheaper: 1 min 55 s, US$0.33 | Slower and costlier: 8 min 2 s, US$0.86 (and ~2.6–4× the tokens) |

One run per condition, scored blind by another model; details, screenshots and source are in the [real-world test](#-real-world-test-without-skill-vs-with-kio) below. Kio runs inside the AI tool you already use: no server, no daemon, no API key.

---

## 💡 What is Kio?

Kio is a set of **7 ready-to-use skill packages** (`SKILL.md` format) for AI coding tools such as **Claude Code**, **Cursor**, **Codex** and **Google Antigravity**. Each skill gives your assistant the process, reference material, scripts and checklists of one field: frontend, backend, QA, planning, growth/SEO, WordPress FSE and first-principles reasoning. You link them once; the assistant then follows them when your request matches, or when you call `/kio`.

There is nothing to host: no server, no background daemon, no API key. See [The 7 Core Engineering Skills](#-the-7-core-engineering-skills) for what each one covers.

---

## 🧰 The 7 Core Engineering Skills

All capabilities are organized into 7 self-contained master skills located in the `skills/` directory:

| Skill Directory | Focus Area | What It Gives Your AI Assistant |
| :--- | :--- | :--- |
| **[`skills/kio-frontend-craft`](skills/kio-frontend-craft)** | **Frontend UI/UX & Motion** | 79 searchable styles, 192 contrast-checked palettes, 74 font pairings and 22 framework rule sets (search CLI), 64 React/Next.js performance rules, Core Web Vitals (PageSpeed 95–100) audits, the 9-pass /unslop redesign SOP, Lenis smooth scroll, PDF → responsive HTML, React Native / Expo / SwiftUI guides, **free stock photos with credits** (Unsplash, Pexels, Openverse) and a **layout check** (`layout-check.js`: no edge spill, aligned rows, no wrapped buttons, no HTML entities like `&amp;`). |
| **[`skills/kio-backend-cloud`](skills/kio-backend-cloud)** | **Backend, DB & Cloud** | REST/GraphQL API and auth (anti-IDOR) design, payments with idempotent webhooks (Stripe, PayPal, VNPay, MoMo, PayOS, SePay — tested reference code that applies each event exactly once on PostgreSQL and SQLite), PostgreSQL / Supabase RLS, EXPLAIN-driven indexing, zero-downtime migrations, Docker, GitHub Actions, Terraform, RAG with pgvector, QLoRA fine-tuning, and MCP servers in Python or TypeScript. |
| **[`skills/kio-qa-security`](skills/kio-qa-security)** | **Automated QA & Security** | 4-quadrant test matrices and unit-test templates (Vitest, Pytest, Go), TDD and systematic debugging (root-cause tracing, flaky-test and test-pollution tools), deep review of risky diffs (blast radius, interrogation, arena), security review (two stages, 5 layers) plus Semgrep and CodeQL SAST (scripts + tests; the SAST folder is CC BY-SA 4.0), and Playwright E2E visual QA at 375/768/1440 px. |
| **[`skills/kio-core-delivery`](skills/kio-core-delivery)** | **Planning & Delivery** | Socratic brainstorming with browser Visual Companion mockups, Spec-Kit SDD templates (`constitution.md`, `spec.md`, `plan.md`, `tasks.md`), 2–5 minute atomic task plans, persistent file-based working memory (`task_plan.md`, `findings.md`, `progress.md`), parallel subagent dispatch, Git worktrees, multi-engine AI CLI routing (`kio_router.py`), and 5-pillar executive audit sign-off. |
| **[`skills/kio-growth-marketing`](skills/kio-growth-marketing)** | **Growth, CRO & SEO** | One router over 79 sub-skills: 53 growth modules (CRO, copywriting, pricing, email, ads, launches, analytics, RevOps…) and 26 SEO Engine sub-skills (technical SEO, schema, AI search / GEO, local SEO) with 19 agents and 60+ Python checks. |
| **[`skills/kio-wordpress-fse`](skills/kio-wordpress-fse)** | **WordPress FSE** | Step-by-step S0-S8 industrial pipeline for turning designs or HTML mockups into clean, 100% native Gutenberg block themes without plugin bloat. |
| **[`skills/kio-cognitive`](skills/kio-cognitive)** | **Deep Thinking & Rationale** | First-principles analysis methods, architectural decision walkthroughs ("Why & How"), and post-mortem failure analysis for continuous learning. |

---

## ⌨️ Quick Commands (Slash Commands)

No prompts to memorise: the installer copies these commands into `~/.claude/commands`, `~/.codex/prompts`, `~/.cursor/commands` and `~/.gemini/commands` (Gemini uses `.toml`). Type the command and your request after it, for example `/kio-fe landing page for a nail salon`. Skills still trigger on their own when a request matches; commands just call the right one faster.

| Command | Skill | Use it for |
| :--- | :--- | :--- |
| `/kio` | auto | Not sure which skill: Kio picks one and says which |
| `/kio-fe` | `kio-frontend-craft` | Building or reviewing UI, landing pages, design systems |
| `/kio-be` | `kio-backend-cloud` | APIs, databases, auth, payments, cloud |
| `/kio-qa` | `kio-qa-security` | Tests, code review, debugging, security |
| `/kio-plan` | `kio-core-delivery` | Planning and executing a multi-step change |
| `/kio-seo` | `kio-growth-marketing` | SEO audits, technical SEO, schema, content |
| `/kio-growth` | `kio-growth-marketing` | CRO, copywriting, launches, ads, email |
| `/kio-wp` | `kio-wordpress-fse` | WordPress block themes, the S0–S8 pipeline |
| `/kio-think` | `kio-cognitive` | First-principles analysis, comparing options |
| `/kio-update` | none | Check for a newer Kio release and update (shows versions, installs only on your yes) |
| `/kio-spec-constitution` → `/kio-spec-specify` → `/kio-spec-clarify` → `/kio-spec-plan` → `/kio-spec-tasks` → `/kio-spec-analyze` → `/kio-spec-implement` (plus `/kio-spec-checklist`, `/kio-spec-converge`) | `kio-core-delivery` | The Spec-Kit SDD flow, **no Spec-Kit CLI needed**; artifacts live in `specs/<NNN>-<name>/` |

Kio's command files carry a `kio-command:` marker; updates only overwrite files with that marker, a file of yours with the same name is left alone, and uninstall removes only Kio's files.

### 🤔 Why is the `/` menu so long?

The menu mixes two kinds of entries that point to the same skills:

- **7 skills** (`kio-frontend-craft`, `kio-qa-security`, ...): they trigger on their own when your request matches their description.
- **19 commands** (`/kio`, `/kio-fe`, ... and 9 `/kio-spec-*`): shortcuts that name the skill for you. `/kio-qa` and the `kio-qa-security` skill do the same job.
- Some tools also list sub-skills found under `references/` (for example a "Kio Seo" entry that belongs to `kio-growth-marketing`). They are not extra skills.

**You only need to remember three things:**

| You want | Type |
| :--- | :--- |
| Not sure which skill | `/kio <your request>` (it picks one and says which) |
| You know the area | `/kio-fe`, `/kio-be`, `/kio-qa`, `/kio-seo`, `/kio-growth`, `/kio-wp`, `/kio-think` |
| A multi-step change | `/kio-plan`; the `/kio-spec-*` steps are only for the Spec-Kit flow |

`/kio` picks one skill and follows its router; it does not run a whole chain by itself. For the full spec → plan → tasks → implement chain use `/kio-plan` or the `/kio-spec-*` steps in order.

**Tool notes**
- **Claude Code, Cursor, Gemini CLI:** commands appear in the `/` menu.
- **Codex:** commands are installed to `~/.codex/prompts` and are called `/prompts:kio`, `/prompts:kio-fe`, ... Some Codex versions or apps do not list custom prompts ("No commands"). The skills still work: pick one from the skill menu or just describe the task.
- **Windows with AppLocker / WDAC (PowerShell in Constrained Language Mode):** use v1.4.2 or later. Older versions stop with `Cannot invoke method. Method invocation is supported only on core types in this language mode`. Check the mode with `$ExecutionContext.SessionState.LanguageMode`, and run `.\setup.ps1` from a checkout if the piped `irm ... | iex` install fails.
- Commands are copied in the last installer step: if the installer stopped early you will see skills but no commands. Re-run it and restart the tool.

---

## 📊 Results & Benchmarks

### 🧪 Real-world test: without skill vs with Kio

Same request *"a fresh-seafood shop website in Da Nang with proper SEO"*, same model **Claude Sonnet 5.5**, one run without a skill and one with `kio-frontend-craft` (2026-11-22, Kio v1.3.0).

| Desktop 1440 px | Mobile 375 px |
|:---:|:---:|
| ![Desktop: left without skill, right with Kio](evaluations/showcase/seafood-v1.3/images/desktop-compare.jpg) | ![Mobile: left without skill, right with Kio](evaluations/showcase/seafood-v1.3/images/mobile-compare.jpg) |

| | Without skill | With Kio |
|---|:---:|:---:|
| **Blind judge score** (Opus 5.5, out of 100) | 75 | **86** |
| Lighthouse mobile — Perf / A11y / Best Practices / SEO | 100 / 96 / 100 / 100 | 98 / **100** / 96 / 100 ¹ |
| Contrast failures | main order button 2.8:1 | **0** |
| Order form | shows success but sends nothing | validates and sends the order |
| Mobile edge overflow / `&amp;` entities | 1 / 1 | **0 / 0** |
| Time | **1 min 55 s** | 8 min 2 s |
| Output / input tokens | **20,387 / 97,344** | 42,951 / 1,663,477 (96% cache reads) |
| Cost | **US$0.33** | US$0.86 |

¹ **Why is there also a 100 / 100 / 100 / 100?** The table shows the real result of this run. The Kio page lost points for 2 issues: a render-blocking Google Fonts stylesheet (Performance 98) and a missing favicon (Best Practices 96); the baseline scored 100 because it was only HTML + CSS with emoji and no photos. To confirm the cause, we **hand-fixed exactly those 2 lines** on the same Kio page (nothing else changed, see [`manual-fix.diff`](evaluations/showcase/seafood-v1.3/manual-fix.diff)) and re-ran Lighthouse: **100 / 100 / 100 / 100**. That number belongs to the hand-fixed page, **not** to a new skill run. Both fixes became mandatory skill rules in v1.3.0; the re-run below shows what the skill does on its own. Both versions of the page are in the [showcase](evaluations/showcase/seafood-v1.3/README.md) so you can run Lighthouse yourself.

**Re-run with the updated skill (same day, same prompt, same Sonnet 5.5, no hand edits):** the skill now loaded fonts without blocking and added a favicon on its own. This page used 5 real photos instead of 1, which exposed a new issue: on phones the hero downloaded the 1024 px file (184 KB), pushing mobile LCP to 3.2 s.

| Re-run | Without skill | With Kio |
|---|:---:|:---:|
| **Blind judge score** (Opus 5.5, both pages re-scored) | 78 | **86** |
| Lighthouse mobile | 100 / 96 / 100 / 100 | 92 / **100 / 100 / 100** |
| Lighthouse desktop | 100 / 96 / 100 / 100 | **100 / 100 / 100 / 100** |
| Misaligned rows desktop / mobile edge overflow | 2 / 1 | **0 / 0** |
| Time / cost | — | 5 min 35 s / US$1.05 |

The cause of Performance 92 was confirmed: adding a 768 px image step at ~60 KB lifts the same page to **99**. That fix is now in `stock_images.py` (480 / 768 px steps, harder compression for the hero) and is the "mobile LCP image ≤ ~80 KB" rule as of v1.3.2. Details: [showcase, re-run section](evaluations/showcase/seafood-v1.3/README.md#re-run-with-the-updated-skill).

Kio produced a clearly better page on design, accessibility and form reliability, at roughly 2.6–4× the time and tokens. One run per condition. Details, full-page screenshots, source code and data: [`evaluations/showcase/seafood-v1.3`](evaluations/showcase/seafood-v1.3/README.md).

### 🧪 Evaluation framework

Kio validates capability through transparent, reproducible benchmarks and live execution evidence. All **7 Master Skills** are defined and benchmarked against the **[Kio Skill Evaluation Framework](evaluations/SKILL_EVALUATION_FRAMEWORK.md)** across 21 test scenarios:

| Skill Group | Scenarios | Evaluation Focus | Benchmark Status | Raw Evidence Logs |
| :--- | :---: | :--- | :---: | :--- |
| **`kio-frontend-craft`** | 5 | Bento Grid, Mobile 375px, 9-Pass /unslop, Negative Tests (No forced Lenis, WCAG audit) | 🟢 5/5 Scenarios Defined | [`results/frontend/`](evaluations/results/frontend/) |
| **`kio-backend-cloud`** | 4 | Supabase RLS, Docker multi-stage, SQL injection prevention, Webhook idempotency | 🟢 4/4 Scenarios Defined | [`results/backend/`](evaluations/results/backend/) |
| **`kio-qa-security`** | 4 | 4-quadrant test matrices, Vitest unit tests, Reject mock-only solutions | 🟢 4/4 Scenarios Defined | [`results/qa/`](evaluations/results/qa/) |
| **`kio-core-delivery`** | 2 | 2-5 minute atomic task breakdowns, Elimination of ambiguous steps | 🟢 2/2 Scenarios Defined | [`results/core/`](evaluations/results/core/) |
| **`kio-growth-marketing`** | 2 | CRO funnel hierarchy, Valid Schema.org JSON-LD | 🟢 2/2 Scenarios Defined | [`results/marketing/`](evaluations/results/marketing/) |
| **`kio-wordpress-fse`** | 2 | Native Gutenberg block patterns, Zero external builder dependency | 🟢 2/2 Scenarios Defined | [`results/wordpress/`](evaluations/results/wordpress/) |
| **`kio-cognitive`** | 2 | First-principles trade-off analysis, Root cause post-mortems | 🟢 2/2 Scenarios Defined | [`results/cognitive/`](evaluations/results/cognitive/) |

> **Latest A/B re-run (v1.2.0, Claude Code, blind judge, n = 1):** average 7.61 → 8.01 (+0.40) across 10 scenarios; largest gain FE-01 (+3.8), 4 scenarios scored lower. Details and caveats in [`benchmark-summary.md`](evaluations/benchmark-summary.md); per-scenario evidence in [`results-v1.2.0/`](evaluations/results-v1.2.0/).

📖 **Review full evaluation framework and live logs**:  
👉 **[Read the Skill Evaluation Framework (SKILL_EVALUATION_FRAMEWORK.md)](evaluations/SKILL_EVALUATION_FRAMEWORK.md)**  
👉 **[Read Live Benchmark Summary & Evidence Logs (benchmark-summary.md)](evaluations/benchmark-summary.md)**

### ⚠️ What these results do not show
- **Small samples:** one landing-page test with one run per condition, and a 10-scenario benchmark with n = 1. The +0.40 average sits inside the ±1 point noise the report itself states.
- **Costs:** Kio's page took roughly 2.6–4× the time and tokens.
- **Routers:** in the v1.2.0 benchmark the model opened no reference file in 7 of 10 runs. The routers now carry "MANDATORY reads" rules (v1.4.1); a re-measurement is still pending.

---

## 🚀 Installation Guide

Kio installs as a set of safe, non-destructive symbolic links directly into your local AI tool configuration directories (`~/.claude/skills`, `~/.cursor/skills`, `~/.gemini/config/skills`).

> **🛡️ 5 Safety & Clean Design Guarantees**:
> - **⬇️ Install Skills**: Install all 7 skills or choose specific individual skills.
> - **✅ Preserve Existing Skills**: Never deletes, renames, or overwrites any of your personal skills (folders or custom symlinks).
> - **🔍 Realpath Target Inspection**: Verifies symlink destinations, updating only symlinks that point to the Kio repository.
> - **📋 Ownership Manifest**: Centrally tracks Kio-managed symlinks in `~/.kio/manifest.json`.
> - **🗑️ Clean Uninstall**: Safely removes only Kio-installed symlinks, leaving all other user skills untouched.

### Method 1: One-Line Installer (Recommended)

#### Linux / macOS / WSL:
```bash
curl -fsSL https://raw.githubusercontent.com/toanpham2111/kio-agent-system/main/setup.sh | bash
```

#### Windows (PowerShell):
```powershell
irm https://raw.githubusercontent.com/toanpham2111/kio-agent-system/main/setup.ps1 | iex
```

> **Which version gets installed:** the one-line installer installs the **latest release** (newest `v*` tag), never unreleased work on `main`. Re-run it to update. To choose another version: `curl -fsSL .../setup.sh | KIO_REF=v1.1.0 bash` (or `KIO_REF=main`); on Windows: `$env:KIO_REF="v1.1.0"; irm .../setup.ps1 | iex`. If an update fails, the installer prints the error and exits with code `2`; your skills keep using the copy already on disk.

**Staying up to date.** Kio does not update itself, so you choose when:
1. Type `/kio-update` in your AI tool: it compares your installed version with the latest release and, only if you agree, runs the installer.
2. Or re-run the one-line installer above; skills are links to `~/.kio/repo`, so every tool sees the new version at once. Restart the tool afterwards.
3. To hear about releases, use GitHub **Watch → Custom → Releases** on the repository.

---

### Method 2: Granular Installation & CLI Options

You can install single skills, inspect available packages, or safely uninstall at any time:

```bash
# List all 7 skills and their command shortcuts
./setup.sh --list

# Install all 7 skills (default)
./setup.sh

# Install specific skill(s) only (e.g. Frontend & QA)
./setup.sh --skill frontend,qa

# Safely uninstall Kio skills (preserves all your personal skills)
./setup.sh --uninstall
```

*(On Windows PowerShell, use `.\setup.ps1 -Skill frontend,qa` and `.\setup.ps1 -Uninstall`)*

---

### Method 3: Copy Single Skills to Your Project
If you prefer not to create global symlinks, simply clone the repository and copy any skill folder into your project's `.claude/skills/` or `.cursor/skills/` directory:
```bash
git clone https://github.com/toanpham2111/kio-agent-system.git
cp -r kio-agent-system/skills/kio-frontend-craft path/to/your-project/.claude/skills/
```

---

## 🛠️ How Skills Work in Your IDE

When an AI coding assistant (like Claude Code, Cursor, or Antigravity) reads a skill:

1. **Context-Triggered Loading**: The assistant inspects the `name` and `description` frontmatter inside each `SKILL.md`.
2. **On-Demand Activation**: When your prompt involves frontend styling, database design, or unit testing, the tool loads only the matching skill into memory—keeping token usage low.
3. **Actionable Instructions**: Rather than hallucinating rules, the AI follows the verified code snippets, directory conventions, and checklists documented in the skill.

---

## 🧩 Compatibility Matrix

Kio adopts the standard `SKILL.md` format. Verification statuses across major AI coding assistants and operating systems are categorized into four transparent tiers:

| AI Coding Tool | Auto-Discovery Path | Linux | macOS | Windows / WSL | Compatibility & Verification Tier |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **Claude Code** | `~/.claude/skills/` or `<project>/.claude/skills/` | ✅ | ✅ | 🟡 | 🟢 **Tested & Verified** (Full test evidence available) |
| **Google Antigravity** | `~/.gemini/config/skills/` | ✅ | ✅ | 🟡 | 🟢 **Tested & Verified** (Full test evidence available) |
| **Cursor IDE** | `~/.cursor/skills/` or `<project>/.cursor/skills/` | ✅ | ✅ | 🟡 | 🟡 **Tested** (Installation and basic discovery verified) |
| **Codex CLI** | `~/.codex/skills/` or `<project>/.codex/skills/` | ✅ | ✅ | 🟡 | 🟡 **Tested** (Installation and basic discovery verified) |
| **Windsurf / Cascade** | `<project>/.windsurf/skills/` | 🔄 | 🔄 | 🔄 | 🔵 **Supported** (Requires manual copy into project directory) |

> **Windows note:** the installers are tested on every push ([CI](https://github.com/toanpham2111/kio-agent-system/actions/workflows/installers.yml)): `setup.ps1` install, update, uninstall and `irm | iex` on Windows PowerShell 5.1 and PowerShell 7; `setup.sh` on Ubuntu and macOS. The Windows column stays 🟡 because each AI tool loading the skills on Windows has not been checked on a real machine.

> **Verification Tier Definitions**:
> - 🟢 **Tested & Verified**: Fully tested in production environments with benchmark logs available in `evaluations/results/`.
> - 🟡 **Tested**: Verified to install cleanly and parse `SKILL.md` specifications.
> - 🔵 **Supported (Manual)**: Specification-compatible; requires manual folder copy into the local workspace.

---

## ❓ Troubleshooting & FAQ

### Troubleshooting Common Issues

#### 1. Symbolic link privilege errors on Windows:
- **Symptom**: PowerShell outputs `New-Item: A required privilege is not held by the client` or fails to link skills.
- **Resolution**: Enable **Developer Mode** in Windows Settings (`Settings > Update & Security > For developers > Developer Mode: ON`), or run PowerShell with **Run as Administrator**.

#### 2. AI tool does not recognize skills after running the installer:
- **Symptom**: Launching `claude` or Cursor shows no change in assistant behavior.
- **Resolution**: Restart the AI CLI session (exit and restart `claude`) or reload the Cursor window to refresh the tool skill cache.

#### 3. Legacy skill name conflicts:
- **Symptom**: Existing symlinks or older versions cause the installer to skip updates.
- **Resolution**: Run `./setup.sh --uninstall` to cleanly remove previous Kio links, then rerun `./setup.sh` to recreate clean symlinks.

---

### Frequently Asked Questions (FAQ)

> **Q1: Does Kio slow down AI response times or consume excessive tokens?**  
> **No.** Kio operates on **Lazy Context Loading**. Your AI assistant only reads the title and brief description from the YAML frontmatter. Detailed skill instructions are only pulled into the active context when your prompt specifically demands them.

> **Q2: Do I need to buy additional API keys or pay extra fees?**  
> **No.** Kio consists of open-source Markdown skill files (`SKILL.md`). It runs directly inside your existing AI tool subscription without requiring any external Kio API key.

> **Q3: Can I install only the Frontend skill without installing the others?**  
> Yes. Simply run `./setup.sh --skill frontend` (or `.\setup.ps1 -Skill frontend` on Windows). The installer will link only `kio-frontend-craft`.

> **Q4: Does Kio run background daemons or consume system RAM?**  
> **No background processes are created.** Kio consists strictly of static markdown files and symbolic links. When your AI tool is closed, Kio consumes zero CPU cycles and zero RAM.

---

## 📚 Documentation

- [Per-skill usage guide](docs/skills.md): prompts and expected outputs for each skill
- [Repository structure](docs/structure.md)
- [Multi-agent workflows](docs/multi-agent.md): optional personas, engine router and memory notes
- [Evaluation framework](evaluations/SKILL_EVALUATION_FRAMEWORK.md) and [benchmark summary](evaluations/benchmark-summary.md)
- [Changelog](CHANGELOG.md) · [Release notes](docs/releases) · [Third-party notices](THIRD_PARTY_NOTICES.md)

---

## 🤝 Community

Kio is built in the open. Issues and pull requests are welcome: see **[CONTRIBUTING.md](CONTRIBUTING.md)** and the [Code of Conduct](CODE_OF_CONDUCT.md). Found a bug or a wrong claim? [Open an issue](https://github.com/toanpham2111/kio-agent-system/issues).

---

## 🔒 Security

To report a vulnerability privately, see **[SECURITY.md](SECURITY.md)**. The installer only creates links to its own folders, never overwrites your own skills, and keeps a manifest of what it created (`~/.kio/manifest.json`).

---

## 📄 License, Credits & Contributing

Kio is open source and licensed under the **[MIT License](LICENSE)**.

> **Exceptions to MIT.** Some third-party material keeps its own license; the full list with copyright lines is in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
>
> | Path | License | If you reuse it |
> | :--- | :--- | :--- |
> | `skills/kio-qa-security/references/codeql/` (Trail of Bits) | **CC BY-SA 4.0** ([LICENSE](skills/kio-qa-security/references/codeql/LICENSE)) | Credit Trail of Bits, say what you changed, release your versions under CC BY-SA 4.0 |
> | `skills/kio-growth-marketing/references/seo/subskills/seo-flow/` (AgriciDaniel/flow) | **CC BY 4.0** | Credit the author and say what you changed |
> | `skills/kio-backend-cloud/references/mcp-server-builder.md` (Anthropic `mcp-builder`) | **Apache 2.0** ([text](skills/kio-backend-cloud/references/LICENSE-APACHE-2.0.txt)) | Keep the notice, mark your changes |
> | `skills/kio-frontend-craft/assets/data/google-fonts.csv` (Google Fonts metadata) | Per font family: SIL OFL 1.1, Apache 2.0 or UFL | Check the family in `google-font-licenses.json` |
>
> Kio's own review process (`references/security-review.md`) is outside the CC BY-SA folder and stays MIT.

### 🙏 Credits & Third-Party Open Source Acknowledgments

Kio unifies, adapts, and extends open-source agent skill specifications, datasets, and tooling, mostly under the MIT License (see the exceptions table above). We gratefully acknowledge the original authors and contributors of the following upstream open-source projects (full copyright notices are preserved in **[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)**):
- **Marketing & CRO Frameworks**: Adapted and modularized from `marketingskills` by Corey Haines (`coreyhaines31/marketingskills`, MIT License).
- **Technical SEO & GEO Sub-skills**: Adapted and integrated from `claude-seo` & `claude-ads` by Daniel Agrici (`AgriciDaniel/claude-seo`, MIT License), Ivan Kuznetsov (`ivankuznetsov/claude-seo`, MIT License), and `flow` framework prompts (CC BY 4.0).
- **Frontend UI/UX Datasets**: Style, typography, and palette datasets in `skills/kio-frontend-craft/assets/data/` adapted from `ui-ux-pro-max-skill` (`nextlevelbuilder/ui-ux-pro-max-skill`, MIT License), Google Fonts metadata, and Phosphor Icons.
- **SDD & Agent Workflows**: Adapted and extended from `superpowers` by Jesse Vincent (`obra/superpowers`, MIT License), GitHub Spec-Kit (`github/spec-kit`, MIT License), and `planning-with-files` by Ahmad Adi (`OthmanAdi/planning-with-files`, MIT License).
- **React & Next.js Performance Rules**: The 64 rules in `skills/kio-frontend-craft/references/react/` are adapted from Vercel's React Best Practices (`vercel-labs/agent-skills`, MIT License).
- **MCP Server Builder**: `skills/kio-backend-cloud/references/mcp-server-builder.md` is adapted from Anthropic's `mcp-builder` skill (`anthropics/skills`, Apache License 2.0).
- **Copywriting, AI-visibility, conversion-tracking and RevOps references**: Profound (`retieedra-profound/skills-marketing-library`), Knowatoa (`Knowatoa/ai-visibility-skills`), ConversionKit (`ConversionKit/conversion-tracking`), Elias Stravik (`eliasstravik/rowbound`) and Ploy AI (`Ploy-AI/ploy-tools`), all MIT License.
- **Practitioner inspirations** (re-expressed, no text copied): Ivan Falco (`ivangfalco/ads-skills`) and Shiv Sakhuja / Gooseworks (`gooseworks-ai/gooseworks-ads-skills`).
- Every sub-skill keeps its original `author` in its frontmatter, with `maintainer: Kio System`. File-level detail lives in each skill's `THIRD_PARTY_NOTICES.md`.

Contributions, new skill modules, and bug fixes are welcome via GitHub pull requests:
- **Repository**: [https://github.com/toanpham2111/kio-agent-system](https://github.com/toanpham2111/kio-agent-system)
- **Author**: Toan Pham ([@toanpham2111](https://github.com/toanpham2111))
