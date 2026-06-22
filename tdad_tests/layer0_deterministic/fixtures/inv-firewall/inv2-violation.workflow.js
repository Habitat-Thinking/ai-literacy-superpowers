/**
 * FIXTURE (malformed-by-design) — INV-2 VIOLATION.
 *
 * Pattern: classify-and-act over a backlog of external issues.
 * Token budget: 50k. Model tier per role: triager=sonnet, actor=opus.
 * INV-1 boundary: proposes only; never writes a durable artefact.
 * Runtime scope: Claude Code only; inert elsewhere.
 *
 * This fixture DELIBERATELY BREACHES INV-2: it declares an
 * untrusted-content reader and then grants it a high-privilege tool
 * (`bash`). The INV-2 lint MUST flag it (AC-10). Not a shipped template.
 */

// @workflow-agent: issue-triager
// @untrusted-reader: true        // reads external issue bodies (untrusted)
// @tools: [read, grep, bash]     // BREACH: `bash` is high-privilege
async function triageUntrusted(ctx) {
  return ctx.spawn("issue-triager");
}

module.exports = { triageUntrusted };
