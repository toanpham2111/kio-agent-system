# Installation and use

This is a portable SKILL.md skill. Put the entire `wpa-seo` folder in the skill directory of the selected tool. Restart the tool or open a new session to refresh discovery.

- Claude Code (personal): `~/.claude/skills/wpa-seo/`
- Codex (personal): `~/.agents/skills/wpa-seo/`
- Qoder IDE/CLI (personal): `~/.qoder/skills/wpa-seo/`

For a project-level skill, use the agent's supported project-level `skills` directory. Other agents may use different locations or may not support this format; verify their current documentation before installing.

Suggested test prompt:
`Use the wpa-seo skill to audit this project. Do not edit files. Give me prioritized issues with file paths and evidence, and distinguish what you could not verify.`

Suggested fix prompt:
`Use the wpa-seo skill to fix only verified high-priority SEO issues in this project. Preserve existing functionality, avoid duplicate schema/metadata, run available tests and report every changed file.`

Skill can guide a coding assistant but does not on its own fetch Search Console data, guarantee crawler indexing or automatically run tests without the agent's tools and permissions.
