#!/usr/bin/env bash
set -euo pipefail
# harness-affordance-check.sh — the affordance/permission chained constraints
# (spec 2026-06-16-affordance-chained-constraints-design.md, steps 4+5).
#
# Two directions, one script:
#   --direction=blocking  affordance-without-permission. Every non-example,
#                         non-hook affordance's Permission pattern must appear
#                         in the permissions allowlist. Exits 1 on a gap.
#   --direction=advisory  permission-without-affordance. Every allowlist
#                         pattern should have a declared affordance. Warns;
#                         always exits 0.
#
# Matching is STRING EQUALITY on the permission pattern (one affordance per
# pattern). Hook-mode affordances are skipped (their Permission is a
# hooks.<Trigger> registration, not an allowlist pattern). Example entries
# carrying the <!-- affordance-example --> marker are skipped.
#
# Reads PROJECT settings only (.claude/settings.json, .claude/settings.local.json)
# for determinism. The check is UNVERIFIED (exit 0, no finding) unless both: a
# real (non-example) affordance exists, and a readable, valid allowlist exists.
#
# Usage: harness-affordance-check.sh [--direction=blocking|advisory] [project-dir]

DIRECTION="blocking"
PROJECT_DIR="."
for arg in "$@"; do
  case "$arg" in
    --direction=blocking) DIRECTION="blocking" ;;
    --direction=advisory) DIRECTION="advisory" ;;
    --direction=*) echo "Unknown --direction (use blocking|advisory)" >&2; exit 2 ;;
    *) PROJECT_DIR="$arg" ;;
  esac
done

unverified() { echo "skipped (unverified): $1"; exit 0; }

command -v jq >/dev/null 2>&1 || unverified "jq is not installed (brew install jq)"

# Resolve HARNESS.md (repo root or .claude/ scaffold).
HARNESS=""
for cand in "$PROJECT_DIR/HARNESS.md" "$PROJECT_DIR/.claude/HARNESS.md"; do
  [ -f "$cand" ] && { HARNESS="$cand"; break; }
done
[ -n "$HARNESS" ] || unverified "no HARNESS.md under $PROJECT_DIR"

# Extract the ## Affordances section body (heading to next ## heading).
SECTION=$(awk '
  /^## Affordances[[:space:]]*$/ { inside=1; next }
  /^## / { if (inside) exit }
  inside { print }
' "$HARNESS")
[ -n "$SECTION" ] || unverified "no ## Affordances section in $HARNESS"

# Parse entries into TSV rows:
#   OK<TAB>name<TAB>pattern   — one well-formed permission pattern
#   DIAG<TAB>name<TAB>reason  — Permission could not be parsed to one pattern
#   DECL<TAB>pattern          — every permission-shaped token declared (incl.
#                               multi-pattern entries), used by the advisory set
# Example-marked and hook entries are dropped entirely. A token is
# "permission-shaped" if it looks like Word(...), mcp__..., or hooks.... —
# annotation paths like `.claude/settings.local.json` are ignored.
PARSED=$(printf '%s\n' "$SECTION" | awk '
  function is_pattern(t) { return (t ~ /^[A-Za-z_]+\(/ || t ~ /^mcp__/ || t ~ /^hooks\./) }
  function flush(   i, n, tmp, tok, is_hook) {
    if (name == "" || is_example) return
    n = 0; delete pats
    tmp = perm_raw
    while (match(tmp, /`[^`]+`/)) {
      tok = substr(tmp, RSTART + 1, RLENGTH - 2)
      tmp = substr(tmp, RSTART + RLENGTH)
      if (is_pattern(tok)) { n++; pats[n] = tok }
    }
    is_hook = (mode == "hook")
    for (i = 1; i <= n; i++) if (pats[i] ~ /^hooks\./) is_hook = 1
    if (is_hook) return
    if (n == 0) { printf "DIAG\t%s\tPermission has no recognisable pattern\n", name; return }
    if (n > 1) {
      printf "DIAG\t%s\tmultiple permission patterns in one field (split into separate affordances)\n", name
      for (i = 1; i <= n; i++) printf "DECL\t%s\n", pats[i]
      return
    }
    printf "OK\t%s\t%s\n", name, pats[1]
    printf "DECL\t%s\n", pats[1]
  }
  /^### / { flush(); name = $0; sub(/^### +/, "", name); sub(/[[:space:]]+$/, "", name); is_example = 0; mode = ""; perm_raw = "" ; next }
  /<!--[^>]*affordance-example[^>]*-->/ { is_example = 1 }
  /^- \*\*Mode\*\*:/ { m = $0; sub(/^- \*\*Mode\*\*:[[:space:]]*/, "", m); split(m, a, " "); mode = a[1] }
  /^- \*\*Permission\*\*:/ { perm_raw = $0; sub(/^- \*\*Permission\*\*:[[:space:]]*/, "", perm_raw) }
  END { flush() }
')

# A real affordance exists? (any OK or DIAG row — POSIX grep, no GNU \|)
if ! printf '%s\n' "$PARSED" | grep -qE '^(OK|DIAG)	'; then
  unverified "no real affordances declared (only examples, or section empty)"
fi

# Build the allowlist: union of .permissions.allow[] across readable, VALID
# project settings files, de-duplicated, C-sorted. An invalid settings file
# goes unverified rather than silently dropping its grants.
ALLOW_FILES=()
for f in "$PROJECT_DIR/.claude/settings.json" "$PROJECT_DIR/.claude/settings.local.json"; do
  if [ -f "$f" ]; then
    jq empty "$f" >/dev/null 2>&1 || unverified "settings file $f is not valid JSON"
    ALLOW_FILES+=("$f")
  fi
done
[ "${#ALLOW_FILES[@]}" -gt 0 ] || unverified "no readable project settings allowlist (.claude/settings*.json)"

ALLOWLIST=$(jq -r '.permissions.allow[]?' "${ALLOW_FILES[@]}" 2>/dev/null | LC_ALL=C sort -u)

in_allowlist() { printf '%s\n' "$ALLOWLIST" | grep -qxF "$1"; }

if [ "$DIRECTION" = "blocking" ]; then
  diags=""
  fails=""
  while IFS=$'\t' read -r kind name extra; do
    case "$kind" in
      DIAG) diags+="DIAGNOSTIC: affordance '$name' — $extra"$'\n' ;;
      OK)
        if ! in_allowlist "$extra"; then
          fails+="FAIL: affordance '$name' declares Permission $extra with no matching allowlist entry"$'\n'
        fi
        ;;
    esac
  done <<< "$PARSED"
  # Deterministic order regardless of HARNESS.md entry order.
  [ -n "$diags" ] && printf '%s' "$diags" | LC_ALL=C sort
  if [ -n "$fails" ]; then
    printf '%s' "$fails" | LC_ALL=C sort
    exit 1
  fi
  echo "OK: every declared affordance has a matching permission."
  exit 0
else
  # advisory: allowlist patterns with no declared affordance. Never fails.
  declared=$(printf '%s\n' "$PARSED" | awk -F '\t' '$1=="DECL"{print $2}' | LC_ALL=C sort -u)
  findings=""
  while IFS= read -r pat; do
    [ -z "$pat" ] && continue
    printf '%s\n' "$declared" | grep -qxF "$pat" || findings+="ADVISORY: permission $pat has no declared affordance"$'\n'
  done <<< "$ALLOWLIST"
  if [ -n "$findings" ]; then
    printf '%s' "$findings" | LC_ALL=C sort
  else
    echo "OK: every permission has a declared affordance."
  fi
  exit 0
fi
