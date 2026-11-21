# Production GitHub Actions CI/CD Pipelines

## 1. Automated Secret & Vulnerability Scanning
```yaml
name: Security Audit
on: [push, pull_request]

jobs:
  trivy-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@0.28.0   # pin a release tag or a full commit SHA, never @master
        with:
          scan-type: 'fs'
          ignore-unfixed: true
          severity: 'CRITICAL,HIGH'
          exit-code: '1'
```

## 2. Docker Buildx with GitHub Cache
```yaml
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

> The Buildx snippet above assumes a `docker/metadata-action` step with `id: meta` and a registry login; the full workflow in §3 has both.

## 3. Full CI → CD workflow (Node example)
```yaml
name: ci
on:
  pull_request:
  push:
    branches: [main]

permissions:
  contents: read            # least privilege by default; widen per job

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true  # stop superseded runs on the same branch

jobs:
  test:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    services:
      postgres:
        image: postgres:16
        env: { POSTGRES_PASSWORD: postgres }
        ports: ['5432:5432']
        options: >-
          --health-cmd "pg_isready -U postgres" --health-interval 5s --health-retries 10
    env:
      DATABASE_URL: postgres://postgres:postgres@localhost:5432/postgres
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22, cache: npm }
      - run: npm ci
      - run: npm run lint && npm run typecheck
      - run: npm run db:migrate
      - run: npm test -- --coverage

  image:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write       # push to GHCR
      id-token: write       # OIDC to the cloud, no long-lived keys
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=sha
            type=raw,value=latest
      - uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy:
    needs: image
    runs-on: ubuntu-latest
    environment: production  # required reviewers + environment-scoped secrets
    steps:
      - run: echo "deploy ghcr.io/${{ github.repository }}:sha-${GITHUB_SHA::7}"
```

## 4. Cloud credentials via OIDC (no static keys)
```yaml
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/gha-deploy
          aws-region: ap-southeast-1
```
The IAM role's trust policy must restrict `token.actions.githubusercontent.com:sub` to `repo:<owner>/<repo>:environment:production` (or a branch) — otherwise any workflow in any repo with that audience can assume it. GCP: `google-github-actions/auth` with Workload Identity Federation; Azure: `azure/login` with federated credentials.

## 5. Rules
- **Pin third-party actions** to a release tag at minimum; pin to a full commit SHA for anything that touches secrets. Let Dependabot (`package-ecosystem: github-actions`) bump them.
- **`pull_request_target` never checks out PR code** with secrets available. Use `pull_request` for untrusted code.
- Never `echo` secrets; pass them via `env:` and let masking work. Untrusted inputs (`github.event.issue.title`, branch names) go through `env:` too — never straight into `run:` (script injection).
- Cache dependencies (`setup-node`/`setup-python` `cache:`), set `timeout-minutes`, and use `concurrency` so stuck jobs do not burn minutes.
- Migrations run **before** the new version takes traffic and must be backward compatible with the old version (see `migrations-and-caching.md`).
- Gate production with an `environment` that has required reviewers; deploy the **same image digest** that passed tests.
