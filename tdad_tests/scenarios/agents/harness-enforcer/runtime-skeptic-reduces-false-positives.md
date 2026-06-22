---
component: harness-enforcer
component_type: agent
tier: behavioural
---

# Scenario: the skeptic persona reduces false positives, recorded once (AC-2, agent-backed / observational)

## Given

A candidate violation flagged by a verifier subagent during a live
workflow-mode run on the Claude Code runtime.

## When

The skeptic persona adversarially reviews the candidate.

## Then

- A **false-positive reduction versus single-context enforcement is
  observable** across real runs.
- The **first time** workflow mode runs, the observation is captured in a
  **`REFLECTION_LOG.md` entry** — a human-curated artefact, **not written
  by the workflow**.

## Rubric

Inherently **observational / agent-backed** (§6 decision 3): there is no
deterministic file read that proves a *rate reduction* — it requires
comparing real runs. Its **structural shadow** is
`declares-first-run-reflection-log-obligation.md` (AC-2 declaration /
FR-8), which asserts the agent doc *declares* the skeptic pass and the
first-run REFLECTION_LOG obligation.

This claim must **not** be over-promised as deterministic anywhere — not
in the agent doc and not in this scenario. The deterministic surface is
only the *declaration*; the effect itself stays observational.

## Status

**Declared, not wired** as a deterministic check — not part of the
Layer-0/1 RED set. It stands as the agent-backed runtime promise whose
deterministic shadow is the first-run REFLECTION_LOG declaration. Any
wording (here or in the agent doc) implying the false-positive reduction
is CI-checkable is to be rejected.
