#!/usr/bin/env bash
set -e

git init practice-repo
cd practice-repo

git commit --allow-empty -m "feat: initial commit"

git checkout -b feature/add-header
git commit --allow-empty -m "feat: add header component"
git commit --allow-empty -m "feat: add navigation links"

git checkout main
git merge --no-ff feature/add-header -m "merge: add header feature"

git checkout -b hotfix/typo
git commit --allow-empty -m "fix: correct typo in title"
git checkout main
git cherry-pick hotfix/typo

git log --oneline --graph --all

cd ..
rm -rf practice-repo
