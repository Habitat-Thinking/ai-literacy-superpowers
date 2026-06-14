---
name: per-stage-cost-bands-emitter
description: Spec for the cost-estimator emitter honouring the #377 §4.3.1 SHOULD obligation — populating per-stage tokens_by_stage[].cost_usd bands on cost-present records now that a usable cost snapshot exists
date: 2026-06-14
status: draft
---

# Cost-estimator — Per-stage `cost_usd` Bands on Cost-present Records

## Problem

The #377 format revision
(`docs/superpowers/specs/2026-06-11-format-revision-per-stage-cost-design.md`)
**admits** an optional `tokens_by_stage[].cost_usd` `{ low, high }` band on
cost-present records, one-directionally coupled to the top-level `cost_usd`
(sub-field present ⟹ top-level present is *enforced*; top-level present ⟹ bands
**SHOULD** be populated is an *emitter obligation*, not a validation-rejection
rule — §4.3.1). When #377 landed, **no producer populated the bands**: the only
cost-present record carrying them was the hand-authored Example 2, and the
`cost-estimator` agent's charter explicitly deferred them —

> "You emit **no** machine-checkable per-stage cost band (that is a separate
> slice's deliverable); the widening lives in the whole-record band and the
> prose."

That deferral was correct at the time: the agent could only emit **cost-omitted**
records, because `observability/costs/` was empty, so there was no rate to price a
per-stage band against. **That precondition is now met.** The repo's first cost
snapshot landed (`observability/costs/2026-06-13-costs.md`, PR #391) and carries a
usable `## Model Breakdown`, so the agent can now emit **cost-present** records
(S1 grounding state 3). This slice is the **falsifiable home** for the §4.3.1
SHOULD obligation (issue #380).

This is **implementation of an already-designed obligation**, not new design. The
per-stage band *pricing convention* is fully specified in the format reference's
**"Per-stage band pricing convention (emitter methodology, NOT a checked
invariant)"** and **"Deriving a per-model rate from a snapshot"** sections
(`skills/cost-estimation/references/estimate-record-format.md` §216, §229). This
spec only makes the emitter honour it.

## Approach

Flip the `cost-estimator` agent's per-stage-band deferral into an **emit
obligation on cost-present records**, and add the same obligation to the S1
`cost-estimation` skill methodology (so the agent inherits it rather than
re-deriving). The derivation is the one the format reference already defines:

- On a **cost-present** record (grounding state 3 — a usable snapshot Model
  Breakdown exists), for **every exercised stage**, emit a
  `tokens_by_stage[].cost_usd` `{ low, high }` band = that stage's `tokens`
  range × its tier's `$/token` rate from the snapshot.
- A **split-tier** stage (e.g. the implementer's `Standard/Capable`) prices its
  **low** bound at the **cheaper** representative model (`claude-sonnet-4`) and
  its **high** bound at the **dearer** one (`claude-opus-4`), per the binding
  table — producing a genuine, strictly-positive spread (`low < high`).
- On a **cost-omitted** record (states 1 and 2 — no usable snapshot rate), **no**
  stage carries a per-stage `cost_usd`; the sub-field is absent everywhere,
  exactly as today. The one-directional coupling is preserved: a per-stage band
  never appears without the top-level `cost_usd`.

No format change is required — the format already admits the band. No new
validation-rejection rule is introduced — absence of bands on a cost-present
record remains valid (the obligation is a SHOULD, and the only checked predicate
on a *present* split-tier band is `low < high`, already in the #377 checklist).

## Acceptance Scenarios

### Scenario A — Cost-present record carries per-stage bands

**Given** a fixture repository with a populated `observability/costs/` snapshot
whose Model Breakdown carries the binding table's named model keys, a parseable
`MODEL_ROUTING.md`, and a target the agent classifies,
**When** the `cost-estimator` agent runs to completion and produces a
**cost-present** record (`cost_usd` present, `cost_basis: snapshot-actuals`),
**Then** **every exercised stage** in `tokens_by_stage[]` carries a
`cost_usd` `{ low, high }` band, and the split-tier stage's band has a
**strictly-positive ordered spread** (`low < high`); and the one-directional
coupling holds (no per-stage band exists without the top-level `cost_usd`).

### Scenario B — Cost-omitted record carries no per-stage bands (unchanged)

**Given** a fixture with an empty `observability/costs/` (or a snapshot with no
usable Model Breakdown),
**When** the agent runs and produces a **cost-omitted** record,
**Then** no stage carries a `cost_usd` sub-field, the top-level `cost_usd` is
absent, and the omission is disclosed in `Excluded` — exactly as before this
slice.

### Scenario C — Emitter convention, not a new validator

**Given** the agent definition and the cost-estimation skill,
**When** their charters are read,
**Then** they instruct the emitter to populate per-stage bands on cost-present
records by reference to the format's per-stage band pricing convention (they do
**not** redefine it), and they do **not** introduce a new validation-rejection
rule (absence of bands on a cost-present record stays valid; the only checked
predicate on a present split-tier band remains `low < high`).

## Functional Requirements

- **FR-001** On a **cost-present** record (grounding state 3), the
  `cost-estimator` emitter SHALL populate a `tokens_by_stage[].cost_usd`
  `{ low, high }` band on **every exercised stage**.
- **FR-002** A **split-tier** stage's per-stage band SHALL price `low` at the
  cheaper representative model and `high` at the dearer one (per the binding
  table), yielding `low < high`.
- **FR-003** The emitter SHALL preserve the one-directional coupling: a
  per-stage `cost_usd` SHALL NOT appear on a **cost-omitted** record, and the
  sub-field SHALL be absent on every stage when the top-level `cost_usd` is
  absent.
- **FR-004** The agent and the S1 `cost-estimation` skill SHALL express this
  obligation **by reference** to the format reference's per-stage band pricing
  convention and rate-derivation sections — they SHALL NOT redefine the pricing
  convention or introduce a new validation-rejection rule.
- **FR-005** No change SHALL be made to `estimate-record-format.md` (the format
  already admits the band) nor to the #377 validation checklist (the
  `low < high` split-tier predicate already covers a present band).

## Expected Outcome

The cost-estimator's cost-present records become a machine-readable per-stage
cost decomposition: each stage's dollar contribution is visible, and the
split-tier widening that dominates the whole-record figure is traceable to the
implementer stage rather than buried in prose. The §4.3.1 SHOULD obligation —
honestly "admitted but unpopulated" at #377 — now has a producer and a
falsifiable Layer 3 scenario.

## Artefacts

1. `agents/cost-estimator.agent.md` — flip the per-stage-band deferral into an
   emit obligation on cost-present records (FR-001 – FR-004).
2. `skills/cost-estimation/SKILL.md` — add the per-stage band emission step to
   the cost-derivation methodology, by reference to the format convention
   (FR-001, FR-004).
3. `tdad_tests/scenarios/agents/cost-estimator/per-stage-cost-bands.md` — a
   Layer 3 behavioural scenario for Scenario A (the falsifiable home #380 asks
   for), reusing the `cost-estimator-cost-present` fixture.
4. `README.md`, `plugin.json`, `marketplace.json`, `CHANGELOG.md` — version
   0.49.0 (behaviour change to a shipped agent — minor bump). No component-count
   change.

## Exemptions

None. This is a behaviour change to a shipped agent and carries its own spec
(this file) as the first commit. The design lineage is #377 §4.3.1 / §216;
no new design decisions are introduced beyond honouring that obligation.
