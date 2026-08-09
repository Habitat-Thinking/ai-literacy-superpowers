#!/usr/bin/env bash
set -euo pipefail
# parked-resume-check.sh — SessionStart hook: surface still-open parking
# records, once, at the start of a session.
#
# Spec: docs/superpowers/specs/2026-08-09-cadence-sentinels-s2-coda-design.md §2.5
# Tests: tdad_tests/layer0_deterministic/test-parked-resume.sh (H1–H8)
#
# This is the payoff that makes parking trustworthy. A record nobody ever sees
# again is a diary, not a handoff — so if a thread was parked with a concrete
# next action, the next session opens with it in view.
#
# ONCE, AND ONLY ON STARTUP. `SessionStart` also fires on resume, clear and
# compact (S1 §4.2), so an unguarded hook would re-inject the parked list into
# the middle of an unrelated working session, every compact, for the rest of
# the day. That is not merely noisy: a parking record exists to release a
# thread's pull so the person can stop holding it, and printing it back at them
# while they are deepest in something else hands the thread straight back. The
# mechanism meant to reduce the epic's target surface would have produced it.
#
# The guard is the `source` field, not a marker file. A per-session marker in
# `~/.claude/sessions/` would have inherited that store's location guarantees
# without its retention contract — the registry's only removal path is the
# lease pruner, which retires `*.json` by heartbeat and sweeps `*.tmp`, so a
# file in neither shape accumulates one per session for the life of the
# machine. Against a carve-out whose second condition is *bounded*, and whose
# own text warns that "a record with no expiry is an archive". Reading a field
# that already arrives on stdin writes nothing at all.
#
# An ABSENT source stays quiet. Unknown provenance is exactly the case where
# re-injection is possible, so silence is the safe reading — the cost of a
# missed surfacing is one session opening cold, and the cost of a wrong one is
# the failure mode above.
#
# Exits 0 unconditionally. A hook that surfaces a handoff must never be able to
# interfere with the session it opens.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$SCRIPT_DIR/lib/record-paths.sh" 2>/dev/null || exit 0

input="$(cat 2>/dev/null || true)"

# Only a genuine startup surfaces. See the header for why absence is silence.
source_field="$(printf '%s' "$input" \
  | grep -oE '"source"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
  | sed -E 's/.*"source"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' || true)"
[ "$source_field" = "startup" ] || exit 0

parked_dir="${CLAUDE_PARKED_DIR:-$PWD/docs/superpowers/parked}"
[ -d "$parked_dir" ] || exit 0

open_records="$(records_open "$parked_dir" 2>/dev/null || true)"
[ -n "$open_records" ] || exit 0

# next_action_of <file> — the first non-empty line under `## Next action`.
# Read rather than summarised: the whole point is that the human's own words
# come back to them.
next_action_of() {
  awk '
    /^##[[:space:]]+Next action/ { inside = 1; next }
    /^##[[:space:]]/             { inside = 0 }
    inside && NF                 { print; exit }
  ' "$1" 2>/dev/null
}

lines=""
while IFS= read -r rec; do
  [ -n "$rec" ] || continue
  action="$(next_action_of "$rec")"
  lines="${lines}- $(basename "$rec")
  ${action}
"
done <<EOF
$open_records
EOF

[ -n "$lines" ] || exit 0

# A plain report, not a nudge. It says what is parked and stops; deciding
# whether to pick any of it up is the human's, and nothing here should read as
# an instruction to resume.
# shellcheck disable=SC2016  # the backticks are markdown for the reader, not a shell expansion
printf 'Parked from an earlier session:\n\n%s\nRun `/coda resume <record>` when one of these is finished.\n' "$lines"
exit 0
