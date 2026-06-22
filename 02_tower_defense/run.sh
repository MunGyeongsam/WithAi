#!/usr/bin/env sh

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GAME_DIR="$SCRIPT_DIR/src"
LOCAL_MAC_LOVE="$SCRIPT_DIR/../love-11.5-mac/love.app/Contents/MacOS/love"
LOVE_BIN="${LOVE_BIN:-$LOCAL_MAC_LOVE}"

if [ ! -x "$LOVE_BIN" ] && ! command -v "$LOVE_BIN" >/dev/null 2>&1; then
  if command -v love >/dev/null 2>&1; then
    LOVE_BIN="love"
  elif command -v love2d >/dev/null 2>&1; then
    LOVE_BIN="love2d"
  elif [ -x "/Applications/love.app/Contents/MacOS/love" ]; then
    LOVE_BIN="/Applications/love.app/Contents/MacOS/love"
  fi
fi

if command -v "$LOVE_BIN" >/dev/null 2>&1; then
  exec "$LOVE_BIN" "$GAME_DIR"
fi

if [ -x "$LOVE_BIN" ]; then
  exec "$LOVE_BIN" "$GAME_DIR"
fi

echo "LÖVE2D executable not found."
echo "- Try: LOVE_BIN=/path/to/love ./run.sh"
echo "- Or run VS Code task: Love2D: Run Tower Defense"
exit 1
