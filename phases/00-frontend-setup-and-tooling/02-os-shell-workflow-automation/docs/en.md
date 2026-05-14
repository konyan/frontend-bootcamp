# OS, Shell & Workflow Automation

> The terminal is not a last resort — it is the fastest interface between thought and action.

**Type:** Learn
**Languages:** Shell
**Prerequisites:** Lesson 01 — Modern Development Environment
**Time:** ~60 minutes

## Learning Objectives

- Understand how the shell startup file works and what PATH controls
- Create aliases and shell functions that eliminate repetitive typing
- Navigate directories faster using keyboard shortcuts and zoxide
- Install Starship to show git branch and Node version in the prompt automatically

## The Problem

A junior developer spends 30 seconds every time they switch projects: `cd Desktop`, `cd projects`, `cd my-app`, `ls` to remember the folder name, `cd src`, then finally run a command. Multiply by 50 context switches per day and they lose 25 minutes to navigation alone.

They type `git status` hundreds of times a day. They open new terminal tabs and retype the last ten commands because they forgot what they ran. They cannot tell which git branch they are on or which Node version is active without running a separate command.

The shell is programmable. Every repeated action in the terminal can be automated into a two-letter alias or a function that runs in milliseconds.

## The Concept

### The Shell Startup File

When a terminal opens, the shell reads a config file before showing the prompt. On macOS with zsh, this file is `~/.zshrc`.

```
Terminal opens
      ↓
~/.zshrc is read top to bottom
      ↓
Aliases, functions, and PATH changes take effect
      ↓
Prompt appears, ready for input
```

Every change to `~/.zshrc` requires a reload:
```bash
source ~/.zshrc
```

### PATH: Where the Shell Finds Commands

When you type `node`, the shell searches a list of directories for an executable named `node`. That list is the `PATH` variable:

```bash
echo $PATH
# /usr/local/bin:/usr/bin:/bin:/home/you/.local/bin
```

When fnm installs Node, it adds its directory to PATH. If a command is "not found," the tool's directory is missing from PATH.

### Aliases vs Shell Functions

| | Alias | Function |
|---|-------|---------|
| Use for | Shortening a fixed command | Commands with logic or arguments |
| Syntax | `alias gs="git status"` | `mkcd() { mkdir "$1" && cd "$1"; }` |
| Accepts arguments | No | Yes |

## Build It

### Step 1: Open your ~/.zshrc

```bash
code ~/.zshrc
```

VS Code creates the file if it does not exist.

### Step 2: Add git aliases

Append to your `~/.zshrc`:

```bash
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline --graph --decorate --all"
alias gco="git checkout"
alias gcb="git checkout -b"
```

Reload: `source ~/.zshrc`. Now `gs` does what `git status` did.

### Step 3: Add navigation aliases

```bash
alias ..="cd .."
alias ...="cd ../.."
alias ll="ls -lah"
alias la="ls -A"
```

### Step 4: Create shell functions

Functions accept arguments. Add these to `~/.zshrc`:

```bash
mkcd() {
  mkdir -p "$1" && cd "$1"
}

port() {
  lsof -i :"$1"
}
```

`mkcd my-project` creates the folder and enters it in one step.
`port 3000` shows what process is using port 3000.

### Step 5: Install zoxide for smart navigation

zoxide learns which directories you visit most and lets you jump to them instantly:

```bash
brew install zoxide
```

Add to `~/.zshrc`:
```bash
eval "$(zoxide init zsh)"
```

After visiting a directory a few times, `z my-app` jumps there from anywhere on the machine.

### Step 6: Install Starship prompt

Starship shows git branch, Node version, and current directory in the prompt automatically — no commands needed:

```bash
brew install starship
```

Add at the very end of `~/.zshrc`:
```bash
eval "$(starship init zsh)"
```

Reload your terminal. Your prompt now shows the active git branch and Node version at all times.

## Use It

Large projects wrap common operations in `scripts/` shell files. Instead of remembering `pnpm run lint && pnpm run typecheck && pnpm run build`, a `./scripts/check.sh` runs the whole sequence. The principle is identical to your aliases: name the thing, call the name. Lesson 12 builds this into a `build-check.sh` for your deploy workflow.

## Ship It

A **dotfiles repository** — a git repo at `~/dotfiles/` containing your `~/.zshrc`, `~/.gitconfig`, and any other shell configs. When you get a new machine, clone the repo and run a setup script. Every professional developer maintains one.

Start now:
```bash
mkdir ~/dotfiles
cp ~/.zshrc ~/dotfiles/.zshrc
ln -sf ~/dotfiles/.zshrc ~/.zshrc
cd ~/dotfiles && git init && git add . && git commit -m "init: dotfiles"
```

## Exercises

1. Add an alias `cdp` that navigates to your main projects folder. Open a new terminal tab and confirm it works. Why does it require a new tab (or `source ~/.zshrc`) after editing?

2. Write a shell function `newapp` that takes a project name, runs `pnpm create vite $1 --template react-ts`, then enters the new folder. Test it.

3. Run `echo $PATH` and find which directory fnm added. Temporarily break PATH: `export PATH=/usr/bin:/bin`. Try running `node`. What error appears? Open a new terminal tab and explain why it recovered.

## Key Terms

| Term | Common Misconception | What It Actually Means |
|------|---------------------|------------------------|
| **Shell** | "The black window hackers use" | A program that interprets text commands — zsh on macOS, bash on most Linux |
| **~/.zshrc** | "A config file I should not touch" | A script that runs on every terminal open — your personal automation center |
| **PATH** | "An OS environment variable, not my concern" | A colon-separated list of directories the shell searches when you type a command name |
| **Alias** | "A shortcut" | A named substitution — cannot accept arguments, replaced verbatim |
| **Shell function** | "An alias with extra steps" | A reusable named block that accepts arguments and can contain logic |
| **dotfiles** | "Hidden config files" | Configuration files starting with `.`, typically version-controlled in `~/dotfiles` |

## Further Reading

- [Zsh guide](https://zsh.sourceforge.io/Guide/) — complete reference for zsh configuration
- [zoxide](https://github.com/ajeetdsouza/zoxide) — the smarter cd replacement
- [Starship prompt](https://starship.rs/) — cross-shell prompt with git and runtime info
- [GitHub dotfiles](https://dotfiles.github.io/) — community dotfile repos and inspiration
