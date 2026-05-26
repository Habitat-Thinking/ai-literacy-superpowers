---
component: carpaccio
component_type: agent
tier: behavioural
fixture: empty-repo
---

# Scenario: carpaccio falls back to acceptance-criterion when decisions are weak

## Given

The agent is invoked with a deliberately vague task description:

> *"Improve the docs page for the install instructions."*

The task has no clear decision boundaries. There is no enumeration,
no choice surface, no obviously material decision.

## When

The carpaccio agent runs to completion.

## Then

The returned content must:

- Have frontmatter with `inseparable: false`
- Have `slices` array length ≥ 1 and ≤ 9
- At least one slice's `lens_used` is `acceptance-criterion`
- No slice has `lens_used: decision-boundary` (or, if any
  do, the prose makes clear why those count as material
  decisions)

## Rubric

- *Does the agent fall back cleanly rather than fabricating
  decision boundaries?* The slices should describe
  acceptance criteria the engineer could test (e.g., "the
  page renders correctly on mobile", "the install command
  is copyable").
- *Did the agent avoid the trap of slicing on file
  boundaries?* "Slicing on files" should appear in
  `## Explicitly not slicing on`.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

Same runner shape as `multi-decision-task.md`.
