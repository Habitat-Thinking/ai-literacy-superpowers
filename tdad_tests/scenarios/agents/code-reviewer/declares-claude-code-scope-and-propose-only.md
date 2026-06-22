---
component: code-reviewer
component_type: agent
tier: structural
---

# Scenario: the workflow-mode section declares Claude-Code-only scope, non-erroring fallback, and propose-only/read-only boundary (AC-2, AC-11 / FR-5)

## Given

The file
`ai-literacy-superpowers/agents/code-reviewer.agent.md` — its workflow-mode
section and its frontmatter `tools`.

## When

The agent doc is read.

## Then

- The workflow-mode section states workflow mode **requires the Claude Code
  runtime** (the phrase "Claude Code" appears tied to the runtime).
- It states that on a tree **without** the runtime the reviewer **falls
  back to its existing single-context review** and **never errors** (the
  phrases "fall back"/"falls back" and "never error"/"never errors"
  appear; it does not pretend to fan out).
- It states workflow mode is **propose-only / read-only** and **never
  writes a durable artefact** (INV-1) — the phrase "durable artefact"
  appears tied to a propose-only / read-only / never-writes statement.
  Keep "durable artefact" **unwrapped**.
- The frontmatter `tools` stays **read-only**: no `Write`, no `Edit` (it
  remains `Read, Glob, Grep, Bash`). This is already true today and must
  **stay** true.

## Rubric

Deterministic structural assertion (AC-2 runtime scope + AC-11 INV-1
precision), grounded in the umbrella §5.5 runtime-scope note and the
slicing-record "Runtime scope — Claude Code only" section. The reviewer is a
propose-only agent; workflow mode adds fan-out, not write capability. The
Claude-Code-gated mode must degrade to the existing static single-context
review, never to an error. S4 restates the Claude-Code-only nature for the
reviewer's *own* behaviour; it does **not** decide the precise Copilot
degradation contract (open-question 4, owned by S7).

The tool-set check is GREEN today (the list already excludes Write/Edit)
and must STAY green through S4 — it is the agent-level INV-1 enforcement.

## Evaluation

Evaluated deterministically by
`tests/test_s4_adversarial_deepresearch_structural.py`
(`TestS4CodeReviewerWorkflowMode` for the section declarations,
`TestS4CodeReviewerReadOnlyToolSet` for the tool boundary). The section
declarations are RED now (no workflow-mode section); the read-only tool
assertion is GREEN now and stays green.
