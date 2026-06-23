---
component: orchestrator
component_type: agent
tier: behavioural
fixture: flaky-test-incident-task
---

# Scenario: a flaky-test / incident task routes to root-cause investigation (AC-3, agent-backed)

## Given

The **opt-in flag is set** (`orchestrator-routing: enabled` in `HARNESS.md`),
the **Claude Code runtime is present**, and a **flaky-test or incident**
task.

## When

The orchestrator classifies it.

## Then

- It routes to **root-cause investigation** with **≥3 independent hypotheses
  from disjoint evidence** and a panel of verifiers/refuters.

## Rubric

This is a **runtime / behavioural** property — *not* deterministically
assertable from a static file read, and explicitly tagged agent-backed in
the spec (§6 decision 2). Its **structural shadow** is
`declares-four-routes-and-triggers.md` (AC-6), which asserts the agent doc
*declares* the root-cause route, its debugging/flaky-test/incident trigger,
and the ≥3-disjoint-evidence-hypotheses + verifier/refuter-panel shape.

A judge evaluating a live run confirms an incident/flaky-test task is routed
to a root-cause investigation that generates at least three independent
hypotheses from disjoint evidence and runs a verifier/refuter panel — the
discipline that defeats premature single-hypothesis fixation. This requires
the Claude Code workflow runtime and the opt-in flag set.

## Status

This scenario is **declared, not wired** as a deterministic check. It is
**not** part of the Layer-0/1 RED set the GATE confirms — it is a
Layer-2/3 agent-backed scenario standing as the runtime promise the
structural shadow declares. It must **not** be promised as CI-checkable.
