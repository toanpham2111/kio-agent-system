# ⚡ MCP Server in TypeScript / Node

Verified against `@modelcontextprotocol/sdk` **1.32.2** with `zod` (stdio, `registerTool`, structured output, tool errors).

## 1. Setup
```bash
npm init -y
npm i @modelcontextprotocol/sdk zod
npm i -D typescript @types/node tsx
```
`package.json`: `"type": "module"`, `"bin": { "kio-orders-mcp": "dist/index.js" }`, scripts `"build": "tsc"`, `"dev": "tsx src/index.ts"`.
`tsconfig.json`: `"module": "NodeNext"`, `"moduleResolution": "NodeNext"`, `"target": "ES2022"`, `"outDir": "dist"`, `"strict": true`.

## 2. Minimal server
```ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const ORDERS: Record<string, { id: string; status: string; total: number }> = {
  o1: { id: "o1", status: "paid", total: 50000 },
};
const server = new McpServer({ name: "kio-orders", version: "1.0.0" });

server.registerTool(
  "orders_get",
  {
    title: "Get order",
    description: "Fetch one order by ID. Returns id, status and total (VND, integer).",
    inputSchema: { order_id: z.string().describe("Order ID, e.g. 'o1'") },
    outputSchema: { id: z.string(), status: z.string(), total: z.number().int() },
    annotations: { readOnlyHint: true, idempotentHint: true, openWorldHint: false },
  },
  async ({ order_id }) => {
    const order = ORDERS[order_id];
    if (!order) {
      return {
        isError: true,
        content: [{ type: "text", text: `Order '${order_id}' not found. Use orders_search to list IDs.` }],
      };
    }
    return { content: [{ type: "text", text: JSON.stringify(order) }], structuredContent: order };
  },
);

await server.connect(new StdioServerTransport()); // stdout is the protocol: log with console.error only
```

- `inputSchema` / `outputSchema` take a **zod shape** (object of fields), not `z.object(...)`.
- Return `isError: true` with an actionable message for expected failures; reserve thrown errors for bugs.
- When you declare `outputSchema`, always return matching `structuredContent` and a text copy for older clients.

## 3. Upstream API helper
```ts
const API = process.env.ORDERS_API_URL!;
const TOKEN = process.env.ORDERS_API_TOKEN!;

async function apiGet<T>(path: string, params: Record<string, string | number | undefined> = {}): Promise<T> {
  const url = new URL(path, API);
  for (const [k, v] of Object.entries(params)) if (v !== undefined) url.searchParams.set(k, String(v));
  const res = await fetch(url, { headers: { Authorization: `Bearer ${TOKEN}` }, signal: AbortSignal.timeout(20_000) });
  if (res.status === 404) throw new UserError("Not found. Check the ID or search first.");
  if (res.status === 429) throw new UserError("Rate limited by the Orders API. Wait a minute and retry.");
  if (!res.ok) throw new Error(`Orders API ${res.status}`);
  return res.json() as Promise<T>;
}
class UserError extends Error {}
// In handlers: catch UserError → return { isError: true, content: [{ type: "text", text: e.message }] }
```

## 4. Remote (Streamable HTTP)
Use `StreamableHTTPServerTransport` from `@modelcontextprotocol/sdk/server/streamableHttp.js` behind your HTTP framework for hosted servers. Require auth (OAuth per the MCP authorization spec, or a bearer token for internal use), validate the `Origin` header, and bind to `127.0.0.1` for local-only servers.

## 5. Test it
- Inspector: `npx @modelcontextprotocol/inspector node dist/index.js`
- Scripted client (CI):
```js
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";

const c = new Client({ name: "ci", version: "1.0.0" });
await c.connect(new StdioClientTransport({ command: "node", args: ["dist/index.js"] }));
const { tools } = await c.listTools();
console.assert(tools[0].annotations.readOnlyHint === true);
const ok = await c.callTool({ name: "orders_get", arguments: { order_id: "o1" } });
console.assert(ok.structuredContent.total === 50000);
const bad = await c.callTool({ name: "orders_get", arguments: { order_id: "zz" } });
console.assert(bad.isError === true);
await c.close();
```

## 6. Register with a client
Claude Code: `claude mcp add kio-orders -e ORDERS_API_URL=https://api.example.com -- node /path/to/dist/index.js`. Other clients take the same `command` / `args` / `env` JSON shown in `python-server.md`.
