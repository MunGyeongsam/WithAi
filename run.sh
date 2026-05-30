#!/usr/bin/env sh

set -eu

GAME_DIR="project/src"
LOVE_BIN="${LOVE_BIN:-love}"

if command -v "$LOVE_BIN" >/dev/null 2>&1; then
  exec "$LOVE_BIN" "$GAME_DIR"
fi

echo "love command not found. Set LOVE_BIN or install LÖVE2D, then run again."
exit 1