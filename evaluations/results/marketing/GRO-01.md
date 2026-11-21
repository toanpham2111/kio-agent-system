# Benchmark Evidence: GRO-01 — CRO Funnel Hierarchy & Valid Schema.org JSON-LD (A/B Comparison)

- **Skill Evaluated**: `kio-growth-marketing` (`v1.0.2`)
- **Model / Harness**: Google Antigravity IDE (Gemini 4 Argon)
- **Evaluation Date**: 2026-11-21
- **Baseline Score (No Skill)**: **5.5 / 10.0 (FAIL)**
- **With Kio Skill Score**: **8.9 / 10.0 (PASS)**
- **Quality Delta**: **+3.4 pts**

---

## 1. Input Prompt
```text
Rewrite the hero copy and conversion structure for a backend engineering bootcamp landing page to maximize trial signups, and generate valid Schema.org Course JSON-LD markup.
```

---

## 2. Baseline Output (Without `kio-growth-marketing`)

### Raw Baseline Output
```markdown
### Hero Copy
**Headline**: Unlock Your Potential with Our Next-Gen Backend Bootcamp!
**Subheadline**: Supercharge your career and revolutionize the way you code with our world-class, game-changing curriculum.
**CTA**: Submit

### JSON-LD
```json
{
  "@context": "https://schema.org",
  "@type": "Course",
  "name": "Backend Bootcamp"
}
```
```

### Baseline Defects Observed
- **AI Slop Copywriting**: Loaded with vague buzzwords (*"Unlock Your Potential"*, *"Next-Gen"*, *"Supercharge"*, *"game-changing"*) and weak friction-heavy CTA (*"Submit"*).
- **Incomplete Schema.org Markup**: Missing mandatory Google Rich Result properties (`description`, `provider`, `offers`, `hasCourseInstance`).

---

## 3. Output With `kio-growth-marketing` Activated

### Raw Kio Skill Output
```markdown
### 1. Outcome-First Hero & 5-Stage Conversion Funnel

- **Headline**: Build and deploy production Go & PostgreSQL systems that handle 10,000 req/s—in 8 weeks.
- **Subheadline**: Hands-on distributed systems labs reviewed by Staff Engineers. Ship a multi-tenant API, an idempotent billing engine, and a high-availability Redis cluster.
- **Primary CTA**: `Start Free Week-1 Lab (No Credit Card)`
- **Risk Reversal Micro-copy**: `14-day full tuition refund guarantee • Live code reviews every Thursday`

#### Funnel Section Order (Fogg Behavior Model: High Motivation + Low Friction)
1. **Above the Fold (Hero)**: Concrete technical outcome + zero-risk sandbox CTA.
2. **Proof of Competence**: GitHub repositories shipped by recent alumni + hiring manager quotes.
3. **Syllabus by Production Deliverable**: Week-by-week architecture artifacts (no vague module titles).
4. **Transparent Tuition & Guarantee**: Upfront price vs. employer reimbursement template.
5. **Objection-Handling FAQ**: Time commitment (8 hrs/week), prerequisites, and refund policy.

---

### 2. Validated Schema.org `Course` JSON-LD

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Course",
  "name": "Production Backend Engineering with Go & PostgreSQL",
  "description": "An 8-week intensive engineering course covering multi-tenant PostgreSQL RLS, distributed caching, idempotent webhooks, and load testing to 10,000 RPS.",
  "provider": {
    "@type": "Organization",
    "name": "Kio Systems Academy",
    "sameAs": "https://github.com/toanpham2111/kio-agent-system"
  },
  "offers": {
    "@type": "Offer",
    "category": "Paid",
    "price": "490.00",
    "priceCurrency": "USD",
    "availability": "https://schema.org/InStock"
  },
  "hasCourseInstance": {
    "@type": "CourseInstance",
    "courseMode": "Online",
    "courseWorkload": "PT8H"
  }
}
</script>
```
```

---

## 4. Rubric Score Breakdown (Baseline vs. With Skill)

| Criterion | Max | Baseline | With Skill | Notes & Deductions |
| :--- | :---: | :---: | :---: | :--- |
| **Anti-Buzzword Copywriting Signal** | 3.0 | 1.0 | 3.0 | Zero AI cliches; leads with measurable engineering outcomes (`10,000 req/s`, `8 weeks`). |
| **CRO Funnel & Friction Reduction** | 3.0 | 1.5 | 2.7 | Specific low-friction CTA (`Start Free Week-1 Lab`) + risk-reversal (-0.3: A/B test hypothesis metric not explicitly stated). |
| **Schema.org Rich Result Validity** | 2.0 | 1.0 | 2.0 | Includes `provider`, `offers`, and `hasCourseInstance` with ISO-8601 `courseWorkload`. |
| **GEO / Search Entity Structure** | 2.0 | 2.0 | 1.2 | Clear entity clarity (-0.8: companion `FAQPage` JSON-LD block omitted). |
| **Total** | **10.0** | **5.5 (FAIL)** | **8.9 (PASS)** | **+3.4 improvement** |
