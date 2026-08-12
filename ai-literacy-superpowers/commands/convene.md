---
name: convene
description: Run the Convener on a spec — maps the roles and groups it affects, drafts the concrete question worth asking each one, and writes the consultation record at docs/superpowers/consultations/<slug>.md; never contacts anyone; use at plan approval alongside /choice-cartograph
---

# /convene \<spec-path\>

Run the convener agent against a spec file, prune and add voices with the
human, and write the structured consultation record. Use at plan approval,
after spec-mode `/diaboli` dispositions are resolved and alongside
`/choice-cartograph`.

**This command never contacts anyone.** It maps voices and drafts questions.
The human carries every conversation, or the conversation does not happen.

## When to use

- At plan approval, beside `/choice-cartograph`, on any spec that changes
  something outside the room — a user-facing surface, a published document, a
  default, an error message, a behaviour rather than an internal
- When a spec is substantively edited after a consultation record exists —
  this writes a `.superseded.md` transition rather than editing in place
- Never as a substitute for talking to someone

## Process

### 1. Validate input

Confirm the spec file exists at the given path. If not, abort with:

```text
Error: spec file not found at <path>. Pass a valid path under docs/superpowers/specs/.
```

### 2. Derive the slug

Strip the date prefix and `.md` extension from the filename — the same
convention the objection and story records use, so one spec resolves to one
record across all three.

Example: `docs/superpowers/specs/2026-08-12-retry-semantics-design.md` →
slug `retry-semantics-design`.

Output path: `docs/superpowers/consultations/<slug>.md`

### 3. Dispatch the convener agent

Pass the spec file path. The agent reads the spec, `HARNESS.md`'s
`## Stakeholders` section if one exists, and the matching objection and story
records, then returns the full consultation-record content with every voice
`disposition: pending`.

Do not pass any prior consultation record — the agent maps fresh.

### 4. Prune **and add**, with the human

Show the proposed voices as a numbered list, each with its question and its
`source_flag`. Then ask, in one exchange:

```text
Voices proposed for <slug>:

  1. Support   [inferred]  when this returns the new error code instead of
                           timing out, does that change what you tell people
                           who call about it?
  2. Docs      [observed]  the published reference describes the 30-second
                           timeout as guaranteed — is that page generated, or
                           maintained by hand?
  3. PO        [inferred]  this changes behaviour for existing integrations on
                           upgrade rather than behind a flag. Fine this
                           quarter, or does it wait?

Which of these do not apply? (numbers, or "none")
Who did it miss? (a role or group, or "nobody")
```

**Both directions, every time.** The prune half is cheap for the human and
the add half is where the value usually is: the highest-leverage voice in a
session is typically the one the agent could not derive.

A voice the human names is written with `source_flag: asked`. Ask them for
the question to put against it; if they would rather not draft one, ask the
agent to draft one for that voice and keep the flag `asked` — the flag
records **who named the voice**, not who wrote the question.

Never argue a voice back onto the list. The human knows their organisation
and the agent does not.

### 5. Write the consultation record

Write the pruned-and-extended content to
`docs/superpowers/consultations/<slug>.md`.

**Records are append-only.** If a file already exists at that path:

1. Write the new record to `<slug>.md` only if no record exists.
2. Otherwise write `<slug>.superseded.md` naming the prior file in
   `supersedes:`, and tell the user which record it replaces.

Never edit an existing record in place, and never delete one. State lives in
the filename.

### 6. Validation checkpoint

Read back the written file and check:

- **F1** — frontmatter carries `spec`, `date`, `state`, `supersedes`, and a
  `voices` list. Fix in place from the agent's output if any is missing.
- **F2** — every voice has `voice`, `source_flag`, `question`,
  `disposition`, `outcome`.
- **F3** — every `disposition` is `pending`. A pre-filled disposition is the
  cognitive-engagement gate defeated; reset it to `pending` and say so.
- **F4** — every `source_flag` is `observed`, `inferred`, or `asked`, and a
  voice is flagged `observed` **only** if `HARNESS.md`'s `## Stakeholders`
  section names it. Downgrade to `inferred` otherwise.
- **F5** — no voice names an agent, a sentinel, or an individual person.
  Drop any that does, and say which and why.
- **F6** — no `question` field carries a salutation, a context paragraph, or
  a sign-off. A question is one sentence a person could answer. Rewrite in
  place to the question alone.
- **F7** — at most 8 voices. If more, keep the highest-ranked 8 per the
  skill's ranking criteria and tell the user which were dropped.
- **F8** — the record resolves: `docs/superpowers/specs/<date>-<slug>.md`
  exists.

Fix deviations **in place**. Do not re-dispatch the agent.

### 7. Present the record to the user

Show:

- Output path, and whether it superseded a prior record
- Voice count, and the `source_flag` distribution
- Whether the project declares a `## Stakeholders` section — and if not, say
  plainly that every voice is `inferred` and the list is therefore shorter
  and less certain than a declared map would produce
- A reminder:

```text
Edit docs/superpowers/consultations/<slug>.md to set each voice's
disposition to `consulted` or `deliberately-not-consulted`, each with a
one-line `outcome`.

Both are complete answers. Deciding not to ask someone, for a stated
reason, is a real decision made deliberately — that is the point.

Each outcome must name something specific to that voice: the merge-time
check refuses one string standing for several decisions. It never judges
your reasons.

The plan-approval gate is SOFT — a `convene_pending_count` is surfaced and
the plan may be approved with every voice still pending. The merge-time
HARNESS constraint **PRs have disposed consultation voices** is the forcing
function, and it is complete-if-present: a PR with no consultation record
passes.
```

### 8. Suggest next steps

If invoked manually (not via orchestrator):

- Carry the conversations yourself. Then record what came back.
- Resolving dispositions at plan-approval time is cheaper than at merge time
  — the context is fresh, and a question asked before implementation can
  still change the spec.
- Once disposed, write the `.resolved.md` transition naming the open record
  in `supersedes:`. Never edit dispositions into the existing file.
