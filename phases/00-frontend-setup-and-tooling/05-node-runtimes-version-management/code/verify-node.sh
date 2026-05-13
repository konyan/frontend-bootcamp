#!/usr/bin/env bash
set -euo pipefail

REQUIRED_MAJOR=20

current=$(node --version | sed 's/v//')
major=$(echo "$current" | cut -d. -f1)

echo "Node.js: v$current"
echo "pnpm:    $(pnpm --version)"

if [ "$major" -lt "$REQUIRED_MAJOR" ]; then
    echo "FAIL: Node $REQUIRED_MAJOR+ required. Run: fnm use $REQUIRED_MAJOR"
    exit 1
fi

echo "OK: Node version is compatible"
