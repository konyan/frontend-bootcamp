# Modern Development Environment

> A professional developer's machine is a precision instrument — every tool chosen deliberately, every version pinned, every layer understood.

**Type:** Learn
**Languages:** JavaScript, Shell
**Prerequisites:** None
**Time:** ~45 minutes

## Learning Objectives

- Understand the four-layer frontend development stack and what belongs in each layer
- Install and verify Node.js, pnpm, and VS Code
- Create and run your first JavaScript project from the command line
- Distinguish between global tools and project-local tools

## The Problem

Two students start building the same React app. One finishes in a weekend with clean, fast workflows. The other spends half their time debugging why their code works differently on their machine than on their teammate's, why their editor shows no errors even though the build fails, and why the setup tutorial they followed broke halfway through.

The difference is not talent — it is environment. A frontend project involves at least four layers of tools: shell, runtime, editor, and project config. When any layer is missing or misconfigured, the failure shows up somewhere unexpected. Understanding the full stack as a map prevents an entire category of confusion before it starts.

## The Concept

The modern frontend development stack has four layers. Each has a clear job:

```
┌─────────────────────────────────────────────┐
│  Layer 4: Project Config                    │
│  package.json, tsconfig.json, vite.config   │
│  Controls how your specific project builds  │
├─────────────────────────────────────────────┤
│  Layer 3: Editor (VS Code)                  │
│  Language server, linter, formatter         │
│  Gives feedback while you type              │
├─────────────────────────────────────────────┤
│  Layer 2: Runtime (Node.js)                 │
│  Executes JavaScript outside the browser    │
│  Powers build tools and the package manager │
├─────────────────────────────────────────────┤
│  Layer 1: Shell (Terminal)                  │
│  bash / zsh                                 │
│  The command interface for everything above │
└─────────────────────────────────────────────┘
```

**Why each layer matters:**

| Layer | What breaks without it |
|-------|------------------------|
| Shell | Cannot run any commands |
| Node.js | Cannot install packages or run build tools |
| Editor | No feedback while coding; errors only visible at build time |
| Project config | Build behaves differently per machine |

**Global vs local tools:**

Some tools are installed globally — once per machine: Node, pnpm, VS Code.
Others are installed locally — once per project: React, Vite, TypeScript.

Global tools do not belong in `package.json`. Project tools do not belong in global installs. Mixing them is the most common source of "works on my machine" bugs.

## Build It

### Step 1: Install Node.js via fnm

Use a version manager instead of the direct Node installer — it lets you switch versions per project.

Install fnm (Fast Node Manager):
```bash
curl -fsSL https://fnm.vercel.app/install | bash
```

Restart your terminal, then install the latest LTS:
```bash
fnm install --lts
fnm use lts-latest
node --version
```

### Step 2: Install pnpm

pnpm is the package manager used throughout this curriculum. It is faster and uses less disk space than npm.

```bash
npm install -g pnpm
pnpm --version
```

### Step 3: Install VS Code

Download from [code.visualstudio.com](https://code.visualstudio.com/). After installing, enable the `code` terminal command:

`Cmd+Shift+P` → type "Shell Command: Install 'code' command in PATH" → Enter.

Verify:
```bash
code --version
```

### Step 4: Create your first project

```bash
mkdir my-first-app
cd my-first-app
pnpm init
```

This creates `package.json` — the Layer 4 config file for your project.

### Step 5: Add a dependency and run code

```bash
pnpm add -D typescript
```

Create `hello.ts`:
```typescript
const greet = (name: string): string => `Hello, ${name}!`
console.log(greet("world"))
```

Run it:
```bash
node --experimental-strip-types hello.ts
```

### Step 6: Verify the full stack

Run the verification script from `code/verify.sh` to confirm all four layers are operational:
```bash
bash code/verify.sh
```

All checks passing means your environment is ready for the remaining lessons.

## Use It

`create-vite` scaffolds a full app with all four layers pre-configured — bundler, TypeScript, and React wired together:

```bash
pnpm create vite my-app --template react-ts
```

The generated `package.json`, `tsconfig.json`, and `vite.config.ts` are the Layer 4 config files you will learn to write from scratch in Lessons 09-12. Understanding what each file does now makes that work straightforward rather than overwhelming.

## Ship It

A **new-machine setup script** — a shell file you can run on any fresh machine to install all four layers in under five minutes. Start it now in `outputs/new-machine-setup.sh` and add to it as you complete each lesson in this phase.

## Exercises

1. Run `node --version`, `pnpm --version`, and `code --version`. Look up the current LTS release on [nodejs.org/en/about/releases](https://nodejs.org/en/about/releases/). Are you on LTS? If not, run `fnm install --lts && fnm use lts-latest`.

2. Open VS Code with `code .` inside `my-first-app`. Find `package.json` in the Explorer. Identify which fields control the project name, version, and scripts.

3. Explain in your own words: why should React be installed with `pnpm add react` inside the project, while pnpm itself is installed globally? What would break if you reversed that?

## Key Terms

| Term | Common Misconception | What It Actually Means |
|------|---------------------|------------------------|
| **Node.js** | "The thing you need to run websites" | A JavaScript runtime for executing JS outside the browser — powers build tools, not the deployed app |
| **Package manager** | "npm and pnpm are the same" | A tool that downloads libraries from the npm registry — pnpm stores packages once globally, npm duplicates them per project |
| **Global install** | "Installing a tool everywhere is always fine" | A tool installed machine-wide, not in any project — only appropriate for dev utilities like pnpm or fnm |
| **Dev dependency** | "Same as a regular dependency" | A package needed only during development (build tools, linters) — not included in what users download |
| **Layer 4 config** | "Boilerplate to copy-paste" | Project-specific files (package.json, tsconfig.json) that tell every tool how to behave for this project |

## Further Reading

- [Node.js release schedule](https://nodejs.org/en/about/releases/) — understanding LTS vs current releases
- [fnm documentation](https://github.com/Schniz/fnm) — the version manager used in this curriculum
- [VS Code setup guide](https://code.visualstudio.com/docs/setup/mac) — official macOS setup instructions
- [A Modern Front-end Project Setup](https://medium.com/@mihirsanghavi/a-modern-front-end-project-setup-98e698c71aad) — the article that inspired this phase
