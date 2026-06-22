#!/usr/bin/env bash
set -euo pipefail
# Layer 0 deterministic check for the four dynamic-workflows S2 templates and
# the SKILL.md flip (spec AC-1, AC-2, AC-3, AC-4, AC-12).
#
# Asserts the *shipped* state of the template library:
#   - the four templates exist at skills/dynamic-workflows/workflows/;
#   - each parses as valid JavaScript (node --check);
#   - each preamble names its pattern, token budget + per-role model tier, the
#     INV-1 boundary, and the Claude-Code-only runtime scope;
#   - SKILL.md references all four by relative path and every path resolves;
#   - SKILL.md is "shipped" framing, not "forthcoming (S2)".
#
# RED NOW: the templates do not exist and SKILL.md still says "forthcoming
# (S2)". Each assertion below fails for the right reason (missing
# implementation), not because the test is malformed.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$SCRIPT_DIR/../../ai-literacy-superpowers/skills/dynamic-workflows"
WF_DIR="$SKILL_DIR/workflows"
SKILL_MD="$SKILL_DIR/SKILL.md"

fail() { echo "FAIL: $*" >&2; exit 1; }

command -v node >/dev/null 2>&1 || fail "node not found on PATH — the parse check (AC-2) requires Node --check"

TEMPLATES=(
  enforcer-fanout
  adversarial-review
  reflection-mining
  deep-assessment
)

# --- AC-1: the four templates exist ------------------------------------------
[ -d "$WF_DIR" ] || fail "workflows/ directory does not exist at $WF_DIR (S2 templates missing — expected RED)"
for t in "${TEMPLATES[@]}"; do
  f="$WF_DIR/$t.workflow.js"
  [ -f "$f" ] || fail "template missing: $f (AC-1)"
done

# --- AC-2: each template parses as valid JavaScript --------------------------
for t in "${TEMPLATES[@]}"; do
  f="$WF_DIR/$t.workflow.js"
  node --check "$f" 2>/dev/null || fail "template does not parse as valid JavaScript: $f (AC-2)"
done

# --- AC-1 + AC-4 + AC-12: each preamble is literate --------------------------
# Extract the top-of-file comment block (the literate preamble) and assert it
# names: a pattern, a token budget, a per-role model tier, the INV-1 boundary,
# and the Claude-Code-only runtime scope.
for t in "${TEMPLATES[@]}"; do
  f="$WF_DIR/$t.workflow.js"
  # The preamble is the leading /** ... */ block; grep the whole file head.
  head_block=$(sed -n '1,60p' "$f")
  echo "$head_block" | grep -qiE "pattern" || fail "$t preamble must name its pattern (AC-1): $f"
  echo "$head_block" | grep -qiE "token budget" || fail "$t preamble must declare a token budget (AC-4): $f"
  echo "$head_block" | grep -qiE "model tier|tier per role|per-role" || fail "$t preamble must declare a per-role model tier (AC-4): $f"
  echo "$head_block" | grep -qiE "INV-1" || fail "$t preamble must name the INV-1 boundary it respects (AC-1): $f"
  echo "$head_block" | grep -qiE "Claude.Code" || fail "$t preamble must state the Claude-Code-only runtime scope (AC-12): $f"
done

# --- AC-3: SKILL.md references all four by resolving relative path ------------
[ -f "$SKILL_MD" ] || fail "SKILL.md not found at $SKILL_MD"

# Must NOT still be in the "forthcoming (S2)" framing.
if grep -qi "forthcoming" "$SKILL_MD"; then
  fail "SKILL.md still uses 'forthcoming' framing — S2 must flip it to 'shipped' (AC-3)"
fi

for t in "${TEMPLATES[@]}"; do
  ref="workflows/$t.workflow.js"
  grep -q "$ref" "$SKILL_MD" || fail "SKILL.md does not reference $ref by relative path (AC-3)"
  # The reference must resolve to an existing file.
  [ -f "$SKILL_DIR/$ref" ] || fail "SKILL.md reference $ref does not resolve to an existing file (AC-3)"
done

echo "All dynamic-workflows template structural tests passed."
