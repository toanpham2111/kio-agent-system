
# 🔍 Kio Deep Review & Adversarial Powerhouse

Kio's deepest review toolkit for adversarial challenge and side-effect prevention. It unifies four pstack capabilities: **Blast Radius**, **Adversarial Interrogation**, **Multi-Solution Arena** and **Permanent Correction**. Full procedures: [`blast-radius.md`](blast-radius.md), [`interrogate.md`](interrogate.md), [`arena.md`](arena.md), [`correct.md`](correct.md).

```
                           🔍 KIO DEEP REVIEW POWERHOUSE
                                         │
        ┌───────────────────┬────────────┴───────┬───────────────────┐
        ▼                   ▼                    ▼                   ▼
     [MODE 1]            [MODE 2]             [MODE 3]            [MODE 4]
   BLAST-RADIUS        INTERROGATE             ARENA              CORRECT
 Breakage beyond diff  Adversarial review   Solution shoot-out  Stop repeat bugs
• Look beyond diff   • Break diffs >300   • 2 parallel runners • Architecture > Type
• Must run tests     • Guard auth/payment • Score by rubric    • Lint > Test
• 0 hand-waving      • Real repro command • Graft the best     • Prove on the past
```

---

## 🎯 4 Operational Modes

### 💥 Mode 1: `blast-radius` (what breaks outside the diff)
* **Goal**: find anything at risk of breaking **outside the git diff** before merge or release.
* **"No hand-waving" rule**:
  1. A plausible-sounding analysis with no command proving it is **worthless**.
  2. Name the **1–2 key facts** that guarantee safety (e.g. *"this function only reads expired cache entries and never overwrites new data"*).
  3. **Look where grep/symbol search misses things**:
     - JSON shapes returned to web / mobile clients.
     - Database columns and types.
     - Microtask ordering, mount / unmount lifecycle.
     - Feature flags and code 2–3 steps downstream.
  4. **Prove it with a real run**: write a verification script or test that runs the real code and exits 0.

### ⚔️ Mode 2: `interrogate` (adversarial review)
* **Triggers**:
  - A git diff larger than **300 lines of code**.
  - Or changes touching sensitive areas: **auth/permissions**, **payments/webhooks**, **DB migrations**, **concurrency/queues**, **file I/O & data deletion**.
* **Adversarial rules**:
  - Play the saboteur: hunt for logic gaps and bizarre edge cases that crash the app.
  - **Only findings with a real repro command count**: drop remarks about style, naming or structure. Keep only findings with a command that shows the code behaving wrongly.
  - Do not change code yourself; report the repro commands so the developer fixes them.

### 🏟️ Mode 3: `arena` (parallel solution shoot-out)
* **Trigger**: hard algorithmic problems, uncertain architecture choices, or a real risk of picking the wrong direction early.
* **Process**:
  1. **Frame**: one shared prompt with 3–6 quantitative scoring criteria (rubric).
  2. **Fan out**: implement 2 independent solutions in 2 separate worktrees.
  3. **Pick & graft**: score both against the rubric, take the better one as the base and graft in the strongest modules of the other.

### 🛡️ Mode 4: `correct` (make recurring bugs impossible)
* **Trigger**: a business-logic or convention bug that has happened **2 or more times** in the project.
* **Fix it at the highest possible level**:
  1. **Remove it through architecture**: one owner per piece of state; hide internals so a wrong import fails immediately.
  2. **Enforce it with the type system (TypeScript/Pydantic)**: make the wrong state impossible to compile.
  3. **Add a linter rule** whose message names the file/function to use instead.
  4. **Write a regression test** that fails if the old bug comes back.
  5. Only then write documentation / rules.

---

## 💻 Usage in Conversation & CLI

### 1. Ask in natural language:
* *"Use deep review to check the blast radius of this PR"* ➔ `blast-radius` mode.
* *"Use deep review to interrogate the payment branch diff"* ➔ `interrogate` mode.
* *"Use deep review to pit 2 solutions against each other for this cache problem"* ➔ `arena` mode.
* *"Use deep review to permanently fix this form-spam bug"* ➔ `correct` mode.

### 2. Triggered automatically by Kio:
* When you call `@kio` on a diff `> 300 lines` or on sensitive modules (auth, Stripe, migrations), Kio **opens `references/deep-review/`** to protect your repository before sign-off.
