/**
 * FIXTURE (malformed-by-design) — INV-2 VIOLATION via tool casing.
 * Pattern: classify-and-act. Token budget: 50k. Model tier per role:
 * triager=sonnet. INV-1 boundary: proposes only. Claude Code only.
 *
 * Regression guard: a high-privilege tool named with different casing must
 * still be flagged for an untrusted reader.
 */
// @workflow-agent: issue-triager
// @untrusted-reader: true
// @tools: [read, Bash]
async function triageUntrusted(ctx) {
  return ctx.spawn("issue-triager");
}
module.exports = { triageUntrusted };
