---
component: assess
component_type: command
tier: structural
---

# Scenario: /assess documents the large-repo deep-research workflow path (AC-10 / FR-10)

## Given

The file
`ai-literacy-superpowers/commands/assess.md`.

## When

The command doc is read.

## Then

- It documents that, for a repo **above the threshold** (`> 300` files) on
  the **Claude Code runtime**, the dispatched assessor agent elects its
  **deep-research workflow mode** (fan-out by area + adversarial
  verification + cited report). The phrase "workflow mode", the literal
  `> 300`, and "Claude Code" all appear, each **unwrapped** on one line.
- It documents that the **output is the same** timestamped assessment
  artefact in the same location, and that there is a **non-erroring
  fallback** elsewhere (the term "fall back"/"falls back"/"fallback"
  appears).

## Rubric

Deterministic structural assertion (AC-10). The command is the
human-facing entry point; it must point at the agent's workflow-mode
election above the threshold so a reader sees the large-repo path without
reading the agent doc. The assertion is load-bearing: it requires the
threshold value, the runtime gate, and the fallback to co-occur — not a
single keyword. The command does not re-decide the threshold; it documents
the path the agent owns.

## Evaluation

Evaluated deterministically by
`tests/test_s4_adversarial_deepresearch_structural.py`
(`TestS4CommandsDocumentWorkflowPath`). RED now: `commands/assess.md` does
not yet document the workflow path (no "workflow mode" / `> 300` / Claude
Code note).
