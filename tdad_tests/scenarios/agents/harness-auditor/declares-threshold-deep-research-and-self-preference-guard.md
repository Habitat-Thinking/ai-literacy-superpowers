---
component: harness-auditor
component_type: agent
tier: structural
---

# Scenario: the workflow-mode section declares the deep-research shape PLUS the self-preference guard (AC-8 / FR-8)

## Given

The file
`ai-literacy-superpowers/agents/harness-auditor.agent.md`.

## When

The agent doc is read.

## Then

- A section titled **`Workflow mode`** (a level-2 or level-3 heading
  containing the phrase "Workflow mode") is present.
- It declares **everything the assessor declares** (AC-7): the repo
  **file count `> 300`** threshold (strict, `> 300` unwrapped),
  configurable via the **optional `HARNESS.md` field** (default 300 when
  absent), **fan out by area**, each finding **verified by a separate
  agent** before synthesis, a **cited report**, **adapts
  `deep-assessment.workflow.js` by relative path**, and the
  **Claude-Code-only scope + non-erroring fallback**.
- **Plus the self-preference guard** (the one demanded specialisation): at
  least one verifier is **adversarial to the framework's own assumptions**
  — the auditor must not grade its own homework. The words "adversarial",
  "framework", and "assumption" co-occur in the section.

## Rubric

Deterministic structural shadow of AC-6 (umbrella D7) **plus** the auditor's
single specialisation. The disposition is "uniform shape, specialise only
where an agent demands it" — the self-preference guard is that one
specialisation (the auditor grades its own framework, so a verifier
adversarial to the framework's assumptions is the guard against self-audit
bias). The shared shape (threshold + fan-out + per-finding verification +
cited report + scope + fallback) is asserted by the same shared helper used
for the assessor; the auditor adds the guard on top.

## Evaluation

Evaluated deterministically by
`tests/test_s4_adversarial_deepresearch_structural.py`
(`TestS4HarnessAuditorWorkflowMode`). RED now: no workflow-mode section
exists in `harness-auditor.agent.md`, so the deep-research shape and the
self-preference-guard declarations are all absent.
