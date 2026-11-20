# 🧪 Kio Skill Evaluation Framework

A unified quality evaluation and verification system for all **7 Master Skills** in Kio. Purpose: **Prove engineering quality through verifiable test scenarios and concrete criteria rather than subjective claims.**

---

## 🧭 Evaluation Rubric Structure

Each Skill is evaluated across 6 dimensions:
1. **Real-world Test Scenarios**: Practical tasks requested by developers in everyday software engineering.
2. **Input Prompts**: Standardized prompts to submit to AI coding assistants (Claude Code, Cursor, Codex, Antigravity).
3. **Expected Behavior**: How the AI should reason and select the matching skill without hallucinations.
4. **Expected Output Criteria**: Measurable code and design standards the generated solution must satisfy.
5. **Negative Test Cases**: Verifying that the AI **DOES NOT** exhibit harmful habits (e.g. forcing unnecessary libraries, over-mocking, or outputting empty placeholders).
6. **Quality Score (1-10)**: Clear rubric to determine Pass/Fail status.

---

## 🧰 Evaluation Matrix for the 7 Master Skills

### 1. `kio-frontend-craft` (Frontend UI/UX & Motion)

| Code | Test Scenario | Input Prompt | Expected Behavior | Expected Output Criteria |
| :--- | :--- | :--- | :--- | :--- |
| `FE-01` | **Build SaaS Dashboard** | *"Build a responsive analytics dashboard in React with Tailwind, showing MRR charts, active users, and a recent transactions table."* | Activates `kio-frontend-craft`, applies color tokens from `colors.csv` | Asymmetric Bento grid layout, no generic purple gradients, includes loading and empty states. |
| `FE-02` | **Mobile Landing Page** | *"Design a mobile-first landing page for an organic coffee subscription service."* | Enforces Defensive Spacing & Zero-Edge-Bleed standards | Fluid layout at `375px`, minimum `44px` touch targets, zero text or buttons touching screen boundaries. |
| `FE-03` | **Refactor Generic AI UI** | *"Refactor this generic AI-generated landing page to look like a bespoke studio website."* | Activates the 9-Pass De-Slopping SOP (`/unslop`) | 9-step refactor: removes decorative emojis, replaces with Phosphor icons, applies 80/15/5 color ratios. |
| `FE-04` | ⛔ **Negative: No Forced Animation** | *"Create a simple static documentation layout in pure HTML/CSS without any animations."* | **DOES NOT** force Lenis smooth scroll or animation libraries | Delivers clean, standard HTML/CSS without unwanted runtime dependencies. |
| `FE-05` | ⛔ **Negative: Accessibility Review** | *"Audit this button: `<button style='color: #777; background: #888;'>Submit</button>`"* | Detects severe color contrast failures based on WCAG standards | Flags contrast ratio failure (< 4.5:1) and recommends accessible AA/AAA color values. |

---

### 2. `kio-backend-cloud` (Backend, Database & Cloud)

| Code | Test Scenario | Input Prompt | Expected Behavior | Expected Output Criteria |
| :--- | :--- | :--- | :--- | :--- |
| `BE-01` | **Supabase Multi-tenant RLS** | *"Create a PostgreSQL schema for a multi-tenant project management app in Supabase with strict Row-Level Security."* | Isolates `tenant_id` and enables RLS across all tables | Explicit `ENABLE ROW LEVEL SECURITY`, distinct policies for `SELECT`, `INSERT`, `UPDATE`, `DELETE` using `auth.uid()`. |
| `BE-02` | **Docker Multi-Stage Build** | *"Write a production Dockerfile for a Next.js 14 App Router project."* | Uses multi-stage build (deps, builder, runner) | Optimized image size (< 150MB), runs as non-root user, separates build-time dependencies. |
| `BE-03` | ⛔ **Negative: SQL Injection Guard** | *"Write a login query searching for a user by email in PostgreSQL."* | Employs parameterized queries or safe ORM access | **BANS** raw string concatenation (`WHERE email = '` + email + `'`). Enforces `$1` parameters. |
| `BE-04` | ⛔ **Negative: Idempotent Webhook** | *"Implement a Stripe checkout.session.completed webhook handler."* | Implements duplicate event verification (Idempotency) | Stores `event_id` in database to prevent double-crediting when Stripe retries deliveries. |

---

### 3. `kio-qa-security` (QA Automation & Security)

| Code | Test Scenario | Input Prompt | Expected Behavior | Expected Output Criteria |
| :--- | :--- | :--- | :--- | :--- |
| `QA-01` | **Unit Test Suite via TDD** | *"Write unit tests using Vitest for a cart discount calculator supporting percent, fixed amount, and coupon expiration."* | Generates a 4-Quadrant Test Matrix before code | Covers 4 quadrants: Happy Path, Boundary Value, Edge Case (negative values), Failure Mode (expired coupons). |
| `QA-02` | **Playwright Visual E2E Check** | *"Write an E2E test script in Playwright to verify the checkout flow on desktop and mobile."* | Implements multi-viewport responsive testing | Executes flow across `1440px` and `375px`, captures screenshots as verification artifacts. |
| `QA-03` | ⛔ **Negative: Ban Mock-Everything** | *"Write unit tests for a string slugify utility function."* | **DOES NOT** mock internal function logic | Tests the function directly with real string inputs, bans mocking regex or pure string handlers. |
| `QA-04` | ⛔ **Negative: Zero-False-Completion** | *"I made a change to the auth middleware. Is it done?"* | Enforces Zero-False-Completion Gate | Demands fresh terminal test execution, only signs off when exit code is 0 with 0 failing tests. |

---

### 4. `kio-core-delivery` (Planning & Delivery)

| Code | Test Scenario | Input Prompt | Expected Behavior | Expected Output Criteria |
| :--- | :--- | :--- | :--- | :--- |
| `DEL-01`| **Atomic Task Decomposition** | *"Plan the implementation of user notification center using WebSockets and React."* | Decomposes project into 2-5 minute atomic tasks | Structured sequence: Socket server setup ➔ Client listener ➔ UI badge ➔ Test suite. |
| `DEL-02`| ⛔ **Negative: No Bloated Plans** | *"Add a simple dark mode toggle button to the navbar."* | Categorizes task as Trivial | Provides 1-2 rapid implementation steps, does not create an over-engineered 10-phase plan. |

---

### 5. `kio-growth-marketing` (Growth, CRO & SEO)

| Code | Test Scenario | Input Prompt | Expected Behavior | Expected Output Criteria |
| :--- | :--- | :--- | :--- | :--- |
| `GRO-01`| **CRO Pricing Page Audit** | *"Review this pricing page copy and suggest conversion improvements for our B2B SaaS."* | Applies behavioral pricing psychology and AARRR | Analyzes checkout friction, recommends decoy pricing, and introduces risk-reversal guarantees. |
| `GRO-02`| ⛔ **Negative: Ban AI Cliches** | *"Write hero copy for an AI customer support bot."* | **BANS** generic marketing buzzwords | Avoids cliches: *"Unleash your potential"*, *"Game-changing"*, *"Revolutionize"*. Uses concrete metrics. |

---

### 6. `kio-wordpress-fse` (WordPress FSE Engineering)

| Code | Test Scenario | Input Prompt | Expected Behavior | Expected Output Criteria |
| :--- | :--- | :--- | :--- | :--- |
| `WP-01` | **Native Block Theme Pattern** | *"Convert this HTML call-to-action banner into a WordPress FSE block pattern."* | Transforms into native Gutenberg block markup | Employs `<!-- wp:group -->`, `<!-- wp:heading -->`, `<!-- wp:buttons -->`, zero dirty shortcodes or inline CSS. |
| `WP-02` | ⛔ **Negative: No Bloated Builders** | *"Build a portfolio grid in WordPress."* | Uses Core Query Loop block and `theme.json` | **BANS** installing heavy page builder plugins or legacy jQuery libraries. |

---

### 7. `kio-cognitive` (Deep Thinking & Architecture)

| Code | Test Scenario | Input Prompt | Expected Behavior | Expected Output Criteria |
| :--- | :--- | :--- | :--- | :--- |
| `COG-01`| **First-Principles Architecture** | *"Should we use Redis or PostgreSQL for user session storage in our high-traffic app?"* | Evaluates tradeoffs from first principles | Compares I/O latency, persistence guarantees, RAM operating costs, and single-point-of-failure risks. |
| `COG-02`| ⛔ **Negative: No Guessing** | *"Our backend is responding slowly, why?"* | Demands profiling metrics first | Requests profiling data (DB query duration, memory heap, network waterfall) before prescribing solutions. |

---

## 📊 Quality Scoring Rubric

Each test scenario is evaluated on a 10-point scale:
- **9 – 10 (Production Ready)**: Meets 100% of output criteria, passes all negative tests, clean code with zero placeholders.
- **7 – 8 (Pass)**: Fulfills core functional criteria, passes negative tests, may require minor formatting adjustments.
- **< 7 (Fail)**: Violates negative test cases (uses generic cliches, forces unneeded libraries, breaks layout, includes `// TODO` stubs).
