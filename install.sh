#!/usr/bin/env bash
# Forgeloom generic installer, for tools without their own plugin system (Codex, Cursor, Aider, ...).
# Copies a stack's AGENTS.md into a target project and makes CLAUDE.md point at it.
#
# Usage: ./install.sh <ios-swift|web|backend> [target-dir]      (target-dir defaults to the current directory)
#
# Safe by default: it never overwrites a project's own AGENTS.md (that file usually holds the project's
# charter). If one exists, the stack knowledge is written next to it as forgeloom-<stack>.md and you are
# told to reference it from your AGENTS.md.
set -eu

STACK="${1:-}"; TARGET="${2:-.}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
case "$STACK" in ios-swift|web|backend) ;; *) echo "usage: $0 <ios-swift|web|backend> [target-dir]" >&2; exit 2 ;; esac
SRC="$HERE/knowledge/$STACK/AGENTS.md"
[ -f "$SRC" ] || { echo "error: $SRC not found" >&2; exit 1; }
[ -d "$TARGET" ] || { echo "error: target directory '$TARGET' does not exist" >&2; exit 1; }
TARGET="$(cd "$TARGET" && pwd)"

if [ ! -e "$TARGET/AGENTS.md" ]; then
  cp "$SRC" "$TARGET/AGENTS.md"
  echo "created   $TARGET/AGENTS.md  (from knowledge/$STACK/AGENTS.md)"
  MAIN="AGENTS.md"
else
  cp "$SRC" "$TARGET/forgeloom-$STACK.md"
  echo "exists    $TARGET/AGENTS.md  (left untouched)"
  echo "created   $TARGET/forgeloom-$STACK.md"
  echo "next step: reference it from your AGENTS.md, e.g. add the line:  See forgeloom-$STACK.md"
  MAIN="AGENTS.md"
fi

# Claude Code reads CLAUDE.md: point it at AGENTS.md (symlink, or a one-line reference file if symlinks are not supported).
if [ -e "$TARGET/CLAUDE.md" ] || [ -L "$TARGET/CLAUDE.md" ]; then
  echo "exists    $TARGET/CLAUDE.md  (left untouched)"
elif ln -s "$MAIN" "$TARGET/CLAUDE.md" 2>/dev/null; then
  echo "created   $TARGET/CLAUDE.md -> $MAIN"
else
  printf '@%s\n' "$MAIN" > "$TARGET/CLAUDE.md"
  echo "created   $TARGET/CLAUDE.md  (one-line reference to $MAIN; symlinks unavailable here)"
fi
