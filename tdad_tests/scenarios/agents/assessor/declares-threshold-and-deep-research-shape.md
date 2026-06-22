---
component: assessor
component_type: agent
tier: structural
---

# Scenario: the workflow-mode section declares the file-count threshold and the deep-research shape (AC-7 / FR-7)

## Given

The file
`ai-literacy-superpowers/agents/assessor.agent.md`.

## When

The agent doc is read.

## Then

- A section titled **`Workflow mode`** (a level-2 or level-3 heading
  containing the phrase "Workflow mode") is present.
- It declares the **repo-size threshold**: repo **file count `> 300`**
  (strict greater-than). The literal `> 300` and the metric "file count"
  both appear. Keep `> 300` **unwrapped** on one line.
- It states the threshold is **configurable** via the **optional
  `HARNESS.md` field** (the §6 decision-1 M1 mechanism), defaulting to
  **300 when absent** (a missing/garbled field safe-defaults, never
  errors).
- It declares the deep-research shape: **fan out by area**, each finding
  **verified by a separate agent** before synthesis, producing a **cited
  report** (file:line citations preserved through synthesis). The phrases
  "separate agent" and "cited report" appear, each **on one line**.
- It states it **adapts `deep-assessment.workflow.js` by relative path**
  (ADAPT, not verbatim) — the filename and "adapt" both appear.
- It states the **Claude-Code-only scope** and the **non-erroring
  fallback** to the existing single-context Phase 1–6 scan ("Claude Code",
  "falls back", "never errors" appear).

## Rubric

Deterministic structural shadow of AC-6 (umbrella D7). What is checkable
from a static file read is that the agent doc *declares* the threshold and
the fan-out/verify/cited-report shape — not that a live run fans out (that
is the agent-backed property AC-6, declared in
`runtime-fans-out-by-area-with-verification.md`, not wired here). The
load-bearing specifics:

- The literal `> 300` default and the file-count metric (the cheap-default
  boundary: small/medium repos stay single-context — the over-orchestration
  guard).
- The configurability mechanism is **named** (optional `HARNESS.md` field),
  consistent with S3 and with the code-reviewer trigger — one knob style
  across the epic.
- The fan-out-by-area + per-finding separate-agent verification + cited
  report co-occur — a long scan can no longer declare itself done after
  partial progress (the "35 of 50" lazy stop).

## Evaluation

Evaluated deterministically by
`tests/test_s4_adversarial_deepresearch_structural.py`
(`TestS4AssessorWorkflowMode`). RED now: no workflow-mode section exists in
`assessor.agent.md`, so the threshold / fan-out / verification / cited-report
/ template-adapt / scope-and-fallback declarations are all absent.
