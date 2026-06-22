---
component: harness-audit
component_type: command
tier: structural
---

# Scenario: /harness-audit documents the large-repo deep-research workflow path (AC-10 / FR-10)

## Given

The file
`ai-literacy-superpowers/commands/harness-audit.md`.

## When

The command doc is read.

## Then

- It documents that, for a repo **above the threshold** (`> 300` files) on
  the **Claude Code runtime**, the dispatched harness-auditor agent elects
  its **deep-research workflow mode** (fan-out by area + adversarial
  verification + cited report, including the framework-adversarial
  verifier). The phrase "workflow mode", the literal `> 300`, and "Claude
  Code" all appear, each **unwrapped** on one line.
- It documents that the **output is the same** (the existing HARNESS.md
  Status section + README badge update) and that there is a **non-erroring
  fallback** elsewhere (the term "fall back"/"falls back"/"fallback"
  appears).

## Rubric

Deterministic structural assertion (AC-10), the auditor command sibling of
the `/assess` scenario. The command documents the path the auditor owns; it
does not re-decide the threshold. The assertion requires the threshold
value, the runtime gate, and the fallback to co-occur — load-bearing, not a
single keyword.

## Evaluation

Evaluated deterministically by
`tests/test_s4_adversarial_deepresearch_structural.py`
(`TestS4CommandsDocumentWorkflowPath`). RED now: `commands/harness-audit.md`
does not yet document the workflow path.
