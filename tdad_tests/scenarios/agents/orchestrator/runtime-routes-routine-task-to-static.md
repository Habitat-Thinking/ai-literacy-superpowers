---
component: orchestrator
component_type: agent
tier: behavioural
fixture: routine-single-file-task
---

# Scenario: a routine coding task selects the static pipeline with no extra compute (AC-1, agent-backed)

## Given

A **routine single-file coding task** (and any flag state).

## When

The orchestrator classifies it.

## Then

- It **selects the existing static pipeline** — **no workflow is spawned and
  no extra compute is spent** — and the pipeline runs exactly as today.

## Rubric

This is a **runtime / behavioural** property — *not* deterministically
assertable from a static file read, and explicitly tagged agent-backed in
the spec (§6 decision 2). Its **structural shadow** is
`declares-classification-step-opt-in-flag-static-default.md` (AC-5, the
static-default supremacy rule) and `declares-four-routes-and-triggers.md`
(AC-6, the routes + triggers), which assert the agent doc *declares*
static-is-default and the route set.

A judge evaluating a live run confirms a routine task lands on the static
pipeline with no workflow spawned. This is the over-orchestration guard
observed at runtime: routing must never make everyday work slower or more
expensive.

## Status

This scenario is **declared, not wired** as a deterministic check. It is
**not** part of the Layer-0/1 RED set the GATE confirms — it is a
Layer-2/3 agent-backed scenario standing as the runtime promise the
structural shadows declare. It must **not** be promised as CI-checkable.
