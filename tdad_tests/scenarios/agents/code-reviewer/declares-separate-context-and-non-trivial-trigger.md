---
component: code-reviewer
component_type: agent
tier: structural
---

# Scenario: the workflow-mode section declares separate-context review and the non-trivial trigger (AC-2 / FR-1, FR-2)

## Given

The file
`ai-literacy-superpowers/agents/code-reviewer.agent.md`.

## When

The agent doc is read.

## Then

- A section titled **`Workflow mode`** (a level-2 or level-3 heading
  containing the phrase "Workflow mode") is present.
- The section declares the **separate-context property** — the reviewing
  agent operates in a **context window distinct from the implementer's**,
  so it is not judging output from the context that produced it. Keep the
  phrase "context window" **on one line** (the content test asserts
  "context window" and "implementer" as separate tokens, so wrapping
  between "context" and "window" would break the check).
- The section declares the **non-trivial trigger**: workflow mode engages
  only for a **non-trivial** review — default **`> 2 files` changed** (or a
  substantive single-file change). Trivial diffs (typo, one-liner,
  formatting) keep the existing single-context review. Keep `> 2 files`
  **unwrapped** on one line.
- The section states the trigger is **configurable** via the **optional
  `HARNESS.md` field** (the §6 decision-1 M1 mechanism — one consistent
  knob style across the epic), not left as "somehow tunable".

## Rubric

This is the deterministic structural shadow of AC-1 (umbrella D5). What is
checkable from a static file read is that the agent doc *declares* the
separate-context property and the non-trivial trigger — not that a live
run actually opens a second context window (that is the agent-backed
property AC-1, declared in
`runtime-runs-in-separate-context-window.md`, not wired here). The
load-bearing specifics a deterministic check verifies:

- "context window" + "implementer" co-occur (the separate-context
  guarantee), asserted as independent tokens so a reasonable line-wrap
  still passes — but the implementer must keep "context window" itself
  unwrapped.
- The literal `> 2 files` default is present (the cheap-default boundary:
  a trivial diff demonstrably stays single-context, defeating the
  over-orchestration risk).
- The configurability mechanism is **named** — an optional `HARNESS.md`
  field — consistent with S3's enforcer threshold.

The scenario must **not** be read as asserting any live context-window
split occurs — only that the contract is declared in checkable language.

## Evaluation

Evaluated deterministically by
`tests/test_s4_adversarial_deepresearch_structural.py`
(`TestS4CodeReviewerWorkflowMode`). RED now because the agent doc contains
no "Workflow mode" section (`grep -n "Workflow mode"` returns nothing), so
none of the separate-context / trigger / configurability phrases exist yet.
