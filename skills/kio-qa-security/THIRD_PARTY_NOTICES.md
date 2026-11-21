# Third-Party Notices — `kio-qa-security`

`kio-qa-security` is maintained by Kio. The router (`SKILL.md`, `SKILL.md`), `references/unit-testing-and-test-cases*.md`, `references/playwright-e2e.md`, `references/tdd-debugging/README*.md`, `references/deep-review/README*.md`, `references/codeql/SKILL.md` and all Kio modifications are © 2026 Toan Pham / Kio System, MIT License (repository `LICENSE`).

Parts of this skill are adapted from the projects below. Keep this file and `references/deep-review/PSTACK-NOTICE.md` when redistributing.

| Upstream project | Copyright | License | Used in |
| :--- | :--- | :--- | :--- |
| [obra/superpowers](https://github.com/obra/superpowers) — systematic debugging & TDD skills | © Jesse Vincent | MIT | `references/tdd-debugging/` (`root-cause-tracing.md`, `defense-in-depth.md`, `condition-based-waiting.md`, `condition-based-waiting-example.ts`, `writing-good-tests.md`), `scripts/find-polluter.sh`, `evals/tdd-pressure/` |
| [pstack](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan ("poteto") | © Lauren Tan | MIT | `references/deep-review/` (`blast-radius.md`, `interrogate.md`, `arena.md`, `correct.md`); details in `PSTACK-NOTICE.md` |
| [trailofbits/skills](https://github.com/trailofbits/skills) — static-analysis (CodeQL, Semgrep) | © Trail of Bits | See the upstream repository's license (Kio has not yet confirmed it; check before redistributing these files) | `references/codeql/workflows/`, `references/codeql/references/`, `references/codeql/scripts/` |

### Inspirations (re-expressed, no text redistributed)

| Source | Credit | Used in |
| :--- | :--- | :--- |
| Alibaba open-code-review (`ocr` CLI) and its five-layer review | Alibaba | The 5-layer quality checklist and the optional `ocr` step in `references/codeql/SKILL.md` |
| Microsoft Playwright and Playwright MCP | Microsoft | Tools documented in `references/playwright-e2e.md` (not redistributed) |

---

## MIT License (applies to the MIT entries above, with each entry's copyright line)

```
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
