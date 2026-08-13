---
title: The cadence discipline
sentinels: [coda, mast, wip-warden, convener]
---
# The cadence discipline

Four sentinels guard the **shape of the work** around decisions, rather than
the decisions themselves.

The [decision-discipline triad](decision-discipline-triad.md) asks whether a
decision is sound: is it small enough to hold, has it been attacked, does it
know what it chose. Those questions assume a person in a condition to answer
them. The cadence discipline is about that condition — how a session ends, what
limits survive the moment they govern, how much is open at once, and who was
never asked.

| Sentinel | Guards | Attacks |
| --- | --- | --- |
| [`coda`](../how-to/closing-a-session.md) | the ending | attrition — sessions that stop by running out rather than by decision |
| [`mast`](../how-to/keeping-a-pact.md) | the pact | in-the-moment renegotiation of a limit set in clear weather |
| [`wip-warden`](../how-to/watching-your-wip.md) | the count | thrash — more open at once than anyone can hold |
| [`convener`](../how-to/convening-the-voices.md) | the room | isolation drift — the question nobody outside the room was asked |

`carpaccio` is the forerunner. It governs cadence too — it exists so a decision
arrives small enough to hold — but it does so by slicing the *work*, which puts
it in the triad. The four here act on the session rather than the task.

The `reservoir-warden` belongs to neither discipline. It watches *the decider*,
and it is deliberately advisory-forever: gating lives here, so that the one
agent observing the human never acquires teeth.

## What these four share

### They are read-only, and the boundary is the mechanism

Every one holds `Read`, `Glob`, `Grep` and no `Write`. That is enforced
deterministically — `scripts/sentinel-integrity-check.sh` fails CI if a
`role: sentinel` agent is granted `Write` or `Edit`.

The consequence is architectural rather than cosmetic. A sentinel *returns*
record content and a command persists it, so the record's dispositions can only
be written by a person opening the file. **That constraint is the
cognitive-engagement gate**, not a policy about it.

### The read/write library split

A sentinel may `source` a read library. Mutation lives in a separate
hooks-only library.

This exists because the frontmatter check cannot see a `source` line — it reads
the declared `tools` list and nothing else. An agent granted `Bash` for
read-only inspection could source a write surface and the integrity matcher
would stay green. So the surfaces are split at the file level:
`session-registry-read.sh` and `session-registry-write.sh`, `mast-notes-read.sh`
and `mast-notes-write.sh`.

The corresponding test greps for a **`source` construct**, not a filename — an
early version failed on an agent's own charter, which names both surfaces in
the sentence forbidding them. A good charter says what it refuses, and a grep
cannot tell naming from doing.

### Records live in the filename, not in a `status` key

Records are append-only: never edited in place, never deleted.

Editing a `status:` key from `parked` to `resumed` **is** an in-place edit, so
the rule and the mechanism contradicted each other. State moved into the path
instead:

```text
2026-08-08-retry-semantics.md              # open
2026-08-09-retry-semantics.resolved.md     # resolved — supersedes the above
```

"What is still open" becomes a query over names rather than a scan of mutable
frontmatter, and the two finally agree. Two queries answer the two real
questions: `records_open` for what is outstanding, `records_latest` for the
current state of each chain — including the transition files `records_open`
excludes by name.

### Operational state is a third category

The category rule says a sentinel persists nothing **about the person**.
Records describe sessions, work, budgets and decisions — never assessments of
someone's state, capacity, or fatigue.

The session registry sits awkwardly against that: it is state about *how someone
is working*. The carve-out is narrow and every clause load-bearing.
**Operational state may be persisted only when it is**:

- **local and never committed** — outside every work tree, so nothing can leak
  into a repo by accident
- **bounded** — entries expire by lease rather than accumulating
- **judging nothing** — a count and a timestamp, never an inference from them
- **disclosed and declinable** — the person can see it and switch it off

A count of open sessions passes. "Three sessions is a lot to be holding" does
not, and no script can tell them apart — a word-ban was tried and rejected,
because it would pass every sentence that actually violates the boundary while
failing on `focus_blocks`, a live pact key. It is held by whoever writes the
output.

### Two declaration surfaces, because two different things declare

`HARNESS.md` is the **repository's** surface: constraints, stakeholders, what
this project requires of anyone working in it. The **pact file** is the
**person's**: a stop hour, a WIP limit, a budget — and it lives outside every
work tree, because a limit you set for yourself is not a rule your colleagues
inherit.

The Convener's `## Stakeholders` section went *into* `HARNESS.md` by the same
reasoning that sent pacts out of it: who a project affects is a property of the
project; a stop hour is a property of a person.

## Two mechanisms worth knowing

### The advisory rail: precedence, not order

Two sentinels counsel stopping on the same `Stop` rail, and two messages about
stopping arriving together is accumulated pressure — which works *worse* than
one.

The first design was first-claim-wins with the reservoir check ordered first.
That preserved the message that **repeats** and permanently spent the one
designed to arrive **once**: the reservoir check has no once-per-session guard
and cannot have one, because it persists nothing by charter and re-emits
whenever a threshold is still crossed. The Mast's `reached` notice fires once,
ever.

So the rail arbitrates by precedence: **a once-only advisory speaks, and a
repeating one defers** to the next turn it is going to get anyway. A rail built
to reduce accumulated pressure was, in its first form, protecting the source of
it.

### The lease renews on every turn, because `Stop` is not session-end

`Stop` fires at the end of every **assistant turn**, not at the end of a
session. A registry that retired an entry on `Stop` would retire it after the
first exchange.

So an entry is *renewed* on `Stop` — a heartbeat — and retired only by expiry.
The count is therefore honest about what it can see: it is at least the number
of live sessions, flagged `inferred` when an entry cannot be read, and never
presented as exact.

## What none of them do

- **None contacts anyone.** The Convener drafts a question and stops; a
  question is one sentence a person could answer, and a message has a
  salutation, a context paragraph, or a sign-off.
- **None auto-blocks silently or auto-approves.** Every gate ends in a human
  disposition recorded in a file.
- **None estimates what it cannot observe.** Each observation is flagged
  `observed`, `inferred`, or `asked`; when a value cannot be observed, the
  sentinel says so rather than guessing.
- **None invents a limit.** A pact block with its clause and no limit is a
  normal file, and reporting a breach of a line the human never drew is the
  worst output this substrate can produce.
- **None can compel.** `enforcement: strict` asks for a disposition and says
  plainly that nothing here can hold a session open or shut.

## See also

- [Sentinels](sentinels.md) — the category, its three-part signature, and the
  full roster
- [The decision-discipline triad](decision-discipline-triad.md) — the other
  discipline
- [Watching the verifier](watching-the-verifier.md) — the `reservoir-warden`,
  which belongs to neither
- [Progressive hardening](progressive-hardening.md) — rung and reach, the two
  axes these constraints ship along
