# WordPress Build Pipeline Rules

## Order of Stages

```
S0 env ──► S1 analyze ──► S2 foundation ──► S3 blocks ──► S4 editor parity
                                                              │
                              S8 report ◄── S7 functional QA ◄── S6 visual QA ◄── S5 content+media
```

- **S0 (Environment & Setup)**: 
  - **Project Discovery**: Scan and analyze repository structure (`wp-content`, themes, plugins, docker-compose).
  - **Port Scanning**: Bind port requested by user; if unspecified, automatically scan for an available port in `8080–8999`.
  - **Database Configuration**: DB name must match project slug in snake_case (`DB_NAME=<project_slug>`). All credentials 100% loaded from `.env`.
  - **Admin Security**: Strict ban on username `admin`. Must use `<project_slug>_admin` with a cryptographically strong password (>= 16 characters).
  - **Adaptive Theme & Docker**:
    - If `wp-content/themes/ai-zippy` exists: Use `ai-zippy` and activate child theme `ai-zippy-child`.
    - If another theme exists (Astra, Flatsome, Custom Theme): Preserve and conform to existing theme architecture.
    - If greenfield environment without `ai-zippy`: Automatically generate a **Standalone FSE Block Theme** at `wp-content/themes/<project-slug>/` with `theme.json` v3, `parts/header.html`, `parts/footer.html`, `templates/`, and auto-register dynamic SSR blocks in `functions.php` via `@wordpress/scripts`.
    - Docker initialization: Auto-configure `webnet` network or attach database service `mariadb:10.11` if no global MySQL container exists.
- **S1 (Analysis)**: Author `ui-spec.md` & `block-map.md`.
- **S2 (Foundation & FSE Architecture)**: 
  - `theme.json`, SCSS tokens, Base typography.
  - **Drag-and-Drop FSE Header & Footer**: Must use FSE Template Parts (`parts/header.html`, `parts/footer.html`) or Navigation Blocks. Hardcoded HTML in PHP templates is strictly forbidden.
  - **WooCommerce Design Tokens**: Synchronize SCSS variables for Primary/Accent colors, typography, and form inputs for Cart, Checkout, and My Account pages.
- **S3 (Custom Dynamic Blocks & CTA Standards)**: 
  - Each block requires standard 7 files and an isolated SCSS partial.
  - **100% Gutenberg Editable**: Never hardcode headings, copy, or media into `render.php`. All content must flow through Block Attributes or ACF fields.
  - **CTA Button Admin Flexibility**: Every CTA button must expose URL and icon picker controls in Admin.
- **S4 (Editor Parity & Admin Edit Page Verification)**: 
  - Gutenberg Editor canvas must match the live Frontend 100%.
  - Verify block attributes can be updated directly inside the WP Admin page editor without console warnings or layout breakage.
- **S5 (Content & Media)**: Sideload media into the Media Library, construct pages, and seed realistic demo content.
- **S6 (Visual QA & WooCommerce Styling Sync)**: 
  - Multi-device automated screenshots across Desktop (1440px), Tablet (768px), Mobile (375px) via Playwright MCP.
  - Verify WooCommerce core pages (`/cart`, `/checkout`, `/my-account`) match project design tokens.
- **S7 (Functional QA: Forms, Mini-Cart, Search)**: 
  - **Form Email Test**: Execute live form submission tests (Contact, Booking, Newsletter). Verify nonce verification, backend sanitization, `wp_mail()` dispatch, and toast notifications.
  - **WooCommerce Mini-Cart Zero-Bug**: Verify the mini-cart drawer opens immediately on the Homepage during cold start, displays empty cart states properly, and updates via AJAX fragments.
- **S8 (Report & Delivery)**: 
  - Generate required visual delivery report: **`src/report-<project-name>.html`**.
  - Report must include:
    1. Admin Credentials: Username (`<project_slug>_admin`), random password, login URL `/wp-admin`.
    2. Detailed Changelog and modified component inventory.
    3. Side-by-side Before/After comparison diff table.
    4. Real browser screenshots captured via Playwright MCP across Desktop, Tablet, and Mobile viewports.

---

## 🔄 Disciplined QA-Dev Zero-Bug Loop
- **Non-Negotiable Verification**: QA and Kio Agent serve as the final approval gatekeepers.
- Immediate REJECTION triggers:
  1. ❌ Form fails to send live emails via `wp_mail()`.
  2. ❌ CTA button lacks dynamic link or icon fields in Admin.
  3. ❌ Gutenberg editor contains hardcoded uneditable text or images.
  4. ❌ Mini-cart fails to open on the Homepage or breaks on cold load.
  5. ❌ Cart, Checkout, or My Account pages display unstyled default WooCommerce layouts.
  6. ❌ Header or Footer are static PHP/HTML instead of editable FSE Template Parts.
- **Action**: QA/Kio **MUST REJECT (FAIL)** immediately and dispatch specific bug checklists back to Dev. Dev must iterate until all acceptance criteria pass.
