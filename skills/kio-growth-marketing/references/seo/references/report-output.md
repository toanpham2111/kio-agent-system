# Mandatory report export / rendering
Run from the active project root. The skill's `scripts/render-report.mjs` accepts an audit JSON document and writes Markdown, Markdown, HTML and PDF to an explicit project folder. Use `references/report-data-example.json` as a schema example, replacing all sample data with real findings.

```bash
mkdir -p seo-reports/$(date +%F)
# Agent produces seo-reports/YYYY-MM-DD/audit-data.json from the actual audit.
node /path/to/wpa-seo/scripts/render-report.mjs \
  --input "$PWD/seo-reports/$(date +%F)/audit-data.json" \
  --out "$PWD/seo-reports/$(date +%F)"
```

Requires Node.js 18+ and Chrome/Chromium or WeasyPrint (`chromium`, `google-chrome`, `chromium-browser`, or `CHROME_BIN`). PDF is printed from HTML by the browser. The script fails loudly if the browser is unavailable; do not pretend a PDF was produced. It does not modify site source files or push/commit results. Choose a noncolliding dated directory for repeat runs. Verify PDF readable and inspect representative pages before delivery. Never claim GSC, GA4, GBP, SERP or PageSpeed measurements without access. If the project is under version control, decide with the user whether audit outputs should be committed.

## Mandatory v3.1 output
The audit run is complete only when `seo-audit-report.md`, `seo-audit-report.html`, and `seo-audit-report.pdf` exist in the same dated `seo-reports/` directory. All three derive from `audit-data.json`. The Markdown is readable/editable in Git, HTML is browser-viewable, and PDF is client-shareable. Verify all 3 paths.
