---
name: kio-frontend-craft
description: "Build high-craft, accessible frontend UI/UX with defensive spacing, WCAG contrast palettes, and Core Web Vitals optimization. Use when designing, building, or refactoring web and mobile interfaces."
author: Toan Pham / Kio System
version: 1.0.2
---

# 🎨 Kio Frontend Craft — UI/UX & Motion Engineering (`kio-frontend-craft`)

The unified frontend engineering and client-side design skill of the Kio System. Integrates 6 core client-side modules:

---

## 🧭 Core 6 Frontend Modules Matrix

| Module | Resource / Tooling | Core Mission & Deliverables |
| :--- | :--- | :--- |
| **1. Anti-Slop UI/UX** | `data/` & `scripts/search.py` | 79 UI Styles, 192 Palettes, 74 Font Pairings, 3-layer Design Tokens. Strict ban on cliche AI neon gradients and cookie-cutter 3-card bento grids. |
| **2. 9-Pass De-Slopping** | 9-Step Refactoring SOP | Systematic 9-step legacy UI refactoring: Spacing ➔ Color (80/15/5 ratio) ➔ Icons (no emojis as icons) ➔ Copy (anti-AI buzzwords) ➔ Typography ➔ Layout (asymmetry) ➔ Details ➔ Visuals ➔ Motion. |
| **3. Motion & Smooth Scroll** | Lenis Smooth Scroll | Enterprise 60fps **Lenis Smooth Scroll** integration (RAF loop, GSAP ScrollTrigger ticker synchronization, mandatory `data-lenis-prevent` for nested scrolls/modals, prefers-reduced-motion compliance). |
| **4. Peak Web Performance** | Core Web Vitals | Core Web Vitals optimization targeting **95–100 PageSpeed**: `LCP < 2.5s` (fetchpriority, dimensions), `CLS = 0.00` (aspect-ratio reserving), `INP < 200ms` (unblocked main thread). |
| **5. PDF to Responsive Web** | `scripts/extract_sections.py` | Pixel-perfect 1:1 PDF-to-HTML conversion. Extracts embedded Base64 imagery into `images/` and outputs structured `design_spec.md`. Maps fixed presentation slides into modern responsive CSS Grid/Flexbox layouts. |
| **6. Mobile & React Modern** | `data/stacks/` | React Native, Expo Router, SwiftUI, 60fps gesture physics, React 19 Server Components by default with Client Components isolated at leaves. |

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
