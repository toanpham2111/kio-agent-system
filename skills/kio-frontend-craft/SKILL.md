---
name: kio-frontend-craft
description: "Kio Frontend, UI/UX & Motion hub. Use for any UI work: designing or reviewing pages, landing pages, dashboards, components; picking a style, palette, font pairing or icons (79 searchable styles, 192 palettes, 74 pairings, 1,934 Google Fonts, 22 stacks); de-slopping AI-looking UIs (9-pass /unslop); accessibility, spacing and responsive fixes; Lenis smooth scroll and GSAP motion; Core Web Vitals / PageSpeed 95-100 (LCP, CLS, INP); React 19 and Next.js App Router performance (64 rules: waterfalls, bundle size, RSC, re-renders); React Native / Expo / SwiftUI mobile; PDF or mockup to responsive HTML."
license: MIT
metadata:
  author: Kio System / Toan Pham
  version: 3.0.0
---

# 🎨 Kio Frontend, UI/UX & Motion (`kio-frontend-craft`)

The router for Kio's interface work. Knowledge lives in `references/`, design data lives in `data/` and is queried with `scripts/search.py`. This file only points the way and holds the mandatory rules.

`KIO_FE_ROOT` = this skill's install directory (e.g. `~/.claude/skills/kio-frontend-craft`). All commands below use `${KIO_FE_ROOT:-skills/kio-frontend-craft}`.

## ⚙️ How to work

1. **New UI → pick a design system first, never improvise.**
   ```bash
   python3 "${KIO_FE_ROOT:-skills/kio-frontend-craft}/scripts/search.py" "<product type + mood>" --design-system [--stack nextjs]
   ```
   It returns a page pattern, style, palette, font pairing, effects and anti-patterns. Record them and apply them consistently.
2. **Pick exactly one primary reference** from the [routing table](#-routing-table). For overlaps use the [selection rules](#-selection-rules-for-overlaps).
3. **Look details up by domain/stack** instead of guessing: `--domain style|color|typography|icons|landing|product|ux|chart|gsap|react|web|google-fonts`, `--stack <framework>`.
4. **Before delivery** always run the checklist in `references/ui-ux/pro-rules.md` (*Pre-Delivery Checklist*) and check at 375 px, 768 px and 1440 px.

## 🧭 Routing table

| Task | Open | Notes |
|---|---|---|
| Choose style, colours, fonts, icons, landing pattern | `scripts/search.py` (`--design-system`, `--domain`) | Data: `data/*.csv`, 192 reasoning profiles in `data/ui-reasoning.csv` |
| Full UI/UX rules in 10 groups (accessibility, touch, layout, forms, navigation, charts…) | `references/ui-ux/quick-reference.md` | CRITICAL → LOW priority |
| Professional rules + pre-delivery checklist | `references/ui-ux/pro-rules.md` | The single, mandatory checklist |
| UI "looks AI-generated" and needs a redo | `references/unslop-9-pass.md` | 9 passes, in order |
| 3-layer design tokens | `templates/design-tokens-starter.json` | Primitive → semantic → component |
| Lenis smooth scroll, GSAP ScrollTrigger | `references/motion-lenis.md` | `data-lenis-prevent`, reduced motion |
| Core Web Vitals, PageSpeed 95–100, page performance audit | `references/web-performance.md` | LCP, CLS, INP, 5-phase audit |
| React / Next.js performance (waterfalls, bundle, RSC, re-renders) | `references/react/README.md` → `references/react/rules/<rule>.md` | 64 rules, 8 groups; full compiled guide: `references/react/AGENTS.md` |
| Framework rules (Vue, Svelte, Astro, shadcn, Flutter, WPF…) | `search.py --stack <name>` | 22 stacks, 1,271 rules |
| React Native / Expo / SwiftUI apps | `references/mobile/README.md` → `references/mobile/react-native-expo.md`, `references/mobile/swiftui-ios.md`, `references/mobile/performance-and-offline.md` | |
| PDF / mockup → responsive HTML | `references/pdf-to-html.md` | Scripts `scripts/convert.sh`, `scripts/extract_sections.py` |

## 🔀 Selection rules for overlaps

| Need | Start at | Switch when |
|---|---|---|
| Slow page | `web-performance.md` (measure first) | The cause is in React/Next.js code → `react/rules/` by group `async-`, `bundle-`, `server-`, `rerender-` |
| React component review | `react/README.md` | The issue is visual/accessibility → `ui-ux/quick-reference.md` |
| Beautify an old UI | `unslop-9-pass.md` | Only small fixes needed → `ui-ux/pro-rules.md` |
| Mobile | `mobile/README.md` | Need detailed stack rules → `search.py --stack react-native` / `swiftui` / `flutter` |
| Motion | `motion-lenis.md` | Need motion presets → `search.py "<mood>" --domain gsap` |

## 🧩 Workflows

| Job | Order |
|---|---|
| New landing page | `search.py --design-system` → tokens → `ui-ux/quick-reference.md` → `motion-lenis.md` (if needed) → `web-performance.md` → `ui-ux/pro-rules.md` checklist |
| Redo an AI-looking UI | Screenshot current state → `search.py --design-system` → `unslop-9-pass.md` → checklist |
| Slow Next.js app | `web-performance.md` (Lighthouse mobile + desktop) → `react/rules/` by cause → measure again |
| PDF → website | `pdf-to-html.md` → tokens → `ui-ux/quick-reference.md` (responsive) → `web-performance.md` |
| New mobile app | `mobile/README.md` → `search.py --stack react-native` → `mobile/performance-and-offline.md` |

APIs, databases and payments belong to `kio-backend-cloud`; Playwright UI testing to `kio-qa-security`; marketing copy and CRO to `kio-growth-marketing`.

## 🛡️ Mandatory rules

1. **No edge bleed (defensive spacing).**
   - Every section sits in `max-w-7xl mx-auto px-4 sm:px-6 md:px-8 lg:px-12`; no text, card or form touches the screen edge at 375 px.
   - Offset fixed headers with `pt-20 sm:pt-28`; leave `pb-20 sm:pb-32` before the footer.
   - Inputs at least `py-3 px-4`, 44 px tall, ≥ 16 px text (no iOS auto-zoom); buttons at least `py-2.5 px-5`.
2. **No generic AI look.** No decorative neon purple gradients, identical 3-column bento grids, emoji as icons, or buzzword copy.
3. **Accessibility is a delivery requirement.** Text contrast ≥ 4.5:1 (large text and controls ≥ 3:1) in light and dark; visible focus; fully keyboard operable; images have `alt`.
4. **Performance is a delivery requirement.** LCP < 2.5 s, CLS < 0.1 (target 0), INP < 200 ms on mobile; images carry dimensions and `aspect-ratio`.
5. **React 19 / Next.js:** Server Components by default, Client Components at the leaves; no sequential `await` waterfalls when work can run in parallel.
6. **Motion respects `prefers-reduced-motion`** and animates only `transform`/`opacity`.

## 📦 What's included

- `data/` — styles, colours, typography, icons, landing, products, UX, charts, motion, React performance, 22 stacks; `catalog-summary.json` (counts), `data-provenance.json` (sources and review dates).
- `scripts/` — `search.py` (BM25 search + design systems), `validate_data.py`, `convert.sh`, `extract_sections.py`; tests: `python3 -m pytest scripts/tests`.
- `references/` — the documents in the table above. `templates/` — design tokens.
- `THIRD_PARTY_NOTICES.md` — credits and licenses for the open-source sources Kio uses; keep it when redistributing.
