---
component: harness-timeline
component_type: command
tier: structural
---

# Scenario: /harness-timeline derives rather than declares, and reads no clock

## Given

The feed exists to support a difference-in-differences analysis, and two
properties decide whether it can.

A feed carrying a **time-varying** field produces different output on different
days from a corpus nobody touched, so a run in November would disagree with the
same run in September. And an intervention with **no end** is a step function
that never steps back: every rule ever retired would still be counted as in
force.

`direction` is the field the analysis actually turns on, which makes it the last
place to accept a self-report.

## When

`ai-literacy-superpowers/commands/harness-timeline.md` is read from the
filesystem.

## Then

**Frontmatter:** `name: harness-timeline`, a description stating it writes to
stdout, derives direction, and carries no field depending on the current date.

**Body:**

- States why it is **not a stored artifact**: a committed derivative drifts, and
  `/harness-check` would then have to police it.
- States that it carries no field depending on today, with the November/September
  consequence spelled out, and that `expires` is emitted **as data** for the
  consumer to interpret.
- States that every intervention has an end, via `superseded_by` and `ends`, and
  gives the interval as `[date, ends)`.
- Tabulates the fields, and derives `direction` from the ladder
  `advisory < validated < blocked`, with surfaces breaking the tie only at equal
  enforcement and overlapping-but-different sets resolving to `same`.
- States that a `no-change` record is `none` and is included deliberately — a
  control observation, not an absence, because "we looked and decided no" and
  "nobody looked" are the difference a governance study measures.
- Excludes `proposed` and `rejected` records, with the reason that nothing was
  ever in force.

**Forbidden:** writing a file, reading the clock, and accepting a declared
direction.
