/**
 * FIXTURE (malformed-by-design) — INV-2 VIOLATION via a wrapped @tools list.
 * Pattern: classify-and-act. Token budget: 50k. Model tier per role:
 * triager=sonnet. INV-1 boundary: proposes only. Claude Code only.
 *
 * Regression guard: a high-privilege tool on a continuation line of a
 * multi-line @tools list must still be flagged.
 */
// @workflow-agent: issue-triager
// @untrusted-reader: true
// @tools: [read,
//          bash]
async function triageUntrusted(ctx) {
  return ctx.spawn("issue-triager");
}
module.exports = { triageUntrusted };
