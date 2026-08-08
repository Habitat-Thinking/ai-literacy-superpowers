#!/usr/bin/env bash
# session-registry-read.sh — the read surface of the session registry.
#
# Spec: docs/superpowers/specs/2026-08-08-cadence-sentinels-s1-infrastructure-design.md §4
# Tests: tdad_tests/layer0_deterministic/test-session-registry.sh (R4–R13)
#
# THIS FILE IS SOURCEABLE BY A SENTINEL. That is the reason it exists as a
# separate file from session-registry-write.sh, and the reason it defines no
# function that writes, deletes, or moves anything.
#
# sentinel-integrity-check.sh enforces the read-only boundary by rejecting
# Write/Edit in an agent's `tools:` list, and explicitly permits Bash. Its own
# header names the limit: an agent that reaches a write capability through an
# undeclared channel is out of scope for a frontmatter check. A single shared
# library exposing registry_prune to every sentinel would manufacture exactly
# that case — CI green while a `role: sentinel` agent deletes files. So the
# boundary is preserved here instead, by what a sentinel *can* reach rather
# than by what it is trusted not to call. R9 is the test.
#
# registry_count is a PURE READ. Pruning happens on the Stop hook rail, never
# on a read path, because the honesty flag has to be a property of the count
# rather than of whoever read first. If a read pruned, the first consumer
# would absorb the uncertainty and report `inferred` while every consumer
# after it reported `observed` about the identical underlying state (R6).

_SRR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$_SRR_DIR/pact-blocks.sh"

# registry_dir — the registry location. $CLAUDE_SESSIONS_DIR overrides so
# tests need no home directory. The default sits outside every work tree,
# which is what makes a .gitignore entry unnecessary (R13).
registry_dir() {
  printf '%s' "${CLAUDE_SESSIONS_DIR:-$HOME/.claude/sessions}"
}

# _lease_hours — how long an entry stays valid without a heartbeat. Declared
# in the pact file rather than compiled in: every other threshold in this
# harness is human-tunable, and a slice premised on the human declaring their
# pacts should not introduce the first one they cannot touch.
_lease_hours() {
  local v
  v="$(block_key 'Session WIP' 'stale_after_hours' '12')"
  case "$v" in ''|*[!0-9]*) v=12 ;; esac
  printf '%s' "$v"
}

# _iso_to_epoch <iso8601> — seconds since epoch, 0 when unparseable. GNU date
# takes -d; BSD/macOS needs -j -f. Both CI and this laptop must agree.
_iso_to_epoch() {
  local ts="$1"
  date -u -d "$ts" +%s 2>/dev/null \
    || date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$ts" +%s 2>/dev/null \
    || printf '0'
}

# _json_field <file> <key> — a string field's value, or empty.
_json_field() {
  grep -o "\"$2\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$1" 2>/dev/null \
    | head -1 | sed -E 's/.*"[[:space:]]*:[[:space:]]*"([^"]*)"$/\1/'
}

# registry_list — one line per live entry: "<id> <repo> <started_at>".
# This is what makes the `repo` field load-bearing: a consumer showing the
# human their other live sessions needs to say where each one is.
registry_list() {
  local dir entry id repo started
  dir="$(registry_dir)"
  [ -d "$dir" ] || return 0
  for entry in "$dir"/*.json; do
    [ -e "$entry" ] || continue
    id="$(_json_field "$entry" id)"
    repo="$(_json_field "$entry" repo)"
    started="$(_json_field "$entry" started_at)"
    printf '%s %s %s\n' "$id" "$repo" "$started"
  done
}

# registry_count — "<n> <observed|inferred>". Never mutates. Never fails.
#
# The flag derives from durable state, not from this read:
#   - a retirement marker written by the pruner and still inside the current
#     lease window means an entry aged out recently, and the pruner cannot
#     tell a crashed session from a healthy long-running one;
#   - an `unknown.json` entry means one file may stand for more than one
#     session, because every hostile id sanitises to the same fallback.
# Either way the count is inferred, and stays inferred for every subsequent
# reader (R6).
registry_count() {
  local dir n flag marker lease now marker_epoch
  dir="$(registry_dir)"
  if [ ! -d "$dir" ]; then printf '0 observed\n'; return 0; fi

  n="$(find "$dir" -maxdepth 1 -name '*.json' 2>/dev/null | wc -l | tr -d '[:space:]')"
  flag="observed"

  marker="$dir/.retired"
  if [ -f "$marker" ]; then
    lease="$(_lease_hours)"
    now="$(date -u +%s)"
    marker_epoch="$(_iso_to_epoch "$(head -1 "$marker")")"
    if [ "$marker_epoch" -gt 0 ] && [ $(( (now - marker_epoch) / 3600 )) -lt "$lease" ]; then
      flag="inferred"
    fi
  fi

  [ -f "$dir/unknown.json" ] && flag="inferred"

  printf '%s %s\n' "$n" "$flag"
}
