#!/usr/bin/env bash
set -euo pipefail
# Layer 0 integration test for the cadence substrate
# (spec 2026-08-13-cadence-sentinels-s7-docs-design.md, §5; K1–K5).
#
# WHAT THIS ADDS THAT THE PER-LIBRARY TESTS CANNOT. S7's first revision proposed
# re-running coverage that already ships — test-pact-blocks.sh,
# test-session-registry.sh, test-wip-check.sh, test-record-contracts.sh,
# test-convene-check.sh. Five independent assertions sharing one mktemp is not
# integration coverage; it is the same coverage with a shared temp directory.
#
# The property none of them can show is AGREEMENT. Three libraries read the pact
# file independently: pact-blocks.sh reads the limit, session-registry-read.sh
# applies the lease, and wip-check.sh compares one against the other. Nothing
# asserted that the value one library reads is the value the next one acts on.
#
# So: one pact file, one registry, three readers, one answer.
#
# WHY THE FOUR OVERRIDES ARE NOT OPTIONAL. The pact file and the session
# registry live OUTSIDE every work tree by design — $HOME/.claude/pacts.md and
# $HOME/.claude/sessions/ — so a toy repo does not isolate them. The first
# revision named a temp directory and none of the overrides. A run would have
# written into the developer's REAL registry, inflating the live-session count
# the WIP Warden reports against a line the person drew — which
# test-wip-check.sh already names as the worst output this substrate can
# produce — and sweep could have retired a merely-idle colleague session.
#
# K4 is why the first revision's K6 was wrong. "A repo with none of these files"
# is not the unadopted state, because none of these files was ever in a repo.
# Anyone who has run /mast tune — everyone who built this epic — would have got
# the ADOPTED behaviour and a green check attesting to a property nobody
# verified. K4 constructs MACHINE-state absence instead.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN="$SCRIPT_DIR/../../ai-literacy-superpowers"

fail() { echo "FAIL: $*" >&2; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

REPO="$TMP/toy-repo"
mkdir -p "$REPO"

# Machine state, not repo state. All four, every time.
export CLAUDE_PACTS_FILE="$TMP/machine/pacts.md"
export CLAUDE_SESSIONS_DIR="$TMP/machine/sessions"
export CLAUDE_MAST_DIR="$TMP/machine/mast"
export CLAUDE_PARKED_DIR="$TMP/machine/parked"
mkdir -p "$TMP/machine"

pact() {  # pact <limit>
  mkdir -p "$(dirname "$CLAUDE_PACTS_FILE")"
  { printf '# Pacts\n\n## Session WIP\n\n'
    printf -- '- max_concurrent_sessions: %s\n' "$1"
    printf '\nThis is a gate on sessions, never on the person. It counts; it does not\nassess.\n'
  } > "$CLAUDE_PACTS_FILE"
}

live() {  # live <id...>
  # shellcheck source=/dev/null
  ( . "$PLUGIN/hooks/scripts/lib/session-registry-write.sh"
    for s in "$@"; do registry_touch "$s" "$REPO"; done )
}

wip() {  # wip <session-id> — run the SessionStart hook as it really fires
  set +e
  OUT="$(printf '{"session_id":"%s","cwd":"%s","source":"startup"}' "$1" "$REPO" \
    | bash "$PLUGIN/hooks/scripts/wip-check.sh" 2>/dev/null)"
  RC=$?
  set -e
}

# --- K1: one pact, three readers, one answer ---------------------------------
# The limit read by pact-blocks.sh must be the limit wip-check.sh enforces
# against the registry session-registry-read.sh counts. Off-by-one in any of the
# three shows up here and nowhere else.
pact 2
# shellcheck source=/dev/null
. "$PLUGIN/hooks/scripts/lib/pact-blocks.sh"
limit="$(block_key "Session WIP" "max_concurrent_sessions" "")"
[ "$limit" = "2" ] || fail "K1: pact-blocks read the limit as '$limit', expected 2"

rm -rf "${CLAUDE_SESSIONS_DIR:?}"; mkdir -p "$CLAUDE_SESSIONS_DIR"
live a b                      # exactly at the limit — compliant
wip "b"
[ -z "$OUT" ] || fail "K1: two live against a limit of two must be silent. Got: $OUT"

live c                        # one over — the breach fires at exactly 3, not 2 or 4
wip "c"
[ -n "$OUT" ] || fail "K1: three live against a limit of two must report a breach"
echo "$OUT" | grep -q "3" || fail "K1: the report must name the count. Got: $OUT"
echo "$OUT" | grep -q "2" || fail "K1: the report must name the limit it read. Got: $OUT"

# --- K2: the lease governs what the count sees -------------------------------
# The breach must clear without the pact changing — the limit and the lease are
# read by DIFFERENT libraries and must agree about the same registry.
printf '{"id":"a","repo":"%s","started_at":"2020-01-01T00:00:00Z","heartbeat":"2020-01-01T00:00:00Z"}' \
  "$REPO" > "$CLAUDE_SESSIONS_DIR/a.json"
wip "c"
[ -z "$OUT" ] \
  || fail "K2: an entry past its lease must stop being counted, clearing the breach. Got: $OUT"

# --- K3: a record written by one contract is found by the other --------------
# records_open answers "what is outstanding"; records_latest answers "what is
# the current state". A resolved record must move between them, because the
# consultation check reads through the second and would otherwise pass
# vacuously on every disposed record.
# shellcheck source=/dev/null
. "$PLUGIN/hooks/scripts/lib/record-paths.sh"
RECS="$TMP/machine/records"; mkdir -p "$RECS"
printf -- '---\nstate: open\nsupersedes: null\n---\n' > "$RECS/thread-one.md"
open_count="$(records_open "$RECS" | grep -c . || true)"
[ "$open_count" = "1" ] || fail "K3: a fresh record must be open, got $open_count"

printf -- '---\nstate: resolved\nsupersedes: thread-one.md\n---\n' > "$RECS/thread-one.resolved.md"
open_count="$(records_open "$RECS" | grep -c . || true)"
[ "$open_count" = "0" ] || fail "K3: a resolved record must not be open, got $open_count"
latest="$(records_latest "$RECS")"
case "$latest" in
  *thread-one.resolved.md) : ;;
  *) fail "K3: records_latest must return the successor, got '$latest'" ;;
esac

# --- K4: silence on an unadopted machine -------------------------------------
# MACHINE state, not repo state: no pact file anywhere, empty registry. This is
# every project that never adopted the epic, and the substrate must say nothing.
rm -f "$CLAUDE_PACTS_FILE"
rm -rf "${CLAUDE_SESSIONS_DIR:?}"; mkdir -p "$CLAUDE_SESSIONS_DIR"
for hook in wip-check parked-resume-check; do
  set +e
  OUT="$(printf '{"session_id":"k4","cwd":"%s","source":"startup"}' "$REPO" \
    | bash "$PLUGIN/hooks/scripts/$hook.sh" 2>/dev/null)"
  RC=$?
  set -e
  [ "$RC" -eq 0 ] || fail "K4: $hook must exit 0 on an unadopted machine (got $RC)"
  [ -z "$OUT" ] || fail "K4: $hook must be silent on an unadopted machine. Got: $OUT"
done

# A sourced reader has no exit status, so assert on what it returns.
[ "$(block_state "Session WIP")" = "absent" ] \
  || fail "K4: with no pact file, the block state must be 'absent'"

# --- K5: nothing leaks into the work tree ------------------------------------
# The pact file and registry are outside every work tree BY DESIGN, and that is
# what makes them safe to hold operational state at all. A script that wrote
# into the repo would put a person's working pattern one `git add` from a
# public commit.
pact 1
live x
wip "y" || true
[ ! -e "$REPO/.claude" ] || fail "K5: a .claude directory appeared in the work tree"
leaked="$(find "$REPO" -name 'pacts.md' -o -name '*.json' 2>/dev/null | head -1)"
[ -z "$leaked" ] || fail "K5: state leaked into the work tree: $leaked"

echo "PASS: cadence integration — one pact, three readers, one answer; silent when unadopted; nothing leaks"
