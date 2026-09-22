#!/usr/bin/env bash
# source-check: verifies that a source spec has the shape /fl:import can place without gaps.
# Usage: source-check.sh <source-spec.md>
#
# The shape is the one prompts/chat-to-source-spec.md produces:
#   ## Project, ## Platforms, one `## Foundation — <Platform>` per platform that is in,
#   one `## Feature: <name>` per feature, and optionally ## Contracts and ## Decisions.
#
# FAIL = a required part is missing or empty: /fl:import would have to mark it as an open question
#        because the chat never produced it. Fix the source (go back to the chat), then import.
# WARN = the source is importable but something is likely wrong (a section /fl:import will not know
#        where to put, chat language, a decision without alternatives or reasons).
# An explicit `Open question: <what is missing>` counts as filled: it is a declared gap, not a
# silent one. It is listed at the end so you can decide whether to close it before importing.
#
# This checks SHAPE, not quality: it cannot tell a good acceptance criterion from a poor one.
#
# Exit: 0 = no FAIL (warnings allowed), 1 = at least one FAIL, 2 = usage error.
set -u

[ $# -eq 1 ] && [ "$1" != "-h" ] && [ "$1" != "--help" ] || { echo "usage: source-check.sh <source-spec.md>" >&2; exit 2; }
[ -f "$1" ] || { echo "source-check: file not found: $1" >&2; exit 2; }

AWK_PROG=""
read -r -d '' AWK_PROG <<'EOF'
function trim(s) { gsub(/^[ \t\r]+|[ \t\r]+$/, "", s); return s }
function bad(m)  { print "FAIL  " m; nfail++ }
function warn(m) { print "WARN  " m; nwarn++ }

# text after a leading word, without the separator ("Feature: Login" -> "Login")
function after_word(t, w,   r) { r = substr(t, length(w) + 1); sub(/^[^A-Za-z0-9]+/, "", r); return trim(r) }

# label(line): if the line starts with a known `Label:` (bullet and bold markers allowed), returns the
# lowercase label and leaves the text after the colon in LABREST; otherwise returns "".
function label(l,   t, i, lab) {
  t = l; sub(/^[-*][ \t]+/, "", t); gsub(/\*\*/, "", t)
  i = index(t, ":"); if (i == 0) return ""
  lab = tolower(trim(substr(t, 1, i - 1)))
  if (index(" name problem users non-goals global constraints platforms in scope out of scope status decision alternatives considered why ", " " lab " ") == 0) return ""
  LABREST = trim(substr(t, i + 1))
  return lab
}

function newunit(kind, name, n) { nunits++; ukind[nunits] = kind; uname[nunits] = name; uline[nunits] = n; return nunits }

function h2(n, t,   lt, k) {
  h3k = ""; h4k = ""; curlab = ""; lt = tolower(t); unit = 0; kind = "OTHER"
  if (lt == "project" || lt == "platforms" || lt == "contracts" || lt == "decisions") {
    k = toupper(lt)
    if (k in seen_kind) bad("line " n ": second `## " t "` section: there must be one")
    seen_kind[k] = 1; kind = k; unit = newunit(k, "", n); single[k] = unit
  } else if (index(lt, "foundation") == 1) {
    kind = "FOUNDATION"; unit = newunit(kind, after_word(t, "foundation"), n)
    if (uname[unit] == "") bad("line " n ": `## " t "` has no platform name (write `## Foundation — <Platform name>`)")
    else if (tolower(uname[unit]) in fnd) bad("line " n ": second Foundation section for " uname[unit])
    else fnd[tolower(uname[unit])] = unit
    nfnd++; fndu[nfnd] = unit
  } else if (index(lt, "feature") == 1) {
    kind = "FEATURE"; unit = newunit(kind, after_word(t, "feature"), n)
    if (uname[unit] == "") bad("line " n ": `## " t "` has no feature name (write `## Feature: <name>`)")
    else if (tolower(uname[unit]) in feat) bad("line " n ": feature " uname[unit] " appears twice: one block per feature, or the two versions will contradict each other")
    else { feat[tolower(uname[unit])] = unit; nfeat++; featu[nfeat] = unit }
  } else warn("line " n ": unknown section `## " t "`: /fl:import will not know where it goes")
}

function h3(n, t) {
  h4k = ""; curlab = ""; h3k = tolower(t)
  if (!unit) return
  h3seen[unit, h3k] = n
  if (kind == "DECISIONS") { ndec++; decu[ndec] = h3k; decn[ndec] = n }
}

function h4(n, t) {
  h4k = tolower(t); curlab = ""
  if (!unit) return
  h4seen[unit, h3k, h4k] = n
  if (h3k == "acceptance criteria") { nac[unit]++; acp[unit, nac[unit]] = h4k; acn[unit, nac[unit]] = n; aco[unit, nac[unit]] = t }
}

function parse_platform(n, t,   s, i, name, st) {
  s = t; sub(/^[-*][ \t]+/, "", s); gsub(/\*\*/, "", s)
  i = index(s, ":")
  if (i == 0) { warn("line " n ": platform line is not `- <Platform name>: in` or `- <Platform name>: out — <reason>`"); return }
  name = trim(substr(s, 1, i - 1)); st = tolower(trim(substr(s, i + 1)))
  if (st ~ /^in([^A-Za-z0-9]|$)/) { nplat++; platname[nplat] = name; platlow[nplat] = tolower(name); platin[tolower(name)] = 1 }
  else if (st ~ /^out([^A-Za-z0-9]|$)/) { platout[tolower(name)] = 1 }
  else warn("line " n ": platform \"" name "\" is neither `in` nor `out`")
}

function content(n, raw,   t, lt, lab) {
  t = trim(raw); if (t == "") return
  lt = tolower(t)
  if (index(lt, "open question:") > 0) { noq++; if (noq <= 30) oql[noq] = n ": " substr(t, 1, 90); oqc[unit, h3k, h4k]++ }
  if (lt ~ /as we (discussed|agreed|said)|as discussed|see (above|below)|supersed|^[-* ]*(update|updated|edit|edited|revised)[ ]*(:|\(|v[0-9])/)
    warn("line " n ": chat or history language (\"" substr(t, 1, 60) "\"): the source must hold the current state only, readable without the chat")
  if (!unit) return
  cnth3[unit, h3k]++
  if (index(lt, "alternative")) alt[unit, h3k] = 1
  if (index(lt, "why")) why[unit, h3k] = 1
  if (kind == "PLATFORMS") { parse_platform(n, t); return }
  if (h4k != "" && t ~ /^[-*][ \t]+\[[ xX]\]/) chk[unit, h3k, h4k]++
  lab = label(t)
  if (lab != "") {
    labseen[unit, h3k, lab] = 1; curlab = lab
    if (LABREST != "") labcnt[unit, h3k, lab]++
    if (kind == "FEATURE" && h3k == "" && lab == "platforms") fplat[unit] = LABREST
  } else if (curlab != "") labcnt[unit, h3k, curlab]++
}

{
  raw = $0; sub(/\r$/, "", raw)
  if (raw ~ /^[ \t]*(```|~~~)/) { infence = !infence; content(NR, raw); next }
  if (!infence) {
    if (raw ~ /^## /)   { h2(NR, trim(substr(raw, 4))); next }
    if (raw ~ /^### /)  { h3(NR, trim(substr(raw, 5))); next }
    if (raw ~ /^#### /) { h4(NR, trim(substr(raw, 6))); next }
    if (raw ~ /^# /)    { next }
  }
  content(NR, raw)
}

END {
  # Project
  if (!("PROJECT" in single)) bad("no `## Project` section (name, problem, users, non-goals, global constraints)")
  else {
    pu = single["PROJECT"]; np = split("name|problem|users|non-goals|global constraints", pl, "|")
    for (i = 1; i <= np; i++) {
      if (!((pu, "", pl[i]) in labseen)) bad("## Project: missing `" pl[i] ":` (write `none` or `Open question: ...` if it is not decided)")
      else if (labcnt[pu, "", pl[i]] < 1) bad("## Project: `" pl[i] ":` is empty")
    }
  }

  # Platforms and their foundations
  if (!("PLATFORMS" in single)) bad("no `## Platforms` section: /fl:import derives the repos from it")
  else if (nplat == 0) bad("## Platforms: no platform is marked `in`")
  nreq = split("technical stack|hosting/infrastructure|general architecture|planned commands|decisions", req, "|")
  for (i = 1; i <= nplat; i++) if (!(platlow[i] in fnd)) bad("no `## Foundation — " platname[i] "` section for a platform that is in")
  for (j = 1; j <= nfnd; j++) {
    fu = fndu[j]; fn = uname[fu]; if (fn == "") continue
    if (!(tolower(fn) in platin)) { bad("line " uline[fu] ": Foundation for \"" fn "\", which is not an `in` platform in ## Platforms"); continue }
    for (r = 1; r <= nreq; r++) {
      if (!((fu, req[r]) in h3seen)) bad("Foundation — " fn ": missing `### " req[r] "`")
      else if (cnth3[fu, req[r]] < 1) bad("Foundation — " fn ": `### " req[r] "` is empty (write `Open question: ...` if it is not decided)")
    }
    if (cnth3[fu, "decisions"] > 0 && (!((fu, "decisions") in alt) || !((fu, "decisions") in why)))
      warn("Foundation — " fn ": `### decisions` should state the alternatives considered and why")
  }

  # Features
  if (nfeat == 0) bad("no `## Feature:` section")
  nfr = split("objective|scope|constraints|acceptance criteria|relevant prior decisions", fr, "|")
  for (j = 1; j <= nfeat; j++) {
    fu = featu[j]; fn = uname[fu]; if (fn == "") continue
    nfp = 0
    if (!(fu in fplat) || fplat[fu] == "") bad("Feature " fn ": missing `Platforms:` line right under the heading")
    else {
      nfp = split(fplat[fu], fp, /[ \t]*,[ \t]*/)
      for (i = 1; i <= nfp; i++) {
        fp[i] = trim(fp[i])
        if (!(tolower(fp[i]) in platin)) bad("Feature " fn ": platform \"" fp[i] "\" is not an `in` platform in ## Platforms")
      }
      if (nfp >= 2) multi = 1
    }
    for (r = 1; r <= nfr; r++) {
      if (!((fu, fr[r]) in h3seen)) bad("Feature " fn ": missing `### " fr[r] "`")
      else if (cnth3[fu, fr[r]] < 1) bad("Feature " fn ": `### " fr[r] "` is empty (write `Open question: ...` if it is not decided)")
    }
    if ((fu, "scope") in h3seen) {
      if (labcnt[fu, "scope", "in scope"] < 1) bad("Feature " fn ": Scope has no `In scope:` text")
      if (labcnt[fu, "scope", "out of scope"] < 1) bad("Feature " fn ": Scope has no `Out of scope:` text (write `none` only if that is really the case)")
    }
    if ((fu, "acceptance criteria") in h3seen) {
      for (i = 1; i <= nfp; i++) {
        k = tolower(fp[i])
        if (!((fu, "acceptance criteria", k) in h4seen)) { bad("Feature " fn ": Acceptance criteria has no `#### " fp[i] "` group"); continue }
        if (chk[fu, "acceptance criteria", k] < 1 && oqc[fu, "acceptance criteria", k] < 1) bad("Feature " fn ": Acceptance criteria for " fp[i] " has no `- [ ]` item and no open question")
        else if (chk[fu, "acceptance criteria", k] < 1) warn("Feature " fn ": Acceptance criteria for " fp[i] " is only an open question")
      }
      for (a = 1; a <= nac[fu]; a++) {
        ok = 0; for (i = 1; i <= nfp; i++) if (tolower(fp[i]) == acp[fu, a]) ok = 1
        if (!ok) warn("line " acn[fu, a] ": Feature " fn ": criteria group `#### " aco[fu, a] "` is not one of the feature platforms")
      }
    }
  }

  # Contracts and cross-platform decisions
  if (multi && !("CONTRACTS" in single)) warn("a feature spans more than one platform but there is no `## Contracts` section (API, data model, design tokens)")
  for (d = 1; d <= ndec; d++) {
    du = single["DECISIONS"]; k = decu[d]
    if (!((du, k, "why") in labseen) || !((du, k, "alternatives considered") in labseen))
      warn("line " decn[d] ": decision `" k "` should have `Alternatives considered:` and `Why:`")
  }

  printf "note  %d platform(s) in, %d feature(s), %d open question(s) written in the source\n", nplat + 0, nfeat + 0, noq + 0
  for (i = 1; i <= noq && i <= 30; i++) print "      line " oql[i]
  if (noq > 30) print "      ... and " (noq - 30) " more"
  if (nfail > 0) { printf "source-check: FAILED (%d problem(s), %d warning(s))\n", nfail, nwarn + 0; exit 1 }
  printf "source-check: OK (%d warning(s))\n", nwarn + 0
  if (noq > 0) print "note  each open question above is a gap declared in the source: close it before importing if you can"
}
EOF

awk "$AWK_PROG" "$1"
