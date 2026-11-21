#!/usr/bin/env python3
"""A/B benchmark harness for Kio skills (Claude Code CLI).

For every scenario in evaluations/results/<group>/<ID>.md:
  1. take the prompt (section "1. Input Prompt") and the rubric table (section 4),
  2. run the prompt in an empty project (baseline) and in a project that has only the
     scenario's skill under .claude/skills/ (with skill),
  3. ask a separate judge call to score both answers against the rubric, blind and in a
     random order,
and write everything to OUT_DIR/<ID>.json.
"""
import json, os, random, re, shutil, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

REPO = sys.argv[1]
OUT = sys.argv[2]
GEN_MODEL = os.environ.get("GEN_MODEL", "claude-sonnet-5-5")
JUDGE_MODEL = os.environ.get("JUDGE_MODEL", "claude-opus-5-5")
ONLY = set(sys.argv[3].split(",")) if len(sys.argv) > 3 else None

SKILL_FOR = {"FE": "kio-frontend-craft", "BE": "kio-backend-cloud", "QA": "kio-qa-security",
             "DEL": "kio-core-delivery", "GRO": "kio-growth-marketing", "WP": "kio-wordpress-fse",
             "COG": "kio-cognitive"}
INSTRUCTION = ("\n\n---\nAnswer directly in your final message with the complete deliverable "
               "(code, SQL, config or document). Do not create or edit files.")


def parse(path):
    t = open(path).read()
    sid = os.path.basename(path)[:-3]
    m = re.search(r"## 1\. Input Prompt\s*```(?:text)?\n(.*?)```", t, re.S)
    prompt = m.group(1).strip()
    rub = re.search(r"## 4\. Rubric.*?\n(\|.*?)(?:\n\n|\Z)", t, re.S).group(1)
    crit = []
    for line in rub.splitlines()[2:]:
        cells = [c.strip() for c in line.strip("|").split("|")]
        name = re.sub(r"[*`]", "", cells[0]).strip()
        if name.lower().startswith("total"):
            continue
        crit.append({"criterion": name, "max": float(cells[1]), "notes": cells[4] if len(cells) > 4 else ""})
    return sid, prompt, crit


def claude(prompt, cwd, model, max_turns, tools):
    cmd = ["claude", "-p", prompt, "--output-format", "stream-json", "--verbose", "--model", model,
           "--max-turns", str(max_turns)]
    if tools:
        cmd += ["--allowedTools", tools]
    r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=1200)
    tool_calls, final = [], {}
    for line in r.stdout.splitlines():
        try:
            e = json.loads(line)
        except ValueError:
            continue
        if e.get("type") == "assistant":
            for c in e["message"].get("content", []):
                if c.get("type") == "tool_use":
                    inp = c.get("input", {})
                    tool_calls.append({"tool": c["name"], "target": (inp.get("file_path") or inp.get("pattern")
                                       or inp.get("skill") or "")[-120:]})
        elif e.get("type") == "result":
            final = e
    return {"result": final.get("result", ""), "models": list((final.get("modelUsage") or {}).keys()),
            "cost": final.get("total_cost_usd"), "turns": final.get("num_turns"),
            "error": final.get("is_error"), "tool_calls": tool_calls}


def run_scenario(path):
    sid, prompt, crit = parse(path)
    skill = SKILL_FOR[re.match(r"[A-Z]+", sid).group(0)]
    base = os.path.join(OUT, "work", sid)
    a_dir, b_dir = os.path.join(base, "baseline"), os.path.join(base, "with-skill")
    os.makedirs(a_dir, exist_ok=True)
    sk_dir = os.path.join(b_dir, ".claude", "skills")
    os.makedirs(sk_dir, exist_ok=True)
    if not os.path.exists(os.path.join(sk_dir, skill)):
        shutil.copytree(os.path.join(REPO, "skills", skill), os.path.join(sk_dir, skill))
    for d in (a_dir, b_dir):
        subprocess.run(["git", "init", "-q"], cwd=d)
    tools = "Read,Glob,Grep,Skill"
    baseline = claude(prompt + INSTRUCTION, a_dir, GEN_MODEL, 12, tools)
    with_skill = claude(f"/{skill} " + prompt + INSTRUCTION, b_dir, GEN_MODEL, 12, tools)

    order = [("A", baseline["result"]), ("B", with_skill["result"])]
    random.Random(sid).shuffle(order)
    labels = {order[0][0]: "X", order[1][0]: "Y"}
    rubric = "\n".join(f"- {c['criterion']} (max {c['max']}): {c['notes']}" for c in crit)
    judge_prompt = (
        "You are a strict senior reviewer grading two answers to the same task. Score each answer "
        "against every rubric criterion, from 0 to that criterion's max, in steps of 0.1. The notes "
        "describe what a full-mark answer contains. Judge only the content; ignore length and style. "
        "Deduct for anything missing, wrong, insecure or merely claimed.\n\n"
        f"TASK:\n{prompt}\n\nRUBRIC:\n{rubric}\n\n"
        f"=== ANSWER X ===\n{order[0][1]}\n=== END X ===\n\n=== ANSWER Y ===\n{order[1][1]}\n=== END Y ===\n\n"
        "Reply with JSON only, no prose: {\"X\": {\"scores\": {\"<criterion>\": n, ...}, \"total\": n, "
        "\"notes\": \"one sentence\"}, \"Y\": {...}}"
    )
    jdir = os.path.join(base, "judge"); os.makedirs(jdir, exist_ok=True)
    judge = claude(judge_prompt, jdir, JUDGE_MODEL, 1, "")
    raw = judge["result"]
    js = json.loads(raw[raw.index("{"): raw.rindex("}") + 1])
    inv = {v: k for k, v in labels.items()}
    scores = {"baseline": js[labels["A"]], "with_skill": js[labels["B"]]}
    rec = {"id": sid, "skill": skill, "prompt": prompt, "rubric": crit,
           "gen_model": GEN_MODEL, "judge_model": JUDGE_MODEL,
           "baseline": baseline, "with_skill": with_skill, "judge": judge,
           "blind_labels": {"baseline": labels["A"], "with_skill": labels["B"]}, "scores": scores}
    json.dump(rec, open(os.path.join(OUT, f"{sid}.json"), "w"), indent=2, ensure_ascii=False)
    return sid, scores["baseline"]["total"], scores["with_skill"]["total"]



def _safe(p):
    try:
        return run_scenario(p)
    except Exception as e:  # keep the other scenarios running
        return (os.path.basename(p), "ERROR", repr(e)[:300])


if __name__ == "__main__":
    files = []
    for g in sorted(os.listdir(os.path.join(REPO, "evaluations", "results"))):
        for f in sorted(os.listdir(os.path.join(REPO, "evaluations", "results", g))):
            if f.endswith(".md") and not f.endswith(".en.md") and (not ONLY or f[:-3] in ONLY):
                files.append(os.path.join(REPO, "evaluations", "results", g, f))
    os.makedirs(OUT, exist_ok=True)
    with ThreadPoolExecutor(max_workers=int(os.environ.get("WORKERS", "4"))) as ex:
        for res in ex.map(lambda p: _safe(p), files):
            print(res, flush=True)

