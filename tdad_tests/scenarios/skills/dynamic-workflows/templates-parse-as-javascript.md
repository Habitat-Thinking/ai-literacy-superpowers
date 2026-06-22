---
component: dynamic-workflows
component_type: skill
tier: structural
fixture: dynamic-workflows/workflows
---

# Scenario: each S2 template parses as valid JavaScript (AC-2)

## Given

The four `*.workflow.js` templates under
`skills/dynamic-workflows/workflows/` (enforcer-fanout, adversarial-review,
reflection-mining, deep-assessment).

## When

Each file is parsed with a JavaScript syntax parser (`node --check` or
equivalent).

## Then

- Each of the four `*.workflow.js` files parses with no syntax error.

## Rubric

This is the deterministic parse check from AC-2 / FR-4 / FR-8. The templates
are *templates an agent ADAPTs*, never verbatim scripts (the runtime function
names defer to <https://code.claude.com/docs/en/workflows>), but they must
still be syntactically valid JavaScript so a reader can trust the shape and so
the firewall can reason over executable lines. Verified by the Layer-0 bash
test `test-workflow-templates.sh` via `node --check`. RED until the templates
exist.
