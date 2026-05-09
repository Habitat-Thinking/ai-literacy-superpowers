---
component: github-actions-supply-chain
component_type: skill
tier: trigger
---

# Scenario: github-actions-supply-chain triggers on workflow-security queries

## Given

A Claude session with the ai-literacy-superpowers plugin loaded.

## When

Each of the following user queries is sent to the model in isolation:

- "Review our GitHub Actions workflows for security issues"
- "Harden our CI pipeline"
- "Are our actions pinned to commit SHAs?"
- "Audit this repo's GitHub Actions supply-chain risk"

## Then

For each query, the model should identify
`github-actions-supply-chain` as a skill to invoke.

## Rubric

Single-inference catalogue match.

## Distinction from `dependency-vulnerability-audit`

This skill is specifically about *workflow file* security and
*action* supply chain — pinning, permissions, third-party action
trust. The `dependency-vulnerability-audit` skill is about
*runtime* dependency CVEs (Go modules, Maven, etc.). The third
query ("pinned to commit SHAs") is unambiguously this skill's
territory.
