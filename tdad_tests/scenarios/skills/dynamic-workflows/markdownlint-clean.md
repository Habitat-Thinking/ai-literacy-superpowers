---
component: dynamic-workflows
component_type: skill
tier: structural
---

# Scenario: dynamic-workflows SKILL.md and references are markdownlint-clean (AC-2)

## Given

The `dynamic-workflows` skill's `SKILL.md` and its three reference files
(`references/patterns.md`, `references/when-not-to-use.md`,
`references/governance.md`) exist.

## When

markdownlint runs over them — via the existing PreToolUse hook at edit time
and the `lint-markdown` CI workflow.

## Then

- `SKILL.md` passes markdownlint with no new violations.
- `references/patterns.md` passes markdownlint with no new violations.
- `references/when-not-to-use.md` passes markdownlint with no new violations.
- `references/governance.md` passes markdownlint with no new violations.
- None of the files contain a runnable dependency on any `.workflow.js`
  file (the S2 template library); any mention of the template library is an
  explicit "forthcoming (S2)" forward-reference, not a link to a file that
  must exist.

## Rubric

This is the deterministic lint check from AC-2 / FR-7. The forward-reference
clause is load-bearing: S1 must be lint-clean and valid *standalone*, with no
broken link to a file S2 has not yet shipped. A markdown link to a
non-existent `workflows/*.workflow.js` path would both mislead a reader and
risk a broken-link lint failure — so the scenario fails if the skill imports
or hard-links any template file.
