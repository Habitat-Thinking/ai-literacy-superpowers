---
component: harness-enforcer
component_type: agent
tier: structural
---

# Scenario: ≤ 8 enforceable constraints keep the existing single-context path (AC-4 / FR-6)

## Given

The file
`ai-literacy-superpowers/agents/harness-enforcer.agent.md`.

## When

The workflow-mode section is read.

## Then

- The section states that with **≤ 8** enforceable constraints — at or
  below the threshold — the enforcer keeps its **existing single-context
  behaviour**.
- The section states that on the below-threshold path **no workflow is
  authored, no verifier subagents are spawned, and no extra compute is
  spent** (the default path is untouched — over-orchestration on small
  harnesses is a regression, umbrella §6).
- The section makes the boundary unambiguous via the strict `>` trigger:
  **exactly 8 stays single-context** (the phrase "single-context" or
  "single context" appears in the below-threshold description).

## Rubric

Deterministic structural assertion (AC-4). The default path for small
`HARNESS.md` files must be preserved and *declared* as preserved, so a
reader and a CI check can both confirm the cheap path is intact. The
load-bearing specifics:

- The "≤ 8 / at-or-below keeps single-context" statement is present.
- The "no workflow / no fan-out / no extra compute" guarantee is present
  — this is the compute-discipline promise that distinguishes S3 from
  blanket orchestration.

The behavioural truth (an actual below-threshold run spends no extra
compute) is agent-backed; the deterministic surface is that the agent doc
*declares* the cheap path is kept.

## Evaluation

Evaluated deterministically by
`tests/test_s3_enforcer_fanout_structural.py`. RED now: there is no
workflow-mode section, so no below-threshold single-context preservation
statement exists in the agent doc.
