#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the next-action anchor check
# (spec 2026-08-09-cadence-sentinels-s2-coda-design.md, §3; N1–N8).
#
# READ THE EXIT CODES CAREFULLY. This script is not a validator and exit 1 is
# not a failure:
#
#     exit 0  -> the next action carries an anchor; do not ask again
#     exit 1  -> no anchor found; ASK ONE MORE QUESTION
#
# The first revision of the spec made this a judge that refused to write a
# parking record until the text passed. That was wrong twice. It measures
# lexical form, not specificity — "keep going in src/" carries an anchor and
# would have passed — and its errors run systematically along the code/non-code
# axis, which is worse than noisy, because the Coda parks decision-shaped
# threads by design.
#
# Demoted to a trigger, both error directions cost the same thing: one extra
# question. The human always answers and the answer is always parked. That is
# why N7 exists — a caller must not be able to mistake a trigger for a fault.
#
# §3.3's grammar is published verbatim in skills/coda/SKILL.md and
# reference/parking-record-format.md, so a human who is asked can argue with it.
# These scenarios are what keep those three copies honest.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN="$SCRIPT_DIR/../../ai-literacy-superpowers"
CHECK="$PLUGIN/scripts/next-action-hint.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

[ -f "$CHECK" ] || fail "anchor check not found at $CHECK"
[ -x "$CHECK" ] || fail "anchor check is not executable: $CHECK"

# asks <text> — true when the check would ask another question (exit 1).
asks() {
  set +e
  "$CHECK" "$1" >/dev/null 2>&1
  local rc=$?
  set -e
  [ "$rc" -eq 1 ]
}

expect_ask() {
  asks "$1" || fail "$2: expected a question for [$1], got none"
}
expect_quiet() {
  asks "$1" && fail "$2: expected no question for [$1], got one" || true
}

# --- N1: no anchor triggers the question -------------------------------------
# A bare English noun is not an anchor. "parser" naming a thing is not the same
# as naming where to start.
for t in \
  "continue work" \
  "carry on" \
  "keep going" \
  "finish this" \
  "pick up where I left off" \
  "more work on the parser"
do
  expect_ask "$t" "N1"
done

# --- N2: each anchor kind in §3.3's table is recognised ----------------------
expect_quiet "rewrite src/parser.rs to split on the first delimiter" "N2 path"
expect_quiet "fix block_key() so it trims only at the ends"          "N2 identifier"
# shellcheck disable=SC2016  # literal backticks are the fixture — that is the anchor kind under test
expect_quiet 'work through the `records_open` glob again'            "N2 backtick"
expect_quiet "add the B12 fixture for a malformed block"             "N2 scenario id"
expect_quiet "revisit pact-blocks.sh:88 and the heading rule"        "N2 line ref"

# --- N8: the decision anchor ------------------------------------------------
# The row that stops the grammar taxing this plugin's own dominant kind of
# work. The other five kinds are all artefacts of code-shaped work; most of
# what gets parked here is a spec, a piece of prose, or a decision.
expect_quiet "ask Russ whether the reserved block should ship at all" "N8 question+person"
expect_quiet "decide between the lease and the explicit transition"   "N8 decide"
expect_quiet "choose between archiving and capping the corpus"        "N8 choose between"

# --- N3: the question names what is missing ----------------------------------
set +e
msg="$("$CHECK" "continue work" 2>&1)"
set -e
echo "$msg" | grep -qiE 'file|test|first step' \
  || fail "N3: the question must name a file, a test, or a first step. Got: $msg"
echo "$msg" | grep -qiE 'too vague|invalid|rejected|error' \
  && fail "N3: the question must not render a verdict on the wording. Got: $msg"

# --- N4: a terse anchor passes ----------------------------------------------
expect_quiet "test_retry.py" "N4"

# --- N5: a vague stem with an anchor passes ----------------------------------
# A known false positive, disclosed in §3.2 — and it costs nothing, because the
# check only decides whether to ask.
expect_quiet "continue the retry branch in test_retry.py" "N5"

# --- N6: empty and whitespace-only trigger the question ----------------------
expect_ask ""      "N6 empty"
expect_ask "   "   "N6 spaces"

# --- N7: a trigger is not an error -------------------------------------------
# The caller reads exit 1 as "ask again". If the script also wrote to stderr or
# used the vocabulary of failure, a caller — or a future maintainer — would
# read it as a fault and start guarding against it.
set +e
stderr="$("$CHECK" "continue work" 2>&1 >/dev/null)"
set -e
[ -z "$stderr" ] || fail "N7: a trigger must write nothing to stderr. Got: $stderr"

echo "PASS: next-action anchor check — triggers a question, never a verdict; all six anchor kinds recognised"
