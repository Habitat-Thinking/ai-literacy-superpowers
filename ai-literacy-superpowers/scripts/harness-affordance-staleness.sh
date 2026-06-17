#!/usr/bin/env bash
set -euo pipefail
# harness-affordance-staleness.sh — the affordance review-staleness GC rule
# (spec 2026-06-16-affordance-review-and-staleness-design.md, step 6).
#
# Flags every non-example affordance (INCLUDING hooks — a hook's Identity /
# Audit trail can go stale too) whose `Last reviewed: YYYY-MM-DD` date is older
# than the threshold, or which has no valid date. Report-only: it prints
# findings and ALWAYS exits 0 (the fix is a human running
# /harness-affordance review <name>, a governance judgment, not a mechanical
# edit).
#
# Threshold precedence: --max-age-days flag > a HARNESS.md marker
# `<!-- affordance-review-threshold-days: N -->` > default 180 days.
# Age is computed in UTC so the day-count is machine-independent.
#
# Usage:
#   harness-affordance-staleness.sh [--max-age-days=N] [--today=YYYY-MM-DD] [project-dir]
# (--today overrides "now" so tests are hermetic.)

MAX_AGE_FLAG=""
TODAY_OVERRIDE=""
PROJECT_DIR="."
for arg in "$@"; do
  case "$arg" in
    --max-age-days=*) MAX_AGE_FLAG="${arg#--max-age-days=}" ;;
    --today=*) TODAY_OVERRIDE="${arg#--today=}" ;;
    --*) echo "Unknown flag: $arg" >&2; exit 2 ;;
    *) PROJECT_DIR="$arg" ;;
  esac
done

# Resolve HARNESS.md (repo root or .claude/ scaffold).
HARNESS=""
for cand in "$PROJECT_DIR/HARNESS.md" "$PROJECT_DIR/.claude/HARNESS.md"; do
  [ -f "$cand" ] && { HARNESS="$cand"; break; }
done
[ -n "$HARNESS" ] || { echo "No HARNESS.md under $PROJECT_DIR — nothing to check."; exit 0; }

# Extract the ## Affordances section body (heading to next ## heading).
SECTION=$(awk '
  /^## Affordances[[:space:]]*$/ { inside=1; next }
  /^## / { if (inside) exit }
  inside { print }
' "$HARNESS")
[ -n "$SECTION" ] || { echo "No ## Affordances section in $HARNESS — nothing to check."; exit 0; }

# Threshold: flag > HARNESS.md marker > default 180. The marker is read from
# the ## Affordances section only (its designated home), never the whole file.
MAX_AGE=180
marker=$(printf '%s\n' "$SECTION" | grep -oE 'affordance-review-threshold-days:[[:space:]]*[0-9]+' 2>/dev/null | grep -oE '[0-9]+' | head -1 || true)
[ -n "$marker" ] && MAX_AGE="$marker"
[ -n "$MAX_AGE_FLAG" ] && MAX_AGE="$MAX_AGE_FLAG"

# UTC-midnight epoch for a YYYY-MM-DD string; empty on parse failure OR when the
# parsed epoch does not round-trip back to the exact input (rejects
# calendar-impossible dates like 2026-02-30 identically on BSD and GNU). The
# explicit 00:00:00 pins midnight UTC on both date implementations — BSD
# `date -u -j -f '%Y-%m-%d'` alone fills the time-of-day from localtime-now.
date_to_epoch() {
  local epoch
  epoch=$(date -u -j -f '%Y-%m-%d %H:%M:%S' "$1 00:00:00" '+%s' 2>/dev/null \
        || date -u -d "$1 00:00:00 UTC" '+%s' 2>/dev/null || true)
  [ -n "$epoch" ] || return 0
  # Round-trip: the epoch must reformat to the same calendar date.
  local back
  back=$(date -u -j -f '%s' "$epoch" '+%Y-%m-%d' 2>/dev/null \
       || date -u -d "@$epoch" '+%Y-%m-%d' 2>/dev/null || true)
  [ "$back" = "$1" ] && printf '%s' "$epoch"
  # Always succeed: failure is signalled by empty output, never a non-zero
  # exit (which would abort the caller's `x=$(date_to_epoch ...)` under set -e).
  return 0
}

TODAY="${TODAY_OVERRIDE:-$(date -u '+%Y-%m-%d')}"
TODAY_EPOCH=$(date_to_epoch "$TODAY")
[ -n "$TODAY_EPOCH" ] || { echo "Could not parse today's date ($TODAY)." >&2; exit 0; }

# Emit one row per non-example entry: name<TAB>last_reviewed (date may be empty).
# Classification is by the example marker only — hooks are included.
ENTRIES=$(printf '%s\n' "$SECTION" | awk '
  function flush() {
    if (name != "" && !is_example) printf "%s\t%s\n", name, last
  }
  /^### / { flush(); name=$0; sub(/^### +/,"",name); sub(/[[:space:]]+$/,"",name); is_example=0; last=""; next }
  /^[[:space:]]*<!--[[:space:]]*affordance-example[[:space:]]*-->[[:space:]]*$/ { is_example=1 }
  /^- \*\*Last reviewed\*\*:/ { last=$0; sub(/^- \*\*Last reviewed\*\*:[[:space:]]*/,"",last); sub(/[[:space:]].*$/,"",last) }
  END { flush() }
')
[ -n "$ENTRIES" ] || { echo "No reviewable affordances (only examples, or section empty)."; exit 0; }

findings=""
while IFS=$'\t' read -r name last; do
  [ -z "$name" ] && continue
  if ! printf '%s' "$last" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
    findings+="UNDATED: affordance '$name' has no valid Last reviewed date — review overdue"$'\n'
    continue
  fi
  reviewed_epoch=$(date_to_epoch "$last")
  if [ -z "$reviewed_epoch" ]; then
    findings+="UNDATED: affordance '$name' Last reviewed '$last' is not a parseable date"$'\n'
    continue
  fi
  age_days=$(( (TODAY_EPOCH - reviewed_epoch) / 86400 ))
  if [ "$age_days" -lt 0 ]; then
    findings+="FUTURE: affordance '$name' Last reviewed $last is in the future — not a credible review date"$'\n'
  elif [ "$age_days" -gt "$MAX_AGE" ]; then
    findings+="STALE: affordance '$name' last reviewed $last ($age_days days ago; threshold $MAX_AGE)"$'\n'
  fi
done <<< "$ENTRIES"

if [ -n "$findings" ]; then
  printf '%s' "$findings" | LC_ALL=C sort
else
  echo "OK: all affordances reviewed within $MAX_AGE days."
fi
exit 0
