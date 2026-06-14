---
component: reservoir-check
component_type: hook
tier: behavioural
fixture: not-opted-in
---

# Scenario: reservoir-check stays silent when the project has not opted in

## Given

One of the following non-opted-in situations (spec
`docs/superpowers/specs/2026-06-14-reservoir-warden-design.md`, Scenario C;
FR-006):

1. A project whose `HARNESS.md` has **no** active `## Cognitive reservoir`
   heading — including the case where the heading appears only inside the
   commented template block (`<!-- ## Cognitive reservoir ... -->`), which must
   remain inert.
2. A project directory with **no** `HARNESS.md` at all.
3. A directory that is **not** a git repository (even if it has a HARNESS.md
   with the marker).

## When

The Stop hook runs at session end in each situation:

```bash
CLAUDE_PROJECT_DIR="$FIXTURE" bash ai-literacy-superpowers/hooks/scripts/reservoir-check.sh
```

## Then

- The script produces **no output** in every situation.
- The script exits **0** and changes nothing on disk.

## Rubric

Deterministic behavioural scenario covering the three self-gate branches
(FR-006). The commented-template sub-case is the important one: the gate matches
an **active** heading (`^#{1,6}\s+Cognitive reservoir`), so a freshly scaffolded
project that copied the template verbatim is **not** opted in. Asserts empty
stdout and exit 0 for all three fixtures.

## Cleanup

Remove the temporary fixture repositories.
