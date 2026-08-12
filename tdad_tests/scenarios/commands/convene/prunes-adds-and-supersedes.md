---
component: convene
component_type: command
tier: structural
---

# Scenario: /convene prunes and adds, then supersedes rather than edits

## Given

Records are append-only (constitutional constraint 7), and the consultation
record's state lives in its filename. A command that "updates" an existing
record by editing frontmatter would violate the rule while appearing to honour
it — the same contradiction that put state in the path in S1.

The validation checkpoint is required by CLAUDE.md for every command writing
structured markdown a downstream consumer parses. Here the downstream consumer
is a deterministic merge-time check, so a malformed record is not a cosmetic
problem: it fails CI on a file the human cannot easily see is wrong.

## When

`ai-literacy-superpowers/commands/convene.md` is read from the filesystem.

## Then

**Frontmatter:** `name: convene`, non-empty description that states it never
contacts anyone.

**Process:**

- Derives the slug by stripping the date prefix and `.md`, and names the output
  `docs/superpowers/consultations/<slug>.md`.
- Runs the prune-**and-add** dialogue in one exchange, asking both "which do not
  apply" and "who did it miss".
- States that a human-named voice is written `source_flag: asked`, and that the
  flag records **who named the voice**, not who wrote the question.
- Writes `<slug>.superseded.md` naming the prior record in `supersedes:` when a
  record already exists — never edits in place, never deletes.
- Carries a **validation checkpoint** with checks F1–F8, each with a
  fix-in-place recipe, including: every disposition reset to `pending`,
  `observed` downgraded to `inferred` unless `HARNESS.md` declares the voice,
  agents and named individuals dropped, salutations and sign-offs rewritten out
  of the `question` field, and the 8-voice cap applied.
- States the checkpoint fixes in place and does **not** re-dispatch the agent.
- Tells the user whether the project declares a `## Stakeholders` section, and
  says plainly when it does not that every voice is therefore `inferred`.
- States the plan-approval gate is soft and the merge constraint is
  complete-if-present.
