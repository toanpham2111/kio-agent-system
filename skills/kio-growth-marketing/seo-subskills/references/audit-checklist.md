# SEO & AEO audit checklist

Mark each item Pass / Fail / N/A / Not Verified and capture evidence.

## Crawlability and indexability
- Intended public pages return an appropriate HTTP status and are reachable through internal links.
- Robots.txt allows desired crawling; robots meta / X-Robots-Tag expresses desired indexing.
- Canonical tags are absolute, correct and consistent with redirects and hreflang where used.
- XML sitemap includes only canonical, indexable URLs, responds successfully and is not stale.
- Important content and links appear in accessible rendered HTML.
- No broken internal links, redirect loops or unexplained soft-404 patterns.

## On-page
- Each important page has a distinct, relevant title and helpful meta description.
- Headings are descriptive, structured logically and represent the content.
- Images have appropriate alt text when informative; decorative images are not needlessly keyword-stuffed.
- Locales, mobile viewport and social preview metadata are appropriate.
- Content satisfies a real query and is accurate, maintained and attributable where applicable.

## Structured data
- Schema type matches page intent and visible claims.
- Required and recommended properties are present where actually known.
- Validate JSON syntax and inspect Google Rich Results Test / Schema Markup Validator where appropriate.
- Watch for duplicated plugin/theme JSON-LD.

## Performance and UX
- Check LCP, INP and CLS using actual measurement tools when available; do not estimate metrics.
- Review image sizing, caching, render-blocking resources, fonts and mobile usability.

## AEO and trust
- Key questions receive direct, accurate answers in content users can see.
- Terms/entities are unambiguous and references for factual claims are traceable.
- Business/contact/author context is accurate when relevant.
- No invented FAQ entries, review stars or authority signals.
- Record AI-search recommendations as hypotheses unless validated with observations.

## Platform-specific
- WordPress: check SEO plugin ownership, site visibility setting, permalinks and WooCommerce transactional pages.
- Next.js: inspect `metadata`, `generateMetadata`, route-specific canonicals, `robots.ts`, `sitemap.ts`, build output and rendered pages.
