#!/usr/bin/env bash
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
    "$id" "$repo" "$started" "$now" > "$tmp" 2>/dev/null || return 0
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

  [ "$retired" -eq 1 ] && _now_iso > "$dir/.retired" 2>/dev/null
  return 0
}
