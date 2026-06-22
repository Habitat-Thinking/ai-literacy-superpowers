/**
 * FIXTURE (malformed-by-design) — INV-2 VIOLATION with @tools before the flag.
 * Pattern: classify-and-act. Token budget: 50k. Model tier per role:
 * triager=sonnet. INV-1 boundary: proposes only. Claude Code only.
 *
 * Regression guard: marker order within a block must not matter — @tools
 * declared above @untrusted-reader: true must still be flagged.
 */
// @workflow-agent: issue-triager
// @tools: [read, push]
// @untrusted-reader: true
async function triageUntrusted(ctx) {
  return ctx.spawn("issue-triager");
}
module.exports = { triageUntrusted };
