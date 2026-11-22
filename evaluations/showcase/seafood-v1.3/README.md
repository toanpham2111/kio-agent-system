# 🦐 Real-world test: seafood shop website — without skill vs with `kio-frontend-craft`

2026-11-22 · Kio v1.3.0 · same prompt, same model **Claude Sonnet 5.5**, one run per condition in separate projects. Full data: [`results.json`](results.json).

**Prompt (Vietnamese):** a fresh-seafood shop site for "Hai San Bien Xanh" (Da Nang), SEO for the keyword "fresh seafood Da Nang": hero, categories with price per kg, bestsellers, freshness promise and delivery steps, reviews, FAQ, quick order form, footer; one `index.html`, Tailwind, responsive, Vietnamese content.

## Desktop (1440 px)
![Desktop comparison](images/desktop-compare.jpg)

## Mobile (375 px)
![Mobile comparison](images/mobile-compare.jpg)

Full pages: [without skill — desktop](images/baseline-desktop-full.jpg) · [mobile](images/baseline-mobile-full.jpg) · [with skill — desktop](images/with-skill-desktop-full.jpg) · [mobile](images/with-skill-mobile-full.jpg). Source: [`site-baseline/`](site-baseline/index.html) · [`site-with-skill/`](site-with-skill/index.html).

## Blind judge score (Claude Opus 5.5, not told which page used the skill)

| Criterion | Max | Without skill | With skill |
|---|:---:|:---:|:---:|
| Design & aesthetics | 20 | 13 | **17** |
| Layout & mobile | 15 | 12 | **13** |
| On-page SEO & structured data | 25 | 21 | **22** |
| Content & persuasion | 15 | 12 | **13** |
| Ordering experience | 15 | 10 | **12** |
| Accessibility | 10 | 7 | **9** |
| **Total** | **100** | **75** | **86** |

Judge's notes:
- **With skill:** a real seafood photo behind the hero, custom SVG icons, consistent CTA colour, correct price-per-kg JSON-LD (`UnitPriceSpecification`), and a form that validates input, moves focus to errors and actually sends the order. Lost points for no Zalo link, icon-only bestseller cards and a JSON-LD address without postal code/geo.
- **Without skill:** a well-linked `@graph` JSON-LD (with geo) and useful seasonal buying tips. Lost points for emoji used as icons and product images, and a form that shows "order received" while sending nothing (only a `TODO` in the code) — **orders are lost**; the floating "Call now" button covers hero content on mobile.

## Automated checks

| | Without skill | With skill |
|---|:---:|:---:|
| Lighthouse mobile — Performance / Accessibility / Best Practices / SEO | 100 / 96 / 100 / 100 | 98 / **100** / 96 / 100 |
| Lighthouse desktop — Performance / Accessibility / Best Practices / SEO | 100 / 96 / 100 / 100 | 100 / **100** / 96 / 100 |
| Contrast failures (Lighthouse) | main "Order" button 2.8:1 and 2 buttons at 3.55:1 | 0 |
| `layout-check.js` mobile — edge overflow | 1 (footer copyright line) | **0** |
| `layout-check.js` desktop — misaligned rows | 2 | 2 |
| SEO checks (title, meta, OG, canonical, one H1, no heading skips, keyword in title/H1/description) | pass | pass |
| Valid JSON-LD | 1 block | 2 blocks |
| HTML entities in source (`&amp;`…) | 1 | **0** |
| Images with `alt` | 0 images (emoji only) | 1/1 (credited stock photo) |

The with-skill Best Practices deduction is only the missing favicon. Lighthouse ran on localhost with the same locally built Tailwind CSS replacing the CDN for both pages.

## Time, tokens and cost

| | Without skill | With skill |
|---|:---:|:---:|
| Time | **1 min 55 s** | 8 min 2 s |
| Turns | 2 | 32 |
| Output tokens | **20,387** | 42,951 |
| Input tokens — total | **97,344** | 1,663,477 |
| ↳ cache reads (~10% price) | 68,520 | 1,594,742 |
| ↳ cache writes | 28,820 | 68,687 |
| Cost | **US$0.33** | US$0.86 |

The skill run looked up a design system, fetched 7 stock photos and kept the 1 that fit, and checked its JSON-LD and FAQ before delivering — hence roughly 2.6–4× the time and tokens.

## Reading these results honestly
- One run per condition; a re-run can differ.
- The judge score is one AI model's assessment against the rubric above, not an absolute measurement.
- The skill is not perfect: the with-skill page still has 2 misaligned rows on desktop and a fixed mobile bar that covers some content — rule 10 and `layout-check.js` exist, but this run could not launch a browser to check itself.
