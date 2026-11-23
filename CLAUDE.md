# Working on Kio

Conventions for AI agents (and humans) changing this repository.

## Every change that adds or changes a feature
1. Update **both** READMEs: `README.md` (Vietnamese) and `README.md` — the "7 core skills" table, the per-skill usage section, counts, script names and environment variables.
2. Check the GitHub **About** section (description, website, topics) of `toanpham2111/my-agent-skills` and `toanpham2111/kio-agent-system`. If it no longer matches, update it (`gh repo edit`) or give the maintainer the exact new text.
3. Add the change to `CHANGELOG.md` / `CHANGELOG.md` and to `docs/releases/vX.Y.Z.md`.
4. Every Vietnamese `*.md` that ships needs a complete `*.en.md` twin; the English sync (`scripts/sync_to_english_repo.sh`) rejects Vietnamese text.

## Skill layout (enforced by `python3 scripts/lint_skills.py`)
- Each `skills/<name>/` holds only `SKILL.md`, `SKILL.md`, `THIRD_PARTY_NOTICES.md`, `LICENSE*`, `references/` (docs, sub-skills), `scripts/` (code; tests in `scripts/tests/`) and `assets/` (templates, data, eval cases).
- Frontmatter: `name` (= folder), `description`, `license`, and `metadata: {author, version}`; nothing else at the top level.
- A new user-facing workflow gets a slash command in `commands/<name>.md` (frontmatter `description` + `argument-hint`, body ends with `Request: $ARGUMENTS` and the `kio-command:` marker line). Both installers copy it to Claude Code, Codex, Cursor and Gemini CLI.

## Before pushing
- Run `python3 scripts/lint_skills.py` and the skill test suites that cover what changed (for example `python3 -m pytest skills/kio-frontend-craft/scripts/tests`). CI (`.github/workflows/installers.yml`) runs the installers on Windows PowerShell 5.1/7, Ubuntu and macOS.
- Credit upstream authors in the skill's `THIRD_PARTY_NOTICES.md` and the root `THIRD_PARTY_NOTICES.md`; sub-skills keep their original `author` with `maintainer: Kio System`.

## Releasing
Follow `docs/RELEASE_WORKFLOW.md` (`scripts/release.sh vX.Y.Z "title" --notes-file docs/releases/vX.Y.Z.md`).
