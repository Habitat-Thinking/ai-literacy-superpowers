#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the sentinel integrity matcher
# (spec 2026-07-20-sentinel-agent-category-design.md, §5.4; AC-2, AC-3, AC-4).
#
# The matcher is a single bash script invoked two ways: a PR-time GitHub gate
# (.github/workflows/harness.yml) and this Layer-0 test, where the red/green
# fixtures live and prove its precision. One matcher, so both callers enforce
# the same rule.
#
# Contract under test (spec §5.4):
#   sentinel-integrity-check.sh <agents-dir>
#     - FAILS (exit non-zero) if any `role: sentinel` agent in the dir is
#       granted Write or Edit, naming the agent and criterion S1 (AC-3);
#     - FAILS if any agent declares a `role:` value outside the enum
#       {sentinel}, naming the agent and the value (AC-4);
#     - PASSES (exit 0) when every sentinel is read-only and untagged
#       pipeline agents — even ones with Write — are ignored (AC-2).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MATCHER="$SCRIPT_DIR/../../ai-literacy-superpowers/scripts/sentinel-integrity-check.sh"
FIX="$SCRIPT_DIR/fixtures/sentinel-integrity"

fail() { echo "FAIL: $*" >&2; exit 1; }

# Guard: the matcher must exist and be executable.
[ -f "$MATCHER" ] || fail "matcher script not found at $MATCHER"
[ -x "$MATCHER" ] || fail "matcher script exists but is not executable: $MATCHER"

# run <agents-dir> -> sets RC and OUT
run() {
  set +e
  OUT=$("$MATCHER" "$1" 2>&1)
  RC=$?
  set -e
}

# --- AC-2: green — read-only sentinel + untagged Write agent both pass --------
run "$FIX/clean"
[ "$RC" -eq 0 ] || fail "clean fixtures must PASS (a read-only sentinel and an ignored untagged agent); got exit $RC: $OUT"

# --- AC-3: red — sentinel granted Write must FAIL, naming agent + S1 ----------
run "$FIX/violation-write"
[ "$RC" -ne 0 ] || fail "a sentinel granted Write must FAIL (got exit 0): $OUT"
echo "$OUT" | grep -q "bad-sentinel" || fail "S1 violation message must name the offending agent: $OUT"
echo "$OUT" | grep -q "S1" || fail "S1 violation message must cite criterion S1: $OUT"

# --- AC-4: red — unknown role value must FAIL, naming agent + value -----------
run "$FIX/violation-role"
[ "$RC" -ne 0 ] || fail "an unknown role value must FAIL (got exit 0): $OUT"
echo "$OUT" | grep -q "typo-role" || fail "unknown-role message must name the offending agent: $OUT"
echo "$OUT" | grep -q "sentinal" || fail "unknown-role message must name the invalid value: $OUT"

echo "PASS: sentinel integrity matcher — green clean, red on Write grant, red on unknown role"
