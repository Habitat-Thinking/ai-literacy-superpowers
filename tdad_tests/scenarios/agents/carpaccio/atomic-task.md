---
component: carpaccio
component_type: agent
tier: behavioural
fixture: empty-repo
---

# Scenario: carpaccio produces a defended single-slice record for an atomic task

## Given

The agent is invoked with a task description that names an
atomic operation:

> *"Rotate the leaked Honeycomb API token: revoke the existing
> token, generate a replacement, update the secret in the
> deployment pipeline, and audit access logs from the past 24h
> for unauthorised use. All four steps must land together."*

## When

The carpaccio agent runs to completion.

## Then

The returned content must:

- Have frontmatter with `inseparable: true`
- Have `slices` array length exactly `1`
- The single slice has `lens_used: inseparability`
- The prose body contains an `## Inseparability rationale`
  section
- The rationale section is at least three sentences long
- Has every slice's `disposition: pending`
- Contains a `## Explicitly not slicing on` section with
  ≥ 3 entries

## Rubric

- *Does the rationale defend inseparability rather than
  assert it?* The agent must explain *why* slicing would
  harm correctness (e.g., a partially-rotated credential is
  worse than an unrotated one), not just claim it cannot be
  sliced.
- *Did the agent consider alternatives before declaring
  atomicity?* The "Explicitly not slicing on" section should
  reveal what slicing dimensions were considered.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

Same runner shape as `multi-decision-task.md`.
