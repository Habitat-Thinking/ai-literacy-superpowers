---
component: cost-estimate
component_type: command
tier: behavioural
fixture: cost-estimate-spec-target-empty-costs
---

# Scenario: an empty cost snapshot produces a written cost-omitted record, not a refusal (runnable-today)

## Given

A fixture repository with a valid, readable **spec** target, a readable
`MODEL_ROUTING.md` whose tables parse, and an **empty** `observability/costs/`
directory (today's default — no snapshot file). No pre-existing `cost-estimates/`
directory. The human responds **`accept`**.

This is the crucial distinction the spec polices (§5.2): a missing **cost
snapshot** is **not** an ungroundable target — the token grounding is intact, so
the command writes a valid cost-omitted record rather than treating it as a
failure.

**Runnable-today** — exercised by a real grounding read against today's empty
`observability/costs/` (spec §10.5; FR-13, FR-14).

## When

The command dispatches the agent, validates the returned cost-omitted record,
summarises it, and the human responds `accept`.

## Then

The **conformance oracle** and the **trailing-slash-summary oracle** assert:

- A **cost-omitted** record is written (NOT a refusal) at the default resolved
  path `cost-estimates/<YYYY-MM-DD>-<target-slug>-estimate.md`.
- The record's `grounding_sources` list carries a `cost-snapshot` entry whose
  `path` is the **directory** `observability/costs/` (with a **trailing slash**;
  no snapshot file existed).
- The **review summary reports that entry as "no snapshot — cost omitted
  (directory inspected, no snapshot found)"**, **not** as a snapshot grounding —
  the command honours the trailing-slash special-case in its **own** summary
  consumption (it adds no validation-checklist line keying on
  `grounding_sources[].path` shape).
- The written record carries the **unguarded trailing-slash sentinel** — no
  checklist line keys on it (the recorded O7 residual: any other consumer that
  does not apply the same trailing-slash test will silently miscount).
- `cost_usd` and `cost_basis` are **absent**, the omission disclosed in
  `Excluded`.
- `tokens` and `agent_compute_time` are **present as `{low, high}` ranges**, and
  `human_gate_time` is **present and not a range** (the qualitative caveat
  string — presence and non-range shape only, never the prose).

## Rubric

Layer 3 behavioural, graded by the **conformance oracle** (cost-omitted field
shape: `cost_usd`/`cost_basis` absent, ranges present, `human_gate_time`
present-and-not-a-range) and the **trailing-slash-summary oracle** (the
trailing-slash `cost-snapshot` entry is reported as "no snapshot", not a
grounding), per spec §9. The empty `observability/costs/` is fixture-pinned. The
oracle never asserts token numbers or the caveat's prose — only the omission
shape and the trailing-slash summary reporting.

## Cleanup

Remove the temporary fixture repository (including any written
`cost-estimates/` directory).

## Implementation note

The runner copies the fixture (readable `MODEL_ROUTING.md`, empty
`observability/costs/`, a spec target), drives an `accept` disposition, asserts
the written record is cost-omitted and conforming, that the `cost-snapshot`
grounding entry's directory `path` is preserved with its trailing slash, and that
the review summary reports it as "no snapshot" rather than a grounding.
