#!/usr/bin/env bash
# Helpers shared by secret-scan.sh and dependency-scan.sh.
# Common input: a unified diff (-U0) of the commit about to be created.

# Files added/modified in the diff (paths relative to the repo root).
fl_diff_files() {
  awk '
    /^diff --git / { inhdr = 1; next }
    /^@@/          { inhdr = 0; next }
    inhdr && /^\+\+\+ / {
      f = $0; sub(/^\+\+\+ /, "", f)
      if (f == "/dev/null") next
      sub(/^b\//, "", f); print f
    }' "$1"
}

# Added lines as TSV: path<TAB>line number<TAB>content.
fl_diff_added_tsv() {
  awk '
    /^diff --git / { inhdr = 1; f = ""; next }
    inhdr && /^\+\+\+ / {
      f = $0; sub(/^\+\+\+ /, "", f)
      if (f == "/dev/null") f = ""; else sub(/^b\//, "", f)
      next
    }
    /^@@/ {
      inhdr = 0
      s = $0; sub(/^@@ -[0-9,]+ \+/, "", s); sub(/[ ,].*$/, "", s); ln = s + 0
      next
    }
    !inhdr && /^\+/ { if (f != "") printf "%s\t%d\t%s\n", f, ln, substr($0, 2); ln++ }
  ' "$1"
}
