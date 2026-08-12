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

# --- P1: S2 adds no value to the next_action_flag enum -----------------------
# The first S2 revision proposed `asked-override`. It was removed at the gate:
# a flag recording that a human's answer failed a check is an agent-authored
# verdict about the person, permanent, committed and countable across records.
# Keeping the enum at one value is what lets S2 consume S1's contract without
# mutating it, so the consumer-never-mutates rule never engages.
grep -qF 'asked-override' "$PARKING_REF" \
  && fail "P1: the parking-record contract must not gain an override enum value — the override lives in the prose body"
grep -qiE 'next_action_flag.*asked' "$PARKING_REF" \
  || fail "P1: parking-record-format.md must still document next_action_flag: asked"

# --- P1b: the anchor grammar is published, and framed as a trigger -----------
# A check whose decisive term lives only in the implementation cannot be argued
# with, and this one is meant to be.
for kind in 'A path' 'A code identifier' 'A backticked span' 'A decision'; do
  grep -qF "$kind" "$PARKING_REF" \
    || fail "P1b: parking-record-format.md must publish the '$kind' anchor row"
done
grep -qiF 'complement is not' "$PARKING_REF" \
  || fail "P1b: the reference page must frame the table as a trigger whose complement is not 'vague'"

# --- P2: an override record is well-formed and unremarkable ------------------
# Its frontmatter must be indistinguishable from any other record; the override
# is prose the human authored and would recognise.
p2="$FIX/2026-08-09-override-example.md"
cat > "$p2" <<'EOF'
---
session: sess-p2
repo: /tmp/toy
created: 2026-08-09
state: parked
supersedes: null
next_action_flag: asked
---

## Context

A thread whose author was asked twice.

## Next action

continue work

(Asked again for a starting point; confirmed this is enough to go on.)
EOF
grep -q 'next_action_flag: asked$' "$p2" \
  || fail "P2: an override record's flag must be plain 'asked'"
grep -qF 'Asked again for a starting point' "$p2" \
  || fail "P2: the override must appear as prose in the body"

# --- P3: an override record is still open ------------------------------------
# An override changes nothing about the record's state.
open_now=$(records_open "$FIX" | sort)
echo "$open_now" | grep -qF "override-example" \
  || fail "P3: an overridden record must still be reported open"
rm -f "$p2"

# --- C4: records_latest returns the current state of each chain --------------
# The complement of records_open, and the gap S5's merge check fell into:
# a disposition only ever exists inside a .resolved.md, and records_open
# excludes every transition file by name — so the one place a disposition lives
# was the one place nothing could read.
declare -F records_latest >/dev/null || fail "C4: lib must define records_latest"

latest=$(records_latest "$FIX" | sort)
# The resolved successor is current; its predecessor is not.
echo "$latest" | grep -q "2026-08-02-retry-branch.resumed.md" \
  || fail "C4: the transition file is the current state of its chain"
if echo "$latest" | grep -q "2026-08-01-retry-branch.md"; then
  fail "C4: a superseded predecessor is not current"
fi
# A record nothing supersedes returns itself.
echo "$latest" | grep -q "2026-08-03-parser-rewrite.md" \
  || fail "C4: an unsuperseded record is its own current state"

# --- C5: records_open and records_latest answer different questions ----------
# Stating the complement explicitly, because conflating them is what the S5
# gate did: open excludes transitions, latest includes them.
open_now=$(records_open "$FIX" | sort)
if [ "$open_now" = "$latest" ]; then
  fail "C5: records_open and records_latest must not be the same set here"
fi

echo "PASS: record contracts — schemas published in reference pages, READMEs point not duplicate, open-record glob honours state-in-the-path"
