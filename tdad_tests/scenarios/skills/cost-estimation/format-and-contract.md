---
component: cost-estimation
component_type: skill
tier: structural
---

# Scenario: cost-estimation ships a well-formed skill and a complete estimate-record format contract

## Given

The `cost-estimation` skill is S1 of the cost-estimator capability
(spec `docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md`).
It ships exactly two artefacts and nothing else:

- `ai-literacy-superpowers/skills/cost-estimation/SKILL.md` — the
  methodology and the disclosure/confidence contract as loadable prose.
- `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`
  — the canonical, stable definition of the estimate-record field set,
  the artefact a downstream command's Output Validation Checkpoint
  references by path.

This scenario fixes the structural contract both files must satisfy
(spec §4, §5, §6, §8.1, §8.2; FR-1 through FR-11, FR-8a, FR-14).

## When

The skill and its format reference are read directly from the
filesystem during the design pass for the S2 agent, the S3 command, or
the S4 orchestrator fold-in — the consumers that parse this contract.

## Then

**SKILL.md frontmatter and sections** (`FR-1`):

- **YAML frontmatter present** with `name: cost-estimation` and a
  non-empty `description` — required by the
  `All frontmatter has name and description` HARNESS constraint.
- **Body contains the required sections**, each surfaced as a heading:
  - the grounding **methodology** (how MODEL_ROUTING.md grounds token
    and time, and how a snapshot grounds cost);
  - the **disclosure/confidence contract**;
  - the **time split** (agent-compute vs human-gate);
  - the **calibration seam** (S6, future-only);
  - the **sibling** relationship to `cost-tracking`;
  - a **"What this skill does NOT do"** section stating it does not
    dispatch, does not write files, and does not decide go/no-go.
- The body **references the format file** by relative path.

**Format reference field set** (`FR-2`, `FR-3`):

- The reference defines a frontmatter field table listing every field
  of spec §4.2: `target`, `target_kind`, `generated_at`, `generated_by`,
  `grounding_sources`, `tokens`, `tokens_by_stage`, `cost_usd`,
  `cost_basis`, `agent_compute_time`, `human_gate_time`, `confidence`,
  and `failure_direction`.
- `cost_usd` and `cost_basis` are marked **conditional
  (present-when-grounded)**, not required.
- `confidence` is a **per-axis object** with keys `tokens`, `time`, and
  (only when `cost_usd` is present) `cost`.
- Every **present** quantitative field (`tokens`,
  `tokens_by_stage[].tokens`, `cost_usd` when present,
  `agent_compute_time`) is specified as a `{low, high}` range.
- There is **no** point-value, `recommendation`, `verdict`, or `proceed`
  field anywhere in the field set.

**Time split** (`FR-5`):

- `agent_compute_time` and `human_gate_time` are **two separate required
  fields with different shapes**: `agent_compute_time` is a numeric
  `{low, high}` range; `human_gate_time` is a **qualitative caveat
  string, NOT a range**.
- The reference states `human_gate_time` is **not estimated numerically
  at S1** because the gate set lives in the orchestrator (S4, #371),
  which this slice does not touch, and that human-gate latency dominates
  wall-clock and is the least-predictable term.

**Disclosure body** (`FR-4`):

- The reference mandates the **four-part disclosure body**: Included,
  Excluded, Confidence rationale, Failure direction. A record missing
  any of the four fails validation.

**Per-axis confidence mapping** (`FR-6`):

- The reference defines the **`target_kind` ceiling** for `tokens`/`time`
  (raw `task-text` capped at `low`; `slicing-record`/`slice` at most
  `medium`; `spec` may reach `high`) and an **independent
  snapshot-quality rule** for the conditional `cost` axis, so a
  spec-grounded target can carry `tokens: high` beside `cost: low`.

**Tier→model→$/token binding** (`FR-7`, `FR-8a`):

- The reference contains a named **tier→model→$/token binding table**
  mapping `Most capable → claude-opus-4`, `Standard → claude-sonnet-4`,
  and the implementer's `Standard / Capable` **split row spanning two
  distinct models** — low bound `claude-sonnet-4`, high bound
  `claude-opus-4` — so the split-tier widening produces a real spread.

**Calibration seam** (`FR-9`):

- The `grounding_sources[]` field permits a `kind: calibration` entry
  alongside `model-routing` and `cost-snapshot`, and the methodology
  describes calibration as **range-refinement**, without implementing S6.

**Sibling** (`FR-10`):

- The reference/skill names `cost-tracking` as the retrospective sibling
  and states the estimate reads the `observability/costs/` snapshots
  that `cost-tracking` writes.

**Worked examples and validation checklist** (`FR-11`, `FR-14`):

- The reference contains **two complete worked example records** — one
  **cost-omitted** (today's default: `cost_usd`/`cost_basis` absent,
  `confidence` with `tokens`/`time` only) and one **cost-present**
  (`cost_basis: snapshot-actuals`, `confidence.cost` present). In both
  examples `human_gate_time` is a qualitative caveat string, not a range.
- The **cost-present** example demonstrates the **split-tier widening**:
  its implementer stage carries a **non-zero cost band** whose low bound
  uses `claude-sonnet-4` and high bound uses `claude-opus-4`, visibly
  wider than the token-range spread alone.
- Neither worked example files an inclusion caveat under `Excluded`
  (O10).
- The reference contains a **"Validation checklist"** subsection
  enumerating the checks a consuming command runs, including the
  two-layer no-verdict guarantee (the field-absence check **and** the
  positive-content scan of §5.3).

## Rubric

This is a Layer 1 structural scenario: every assertion is mechanically
checkable by reading `SKILL.md` and `references/estimate-record-format.md`
and matching against frontmatter, headings, the field table, the binding
table, and the two worked example blocks. The scenario passes only when
every assertion in `Then` can be verified by inspection of the two files.

A future Layer 3 scenario could load the skill and ask a model to emit a
record against the format, asserting the result validates — that
behavioural verification is deferred (no dispatchable side-effect ships
in S1; spec §9 targets `[structural, trigger]` only).

## Notes

Scope is S1 only. This scenario does NOT assert anything about the S2
agent, the S3 command, the S4 orchestrator wiring, the S5 ballpark, or
the S6 calibration implementation — only that the methodology and format
contract those slices consume are present and well-formed.
