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
- Define explicit health checks (`test: ["CMD", "curl", "-f", "http://localhost:8000/healthz"]`).
- Isolate services on custom user bridge networks.
