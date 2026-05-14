#!/usr/bin/env bash
set -euo pipefail

TMPDIR="$(mktemp -d)"
echo "Practice repo: $TMPDIR"
cd "$TMPDIR"

git init -b main
git config user.email "practice@example.com"
git config user.name "Practice"

echo "# Project" > README.md
git add README.md
git commit -m "feat: initial commit"

git checkout -b feature/sidebar
echo "sidebar content" > sidebar.js
git add sidebar.js
git commit -m "feat(ui): add sidebar component"

echo "sidebar styles" > sidebar.css
git add sidebar.css
git commit -m "style(ui): add sidebar styles"

git checkout main
echo "main update" >> README.md
git add README.md
git commit -m "docs: update readme"

echo ""
echo "Current log:"
git log --oneline --graph --all

echo ""
echo "Merging feature/sidebar into main..."
git merge feature/sidebar --no-ff -m "Merge feature/sidebar"

echo ""
echo "After merge:"
git log --oneline --graph --all

echo ""
echo "Practice repo is at: $TMPDIR"
echo "cd into it and practice: git stash, git rebase -i, git reflog"
