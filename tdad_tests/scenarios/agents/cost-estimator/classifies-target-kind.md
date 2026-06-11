---
component: cost-estimator
component_type: agent
tier: behavioural
fixture: cost-estimator-target-shapes
---

# Scenario: cost-estimator classifies target_kind and honours the S1 confidence ceiling

## Given

A fixture repository with a readable, parseable `MODEL_ROUTING.md` and three
target shapes the agent can be dispatched against **with no stated kind**:

- Raw **inline task text** supplied in the dispatch (no path, no stated kind).
- A **carpaccio slicing-record** file (carpaccio frontmatter with a `slices:`
  array) at a known path.
- A **design spec** file (a spec header table, numbered `## N.` sections, a
  Gherkin acceptance-scenario block) at a known path.

The classification is load-bearing because it sets the S1 confidence **ceiling**
for the `tokens`/`time` axes (spec §4.2). This scenario covers spec §9.3; FR-4,
FR-5, FR-6a.

## When

The cost-estimator agent runs to completion against each target shape in turn.

## Then

**Task-text dispatch** (inline prose, no path, no stated kind):

- `target_kind` is `task-text`.
- The `tokens` and `time` confidence axes are **capped at `low`** (the parsed
  enum value is `low`).
- Because the kind was **inferred** (the task-text default), `Confidence
  rationale` carries an **inference-basis line** naming the signal it classified
  on (e.g. of the form "classified as `task-text` by `<signal>`").

**Slicing-record dispatch** (carpaccio record path, no stated kind):

- `target_kind` is `slicing-record`.
- The `tokens` and `time` confidence axes do **not exceed `medium`**.
- Because the kind was **inferred**, `Confidence rationale` carries an
  inference-basis line naming the slicing-record signal it matched on.

**Spec dispatch** (spec file path, no stated kind):

- `target_kind` is `spec`.
- The `tokens` and `time` confidence axes **may reach `high`** (the spec ceiling),
  but the parsed value never exceeds `high`.
- Because the kind was **inferred**, `Confidence rationale` carries an
  inference-basis line naming the spec signal it matched on — so a confident
  mis-read that up-classifies the ceiling is human-catchable.

## Rubric

Layer 3 behavioural, graded by **deterministic oracles** (spec §8). For each
dispatch the oracle parses `target_kind` from the frontmatter, parses the
`confidence.tokens` and `confidence.time` enum values and asserts they do not
exceed the kind's ceiling, and **greps the `Confidence rationale` body for an
inference-basis line** (the presence of a "classified as `<kind>` by" marker).
The grounding inputs are fixture-pinned. The oracle never asserts the specific
signal wording — only that `target_kind`, the ceiling, and the
inference-basis-line presence are correct. The exact token numbers are out of
grading scope.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

The runner runs three single-agent sessions (one per target shape) with the
cost-estimator's frontmatter as system prompt and tools list, each with no
stated kind, then parses each returned record and applies the per-shape oracle
assertions above.
