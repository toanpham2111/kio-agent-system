---
name: kio-qa-security
description: "Generate 4-quadrant test matrices, write unit tests (Vitest, Pytest, Go) with disciplined mocking, run Playwright E2E checks, and perform security reviews. Use when writing tests, debugging, or auditing code."
author: Toan Pham / Kio System
version: 1.0.2
---

# 🧪 Kio QA, Code Review & Security Verification (`kio-qa-security`)

The quality assurance, code review, and security testing skill of the Kio System. Integrates 5 core verification modules:

---

## 🧭 Core 5 Verification Modules Matrix

| Module | Reference / Methodology | Core Mission & Deliverables |
| :--- | :--- | :--- |
| **1. Unit Test & Test Cases**| `references/unit-testing-and-test-cases.md` | Automated **4-Quadrant Test Case Matrix** generation (Happy Path, Boundary Value, Edge Case, Failure Mode, Security Auth). Automated **standardized Unit Tests** (Vitest/Jest, Pytest, Go test, PHPUnit) enforcing Disciplined Mocking (mock only external side-effects, never mock the unit under test). |
| **2. TDD & Root-Cause QA** | TDD & Systematic Debugging | TDD Red-Green-Refactor, Systematic Debugging (`NO FIXES WITHOUT ROOT CAUSE FIRST`), **Zero-False-Completion** gate (absolute ban on declaring tasks done without live test execution), **Mandatory Feature Test Cases** (100% of new features must ship with comprehensive test suites). |
| **3. Deep Code Review** | Blast Radius & Adversarial Review | Blast radius impact analysis outside the git diff (**`blast-radius`**), adversarial review on diffs >300 lines (**`interrogate`**), multi-solution performance comparisons (**`arena`**), and permanent bug elimination across architecture and types (**`correct`**). |
| **4. Security & SAST Audit** | OWASP & SAST Verification | Two-stage code review (Spec Compliance ➔ Code Quality), SAST static analysis (Semgrep & CodeQL taint tracking), **4-Layer Anti-Bot Spam Defense** (Honeypot, Timestamp <3s check, IP Rate Limiting, Nonce/Turnstile). |
| **5. Playwright Browser E2E** | Headless Chromium Visual QA | Real headless Chromium browser simulating user journeys E2E, side-by-side 1:1 visual diffing against design mockups, and responsive defensive spacing checks across 3 viewports: **Desktop (1440px), Tablet (768px), Mobile (375px)**. |

---

## 🛡️ Strict Quality Verification Gates

1. **Zero Unverified Completion**: Every declaration of completion must cite fresh terminal command outputs, exit code 0, and 0 failing tests.
2. **Blast Radius Analysis Before Merge**: For any architectural or API refactoring, inspect and test consumers outside the git diff to prove zero cascading regressions.
3. **👁️ Visual Side-by-Side Verification (1:1 Ground Truth)**:
   - When a design source exists (HTML / PDF / Image mockup): Open real Playwright screenshots and design files side-by-side.
   - If AI deviates from the design, invents colors, or changes typography ➔ **REJECT IMMEDIATELY and require a minimal fix loop**.
