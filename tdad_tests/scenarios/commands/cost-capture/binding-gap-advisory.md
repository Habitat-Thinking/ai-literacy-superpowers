---
component: cost-capture
component_type: command
tier: structural
---

# Scenario: cost-capture reports cost-estimate grounding at capture time as an informational, non-gating advisory backed by a structured Observations line

## Given

The binding-gap-warning slice (#413, spec
`docs/superpowers/specs/2026-06-15-cost-capture-binding-gap-warning-design.md`)
gives `/cost-capture` a capture-time advisory: after writing and validating a
snapshot, it tells the human whether the prospective `cost-estimation` sibling
will **ground**, **proxy**, or **omit** cost against it, and records the outcome
as a `Cost-estimate grounding:` line in the snapshot's `## Observations`. This
closes the binding-gap feedback loop (the #411 silent-feedback latency) one step
earlier — at capture, where the human can act.

This is a **structural** scenario: it asserts the **command-file text** and the
**cost-tracking snapshot-format text**, not the output of a live capture run
(behavioural verification is API-gated and out of scope here).

## When

`ai-literacy-superpowers/commands/cost-capture.md` and
`ai-literacy-superpowers/skills/cost-tracking/SKILL.md` are read as the contract.

## Then

**The advisory is informational, never a gate (diaboli O5):**

- The command documents an advisory step that **emits no pass/fail token**,
  **never modifies the snapshot's cost data**, and **runs regardless of the
  step-10 validation result** — explicitly distinct from the mandatory
  structural validation checkpoint.

**It is a family-presence check, not a pricing re-run (diaboli O2):**

- The command resolves Model Breakdown keys by the **family-stem + delimiter
  rule referenced from the binding table**
  (`skills/cost-estimation/references/estimate-record-format.md`) to detect
  **which estimating-tier families** (`claude-opus-4` / `claude-sonnet-4`) are
  present. It explicitly does **not** compute rates, aggregate families, or
  select a proxy source — those stay estimator-only.

**The four outcomes are total (diaboli O1) and conditionally worded (O3):**

- `grounds` (both families present);
- `proxied (<absent tier(s)>)` (one family present) — worded **conditionally**:
  estimates that *exercise* the absent tier are proxied; others ground directly;
- `omitted (no estimating-tier family)` (a Model Breakdown exists but neither
  family is present — e.g. haiku-only) — the unconditional "will omit";
- `omitted (no per-model breakdown)` (no Model Breakdown recorded — the
  structural state-1/2 case, distinct from the family-mismatch case).

**The outcome is a structured, checkable artefact (diaboli O7):**

- The command writes a `Cost-estimate grounding:` line into the snapshot's
  `## Observations`, and the `cost-tracking` snapshot format documents that line
  with the four legal values. It is also echoed in the capture summary.

**Honesty (diaboli O8) and no issue-number leak (diaboli O4):**

- The advisory distinguishes *thin because data was not recorded* (actionable)
  from *thin because the period genuinely used only some tiers* (not a defect),
  and **never** nudges adding a model row for spend that did not occur.
- The advisory text carries **no** GitHub issue number (it names the action —
  "the binding stem table needs updating" — not "#414").

**The cost-tracking SKILL pointer is scoped (diaboli O10):**

- The SKILL notes estimating-tier coverage drives prospective grounding **and**
  annotates that a non-estimating-family row (e.g. haiku) is a valid breakdown
  entry that does not by itself ground cost.

## Rubric

Layer 1 structural. Every assertion is verifiable by reading
`commands/cost-capture.md` (the advisory step, its non-gating constraints, the
family-presence scoping, the four outcomes, the conditional wording, the
honesty note, the absence of an issue number) and `skills/cost-tracking/SKILL.md`
(the `Cost-estimate grounding:` Observations line with four values, the
estimating-tier-coverage pointer, the haiku annotation) — not by running a
capture.

The scenario **passes** only when the advisory is documented as informational
(no pass/fail, no snapshot mutation, runs regardless of validation), as a
presence check (not a pricing re-run), with all four totalled outcomes,
conditional proxy wording, the structured `Cost-estimate grounding:` Observations
line, the no-fabrication honesty note, and no issue number in the advisory text.

The scenario **fails** if a future edit turns the advisory into a gate (pass/fail
or snapshot mutation), has it re-implement rate/aggregation/proxy pricing, drops
the no-per-model-data outcome, states proxy/omission unconditionally where the
estimator's outcome depends on the exercised tier, removes the structured
Observations line, nudges fabricated rows, or bakes a GitHub issue number into
the user-facing advisory.

## Notes

Scope is #413 only. #413 is a pure consumer of the v0.50.0 family-stem rule (#411
/ #412) — it adds no binding, proxy logic, rate maths, or format field. The
stem-table maintenance the no-estimating-family advisory points at (for a model
generation the stems don't yet know) is the sibling follow-on #414.
