#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for assay corrections
# (spec 2026-08-25-assay-corrections-design.md; E1-E10 -> A1-A10).
#
# E3 IS NON-NEGOTIABLE. The whole point is a correction channel that never edits
# the record, so the assay is hashed before and after. "The assay was not
# touched" is a measurable claim, and asserting it by reading the code is not.
#
# THE FIXTURES ARE THE TWO REAL ERRORS from 2026-08-25T08-08Z-assay.md: the
# provenance count (six specs, actually four) and the GC rule count (nineteen
# rules, actually five). Both were load-bearing, and one reached a frozen record.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
REG="$ROOT/ai-literacy-superpowers/scripts/harness-registrar.py"

fail() { echo "FAIL: $*" >&2; exit 1; }
[ -f "$REG" ] || fail "harness registrar not found at $REG"

PY=/usr/bin/python3
command -v "$PY" >/dev/null 2>&1 || PY=python3

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"
mkdir -p harness/decisions harness/assay
printf '# Harness\n\nHand-written.\n' > HARNESS.md

A="harness/assay/2026-08-25T08-08Z-assay.md"
E="harness/assay/2026-08-25T08-08Z-assay.errata.md"

reg() { set +e; OUT="$( "$PY" "$REG" "$@" 2>&1 )"; RC=$?; set -e; }
sha() { "$PY" -c "import hashlib,sys;print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())" "$1"; }

refuses() {
  [ "$RC" -ne 0 ] || fail "$1: expected non-zero exit, got 0. Out: $OUT"
  printf '%s' "$OUT" | grep -q 'Traceback' && fail "$1: crashed instead of refusing. Out: $OUT"
  printf '%s' "$OUT" | grep -qi -- "$2" || fail "$1: message must mention '$2'. Out: $OUT"
}

cat > harness/surfaces.yaml <<'EOF'
routes:
  harness-loop: HARNESS.md
  turn-instructions: AGENTS.md
  script-validator: HARNESS.md
surfaces:
  ci:
    targets: [.github/workflows/]
    supports: [validated, blocked]
EOF

cat > "$A" <<'EOF'
---
assay: harness/assay/2026-08-25T08-08Z-assay.md
date: 2026-08-25
agent: harness-assayer
model: claude-opus-5
---

# Assay 2026-08-25T08-08Z

## Findings

### finding-2 — The periodic check suite stops at its first failure

`.github/workflows/gc.yml` runs nineteen declared GC rules as sequential steps.
Only the Summary step carries `if: always()`.

```yaml
classification: harness-loop
enforcement: validated
surfaces: [ci]
priority: P1
evidence:
  - .github/workflows/gc.yml
```

#### Proposed rule

````markdown
- **Rule**: A periodic check suite must produce a result for every rule it
  declares, in every run.
````

#### Cost estimate

Thirty minutes once.

### finding-7 — Something else entirely, never corrected

An unrelated observation that stands.

```yaml
classification: harness-loop
enforcement: validated
surfaces: [ci]
priority: P2
evidence:
  - HARNESS.md
```

#### Proposed rule

````markdown
- **Rule**: Something else.
````

#### Cost estimate

Nothing.
EOF

BEFORE="$(sha "$A")"
printf 'gc.yml carries eleven rule steps covering five of the nineteen declared\nGC rules, not nineteen. The masking observation is unaffected and stands.\n' > correction.txt

# === E2: refusals write nothing =============================================
reg correct --assay "$A" --finding finding-99 --correction-file correction.txt
refuses "E2" "finding-99"
[ -f "$E" ] && fail "E2: an errata file was written despite the refusal"
reg correct --assay harness/assay/nope.md --finding finding-2 --correction-file correction.txt
refuses "E2b" "not found"
printf '' > empty.txt
reg correct --assay "$A" --finding finding-2 --correction-file empty.txt
refuses "E2c" "empty"
[ -f "$E" ] && fail "E2c: an errata file was written despite the refusal"
echo "E2 ok (unknown finding, missing assay and empty correction all refuse)"

# === E1: a correction is recorded ===========================================
reg correct --assay "$A" --finding finding-2 --correction-file correction.txt
[ "$RC" -eq 0 ] || fail "E1: correct failed. Out: $OUT"
[ -f "$E" ] || fail "E1: no errata file written"
grep -q '^## finding-2$' "$E" || fail "E1: errata does not name the finding"
grep -q 'eleven rule steps' "$E" || fail "E1: the correction text was not carried"
echo "E1 ok (correction recorded)"

# a second correction appends rather than replacing
printf 'A further correction, appended.\n' > second.txt
reg correct --assay "$A" --finding finding-7 --correction-file second.txt
[ "$RC" -eq 0 ] || fail "E1b: second correct failed. Out: $OUT"
grep -q '^## finding-2$' "$E" || fail "E1b: the first correction was lost"
grep -q '^## finding-7$' "$E" || fail "E1b: the second correction is missing"
echo "E1b ok (appends, never replaces)"

# === E3: the assay is byte-identical ========================================
AFTER="$(sha "$A")"
[ "$BEFORE" = "$AFTER" ] || fail "E3: the assay was modified"
echo "E3 ok (assay untouched, verified by hash)"

# === E4: propose on a corrected finding refuses =============================
reg propose --assay "$A" --finding finding-2 --today 2026-08-25 --slug corrected
refuses "E4" "correction"
printf '%s' "$OUT" | grep -q 'eleven rule steps' \
  || fail "E4: the refusal must quote the correction. Out: $OUT"
[ -f harness/decisions/HDR-2026-08-25-corrected.md ] \
  && fail "E4: a record was written despite the refusal"
echo "E4 ok (refused, correction quoted, nothing written)"

# === E5: acknowledging proceeds, and the record says so =====================
reg propose --assay "$A" --finding finding-2 --today 2026-08-25 --slug corrected \
  --acknowledge-correction
[ "$RC" -eq 0 ] || fail "E5: acknowledged propose failed. Out: $OUT"
grep -qi 'correction' harness/decisions/HDR-2026-08-25-corrected.md \
  || fail "E5: the record does not record that a correction was acknowledged"
echo "E5 ok (acknowledged, and the record says so)"

# === E6: an uncorrected finding in the same assay is unaffected =============
# finding-7 was corrected above, so use a third assay finding path: re-run
# against a fresh assay with no errata to prove the gate is not global.
mkdir -p harness/assay
cp "$A" harness/assay/2026-08-24T08-08Z-assay.md
"$PY" - harness/assay/2026-08-24T08-08Z-assay.md <<'PYEOF'
import sys
p = sys.argv[1]; t = open(p).read()
open(p, "w").write(t.replace("2026-08-25T08-08Z", "2026-08-24T08-08Z"))
PYEOF
reg propose --assay harness/assay/2026-08-24T08-08Z-assay.md --finding finding-2 \
  --today 2026-08-25 --slug uncorrected
[ "$RC" -eq 0 ] || fail "E6: an assay with no errata must propose normally. Out: $OUT"
echo "E6 ok (uncorrected findings unaffected)"

# === E7: a corrected finding does not corroborate ===========================
# The two-assay threshold exists so a single incident cannot reach the loop
# layer. Without this, a falsified observation could be the second assay that
# lets a rule through.
mkdir -p harness/decisions
mkhdr() {  # mkhdr <slug> <evidence-yaml-lines>
  cat > "harness/decisions/HDR-2026-08-25-$1.md" <<EOF
---
id: HDR-2026-08-25-$1
title: A loop-layer rule
status: accepted
classification: harness-loop
enforcement: validated
surfaces: [ci]
provisional: true
expires: 2026-11-23
evidence:
$2
cost: |
  Written by a human.
proposer:
  agent: harness-assayer
  model: claude-opus-5
  assay: $A
approver: tester
approved_at: 2026-08-25T10:00Z
supersedes: null
superseded_by: null
---

## Finding

Observed twice.

## Rule

\`\`\`\`markdown
- **Rule**: Something.
\`\`\`\`

## Cost

Written by a human.

## Why this layer

Written by a human.

## Enforcement

Written by a human.

## Validation

Written by a human.

## Rejected alternatives

Written by a human.
EOF
}

# Two distinct assays, but the finding cited in one carries a correction.
mkhdr corroborated "  - $A#finding-2
  - harness/assay/2026-08-24T08-08Z-assay.md#finding-2"
set +e
VOUT="$( "$PY" "$ROOT/ai-literacy-superpowers/scripts/check-harness-decisions.py" 2>&1 )"; VRC=$?
set -e
[ "$VRC" -ne 0 ] || fail "E7: a corrected finding corroborated a loop-layer rule. Out: $VOUT"
printf '%s' "$VOUT" | grep -qi 'two distinct assays' \
  || fail "E7: the refusal should name the threshold. Out: $VOUT"
echo "E7 ok (a corrected finding does not corroborate)"

# The same shape, citing an UNCORRECTED finding in the same assay, still passes.
mkhdr corroborated "  - $A#finding-99-uncorrected
  - harness/assay/2026-08-24T08-08Z-assay.md#finding-2"
set +e
VOUT="$( "$PY" "$ROOT/ai-literacy-superpowers/scripts/check-harness-decisions.py" 2>&1 )"; VRC=$?
set -e
[ "$VRC" -eq 0 ] || fail "E7b: an uncorrected finding must still corroborate. Out: $VOUT"
echo "E7b ok (exclusion is per-finding, not per-assay)"
rm -f harness/decisions/HDR-2026-08-25-corroborated.md

echo "assay corrections: all checks passed (E1-E7)"
