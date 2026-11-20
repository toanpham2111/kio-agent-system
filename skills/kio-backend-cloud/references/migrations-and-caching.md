# Zero-Downtime Migrations & Redis Patterns

## 1. Safe Schema Migration Playbook
When renaming or dropping columns in high-traffic applications:
1. **Phase 1 (Add)**: Add the new column as nullable.
2. **Phase 2 (Dual Write)**: Update app code to write to both old and new columns, reading from old.
3. **Phase 3 (Backfill)**: Run asynchronous background script in small batches (e.g. 1,000 rows/batch) to copy old data to new.
4. **Phase 4 (Read New)**: Switch app reads to the new column.
5. **Phase 5 (Deprecate Old)**: Stop writing to old column, then safely DROP COLUMN.

## 2. Redis Distributed Locking (Redlock)
```typescript
import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

async function acquireLock(lockKey: string, ttlMs: number): Promise<string | null> {
  const token = Math.random().toString(36).substring(2);
  const result = await redis.set(lockKey, token, 'PX', ttlMs, 'NX');
  return result === 'OK' ? token : null;
}

async function releaseLock(lockKey: string, token: string): Promise<boolean> {
  const luaScript = `
    if redis.call("get", KEYS[1]) == ARGV[1] then
      return redis.call("del", KEYS[1])
    else
      return 0
    end
  `;
  const result = await redis.eval(luaScript, 1, lockKey, token);
  return result === 1;
}
```
