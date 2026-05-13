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
