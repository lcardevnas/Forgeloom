#!/usr/bin/env bash
# secret-scan: looks for secrets in the ADDED lines of a diff.
# Usage: secret-scan.sh <unified-diff>      Exits 1 if there are findings, 0 otherwise.
# One-off exception: add "fl:allow-secret" on the same line (with a justification).
# It never prints the secret value, only file:line and the rule.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_lib.sh"

DIFF="${1:?uso: secret-scan.sh <diff>}"
TSV="$(mktemp)"; CONTENT="$(mktemp)"; OUT="$(mktemp)"
trap 'rm -f "$TSV" "$CONTENT" "$OUT"' EXIT

fl_diff_added_tsv "$DIFF" | grep -v 'fl:allow-secret' > "$TSV"
cut -f3- "$TSV" > "$CONTENT"   # content only: the regex is never applied to the path or the line number

# report_lines <rule>  — reads line numbers (of CONTENT) from stdin and emits file:line  rule
report_lines() {
  awk -v rule="$1" -F'\t' 'NR==FNR { want[$1]=1; next } (FNR in want) { printf "%s:%s  %s\n", $1, $2, rule }' - "$TSV" >> "$OUT"
}

# scan <rule-name> <ERE-regex> [i]   (i = case-insensitive)
scan() {
  local flags="-E"; [ "${3:-}" = "i" ] && flags="-Ei"
  grep $flags -n -- "$2" "$CONTENT" 2>/dev/null | cut -d: -f1 | report_lines "$1"
}

scan "AWS access key id"            'AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}'
scan "private key (PEM/OpenSSH/PGP)" '-----BEGIN ([A-Z]+ )?PRIVATE KEY( BLOCK)?-----'
scan "GitHub token"                 'gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{22,}'
scan "Slack token"                  'xox[abprs]-[A-Za-z0-9-]{10,}'
scan "Google API key"               'AIza[0-9A-Za-z_-]{35}'
scan "Stripe secret key"            '[sr]k_live_[0-9a-zA-Z]{16,}'
scan "Anthropic API key"            'sk-ant-[A-Za-z0-9_-]{20,}'
scan "OpenAI-style API key"         'sk-(proj-)?[A-Za-z0-9_-]{32,}'
scan "npm auth token"              '_authToken[[:space:]]*=[[:space:]]*[A-Za-z0-9_-]{20,}'
scan "JWT"                          'eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'
scan "URL with embedded credentials" '[a-z][a-z0-9+.-]*://[^/[:space:]:@]+:[^/[:space:]@]{3,}@[^/[:space:]]+'

# Generic assignment of a literal to a suspicious name (environment reads and templates are discarded).
GENERIC='(password|passwd|pwd|secret|api[_-]?key|apikey|access[_-]?token|auth[_-]?token|private[_-]?key|client[_-]?secret)[[:alnum:]_]*[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"'[:space:]]{8,}["'"'"']'
grep -Ein -- "$GENERIC" "$CONTENT" 2>/dev/null |
  grep -Eiv '\$\{|<[A-Za-z_ -]+>|process\.env|os\.environ|getenv|ProcessInfo|ENV\[' |
  cut -d: -f1 | report_lines "literal assigned to a sensitive name (password/secret/api key/token)"

# Files that should never be committed (by name).
fl_diff_files "$DIFF" | while IFS= read -r f; do
  b="$(basename "$f")"
  case "$b" in
    .env.example|.env.sample|.env.template|.env.dist) ;;
    .env|.env.*|*.pem|*.p12|*.pfx|*.jks|*.keystore|id_rsa|id_dsa|id_ecdsa|id_ed25519)
      echo "$f:1  credentials/key file (by name)" >> "$OUT" ;;
  esac
done

if [ -s "$OUT" ]; then
  echo "secret-scan: possible secret in the commit (values deliberately omitted):" >&2
  sort -u "$OUT" | sed 's/^/  /' >&2
  echo "  Remove the secret and use Keychain / environment variables / a secrets manager." >&2
  echo "  Confirmed false positive: add 'fl:allow-secret' on that line (with the justification)." >&2
  exit 1
fi
exit 0
