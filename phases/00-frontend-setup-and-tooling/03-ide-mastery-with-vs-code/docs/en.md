# IDE Mastery with VS Code

> A default editor leaves a lot of friction on the table. Frontend work gets easier when the editor helps you make fewer mistakes sooner.

**Type:** Build
**Languages:** TypeScript
**Prerequisites:** Lesson 01
**Time:** ~60 minutes

## The Problem

A developer opens a shared project and the formatter runs on save for them but not for their teammate. They spend ten minutes debugging before discovering the teammate's VS Code has a different default formatter set in their user settings, and the project has no `.vscode/settings.json` to override it. Meanwhile ESLint is running twice on every file because two extensions both registered themselves as the TypeScript language provider and neither knows about the other.

These are not editor bugs. They are configuration gaps. VS Code gives every developer a blank slate by default, and blank slates diverge. The fix is to commit a workspace settings file that makes the editor behavior part of the project, the same way `package.json` makes the dependencies part of the project. Then there is one canonical configuration and every clone gets it automatically.

## The Concept

VS Code applies settings in a hierarchy. Lower levels override higher ones:

```
Default Settings         (VS Code built-ins, lowest priority)
        |
        v
User Settings            (~/.config/Code/User/settings.json)
        |
        v
Workspace Settings       (.vscode/settings.json in the repo, highest priority)
```

User settings are your personal defaults across every project. Workspace settings are scoped to the open folder and committed to git. When both define the same key, the workspace setting wins.

Extensions have an activation model separate from settings. An extension declares in its `package.json` which file types or language IDs it handles. When VS Code opens a file of that type, it activates the matching extensions. If two extensions both handle `typescript`, you may get duplicate diagnostics, conflicting formatters, or double-running linters. The workspace settings `editor.defaultFormatter` and `editor.codeActionsOnSave` make the intended extension explicit so there is no ambiguity.

```
.vscode/settings.json  <-- committed to git, applies to all developers
~/.config/Code/User/settings.json  <-- personal, not committed
VS Code defaults  <-- apply when neither file says anything
```

## Build It

### Step 1: Open workspace settings

Press Cmd+Shift+P (macOS) or Ctrl+Shift+P (Windows/Linux) to open the command palette. Type "workspace settings json" and select "Preferences: Open Workspace Settings (JSON)".

VS Code creates `.vscode/settings.json` in the project root if it does not exist and opens it. This is the file you will commit to the repository.

### Step 2: Add the settings from code/.vscode/settings.json

Paste the full settings object. Walk through each key:

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.tabSize": 2,
  "editor.rulers": [100],
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  },
  "typescript.preferences.importModuleSpecifier": "non-relative",
  "typescript.updateImportsOnFileMove.enabled": "always",
  "files.exclude": {
    "node_modules": true,
    ".next": true,
    "dist": true
  },
  "search.exclude": {
    "node_modules": true,
    "pnpm-lock.yaml": true
  },
  "explorer.fileNesting.enabled": true,
  "explorer.fileNesting.patterns": {
    "*.ts": "${capture}.js, ${capture}.d.ts",
    "tsconfig.json": "tsconfig.*.json"
  }
}
```

Key explanations:
- `editor.formatOnSave` + `editor.defaultFormatter`: runs Prettier on every save, using only the Prettier extension (not any other)
- `editor.rulers`: draws a vertical guide at column 100, a common line-length limit for TypeScript projects
- `editor.codeActionsOnSave` with `"explicit"`: runs ESLint auto-fixes on save, but only fixes that ESLint is confident about (not experimental ones)
- `typescript.preferences.importModuleSpecifier`: generates `import { foo } from "@/components/Foo"` instead of `../../components/Foo` when using path aliases
- `files.exclude` + `search.exclude`: hides generated directories from the file explorer and search results, reducing noise
- `explorer.fileNesting.patterns`: nests `.d.ts` and compiled `.js` files under their `.ts` source in the explorer

### Step 3: Bind two keyboard shortcuts

Press Cmd+K, Cmd+S to open the keybindings editor. Two shortcuts to add or confirm:

- **Toggle terminal**: Ctrl+` (backtick) — opens and closes the integrated terminal without leaving the keyboard
- **Toggle sidebar**: Cmd+B (macOS) / Ctrl+B (Windows/Linux) — gives the editor the full width when you need to focus on code

These are VS Code defaults. Confirming they work is faster than discovering they are remapped when you need them.

### Step 4: Practice command palette navigation

The command palette (Cmd+Shift+P) runs any VS Code command by name. Muscle memory for these two removes the need to touch the mouse for the most common navigations:

- **Go to Symbol in File** (Cmd+Shift+O): lists every function, class, and variable in the current file. Type to filter. This is how you navigate a 300-line file without scrolling.
- **Go to Definition** (F12 or Cmd+click): jumps to where a function or type is defined, even if it is in `node_modules`. Essential for understanding third-party APIs.

Open a TypeScript file in any project and practice jumping between symbols with Cmd+Shift+O, then navigate back with Ctrl+- (go back).

## Use It

Two extensions layer on top of workspace settings to surface TypeScript errors more visibly:

**Error Lens** (`usernamehw.errorlens`): displays the diagnostic message inline on the line where the error occurs, rather than requiring you to hover over the red underline. TypeScript errors become impossible to miss.

**Pretty TypeScript Errors** (`yoavbls.pretty-ts-errors`): reformats the cryptic multi-line TypeScript error messages into structured, readable output. The same error that used to require ten seconds of parsing becomes immediately clear.

Install both from the Extensions sidebar (Cmd+Shift+X). They read the existing TypeScript language server output and add no new configuration. Commit their extension IDs to `.vscode/extensions.json` so VS Code recommends them to anyone who clones the project:

```json
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "usernamehw.errorlens",
    "yoavbls.pretty-ts-errors"
  ]
}
```

## Ship It

The `.vscode/settings.json` file in `code/` is the reusable artifact from this lesson. Copy it into the root `.vscode/` of every frontend project you start and commit it. Pair it with `.vscode/extensions.json` listing recommended extensions.

A developer cloning the project for the first time will see a VS Code notification: "This workspace has extension recommendations." One click installs all of them. Combined with the settings file, the editor experience is consistent from the first open.

## Exercises

1. Add `"editor.linkedEditing": true` to your workspace settings. Open an HTML file, click on an opening tag, and rename it. Observe what happens to the closing tag and explain why this setting matters for HTML/JSX editing.
2. Install the "Error Lens" extension. Open a TypeScript file and intentionally introduce a type error (assign a string to a number variable). Describe what changed in how the error is displayed compared to the default behavior.
3. Open two related frontend projects in one multi-root workspace. Create a `.code-workspace` file that includes both folders and observe how VS Code handles settings scope across roots.

## Key Terms

| Term | What people say | What it actually means |
|------|----------------|----------------------|
| Workspace settings | "Add it to the workspace settings" | VS Code configuration in `.vscode/settings.json`, scoped to one project and committed to git |
| User settings | "Check your user settings" | Personal VS Code configuration at `~/.config/Code/User/settings.json`, applies globally across all projects |
| Command palette | "Use the command palette" | The Cmd+Shift+P overlay that runs any VS Code command by name |
| Multi-root workspace | "Open it as a workspace" | A VS Code session with multiple top-level folders, defined by a `.code-workspace` file |
| Extension activation | "The extension isn't activating" | The process by which VS Code loads an extension when a matching file type or condition is detected |

## Further Reading

- [VS Code: User and Workspace Settings](https://code.visualstudio.com/docs/getstarted/settings) — complete reference for the settings hierarchy and all available keys
- [VS Code Keyboard Shortcuts Reference](https://code.visualstudio.com/docs/getstarted/keybindings) — the full default keybinding list for macOS, Windows, and Linux
