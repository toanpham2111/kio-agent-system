# 📂 Repository Structure

How the repository is laid out. Back to the [README](../README.md).


The repository maintains a clean, transparent layout centered on the `skills/` directory:

```
kio-agent-system/
├── skills/                           # Core: 7 Self-contained engineering skills
│   ├── kio-frontend-craft/           # UI/UX, styles, palettes, Lenis smooth scroll
│   ├── kio-backend-cloud/            # API design, database RLS, Docker, cloud setups
│   ├── kio-qa-security/              # Test case matrix, unit tests, Playwright checks
│   ├── kio-core-delivery/            # Atomic task planning, spec-kit templates
│   ├── kio-growth-marketing/         # Conversion frameworks, technical SEO modules
│   ├── kio-wordpress-fse/            # WordPress block theme creation pipeline
│   └── kio-cognitive/                # Architecture rationale walkthroughs
│        (every skill: SKILL.md, SKILL.md, THIRD_PARTY_NOTICES.md, references/, scripts/, assets/)
├── commands/                         # 19 /kio-* slash commands (Claude Code, Codex, Cursor, Gemini CLI)
├── evaluations/                      # Skill Evaluation Framework & Live Benchmarks
│   ├── SKILL_EVALUATION_FRAMEWORK.md # 21 verified test scenarios
│   ├── benchmark-summary.md          # Live benchmark summary report
│   └── results/                      # Raw evidence logs per scenario (FE, BE, QA...)
├── agents/                           # Optional: 6 Role-specialized agent personas
│   ├── kio.md                        # Coordinator persona for task triage & review
│   ├── agent-pd.md                   # Product & specification planner persona
│   ├── agent-fe.md                   # Frontend engineering specialist persona
│   ├── agent-be.md                   # Backend & database specialist persona
│   ├── agent-qa.md                   # QA & test verification specialist persona
│   └── wp-leader.md                  # WordPress FSE technical lead persona
├── memory/                           # Optional: Cross-session notes & project registry
│   ├── global_learnings.md           # Tracked lessons learned across projects
│   ├── user_profile.md               # User preferences & tech stack notes
│   └── projects_registry.md          # Active local dev ports registry
├── docs/                             # Engineering guides & operational SOPs
│   ├── releases/                     # Release notes per version
│   └── RELEASE_WORKFLOW.md           # Dual-repository release & synchronization SOP
├── rules/                            # Optional: Global coding guidelines
│   ├── GLOBAL_RULE.md                # General code quality & safety rules
│   └── wp-build-pipeline.md          # WordPress FSE technical checklist
├── scripts/                          # Utility & synchronization scripts
├── setup.sh                          # Safe 1-command installer for Linux/macOS/WSL
├── setup.ps1                         # Safe 1-command installer for Windows
├── CONTRIBUTING.md                   # Contribution guidelines
├── CHANGELOG.md                      # Release changelog (Semantic Versioning)
├── SECURITY.md                       # Security policy and disclosure
├── CODE_OF_CONDUCT.md                # Contributor Covenant Code of Conduct
├── README.md                         # Primary documentation
└── LICENSE                           # MIT License
```
