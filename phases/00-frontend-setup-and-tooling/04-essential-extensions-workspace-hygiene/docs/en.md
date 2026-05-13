# Essential Extensions & Workspace Hygiene

> The best workspace has only the tools the project needs — visible, consistent, and conflict-free.

**Type:** Build
**Languages:** TypeScript
**Prerequisites:** Lesson 03 — IDE Mastery with VS Code
**Time:** ~45 minutes

## The Problem

A new team member installs 30 extensions because "they might be useful." The project uses Prettier for formatting, but they also have the Beautify extension active. Both fire on save and fight each other — sometimes Prettier wins, sometimes Beautify, and the file never settles. One developer's editor formats with single quotes; another formats with double quotes because they each have different personal settings and no `.prettierrc` checked in.

A second problem: there is no `.vscode/extensions.json` in the repository. Every developer has a different extension set. Half the team has Tailwind CSS IntelliSense installed; the other half writes class names blind. Nobody knows which extensions the project actually requires, and onboarding a new developer means a half-hour of "which extensions do I need to install?" conversation.

A good workspace defines its tools clearly, avoids redundancy, and encodes the agreed style in config files that everyone gets when they clone.

## The Concept

Extensions fall into four categories. Understanding the category prevents conflicts:

| Category | Role | Examples |
|----------|------|---------|
| Formatter | Rewrites code style on save | Prettier, Biome |
| Linter | Flags code quality issues | ESLint, Biome |
| Language server | Provides IntelliSense, types | TypeScript, Tailwind CSS |
| Utility | Augments the editor UX | GitLens, Error Lens, Spell Checker |

**The golden rule:** only one formatter should own a file type. If Prettier is the formatter for `.ts` files, no other extension should also format `.ts` on save. Explicit per-language formatter settings prevent this.

```
project root
├── .vscode/
│   ├── extensions.json   ← tells VS Code which extensions to recommend
│   └── settings.json     ← workspace rules that override user settings
└── .prettierrc           ← style config committed to git, shared by everyone
```

`extensions.json` uses `"recommendations"` — VS Code prompts team members to install them, but does not force it. The style config files (`.prettierrc`, `eslint.config.js`) do the actual enforcement regardless of which extensions are installed.

## Build It

### Step 1: Install the recommended extensions

Open the Extensions panel, click the filter icon, choose "Show Recommended Extensions." Install everything in the list from `code/.vscode/extensions.json`. Verify each extension activates by checking the status bar when you open a `.ts` file.

### Step 2: Create `.prettierrc`

Drop this into your project root (same content as `code/.prettierrc`):

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100
}
```

Prettier reads this file automatically. Any developer who runs `prettier --write` gets identical output regardless of their editor settings.

### Step 3: Set Prettier as the only formatter

Use the workspace settings from `code/.vscode/settings.json`. The critical keys:

```json
{
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  },
  "prettier.requireConfig": true
}
```

`prettier.requireConfig: true` means Prettier refuses to format a file if there is no `.prettierrc` — it will not silently apply defaults.

### Step 4: Verify no conflicts

Open a `.ts` file, introduce a style violation (wrong quotes, missing semicolon), save. Confirm that exactly one formatter runs and the result matches `.prettierrc`. If you see the file "flicker" twice on save, a second formatter is active — find and disable it for TypeScript files.

## Use It

`create-next-app` with TypeScript scaffolds an `eslint.config.mjs` and expects Prettier to be configured separately. Larger projects use `prettier.config.js` (instead of `.prettierrc`) for dynamic configuration. The principle is the same: one source of truth for style, committed to git.

Biome is a newer alternative that bundles formatting and linting into a single tool — no Prettier + ESLint pair needed. For new projects this can simplify the extension setup, but the workspace hygiene pattern (one tool per role, config in git) is identical.

## Ship It

The `code/.vscode/extensions.json`, `code/.vscode/settings.json`, and `code/.prettierrc` files form a portable workspace baseline. Copy all three into any new frontend project before the first commit.

Save the extensions list somewhere you can retrieve it quickly — it is the fastest way to answer "what do I need to install?" for a new team member.

## Exercises

1. Add the "Import Cost" extension and observe bundle size hints as you import from `lodash` vs `lodash-es`.
2. Write a `.prettierignore` file that skips `dist/`, `node_modules/`, and `*.generated.ts` files.
3. Turn on `"prettier.requireConfig": true` in workspace settings, then remove `.prettierrc` and observe what Prettier does on save — then restore the file.

## Key Terms

| Term | What people say | What it actually means |
|------|----------------|----------------------|
| Formatter | "Prettier is a linter" | A tool that rewrites code layout — quotes, spacing, trailing commas — without checking logic |
| Linter | "ESLint formats my code" | A tool that flags code quality patterns (unused vars, missing deps array) — it does not reformat |
| Language server | "TypeScript extension" | A background process that provides IntelliSense, type errors, and go-to-definition across files |
| Extension recommendation | "Required extension" | A suggested list — VS Code prompts to install, but the developer can decline |
| Workspace hygiene | "Best practices" | Keeping extension count low, removing conflicts, and encoding shared rules in committed config files |

## Further Reading

- [Prettier docs](https://prettier.io/docs/en/index.html) — configuration options and editor integration
- [ESLint getting started](https://eslint.org/docs/latest/use/getting-started) — rule configuration and flat config format
- [VS Code Extension Marketplace](https://marketplace.visualstudio.com/vscode) — extension pages include the exact extension ID needed for `extensions.json`
