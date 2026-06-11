---
component: cost-estimator
component_type: agent
tier: behavioural
fixture: cost-estimator-spec-target-empty-costs
---

# Scenario: an empty cost snapshot is emitted as a cost-omitted record, NOT refused

## Given

A fixture repository with:

- A valid, readable **spec** target file at a known path.
- A readable `MODEL_ROUTING.md` whose Token Budget Guidance and Agent Routing
  tables parse.
- An **empty** `observability/costs/` directory (today's default — no snapshot
  file).

This is the crucial distinction the spec polices (§5.3): a missing **cost
snapshot** is **not** an ungroundable target. The token grounding is intact, so
the agent emits a valid cost-omitted record rather than refusing. Conflating the
two would make the agent refuse on every estimate in today's repo.

This scenario covers spec §9.6; FR-8, FR-8a. It is the deliberate counterpart to
`refuses-ungroundable-target.md` (§9.5): absent token grounding → REFUSED; absent
cost snapshot → cost-omitted, not refused.

## When

The cost-estimator agent runs to completion.

## Then

- The returned string is a **valid cost-omitted estimate record** — it parses as
  conforming estimate-record frontmatter and **is NOT a `REFUSED:` string** (it
  does not begin with the `REFUSED:` prefix).
- `cost_usd` and `cost_basis` are **absent**, and the `Excluded` section is
  **present** and discloses the cost omission.
- The `grounding_sources` list **still carries the mandatory `cost-snapshot`
  entry**, with its `path` set to the directory `observability/costs/` (no
  snapshot file existed), and the `Excluded` prose notes the directory was read
  and held no snapshot (§5.3, O7).
- The `cost-snapshot` grounding entry is **never dropped** and **never given a
  fabricated snapshot file path**.
- `tokens` and `agent_compute_time` are **present as `{low, high}` ranges**.
- `human_gate_time` is **present** and is **not** a `{low, high}` range (the
  qualitative caveat string). The oracle asserts only presence and non-range
  shape — never the caveat's prose content.
- The `confidence` object carries `tokens` and `time` but **no `cost`** axis.

## Rubric

Layer 3 behavioural, graded by **deterministic oracles** (spec §8): the
`REFUSED:`-prefix oracle asserts the string is **not** a refusal; the conformance
parse asserts the cost-omitted field shape (`cost_usd`/`cost_basis` absent, the
ranges present, `human_gate_time` present-and-not-a-range); the presence/absence
oracle asserts the `cost-snapshot` grounding entry's directory `path` and the
`Excluded` disclosure. The fixture pins an empty `observability/costs/`. The
oracle never asserts token numbers or the caveat's prose — only the omission
shape and the grounding-path convention.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

The runner copies the fixture (readable `MODEL_ROUTING.md`, empty
`observability/costs/`, a spec target), runs a single-agent session, then asserts
the returned string is not a `REFUSED:` string, parses it as a cost-omitted
record, and applies the grounding-path and disclosure assertions above.
