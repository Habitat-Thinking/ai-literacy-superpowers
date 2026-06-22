---
component: dynamic-workflows
component_type: skill
tier: structural
---

# Scenario: dynamic-workflows enumerates and its frontmatter validates (AC-1)

## Given

The ai-literacy-superpowers plugin is installed and its skills are
enumerated by the plugin component discovery (`runner.plugin.list_skills`).

## When

The skill inventory is walked and the `dynamic-workflows` skill is located.

## Then

- A skill named `dynamic-workflows` appears in the enumeration.
- Its `SKILL.md` lives at
  `ai-literacy-superpowers/skills/dynamic-workflows/SKILL.md` and exists.
- Its frontmatter declares a non-empty `name: dynamic-workflows`.
- Its frontmatter declares a non-empty `description`.

## Rubric

This is the deterministic schema check from AC-1 / FR-1. It is satisfied
only when the skill physically exists and its frontmatter parses with both
required keys filled. Until the skill is authored, the structural corpus
check (`test_every_scenario_targets_an_existing_component`) fails because
`find_component(name="dynamic-workflows", component_type="skill")` raises
`LookupError` — that is the intended RED state for S1.

A `description` that is present but does not carry the trigger concepts
(dynamic workflows, multi-agent harnesses, the six patterns, "when to use a
workflow") is a content regression caught by the trigger-tier scenario, not
this one; here we assert only schema presence.
