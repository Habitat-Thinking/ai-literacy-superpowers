---
component: dynamic-workflows
component_type: skill
tier: structural
---

# Scenario: dynamic-workflows SKILL.md is markdownlint-clean and its template references resolve (AC-2, AC-3)

## Given

The `dynamic-workflows` skill's `SKILL.md` and its three reference files
(`references/patterns.md`, `references/when-not-to-use.md`,
`references/governance.md`) exist, and — as of S2 — the four `*.workflow.js`
templates exist under `workflows/`.

## When

markdownlint runs over the markdown files — via the existing PreToolUse hook
at edit time and the `lint-markdown` CI workflow — and `SKILL.md`'s template
references are resolved against the filesystem.

## Then

- `SKILL.md` passes markdownlint with no new violations.
- `references/patterns.md` passes markdownlint with no new violations.
- `references/when-not-to-use.md` passes markdownlint with no new violations.
- `references/governance.md` passes markdownlint with no new violations.
- `SKILL.md` references the four S2 templates by relative path
  (`workflows/<name>.workflow.js`) and **every referenced path resolves to an
  existing file** — the S1 "forthcoming (S2)" forward-reference is gone.

## Rubric

This is the deterministic lint + reference-resolution check (AC-2 lint, AC-3
resolution). **S2 reconciliation:** the S1 form of this scenario asserted that
SKILL.md contained *no* hard-link to a `.workflow.js` file and that any mention
was a "forthcoming (S2)" forward-reference. That property was correct for S1's
standalone validity but is now **false by design** — S2 ships the templates and
SKILL.md links them by relative path. The load-bearing clause is therefore
replaced: SKILL.md's references must *resolve* (the AC-3 property), not be
*absent*. The markdownlint-clean assertion is retained — the flipped section
and any new links must still pass markdownlint with no broken-link or
formatting violations. A reference that does not resolve to an existing file
both misleads a reader and risks a broken-link failure, so the scenario fails
if any of the four template paths is dangling.
