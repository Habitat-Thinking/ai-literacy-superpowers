#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the INV-1/INV-2 firewall matcher (dynamic-workflows S2).
#
# The matcher is a single bash script (spec §7.2, decision W1+W2) invoked two
# ways: a PR-time GitHub workflow (the blocking gate) and this Layer-0 test
# (where the red/green fixtures live and prove the matcher's precision). This
# test exercises the matcher against four malformed-by-design fixtures under
# fixtures/inv-firewall/ (lint-ignored).
#
# Contract under test (spec §7.1 Option C / §7.3 Option I1):
#   inv-firewall.sh --check=inv1 <file...>
#     - strips comment/preamble lines first;
#     - FAILS (exit non-zero) if any of the four durable filenames
#       (HARNESS.md, AGENTS.md, CLAUDE.md, MODEL_ROUTING.md) appears in
#       executable (non-comment) code — whether or not the specific write
#       call is recognised (drift-robust "no durable filename in executable
#       code" clause);
#     - PASSES (exit 0) when durable filenames appear only in the literate
#       preamble / comments.
#   inv-firewall.sh --check=inv2 <file...>
#     - finds every agent block marked `@untrusted-reader: true`;
#     - FAILS if that agent's `@tools` list contains any high-privilege tool
#       (write, edit, bash, commit, push);
#     - PASSES vacuously when no untrusted reader is declared.
#
# RED NOW: the matcher script does not yet exist (it is S2 implementation).
# This test therefore fails at the "matcher script exists" guard — the right
# RED reason (missing implementation, not a malformed test).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MATCHER="$SCRIPT_DIR/../../ai-literacy-superpowers/scripts/inv-firewall.sh"
FIX="$SCRIPT_DIR/fixtures/inv-firewall"

fail() { echo "FAIL: $*" >&2; exit 1; }

# Guard: the matcher must exist and be executable. RED here until S2 ships it.
[ -f "$MATCHER" ] || fail "matcher script not found at $MATCHER (S2 implementation missing — expected RED until the firewall ships)"
[ -x "$MATCHER" ] || fail "matcher script exists but is not executable: $MATCHER"

# run <check> <file> -> sets RC and OUT
run() {
  set +e
  OUT=$("$MATCHER" "--check=$1" "$2" 2>&1)
  RC=$?
  set -e
}

# --- INV-1: true positive (AC-7) ---------------------------------------------
# A template that writes a durable artefact directly in executable code must
# FLAG (exit non-zero) and name the offending file, the durable artefact, and
# the INV-1 rule.
run inv1 "$FIX/inv1-violation.workflow.js"
[ "$RC" -ne 0 ] || fail "INV-1 must FLAG a direct write to AGENTS.md in executable code (got exit 0): $OUT"
echo "$OUT" | grep -q "inv1-violation.workflow.js" || fail "INV-1 violation message must name the offending file: $OUT"
echo "$OUT" | grep -q "AGENTS.md" || fail "INV-1 violation message must name the durable artefact: $OUT"
echo "$OUT" | grep -qi "INV-1" || fail "INV-1 violation message must cite the INV-1 rule: $OUT"

# --- INV-1: no false positive (AC-8 / AC-9) ----------------------------------
# A template whose literate PREAMBLE names AGENTS.md / HARNESS.md but whose
# executable code writes only to a non-durable staging sink must PASS.
run inv1 "$FIX/inv1-clean.workflow.js"
[ "$RC" -eq 0 ] || fail "INV-1 must PASS a template that only mentions durable artefacts in its preamble (false positive; got exit $RC): $OUT"

# --- INV-2: true positive (AC-10) --------------------------------------------
# An @untrusted-reader agent granted a high-privilege tool must FLAG.
run inv2 "$FIX/inv2-violation.workflow.js"
[ "$RC" -ne 0 ] || fail "INV-2 must FLAG an untrusted-reader granted a high-privilege tool (got exit 0): $OUT"
echo "$OUT" | grep -q "inv2-violation.workflow.js" || fail "INV-2 violation message must name the offending file: $OUT"
echo "$OUT" | grep -qi "bash" || fail "INV-2 violation message must name the offending high-privilege tool: $OUT"

# --- INV-2: clean (AC-10/AC-11) ----------------------------------------------
# An @untrusted-reader agent with only low-privilege tools (and a separate
# trusted actor that reads no untrusted content) must PASS.
run inv2 "$FIX/inv2-clean.workflow.js"
[ "$RC" -eq 0 ] || fail "INV-2 must PASS when the untrusted reader is withheld every high-privilege tool (got exit $RC): $OUT"

# --- Regression guards (S2 adversarial review) -------------------------------
# Bypasses the first matcher missed. Each must now FLAG.

# INV-1: a durable filename split across string concatenation.
run inv1 "$FIX/inv1-concat.workflow.js"
[ "$RC" -ne 0 ] || fail "INV-1 must FLAG a durable filename split by concatenation (\"AGENTS\" + \".md\"): $OUT"
echo "$OUT" | grep -q "AGENTS.md" || fail "INV-1 concat message must name the durable artefact: $OUT"

# INV-2: a high-privilege tool named with different casing.
run inv2 "$FIX/inv2-uppercase.workflow.js"
[ "$RC" -ne 0 ] || fail "INV-2 must FLAG a high-privilege tool regardless of casing (Bash): $OUT"

# INV-2: a high-privilege tool on a continuation line of a wrapped @tools list.
run inv2 "$FIX/inv2-multiline.workflow.js"
[ "$RC" -ne 0 ] || fail "INV-2 must FLAG a high-privilege tool on a multi-line @tools list: $OUT"

# INV-2: @tools declared before the @untrusted-reader flag (order independence).
run inv2 "$FIX/inv2-order.workflow.js"
[ "$RC" -ne 0 ] || fail "INV-2 must FLAG regardless of marker order within an agent block: $OUT"

# INV-2: uppercased marker keywords must not escape the lint.
run inv2 "$FIX/inv2-uppercase-markers.workflow.js"
[ "$RC" -ne 0 ] || fail "INV-2 must FLAG when the marker keywords themselves are uppercased: $OUT"

# INV-2: an unterminated @tools list for an untrusted reader fails closed.
run inv2 "$FIX/inv2-unterminated.workflow.js"
[ "$RC" -ne 0 ] || fail "INV-2 must FLAG (fail closed) an unterminated @tools list for an untrusted reader: $OUT"

echo "All INV-1/INV-2 firewall tests passed."
