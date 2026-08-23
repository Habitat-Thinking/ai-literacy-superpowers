---
component: harness-review
component_type: command
tier: structural
---

# Scenario: /harness-review never edits a frozen record

## Given

Supersession conventionally writes `superseded_by` and `status: superseded` onto
the record being superseded. S2 made that impossible: an accepted record is
frozen, and `/harness-check` compares it against its content at the commit that
accepted it.

The resolution was to derive supersession from the successor's `supersedes:`
field rather than carve an exception into the one check that guarantees accepted
rules are not quietly reworded. This command is where that decision is most
likely to erode, because "just extend the expiry" is the obvious, cheap, wrong
move.

There is also a gap in the source design this command must not paper over: a
`review_trigger` is free text, nothing evaluates it mechanically, so a rule
carrying one and no expiry never lapses and is permanent by construction.

## When

`ai-literacy-superpowers/commands/harness-review.md` is read from the filesystem.

## Then

**Frontmatter:** `name: harness-review`, a description stating it is read-only
and that every outcome produces a superseding record.

**Body:**

- Tabulates the three outcomes — re-evidence, weaken, demote — and states that
  **all three produce a new record**.
- States that nothing edits the old record, and gives the reason: it is frozen,
  supersession is derived, and the record of what the rule cost and why it went
  is the output of the mechanism rather than its residue.
- Describes a demotion as a `## Rule` section saying `Withdrawn.`
- States that a **demotion has a cost too**, and that the validator refuses an
  empty one just the same.
- Surfaces trigger-only records in their own section, says plainly that they
  never lapse and never fail CI, and forbids quietly treating a trigger as
  satisfied.

**Validation checkpoint:** R1–R6, including R3 (neither record stores a derived
state) and R6 (the old record is still on disk).

**Forbidden:** editing an accepted record, deleting a record, and **extending an
expiry in place** — a rule that deserves more time deserves a new decision, with
a cost, written by whoever grants it.
