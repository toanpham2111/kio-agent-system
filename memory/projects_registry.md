# 🗂️ Kio Global Memory: Projects Registry (Template)

> Location: `~/.kio/memory/projects_registry.md` (Synchronized across all projects on your workstation)
> Guide: Central registry tracking active projects, local port allocations, and database names to prevent port and environment collisions.

---

## 📋 Active Projects Registry

| Project Name | Workspace Path | Tech Stack | Active Port | Database Name | Notes |
|---|---|---|---|---|---|
| **example-shop** | `~/Projects/example-shop` | Next.js / PostgreSQL | `8080` (Web), `5433` (DB) | `example_shop` | Example row: replace with your projects. |
| **kio-agent-system** | `/path/to/kio-agent-system` | Python / Shell / Markdown / HTML / JS | — | — | Central Kio rule and skill system repository. |

---

## 🛡️ Port Allocation & Project Scaffolding Rules
1. **Recommended Safe Port Range**: `8080` – `8999`.
2. **Pre-Flight Conflict Check**: Before scaffolding a project, scan this table and detect available free ports.
3. **Automatic Registration**: Upon successfully provisioning a new local project, add a row to this registry.
