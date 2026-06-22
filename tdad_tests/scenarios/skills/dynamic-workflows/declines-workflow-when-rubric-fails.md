---
component: dynamic-workflows
component_type: skill
tier: behavioural
---

# Scenario: agent declines a workflow when the election rubric fails (AC-8)

## Given

A task that fails the four-question election rubric — none of long-running,
massively parallel, highly structured, or adversarial applies. For example:
"Rename this one function and update its three call sites in the same file."
The agent has the `dynamic-workflows` skill available to consult.

## When

The agent considers whether to spin up a workflow for the task and consults
`dynamic-workflows` (specifically `references/when-not-to-use.md`).

## Then

- The agent DECLINES to elect a workflow.
- The agent explicitly USES the static pipeline (the plugin's default
  `spec-writer → GATE → tdd-agent → implementer → code-reviewer → GUARDRAIL →
  integration-agent` path, or simply a single-pass edit for a change this
  small).
- The agent CITES `when-not-to-use.md` / the four-question rubric as the
  reason, noting that none of the four discriminating questions applies.

## Rubric

This is the agent-backed behaviour from AC-8 / FR-4 (Layer 3, full SDK
invocation). The pass condition is that the agent *refuses* the workflow and
grounds the refusal in the rubric — the discipline is "workflows are elected,
not reflexive", and an agent that reaches for parallel subagents on a trivial
in-file rename has breached it.

Reflexively electing a workflow here is the canonical failure (the §7
over-orchestration risk made observable). An agent that declines but cannot
say *why* (does not reference the four questions or the static-pipeline
default) is a partial pass graded as a failure: the citation is what proves
the decision came from the skill rather than chance.
