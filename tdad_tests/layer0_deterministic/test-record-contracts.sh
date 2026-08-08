#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the two record contracts S1 owns and S2/S5 consume
# (spec 2026-08-08-cadence-sentinels-s1-infrastructure-design.md, §5; C1–C3).
#
# Two properties are under test, and both exist because of a choice story.
#
#   1. WHERE the contract lives (#8). mkdocs.yml carries
#      `exclude_docs: superpowers/`, so a schema homed in a record directory's
#      README is the one format contract in this repo an adopter cannot read.
#      The schemas therefore live in published reference/ pages, and the
#      READMEs point rather than duplicate — which also removes the
#      two-copies-drift problem a duplicated schema would create.
#
#   2. HOW state transitions (#9). Constraint 7 says records are append-only,
#      and editing a `status` key from parked to resumed IS an in-place edit.
#      So state lives in the filename and a transition writes a new file.
#      C3 tests the glob that falls out of that: it is the query S2's resume
#      path depends on, and it is only correct if transitions are files.
#
# S1 owns these contracts; per the promoted ARCH_DECISION a consumer never
# mutates the contract it consumes, so S2 needing a new field carves its own
# contract-owning slice rather than editing the reference page.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
REF="$ROOT/docs/plugins/ai-literacy-superpowers/reference"
PARKED_README="$ROOT/docs/superpowers/parked/README.md"
CONSULT_README="$ROOT/docs/superpowers/consultations/README.md"
LIB="$ROOT/ai-literacy-superpowers/hooks/scripts/lib/record-paths.sh"
FIX="$SCRIPT_DIR/fixtures/cadence-records/parked"

fail() { echo "FAIL: $*" >&2; exit 1; }

# --- C1: the reference pages carry the schemas -------------------------------
PARKING_REF="$REF/parking-record-format.md"
CONSULT_REF="$REF/consultation-record-format.md"
[ -f "$PARKING_REF" ] || fail "C1: parking record format page not found at $PARKING_REF"
[ -f "$CONSULT_REF" ] || fail "C1: consultation record format page not found at $CONSULT_REF"

for field in session repo created state supersedes next_action_flag; do
  grep -qF "$field" "$PARKING_REF" \
    || fail "C1: parking-record-format.md is missing the '$field' field"
done
for field in spec date state supersedes voices source_flag question disposition outcome; do
  grep -qF "$field" "$CONSULT_REF" \
    || fail "C1: consultation-record-format.md is missing the '$field' field"
done

# Both pages must state the rule that makes append-only true, not merely claim
# append-only while describing a mutable key.
for page in "$PARKING_REF" "$CONSULT_REF"; do
  grep -qiF "append-only" "$page" || fail "C1: $(basename "$page") must state the append-only rule"
  grep -qiE "filename|state-in-the-path|in the path" "$page" \
    || fail "C1: $(basename "$page") must state that state lives in the filename"
done

# `next_action` is the field the Coda validates; the contract has to say it is
# mandatory or S2 inherits an optional field it is required to enforce.
grep -qiF "next_action" "$PARKING_REF" \
  || fail "C1: parking-record-format.md must name the mandatory next_action"

# --- C2: the directory READMEs point, they do not duplicate ------------------
[ -f "$PARKED_README" ] || fail "C2: $PARKED_README not found"
[ -f "$CONSULT_README" ] || fail "C2: $CONSULT_README not found"

grep -qF "parking-record-format" "$PARKED_README" \
  || fail "C2: parked/README.md must link its reference page"
grep -qF "consultation-record-format" "$CONSULT_README" \
  || fail "C2: consultations/README.md must link its reference page"

# A README that declares its own field set is a second copy of the contract,
# which is the drift the reference-page home exists to prevent.
for readme in "$PARKED_README" "$CONSULT_README"; do
  if grep -qE '^\s*(session|voices|next_action_flag|source_flag):' "$readme"; then
    fail "C2: $(basename "$(dirname "$readme")")/README.md declares a field set — it must point, not duplicate"
  fi
done

# --- C3: the state-in-the-path glob ------------------------------------------
[ -f "$LIB" ] || fail "C3: record path helper not found at $LIB"
# shellcheck source=/dev/null
. "$LIB"
declare -F records_open >/dev/null || fail "C3: lib must define records_open"

open=$(records_open "$FIX" | sort)
expected="$FIX/2026-08-03-parser-rewrite.md"
[ "$open" = "$expected" ] || fail "C3: expected exactly the still-parked record
  expected: $expected
  got:      $open"

# The two guards that make C3 meaningful rather than a filename coincidence.
# No match is the passing case, so these cannot sit in an `&&` chain — under
# `set -e` a failing grep would abort the script exactly when the test passes.
if echo "$open" | grep -q "retry-branch.resumed"; then
  fail "C3: a transition file must never be reported as open"
fi
if echo "$open" | grep -q "2026-08-01-retry-branch.md"; then
  fail "C3: a record named by a transition's supersedes must not be reported as open"
fi

echo "PASS: record contracts — schemas published in reference pages, READMEs point not duplicate, open-record glob honours state-in-the-path"
