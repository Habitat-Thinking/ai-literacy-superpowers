#!/usr/bin/env bash

(return 0 2>/dev/null) || set -euo pipefail
# mast-notes-write.sh — the mutation surface of the boundary note store.
#
# Spec: §4 · Tests: test-mast-notes.sh (MN2, MN3)
#
# HOOKS AND COMMANDS ONLY. A `role: sentinel` agent must never source this.
# S1 made the same split for the registry and `sentinel-design` promoted the
# rule out of it: a read surface a sentinel may source, a write surface it may
# not.

_MNW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$_MNW_DIR/mast-notes-read.sh"
# shellcheck source=/dev/null
. "$_MNW_DIR/session-registry-read.sh"   # _lease_hours, _iso_to_epoch

# notes_append <event-text> [repo] — record that something fired.
#
# Only facts. "reached hard_stop_hour=20:00" is a fact; "continued past the
# stop by choice" is an attribution of intent by a hook, about a person, and
# does not belong here.
notes_append() {
  local text="$1" repo="${2:-$PWD}" f
  f="$(notes_path "$repo")"
  mkdir -p "$(dirname "$f")" 2>/dev/null || return 0
  printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$text" >> "$f" 2>/dev/null || true
}

# notes_touch [repo] — refresh the file's mtime while its repo has a live
# session.
#
# This is what lets ONE lease do two jobs. The file both bounds the store and
# holds the once-per-session notice state, and those pull opposite ways: a file
# appended to only on a boundary event stops being renewed the moment the
# notices are done, so under a 12-hour lease a session reaching its stop at
# 20:00 and still alive at 08:00 would have its own hook prune its notice state
# — and `reached` would fire again. A heartbeat is the shape S1 already proved.
notes_touch() {
  local f
  f="$(notes_path "${1:-$PWD}")"
  [ -f "$f" ] || return 0
  touch "$f" 2>/dev/null || true
}

# notes_mark_consumed [repo] — the Coda has collected these events.
#
# MARKS, NEVER REMOVES. The notice state lives in this file and `/coda`'s final
# step is a statement rather than a process ending — the session stays alive and
# the Stop rail keeps firing. Deleting at close would take the notice state with
# it and `reached` would fire again on the next turn, on exactly the sessions
# where the human had already been told once. Marking also makes a second
# `/coda` idempotent.
notes_mark_consumed() {
  notes_append "consumed-by-coda" "${1:-$PWD}"
}

# notes_prune — retire note files whose repo has had no live session for a
# lease.
#
# UNCONDITIONAL, and called before any opt-in check. Gating the janitor behind
# the feature meant that a human who used it for a month and then deleted their
# Budgets block left every note file behind forever — and the one path where
# someone has withdrawn consent is the one path where leftover state matters
# most.
notes_prune() {
  local dir lease
  dir="$(notes_dir)"
  [ -d "$dir" ] || return 0
  lease="$(_lease_hours)"
  find "$dir" -maxdepth 1 -name '*.notes' -mmin +$(( lease * 60 )) \
    -exec rm -f {} + 2>/dev/null || true
  return 0
}
