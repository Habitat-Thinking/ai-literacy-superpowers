---
spec: docs/superpowers/specs/2026-06-15-dl-change-site-prediction-design.md
date: 2026-06-15
mode: spec
diaboli_model: claude-opus-4-8[1m]
adjudication: all 12 accepted (1 critical, 4 high, 7 medium) — absorbed into the spec
objections:
  - id: O1
    category: specification quality
    severity: high
    claim: "The failure-direction rule (§5) admits 'a clearly-marked note' but the change_prediction schema defines no field to carry it, so the disclosure has no required structured home — and the empty case (predicted_sites: []) has no reason to carry it either."
    disposition: accepted
    disposition_rationale: "Added a structured, required-when-needed `change_direction` enum field (over-prediction | under-prediction) on the change_prediction block; mandatory when change_confidence < high (including the empty case). The disclosure now lives in parseable YAML, checkpoint-verifiable — the same lesson scope-resolution learned (structured, not prose)."
  - id: O2
    category: implementation
    severity: critical
    claim: "The agent enumerates exactly four legal modes and refuses unrecognised ones; the spec introduces mode: change-prediction without naming the agent-file deltas, so the agent would refuse the very mode the feature dispatches."
    disposition: accepted
    disposition_rationale: "Spec §4 now enumerates every agent-file delta required in lockstep: the Inputs mode list (four→five), the unrecognised-mode refusal example, the missing-task refusal example, and the frontmatter description / 'Four modes' prose. Implementation must move all of them together."
  - id: O3
    category: specification quality
    severity: high
    claim: "The insert target encodes structure in a string (after:<stage-id>) with no validation rule, and change_prediction is absent from the template Validation rules entirely."
    disposition: accepted
    disposition_rationale: "Replaced the string-encoded anchor with a TYPED form: kind: insert carries `anchor: <stage-id>` + `position: after | before` (no in-string parsing). kind: modify carries `target: <stage-id>`. Added a full change_prediction Validation-rules block to the template (target/anchor must reference an existing stage.id; position required+legal on insert; kind legality; empty-list + change_direction rules)."
  - id: O4
    category: risk
    severity: high
    claim: "The render highlight reads as a directive ('edit here') despite the banner; the model-level predict-not-direct rule is enforced only by prose at the render surface the developer acts on."
    disposition: accepted
    disposition_rationale: "Strengthened the render anti-directive controls at the point of emphasis (§6): every highlighted node carries a 'predicted' badge; the legend keys the highlight to 'prediction, not instruction'; the panel phrases every site as 'likely edits …'; the checkpoint fails on any imperative/directive phrasing in the render. The banner is now the floor, not the only control."
  - id: O5
    category: specification quality
    severity: high
    claim: "modify vs insert classification rests on surface task verbs, which cannot reliably discriminate (a task may phrase an insert as a modify); the 'never conflated' guarantee is unfounded."
    disposition: accepted
    disposition_rationale: "Softened the guarantee: the kind is a best-judgement label grounded in code evidence where available (O6), and MAY be wrong — misclassification is one of the failures the change_direction disclosure covers. A task may legitimately imply BOTH kinds (the motivating example inserts a step AND modifies the gate's routing); the spec now says so and permits both."
  - id: O6
    category: implementation
    severity: medium
    claim: "Predicted sites carry a reason but no evidence field — the one new claim type, and the heaviest honesty burden, is the only one allowed to skip a checkable citation."
    disposition: accepted
    disposition_rationale: "Added an `evidence` field to predicted_sites[] ({ path, excerpt? }); required for a modify site at change_confidence medium/high (cite the code in the target stage the task changes), encouraged for insert (the anchor's evidence). Brings the prediction in line with PipelineStage/transition grounding."
  - id: O7
    category: scope
    severity: medium
    claim: "The pipeline-map spec left the task_relevance per-stage-marker question open for the cartographer; this spec chooses the wrapper block but never closes that question, risking two ways to express stage-level task relevance."
    disposition: accepted
    disposition_rationale: "Spec §3 now explicitly CLOSES the pipeline-map §9.2.3 open question: the wrapper change_prediction block subsumes it; no per-stage task_relevance marker is added. One representation."
  - id: O8
    category: risk
    severity: medium
    claim: "A modify target need only exist in stages, not be in-scope, so a prediction can mark a stage the scope panel disclosed as adjacent/context — a self-contradicting artefact."
    disposition: accepted
    disposition_rationale: "Added the rule: a modify target (and an insert anchor) must be in the touched/in-scope set, not a context-only stage. If prediction needs an edit site the bound disclosed as adjacent, that is an under-reach signal fed back into scope_resolution (the Phase B scope-relevance loop), not a silent contradiction. The checkpoint cross-checks predicted targets against scope_resolution."
  - id: O9
    category: premise
    severity: medium
    claim: "The premise leads with the insert case, where the value-add over the scope panel is weakest (the anchor echoes scope + the task verb); the strong case is modify-narrowing."
    disposition: accepted
    disposition_rationale: "Reframed §1 to foreground the modify-narrowing value (narrowing a wide touched-set to the few actually-edited nodes — where the two sets most diverge) as the primary justification, with insert as the secondary, structural-change case. The feature is defended on its strongest case."
  - id: O10
    category: scope
    severity: medium
    claim: "The spec changes /pipeline-map's documented surface (flag, panel, styling, banner) but lists no docs deliverable — the same omission the pipeline-map spec absorbed as O9."
    disposition: accepted
    disposition_rationale: "Spec §6 now names the docs update as an explicit, same-PR deliverable: the run-the-pipeline-map-command how-to and pipeline-map-command reference gain the --predict-change flag and the predicted-change-sites surface (CLAUDE.md Docs Site Review)."
  - id: O11
    category: specification quality
    severity: medium
    claim: "change_confidence is 'the prediction as a whole' but predicted_sites is a list of independently-reasoned sites with no rule relating the scalar to mixed-certainty sites."
    disposition: accepted
    disposition_rationale: "Spec §3.1 now states change_confidence is the MINIMUM (the honest floor) over the predicted sites, and that mixed certainty must be named in the change_direction disclosure. A confident insert beside a guessy modify reports the lower value."
  - id: O12
    category: alternatives
    severity: medium
    claim: "The spec ships a fifth mode that re-runs the full pipeline build; a cheaper consume-an-existing-map prediction pass (mirroring cross-check-only's payload pattern) is not weighed."
    disposition: accepted
    disposition_rationale: "Recorded the weigh-and-decision in §4: the superset construction is chosen for the one-shot /pipeline-map --predict-change UX (the primary human surface — a developer states a task and gets the predicted map in one step, no two-step map-then-feed). The cheaper consume-a-map payload form (predict over a map already generated and trusted) is a recorded, deliberately-deferred follow-on affordance, not built in v1."
---

## Summary

Spec-mode diaboli on the change-site-prediction spec (#368) raised **12
objections** — 1 critical, 4 high, 7 medium, 0 low — across premise (1),
scope (2), implementation (2), risk (2), alternatives (1), and
specification quality (4). **All 12 accepted** and absorbed into the spec.

The defining theme is the feature's **honesty burden**: predicting future
human edits is far easier to assert with false confidence than the
verifiable scope it sits beside. The load-bearing resolutions:

- **O2 (critical)** — the spec now enumerates the agent-file mode-enum
  deltas (four→five) it must move in lockstep, so the new mode is not
  refused by its own dispatch surface.
- **O1 / O11** — the failure-direction disclosure gets a **structured**
  `change_direction` field (required when confidence < high, including the
  empty case), and `change_confidence` is defined as the **minimum** over
  sites — no prose-only disclosure, no ambiguous aggregate.
- **O3** — the insert anchor becomes a **typed** `anchor` + `position`
  pair (no in-string parsing), with a full Validation-rules block added to
  the template.
- **O4** — the render carries the predict-not-direct framing **at the
  point of emphasis** (per-node "predicted" badge, legend, panel phrasing,
  checkpoint), not just a banner.
- **O5 / O6 / O8** — kind is a best-judgement label (the "never conflated"
  guarantee softened), predicted sites gain an **evidence** field, and
  targets must be **in-scope** (an out-of-scope need is an under-reach
  correction fed back to scope_resolution, never a silent contradiction).

## What was NOT challenged (diaboli disclosure)

- The opt-in, off-default placement (`mode: pipeline` unchanged; the flag
  gates prediction) — the right risk posture, faithful to the deferral.
- The additivity / back-compat of the `change_prediction` wrapper block
  (absence ⇒ "not run") — mirrors the proven `pipeline_cross_check_status`
  pattern.
- The unchanged read-only trust boundary.
- Removal/rerouting and effort-sizing being out of v1 scope.
- The model-level "predict, never direct" phrasing rule itself (O4 is
  narrowly about the render weakening it).
