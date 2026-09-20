#!/usr/bin/env bash
# Forgeloom pre-commit gate: secret-scan + dependency-scan over what is about to be committed.
#
# Two ways to use it:
#  1. Claude Code PreToolUse hook (hooks.json): receives the tool-call JSON on stdin, and only
#     acts if the Bash command is a `git commit`. Blocks with exit 2 (stderr reaches Claude).
#  2. git `pre-commit` hook:  ln -s <path>/pre-commit-gate.sh .git/hooks/pre-commit
#     (or call it with --git; it also self-detects when installed as "pre-commit"). Blocks with exit 1. It also covers manual commits outside Claude Code.
#
# Note: a Claude Code hook only sees the commands Claude runs; `git commit --no-verify` does not
# bypass it, but a commit you make by hand in your terminal does not trigger it either (use mode 2 for that).
set -u
# Resolve symlinks (the script may be installed as .git/hooks/pre-commit -> this file).
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  d="$(cd -P "$(dirname "$SOURCE")" && pwd)"; SOURCE="$(readlink "$SOURCE")"
  case "$SOURCE" in /*) ;; *) SOURCE="$d/$SOURCE" ;; esac
done
HERE="$(cd -P "$(dirname "$SOURCE")" && pwd)"

# git-hook mode: explicit --git, invoked under the name "pre-commit", or stdin is a terminal.
GIT_MODE=0
if [ "${1:-}" = "--git" ] || [ "$(basename "${BASH_SOURCE[0]}")" = "pre-commit" ] || [ -t 0 ]; then GIT_MODE=1; fi

FL_MODE="staged"
BLOCK_CODE=2
if [ "$GIT_MODE" = "1" ]; then
  BLOCK_CODE=1
else
  INPUT="$(cat)"
  if command -v jq >/dev/null 2>&1; then
    CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"
    CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)"
  else
    CMD="$INPUT"; CWD=""   # without jq: search the raw JSON
  fi
  # Is it a `git commit`? (handles `git -C dir commit`, `git -c k=v commit`, chained with && ; |)
  printf '%s' "$CMD" | grep -Eq '(^|[;&|(]|&&|\|\|)[[:space:]]*git[[:space:]]+([^;&|]*[[:space:]])?commit([[:space:]"]|$)' || exit 0
  # `git commit -a/--all` includes unstaged changes: scan against HEAD, not against the index.
  COMMIT_ALL=0
  printf '%s' "$CMD" | grep -Eq '[[:space:]](-[a-zA-Z]*a[a-zA-Z]*|--all)([[:space:]"]|$)' && { FL_MODE="all"; COMMIT_ALL=1; }
  # A PreToolUse hook runs BEFORE the whole command, so in `git add -A && git commit` the `git add`
  # has not happened yet and the index is still empty. Anticipate what chained `git add`s will stage.
  ADD_BROAD=0; ADD_PATHS=""
  while IFS= read -r seg; do
    printf '%s' "$seg" | grep -Eq '(^|[[:space:]])git[[:space:]]+([^;&|]*[[:space:]])?add([[:space:]]|$)' || continue
    args="$(printf '%s' "$seg" | sed -E 's/^.*[[:space:]]add([[:space:]]+|$)//')"
    set -f
    for tok in $args; do
      tok="$(printf '%s' "$tok" | tr -d "\"'")"
      case "$tok" in
        -A|--all|-u|--update|.|./|:/|\*|:\(top\)) ADD_BROAD=1 ;;
        -*) ;;
        "") ;;
        *) ADD_PATHS="$ADD_PATHS
$tok" ;;
      esac
    done
    set +f
  done <<SEGS
$(printf '%s' "$CMD" | sed -E 's/(&&|\|\||;|\|)/\
/g')
SEGS
  if [ "$ADD_BROAD" = "1" ] || [ -n "$ADD_PATHS" ]; then FL_MODE="all"; fi
  [ -n "$CWD" ] && [ -d "$CWD" ] && cd "$CWD"
  # The real repo may come from `cd <dir> && git commit` or from `git -C <dir> commit`.
  CD_TARGET="$(printf '%s' "$CMD" | sed -nE 's/.*(^|[;&|])[[:space:]]*cd[[:space:]]+("([^"]+)"|([^[:space:];&|]+)).*/\3\4/p' | head -1)"
  [ -n "$CD_TARGET" ] && [ -d "$CD_TARGET" ] && cd "$CD_TARGET"
  C_TARGET="$(printf '%s' "$CMD" | sed -nE 's/.*git[[:space:]]+-C[[:space:]]+("([^"]+)"|([^[:space:]]+)).*/\2\3/p' | head -1)"
  [ -n "$C_TARGET" ] && [ -d "$C_TARGET" ] && cd "$C_TARGET"
fi
export FL_MODE

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
cd "$ROOT" || exit 0

if git rev-parse --verify -q HEAD >/dev/null 2>&1; then BASE="HEAD"; else BASE="4b825dc642cb6eb9a060e54bf8d69288fbee4904"; fi
DIFF="$(mktemp)"; trap 'rm -f "$DIFF"' EXIT
untracked_diff() { # files (one per line) → synthetic "added" diff for files not yet tracked
  while IFS= read -r f; do [ -f "$f" ] && git diff --no-color --no-index -U0 -- /dev/null "$f" 2>/dev/null; done
}
{
  if [ "$FL_MODE" = "all" ]; then
    if [ "${COMMIT_ALL:-0}" = "1" ] || [ "${ADD_BROAD:-0}" = "1" ]; then
      # `commit -a` (tracked changes) or a broad `git add` (tracked changes + untracked files).
      git diff --no-color --no-renames -U0 --diff-filter=ACMR "$BASE" 2>/dev/null
    fi
    [ "${ADD_BROAD:-0}" = "1" ] && git ls-files --others --exclude-standard 2>/dev/null | untracked_diff
    if [ -n "${ADD_PATHS:-}" ]; then
      # `git add <paths>`: only those paths (tracked changes + untracked files under them).
      PATHS_ARR=(); while IFS= read -r pth; do [ -n "$pth" ] && PATHS_ARR+=("$pth"); done <<PATHS
$ADD_PATHS
PATHS
      git diff --no-color --no-renames -U0 --diff-filter=ACMR "$BASE" -- "${PATHS_ARR[@]}" 2>/dev/null
      git ls-files --others --exclude-standard -- "${PATHS_ARR[@]}" 2>/dev/null | untracked_diff
    fi
  fi
  git diff --cached --no-color --no-renames -U0 --diff-filter=ACMR 2>/dev/null
} > "$DIFF"
[ -s "$DIFF" ] || exit 0

FAIL=0; REPORT=""
run() { # name script
  local err; err="$(bash "$HERE/$2" "$DIFF" 2>&1 >/dev/null)"; local rc=$?
  if [ $rc -ne 0 ]; then FAIL=1; REPORT="$REPORT$err
"; elif [ -n "$err" ]; then REPORT="$REPORT$err
"; fi
}
run secret-scan secret-scan.sh
run dependency-scan dependency-scan.sh

if [ "$FAIL" = "1" ]; then
  {
    echo "Forgeloom pre-commit gate: COMMIT BLOCKED."
    printf '%s' "$REPORT"
  } >&2
  exit "$BLOCK_CODE"
fi
# Non-blocking warnings (e.g. OSV.dev unreachable) still reach the user.
[ -n "$REPORT" ] && printf '%s' "$REPORT" >&2
exit 0
