/**
 * adversarial-review.workflow.js — TEMPLATE. Adapt per task; never run verbatim.
 *
 * Intent. Move code review into a context window distinct from the one that
 * produced the implementation, so the reviewer is not judging its own output.
 * Advocatus Diaboli is the rubric-bearing adversary; each CUPID and literate-
 * programming property is checked by a dedicated verifier and the findings are
 * synthesised, not collapsed into a single thumbs-up.
 *
 * Pattern: adversarial verification. Separation of producer and critic is the
 * load-bearing property — it defeats self-preferential bias.
 *
 * Token budget: ~12k per workflow (per-property verifiers plus synthesis).
 * Model tier per role: per-property verifier = sonnet, adversary/synthesizer =
 * opus (the hardest judgement). See the MODEL_ROUTING workflow-election section.
 *
 * INV-1 boundary: review *proposes* findings; it never writes a durable
 * artefact. The diff under review is handed in via `args`; nothing here edits
 * the curated harness, agent memory, or project conventions.
 *
 * Runtime scope: Claude Code only. Dynamic workflows are a Claude Code runtime
 * capability and are not transferable to Copilot CLI or other coding agents;
 * on a tree without the workflow runtime this file is inert reference material.
 *
 * Adapt: confirm the runtime primitives against
 * https://code.claude.com/docs/en/workflows before running. Review cycles still
 * respect the pipeline's MAX_REVIEW_CYCLES guardrail.
 */

export const meta = {
  name: 'adversarial-review',
  description: 'Separate-context review: one verifier per CUPID/literate property, synthesised',
  phases: [{ title: 'Refute' }, { title: 'Synthesize' }],
}

const FINDING_SCHEMA = {
  type: 'object',
  required: ['property', 'pass', 'findings'],
  properties: {
    property: { type: 'string' },
    pass: { type: 'boolean' },
    findings: { type: 'array', items: { type: 'string' } },
  },
}

// The properties the adversary evaluates, each by its own verifier.
const PROPERTIES = [
  'Composable', 'Unix-philosophy', 'Predictable', 'Idiomatic', 'Domain-based',
  'Literate: narrative preamble', 'Literate: reasoning-not-signatures',
]

const diff = (typeof args === 'object' && args && args.diff) || ''

phase('Refute')
// Each property is checked by a dedicated verifier in a fresh context — none
// of them saw the implementer's reasoning.
const evaluated = (await parallel(
  PROPERTIES.map((p) => () =>
    agent(
      `You are Advocatus Diaboli. Evaluate the diff strictly against the "${p}" property. Find where it fails; do not praise. Diff:\n${diff}`,
      { label: `refute:${p}`, phase: 'Refute', model: 'sonnet', schema: FINDING_SCHEMA },
    ),
  ),
)).filter(Boolean)

phase('Synthesize')
// Synthesis preserves each property's findings rather than collapsing them.
const failed = evaluated.filter((e) => !e.pass)
const verdict = await agent(
  `Synthesise these per-property review findings into a prioritised report (blocking / should-fix / nit). Do not drop any property's findings.\n${JSON.stringify(evaluated)}`,
  { label: 'synthesize', phase: 'Synthesize', model: 'opus' },
)
log(`adversarial-review: ${PROPERTIES.length} properties evaluated; ${failed.length} with findings`)
log(verdict)
// In the live runtime the workflow returns the synthesised verdict to its caller.
