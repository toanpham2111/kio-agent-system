#!/usr/bin/env node
// Kio SEO: generate matching Markdown, HTML and PDF reports from a single evidence-based audit JSON.
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { spawnSync } from 'node:child_process';

function fail(message) { console.error(`KIO SEO ERROR: ${message}`); process.exit(1); }
const args = process.argv.slice(2);
function opt(key) { const n=args.indexOf(key); return n<0 ? null : args[n+1]; }
const input=opt('--input'), out=opt('--out');
if (!input || !out) fail('Usage: node render-report.mjs --input /project/seo-reports/date/audit-data.json --out /project/seo-reports/date');
if (!fs.existsSync(input)) fail(`Missing input: ${input}`);
let data;
try { data=JSON.parse(fs.readFileSync(input,'utf8')); } catch(e) { fail(`Invalid JSON: ${e.message}`); }
if (!data.project || !data.auditDate || !Array.isArray(data.findings) || !Array.isArray(data.sources)) fail('Require project, auditDate, findings[] and sources[]');
const esc=x=>String(x??'Not provided').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
const list=x=>Array.isArray(x)&&x.length?`<ul>${x.map(v=>`<li>${esc(v)}</li>`).join('')}</ul>`:'<p class="muted">Not available / Chưa có dữ liệu</p>';
const sev=x=>['critical','high','medium','low'].includes(String(x).toLowerCase()) ? String(x).toLowerCase() : 'unknown';
const findings=data.findings.map((f,i)=>`<tr><td>${i+1}</td><td><span class="tag ${sev(f.severity)}">${esc(f.severity)}</span></td><td>${esc(f.category)}</td><td>${esc(f.location)}</td><td><strong>${esc(f.issue)}</strong></td><td>${esc(f.evidence)}</td><td>${esc(f.recommendation)}</td><td>${esc(f.status || 'Unverified')}</td></tr>`).join('');
const sections=(data.sections||[]).map(s=>`<section><h2>${esc(s.title)}</h2><p>${esc(s.details)}</p></section>`).join('');
const roadmap=(data.roadmap||[]).map(r=>`<section><h3>${esc(r.phase)}</h3>${list(r.actions)}</section>`).join('');
const val=data.validation||{};
const html=`<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Kio SEO Audit — ${esc(data.project)}</title><style>
@page{size:A4;margin:17mm 13mm}*{box-sizing:border-box}body{margin:0;font-family:Arial,"DejaVu Sans",sans-serif;color:#24262b;background:#f6f5f2;line-height:1.55}main{max-width:1160px;margin:24px auto;background:white;padding:40px 42px;box-shadow:0 3px 28px #0001}.eyebrow{font-size:11px;letter-spacing:3px;color:#9b7c42;font-weight:bold}.hero{border-bottom:3px solid #b49a65;padding-bottom:25px;margin-bottom:28px}h1{font-size:34px;line-height:1.2;margin:10px 0}h2{font-size:21px;border-bottom:1px solid #ddd4c4;padding-bottom:9px;margin-top:32px}h3{font-size:16px}.meta{color:#6f716f;font-size:13px}.summary{border-left:4px solid #b49a65;padding:16px 22px;background:#f6f3ec}.muted{color:#787878}.table-wrap{overflow-x:auto}table{width:100%;border-collapse:collapse;font-size:11px;table-layout:fixed}th{background:#272523;color:white;text-align:left}td,th{border-bottom:1px solid #e3dfd7;padding:8px;vertical-align:top;overflow-wrap:anywhere}tr:nth-child(even){background:#f7f5f1}.tag{font-weight:700;text-transform:uppercase;font-size:10px}.critical{color:#af2c24}.high{color:#ad5b00}.medium{color:#836f30}.low{color:#276846}ul{padding-left:22px}li{margin-bottom:5px}.footer{font-size:11px;color:#777;margin-top:40px;border-top:1px solid #ddd;padding-top:12px}section{break-inside:avoid}tr{break-inside:avoid} @media print{body{background:white}main{box-shadow:none;margin:0;padding:0;max-width:none}h2{break-after:avoid}table{font-size:9px}thead{display:table-header-group}}
</style></head><body><main><header class="hero"><div class="eyebrow">KIO SEO • PROFESSIONAL TECHNICAL SEO & AEO AUDIT</div><h1>${esc(data.project)}</h1><div class="meta">Domain: ${esc(data.domain)} · Audit date: ${esc(data.auditDate)}<br>Scope: ${esc(data.scope)}</div></header><section><h2>Executive summary / Tổng quan</h2><div class="summary">${esc(data.summary||'Not available')}</div></section><section><h2>Evidence and limitations / Nguồn & giới hạn</h2><h3>Sources inspected</h3>${list(data.sources)}<h3>Unavailable / limitations</h3>${list(data.limitations)}</section><section><h2>Audit findings / Các vấn đề phát hiện</h2><p>${data.findings.length} findings recorded. Findings and evidence must be verified by the auditing agent.</p><div class="table-wrap"><table><thead><tr><th>#</th><th>Priority</th><th>Category</th><th>URL / file</th><th>Finding</th><th>Evidence</th><th>Recommendation</th><th>Status</th></tr></thead><tbody>${findings||'<tr><td colspan="8">No verified findings recorded.</td></tr>'}</tbody></table></div></section>${sections}<section><h2>Prioritized roadmap / Lộ trình</h2>${roadmap||'<p>No roadmap provided.</p>'}</section><section><h2>Validation / Xác minh</h2><h3>Passed</h3>${list(val.passed)}<h3>Failed</h3>${list(val.failed)}<h3>Not tested</h3>${list(val.notTested)}</section><div class="footer">Kio SEO • Evidence-based assessment, not a guarantee of rankings or AI citations.</div></main></body></html>`;
fs.mkdirSync(out,{recursive:true});
const htmlPath=path.join(out,'seo-audit-report.html'), pdfPath=path.join(out,'seo-audit-report.pdf'), mdPath=path.join(out,'seo-audit-report.md');
// Markdown is generated from the exact same audit-data.json as the HTML and PDF.
// Escape untrusted text in Markdown tables and preserve line breaks consistently.
const mdText=x=>String(x??'Not provided').replace(/\r?\n/g,' ').replace(/\|/g,'\\|').trim();
const mdList=x=>Array.isArray(x)&&x.length?x.map(v=>`- ${String(v??'').replace(/\r?\n/g,' ')}`).join('\n'):'- Not available / Chưa có dữ liệu';
const mdRows=data.findings.map((f,i)=>`| ${i+1} | ${mdText(f.severity)} | ${mdText(f.category)} | ${mdText(f.location)} | ${mdText(f.issue)} | ${mdText(f.evidence)} | ${mdText(f.recommendation)} | ${mdText(f.status||'Unverified')} |`).join('\n');
const mdSections=(data.sections||[]).map(s=>`## ${String(s.title??'Section')}\n\n${String(s.details??'Not available')}\n`).join('\n');
const mdRoadmap=(data.roadmap||[]).map(r=>`### ${String(r.phase??'Phase')}\n\n${mdList(r.actions)}`).join('\n\n');
const md=`# Kio SEO — Professional Technical SEO & AEO Audit\n\n**Project:** ${data.project}  \n**Domain:** ${data.domain||'Not provided'}  \n**Audit date:** ${data.auditDate}  \n**Scope:** ${data.scope||'Not provided'}\n\n## Executive summary / Tổng quan\n\n${data.summary||'Not available'}\n\n## Evidence sources / Nguồn chứng cứ\n\n${mdList(data.sources)}\n\n## Limitations / Giới hạn\n\n${mdList(data.limitations)}\n\n## Audit findings / Các vấn đề phát hiện\n\n| # | Priority | Category | URL / file | Finding | Evidence | Recommendation | Status |\n|---|---|---|---|---|---|---|---|\n${mdRows||'| — | — | — | — | No verified findings | — | — | — |'}\n\n${mdSections}## Prioritized roadmap / Lộ trình\n\n${mdRoadmap||'Not provided'}\n\n## Validation / Xác minh\n\n### Passed\n${mdList(val.passed)}\n\n### Failed\n${mdList(val.failed)}\n\n### Not tested\n${mdList(val.notTested)}\n\n---\nKio SEO • Evidence-based assessment, not a guarantee of rankings or AI citations.\n`;
fs.writeFileSync(mdPath,md,'utf8');
fs.writeFileSync(htmlPath,html,'utf8');
const browsers=[process.env.CHROME_BIN,'chromium','chromium-browser','google-chrome','google-chrome-stable'].filter(Boolean);
let browser=null;
for(const candidate of browsers){const probe=spawnSync(candidate,['--version'],{encoding:'utf8'});if(!probe.error && probe.status===0){browser=candidate;break;}}
if(!browser && !process.env.WPA_PDF_RENDERER) { /* Try WeasyPrint fallback after HTML is saved. */ }
const profile=fs.mkdtempSync(path.join(os.tmpdir(),'wpa-seo-chrome-'));
const localUrl='file://'+encodeURI(path.resolve(htmlPath));
const result=browser ? spawnSync(browser,['--headless','--no-sandbox','--disable-gpu','--disable-dev-shm-usage','--disable-background-networking','--no-first-run','--disable-extensions',`--user-data-dir=${profile}`,`--print-to-pdf=${path.resolve(pdfPath)}`,'--no-pdf-header-footer',localUrl],{encoding:'utf8',timeout:20000}) : {status:1,stderr:'Chrome unavailable'};
fs.rmSync(profile,{recursive:true,force:true});
if(result.error||result.status!==0 || !fs.existsSync(pdfPath)) {
  // WeasyPrint exports the same HTML to PDF when Chrome cannot run.
  const fallback=spawnSync('weasyprint',[htmlPath,pdfPath],{encoding:'utf8',timeout:30000});
  if(fallback.error||fallback.status!==0) fail(`PDF generation failed. Chrome: ${(result.stderr||result.error?.message||'unavailable').slice(-300)}; WeasyPrint: ${(fallback.stderr||fallback.error?.message||'unavailable').slice(-300)}. Install Chrome/Chromium or WeasyPrint.`);
}
if(!fs.existsSync(mdPath)||fs.statSync(mdPath).size<250||!fs.readFileSync(mdPath,'utf8').includes('## Audit findings')) fail('Markdown verification failed');
if(!fs.existsSync(htmlPath)||fs.statSync(htmlPath).size<1000) fail('HTML verification failed');
if(!fs.existsSync(pdfPath)||fs.statSync(pdfPath).size<1000||fs.readFileSync(pdfPath).subarray(0,4).toString()!=='%PDF') fail('PDF verification failed');
console.log(JSON.stringify({success:true,markdown:mdPath,html:htmlPath,pdf:pdfPath,markdownBytes:fs.statSync(mdPath).size,htmlBytes:fs.statSync(htmlPath).size,pdfBytes:fs.statSync(pdfPath).size},null,2));
