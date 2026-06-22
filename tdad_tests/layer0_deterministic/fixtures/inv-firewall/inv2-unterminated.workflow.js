/**
 * FIXTURE (malformed-by-design) — INV-2 VIOLATION via an unterminated list.
 * Pattern: classify-and-act. Token budget: 50k. Model tier per role:
 * triager=sonnet. INV-1 boundary: proposes only. Claude Code only.
 *
 * Regression guard: an untrusted reader whose @tools list never closes cannot
 * be verified and must fail closed. There is no closing bracket anywhere.
 */
// @workflow-agent: issue-triager
// @untrusted-reader: true
// @tools: [read,
//          bash
async function triageUntrusted(ctx) {
  return ctx.spawn("issue-triager")
}
module.exports = { triageUntrusted }
