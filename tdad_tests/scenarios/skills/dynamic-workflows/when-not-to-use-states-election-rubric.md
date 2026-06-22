---
component: dynamic-workflows
component_type: skill
tier: structural
---

# Scenario: when-not-to-use.md states the four-question election rubric (AC-7)

## Given

The file
`ai-literacy-superpowers/skills/dynamic-workflows/references/when-not-to-use.md`.

## When

The file is read.

## Then

- The compute-discipline election rubric is stated as four discriminating
  questions: is the task **long-running**, **massively parallel**, **highly
  structured**, or **adversarial**?
- The default is stated explicitly: **if none of the four apply, use the
  static pipeline.**
- The file does **not** fix the D3 fan-out threshold value (= 8); it may note
  that a fan-out threshold exists but must not state its number (that rides
  on S3).

## Rubric

This is the deterministic content check from AC-7 / FR-4. All four
discriminating questions must be present and the "if none apply, use the
static pipeline" default must be explicit — the default is what makes a
workflow *elected* rather than reflexive (the §7 over-orchestration risk).

The no-threshold-value clause is a scope guardrail: stating "= 8" here would
pre-empt S3's open-question-1 decision and is therefore a regression for S1.
