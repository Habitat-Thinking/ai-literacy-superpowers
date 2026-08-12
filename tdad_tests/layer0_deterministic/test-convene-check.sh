#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the consultation-disposition check
# (spec 2026-08-12-cadence-sentinels-s5-convener-design.md, §9.1; V1–V8).
#
# V5 is the one the spec gate found, and it is why S1 grew a second query.
# `records_open` excludes `*.resolved.md` BY NAME — and a disposed voice only
# ever exists inside a `.resolved.md`, because the append-only rule forbids
# editing a `disposition` key in place. A check built on `records_open` would
# therefore read an empty set for every fully-disposed record and pass it
# vacuously: the one query available could not see the one file that matters.
# So this reads through `records_latest`.
#
# V7 is the other half of the design. `pending` is a detectable failure; eight
# voices bulk-filled `deliberately-not-consulted / "no time"` is an undetectable
# one, and revision 1 blessed exactly that string while forbidding any check on
# dispositions. An all-pending record is truthful about disengagement; an
# all-declined one launders it into eight decisions nobody made — permanently,
# because the record is append-only and the next reader will trust it.
#
# The check never judges a REASON. "No time; shipping Thursday and the docs
# owner is on leave" passes. It refuses one string standing for eight decisions.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
CHECK="$ROOT/ai-literacy-superpowers/scripts/check-consultation-dispositions.py"

fail() { echo "FAIL: $*" >&2; exit 1; }
[ -f "$CHECK" ] || fail "consultation check not found at $CHECK"

PY=/usr/bin/python3
command -v "$PY" >/dev/null 2>&1 || PY=python3

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
SPECS="$TMP/docs/superpowers/specs"
RECS="$TMP/docs/superpowers/consultations"
mkdir -p "$SPECS" "$RECS"

spec() {  # spec <slug> — a spec file the check will look for a record against
  printf '# Spec\n' > "$SPECS/2026-08-12-$1-design.md"
}

run() {
  set +e
  OUT="$( cd "$TMP" && "$PY" "$CHECK" 2>&1 )"
  RC=$?
  set -e
}

# --- V1: a spec with no consultation record passes ---------------------------
# Complete-if-present, not required. Running /convene remains a choice, and a
# project that never convened has not made the mistake this catches.
spec retry-semantics
run
[ "$RC" -eq 0 ] || fail "V1: a spec with no record must pass (got $RC). Out: $OUT"

# --- V8: the record is found by <spec-slug>.md -------------------------------
# S1's first grammar gave <YYYY-MM-DD>-<slug>.md carrying the RECORD's date, so
# nothing connected a spec to its record. The naming rule is now the same one
# the objection and story records use.
cat > "$RECS/retry-semantics-design.md" <<'EOF'
---
spec: docs/superpowers/specs/2026-08-12-retry-semantics-design.md
date: 2026-08-12
state: open
supersedes: null
voices:
  - voice: Support
    source_flag: inferred
    question: does the new error code change what you tell callers?
    disposition: pending
    outcome: null
---
EOF
run
[ "$RC" -ne 0 ] || fail "V8: a record at <spec-slug>.md must be found. Out: $OUT"
echo "$OUT" | grep -qF "retry-semantics" \
  || fail "V8: the failure must name the spec. Got: $OUT"

# --- V3: a pending voice fails, naming the voice ------------------------------
echo "$OUT" | grep -qF "Support" || fail "V3: must name the pending voice. Got: $OUT"

# V3b: pending fails even when someone filled in an outcome. `pending` means
# nobody decided, and an outcome attached to it describes a conversation whose
# disposition was never recorded — the abandoned conversation exactly.
cat > "$RECS/retry-semantics-design.md" <<'EOF'
---
spec: docs/superpowers/specs/2026-08-12-retry-semantics-design.md
date: 2026-08-12
state: open
supersedes: null
voices:
  - voice: Support
    source_flag: inferred
    question: does the new error code change what you tell callers?
    disposition: pending
    outcome: raised it in standup, waiting to hear back
---
EOF
run
[ "$RC" -ne 0 ] || fail "V3b: a pending voice must fail even with an outcome. Out: $OUT"
echo "$OUT" | grep -qi 'pending' \
  || fail "V3b: the failure must say the voice is pending. Got: $OUT"

# --- V2: a fully-dispositioned record passes ----------------------------------
# Both dispositions are complete answers. Deciding NOT to ask someone, for a
# stated reason, is a real decision made deliberately — which is the point.
cat > "$RECS/retry-semantics-design.md" <<'EOF'
---
spec: docs/superpowers/specs/2026-08-12-retry-semantics-design.md
date: 2026-08-12
state: open
supersedes: null
voices:
  - voice: Support
    source_flag: inferred
    question: does the new error code change what you tell callers?
    disposition: consulted
    outcome: they want the code in the message body, not just the header
  - voice: Docs
    source_flag: observed
    question: does the published reference describe the old timeout?
    disposition: deliberately-not-consulted
    outcome: the page is generated from this file, so there is nothing to decide
---
EOF
run
[ "$RC" -eq 0 ] || fail "V2: a fully-dispositioned record must pass. Out: $OUT"

# --- V4: deliberately-not-consulted with no outcome fails ---------------------
# The because is what makes it a disposition rather than a shrug.
cat > "$RECS/retry-semantics-design.md" <<'EOF'
---
spec: docs/superpowers/specs/2026-08-12-retry-semantics-design.md
date: 2026-08-12
state: open
supersedes: null
voices:
  - voice: Docs
    source_flag: observed
    question: does the published reference describe the old timeout?
    disposition: deliberately-not-consulted
    outcome: null
---
EOF
run
[ "$RC" -ne 0 ] || fail "V4: declined with no outcome must fail. Out: $OUT"
echo "$OUT" | grep -qiE 'outcome|because|reason' \
  || fail "V4: the failure must say the outcome is missing. Got: $OUT"

# --- V7: identical outcomes across voices fail --------------------------------
# One string cannot stand for several decisions.
cat > "$RECS/retry-semantics-design.md" <<'EOF'
---
spec: docs/superpowers/specs/2026-08-12-retry-semantics-design.md
date: 2026-08-12
state: open
supersedes: null
voices:
  - voice: Support
    source_flag: inferred
    question: does the new error code change what you tell callers?
    disposition: deliberately-not-consulted
    outcome: no time
  - voice: Docs
    source_flag: observed
    question: does the published reference describe the old timeout?
    disposition: deliberately-not-consulted
    outcome: no time
---
EOF
run
[ "$RC" -ne 0 ] || fail "V7: two voices sharing one outcome must fail. Out: $OUT"
echo "$OUT" | grep -qiE 'same|identical|distinct|repeat' \
  || fail "V7: the failure must say the outcomes are not distinct. Got: $OUT"

# V7b: a REASON is never judged. Specific-to-the-voice is the whole test.
cat > "$RECS/retry-semantics-design.md" <<'EOF'
---
spec: docs/superpowers/specs/2026-08-12-retry-semantics-design.md
date: 2026-08-12
state: open
supersedes: null
voices:
  - voice: Support
    source_flag: inferred
    question: does the new error code change what you tell callers?
    disposition: deliberately-not-consulted
    outcome: no time; shipping Thursday and support triage is already queued
  - voice: Docs
    source_flag: observed
    question: does the published reference describe the old timeout?
    disposition: deliberately-not-consulted
    outcome: no time; the docs owner is on leave until the week after release
---
EOF
run
[ "$RC" -eq 0 ] || fail "V7b: honest per-voice reasons must pass, however thin. Out: $OUT"

# V7c: capitalising one of them does not make one decision two. Case, spacing
# and trailing punctuation are not content, and a rule that could be evaded by
# pressing shift would teach evasion rather than thought.
cat > "$RECS/retry-semantics-design.md" <<'EOF'
---
spec: docs/superpowers/specs/2026-08-12-retry-semantics-design.md
date: 2026-08-12
state: open
supersedes: null
voices:
  - voice: Support
    source_flag: inferred
    question: does the new error code change what you tell callers?
    disposition: deliberately-not-consulted
    outcome: No time.
  - voice: Docs
    source_flag: observed
    question: does the published reference describe the old timeout?
    disposition: deliberately-not-consulted
    outcome: no   time
---
EOF
run
[ "$RC" -ne 0 ] \
  || fail "V7c: case and spacing must not disguise one string as two. Out: $OUT"

# --- V5: a superseded record is not checked; its successor is -----------------
# The finding that grew records_latest. The predecessor still carries `pending`
# on every voice — a check that read it would fail a fully-disposed PR.
cat > "$RECS/retry-semantics-design.md" <<'EOF'
---
spec: docs/superpowers/specs/2026-08-12-retry-semantics-design.md
date: 2026-08-12
state: superseded
supersedes: null
voices:
  - voice: Support
    source_flag: inferred
    question: does the new error code change what you tell callers?
    disposition: pending
    outcome: null
---
EOF
cat > "$RECS/retry-semantics-design.resolved.md" <<'EOF'
---
spec: docs/superpowers/specs/2026-08-12-retry-semantics-design.md
date: 2026-08-12
state: resolved
supersedes: retry-semantics-design.md
voices:
  - voice: Support
    source_flag: inferred
    question: does the new error code change what you tell callers?
    disposition: consulted
    outcome: they want the code in the message body, not just the header
---
EOF
run
[ "$RC" -eq 0 ] \
  || fail "V5: the resolved successor must be what is checked, not its pending predecessor. Out: $OUT"

# V5b: and the successor's own failures are still caught.
cat > "$RECS/retry-semantics-design.resolved.md" <<'EOF'
---
spec: docs/superpowers/specs/2026-08-12-retry-semantics-design.md
date: 2026-08-12
state: resolved
supersedes: retry-semantics-design.md
voices:
  - voice: Support
    source_flag: inferred
    question: does the new error code change what you tell callers?
    disposition: pending
    outcome: null
---
EOF
run
[ "$RC" -ne 0 ] || fail "V5b: a pending voice in the successor must still fail. Out: $OUT"
rm -f "$RECS"/retry-semantics-design*.md

# --- V6: a malformed record fails loudly --------------------------------------
# A matcher that cannot parse a record must not report it clean. Silence on an
# unparseable file is the failure mode that makes a green check meaningless.
printf 'no frontmatter here at all\n' > "$RECS/retry-semantics-design.md"
run
[ "$RC" -ne 0 ] || fail "V6: a record with no frontmatter must fail loudly. Out: $OUT"
echo "$OUT" | grep -qiE 'malformed|could not|cannot|unparse|no frontmatter' \
  || fail "V6: the failure must say the record could not be read. Got: $OUT"

cat > "$RECS/retry-semantics-design.md" <<'EOF'
---
spec: docs/superpowers/specs/2026-08-12-retry-semantics-design.md
date: 2026-08-12
state: open
supersedes: null
voices:
  - voice: Support
    source_flag: inferred
    question: does the new error code change what you tell callers?
    disposition: maybe-later
    outcome: null
---
EOF
run
[ "$RC" -ne 0 ] || fail "V6b: an off-enum disposition must fail. Out: $OUT"
rm -f "$RECS"/*.md

# --- V1b: a record with no voices at all is not a breach ----------------------
# The Convener found nobody, and said so. That is a complete answer.
cat > "$RECS/retry-semantics-design.md" <<'EOF'
---
spec: docs/superpowers/specs/2026-08-12-retry-semantics-design.md
date: 2026-08-12
state: open
supersedes: null
voices: []
---
EOF
run
[ "$RC" -eq 0 ] || fail "V1b: an empty voice list must pass. Out: $OUT"
rm -f "$RECS"/*.md

# --- V1c: no consultations directory at all passes ----------------------------
# The overwhelming majority of repos. A check that errored here would fail
# every project that never adopted the Convener.
rm -rf "$RECS"
run
[ "$RC" -eq 0 ] || fail "V1c: an absent consultations directory must pass (got $RC). Out: $OUT"
mkdir -p "$RECS"

# --- V9: an orphan record — no matching spec — is reported, not ignored -------
# A record whose spec was renamed or deleted is silently unenforced otherwise,
# which is the drift the harness-auditor exists to find.
cat > "$RECS/vanished-design.md" <<'EOF'
---
spec: docs/superpowers/specs/2026-08-12-vanished-design.md
date: 2026-08-12
state: open
supersedes: null
voices:
  - voice: Support
    source_flag: inferred
    question: does anything still call this?
    disposition: consulted
    outcome: nothing has called it since the March migration
---
EOF
run
[ "$RC" -ne 0 ] || fail "V9: a record with no matching spec must be reported. Out: $OUT"
echo "$OUT" | grep -qiE 'no spec|orphan|missing spec|no matching' \
  || fail "V9: the failure must say the spec is missing. Got: $OUT"

echo "PASS: consultation dispositions — complete-if-present, reads the successor, refuses one string for many decisions"
