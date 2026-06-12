---
component: cost-estimate
component_type: command
tier: behavioural
fixture: cost-estimate-spec-target-empty-costs
---

# Scenario: the human disposition precedes the single Write (the ordering invariant) (runnable-today)

## Given

A fixture repository with a valid, readable **spec** target, a readable
`MODEL_ROUTING.md` whose tables parse, an **empty** `observability/costs/`, and
no pre-existing `cost-estimates/` directory.

The command is run against the spec target and reaches the disposition step. This
scenario exercises the dispose-then-write ordering invariant on both an `abort`
and an `accept` path.

**Runnable-today** — cost-omitted record from an empty `observability/costs/`
(spec §10.2; FR-8, FR-9, FR-12).

## When

The command dispatches the agent, validates the returned record, shows the review
summary, and reaches the disposition prompt.

## Then

The **file-existence oracle** asserts, across the disposition paths:

- **At the disposition step, no file has been written yet** — nothing exists
  under `cost-estimates/` (or the resolved output dir) before the human responds.
- The review summary **shows the resolved output path** (so the human confirms
  both content and destination before any write).
- The summary offers the **full disposition vocabulary** — `accept` / `edit` /
  `re-run` / `abort`.
- On **`abort`**: **no file is written**.
- On **`accept`** (the alternate run on the same fixture): **exactly one Write**
  occurs, to the resolved output path, **after** the disposition.

## Rubric

Layer 3 behavioural, graded by the **file-existence oracle** (no-file-before-the-
disposition; no-file-on-abort; exactly-one-file-on-accept at the resolved path),
per spec §9. The fixture pins the grounding so the input is deterministic even
though the dispatch is not. The oracle never asserts the summary's prose — only
the on-disk state at each step and the presence of the resolved path in the
summary.

## Cleanup

Remove the temporary fixture repository (including any written
`cost-estimates/` directory).

## Implementation note

The runner drives the command twice against the same fixture — once choosing
`abort`, once choosing `accept` — and asserts no file exists at the disposition
step in both, no file after `abort`, and exactly one file at the resolved path
after `accept`.
