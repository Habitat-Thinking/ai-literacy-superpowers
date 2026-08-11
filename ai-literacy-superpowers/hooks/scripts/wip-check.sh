#!/usr/bin/env bash
set -euo pipefail
# wip-check.sh — SessionStart hook: how many sessions are live, against the
# limit the human declared for themselves.
#
# Spec: docs/superpowers/specs/2026-08-10-cadence-sentinels-s4-wip-warden-design.md
# Tests: tdad_tests/layer0_deterministic/test-wip-check.sh (C1–C12, B4)
#
# IT COUNTS SESSIONS. IT NEVER WATCHES THE HUMAN. That split is the whole
# reason this can exist alongside the Reservoir Warden: that agent watches the
# person and never gates, and it is trustworthy precisely because it has no
# teeth and wants none. The moment a sibling starts inferring from session
# counts how tired someone is, the Warden's contract is retroactively broken
# for everyone who ever told it their chronotype.
#
# So: a number, an age per session, a comparison against a declared line. No
# speculation about attention, capacity, or how anyone is doing — not as a
# hedge, not as a sympathetic aside.
#
# IT NEVER INVENTS A LIMIT. `/mast tune` deliberately offers a two-line pact,
# so a Session WIP block with its clause and no `max_concurrent_sessions` is a
# plausible file — and `block_state` calls it `declared`, because S1 defined
# malformed as "clause OR required key missing" and only the clause half was
# ever implemented (#503). Reporting a breach of a line the human never drew
# would be the worst output available: an imposed limit is precisely the pact
# the clear-weather rule says does not hold.
#
# STARTUP ONLY. SessionStart re-fires on resume, clear and compact, and a
# breach report re-injected mid-session is the thrash this exists to name.
# Absent source stays quiet — unknown provenance is where re-injection lives.
#
# Ordered AFTER session-registry-start.sh on the same rail, so the starting
# session's entry exists when the count is taken. A human writing
# `max_concurrent_sessions: 2` means two including the one they are in.
#
# Exits 0 on every path.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$SCRIPT_DIR/lib/session-registry-read.sh" 2>/dev/null || exit 0

input="$(cat 2>/dev/null || true)"

source_field="$(printf '%s' "$input" \
  | grep -oE '"source"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
  | sed -E 's/.*"source"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' || true)"
[ "$source_field" = "startup" ] || exit 0

# Self-gate before touching anything else: no declared block, nothing to say.
# A hook announcing an observe-only line to everyone who never asked for this
# epic is the imposition S1 warns against. `/wip` is the surface that answers a
# direct question, and it does use the fixed sentence.
[ "$(block_state 'Session WIP' 2>/dev/null || printf 'absent')" = "declared" ] || exit 0

read -r count flag <<<"$(registry_count 2>/dev/null || printf '0 observed')"
case "$count" in ''|*[!0-9]*) exit 0 ;; esac

# Ask whether the human declared a limit, rather than inferring it from an
# empty string. `block_state` answers well-formedness; this answers
# completeness (#503). A partial pact is a complete pact — just a short one.
limit=""
if block_has_key 'Session WIP' 'max_concurrent_sessions'; then
  limit="$(block_key 'Session WIP' 'max_concurrent_sessions' '')"
fi
enforcement="$(block_key 'Session WIP' 'enforcement' 'advisory')"

# `at least` rather than a bare number whenever the count is inferred. S1 was
# explicit that no consumer may treat this as an exact number of open windows,
# and this is the first consumer.
approx=""
[ "$flag" = "inferred" ] && approx="at least "

# _sessions_block — one line per live session: which, and how long since it
# last finished a turn. Age is time since HEARTBEAT, not since started_at:
# age-since-start would say the session you are actively working in is the
# oldest and therefore the obvious one to park, which is exactly backwards.
_sessions_block() {
  local id hb repo now hb_epoch age
  now="$(date -u +%s)"
  # `started_at` is consumed into a throwaway on purpose: the age reported here
  # is time since heartbeat, and reading start into a named variable would
  # invite someone to use it.
  while IFS=$'\t' read -r id _ hb repo; do
    [ -n "$id" ] || continue
    hb_epoch="$(_iso_to_epoch "$hb")"
    if [ "$hb_epoch" -gt 0 ]; then
      age=$(( (now - hb_epoch) / 60 ))
      if [ "$age" -ge 60 ]; then
        printf -- '  - %s — %sh since its last turn — %s\n' "$id" "$((age / 60))" "$repo"
      else
        printf -- '  - %s — %sm since its last turn — %s\n' "$id" "$age" "$repo"
      fi
    else
      printf -- '  - %s — last turn unknown — %s\n' "$id" "$repo"
    fi
  done <<EOF
$(registry_list 2>/dev/null || true)
EOF
}

# emit <message> — JSON-encode and print a systemMessage, as reservoir-check.sh
# does. Captured via command substitution rather than piped into `read`: awk's
# ORS="" leaves no trailing newline, so `read` hits EOF, returns 1, and takes
# the whole script down under `set -e`.
emit() {
  local encoded
  encoded=$(printf '%s' "$1" \
    | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' \
    | awk 'BEGIN{ORS=""} {if (NR>1) printf "\\n"; printf "%s", $0}')
  printf '{"systemMessage": "%s"}\n' "$encoded"
}

# No limit declared — say so, point at the ritual, compare nothing.
# shellcheck disable=SC2016  # the backticks are markdown for the reader
if [ -z "$limit" ] || case "$limit" in ''|*[!0-9]*) true ;; *) false ;; esac; then
  emit "$(printf '%s%s session(s) live. You have not declared a limit in your Session WIP block.\n\n%s\nRun `/mast tune` to set one.' \
    "$approx" "$count" "$(_sessions_block)")"
  exit 0
fi

[ "$count" -gt "$limit" ] || exit 0

if [ "$enforcement" = "strict" ]; then
  emit "$(printf '%s%s session(s) live; your limit is %s.\n\n%sPark one, or say what is urgent enough to keep them all open.\n\nThis asks. It cannot hold a session, and nothing in this plugin can — if you keep going, you keep going.' \
    "$approx" "$count" "$limit" "$(_sessions_block)")"
else
  emit "$(printf '%s%s session(s) live; your limit is %s.\n\n%s' \
    "$approx" "$count" "$limit" "$(_sessions_block)")"
fi
exit 0
