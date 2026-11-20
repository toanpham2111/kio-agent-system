---
name: kio-qa-security
description: "Kio Master QA, Deep Review, Security & Verification Powerhouse — Unifies TDD Red-Green-Refactor, Systematic Debugging (Iron Law & Rule of 3), Zero-False-Completion Evidence Gates, Mandatory Feature Test Cases, Deep Review & Adversarial Suite (Blast Radius analysis outside diff, adversarial interrogation >300 lines, multi-solution arena, permanent bug elimination), Two-Stage Code Reviews, SAST Static Analysis (Semgrep & CodeQL), 4-Layer Anti-Bot Spam Defense, and Playwright Headless Browser Visual E2E Verification across 1440px / 768px / 375px."
author: Toan Pham / Kio System
version: 2.0.0
---

# 🧪 Kio Master QA, Deep Review, Security & Verification Powerhouse (`kio-qa-security`)

The unified quality gatekeeper, adversarial code reviewer, and security testing powerhouse of the Kio System. Integrates 5 core verification engines:

---

## 🧭 Core 5 Verification Engines Matrix

| Engine | Functional Module | Core Mission & Deliverables |
| :--- | :--- | :--- |
| **1. Unit Test & Test Cases**| `kio-test-craft` | Automated **4-Quadrant Test Case Matrix** generation (Happy Path, Boundary Value, Edge Case, Failure Mode, Security Auth). Automated **standardized Unit Tests** (Vitest/Jest, Pytest, Go test, PHPUnit) enforcing Disciplined Mocking (mock only external side-effects, never mock the unit under test). See details in `references/unit-testing-and-test-cases.md`. |
| **2. Kio QA Engine** | `kio-qa` | TDD Red-Green-Refactor, Systematic Debugging (`NO FIXES WITHOUT ROOT CAUSE FIRST`), **Zero-False-Completion** gate (absolute ban on declaring tasks done without live test execution), **Mandatory Feature Test Cases** (100% of new features must ship with comprehensive test suites). |
| **3. Deep Review Suite** | `kio-deep-review` | Blast radius impact analysis outside the git diff (**`blast-radius`**), adversarial interrogation on diffs >300 lines (**`interrogate`**), multi-solution performance competitions (**`arena`**), and permanent bug elimination across architecture and types (**`correct`**). |
| **4. Security & SAST Audit** | `kio-security-review` | Two-stage code review (Spec Compliance ➔ Code Quality), Kio Enterprise 5-layer quality standards, SAST static analysis (Semgrep & CodeQL taint tracking), **4-Layer Anti-Bot Spam Defense** (Honeypot, Timestamp <3s check, IP Rate Limiting, Nonce/Turnstile). |
| **5. Playwright Browser E2E** | `playwright` | Real headless Chromium browser simulating user journeys E2E, side-by-side 1:1 visual diffing against design mockups, and responsive defensive spacing checks across 3 viewports: **Desktop (1440px), Tablet (768px), Mobile (375px)**. |

---

## 🛡️ Strict Quality Verification Gates

1. **Zero Unverified Completion**: Every declaration of completion must cite fresh terminal command outputs, exit code 0, and 0 failing tests.
2. **Blast Radius Analysis Before Merge**: For any architectural or API refactoring, inspect and test consumers outside the git diff to prove zero cascading regressions.
3. **👁️ Visual Side-by-Side Verification (1:1 Ground Truth)**:
   - When a design source exists (HTML / PDF / Image mockup): Open real Playwright screenshots and design files side-by-side.
   - If AI deviates from the design, invents colors, or changes typography ➔ **REJECT IMMEDIATELY and require a minimal fix loop**.
