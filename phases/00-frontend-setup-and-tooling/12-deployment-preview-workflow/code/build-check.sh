#!/usr/bin/env bash
set -euo pipefail

echo "Type checking..."
pnpm tsc --noEmit

echo "Linting..."
pnpm lint

echo "Building..."
pnpm build

echo ""
echo "All checks passed."
