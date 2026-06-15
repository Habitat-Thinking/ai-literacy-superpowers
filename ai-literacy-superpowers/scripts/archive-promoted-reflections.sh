#!/usr/bin/env bash
# archive-promoted-reflections.sh
#
# Path 1 archival (specs 2026-04-30-reflection-log-archival-design.md +
# 2026-06-15-reflection-fragments-migration-design.md): move each active
# fragment with a verified `Promoted` line to reflections/archive/<YYYY>.md,
# delete it, and regenerate the aggregate REFLECTION_LOG.md. Run from root.
#
# Usage: archive-promoted-reflections.sh [--dry-run=true|false]

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
ARCHIVE_DIR="reflections/archive"
TODAY=$(date '+%Y-%m-%d')

if [ ! -d "$ACTIVE_DIR" ] || [ -z "$(fragment_paths "$ACTIVE_DIR")" ]; then
  echo "No fragments in $ACTIVE_DIR; nothing to do." >&2
  exit 0
fi

mkdir -p "$ARCHIVE_DIR"

# Pass 1: identify fragments to archive (those with a verified Promoted line).
to_archive=()
while IFS= read -r frag; do
  [ -n "$frag" ] || continue
  entry=$(cat "$frag")
  rhs=$(parse_promoted "$entry")
  if [ -n "$rhs" ]; then
    if verify_rhs "$rhs"; then
      to_archive+=("$frag")
    else
      echo "WARN: Promoted line did not verify; keeping fragment $frag" >&2
    fi
  fi
done < <(fragment_paths "$ACTIVE_DIR")

if [ "${#to_archive[@]}" -eq 0 ]; then
  echo "No promoted entries to archive."
  exit 0
fi

if [ "$DRY_RUN" = "true" ]; then
  echo "Would archive ${#to_archive[@]} fragment(s) (dry run)."
  exit 0
fi

# Pass 2: append to year archives, then delete the source fragments.
for frag in "${to_archive[@]}"; do
  entry=$(cat "$frag")
  year=$(resolve_year "$entry")
  archive_path="$ARCHIVE_DIR/$year.md"
  if [ ! -f "$archive_path" ]; then
    {
      echo "# Reflection Archive — $year"
      echo ""
      echo "Entries archived from \`REFLECTION_LOG.md\` after promotion."
      echo ""
    } > "$archive_path"
  fi
  {
    echo "---"
    echo ""
    printf '%s' "$entry"
    printf '\n'
    echo "- **Archived**: $TODAY (auto, Path 1)"
    echo ""
  } >> "$archive_path"
  rm -f "$frag"
done

# Pass 3: regenerate the aggregate from the remaining fragments.
regenerate_log "$ACTIVE_DIR" "$LOG"

remaining=$(fragment_paths "$ACTIVE_DIR" | grep -c . || true)
echo "Archived ${#to_archive[@]} entries; ${remaining} fragment(s) remain in $ACTIVE_DIR."
