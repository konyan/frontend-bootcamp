# Essential Extensions & Workspace Hygiene

> One formatter. One linter. Committed config files. Everything else is noise.

**Type:** Build
**Languages:** JavaScript, TypeScript
**Prerequisites:** Lesson 03 — IDE Mastery with VS Code
**Time:** ~45 minutes

## Learning Objectives

- Install the essential VS Code extensions for frontend development
- Configure Prettier as the single formatter and prevent ESLint conflicts
- Create `.prettierrc` and `.editorconfig` files that enforce consistent style
- Add `.vscode/extensions.json` so teammates install the correct extensions automatically

## The Problem

A team of four developers all use VS Code. One has Prettier installed. One has a different formatter called Beautify. Two have nothing. Every save rewrites the file slightly differently — different quote styles, different semicolons, different trailing commas. Every pull request has hundreds of diff lines that are pure whitespace noise, hiding the real changes.

The CI pipeline enforces ESLint. But ESLint also has formatting rules turned on, and they conflict with Prettier — both tools rewrite the same lines in opposite directions. Developers disable one, then the other, then give up and ignore all the warnings.

This chaos is entirely preventable. The rule is simple: one tool formats, one tool lints, and neither does the other's job.

## The Concept

### The Four Extension Categories

| Category | Job | Tool |
|----------|-----|------|
| Formatter | Makes code look consistent | Prettier |
| Linter | Finds bugs and bad patterns | ESLint |
| Language server | Type checking and autocomplete | TypeScript (built-in) |
| Utility | Git blame, error display, icons | GitLens, Error Lens |

**The golden rule:** one formatter only. If Prettier is configured, disable all ESLint formatting rules with `eslint-config-prettier`. ESLint catches bugs (`no-unused-vars`, `no-console`), not where semicolons go.

### Config File Hierarchy

```
Project root/
├── .prettierrc          ← Prettier formatting rules
├── eslint.config.js     ← ESLint bug-finding rules
├── .editorconfig        ← Editor-agnostic settings (indentation, line endings)
└── .vscode/
    ├── settings.json    ← VS Code settings for this project
    └── extensions.json  ← Recommended extensions for this project
```

`.editorconfig` is read by VS Code, JetBrains, Vim, and most other editors. It ensures teammates not using VS Code still get consistent indentation and line endings.

## Build It

### Step 1: Install the essential extensions

`Cmd+Shift+X` → search and install:

| Extension ID | What it does |
|-------------|-------------|
| `esbenp.prettier-vscode` | Prettier formatter integration |
| `dbaeumer.vscode-eslint` | ESLint inline error display |
| `usernamehw.errorlens` | Shows error messages inline next to the code |
| `eamodio.gitlens` | Git blame and history in the editor |
| `PKief.material-icon-theme` | File icons for easier project navigation |
| `christian-kohler.path-intellisense` | Autocomplete for import file paths |

### Step 2: Create `.prettierrc`

```json
{
  "semi": false,
  "singleQuote": true,
  "trailingComma": "es5",
  "tabWidth": 2,
  "printWidth": 100,
  "bracketSpacing": true,
  "arrowParens": "avoid"
}
```

The specific values matter less than having a committed file everyone follows. Prettier enforces whatever is in this file, so debates about style end here.

### Step 3: Create `.editorconfig`

```ini
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.md]
trim_trailing_whitespace = false
```

`end_of_line = lf` prevents Windows developers from committing CRLF line endings that cause noisy diffs on every line of every file.

### Step 4: Install and configure ESLint

```bash
pnpm add -D eslint @eslint/js eslint-config-prettier
```

Create `eslint.config.js`:

```js
import js from '@eslint/js'
import prettierConfig from 'eslint-config-prettier'

export default [
  js.configs.recommended,
  prettierConfig,
  {
    rules: {
      'no-unused-vars': 'warn',
      'no-console': 'warn',
    },
  },
]
```

`eslint-config-prettier` disables every ESLint rule that overlaps with Prettier. ESLint now only catches logic problems, never formatting.

### Step 5: Create `.vscode/extensions.json`

This file prompts teammates to install the recommended extensions when they open the project:

```json
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "usernamehw.errorlens",
    "eamodio.gitlens"
  ]
}
```

Commit this file. It documents exactly which extensions this project relies on.

### Step 6: Add format and lint scripts to package.json

```json
{
  "scripts": {
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "lint": "eslint ."
  }
}
```

`pnpm format` fixes all files. `pnpm format:check` exits with code 1 if any file is unformatted — use this in CI to enforce consistency.

## Use It

Biome is a newer tool that combines formatting and linting in a single Rust binary — 25x faster than Prettier + ESLint with a single config file. The principle is identical (one formatter, one linter), just fewer moving parts:

```bash
pnpm add -D @biomejs/biome
npx @biomejs/biome init
```

Whether you choose Prettier + ESLint or Biome, the key is that every developer uses the same tool, with the same config file checked into git.

## Ship It

A **workspace hygiene template**: the four files from this lesson (`.prettierrc`, `.editorconfig`, `eslint.config.js`, `.vscode/extensions.json`) checked into a template repository. Every new project starts by copying them. This is the baseline for consistent, reviewable code on any team.

## Exercises

1. Install Prettier and open a JavaScript file with mixed formatting (inconsistent quotes, varying spaces). Save with `"formatOnSave": true`. What changed? What did not change?

2. Add `console.log("debug")` to a file. Run `pnpm lint`. Verify ESLint warns about it. Run `pnpm format:check` — does Prettier care? Why or why not?

3. Look at a public open-source React project on GitHub. Find their `package.json`. Do they use Prettier? ESLint? Both? How do they prevent conflicts between the two?

## Key Terms

| Term | Common Misconception | What It Actually Means |
|------|---------------------|------------------------|
| **Formatter** | "Same job as a linter" | A tool that rewrites code layout (spacing, quotes, commas) without changing behavior |
| **Linter** | "Enforces style rules" | A tool that finds potential bugs and bad patterns — not responsible for visual formatting |
| **eslint-config-prettier** | "Disables ESLint" | Disables only the ESLint rules that overlap with what Prettier handles — ESLint still runs |
| **.editorconfig** | "A VS Code config file" | An editor-agnostic file read by VS Code, JetBrains, Vim, and others — works across all editors |
| **Workspace recommendations** | "Optional suggestions" | Extensions in `.vscode/extensions.json` that VS Code offers to install when anyone opens the project |

## Further Reading

- [Prettier docs: options](https://prettier.io/docs/en/options.html) — all formatting options with examples
- [ESLint getting started](https://eslint.org/docs/latest/use/getting-started) — configuration and rule reference
- [eslint-config-prettier](https://github.com/prettier/eslint-config-prettier) — why and how to disable conflicting rules
- [EditorConfig spec](https://editorconfig.org/) — all supported properties and editor compatibility
