# 🐍 MCP Server in Python

Verified against the official `mcp` Python SDK **2.3.0** (stdio, tool listing, structured output, tool errors).

> **Version note.** In `mcp` 2.x, `FastMCP` was renamed to **`MCPServer`** (`from mcp.server.mcpserver import MCPServer`) and Python-side model attributes are snake_case (`read_only_hint`, `input_schema`, `is_error`). Code written for 1.x (`from mcp.server.fastmcp import FastMCP`) needs `pip install "mcp<2"` or the migration guide at `https://py.sdk.modelcontextprotocol.io/v2/migration/`. Pin the major version in `pyproject.toml`.

## 1. Project layout
```
kio-orders-mcp/
├── pyproject.toml          # dependencies: mcp>=2.3,<3 ; httpx ; pydantic
├── src/kio_orders_mcp/
│   ├── server.py           # MCPServer instance + tool registration
│   ├── client.py           # thin HTTP client for the upstream API (one place for auth, retries)
│   └── models.py           # pydantic input/output models
└── tests/
```

## 2. Minimal server
```python
from typing import Annotated

from pydantic import BaseModel, Field
from mcp.server.mcpserver import MCPServer
from mcp.server.mcpserver.exceptions import ToolError
from mcp.types import ToolAnnotations

mcp = MCPServer("kio-orders", instructions="Read-only access to Kio orders.")


class Order(BaseModel):
    id: str
    status: str
    total: int


ORDERS = {"o1": {"id": "o1", "status": "paid", "total": 50000}}


@mcp.tool(
    title="Get order",
    annotations=ToolAnnotations(readOnlyHint=True, idempotentHint=True, openWorldHint=False),
)
async def orders_get(order_id: Annotated[str, Field(description="Order ID, e.g. 'o1'")]) -> Order:
    """Fetch one order by ID. Returns id, status and total (VND, integer)."""
    order = ORDERS.get(order_id)
    if order is None:
        raise ToolError(f"Order '{order_id}' not found. Use orders_search to list IDs.")
    return Order(**order)


if __name__ == "__main__":
    mcp.run()  # stdio; mcp.run(transport="streamable-http") for remote
```

- The **docstring** becomes the tool description; `Field(description=...)` documents each argument. Both are what the model reads — write them for the model.
- Returning a **pydantic model** produces `structuredContent` plus a text fallback.
- Raise **`ToolError`** for messages the model should see. Any other exception becomes the generic "Error executing tool …" and its text stays in server logs (good for secrets, bad for guidance).
- Never `print()` in a stdio server: stdout is the protocol. Log to stderr.

## 3. Calling an upstream API
```python
import os
import httpx

API = os.environ["ORDERS_API_URL"]
TOKEN = os.environ["ORDERS_API_TOKEN"]          # from env, never hard-coded

async def api_get(path: str, **params) -> dict:
    async with httpx.AsyncClient(base_url=API, timeout=20,
                                 headers={"Authorization": f"Bearer {TOKEN}"}) as http:
        r = await http.get(path, params=params)
    if r.status_code == 404:
        raise ToolError("Not found. Check the ID or search first.")
    if r.status_code == 429:
        raise ToolError("Rate limited by the Orders API. Wait a minute and retry.")
    r.raise_for_status()
    return r.json()
```

## 4. Pagination and size limits
```python
@mcp.tool(annotations=ToolAnnotations(readOnlyHint=True))
async def orders_search(
    query: Annotated[str, Field(description="Customer email, name or order ID fragment")],
    limit: Annotated[int, Field(ge=1, le=50, description="Max results (default 20)")] = 20,
    cursor: Annotated[str | None, Field(description="next_cursor from the previous call")] = None,
) -> dict:
    """Search orders. Returns {items, next_cursor}; pass next_cursor to get more."""
    data = await api_get("/orders", q=query, limit=limit, cursor=cursor)
    return {"items": data["items"], "next_cursor": data.get("next_cursor")}
```
Keep responses small (IDs + the few fields the model needs); offer a `get` tool for details.

## 5. Test it
- **Inspector:** `npx @modelcontextprotocol/inspector python -m kio_orders_mcp.server`
- **Scripted client (CI):**
```python
import asyncio, sys
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def main():
    params = StdioServerParameters(command=sys.executable, args=["src/kio_orders_mcp/server.py"])
    async with stdio_client(params) as (r, w), ClientSession(r, w) as s:
        await s.initialize()
        tools = (await s.list_tools()).tools
        assert tools[0].annotations.read_only_hint
        ok = await s.call_tool("orders_get", {"order_id": "o1"})
        assert not ok.is_error and ok.structured_content["total"] == 50000
        bad = await s.call_tool("orders_get", {"order_id": "zz"})
        assert bad.is_error and "not found" in bad.content[0].text

asyncio.run(main())
```

## 6. Register with a client
```json
{
  "mcpServers": {
    "kio-orders": {
      "command": "uv",
      "args": ["run", "--directory", "/path/to/kio-orders-mcp", "python", "-m", "kio_orders_mcp.server"],
      "env": { "ORDERS_API_URL": "https://api.example.com", "ORDERS_API_TOKEN": "${ORDERS_API_TOKEN}" }
    }
  }
}
```
Claude Code: `claude mcp add kio-orders -- uv run --directory /path/to/kio-orders-mcp python -m kio_orders_mcp.server`.
