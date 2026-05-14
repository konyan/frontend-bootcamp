# Deployment & Preview Workflow

> "It works on my machine" ends the moment you set up a preview deploy.

**Type:** Build
**Languages:** TypeScript, Shell
**Prerequisites:** Lessons 06 and 11
**Time:** ~60 minutes

## Learning Objectives

- Understand why local and production environments behave differently
- Configure environment variables correctly for a Vite frontend app
- Create `vercel.json` with security headers and frozen-lockfile installs
- Establish a preview-deploy workflow so reviewers test the real artifact, not a local server

## The Problem

You build your app locally and it works perfectly. You push to GitHub. Ten minutes later Vercel says the deploy succeeded. You open the URL and it crashes: `Cannot read properties of undefined`. The API call is failing because `VITE_API_URL` is `undefined` — you added it to your local `.env` file but never added it to the Vercel dashboard.

This is the most common cause of "works locally, broken in production" for frontend apps. It is entirely preventable.

A second problem: you push a fix, wait for CI, wait for the deploy, share the URL — and a reviewer says the change is not visible. You pushed to the wrong branch and the preview went to the wrong environment. Without a structured deployment workflow, every team member ships differently.

## The Concept

### Why Local and Production Differ

| Aspect | Local | Production |
|--------|-------|------------|
| Environment variables | Your `.env` file | Platform dashboard settings |
| Operating system | macOS (case-insensitive paths) | Linux (case-sensitive) |
| Node version | Whatever is installed | Platform-configured |
| Build command | You run it | Platform runs it on every push |

A file named `UserCard.tsx` imported as `import UserCard from './usercard'` works on macOS and silently fails on Linux. Preview deploys catch this because they run on the same Linux infrastructure as production.

### Environment Variables in Frontend Apps

All frontend JavaScript runs in the browser. There is no secure server-side environment — everything bundled into the JS is visible in DevTools. The `VITE_` prefix enforces this distinction:

| Prefix | When resolved | Browser visible |
|--------|--------------|-----------------|
| `VITE_` | Build time | Yes — inlined as a string literal |
| `NEXT_PUBLIC_` | Build time | Yes — inlined as a string literal |
| (no prefix) in Next.js | Server only | No |

If a `VITE_` variable is missing at build time, it becomes the string `"undefined"` — no error until the code uses it at runtime.

**Never put secrets (API keys, tokens) in `VITE_` variables.** They are public.

### The Deploy Pipeline

```
Developer pushes branch
        ↓
CI: tsc --noEmit, pnpm lint, pnpm build
        ↓
Preview deploy created    ← unique URL, same infrastructure as prod
        ↓
Reviewer tests preview URL
        ↓
Merge to main
        ↓
Production promotion      ← same artifact, no rebuild
```

The production promotion step does not rebuild. The artifact that was previewed and reviewed is exactly what reaches production.

## Build It

### Step 1: Create `.env.example`

```bash
# App
VITE_APP_NAME=My Frontend App
VITE_API_URL=https://api.example.com

# Feature flags
VITE_ENABLE_ANALYTICS=false
VITE_ENABLE_DEBUG_PANEL=false
```

Commit this file. It documents what variables the app requires without exposing real values. Add `.env` to `.gitignore` — never commit it.

Every developer who clones the repo copies `.env.example` to `.env` and fills in their values.

### Step 2: Add env vars to the platform

In the Vercel dashboard: Project Settings > Environment Variables. Add each `VITE_*` variable for Production, Preview, and Development environments.

Or via the CLI:
```bash
vercel env add VITE_API_URL
```

Run a fresh deploy after adding variables — Vercel rebuilds when environment variables change.

### Step 3: Create `vercel.json`

```json
{
  "buildCommand": "pnpm build",
  "outputDirectory": "dist",
  "installCommand": "pnpm install --frozen-lockfile",
  "framework": "vite",
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-Frame-Options", "value": "DENY" }
      ]
    },
    {
      "source": "/assets/(.*)",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
      ]
    }
  ]
}
```

`--frozen-lockfile` fails if `pnpm-lock.yaml` is out of sync with `package.json` — ensuring the platform installs exactly the versions that were tested. `Cache-Control: immutable` on `/assets/` tells browsers to cache hashed asset files forever (safe because the hash changes with content).

### Step 4: Create `build-check.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Type checking..."
pnpm tsc --noEmit

echo "Linting..."
pnpm lint

echo "Building..."
pnpm build

echo "All checks passed."
```

Make it executable and run it before opening a PR:

```bash
chmod +x build-check.sh
./build-check.sh
```

### Step 5: Push and verify the preview URL

```bash
git checkout -b feat/my-feature
git push origin feat/my-feature
```

Vercel creates a preview deploy automatically. The URL appears in the GitHub PR as a status check. Click it, navigate to the pages your PR touches, and verify behavior. Share the URL in the PR description so reviewers test the real artifact.

## Use It

Netlify uses `netlify.toml` for the same configuration:

```toml
[build]
  command = "pnpm build"
  publish = "dist"

[[headers]]
  for = "/assets/*"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"
```

GitHub Environments add a human approval gate before production deploys. Add required reviewers in repository Settings > Environments:

```yaml
jobs:
  deploy:
    environment: production
    steps:
      - run: ./build-check.sh
```

No deploy runs without approval. This is the human checkpoint between preview validation and production promotion.

## Ship It

The four files — `vercel.json`, `.env.example`, `build-check.sh`, and a `prompt-deploy-troubleshooter.md` in `outputs/` — form a complete deploy baseline. Add them to every project before the first deploy.

## Exercises

1. Add `VITE_APP_VERSION=$(git rev-parse --short HEAD) pnpm build` as the build command and display the value in a footer component. Explain why this works for build-time values but not for values that need to change without a rebuild.

2. Write a GitHub Actions workflow file at `.github/workflows/pr-check.yml` that runs `./build-check.sh` on every pull request targeting `main`.

3. Explain what an attacker can do if a `.env` file containing `VITE_API_KEY=sk-live-...` is accidentally committed to a public repository. What are the two steps to remediate it?

## Key Terms

| Term | Common Misconception | What It Actually Means |
|------|---------------------|------------------------|
| **Preview deploy** | "A staging environment" | A fully built and hosted version of the app from a specific PR — distinct URL, same infrastructure as production |
| **Build-time variable** | "A server environment variable" | A value inlined as a string literal during `vite build` — visible in the browser bundle |
| **Frozen lockfile** | "A stricter install mode" | Install fails if `pnpm-lock.yaml` is out of sync — guarantees the platform installs the tested versions |
| **Production promotion** | "A new deploy" | Making an already-built artifact available at the production URL — no rebuild, what was previewed is what ships |
| **CI/CD** | "Just automation" | A pipeline that runs checks (build, lint, typecheck) on every push and deploys only when they pass |

## Further Reading

- [Vercel environment variables](https://vercel.com/docs/environment-variables) — how to add, scope, and reference env vars
- [Netlify deploy configuration](https://docs.netlify.com/configure-builds/file-based-configuration/) — `netlify.toml` reference
- [The Twelve-Factor App: Config](https://12factor.net/config) — the principle behind keeping config out of code
- [GitHub Actions for frontend](https://docs.github.com/en/actions/use-cases-and-examples/building-and-testing/building-and-testing-nodejs) — Node.js CI workflow reference
