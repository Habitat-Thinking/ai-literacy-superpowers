#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for review, expiry and demotion
# (spec 2026-08-23-harness-evolution-s4-review-demotion-design.md, §7; D1-D16).
#
# D7/D8 ARE THE DISSOLVED CONFLICT. S2 froze accepted records and checks them
# against git. Supersession conventionally writes `superseded_by` and
# `status: superseded` onto the record being superseded - an edit to a frozen
# record, so the two mechanisms would have contradicted each other on the first
# demotion anyone performed. Rather than carve an exception into the one check
# that guarantees accepted rules are not quietly reworded, supersession is
# DERIVED from the successor's `supersedes` field and the old record is never
# touched. These two assertions are what stop that decision eroding.
#
# D11 IS THE ONE THAT KEEPS THE DESIGN HONEST. The two-assay threshold exists to
# make rules hard to ADD. Applying it to removal would mean a rule that turned
# out to be wrong needed two assays' evidence before anyone could withdraw it,
# and would stay in force meanwhile - the exact inversion of "hard to add, easy
# to retire".

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
REG="$ROOT/ai-literacy-superpowers/scripts/harness-registrar.py"
VAL="$ROOT/ai-literacy-superpowers/scripts/check-harness-decisions.py"

fail() { echo "FAIL: $*" >&2; exit 1; }
[ -f "$REG" ] || fail "harness registrar not found at $REG"

PY=/usr/bin/python3
command -v "$PY" >/dev/null 2>&1 || PY=python3

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
HARNESS="$TMP/harness"
DEC="$HARNESS/decisions"
mkdir -p "$DEC" "$HARNESS/assay" "$TMP/.claude/agents"

reg() { set +e; OUT="$( cd "$TMP" && "$PY" "$REG" "$@" 2>&1 )"; RC=$?; set -e; }
val() { set +e; OUT="$( cd "$TMP" && "$PY" "$VAL" 2>&1 )"; RC=$?; set -e; }

tree_hash() {
  ( cd "$TMP" && "$PY" -c "
import hashlib, os
h = hashlib.sha256()
for dirpath, dirs, files in os.walk('.'):
    dirs[:] = sorted(d for d in dirs if d != '.git')
    for name in sorted(files):
        p = os.path.join(dirpath, name)
        h.update(p.encode()); h.update(open(p, 'rb').read())
print(h.hexdigest())
" )
}

expect_ok()   { [ "$RC" -eq 0 ] || fail "$1: expected exit 0, got $RC. Out: $OUT"; }
expect_fail() {
  [ "$RC" -ne 0 ] || fail "$1: expected non-zero exit, got 0. Out: $OUT"
  printf '%s' "$OUT" | grep -q 'Traceback' \
    && fail "$1: crashed instead of refusing. Out: $OUT"
  printf '%s' "$OUT" | grep -qi -- "$2" \
    || fail "$1: message must mention '$2'. Out: $OUT"
}

cat > "$HARNESS/surfaces.yaml" <<'EOF'
routes:
  harness-loop: HARNESS.md
  turn-instructions: AGENTS.md

surfaces:
  claude-code:
    targets: [CLAUDE.md, .claude/agents/]
    supports: [advisory, validated, blocked]
  ci:
    targets: [.github/workflows/]
    supports: [validated, blocked]
EOF
printf '# Harness\n\nHand-written.\n' > "$TMP/HARNESS.md"
printf '# Agents\n\nHand-written.\n' > "$TMP/AGENTS.md"
printf '# Build log\n\nEvidence lives here.\n' > "$HARNESS/build-log.md"
printf -- '---\nassay: a\ndate: 2026-01-01\nagent: harness-assayer\nmodel: m\n---\n' \
  > "$HARNESS/assay/2026-01-01T00-00Z-assay.md"
printf -- '---\nassay: b\ndate: 2026-02-01\nagent: harness-assayer\nmodel: m\n---\n' \
  > "$HARNESS/assay/2026-02-01T00-00Z-assay.md"

cat > "$TMP/mkhdr.py" <<'PYEOF'
import json, os, sys

d = json.load(sys.stdin)
root = os.environ["FIXTURE_ROOT"]
hid = d["id"]
cls = d.get("classification", "turn-instructions")
status = d.get("status", "accepted")

L = ["---", f"id: {hid}", "title: " + d.get("title", "A rule"),
     f"status: {status}", f"classification: {cls}",
     "enforcement: " + d.get("enforcement", "advisory"),
     "surfaces: [" + ", ".join(d.get("surfaces", ["claude-code"])) + "]"]
if d.get("provisional", True):
    L += ["provisional: true"]
    if d.get("expires", "2099-01-01"):
        L.append("expires: " + d.get("expires", "2099-01-01"))
    if d.get("review_trigger"):
        L.append('review_trigger: "' + d["review_trigger"] + '"')
else:
    L.append("provisional: false")
if d.get("imported"):
    L.append("imported: true")
if d.get("target"):
    L.append("target: " + d["target"])
L.append("evidence:")
for e in d.get("evidence", ["harness/build-log.md#x"]):
    L.append(f"  - {e}")
L += ["proposed_cost: |", "  An estimate."]
if status == "accepted":
    L += ["cost: |", "  " + d.get("cost", "The approver's own words about this rule."),
          "approver: russ@russmiles.com",
          "approved_at: " + d.get("approved_at", "2026-01-01T00:00Z")]
else:
    L.append('cost: ""')
L += ["proposer:", "  agent: " + d.get("agent", "harness-assayer"), "  model: claude-opus-5"]
if d.get("assay", "harness/assay/2026-01-01T00-00Z-assay.md"):
    L.append("  assay: " + d.get("assay", "harness/assay/2026-01-01T00-00Z-assay.md"))
L.append("supersedes: " + (d["supersedes"] if d.get("supersedes") else "null"))
L.append("superseded_by: " + (d["superseded_by"] if d.get("superseded_by") else "null"))
L += ["---", "", "## Finding", "", "Something was observed.", "", "## Rule", ""]
if d.get("withdrawn"):
    L.append("Withdrawn.")
elif cls == "no-change":
    L.append("No change.")
else:
    L += ["````markdown", d.get("rule", "- **Rule**: The fixture rule."), "````"]
L += ["", "## Cost", "", "What this demands of whoever works here next.", ""]
if cls in ("harness-loop", "script-validator", "new-agent"):
    for h in ("Why this layer", "Enforcement", "Validation", "Rejected alternatives"):
        L += [f"## {h}", "", "A real, human-written answer.", ""]

with open(os.path.join(root, "harness", "decisions", hid + ".md"), "w") as fh:
    fh.write("\n".join(L).rstrip("\n") + "\n")
PYEOF
mkhdr() { FIXTURE_ROOT="$TMP" "$PY" "$TMP/mkhdr.py"; }

# === D1: an expired rule still in force fails check ==========================
mkhdr <<'EOF'
{"id": "HDR-2026-01-01-lapsed", "title": "A lapsed rule", "expires": "2026-02-01"}
EOF
reg compile; expect_ok "D1 (compile)"
reg check
expect_fail "D1 (expired rule still in force)" "expired"

# === D4: superseding it clears the failure ==================================
mkhdr <<'EOF'
{"id": "HDR-2026-03-01-renewed", "title": "Re-evidenced", "expires": "2099-01-01",
 "supersedes": "HDR-2026-01-01-lapsed", "agent": "harness-review", "assay": "",
 "evidence": ["harness/decisions/HDR-2026-01-01-lapsed.md"]}
EOF
reg compile; expect_ok "D4 (compile after supersession)"
reg check; expect_ok "D4 (supersession clears the lapse)"

# === D5: a superseded record compiles nothing ================================
grep -q 'HDR-2026-01-01-lapsed' "$TMP/AGENTS.md" \
  && fail "D5: a superseded record is still compiled into its target"
grep -q 'HDR-2026-03-01-renewed' "$TMP/AGENTS.md" \
  || fail "D5: the superseding record was not compiled"

# === D6: it stays in the corpus and in the index, marked superseded ===========
[ -f "$DEC/HDR-2026-01-01-lapsed.md" ] || fail "D6: the record was deleted"
grep -q 'HDR-2026-01-01-lapsed' "$DEC/index.md" || fail "D6: missing from the index"
"$PY" - "$DEC/index.md" <<'PYEOF'
import re, sys
idx = open(sys.argv[1]).read()
row = next(ln for ln in idx.splitlines() if "HDR-2026-01-01-lapsed" in ln)
assert "superseded" in row.lower(), f"D6: the index does not derive superseded: {row!r}"
row2 = next(ln for ln in idx.splitlines() if "HDR-2026-03-01-renewed" in ln)
assert "superseded" not in row2.lower(), f"D6: the successor is marked superseded: {row2!r}"
PYEOF
echo "D6 ok (superseded state derived, not stored)"

# === D2/D3: what never lapses ================================================
mkhdr <<'EOF'
{"id": "HDR-2026-01-02-imported", "title": "Grandfathered", "provisional": false,
 "imported": true, "agent": "imported", "assay": "",
 "evidence": ["HARNESS.md#tests-pass-before-merge"]}
EOF
mkhdr <<'EOF'
{"id": "HDR-2026-01-03-permanent", "title": "Earned permanence", "provisional": false,
 "assay": ""}
EOF
reg compile; expect_ok "D2/D3 (compile)"
reg check; expect_ok "D2/D3 (neither an import nor a non-provisional rule lapses)"

# === D7: derived states may not be stored ====================================
for bad in superseded expired; do
  mkhdr <<EOF
{"id": "HDR-2026-01-04-stored-$bad", "title": "Stores a derived state",
 "status": "$bad"}
EOF
  val
  expect_fail "D7 (stored status: $bad)" "derived"
  rm -f "$DEC/HDR-2026-01-04-stored-$bad.md"
done

# === D8: superseded_by must be null ==========================================
mkhdr <<'EOF'
{"id": "HDR-2026-01-05-back-pointer", "title": "Stores a back pointer",
 "superseded_by": "HDR-2026-03-01-renewed"}
EOF
val
expect_fail "D8 (non-null superseded_by)" "derived"
rm -f "$DEC/HDR-2026-01-05-back-pointer.md"

# === D9: broken supersession chains ==========================================
mkhdr <<'EOF'
{"id": "HDR-2026-01-06-ghost", "title": "Supersedes nothing that exists",
 "supersedes": "HDR-1999-01-01-does-not-exist"}
EOF
val; expect_fail "D9a (supersedes a missing record)" "does-not-exist"
rm -f "$DEC/HDR-2026-01-06-ghost.md"

mkhdr <<'EOF'
{"id": "HDR-2026-01-07-ouroboros", "title": "Supersedes itself",
 "supersedes": "HDR-2026-01-07-ouroboros"}
EOF
val; expect_fail "D9b (supersedes itself)" "itself"
rm -f "$DEC/HDR-2026-01-07-ouroboros.md"

# Two records superseding the same predecessor: the chain forks, and nothing can
# say which successor is in force.
mkhdr <<'EOF'
{"id": "HDR-2026-04-01-rival", "title": "A second successor",
 "supersedes": "HDR-2026-01-01-lapsed", "agent": "harness-review", "assay": "",
 "evidence": ["harness/decisions/HDR-2026-01-01-lapsed.md"]}
EOF
val; expect_fail "D9c (two records supersede one)" "already superseded"
rm -f "$DEC/HDR-2026-04-01-rival.md"

# === D10/D11: retirement =====================================================
mkhdr <<'EOF'
{"id": "HDR-2026-05-01-orphan-retirement", "title": "Retires nothing",
 "withdrawn": true}
EOF
val; expect_fail "D10a (a retirement must supersede something)" "supersedes"
rm -f "$DEC/HDR-2026-05-01-orphan-retirement.md"

# A harness-loop rule, then its retirement citing ONE assay. The two-assay
# threshold must not apply: making a wrong rule hard to withdraw is the exact
# inversion of "hard to add, easy to retire".
mkhdr <<'EOF'
{"id": "HDR-2026-06-01-loop-rule", "title": "A loop-layer rule",
 "classification": "harness-loop", "expires": "2099-01-01",
 "evidence": ["harness/assay/2026-01-01T00-00Z-assay.md#f1",
              "harness/assay/2026-02-01T00-00Z-assay.md#f2"]}
EOF
reg compile; expect_ok "D11 (compile the loop rule)"
grep -q 'HDR-2026-06-01-loop-rule' "$TMP/HARNESS.md" || fail "D11: loop rule not applied"

mkhdr <<'EOF'
{"id": "HDR-2026-07-01-loop-retirement", "title": "Withdraw the loop rule",
 "classification": "harness-loop", "withdrawn": true,
 "supersedes": "HDR-2026-06-01-loop-rule", "agent": "harness-review", "assay": "",
 "evidence": ["harness/decisions/HDR-2026-06-01-loop-rule.md"]}
EOF
val; expect_ok "D11 (a harness-loop retirement needs no second assay)"
reg compile; expect_ok "D10b (compile the retirement)"
grep -q 'HDR-2026-06-01-loop-rule' "$TMP/HARNESS.md" \
  && fail "D10b: the retired rule is still in HARNESS.md"
grep -q 'HDR-2026-07-01-loop-retirement' "$TMP/HARNESS.md" \
  && fail "D10b: a retirement compiled rule text of its own"
reg check; expect_ok "D10b (check clean after retirement)"

# === D12: the cycle cap counts live records ==================================
for n in 1 2 3; do
  mkhdr <<EOF
{"id": "HDR-2026-08-0$n-capped", "title": "Capped rule $n",
 "assay": "harness/assay/2026-02-01T00-00Z-assay.md"}
EOF
done
val; expect_ok "D12 (three live records from one assay)"

mkhdr <<'EOF'
{"id": "HDR-2026-08-04-capped", "title": "Capped rule 4",
 "assay": "harness/assay/2026-02-01T00-00Z-assay.md"}
EOF
val; expect_fail "D12 (a fourth live record from one assay)" "three"

# Superseding one frees its slot: the cap limits how much governance an assay
# ADDS, and a retired rule adds nothing.
mkhdr <<'EOF'
{"id": "HDR-2026-09-01-frees-a-slot", "title": "Withdraw capped rule 1",
 "withdrawn": true, "supersedes": "HDR-2026-08-01-capped",
 "agent": "harness-review", "assay": "",
 "evidence": ["harness/decisions/HDR-2026-08-01-capped.md"]}
EOF
val; expect_ok "D12 (superseding one frees its slot)"

# === D17: not provisional means no expiry ====================================
# A rule that is not on trial has no trial date. Permitting both would leave a
# record carrying an expiry that nothing acts on - which reads to a human as a
# lapse waiting to happen and to a machine as nothing at all. Those two readings
# diverging is the failure this whole corpus exists to prevent.
"$PY" - "$DEC" <<'EOF'
import os, sys
path = os.path.join(sys.argv[1], "HDR-2026-01-08-contradiction.md")
open(path, "w").write("""---
id: HDR-2026-01-08-contradiction
title: Not provisional, yet expires
status: accepted
classification: turn-instructions
enforcement: advisory
surfaces: [claude-code]
provisional: false
expires: 2026-02-01
evidence:
  - harness/build-log.md#x
proposed_cost: |
  An estimate.
cost: |
  The approver's own words.
approver: russ@russmiles.com
approved_at: 2026-01-01T00:00Z
proposer:
  agent: harness-assayer
  model: claude-opus-5
supersedes: null
superseded_by: null
---

## Finding

Something was observed.

## Rule

````markdown
- **Rule**: The fixture rule.
````

## Cost

What this demands of whoever works here next.
""")
EOF
val
expect_fail "D17 (provisional: false with an expiry)" "contradiction"
rm -f "$DEC/HDR-2026-01-08-contradiction.md"

# === D13/D14: evidence resolution ============================================
mkhdr <<'EOF'
{"id": "HDR-2026-10-01-dangling", "title": "Cites a path that is gone",
 "evidence": ["harness/deleted-log.md#x"]}
EOF
reg compile >/dev/null 2>&1 || true
reg check
expect_fail "D13 (evidence names a path that does not exist)" "deleted-log"
rm -f "$DEC/HDR-2026-10-01-dangling.md"

mkhdr <<'EOF'
{"id": "HDR-2026-10-02-scheme", "title": "Cites a trace URI",
 "evidence": ["trace://run/8821", "harness/build-log.md#x"]}
EOF
reg compile; expect_ok "D14 (compile)"
reg check
expect_ok "D14 (a URI-scheme reference does not fail the check)"
printf '%s' "$OUT" | grep -qi 'trace://run/8821' \
  || fail "D14: an unresolvable-by-design reference must be NAMED as skipped, not
passed in silence - otherwise any evidence can be laundered by prefixing a
scheme. Out: $OUT"

# === D15/D16: review is read-only and separates the two kinds of lapse ========
mkhdr <<'EOF'
{"id": "HDR-2026-11-01-trigger-only", "title": "Trigger with no expiry",
 "expires": "", "review_trigger": "Two consecutive assays with zero findings"}
EOF
mkhdr <<'EOF'
{"id": "HDR-2026-11-02-lapsed-again", "title": "Another lapsed rule",
 "expires": "2026-03-01"}
EOF
reg compile >/dev/null 2>&1 || true

BEFORE="$(tree_hash)"
reg review
[ "$(tree_hash)" = "$BEFORE" ] || fail "D16: review wrote to the corpus"

printf '%s' "$OUT" | grep -q 'HDR-2026-11-02-lapsed-again' \
  || fail "D15: review does not list the expired record. Out: $OUT"
printf '%s' "$OUT" | grep -q 'HDR-2026-11-01-trigger-only' \
  || fail "D15: review does not list the trigger-only record. Out: $OUT"
printf '%s' "$OUT" | grep -qi 'Triggers nothing can evaluate' \
  || fail "D15: trigger-only records must be listed in their OWN section - a
trigger is free text, so a rule carrying one and no expiry never lapses and is
permanent by construction. Out: $OUT"
printf '%s' "$OUT" | grep -qi 're-evidence' \
  || fail "D15: review must name the three outcomes. Out: $OUT"
# A rule that is in force and not lapsed must not be listed.
printf '%s' "$OUT" | grep -q 'HDR-2026-01-03-permanent' \
  && fail "D15: review listed a rule that has not lapsed. Out: $OUT"

echo "harness review/demotion: all checks passed (D1-D16)"
