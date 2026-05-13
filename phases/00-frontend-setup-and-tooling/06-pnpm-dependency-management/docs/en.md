# pnpm and Dependency Management

> One lockfile, one store, one source of truth — reproducible installs across every machine and CI run.

**Type:** Build
**Languages:** JavaScript
**Prerequisites:** Lesson 05 — Node.js Runtimes & Version Management
**Time:** ~60 minutes

## The Problem

A developer runs `npm install` on a monorepo and the `node_modules` folder grows to 800 MB. Half of that is the same packages duplicated across three sub-packages because npm hoists dependencies differently on each machine depending on install order. A second developer uses yarn and their `yarn.lock` diverges from the `package-lock.json`. Now every PR has a lockfile conflict no one wants to touch.

The CI pipeline runs on a fresh container. The install takes four minutes — slow enough that developers skip running it locally and push with stale lockfiles. Production deploys a different version of a transitive dependency than the one that was tested. The bug is real, the cause is invisible, and the fix is a two-day investigation.

pnpm solves these problems with a content-addressable store and strict non-hoisting by default, making installs fast, reproducible, and honest about what a package can actually see.

## The Concept

**How pnpm stores packages:**

```
~/.pnpm-store/          ← one global store on disk (content-addressable)
    v3/
        files/
            ab/cd...    ← each file stored once by hash

project/
    node_modules/
        .pnpm/          ← flat list of all packages with exact versions
        react → symlink → .pnpm/react@19.0.0/node_modules/react
```

Every package is stored once globally. Projects symlink into the store. Installing the same version across 10 projects costs disk space only once.

**No phantom dependencies:** because pnpm does not hoist by default, a package can only `require()` what it explicitly declared in its own `dependencies`. If you import `lodash` without listing it in `package.json`, the import fails — which is the correct behavior.

**Lockfile:** `pnpm-lock.yaml` records exact versions of every direct and transitive dependency. Commit it to git. Never edit it manually.

**Workspace layout:**
```
monorepo/
├── pnpm-workspace.yaml    ← lists package locations
├── package.json           ← root, holds shared dev tools
├── apps/
│   └── web/               ← workspace package
└── packages/
    └── ui/                ← shared component library
```

## Build It

### Step 1: Install pnpm

Via Corepack (bundled with Node.js 16+):
```bash
corepack enable
corepack prepare pnpm@latest --activate
```

Or directly:
```bash
npm install -g pnpm
```

Verify: `pnpm --version`

### Step 2: Initialize a project

```bash
mkdir my-app && cd my-app
pnpm init
```

Replace the generated `package.json` with `code/package.json` — it includes `engines`, a `preinstall` guard, and common scripts.

### Step 3: Add dependencies and inspect the lockfile

```bash
pnpm add react react-dom
pnpm add -D typescript vite
```

Open `pnpm-lock.yaml`. Each entry shows the exact resolved version, integrity hash, and which packages depend on it. This is what CI uses to reproduce the exact install.

### Step 4: Configure via .npmrc

Create `.npmrc` from `code/.npmrc`:

```ini
shamefully-hoist=false
strict-peer-dependencies=false
auto-install-peers=true
engine-strict=true
```

`engine-strict=true` makes pnpm fail the install if the Node version does not satisfy `package.json#engines`.

### Step 5: Set up a workspace

Create `pnpm-workspace.yaml` from `code/pnpm-workspace.yaml`:

```yaml
packages:
  - "apps/*"
  - "packages/*"
```

Install a shared dev dependency at the root:
```bash
pnpm add -w typescript
```

Install a dependency only in one workspace package:
```bash
pnpm add react --filter @myapp/web
```

## Use It

`pnpm dlx` replaces `npx` for one-off commands without installing globally:
```bash
pnpm dlx create-vite@latest my-app
```

`pnpm why <package>` shows exactly why a package is in `node_modules` — which package required it and through which dependency chain. Essential for understanding transitive dependencies.

`pnpm store prune` cleans unreferenced packages from the global store — run periodically to reclaim disk space.

## Ship It

The `package.json`, `pnpm-workspace.yaml`, and `.npmrc` in `code/` are the baseline for any new project. The `preinstall` script (`npx only-allow pnpm`) prevents teammates from accidentally running `npm install` or `yarn`, which would create a conflicting lockfile.

## Exercises

1. Run `pnpm store path` and then `du -sh $(pnpm store path)` to see the size of the global store. Explain why this number does not grow linearly with the number of projects.
2. Create a two-package workspace (`apps/web` and `packages/ui`) and add a dependency to `packages/ui` only. Verify `apps/web` cannot import it without declaring it explicitly.
3. Add `"preinstall": "npx only-allow pnpm"` to a project's `package.json` and try running `npm install` — explain the error and why it matters.

## Key Terms

| Term | What people say | What it actually means |
|------|----------------|----------------------|
| Lockfile | "pnpm-lock.yaml" | A file recording the exact resolved version and integrity hash of every dependency — the source of truth for reproducible installs |
| Hoisting | "node_modules flattening" | Moving transitive dependencies up to the root `node_modules` so any package can accidentally import them — pnpm avoids this by default |
| Phantom dependency | "It just works" | A package imported without being listed in `dependencies` — works because npm/yarn hoist it, breaks when pnpm is used |
| Workspace | "Monorepo" | Multiple packages in one repo managed together — pnpm workspaces share the store and can cross-reference each other |
| Content-addressable store | "pnpm cache" | A global folder where each file is stored once by its hash — symlinked into every project that needs it |

## Further Reading

- [pnpm docs](https://pnpm.io/motivation) — motivation, workspace, and CLI reference
- [pnpm workspaces](https://pnpm.io/workspaces) — monorepo setup and filtering
- [Why pnpm](https://pnpm.io/faq) — official FAQ comparing pnpm to npm and yarn
