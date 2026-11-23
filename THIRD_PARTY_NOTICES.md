# Third-Party Open Source Notices & Licenses

**Kio (`toanpham2111/kio-agent-system`)** is maintained by Toan Pham / Kio System and released under the **MIT License** (`LICENSE`). Kio adapts, reorganises and extends open-source agent skills, datasets and tooling. This file is the repository-wide index of every upstream source; each skill also ships its own `THIRD_PARTY_NOTICES.md` with the file-level detail:

- [`skills/kio-growth-marketing/THIRD_PARTY_NOTICES.md`](skills/kio-growth-marketing/THIRD_PARTY_NOTICES.md)
- [`skills/kio-frontend-craft/THIRD_PARTY_NOTICES.md`](skills/kio-frontend-craft/THIRD_PARTY_NOTICES.md)
- [`skills/kio-backend-cloud/THIRD_PARTY_NOTICES.md`](skills/kio-backend-cloud/THIRD_PARTY_NOTICES.md)
- [`skills/kio-qa-security/THIRD_PARTY_NOTICES.md`](skills/kio-qa-security/THIRD_PARTY_NOTICES.md)
- [`skills/kio-core-delivery/THIRD_PARTY_NOTICES.md`](skills/kio-core-delivery/THIRD_PARTY_NOTICES.md)

The licenses below allow modification and redistribution **on the condition that the original copyright and license notices are kept**. Do not remove this file, the per-skill notices, or the `LICENSE.txt` files in `skills/kio-growth-marketing/references/seo/subskills/`.

---

## 1. Redistributed (adapted) upstream works

| # | Upstream project | Copyright holder(s) | License | Used in |
| :--- | :--- | :--- | :--- | :--- |
| 1 | [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) | Corey Haines and contributors | MIT | `skills/kio-growth-marketing/references/modules/` (53 modules), `tools/` |
| 2 | [AgriciDaniel/claude-seo](https://github.com/AgriciDaniel/claude-seo) | AgriciDaniel (Daniel Agrici); `seo-content-brief` by puneetindersingh; Pro Hub Challenge contributions by Lutfiya Miller (`seo-cluster`), Dan Colta (`seo-drift`), Matej Marjanovic (`seo-ecommerce`), Florian Schmitz (`seo-sxo`) | MIT | `skills/kio-growth-marketing/references/seo/` |
| 3 | `claude-seo` by Ivan Kuznetsov (`ivankuznetsov/claude-seo`) | Ivan Kuznetsov | MIT | `skills/kio-growth-marketing/references/seo/` (as listed in v1.0.2) |
| 4 | [AgriciDaniel/flow](https://github.com/AgriciDaniel/flow) | Daniel Agrici | CC BY 4.0 | `skills/kio-growth-marketing/references/seo/subskills/seo-flow/` |
| 5 | [AgriciDaniel/claude-ads](https://github.com/AgriciDaniel/claude-ads) | Daniel Agrici | MIT | `modules/ads/references/audit-guardrails.md` |
| 6 | [retieedra-profound/skills-marketing-library](https://github.com/retieedra-profound/skills-marketing-library) | Profound and Wispr Flow contributors | MIT | `modules/copywriting`, `modules/copy-editing`, `modules/product-marketing` references |
| 7 | [Knowatoa/ai-visibility-skills](https://github.com/Knowatoa/ai-visibility-skills) | Knowatoa | MIT | `modules/events`, `modules/public-relations` references |
| 8 | [ConversionKit/conversion-tracking](https://github.com/ConversionKit/conversion-tracking) | ConversionKit | MIT | `modules/conversion-tracking` |
| 9 | [eliasstravik/rowbound](https://github.com/eliasstravik/rowbound) | Elias Stravik | MIT | `modules/revops`, `modules/prospecting`, `tools/integrations` |
| 10 | [Ploy-AI/ploy-tools](https://github.com/Ploy-AI/ploy-tools) | Ploy AI | MIT | `tools/integrations/ploy.md` |
| 11 | [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | NextLevelBuilder and ui-ux-pro-max contributors | MIT | `skills/kio-frontend-craft/assets/data/`, `scripts/` (search engine, validators, tests), `references/ui-ux/` |
| 12 | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) — React Best Practices | Vercel, Inc. | MIT | `skills/kio-frontend-craft/references/react/` (64 rules + full guide) |
| 13 | [phosphor-icons/core](https://github.com/phosphor-icons/core) | Phosphor Icons | MIT | `skills/kio-frontend-craft/assets/data/phosphor-icons-upstream.json`, `data/icons.csv` |
| 14 | [google/fonts](https://github.com/google/fonts) metadata | The respective font authors | Per family: SIL OFL 1.1, Apache 2.0, UFL (see `data/google-font-licenses.json`) | `skills/kio-frontend-craft/assets/data/google-fonts.csv` (metadata only, no font files) |
| 15 | [anthropics/skills](https://github.com/anthropics/skills) — `mcp-builder` | Anthropic, PBC | Apache 2.0 (text in `skills/kio-backend-cloud/references/LICENSE-APACHE-2.0.txt`) | `skills/kio-backend-cloud/references/mcp-server-builder.md` (modified by Kio) |
| 16 | [obra/superpowers](https://github.com/obra/superpowers) | Jesse Vincent | MIT | `skills/kio-core-delivery/references/` (`brainstorming.md`, `visual-companion.md`, `writing-plans.md`, `executing-plans.md`, `dispatching-parallel-agents.md`, `git-worktrees.md`), `skills/kio-core-delivery/scripts/` (visual brainstorming companion), `skills/kio-qa-security/references/tdd-debugging/`, `scripts/find-polluter.sh`, `evals/tdd-pressure/` |
| 17 | [pstack](https://github.com/cursor/plugins/tree/main/pstack) | Lauren Tan ("poteto") | MIT | `skills/kio-qa-security/references/deep-review/` (blast-radius, interrogate, arena, correct) |
| 18 | [trailofbits/skills](https://github.com/trailofbits/skills) — static-analysis | Trail of Bits | **CC BY-SA 4.0** (not MIT; ShareAlike applies; notice and list of Kio changes in `skills/kio-qa-security/references/codeql/LICENSE`) | `skills/kio-qa-security/references/codeql/` (whole folder: SKILL.md, workflows, references, scripts) |
| 19 | [github/spec-kit](https://github.com/github/spec-kit) | GitHub, Inc. | MIT | `skills/kio-core-delivery/references/spec-driven.md`, `skills/kio-core-delivery/assets/templates/` (`*-template.md`, `commands/*.md`) |
| 20 | [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) | Ahmad Adi | MIT | `skills/kio-core-delivery/references/planning-with-files/`, `skills/kio-core-delivery/assets/templates/` (`task_plan*.md`, `findings.md`, `progress.md`, `loop.md`), `skills/kio-core-delivery/scripts/planning/` |

## 2. Inspirations and practitioner sources (re-expressed, no text redistributed)

| Source | Credit | Used in |
| :--- | :--- | :--- |
| [ivangfalco/ads-skills](https://github.com/ivangfalco/ads-skills) | Ivan Falco | Framework lineage of `modules/ads/references/` and `modules/ad-creative/references/awareness-headlines.md` |
| [gooseworks-ai/gooseworks-ads-skills](https://github.com/gooseworks-ai/gooseworks-ads-skills) | Shiv Sakhuja and the Gooseworks team | `modules/ad-creative/references/imessage-video-ads.md` |
| Cloudflare web performance audit workflow | Cloudflare | `skills/kio-frontend-craft/references/web-performance.md` (5-phase audit approach) |
| Alibaba open-code-review (`ocr`) | Alibaba | 5-layer review checklist in `skills/kio-qa-security/references/security-review.md` |
| *Founding Marketing* (book) | Corey Haines | Cited and summarised in several `modules/` references |

Books, articles and products named inside the skills keep their in-line citations; their trademarks belong to their owners.

---

## 3. License texts

### MIT License (applies to every MIT entry above, with that entry's copyright line)

```text
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

### Creative Commons Attribution 4.0 (FLOW)
Adapted (reorganised and wired into the Kio router). Full terms: <https://creativecommons.org/licenses/by/4.0/>.

### Apache License 2.0 (`mcp-builder`)
Full text: [`skills/kio-backend-cloud/references/LICENSE-APACHE-2.0.txt`](skills/kio-backend-cloud/references/LICENSE-APACHE-2.0.txt). Kio's changes are described in `skills/kio-backend-cloud/THIRD_PARTY_NOTICES.md`.
