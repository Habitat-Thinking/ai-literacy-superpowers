---
component: assessor
component_type: agent
tier: behavioural
fixture: large-repo-inventory
---

# Scenario: an above-threshold repo fans out by area with per-finding separate-agent verification (AC-6, agent-backed)

## Given

A repo **above the file-count threshold** (`> 300` files) and the **Claude
Code runtime present**.

## When

The assessor runs in workflow mode against that repo.

## Then

- Findings **fan out by area** — each area is scanned by its own agent, so
  no single long scan can declare itself done after partial progress.
- **Each finding is verified by a separate agent before synthesis**, and
  the synthesised report preserves file:line citations (a completeness pass
  guards the tail of findings).

## Rubric

This is a **runtime / behavioural** property — *not* deterministically
assertable from a static file read, and explicitly tagged agent-backed in
the spec (§6 decision 2). Its **structural shadow** is
`declares-threshold-and-deep-research-shape.md` (AC-7), which asserts the
agent doc *declares* the threshold, the fan-out-by-area, the per-finding
separate-agent verification, and the cited report.

A judge evaluating a live run confirms (a) the scan fans out by area and
(b) every finding passes through a separate verifier agent before the
synthesis barrier. This requires the Claude Code workflow runtime; on a tree
without it the assessor falls back to its existing single-context Phase 1–6
scan (see `declares-threshold-and-deep-research-shape.md`).

## Status

This scenario is **declared, not wired** as a deterministic check. It is
**not** part of the Layer-0/1 RED set the GATE confirms — it is a
Layer-2/3 agent-backed scenario standing as the runtime promise the
structural shadow declares. It must **not** be promised as CI-checkable.
