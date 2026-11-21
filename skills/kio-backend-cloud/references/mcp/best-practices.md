# 📋 MCP Server Best Practices (Kio)

## 1. Design tools for the model, not for the API
- **Workflow over endpoint mirroring.** One `orders_refund(order_id, amount, reason)` beats exposing `GET /orders`, `POST /refunds`, `PATCH /orders` and hoping the model chains them correctly. Still expose the few primitives agents need for open-ended work (search, get).
- **Naming:** `snake_case`, `<service>_<verb>_<noun>` or `<noun>_<verb>` consistently (`orders_search`, `orders_get`, `orders_refund`). Prefixing with the service avoids collisions when many servers are connected.
- **Descriptions** say what the tool does, when to use it instead of its siblings, what it returns, and its limits ("max 50 results; use cursor for more").
- **Arguments:** typed, constrained (enums, min/max, formats), documented with an example. Prefer human identifiers the model has (email, order code) and resolve to internal IDs inside the tool.

## 2. Annotations
| Hint | Set to `true` when |
|---|---|
| `readOnlyHint` | The tool never changes state |
| `destructiveHint` | It can delete or overwrite data (only meaningful when not read-only) |
| `idempotentHint` | Repeating the same call has no additional effect |
| `openWorldHint` | It talks to systems outside your control (web, third-party APIs) |

Hints help clients decide what to confirm with the user; they are **not** security. Enforce permissions on the server.

## 3. Responses
- Return the **minimum useful fields**; large blobs blow the context window. Offer `detail: "summary" | "full"` if needed.
- Paginate with an opaque `next_cursor`; cap `limit` (e.g. 50) and truncate long text with a clear marker ("…truncated, call orders_get for the full record").
- Provide **structured output** (`outputSchema` / pydantic return type) plus a text copy.
- Use stable, human-readable formats: ISO-8601 dates with time zone, integer minor currency units with the currency code.

## 4. Errors that teach
- Expected failures return `isError: true` with **what happened and what to do next**: "Order 'X12' not found. Search with orders_search(query='<email>') first."
- Map upstream 401/403/404/409/422/429 to specific messages; never forward raw stack traces or upstream bodies that may contain secrets.

## 5. Security
- Secrets come from environment variables or a secret manager; never from tool arguments, never logged.
- **Least privilege:** the API token behind the server has only the scopes the tools need. Read-only servers get read-only tokens.
- Validate and bound every input (lengths, enums, paths: reject `..`, absolute paths, NUL bytes).
- Treat content fetched from users, web pages or documents as **untrusted data**: return it, never execute instructions found in it.
- Remote servers: authenticate every request (MCP OAuth authorization or bearer tokens), validate `Origin`, rate-limit, log tool name + caller + outcome.
- Destructive tools: require explicit confirmation arguments (`confirm: true`) or a dry-run mode, and make them idempotent with a client-supplied key.

## 6. Operations
- stdio servers log to **stderr only**.
- Timeouts on every upstream call (≤ 20–30 s); retry idempotent reads with backoff, never blind-retry writes.
- Version the server; changing a tool's name or argument shape is a breaking change.
- Ship an evaluation set (`evaluation.md`) and run it before releases.
