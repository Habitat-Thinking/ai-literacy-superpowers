#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the parked-resume SessionStart hook
# (spec 2026-08-09-cadence-sentinels-s2-coda-design.md, §2.5; H1–H8).
#
# The hook surfaces still-open parking records once per session. H5 is the
# scenario that carries the design: `SessionStart` fires on startup, resume,
# clear and compact (established in S1 §4.2 and repeated in
# session-registry-start.sh), so an unguarded hook would re-inject the parked
# list into the middle of an unrelated working session, every compact, forever.
#
# That is not merely noisy. A parking record exists to release a thread's pull
# so the person can stop holding it. Printing "still parked: implement the retry
# branch" while they are deepest in something else hands the thread straight
# back — the surface this epic exists to reduce, produced by the mechanism meant
# to reduce it.
#
# H8 carries the other half. The guard keys off S1's existing registry entry
# (`started_at`, per-session and stable across compacts by design) rather than
# writing a marker file into a directory S1 owns. A marker would have inherited
# that store's location guarantees without its retention contract: the pruner
# retires `*.json` by heartbeat and sweeps `*.tmp`, so a file in neither shape
# would accumulate one per session for the life of the machine.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN="$SCRIPT_DIR/../../ai-literacy-superpowers"
HOOK="$PLUGIN/hooks/scripts/parked-resume-check.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

[ -f "$HOOK" ] || fail "resume hook not found at $HOOK"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export CLAUDE_SESSIONS_DIR="$TMP/sessions"
export CLAUDE_PARKED_DIR="$TMP/parked"
mkdir -p "$CLAUDE_SESSIONS_DIR" "$CLAUDE_PARKED_DIR"

# SessionStart carries a `source`: startup | resume | clear | compact.
# The guard fires on startup only — that IS the once-per-session rule, and it
# needs no stored marker and has no timing race.
# Pass the literal `none` to omit the field entirely — `${2:-...}` would treat
# an empty string as unset and silently substitute the default, which is
# exactly the case the absent-source scenario needs to exercise.
hook_input() {
  if [ "${2-startup}" = "none" ]; then
    printf '{"session_id":"%s","cwd":"%s"}' "$1" "$TMP"
  else
    printf '{"session_id":"%s","cwd":"%s","source":"%s"}' "$1" "$TMP" "${2-startup}"
  fi
}

# run <session-id> [source] -> OUT, RC
run() {
  set +e
  OUT="$(hook_input "$1" "${2-startup}" | bash "$HOOK" 2>/dev/null)"
  RC=$?
  set -e
}

# A session must exist in the registry for the guard to key off it.
start_session() {
  # shellcheck source=/dev/null
  ( . "$PLUGIN/hooks/scripts/lib/session-registry-write.sh"; registry_touch "$1" "$TMP" )
}

park() {  # park <filename> <next action>
  cat > "$CLAUDE_PARKED_DIR/$1" <<EOF
---
session: sess-x
repo: $TMP
created: 2026-08-09
state: parked
supersedes: null
next_action_flag: asked
---

## Context

A fixture thread.

## Next action

$2
EOF
}

# --- H2: silent when the directory does not exist ----------------------------
CLAUDE_PARKED_DIR="$TMP/nonexistent" run "sess-h2"
[ "$RC" -eq 0 ] || fail "H2: must exit 0 when the parked directory is absent (got $RC)"
[ -z "$OUT" ] || fail "H2: must be silent when the parked directory is absent. Got: $OUT"

# --- H1: silent when nothing is parked ---------------------------------------
start_session "sess-h1"
run "sess-h1"
[ "$RC" -eq 0 ] || fail "H1: must exit 0 with an empty parked directory (got $RC)"
[ -z "$OUT" ] || fail "H1: must be silent with nothing parked. Got: $OUT"

# --- H3: surfaces an open record, naming it and its next action --------------
park "2026-08-08-retry-branch.md" "implement the retry branch, starting from test_retry.py"
start_session "sess-h3"
run "sess-h3"
[ "$RC" -eq 0 ] || fail "H3: must exit 0 (got $RC)"
echo "$OUT" | grep -qF "retry-branch" \
  || fail "H3: output must name the record. Got: $OUT"
echo "$OUT" | grep -qF "test_retry.py" \
  || fail "H3: output must carry the next action. Got: $OUT"

# --- H5: once per session ----------------------------------------------------
# The scenario that carries the design. SessionStart re-fires on resume, clear
# and compact; each of those must be silent, or the parked list is re-injected
# into the middle of an unrelated working session for the rest of the day.
for src in resume clear compact; do
  run "sess-h3" "$src"
  [ "$RC" -eq 0 ] || fail "H5: a $src firing must still exit 0 (got $RC)"
  [ -z "$OUT" ] \
    || fail "H5: a $src firing must be silent — only startup surfaces. Got: $OUT"
done

# An absent source must not be treated as startup. Unknown provenance is the
# case where re-injection is possible, so the safe reading is 'stay quiet'.
run "sess-h3" "none"
[ -z "$OUT" ] || fail "H5: an absent source must not surface. Got: $OUT"

# --- H6: a new session surfaces again ----------------------------------------
start_session "sess-h6"
run "sess-h6"
echo "$OUT" | grep -qF "retry-branch" \
  || fail "H6: a new startup must get the list. Got: $OUT"

# --- H4: a resumed record is not surfaced ------------------------------------
cat > "$CLAUDE_PARKED_DIR/2026-08-09-retry-branch.resumed.md" <<EOF
---
session: sess-y
repo: $TMP
created: 2026-08-09
state: resumed
supersedes: 2026-08-08-retry-branch.md
next_action_flag: asked
---

## Context

Resumed.

## Next action

Resumed — no further action pending.
EOF
start_session "sess-h4"
run "sess-h4"
echo "$OUT" | grep -qF "retry-branch" \
  && fail "H4: a record superseded by a .resumed.md transition must not be surfaced. Got: $OUT"

# --- H7: exits 0 unconditionally ---------------------------------------------
blocked="$TMP/blocked"; : > "$blocked"
CLAUDE_PARKED_DIR="$blocked/parked" run "sess-h7a"
[ "$RC" -eq 0 ] || fail "H7: must exit 0 when the parked path is unusable (got $RC)"

set +e
OUT="$(hook_input "sess-h7b" | env -u HOME bash "$HOOK" 2>/dev/null)"
RC=$?
set -e
[ "$RC" -eq 0 ] || fail "H7: must exit 0 with HOME unset (got $RC)"

set +e
OUT="$(printf 'not json' | bash "$HOOK" 2>/dev/null)"
RC=$?
set -e
[ "$RC" -eq 0 ] || fail "H7: must exit 0 on unparseable stdin (got $RC)"

# --- H8: no marker file is written -------------------------------------------
# The guard reads S1's started_at. It must leave no residue in a directory
# another slice owns and whose only removal path is the lease pruner.
before="$(find "$CLAUDE_SESSIONS_DIR" -type f | sort)"
start_session "sess-h8"
mid="$(find "$CLAUDE_SESSIONS_DIR" -type f | sort)"
run "sess-h8"; run "sess-h8"
after="$(find "$CLAUDE_SESSIONS_DIR" -type f | sort)"
[ "$mid" = "$after" ] \
  || fail "H8: the hook must write no file into the registry directory.
  before hook: $mid
  after hook:  $after"
[ "$before" != "$mid" ] || fail "H8: the fixture did not actually create a session entry"

echo "PASS: parked-resume hook — surfaces once per session, honours transitions, writes nothing"
