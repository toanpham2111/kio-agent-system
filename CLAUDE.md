# Working on Kio

Conventions for AI agents (and humans) changing this repository.

## Every change that adds or changes a feature
1. Update **both** READMEs: `README.md` (Vietnamese) and `README.md` — the "7 core skills" table, the per-skill usage section, counts, script names and environment variables.
2. Check the GitHub **About** section (description, website, topics) of `toanpham2111/my-agent-skills` and `toanpham2111/kio-agent-system`. If it no longer matches, update it (`gh repo edit`) or give the maintainer the exact new text.
3. Add the change to `CHANGELOG.md` / `CHANGELOG.md` and to `docs/releases/vX.Y.Z.md`.
4. Every Vietnamese `*.md` that ships needs a complete `*.en.md` twin; the English sync (`scripts/sync_to_english_repo.sh`) rejects Vietnamese text.

## Before pushing
- Run the skill test suites that cover what changed (for example `python3 -m pytest skills/kio-frontend-craft/scripts/tests`).
- Credit upstream authors in the skill's `THIRD_PARTY_NOTICES.md` and the root `THIRD_PARTY_NOTICES.md`; sub-skills keep their original `author` with `maintainer: Kio System`.

## Releasing
Follow `docs/RELEASE_WORKFLOW.md` (`scripts/release.sh vX.Y.Z "title" --notes-file docs/releases/vX.Y.Z.md`).
