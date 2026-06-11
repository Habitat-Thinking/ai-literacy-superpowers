---
component: cost-estimator
component_type: agent
tier: behavioural
fixture: cost-estimator-spec-target-empty-costs
---

# Scenario: cost-estimator emits a conforming estimate record against a real target

## Given

A fixture repository containing:

- A real **design spec** target file (a spec header table, numbered `## N.`
  sections, and a Gherkin acceptance-scenario block) at a known path.
- A readable `MODEL_ROUTING.md` whose **Token Budget Guidance** and **Agent
  Routing** tables parse, and which carries a `cost-estimator` Standard-tier row.
- An **empty** `observability/costs/` directory (today's default — no snapshot
  file present).

The agent is dispatched against the spec target with `target_kind` stated
**explicitly** in the dispatch as `spec`, and **no resolved model id** supplied
in the dispatch context.

This scenario covers spec §9.2; FR-3, FR-8, FR-8a, FR-8b, FR-12.

## When

The cost-estimator agent runs to completion.

## Then

The agent returns a markdown string with YAML frontmatter and a four-part prose
body. The **deterministic oracle parses the frontmatter** (it does not read it
loosely) and asserts:

- The frontmatter **conforms to the S1 estimate-record field set** — the
  required fields are present, every enum value is in range, and every present
  `{low, high}` range has `low ≤ high`.
- `target_kind` is `spec`, and the `tokens`/`time` confidence axes are **within
  the spec ceiling** (at most `high`).
- `cost_usd` and `cost_basis` are **absent** (no snapshot), and the `Excluded`
  section is **present** and names the cost omission.
- The `grounding_sources` list carries a `cost-snapshot` entry whose `path` is
  the directory `observability/costs/` (with a trailing slash; no snapshot file
  existed) — the entry is **present**, never dropped, never a fabricated file
  path (`FR-8a`, O7).
- The `confidence` object carries `tokens` and `time` axes but **no `cost`
  axis** (cost-omitted record).
- `generated_by` is exactly `cost-estimator / tier:Standard` — the dispatch
  supplied no resolved model id, so the routing-tier label is recorded, never a
  guessed or hard-coded concrete model string (`FR-8b`, O3).
- Because `target_kind` was supplied **explicitly**, **no inference-basis line**
  is required in `Confidence rationale`.
- `agent_compute_time` is a `{low, high}` range; `human_gate_time` is **present**
  and is **not** a `{low, high}` range (a qualitative caveat string). The oracle
  asserts only presence and non-range shape — never the caveat's prose content.
- The returned string contains **no** `recommendation`, `verdict`, `proceed`, or
  go/no-go field anywhere in the frontmatter, **and** no imperative
  recommendation or go/no-go prose in the disclosure body (`FR-12`).
- The returned string is **not** a `REFUSED:` string.

## Rubric

This is a Layer 3 behavioural scenario graded by **deterministic oracles** (spec
§8), not by exact prose or token numbers. The grounding inputs are fixture-pinned
so the input is deterministic even though the `model: inherit` dispatch is not.
The conformance oracle parses the frontmatter and checks the S1 field set; the
presence/absence oracle checks the named fields/markers above. A run passes only
when every oracle holds across the conforming output — the exact token figures
and exact disclosure wording are explicitly **out of grading scope**.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

The runner copies the fixture to a temp directory, runs a single-agent session
with the cost-estimator's frontmatter as the system prompt and tools list, sends
the dispatch (target path + explicit `target_kind: spec`, no resolved model id),
then parses the returned string as YAML + markdown and applies the oracle
assertions above. No LLM-as-judge is required — every assertion is a structural
parse or a presence/absence check.
