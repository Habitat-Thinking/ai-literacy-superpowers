---
component: harness-auditor
component_type: agent
tier: behavioural
fixture: large-repo-inventory
---

# Scenario: an above-threshold audit fans out by area with a framework-adversarial verifier (AC-6 + self-preference guard, agent-backed)

## Given

A repo **above the file-count threshold** (`> 300` files) and the **Claude
Code runtime present**.

## When

The harness-auditor runs in workflow mode against that repo.

## Then

- Findings **fan out by area** and **each finding is verified by a separate
  agent before synthesis**, producing a cited report (as for the assessor).
- **At least one verifier challenges the framework's own assumptions** — a
  live verifier is adversarial to the framework, so the auditor cannot grade
  its own homework.

## Rubric

This is a **runtime / behavioural** property — *not* deterministically
assertable from a static file read, and explicitly tagged agent-backed in
the spec (§6 decision 2). Its **structural shadow** is
`declares-threshold-deep-research-and-self-preference-guard.md` (AC-8),
which asserts the agent doc *declares* the deep-research shape plus the
self-preference guard.

A judge evaluating a live run confirms (a) the audit fans out by area with
per-finding separate-agent verification and (b) at least one verifier is
genuinely adversarial to the framework's assumptions (not a rubber stamp).
This requires the Claude Code workflow runtime; on a tree without it the
auditor falls back to its existing single-context behaviour.

## Status

This scenario is **declared, not wired** as a deterministic check. It is
**not** part of the Layer-0/1 RED set the GATE confirms — it is a
Layer-2/3 agent-backed scenario standing as the runtime promise the
structural shadow declares. It must **not** be promised as CI-checkable.
