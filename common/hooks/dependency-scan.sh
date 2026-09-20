#!/usr/bin/env bash
# dependency-scan: blocks new/changed dependencies with known vulnerabilities (OSV.dev).
#
# Usage (gate):   dependency-scan.sh <unified-diff>     [FL_MODE=staged|all]
# Usage (manual): dependency-scan.sh --check <ecosystem> <package> <version>
#                 ecosystems: npm | PyPI | Go | crates.io | SwiftURL
#                 (SPM: package = github.com/<org>/<repo>)
# Exits 1 if there are vulnerabilities, 0 otherwise.
#
# Covers: package.json (+package-lock.json), Package.resolved / Package.swift (SPM),
#         requirements*.txt (PyPI), go.mod (Go), Cargo.lock (crates.io).
# Known limits: only dependencies added or changed in this commit; with no lockfile the version
#   queried is the lower bound of the declared range; Package.swift only when on a single line;
#   unsupported managers (yarn/pnpm lock, poetry, Gemfile, pom, gradle...) warn but do not block.
# Variables: FL_DEPSCAN_ALLOW=ID1,ID2  (justified exceptions, by advisory ID)
#            FL_DEPSCAN_STRICT=1       (also fail if OSV.dev does not respond; by default it only warns)
#            FL_SKIP_DEPSCAN=1         (disable the scan)
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_lib.sh"

[ "${FL_SKIP_DEPSCAN:-0}" = "1" ] && exit 0
for bin in curl jq; do
  command -v "$bin" >/dev/null 2>&1 || { echo "dependency-scan: '$bin' is missing; scan NOT performed." >&2; [ "${FL_DEPSCAN_STRICT:-0}" = "1" ] && exit 1; exit 0; }
done

TAB="$(printf '\t')"
FOUND=0; NETFAIL=0; SEEN=""; NOTES=""
ALLOW=",${FL_DEPSCAN_ALLOW:-},"

osv_query() { # ecosystem name version
  curl -sS -m 20 -X POST https://api.osv.dev/v1/query -H 'Content-Type: application/json' \
    -d "$(jq -cn --arg e "$1" --arg n "$2" --arg v "$3" '{package:{name:$n,ecosystem:$e},version:$v}')" 2>/dev/null
}

check_dep() { # ecosystem name version source
  local eco="$1" name="$2" ver="$3" src="$4" key resp ids out
  key="$eco|$name|$ver"
  case "$SEEN" in *"
$key
"*) return ;; esac
  SEEN="$SEEN
$key
"
  resp="$(osv_query "$eco" "$name" "$ver")" || { NETFAIL=1; return; }
  printf '%s' "$resp" | jq -e . >/dev/null 2>&1 || { NETFAIL=1; return; }
  # Discards explicitly allowed advisories (by id or by CVE/GHSA alias).
  out="$(printf '%s' "$resp" | jq -r --arg allow "$ALLOW" '
      def fixed: ([.affected[]?.ranges[]?.events[]?.fixed // empty] | unique | join(", "));
      def ids: ([.id] + (.aliases // []));
      .vulns[]? | select( (ids | map(. as $i | select($allow | contains("," + $i + ","))) ) | length == 0 )
      | "    - \(.id)\(([(.aliases // [])[] | select(startswith("CVE-"))] | join(",")) | if . == "" then "" else " (" + . + ")" end): \((.summary // "no summary") | .[0:90]) — fixed in: \(fixed | if . == "" then "no known fix" else . end)"')"
  if [ -n "$out" ]; then
    FOUND=1
    echo "  $eco $name@$ver  (source: $src)" >&2
    printf '%s\n' "$out" >&2
  fi
}

# ---------- manual mode ----------
if [ "${1:-}" = "--check" ]; then
  [ $# -eq 4 ] || { echo "usage: dependency-scan.sh --check <ecosystem> <package> <version>" >&2; exit 2; }
  echo "dependency-scan: querying OSV.dev..." >&2
  check_dep "$2" "$3" "${4#v}" "manual"
  [ "$NETFAIL" = "1" ] && { echo "dependency-scan: OSV.dev did not respond." >&2; exit 3; }
  [ "$FOUND" = "1" ] && exit 1
  echo "dependency-scan: no known vulnerabilities for $2@$4." >&2
  exit 0
fi

# ---------- gate mode ----------
DIFF="${1:?uso: dependency-scan.sh <diff> | --check <eco> <pkg> <ver>}"
MODE="${FL_MODE:-staged}"

new_content() { if [ "$MODE" = "all" ]; then cat -- "$1" 2>/dev/null; else git show ":$1" 2>/dev/null; fi; }
old_content() { git show "HEAD:$1" 2>/dev/null; }
lock_content() { git show ":$1" 2>/dev/null || cat -- "$1" 2>/dev/null; }   # the lockfile may not be part of the commit
added_lines()  { fl_diff_added_tsv "$DIFF" | awk -F'\t' -v f="$1" '$1 == f { c=$3; for(i=4;i<=NF;i++) c=c "\t" $i; print c }'; }
lower_bound()  { printf '%s' "$1" | sed -E 's/^[^0-9]*//; s/[^0-9A-Za-z.+_-].*$//'; }
spm_name()     { printf '%s' "$1" | sed -E 's#^(https?|ssh|git)://##; s#^git@##; s#^[^@/]+@##; s#:#/#; s#\.git$##; s#/$##'; }
changed_only() { # stdin: "key<TAB>value" of the new file; $1: file with the old one → new or changed lines
  grep -vxF -f "$1" 2>/dev/null || cat
}

FILES="$(fl_diff_files "$DIFF")"
[ -z "$FILES" ] && exit 0
TMP_OLD="$(mktemp)"; PLAN="$(mktemp)"; trap 'rm -f "$TMP_OLD" "$PLAN"' EXIT
SPM_RESOLVED_SEEN=0

while IFS= read -r f; do
  b="$(basename "$f")"; d="$(dirname "$f")"
  case "$b" in
    package.json)
      dep_filter='((.dependencies // {}) + (.devDependencies // {}) + (.optionalDependencies // {}) + (.peerDependencies // {})) | to_entries[] | "\(.key)\t\(.value)"'
      old_content "$f" | jq -r "$dep_filter" > "$TMP_OLD" 2>/dev/null || : > "$TMP_OLD"
      lock="$(lock_content "$d/package-lock.json")"
      new_content "$f" | jq -r "$dep_filter" 2>/dev/null | changed_only "$TMP_OLD" | while IFS="$TAB" read -r name range; do
        ver=""
        [ -n "$lock" ] && ver="$(printf '%s' "$lock" | jq -r --arg n "$name" '.packages["node_modules/"+$n].version // .dependencies[$n].version // empty' 2>/dev/null)"
        [ -z "$ver" ] && ver="$(lower_bound "$range")"
        if [ -z "$ver" ]; then echo "NOTE  npm $name@$range: no resolvable version (git/url/tag); not checked ($f)"; continue; fi
        echo "DEP${TAB}npm${TAB}$name${TAB}$ver${TAB}$f"
      done ;;
    Package.resolved)
      SPM_RESOLVED_SEEN=1
      pin_filter='(.pins // .object.pins // [])[] | [(.location // .repositoryURL), (.state.version // empty)] | @tsv'
      old_content "$f" | jq -r "$pin_filter" > "$TMP_OLD" 2>/dev/null || : > "$TMP_OLD"
      new_content "$f" | jq -r "$pin_filter" 2>/dev/null | changed_only "$TMP_OLD" | while IFS="$TAB" read -r loc ver; do
        [ -z "$ver" ] && continue
        echo "DEP${TAB}SwiftURL${TAB}$(spm_name "$loc")${TAB}$ver${TAB}$f"
      done ;;
    Package.swift)
      added_lines "$f" | grep -E '\.package\(' | while IFS= read -r line; do
        url="$(printf '%s' "$line" | sed -nE 's/.*url:[[:space:]]*"([^"]+)".*/\1/p')"
        ver="$(printf '%s' "$line" | sed -nE 's/.*url:[[:space:]]*"[^"]+"[^"]*"([0-9][^"]*)".*/\1/p')"
        if [ -z "$url" ] || [ -z "$ver" ]; then echo "NOTE  SPM: dependency in $f with no version resolvable on a single line; not checked"; continue; fi
        echo "DEP${TAB}SwiftURL${TAB}$(spm_name "$url")${TAB}$ver${TAB}$f (lower bound of the range)"
      done ;;
    requirements*.txt)
      added_lines "$f" | while IFS= read -r line; do
        case "$line" in ''|\#*|-*) continue ;; esac
        name="$(printf '%s' "$line" | sed -nE 's/^[[:space:]]*([A-Za-z0-9_.-]+)(\[[^]]*\])?[[:space:]]*(===|==|>=|~=).*/\1/p')"
        ver="$(printf '%s' "$line" | sed -nE 's/^[[:space:]]*[A-Za-z0-9_.-]+(\[[^]]*\])?[[:space:]]*(===|==|>=|~=)[[:space:]]*([0-9][A-Za-z0-9.+!_-]*).*/\3/p')"
        if [ -z "$name" ] || [ -z "$ver" ]; then echo "NOTE  PyPI: '$(printf '%s' "$line" | awk '{print $1}')' has no pinned version in $f; not checked"; continue; fi
        echo "DEP${TAB}PyPI${TAB}$(printf '%s' "$name" | tr 'A-Z_' 'a-z-')${TAB}$ver${TAB}$f"
      done ;;
    go.mod)
      added_lines "$f" | sed -nE 's/^[[:space:]]*(require[[:space:]]+)?([^[:space:]]+\.[^[:space:]]+)[[:space:]]+v([0-9][^[:space:]]*).*/\2 \3/p' |
        while read -r mod ver; do
          echo "DEP${TAB}Go${TAB}$mod${TAB}${ver%+incompatible}${TAB}$f"
        done ;;
    Cargo.lock)
      cargo_filter='/^\[\[package\]\]/{n=""; v=""; s=""} /^name = /{gsub(/"/,"",$3); n=$3} /^version = /{gsub(/"/,"",$3); v=$3} /^source = /{s=1; if(n!=""&&v!="") print n "\t" v}'
      old_content "$f" | awk "$cargo_filter" > "$TMP_OLD" 2>/dev/null || : > "$TMP_OLD"
      new_content "$f" | awk "$cargo_filter" | changed_only "$TMP_OLD" | while IFS="$TAB" read -r name ver; do
        echo "DEP${TAB}crates.io${TAB}$name${TAB}$ver${TAB}$f"
      done ;;
    yarn.lock|pnpm-lock.yaml|poetry.lock|Pipfile.lock|Gemfile.lock|composer.lock|pom.xml|build.gradle|build.gradle.kts|Podfile.lock)
      echo "NOTE  $b: package manager not supported by dependency-scan; its dependencies were NOT checked" ;;
  esac
done <<EOF_FILES > "$PLAN"
$FILES
EOF_FILES

# The plan (DEP/NOTE) is generated in a subprocess: it is consumed here, in the main shell, to keep FOUND/NETFAIL.
if [ -s "$PLAN" ]; then
  echo "dependency-scan: checking new/changed dependencies against OSV.dev..." >&2
  while IFS="$TAB" read -r kind eco name ver src; do
    case "$kind" in
      DEP) check_dep "$eco" "$name" "$ver" "$src" ;;
      NOTE*) NOTES="$NOTES
  ${kind#NOTE  }" ;;
    esac
  done < "$PLAN"
fi

[ -n "$NOTES" ] && printf 'dependency-scan (warning):%s\n' "$NOTES" >&2

if [ "$FOUND" = "1" ]; then
  echo "dependency-scan: BLOCKED — dependencies with known vulnerabilities (source: OSV.dev)." >&2
  echo "  Upgrade to a fixed version, or pick another dependency / write those lines yourself." >&2
  echo "  Justified exception: FL_DEPSCAN_ALLOW=<ID,ID> in the command environment." >&2
  exit 1
fi
if [ "$NETFAIL" = "1" ]; then
  echo "dependency-scan: OSV.dev did not respond; dependencies NOT checked." >&2
  [ "${FL_DEPSCAN_STRICT:-0}" = "1" ] && exit 1
fi
exit 0
