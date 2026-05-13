# Node.js Runtimes & Version Management

> Pin the runtime version once, and never wonder why CI passes but local fails.

**Type:** Build
**Languages:** JavaScript
**Prerequisites:** Lesson 01 — The Modern Development Environment
**Time:** ~60 minutes

## The Problem

A developer clones a three-year-old project and runs `pnpm install`. It fails with a cryptic native module compilation error. After 30 minutes of debugging they discover the project requires Node 16, but their global Node is 20. A teammate has Node 18. The CI pipeline runs Node 22. No one pinned a version. Every environment is slightly different, and bugs appear on one machine but not another with no obvious explanation.

A second scenario: two projects live on the same laptop. Project A requires Node 16 for legacy reasons; Project B requires Node 20 for `fetch` built-in and modern crypto APIs. Switching between them means remembering to run `nvm use 16` or `nvm use 20` every time — and forgetting causes silent breakage.

Version managers solve both problems: they let you install multiple Node versions and switch between them per project, and pin files (`.nvmrc`, `.node-version`) tell the manager which version a project expects.

## The Concept

**The Node.js release cycle:**

```
Current  →  Active LTS  →  Maintenance LTS  →  End of Life
  (new features)  (stable)      (security only)     (drop it)
```

Even-numbered releases become LTS. Odd-numbered releases (19, 21) reach end of life after six months. For production apps, always pick an LTS version.

**Runtime options:**

| Runtime | Notes |
|---------|-------|
| Node.js | The standard. Use this unless you have a specific reason not to. |
| Bun | Fast, built-in bundler/test runner — not yet a drop-in replacement for all Node APIs |
| Deno | Different module system, good for scripts and edge functions |

**Version managers:**

| Tool | Install speed | Auto-switch | Config file |
|------|-------------|------------|-------------|
| fnm | Very fast (Rust) | With shell hook | `.node-version` or `.nvmrc` |
| nvm | Slow (bash) | Manual `nvm use` | `.nvmrc` |
| Volta | Fast (Rust) | Automatic on `cd` | `package.json#volta` |

**Pin files:** `.nvmrc` (widely supported) or `.node-version` (fnm default). Both contain just a version number. Commit the file to git so every developer and CI gets the same version.

## Build It

### Step 1: Install fnm

On macOS with Homebrew:
```bash
brew install fnm
```

Or with the install script (macOS and Linux):
```bash
curl -fsSL https://fnm.vercel.app/install | bash
```

Add the shell hook to `~/.zshrc` (fnm prints the exact line during install):
```bash
eval "$(fnm env --use-on-cd)"
```

Reload the shell: `source ~/.zshrc`

### Step 2: Install and use Node 20

```bash
fnm install 20
fnm use 20
node --version
```

### Step 3: Pin the version in a project

In the project root:
```bash
echo "20" > .nvmrc
```

With `--use-on-cd` in the shell hook, fnm switches to the pinned version automatically when you `cd` into the directory.

### Step 4: Add the engines field to package.json

The `engines` field in `package.json` makes pnpm enforce the constraint at install time:

```json
{
  "engines": {
    "node": ">=20.0.0",
    "pnpm": ">=9.0.0"
  }
}
```

Enable the enforcement in `.npmrc`:
```
engine-strict=true
```

### Step 5: Verify with the check script

```bash
bash code/verify-node.sh
```

The script reads the current Node version and exits with an error if it is below the required major version.

## Use It

Volta takes a different approach — it reads `package.json#volta` and switches Node versions automatically when you `cd`, without any shell hook:

```json
{
  "volta": {
    "node": "20.11.0",
    "pnpm": "9.1.0"
  }
}
```

Volta pins the exact patch version (not just `>=20`), which is stricter. Teams that want guaranteed reproducibility between developer machines often prefer Volta for this reason.

## Ship It

Three files to commit to every project: `.nvmrc`, `package.json` with `engines`, and `verify-node.sh`. They document the runtime requirement, enforce it at install time, and give any developer a quick check command.

## Exercises

1. Install Node 18 alongside Node 20 with fnm (`fnm install 18`) and switch between them with `fnm use`.
2. Add `"volta": {"node": "20.0.0"}` to a `package.json` and explain what this does for a teammate who has Volta installed but not fnm.
3. Run `node --version` in a fresh terminal tab (without `cd`-ing into a project) and explain whether your version manager switches automatically or requires a manual command.

## Key Terms

| Term | What people say | What it actually means |
|------|----------------|----------------------|
| LTS | "The stable version" | Long-Term Support — even-numbered releases that receive security updates for 30 months |
| Version manager | "nvm" | A tool that installs multiple Node versions and lets you switch between them |
| Runtime | "Node" | The environment that executes JavaScript outside the browser |
| .nvmrc | "The Node config file" | A plain text file containing a version number — read by fnm, nvm, and many CI tools |
| engines field | "Locks the Node version" | A `package.json` field that declares version requirements — pnpm enforces it with `engine-strict=true` |

## Further Reading

- [fnm GitHub repo](https://github.com/Schniz/fnm) — installation and shell hook setup
- [Node.js release schedule](https://nodejs.org/en/about/previous-releases) — LTS dates and EOL calendar
- [Volta docs](https://docs.volta.sh/guide/) — alternative version manager with automatic switching
