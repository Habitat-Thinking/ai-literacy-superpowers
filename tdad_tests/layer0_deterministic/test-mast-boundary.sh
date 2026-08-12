#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the boundary notices and the note store
# (spec 2026-08-12-cadence-sentinels-s3b-boundary-notices-design.md; MB/MN).
#
# MB4 and MB10 carry the constitutional weight.
#
# MB4: nothing is created for a human who declared no Budgets block. A
# directory appearing under ~/.claude/ for someone who opted into nothing is
# operational state with no operational purpose.
#
# MB10: the store records only what FIRED. An earlier design carried a line
# reading "continued past the 20:00 stop by choice", timestamped identically to
# the notice — written before the human had done anything. Nothing observes a
# choice; continuing is the absence of stopping, and reading intent into
# silence is exactly what the boundary between counting and watching forbids.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN="$SCRIPT_DIR/../../ai-literacy-superpowers"
HOOK="$PLUGIN/hooks/scripts/mast-boundary-check.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
[ -f "$HOOK" ] || fail "boundary hook not found at $HOOK"

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
export CLAUDE_MAST_DIR="$TMP/mast" CLAUDE_ADVISORY_DIR="$TMP/rail" CLAUDE_PACTS_FILE="$TMP/pacts.md"

# shellcheck source=/dev/null
. "$PLUGIN/hooks/scripts/lib/mast-notes-write.sh"

run() { set +e; OUT="$(printf '{"cwd":"%s"}' "$TMP" | bash "$HOOK" 2>/dev/null)"; RC=$?; set -e; }

# pact <hard_stop_hour> [extra...] — a well-formed Budgets block
pact() {
  { printf '# Pacts\n\n## Budgets\n\n- hard_stop_hour: %s\n' "$1"; shift
    [ "$#" -gt 0 ] && printf '%s\n' "$@"
    printf '\nUnspent budget is not a debt.\n'; } > "$CLAUDE_PACTS_FILE"
}
at() { printf '%02d:%02d' "$1" "$2"; }   # a local HH:MM
minutes_from_now() { date -v+"$1"M +%H:%M 2>/dev/null || date -d "+$1 minutes" +%H:%M; }

# --- MB4: no block, no output, AND no store ---------------------------------
: > "$CLAUDE_PACTS_FILE"
run
[ "$RC" -eq 0 ] || fail "MB4: must exit 0 (got $RC)"
[ -z "$OUT" ] || fail "MB4: must be silent with no Budgets block. Got: $OUT"
[ ! -d "$CLAUDE_MAST_DIR" ] \
  || fail "MB4: no store may be created for a human who declared nothing"

# --- MB3: silent well before the line ---------------------------------------
pact "$(minutes_from_now 300)"
run
[ -z "$OUT" ] || fail "MB3: must be silent five hours out. Got: $OUT"

# --- MB1: approaching fires once --------------------------------------------
pact "$(minutes_from_now 20)"
run
echo "$OUT" | grep -qiE 'minute' || fail "MB1: approaching must fire inside the lead. Got: $OUT"
run
[ -z "$OUT" ] || fail "MB1: approaching must fire once. Got: $OUT"

# --- MB2: reached fires once and recommends /coda ---------------------------
rm -rf "${CLAUDE_MAST_DIR:?}" "${CLAUDE_ADVISORY_DIR:?}"
pact "$(at 0 1)"   # 00:01 — already passed for any run after 00:01
run
echo "$OUT" | grep -qF '/coda' || fail "MB2: reached must recommend /coda. Got: $OUT"
echo "$OUT" | grep -qiE 'stops you|keep going' \
  || fail "MB2: reached must say it does not stop you. Got: $OUT"
run
[ -z "$OUT" ] || fail "MB2: reached must fire once. Got: $OUT"

# --- MB7: the notice state survives consumption ------------------------------
# /coda's last step is a statement, not a process ending, so the Stop rail keeps
# firing. A store deleted at close would re-fire reached on the next turn.
notes_mark_consumed "$TMP"
notes_read "$TMP" | grep -q 'consumed-by-coda' || fail "MB7: consumption must be recorded"
[ -f "$(notes_path "$TMP")" ] || fail "MB7: consumption must MARK, never remove"
rm -rf "${CLAUDE_ADVISORY_DIR:?}"
run
[ -z "$OUT" ] || fail "MB7: reached must not fire again after consumption. Got: $OUT"

# --- MB10: the store records what fired, never what it meant -----------------
contents="$(notes_read "$TMP")"
echo "$contents" | grep -q 'reached hard_stop_hour' || fail "MB10: the fired event must be recorded"
if echo "$contents" | grep -qiE 'by choice|continued|chose|decided|ignored'; then
  fail "MB10: the store must hold no attribution of intent. Got: $contents"
fi

# --- MB6: a repeating advisory defers to the once-only notice ----------------
# shellcheck source=/dev/null
. "$PLUGIN/hooks/scripts/lib/advisory-rail.sh"
rm -rf "${CLAUDE_MAST_DIR:?}" "${CLAUDE_ADVISORY_DIR:?}"
pact "$(at 0 1)"
run
[ -n "$OUT" ] || fail "MB6: setup — reached should have fired"
advisory_defer_if_claimed stop \
  || fail "MB6: a once-only notice must claim the turn so a repeating advisory defers"

# --- MB11: the warden DEFERS; it does not claim ------------------------------
# Structural, and deliberately so. Driving reservoir-check.sh to the point of
# emission needs an opted-in Cognitive reservoir block and crossed git-window
# thresholds, which is beyond Layer 0 — but the distinction it guards is the
# one that reshaped this slice, so it is worth pinning at the only level
# available here.
#
# If the warden claimed once-only instead of deferring, first-claim-wins would
# return by the back door: it re-emits every turn while a threshold stays
# crossed, so it would take the claim on the turn before the Mast's notice and
# permanently spend a message designed to arrive once.
RCHK="$PLUGIN/hooks/scripts/reservoir-check.sh"
grep -q 'advisory_defer_if_claimed stop' "$RCHK" \
  || fail "MB11: reservoir-check must DEFER to a once-only claim"
if grep -q 'advisory_claim once-only' "$RCHK"; then
  fail "MB11: reservoir-check must not claim once-only — it repeats every turn and would spend the Mast's single notice"
fi

# --- MB5: malformed degrades to silence, never a gate -----------------------
rm -rf "${CLAUDE_MAST_DIR:?}" "${CLAUDE_ADVISORY_DIR:?}"
printf '# Pacts\n\n## Budgets\n\n- hard_stop_hour: 00:01\n\nThe clause is gone.\n' > "$CLAUDE_PACTS_FILE"
run
[ "$RC" -eq 0 ] || fail "MB5: malformed must never gate (got $RC)"
[ -z "$OUT" ] || fail "MB5: malformed must be silent. Got: $OUT"

# --- MN3/MB8: the prune is unconditional, and everything exits 0 -------------
# The janitor must not sit behind the opt-in: deleting your pact would
# otherwise leave every note file behind forever.
mkdir -p "$CLAUDE_MAST_DIR"; : > "$CLAUDE_MAST_DIR/old.notes"
touch -t 202001010000 "$CLAUDE_MAST_DIR/old.notes"
: > "$CLAUDE_PACTS_FILE"          # opted out entirely
run
[ ! -f "$CLAUDE_MAST_DIR/old.notes" ] \
  || fail "MN3: a stale note file must be pruned even with no declared block"

blocked="$TMP/blocked"; : > "$blocked"
set +e; OUT="$(printf '{"cwd":"%s"}' "$TMP" | CLAUDE_MAST_DIR="$blocked/x" bash "$HOOK" 2>/dev/null)"; RC=$?; set -e
[ "$RC" -eq 0 ] || fail "MB8: an unwritable store must still exit 0 (got $RC)"
set +e; OUT="$(printf 'not json' | env -u HOME bash "$HOOK" 2>/dev/null)"; RC=$?; set -e
[ "$RC" -eq 0 ] || fail "MB8: HOME unset and junk stdin must still exit 0 (got $RC)"

# --- MN4: the read library exposes no mutation -------------------------------
R="$PLUGIN/hooks/scripts/lib/mast-notes-read.sh"
( unset -f notes_append notes_prune notes_mark_consumed 2>/dev/null || true
  # shellcheck source=/dev/null
  . "$R"
  if declare -F notes_append >/dev/null || declare -F notes_prune >/dev/null; then
    echo "FAIL: MN4: sourcing the read library must not define a mutator" >&2; exit 1
  fi ) || exit 1
if grep -nE '(^|[^[:alnum:]_])(rm|rmdir|mv|cp|tee|truncate)[[:space:]]' "$R" | grep -vqE ':[[:space:]]*#'; then
  fail "MN4: the read library must contain no mutation command"
fi

# --- MN5: one repo's notes are its own ---------------------------------------
rm -rf "${CLAUDE_MAST_DIR:?}"
notes_append "reached a" "/repo/alpha"
notes_append "reached b" "/repo/beta"
notes_read "/repo/alpha" | grep -q 'reached a' || fail "MN5: alpha's note must be readable"
if notes_read "/repo/alpha" | grep -q 'reached b'; then
  fail "MN5: one repo's notes must not leak into another's"
fi

echo "PASS: boundary notices — once each, store holds only what fired, prune unconditional"
