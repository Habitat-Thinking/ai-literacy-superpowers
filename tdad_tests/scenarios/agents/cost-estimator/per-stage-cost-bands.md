---
component: cost-estimator
component_type: agent
tier: behavioural
fixture: cost-estimator-cost-present
---

# Scenario: per-stage cost_usd bands are populated on cost-present records (#380)

## Given

A fixture repository with a **populated** `observability/costs/` snapshot whose
Model Breakdown carries the binding table's named model keys, a parseable
`MODEL_ROUTING.md`, and a target the agent classifies — so the agent computes a
**cost-present** record (`cost_usd` present, `cost_basis: snapshot-actuals`).

This scenario is the falsifiable home for the #377 §4.3.1 SHOULD obligation
(issue #380, spec
`docs/superpowers/specs/2026-06-14-per-stage-cost-bands-emitter-design.md`;
FR-001 – FR-003): now that a usable snapshot exists, the emitter must populate
per-stage `cost_usd` bands. On cost-omitted records the obligation does not
apply (there is no rate to price a band).

## When

The cost-estimator agent runs to completion, producing a cost-present record.

## Then

**Per-stage bands present (FR-001):**

- **Every exercised stage** in `tokens_by_stage[]` carries a `cost_usd`
  `{ low, high }` band (every stage that has a `tokens` band also has a
  `cost_usd` band).
- Each per-stage band is a well-formed two-key range with `low ≤ high`.

**Split-tier strict spread (FR-002):**

- The split-tier stage (the implementer, `model_tier` matching
  `Standard/Capable` whitespace-insensitively) has a **strictly-positive ordered
  spread**: `low < high` (the cheaper-model low bound is strictly below the
  dearer-model high bound).

**One-directional coupling preserved (FR-003):**

- No per-stage `cost_usd` band appears unless the top-level `cost_usd` is also
  present (here it is). The runner's cost-omitted scenarios
  (`emits-conforming-record`, `empty-snapshot-not-refused`) cover the converse —
  that no band appears on a cost-omitted record.

## Rubric

Layer 3 behavioural, graded by **presence/absence + ordering oracles** (no exact
dollar values asserted, since those live in the snapshot, not the record). The
oracle asserts `cost_usd` is present; that every `tokens_by_stage[]` entry with a
`tokens` band also carries a `cost_usd` band; that each present band satisfies
`low ≤ high`; and that the split-tier stage's band satisfies `low < high`. It
never asserts the absolute rate or which bound binds to which model (that is an
emitter convention the record cannot expose). The fixture pins the snapshot mix
so a cost-present record is produced deterministically.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

Reuses the `cost-estimator-cost-present` fixture (populated snapshot with the
binding table's named keys) shared with `blended-rate-skew-surfaced.md`. The
runner copies the fixture, runs a single-agent session, parses the returned
record's `tokens_by_stage[]`, and applies the presence and `low < high`
assertions above.
