#!/usr/bin/env bash
# record-paths.sh — the open-record query for state-in-the-path records.
#
# Spec: docs/superpowers/specs/2026-08-08-cadence-sentinels-s1-infrastructure-design.md §5.1
# Tests: tdad_tests/layer0_deterministic/test-record-contracts.sh (C3)
#
# Read-only. A sentinel may source this file.
#
# Why state lives in the filename. Constraint 7 says records are append-only,
# and editing a `status:` key from `parked` to `resumed` IS an in-place edit —
# the rule and the mechanism contradicted each other. So a transition writes a
# NEW file whose name carries the new state, and nothing is ever edited or
# deleted. "What is still open" then becomes a query over names rather than a
# scan of mutable frontmatter, and the two finally agree.
#
# It also keeps the Coda honest: resuming a parked thread is a *write* by the
# /coda command, not an *edit* of an existing record, so the read-only agent
# never needs a mutation path it is forbidden to have.

# records_open <dir> — records in <dir> that are still open, one path per line.
#
# A record is open unless it is itself a transition file (`*.resumed.md`,
# `*.superseded.md`) or some transition names it in `supersedes:`. Both tests
# matter: the first alone would report a superseded predecessor as open, and
# the second alone would report the transition file itself.
records_open() {
  local dir="$1" f base superseded

  [ -d "$dir" ] || return 0

  # Every filename claimed by a transition's `supersedes:` field.
  superseded="$(grep -hE '^supersedes:[[:space:]]*[^[:space:]]' "$dir"/*.md 2>/dev/null \
    | sed -E 's/^supersedes:[[:space:]]*//; s/[[:space:]]+$//' \
    | grep -v '^null$' || true)"

  for f in "$dir"/*.md; do
    [ -e "$f" ] || continue
    base="$(basename "$f")"

    case "$base" in
      README.md|*.resumed.md|*.superseded.md|*.resolved.md) continue ;;
    esac

    if [ -n "$superseded" ] && printf '%s\n' "$superseded" | grep -qxF "$base"; then
      continue
    fi

    printf '%s\n' "$f"
  done
}
