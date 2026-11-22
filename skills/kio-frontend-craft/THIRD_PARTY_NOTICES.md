# Third-Party Notices — `kio-frontend-craft`

`kio-frontend-craft` is a Kio skill: the router, the Kio rules (defensive spacing, anti-slop, delivery gates), `references/unslop-9-pass.md`, `references/motion-lenis.md`, `references/pdf-to-html.md`, `references/mobile/`, `references/web-performance.md`, `templates/` and all Kio edits are © 2026 Toan Pham / Kio System, MIT License (repository `LICENSE`).

Parts of the data, scripts and rules are adapted from the open-source projects below. Their licenses allow modification and redistribution under the Kio name **on the condition that the original copyright and license notices are kept**. This file is that notice; do not remove it.

| Upstream project | Copyright | License | Used in |
| :--- | :--- | :--- | :--- |
| [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | © nextlevelbuilder and contributors | MIT | `data/*.csv`, `data/stacks/`, `scripts/core.py`, `scripts/search.py`, `scripts/design_system.py`, `scripts/reasoning_contract.py`, `scripts/validate_data.py`, `scripts/tests/`, `references/ui-ux/` |
| [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) — React Best Practices | © Vercel, Inc. | MIT | `references/react/` (README, AGENTS.md, 64 rules) |
| [Phosphor Icons](https://github.com/phosphor-icons/core) | © Phosphor Icons | MIT | `data/phosphor-icons-upstream.json`, icon names in `data/icons.csv` |
| [Google Fonts](https://github.com/google/fonts) metadata | © the respective font authors | Per family (SIL OFL 1.1, Apache 2.0, UFL); see `data/google-font-licenses.json` | `data/google-fonts.csv`, `data/google-font-licenses.json` (metadata only, no font files) |

The web performance workflow in `references/web-performance.md` follows the public Cloudflare web performance audit approach; no Cloudflare source files are included.

Stock photo services used at build time by `scripts/stock_images.py` (no images are redistributed with Kio): [Unsplash](https://unsplash.com/license) (Unsplash License, hotlinked, credit required by the API guidelines), [Pexels](https://www.pexels.com/license/) (Pexels License) and [Openverse](https://openverse.org) (each image keeps its own Creative Commons license). Credits for the images a page uses are written to `CREDITS.json` / `CREDITS.html` next to the images.

---

## MIT License (applies to every MIT project listed above)

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
