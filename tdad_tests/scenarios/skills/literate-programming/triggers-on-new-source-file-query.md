---
component: literate-programming
component_type: skill
tier: trigger
---

# Scenario: literate-programming triggers on source-file authoring queries

## Given

A Claude session with the ai-literacy-superpowers plugin loaded — so
all skill descriptions, including `literate-programming`, are
available for matching.

## When

Each of the following user queries is sent to the model in isolation:

- "I'm about to create a new module for parsing config files — what should it look like?"
- "Write me a new helper class for handling user authentication"
- "Create a new Python file that handles snapshot serialisation"
- "I'm rewriting the renderer module from scratch"

## Then

For each query, the model should identify `literate-programming` as
a skill to invoke. The skill's role is to ensure new code carries
narrative preambles, reasoning-based documentation, and reader-first
presentation.

## Rubric

A single inference per query: hand the model the plugin's skill
descriptions and the query, ask "which skills would you invoke?",
and parse the response. The skill must appear in the match list.

## Implementation note

Tests live in `tdad_tests/tests/test_layer2_triggers.py`. The
extractor pattern is the same as the cupid-code-review trigger
test from PR #285 (`runner.sdk.match_skills`).
