# 🤝 Contributing to Kio System

Thank you for your interest in contributing to **Kio — Open Source AI Skills Collection for Modern Software Engineering**! This project provides modular, production-grade skills to make AI coding assistants more reliable and disciplined.

---

## 📌 Ways to Contribute

You can contribute in several ways:
1. **Bug Reports**: If an installation script fails, instructions are inaccurate, or an AI assistant hallucinates invalid code when a skill is active.
2. **Feature Requests**: Proposing new engineering domains, test suites, or workflow checklists.
3. **Skill Enhancements**: Adding new design tokens, verified color palettes, database index templates, or unit test patterns.
4. **Benchmark Evidence**: Adding test scenarios or live execution logs to the `evaluations/` directory.

---

## 🛠️ Standards for Writing New Skills

Every skill folder under `skills/` must strictly adhere to the **Agent Skill Standard**:

1. **Minimum Directory Layout**:
   ```
   skills/kio-<skill-name>/
   ├── SKILL.md              # Mandatory: Core instruction file
   └── references/           # Optional: Deep architectural references
   ```
2. **YAML Frontmatter Specification** in `SKILL.md`:
   ```yaml
   ---
   name: kio-<skill-name>
   description: "Clear, concise summary (1-3 sentences) detailing capabilities and trigger conditions."
   author: Kio System / <Your Name>
   version: 1.0.0
   ---
   ```
3. **Content Discipline**:
   - **Actionable Blueprints**: Avoid generic advice. Provide runnable code snippets, real terminal commands, and concrete checklists.
   - **Negative Constraints**: Explicitly state what the AI must NOT do (e.g., no arbitrary mock libraries, no raw SQL string concatenation).
   - **Token Optimization**: Place lengthy technical details into `references/` so models only load them when strictly needed.

---

## 🔄 Pull Request Workflow

1. **Fork** the repository to your GitHub account.
2. Create a feature branch off `main`:
   ```bash
   git checkout -b feature/new-skill-or-fix
   ```
3. Implement changes and verify locally:
   - Test installer changes using `./setup.sh --list` and mock directory tests.
   - For skill additions, include matching test cases in `evaluations/SKILL_EVALUATION_FRAMEWORK.md`.
4. Commit using **Conventional Commits**:
   - `feat: add kio-devops skill`
   - `fix: resolve symlink path resolution on macOS`
   - `docs: update compatibility matrix`
5. Push to your fork and submit a **Pull Request** to `main`:
   👉 [https://github.com/toanpham2111/kio-agent-system/pulls](https://github.com/toanpham2111/kio-agent-system/pulls)

---

## 📜 Code of Conduct
All contributors are expected to uphold the [Code of Conduct (CODE_OF_CONDUCT.md)](CODE_OF_CONDUCT.md). Please maintain a welcoming, respectful, and collaborative environment.
