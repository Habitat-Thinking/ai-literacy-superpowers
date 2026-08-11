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

# --- B10: a clause wrapped across lines still reads as declared --------------
# Clause matching normalises whitespace, because the clause's WORDS are the
# interface and its line breaks are not. Every block above whose clause happens
# to sit on one line matches with or without normalisation, so none of them
# guards this — B7's Budgets clause is single-line in every fixture.
#
# Session WIP's clause wraps mid-sentence in both the shipped template and
# full.md, which makes it the one case that can fail. Without normalisation it
# reads `malformed`, which is the exact regression that shipped and was caught
# by hand on the first run.
export CLAUDE_PACTS_FILE="$TEMPLATE"
[ "$(block_state 'Session WIP')" = "declared" ] \
  || fail "B10: the template's Session WIP clause wraps across lines and must still read as declared"

export CLAUDE_PACTS_FILE="$FIX/full.md"
[ "$(block_state 'Session WIP')" = "declared" ] \
  || fail "B10: a wrapped Session WIP clause must read as declared in the full fixture too"

# And the guard must not be so loose that a genuinely missing clause passes.
export CLAUDE_PACTS_FILE="$FIX/malformed-budgets.md"
[ "$(block_state 'Budgets')" = "malformed" ] \
  || fail "B10: normalisation must not make a deleted clause look present"

# --- B11: a standalone # comment inside a block does not truncate it --------
# The pact file is hand-edited, and the shipped guidance warns only against a
# trailing `#` on a VALUE line — which reads as permission for a comment on its
# own line. Under the general markdown rule that comment ends the span, taking
# the mandatory clause with it and flipping a good block to malformed.
export CLAUDE_PACTS_FILE="$FIX/with-comments.md"
[ "$(block_state 'Session WIP')" = "declared" ] \
  || fail "B11: a standalone # comment must not truncate the block into malformed"
val=$(block_key 'Session WIP' 'stale_after_hours' 'MISSING')
[ "$val" = "6" ] \
  || fail "B11: a key below a # comment must still be readable, got '$val'"
[ "$(block_state 'Budgets')" = "declared" ] \
  || fail "B11: a sub-heading inside a block must not truncate it"
val=$(block_key 'Budgets' 'sessions_per_day' 'MISSING')
[ "$val" = "3" ] || fail "B11: a key below a sub-heading must be readable, got '$val'"
# The block must still END at the next real block heading — B8 would pass
# trivially if a span simply ran to end-of-file.
val=$(block_key 'Session WIP' 'hard_stop_hour' 'NOT-MINE')
[ "$val" = "NOT-MINE" ] \
  || fail "B11: Session WIP must not absorb Budgets' keys, got '$val'"

# --- B12: block_state answers well-formedness, not completeness -------------
# S1 defined malformed as "mandatory clause OR required key missing" and only
# the clause half was ever implemented. The gate that found it (#503) decided
# the DEFINITION was the defect, not the code.
#
# /mast tune deliberately offers a two-line pact — "a number invented to move
# the dialogue along is not more authored than one they declined to give" — so
# a human who declares Session WIP with only stale_after_hours authored exactly
# what they meant. Calling that malformed says it is broken. It is not; it is
# partial, on purpose.
export CLAUDE_PACTS_FILE="$FIX/partial-wip.md"
[ "$(block_state 'Session WIP')" = "declared" ] \
  || fail "B12: a deliberately partial block is well-formed, not malformed"

# --- B13: block_has_key answers the completeness question separately ---------
# This is what a consumer asks instead of trusting `declared` to mean "the
# values I need are here". It is what lets the WIP Warden say "you have not
# declared a limit" rather than inventing one.
declare -F block_has_key >/dev/null || fail "B13: lib must define block_has_key"

block_has_key 'Session WIP' 'stale_after_hours' \
  || fail "B13: a declared key must report present"
if block_has_key 'Session WIP' 'max_concurrent_sessions'; then
  fail "B13: an undeclared key must report absent"
fi

# Absent block, absent key — never an error, and never a claim of presence.
export CLAUDE_PACTS_FILE="$SCRIPT_DIR/fixtures/cadence-pacts/does-not-exist.md"
set +e; block_has_key 'Session WIP' 'anything'; rc=$?; set -e
[ "$rc" -eq 1 ] || fail "B13: an absent block must report the key absent, exit 1 (got $rc)"

# A key whose value is empty is not declared. `- max_concurrent_sessions:` with
# nothing after it is a human who started typing and stopped, not a limit.
export CLAUDE_PACTS_FILE="$FIX/empty-value.md"
if block_has_key 'Session WIP' 'max_concurrent_sessions'; then
  fail "B13: a key with an empty value must not report as declared"
fi

echo "PASS: pact-block reader — template well-formed, three states honoured, values survive extraction, keys scoped to their block"
