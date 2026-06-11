---
spec: docs/superpowers/specs/2026-06-11-format-revision-per-stage-cost-design.md
date: 2026-06-11
mode: code
diaboli_model: claude-opus-4-8[1m]
objections:
  - id: O1
    category: specification quality
    severity: medium
    claim: "Example 2's whole-record `tokens` range and its `tokens_by_stage` sum are exactly equal, and (newly) its whole-record cost_usd is set exactly equal to the per-stage cost sum 'by construction' — so the sole canonical cost-present example demonstrates exact equality on every axis, which the reference's own correlation note explicitly disclaims as required, risking over-generalisation into a false must-sum mandate."
    evidence: "estimate-record-format.md L491 `tokens: { low: 200000, high: 500000 }` equals the stage sum (L493-504); L79-83 says the whole-record band need NOT equal the sum and the prose explains only when they DIFFER — but Example 2 now shows equality on both tokens and cost simultaneously, with no differing-band example."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Add a one-line note to Example 2's prose: the whole-record
      band equals the per-stage sum here by construction, and the correlation
      note (§4.4) permits them to differ — so the example is not a must-sum
      mandate.
  - id: O2
    category: implementation
    severity: medium
    claim: "The merged S2 agent names two different literal forms for the emitted split-tier `model_tier` value — `Standard / Capable` (spaced) and `Standard/Capable` (unspaced) — while the reference's binding table instructs emitting the literal `Standard/Capable`. The new Split-tier spread rule is robust (it whitespace-normalises before testing `/`), but the agent's emitted-value contract leaves the actual byte-string undefined, so an exact-string consumer of `model_tier` would diverge."
    evidence: "cost-estimator.agent.md L146 `the split tier Standard / Capable` vs L162 `Standard/Capable split`; estimate-record-format.md L213-214 `records the literal split label (Standard/Capable)`."
    disposition: accepted
    disposition_rationale: >
      Accepted as a noted residual (out of #377's format-only scope — it touches
      the merged S2 agent). The Split-tier spread rule normalises whitespace, so
      conformance holds; the agent's two literal forms are a pre-existing S2 doc
      inconsistency. Filed as a tiny follow-on issue to normalise the agent's
      emitted `model_tier` literal; not fixed in this format slice.
  - id: O3
    category: risk
    severity: medium
    claim: "The Split-tier spread closed rule is proved total by 'no single tier label contains /', but the rule fires on the EMITTED `model_tier` value, and the reference types `model_tier` as an open `string` with no validation-checklist line constraining the emitted value to the enumerated binding-table labels — so the totality is closed by convention, not construction; a future emitter writing a free-form `model_tier` containing `/` would be silently misclassified as split-tier."
    evidence: "estimate-record-format.md L341-345 grounds soundness in the labels MODEL_ROUTING.md admits; but L30 types `model_tier` as `string ... may be a split tier such as Standard/Capable`, and the validation checklist (L312-376) has no line restricting the emitted `model_tier` to the enumerated set."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Add a one-line note that the contains-`/` classifier is
      total only over the binding-table labels, and emitters MUST write only those
      enumerated labels into `model_tier` — making the convention explicit rather
      than implied.
  - id: O4
    category: specification quality
    severity: low
    claim: "The Split-tier spread checklist line keys on a stage's `model_tier` being a split tier but does not state the verdict when a `tokens_by_stage[]` entry carries a per-stage cost_usd while its `model_tier` is absent — `model_tier` is required per the field table so a well-formed record cannot hit this, but the checklist line does not cross-reference that dependency, leaving an S3 author to decide in isolation."
    evidence: "estimate-record-format.md L330-345 keys on `model_tier` being a split tier with no clause for an absent `model_tier`; the only guard is the separate required-ness of `model_tier` at L30, which the checklist line does not name."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Add a parenthetical to the Split-tier spread checklist line
      cross-referencing that `model_tier` is a required sub-field, so an S3 author
      implementing the line in isolation knows an absent `model_tier` is a
      structural failure handled elsewhere, not a vacuous pass.
  - id: O5
    category: implementation
    severity: low
    claim: "Example 1 carries four stages (incl. code-reviewer) and Example 2 carries three (code-reviewer and integration dropped, named in Excluded), so the canonical demonstration of the new per-stage cost_usd sub-field lands on a different, smaller stage roster than the cost-omitted example — a reader cannot read the two as a clean before/after of the same record gaining bands."
    evidence: "estimate-record-format.md Example 1 L426-438 (4 stages); Example 2 L492-504 (3 stages), L536-538 Excluded names code-reviewer and integration as not enumerated."
    disposition: accepted
    disposition_rationale: >
      Accepted as a noted residual (clarity, not correctness — both examples
      validate). The differing rosters are acceptable for now; a future docs pass
      could align them for a clean before/after, but it is not worth a format
      churn in this slice.
  - id: O6
    category: risk
    severity: low
    claim: "The grounding-path consumer special-case (don't count a trailing-slash directory path as a grounding) is advisory/unenforced, and at code time the risk is the COMMON case not a tail: the directory-sentinel path is the day-one default the merged S2 agent emits on every record (empty observability/costs/), so a downstream counter that doesn't special-case the trailing slash miscounts 100% of today's records as snapshot-grounded."
    evidence: "estimate-record-format.md L279-285 (special-case) + L296-301 ('advisory/unenforced ... silent-miscount risk'); cost-estimator.agent.md L282-284: the agent emits the directory path on the cost-omitted (today's only producible) record."
    disposition: accepted
    disposition_rationale: >
      Accepted as a noted residual. The miscount risk is consciously accepted
      (the keep-the-directory-sentinel trade); the code-time sharpening — that it
      is the 100%-of-records common case today, not a tail — is recorded here so
      the S3 checkpoint author treats the trailing-slash special-case as
      mandatory, not optional.
---

## O1 — specification quality — medium

### Claim

Example 2's whole-record `tokens` range and the arithmetic sum of its
`tokens_by_stage[].tokens` are exactly equal, and (newly) its whole-record
`cost_usd` is set exactly equal to the per-stage cost sum "by construction". The
reference's explicit rule (L79-83) is that the whole-record band need **not** equal
the sum, and the prose must explain only **when they differ**. Example 2 satisfies
the rule vacuously, but it now demonstrates exact equality on **both** axes
simultaneously, as the single canonical cost-present example. An author reading only
the example — the reference instructs readers to parse, not read loosely — may
over-generalise this into a false "per-stage bands must sum to the whole-record band"
mandate, the rigidity the correlation note exists to prevent.

### Evidence

`estimate-record-format.md` L491 `tokens: { low: 200000, high: 500000 }`; stages
(L493-504) sum to `{200000, 500000}`. Spec §4.5 step 4 sets the whole-record cost
equal to the per-stage sum. The reference's own rule (L79-83): "The whole-record
band need **not** equal the arithmetic sum ... When they differ the prose body says
why."

### Why this matters

The single worked example is the most-copied surface of a contract. Demonstrating
exact equality on every band, with no example of a deliberately-differing band and
its prose justification, undercuts the correlation note's intent and invites a future
emitter or S3 checkpoint to enforce a sum constraint the format explicitly disclaims.
A one-line note in the Example 2 prose ("the whole-record band equals the sum here by
construction; the correlation note permits them to differ") would close it.

## O2 — implementation — medium

### Claim

The merged S2 agent must stay conformant to the edited reference, but the agent's own
description of the value it emits into `tokens_by_stage[].model_tier` is internally
ambiguous: `Standard / Capable` (spaced) at L146 and `Standard/Capable` (unspaced) at
L162. The reference's binding table (L214) instructs emitting the literal
`Standard/Capable`. The new Split-tier spread closed rule is robust to this (it
whitespace-normalises before testing for `/`), but the agent's emitted-value contract
does not pin which literal it writes.

### Evidence

`cost-estimator.agent.md` L146 "the split tier `Standard / Capable`" vs L162
"`Standard/Capable` split". `estimate-record-format.md` L213-214: "records the literal
split label (`Standard/Capable`)".

### Why this matters

A reference that calls `model_tier` "the literal split label" while its sole merged
consumer names two different literals leaves the emitted byte-string undefined. The
Split-tier rule absorbs it today, but any consumer doing an exact-string match on
`model_tier` (not the normalised join key) would diverge by emitted form. This is a
pre-existing S2 ambiguity the format edit did not introduce but now interacts with —
worth a one-word S2 agent fix (pick the unspaced literal) or a noted residual, since a
format-only slice should not silently depend on an ambiguous consumer.

## O3 — risk — medium

### Claim

The Split-tier spread closed rule is proved total by "no single (non-split) tier label
contains a `/`" (L341-345). That proof is over the labels `MODEL_ROUTING.md` admits,
but the rule fires on the **emitted** `model_tier` value, and the reference does not
constrain an emitter to write only binding-table labels into that field. The field-table
type (L30) is `string ... may be a split tier`, descriptive rather than a closed enum,
and no validation-checklist line restricts the emitted `model_tier`. A future emitter
writing a free-form `model_tier` containing `/` for a non-split reason would be silently
classified as split-tier and subjected to the strict `low < high` check it should not face.

### Evidence

`estimate-record-format.md` L341-345 grounds soundness in "`MODEL_ROUTING.md` names
exactly the single tiers `Most capable` and `Standard` ... plus the one ... split". But
L30 types `model_tier` as an open `string`, and the validation checklist (L312-376) has no
line constraining the emitted `model_tier` to that enumerated set.

### Why this matters

A "closed rule" whose totality depends on a property of an unvalidated free-text field is
closed only by convention. The slice markets the contains-`/` trigger as a sound total
classifier; true for admitted labels, but the format does not enforce that emitters only
produce admitted labels, so the guarantee is weaker than stated for any future
non-conformant emitter. A one-line note ("the contains-`/` classifier is total only over
the binding-table labels; emitters MUST write only those into `model_tier`") would make the
convention explicit.

## O4 — specification quality — low

### Claim

The Split-tier spread checklist line is keyed on a stage's `model_tier` being a split tier,
but does not state the verdict when a `tokens_by_stage[]` entry carries a per-stage
`cost_usd` while its `model_tier` is absent. Because `model_tier` is required per the field
table, a well-formed record cannot hit this, but the checklist line does not cross-reference
that dependency, so an S3 Output Validation Checkpoint author implementing the line in
isolation must independently decide whether an absent `model_tier` is a vacuous pass or a
structural fail.

### Evidence

`estimate-record-format.md` L330-345: the line tests "every present
`tokens_by_stage[].cost_usd` whose `model_tier` is a split tier" with no clause for an
absent `model_tier`; the only guard is the separate required-ness of `model_tier` at L30,
which the checklist line does not name.

### Why this matters

The slice's deterministic-parse goal is that an S3 checkpoint author implements exactly one
behaviour from the line as written. A dependency on a separate field's required-ness the line
does not surface is a small residual ambiguity a careful author resolves and a careless one
may not. A parenthetical "(`model_tier` is a required sub-field per §4.x)" closes it.

## O5 — implementation — low

### Claim

The two worked examples model different stage rosters: Example 1 carries four stages
(including code-reviewer at `Most capable`), Example 2 carries three (code-reviewer and
integration dropped, named in Excluded). Each is internally consistent, but the canonical
demonstration of the new per-stage `cost_usd` sub-field lands on a smaller, different stage
set than the cost-omitted example, so a reader cannot read the two as a clean before/after
of the same record gaining bands.

### Evidence

`estimate-record-format.md` Example 1 L426-438 (spec-writer, tdd-agent, implementer,
code-reviewer); Example 2 L492-504 (spec-writer, tdd-agent, implementer only), L536-538
Excluded names code-reviewer and integration as not enumerated.

### Why this matters

The clearest way to teach an optional additive sub-field is the same record with and without
it. The differing rosters make the examples teach two things at once (stage selection AND
per-stage cost), a minor clarity cost on the contract's most-read surface. Not a correctness
defect — both examples validate.

## O6 — risk — low

### Claim

The grounding-path consumer special-case (an aggregator must not count a trailing-slash
directory path as a grounding) is advisory and unenforced, with no checklist line keying on
`grounding_sources[].path` shape. At code time the risk is concrete and not a tail case: the
directory-sentinel path is the day-one default the merged S2 agent emits on every record
(empty `observability/costs/`), so every currently-producible record carries the overloaded
`path`, and any downstream counter that does not special-case the trailing slash miscounts
100% of today's records as snapshot-grounded.

### Evidence

`estimate-record-format.md` L279-285 (consumer special-case) and L296-301 ("advisory/
unenforced ... externalises a silent-miscount risk"). `cost-estimator.agent.md` L282-284:
the agent emits the directory path on the cost-omitted path, today's only producible record.

### Why this matters

The slice consciously accepts this residual, so it is recorded, not re-litigated. The
code-time sharpening is that the overloaded path is the universal case today, not an edge
case — so the first consumer to count groundings without reading the advisory note silently
over-counts every record. The unenforced convention puts the full weight of correctness on
each downstream author reading prose, with no structural backstop. Worth the human noting the
risk is 100%-of-records, not a corner.

## Explicitly not objecting to

- **Version bump correctness**: `plugin.json` (0.43.0), `marketplace.json` (`plugin_version`
  + entry 0.43.0, top-level `version` left at 0.4.0), `README.md` badge (v0.43.0), and the
  `CHANGELOG.md` `## 0.43.0 — 2026-06-11` heading are mutually consistent and match the spec
  §9 / CLAUDE.md minor-bump rule.
- **Example 2 cost arithmetic**: every band re-derives exactly from the two fixed rates
  (sonnet `4.0e-6`, opus `2.0e-5`) — `1.00/2.00`, `0.20/0.60`, `0.40/5.00`, summing to
  `1.60/7.60` — and the split-tier implementer band has the required strict `0.40 < 5.00`
  spread; the numbers are correct.
- **The one-directional coupling vs `iff`**: the field table, §4.1 prose, the checklist
  coupling line, and the backward-compat scenario all consistently state the asymmetric
  (non-biconditional) coupling — the class-B hazard is genuinely closed in the implementation
  text.
- **S2 conformance on `generated_by` and grounding-path**: the merged agent emits
  `cost-estimator / tier:Standard` and the directory path, both admitted by the widened
  description and documented sentinel with zero agent change.
- **The §4.4.1 CAN/CANNOT honesty note**: the reference states plainly that a `{99.0, 100.0}`
  band passes and that absolute-rate falsification defers to S3 — the floor-not-full-widening
  framing is accurate, not over-claimed.
- **Out-of-scope deferrals**: the absence of the S3 command, S4 wiring, and the deferred
  emitter enhancement (#380) is correct for a format-only slice.
