#!/usr/bin/env bash
set -euo pipefail

pass() { echo "  [OK] $1"; }
fail() { echo "  [FAIL] $1"; FAILED=1; }

FAILED=0

echo "Checking Layer 1: Shell"
if [ -n "$SHELL" ]; then pass "Shell: $SHELL"; else fail "Shell not detected"; fi

echo "Checking Layer 2: Node.js runtime"
if command -v node &>/dev/null; then
  NODE_VER=$(node --version)
  pass "Node: $NODE_VER"
else
  fail "Node not found — run: fnm install --lts"
fi

if command -v pnpm &>/dev/null; then
  PNPM_VER=$(pnpm --version)
  pass "pnpm: $PNPM_VER"
else
  fail "pnpm not found — run: npm install -g pnpm"
fi

echo "Checking Layer 3: Editor"
if command -v code &>/dev/null; then
  CODE_VER=$(code --version | head -1)
  pass "VS Code: $CODE_VER"
else
  fail "VS Code 'code' command not found — install from code.visualstudio.com"
fi

echo "Checking Layer 4: Project config"
if [ -f "package.json" ]; then
  pass "package.json found"
else
  fail "No package.json — run: pnpm init"
fi

if [ "$FAILED" -eq 0 ]; then
  echo ""
  echo "All checks passed. Your environment is ready."
else
  echo ""
  echo "Some checks failed. Fix the issues above before continuing."
  exit 1
fi
