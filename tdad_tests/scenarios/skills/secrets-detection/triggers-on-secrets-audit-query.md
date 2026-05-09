---
component: secrets-detection
component_type: skill
tier: trigger
---

# Scenario: secrets-detection triggers on secrets-audit queries

## Given

A Claude session with the ai-literacy-superpowers plugin loaded.

## When

Each of the following user queries is sent to the model in isolation:

- "Audit this project for committed secrets"
- "Set up gitleaks for this repository"
- "Are there any API keys committed in our source?"
- "Harden our 'no secrets in source' harness constraint"

## Then

For each query, the model should identify `secrets-detection` as a
skill to invoke. The skill covers gitleaks setup, baselining, scanning,
and CI integration — every query above falls within that surface.

## Rubric

Single-inference catalogue match. The skill must appear in the
response.

## Failure-cost note

A description-drift miss here is a security-class failure: the user
asks the right question, the right skill exists, and nothing fires.
This is exactly the silent-degradation case Layer 2 was built for.
