---
component: cost-estimate
component_type: command
tier: behavioural
fixture: cost-estimate-rerun-snapshot-added
---

# Scenario: re-run re-dispatches and re-reads a newly-added snapshot (O8) (synthetic cost-present)

## Given

A fixture repository where the command has first produced a **cost-omitted**
record (`observability/costs/` was empty at first dispatch). Before disposing,
the human **adds a usable cost snapshot** to `observability/costs/`, then responds
**`re-run`**.

This is a **synthetic cost-present fixture** — it pins a snapshot world the
command's first real grounding could not produce (today's repo ships an empty
`observability/costs/`), so the added snapshot is hand-pinned to exercise the
re-run-re-reads behaviour, not produced by a grounded emit on today's repo (spec
§10.6b; FR-8b).

## When

The human responds `re-run` after adding the snapshot.

## Then

The **re-dispatch-re-reads oracle** asserts:

- The command **re-dispatches the agent on the same target** (a full fresh
  dispatch, not a reuse of cached grounding).
- The re-dispatch **re-reads the grounding sources afresh, including the
  now-populated `observability/costs/`**.
- The re-validated, re-summarised record **can now carry `cost_usd` grounded in
  the added snapshot** (the cost-present record the first dispatch could not
  produce).

## Rubric

Layer 3 behavioural, graded by the **re-dispatch-re-reads oracle** (spec §9): the
first dispatch (empty `observability/costs/`) yields a cost-omitted record; after
a fixture-pinned snapshot is added and `re-run` is chosen, the re-summarised
record is **cost-present** — the grounding was re-read, not cached. The snapshot
add is fixture-pinned. The oracle never asserts exact cost numbers — only the
cost-omitted → cost-present transition across the re-run.

## Cleanup

Remove the temporary fixture repository (including any written
`cost-estimates/` directory).

## Implementation note

The runner drives the command to a first cost-omitted summary, injects a usable
snapshot into the fixture's `observability/costs/`, drives a `re-run`, and asserts
the re-summarised record can carry a `cost_usd` grounded in the added snapshot —
confirming the re-dispatch re-read the now-populated directory.
