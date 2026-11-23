# 🤖 Multi-Agent Workflows & Orchestration

Optional assets beyond standalone skills. Back to the [README](../README.md).


For developers who want an orchestrated team experience beyond standalone skills, Kio includes optional multi-agent assets:

## 1. The 6 Sub-Agent Personas (`agents/`)
If your environment supports custom agents or sub-agent delegation, you can invoke specialized roles:
- **`kio`**: Coordinates high-level planning and reviews final diffs.
- **`agent-pd`**: Gathers requirements and writes task specs before coding begins.
- **`agent-fe`**: Implements client-side views and animations.
- **`agent-be`**: Handles database models, server endpoints, and cloud infra.
- **`agent-qa`**: Writes unit tests, checks for regressions, and runs Playwright.
- **`wp-leader`**: Orchestrates WordPress theme development.

## 2. Multi-Engine Task Routing (`kio_router.py`)
Located in `skills/kio-core-delivery/scripts/kio_router.py`, this optional utility helps recommend which CLI tool fits a specific subtask best:
- **Claude Code (`claude -p`)**: Recommended for frontend craft, CSS micro-interactions, and nuanced copywriting.
- **OpenAI Codex (`codex exec`)**: Recommended for heavy algorithm tasks, complex SQL queries, and unit test generation.
- **Google Antigravity (`agy -p`)**: Recommended for large monorepo context scanning (1M-2M tokens) and document extraction.

## 3. Persistent Memory Notes (`memory/`)
A simple file-based memory system allowing your local tools to remember:
- Recurring bugs and lessons learned (`memory/global_learnings.md`)
- Preferred tech stacks (`memory/user_profile.md`)
- Local development ports to avoid port collisions (`memory/projects_registry.md`)
