---
component: dynamic-workflows
component_type: skill
tier: structural
fixture: dynamic-workflows/workflows
---

# Scenario: SKILL.md references all four templates by resolving path (AC-3)

## Given

`SKILL.md` flipped to its S2 "shipped" framing of the template library.

## When

`SKILL.md` is read.

## Then

- `SKILL.md` references **all four** templates by relative path
  (`workflows/enforcer-fanout.workflow.js`,
  `workflows/adversarial-review.workflow.js`,
  `workflows/reflection-mining.workflow.js`,
  `workflows/deep-assessment.workflow.js`).
- Every referenced path **resolves to an existing file** on disk.
- The "forthcoming (S2)" wording is **gone** — the framing is "shipped" and
  prompts agents to ADAPT the templates, not run them verbatim.

## Rubric

This is the deterministic reference-resolution check from AC-3 / FR-5 / FR-8.
It is the property that supersedes the S1 "no hard-link / forthcoming
forward-reference" clause (see the reconciled `markdownlint-clean.md`
scenario). Verified by the Layer-0 bash test `test-workflow-templates.sh`,
which fails if any of the four references is absent, fails to resolve, or if
the "forthcoming" wording survives. RED until SKILL.md is flipped and the
templates exist.
