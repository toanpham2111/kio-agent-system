# Index Optimization & EXPLAIN Diagnostics

## 1. Multi-Column Index Column Ordering Rules
The "Equality First, Range Second" principle:
1. Put columns checked with equality (`=`) first.
2. Put columns checked with inequality/ranges (`<`, `>`, `BETWEEN`) or `ORDER BY` last.

```sql
-- Query:
SELECT * FROM audit_logs 
WHERE organization_id = 'org_123' 
  AND created_at >= NOW() - INTERVAL '7 days' 
ORDER BY created_at DESC;

-- Correct Composite Index:
CREATE INDEX idx_audit_org_created 
ON audit_logs (organization_id, created_at DESC);
```

## 2. GIN Indexing for JSONB
```sql
-- Enable GIN index on jsonb payload
CREATE INDEX idx_events_payload 
ON analytics_events USING GIN (payload jsonb_path_ops);

-- Optimal query using JSON containment operator (@>)
SELECT * FROM analytics_events 
WHERE payload @> '{"action": "checkout", "currency": "USD"}';
```

## 3. Reading `EXPLAIN (ANALYZE, BUFFERS)`
```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT id, total FROM orders
WHERE customer_id = $1 AND status = 'paid'
ORDER BY created_at DESC LIMIT 20;
```
| Signal in the plan | Meaning | Usual fix |
|---|---|---|
| `Seq Scan` on a large table with a selective filter | No usable index | Composite index matching filter + sort |
| `Rows Removed by Filter` ≫ rows returned | Index exists but is not selective enough | Put the equality columns first, or a partial index |
| Estimated rows vs actual rows off by 10×+ | Stale/insufficient statistics | `ANALYZE`, raise `default_statistics_target`, extended statistics for correlated columns |
| `Sort` + `external merge Disk` | Sort spilled to disk | Index that delivers the order, or raise `work_mem` for that query |
| `Nested Loop` with a large outer side | Bad join choice from bad estimates | Fix estimates first; index the inner join key |
| `Buffers: shared read` high | Data not in cache | Covering index (`INCLUDE`), fewer columns, partitioning |

Run it on production-like data volume — plans on a 1 000-row dev table say nothing.

## 4. Index types worth knowing
```sql
-- Covering index: answer from the index alone (Index Only Scan)
CREATE INDEX idx_orders_customer_created ON orders (customer_id, created_at DESC) INCLUDE (total, status);

-- Partial index: only the rows you actually query
CREATE INDEX idx_orders_pending ON orders (created_at) WHERE status = 'pending';

-- Expression index: must match the query expression exactly
CREATE INDEX idx_users_email_lower ON users (lower(email));
SELECT * FROM users WHERE lower(email) = lower($1);

-- Trigram for ILIKE '%term%' search
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_products_name_trgm ON products USING GIN (name gin_trgm_ops);

-- BRIN for huge append-only time series
CREATE INDEX idx_events_created_brin ON events USING BRIN (created_at);
```

## 5. Building indexes in production
- `CREATE INDEX CONCURRENTLY` (and `DROP INDEX CONCURRENTLY`) avoids blocking writes; it cannot run inside a transaction block, so mark that migration non-transactional.
- If it fails it leaves an `INVALID` index: find with `SELECT indexrelid::regclass FROM pg_index WHERE NOT indisvalid;`, drop, retry.
- Set `lock_timeout` (e.g. `'5s'`) in migrations so a blocked DDL fails fast instead of queueing every query behind it.

## 6. Query patterns
- **Keyset pagination** instead of `OFFSET` on large tables: `WHERE (created_at, id) < ($1, $2) ORDER BY created_at DESC, id DESC LIMIT 20` with index `(created_at DESC, id DESC)`.
- Kill **N+1** queries: batch with `WHERE id = ANY($1)` or ORM eager loading; log query counts per request in development.
- Select only needed columns; avoid `SELECT *` on wide tables with `jsonb`/`text` columns.
- Find what to fix with `pg_stat_statements`: sort by `total_exec_time`, not by `mean_exec_time` alone.
- Unused indexes cost writes: `SELECT relname, indexrelname, idx_scan FROM pg_stat_user_indexes WHERE idx_scan = 0;` (check on every replica before dropping).
