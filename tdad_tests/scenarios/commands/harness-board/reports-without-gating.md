---
component: harness-board
component_type: command
tier: structural
---

# Scenario: /harness-board reports without gating, and never omits what it cannot classify

## Given

A board is read instead of the records it summarises. That makes two failure
modes worse here than elsewhere.

If the board **recomputes** a refusal that `precheck` already computes, the two
implementations will diverge — and the divergence favours the board, because the
board is what someone reads. The record would be refused at the gate while the
board said it was ready.

If the board **omits** a record it cannot parse, it reports a smaller world than
it checked. That is the subject of the rule this repository currently has in
force, and a board is the worst place to reproduce it: the omission is invisible
precisely because the board is the thing you would use to notice.

A third property decides whether it stays true: a board that writes a file
becomes a file that goes stale. This repository carries two stored dashboards
that went 106 days unread, which is the evidence rather than the worry.

## When

`ai-literacy-superpowers/commands/harness-board.md` is read from the filesystem.

## Then

**Frontmatter:** `name: harness-board`, and a description stating it is read-only
and writes nothing.

**Body:**

- States that it **quotes `precheck`** for a proposed record's blocker rather
  than reimplementing the refusal, and gives the reason: two implementations
  diverge in favour of the one someone reads.
- States that a record it cannot classify appears under `UNCLASSIFIED` **with its
  path**, and gives the reason: omitting it would report a smaller world than was
  checked.
- States that it **writes no file**, that there is deliberately no `BOARD.md`,
  and cites the two dashboards that went unread as the reason.
- Distinguishes **IN FORCE** from **ACCEPTED BUT NOT BINDING**, and states that
  the distinction is read from the registrar's derived state rather than from
  `status`, because a superseded rule and a retirement are both `accepted` and
  neither binds.
- States that every blocked item carries a **concrete next action** rather than a
  state.
- Notes that disposition values are normalised for counting with the raw value
  surfaced, and that the divergence is permitted by the schema rather than an
  error.

**Forbidden:** proposing, accepting or disposing anything; writing any file;
exiting non-zero because of the corpus's state rather than its own failure.
