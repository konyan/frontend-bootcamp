# pnpm & Dependency Management

> Every JavaScript project uses other people's code. How you manage it determines how fast and reliable your workflow is.

**Type:** Build
**Languages:** JavaScript
**Prerequisites:** Lesson 05 — Node.js Runtimes & Version Management
**Time:** ~60 minutes

## Learning Objectives

- Understand what a package manager does and why pnpm exists
- Install packages as dependencies vs dev dependencies and know the difference
- Read and trust the lockfile for reproducible installs
- Prevent phantom dependencies from making your project fragile

## The Problem

You start a new project and run `npm install`. Forty seconds pass. The `node_modules` folder is now 350 MB for a todo app with five dependencies. A colleague runs the same command on their machine and gets a slightly different version of one transitive dependency. A week later a package publishes a patch and your colleague's machine now has a different behavior than yours.

CI fails with an error that does not reproduce locally. Someone manually deleted the lockfile because it had merge conflicts. Now every machine is installing different versions and nobody knows which one is correct.

These are not edge cases — they happen on every project that uses npm carelessly. pnpm solves the performance and reproducibility problems with a single global store and a strict lockfile.

## The Concept

### What a Package Manager Does

When you write `import { useState } from 'react'`, React is not built into JavaScript. Someone wrote it, published it to the npm registry, and you download it. A package manager handles downloading, storing, and managing all these libraries.

```
pnpm add react
        ↓
Downloads react from registry.npmjs.org
Also downloads everything react depends on
Records exact versions in pnpm-lock.yaml
Creates symlinks in node_modules/
```

### How pnpm Stores Packages

npm copies every package into every project's `node_modules`. pnpm uses a single global store and symlinks from it:

```
~/.pnpm-store/          ← one copy per unique file, shared across all projects
    react@19.0.0/

project-a/node_modules/react  →  ~/.pnpm-store/react@19.0.0
project-b/node_modules/react  →  ~/.pnpm-store/react@19.0.0
```

Installing the same React version across 10 projects costs disk space only once. Installs are fast because files already exist on disk — only the symlinks are new.

### The Lockfile

`pnpm-lock.yaml` records the exact version and integrity hash of every package installed, including all transitive dependencies. Commit it to git. Never edit it manually. Never delete it.

When CI runs `pnpm install`, it reads the lockfile and installs exactly those versions — not the latest, not something slightly different.

### Dependencies vs Dev Dependencies

```
pnpm add react              →  goes in "dependencies"    (shipped to users)
pnpm add -D typescript      →  goes in "devDependencies" (build tools only)
```

Dev dependencies are not included in a production build. Users never download your TypeScript compiler or your test runner.

### No Phantom Dependencies

npm flattens all packages into one `node_modules` directory. This means any file can accidentally import any package, even ones not listed in its own `package.json`. pnpm is strict: a package can only import what it explicitly declared. Phantom dependency bugs fail immediately with pnpm instead of silently in production.

## Build It

### Step 1: Install pnpm

```bash
npm install -g pnpm
pnpm --version
```

### Step 2: Initialize a project

```bash
mkdir my-app && cd my-app
pnpm init
```

### Step 3: Add dependencies

```bash
pnpm add react react-dom
pnpm add -D typescript vite @types/react @types/react-dom
```

Open `pnpm-lock.yaml`. Each entry shows the exact resolved version and an integrity hash. This is what CI uses to reproduce the exact install.

### Step 4: Configure .npmrc

Create `.npmrc` in the project root:

```ini
shamefully-hoist=false
strict-peer-dependencies=false
auto-install-peers=true
engine-strict=true
```

`shamefully-hoist=false` is the default — it keeps pnpm's strict non-hoisting behavior. Only set it to `true` if a package explicitly requires it (rare).

### Step 5: Add a preinstall guard

Add this to `package.json` scripts to prevent teammates from accidentally running `npm install`:

```json
{
  "scripts": {
    "preinstall": "npx only-allow pnpm"
  }
}
```

Any `npm install` or `yarn install` in this project will now fail with a clear message.

### Step 6: Verify with pnpm why

```bash
pnpm why react
```

This shows why `react` is in `node_modules` — which package required it and through what dependency chain. Use it whenever you see an unfamiliar package.

## Use It

`pnpm dlx` runs a one-off command from the registry without installing it globally:

```bash
pnpm dlx create-vite@latest my-app --template react-ts
```

This is the pnpm equivalent of `npx`. Use it for scaffolding commands you only run once.

`pnpm store prune` removes packages from the global store that no project currently uses — run periodically to reclaim disk space.

## Ship It

The baseline `package.json` and `.npmrc` from `code/` are your starting point for every new project. The `preinstall` guard and `engine-strict` setting prevent the two most common team workflow mistakes before they happen.

## Exercises

1. Run `pnpm store path` and then `du -sh $(pnpm store path)`. Open two projects that share a dependency (e.g., React). Explain in one paragraph why the store size does not double.

2. Add a package with `pnpm add lodash`. Run `pnpm why lodash`. What output do you see? Now try importing a package you did not add — does the import fail or succeed? Why?

3. Add `"preinstall": "npx only-allow pnpm"` to a project. Try running `npm install`. What error message appears? Explain why this guard matters on a team.

## Key Terms

| Term | Common Misconception | What It Actually Means |
|------|---------------------|------------------------|
| **Package manager** | "npm and pnpm are interchangeable" | A tool that downloads libraries from the npm registry — pnpm stores files once globally, npm copies per project |
| **Lockfile** | "An auto-generated file I can delete" | The source of truth for reproducible installs — records exact versions and hashes for every dependency |
| **Dev dependency** | "Same as a regular dependency" | A package needed during development only — build tools, linters, test runners never shipped to users |
| **Phantom dependency** | "It works, so it must be fine" | A package imported without being listed in `dependencies` — works by accident with npm, fails with pnpm |
| **Content-addressable store** | "A cache" | A global directory where each unique file is stored once by its hash — symlinked into every project |

## Further Reading

- [pnpm motivation](https://pnpm.io/motivation) — why pnpm was built and how it compares to npm/yarn
- [pnpm CLI reference](https://pnpm.io/cli/add) — all commands documented
- [npm vs pnpm vs yarn](https://pnpm.io/faq) — official FAQ comparing the three package managers
