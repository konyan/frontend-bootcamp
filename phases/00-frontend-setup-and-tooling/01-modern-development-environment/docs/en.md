# The Modern Development Environment

> A clean frontend setup removes the friction of missing tools, inconsistent editor behavior, and mismatched runtime versions.

**Type:** Build
**Languages:** Shell
**Prerequisites:** None
**Time:** ~60 minutes

## The Problem

You clone a repo from a teammate. You run `pnpm install`. It fails with a Node version error. You switch Node versions, try again. Now ESLint is throwing parse errors it didn't throw on their machine. You open VS Code and the formatter doesn't run on save because the Prettier extension isn't installed or the workspace settings aren't committed. An hour later you haven't written a single line of feature code.

This isn't bad luck. It's the predictable result of an unconfigured environment. Every developer on a team brings their own shell, their own editor state, their own runtime versions — and without explicit configuration at each layer, the experience diverges silently over time.

The fix is to treat your environment as part of the project. Shell, runtime, editor, and project config are not personal preferences; they are infrastructure. When each layer is explicitly configured and version-controlled, a fresh clone just works.

## The Concept

The frontend development environment is a stack of four layers, each one configuring the layer above it.

```
+---------------------------+
|   Project Config          |  package.json, .eslintrc, prettier.config.js
+---------------------------+
|   Editor                  |  VS Code + .vscode/settings.json + extensions
+---------------------------+
|   Runtime                 |  Node.js version, pnpm version, global tools
+---------------------------+
|   Shell                   |  zsh/bash, PATH, dotfiles, aliases
+---------------------------+
```

The shell runs when your terminal opens. It sets PATH so your system can find `node`, `pnpm`, and `git`. The runtime layer is the specific version of Node installed and active. The editor layer is VS Code plus whatever workspace settings and extensions are present. The project config layer is the repo itself: linter rules, formatter config, `package.json` scripts.

Problems compound when layers are out of sync. The right approach is to pin versions explicitly and commit configuration at every layer. Then the environment is reproducible by anyone who clones the project.

## Build It

### Step 1: Verify core tools are installed

Open a terminal and run each command. Every one should print a version number without errors.

```bash
git --version
node --version
pnpm --version
code --version
```

If any command returns `command not found`:
- **git**: Install from [git-scm.com](https://git-scm.com) or via `brew install git`
- **node**: Install via [fnm](https://github.com/Schniz/fnm): `brew install fnm && fnm install 20`
- **pnpm**: `npm install -g pnpm` or `brew install pnpm`
- **code**: Open VS Code, press Cmd+Shift+P, run "Shell Command: Install 'code' command in PATH"

### Step 2: Run the verification script

The verification script checks all four tools and reports pass/fail with version output.

```bash
python3 phases/00-frontend-setup-and-tooling/01-modern-development-environment/code/verify.py
```

Expected output when everything is configured correctly:

```
=== Frontend Setup & Tooling Check ===

Core:
  [PASS] Git (git version 2.43.0)
  [PASS] Node.js (v20.11.0)
  [PASS] npm (10.2.4)
  [PASS] pnpm (8.15.1)

Result: 4/4 core checks passed
[INFO] VS Code CLI found

You're ready. Start with Phase 1.
```

Fix any `[FAIL]` lines before proceeding.

### Step 3: Create workspace settings for VS Code

Inside any frontend project, create `.vscode/settings.json` with the following content. Commit this file to git so every developer gets the same editor behavior.

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.tabSize": 2
}
```

`formatOnSave` runs Prettier every time you save a file. `defaultFormatter` ensures VS Code uses Prettier and not a built-in formatter or a conflicting extension.

### Step 4: Pin the Node version

Create a `.node-version` file in the root of your project. Tools like fnm and nvm read this file and automatically switch to the correct version when you enter the directory.

```bash
echo "20" > .node-version
```

Alternatively, create `.nvmrc` with the same content. Both formats are widely supported. Commit this file alongside `.vscode/settings.json`.

## Use It

When you run `pnpm create next-app@latest` or `pnpm create vite@latest`, the generated project already includes `.vscode/settings.json` and a `package.json#engines` field:

```json
{
  "engines": {
    "node": ">=18.0.0"
  }
}
```

The `engines` field documents the required Node version at the package level. Combined with a `.node-version` file and the `verify.py` script, you have three complementary layers enforcing consistency: the version manager pins the runtime, the script checks it, and `package.json` communicates it to any package manager that runs install.

The `.vscode/settings.json` approach is the same as what scaffolded projects use, but now you understand why each key is there rather than accepting it as boilerplate.

## Ship It

The `verify.py` script in `code/` is the reusable artifact from this lesson. Copy it into any new project and run it as the first onboarding step:

```bash
python3 code/verify.py
```

It checks Git, Node.js, npm, and pnpm, prints clear pass/fail output, and exits with code 1 if anything is missing. Point new teammates to it in your project README so environment setup is a single command, not a guessing game.

## Exercises

1. Run `verify.py` against your own machine. If any check fails, install the missing tool and re-run until all four pass.
2. Add `"editor.codeActionsOnSave": {"source.fixAll.eslint": "explicit"}` to your workspace settings. Open a JS file with a lint error and save it. Describe what changed and why this setting is more explicit than `true`.
3. Add a `package.json#engines` field to a project pinning Node to `>=20.0.0`. Then run `pnpm install` and observe whether pnpm warns you if your active Node version is older than the requirement.

## Key Terms

| Term | What people say | What it actually means |
|------|----------------|----------------------|
| Runtime | "What Node version are you on?" | The executing environment that interprets your code — here, a specific version of Node.js |
| Version manager | "Use fnm or nvm" | A tool that installs multiple Node versions and switches between them per project |
| Workspace settings | "It's in `.vscode`" | VS Code configuration scoped to one project folder, committed to git, overrides user settings |
| PATH | "It's not on my PATH" | An ordered list of directories the shell searches when you type a command name |

## Further Reading

- [Node.js Downloads](https://nodejs.org/en/download) — official release page; prefer the LTS line
- [fnm — Fast Node Manager](https://github.com/Schniz/fnm) — recommended version manager; reads `.node-version` automatically
- [VS Code: User and Workspace Settings](https://code.visualstudio.com/docs/getstarted/settings) — complete reference for the settings hierarchy
