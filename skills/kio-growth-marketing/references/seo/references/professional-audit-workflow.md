# WPA SEO — Professional audit workflow (v2.0)

This reference converts the *KS Jewellery SEO Audit* (13 pages, user-provided, dated 1 Nov 2026; described as live inspections 3 Nov 2026) into reusable guidance. It is **not** a fresh verification of that website, and its numerical findings must not be applied to another project.

## Evidence protocol (run first)
Capture target domain, site owner, target market, language, platform, live vs staging, access level, tool outputs and observation date. Tag claims as **Verified**, **Likely**, **Needs access**, or **Not tested**. Where access to Search Console, Analytics, Business Profile, rank/keyword tools or field Core Web Vitals is missing, explicitly say so. Avoid inventing metrics. List positive findings as well as defects.

## Audit modules

### A. Domain integrity and crawl/index controls — highest priority
- Test HTTP/HTTPS and www/non-www variants; capture status codes and full redirect chains. Check one preferred canonical URL per indexable page, including paginated and product content.
- Examine staging and preview copies and accidental test pages; identify whether they are publicly accessible, indexable or confirmed indexed (these are different states). Recommend authenticated staging and appropriate `noindex`; do not equate robots.txt blocking with deindexation.
- Inspect robots.txt, XML sitemap index and children; check only canonical, valid, indexable URLs are included. Review users/author sitemap and WooCommerce cart/checkout/account with business-specific caution.
- Check mixed-content links, response language, crawler challenges/bot protection, server headers; classify non-ranking security hygiene separately.
- Confirm any proposed 301 changes, DNS, hosting, CDN and payment impact with owner before implementation.

### B. On-page metadata and media
- Examine page-specific title, meta description, semantic H1/headings, canonical, OG/social cards and rendered HTML. Prefer compelling and accurate copy; character counts are hints, not strict ranking thresholds.
- Inspect meaningful image alt text versus decorative alt='', file naming, responsive images. Do not fill decorative images with keyword stuffing.
- Validate JSON-LD graph for suitable Organization/LocalBusiness subtype, BreadcrumbList, Product, and genuinely visible FAQs only; avoid duplicate schema with existing plugins.

### C. Information architecture and content
- Cluster user intent and services. Audit whether distinct high-value offerings have discoverable, sufficiently useful landing pages rather than homepage cards/modals alone.
- Recommend each justified service page cover service scope, process, limitations, lead time/pricing guidance **if verified**, proof, genuine FAQs and clear contact CTA. Link to related services and relevant articles naturally.
- Remove/noindex thin test pages appropriately, keep a clean sitemap, plan redirects for changed slugs; check ecommerce product titles, unique descriptions and factual Product schema.

### D. Local SEO and business identity
- Compare NAP (name, address incl. unit, phone), hours and brand across website, Google Business Profile, directories and other legitimate web properties.
- Resolve business identity conflicts with owner: multiple units, trading names, secondary domains and multiple locations may be legitimate. Do not consolidate without authorization.
- Check appropriate business subtype and categories, verified attributes, `sameAs` profiles, photos, services and reviews. Encourage authentic reviews without incentivization or fabricated claims.

### E. Keywords, content and competitors
- Identify transactional, informational, local and niche search intent. Research actual SERP competitors where tools are available; distinguish observed rankings from estimates.
- Compare page format, content depth, process/pricing transparency, first-party photos and CTA, *not* copied wording. Avoid ungrounded competition/volume estimates.
- Prioritize unique, defensible expertise and case studies; map articles to service pages and update older posts/URLs with proper redirects when justified.

### F. Performance, credibility and AEO
- Observe payloads, scripts, stylesheets, inline styles and image counts as diagnostic clues; measure LCP, INP and CLS with device and data-source context. Common good thresholds: LCP <= 2.5s, INP <= 200ms, CLS <= 0.1 (75th percentile field data where available).
- Make author, business, expertise, location, legal/guarantee information and original evidence easy to verify; do not invent credentials or ratings.
- For AEO, answer likely questions plainly, retain accessible HTML, identify entities, cite verifiable sources and use structured data accurately; no promise of AI citations.

## Prioritization and implementation roadmap
- **Critical:** domain/canonical conflicts, unintended indexable staging, major crawl accessibility issues; confirm evidence before labeling critical.
- **High:** important page metadata gaps, thin/indexable test pages, missing distinct commercial landing pages, broken indexing.
- **Medium:** local identity inconsistency, schema omissions, relevant image descriptions, content linking, observed payload concerns.
- **Low/opportunity:** refinements, additional case studies, outreach and eligible content expansion.
- **Phase 1 (immediate):** stop technical/indexing leaks, establish measurement, repair titles/meta of key pages.
- **Phase 2 (foundations):** service architecture, local identity, structured data, internal links, image quality and key UX fixes.
- **Phase 3 (growth):** validated keyword content, products, case studies, performance iteration, legitimate community links.
These phases are **ordering guidance**, not universal deadlines or a guaranteed outcome.

## Audit measurements and status
Show coverage, observed URLs, timestamps and evidence artifacts. Offer a subjective score only when user requests one and a transparent rubric is supplied; avoid implying Google-issued scores. Track indexability/status (Search Console), impressions/clicks, local calls/directions (Business Profile), qualified leads/conversions (analytics), and CWV with source and dates. Do not extrapolate Search Console metrics from a crawl.

## Deliverable
Use `report-template.md`; provide severity, affected URL, observed evidence, user impact, safe recommended action, responsible owner, effort/dependency, validation test and status. Identify wins and missing access separately. Ask explicit approval for production-impacting changes.
