#!/usr/bin/env bash
set -uo pipefail
# session-registry-sweep.sh — Stop hook: renew this session's lease, then
# retire any that have expired.
#
# Spec: docs/superpowers/specs/2026-08-08-cadence-sentinels-s1-infrastructure-design.md §4.5
# Tests: tdad_tests/layer0_deterministic/test-session-registry.sh (R3, R5, R7)
#
# This hook RENEWS. It does not delete this session's entry, and R3 is the
# test that says so: Stop fires when the agent finishes responding, many times
# per session, so a delete here would empty the registry after each session's
# first answer.
#
# Pruning lives here, on the hook rail, rather than in any read path. That is
# what keeps registry_count pure and the honesty flag a property of the count
# rather than of whoever read first.
#
# Exits 0 unconditionally.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$SCRIPT_DIR/lib/session-registry-write.sh" 2>/dev/null || exit 0

input="$(cat 2>/dev/null || true)"

session="$(printf '%s' "$input" \
  | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
  | sed -E 's/.*"session_id"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')"
[ -n "$session" ] || session="unknown"

repo="$(printf '%s' "$input" \
  | grep -oE '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
  | sed -E 's/.*"cwd"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')"
[ -n "$repo" ] || repo="$PWD"

registry_touch "$session" "$repo" 2>/dev/null || true
registry_prune 2>/dev/null || true
exit 0
