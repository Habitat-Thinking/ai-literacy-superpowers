/**
 * FIXTURE (malformed-by-design) — INV-2 VIOLATION via uppercased markers.
 * Pattern: classify-and-act. Token budget: 50k. Model tier per role:
 * triager=sonnet. INV-1 boundary: proposes only. Claude Code only.
 *
 * Regression guard: uppercasing the marker keywords themselves must not escape
 * the lint (the markers are matched case-insensitively).
 */
// @WORKFLOW-AGENT: issue-triager
// @UNTRUSTED-READER: TRUE
// @TOOLS: [read, bash]
async function triageUntrusted(ctx) {
  return ctx.spawn("issue-triager");
}
module.exports = { triageUntrusted };
