# OS, Shell & Workflow Automation

> If every command feels longer than it should, your workflow stays slow no matter how good the framework is.

**Type:** Build
**Languages:** Shell
**Prerequisites:** Lesson 01
**Time:** ~60 minutes

## The Problem

A developer types `pnpm install` 40 times a day. They kill stuck dev servers by opening Activity Monitor, clicking through the process list, and force-quitting the right PID. They forget which Node version a project needs every time they switch repos and have to open `package.json` to check. Each of these is a small friction. But small friction repeated hundreds of times a day across months adds up to hours lost and a constant low-level sense of irritation that makes the work feel harder than it is.

The shell is configurable. Every repetitive command can become a two-letter alias. Every multi-step operation can become a function that accepts arguments. That configuration lives in a dotfiles repository and follows you across machines. This is not about being clever — it is about removing unnecessary cognitive load from the mechanical parts of the job so more attention is available for the actual work.

The setup takes one hour. The payback is permanent.

## The Concept

When you open a terminal, the shell executes a startup script before it gives you a prompt. On zsh (the default on macOS) that script is `~/.zshrc`. On bash it is `~/.bashrc` or `~/.bash_profile`. These files are sourced in a specific order depending on whether the shell is a login shell or an interactive shell.

```
Terminal opens
      |
      v
  ~/.zprofile   (login shell, run once at login)
      |
      v
  ~/.zshrc      (interactive shell, run each new tab)
      |
      |-- sources aliases.sh
      |-- sources functions.sh
      |-- sets PATH entries
      v
  prompt appears
```

PATH is a colon-separated list of directories. When you type `node`, the shell searches each directory in PATH from left to right and runs the first `node` binary it finds. This is why version managers prepend their directory: `~/.fnm/` appears before `/usr/local/bin/` so fnm's Node wins.

Aliases rename commands. They are simple text substitutions with no argument handling:

```bash
alias gs="git status"
```

Shell functions are small programs. They accept positional arguments (`$1`, `$2`, `"$@"`) and can contain logic:

```bash
mkcd() { mkdir -p "$1" && cd "$1"; }
```

The distinction matters: use an alias when you just want a shorter name, use a function when you need to handle arguments or run multiple steps.

## Build It

### Step 1: Open your shell startup file

Open `~/.zshrc` in VS Code:

```bash
code ~/.zshrc
```

If the file does not exist, VS Code will create it. Add a line at the bottom to source your aliases file once you create it. Using a separate file keeps `.zshrc` readable:

```bash
source ~/dotfiles/aliases.sh
source ~/dotfiles/functions.sh
```

For now, you can place the files anywhere. A `~/dotfiles/` directory is the conventional location.

### Step 2: Create the aliases file

Create `aliases.sh` with the content from `code/aliases.sh`. The file defines short names for the pnpm commands you will type most and three Git shortcuts.

```bash
#!/usr/bin/env bash

alias dev="pnpm dev"
alias build="pnpm build"
alias lint="pnpm lint"
alias fmt="pnpm format"
alias gs="git status"
alias gp="git push"
alias gl="git pull"

ni() { pnpm install "$@"; }
na() { pnpm add "$@"; }
nrm() { pnpm remove "$@"; }
```

`ni`, `na`, and `nrm` are functions rather than aliases because they forward arguments. `ni react` becomes `pnpm install react`. Aliases cannot do this.

### Step 3: Create the functions file

Create `functions.sh` with the content from `code/functions.sh`. Three functions cover the most common time-wasters:

```bash
#!/usr/bin/env bash

mkcd() { mkdir -p "$1" && cd "$1"; }

port-kill() {
    local port=$1
    lsof -ti :"$port" | xargs kill -9
}

node-version() {
    node --version
    pnpm --version
}
```

`mkcd` creates a directory and enters it in one step. `port-kill` kills whatever process is listening on a given port — useful when `pnpm dev` fails because port 3000 is already occupied. `node-version` prints both Node and pnpm versions for quick confirmation.

### Step 4: Reload the shell and test

Source your `.zshrc` to apply the changes without opening a new terminal tab:

```bash
source ~/.zshrc
```

Test each alias and function:

```bash
gs           # should run git status
node-version # should print node and pnpm versions
mkcd /tmp/test-dir && pwd  # should create the dir and print its path
port-kill 3000 # kills anything on port 3000; safe if nothing is running
```

If a command is not found, check that the `source` lines in `.zshrc` point to the correct file paths.

## Use It

The dotfiles pattern scales into a set of well-maintained tools:

- **zoxide** (`brew install zoxide`): a smarter `cd` that learns your most-visited directories. `z proj` jumps to your projects folder. It replaces `cd` entirely for navigation and works from any shell startup file.
- **fzf** (`brew install fzf`): fuzzy finder that integrates with shell history. Press Ctrl+R to search your command history interactively instead of scrolling. It also powers fuzzy file selection in many other tools.
- **starship** (`brew install starship`): a cross-shell prompt written in Rust. It reads your current directory, git branch, Node version, and active language version and displays them in the prompt. One config file works across zsh, bash, and fish.

All three follow the same dotfiles pattern: install the tool, add one line to `.zshrc`, and the behavior is active in every new terminal session.

## Ship It

The `aliases.sh` and `functions.sh` files in `code/` are the reusable artifacts from this lesson. Keep them in a personal dotfiles repository on GitHub (private is fine). On a new machine:

```bash
git clone git@github.com:yourname/dotfiles.git ~/dotfiles
echo "source ~/dotfiles/aliases.sh" >> ~/.zshrc
echo "source ~/dotfiles/functions.sh" >> ~/.zshrc
source ~/.zshrc
```

That is the entire setup. Your full workflow automation is available in under a minute on any machine.

## Exercises

1. Add a `gco` alias for `git checkout` to `aliases.sh`. Reload the shell and confirm it works.
2. Write a `new-fe` function that creates a directory with the name of its first argument, enters it, and runs `pnpm create vite@latest .` inside it. Test it by creating a throwaway project.
3. Create a private GitHub repository named `dotfiles`, push your `aliases.sh` and `functions.sh` files to it, and update your `.zshrc` to source them from `~/dotfiles/` after cloning.

## Key Terms

| Term | What people say | What it actually means |
|------|----------------|----------------------|
| Dotfiles | "Share your dotfiles" | Hidden configuration files in your home directory (`~/.zshrc`, `~/.gitconfig`) and the repo that tracks them |
| Alias | "I aliased that" | A shell-level text substitution that renames a command; no argument handling |
| Shell function | "I wrote a function for that" | A named block of shell code that accepts arguments and can contain logic |
| PATH | "Add it to your PATH" | The colon-separated list of directories the shell searches for executables |
| source | "Source your rc file" | Execute a shell script in the current shell session, applying its variable and alias definitions immediately |

## Further Reading

- [zsh Documentation](https://zsh.sourceforge.io/Doc/Release/zsh_toc.html) — authoritative reference for startup file load order and shell options
- [The Missing Semester: Shell Tools](https://missing.csail.mit.edu/2020/shell-tools/) — MIT lecture covering aliases, functions, and dotfile management
- [Starship Prompt](https://starship.rs) — cross-shell prompt with zero configuration required to get started
