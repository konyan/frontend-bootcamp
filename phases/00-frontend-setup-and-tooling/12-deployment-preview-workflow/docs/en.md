# Deployment & Preview Workflow

> A feature is not done when it works locally — it is done when it works on the same infrastructure your users hit.

**Type:** Build
**Languages:** TypeScript
**Prerequisites:** Lessons 06 and 11
**Time:** ~60 minutes

## The Problem

A developer builds their app locally and it works perfectly. They push to GitHub and Vercel deploys it. The deployed app crashes at runtime because `import.meta.env.VITE_API_URL` is `undefined` — they added the variable to their local `.env` file but forgot to add it in the Vercel dashboard. The error only appears after the deploy reaches users.

A reviewer clicks the preview link in a pull request and sees a 404. The route the developer added is in the codebase, but the `vercel.json` does not have a rewrite rule, so direct URL access to a client-side route falls through to the static file server and fails.

The production deploy overwrites a working version with a broken one because there was no staging check. The team has no `build-check.sh`, no CI run on the PR, and no preview environment to validate against before promotion. Every developer manually runs their own incantation to ship, so the deploy process is different every time.

## The Concept

**The modern frontend deploy pipeline:**

```
Developer pushes branch
        |
        v
  CI runs build checks
  (tsc, lint, pnpm build)
        |
        v
  Preview deploy created
  (unique URL per PR)
        |
        v
  Reviewer approves
  (checks preview URL)
        |
        v
  Merge to main
        |
        v
  Production promotion
  (same artifact, new routing)
```

No new build happens at the production promotion step. The artifact built for preview is the same artifact that reaches production — this guarantees what you reviewed is what users get.

**Environment variables in frontend apps:**

Frontend JavaScript runs in the browser. There is no secure server-side environment, so all variables bundled into the JS are visible to anyone who opens DevTools. The framework prefixes enforce this distinction:

| Prefix | Framework | When resolved | Visible to browser |
|--------|-----------|--------------|-------------------|
| `VITE_` | Vite | Build time | Yes — bundled into JS |
| `NEXT_PUBLIC_` | Next.js | Build time | Yes — bundled into JS |
| (no prefix) | Next.js | Server only | No — never in the bundle |

Build-time variables are inlined as string literals during `vite build`. If the variable is missing at build time, the literal is `undefined` and no runtime error occurs until the code tries to use it — which is why the bug is easy to miss locally but surfaces in production.

**Preview deploys** give every pull request its own URL. The reviewer tests the actual built artifact on the actual hosting infrastructure, not a local dev server. This catches:

- Missing environment variables
- Routing mismatches (`vercel.json` rewrite rules)
- Asset loading failures (wrong base path)
- Platform-specific build failures (Linux case-sensitivity vs macOS)

## Build It

### Step 1: Create `.env.example`

Copy `code/.env.example` to the project root and commit it:

```
# App
VITE_APP_NAME=My Frontend App
VITE_API_URL=https://api.example.com

# Feature flags
VITE_ENABLE_ANALYTICS=false
VITE_ENABLE_DEBUG_PANEL=false
```

This file is a contract. It documents which variables the app requires without exposing real values. Every developer who clones the repo copies it to `.env` and fills in their values. Add `.env` to `.gitignore` — never commit it.

### Step 2: Add env vars to the platform

In the Vercel dashboard: Project Settings > Environment Variables. Add each `VITE_*` variable for the Production, Preview, and Development environments. Or use the CLI:

```bash
vercel env add VITE_API_URL
```

Vercel re-runs the build when variables change. Run a fresh deploy after adding variables to verify they are picked up.

### Step 3: Create `vercel.json`

Copy `code/vercel.json` to the project root:

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

`--frozen-lockfile` ensures the platform installs exactly the versions in `pnpm-lock.yaml`. Without it, a patch release published after your last commit can change the deployed behavior. The `Cache-Control: immutable` header on `/assets/` tells browsers never to re-request hashed asset files — since the hash changes when content changes, this is safe and eliminates unnecessary network requests on repeat visits.

### Step 4: Run `build-check.sh` locally before merging

Copy `code/build-check.sh` to the project root and make it executable:

```bash
chmod +x build-check.sh
./build-check.sh
```

The script runs `tsc --noEmit`, `pnpm lint`, and `pnpm build` in sequence. If any step fails, the script exits immediately (`set -euo pipefail`). Run this before opening a PR rather than waiting for CI to catch failures.

### Step 5: Push a branch and verify the preview URL

```bash
git checkout -b feat/my-feature
git push origin feat/my-feature
```

Vercel creates a preview deploy automatically. The URL appears in the GitHub PR as a status check. Click it, navigate to the pages your PR touches, and confirm they behave correctly. Share the preview URL in the PR description so reviewers can test without setting up the project locally.

## Use It

Netlify's `netlify.toml` serves the same purpose as `vercel.json`:

```toml
[build]
  command = "pnpm build"
  publish = "dist"

[[headers]]
  for = "/assets/*"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"
```

GitHub Environments add a production gate on top of the platform-level deploy. Configure a `production` environment in repository Settings > Environments, add required reviewers, and reference it in the workflow:

```yaml
jobs:
  deploy:
    environment: production
    steps:
      - run: ./build-check.sh
```

No deploy runs without a named reviewer approving it. This is the human checkpoint between preview validation and production promotion.

## Ship It

The `vercel.json`, `.env.example`, and `build-check.sh` in `code/`, plus the `prompt-deploy-troubleshooter.md` output — drop all four into any frontend project before the first deploy. They give you a reproducible build check, a documented env var contract, a platform config with security headers, and a diagnostic prompt for when deploys fail.

## Exercises

1. Add a `VITE_APP_VERSION` env var and set it to the current git SHA in the build command: `VITE_APP_VERSION=$(git rev-parse --short HEAD) pnpm build`. Display it in a footer component. Explain in writing why this approach works for build-time values but would be wrong for a value that needs to change without a new build.
2. Write a GitHub Actions workflow file (`.github/workflows/pr-check.yml`) that runs `./build-check.sh` on every pull request targeting `main`.
3. Explain why a `.env` file must be in `.gitignore` and what the concrete consequences are if it is accidentally committed and pushed to a public repository — include what an attacker could do with the values and how to remediate the exposure.

## Key Terms

| Term | What people say | What it actually means |
|------|----------------|----------------------|
| preview deploy | "preview URL" | A fully built and hosted version of the app from a specific branch or PR, distinct from production |
| environment variable | "env var" | A named value injected into the build or runtime environment, kept outside source code |
| build-time variable | "VITE_ prefix" | A variable inlined as a string literal during the build — visible in the browser bundle |
| production promotion | "promoting to prod" | Making an already-built artifact available at the production URL without rebuilding |
| CI/CD | "the pipeline" | Automated steps (build, test, deploy) triggered by a git push |

## Further Reading

- [Vercel environment variables docs](https://vercel.com/docs/environment-variables) — how to add, scope, and reference env vars per environment
- [Netlify deploy configuration](https://docs.netlify.com/configure-builds/file-based-configuration/) — `netlify.toml` reference
- [The Twelve-Factor App: Config](https://12factor.net/config) — the principle behind keeping config out of code and in the environment
