#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for harness write-path integrity
# (spec 2026-08-25-harness-write-path-integrity-design.md; W1-W8 -> A1-A8).
#
# THIS SUITE EXISTS BECAUSE PHASE 2 NEVER HAD IT. The two fixed routes are both
# markdown, so nothing in the original acceptance criteria ever pointed a record
# at another file type. On 2026-08-25 a script-validator record targeting
# .github/workflows/gc.yml was accepted, the compiler appended a markdown region
# to a YAML file, the workflow stopped parsing, and /harness-check reported OK.
#
# W1 and W5 are the two that matter. W1 asserts the refusal fires BEFORE
# anything is written; W5 asserts the check can see a bad target at all, which
# is the thing that was silent.
#
# THE CLOCK IS INJECTED, NOT READ. --today and --now exist so this suite cannot
# fail because it ran at the wrong hour.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
REG="$ROOT/ai-literacy-superpowers/scripts/harness-registrar.py"

fail() { echo "FAIL: $*" >&2; exit 1; }
[ -f "$REG" ] || fail "harness registrar not found at $REG"

PY=/usr/bin/python3
command -v "$PY" >/dev/null 2>&1 || PY=python3

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
HARNESS="$TMP/harness"
DEC="$HARNESS/decisions"
ASSAY="$HARNESS/assay"
mkdir -p "$DEC" "$ASSAY" "$TMP/.github/workflows"

A1F="harness/assay/2026-08-25T08-08Z-assay.md"

reg() {
  set +e
  OUT="$( cd "$TMP" && "$PY" "$REG" "$@" 2>&1 )"
  RC=$?
  set -e
}

refuses() {
  [ "$RC" -ne 0 ] || fail "$1: expected non-zero exit, got 0. Out: $OUT"
  printf '%s' "$OUT" | grep -q 'Traceback' \
    && fail "$1: crashed instead of refusing. Out: $OUT"
  printf '%s' "$OUT" | grep -qi -- "$2" \
    || fail "$1: message must mention '$2'. Out: $OUT"
}

corpus_hash() {
  ( cd "$TMP" && "$PY" -c "
import hashlib, os
h = hashlib.sha256()
for dirpath, dirs, files in os.walk('harness'):
    dirs.sort()
    for name in sorted(files):
        p = os.path.join(dirpath, name)
        h.update(p.encode())
        h.update(open(p,'rb').read())
print(h.hexdigest())
" )
}

# --- artifacts ---------------------------------------------------------------
printf '# Harness\n\nHand-written.\n' > "$TMP/HARNESS.md"
printf '# Agents\n\nHand-written.\n' > "$TMP/AGENTS.md"

# A real workflow, valid YAML. If the write path ever touches it, it stops
# being valid, which is the whole point of W8.
cat > "$TMP/.github/workflows/gc.yml" <<'EOF'
name: Garbage Collection
on:
  schedule:
    - cron: "0 9 * * 1"
jobs:
  gc:
    runs-on: ubuntu-latest
    steps:
      - name: Summary
        if: always()
        run: echo "done"
EOF
WF_BEFORE="$( "$PY" -c "import hashlib,sys;print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())" "$TMP/.github/workflows/gc.yml" )"

cat > "$HARNESS/surfaces.yaml" <<'EOF'
routes:
  harness-loop: HARNESS.md
  turn-instructions: AGENTS.md
  script-validator: HARNESS.md

surfaces:
  claude-code:
    targets: [CLAUDE.md, .claude/agents/]
    supports: [advisory, validated, blocked]
  ci:
    targets: [.github/workflows/]
    supports: [validated, blocked]
EOF

# --- the assay ---------------------------------------------------------------
# finding-2 reproduces the real one: a script-validator whose target is a
# workflow file. finding-9 is the same finding with no target at all, which
# under the new route must land in HARNESS.md.
cat > "$TMP/$A1F" <<'EOF'
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
target: .github/workflows/gc.yml
priority: P1
evidence:
  - .github/workflows/gc.yml
overfitting_risk: low
```

#### Proposed rule

````markdown
- **Rule**: A periodic check suite must produce a result for every rule it
  declares, in every run.
- **Enforcement**: deterministic
- **Tool**: `.github/workflows/gc.yml` (weekly schedule)
- **Scope**: pr
````

#### Cost estimate

Thirty minutes once; the weekly run looks worse before it looks better.

### finding-9 — The same rule, routed rather than targeted

Identical observation, with no target named, so the classification route decides.

```yaml
classification: script-validator
enforcement: validated
surfaces: [ci]
priority: P1
evidence:
  - .github/workflows/gc.yml
overfitting_risk: low
```

#### Proposed rule

````markdown
- **Rule**: A periodic check suite must produce a result for every rule it
  declares, in every run.
- **Enforcement**: deterministic
- **Tool**: `.github/workflows/gc.yml` (weekly schedule)
- **Scope**: pr
````

#### Cost estimate

Thirty minutes once; the weekly run looks worse before it looks better.
EOF

printf 'Written by a human, in their own words, and not the proposal.\n' > "$TMP/cost.txt"

# === W1 (A1): a non-markdown target is refused, and nothing is written =======
reg propose --assay "$A1F" --finding finding-2 --today 2026-08-25
[ "$RC" -eq 0 ] || fail "W1 setup: propose failed. Out: $OUT"
HDR2="$( cd "$TMP" && ls harness/decisions/HDR-*.md | head -1 )"

# Fill the tier-2 sections, so the refusal under test is the target refusal and
# not the placeholder one. A test that passes on the wrong refusal proves
# nothing about the thing it names.
fill_tier2() {
  "$PY" - "$1" <<'PYEOF'
import re, sys
p = sys.argv[1]; t = open(p).read()
for h in ("Why this layer", "Enforcement", "Validation", "Rejected alternatives"):
    t = re.sub(rf"(## {h}\n\n)_TODO[^\n]*\n", rf"\1Written by a human.\n", t)
open(p, "w").write(t)
PYEOF
}
fill_tier2 "$TMP/$HDR2"

BEFORE="$(corpus_hash)"
reg accept --hdr "$HDR2" --cost-file cost.txt \
  --approver "tester" --now 2026-08-25T10:00Z
refuses "W1" "cannot hold"
AFTER="$(corpus_hash)"
[ "$BEFORE" = "$AFTER" ] || fail "W1: corpus changed during a refused acceptance"
grep -q '^status: proposed' "$TMP/$HDR2" || fail "W1: record must stay proposed"
echo "W1 ok (non-markdown target refused at accept; nothing written)"

# === W2 (A2): the refusal names the target and points at the Tool field ======
printf '%s' "$OUT" | grep -q '\.github/workflows/gc\.yml' \
  || fail "W2: refusal must name the offending target. Out: $OUT"
printf '%s' "$OUT" | grep -qi 'tool' \
  || fail "W2: refusal must direct the author to the Tool field. Out: $OUT"
echo "W2 ok (refusal names the target and the remedy)"

# === W8 (A8): the workflow file is untouched =================================
WF_AFTER="$( "$PY" -c "import hashlib,sys;print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())" "$TMP/.github/workflows/gc.yml" )"
[ "$WF_BEFORE" = "$WF_AFTER" ] || fail "W8: the workflow file was modified"
grep -q 'BEGIN GENERATED' "$TMP/.github/workflows/gc.yml" \
  && fail "W8: a generated region was written into a YAML workflow"
echo "W8 ok (gc.yml untouched and free of generated markers)"

# === W3 (A3): script-validator with no target routes to HARNESS.md ===========
reg propose --assay "$A1F" --finding finding-9 --today 2026-08-25 --slug routed
[ "$RC" -eq 0 ] || fail "W3 setup: propose failed. Out: $OUT"
HDR9="harness/decisions/HDR-2026-08-25-routed.md"
fill_tier2 "$TMP/$HDR9"
reg accept --hdr "$HDR9" --cost-file cost.txt \
  --approver "tester" --now 2026-08-25T10:05Z
[ "$RC" -eq 0 ] || fail "W3: routed script-validator must be accepted. Out: $OUT"
grep -q 'BEGIN GENERATED' "$TMP/HARNESS.md" \
  || fail "W3: the rule was not applied to HARNESS.md"
grep -q 'periodic check suite must produce a result' "$TMP/HARNESS.md" \
  || fail "W3: rule text missing from HARNESS.md"
echo "W3 ok (script-validator routes to HARNESS.md and applies)"

# === W4 (A4): compile refuses the same case rather than writing ==============
# Hand-accept it, attribution included. A record flipped to accepted without
# approver/cost fails the validator for an unrelated reason, and a test that
# fails for the wrong reason proves nothing.
"$PY" - "$TMP/$HDR2" <<'PYEOF'
import re, sys
p = sys.argv[1]; t = open(p).read()
t = t.replace("status: proposed", "status: accepted", 1)
t = t.replace('cost: ""',
              'cost: |\n  Written by a human, in their own words.', 1)
t = re.sub(r"^supersedes:", "approver: tester\napproved_at: 2026-08-25T10:00Z\nsupersedes:",
           t, count=1, flags=re.M)
t = re.sub(r"(## Cost\n\n)_TODO[^\n]*\n", r"\1Written by a human, in their own words.\n", t)
open(p, "w").write(t)
PYEOF
BEFORE="$(corpus_hash)"
reg compile
refuses "W4" "cannot hold"
WF_AFTER="$( "$PY" -c "import hashlib,sys;print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())" "$TMP/.github/workflows/gc.yml" )"
[ "$WF_BEFORE" = "$WF_AFTER" ] || fail "W4: compile modified the workflow file"
echo "W4 ok (compile refuses a non-markdown target)"

# === W5 (A5): check exits non-zero on a compilable bad target ================
reg check
[ "$RC" -ne 0 ] || fail "W5: check must fail on a non-markdown target. Out: $OUT"
printf '%s' "$OUT" | grep -q '\.github/workflows/gc\.yml' \
  || fail "W5: check must name the offending target. Out: $OUT"
echo "W5 ok (check sees the bad target)"

# === W6 (A6): a superseded record with a bad target does NOT fail check ======
# The existing corpus carries exactly this shape. Retiring is how the real one
# was resolved, and the fix must not fail the corpus it was written for.
cat > "$TMP/harness/decisions/HDR-2026-08-25-retire.md" <<EOF
---
id: HDR-2026-08-25-retire
title: Retire the periodic check suite rule
status: accepted
classification: script-validator
enforcement: validated
surfaces: [ci]
provisional: false
evidence:
  - $A1F#finding-2
proposed_cost: |
  None.
cost: |
  Withdrawing where the rule was pointed, not the rule itself.
proposer:
  agent: human
  model: n/a
  assay: $A1F
approver: tester
approved_at: 2026-08-25T10:10Z
supersedes: $(basename "$HDR2" .md)
superseded_by: null
---

## Finding

The rule was applied to a YAML workflow and left it unparseable.

## Rule

Withdrawn.

## Cost

Withdrawing where the rule was pointed, not the rule itself.

## Why this layer

Same layer as the rule it withdraws.

## Enforcement

None. A retirement compiles nothing.

## Validation

The workflow parses and carries no generated region.

## Rejected alternatives

No change: the next compile would re-break the workflow.
EOF
# The retirement makes HDR2 superseded, so it drops out of the compile plan and
# the index must be regenerated to match.
reg compile
[ "$RC" -eq 0 ] || fail "W6: compile must succeed once the bad target is superseded. Out: $OUT"
reg check
[ "$RC" -eq 0 ] || fail "W6: a superseded bad target must not fail check. Out: $OUT"
echo "W6 ok (superseded records are exempt; existing corpus survives)"

# === W7 (A7): the allowlist is an allowlist, not a denylist =================
# A type nobody thought of must refuse too. `.yml` was the one nobody thought of.
# Mutates HDR9, which is accepted and still IN FORCE - HDR2 is superseded by now
# and correctly exempt, so it would prove nothing.
for ext in json sh py toml; do
  "$PY" - "$TMP/$HDR9" "$ext" <<'PYEOF'
import re, sys
p, ext = sys.argv[1], sys.argv[2]
t = open(p).read()
line = f"target: some/file.{ext}"
if re.search(r"^target: .*$", t, flags=re.M):
    t = re.sub(r"^target: .*$", line, t, count=1, flags=re.M)
else:
    t = re.sub(r"^supersedes:", line + "\nsupersedes:", t, count=1, flags=re.M)
open(p, "w").write(t)
PYEOF
  reg check
  [ "$RC" -ne 0 ] || fail "W7: check must refuse a .$ext target. Out: $OUT"
  printf '%s' "$OUT" | grep -q "some/file.$ext" \
    || fail "W7: check must name the .$ext target. Out: $OUT"
done
echo "W7 ok (allowlist refuses json, sh, py, toml)"

echo "harness write path: all checks passed (W1-W8)"
