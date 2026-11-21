# ✅ Evaluating an MCP Server

Unit tests prove each tool works; an **evaluation** proves a model can use the tools to answer real questions. Do both.

## 1. Write 10 evaluation questions
Each question must be:
- **Realistic** — something a user of the service would actually ask.
- **Multi-step** — needs 2+ tool calls (search → get → compare), not one lookup.
- **Read-only** — answerable without changing data, so it can run repeatedly.
- **Verifiable** — a single, exact answer (an ID, number, date, name) that you checked by hand.
- **Stable** — the answer will not change next week (use historical/closed records).

Avoid questions whose answer appears verbatim in a tool description, or that need data the tools cannot reach.

## 2. File format
```xml
<evaluation>
  <qa_pair>
    <question>Which customer had the largest single refund in March 2025, and what was the order ID?</question>
    <answer>lan.nguyen@example.com, o-48213</answer>
  </qa_pair>
  <!-- 9 more -->
</evaluation>
```
JSON (`[{"question": "...", "answer": "..."}]`) works equally well; keep it in the repo next to the server.

## 3. Run it
1. Connect the server to an agent (Claude Code: `claude mcp add ...`) in a fresh session.
2. Ask each question **without hints**; let the agent use only the MCP tools.
3. Record: final answer, correct/incorrect, number of tool calls, errors hit, and wall time.
4. Read the transcripts, not just the score. The fixes are usually in **descriptions, argument names, error messages and response size**, not in the model.

## 4. Score and act
| Symptom in transcripts | Fix |
|---|---|
| Model picks the wrong tool | Sharpen descriptions: "use this instead of X when…" |
| Repeated failed calls with bad arguments | Constrain types/enums, add examples, return teaching errors |
| Runs out of context | Smaller responses, pagination, summary mode |
| Gives up after an error | Error messages must say what to try next |
| Too many calls for a simple question | Add a workflow tool that combines the common chain |

Target ≥ 8/10 correct before release; re-run after every tool or description change and track the score over time.
