---
component: dynamic-workflows
component_type: skill
tier: structural
---

# Scenario: MODEL_ROUTING.md gains workflow-election + token-budget + classifier (AC-9)

## Given

The template `ai-literacy-superpowers/templates/MODEL_ROUTING.md`, extended as
part of the `dynamic-workflows` skill slice (S1).

## When

The file is read.

## Then

- It contains a **workflow-election** section — the election discipline (D8)
  given a home in the routing template.
- It states a **token-budget convention**: an explicit per-workflow cap (e.g.
  "use 10k tokens"), so every elected workflow carries a bounded budget.
- It describes the **model-routing-classifier** idea: a classifier agent that
  researches task complexity, then routes across the Haiku / Sonnet / Opus
  tiers.

## Rubric

This is the deterministic content check from AC-9 / FR-6. All three elements
must be present: the workflow-election section, an explicit per-workflow
token cap, and the classifier-tiering idea naming Haiku/Sonnet/Opus.

This scenario is filed under the `dynamic-workflows` skill because the
template extension is part of S1's skill slice — until the skill exists the
structural corpus check reddens, and the MODEL_ROUTING.md additions are
authored in the same slice. It does not assert the D4 routing default
(opt-in vs on-by-default) — that rides on S5.
