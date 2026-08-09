# Parking record format

A **parking record** captures one live thread of work at the moment a session
closes, so that stopping costs nothing and resuming starts from a concrete
step rather than from a cold read of yesterday's diff.

Records live in `docs/superpowers/parked/`. They are written by the `/coda`
command after the human has confirmed the next action — never by the `coda`
agent, which is `role: sentinel` and read-only.

Owned by the Cadence Sentinels S1 slice. A consumer never mutates the contract
it consumes: a slice that needs a new field carves its own contract-owning
slice with its own adversarial pass.

## Filename

```text
docs/superpowers/parked/<YYYY-MM-DD>-<slug>.md
```

State lives **in the filename**, and a transition writes a new file:

```text
2026-08-08-retry-branch.md              # parked
2026-08-09-retry-branch.resumed.md      # resumed — supersedes the above
2026-08-09-retry-branch.superseded.md   # superseded
```

## Append-only

Records are append-only. A record is **never edited in place and never
deleted**. Resuming a parked thread writes a `.resumed.md` file naming its
predecessor in `supersedes:`; it does not change the predecessor.

This is why state is in the path rather than in a mutable `status:` key —
editing a key from `parked` to `resumed` *is* an in-place edit, so a single
mutable field would have contradicted the append-only rule it claimed to obey.

The query for "what is still parked" follows from the same rule: every `*.md`
that is not itself a transition file and is not named by any transition's
`supersedes:`. It ships as `records_open` in
`hooks/scripts/lib/record-paths.sh` rather than as prose, so consumers share
one answer.

## Frontmatter

```yaml
---
session: <sanitised session id>
repo: <absolute path to project root>
created: <YYYY-MM-DD>
state: parked | resumed | superseded
supersedes: <filename> | null
next_action_flag: asked
---
```

| Field | Meaning |
| --- | --- |
| `session` | Opaque provenance only — **never a lookup key**. See the warning below. |
| `repo` | Where the parked work lives. |
| `created` | The date the record was written. |
| `state` | Restates what the filename says, for readability. The **filename is authoritative**. |
| `supersedes` | The record this one replaces, or `null`. |
| `next_action_flag` | Always `asked`. The next action comes from the human, never from inference. |

> **`session` is not a lookup key.** The session registry forgets an entry one
> lease after its last heartbeat (12 hours by default). A parking record is
> permanent. Resolving a record's `session` against the live registry will
> therefore fail for every record older than a lease, and succeed misleadingly
> for a reused id. Treat it as provenance and nothing more.

## Body

Two sections, both required.

```markdown
## Context

One paragraph: what this thread is, and what state it was left in.

## Next action

A single concrete resume step.
```

### The next action is validated

`next_action` is **mandatory and validated**. A vague next action is refused
with a reprompt, because a vague plan does not do the work a written plan
does:

- ❌ "continue work"
- ❌ "carry on with the parser"
- ✅ "implement the retry branch of slice 7's error path, starting from the
  failing test in `test_retry.py`"

Specificity is the active ingredient, not completeness. A thread parked with a
concrete next step stops pulling at the person who parked it; one parked with
"continue work" does not.

### The anchor grammar

`scripts/next-action-hint.sh` decides whether the Coda asks **once more**. A
next action carries an anchor when it contains at least one of:

| Anchor | Pattern |
| --- | --- |
| A path | a token containing `/` or a known file extension |
| A code identifier | a token containing `_`, `::`, or `()`, or in `Some.Case` form |
| A backticked span | anything inside backticks |
| A scenario or ticket id | a letter-digit token such as `B12`, `R4`, `#492` |
| A line or section reference | `file:12`, `§3.2`, `line 40` |
| A decision | a question word, a named person, or `ask` / `decide` / `choose between` |

**This is a trigger heuristic, and its complement is not "vague".** A next
action carrying no anchor gets one question. It does not get a verdict, and it
is not being called imprecise. The table says what makes the Coda *stop
asking* — not what makes a next action good.

The decision row exists because the other five are artefacts of code-shaped
work, and much of what gets parked is a spec, a piece of prose, or a decision.
Without it the check would tax the dominant kind of thread at every close.

### When the author was asked twice

The Coda never refuses a next action. If the check triggers and the author
gives the same answer again, the record is written with their answer plus a
line in their own voice:

```markdown
## Next action

continue work

(Asked again for a starting point; confirmed this is enough to go on.)
```

**That line, not a frontmatter flag, is where the override lives.**
`next_action_flag` is `asked` for every record; there is no second value.

A flag recording that someone's answer failed a check would be an
agent-authored verdict about the person — permanent, committed, and countable
across records. That is a claim *about* the human rather than *by* them, which
the `sentinel-design` boundary forbids, and the operational-state carve-out
cannot rescue it because these records are committed and permanent.
