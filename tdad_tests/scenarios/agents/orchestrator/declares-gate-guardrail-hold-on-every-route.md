---
component: orchestrator
component_type: agent
tier: structural
---

# Scenario: the classification step declares the GATE/GUARDRAIL-hold invariant on every route (AC-7, AC-4 structural shadow / FR-5)

## Given

The task-classification section of
`ai-literacy-superpowers/agents/orchestrator.agent.md`.

## When

The section is read.

## Then

- The section states explicitly that the **Plan Approval GATE** remains in
  force **on every route** (static and non-static alike). Keep "Plan
  Approval" **unwrapped**; the content test asserts "plan approval" with
  "gate".
- The section states the **`MAX_REVIEW_CYCLES=3` GUARDRAIL** remains in
  force on every route. `MAX_REVIEW_CYCLES` is a single unwrappable token;
  the content test asserts "max_review_cycles" with "3".
- The section states that **no route bypasses, weakens, or multiplies**
  these — they hold on **every** route. The content test asserts "every
  route" co-occurs with "gate"/"guardrail".

## Rubric

Deterministic structural shadow of AC-4 (umbrella D4 acceptance). AC-4 — the
live enforcement of the gate/guardrail across a real non-static route — is a
**pipeline-level behavioural property, unverified/declared**, NOT provable
from the agent doc alone, and must **not** be over-promised as
deterministic. What a file read *can* verify is that the section **declares**
the invariant: the GATE and the `MAX_REVIEW_CYCLES=3` GUARDRAIL hold on
every route, with no route permitted to bypass or weaken them.

This is the load-bearing GATE/GUARDRAIL-erosion guard: a non-static route
could be (mis)written to skip Plan Approval or multiply the review cap, so
the declaration must be explicit and route-universal.

## Evaluation

Evaluated deterministically by
`tests/test_s5_orchestrator_routing_structural.py`
(`TestS5OrchestratorGateGuardrailInvariant`). RED now: no classification
section exists, so the GATE/GUARDRAIL-hold-on-every-route statement is
absent.
