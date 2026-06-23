---
component: orchestrator
component_type: agent
tier: behavioural
fixture: taste-based-naming-task
---

# Scenario: a taste-based task routes to a tournament (AC-2, agent-backed)

## Given

The **opt-in flag is set** (`orchestrator-routing: enabled` in `HARNESS.md`),
the **Claude Code runtime is present**, and a **taste-based task** (naming /
design).

## When

The orchestrator classifies it.

## Then

- It routes to a **tournament with a rubric-bearing judge** agent.

## Rubric

This is a **runtime / behavioural** property — *not* deterministically
assertable from a static file read, and explicitly tagged agent-backed in
the spec (§6 decision 2). Its **structural shadow** is
`declares-four-routes-and-triggers.md` (AC-6), which asserts the agent doc
*declares* the tournament route and its taste/design trigger.

A judge evaluating a live run confirms a taste/naming task is routed to a
tournament with a rubric-bearing judge (taste resolves by comparing
candidates against an explicit rubric, not a single linear pass). This
requires the Claude Code workflow runtime and the opt-in flag set; it cannot
run on a tree without the runtime or with the flag off (where the classifier
falls back to the static pipeline).

## Status

This scenario is **declared, not wired** as a deterministic check. It is
**not** part of the Layer-0/1 RED set the GATE confirms — it is a
Layer-2/3 agent-backed scenario standing as the runtime promise the
structural shadow declares. It must **not** be promised as CI-checkable.
