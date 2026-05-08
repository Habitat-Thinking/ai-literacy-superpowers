#!/usr/bin/env bash
set -euo pipefail
#
# rewrite-docs-links.sh — one-shot link rewriter for docs reorgs.
#
# Reads a move-map TSV from $1 with `<old-path>\t<new-path>` rows.
# Rewrites every markdown link in the repo whose left-hand-side matches
# an old-path. Idempotent — running the script twice with the same
# move-map produces the same output as running it once.
#
# Usage: rewrite-docs-links.sh <move-map.tsv>
#
# Skips: .git/, node_modules/, observability/archive/, reflections/archive/,
# docs/superpowers/specs/, docs/superpowers/plans/ (may quote old paths in
# their "before" examples), docs/superpowers/objections/ and stories/
# (historical), any file named CHANGELOG.md (historical PR descriptions).

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <move-map.tsv>" >&2
  exit 2
fi

map="$1"

if [[ ! -f "$map" ]]; then
  echo "Error: move-map not found: $map" >&2
  exit 2
fi

# Read the move-map and apply each rewrite to every matching markdown file.
# Outer loop: each row in the move-map.
# Inner loop: every markdown file in the repo (excluding archived/historical trees).
while IFS=$'\t' read -r old new; do
  if [[ -z "$old" || -z "$new" ]]; then
    continue
  fi

  # Escape regex metacharacters in $old before passing to sed.
  # grep -qF above already treats it as a fixed string, so $old is unchanged there.
  old_pat=$(printf '%s\n' "$old" | sed 's/[]\.[*^${}()|+?]/\\&/g')

  # Use | as the sed delimiter since paths contain forward slashes.
  while IFS= read -r -d '' file; do
    if grep -qF "$old" "$file"; then
      # No signal trap installed: this is a one-shot migration tool. If killed
      # mid-rewrite, .md.tmp orphans may remain — they are harmless because find
      # filters by name "*.md" and the script is idempotent on re-run.
      sed "s|$old_pat|$new|g" "$file" >"$file.tmp" && mv "$file.tmp" "$file"
    fi
  done < <(find . -type f -name "*.md" \
    -not -path "./.git/*" \
    -not -path "./node_modules/*" \
    -not -path "./observability/archive/*" \
    -not -path "./reflections/archive/*" \
    -not -path "./docs/superpowers/specs/*" \
    -not -path "./docs/superpowers/objections/*" \
    -not -path "./docs/superpowers/stories/*" \
    -not -path "./docs/superpowers/plans/*" \
    -not -name "CHANGELOG.md" \
    -print0)
done <"$map"
