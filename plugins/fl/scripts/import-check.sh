#!/usr/bin/env bash
# import-check: verifies that /fl:import lost nothing from the source spec.
# Usage: import-check.sh <import-map.md> [--repo <dir-name>] [--map-only]
#
#   --map-only   only check the map itself (source frozen, every source line accounted for)
#   --repo NAME  also check the rows whose destination is inside NAME/ (one import run per repo);
#                without it, every row of every repo is checked (the final check)
#
# What it guarantees, in order:
#   1. The source file still has the sha256 recorded in the map (it was not edited mid-import).
#   2. Every non-trivial source line belongs to at least one row of the map (nothing was left out
#      by accident). A line may be in several rows on purpose (it applies to several repos).
#   3. Each `verbatim`/`openapi` row: every line of its range appears, word for word, in the
#      destination file. The comparison ignores indentation, heading/list/checkbox markers and
#      blank or rule-only lines, so moving text under another heading or turning a bullet into
#      a checklist item passes; rewording does not.
#   4. Each `dropped` row is listed for review and needs a reason in Notes.
#   5. Every AGENTS.md of a checked repo stays under 200 lines.
#   6. Every openapi.yaml that received `openapi` rows passes an OpenAPI structural linter.
#
#      Step 6 checks STRUCTURE (valid YAML, valid OpenAPI, no dangling $ref), not style completeness:
#      Redocly's `recommended` rules (servers, security, summaries, operationIds) would force the
#      import to invent facts the source never states, so the default is its `minimal` ruleset.
#
# Environment: FL_IMPORT_LINT_CMD (linter command, run with the file as its last argument; default:
#              `redocly lint --extends minimal`; use it for a stricter ruleset or another linter),
#              FL_IMPORT_SKIP_LINT=1 (skip step 6 with a warning).
# Exit: 0 = everything holds, 1 = at least one check failed, 2 = usage error.
set -u

usage() { echo "usage: import-check.sh <import-map.md> [--repo <dir-name>] [--map-only]" >&2; exit 2; }

MAP=""; ONLY_REPO=""; MAP_ONLY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --repo)     [ $# -ge 2 ] || usage; ONLY_REPO="${2%/}"; shift 2 ;;
    --map-only) MAP_ONLY=1; shift ;;
    -h|--help)  usage ;;
    -*)         usage ;;
    *)          [ -z "$MAP" ] || usage; MAP="$1"; shift ;;
  esac
done
[ -n "$MAP" ] || usage
[ -f "$MAP" ] || { echo "import-check: map not found: $MAP" >&2; exit 2; }

MAPDIR="$(cd "$(dirname "$MAP")" && pwd)"
ERRORS=0
fail() { echo "FAIL  $*"; ERRORS=$((ERRORS + 1)); }
note() { echo "      $*"; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
SEP=$'\037'

# Line normalization shared by every awk pass (see step 3 above).
NORM='
function norm(s) {
  gsub(/\r/, "", s)
  sub(/^[ \t]+/, "", s)
  while (match(s, /^(>+|#+|[-*+]|[0-9]+[.)]|\[[ xX]\])[ \t]+/)) s = substr(s, RLENGTH + 1)
  gsub(/[ \t]+/, " ", s); sub(/ $/, "", s)
  if (s ~ /^[-=*_|:`+. ]*$/) return ""
  return s
}'

# ── Header: source path and sha256 ────────────────────────────────────────────
header_value() { # header_value <key>
  awk -v k="$1" '
    index($0, k ":") == 1 { v = substr($0, length(k) + 2); gsub(/^[ \t`]+|[ \t`]+$/, "", v); print v; exit }' "$MAP"
}
SRC_REL="$(header_value source)"; SRC_SHA="$(header_value sha256)"
[ -n "$SRC_REL" ] && [ -n "$SRC_SHA" ] || { echo "import-check: the map needs 'source:' and 'sha256:' header lines" >&2; exit 2; }
case "$SRC_REL" in /*) SRC="$SRC_REL" ;; *) SRC="$MAPDIR/$SRC_REL" ;; esac
[ -f "$SRC" ] || { echo "import-check: source not found: $SRC" >&2; exit 2; }

sha256_of() { if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1"; else sha256sum "$1"; fi | awk '{print $1}'; }
[ "$(sha256_of "$SRC")" = "$SRC_SHA" ] || fail "source changed since the map was made ($SRC_REL): re-create the map, do not import from a moving source"
SRC_LINES="$(awk 'END { print NR }' "$SRC")"

# ── Rows ──────────────────────────────────────────────────────────────────────
awk -F'|' -v OFS="$SEP" '
  function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); gsub(/`/, "", s); return s }
  /^[ \t]*\|/ {
    if (NF < 7)                       { print "MALFORMED", NR; next }
    id = trim($2)
    if (id == "ID" || id ~ /^[:-]*$/) next
    print "ROW", trim($2), trim($3), trim($4), trim($5), trim($6), trim($7)
  }' "$MAP" > "$TMP/rows"

: > "$TMP/ranges"; : > "$TMP/checked"; : > "$TMP/dropped"; ROWS=0
while IFS="$SEP" read -r kind id lines section dest treat notes; do
  if [ "$kind" = "MALFORMED" ]; then fail "map line $id is a table row with too few cells (expected: ID | Lines | Section | Destination | Treatment | Notes)"; continue; fi
  ROWS=$((ROWS + 1))
  if ! [[ "$lines" =~ ^[0-9]+(-[0-9]+)?$ ]]; then fail "$id: Lines must be N or N-M, got '$lines'"; continue; fi
  a="${lines%%-*}"; b="${lines##*-}"
  if [ "$a" -lt 1 ] || [ "$a" -gt "$b" ] || [ "$b" -gt "$SRC_LINES" ]; then fail "$id: lines $lines are outside the source (1-$SRC_LINES)"; continue; fi
  case "$treat" in
    verbatim|openapi|dropped) ;;
    *) fail "$id: Treatment must be verbatim, openapi or dropped, got '$treat'"; continue ;;
  esac
  echo "$a $b" >> "$TMP/ranges"
  if [ "$treat" = "dropped" ]; then
    [ -n "$notes" ] || fail "$id: a dropped row needs its reason in Notes"
    printf '%s\t%s\t%s\t%s\n' "$id" "$lines" "$section" "$notes" >> "$TMP/dropped"
    continue
  fi
  case "$dest" in
    ""|/*|..|../*|*/../*|*/..) fail "$id: Destination must be a relative path inside the umbrella folder, got '$dest'"; continue ;;
    */*) ;;
    *)   fail "$id: Destination must start with the repo folder (repo/path), got '$dest'"; continue ;;
  esac
  printf '%s%s%s%s%s%s%s%s%s\n' "$id" "$SEP" "$a" "$SEP" "$b" "$SEP" "$dest" "$SEP" "$treat" >> "$TMP/checked"
done < "$TMP/rows"
[ "$ROWS" -gt 0 ] || fail "the map has no rows"

# ── 2. Every source line is accounted for ─────────────────────────────────────
awk "$NORM"'
  FILENAME == ARGV[1] { for (i = $1; i <= $2; i++) cov[i] = 1; next }
  { if (norm($0) != "" && !(FNR in cov)) { if (start && FNR == prev + 1) prev = FNR; else { if (start) print start "-" prev; start = prev = FNR } } }
  END { if (start) print start "-" prev }' "$TMP/ranges" "$SRC" > "$TMP/uncovered"
if [ -s "$TMP/uncovered" ]; then
  fail "source lines not covered by any row (add rows, or a 'dropped' row with a reason):"
  while read -r r; do note "lines $r"; done < "$TMP/uncovered"
fi

# ── 3. Rows of the checked repos: text present in the destination ─────────────
CHECKED=0; REPOS=""; OPENAPI_FILES=""
if [ "$MAP_ONLY" -eq 0 ]; then
  while IFS="$SEP" read -r id a b dest treat; do
    repo="${dest%%/*}"
    [ -z "$ONLY_REPO" ] || [ "$repo" = "$ONLY_REPO" ] || continue
    CHECKED=$((CHECKED + 1))
    case " $REPOS " in *" $repo "*) ;; *) REPOS="$REPOS $repo" ;; esac
    if [ "$treat" = "openapi" ]; then case " $OPENAPI_FILES " in *" $dest "*) ;; *) OPENAPI_FILES="$OPENAPI_FILES $dest" ;; esac; fi
    if [ ! -f "$MAPDIR/$dest" ]; then fail "$id: destination file does not exist yet: $dest"; continue; fi
    # FILENAME (not NR == FNR) so an empty destination is not mistaken for the source
    awk -v A="$a" -v B="$b" "$NORM"'
      FILENAME == ARGV[1] { have[norm($0)] = 1; next }
      FNR >= A && FNR <= B { n = norm($0); if (n == "") next; total++; if (!(n in have)) { miss++; if (miss <= 5) printf "%d: %s\n", FNR, substr($0, 1, 90) } }
      END { printf "COUNT %d %d\n", total + 0, miss + 0 }' "$MAPDIR/$dest" "$SRC" > "$TMP/row.out"
    read -r _ total miss < <(tail -1 "$TMP/row.out")
    if [ "${miss:-0}" -gt 0 ]; then
      fail "$id: $miss of $total source lines (lines $a-$b) are not in $dest, word for word. First ones:"
      sed '$d' "$TMP/row.out" | while IFS= read -r l; do note "$l"; done
    fi
  done < "$TMP/checked"
  [ "$CHECKED" -gt 0 ] || fail "no rows to check${ONLY_REPO:+ for repo '$ONLY_REPO'}: check the repo folder name against the Destination column"
fi

# ── 5. AGENTS.md size ─────────────────────────────────────────────────────────
for repo in $REPOS; do
  if [ -f "$MAPDIR/$repo/AGENTS.md" ]; then
    n="$(awk 'END { print NR }' "$MAPDIR/$repo/AGENTS.md")"
    [ "$n" -le 200 ] || fail "$repo/AGENTS.md has $n lines (limit 200): move the long detail to $repo/docs/ and link it"
  fi
done

# ── 6. OpenAPI validity ───────────────────────────────────────────────────────
lint_cmd() {
  if [ -n "${FL_IMPORT_LINT_CMD:-}" ]; then echo "$FL_IMPORT_LINT_CMD"
  elif command -v redocly >/dev/null 2>&1; then echo "redocly lint --extends minimal"
  fi
}
for f in $OPENAPI_FILES; do
  [ -f "$MAPDIR/$f" ] || continue
  if [ -n "${FL_IMPORT_SKIP_LINT:-}" ]; then echo "WARN  $f was NOT validated (FL_IMPORT_SKIP_LINT is set)"; continue; fi
  cmd="$(lint_cmd)"
  if [ -z "$cmd" ]; then
    fail "$f cannot be validated: no OpenAPI linter found. Install one (npm install -g @redocly/cli) or set FL_IMPORT_LINT_CMD; FL_IMPORT_SKIP_LINT=1 skips it with a warning"
    continue
  fi
  # shellcheck disable=SC2086
  if $cmd "$MAPDIR/$f" > "$TMP/lint.out" 2>&1; then echo "ok    $f passes the OpenAPI linter ($cmd)"
  else fail "$f does not pass the OpenAPI linter ($cmd):"; sed -n '1,15p' "$TMP/lint.out" | while IFS= read -r l; do note "$l"; done; fi
done

# ── Report ────────────────────────────────────────────────────────────────────
if [ -s "$TMP/dropped" ] && [ -z "$ONLY_REPO" ]; then
  echo "note  rows left out on purpose (review them; they are not in any repo):"
  while IFS=$'\t' read -r id lines section notes; do note "$id lines $lines — $section — $notes"; done < "$TMP/dropped"
fi
if [ "$ERRORS" -gt 0 ]; then echo "import-check: FAILED ($ERRORS problem(s))"; exit 1; fi
if [ "$MAP_ONLY" -eq 1 ]; then echo "import-check: map OK ($ROWS rows; every source line is accounted for)"
else echo "import-check: OK ($CHECKED row(s) checked${ONLY_REPO:+ in $ONLY_REPO}; $ROWS in the map)"; fi
