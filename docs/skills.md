# 📖 Per-Skill Usage Guide

Prompts and expected outputs for each of the 7 skills. Back to the [README](../README.md).


Each skill is designed to activate on demand when given a relevant prompt. Use the real-world prompt examples below:

## 1. `kio-frontend-craft`
- **When to Use**: Building web interfaces, mobile layouts, fixing alignment bugs, removing generic AI styling, or auditing color contrast.
- **Stock photos**: when you have no real photos, the skill fetches free stock images with credits. Set `UNSPLASH_ACCESS_KEY` (unsplash.com/developers) or `PEXELS_API_KEY` (pexels.com/api) for the best results; without a key it uses Openverse (openly licensed, smaller images).
- **Prompt Example**:
  ```text
  "Build a responsive SaaS analytics dashboard in React + Tailwind CSS with MRR metric cards, a recent transactions table, dark mode support, and an empty state."
  ```
- **Expected Output**:
  - Asymmetric Bento Grid layout with defensive padding that never clips screen borders at `375px` or `1440px`.
  - Palette selected from curated system with 80/15/5 distribution (80% neutral background, 15% structure, 5% accent).
  - Clean interactive buttons with defined hover, focus-visible, and active states. No cliche purple gradients.

## 2. `kio-backend-cloud`
- **When to Use**: Designing REST or GraphQL endpoints, drafting database migrations, securing PostgreSQL tables with RLS, and writing Dockerfiles.
- **Prompt Example**:
  ```text
  "Create a PostgreSQL schema for a multi-tenant project management app in Supabase with strict Row-Level Security policies."
  ```
- **Expected Output**:
  - Production-ready SQL with explicit `ENABLE ROW LEVEL SECURITY;`.
  - Distinct policies for `SELECT`, `INSERT`, `UPDATE`, and `DELETE` scoped to `auth.uid()` and `tenant_id`.
  - B-Tree indexes on foreign keys to prevent sequential table scans.

## 3. `kio-qa-security`
- **When to Use**: Designing test plans, generating test case matrices, writing unit tests (Vitest/Pytest), and setting up Playwright visual tests.
- **Prompt Example**:
  ```text
  "Create a 4-quadrant test case matrix and write comprehensive Vitest unit tests for user authentication (JWT login) including brute-force rate limit edge cases."
  ```
- **Expected Output**:
  - Structured matrix covering Happy Path, Boundary, Edge Case, and Failure Mode.
  - Complete Vitest test suite with safe external mocks, clear assertions, and >90% branch coverage.

## 4. `kio-core-delivery`
- **When to Use**: Breaking down large epics into small steps, writing technical specification documents, or coordinating multi-engine task delivery.
- **Long tasks**: for work with 5+ steps the skill keeps a plan on disk (`.planning/<date>-<task>/task_plan.md`, `findings.md`, `progress.md`) via `scripts/planning/init-session.sh`, and `check-complete.sh` reports unfinished phases before you stop.
- **Prompt Example**:
  ```text
  "I want to build an automated PDF invoice export service. Create an SDD specification document and break it down into 2-5 minute atomic tasks."
  ```
- **Expected Output**:
  - Structured spec defining Inputs, Outputs, Failure Cases, and Dependencies.
  - Ordered checklist of atomic tasks (e.g., Task 1: HTML template, Task 2: PDF renderer, Task 3: API route, Task 4: Unit tests).

## 5. `kio-growth-marketing`
- **When to Use**: Landing page conversion optimization, pricing psychology, technical SEO audits, and Schema.org structured data.
- **Prompt Example**:
  ```text
  "Restructure this coding bootcamp landing page to maximize signups, and generate valid Schema.org Course JSON-LD markup."
  ```
- **Expected Output**:
  - High-converting 6-tier page hierarchy (Hero $\rightarrow$ Social Proof $\rightarrow$ Core Benefits $\rightarrow$ Curriculum $\rightarrow$ Pricing $\rightarrow$ FAQ).
  - Syntactically valid JSON-LD `@type: "Course"` snippet ready for Google Rich Snippets.

## 6. `kio-wordpress-fse`
- **When to Use**: Converting HTML/Figma mockups into Gutenberg Full Site Editing (FSE) block patterns, themes, or templates.
- **Prompt Example**:
  ```text
  "Convert this Hero section design into a native WordPress Gutenberg Block Pattern for Full Site Editing."
  ```
- **Expected Output**:
  - Clean pattern file placed in `patterns/` using native comments (`<!-- wp:group -->`, `<!-- wp:heading -->`, `<!-- wp:buttons -->`).
  - Seamless styling connected with `theme.json` without hardcoded CSS overrides.

## 7. `kio-cognitive`
- **When to Use**: Architecture trade-off evaluations, first-principles reasoning, and post-mortem root cause analysis.
- **Prompt Example**:
  ```text
  "Evaluate the trade-offs between storing file uploads directly as database BLOBs versus S3 Object Storage Presigned URLs from first principles."
  ```
- **Expected Output**:
  - Multi-dimensional breakdown: database I/O overhead, network latency, backup complexity, server bandwidth, and operational cost.
  - Concrete technical recommendation mapped to specific throughput thresholds.
