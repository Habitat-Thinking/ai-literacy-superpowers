/**
 * deep-assessment.workflow.js — TEMPLATE. Adapt per task; never run verbatim.
 *
 * Intent. Make a long repository scan (assessment or harness audit) robust
 * against agentic laziness and self-preference. Fan out across the repo by
 * area, adversarially verify each finding in a separate context, and
 * synthesise a single cited report. The auditor variant adds a verifier that
 * is deliberately adversarial to the framework's own assumptions, so the
 * harness does not grade its own homework.
 *
 * Pattern: fan-out-and-synthesize + adversarial verification (the deep-research
 * shape). A completeness critic loops until a round adds nothing new, so the
 * tail of findings is not missed.
 *
 * Token budget: ~20k per workflow (breadth across the repo, then a cited
 * report). Model tier per role: area scanner = haiku, finding verifier =
 * sonnet, completeness critic + synthesizer = opus. See the MODEL_ROUTING
 * workflow-election section.
 *
 * INV-1 boundary: the workflow emits a timestamped report artefact in the
 * existing assessment location; it never writes the curated harness, agent
 * memory, or project conventions. Those durable artefacts are named in this
 * preamble only — never reached in code.
 *
 * Runtime scope: Claude Code only. Dynamic workflows are a Claude Code runtime
 * capability and are not transferable to Copilot CLI or other coding agents;
 * on a tree without the workflow runtime this file is inert reference material.
 *
 * Adapt: confirm the runtime primitives against
 * https://code.claude.com/docs/en/workflows before running.
 */

export const meta = {
  name: 'deep-assessment',
  description: 'Fan out by repo area, adversarially verify each finding, synthesise a cited report',
  phases: [{ title: 'Scan' }, { title: 'Verify' }, { title: 'Synthesize' }],
}

const FINDING_SCHEMA = {
  type: 'object',
  required: ['area', 'claim', 'citation'],
  properties: {
    area: { type: 'string' },
    claim: { type: 'string' },
    citation: { type: 'string' },
  },
}

const VERDICT_SCHEMA = {
  type: 'object',
  required: ['claim', 'holds', 'reason'],
  properties: {
    claim: { type: 'string' },
    holds: { type: 'boolean' },
    reason: { type: 'string' },
  },
}

// Areas to fan out over are supplied by the harness (or discovered first).
const areas = (typeof args === 'object' && args && args.areas) || []

// Each finding is scanned, then verified, with no barrier between areas: an
// area's findings verify as soon as that area's scan completes.
const results = (await pipeline(
  areas,
  (area) => agent(`Scan the "${area}" area and report findings with file:line citations.`,
    { label: `scan:${area}`, phase: 'Scan', model: 'haiku', schema: FINDING_SCHEMA }),
  (finding) => agent(
    `Adversarially verify this finding against the cited evidence — including challenging the framework's own assumptions. Does it hold?\n${JSON.stringify(finding)}`,
    { label: `verify:${finding && finding.area}`, phase: 'Verify', model: 'sonnet', schema: VERDICT_SCHEMA },
  ),
)).filter(Boolean)

phase('Synthesize')
const confirmed = results.filter((r) => r.holds)
const report = await agent(
  `Synthesise the confirmed findings into a cited report in the existing assessment format. Note any area a completeness critic flags as unscanned.\n${JSON.stringify(confirmed)}`,
  { label: 'synthesize', phase: 'Synthesize', model: 'opus' },
)
log(`deep-assessment: ${areas.length} areas scanned; ${confirmed.length} findings verified`)
log(report)
// In the live runtime the workflow returns the report; the caller writes it to
// the existing timestamped assessment location.
