#!/usr/bin/env bash

# Strict mode, applied only when this file is EXECUTED. `return` succeeds
# solely inside a sourced context, so the `set` is skipped when a hook script
# or a sentinel sources us. That matters: `set` mutates the CALLER's shell, and
# a library whose whole purpose is being safely sourceable must not impose
# -e/-u/-o pipefail on whatever sourced it. Satisfies the "Shell scripts use
# strict mode" constraint (HARNESS.md) in the only context where strict mode
# is meaningful for a library.
(return 0 2>/dev/null) || set -euo pipefail
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
# A record is open unless it is itself a transition file — `*.resumed.md`,
# `*.superseded.md`, or `*.resolved.md`, the last being the consultation
# record's transition — or some transition names it in `supersedes:`. Both tests
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

# records_latest <dir> — the CURRENT state of every record chain, one path per
# line: the newest file in each supersession chain, transitions included.
#
# The complement of records_open, and a genuine gap in the substrate rather
# than one consumer's special case. `records_open` answers "what is still
# unresolved" and therefore excludes every transition file by name — which
# means the one place a disposition ever lives is the one place it cannot see.
# S5's merge check needed to read dispositions out of `.resolved.md` files and
# found nothing to read them with.
#
# So: for each chain, return the file nothing supersedes. An open record with
# no successor returns itself; a resolved one returns the `.resolved.md`, not
# its predecessor.
records_latest() {
  local dir="$1" f base superseded

  [ -d "$dir" ] || return 0

  superseded="$(grep -hE '^supersedes:[[:space:]]*[^[:space:]]' "$dir"/*.md 2>/dev/null \
    | sed -E 's/^supersedes:[[:space:]]*//; s/[[:space:]]+$//' \
    | grep -v '^null$' || true)"

  for f in "$dir"/*.md; do
    [ -e "$f" ] || continue
    base="$(basename "$f")"
    [ "$base" = "README.md" ] && continue
    if [ -n "$superseded" ] && printf '%s\n' "$superseded" | grep -qxF "$base"; then
      continue
    fi
    printf '%s\n' "$f"
  done
}
