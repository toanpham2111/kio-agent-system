---
description: "Spec-Kit (Kio): write the feature specification"
argument-hint: "<feature description>"
---
Use the `kio-core-delivery` skill and follow its `assets/templates/commands/specify.md` workflow step by step.

Run it in Kio mode, without the Spec-Kit CLI:
- Ignore the template's `scripts:` / `handoffs:` frontmatter, `{SCRIPT}` steps and `.specify/` extension hooks: Kio does not install them.
- Templates come from the skill: `assets/templates/constitution-template.md`, `spec-template.md`, `plan-template.md`, `tasks-template.md`, `checklist-template.md`.
- Feature artifacts live in `specs/<NNN>-<short-name>/` at the repository root (`spec.md`, `plan.md`, `tasks.md`, `checklists/`); the constitution lives in `memory/constitution.md` (create the folders if missing). Pick the next free `NNN`, or reuse the folder of the feature being worked on.
- Where the template says `/speckit.<step>`, the Kio command is `/kio-spec-<step>`.

Request: $ARGUMENTS
(If the line above still shows a placeholder, the request is the text typed after the command.)

<!-- kio-command: managed by the Kio installer; local edits are replaced on update -->
