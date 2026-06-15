#!/usr/bin/env bash
# reflection-log-helpers.sh
#
# Shared helpers for reflection-log archival scripts.
# Sourced by archive-promoted-reflections.sh, migrate-reflection-log.sh,
# regenerate-reflection-log.sh, split-reflection-log.sh, and read-side
# filtering callers.
#
# Storage model (see docs/superpowers/specs/
# 2026-06-15-reflection-fragments-migration-design.md):
#   - SOURCE OF TRUTH = per-entry fragments in reflections/active/<date>-<slug>.md,
#     one entry body per file, no leading `---` separator.
#   - GENERATED VIEW  = REFLECTION_LOG.md, a deterministic, committed,
#     union-merged aggregate regenerated from the active fragments.
# Readers consume the aggregate; writers write fragments and regenerate.
#
# Functions defined here:
# - split_entries <log-path>      → emit each entry preceded by `---ENTRY---`
# - parse_promoted <entry-text>   → echo Promoted RHS or empty if absent
# - extract_field <entry> <name>  → echo the value of `- **<name>**: ...`
# - bounded_entries <log> <n> <m> → return entries within last n OR last m days
# - resolve_year <entry-text>     → echo YYYY from the entry's Date field
# - slugify <text>                → echo a kebab-case slug (≤6 words)
# - fragment_paths [active-dir]   → list fragment files in Date-then-name order
# - default_reflection_header     → print the canonical aggregate header
# - regenerate_log [active] [out] → rewrite the aggregate from fragments

set -euo pipefail

# split_entries: emit log entries one at a time, separated by `---ENTRY---`
# markers (so callers can iterate without running awk per call).
split_entries() {
  local log_path="$1"
  awk '
    /^---$/ {
      if (in_entry) { print "---ENTRY---" }
      in_entry = 1
      next
    }
    /^# / && !in_entry { next }
    in_entry { print }
    END {
      if (in_entry) print "---ENTRY---"
    }
  ' "$log_path"
}

# parse_promoted: extract the right-hand side of a Promoted line.
# Returns empty string if the line is absent or malformed (per grammar).
#
# Grammar (from spec):
#   PROMOTED_LINE := "- **Promoted**: " DATE " → " RHS
#   DATE          := YYYY-MM-DD
#   RHS           := AGENTS_FORM | HARNESS_FORM | CLOSURE_FORM | SUPERSEDE_FORM
parse_promoted() {
  local entry="$1"
  # Match: - **Promoted**: YYYY-MM-DD → <rhs>
  local re='^- \*\*Promoted\*\*: ([0-9]{4}-[0-9]{2}-[0-9]{2}) → (.+)$'
  while IFS= read -r line; do
    if [[ "$line" =~ $re ]]; then
      local rhs="${BASH_REMATCH[2]}"
      # Trim trailing whitespace — protects downstream grep verification
      # against curator typos that add invisible trailing spaces.
      rhs="${rhs%"${rhs##*[![:space:]]}"}"
      echo "$rhs"
      return 0
    fi
  done <<< "$entry"
  echo ""
}

# extract_field: emit the value of "- **<name>**: <value>" line.
# Returns empty if absent.
extract_field() {
  local entry="$1"
  local name="$2"
  local re="^- \*\*${name}\*\*: (.+)$"
  while IFS= read -r line; do
    if [[ "$line" =~ $re ]]; then
      echo "${BASH_REMATCH[1]}"
      return 0
    fi
  done <<< "$entry"
  echo ""
}

# resolve_year: extract YYYY from the entry's Date field.
resolve_year() {
  local entry="$1"
  local date; date=$(extract_field "$entry" "Date")
  echo "${date%%-*}"
}

# bounded_entries: return entries within the more inclusive of:
#   - the last N entries (by Date field, descending)
#   - entries within the last M days
# Output uses the same `---ENTRY---` separator as split_entries.
bounded_entries() {
  local log_path="$1"
  local max_count="$2"
  local max_days="$3"
  local cutoff_epoch
  cutoff_epoch=$(date -j -v-"${max_days}"d '+%s' 2>/dev/null || date -d "-${max_days} days" '+%s')

  local entries; entries=$(split_entries "$log_path")
  local entry=""

  # Collect candidate entries with their dates; sort descending; clip by max_count
  # but include any entry whose date is newer than cutoff regardless.
  local tmpfile; tmpfile=$(mktemp)
  while IFS= read -r line; do
    if [ "$line" = "---ENTRY---" ]; then
      local entry_date entry_epoch
      entry_date=$(extract_field "$entry" "Date")
      entry_epoch=$(date -j -f '%Y-%m-%d' "$entry_date" '+%s' 2>/dev/null \
                    || date -d "$entry_date" '+%s')
      printf '%s\t%s\n' "$entry_epoch" "$entry" >> "$tmpfile"
      entry=""
    else
      entry+="${line}"$'\n'
    fi
  done <<< "$entries"

  # Sort descending by epoch, then output more inclusive of count or day window.
  sort -t $'\t' -k1,1nr "$tmpfile" | awk -F '\t' \
    -v max_count="$max_count" -v cutoff="$cutoff_epoch" '
    {
      epoch = $1
      gsub(/\\n/, "\n", $2)
      if (NR <= max_count || epoch >= cutoff) {
        print $2
        print "---ENTRY---"
      }
    }'
  rm -f "$tmpfile"
}

# verify_rhs: return 0 if the Promoted line's right-hand side resolves to
# actual content in the current tree (AGENTS.md / HARNESS.md) or is a
# closure form. Return 1 otherwise.
verify_rhs() {
  local rhs="$1"
  case "$rhs" in
    AGENTS.md*\"*\")
      local quoted; quoted=$(echo "$rhs" | sed -E 's/^.*"(.*)".*$/\1/')
      [ -f AGENTS.md ] && grep -qF "$quoted" AGENTS.md
      ;;
    HARNESS.md:*)
      local cname; cname=$(echo "$rhs" | sed -E 's/^HARNESS.md:[[:space:]]*//')
      [ -f HARNESS.md ] && grep -qF "### $cname" HARNESS.md
      ;;
    aged-out*|"no promotion"*|superseded\ by\ *)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# propose_for_entry: emit a markdown block proposing a Promoted tag for one entry.
# Used by migrate-reflection-log.sh.
# Caller must set TODAY in the calling shell.
propose_for_entry() {
  local entry="$1"
  local cutoff="$2"
  local date_field surprise proposal entry_epoch
  date_field=$(extract_field "$entry" "Date")
  surprise=$(extract_field "$entry" "Surprise")
  proposal=$(extract_field "$entry" "Proposal")
  entry_epoch=$(date -j -f '%Y-%m-%d' "$date_field" '+%s' 2>/dev/null \
                || date -d "$date_field" '+%s')

  echo "---"
  echo ""
  echo "## Entry dated $date_field"
  echo ""

  # Already has a Promoted line — skip.
  if [ -n "$(parse_promoted "$entry")" ]; then
    echo "Already promoted; nothing to propose."
    return 0
  fi

  # Cross-reference surprise/proposal text against AGENTS.md
  local agents_match=""
  if [ -f AGENTS.md ] && [ -n "$surprise$proposal" ]; then
    local kw; kw=$(echo "$surprise" | awk '{print $1, $2, $3}')
    if [ -n "$kw" ] && grep -qF "$kw" AGENTS.md; then
      agents_match="$kw"
    fi
  fi
  if [ -n "$agents_match" ]; then
    echo "**Likely-promoted to AGENTS.md** (keyword \"$agents_match\" matches)."
    echo ""
    echo "Proposed line for the entry:"
    echo ""
    echo "    - **Promoted**: $TODAY → AGENTS.md STYLE: \"$agents_match\""
    echo ""
    return 0
  fi

  # Cross-reference Constraint field against HARNESS.md
  local constraint; constraint=$(extract_field "$entry" "Constraint")
  if [ -f HARNESS.md ] && [ -n "$constraint" ] && [ "$constraint" != "none" ]; then
    if grep -qF "$constraint" HARNESS.md; then
      echo "**Likely-promoted to HARNESS.md** (constraint \"$constraint\" matches)."
      echo ""
      echo "Proposed line:"
      echo ""
      echo "    - **Promoted**: $TODAY → HARNESS.md: $constraint"
      echo ""
      return 0
    fi
  fi

  # Aged-out check
  if [ "$entry_epoch" -lt "$cutoff" ]; then
    echo "**Single-instance, aged-out** (older than threshold; no overlap found)."
    echo ""
    echo "Proposed line:"
    echo ""
    echo "    - **Promoted**: $TODAY → aged-out, no promotion warranted"
    echo ""
    return 0
  fi

  # Recent, no overlap → leave alone
  echo "Recent (within threshold), no overlap. Recommend leaving untouched."
  echo ""
}

# ---------------------------------------------------------------------------
# Fragment model: per-entry source of truth + generated aggregate.
# ---------------------------------------------------------------------------

# slugify: turn a Task line into a filesystem-safe kebab-case slug (≤6 words).
# Used to name reflection fragment files.
slugify() {
  local text="$1"
  local slug
  slug=$(printf '%s' "$text" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//' \
    | cut -d- -f1-6)
  # Fall back to a stable placeholder if the task had no usable characters.
  [ -n "$slug" ] && printf '%s' "$slug" || printf 'entry'
}

# trim_blanks: strip leading and trailing blank lines from stdin, emitting
# the inner content with a single trailing newline. Keeps fragment bodies and
# the regenerated aggregate free of the stray blank lines that the monolith's
# `---`/blank-line separators would otherwise leave behind.
trim_blanks() {
  awk '
    { lines[NR] = $0 }
    END {
      start = 1
      while (start <= NR && lines[start] ~ /^[[:space:]]*$/) start++
      end = NR
      while (end >= start && lines[end] ~ /^[[:space:]]*$/) end--
      for (i = start; i <= end; i++) print lines[i]
    }'
}

# fragment_paths: list active reflection fragments in deterministic order.
# Filenames are date-prefixed (YYYY-MM-DD-slug.md), so a plain byte sort
# yields Date order then slug order — the aggregate's canonical ordering.
fragment_paths() {
  local active_dir="${1:-reflections/active}"
  [ -d "$active_dir" ] || return 0
  find "$active_dir" -maxdepth 1 -name '*.md' 2>/dev/null | LC_ALL=C sort
}

# default_reflection_header: the canonical header for a freshly generated
# aggregate (used when no existing REFLECTION_LOG.md is present to inherit a
# header from). The example entry stays indented inside the comment so it
# never matches the `^---$` / `^- **Date**:` greps that count real entries.
default_reflection_header() {
  cat <<'HEADER'
# Reflection Log

<!-- GENERATED FILE — do not edit by hand.

     This file is a deterministic aggregate of the per-entry fragments in
     reflections/active/. Add a reflection with /reflect (which writes a
     fragment and regenerates this file); never append here directly.
     Regenerate with: scripts/regenerate-reflection-log.sh

     Each entry below mirrors one fragment. Entry format:

     ---

     - **Date**: YYYY-MM-DD
     - **Agent**: integration-agent
     - **Task**: [one-sentence summary]
     - **Surprise**: [anything unexpected]
     - **Proposal**: [pattern or gotcha for AGENTS.md, or "none"]
     - **Improvement**: [what would make the pipeline smoother]
     - **Signal**: [context | instruction | workflow | failure | none]
     - **Constraint**: [proposed constraint, or "none"]
-->

HEADER
}

# regenerate_log: rewrite the aggregate REFLECTION_LOG.md from the active
# fragments. Deterministic and idempotent. Preserves the existing header
# (everything before the first `^---$`) so a project's customised header
# survives; falls back to default_reflection_header for a fresh file.
regenerate_log() {
  local active_dir="${1:-reflections/active}"
  local out="${2:-REFLECTION_LOG.md}"
  local tmp="${out}.regen.tmp"

  if [ -f "$out" ] && grep -q '^---$' "$out"; then
    awk '/^---$/{exit} {print}' "$out" > "$tmp"
  else
    default_reflection_header > "$tmp"
  fi

  local f
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    {
      echo "---"
      echo ""
      # Normalise each fragment to a clean body with a single trailing
      # newline, then add one blank line before the next separator —
      # robust to however the fragment was authored.
      trim_blanks < "$f"
      printf '\n'
    } >> "$tmp"
  done < <(fragment_paths "$active_dir")

  mv "$tmp" "$out"
}
