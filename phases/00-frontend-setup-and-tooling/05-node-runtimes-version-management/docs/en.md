# Node.js Runtimes & Version Management

> Pin the version. Write it down. Make it reproducible.

**Type:** Learn
**Languages:** JavaScript
**Prerequisites:** Lesson 01 — Modern Development Environment
**Time:** ~45 minutes

## Learning Objectives

- Understand the difference between Node.js LTS and current releases
- Use fnm to install multiple Node versions and switch between projects
- Pin a Node version in `.nvmrc` and `package.json` so the team always uses the same one
- Know when to consider Deno or Bun as Node alternatives

## The Problem

A developer clones a project from a colleague and runs `pnpm install`. It fails with a cryptic error about a native module. The developer has Node 22 installed. The project was built on Node 18 and uses a package that changed its native bindings between those versions.

A second scenario: a developer upgrades Node globally to test a new feature, forgets about it, and three of their other projects start behaving differently. One project's test suite now has 47 new failures — not because the code changed, but because Node's behavior around a specific API changed between versions.

A version manager solves both problems by letting you run different Node versions per directory, pinned in a file that is committed to git.

## The Concept

### LTS vs Current

Node.js maintains two release lines simultaneously:

```
Current  →  Active LTS  →  Maintenance  →  End of Life
  (new features)  (stable, recommended)  (security only)  (unsupported)
```

| Release type | When to use |
|-------------|-------------|
| LTS (Long-Term Support) | Production projects, team environments |
| Current | Experimenting with new Node features |

LTS releases are supported for 30 months. A new LTS starts every October with an even major version (18, 20, 22). Use LTS for any project that other developers will run.

### How fnm Works

fnm stores each Node version in its own directory and creates symlinks in your PATH when you run `fnm use`:

```
~/.fnm/node-versions/
    v18.20.0/
    v20.14.0/
    v22.3.0/    ← active via PATH symlink

project-a/.nvmrc  →  v18
project-b/.nvmrc  →  v22
```

When you `cd` into a project directory, fnm reads `.nvmrc` or `.node-version` and automatically switches to the pinned version.

### The Three Version Managers

| Tool | Speed | Auto-switch | Install |
|------|-------|------------|---------|
| fnm | Fast (Rust) | Yes | `curl \| bash` |
| nvm | Slow (bash) | Yes | `curl \| bash` |
| Volta | Fast (Rust) | Yes | `curl \| bash` |

This curriculum uses fnm. All three are functionally equivalent for daily use.

## Build It

### Step 1: Install fnm and set up auto-switching

If you completed Lesson 01, fnm is already installed. Add auto-switching to your `~/.zshrc`:

```bash
eval "$(fnm env --use-on-cd)"
```

Now, whenever you `cd` into a project with a `.nvmrc` file, fnm automatically uses the correct Node version.

### Step 2: Install the LTS version

```bash
fnm install --lts
fnm list
```

`fnm list` shows every Node version installed on your machine.

### Step 3: Pin a version with .nvmrc

Inside your project folder, create `.nvmrc`:

```
22
```

That single number (major version only) tells fnm to use the latest Node 22. Commit this file.

Now test auto-switching:
```bash
cd /tmp && node --version   # shows default version
cd ~/my-first-app && node --version   # shows v22.x
```

### Step 4: Add an engines field to package.json

The `.nvmrc` tells fnm which Node to use. The `engines` field tells npm/pnpm to fail the install if the wrong version is used:

```json
{
  "engines": {
    "node": ">=22.0.0",
    "pnpm": ">=9.0.0"
  }
}
```

Enable engine enforcement in `.npmrc`:
```ini
engine-strict=true
```

Now `pnpm install` fails immediately on the wrong Node version instead of silently producing a broken `node_modules`.

### Step 5: Install a second Node version and switch

```bash
fnm install 20
fnm use 20
node --version   # v20.x

fnm use 22
node --version   # v22.x
```

### Step 6: Set a global default

```bash
fnm default 22
```

New terminal tabs now start with Node 22. Projects with a `.nvmrc` still auto-switch to their pinned version.

## Use It

Volta takes a different approach: it pins Node and pnpm versions inside `package.json` rather than in a separate `.nvmrc` file, which means there is one less file to maintain:

```json
{
  "volta": {
    "node": "22.3.0",
    "pnpm": "9.1.0"
  }
}
```

`create-next-app` sets `"engines"` in `package.json` automatically. Reading that field tells you what Node version the project maintainers tested on — always check it before starting on a new codebase.

## Ship It

A **`.nvmrc` + `.npmrc` pair** committed to every project:

`.nvmrc`:
```
22
```

`.npmrc`:
```ini
engine-strict=true
```

These two files together pin the Node version and enforce it on install. Add them to your project template now.

## Exercises

1. Install two Node versions (18 and 22). Create two folders, each with a different `.nvmrc`. `cd` between them and verify `node --version` auto-switches.

2. Add `"engines": { "node": ">=22.0.0" }` to a project's `package.json` and `engine-strict=true` to `.npmrc`. Switch to Node 18 with `fnm use 18`. Run `pnpm install`. What error do you get?

3. Look up what changed between Node 18 and Node 22 on the [Node.js changelog](https://github.com/nodejs/node/blob/main/CHANGELOG.md). Find one change that could affect a frontend project's build tools. Write a one-sentence explanation of it.

## Key Terms

| Term | Common Misconception | What It Actually Means |
|------|---------------------|------------------------|
| **LTS** | "An older, slower version" | Long-Term Support — the version recommended for production, maintained for 30 months |
| **Version manager** | "Just for switching Node versions" | A tool that installs multiple runtimes and controls which one is active per directory |
| **.nvmrc** | "A file only nvm reads" | A plain text file with a Node version — read by nvm, fnm, and Volta for auto-switching |
| **engines field** | "Documentation in package.json" | A declaration that pnpm/npm enforces when `engine-strict=true` — fails install on wrong version |
| **Current release** | "The latest and therefore the best" | The bleeding-edge release with new features but shorter support — not suitable for team projects |

## Further Reading

- [Node.js release schedule](https://nodejs.org/en/about/releases/) — LTS dates and end-of-life timeline
- [fnm documentation](https://github.com/Schniz/fnm) — installation, commands, and auto-switching setup
- [Volta docs](https://docs.volta.sh/) — alternative version manager with package.json integration
- [Node.js changelog](https://github.com/nodejs/node/blob/main/CHANGELOG.md) — what changed between versions
