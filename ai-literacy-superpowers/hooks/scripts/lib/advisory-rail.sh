#!/usr/bin/env bash

# Strict mode when executed, never leaked into a sourcing shell.
(return 0 2>/dev/null) || set -euo pipefail
# advisory-rail.sh — one stop-advisory per turn, arbitrated by precedence.
#
# Spec: docs/superpowers/specs/2026-08-12-cadence-sentinels-s3b-boundary-notices-design.md §3
# Tests: tdad_tests/layer0_deterministic/test-advisory-rail.sh (AR1–AR6)
#
# WHY PRECEDENCE AND NOT ORDER. Two sentinels counsel stopping on the Stop rail
# and they operate on different periods. `reservoir-check.sh` has no
# once-per-session guard and cannot have one — it persists nothing by charter,
# recomputes an eight-hour window every turn, and re-emits whenever a threshold
# is still crossed. The Mast's `reached` fires once, ever.
#
# The first design was first-claim-wins with the warden ordered first. That
# preserved the message that repeats and permanently spent the one designed to
# arrive once: the note was still logged on the suppressed turn, so the human
# would never have received the boundary message at all. A rail built to reduce
# accumulated pressure was protecting the source of it.
#
# So: a **once-only** advisory speaks and a **repeating** one defers. The warden
# loses nothing — it fires again next turn, on the same conditions. The Mast's
# notice has no next turn.
#
# WHAT A TURN IS. A Stop hook receives no turn identifier and every hook in one
# firing sees the same session id, so a turn is scoped by the only thing
# available: hooks in one firing run back-to-back, so a claim holds for a short
# wall-clock window. Two disclosed failure modes, both bounded:
#
#   - two turns completing inside the window collapse into one, costing one
#     skipped repeating advisory;
#   - a rail slow enough to straddle it lets both emit, costing one duplicate.
#
# ATOMICITY. Claiming is `mkdir`, which is atomic on every POSIX filesystem. A
# check-then-act would race, and a rail whose guarantee flickers teaches the
# human to discount the sentinel — the failure it exists to prevent, arriving
# by another door.
#
# Every function exits without error when it cannot write. An advisory rail
# that broke a hook would be worse than one that let two messages through.

_AR_WINDOW_SECONDS=10

advisory_dir() {
  printf '%s' "${CLAUDE_ADVISORY_DIR:-$HOME/.claude/advisory}"
}

# _ar_bucket — the current turn window, as an integer.
#
# The claim's NAME carries its window, which is what makes this race-free with
# no cleanup step. An earlier version cleared a stale claim before claiming,
# and AR5 caught the race on the first run: several concurrent callers each
# found no claim, then each deleted the claim a previous one had just won —
# three winners instead of one. Bucketing removes the cleanup entirely. Every
# caller inside one window computes the same name, so `mkdir` arbitrates, and
# an earlier window's claim is simply a name nobody looks at.
_ar_bucket() { printf '%s' "$(( $(date -u +%s) / _AR_WINDOW_SECONDS ))"; }

# _ar_claim_path <kind>
_ar_claim_path() { printf '%s/%s.%s.claim' "$(advisory_dir)" "$1" "$(_ar_bucket)"; }

# _ar_sweep <kind> — drop this kind's claims from earlier windows. Bounded by
# construction: at most one directory per kind survives a sweep.
_ar_sweep() {
  local dir current
  dir="$(advisory_dir)"
  current="$(_ar_claim_path "$1")"
  find "$dir" -maxdepth 1 -type d -name "$1.*.claim" ! -path "$current" \
    -exec rm -rf {} + 2>/dev/null || true
}

# advisory_claim <class> <kind> — claim the turn for this kind.
#
# Exit 0 when the caller may speak. Only the `once-only` class claims; a
# repeating caller uses advisory_defer_if_claimed instead.
advisory_claim() {
  local class="$1" kind="$2" dir
  dir="$(advisory_dir)"
  mkdir -p "$dir" 2>/dev/null || return 0   # cannot arbitrate: let it speak

  if [ "$class" = "once-only" ]; then
    # mkdir is the atomic operation: exactly one concurrent caller wins.
    mkdir "$(_ar_claim_path "$kind")" 2>/dev/null || return 1
    _ar_sweep "$kind"
    return 0
  fi

  advisory_defer_if_claimed "$kind" && return 1
  return 0
}

# advisory_defer_if_claimed <kind> — true when a once-only advisory has claimed
# the current window, meaning a repeating caller stays silent.
#
# A turn straddling a window boundary lets both speak. That is one of the two
# disclosed failure modes, and it costs one duplicate message.
advisory_defer_if_claimed() {
  [ -d "$(_ar_claim_path "$1")" ]
}

# advisory_reset — drop every claim. For tests, and for a caller that knows a
# turn has ended.
advisory_reset() {
  local dir
  dir="$(advisory_dir)"
  [ -d "$dir" ] || return 0
  rm -rf "${dir:?}"/*.claim 2>/dev/null || true
  return 0
}
