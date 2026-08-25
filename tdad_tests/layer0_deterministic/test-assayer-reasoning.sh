#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for carrying the Assayer's reasoning into the record
# (spec 2026-08-25-carry-assayer-reasoning-design.md; R1-R9 -> A1-A9).
#
# R7 IS THE ONE THAT MUST NOT BREAK. The rule block is the byte-identical source
# the compiler applies, and this change touches the same parser. A regression
# there is worse than the defect being fixed.
#
# R2 IS WHY THE SECTION EXISTS AT ALL. The Assayer's words and the approver's
# must be distinguishable in the record, for the same reason proposed_cost and
# cost are separate fields: pre-filled reasoning reads exactly like considered
# reasoning, and nothing downstream can tell them apart.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
REG="$ROOT/ai-literacy-superpowers/scripts/harness-registrar.py"

fail() { echo "FAIL: $*" >&2; exit 1; }
[ -f "$REG" ] || fail "harness registrar not found at $REG"

PY=/usr/bin/python3
command -v "$PY" >/dev/null 2>&1 || PY=python3

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/harness/decisions" "$TMP/harness/assay"
printf '# Harness\n\nHand-written.\n' > "$TMP/HARNESS.md"

A="harness/assay/2026-08-25T08-08Z-assay.md"

reg() {
  set +e
  OUT="$( cd "$TMP" && "$PY" "$REG" "$@" 2>&1 )"
  RC=$?
  set -e
}

cat > "$TMP/harness/surfaces.yaml" <<'EOF'
routes:
  harness-loop: HARNESS.md
  turn-instructions: AGENTS.md
  script-validator: HARNESS.md

surfaces:
  ci:
    targets: [.github/workflows/]
    supports: [validated, blocked]
EOF

# finding-2 reproduces the real one: reasoning AFTER the metadata block, which
# is where the Assayer conventionally puts it and where extraction never looked.
# finding-5 has none, which is normal for no-change.
cat > "$TMP/$A" <<'EOF'
---
assay: harness/assay/2026-08-25T08-08Z-assay.md
date: 2026-08-25
agent: harness-assayer
model: claude-opus-5
---

# Assay 2026-08-25T08-08Z

## Findings

### finding-2 — The periodic check suite stops at its first failure

Only the Summary step carries `if: always()`, so a failing step silences every
later step. Six consecutive scheduled runs failed.

```yaml
classification: script-validator
enforcement: validated
surfaces: [ci]
priority: P1
evidence:
  - .github/workflows/gc.yml
overfitting_risk: low
```

**Why this layer, and why no existing owner absorbs it.** `/harness-gc` runs the
rules on demand. What it cannot own is the scheduled runner when nobody invokes
it: the whole value of a weekly job is the weeks nobody looks.

**Overfitting risk: low.** The rule states a property of any periodic check
suite and encodes neither of the two rules that happened to fail.

**Validation plan.** Re-run with a deliberately failing early step and assert
every later step still produces a conclusion. A fix that makes the job green by
tolerating failures is worse than the defect.

#### Proposed rule

````markdown
- **Rule**: A periodic check suite must produce a result for every rule it
  declares, in every run.

  Note the indentation and the fence below; both are part of the text.

  ```bash
  gh run view --json jobs
  ```
- **Enforcement**: deterministic
- **Scope**: pr
````

#### Cost estimate

Thirty minutes once; the weekly run looks worse before it looks better.

### finding-5 — Nothing needed to change

The decision corpus is empty because nothing has been proposed yet.

```yaml
classification: no-change
enforcement: advisory
surfaces: []
priority: P3
evidence:
  - harness/decisions/index.md
```

#### Proposed rule

No change.

#### Cost estimate

None.
EOF

# === R1/R2/R6/R7: reasoning carried, attributed, and nothing else disturbed ==
reg propose --assay "$A" --finding finding-2 --today 2026-08-25 --slug reasoned
[ "$RC" -eq 0 ] || fail "R1: propose failed. Out: $OUT"
H="$TMP/harness/decisions/HDR-2026-08-25-reasoned.md"
[ -f "$H" ] || fail "R1: HDR not written"

grep -q "^## Assayer's reasoning" "$H" \
  || fail "R1: no '## Assayer's reasoning' section. Out: $(sed -n '/^## /p' "$H")"

"$PY" - "$H" "$TMP/$A" <<'PYEOF'
import re, sys
hdr, assay = open(sys.argv[1]).read(), open(sys.argv[2]).read()

def section(text, name):
    m = re.search(rf"^## {re.escape(name)}\n(.*?)(?=^## |\Z)", text, re.M | re.S)
    return m.group(1) if m else None

# R1: byte-identical to the assay's post-metadata prose.
body = assay.split("### finding-2", 1)[1].split("### finding-5", 1)[0]
# Past the CLOSING fence of the yaml block specifically. Splitting on bare
# fences walks into the rule block's nested ```bash and lands in the wrong place.
ystart = body.index("```yaml")
yend = body.index("```", ystart + len("```yaml"))
after = body[body.index("\n", yend) + 1:]
expected = after.split("#### ", 1)[0].strip()
got = section(hdr, "Assayer's reasoning")
assert got is not None, "R1: section missing"
# strip the attribution line, whatever form it takes, then compare the prose
prose = "\n".join(l for l in got.strip().split("\n")
                  if not l.strip().startswith("_")).strip()
assert prose == expected, (
    "R1: reasoning is not byte-identical.\n--- expected ---\n"
    f"{expected!r}\n--- got ---\n{prose!r}")

# R2: attributed - the section must name the Assayer, not leave it ambiguous.
assert re.search(r"assayer", got, re.I), f"R2: section is not attributed: {got[:200]!r}"

# R6: ## Finding is still the observation only, ending at the first fence.
finding = section(hdr, "Finding").strip()
assert finding.startswith("Only the Summary step"), f"R6: {finding[:80]!r}"
assert "Why this layer" not in finding, "R6: reasoning leaked into ## Finding"
assert "```" not in finding, "R6: a fence leaked into ## Finding"

# R7: the rule block is byte-identical, fences and indentation intact.
hb = re.findall(r"^````markdown\n(.*?)^````$", hdr, re.M | re.S)
ab = re.findall(r"^````markdown\n(.*?)^````$", body, re.M | re.S)
assert len(hb) == 1 and hb[0] == ab[0], "R7: rule block changed"
assert "```bash" in hb[0], "R7: the inner fence was eaten"
print("R1 ok (reasoning carried verbatim)")
print("R2 ok (attributed to the Assayer)")
print("R6 ok (## Finding unchanged)")
print("R7 ok (rule block still byte-identical)")
PYEOF

# === R5: overfitting_risk reaches the frontmatter ============================
grep -q '^overfitting_risk: low$' "$H" \
  || fail "R5: overfitting_risk missing from frontmatter"
echo "R5 ok (overfitting_risk carried)"

# === R4: the tier-2 placeholders are untouched, and acceptance still refuses ==
for s in "Why this layer" "Enforcement" "Validation" "Rejected alternatives"; do
  "$PY" - "$H" "$s" <<'PYEOF'
import re, sys
t, name = open(sys.argv[1]).read(), sys.argv[2]
m = re.search(rf"^## {re.escape(name)}\n\n(.*?)$", t, re.M)
assert m and m.group(1).startswith("_TODO"), f"R4: '{name}' is not a placeholder"
PYEOF
done
printf 'A cost in the approver own words.\n' > "$TMP/cost.txt"
reg accept --hdr harness/decisions/HDR-2026-08-25-reasoned.md \
  --cost-file cost.txt --approver tester --now 2026-08-25T10:00Z
[ "$RC" -ne 0 ] || fail "R4: acceptance must still refuse while placeholders stand"
printf '%s' "$OUT" | grep -qi 'placeholder' \
  || fail "R4: refusal should name the placeholders. Out: $OUT"
echo "R4 ok (placeholders intact; acceptance still refused)"

# === R3: a finding with no post-metadata prose emits no section ==============
reg propose --assay "$A" --finding finding-5 --today 2026-08-25 --slug quiet
[ "$RC" -eq 0 ] || fail "R3: propose failed for no-change finding. Out: $OUT"
Q="$TMP/harness/decisions/HDR-2026-08-25-quiet.md"
grep -q "Assayer's reasoning" "$Q" \
  && fail "R3: emitted a reasoning section for a finding that has none"
grep -q '^overfitting_risk:' "$Q" \
  && fail "R5: emitted overfitting_risk when the finding declares none"
echo "R3 ok (section omitted, not emitted empty)"
echo "R5b ok (overfitting_risk omitted when absent)"

# === R9: the corpus still validates =========================================
set +e
VOUT="$( cd "$TMP" && "$PY" "$ROOT/ai-literacy-superpowers/scripts/check-harness-decisions.py" 2>&1 )"
VRC=$?
set -e
[ "$VRC" -eq 0 ] || fail "R9: corpus does not validate. Out: $VOUT"
echo "R9 ok (corpus validates)"

echo "assayer reasoning: all checks passed (R1-R9)"
