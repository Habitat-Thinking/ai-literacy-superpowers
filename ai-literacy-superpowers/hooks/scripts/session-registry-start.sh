#!/usr/bin/env bash
set -euo pipefail
# session-registry-start.sh — SessionStart hook: write or renew this session's
# registry entry.
#
# Spec: docs/superpowers/specs/2026-08-08-cadence-sentinels-s1-infrastructure-design.md §4.5
# Tests: tdad_tests/layer0_deterministic/test-session-registry.sh (R1, R2, R10)
#
# SessionStart fires on startup, resume, clear and compact, so this runs more
# than once per session. It is idempotent by construction: write if absent,
# renew the heartbeat if present, and never touch started_at.
#
# Exits 0 unconditionally. A registry failure must never surface to a session
# or interfere with it — the same contract every other hook script here holds.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$SCRIPT_DIR/lib/session-registry-write.sh" 2>/dev/null || exit 0

input="$(cat 2>/dev/null || true)"

# Every extraction below ends in `|| true`: under set -e + pipefail a grep
# that matches nothing would abort the script, defeating both the fallback on
# the next line and this hook's exits-0-unconditionally contract.

session="$(printf '%s' "$input" \
  | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
  | sed -E 's/.*"session_id"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' || true)"
[ -n "$session" ] || session="unknown"

repo="$(printf '%s' "$input" \
  | grep -oE '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
  | sed -E 's/.*"cwd"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' || true)"
[ -n "$repo" ] || repo="$PWD"

registry_touch "$session" "$repo" 2>/dev/null || true
exit 0
