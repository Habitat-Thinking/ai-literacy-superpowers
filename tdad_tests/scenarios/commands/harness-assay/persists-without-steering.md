---
component: harness-assay
component_type: command
tier: structural
---

# Scenario: /harness-assay persists the report without steering or editing it

## Given

The Assayer is read-only by construction, so this command holds the write. That
makes it the place two failures could enter.

The first is **steering**: a prompt that names the suspected defect turns the
assay into a confirmation, and no honesty rule protects against a question that
already contains its answer.

The second is **editing**: correcting the report into shape puts the command's
judgement into a record that claims to be the Assayer's observations — and assays
are append-only, so it cannot be undone later.

The validation checkpoint required by CLAUDE.md has a mechanical half and a human
half here, because the most important property — that a passing-check claim cites
observed output — is not something a linter can see.

## When

`ai-literacy-superpowers/commands/harness-assay.md` is read from the filesystem.

## Then

**Frontmatter:** `name: harness-assay`, a description stating the agent is
read-only and never self-triggers.

**Process:**

- Refuses to run mid-phase, on the ground that an assay of work still in flight
  is an assay of a guess.
- **Forbids passing a hypothesis** to the agent, with the reason.
- Derives a filesystem-safe timestamped path, and states that assays are
  append-only — an existing file is never overwritten.
- Writes the agent's returned content **verbatim**, and forbids editing it into
  shape, with the reason.
- Distinguishes itself from `/harness-audit`, `/governance-audit` and `/reflect`,
  and says the overlap is managed by the rejected-candidates rule.

**Validation checkpoint:** invokes `harness-registrar.py lint-assay` for the
mechanical half, then checks S1–S6 for what a linter cannot see — including S2
(every passing-check claim cites observed output), S3 (absent sources named as
absent), S4 (**Rejected candidates** non-empty or explained) and S5 (conflicting
evidence left unresolved).

States that a lint failure is fixed by **re-running the agent**, never by editing
the record.

**Next steps:** offers `/diaboli` on the assay for anything proposing a
`harness-loop` change, and warns that not every finding should be proposed —
three accepted records per cycle is the cap.
