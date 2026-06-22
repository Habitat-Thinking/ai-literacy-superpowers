/**
 * FIXTURE (by-design) — INV-2 CLEAN.
 *
 * Pattern: classify-and-act over a backlog of external issues.
 * Token budget: 50k. Model tier per role: triager=sonnet, actor=opus.
 * INV-1 boundary: proposes only; never writes a durable artefact.
 * Runtime scope: Claude Code only; inert elsewhere.
 *
 * INV-2 is RESPECTED: the untrusted-content reader is withheld every
 * high-privilege tool (`write`, `edit`, `bash`, `commit`, `push`). Only a
 * separate, trusted actor — which reads no untrusted content — may act. The
 * INV-2 lint MUST pass on this fixture.
 */

// @workflow-agent: issue-triager
// @untrusted-reader: true        // reads external issue bodies (untrusted)
// @tools: [read, grep]           // low-privilege only — quarantined
async function triageUntrusted(ctx) {
  return ctx.spawn("issue-triager");
}

// @workflow-agent: trusted-actor
// @untrusted-reader: false       // acts only on the triager's vetted output
// @tools: [read, write, bash]    // high-privilege, but reads no untrusted content
async function act(ctx) {
  return ctx.spawn("trusted-actor");
}

module.exports = { triageUntrusted, act };
