---
component: dynamic-workflows
component_type: skill
tier: structural
---

# Scenario: a dynamic-workflows how-to guide exists (S1 GATE pull-in)

## Given

The docs site directory
`docs/plugins/ai-literacy-superpowers/how-to/`.

## When

The how-to guides are enumerated.

## Then

- A how-to guide for the `dynamic-workflows` skill exists under
  `docs/plugins/ai-literacy-superpowers/how-to/` (e.g.
  `dynamic-workflows.md`).
- The guide references the `dynamic-workflows` skill by name.

## Rubric

The spec (§6.4) recommended deferring the how-to guide to S7, but the human
pulled it into S1 at the GATE. This is a lightweight presence check: the
guide file exists and names the skill. It does not assert the guide walks
through any runnable workflow template (those are S2) — S1 ships reading
material, so the guide is an orientation to the skill's conceptual model and
election rubric, not an end-to-end runbook.

Until the guide file is authored, this scenario is RED by absence of the
file under the how-to directory.
