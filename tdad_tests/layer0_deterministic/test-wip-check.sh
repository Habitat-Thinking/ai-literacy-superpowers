#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the WIP breach check
# (spec 2026-08-10-cadence-sentinels-s4-wip-warden-design.md, §9; C1–C12).
#
# C12 is the one that matters most, and it is not obvious. `/mast tune`
# deliberately offers a two-line pact and declines to march the human through
# every key, so a `Session WIP` block carrying its mandatory clause and
# `stale_after_hours` and nothing else is a plausible product of the sanctioned
# authoring path — not a pathological fixture. `block_state` returns `declared`
# for it, because S1 defined malformed as "mandatory clause OR required key
# missing" and only the clause half was ever implemented (#503).
#
# So the hook must not invent a limit. Reporting a breach of a line the human
# never drew is the worst output this slice can produce: an imposed limit is
# precisely the pact the clear-weather rule says does not hold.
#
# C10 carries the other half of the design. `SessionStart` re-fires on resume,
# clear and compact, and a breach report re-injected mid-session is the thrash
# the sentinel exists to name. Same `source` guard S2 shipped, writing nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN="$SCRIPT_DIR/../../ai-literacy-superpowers"
HOOK="$PLUGIN/hooks/scripts/wip-check.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

[ -f "$HOOK" ] || fail "wip check not found at $HOOK"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export CLAUDE_SESSIONS_DIR="$TMP/sessions"
export CLAUDE_PACTS_FILE="$TMP/pacts.md"
mkdir -p "$CLAUDE_SESSIONS_DIR"

hook_input() {
  if [ "${2-startup}" = "none" ]; then
    printf '{"session_id":"%s","cwd":"%s"}' "$1" "$TMP"
  else
    printf '{"session_id":"%s","cwd":"%s","source":"%s"}' "$1" "$TMP" "${2-startup}"
  fi
}

run() {
  set +e
  OUT="$(hook_input "$1" "${2-startup}" | bash "$HOOK" 2>/dev/null)"
  RC=$?
  set -e
}

live() {  # live <id...> — write a fresh registry entry per id
  # shellcheck source=/dev/null
  ( . "$PLUGIN/hooks/scripts/lib/session-registry-write.sh"
    for s in "$@"; do registry_touch "$s" "$TMP"; done )
}

pact() {  # pact <body-line...> — a Session WIP block with its mandatory clause
  { printf '# Pacts\n\n## Session WIP\n\n'
    printf '%s\n' "$@"
    printf '\nThis is a gate on sessions, never on the person. It counts; it does not\nassess.\n'
  } > "$CLAUDE_PACTS_FILE"
}

# --- C1: silent when no Session WIP block is declared -------------------------
# A SessionStart hook announcing an observe-only line to every user who never
# asked for this epic is the imposition S1 warns against. /wip is different
# (C11) — a human who asked a question and got nothing cannot tell an absent
# block from a compliant one.
: > "$CLAUDE_PACTS_FILE"
live a b c
run "s-c1"
[ "$RC" -eq 0 ] || fail "C1: must exit 0 (got $RC)"
[ -z "$OUT" ] || fail "C1: must be silent with no block declared. Got: $OUT"

# --- C2: silent when under the limit -----------------------------------------
# The starting session is counted, so two live against a limit of two is
# compliant, not a breach.
rm -f "$CLAUDE_SESSIONS_DIR"/*.json
pact '- max_concurrent_sessions: 2'
live a b
run "s-c2"
[ -z "$OUT" ] || fail "C2: two live against a limit of two must be silent. Got: $OUT"

# --- C3: reports a breach -----------------------------------------------------
live c
run "s-c3"
echo "$OUT" | grep -q "3" || fail "C3: the report must name the count. Got: $OUT"
echo "$OUT" | grep -q "2" || fail "C3: the report must name the limit. Got: $OUT"

# --- C4: lists the live sessions, with an age ---------------------------------
# What makes the report actionable rather than merely true: "park one" is
# unanswerable if you cannot see which.
for s in a b c; do
  echo "$OUT" | grep -q "$s" || fail "C4: the report must list session '$s'. Got: $OUT"
done

# --- C6/C7: strict asks, and says it cannot compel ----------------------------
pact '- max_concurrent_sessions: 2' '- enforcement: advisory'
run "s-c6a"
if echo "$OUT" | grep -qiE 'park one|what is urgent|which would you'; then
  fail "C6: advisory must not ask for a disposition. Got: $OUT"
fi

pact '- max_concurrent_sessions: 2' '- enforcement: strict'
run "s-c6b"
echo "$OUT" | grep -qiE 'park|urgent' \
  || fail "C6: strict must ask for a disposition. Got: $OUT"
echo "$OUT" | grep -qiE "cannot hold|can't hold|cannot stop|nothing here can" \
  || fail "C7: strict must say plainly that it cannot compel. Got: $OUT"

# --- C12: a declared block with no limit compares nothing ---------------------
pact '- stale_after_hours: 12'
run "s-c12"
[ "$RC" -eq 0 ] || fail "C12: must exit 0 (got $RC)"
echo "$OUT" | grep -qiE 'no limit|not declared|have not declared|haven.t declared' \
  || fail "C12: must say no limit is declared. Got: $OUT"
echo "$OUT" | grep -qiF '/mast tune' \
  || fail "C12: must point at /mast tune. Got: $OUT"
if echo "$OUT" | grep -qiE 'over|breach|exceed|more than'; then
  fail "C12: must not report a breach of a limit that was never declared. Got: $OUT"
fi

# --- C5: an inferred count is reported as approximate -------------------------
# S1: no consumer may treat this count as an exact number of open windows.
pact '- max_concurrent_sessions: 1'
: > "$CLAUDE_SESSIONS_DIR/unknown.json"
printf '{"id":"unknown","repo":"%s","started_at":"2026-08-11T00:00:00Z","heartbeat":"%s"}' \
  "$TMP" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$CLAUDE_SESSIONS_DIR/unknown.json"
run "s-c5"
echo "$OUT" | grep -qiE 'at least|approximate|may |might ' \
  || fail "C5: an inferred count must be reported as approximate. Got: $OUT"

# --- C8: a malformed block degrades to silence, never a gate -----------------
printf '# Pacts\n\n## Session WIP\n\n- max_concurrent_sessions: 1\n\nThe clause is gone.\n' \
  > "$CLAUDE_PACTS_FILE"
run "s-c8"
[ "$RC" -eq 0 ] || fail "C8: a malformed block must never gate (got $RC)"
[ -z "$OUT" ] || fail "C8: the hook must stay silent on a malformed block. Got: $OUT"

# --- C10: fires on startup only ----------------------------------------------
pact '- max_concurrent_sessions: 1'
run "s-c10" "startup"
[ -n "$OUT" ] || fail "C10: a startup must report the breach"
for src in resume clear compact none; do
  run "s-c10" "$src"
  [ -z "$OUT" ] \
    || fail "C10: a $src firing must be silent — a breach report re-injected mid-session is the thrash this names. Got: $OUT"
done

# --- C9: exits 0 on every path -----------------------------------------------
blocked="$TMP/blocked"; : > "$blocked"
CLAUDE_SESSIONS_DIR="$blocked/sessions" run "s-c9a"
[ "$RC" -eq 0 ] || fail "C9: unreadable registry must still exit 0 (got $RC)"

set +e
OUT="$(hook_input "s-c9b" | env -u HOME bash "$HOOK" 2>/dev/null)"; RC=$?
set -e
[ "$RC" -eq 0 ] || fail "C9: HOME unset must still exit 0 (got $RC)"

set +e
OUT="$(printf 'not json' | bash "$HOOK" 2>/dev/null)"; RC=$?
set -e
[ "$RC" -eq 0 ] || fail "C9: unparseable stdin must still exit 0 (got $RC)"

# --- B4: no write surface is reachable ---------------------------------------
# The frontmatter check cannot see this: Bash is permitted and it reads only
# the declared tools list.
#
# Matches a SOURCE of a write library, not a mention of one. The first version
# grepped for the filenames and failed on the agent's own charter, which names
# both surfaces in the sentence forbidding them — a good charter says what it
# refuses. That is the same distinction that moved the speculation ban from
# files to emitted output (O5, O6): a grep cannot tell naming from doing.
for f in "$HOOK" "$PLUGIN/agents/wip-warden.agent.md"; do
  [ -f "$f" ] || continue
  if grep -qE '^[[:space:]]*(\.|source)[[:space:]].*(session-registry-write|pact-write)\.sh' "$f"; then
    fail "B4: $(basename "$f") sources a write surface"
  fi
done

echo "PASS: WIP check — counts honestly, never invents a limit, asks without pretending to compel"
