---
component: carpaccio
component_type: agent
tier: behavioural
fixture: empty-repo
---

# Scenario: carpaccio sequences mixed-independence work

## Given

The agent is invoked with a task description containing both
independent and sequential sub-work:

> *"Add observability to the checkout flow. Three pieces:
> (a) emit a span per checkout step (requires nothing); (b) add
> a Honeycomb board (requires the spans to exist); (c) write a
> runbook explaining the new spans (requires both the spans
> and the board)."*

## When

The carpaccio agent runs to completion.

## Then

The returned content must:

- Have frontmatter with `inseparable: false`
- Have `slices` array length between 2 and 9
- Have at least one slice with `lens_used: independence`
- The `## Sequencing recommendation` section describes a
  concrete order, not "any order"
- Each slice's `sequencing_note` is consistent with the
  recommendation

## Rubric

- *Does the sequencing match the dependency graph?* Slice
  emitting spans should precede the board; the runbook
  should be last.
- *Are dependencies explicit?* Each slice's "Dependencies"
  prose subsection should name what must land first.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

Same runner shape as `multi-decision-task.md`.
