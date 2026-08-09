#!/usr/bin/env bash

# Strict mode, applied only when this file is EXECUTED. `return` succeeds
# solely inside a sourced context, so the `set` is skipped when a hook script
# or a sentinel sources us. That matters: `set` mutates the CALLER's shell, and
# a library whose whole purpose is being safely sourceable must not impose
# -e/-u/-o pipefail on whatever sourced it. Satisfies the "Shell scripts use
# strict mode" constraint (HARNESS.md) in the only context where strict mode
# is meaningful for a library.
(return 0 2>/dev/null) || set -euo pipefail
# session-registry-write.sh — the mutation surface of the session registry.
#
# Spec: docs/superpowers/specs/2026-08-08-cadence-sentinels-s1-infrastructure-design.md §4.2, §4.4
# Tests: tdad_tests/layer0_deterministic/test-session-registry.sh (R1–R3, R5, R7, R10)
#
# HOOK SCRIPTS ONLY. A sentinel must never source this file — that is the
# whole point of splitting it from session-registry-read.sh, which a sentinel
# may source freely. See the read library's header for why the frontmatter
# check cannot enforce this on its own.
#
# The registry is a LEASE, not a liveness log. An entry is valid for
# stale_after_hours from its last heartbeat; staying alive means renewing.
# Nothing here deletes an entry because a session "ended" — the pruner retires
# entries whose lease expired, and that is the only removal path.
#
# Why renewal rather than delete-on-Stop. The Stop hook fires when the main
# agent finishes responding — many times per session, not once at session end.
# All nine pre-existing Stop scripts declare "runs at session end" in their
# headers and none carries a once-per-session guard; that is harmless for nine
# idempotent advisories, whose worst failure is a duplicate nudge, and fatal
# for a destructive one. A delete-on-Stop registry empties itself after each
# session's first response, and the WIP Warden reports 1 while four sessions
# run. Renewal makes correctness independent of how often Stop fires: once per
# session, once per turn, or fifty times a turn all behave the same.

_SRW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$_SRW_DIR/session-registry-read.sh"   # registry_dir, _lease_hours, _iso_to_epoch, _json_field

_now_iso() { date -u +%Y-%m-%dT%H:%M:%SZ; }

# registry_sanitise_id <raw> — a session id safe to use as a path component.
#
# Already adjudicated once in this repo for the same field
# (affordance-invocation-recorder.sh:55, after a code-time objection). A `/` or
# `..` reaching a path context is strictly worse than the JSON-injection case
# fixed there, because the write lands outside the intended directory. Every
# hostile id collapses to the single fallback `unknown`, which is why a
# registry containing unknown.json reports its count as inferred: that one
# file may stand for more than one session.
registry_sanitise_id() {
  local id="$1"
  printf '%s' "$id" | grep -qE '^[A-Za-z0-9._-]+$' || id="unknown"
  printf '%s' "$id"
}

# _json_escape <string> — escape backslash and double-quote for a JSON string.
#
# `repo` is a filesystem path, and a path may legally contain a `"`. Without
# this, such a path closes the JSON string early and injects arbitrary keys —
# and because `_json_field` takes the FIRST match, an injected `heartbeat`
# wins over the real one:
#
#     repo='/w/a","heartbeat":"2099-01-01T00:00:00Z'
#       -> heartbeat reads back as 2099-01-01T00:00:00Z
#
# Lease expiry is the ONLY removal path in this design, so that entry becomes
# immortal: it inflates the WIP count for every sentinel on the machine,
# permanently, recoverable only by a human deleting the file. That is a worse
# outcome than the injection case this repo already adjudicated for the
# sibling `session_id` field, and it is why `repo` gets escaped rather than
# merely truncated. Backslash must be replaced first, or it would double-escape
# the quotes added after it.
_json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  printf '%s' "$s"
}

# registry_touch <session-id> <repo> — write the entry if absent, renew its
# heartbeat if present. NEVER resets started_at: SessionStart fires on
# startup, resume, clear and compact, and a reset started_at would mean a
# genuinely long-running session never ages out (R2).
registry_touch() {
  local id repo dir entry now started tmp
  id="$(registry_sanitise_id "$1")"
  repo="${2:-$PWD}"
  dir="$(registry_dir)"
  mkdir -p "$dir" 2>/dev/null || return 0
  entry="$dir/$id.json"
  now="$(_now_iso)"

  started="$now"
  [ -f "$entry" ] && started="$(_json_field "$entry" started_at)"
  [ -n "$started" ] || started="$now"

  tmp="$entry.$$.tmp"
  printf '{"id":"%s","repo":"%s","started_at":"%s","heartbeat":"%s"}\n' \
    "$id" "$(_json_escape "$repo")" "$(_json_escape "$started")" "$now" > "$tmp" 2>/dev/null || return 0
  # Rename, so a reader never observes a half-written entry. Several sessions
  # run these hooks against one shared registry directory at the same time.
  mv -f "$tmp" "$entry" 2>/dev/null || return 0
}

# registry_prune — retire every entry whose lease has expired, and record that
# a retirement happened.
#
# The marker is what makes the honesty flag durable. Without it the flag would
# have to be inferred from "did THIS read prune something", which hands the
# uncertainty to whichever consumer happened to read first and hides it from
# everyone after (R6). The pruner cannot distinguish a crashed session from a
# healthy long-running one — it only knows the lease expired — so that
# uncertainty belongs to the count from then on.
registry_prune() {
  local dir lease now entry hb hb_epoch retired
  dir="$(registry_dir)"
  [ -d "$dir" ] || return 0
  lease="$(_lease_hours)"
  now="$(date -u +%s)"
  retired=0

  for entry in "$dir"/*.json; do
    [ -e "$entry" ] || continue
    hb="$(_json_field "$entry" heartbeat)"
    hb_epoch="$(_iso_to_epoch "$hb")"
    [ "$hb_epoch" -gt 0 ] || continue          # unparseable: leave it alone
    if [ $(( (now - hb_epoch) / 3600 )) -ge "$lease" ]; then
      rm -f "$entry" 2>/dev/null && retired=1
    fi
  done

  # A hook killed at its 10s timeout between the write and the rename leaves a
  # temp behind. It cannot corrupt a count — `*.tmp` matches neither the
  # `*.json` glob nor the find — but nothing else would ever collect it, and
  # the pruner is already the janitor on this rail.
  find "$dir" -maxdepth 1 -name '*.tmp' -mmin +$(( lease * 60 )) -exec rm -f {} + 2>/dev/null || true

  [ "$retired" -eq 1 ] && _now_iso > "$dir/.retired" 2>/dev/null
  return 0
}
