# COG-01 — A/B re-run for v1.2.0

- **Skill:** `kio-cognitive` (as shipped in v1.2.0)
- **Generation model:** `claude-sonnet-5-5` (both runs) · **Judge model:** `claude-opus-5-5`
- **Harness:** Claude Code CLI, [`../harness/run_bench.py`](../harness/run_bench.py); baseline = empty project, with skill = project containing only `kio-cognitive`, invoked as `/kio-cognitive`
- **Judge:** blind (answers labelled X/Y in a seeded random order: baseline = Y, with skill = X), rubric from the v1.0.2 scenario file
- **Skill files read during the with-skill run:** none beyond the injected `SKILL.md`
- **Score:** baseline **7.3 / 10** · with skill **6.8 / 10** · Δ **-0.5**

## Prompt
```text
Evaluate the trade-offs between storing user file uploads directly as PostgreSQL BYTEA/BLOBs versus Object Storage (S3/R2) with Presigned URLs from first principles.
```

## Rubric scores

| Criterion | Max | Baseline | With skill |
| :--- | :---: | :---: | :---: |
| First-Principles Mechanical Depth | 3.0 | 2.7 | 2.2 |
| Balanced Trade-Off Rigor | 3.0 | 2.4 | 2.4 |
| Quantitative Decision Thresholds | 2.0 | 1.0 | 1.1 |
| Conciseness & Actionability | 2.0 | 1.2 | 1.1 |
| **Total** | **10** | **7.3** | **6.8** |

## Judge notes

- **Baseline:** Y names ~2 KB TOAST chunking, buffer eviction, WAL amplification, PITR/RTO and backup coherence, and solves orphans with a pending state, reaper and reconciliation. Its thresholds stop at 1 MB and 10–50 GB with no throughput figure, and it has no dedicated cost calculation table.
- **With skill:** X covers shared_buffers cache pollution, WAL/replication amplification and restore RTO well, and its pending state machine has a reaper and working code. It never mentions the ~2 KB TOAST chunk size, gives no throughput threshold, and has no $/GB/month cost table.

## Baseline output (no skill)

<details><summary>Show full answer (8853 characters)</summary>

# Postgres BYTEA vs Object Storage + Presigned URLs

## Bottom line
**Default to object storage (S3/R2) with presigned URLs, and keep only metadata in Postgres.** Use BYTEA only when files are tiny (under ~1 MB), the system is low-volume, and transactional atomicity with the row is worth more than scale. A common hybrid is BYTEA or `text` for small things like avatars under 100 KB or signatures, and object storage for everything else.

## First principles: what each system is built for

| | PostgreSQL | Object storage |
|---|---|---|
| Optimized for | Small structured rows, transactions, indexes, joins | Large immutable blobs, huge parallel throughput |
| Scaling unit | Vertical (one primary), read replicas | Effectively unbounded, horizontal |
| Cost/GB | High (SSD, IOPS, replicated, backed up) | ~10–50x lower; R2 has zero egress fees |
| Consistency | ACID across rows and files | Strong per-object, but no cross-system transaction with your DB |

A database's scarce resources are **memory (shared_buffers/page cache), connections, WAL bandwidth and I/O**. Files are large and usually read once, so they consume those resources without benefiting from what the DB is good at (indexing, joins, querying). A file's bytes are opaque to SQL.

## Where BYTEA hurts (mechanics)

1. **Cache pollution.** Large values are TOASTed (chunked into ~2 KB pieces in a side table). Reading a 5 MB file pulls thousands of pages through the buffer cache and evicts hot index and row pages, which slows unrelated queries.
2. **Memory and protocol overhead.** BYTEA is returned in whole. Drivers typically buffer the entire value in app memory (hex encoding in text protocol doubles the size). There is no native range or streaming read. `substring()` on BYTEA helps somewhat, and Large Objects (`lo_*`) can stream, but they come with their own problems (OID management, no cascade delete, permission quirks). The hard limit is 1 GB per value, and practically you hit trouble far earlier.
3. **Connection occupancy.** The upload or download holds a DB connection (a scarce, expensive process-per-connection resource) for the whole transfer to a slow client. 50 slow mobile uploads can exhaust a pool of 50.
4. **WAL amplification.** Every byte is written to the TOAST table, the WAL, and then replicas' WALs. Replication lag grows, and bulk uploads can stall other writes.
5. **Backup, restore and maintenance.** `pg_dump`, base backups, `VACUUM`, and `pg_upgrade` all scale with total size. A 2 TB database takes hours to restore, which hurts your RTO. Updating or deleting blobs creates bloat, and TOAST bloat needs vacuuming or `pg_repack`.
6. **No CDN, no edge.** Every download goes through your app and DB. You pay app-server bandwidth and CPU, and you can't cache at the edge without building it yourself.
7. **Cost.** Managed Postgres storage runs about $0.10–0.25/GB-month, versus about $0.015–0.023 for S3 and about $0.015 for R2, before replicas and backups multiply the DB figure.

## Where BYTEA genuinely wins

1. **Atomicity.** The row and the file commit or roll back together. There are no orphans and no dangling references.
2. **Simplicity.** One system, one backup, one access-control model, and point-in-time recovery covers files too. There is no IAM, CORS, or bucket lifecycle to configure.
3. **Consistency of deletes (GDPR).** `DELETE` plus vacuum is one operation. With object storage you must delete the object separately, and versioned buckets need extra handling.
4. **Authorization in SQL.** Row-level security applies directly, with no URL-signing layer.
5. **Local dev and tests.** Nothing extra to run.

This suits roughly under 1 MB per file, under ~10–50 GB total, and low concurrency.

## What object storage + presigned URLs gives you

**Flow**
```
1. Client -> API: POST /uploads {filename, size, content_type}
2. API: validate (auth, quota, type, size), INSERT files row status='pending',
        generate key = "u/{user}/{uuid}" (never use the user-supplied name as the key),
        return presigned PUT (or POST policy) with short expiry (5-15 min)
3. Client -> S3/R2: PUT bytes directly (bytes never touch your servers)
4. Completion: S3 event notification (or client calls POST /uploads/{id}/complete,
        and the server HEADs the object to verify size/etag) -> status='ready'
5. Download: API checks authz -> returns presigned GET (short TTL) or CDN signed URL
```

Metadata table:
```sql
CREATE TABLE files (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id    bigint NOT NULL REFERENCES users(id),
  object_key  text NOT NULL UNIQUE,
  size_bytes  bigint,
  content_type text,
  sha256      bytea,
  status      text NOT NULL CHECK (status IN ('pending','ready','deleted')),
  created_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON files (status, created_at) WHERE status = 'pending';
```

**Benefits**
- Bytes bypass your servers, so API capacity depends on request count and not on bandwidth or file size.
- Multipart uploads give resumability, parallelism, and files up to 5 TB.
- Range requests, CDN integration, and lifecycle tiering (IA, Glacier) come built in.
- Durability is 11 nines with cross-region replication options.
- The DB stays small, fast, and cheap to back up.

## Costs of the object-storage approach (be honest)

1. **Dual-write consistency.** There is no distributed transaction. Failure modes include an upload that never completes (orphan object, `pending` row) and a row deleted while the object remains. The fix is the pending-state pattern above plus a reaper job that deletes stale pending rows and their objects, plus S3 lifecycle rules to abort incomplete multipart uploads. Also reconcile periodically (list the bucket against the table).
2. **Backup coherence.** A DB restore to time T no longer matches the bucket. Mitigate with bucket versioning, soft-delete (`status='deleted'` with delayed hard-delete), and never overwriting keys (immutable, UUID keys).
3. **Security surface.** Presigned URLs are bearer tokens, so anyone with the URL has access until it expires. Keep TTLs short, scope them to a single key, and don't log them. For uploads, enforce limits that a plain presigned PUT can't: use **presigned POST policies** (`content-length-range`, content-type conditions) or verify post-upload via HEAD. Set CORS narrowly, block public access, and scan for malware (queue a job on upload complete) because content is untrusted. Serve user content from a separate domain, with `Content-Disposition: attachment` where appropriate, to avoid XSS.
4. **Extra moving parts.** Includes IAM, CORS, lifecycle, an event pipeline, and a local emulator (MinIO or LocalStack) for dev.
5. **Authorization is per-URL, not per-request.** Revocation isn't instant (the URL lives until expiry), so keep TTLs to minutes.

## Decision framework

| Factor | Pick BYTEA | Pick Object storage |
|---|---|---|
| File size | < ~1 MB, bounded | Anything larger or unbounded |
| Total volume | < tens of GB | Hundreds of GB or more |
| Traffic | Low concurrency | Many concurrent or slow-client transfers |
| Need atomic file + row | Strict | Can tolerate eventual cleanup |
| Downloads served widely | No | Yes (CDN) |
| Team ops capacity | Minimal | Comfortable with cloud primitives |
| Compliance / PITR for files | Needs single-snapshot restore | Handled via versioning |

## Practical recommendations

- **Default:** S3/R2 + presigned URLs + metadata table with a `pending -> ready` state machine.
- **Choose R2** when egress dominates cost (media-heavy downloads). **Choose S3** for the deepest ecosystem (events, Object Lock, Glacier tiers).
- **If you do use BYTEA**, put it in a **separate table** (`file_blobs(file_id, data)`), never as a column in a hot table. Select it only by primary key and never in `SELECT *`. Set a hard size limit (for example, 1 MB) at the API and with a `CHECK (octet_length(data) <= 1048576)`. Move to object storage before the database reaches ~10s of GB. Design the API around a `file_id` abstraction now so the storage backend can be swapped later without changing clients.
- **Migration path** from BYTEA to object storage is straightforward if you abstract it: add `object_key`, backfill in batches, dual-read, then drop the BYTEA column and let `VACUUM FULL` or `pg_repack` reclaim space.

## Summary
BYTEA trades **scalability and cost** for **atomicity and simplicity**. Object storage trades **simplicity and transactional guarantees** for **scalability, cost, and a path to CDN delivery**. Because files are large, opaque, and read-mostly, they match object storage's strengths and conflict with the database's. The consistency problems of the split design are well understood and solvable with an explicit state machine and a reaper job. The scalability problems of BYTEA are structural and can't be tuned away.

</details>

## Output with skill

<details><summary>Show full answer (12316 characters)</summary>

# User file uploads: PostgreSQL BYTEA vs. object storage with presigned URLs

**Recommendation:** Use object storage (S3/R2) with presigned URLs as the default. Keep only metadata in Postgres. BYTEA is defensible only when files are small (under ~1 MB), the total volume is bounded (a few GB), and you value atomic transactions over everything else, for example avatars, signatures, or small PDFs in an internal tool.

## 1. First principles: what each system is built for

| Property | A file | Postgres | Object store |
|---|---|---|---|
| Size | KB to GB | Optimized for rows of ~bytes to KB | Optimized for KB to TB |
| Mutability | Write once, read many | Frequent updates, MVCC | Immutable objects |
| Access pattern | Streamed, byte ranges, cacheable | Random access, indexes, joins | HTTP GET, ranges, CDN |
| Query value | Opaque, never filtered by content | Predicates, joins | None (and none needed) |
| Cost driver | Bytes stored plus bytes served | IOPS, RAM, replicas | Bytes stored plus requests |
| Scarce resource | Bandwidth | **Connections, `shared_buffers`, WAL, I/O** | Effectively none |

Files are big, opaque, and write-once. Postgres's strengths (transactions, indexes, joins) buy you nothing on the bytes themselves. The remaining question is what putting bytes in Postgres costs your *other* workloads.

## 2. What BYTEA actually costs

1. **The DB sits on the data path.** Every upload and download streams through app server, then DB connection, then disk. A slow 50 MB mobile upload holds a pooled connection (or a buffered request) for its whole duration. A few dozen concurrent downloads can exhaust a pool of 20–100 connections and take down your *transactional* traffic.
2. **Memory buffering.** Most drivers (`pg`, `psycopg`, JDBC) materialize a whole `bytea` value in memory. Text-mode transfer hex-encodes it, so the wire size is ~2×. The hard limit is 1 GB per value, but you hit trouble far earlier.
3. **WAL and replication amplification.** Every byte is written to the heap/TOAST and again to WAL. Replicas replay it too. Upload bursts cause replication lag, and lag hurts your read replicas and failover RPO.
4. **Cache pollution.** TOAST pages compete for `shared_buffers` and the OS page cache with your hot relational data. One user downloading a 200 MB file evicts the pages your queries need.
5. **Backup and restore.** `pg_dump`, base backups, PITR, and `VACUUM FULL`/major upgrades all scale with total size. A 2 TB DB where 1.9 TB is files means hours-long restores. That directly hurts your recovery time objective (RTO).
6. **Cost per GB.** Managed Postgres storage runs roughly 5–10× the price of S3, and about 8× R2 (order of magnitude: ~$0.10–0.12/GB-month vs. ~$0.023 S3 vs. ~$0.015 R2). Replicas multiply it.
7. **Serving features are missing.** There is no CDN, no native HTTP range/resume, no edge caching, and no direct browser-to-store upload. You must build all of that in the app tier.
8. **Bloat and vacuum.** Replacing or deleting a file creates dead TOAST tuples. Autovacuum has to chew through them.

**Where BYTEA genuinely wins:**
- **Atomicity.** One transaction commits the row and the file, or neither. There are no orphans and no two-phase problem.
- **A single backup** is internally consistent, and a restore brings the file and metadata back together at the same point in time.
- **One system to run.** There is no extra IAM, bucket policy, CORS, or SDK, and local dev needs nothing extra.
- **Row-level security and permissions** apply to the bytes for free.
- **Small and bounded:** thumbnails, signatures, icons.

(Postgres Large Objects, `lo_*`, raise the limit to 4 TB and allow streaming. They share the WAL, backup, and cost problems, and add awkward lifecycle management.)

## 3. What object storage + presigned URLs costs

1. **Lost atomicity.** The DB row and the object can drift apart. You get orphan objects (uploaded, but the row was never confirmed) and dangling rows (row exists, object deleted). You must design for this explicitly (see the state machine below).
2. **Two systems.** You take on IAM, CORS, lifecycle rules, bucket versioning, and separate backups or versioning for object durability.
3. **Authorization is no longer free.** A presigned URL is a bearer token until it expires. Keep TTLs short (60–300 s for upload, 5–15 min for download) and never log the URLs.
4. **Validation moves.** The server no longer sees the bytes, so size and MIME type can't be checked inline. You need signed constraints plus post-upload verification, and async scanning for malware.
5. **Vendor and API quirks.** For example, S3 supports presigned POST with a `content-length-range` policy. R2 supports presigned PUT but not POST policies, so enforce size by signing `Content-Length` and re-checking with `HEAD`.
6. **Egress costs.** S3 charges for egress (put CloudFront in front). R2 charges none.

**What you gain:**
- The DB never touches the bytes, so the connection pool, WAL, and cache stay clean.
- Browser-to-store transfer runs at full bandwidth, with multipart/resumable uploads and range requests.
- CDN-cacheable downloads.
- Independent scaling (storage grows without the DB growing).
- 11 nines of durability, versioning, and lifecycle tiering.

## 4. Decision rule

```
size per file  < ~256 KB   AND  total < ~5 GB   AND  need atomicity   → BYTEA is fine
size per file  < ~1 MB     AND  total < ~50 GB  AND  low concurrency   → BYTEA tolerable, in a separate table
anything else (user-generated, video, PDFs, growth expected)           → Object storage + presigned URLs
```

If you choose BYTEA, still isolate it. Use a separate table, or a separate database with its own pool, so it can be moved later.

## 5. Implementation: object storage design

### Schema (metadata only, with a state machine to handle the consistency gap)

```sql
CREATE TYPE upload_status AS ENUM ('pending', 'uploaded', 'rejected', 'deleted');

CREATE TABLE files (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id      uuid        NOT NULL REFERENCES users(id),
  object_key    text        NOT NULL UNIQUE,          -- e.g. u/<owner>/<uuid>
  filename      text        NOT NULL,                 -- display only; never used in the key
  content_type  text        NOT NULL,
  size_bytes    bigint      NOT NULL CHECK (size_bytes > 0 AND size_bytes <= 104857600),
  sha256        bytea,                                -- filled after verification
  status        upload_status NOT NULL DEFAULT 'pending',
  created_at    timestamptz NOT NULL DEFAULT now(),
  uploaded_at   timestamptz
);

CREATE INDEX files_owner_idx ON files (owner_id, created_at DESC) WHERE status = 'uploaded';
-- Reaper uses this to find abandoned uploads:
CREATE INDEX files_pending_idx ON files (created_at) WHERE status = 'pending';
```

### Upload flow (3 steps)

```
1. Client → API: POST /files {filename, contentType, size}
   API: validate, INSERT row (pending), return presigned PUT URL
2. Client → Object store: PUT bytes directly (DB/API not involved)
3. Client → API: POST /files/:id/complete
   API: HEAD object, verify size/type, UPDATE status='uploaded'
```

### Code (TypeScript, AWS SDK v3; works with R2 via `endpoint`)

```ts
import { S3Client, PutObjectCommand, GetObjectCommand, HeadObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { randomUUID } from "node:crypto";

const s3 = new S3Client({
  region: "auto",                                   // R2; use real region for S3
  endpoint: process.env.S3_ENDPOINT,                // https://<acct>.r2.cloudflarestorage.com
  credentials: { accessKeyId: process.env.S3_KEY!, secretAccessKey: process.env.S3_SECRET! },
});
const BUCKET = process.env.S3_BUCKET!;
const MAX = 100 * 1024 * 1024;
const ALLOWED = new Set(["image/png", "image/jpeg", "application/pdf"]);

// Step 1
export async function initUpload(db, userId: string, b: { filename: string; contentType: string; size: number }) {
  if (!ALLOWED.has(b.contentType)) throw new Error("type not allowed");
  if (b.size <= 0 || b.size > MAX) throw new Error("bad size");

  const id = randomUUID();
  const key = `u/${userId}/${id}`;                  // never trust user filename in the key

  await db.query(
    `INSERT INTO files (id, owner_id, object_key, filename, content_type, size_bytes)
     VALUES ($1,$2,$3,$4,$5,$6)`,
    [id, userId, key, b.filename, b.contentType, b.size],
  );

  const url = await getSignedUrl(
    s3,
    new PutObjectCommand({
      Bucket: BUCKET, Key: key,
      ContentType: b.contentType,                   // signed: client must send exactly this
      ContentLength: b.size,                        // signed: size is pinned
    }),
    { expiresIn: 300 },
  );
  return { id, url, headers: { "Content-Type": b.contentType } };
}

// Step 3
export async function completeUpload(db, userId: string, id: string) {
  const { rows } = await db.query(
    `SELECT object_key, size_bytes, content_type FROM files
     WHERE id=$1 AND owner_id=$2 AND status='pending'`, [id, userId]);
  if (!rows[0]) throw new Error("not found");

  const head = await s3.send(new HeadObjectCommand({ Bucket: BUCKET, Key: rows[0].object_key }))
    .catch(() => null);
  const ok = head && head.ContentLength === Number(rows[0].size_bytes)
                  && head.ContentType === rows[0].content_type;

  await db.query(
    `UPDATE files SET status=$2, uploaded_at=CASE WHEN $2='uploaded' THEN now() END WHERE id=$1`,
    [id, ok ? "uploaded" : "rejected"]);
  if (!ok) throw new Error("upload missing or mismatched");
  // Optionally enqueue async: malware scan, magic-byte sniffing, sha256, thumbnailing.
}

// Download: authorize in the app, then hand out a short-lived URL
export async function downloadUrl(db, userId: string, id: string) {
  const { rows } = await db.query(
    `SELECT object_key, filename FROM files
     WHERE id=$1 AND owner_id=$2 AND status='uploaded'`, [id, userId]);
  if (!rows[0]) throw new Error("not found");
  return getSignedUrl(
    s3,
    new GetObjectCommand({
      Bucket: BUCKET, Key: rows[0].object_key,
      ResponseContentDisposition: `attachment; filename="${encodeURIComponent(rows[0].filename)}"`,
    }),
    { expiresIn: 600 },
  );
}
```

### Reaper (closes the consistency gap)

```sql
-- Run every ~10 min. Abandoned uploads: delete objects (by key) then rows.
UPDATE files SET status = 'deleted'
WHERE status = 'pending' AND created_at < now() - interval '1 hour'
RETURNING object_key;   -- app deletes these keys from the bucket, best-effort, idempotent
```

Back this up with a bucket lifecycle rule (abort incomplete multipart uploads after 1 day) and a periodic reconciliation job that lists the bucket and flags keys with no row.

### Bucket config essentials

```json
// CORS (browser direct upload)
[{ "AllowedOrigins": ["https://app.example.com"],
   "AllowedMethods": ["PUT", "GET"],
   "AllowedHeaders": ["Content-Type"],
   "ExposeHeaders": ["ETag"],
   "MaxAgeSeconds": 3000 }]
```

- Block all public access, and serve only through presigned URLs.
- Enable server-side encryption.
- Enable versioning if accidental delete matters.
- For files over ~100 MB, use multipart upload with presigned part URLs.

## 6. Summary

| Dimension | BYTEA | Object storage + presigned |
|---|---|---|
| Atomicity / consistency | **Strong** | Eventual; needs the state machine and reaper |
| Operational simplicity | **One system** | Two systems |
| DB load (connections, WAL, cache) | Heavy | **None** |
| Scales to large files and volume | Poor (1 GB cap, backups, lag) | **Excellent** |
| Cost per GB | High | **Low** (R2 is lowest, with free egress) |
| CDN / range / resumable | No | **Yes** |
| Backup and restore time | Grows with files | **Independent of files** |
| Security model | Simple, DB-enforced | Bearer URLs, so keep TTLs short |
| Server-side validation | Inline | Post-upload verify and async scan |

The core trade is atomicity and simplicity against keeping the database off the data path. Data volume grows without bound, and the database is your most expensive and least horizontally scalable component. So you should usually pay the extra complexity of two systems, and that complexity is bounded and well understood: a state column, a reaper, and a HEAD check.

</details>
