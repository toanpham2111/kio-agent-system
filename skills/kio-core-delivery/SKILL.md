---
name: kio-core-delivery
description: "Author Specification-Driven Development (SDD) documents and decompose features into verifiable 2-5 minute atomic tasks. Use when scoping requirements, writing technical specs, or planning project execution."
author: Toan Pham / Kio System
version: 1.0.2
---

# 👑 Kio Core Delivery — Specification & Atomic Task Planning (`kio-core-delivery`)

The technical specification, atomic task breakdown, and delivery workflow skill of the Kio System. Integrates 9 core delivery modules:

---

## 🧭 Core 9 Delivery Modules Matrix

| Module | Resource / Tooling | Core Mission & Deliverables |
| :--- | :--- | :--- |
| **1. 5-Pillar Quality Audit** | Executive Quality Gate | Enforces the 5-Pillar Audit (Security, Lean Code <700 lines, Anti-Slop UI/UX, SDD, Business Alignment). Final Sign-Off. |
| **2. Multi-Engine Router** | `scripts/kio_router.py` | Dynamically classifies tasks and recommends the optimal AI CLI (`claude` for UI/UX, `codex` for Algorithms/DB/Tests, `agy` for 1M+ Context & Monorepos). |
| **3. Socratic Brainstorming** | PRD & Intent Discovery | Discovers root user intent via high-leverage Socratic inquiry, extracts PRDs, uncovers edge cases, and optimizes conversion (CRO). |
| **4. Specification-Driven Dev (SDD)** | `templates/` | Enterprise architecture via 4 core artifacts: `constitution.md` (boundaries), `spec.md` (Gherkin user stories), `plan.md` (architecture & data models), `tasks.md` (atomic checklist). |
| **5. Atomic Plan Writing** | 2–5m Task Breakdown | Decomposes complex epics into independent 2–5 minute Atomic Tasks with verifiable checkpoint commands. |
| **6. Disciplined Plan Execution** | TDD & Two-Stage Review | Enforces disciplined execution adhering to TDD (Red-Green-Refactor) and mandatory two-stage review (Spec compliance & Code quality). |
| **7. Persistent File Planning** | Cross-Session State | Preserves cross-session state and architectural memory in `memory/` (`task_plan.md`, `progress.md`, `findings.md`). |
| **8. Parallel Agent Dispatcher** | Concurrent Sub-agents | Coordinates concurrent sub-agents across isolated workstreams with zero context collision. |
| **9. Isolated Workspace Management** | Git Worktrees | Manages isolated Git worktrees and feature branches to execute parallel initiatives cleanly without merge conflicts. |

---

## 🚀 1. End-to-End Delivery SOP

```mermaid
flowchart TD
    User["User Request"] --> Triage{"Task Complexity Triage (Tier 1 / 2 / 3)"}
    
    Triage -->|"Tier 1: < 30s (Hotfix/CSS)"| FastTrack["🚀 Express Fast-Track (Minimal Diff, direct edit, fast verify)"]
    
    Triage -->|"Tier 2 & 3: New Feature"| Brainstorm["💡 Socratic Brainstorming & PRD Extraction"]
    Brainstorm --> SDD["📐 Specification-Driven Development (.spec-kit/)"]
    SDD --> Plan["⚡ Atomic Plan Writing (2-5 min tasks checklist)"]
    
    Plan --> Dispatcher["🤖 Multi-Engine Router (scripts/kio_router.py)"]
    Dispatcher -->|"UI/UX Craft"| Claude["🟣 Claude Code CLI"]
    Dispatcher -->|"Logic & Tests"| Codex["🟢 OpenAI Codex CLI"]
    Dispatcher -->|"Large Context"| Agy["🔵 Antigravity CLI"]
    
    Claude --> ParallelIntegrate["📦 Checkpoint Verification & Integration"]
    Codex --> ParallelIntegrate
    Agy --> ParallelIntegrate
    
    ParallelIntegrate --> Audit["👑 Kio 5-Pillar Executive Audit"]
    Audit --> SignOff["🏆 Executive Sign-Off & Delivery"]
```

---

## 🛠️ 2. Integrated Utility Arsenal

### A. CLI Multi-Engine Router:
```bash
# View engine availability matrix
kio-router matrix

# Classify intent and get routing recommendation
kio-router classify "Design a responsive landing page hero with smooth Lenis scroll"

# Dispatch task with dry-run preview
kio-router dispatch "Write comprehensive unit tests for Stripe webhook idempotency" --dry-run
```

### B. Visual Brainstorming Companion Server:
```bash
# Start visual brainstorming companion server (ports 3333-3343)
bash skills/kio-core-delivery/scripts/start-server.sh

# Stop server after brainstorming completes
bash skills/kio-core-delivery/scripts/stop-server.sh
```
