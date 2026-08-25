#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for routing table merge semantics
# (spec 2026-08-25-routes-merge-design.md; M1-M9 -> A1-A9).
#
# M5/M6 ARE WHY THIS IS NOT A ONE-LINE FIX. `target_of` prefers the route over
# any target a record names, so a merged-back default that points at a file the
# project does not have would leave records of that classification unacceptable
# AND unredirectable. Suppression is what keeps that case reachable.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
VAL="$ROOT/ai-literacy-superpowers/scripts/check-harness-decisions.py"
REG="$ROOT/ai-literacy-superpowers/scripts/harness-registrar.py"

fail() { echo "FAIL: $*" >&2; exit 1; }
[ -f "$VAL" ] || fail "validator not found at $VAL"

PY=/usr/bin/python3
command -v "$PY" >/dev/null 2>&1 || PY=python3

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"
mkdir -p harness/decisions harness/assay
printf '# Harness\n\nHand-written.\n' > HARNESS.md
export VAL

routes() {  # routes -> "k=v,k=v" sorted
  "$PY" - <<'PYEOF'
import importlib.util, os
spec = importlib.util.spec_from_file_location("val", os.environ["VAL"])
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
r = m.effective_routes(".")
print(",".join(f"{k}={v}" for k, v in sorted(r.items())))
PYEOF
}

DEFAULTS="harness-loop=HARNESS.md,script-validator=HARNESS.md,turn-instructions=AGENTS.md"

# === M1: no surfaces.yaml at all ============================================
[ "$(routes)" = "$DEFAULTS" ] || fail "M1: expected defaults, got $(routes)"
echo "M1 ok (no surfaces.yaml -> defaults)"

# === M2: a surfaces.yaml with no routes block ===============================
cat > harness/surfaces.yaml <<'EOF'
surfaces:
  ci:
    targets: [.github/workflows/]
    supports: [validated, blocked]
EOF
[ "$(routes)" = "$DEFAULTS" ] || fail "M2: expected defaults, got $(routes)"
echo "M2 ok (no routes block -> defaults)"

# === M3: a partial block keeps the defaults it does not mention =============
# This is the trap: declaring one route silently dropped every default,
# including harness-loop, and the failure surfaced only at acceptance.
cat > harness/surfaces.yaml <<'EOF'
routes:
  agent-instruction: .claude/agents/example.agent.md
surfaces:
  ci:
    targets: [.github/workflows/]
    supports: [validated, blocked]
EOF
GOT="$(routes)"
printf '%s' "$GOT" | grep -q 'harness-loop=HARNESS.md' \
  || fail "M3: harness-loop default was dropped. Got $GOT"
printf '%s' "$GOT" | grep -q 'turn-instructions=AGENTS.md' \
  || fail "M3: turn-instructions default was dropped. Got $GOT"
printf '%s' "$GOT" | grep -q 'agent-instruction=.claude/agents/example.agent.md' \
  || fail "M3: the project's own route is missing. Got $GOT"
echo "M3 ok (partial block merges with defaults)"

# === M4: a project entry overrides a default of the same name ===============
cat > harness/surfaces.yaml <<'EOF'
routes:
  harness-loop: GOVERNANCE.md
surfaces:
  ci:
    targets: [.github/workflows/]
    supports: [validated, blocked]
EOF
printf '%s' "$(routes)" | grep -q 'harness-loop=GOVERNANCE.md' \
  || fail "M4: the project override did not win. Got $(routes)"
echo "M4 ok (project entry overrides the default)"

# === M5: an empty value suppresses a default ================================
cat > harness/surfaces.yaml <<'EOF'
routes:
  turn-instructions:
  script-validator: HARNESS.md
surfaces:
  ci:
    targets: [.github/workflows/]
    supports: [validated, blocked]
EOF
GOT="$(routes)"
printf '%s' "$GOT" | grep -q 'turn-instructions=' \
  && fail "M5: the suppressed default is still present. Got $GOT"
printf '%s' "$GOT" | grep -q 'harness-loop=HARNESS.md' \
  || fail "M5: suppression must not drop the other defaults. Got $GOT"
echo "M5 ok (empty value suppresses, others survive)"

# === M6: a suppressed classification behaves as unrouted ====================
# The record must name its own target, and one that does must be accepted.
# Without this, a project with no AGENTS.md could never accept a
# turn-instructions record: the route wins over any target it names.
cat > harness/assay/2026-08-25T08-08Z-assay.md <<'EOF'
---
assay: harness/assay/2026-08-25T08-08Z-assay.md
date: 2026-08-25
agent: harness-assayer
model: claude-opus-5
---

# Assay

## Findings

### finding-1 — A turn-level instruction

Observed once.

```yaml
classification: turn-instructions
enforcement: advisory
surfaces: [ci]
target: HARNESS.md
priority: P2
evidence:
  - HARNESS.md
```

#### Proposed rule

````markdown
- **Rule**: Something about the turn.
````

#### Cost estimate

Nothing.
EOF
set +e
OUT="$( "$PY" "$REG" propose --assay harness/assay/2026-08-25T08-08Z-assay.md \
  --finding finding-1 --today 2026-08-25 --slug routed 2>&1 )"
RC=$?
set -e
[ "$RC" -eq 0 ] || fail "M6: propose failed. Out: $OUT"
printf 'Written by a human.\n' > cost.txt
set +e
OUT="$( "$PY" "$REG" accept --hdr harness/decisions/HDR-2026-08-25-routed.md \
  --cost-file cost.txt --approver tester --now 2026-08-25T10:00Z 2>&1 )"
RC=$?
set -e
[ "$RC" -eq 0 ] || fail "M6: a suppressed classification must honour its own target. Out: $OUT"
grep -q 'Something about the turn' HARNESS.md \
  || fail "M6: the rule was not applied to the named target"
[ -f AGENTS.md ] && fail "M6: the suppressed route was used anyway"
echo "M6 ok (suppressed classification honours its own target)"

# === M7: the docstring matches the behaviour ================================
"$PY" - <<'PYEOF'
import importlib.util, os
spec = importlib.util.spec_from_file_location("val", os.environ["VAL"])
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
doc = (m.effective_routes.__doc__ or "")
assert "defaults" in doc.lower(), "M7: the docstring should still describe defaults"
PYEOF
echo "M7 ok (docstring describes what happens)"

echo "routes merge: all checks passed (M1-M7)"
