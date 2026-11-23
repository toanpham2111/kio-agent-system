# Hardened Docker Recipes

## 1. Python / FastAPI Production Dockerfile
```dockerfile
FROM python:3.11-slim-bookworm AS builder

WORKDIR /app
RUN pip install --no-cache-dir poetry
COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.in-project true && \
    poetry install --no-interaction --no-ansi --only main

FROM python:3.11-slim-bookworm AS runner
WORKDIR /app
ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1

RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup appuser

COPY --from=builder /app/.venv /app/.venv
COPY . /app

USER appuser
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## 2. Docker Compose Dev Environment Standard
- Use volume mounts for hot reload.
- Define explicit health checks. `-slim` images ship without `curl`, so use the runtime itself: `test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/healthz')"]` (or install `curl` explicitly).
- Isolate services on custom user bridge networks.

## 3. Node.js / Next.js production Dockerfile
```dockerfile
# syntax=docker/dockerfile:1
FROM node:22-bookworm-slim AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci

FROM node:22-bookworm-slim AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build            # next.config.js: output: 'standalone'

FROM node:22-bookworm-slim AS runner
WORKDIR /app
ENV NODE_ENV=production PORT=3000 HOSTNAME=0.0.0.0
COPY --from=build --chown=node:node /app/.next/standalone ./
COPY --from=build --chown=node:node /app/.next/static ./.next/static
COPY --from=build --chown=node:node /app/public ./public
USER node
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s CMD node -e "fetch('http://localhost:3000/api/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"
CMD ["node", "server.js"]
```

## 4. Compose for local development
```yaml
services:
  api:
    build: { context: ., target: build }
    command: npm run dev
    env_file: .env                     # never commit .env; commit .env.example
    ports: ["8080:3000"]
    volumes: [".:/app", "/app/node_modules"]   # anonymous volume keeps container deps
    depends_on:
      db: { condition: service_healthy }
  db:
    image: postgres:16
    environment: { POSTGRES_PASSWORD: postgres }
    volumes: ["pgdata:/var/lib/postgresql/data"]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      retries: 10
  redis:
    image: redis:7-alpine
volumes: { pgdata: {} }
```

## 5. Hardening checklist
- [ ] Multi-stage build; final stage has no compilers, package managers' caches, or source you do not run.
- [ ] Runs as a non-root user (`USER node` / UID ≥ 10000); `--read-only` root FS where possible, with `tmpfs` for `/tmp`.
- [ ] `.dockerignore` excludes `.git`, `.env*`, `node_modules`, test fixtures, local DB dumps.
- [ ] No secrets in `ARG`/`ENV`/layers; use BuildKit `--mount=type=secret` at build time and runtime env/secret stores.
- [ ] Base images pinned to a minor version (`node:22-bookworm-slim`) and rebuilt weekly for patches; production deploys reference the **digest**.
- [ ] Image scanned in CI (Trivy/Grype); fail on fixable CRITICAL/HIGH.
- [ ] One process per container, logs to stdout/stderr, graceful shutdown on `SIGTERM` (Node: close the HTTP server; Uvicorn handles it).
- [ ] `HEALTHCHECK` (or orchestrator probes) hits a cheap endpoint that does not call third parties.
