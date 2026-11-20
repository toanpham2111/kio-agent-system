---
name: kio-frontend-craft
description: "Kio Master Frontend, UI/UX & Motion Powerhouse — Unifies Anti-Slop aesthetics, 79 UI styles, 192 palettes, 3-layer Design Tokens, the 9-Pass De-Slopping SOP (/unslop), Lenis 60fps Smooth Scroll (lenis.dev), Core Web Vitals optimization (95-100 PageSpeed), Pixel-Perfect PDF-to-HTML conversion with Base64 asset inlining, React Native / Expo Mobile, and React 19 / Next.js App Router best practices."
author: Toan Pham / Kio System
version: 2.0.0
---

# 🎨 Kio Master Frontend, UI/UX & Motion Powerhouse (`kio-frontend-craft`)

The unified frontend engineering and client-side design powerhouse of the Kio System. Integrates 6 core client-side modules:

---

## 🧭 Core 6 Frontend Engines Matrix

| Engine | Functional Module | Core Mission & Deliverables |
| :--- | :--- | :--- |
| **1. Anti-Slop UI/UX** | `kio-ui-ux` | 79 UI Styles, 192 Palettes, 74 Font Pairings, 3-layer Design Tokens. Strict ban on cliche AI neon gradients and cookie-cutter 3-card bento grids. CLI lookup: `scripts/search.py`. |
| **2. 9-Pass De-Slopping** | `/unslop` | Systematic 9-step legacy UI refactoring: Spacing ➔ Color (80/15/5 ratio) ➔ Icons (no emojis as icons) ➔ Copy (anti-AI buzzwords) ➔ Typography ➔ Layout (asymmetry) ➔ Details ➔ Visuals ➔ Motion. |
| **3. Motion & Smooth Scroll** | `lenis.dev` | Enterprise 60fps **Lenis Smooth Scroll** integration (RAF loop, GSAP ScrollTrigger ticker synchronization, mandatory `data-lenis-prevent` for nested scrolls/modals, prefers-reduced-motion compliance). |
| **4. Peak Web Performance** | `kio-web-perf` | Core Web Vitals optimization targeting **95–100 PageSpeed**: `LCP < 2.5s` (fetchpriority, dimensions), `CLS = 0.00` (aspect-ratio reserving), `INP < 200ms` (unblocked main thread). |
| **5. PDF to Responsive Web** | `kio-pdf2html` | Pixel-perfect 1:1 PDF-to-HTML conversion. `scripts/extract_sections.py` extracts embedded Base64 imagery into `images/` and outputs structured `design_spec.md`. Maps fixed presentation slides into modern responsive CSS Grid/Flexbox layouts. |
| **6. Mobile & React Modern** | `kio-mobile` & `react` | React Native, Expo Router, SwiftUI, 60fps gesture physics, React 19 Server Components by default with Client Components isolated at leaves. |

---

## 🛡️ Non-Negotiable Architecture Standards

1. **🛡️ Zero-Edge-Bleed & Defensive Spacing (BAN CLIPPED EDGES)**:
   - Every section MUST be wrapped in a responsive container: `max-w-7xl mx-auto px-4 sm:px-6 md:px-8 lg:px-12`. Never allow text, cards, or inputs to touch viewport edges at 0px on any screen (especially 375px mobile).
   - Header/Footer Clearance: Always offset sticky headers with `pt-20 sm:pt-28` and maintain generous footer breathing room `pb-20 sm:pb-32`.
   - Form Controls & Inputs: Minimum inner padding `py-3 px-4`, min-height 44px, font-size >= 16px (prevents iOS auto-zoom). Button minimum padding `py-2.5 px-5`.

2. **🌊 Standard Lenis Smooth Scroll Boilerplate**:
   ```javascript
   import Lenis from 'lenis'
   const lenis = new Lenis({
     duration: 1.2,
     easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
     smoothWheel: true,
   })
   function raf(time) {
     lenis.raf(time)
     requestAnimationFrame(raf)
   }
   requestAnimationFrame(raf)
   ```

3. **🧹 Style & Palette Knowledge CLI Search**:
   ```bash
   python3 skills/kio-frontend-craft/scripts/search.py "<keyword>" --design-system
   python3 skills/kio-frontend-craft/scripts/search.py "<keyword>" --domain fintech
   ```

4. **📄 PDF / Mockup Section Extraction**:
   ```bash
   python3 skills/kio-frontend-craft/scripts/extract_sections.py <file.html>
   ```
