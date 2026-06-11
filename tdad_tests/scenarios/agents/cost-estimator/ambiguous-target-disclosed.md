---
component: cost-estimator
component_type: agent
tier: behavioural
fixture: cost-estimator-ambiguous-target
---

# Scenario: an ambiguous target is resolved conservatively and disclosed, never silently up-classified

## Given

A fixture repository with a readable, parseable `MODEL_ROUTING.md` and a target
file at a known path whose shape matches **neither a clear slicing record nor a
clear spec** — it has signals that could place it in either of two candidate
kinds — dispatched with **no stated kind**.

The target is still **classifiable** (it is not unreadable or shapeless — that
would be a refusal, §9.5). The ambiguity is between two candidate `target_kind`
values of differing grounding ceiling.

This scenario covers spec §9.4; FR-6.

## When

The cost-estimator agent runs to completion.

## Then

- `target_kind` is the **lower-grounding** candidate kind of the two (the
  conservative choice — a lower ceiling cannot over-claim confidence).
- The `Confidence rationale` section **discloses the classification ambiguity**
  (a greppable marker noting the target could be read as either candidate).
- The `tokens`/`time` confidence axes **do not exceed the lower candidate's
  ceiling** (the parsed enum value is at or below that ceiling).

## Rubric

Layer 3 behavioural, graded by **deterministic oracles** (spec §8). The oracle
parses `target_kind` and asserts it is the lower-grounding candidate; parses
`confidence.tokens`/`confidence.time` and asserts they do not exceed that
candidate's ceiling; and greps `Confidence rationale` for an ambiguity-disclosure
marker. The fixture pins a target whose two candidate kinds have a known
grounding ordering, so "lower-grounding" is deterministic. The oracle never
asserts the exact disclosure wording — only that the conservative kind was chosen
and the ambiguity is disclosed.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

The runner runs a single-agent session against the pinned ambiguous target with
no stated kind, then parses the returned record's `target_kind` and confidence
axes and greps `Confidence rationale` for the ambiguity disclosure.
