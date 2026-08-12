# Consultation record format

A **consultation record** names the voices a spec affects, the concrete
question worth asking each of them, and what was decided about each — either
that they were consulted, or that they deliberately were not, and why.

Records live in `docs/superpowers/consultations/`. They are written by the
`/convene` command after the human disposes; the `convener` agent is
`role: sentinel` and read-only.

The Convener maps voices and drafts questions. It never contacts anyone, and
it never treats an agent as a consultable voice.

Owned by the Cadence Sentinels S1 slice. A consumer never mutates the contract
it consumes.

## Filename

```text
docs/superpowers/consultations/<spec-slug>.md
```

**`<spec-slug>` is the spec's filename with its date prefix and `.md`
extension stripped** — the same convention the objection and story records use,
so one spec resolves to one record across all three. Added 2026-08-12: the
first revision gave `<YYYY-MM-DD>-<slug>.md` without saying what `slug` was or
how it related to the `spec:` field, which left a consumer unable to answer
"does this spec have a record" without guessing.

State lives **in the filename**, and a transition writes a new file:

```text
2026-08-08-retry-semantics.md              # open
2026-08-09-retry-semantics.resolved.md     # resolved — supersedes the above
2026-08-10-retry-semantics.superseded.md   # superseded on spec revision
```

## Append-only

Records are append-only. A record is **never edited in place and never
deleted**.

Because dispositions accumulate during a review, a consultation record is
written once per **revision**: disposing voices produces a new `.resolved.md`
file carrying the full voice list with its dispositions filled in, naming the
open record in `supersedes:`. The frontmatter of a written record is never
edited — which is what keeps the rule true, since editing a per-voice
`disposition` inside an existing file would be an in-place edit of a record
the rule says is immutable.

`records_open` in `hooks/scripts/lib/record-paths.sh` answers "which
consultations are still open" from the filenames.

## Frontmatter

```yaml
---
spec: <path to the spec under approval>
date: <YYYY-MM-DD>
state: open | resolved | superseded
supersedes: <filename> | null
voices:
  - voice: <role or group>
    source_flag: observed | inferred | asked
    question: <the concrete question worth asking them>
    disposition: pending | consulted | deliberately-not-consulted
    outcome: <one line> | null
---
```

| Field | Meaning |
| --- | --- |
| `spec` | The spec under approval. |
| `date` | The date the record was written. |
| `state` | Restates the filename, for readability. The **filename is authoritative**. |
| `supersedes` | The record this one replaces, or `null`. |
| `voices` | One entry per material voice. |

### Per-voice fields

| Field | Meaning |
| --- | --- |
| `voice` | A role or group — never a named individual, and never an agent. |
| `source_flag` | How the voice was identified. `observed`: a declared stakeholder map named it. `inferred`: derived from the change itself. `asked`: the human named it. |
| `question` | The actual question worth asking them. Not "sync with X". |
| `disposition` | `pending` until a human decides. |
| `outcome` | One line. **Required** when the disposition is `deliberately-not-consulted` — that path needs its because. |

## The gate is soft

At plan approval, unresolved voices are **listed, not blocking**. An
agent-verified merge-time check flags a spec whose consultation record still
carries a voice with no disposition. It is never escalated to deterministic
enforcement.

A voice recorded as `deliberately-not-consulted` with a stated because is a
complete, healthy disposition — not a debt. The record exists to make the
decision visible, not to require that everyone be asked.
