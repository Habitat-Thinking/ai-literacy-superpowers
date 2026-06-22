---
component: harness-enforcer
component_type: agent
tier: structural
---

# Scenario: Claude-Code-only runtime scope and non-erroring fallback are declared (AC-7 / FR-9)

## Given

The file
`ai-literacy-superpowers/agents/harness-enforcer.agent.md`.

## When

The workflow-mode section is read.

## Then

- The section states workflow mode **requires the Claude Code runtime**
  (the phrase "Claude Code" appears tied to the runtime requirement).
- The section states that on a tree **without** the runtime (e.g. GitHub
  Copilot CLI or any other coding agent) the enforcer **falls back to its
  existing single-context behaviour** (the phrase "falls back" / "fall
  back" tied to "single-context" appears).
- The section states the fallback **never errors** and the enforcer does
  **not pretend to fan out** where the runtime is absent (the phrase
  "never error" / "never errors" appears).

## Rubric

Deterministic structural assertion (AC-7), grounded in the umbrella §5.5
runtime-scope note and the slicing-record "Runtime scope — Claude Code
only" section. The plugin ships to multiple trees; the workflow mode is
Claude-Code-gated, and the absence of the runtime must degrade gracefully
to the existing static behaviour, never to an error.

Note the boundary: S3 restates the Claude-Code-only nature for the
enforcer's *own* behaviour. It does **not** decide the precise Copilot
degradation *contract* (guidance-only vs omit) — that is open-question 4,
owned by S7. The check asserts only the non-erroring single-context
fallback, not any S7 contract specifics.

## Evaluation

Evaluated deterministically by
`tests/test_s3_enforcer_fanout_structural.py`. RED now: no workflow-mode
section exists, so the Claude-Code-only requirement and the non-erroring
single-context fallback are absent from the agent doc.
