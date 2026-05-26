---
component: carpaccio
component_type: agent
tier: behavioural
fixture: empty-repo
---

# Scenario: carpaccio re-dispatch on revised disposition

## Given

The agent is invoked with:

- A task description identical to `multi-decision-task.md`
- A prior slicing record in which two slices were marked
  `disposition: revised` with rationale strings:
  - *"The two indexing slices should be one — they cover
    the same code path."*
  - *"The relevance ranking is a separate concern that
    should land later, not in this iteration."*

## When

The carpaccio agent runs to completion (re-dispatch).

## Then

The returned content must:

- Be a fresh slicing record (the prior one is overwritten
  by the orchestrator, not the agent — the agent just
  returns new content)
- Show evidence the rationale was applied:
  - Fewer slices than the prior record (the two
    indexing slices have been merged or one is renamed
    to cover both)
  - The relevance-ranking work has been deferred (no
    slice covers it, OR it appears as a separate
    deferred slice that the orchestrator could file as
    a follow-up issue)
- Every slice ships with `disposition: pending` (the
  agent never preserves prior dispositions across
  dispatches — this matches the diaboli/cartographer
  pattern)

## Rubric

- *Did the agent treat the rationale as instruction or
  just noise?* The new slicing should observably reflect
  the rationale, not just regenerate from scratch.
- *Did the agent over-correct?* It is acceptable for the
  agent to push back in its slicing decisions (e.g.,
  argue the two indexing slices really are distinct) by
  emitting the same shape — but the prose must
  acknowledge the rationale, not silently ignore it.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

Same runner shape as `multi-decision-task.md`, except the
user message includes both the original task and a
serialised representation of the prior slicing record
with the two `revised` rationale strings.
