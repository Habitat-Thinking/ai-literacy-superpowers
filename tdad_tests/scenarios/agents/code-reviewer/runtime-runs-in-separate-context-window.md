---
component: code-reviewer
component_type: agent
tier: behavioural
fixture: non-trivial-diff
---

# Scenario: a non-trivial review runs in a context window distinct from the implementer's (AC-1, agent-backed)

## Given

A **non-trivial** implementation diff (above the trigger — `> 2 files`
changed) and the **Claude Code runtime present**.

## When

The code-reviewer runs in workflow mode against that diff.

## Then

- The reviewing agent operates in a **context window distinct from the
  implementer's** — it does not inherit the producing context's reasoning.
- Each CUPID property and each literate-programming property is checked by
  a **dedicated verifier** subagent; the findings are **synthesised** into
  one report, **not collapsed** into a single thumbs-up.

## Rubric

This is a **runtime / behavioural** property — *not* deterministically
assertable from a static file read, and explicitly tagged agent-backed in
the spec (§6 decision 2). Its **structural shadow** is
`declares-separate-context-and-non-trivial-trigger.md` (AC-2) plus
`declares-per-property-verifiers-synthesised.md` (AC-3), which assert the
agent doc *declares* the separate-context property and the per-property
fan-out.

A judge evaluating a live run confirms (a) the review context window is
distinct from the implementer's and (b) one verifier exists per CUPID +
literate property behind a synthesis barrier. This requires the Claude Code
workflow runtime; it cannot be run on a tree without it (where the reviewer
falls back to single-context — see
`declares-claude-code-scope-and-propose-only.md`).

## Status

This scenario is **declared, not wired** as a deterministic check. It is
**not** part of the Layer-0/1 RED set the GATE confirms — it is a
Layer-2/3 agent-backed scenario standing as the runtime promise the
structural shadows declare. It must **not** be promised as CI-checkable.
