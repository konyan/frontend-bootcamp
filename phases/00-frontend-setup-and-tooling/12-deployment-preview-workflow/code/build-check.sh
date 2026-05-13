#!/usr/bin/env bash
set -euo pipefail

echo "=== Pre-deploy build check ==="

pnpm tsc --noEmit
echo "TypeScript: OK"

pnpm lint
echo "Lint: OK"

pnpm build
echo "Build: OK"

BUNDLE_SIZE=$(du -sh dist/assets/*.js 2>/dev/null | awk '{sum += $1} END {print sum}')
echo "Bundle: ${BUNDLE_SIZE}K JS assets in dist/"

echo "=== All checks passed ==="
