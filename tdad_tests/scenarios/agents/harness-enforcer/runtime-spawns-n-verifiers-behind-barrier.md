---
component: harness-enforcer
component_type: agent
tier: behavioural
fixture: enforceable-constraint-inventory
---

# Scenario: N>8 enforceable constraints spawn exactly N verifiers behind a synthesis barrier (AC-1, agent-backed)

## Given

A `HARNESS.md` with **N > 8** commit-scoped **enforceable** constraints
and the **Claude Code runtime present**.

## When

The enforcer runs in workflow mode against that harness.

## Then

- Exactly **N** verifier subagents are spawned, **one per rule**.
- The **synthesis barrier waits for all N** results before any report is
  produced — no report can form from a partial set.

## Rubric

This is a **runtime / behavioural** property — *not* deterministically
assertable from a static file read, and explicitly tagged agent-backed in
the spec (§6 decision 2). Its **structural shadow** is
`declares-fanout-skeptic-synthesis-shape.md` (AC-6), which asserts the
agent doc *declares* the per-rule fan-out and the all-N synthesis barrier.

A judge evaluating a live run confirms (a) the verifier count equals the
enforceable-constraint count and (b) no report is emitted before all N
return. This requires the Claude Code workflow runtime; it cannot be run
on a tree without it (where the enforcer falls back to single-context —
see AC-7).

## Status

This scenario is **declared, not wired** as a deterministic check. It is
**not** part of the Layer-0/1 RED set the GATE confirms — it is a
Layer-2/3 agent-backed scenario standing as the runtime promise the
structural shadows (AC-5/AC-6) declare. It must **not** be promised as
CI-checkable.
