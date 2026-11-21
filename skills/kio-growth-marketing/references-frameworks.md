# Kio Growth Marketing — Frameworks & Tooling Reference Guide

Comprehensive architecture and module reference for **`kio-growth-marketing`** inside the [Kio Agent System](https://github.com/toanpham2111/kio-agent-system).

---

## 1. Directory Structure

```
skills/kio-growth-marketing/
├── SKILL.md                   # Master Growth Marketing & Technical SEO router
├── modules/                   # Specialized CRO, copywriting, and growth sub-modules
│   ├── ab-testing/
│   ├── ad-creative/
│   ├── ads/
│   ├── ai-seo/
│   ├── analytics/
│   ├── attribution/
│   ├── churn-prevention/
│   ├── cold-email/
│   ├── content-strategy/
│   ├── conversion-tracking/
│   ├── copywriting/
│   ├── cro/
│   ├── customer-research/
│   ├── emails/
│   ├── launch/
│   ├── lead-magnets/
│   ├── marketing-loops/
│   ├── marketing-plan/
│   ├── marketing-psychology/
│   ├── onboarding/
│   ├── pricing/
│   ├── programmatic-seo/
│   ├── referrals/
│   ├── revops/
│   ├── sales-enablement/
│   ├── signup/
│   ├── site-architecture/
│   └── social/
├── seo-subskills/             # Technical SEO, Schema.org JSON-LD, E-E-A-T & GEO modules
│   ├── subskills/
│   ├── agents/
│   └── scripts/
└── tools/                     # Zero-dependency Node.js CLIs & tool integration guides
    ├── REGISTRY.md            # Complete index of marketing/analytics integrations
    ├── SETUP.md               # Environment & local credentials setup
    ├── clis/                  # Zero-dependency Node.js CLI utilities (Node 18+)
    ├── composio/              # OAuth/MCP integration mapping
    └── integrations/          # Per-platform API & analytics integration guides
```

---

## 2. CLI Verification & Usage

All CLI scripts inside `tools/clis/*.js` are zero-dependency Node.js 18+ utilities:

```bash
node --check skills/kio-growth-marketing/tools/clis/<name>.js          # Syntax check
node skills/kio-growth-marketing/tools/clis/<name>.js                  # Display help & usage
node skills/kio-growth-marketing/tools/clis/<name>.js <cmd> --dry-run  # Preview HTTP payload safely
```

---

## 3. Tool Registry & Integration Mapping

- **Tool discovery**: Consult [`tools/REGISTRY.md`](tools/REGISTRY.md) for the full catalog of supported analytics, CRM, email, and advertising platforms.
- **Integration guides**: Consult `tools/integrations/{tool}.md` for authentication, API endpoints, and implementation recipes:
  - **Analytics & Funnels**: `ga4.md`, `mixpanel.md`, `amplitude.md`, `posthog.md`, `segment.md`
  - **Lifecycle & Email**: `customer-io.md`, `mailchimp.md`, `resend.md`, `klaviyo.md`, `activecampaign.md`
  - **Paid Acquisition**: `google-ads.md`, `meta-ads.md`, `linkedin-ads.md`, `tiktok-ads.md`
  - **Referrals & Affiliates**: `rewardful.md`, `tolt.md`, `dub-co.md`, `partnerstack.md`

---

## 4. Core Growth & SEO Quality Standards

1. **Outcome-First Copywriting (Anti-Slop)**: Avoid generic AI marketing buzzwords (*"Unlock synergies"*, *"Game-changing revolution"*). Focus on measurable customer outcomes, specific pain points, and concrete social proof.
2. **Behavioral CRO Frameworks**: Ground conversion recommendations in established behavioral models (Fogg Behavior Model $B = MAP$, Cialdini's Principles of Persuasion, jobs-to-be-done).
3. **Validated Schema.org JSON-LD**: Every landing page, article, product, or local business template must include syntactically valid JSON-LD (`Organization`, `Product`, `Course`, `Article`, `FAQPage`, `BreadcrumbList`).
4. **Generative Engine Optimization (GEO)**: Structure authoritative content with clear entity definitions, citation-ready statistics, and semantic HTML hierarchy for Google AI Overviews, ChatGPT Search, and Perplexity.
