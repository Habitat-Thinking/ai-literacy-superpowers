---
component: cost-estimate
component_type: command
tier: behavioural
fixture: cost-estimate-spec-target-empty-costs
---

# Scenario: /cost-estimate writes a conforming cost-omitted record on accept (runnable-today)

## Given

A fixture repository containing:

- A real **design spec** target file (a spec header table, numbered `## N.`
  sections, and a Gherkin acceptance-scenario block) at a known path.
- A readable `MODEL_ROUTING.md` whose **Token Budget Guidance** and **Agent
  Routing** tables parse, and which carries a `cost-estimator` routing row.
- An **empty** `observability/costs/` directory (today's default — no snapshot
  file present).
- No pre-existing `cost-estimates/` directory.

The command is run against the spec target. The human responds **`accept`** at
the disposition step.

**Runnable-today** — exercised by a real grounding read on today's repo; an empty
`observability/costs/` yields a cost-omitted record (spec §10.1; FR-9, FR-10,
FR-13).

## When

The command dispatches the agent, validates the returned record, summarises it,
and the human responds `accept`.

## Then

The **deterministic oracles** assert:

- **Exactly one file** is written, at the default resolved path
  `cost-estimates/<YYYY-MM-DD>-<target-slug>-estimate.md` — a top-level
  directory, **outside** `observability/` (the command created the directory).
- The written record's **frontmatter conforms to the S1 estimate-record field
  set** — parsed, not read loosely: required fields present, every enum in range,
  every present `{low, high}` range has `low ≤ high`, and the four disclosure
  sections (Included, Excluded, Confidence rationale, Failure direction) are
  present.
- `cost_usd` and `cost_basis` are **absent**, and the omission is disclosed in
  the `Excluded` section.
- The written record contains **no** `recommendation`, `verdict`, or `proceed`
  field in the frontmatter.
- The command **confirms the full written path** to the human.

## Rubric

Layer 3 behavioural, graded by the **file-existence + path oracle** (one file at
the resolved `cost-estimates/` path) and the **conformance oracle** (frontmatter
parse against the S1 field set), per spec §9. The grounding inputs are
fixture-pinned so the input is deterministic even though the `model: inherit`
dispatch is not. No LLM-as-judge is used; the exact token figures and exact
disclosure wording are out of grading scope.

## Cleanup

Remove the temporary fixture repository (including any written
`cost-estimates/` directory).

## Implementation note

The runner copies the fixture to a temp directory, runs the command's flow
driving an `accept` disposition, then asserts a single file exists at the
default `cost-estimates/` resolved path, parses its frontmatter for S1
conformance, and checks the cost-omitted shape and the path-confirmation.
