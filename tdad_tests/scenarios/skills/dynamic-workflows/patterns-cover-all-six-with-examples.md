---
component: dynamic-workflows
component_type: skill
tier: structural
---

# Scenario: patterns.md names all six patterns with worked micro-examples (AC-3)

## Given

The file
`ai-literacy-superpowers/skills/dynamic-workflows/references/patterns.md`.

## When

The file is read.

## Then

All six composable patterns are named, and each carries a worked
micro-example (a concrete, task-shaped illustration, not just a definition):

- classify-and-act
- fan-out-and-synthesize
- adversarial verification
- generate-and-filter
- tournament
- loop-until-done

## Rubric

This is the deterministic content check from AC-3 / FR-3. "Named" means each
of the six pattern labels appears as a heading or term in the file; "worked
micro-example" means each pattern section illustrates the pattern against a
concrete task rather than only restating its definition.

A pattern listed without a micro-example fails the scenario — the worked
example is what makes the pattern usable by an agent reasoning about a real
task (and is what AC-5's agent-backed naming relies on). The file must not
fix the D3 fan-out threshold value (= 8); it may mention that a threshold for
fan-out mode exists, but stating a number is out of S1 scope (it rides on S3).
