/**
 * reflection-mining.workflow.js — TEMPLATE. Adapt per task; never run verbatim.
 *
 * Intent. Raise the *proposal* quality of the compound-learning loop without
 * touching the human-curates principle. Cluster the project's reflection log
 * with parallel agents, adversarially pre-filter each candidate rule ("would
 * this actually have prevented a real past mistake?"), and surface a vetted
 * shortlist for a human to promote. The workflow never promotes anything itself.
 *
 * Pattern: generate-and-filter + adversarial verification. Over-generate
 * candidate rules, then prune hard.
 *
 * Token budget: ~8k per workflow (cluster, filter, shortlist — proposal only).
 * Model tier per role: clusterer = haiku, skeptic = sonnet, shortlister =
 * sonnet. See the MODEL_ROUTING workflow-election section.
 *
 * INV-1 boundary (the firewall this workflow exists to respect): it writes a
 * vetted shortlist to a NON-durable staging sink only. It never writes the
 * curated agent-memory file or any other durable artefact — promotion is a
 * human act through the existing curation gate. Reflection-log content is
 * handed in via `args`; the durable artefacts are named in this preamble only
 * to document the boundary, never reached in code.
 *
 * Runtime scope: Claude Code only. Dynamic workflows are a Claude Code runtime
 * capability and are not transferable to Copilot CLI or other coding agents;
 * on a tree without the workflow runtime this file is inert reference material.
 *
 * Adapt: confirm the runtime primitives against
 * https://code.claude.com/docs/en/workflows before running.
 */

export const meta = {
  name: 'reflection-mining',
  description: 'Cluster reflections, adversarially filter, shortlist promotion candidates for a human',
  phases: [{ title: 'Cluster' }, { title: 'Filter' }, { title: 'Shortlist' }],
}

const CANDIDATE_SCHEMA = {
  type: 'object',
  required: ['rule', 'wouldHavePrevented', 'evidence'],
  properties: {
    rule: { type: 'string' },
    wouldHavePrevented: { type: 'boolean' },
    evidence: { type: 'string' },
  },
}

// Reflection-log entries are handed in by the harness — never read by name.
const entries = (typeof args === 'object' && args && args.entries) || []

phase('Cluster')
const clusters = await agent(
  `Cluster these reflection entries by the underlying recurring theme. Return one candidate rule per cluster.\n${JSON.stringify(entries)}`,
  { label: 'cluster', phase: 'Cluster', model: 'haiku' },
)

phase('Filter')
// Adversarial pre-filter: keep a candidate only if it would have prevented a
// real past mistake. Each is judged in its own context.
const judged = (await parallel(
  (clusters.candidates || []).map((c) => () =>
    agent(
      `Would this proposed rule actually have prevented a real mistake recorded in the log? Refute it if not.\n${JSON.stringify(c)}`,
      { label: `filter:${c.id || c.rule}`, phase: 'Filter', model: 'sonnet', schema: CANDIDATE_SCHEMA },
    ),
  ),
)).filter(Boolean)

phase('Shortlist')
const shortlist = judged.filter((c) => c.wouldHavePrevented)
// Proposes to a NON-durable staging sink for a human to curate (INV-1).
// The staging path is supplied by the harness; nothing durable is written here.
const stagingSink = (typeof args === 'object' && args && args.stagingPath) || 'REFLECTION_STAGING.md'
log(`reflection-mining: ${shortlist.length} vetted candidate(s) proposed to ${stagingSink} for human curation`)
// In the live runtime the workflow returns the shortlist; a human promotes.
