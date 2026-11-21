# Benchmark Evidence: COG-01 — First-Principles Architecture Trade-Off Analysis (A/B Comparison)

- **Skill Evaluated**: `kio-cognitive` (`v1.0.2`)
- **Model / Harness**: Google Antigravity IDE (Gemini 4 Argon)
- **Evaluation Date**: 2026-11-21
- **Baseline Score (No Skill)**: **6.0 / 10.0 (FAIL)**
- **With Kio Skill Score**: **9.3 / 10.0 (PASS)**
- **Quality Delta**: **+3.3 pts**

---

## 1. Input Prompt
```text
Evaluate the trade-offs between storing user file uploads directly as PostgreSQL BYTEA/BLOBs versus Object Storage (S3/R2) with Presigned URLs from first principles.
```

---

## 2. Baseline Output (Without `kio-cognitive`)

### Raw Baseline Output
```markdown
### Database BLOBs vs. S3 Object Storage

**PostgreSQL BLOBs:**
- Pros: Easy to back up in one place, transactional consistency, simple setup.
- Cons: Database gets large, slower queries, expensive storage.

**S3 Object Storage:**
- Pros: Cheap, scalable, works well with CDNs, doesn't slow down the database.
- Cons: Harder to keep in sync with the database, requires managing AWS credentials.

**Conclusion**: You should generally use S3 for large files and database BLOBs only for small files.
```

### Baseline Defects Observed
- **Surface-Level Platitudes**: States "slower queries" and "database gets large" without explaining the underlying OS/database mechanics (shared buffer pool eviction, TOAST chunking, WAL amplification, Node/API memory backpressure).
- **No Quantitative Decision Thresholds**: Leaves the engineer with vague advice ("small files vs. large files") instead of concrete byte/throughput cutoff boundaries.

---

## 3. Output With `kio-cognitive` Activated

### Raw Kio Skill Output
```markdown
### 1. First-Principles Hardware & Runtime Mechanics

| Physical Layer | PostgreSQL `BYTEA` (TOAST Storage) | S3 / R2 Object Storage + Presigned URLs |
| :--- | :--- | :--- |
| **Memory & Buffer Pool (`shared_buffers`)** | Any payload `> 2 KB` is sliced into `2 KB` chunks in an out-of-line TOAST table. Reading a `10 MB` file pulls ~5,000 TOAST pages into PostgreSQL `shared_buffers`, evicting hot B-Tree index pages and degrading unrelated OLTP queries. | Zero database memory footprint (`~120 bytes` for the object key + metadata row). |
| **Write Amplification & WAL I/O** | Every file upload writes full binary bytes to the Write-Ahead Log (WAL) AND the TOAST heap (`2x` disk I/O), plus replicates across streaming read replicas. | Database writes only a metadata row (`< 256 bytes`). Binary payload streams directly from client browser to S3 edge via HTTP `PUT`. |
| **Application Server Network & Event Loop** | Backend API must buffer or stream multi-megabyte payloads through Node.js/Go worker memory, tying up file descriptors and saturating server egress bandwidth. | API generates a cryptographic HMAC presigned URL in `< 0.2 ms` CPU time; client uploads/downloads directly against S3/CDN edge. |
| **Backup & Point-in-Time Recovery (PITR)** | `pg_dump` and base backups balloon from megabytes to terabytes, increasing MTTR (Mean Time To Restore) during an outage from minutes to hours. | Database snapshots remain lean (`< 5 GB`) with sub-5-minute restore times; object lifecycle managed independently. |

---

### 2. Concrete Architectural Decision Matrix

1. **Use PostgreSQL `BYTEA` ONLY when ALL 3 conditions hold**:
   - Payload is strictly **`< 64 KB`** (e.g., cryptographic keys, small SVG avatars, signed JSON receipts).
   - Strict **ACID transactional atomicity** is mandatory (the binary payload and relational state must commit or roll back in a single database transaction).
   - Total binary dataset size is projected to remain **`< 10 GB`** over 24 months.

2. **Use S3 / Cloudflare R2 Presigned URLs when ANY of the following hold**:
   - Payload exceeds **`64 KB`** (PDFs, user images, exports, audio/video).
   - Concurrent upload/download traffic exceeds **`50 Mbps`** (offloads bandwidth from application workers).
   - Pattern: Use a **2-phase status column** (`status: 'pending_upload' | 'ready'`) on the `files` metadata table, finalized by an S3 webhook or client confirmation check to prevent orphaned references.
```

---

## 4. Rubric Score Breakdown (Baseline vs. With Skill)

| Criterion | Max | Baseline | With Skill | Notes & Deductions |
| :--- | :---: | :---: | :---: | :--- |
| **First-Principles Mechanical Depth** | 3.0 | 1.0 | 3.0 | Explains PostgreSQL `2 KB` TOAST chunking, `shared_buffers` eviction, WAL write amplification, and PITR MTTR impact. |
| **Balanced Trade-Off Rigor** | 3.0 | 2.0 | 3.0 | Identifies the exact niche where `BYTEA` wins (ACID atomicity for `< 64 KB` records) and how to solve S3 orphan inconsistency (`pending_upload` state machine). |
| **Quantitative Decision Thresholds** | 2.0 | 1.0 | 2.0 | Provides explicit numeric boundaries (`64 KB` payload, `10 GB` dataset, `50 Mbps` throughput). |
| **Conciseness & Actionability** | 2.0 | 2.0 | 1.3 | Structured engineering table (-0.7: storage cost $/GB/month calculation table omitted). |
| **Total** | **10.0** | **6.0 (FAIL)** | **9.3 (PASS)** | **+3.3 improvement** |
