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
# pattern). hook-mode affordances are skipped (their Permission is a
# hooks.<Trigger> registration, not an allowlist pattern). Example entries
# carrying <!-- affordance-example --> are skipped.
#
# Reads PROJECT settings only (.claude/settings.json, .claude/settings.local.json)
# for determinism; the user layer is not read here. The check is UNVERIFIED
# (exit 0, no finding) unless both: a non-example affordance exists, and a
# readable allowlist exists.
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

# Emit one TSV row per real (non-example, non-hook) affordance:
#   OK<TAB>name<TAB>pattern        — a well-formed single pattern
#   DIAG<TAB>name<TAB>reason       — Permission could not be parsed cleanly
# Example-marked and hook-mode entries are dropped entirely.
PARSED=$(printf '%s\n' "$SECTION" | awk '
  function flush() {
    if (name == "" || is_example || mode == "hook") { return }
    if (perm_raw == "") { printf "DIAG\t%s\tno Permission field\n", name; return }
    # The pattern is the first backticked token; anything before the first
    # " (" parenthetical that carries a comma signals multiple patterns.
    head = perm_raw
    p = index(head, " (")
    if (p > 0) head = substr(head, 1, p - 1)
    if (index(head, ",") > 0) {
      printf "DIAG\t%s\tmultiple permission patterns in one field (split into separate affordances)\n", name
      return
    }
    if (match(perm_raw, /`[^`]+`/)) {
      pat = substr(perm_raw, RSTART + 1, RLENGTH - 2)
      printf "OK\t%s\t%s\n", name, pat
    } else {
      printf "DIAG\t%s\tPermission has no `pattern` token\n", name
    }
  }
  /^### / { flush(); name = $0; sub(/^### +/, "", name); sub(/[[:space:]]+$/, "", name); is_example=0; mode=""; perm_raw="" ; next }
  /affordance-example/ { is_example=1 }
  /^- \*\*Mode\*\*:/ { m=$0; sub(/^- \*\*Mode\*\*:[[:space:]]*/, "", m); split(m, a, " "); mode=a[1] }
  /^- \*\*Permission\*\*:/ { perm_raw=$0; sub(/^- \*\*Permission\*\*:[[:space:]]*/, "", perm_raw) }
  END { flush() }
')

# A real affordance exists?
if ! printf '%s\n' "$PARSED" | grep -q '^OK\|^DIAG'; then
  unverified "no real affordances declared (only examples, or section empty)"
fi

# Build the allowlist: union of .permissions.allow[] across readable project
# settings files, de-duplicated, C-sorted.
ALLOW_FILES=()
for f in "$PROJECT_DIR/.claude/settings.json" "$PROJECT_DIR/.claude/settings.local.json"; do
  [ -f "$f" ] && ALLOW_FILES+=("$f")
done
[ "${#ALLOW_FILES[@]}" -gt 0 ] || unverified "no readable project settings allowlist (.claude/settings*.json)"

ALLOWLIST=$(jq -r '.permissions.allow[]?' "${ALLOW_FILES[@]}" 2>/dev/null | LC_ALL=C sort -u)

contains_pattern() {
  printf '%s\n' "$ALLOWLIST" | grep -qxF "$1"
}

failed=0

if [ "$DIRECTION" = "blocking" ]; then
  # Surface parse diagnostics first (non-blocking), then real gaps (blocking).
  while IFS=$'\t' read -r kind name extra; do
    [ -z "$kind" ] && continue
    if [ "$kind" = "DIAG" ]; then
      echo "DIAGNOSTIC: affordance '$name' — $extra"
    fi
  done <<< "$PARSED"
  while IFS=$'\t' read -r kind name pat; do
    [ "$kind" = "OK" ] || continue
    if ! contains_pattern "$pat"; then
      echo "FAIL: affordance '$name' declares Permission $pat with no matching allowlist entry"
      failed=1
    fi
  done <<< "$PARSED"
  if [ "$failed" -eq 0 ]; then
    echo "OK: every declared affordance has a matching permission."
  fi
  exit "$failed"
else
  # advisory: allowlist patterns with no declared affordance. Never fails.
  declared=$(printf '%s\n' "$PARSED" | awk -F '\t' '$1=="OK"{print $3}' | LC_ALL=C sort -u)
  count=0
  while IFS= read -r pat; do
    [ -z "$pat" ] && continue
    if ! printf '%s\n' "$declared" | grep -qxF "$pat"; then
      echo "ADVISORY: permission $pat has no declared affordance"
      count=$((count + 1))
    fi
  done <<< "$ALLOWLIST"
  if [ "$count" -eq 0 ]; then
    echo "OK: every permission has a declared affordance."
  fi
  exit 0
fi
