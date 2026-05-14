# IDE Mastery with VS Code

> An editor that understands your code catches bugs before you run anything.

**Type:** Learn
**Languages:** JavaScript, TypeScript
**Prerequisites:** Lesson 01 — Modern Development Environment
**Time:** ~45 minutes

## Learning Objectives

- Distinguish between user settings and workspace settings and know when to use each
- Use the command palette and core keyboard shortcuts to navigate without the mouse
- Configure VS Code to show TypeScript errors, format on save, and highlight problems inline
- Understand how the language server gives VS Code its code intelligence

## The Problem

A student opens VS Code and types `const x = null; x.toUpperCase()`. Nothing looks wrong — no red underline, no warning. They run the code and get `TypeError: Cannot read properties of null`. The editor gave no signal.

Their mentor's editor shows a red squiggle the moment the mistake is typed, with the exact error message and a suggested fix. The mentor has not run anything yet.

The difference is configuration. VS Code ships as a general-purpose text editor. To become a real IDE — a tool that understands your code — it needs a language server enabled, the right settings applied, and a formatter configured. This lesson shows exactly how to set that up.

## The Concept

### How VS Code Understands Code

VS Code uses the Language Server Protocol (LSP) to connect the editor to language analysis tools:

```
You type code
      ↓
VS Code sends text to the TypeScript Language Server
      ↓
Language Server analyzes: types, imports, unused variables
      ↓
VS Code displays: red squiggles, hover docs, autocomplete
```

The TypeScript language server is built into VS Code. For other languages, an extension ships its own language server.

### Settings Hierarchy

VS Code has two levels of settings that stack:

```
User Settings    (~/.config/Code/User/settings.json)
      ↓ overridden by
Workspace Settings  (.vscode/settings.json in the project)
```

User settings apply to every project. Workspace settings apply only to the current project and override user settings. Commit `.vscode/settings.json` to git so the whole team uses the same editor config.

### The Five Shortcuts You Need First

| Shortcut | Action |
|----------|--------|
| `Cmd+Shift+P` | Command Palette — run any VS Code command by name |
| `Cmd+P` | Quick Open — jump to any file by name |
| `Cmd+click` | Go to definition |
| `Shift+F12` | Find all references to this symbol |
| `Cmd+Shift+F` | Search across all files |

## Build It

### Step 1: Open User Settings as JSON

`Cmd+Shift+P` → type "Open User Settings JSON" → Enter.

Add these foundational settings:

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.tabSize": 2,
  "editor.minimap.enabled": false,
  "editor.rulers": [80, 120],
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "explorer.confirmDelete": false,
  "terminal.integrated.defaultProfile.osx": "zsh"
}
```

### Step 2: Enable TypeScript inline feedback

Add these to your user settings for real-time type checking:

```json
{
  "typescript.suggest.completeFunctionCalls": true,
  "typescript.inlayHints.parameterNames.enabled": "literals",
  "typescript.inlayHints.variableTypes.enabled": true,
  "javascript.suggest.autoImports": true
}
```

### Step 3: Create a workspace settings file

Inside any project folder, create `.vscode/settings.json`:

```json
{
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.tabSize": 2,
  "[markdown]": {
    "editor.wordWrap": "on",
    "editor.rulers": []
  }
}
```

The `[markdown]` key applies settings only to Markdown files — per-language overrides work for any language identifier.

### Step 4: Practice the five navigation shortcuts

Open a project and navigate only with shortcuts for five minutes — no mouse, no Explorer panel clicks:

- `Cmd+P` to jump between files
- `Cmd+click` to follow a function to its definition
- `Shift+F12` to see everywhere a function is called
- `Cmd+Shift+O` to jump to a symbol (function/variable) within the current file
- `Cmd+Shift+P` → "Go to Line" to jump to a specific line number

### Step 5: Configure the integrated terminal

Use VS Code's built-in terminal instead of switching applications:

- Open: `` Cmd+` ``
- New terminal: `Cmd+Shift+5`
- Split: `Cmd+\`

Add to user settings:
```json
{
  "terminal.integrated.fontSize": 13,
  "terminal.integrated.lineHeight": 1.2
}
```

### Step 6: Verify error detection works

Create `test-errors.ts` in any project with a tsconfig.json:
```typescript
const user = null
console.log(user.name)
```

If VS Code is configured correctly, `user.name` shows a red squiggle immediately with the message "Object is possibly 'null'". If it does not, check that the TypeScript extension is active in the Extensions panel.

## Use It

VS Code Remote Development lets the editor UI run locally while the code and terminal run on a remote server or Docker container. The extensions `Remote - SSH` and `Dev Containers` enable this. Your shortcuts and settings work identically — only the filesystem changes. Teams use this to give every developer an identical Linux environment regardless of their local OS.

## Ship It

A **`.vscode/` folder** committed to every project with:
- `settings.json` — project-specific editor config
- `extensions.json` — recommended extensions (covered in Lesson 04)

When a teammate opens the project, VS Code reads these automatically. Add this pattern to your project template.

## Exercises

1. Open a `.js` file and type `const x = null; x.length`. Hover over `.length`. What does VS Code show? Rename the file to `.ts` — does the behavior change, and why?

2. Use `Cmd+P` to navigate between three files without touching the Explorer sidebar. Then use `Cmd+Shift+O` to jump to a specific function by name within a file.

3. Add `.vscode/settings.json` with `"editor.tabSize": 4` to a project. Verify it overrides your user setting of `2` only inside that project by checking the tab size indicator in the VS Code status bar.

## Key Terms

| Term | Common Misconception | What It Actually Means |
|------|---------------------|------------------------|
| **Language Server** | "The plugin that adds syntax colors" | A separate process that analyzes types, imports, and references — communicates with the editor via LSP |
| **User settings** | "The only settings file" | Settings stored in your home directory that apply globally to all projects |
| **Workspace settings** | "Optional extras" | Per-project overrides in `.vscode/settings.json` — committed to git so the whole team shares them |
| **Format on save** | "The editor auto-fixing my code" | Running the configured formatter (Prettier) every time a file is saved |
| **Command Palette** | "The search bar" | A command runner that executes any VS Code action by name — faster than any menu |

## Further Reading

- [VS Code keyboard shortcuts (macOS)](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf) — printable shortcut reference
- [VS Code settings reference](https://code.visualstudio.com/docs/getstarted/settings) — every available setting documented
- [Language Server Protocol](https://microsoft.github.io/language-server-protocol/) — the protocol that powers editor intelligence
- [VS Code Tips and Tricks](https://code.visualstudio.com/docs/getstarted/tips-and-tricks) — official productivity techniques
