---
name: codeql-semgrep-review
description: "Security code review and SAST for kio-qa-security: two-stage review, the 5-layer quality checklist, line-level diff review, Semgrep scans and CodeQL taint tracking with merged SARIF. Use for security audits, pre-merge review of risky diffs, or 'scan this repo for vulnerabilities'."
metadata:
  author: Trail of Bits (CodeQL/Semgrep workflows, scripts, references)
  maintainer: Kio System
---

# 🛡️ Security Review & Static Analysis (Semgrep + CodeQL)

`{baseDir}` below is this folder: `<kio-qa-security install dir>/references/codeql` (for example `~/.claude/skills/kio-qa-security/references/codeql`). Substitute it literally in every command.

## When to use what

| Need | Go to |
|---|---|
| Review a feature or PR before merge | [Two-stage review](#1-two-stage-code-review) + [5-layer checklist](#2-the-5-layer-quality-checklist) |
| Fast pattern scan, many languages, no build | Semgrep: Follow "Step 1: Resolve Output Directory, Detect Languages and Pro Availability" in workflows/scan-workflow.md |
| Deep interprocedural taint tracking | CodeQL: [Database Discovery](#database-discovery), then Follow "Step 1: Detect Language and Configure" in workflows/build-database.md, then workflows/run-analysis.md |
| Model a custom framework's sources/sinks | workflows/create-data-extensions.md |
| Merge and triage results | `{baseDir}/scripts/merge_sarif.py`, references/sarif-processing.md |

Rule references: references/rulesets.md, references/ruleset-catalog.md (Trail of Bits, 0xdea, Decurity and community packs), references/scan-modes.md ("important only" vs "run all"), references/threat-models.md.

---

## 1. Two-stage code review

**Stage 1 — spec compliance.** Does the change satisfy every acceptance criterion in the PRD/issue? Flag missing cases and unrequested scope.

**Stage 2 — code quality and security.** Run the 5-layer checklist below and, for risky diffs, a scan.

Receiving feedback: verify each comment against the codebase before changing anything, push back with evidence when a suggestion is wrong, and fix one issue at a time with tests after each.

## 2. The 5-layer quality checklist

1. **Security & zero trust** — parameterised queries only; output escaped for its context (HTML, attribute, URL, JS); CSRF tokens/nonces and capability checks on every state-changing endpoint; no secrets in code; public forms protected by honeypot, minimum fill time (< 3 s rejected), per-IP rate limit and an invisible challenge (Turnstile / reCAPTCHA v3).
2. **Performance & resources** — no queries inside loops (N+1); handles, sockets and connections closed in `finally`; no repeated heavy allocation in hot loops.
3. **Concurrency** — multi-step mutations inside transactions; webhooks and payment handlers idempotent.
4. **Architecture** — files under 700 lines; no `TODO` stubs or mock data on production paths.
5. **Project rules** — follow the repository's `CLAUDE.md` / `AGENTS.md` / `rules/GLOBAL_RULE.md`.

## 3. Line-level diff review (optional)

If the open-source `ocr` CLI (Alibaba open-code-review) is installed:

```bash
ocr review --audience agent -b "Spec compliance and security audit for latest changes"
ocr review --base main
```

Spend effort on `critical` and `high` findings; drop style nitpicks that conflict with intentional design.

---

## Each Bash call is a fresh shell

Every fenced block in this skill and its workflows runs as **its own Bash invocation**. Nothing set in one block exists in the next:

- **Variables and arrays** (`OUTPUT_DIR`, `DB_NAME`, `CODEQL_LANG`, `FOUND_DBS`) must be set again, or re-derived, in the block that uses them. An array built in an earlier block is empty in a later one, and an empty `FOUND_DBS` reads as "no database".
- **Functions** from `source "{baseDir}/scripts/build_log.sh"` (`log_step`, `run_logged`, …) must be sourced again in each block; a missing function exits 127, which the build ladder reads as a failed method.
- **`PATH` changes** (for example adding CodeQL) do not carry over; check for `codeql` in the block that needs it.
- Read script output with command substitution (`OUT=$(script)`), not `done < <(script)`: a process substitution discards the exit status.

## Database Discovery

Before building a CodeQL database, look for existing ones. Discovery and selection share one block so the array never crosses a shell boundary:

```bash
OUTPUT_DIR="${OUTPUT_DIR:-.}"
if ! DB_LIST=$("{baseDir}/scripts/find_databases.sh" "$OUTPUT_DIR" .); then
  echo "ERROR: database discovery failed — see the message above" >&2
  exit 1
fi

FOUND_DBS=()
while IFS= read -r db; do
  [ -n "$db" ] || continue
  FOUND_DBS+=("$db")
done <<<"$DB_LIST"

echo "Found ${#FOUND_DBS[@]} CodeQL database(s):"
for db in "${FOUND_DBS[@]}"; do
  echo "  - $db"
done
```

- **0 found** → build one: Follow "Step 1: Detect Language and Configure" in workflows/build-database.md.
- **1 found** → set `DB_NAME` to it and run workflows/run-analysis.md.
- **Several** → ask the user which one, then set `DB_NAME` in the analysis block.

`find_databases.sh` exits 2 when `codeql` is not on this shell's `PATH`; report that instead of rebuilding.

---

## Semgrep quick start

```bash
# Never send telemetry from a client's code
semgrep scan --config auto --metrics=off --error --sarif --output semgrep-results.sarif
```

For curated packs, approval gates and parallel runs use workflows/scan-workflow.md; merge outputs with `{baseDir}/scripts/merge_sarif.py`.

## Sign-off format

```markdown
[🛡️ Kio Security Review — Sign-off]
1. Two-stage review: PASS — matches spec, quality review done
2. 5-layer checklist: PASS — 0 SQLi/XSS, 0 secrets, files < 700 lines, 0 TODO
3. Diff review: PASS — 0 critical/high
4. SAST (Semgrep/CodeQL): PASS — <n> findings triaged, 0 open high/critical
Evidence: <commands run, SARIF paths>
```
