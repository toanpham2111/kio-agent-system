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
