---
component: dynamic-workflows
component_type: skill
tier: structural
fixture: dynamic-workflows/workflows
---

# Scenario: the four S2 workflow templates exist (AC-1)

## Given

The `dynamic-workflows` skill has shipped its S2 template library under
`ai-literacy-superpowers/skills/dynamic-workflows/workflows/`.

## When

The `workflows/` directory is read.

## Then

- The directory `skills/dynamic-workflows/workflows/` exists.
- Exactly these four files exist:
  - `workflows/enforcer-fanout.workflow.js`
  - `workflows/adversarial-review.workflow.js`
  - `workflows/reflection-mining.workflow.js`
  - `workflows/deep-assessment.workflow.js`

## Rubric

This is the deterministic existence check from AC-1 / FR-1. It is verified by
the Layer-0 bash test `test-workflow-templates.sh`, which fails until the four
files are present. Until S2 ships the templates, the `workflows/` directory
does not exist and the Layer-0 check is RED for the right reason — missing
implementation, not a malformed assertion. The templates are *reference
substrate the later agent slices ADAPT* (S3–S6); S2 wires no agent or command
to them (AC-13).
