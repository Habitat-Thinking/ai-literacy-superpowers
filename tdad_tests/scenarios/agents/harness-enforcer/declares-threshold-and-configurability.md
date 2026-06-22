---
component: harness-enforcer
component_type: agent
tier: structural
---

# Scenario: the workflow-mode section declares the default-8 threshold and per-project configurability (AC-5 / FR-1, FR-2)

## Given

The file
`ai-literacy-superpowers/agents/harness-enforcer.agent.md`.

## When

The agent doc is read.

## Then

- A section titled **`Workflow mode`** (a level-2 or level-3 heading
  containing the phrase "Workflow mode") is present.
- The section declares a **default threshold of `8`** commit-scoped
  enforceable constraints — the literal value `8` appears alongside the
  word "threshold".
- The section states the threshold is **configurable per project** via an
  **optional `HARNESS.md` field the enforcer reads** (the §6 decision-1
  M1 mechanism, named explicitly — not left as "somehow configurable").
- The section states that when the field is **absent the default is `8`**
  (missing/garbled field falls back to 8 rather than erroring).
- The trigger is a **strict `>`** (greater-than) comparison: workflow mode
  engages only when the enforceable-constraint count **exceeds** the
  threshold — the section uses "exceeds", "greater than", or the `>`
  symbol, not "≥" or "at least".

## Rubric

This is the deterministic structural shadow of AC-5 (umbrella D3). What is
checkable from a static file read is that the agent doc *declares* the
threshold and its configurability mechanism — not that a live run honours
it (that is the agent-backed property AC-1 shadows). The load-bearing
specifics a deterministic check verifies:

- The literal default value `8` is present and tied to the threshold.
- The configurability mechanism is **named** — an optional `HARNESS.md`
  field — so a reviewer can see *how* a project overrides it, not merely
  that it is "configurable".
- The absent → 8 default is stated, because a missing-field error would
  be a regression (§9 risk: garbled field must safe-default).
- The strict `>` trigger is stated, because exactly-8 must stay on the
  cheap single-context path (the AC-4 boundary).

The scenario must **not** be read as asserting any live threshold read
occurs — only that the contract is declared in checkable language.

## Evaluation

This scenario is evaluated deterministically by
`tests/test_s3_enforcer_fanout_structural.py`, which reads the target file
and asserts the phrases above are present. It is RED now because the agent
doc contains no "Workflow mode" section (`grep -n "Workflow mode"` returns
nothing), so none of the threshold/configurability phrases exist yet.
