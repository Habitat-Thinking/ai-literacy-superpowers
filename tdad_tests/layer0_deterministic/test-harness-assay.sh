#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the assay linter and the forward-test fixture
# (spec 2026-08-23-harness-evolution-s3-assayer-design.md, §9; A5-A8).
#
# WHAT THIS CAN AND CANNOT SHOW. The Assayer's output is a judgement, and no
# deterministic test can establish that a judgement is good. What a
# deterministic test CAN establish is that the contract between the Assayer and
# the Registrar holds: a conforming assay lints clean and every one of its
# findings produces a valid decision record. That is what this file asserts, and
# the spec is explicit that it is not evidence the Assayer works. §10's forward
# test, with its negative case, is that evidence.
#
# A6 IS WHY THE LINTER IS EAGER. /harness-propose parses ONE finding at a time,
# so a single malformed block costs one finding rather than the whole report.
# At write time the question is different - is this DOCUMENT well-formed - and a
# linter that stopped at the first defect would send an author round the loop
# once per mistake against an append-only record they may not edit afterwards.
#
# The fixture is exercised here rather than merely stored, so a fixture that
# drifts out of contract fails on the PR that drifts it.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
REG="$ROOT/ai-literacy-superpowers/scripts/harness-registrar.py"
SEED="$SCRIPT_DIR/fixtures/assay_seed"

fail() { echo "FAIL: $*" >&2; exit 1; }
[ -f "$REG" ] || fail "harness registrar not found at $REG"
[ -d "$SEED" ] || fail "assay fixture not found at $SEED"

PY=/usr/bin/python3
command -v "$PY" >/dev/null 2>&1 || PY=python3

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
HARNESS="$TMP/harness"
mkdir -p "$HARNESS/assay" "$HARNESS/decisions"
cp "$SEED/repo/harness/surfaces.yaml" "$HARNESS/surfaces.yaml"
cp "$SEED/repo/HARNESS.md" "$TMP/HARNESS.md"
cp "$SEED/repo/AGENTS.md" "$TMP/AGENTS.md"
mkdir -p "$TMP/.claude/agents"
cp "$SEED/repo/.claude/agents/builder.agent.md" "$TMP/.claude/agents/builder.agent.md"

A="harness/assay/2026-08-21T16-02Z-assay.md"
cp "$SEED/expected-assay.md" "$TMP/$A"

reg() { set +e; OUT="$( cd "$TMP" && "$PY" "$REG" "$@" 2>&1 )"; RC=$?; set -e; }

expect_ok()   { [ "$RC" -eq 0 ] || fail "$1: expected exit 0, got $RC. Out: $OUT"; }
expect_fail() {
  [ "$RC" -ne 0 ] || fail "$1: expected non-zero exit, got 0. Out: $OUT"
  printf '%s' "$OUT" | grep -q 'Traceback' \
    && fail "$1: crashed instead of refusing. Out: $OUT"
  printf '%s' "$OUT" | grep -qi -- "$2" \
    || fail "$1: message must mention '$2'. Out: $OUT"
}

# === A5: a conforming assay lints clean ======================================
reg lint-assay --assay "$A"
expect_ok "A5 (the fixture assay conforms)"

# === A8: every finding round-trips into a valid decision record ==============
# The contract is only real if both ends agree. A fixture that lints but cannot
# be proposed from would satisfy the linter and nothing else.
FINDINGS="$("$PY" - "$TMP/$A" <<'PYEOF'
import re, sys
text = open(sys.argv[1]).read()
section = re.search(r"\n## Findings\n(.*?)(?=\n## |\Z)", text, re.S).group(1)
for m in re.finditer(r"^### ([a-z0-9-]+)\s*[—–-]", section, re.M):
    print(m.group(1))
PYEOF
)"
[ -n "$FINDINGS" ] || fail "A8: the fixture assay declares no findings"
for fid in $FINDINGS; do
  reg propose --assay "$A" --finding "$fid" --today 2026-08-21
  expect_ok "A8 (propose $fid)"
done
set +e
VOUT="$( cd "$TMP" && "$PY" "$ROOT/ai-literacy-superpowers/scripts/check-harness-decisions.py" 2>&1 )"
VRC=$?
set -e
[ "$VRC" -eq 0 ] || fail "A8: records proposed from the fixture do not validate. Out: $VOUT"
rm -f "$HARNESS/decisions"/HDR-*.md

# === A6: EVERY malformed finding is reported in one pass =====================
BAD="harness/assay/2026-08-22T09-00Z-assay.md"
cat > "$TMP/$BAD" <<'EOF'
---
assay: harness/assay/2026-08-22T09-00Z-assay.md
date: 2026-08-22
agent: harness-assayer
model: claude-opus-5
---

# Assay

## Findings

### finding-1 — No observation at all

```yaml
classification: turn-instructions
enforcement: advisory
surfaces: [claude-code]
priority: P2
evidence:
  - harness/build-log.md#a
```

#### Proposed rule

````markdown
- **Rule**: One.
````

#### Cost estimate

A cost.

### finding-2 — Missing a metadata key

Something was observed.

```yaml
classification: turn-instructions
enforcement: advisory
surfaces: [claude-code]
evidence:
  - harness/build-log.md#b
```

#### Proposed rule

````markdown
- **Rule**: Two.
````

#### Cost estimate

A cost.

### finding-3 — Two rule blocks

Something else was observed.

```yaml
classification: turn-instructions
enforcement: advisory
surfaces: [claude-code]
priority: P2
evidence:
  - harness/build-log.md#c
```

#### Proposed rule

````markdown
- **Rule**: Three.
````

````markdown
- **Rule**: Also three.
````

#### Cost estimate

A cost.

### finding-4 — Empty cost estimate

A fourth observation.

```yaml
classification: turn-instructions
enforcement: advisory
surfaces: [claude-code]
priority: P2
evidence:
  - harness/build-log.md#d
```

#### Proposed rule

````markdown
- **Rule**: Four.
````

#### Cost estimate

### finding-5 — Perfectly fine

A fifth observation, and this one is well-formed.

```yaml
classification: turn-instructions
enforcement: advisory
surfaces: [claude-code]
priority: P3
evidence:
  - harness/build-log.md#e
```

#### Proposed rule

````markdown
- **Rule**: Five.
````

#### Cost estimate

A cost.
EOF
reg lint-assay --assay "$BAD"
[ "$RC" -ne 0 ] || fail "A6: a malformed assay must not lint clean. Out: $OUT"

# All four defects, in one pass. A linter that stopped at the first would send
# the author round the loop once per mistake.
for fid in finding-1 finding-2 finding-3 finding-4; do
  printf '%s' "$OUT" | grep -q "$fid" \
    || fail "A6: '$fid' is not reported. Only the first defect was found. Out: $OUT"
done
printf '%s' "$OUT" | grep -q 'finding-5' \
  && fail "A6: the well-formed finding was reported as a defect. Out: $OUT"

# === A7: each defect is named specifically ===================================
"$PY" - <<'PYEOF' "$OUT"
import re, sys
out = sys.argv[1]
want = {
    "finding-1": r"observ",          # missing observation prose
    "finding-2": r"priority",        # missing metadata key, named
    "finding-3": r"four-backtick|exactly one",
    "finding-4": r"[Cc]ost estimate",
}
for fid, pattern in want.items():
    line = next((ln for ln in out.splitlines() if fid in ln), "")
    assert re.search(pattern, line), (
        f"A7: the message for {fid} does not name the defect "
        f"(wanted /{pattern}/): {line!r}")
PYEOF
echo "A7 ok (each defect named specifically)"

# === Document-level defects ==================================================
NOFM="harness/assay/2026-08-23T09-00Z-assay.md"
printf '# Assay\n\n## Findings\n\n### finding-1 — x\n\nobs\n' > "$TMP/$NOFM"
reg lint-assay --assay "$NOFM"
expect_fail "A7 (no frontmatter)" "frontmatter"

NOMODEL="harness/assay/2026-08-23T10-00Z-assay.md"
printf -- '---\nassay: x\ndate: 2026-08-23\nagent: harness-assayer\n---\n\n## Findings\n' \
  > "$TMP/$NOMODEL"
reg lint-assay --assay "$NOMODEL"
expect_fail "A7 (frontmatter missing model)" "model"

NOSECT="harness/assay/2026-08-23T11-00Z-assay.md"
printf -- '---\nassay: x\ndate: 2026-08-23\nagent: harness-assayer\nmodel: m\n---\n\n# Assay\n' \
  > "$TMP/$NOSECT"
reg lint-assay --assay "$NOSECT"
expect_fail "A7 (no Findings section)" "Findings"

# An assay with a Findings section and no findings in it. `no-change` is a live
# option precisely so this is never the honest way to say nothing changed:
# recording that nothing needed to change is itself evidence, and an empty
# section records nothing at all.
EMPTY="harness/assay/2026-08-23T12-00Z-assay.md"
printf -- '---\nassay: x\ndate: 2026-08-23\nagent: harness-assayer\nmodel: m\n---\n\n## Findings\n\nNothing.\n' \
  > "$TMP/$EMPTY"
reg lint-assay --assay "$EMPTY"
expect_fail "A7 (Findings section with no findings)" "no findings"

# === A no-change finding is first-class ======================================
NC="harness/assay/2026-08-23T13-00Z-assay.md"
cat > "$TMP/$NC" <<'EOF'
---
assay: harness/assay/2026-08-23T13-00Z-assay.md
date: 2026-08-23
agent: harness-assayer
model: claude-opus-5
---

## Findings

### finding-1 — Nothing needed to change

The friction observed this phase came from one unusually exploratory session,
not from a missing rule.

```yaml
classification: no-change
enforcement: advisory
surfaces: []
priority: P3
evidence:
  - harness/build-log.md#2026-08-18T10:02Z
```

#### Proposed rule

No change.

#### Cost estimate

None. Recording that nothing needed to change is itself evidence.
EOF
reg lint-assay --assay "$NC"
expect_ok "A7 (a no-change assay is a successful assay)"
reg propose --assay "$NC" --finding finding-1 --today 2026-08-23
expect_ok "A7 (a no-change finding proposes)"

echo "harness assay linter: all checks passed (A5-A8)"
