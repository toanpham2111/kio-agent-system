#!/usr/bin/env python3
"""
Kio Multi-Engine AI CLI Router (kio_router.py)
==============================================
Intelligent task classification and non-interactive dispatcher for:
- Claude Code CLI (`claude`) -> UI/UX Craft, Anti-Slop, Refactoring, Copywriting
- OpenAI Codex CLI (`codex`)  -> Backend Logic, Algorithms, SQL, Unit Tests
- Google Antigravity CLI (`agy`) -> Huge Context (1M+), Codebase-wide Audits, PDF/Multimodal

Author: Kio System / Toan Pham
Version: 1.0.0
"""

import sys
import os
import shutil
import subprocess
import argparse
import json
import re
from typing import Dict, Any, List, Optional, Tuple

ENGINE_SPECS = {
    "claude": {
        "name": "Claude Code CLI",
        "binary": "claude",
        "strengths": [
            "UI/UX Craft & Responsive Design",
            "Anti-Slop 9-Pass Refactoring (/unslop)",
            "Nuanced Human-like Copywriting (Anti-AI)",
            "Complex Architectural Refactoring",
            "Deep Code Reviews & Security Auditing"
        ],
        "default_models": ["claude-3-7-sonnet", "claude-3-5-sonnet", "claude-opus"],
        "exec_cmd": lambda prompt, extra_args: [
            "claude", "-p", prompt, "--dangerously-skip-permissions"
        ] + extra_args,
        "keywords": [
            "ui", "ux", "css", "scss", "tailwind", "frontend", "fe", "craft",
            "anti-slop", "unslop", "copywriting", "copy", "text", "landing", "animation",
            "motion", "lenis", "gsap", "refactor", "component", "react", "vue", "html",
            "design", "palette", "typography", "responsive", "bento", "audit-ui"
        ]
    },
    "codex": {
        "name": "OpenAI Codex CLI",
        "binary": "codex",
        "strengths": [
            "Pure Logic, Algorithms & Math",
            "Database Schema, SQL Queries & Index Tuning",
            "Comprehensive Unit Tests & Edge Case Coverage",
            "Regex, AST & Complex Data Transformations",
            "Rapid API Boilerplate & Scaffolding"
        ],
        "default_models": ["o3-mini", "o1", "gpt-4o", "gpt-5"],
        "exec_cmd": lambda prompt, extra_args: [
            "codex", "exec", prompt
        ] + extra_args,
        "keywords": [
            "algorithm", "math", "sql", "database", "postgres", "redis", "query",
            "unit test", "unittest", "pytest", "test case", "mock", "jest",
            "backend", "be", "api", "crud", "regex", "ast", "data parsing",
            "optimization", "sorting", "tree", "graph", "performance-be"
        ]
    },
    "agy": {
        "name": "Google Antigravity CLI",
        "binary": "agy",
        "strengths": [
            "Huge Context Window (1M - 2M tokens)",
            "Codebase-wide Audits & Cross-File Dependencies",
            "Multimodal Processing (PDF, Images, Video)",
            "Google Cloud, Firebase & Android CLI Integration",
            "High-Throughput Parallel Batch Tasks"
        ],
        "default_models": ["gemini-2.5-pro", "gemini-2.5-flash"],
        "exec_cmd": lambda prompt, extra_args: [
            "agy", "-p", prompt, "--dangerously-skip-permissions"
        ] + extra_args,
        "keywords": [
            "repo", "codebase", "monorepo", "all files", "entire project", "scan all",
            "pdf", "document", "spec-kit", "constitution", "huge context", "multimodal",
            "firebase", "google cloud", "gcp", "android", "flutter", "batch",
            "1m tokens", "audit repo", "large docs", "extract sections"
        ]
    }
}

def detect_installed_engines() -> Dict[str, Dict[str, Any]]:
    """Detect available binaries and their version/path."""
    status = {}
    for key, spec in ENGINE_SPECS.items():
        bin_path = shutil.which(spec["binary"])
        version = None
        if bin_path:
            try:
                if key == "claude":
                    res = subprocess.run([bin_path, "--version"], capture_output=True, text=True, timeout=5)
                    version = res.stdout.strip()
                elif key == "codex":
                    res = subprocess.run([bin_path, "--version"], capture_output=True, text=True, timeout=5)
                    version = (res.stdout or res.stderr).strip()
                elif key == "agy":
                    res = subprocess.run([bin_path, "--version"], capture_output=True, text=True, timeout=5)
                    version = res.stdout.strip()
            except Exception:
                version = "Installed (Version check failed)"
        status[key] = {
            "name": spec["name"],
            "binary": spec["binary"],
            "installed": bin_path is not None,
            "path": bin_path,
            "version": version
        }
    return status

def classify_prompt(prompt: str) -> Tuple[str, float, Dict[str, int]]:
    """
    Score the prompt against each engine's keyword heuristics.
    Returns: (best_engine, confidence, score_breakdown)
    """
    text = prompt.lower()
    scores = {"claude": 0, "codex": 0, "agy": 0}

    for engine, spec in ENGINE_SPECS.items():
        for kw in spec["keywords"]:
            # Match whole words or phrase
            pattern = r'\b' + re.escape(kw) + r'\b'
            matches = len(re.findall(pattern, text))
            scores[engine] += matches * 2

    # Additional contextual heuristics
    if any(k in text for k in ["css", "tailwind", "giao diện", "ui", "ux", "phối màu", "màu", "font", "chữ"]):
        scores["claude"] += 4
    if any(k in text for k in ["unit test", "test case", "thuật toán", "cơ sở dữ liệu", "sql", "api", "backend"]):
        scores["codex"] += 4
    if any(k in text for k in ["toàn bộ repo", "quét", "context lớn", "tài liệu dài", "pdf", "firebase", "android"]):
        scores["agy"] += 4

    # Determine highest score
    sorted_scores = sorted(scores.items(), key=lambda x: x[1], reverse=True)
    best_engine, best_score = sorted_scores[0]
    total_score = sum(scores.values())

    if total_score == 0:
        # Default fallback is Claude for general tasks, or agy if large prompt
        if len(prompt) > 2000:
            return "agy", 0.60, scores
        return "claude", 0.50, scores

    confidence = round(best_score / max(total_score, 1), 2)
    return best_engine, confidence, scores

def format_matrix() -> str:
    """Print the complete capability matrix."""
    lines = []
    lines.append("=" * 80)
    lines.append("👑 KIO MULTI-ENGINE AI CLI ROUTING MATRIX")
    lines.append("=" * 80)
    installed = detect_installed_engines()

    for key, spec in ENGINE_SPECS.items():
        inst = installed[key]
        status_icon = "✅" if inst["installed"] else "❌"
        lines.append(f"\n{status_icon} [{key.upper()}] - {spec['name']}")
        lines.append(f"  • Binary Path   : {inst['path'] or 'NOT FOUND'}")
        lines.append(f"  • Version       : {inst['version'] or 'N/A'}")
        lines.append(f"  • Models        : {', '.join(spec['default_models'])}")
        lines.append(f"  • Core Strengths:")
        for s in spec["strengths"]:
            lines.append(f"    - {s}")
    lines.append("\n" + "=" * 80)
    return "\n".join(lines)

def dispatch_task(prompt: str, engine_override: Optional[str] = None, dry_run: bool = False, timeout: int = 120, extra_args: List[str] = None) -> int:
    """Classify and dispatch task to selected engine."""
    extra_args = extra_args or []
    installed = detect_installed_engines()

    if engine_override:
        engine = engine_override.lower()
        if engine not in ENGINE_SPECS:
            print(f"❌ Error: Unknown engine '{engine}'. Choose from {list(ENGINE_SPECS.keys())}")
            return 1
        confidence = 1.0
        reason = "Manual override"
    else:
        engine, confidence, scores = classify_prompt(prompt)
        reason = f"Automated classification (Confidence: {int(confidence*100)}%, Breakdown: {scores})"

    spec = ENGINE_SPECS[engine]
    inst = installed[engine]

    print("=" * 70)
    print(f"👑 KIO MULTI-ENGINE DISPATCHER")
    print(f"• Task Prompt    : {prompt[:80]}{'...' if len(prompt) > 80 else ''}")
    print(f"• Target Engine  : {spec['name']} ({engine})")
    print(f"• Routing Reason : {reason}")
    print(f"• Binary Status  : {'Available (' + str(inst['path']) + ')' if inst['installed'] else 'NOT FOUND'}")
    print("=" * 70)

    # Fallback check
    if not inst["installed"]:
        print(f"⚠️ Target engine '{engine}' is not installed! Looking for fallback...")
        available = [k for k, v in installed.items() if v["installed"]]
        if not available:
            print("❌ No AI CLI engine available on system!")
            return 1
        fallback = available[0]
        print(f"🔄 Fallback to '{fallback}' ({ENGINE_SPECS[fallback]['name']})")
        engine = fallback
        spec = ENGINE_SPECS[engine]

    cmd = spec["exec_cmd"](prompt, extra_args)

    if dry_run:
        print(f"🚀 [DRY-RUN] Command to execute:\n{' '.join(cmd)}")
        return 0

    print(f"🚀 Executing via {engine} CLI...")
    try:
        proc = subprocess.run(cmd, timeout=timeout)
        print(f"\n✅ Task finished with exit code {proc.returncode}")
        return proc.returncode
    except subprocess.TimeoutExpired:
        print(f"❌ Execution timed out after {timeout} seconds!")
        return 124
    except Exception as e:
        print(f"❌ Execution error: {e}")
        return 1

def main():
    parser = argparse.ArgumentParser(description="Kio Multi-Engine AI CLI Router")
    subparsers = parser.add_subparsers(dest="subcommand", help="Subcommand to execute")

    # list-engines
    subparsers.add_parser("list-engines", help="List detected CLI engines and their status")

    # matrix
    subparsers.add_parser("matrix", help="Display full capability routing matrix")

    # classify
    classify_p = subparsers.add_parser("classify", help="Classify a prompt without executing")
    classify_p.add_argument("prompt", type=str, help="The task prompt to classify")

    # dispatch
    dispatch_p = subparsers.add_parser("dispatch", help="Dispatch task to the optimal engine")
    dispatch_p.add_argument("prompt", type=str, help="The task prompt")
    dispatch_p.add_argument("--engine", "-e", type=str, choices=["claude", "codex", "agy"], help="Force specific engine")
    dispatch_p.add_argument("--dry-run", "-d", action="store_true", help="Print command without executing")
    dispatch_p.add_argument("--timeout", "-t", type=int, default=180, help="Execution timeout in seconds")

    args, unknown = parser.parse_known_args()

    if args.subcommand == "list-engines":
        installed = detect_installed_engines()
        print(json.dumps(installed, indent=2))
    elif args.subcommand == "matrix":
        print(format_matrix())
    elif args.subcommand == "classify":
        engine, conf, scores = classify_prompt(args.prompt)
        print(json.dumps({
            "prompt": args.prompt,
            "recommended_engine": engine,
            "confidence": conf,
            "scores": scores,
            "strengths": ENGINE_SPECS[engine]["strengths"]
        }, indent=2))
    elif args.subcommand == "dispatch":
        code = dispatch_task(args.prompt, engine_override=args.engine, dry_run=args.dry_run, timeout=args.timeout, extra_args=unknown)
        sys.exit(code)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
