#!/usr/bin/env python3
"""Kio skill linter: one layout and one frontmatter shape for every skill.

Checks, per skills/<name>/:
  * SKILL.md and SKILL.en.md exist; frontmatter has exactly the Kio shape:
      name (== folder), description, license, metadata.{author, version}
    and nothing else at the top level (author/version belong in metadata).
  * only the standard top-level entries exist:
      SKILL.md, SKILL.en.md, THIRD_PARTY_NOTICES.md, LICENSE*, references/, scripts/, assets/
  * every relative Markdown link ](path) in the skill resolves to a file or folder.
Also checks commands/*.md: frontmatter with description, and the skill it names exists.

Exit code 1 on any problem. Usage: python3 scripts/lint_skills.py [--quiet]
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"
COMMANDS = ROOT / "commands"
ALLOWED_TOP = {"SKILL.md", "SKILL.en.md", "THIRD_PARTY_NOTICES.md", "references", "scripts", "assets"}
TOP_KEYS = {"name", "description", "license", "metadata"}
META_KEYS = {"author", "version"}
LINK = re.compile(r"\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")


def frontmatter(text: str) -> tuple[dict[str, str], dict[str, str]] | None:
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---", 4)
    if end < 0:
        return None
    top: dict[str, str] = {}
    meta: dict[str, str] = {}
    section = None
    for line in text[4:end].splitlines():
        if not line.strip():
            continue
        m = re.match(r"^([A-Za-z_][\w-]*):\s*(.*)$", line)
        if m:
            section = m.group(1)
            top[section] = m.group(2)
            continue
        m = re.match(r"^\s+([A-Za-z_][\w-]*):\s*(.*)$", line)
        if m and section == "metadata":
            meta[m.group(1)] = m.group(2)
    return top, meta


def check_links(md: Path, problems: list[str]) -> None:
    text = md.read_text(encoding="utf-8", errors="replace")
    text = re.sub(r"```.*?```", "", text, flags=re.S)  # ignore code blocks
    text = re.sub(r"`[^`\n]*`", "", text)               # and inline code
    for target in LINK.findall(text):
        if re.match(r"^[a-z][a-z0-9+.-]*:", target) or target.startswith(("#", "<", "/")):
            continue
        path = target.split("#", 1)[0].split("?", 1)[0]
        if not path or "{" in path or "<" in path:
            continue
        if not (md.parent / path).exists():
            problems.append(f"{md.relative_to(ROOT)}: broken link -> {target}")


def lint_skill(skill: Path, problems: list[str]) -> None:
    rel = skill.relative_to(ROOT)
    for f in ("SKILL.md", "SKILL.en.md"):
        p = skill / f
        if not p.exists():
            problems.append(f"{rel}: missing {f}")
            continue
        fm = frontmatter(p.read_text(encoding="utf-8"))
        if fm is None:
            problems.append(f"{rel}/{f}: missing frontmatter")
            continue
        top, meta = fm
        if top.get("name") != skill.name:
            problems.append(f"{rel}/{f}: name must be '{skill.name}'")
        for k in sorted(TOP_KEYS - top.keys()):
            problems.append(f"{rel}/{f}: missing '{k}'")
        for k in sorted(top.keys() - TOP_KEYS):
            problems.append(f"{rel}/{f}: unexpected top-level '{k}' (move it under metadata)")
        for k in sorted(META_KEYS - meta.keys()):
            problems.append(f"{rel}/{f}: missing 'metadata.{k}'")
    for entry in skill.iterdir():
        if entry.name.startswith(".") or entry.name == "__pycache__":
            continue
        if entry.name not in ALLOWED_TOP and not entry.name.startswith("LICENSE"):
            problems.append(f"{rel}: non-standard top-level entry '{entry.name}' "
                            "(use references/, scripts/ or assets/)")
    for md in skill.rglob("*.md"):
        if "node_modules" in md.parts:
            continue
        check_links(md, problems)


def lint_commands(problems: list[str]) -> None:
    if not COMMANDS.exists():
        return
    for cmd in sorted(COMMANDS.glob("*.md")):
        rel = cmd.relative_to(ROOT)
        text = cmd.read_text(encoding="utf-8")
        fm = frontmatter(text)
        if fm is None or "description" not in fm[0]:
            problems.append(f"{rel}: needs frontmatter with description")
        if "$ARGUMENTS" not in text:
            problems.append(f"{rel}: body must pass $ARGUMENTS")
        if "kio-command:" not in text:
            problems.append(f"{rel}: missing the kio-command: marker line")
        named = re.findall(r"`(kio-[a-z-]+)`", text)
        for skill in named:
            if not (SKILLS / skill).is_dir():
                problems.append(f"{rel}: names unknown skill '{skill}'")
        for step in re.findall(r"`assets/templates/commands/([a-z-]+)\.md`", text):
            if not (SKILLS / "kio-core-delivery/assets/templates/commands" / f"{step}.md").exists():
                problems.append(f"{rel}: missing workflow template '{step}.md'")


def main() -> int:
    problems: list[str] = []
    for skill in sorted(p for p in SKILLS.iterdir() if p.is_dir()):
        lint_skill(skill, problems)
    lint_commands(problems)
    if problems:
        print("\n".join(problems))
        print(f"\n{len(problems)} problem(s)")
        return 1
    if "--quiet" not in sys.argv:
        print(f"OK: {len(list(SKILLS.iterdir()))} skills, commands checked")
    return 0


if __name__ == "__main__":
    sys.exit(main())
