---
component: cost-estimator
component_type: agent
tier: behavioural
fixture: cost-estimator-inference-target
---

# Scenario: an inferred classification discloses its basis; an explicit one does not (O6)

## Given

A fixture repository with a readable, parseable `MODEL_ROUTING.md` and a single
target file at a known path whose frontmatter/structure the agent will read as a
particular `target_kind` (a single-shape match the agent is confident about, but
which could be wrong). This is the confident-mis-read case O6 exists to catch:
without disclosure, a confident wrong single-match silently up-classifies the
confidence ceiling.

This scenario covers spec §9.7; FR-6a (O6).

## When

The cost-estimator agent runs to completion twice against the **same** target
path: once **with no stated kind** (inference path), and once **with
`target_kind` stated explicitly** in the dispatch.

## Then

**No-stated-kind dispatch (inferred):**

- `target_kind` in the emitted record is the agent's **inferred** kind.
- `Confidence rationale` carries an **inference-basis line of the form
  "classified as `<kind>` by `<signal>`"**, naming the concrete signal — the
  greppable marker is **present**.
- The line is present **even though the agent detected no ambiguity** (a
  confident single-match still discloses its basis), so a confident wrong
  classification is human-catchable.

**Explicit-kind dispatch:**

- `target_kind` in the emitted record is the **stated** kind.
- **No inference-basis line is present** in `Confidence rationale` — the kind was
  supplied by the dispatcher, not derived by the agent, so there is no inference
  to expose. The "classified as `<kind>` by" marker is **absent**.

## Rubric

Layer 3 behavioural, graded by a **presence/absence oracle** (spec §8). The
oracle greps the `Confidence rationale` body for the "classified as `<kind>` by"
inference-basis marker: it must be **present** on the inferred dispatch and
**absent** on the explicit dispatch. The grounding inputs and the target path are
fixture-pinned and identical across both runs, so the only varying input is
whether the dispatch states the kind. The oracle never asserts the specific
signal text — only the presence/absence of the inference-basis line.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

The runner runs two single-agent sessions against the same pinned target path —
one omitting `target_kind`, one stating it — then greps each returned record's
`Confidence rationale` for the inference-basis marker and asserts present-then-
absent.
