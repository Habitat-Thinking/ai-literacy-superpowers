---
component: cost-estimator
component_type: agent
tier: structural
---

# Scenario: cost-estimator ships as a read-only emitter — tool boundary and charter

## Given

The `cost-estimator` agent is S2 of the cost-estimator capability
(spec `docs/superpowers/specs/2026-06-11-cost-estimator-agent-design.md`).
It is a **read-only derived-judgment emitter**: given a target it reads its
grounding sources, applies the S1 `cost-estimation` methodology, and **returns
the estimate-record content as a string** for a dispatcher to persist after a
human disposes. It writes nothing; it decides nothing.

This scenario fixes the structural contract the single agent file must satisfy
(spec §2.1, §3.1, §3.2, §4, §5, §6; FR-1, FR-2, FR-3, FR-6a).

## When

The agent file at `ai-literacy-superpowers/agents/cost-estimator.agent.md` is
read directly from the filesystem during the design pass for the S3 command or
the S4 orchestrator fold-in — the dispatchers that will consume its output.

## Then

**Frontmatter** (`FR-1`):

- **YAML frontmatter present** with `name: cost-estimator` and a non-empty
  `description` — required by the `All frontmatter has name and description`
  HARNESS constraint.
- The `tools` declaration is **exactly** `Read`, `Glob`, `Grep` — and contains
  **no** `Write`, **no** `Edit`, **no** `Bash`. This is the load-bearing
  trust-boundary decision (spec §3.2): the agent cannot persist a record, so the
  human disposition cannot be bypassed.
- `model: inherit` (the routing tier is recorded in `MODEL_ROUTING.md`, not
  pinned in the agent file) (spec §7).

**Charter section** (`FR-2`):

- The body states the agent **returns the estimate-record content as a string**.
- The body states the agent **does not write the record, does not name where it
  is persisted, and does not validate it** — those are a dispatcher's job (S3/S4,
  out of scope).
- The body states the agent **never decides go/no-go and never picks a
  confidence label as a verdict**.
- The body references the AGENTS.md **agent-emit + dispatcher-persist +
  human-disposes** decision and its **dispose-then-write ordering invariant**.

**Grounding-context section** (`FR-3`):

- The body instructs the agent to load the S1 `cost-estimation` skill
  (`ai-literacy-superpowers/skills/cost-estimation/SKILL.md`) as reasoning
  context and to emit a record conforming to
  `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`,
  **referenced by path** — it does **not** inline a competing field definition
  and does **not** redefine, extend, or mutate the S1 format reference.

**Required contract sections present**:

- An **input / target contract** section naming the four accepted target types
  and the `target_kind` classification rule, including the inference-basis
  disclosure on inferred kinds (spec §4; `FR-6a`).
- An **emit-not-write + refusal** section describing the `REFUSED:` convention,
  its trigger conditions, and the empty-snapshot-is-not-a-refusal rule (spec §5).
- A **disclosure obligations** section covering the folded-in S1 residuals: the
  mechanical cost-omission rule and the blended-rate-skew surfacing (spec §6).

## Rubric

This is a Layer 1 structural scenario: every assertion is mechanically checkable
by reading the agent file and matching against its frontmatter `tools` list and
its body headings. The scenario passes only when the tool boundary is exactly
`Read, Glob, Grep`, the charter states emits-a-string / never-writes /
never-validates / never-decides and cites the agent-emit decision plus the
dispose-then-write ordering invariant, and the input-contract, refusal, and
disclosure sections are all present and reference (not redefine) the S1 contract.

## Notes

Scope is S2 only. This scenario asserts the agent's structural shape; it does
**not** assert anything about the S3 command, the S4 orchestrator wiring, or the
#377 per-stage `cost_usd` format change. S2 makes no change to
`estimate-record-format.md`.
