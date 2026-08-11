#!/usr/bin/env bash

# Strict mode, applied only when this file is EXECUTED. `return` succeeds
# solely inside a sourced context, so the `set` is skipped when a hook script
# or a sentinel sources us. That matters: `set` mutates the CALLER's shell, and
# a library whose whole purpose is being safely sourceable must not impose
# -e/-u/-o pipefail on whatever sourced it. Satisfies the "Shell scripts use
# strict mode" constraint (HARNESS.md) in the only context where strict mode
# is meaningful for a library.
(return 0 2>/dev/null) || set -euo pipefail
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
#
# Deliberately reads the value without consulting `block_state`, so a
# `malformed` Session WIP block still supplies a lease. The Null Object
# contract is about GATING: a block whose governing clause was deleted must
# not be used to hold its keeper to anything. Retention is not gating — it is
# housekeeping on local state, and refusing to garbage-collect would punish
# the human for a typo. S2's WIP Warden faces the same question for
# `max_concurrent_sessions`, where the answer is the opposite: that value
# advises a person, so a malformed block must degrade to observe-only.
_lease_hours() {
  local v
  v="$(block_key 'Session WIP' 'stale_after_hours' '12')"
  case "$v" in ''|*[!0-9]*) v=12 ;; esac
  # Floor at 1. `0` passes the digit test but means "expire everything
  # immediately" — including the entry the sweep wrote one line earlier — while
  # the honesty flag stays quiet, because 0 is not < 0. A human writing 0
  # almost certainly means "never expire", which is the opposite. Treat it as
  # the typo it is rather than silently disabling the registry.
  [ "$v" -lt 1 ] && v=12
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
#
# Escape-aware in both directions: the match tolerates escaped quotes inside
# the value, and the escapes are decoded on the way out. registry_touch
# escapes `repo` on write, so a read path that stopped at the first quote —
# escaped or not — would hand a truncated path to registry_list, which is the
# surface a consumer uses to tell the human where their other sessions are.
_json_field() {
  grep -oE "\"$2\"[[:space:]]*:[[:space:]]*\"([^\"\\\\]|\\\\.)*\"" "$1" 2>/dev/null \
    | head -1 \
    | sed -E 's/^[^:]*:[[:space:]]*"(.*)"$/\1/' \
    | sed -e 's/\\"/"/g' -e 's/\\\\/\\/g'
}

# registry_list — one line per LIVE entry:
# "<id>\t<started_at>\t<heartbeat>\t<repo>".
#
# FILTERS EXPIRED LEASES, exactly as registry_count does. It did not until
# 2026-08-11, while its docstring claimed it did — the claim above was written
# in S1 and was false from the day it shipped. S4's spec gate found it: a
# consumer reporting a count from registry_count and a list from registry_list
# would have said "1 live session" and then listed four, on the ordinary
# working day the count's filter exists to survive. A report whose halves
# disagree is worse than no report.
#
# Repairing a function to match the behaviour its own contract promised is not
# a contract change; it is the defect. R17 and R18 are the guards.
#
# `heartbeat` is carried because an honest AGE needs it. Age-since-`started_at`
# says the session you are actively working in is the oldest and therefore the
# obvious one to park, which is exactly backwards; time-since-`heartbeat` says
# the one you have not touched since this morning is. Only the second is
# actionable, and only the second matches what liveness means here.
#
# Tab-separated, with `repo` LAST, because `repo` is a filesystem path and
# paths routinely contain spaces — a free-form field in the middle would hand
# every consumer doing the obvious `read -r` a corrupted timestamp.
registry_list() {
  local dir entry id repo started hb hb_epoch lease now
  dir="$(registry_dir)"
  [ -d "$dir" ] || return 0
  lease="$(_lease_hours)"
  now="$(date -u +%s)"
  for entry in "$dir"/*.json; do
    [ -e "$entry" ] || continue
    hb="$(_json_field "$entry" heartbeat)"
    hb_epoch="$(_iso_to_epoch "$hb")"
    # An unparseable heartbeat is listed rather than dropped, matching
    # registry_count, which counts it and flags the count inferred.
    if [ "$hb_epoch" -gt 0 ] && [ $(( (now - hb_epoch) / 3600 )) -ge "$lease" ]; then
      continue
    fi
    id="$(_json_field "$entry" id)"
    repo="$(_json_field "$entry" repo)"
    started="$(_json_field "$entry" started_at)"
    printf '%s\t%s\t%s\t%s\n' "$id" "$started" "$hb" "$repo"
  done
}

# registry_count — "<n> <observed|inferred>". Never mutates. Never fails.
#
# COUNTS ONLY ENTRIES WHOSE LEASE HAS NOT EXPIRED. Counting files instead was
# a real defect, found at the code gate and reproduced: nothing removes an
# entry when a session ends, because by design nothing knows a session ended —
# the pruner is the only removal path and it runs on the Stop rail. So a
# morning session, an afternoon session, and a live evening session are three
# files, all with heartbeats inside a 12-hour lease, and the count returned
# `3 observed`. Under `max_concurrent_sessions: 2` the WIP Warden would have
# reported a confident breach on an ordinary working day.
#
# Filtering here is a pure read — no file is touched — so it costs nothing at
# the trust boundary (R8, R9) and leaves the lease lifecycle exactly as the
# spec gate adjudicated it.
#
# The flag derives from durable state, not from this read:
#   - an entry excluded because its lease expired but the pruner has not yet
#     run: the same "crashed, or merely quiet?" uncertainty a retirement
#     carries, seen a moment earlier;
#   - a retirement marker still inside the current lease window, meaning an
#     entry aged out recently;
#   - an `unknown.json` entry, since every hostile id sanitises to that one
#     fallback and the file may stand for more than one session.
# Any of these makes the count inferred, and it stays inferred for every
# subsequent reader (R6).
registry_count() {
  local dir n flag marker lease now marker_epoch entry hb hb_epoch
  dir="$(registry_dir)"
  if [ ! -d "$dir" ]; then printf '0 observed\n'; return 0; fi

  lease="$(_lease_hours)"
  now="$(date -u +%s)"
  n=0
  flag="observed"

  for entry in "$dir"/*.json; do
    [ -e "$entry" ] || continue
    hb="$(_json_field "$entry" heartbeat)"
    hb_epoch="$(_iso_to_epoch "$hb")"
    # An unparseable heartbeat is counted rather than discarded — discarding
    # would let a corrupt entry quietly shrink the count — but it is not
    # something we can claim to have observed.
    if [ "$hb_epoch" -le 0 ]; then
      n=$((n + 1)); flag="inferred"; continue
    fi
    if [ $(( (now - hb_epoch) / 3600 )) -ge "$lease" ]; then
      flag="inferred"          # expired, awaiting the next sweep
      continue
    fi
    n=$((n + 1))
  done

  marker="$dir/.retired"
  if [ -f "$marker" ]; then
    marker_epoch="$(_iso_to_epoch "$(head -1 "$marker")")"
    if [ "$marker_epoch" -gt 0 ] && [ $(( (now - marker_epoch) / 3600 )) -lt "$lease" ]; then
      flag="inferred"
    fi
  fi

  [ -f "$dir/unknown.json" ] && flag="inferred"

  printf '%s %s\n' "$n" "$flag"
}
