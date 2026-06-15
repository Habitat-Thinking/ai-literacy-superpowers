#!/usr/bin/env bash
# regenerate-reflection-log.sh
#
# Rewrite the generated aggregate REFLECTION_LOG.md from the per-entry
# fragments in reflections/active/ (spec
# 2026-06-15-reflection-fragments-migration-design.md). Fragments are the
# source of truth; the aggregate is a committed, union-merged view.
# Deterministic and idempotent, so a messy union merge self-heals on rerun.
#
# Usage: regenerate-reflection-log.sh [active-dir] [output-file]
# Defaults: reflections/active  REFLECTION_LOG.md ; run from project root.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/reflection-log-helpers.sh"

ACTIVE_DIR="${1:-reflections/active}"
OUT="${2:-REFLECTION_LOG.md}"

if [ ! -d "$ACTIVE_DIR" ]; then
  echo "No $ACTIVE_DIR; nothing to regenerate." >&2
  exit 0
fi

regenerate_log "$ACTIVE_DIR" "$OUT"

count=$(fragment_paths "$ACTIVE_DIR" | grep -c . || true)
echo "Regenerated $OUT from $count fragment(s) in $ACTIVE_DIR."
