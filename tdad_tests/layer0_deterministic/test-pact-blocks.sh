#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the pact-block reader
# (spec 2026-08-08-cadence-sentinels-s1-infrastructure-design.md, §3; B1–B9).
#
# The reader is the one thing in S1 that parses a pact file. Three sentinels
# consume it in S2–S5, so the properties tested here are the properties those
# slices inherit — above all two of them:
#
#   1. The value-extraction rule (§3.6). The inherited `read_key` from
#      reservoir-check.sh is greedy on `[:=]` and strips interior whitespace,
#      so `hard_stop_hour: 18:30` yields `30` and `focus_blocks: 09:00-12:00,
#      14:00-17:00` yields `00`. B7 is the test that forbids reusing it.
#   2. Block scoping (§3.6). B8 is the ONLY scenario that can distinguish a
#      block-scoped lookup from a whole-file one; a single-block fixture
#      passes with `read_key` unmodified and proves nothing.
#
# Contract under test (spec §3.8), all from lib/pact-blocks.sh:
#   pact_file                              -> resolved path ($CLAUDE_PACTS_FILE, else ~/.claude/pacts.md)
#   block_state <heading>                  -> absent | malformed | declared
#   block_key <heading> <key> <default>    -> value, first-delimiter split, ends-trimmed
#   block_absent_note <heading>            -> the fixed observe-only sentence
#
# Absence is never an error and malformed is never a gate: every path here
# exits 0 (spec §3.7, the Null Object contract).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN="$SCRIPT_DIR/../../ai-literacy-superpowers"
LIB="$PLUGIN/hooks/scripts/lib/pact-blocks.sh"
TEMPLATE="$PLUGIN/templates/pacts.md"
FIX="$SCRIPT_DIR/fixtures/cadence-pacts"

fail() { echo "FAIL: $*" >&2; exit 1; }

[ -f "$LIB" ] || fail "pact-block reader not found at $LIB"
[ -f "$TEMPLATE" ] || fail "pact template not found at $TEMPLATE"

# shellcheck source=/dev/null
. "$LIB"

for fn in pact_file block_state block_key block_absent_note; do
  declare -F "$fn" >/dev/null || fail "lib must define $fn"
done

# --- B1: template well-formed, no trailing inline comments on value lines ----
# The trap is real: read_key strips whitespace but keeps a trailing `#`, so a
# tuned value with an inline comment degrades silently to its default. The
# shipped HARNESS.md template makes this mistake; the pact template must not.
for heading in "Session WIP" "Budgets" "Sync cadence"; do
  grep -qE "^#{1,6}[[:space:]]+${heading}\$" "$TEMPLATE" \
    || fail "B1: template is missing the '${heading}' heading"
done
if grep -nE '^[[:space:]]*-[[:space:]]*[a-z_]+[[:space:]]*:.*#' "$TEMPLATE"; then
  fail "B1: a template value line carries a trailing '#' comment — read_key would swallow it into the value"
fi

# --- B2: mandatory clauses present in the template ---------------------------
# Matched whitespace-normalised, exactly as the library matches them: the
# clause's words are the interface, its line breaks are not. A template author
# may wrap the sentence; they may not reword it.
flat_template=$(tr '\n' ' ' < "$TEMPLATE" | tr -s '[:space:]' ' ')
echo "$flat_template" | grep -qF 'Unspent budget is not a debt.' \
  || fail "B2: template Budgets block is missing the literal not-a-debt clause"
echo "$flat_template" | grep -qF 'It counts; it does not assess.' \
  || fail "B2: template Session WIP block is missing the gate-on-sessions clause"

# --- B3: Sync cadence carries the reserved marker -----------------------------
echo "$flat_template" | grep -qiF 'Reserved. No sentinel reads this block yet.' \
  || fail "B3: template Sync cadence block is missing the reserved marker"

# --- B4: no pact file at all — every block absent, note emitted, exit 0 -------
export CLAUDE_PACTS_FILE="$SCRIPT_DIR/fixtures/cadence-pacts/does-not-exist.md"
for heading in "Session WIP" "Budgets" "Sync cadence"; do
  set +e; state=$(block_state "$heading"); rc=$?; set -e
  [ "$rc" -eq 0 ] || fail "B4: block_state must exit 0 when no pact file exists (got $rc)"
  [ "$state" = "absent" ] || fail "B4: '$heading' must be absent when no pact file exists, got '$state'"
  note=$(block_absent_note "$heading")
  echo "$note" | grep -qF "running in observe-only mode" \
    || fail "B4: absent note must carry the fixed observe-only sentence, got '$note'"
  echo "$note" | grep -qF "$heading" \
    || fail "B4: absent note must name the block, got '$note'"
done

# --- B5: absent block inside a file that exists -------------------------------
export CLAUDE_PACTS_FILE="$FIX/budgets-only.md"
[ "$(block_state 'Session WIP')" = "absent" ] \
  || fail "B5: 'Session WIP' must be absent in a file declaring only Budgets"
[ "$(block_state 'Budgets')" = "declared" ] \
  || fail "B5: 'Budgets' must be declared in the budgets-only fixture"

# --- B9: default returned for an absent optional key --------------------------
# budgets-only.md deliberately omits sessions_per_day.
set +e; val=$(block_key 'Budgets' 'sessions_per_day' 'FALLBACK'); rc=$?; set -e
[ "$rc" -eq 0 ] || fail "B9: block_key must exit 0 for an absent key (got $rc)"
[ "$val" = "FALLBACK" ] || fail "B9: absent key must return the supplied default, got '$val'"

# --- B6: malformed — clause deleted, degrades to observe-only, never a gate ---
export CLAUDE_PACTS_FILE="$FIX/malformed-budgets.md"
set +e; state=$(block_state 'Budgets'); rc=$?; set -e
[ "$rc" -eq 0 ] || fail "B6: a malformed block must never gate — block_state must exit 0 (got $rc)"
[ "$state" = "malformed" ] \
  || fail "B6: a Budgets block missing the not-a-debt clause must be 'malformed', got '$state'"
note=$(block_absent_note 'Budgets')
echo "$note" | grep -qF "running in observe-only mode" \
  || fail "B6: a malformed block must still emit the observe-only sentence, got '$note'"

# --- B7: colon- and space-bearing values survive extraction -------------------
# This is the scenario the inherited greedy parser fails. Verified empirically
# at the spec gate: read_key turns 18:30 into 30 and the focus_blocks list
# into 00.
export CLAUDE_PACTS_FILE="$FIX/full.md"
[ "$(block_state 'Budgets')" = "declared" ] || fail "B7: full fixture's Budgets must be declared"

val=$(block_key 'Budgets' 'hard_stop_hour' '')
[ "$val" = "18:30" ] || fail "B7: hard_stop_hour must be '18:30', got '$val' (greedy split yields '30')"

val=$(block_key 'Budgets' 'focus_blocks' '')
[ "$val" = "09:00-12:00, 14:00-17:00" ] \
  || fail "B7: focus_blocks must survive whole, got '$val' (greedy split yields '00')"

val=$(block_key 'Budgets' 'daily_cost_ceiling' '')
[ "$val" = "not observable" ] \
  || fail "B7: daily_cost_ceiling must keep its interior space, got '$val'"

val=$(block_key 'Sync cadence' 'sync_points' '')
[ "$val" = "09:00, 16:00" ] || fail "B7: sync_points must survive whole, got '$val'"

# A bare integer must still work — the regression guard on the simple case.
val=$(block_key 'Session WIP' 'max_concurrent_sessions' '')
[ "$val" = "2" ] || fail "B7: a bare integer value must still parse, got '$val'"

# --- B8: block-scoped key isolation ------------------------------------------
# The only scenario that distinguishes block-scoped from whole-file lookup.
export CLAUDE_PACTS_FILE="$FIX/shared-key.md"
val=$(block_key 'Session WIP' 'enforcement' '')
[ "$val" = "advisory" ] \
  || fail "B8: Session WIP's enforcement must be 'advisory', got '$val'"
val=$(block_key 'Budgets' 'enforcement' '')
[ "$val" = "strict" ] \
  || fail "B8: Budgets' enforcement must be 'strict', got '$val' — a whole-file parser returns 'advisory' here"

echo "PASS: pact-block reader — template well-formed, three states honoured, values survive extraction, keys scoped to their block"
