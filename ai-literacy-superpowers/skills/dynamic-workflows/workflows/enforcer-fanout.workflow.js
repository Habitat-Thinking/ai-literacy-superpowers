/**
 * enforcer-fanout.workflow.js — TEMPLATE. Adapt per task; never run verbatim.
 *
 * Intent. Replace single-context enforcement of many harness constraints —
 * which tires and stops early ("35 of 50 checked") — with one verifier
 * subagent per constraint, each in its own clean context, plus a skeptic pass
 * that tries to refute every candidate violation before it is reported.
 *
 * Pattern: fan-out-and-synthesize + adversarial verification. The synthesis
 * barrier is load-bearing — the report cannot form until all N verifiers have
 * returned, so there is no silent "good enough" stop.
 *
 * Token budget: ~10k per workflow (each verifier is small and focused).
 * Model tier per role: verifier = haiku (one mechanical constraint each),
 * skeptic = sonnet (judgement), synthesizer = sonnet. See the MODEL_ROUTING
 * workflow-election section for the budget + tiering convention.
 *
 * INV-1 boundary: this workflow only *reports*. The constraint inventory is
 * handed in by the harness via `args`, never reached by spelling a durable
 * filename in code, and findings are returned, never written back to the
 * curated harness or agent memory. Promotion of any finding flows through the
 * human-curation gate, not this workflow.
 *
 * Runtime scope: Claude Code only. Dynamic workflows are a Claude Code runtime
 * capability and are not transferable to Copilot CLI or other coding agents;
 * on a tree without the workflow runtime this file is inert reference material.
 *
 * Adapt: confirm the runtime primitives (agent/parallel/pipeline/phase/log)
 * against https://code.claude.com/docs/en/workflows before running.
 */

export const meta = {
  name: 'enforcer-fanout',
  description: 'One verifier subagent per harness constraint, skeptic-filtered, synthesised',
  phases: [{ title: 'Verify' }, { title: 'Skeptic' }, { title: 'Synthesize' }],
}

const VERDICT_SCHEMA = {
  type: 'object',
  required: ['id', 'violated', 'evidence'],
  properties: {
    id: { type: 'string' },
    violated: { type: 'boolean' },
    evidence: { type: 'string' },
  },
}

const SKEPTIC_SCHEMA = {
  type: 'object',
  required: ['id', 'isRealViolation', 'reason'],
  properties: {
    id: { type: 'string' },
    isRealViolation: { type: 'boolean' },
    reason: { type: 'string' },
  },
}

// The harness supplies the enforceable constraint inventory — the template
// never reaches for a curated file by name (INV-1 / firewall).
const constraints = (typeof args === 'object' && args && args.constraints) || []
if (!constraints.length) {
  log('enforcer-fanout: no constraints supplied — nothing to enforce')
}

phase('Verify')
// Fan out: one verifier per constraint, each in its own clean context window.
const candidates = (await parallel(
  constraints.map((c) => () =>
    agent(
      `Verify this single constraint against the staged diff. Report pass/fail with file:line evidence:\n${c.text}`,
      { label: `verify:${c.id}`, phase: 'Verify', model: 'haiku', schema: VERDICT_SCHEMA },
    ),
  ),
)).filter(Boolean)

phase('Skeptic')
// Adversarial pass: a skeptic tries to refute each candidate violation so a
// false positive never reaches the report.
const reviewed = (await parallel(
  candidates
    .filter((v) => v.violated)
    .map((v) => () =>
      agent(
        `A verifier flagged this as a violation. Try to refute it — is it a false positive? Default to keeping it only if you cannot refute it.\n${JSON.stringify(v)}`,
        { label: `skeptic:${v.id}`, phase: 'Skeptic', model: 'sonnet', schema: SKEPTIC_SCHEMA },
      ),
    ),
)).filter(Boolean)

phase('Synthesize')
// Synthesis barrier: every constraint is accounted for — no silent drop.
const confirmed = reviewed.filter((r) => r.isRealViolation)
log(`enforcer-fanout: checked ${constraints.length} constraints; ${confirmed.length} confirmed after skeptic review`)
// In the live runtime the workflow returns { checked, confirmed } to its caller.
