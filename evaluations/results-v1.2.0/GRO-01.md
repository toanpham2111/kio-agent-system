# GRO-01 — A/B re-run for v1.2.0

- **Skill:** `kio-growth-marketing` (as shipped in v1.2.0)
- **Generation model:** `claude-sonnet-5-5` (both runs) · **Judge model:** `claude-opus-5-5`
- **Harness:** Claude Code CLI, [`../harness/run_bench.py`](../harness/run_bench.py); baseline = empty project, with skill = project containing only `kio-growth-marketing`, invoked as `/kio-growth-marketing`
- **Judge:** blind (answers labelled X/Y in a seeded random order: baseline = X, with skill = Y), rubric from the v1.0.2 scenario file
- **Skill files read during the with-skill run:** none beyond the injected `SKILL.md`
- **Score:** baseline **7.0 / 10** · with skill **6.4 / 10** · Δ **-0.6**

## Prompt
```text
Rewrite the hero copy and conversion structure for a backend engineering bootcamp landing page to maximize trial signups, and generate valid Schema.org Course JSON-LD markup.
```

## Rubric scores

| Criterion | Max | Baseline | With skill |
| :--- | :---: | :---: | :---: |
| Anti-Buzzword Copywriting Signal | 3.0 | 1.8 | 1.5 |
| CRO Funnel & Friction Reduction | 3.0 | 2.5 | 2.4 |
| Schema.org Rich Result Validity | 2.0 | 1.6 | 1.5 |
| GEO / Search Entity Structure | 2.0 | 1.1 | 1.0 |
| **Total** | **10** | **7.0** | **6.4** |

## Judge notes

- **Baseline:** X avoids clichés and sets a week-1 deploy outcome, but it has no throughput-type metric; it gives a clear no-card trial, a no-auto-charge risk reversal and a stated primary metric. The Course schema has provider, offers and an instance, but 'PT12H per week' is not valid ISO-8601, and there is no FAQPage JSON-LD.
- **With skill:** Y's hero is positioning-led ('not tutorial apps') and has no measurable engineering outcomes; it gives a solid free-week CTA, friction reduction and a primary metric. It wrongly calls 'PT10H per week' valid ISO-8601, has weaker provider sameAs entity signals, and omits the FAQPage JSON-LD.

## Baseline output (no skill)

<details><summary>Show full answer (8238 characters)</summary>

# Backend Engineering Bootcamp: Landing Page Rewrite

I had no brand, pricing, or trial details, so the items in `[brackets]` are placeholders. Replace them with real facts. Don't ship invented stats or ratings. Google's structured-data policies penalize markup that doesn't match visible page content.

## 1. Conversion strategy

- **One goal:** start the free trial. Every CTA on the page says the same thing and goes to the same form.
- **Lower the barrier:** no credit card, and email-only signup. Ask for goal and experience level after signup, not before.
- **Lead with the outcome:** the job-ready skill and a concrete deliverable, not the curriculum.
- **Remove doubts in order:** "Is it for me?", "Will it work?", "What's the catch?", "What happens next?"

## 2. Hero

**Eyebrow:** Backend Engineering Bootcamp · [12 weeks] · Live mentors

**H1:** Ship a production-ready backend in your first week. Get hired for it in [12].

**Subhead:** Learn APIs, databases, auth, testing, and cloud deployment by building real services with code review from working engineers. Start the [7-day] free trial and deploy your first API today.

**Primary CTA button:** Start my free trial

**Microcopy under button:** No credit card · Cancel anytime · Full access to Module 1–2

**Secondary CTA (text link):** See the syllabus →

**Trust strip (use only true facts):**
- [N] graduates · [X%] hired within [6] months *(only with a published methodology)*
- Alumni now at [Company], [Company], [Company]
- Rated [4.x/5] on [Platform] ([N] reviews)

**Hero visual:** a short (under 30s) screen recording of an API going from `git push` to a live URL. It shows the outcome instead of a stock photo.

## 3. Section order

| # | Section | Purpose | Copy direction |
|---|---|---|---|
| 1 | Hero | Promise and CTA | See above |
| 2 | Social proof bar | Credibility | Logos, grads, rating |
| 3 | "Is this for you?" | Self-qualify, cut objections | Two columns: *Great fit* (knows one language, wants to move beyond tutorials) and *Not yet* (never coded, so start with [prep course]) |
| 4 | What you'll build | Make it concrete | 3 project cards: REST API with auth, event-driven service with a queue, deployed app with CI/CD and monitoring. Each lists stack and what it proves to employers |
| 5 | What's in the trial | Remove "what's the catch" | Checklist: Module 1–2 lessons, one graded project, one mentor code review, community access. State what happens on day 8: "You choose. We never auto-charge." |
| 6 | Curriculum, condensed | Show rigor | Accordion by week: Foundations, Data, Systems, Deploy. Link to full syllabus |
| 7 | How it works | Reduce uncertainty | 1. Create account (30s) → 2. Deploy your first API (day 1) → 3. Get mentor feedback (day 3) → 4. Decide |
| 8 | Outcomes and testimonials | Proof | 3 named, photo-backed stories in the form *background → result → timeframe*. Add a link to the outcomes report |
| 9 | Mentors | Trust | Photo, role, company, one line each |
| 10 | Pricing, brief | Prevent surprise | "[$X]/month or [$Y] upfront. Income-share or financing: [details]." Trial CTA repeated |
| 11 | FAQ | Last objections | See below |
| 12 | Final CTA band | Close | "Your first deployed API is one afternoon away." Button: Start my free trial |

**Sticky mobile CTA bar:** the button stays pinned to the bottom after the hero scrolls out of view.

## 4. Signup form

- **Fields:** email only, with an optional "Continue with GitHub/Google" option.
- **Button:** "Create my free account"
- **Below the button:** "We'll email your login. No card needed."
- **Post-signup (progressive profiling):** current level (3 options), goal (job / promotion / side project), preferred weekly hours. Use these answers to personalize onboarding.
- **Success state:** go straight into Lesson 1. Don't show a "check your inbox" dead end.

## 5. FAQ (objection-led)

- **Do I need a CS degree?** No. You need [basic fluency in one language, e.g. Python/JS]. Take the 10-minute skills check.
- **What happens after the trial?** Nothing automatic. You'll get a reminder on day [5], and you pick a plan or walk away.
- **How much time per week?** [10–15] hours. Sessions are recorded.
- **Will I get a job?** [Honest statement of outcomes with a link to the methodology.] We don't guarantee employment.
- **Can I get a refund?** [Policy.]
- **Who reviews my code?** Working engineers at [companies], with turnaround within [48h].

## 6. Tests to run (in order of expected impact)

1. **H1 outcome framing vs. time framing:** "Ship a production backend in week 1" vs. "Become a backend engineer in 12 weeks".
2. **CTA label:** "Start my free trial" vs. "Deploy my first API free".
3. **Email-only vs. email + goal question** (completion rate and trial activation).
4. **Hero video vs. static code screenshot.**
5. **Social proof placement:** inside the hero vs. directly below it.

**Primary metric:** trial-start rate. **Guardrail metrics:** activation (Lesson 1 complete within 24h) and trial-to-paid. A winner on signups that lowers activation should not ship.

## 7. Schema.org Course JSON-LD

Place this in `<head>` or before `</body>`. Every value must match what's visible on the page. I left out `aggregateRating` on purpose: add it only if real, publicly visible reviews back it.

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Course",
  "@id": "https://www.example.com/backend-bootcamp#course",
  "name": "Backend Engineering Bootcamp",
  "description": "A 12-week, mentor-led bootcamp where you build and deploy production-ready backend services: REST APIs, databases, authentication, testing, message queues, and CI/CD on the cloud. Start with a free 7-day trial.",
  "url": "https://www.example.com/backend-bootcamp",
  "image": "https://www.example.com/images/backend-bootcamp.jpg",
  "inLanguage": "en",
  "educationalLevel": "Intermediate",
  "coursePrerequisites": "Basic proficiency in one programming language such as Python or JavaScript.",
  "teaches": [
    "Designing and building REST APIs",
    "Relational database modeling and SQL",
    "Authentication and authorization",
    "Automated testing",
    "Event-driven architecture with message queues",
    "Cloud deployment and CI/CD"
  ],
  "timeRequired": "P12W",
  "provider": {
    "@type": "Organization",
    "name": "Example Academy",
    "url": "https://www.example.com",
    "sameAs": [
      "https://www.linkedin.com/company/example-academy",
      "https://github.com/example-academy"
    ]
  },
  "offers": [
    {
      "@type": "Offer",
      "name": "7-day free trial",
      "category": "Free trial",
      "price": "0",
      "priceCurrency": "USD",
      "url": "https://www.example.com/backend-bootcamp/trial",
      "availability": "https://schema.org/InStock"
    },
    {
      "@type": "Offer",
      "name": "Full bootcamp",
      "category": "Paid",
      "price": "3995",
      "priceCurrency": "USD",
      "url": "https://www.example.com/backend-bootcamp/pricing",
      "availability": "https://schema.org/InStock"
    }
  ],
  "hasCourseInstance": {
    "@type": "CourseInstance",
    "name": "Backend Engineering Bootcamp, January 2027 cohort",
    "courseMode": "online",
    "courseWorkload": "PT12H per week",
    "startDate": "2027-01-11",
    "endDate": "2027-04-02",
    "inLanguage": "en",
    "instructor": {
      "@type": "Person",
      "name": "Jane Doe"
    }
  }
}
</script>
```

**Notes on validity**
- Required for Google's Course rich result: `name`, `description`, `provider`. Everything else is recommended or optional.
- Replace the example.com URLs, prices, dates, and instructor with real values. Add a `CourseInstance` for each live cohort. Use `courseMode: "online"` or `"onsite"` as applicable.
- Only mark up offers you actually sell. If the trial isn't a standalone purchasable offer, delete that first `Offer`.
- Validate with the Schema Markup Validator (validator.schema.org) and Google's Rich Results Test after deploying.
- Pair this with an FAQ block that matches the visible FAQ section if you want FAQ markup. FAQ rich results are now limited to well-known government and health sites in Google Search, so the benefit is mainly for other parsers.

</details>

## Output with skill

<details><summary>Show full answer (8708 characters)</summary>

# Backend Engineering Bootcamp: hero rewrite, conversion structure and Course JSON-LD

**Assumptions.** You didn't give me a product brief, so I made these up and marked them. Replace everything in `[brackets]` before shipping.

- The "trial" is a free first week or module with no card required.
- The audience is junior-to-mid developers moving into backend work.
- I invented no stats, ratings, hiring rates or salary claims. Any proof element below only goes live once you have real data.

---

## 1. Hero copy

**Eyebrow:** `[12]-week online backend bootcamp · Node.js/Go/Python`

**H1 (primary):**
> Build and ship real backend systems, not tutorial apps.

**Subhead:**
> Learn APIs, databases, auth, queues and deployment by building a production-style service with code review from working engineers. Start with a free first week: no card needed.

**Primary CTA:** `Start your free week`
**Microcopy under CTA:** `No credit card · Takes 60 seconds · Cancel anytime`
**Secondary CTA (text link):** `See the full syllabus ↓`

**Hero bullets (3, outcome-led):**
- Design and deploy a REST/GraphQL API with Postgres, caching and background jobs
- Get line-by-line code review on every project
- Finish with a deployed portfolio service you can explain in an interview

**Proof strip (only with real data):** `[N] graduates · [Company logos with permission] · [Verified rating + source]`

**A/B variants for the H1:**

| Variant | H1 | Hypothesis |
|---|---|---|
| A (control) | Build and ship real backend systems, not tutorial apps. | Outcome and anti-tutorial positioning |
| B | Learn backend engineering by building one production-grade service. | Concrete, project-based promise |
| C | Stuck at CRUD apps? Learn the backend skills teams actually hire for. | Pain-led, for people who already know the basics |

Test one element at a time. The H1 goes first, then the CTA label (`Start your free week` vs `Try Week 1 free`).

---

## 2. Conversion structure (top to bottom)

1. **Sticky nav.** Logo, Syllabus, Pricing, FAQ, and a `Start free week` button. Keep it to one CTA and drop the other nav clutter.
2. **Hero.** Copy above, plus a visual of a real code-review comment or architecture diagram. Avoid stock photos.
3. **Proof strip.** Real logos, numbers and testimonials only.
4. **Problem and outcome.** Three or four pain points, each paired with what you will be able to do:
   - "I can build CRUD but not handle concurrency, auth or scaling."
   - "My projects don't look like production code."
5. **What you'll build.** Show the capstone architecture diagram and a week-by-week syllabus in an accordion (stack, project, skill per week).
6. **How the free week works.** Three steps: Sign up → Start Week 1 (project + review) → Decide to continue. Be explicit about what's free and what happens at the end. No surprise charges.
7. **How learning works.** Live sessions, code review turnaround (`[x] hours`), mentor ratio, and weekly time commitment (`[x] hrs/week`).
8. **Instructors.** Real names, real engineering backgrounds, linked profiles.
9. **Testimonials and outcomes.** Named, specific, and tied to the skill gained. Add a mid-page CTA after this section.
10. **Pricing and guarantee.** Show the price transparently, with financing if you offer it. Add a refund or pause policy only if it is real.
11. **Objection FAQ.** Cover these:
    - "Do I need prior experience?"
    - "How much time per week?"
    - "Is the free week really free?"
    - "Which language?"
    - "What support will I get?"
12. **Final CTA block.** Restate the promise and repeat the button with the same microcopy.
13. **Footer.** Contact, refund policy, terms.

**Rules for the page:** one primary CTA repeated 3–4 times (hero, after proof, after testimonials, final) with identical wording. Put the form on the first screen on desktop, or behind a one-tap CTA on mobile.

## 3. Signup form (minimize friction)

- **Fields:** email only on step 1. Step 2, after signup, asks for name, current experience level and goal. This progressive profiling cuts form abandonment without losing segmentation data.
- Offer Google/GitHub SSO, since your audience is developers.
- **Button:** `Start my free week` (not "Submit").
- **Consent line:** "By continuing you agree to the Terms and Privacy Policy." Add a marketing opt-in checkbox only if your jurisdiction requires it.
- **After submit:** go straight into the Week 1 dashboard, not a "check your email" dead end. Send a confirmation email with the first task.

## 4. Tracking and testing plan

Events: `hero_cta_click`, `signup_start`, `signup_complete`, `week1_first_task_started`, `syllabus_expand`, `scroll_75`, `faq_open`, `trial_to_paid`.

Primary metric: visitor → trial signup. Guardrail metric: trial → week-1 activation, because signup count alone can be gamed by a looser offer.

Run the H1 test only once you have enough traffic for a valid sample size. Calculate it before launch, and don't stop the test early. If traffic is low, run sequential before/after comparisons and treat them as directional only.

---

## 5. Schema.org Course JSON-LD

Replace the `[ ]` values and only mark up what is visible on the page. Remove `offers` or `hasCourseInstance` fields you can't fill truthfully. I left out `aggregateRating`/`review` on purpose; add them only with real, visible, verifiable reviews.

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Course",
  "@id": "https://www.example.com/backend-bootcamp#course",
  "name": "Backend Engineering Bootcamp",
  "description": "A 12-week online bootcamp where developers build and deploy a production-style backend service covering REST APIs, PostgreSQL, authentication, caching, background jobs and cloud deployment, with code review from working engineers.",
  "url": "https://www.example.com/backend-bootcamp",
  "image": "https://www.example.com/images/backend-bootcamp-og.jpg",
  "inLanguage": "en",
  "courseCode": "BE-101",
  "educationalLevel": "Intermediate",
  "teaches": [
    "Designing and building REST APIs",
    "Relational database design with PostgreSQL",
    "Authentication and authorization",
    "Caching and background job processing",
    "Containerized deployment to the cloud"
  ],
  "coursePrerequisites": "Basic programming experience in any language.",
  "timeRequired": "P12W",
  "provider": {
    "@type": "Organization",
    "name": "Example Academy",
    "sameAs": "https://www.example.com",
    "url": "https://www.example.com"
  },
  "offers": [
    {
      "@type": "Offer",
      "name": "Free first week trial",
      "category": "Free",
      "price": "0",
      "priceCurrency": "USD",
      "url": "https://www.example.com/backend-bootcamp#start",
      "availability": "https://schema.org/InStock"
    },
    {
      "@type": "Offer",
      "name": "Full 12-week bootcamp",
      "category": "Paid",
      "price": "1499.00",
      "priceCurrency": "USD",
      "url": "https://www.example.com/backend-bootcamp#pricing",
      "availability": "https://schema.org/InStock"
    }
  ],
  "hasCourseInstance": {
    "@type": "CourseInstance",
    "courseMode": "Online",
    "courseWorkload": "PT10H per week",
    "startDate": "2026-12-07",
    "endDate": "2027-03-01",
    "instructor": {
      "@type": "Person",
      "name": "Instructor Name",
      "url": "https://www.example.com/instructors/instructor-name"
    }
  }
}
</script>
```

**Validation notes**

- Google's Course rich result requires `name`, `description` and `provider`. The rest is recommended.
- `timeRequired` uses an ISO 8601 duration (`P12W` is 12 weeks). `courseWorkload` is also ISO 8601 (`PT10H` is 10 hours).
- The `provider` is an `Organization`, and the `instructor` sits inside `CourseInstance`, which is where Schema.org defines it.
- The dates, price and instructor are placeholders. Keep them consistent with the visible page and update them for each cohort.
- Check the result in Google's Rich Results Test and validator.schema.org before deploying. I wrote this by hand and haven't run it through either tool.
- Keep the JSON-LD static in the HTML, not injected late by JavaScript, so crawlers read it reliably.
- Don't promise rich-result eligibility or ranking gains. Course markup makes eligibility possible, nothing more.

---

**Before you ship, get these approved and filled in:** the real trial terms, price, cohort dates, instructor names, and any proof elements (logos, ratings, outcomes). Hero claims like "code review from working engineers" must match what you actually deliver. If you send me the product details and any current conversion data, I can tighten the copy and set a sample-size target for the first test.

</details>
