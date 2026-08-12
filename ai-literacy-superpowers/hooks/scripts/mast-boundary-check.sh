#!/usr/bin/env bash
set -euo pipefail
# mast-boundary-check.sh — Stop hook: the approaching and reached notices.
#
# Spec: docs/superpowers/specs/2026-08-12-cadence-sentinels-s3b-boundary-notices-design.md
# Tests: tdad_tests/layer0_deterministic/test-mast-boundary.sh (MB1–MB9)
#
# ONE RECOMMENDATION, ONCE. A boundary-moment prompt improves adherence where
# an ambient reminder does not — the mechanism is a prompt at the decision
# point, not accumulated pressure. Repeating it would not make it work better;
# it would make it work worse.
#
# It never blocks and never asks for a disposition. At the line it recommends
# exactly one thing: /coda.
#
# A LEAD TIME, NOT A FRACTION. The first design said "80% of the way from
# session start to hard_stop_hour", which is not computable: started_at is UTC
# and hard_stop_hour is local, and started_at is deliberately never reset
# across resume — so a session resumed the next morning is already past 80% at
# breakfast and the notice fires on every resume with nothing approached.
# A lead time needs one endpoint, in the same frame as the value it measures.
#
# THE PRUNE RUNS FIRST, unconditionally. Gating the janitor behind the opt-in
# meant that deleting your Budgets block left every note file behind forever,
# and the path where someone has withdrawn consent is the path where leftover
# state matters most.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$SCRIPT_DIR/lib/mast-notes-write.sh" 2>/dev/null || exit 0
# shellcheck source=/dev/null
. "$SCRIPT_DIR/lib/advisory-rail.sh" 2>/dev/null || exit 0

input="$(cat 2>/dev/null || true)"
repo="$(printf '%s' "$input" \
  | grep -oE '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
  | sed -E 's/.*"cwd"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' || true)"
[ -n "$repo" ] || repo="$PWD"

# Unconditional janitor, before any opt-in check.
notes_prune

# Self-gate: nothing is created for a human who declared no Budgets block.
[ "$(block_state 'Budgets' 2>/dev/null || printf 'absent')" = "declared" ] || exit 0

stop_hour="$(block_key 'Budgets' 'hard_stop_hour' '')"
case "$stop_hour" in
  [0-9][0-9]:[0-9][0-9]) : ;;
  *) exit 0 ;;
esac

lead="$(block_key 'Session WIP' 'approaching_lead_minutes' '30')"
case "$lead" in ''|*[!0-9]*) lead=30 ;; esac

# Minutes from now until the line, in local time — the same frame the human
# declared it in.
now_min=$(( 10#$(date +%H) * 60 + 10#$(date +%M) ))
stop_min=$(( 10#${stop_hour%%:*} * 60 + 10#${stop_hour##*:} ))
remaining=$(( stop_min - now_min ))

# A session that begins after the line gets the reached notice, not a negative
# fraction. There is no day-rollover puzzle because there is no interval.
emit() {
  local encoded
  encoded=$(printf '%s' "$1" \
    | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' \
    | awk 'BEGIN{ORS=""} {if (NR>1) printf "\\n"; printf "%s", $0}')
  printf '{"systemMessage": "%s"}\n' "$encoded"
}

# The notes file is touched while its repo has a live session, so one lease can
# both bound the store and preserve the notice state.
notes_touch "$repo"

# shellcheck disable=SC2016  # the backticks are markdown for the reader
if [ "$remaining" -le 0 ]; then
  notes_has "reached" "$repo" && exit 0
  notes_append "reached hard_stop_hour=$stop_hour" "$repo"
  # once-only: it speaks, and a repeating advisory defers to the next turn it
  # is going to get anyway.
  advisory_claim once-only stop || exit 0
  emit "$(printf 'Your %s stop has passed.\n\nRun `/coda` to close out — it will survey what landed, park what is open with a concrete next step, and end the session.\n\nNothing here stops you. If you keep going, you keep going.' "$stop_hour")"
  exit 0
fi

if [ "$remaining" -le "$lead" ]; then
  notes_has "approaching" "$repo" && exit 0
  notes_append "approaching hard_stop_hour=$stop_hour lead=${lead}m" "$repo"
  advisory_claim once-only stop || exit 0
  emit "$(printf '%s minutes to your %s stop.' "$remaining" "$stop_hour")"
fi
exit 0
