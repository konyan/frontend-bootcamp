#!/usr/bin/env bash
set -euo pipefail

ZSHRC="$HOME/.zshrc"

echo "Adding git aliases to $ZSHRC"

cat >> "$ZSHRC" << 'ALIASES'

alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline --graph --decorate --all"
alias gco="git checkout"
alias gcb="git checkout -b"
alias ..="cd .."
alias ...="cd ../.."
alias ll="ls -lah"

mkcd() {
  mkdir -p "$1" && cd "$1"
}

port() {
  lsof -i :"$1"
}
ALIASES

echo "Aliases added. Run: source ~/.zshrc"

if command -v brew &>/dev/null; then
  echo "Installing zoxide and starship via Homebrew..."
  brew install zoxide starship

  cat >> "$ZSHRC" << 'TOOLS'

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
TOOLS

  echo "zoxide and starship configured."
else
  echo "Homebrew not found. Install it from https://brew.sh then rerun this script."
fi
