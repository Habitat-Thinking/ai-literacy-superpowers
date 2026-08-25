#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for setting the target at the acceptance gate
# (spec 2026-08-25-target-at-the-gate-design.md; T1-T10 -> A1-A10).
#
# T1 IS THE DOCUMENTED WORKFLOW, and before this change it was impossible: the
# reference says the Assayer often cannot know which of four agent files owns a
# behaviour and that the human decides at the gate, but such a record proposed
# cleanly and could never be accepted.
#
# T8 IS THE GUARD. Every refusal here happens before anything is written, and
# "nothing was written" is measured by hashing the corpus rather than read off
# the code.

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
mkdir -p harness/decisions harness/assay .claude/agents
printf '# Harness\n\nHand-written.\n' > HARNESS.md
printf '# Agents\n\nHand-written.\n' > AGENTS.md
printf -- '---\nname: tdd\n---\n\n# TDD agent\n\nHand-written.\n' > .claude/agents/tdd.agent.md
printf '#!/usr/bin/env bash\nexit 0\n' > run.sh
printf 'Written by a human, in their own words.\n' > cost.txt

A="harness/assay/2026-08-25T08-08Z-assay.md"
reg() { set +e; OUT="$( "$PY" "$REG" "$@" 2>&1 )"; RC=$?; set -e; }
refuses() {
  [ "$RC" -ne 0 ] || fail "$1: expected non-zero exit, got 0. Out: $OUT"
  printf '%s' "$OUT" | grep -q 'Traceback' && fail "$1: crashed. Out: $OUT"
  printf '%s' "$OUT" | grep -qi -- "$2" || fail "$1: message must mention '$2'. Out: $OUT"
}
corpus_hash() {
  "$PY" -c "
import hashlib, os
h = hashlib.sha256()
for dirpath, dirs, files in os.walk('harness'):
    dirs.sort()
    for name in sorted(files):
        p = os.path.join(dirpath, name)
        h.update(p.encode()); h.update(open(p,'rb').read())
print(h.hexdigest())"
}

cat > harness/surfaces.yaml <<'EOF'
routes:
  harness-loop: HARNESS.md
  turn-instructions: AGENTS.md
surfaces:
  claude-code:
    targets: [CLAUDE.md, .claude/agents/]
    supports: [advisory, validated, blocked]
EOF

cat > "$A" <<'EOF'
---
assay: harness/assay/2026-08-25T08-08Z-assay.md
date: 2026-08-25
agent: harness-assayer
model: claude-opus-5
---

# Assay

## Findings

### finding-4 — Belongs to an agent, but the Assayer cannot say which

The behaviour belongs to an agent. Which of four agent files owns it is not
something this report can determine.

```yaml
classification: agent-instruction
enforcement: advisory
surfaces: [claude-code]
priority: P2
evidence:
  - HARNESS.md
```

#### Proposed rule

````markdown
- **Rule**: Cite observed output, never a planned command.
````

#### Cost estimate

One check per phase boundary.

### finding-6 — The Assayer did name a target, and guessed wrong

Observed once.

```yaml
classification: agent-instruction
enforcement: advisory
surfaces: [claude-code]
target: AGENTS.md
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

### finding-8 — A routed classification

Observed once.

```yaml
classification: harness-loop
enforcement: advisory
surfaces: [claude-code]
priority: P2
evidence:
  - harness/assay/2026-08-24T08-08Z-assay.md#finding-8
  - HARNESS.md
```

#### Proposed rule

````markdown
- **Rule**: A loop-layer rule.
````

#### Cost estimate

Nothing.
EOF

fill() { "$PY" - "$1" <<'PYEOF'
import re, sys
p = sys.argv[1]; t = open(p).read()
for h in ("Why this layer", "Enforcement", "Validation", "Rejected alternatives"):
    t = re.sub(rf"(## {h}\n\n)_TODO[^\n]*\n", r"\1Written by a human.\n", t)
open(p, "w").write(t)
PYEOF
}

# === T2: without --target it still refuses, message unchanged ================
reg propose --assay "$A" --finding finding-4 --today 2026-08-25 --slug notarget
[ "$RC" -eq 0 ] || fail "T2 setup: propose failed. Out: $OUT"
H=harness/decisions/HDR-2026-08-25-notarget.md
BEFORE="$(corpus_hash)"
reg accept --hdr "$H" --cost-file cost.txt --approver tester --now 2026-08-25T10:00Z
refuses "T2" "must name its own"
[ "$(corpus_hash)" = "$BEFORE" ] || fail "T2: the corpus changed during a refusal"
echo "T2 ok (no target, no flag: refuses as before)"

# === T3/T4/T5: the three refusals, none of which writes ======================
reg accept --hdr "$H" --cost-file cost.txt --approver tester --now 2026-08-25T10:00Z \
  --target run.sh
refuses "T4" "cannot hold"
reg accept --hdr "$H" --cost-file cost.txt --approver tester --now 2026-08-25T10:00Z \
  --target docs/missing.md
refuses "T5" "does not exist"
[ "$(corpus_hash)" = "$BEFORE" ] || fail "T4/T5: the corpus changed during a refusal"
echo "T4 ok (non-markdown target refused)"
echo "T5 ok (absent artifact refused)"

# === T1: the documented workflow now works ==================================
reg accept --hdr "$H" --cost-file cost.txt --approver tester --now 2026-08-25T10:00Z \
  --target .claude/agents/tdd.agent.md
[ "$RC" -eq 0 ] || fail "T1: accept with --target failed. Out: $OUT"
grep -q 'Cite observed output' .claude/agents/tdd.agent.md \
  || fail "T1: the rule was not applied to the supplied target"
grep -q '^target: .claude/agents/tdd.agent.md$' "$H" \
  || fail "T1: the record does not carry the approver's target"
echo "T1 ok (a record naming no target is acceptable at the gate)"

# === T7: nothing to preserve, so no proposed_target ==========================
grep -q '^proposed_target:' "$H" \
  && fail "T7: proposed_target written when the assay named none"
echo "T7 ok (no proposed_target when the assay named none)"

# === T6: an override preserves the Assayer's value ==========================
reg propose --assay "$A" --finding finding-6 --today 2026-08-25 --slug override
[ "$RC" -eq 0 ] || fail "T6 setup: propose failed. Out: $OUT"
H6=harness/decisions/HDR-2026-08-25-override.md
grep -q '^target: AGENTS.md$' "$H6" || fail "T6 setup: the assay's target is missing"
reg accept --hdr "$H6" --cost-file cost.txt --approver tester --now 2026-08-25T10:05Z \
  --target .claude/agents/tdd.agent.md
[ "$RC" -eq 0 ] || fail "T6: override failed. Out: $OUT"
grep -q '^proposed_target: AGENTS.md$' "$H6" \
  || fail "T6: the Assayer's target was not preserved"
grep -q '^target: .claude/agents/tdd.agent.md$' "$H6" \
  || fail "T6: the approver's target is not in 'target'"
echo "T6 ok (override preserves the Assayer's value as proposed_target)"

# === T3: a routed classification refuses --target ===========================
# The route wins in target_of, so accepting a target here would silently discard
# what the approver typed - the failure #551 was about.
mkdir -p harness/assay
cp "$A" harness/assay/2026-08-24T08-08Z-assay.md
"$PY" - harness/assay/2026-08-24T08-08Z-assay.md <<'PYEOF'
import sys
p = sys.argv[1]; t = open(p).read()
open(p, "w").write(t.replace("2026-08-25T08-08Z", "2026-08-24T08-08Z"))
PYEOF
reg propose --assay "$A" --finding finding-8 --today 2026-08-25 --slug routed
[ "$RC" -eq 0 ] || fail "T3 setup: propose failed. Out: $OUT"
fill harness/decisions/HDR-2026-08-25-routed.md
BEFORE="$(corpus_hash)"
reg accept --hdr harness/decisions/HDR-2026-08-25-routed.md --cost-file cost.txt \
  --approver tester --now 2026-08-25T10:10Z --target .claude/agents/tdd.agent.md
refuses "T3" "routed"
[ "$(corpus_hash)" = "$BEFORE" ] || fail "T3: the corpus changed during a refusal"
echo "T3 ok (a routed classification refuses --target)"

# === T9: accepting without --target is otherwise unaffected =================
reg accept --hdr harness/decisions/HDR-2026-08-25-routed.md --cost-file cost.txt \
  --approver tester --now 2026-08-25T10:15Z
[ "$RC" -eq 0 ] || fail "T9: a routed record must accept normally. Out: $OUT"
grep -q 'A loop-layer rule' HARNESS.md || fail "T9: the routed rule was not applied"
echo "T9 ok (unchanged without --target)"

echo "target at the gate: all checks passed (T1-T9)"
