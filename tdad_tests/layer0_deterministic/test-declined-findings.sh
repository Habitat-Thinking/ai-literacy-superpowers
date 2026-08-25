#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for recording a declined finding
# (spec 2026-08-25-record-declined-findings-design.md; D1-D10 -> A1-A10).
#
# D9 IS THE GUARD. The relaxation exists so that saying no is cheap; if it leaks
# into accepted records, a rule could enter force with no Rule section and no
# cost, which is far worse than the hole being fixed.
#
# D4 IS THE POINT. Declining must cost ONE section. If a rejected harness-loop
# record still needs four tier-2 sections plus a cost, nobody records a refusal
# and the corpus keeps recording only what entered.

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
cd "$TMP"
mkdir -p harness/decisions harness/assay
printf '# Harness\n\nHand-written.\n' > HARNESS.md

A="harness/assay/2026-08-25T08-08Z-assay.md"

reg() { set +e; OUT="$( "$PY" "$REG" "$@" 2>&1 )"; RC=$?; set -e; }
val() { set +e; VOUT="$( "$PY" "$VAL" 2>&1 )"; VRC=$?; set -e; }

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

# finding-1 is a harness-loop finding, the heaviest tier, so D4 proves the
# relaxation on the case that would otherwise cost the most to decline.
cat > "$A" <<'EOF'
---
assay: harness/assay/2026-08-25T08-08Z-assay.md
date: 2026-08-25
agent: harness-assayer
model: claude-opus-5
---

# Assay 2026-08-25T08-08Z

## Findings

### finding-1 — An epic's authority cited to a document nobody can open

Six specs carry a provenance line naming a build spec supplied in conversation.
No such document exists in the repository.

```yaml
classification: harness-loop
enforcement: advisory
surfaces: [ci]
priority: P2
evidence:
  - HARNESS.md
overfitting_risk: low
```

#### Proposed rule

````markdown
- **Rule**: A spec naming a source document as its authority must cite something
  a second reader can open.
- **Enforcement**: agent
- **Scope**: pr
````

#### Cost estimate

Fifteen to forty minutes once per epic.
EOF

# === D3: a rejection with no reason is refused before anything is written ====
# There is no later gate for a rejection - it is written at `rejected` and never
# accepted - so the reason is supplied up front rather than left as a
# placeholder that would either block the write or sit in the corpus forever.
reg propose --assay "$A" --finding finding-1 --today 2026-08-25 --slug declined --reject
[ "$RC" -ne 0 ] || fail "D3: --reject without --reason-file must refuse. Out: $OUT"
[ -f harness/decisions/HDR-2026-08-25-declined.md ] \
  && fail "D3: a record was written despite the refusal"
printf '' > empty.txt
reg propose --assay "$A" --finding finding-1 --today 2026-08-25 --slug declined \
  --reject --reason-file empty.txt
[ "$RC" -ne 0 ] || fail "D3b: an empty reason must refuse. Out: $OUT"
[ -f harness/decisions/HDR-2026-08-25-declined.md ] \
  && fail "D3b: a record was written despite the refusal"
echo "D3 ok (no reason, no record)"
echo "D3b ok (empty reason, no record)"

# === D1/D2: --reject writes a complete rejected record =======================
cat > reason.txt <<'EOF'
The deviations were accurate; the harm was checkability, and transcription fixed
it without a rule.
EOF
reg propose --assay "$A" --finding finding-1 --today 2026-08-25 --slug declined \
  --reject --reason-file reason.txt
[ "$RC" -eq 0 ] || fail "D1: propose --reject failed. Out: $OUT"
H="harness/decisions/HDR-2026-08-25-declined.md"
[ -f "$H" ] || fail "D1: no record written"
grep -q '^status: rejected$' "$H" || fail "D1: status is not 'rejected'"
grep -q '^## Finding$' "$H"       || fail "D2: no '## Finding' section"
grep -q '^## Rejection$' "$H"     || fail "D2: no '## Rejection' section"
grep -q 'checkability' "$H"       || fail "D2: the reason was not carried"
grep -q '_TODO' "$H"              && fail "D2: a rejection must never carry a placeholder"
echo "D1 ok (rejected record written)"
echo "D2 ok (Finding carried, reason recorded)"

# === D4: Finding + Rejection alone is enough, even for harness-loop =========
grep -q '^## Rule$'  "$H" && fail "D4 setup: the record should carry no ## Rule"
grep -q '^## Cost$'  "$H" && fail "D4 setup: the record should carry no ## Cost"
grep -q '^## Why this layer$' "$H" && fail "D4 setup: no tier-2 sections expected"
val
[ "$VRC" -eq 0 ] || fail "D4: Finding + Rejection should validate. Out: $VOUT"
echo "D4 ok (one section to decline a harness-loop finding)"

# === D5/D6/D7: no artifact, no feed, but present in the index ===============
BEFORE="$( "$PY" -c "import hashlib;print(hashlib.sha256(open('HARNESS.md','rb').read()).hexdigest())" )"
reg compile
[ "$RC" -eq 0 ] || fail "D5: compile failed. Out: $OUT"
AFTER="$( "$PY" -c "import hashlib;print(hashlib.sha256(open('HARNESS.md','rb').read()).hexdigest())" )"
[ "$BEFORE" = "$AFTER" ] || fail "D5: a rejected record reached an artifact"
echo "D5 ok (reaches no artifact)"

reg timeline
[ "$RC" -eq 0 ] || fail "D6: timeline failed. Out: $OUT"
printf '%s' "$OUT" | grep -q 'HDR-2026-08-25-declined' \
  && fail "D6: a rejection must not appear in the intervention feed"
echo "D6 ok (absent from the feed)"

grep -q 'HDR-2026-08-25-declined' harness/decisions/index.md \
  || fail "D7: the rejection is missing from the index"
grep -E 'HDR-2026-08-25-declined.*\| rejected \|' harness/decisions/index.md >/dev/null \
  || fail "D7: index should show state 'rejected'. Row: $(grep 'declined' harness/decisions/index.md)"
echo "D7 ok (in the index, state rejected)"

# === D9: the relaxation must not leak into accepted records =================
# Same body, flipped to accepted. It must now fail for the sections it lacks.
cp "$H" harness/decisions/HDR-2026-08-25-leak.md
"$PY" - harness/decisions/HDR-2026-08-25-leak.md <<'PYEOF'
import sys
p = sys.argv[1]; t = open(p).read()
t = t.replace("id: HDR-2026-08-25-declined", "id: HDR-2026-08-25-leak")
t = t.replace("status: rejected", "status: accepted")
open(p, "w").write(t)
PYEOF
val
[ "$VRC" -ne 0 ] || fail "D9: an accepted record with no Rule/Cost validated - the relaxation leaked"
printf '%s' "$VOUT" | grep -qi 'Rule\|Cost' \
  || fail "D9: the failure should name the missing sections. Out: $VOUT"
rm -f harness/decisions/HDR-2026-08-25-leak.md
echo "D9 ok (accepted records still require everything)"

# === D8: a rejection consumes no cycle slot =================================
# Three accepted records from one assay is the cap. Add rejections on top and
# the corpus must still validate.
for n in 1 2 3; do
  cp "$H" "harness/decisions/HDR-2026-08-25-extra-$n.md"
  "$PY" - "harness/decisions/HDR-2026-08-25-extra-$n.md" "$n" <<'PYEOF'
import sys
p, n = sys.argv[1], sys.argv[2]
t = open(p).read().replace("id: HDR-2026-08-25-declined", f"id: HDR-2026-08-25-extra-{n}")
open(p, "w").write(t)
PYEOF
done
val
[ "$VRC" -eq 0 ] || fail "D8: rejections consumed a cycle slot. Out: $VOUT"
echo "D8 ok (rejections do not count against the cap)"

# === D10: a propose leaves the corpus checkable ==============================
# The gates are deliberately separate and a proposal is SUPPOSED to sit at
# `proposed` and carry forward. If check fails for that whole interval, the CI
# entry point is red whenever anyone uses the loop as documented, and people
# learn to ignore it (#564).
#
# D8 and D9 build fixtures by copying files directly, which legitimately leaves
# the index stale. Sync first, so what D10 measures is whether PROPOSE
# introduces drift, not whether `cp` does.
reg index
[ "$RC" -eq 0 ] || fail "D10 setup: index regeneration failed. Out: $OUT"
reg check
[ "$RC" -eq 0 ] || fail "D10 setup: corpus is not clean before the test. Out: $OUT"

reg propose --assay "$A" --finding finding-1 --today 2026-08-25 --slug plainprop
[ "$RC" -eq 0 ] || fail "D10b setup: propose failed. Out: $OUT"
reg check
[ "$RC" -eq 0 ] || fail "D10b: check must pass after a plain propose. Out: $OUT"
grep -q 'HDR-2026-08-25-plainprop' harness/decisions/index.md   || fail "D10b: the proposed record is missing from the index"
echo "D10 ok (check passes straight after a propose, rejected or not)"

# Only the index moves: a proposed record reaches no artifact and is absent from
# the enforcement report.
grep -q 'HDR-2026-08-25-plainprop' harness/enforcement-report.md 2>/dev/null \
  && fail "D10c: a proposed record reached the enforcement report"
grep -q 'BEGIN GENERATED' HARNESS.md \
  && fail "D10c: a proposed record reached HARNESS.md"
echo "D10c ok (only the index moved)"

echo "declined findings: all checks passed (D1-D10)"
