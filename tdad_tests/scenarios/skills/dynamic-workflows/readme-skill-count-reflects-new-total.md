---
component: dynamic-workflows
component_type: skill
tier: structural
---

# Scenario: README skill-count badge/text reflects the new total of 36 (S1 GATE pull-in)

## Given

The repository `README.md`, after the `dynamic-workflows` skill lands.

## When

The skills badge (line ~9, `img.shields.io/badge/Skills-...`) and the
`ai-literacy-superpowers` plugin-table row (line ~31, "**N skills, ...**")
are read.

## Then

- The shields.io skills badge reads `Skills-36` (not the stale `Skills-35`).
- The plugin-table row text reads "**36 skills, ...**" (not "**35 skills**").

## Rubric

The spec (§6.3) deliberately deferred the badge/count correction to S7, but
the human pulled it into S1 at the GATE — so for S1 the README must reflect
the true filesystem count of 36 skills once `dynamic-workflows` is added.

This is a lightweight count-consistency check, not CI-enforced (no
skill-count grep workflow exists), so it is verified by reading the two
README locations. It is RED while the README still reads `35`.

The plugin-version bump (`0.57.0 → 0.58.0`) and the marketplace/plugin.json
version locations are covered by the separate `Version Check` CI gate, not by
this scenario.
