---
component: cost-estimator
component_type: agent
tier: behavioural
fixture: cost-estimator-cost-present
---

# Scenario: the blended-rate skew is surfaced on cost-bearing records, with a precedence rule on conflict (O4/O2/O10)

## Given

A fixture repository with a **populated** `observability/costs/` snapshot whose
Model Breakdown carries the binding table's named model keys, a parseable
`MODEL_ROUTING.md`, and a spec target — so the agent computes a **cost-present**
record (`cost_usd` present, `cost_basis: snapshot-actuals`, `confidence.cost`
present).

The S1 binding collapses input/output token rates into a single blended
$/token (the sanctioned spec-round simplification). On a cost-present record the
agent must **surface** that simplification honestly. This scenario covers spec
§9.9; FR-11, FR-11a (O4/O2/O10). On cost-omitted records the obligation does not
apply (there is no rate to skew).

## When

The cost-estimator agent runs to completion, producing a cost-present record.

## Then

**Blended-rate disclosure (FR-11):**

- The `Confidence rationale` or `Included` section **names that the $/token rate
  is a single blended figure** (input and output rates collapsed), derived from
  the snapshot quarter's mix.
- It **states the figure skews** when the estimated task's input/output ratio
  diverges from the snapshot quarter's.
- The `failure_direction` reasoning **accounts for** the blended-rate skew.
- The agent does **not reintroduce a per-direction rate** (no separate
  input-rate / output-rate figures appear).

**Precedence on conflicting drivers (FR-11a, O10):**

When the fixture configures a cost-present record whose blended-rate skew leans
one direction while the upper-tier-default budgets lean the opposite:

- The prose body **names EVERY driver** bearing on the direction (the
  blended-rate skew **and** the budget-default driver **and** any other), each
  with the direction it pushes.
- The single `failure_direction` enum is set to the **larger-magnitude
  (dominant)** driver — or `symmetric` when the agent judges the opposing drivers
  roughly equal, with the prose naming both as the reason.
- The enum is **never inconsistent with the prose** — it is the dominant driver
  (or `symmetric`), not a coin-flip between conflicting signals.

## Rubric

Layer 3 behavioural, graded by **presence/absence oracles** (spec §8). The oracle
asserts `cost_usd` is **present**; greps the disclosure body for the
blended-rate-skew marker (a "single blended" / "input and output" rate phrase and
a "skews when … diverges" phrase); asserts **no** per-direction rate figures
appear; parses `failure_direction` as a valid enum
(`likely-overrun | likely-underrun | symmetric`); and, on the conflicting-driver
configuration, asserts **more than one driver is named** in the prose and that the
parsed enum value is one the prose names as dominant (or `symmetric` with both
drivers named). The oracle never asserts which exact direction the model judges
nor the exact prose — only that the markers are present, no per-direction rate is
reintroduced, and the enum is consistent with a named driver. The fixture pins the
snapshot mix so a cost-present record is produced deterministically.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

The runner copies the cost-present fixture (populated snapshot with the named
keys), runs a single-agent session, parses the returned record's `cost_usd`,
`failure_direction`, and disclosure body, and applies the marker-presence and
enum-consistency assertions above. No exact direction or rate value is asserted.
