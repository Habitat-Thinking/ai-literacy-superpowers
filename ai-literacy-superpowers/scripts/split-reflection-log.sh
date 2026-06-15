#!/usr/bin/env bash
# split-reflection-log.sh
#
# One-time migration (spec 2026-06-15-reflection-fragments-migration-design.md):
# split a monolithic REFLECTION_LOG.md into per-entry fragments under
# reflections/active/<Date>-<slug>.md (slug from the Task field; numeric
# suffix on same-date collisions), preserving Promoted lines, then
# regenerate the aggregate. reflections/archive/ is untouched. Idempotent:
# self-skips if reflections/active/ already has fragments. Run from root.
#
# Usage: split-reflection-log.sh [--dry-run=true|false]

set -euo pipefail

DRY_RUN="false"
for arg in "$@"; do
  case "$arg" in
    --dry-run=true) DRY_RUN="true" ;;
    --dry-run=false) DRY_RUN="false" ;;
    *) echo "Unknown arg: $arg" >&2; exit 2 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/reflection-log-helpers.sh"

LOG="REFLECTION_LOG.md"
ACTIVE_DIR="reflections/active"

[ -f "$LOG" ] || { echo "No $LOG in $(pwd); nothing to migrate." >&2; exit 0; }

if [ -d "$ACTIVE_DIR" ] && [ -n "$(fragment_paths "$ACTIVE_DIR")" ]; then
  echo "$ACTIVE_DIR already has fragments; migration has run before. Skipping."
  exit 0
fi

# Pass 1: split into fragments, collecting (filename, body) pairs.
# `seen` is a newline-delimited set of claimed names — associative arrays
# are avoided for bash 3.2 (macOS default) compatibility.
names=()
bodies=()
seen=$'\n'
entry=""
while IFS= read -r line; do
  if [ "$line" = "---ENTRY---" ]; then
    date_field=$(extract_field "$entry" "Date")
    task_field=$(extract_field "$entry" "Task")
    [ -n "$date_field" ] || date_field="undated"
    slug=$(slugify "$task_field")
    base="${date_field}-${slug}"
    name="$base"
    n=2
    while [ "$seen" != "${seen/$'\n'$name$'\n'/}" ]; do
      name="${base}-${n}"
      n=$((n + 1))
    done
    seen="${seen}${name}"$'\n'
    names+=("$name")
    bodies+=("$entry")
    entry=""
  else
    entry+="${line}"$'\n'
  fi
done < <(split_entries "$LOG")

if [ "${#names[@]}" -eq 0 ]; then
  echo "No entries found in $LOG; nothing to migrate."
  exit 0
fi

if [ "$DRY_RUN" = "true" ]; then
  echo "Would write ${#names[@]} fragment(s) to $ACTIVE_DIR (dry run):"
  for name in "${names[@]}"; do echo "  $ACTIVE_DIR/${name}.md"; done
  exit 0
fi

# Pass 2: write fragments (body only, no leading separator, blank-trimmed).
mkdir -p "$ACTIVE_DIR"
for i in "${!names[@]}"; do
  printf '%s' "${bodies[$i]}" | trim_blanks > "$ACTIVE_DIR/${names[$i]}.md"
done

# Pass 3: regenerate the aggregate from the fragments.
regenerate_log "$ACTIVE_DIR" "$LOG"

echo "Migrated ${#names[@]} entries into $ACTIVE_DIR; regenerated $LOG."
