---
name: coda
description: Use when closing an agentic session deliberately rather than by attrition — carries the four-step ritual (survey, park, closure summary and reflection, close), the anchor grammar behind the next-action question, the evidence for why a specific written plan releases an unfinished thread, and the anti-patterns that would turn a closing ritual into a gate on the person
---

# The Coda

An agentic session has no terminal cue. There is no compile, no deploy, no
colleague standing up to leave — the medium supplies nothing that says *this is
finished*. So sessions end by attrition: the human stops when something
external interrupts, and the work is left in whatever state the interruption
found it.

Two costs follow. The unfinished threads keep their pull, because nothing wrote
down where they were. And the next session opens cold, re-deriving from a diff
what the previous session already knew.

> **The Coda** — the good ending. A ritual that closes a session deliberately,
> records what landed, and parks every live thread with a concrete resume step.

**What it attacks:** *drift* — the "while we're here" extension nobody
deliberately chose — and the cold-start cost of an unrecorded stop.

Not compulsive continuation itself. The Coda's only defence against continuing
is a refusal that steps aside the moment the human plainly asks it to, and a
plain request to continue is the shape that failure mode takes. Claiming
otherwise would be an overclaim in the sentence that names the sentinel.

## The ritual

Four steps, same order every time.

| # | Step |
| --- | --- |
| 1 | **Survey** — what landed, what is still live |
| 2 | **Park** — one record per thread, committed |
| 3 | **Closure summary and reflection** — via `/reflect` |
| 4 | **Close** |

### Why parking comes before reflection

The portable reason: the closure summary names what was parked, and it can
only do that if parking has already happened.

The local reason, where a *Reflections via PR workflow* constraint is declared:
`/reflect` is not a write-a-fragment-and-return operation. It branches,
commits, pushes, opens a PR, waits on CI, merges, and pulls `main`. Run before
parking, it would move the working tree off the branch holding the very
uncommitted work the survey had just enumerated. A closing ritual that
rearranges your git state is the most expensive way to stop yet designed.

Parking records are committed at step 2, before `/reflect` runs — `/reflect`
stages only the reflection paths, so without an explicit commit the ritual
would publish a summary describing records it left behind uncommitted in a
tree it had just relocated.

## The survey is flagged per item

<!-- evidence: the honesty discipline generalised from the reservoir warden —
     a blanket confidence claim over a mixed-provenance list is the failure it
     exists to prevent. -->

| Item | Flag |
| --- | --- |
| Commits, working-tree state, dispositions in records | `observed` |
| Merged PRs, open-PR check state | `observed` when `gh` succeeds; `inferred` when it does not |
| Which files constitute one thread | `asked` |
| Boundary events this session | `observed` |

**Thread grouping is the central epistemic act.** Nine modified files are an
observation; that they are *two* threads is a judgement, and it decides how
many records exist and what each says. The Coda proposes a grouping and it
stands unless the human changes it — propose-and-default-accept, because this
step lands after the human has already decided they are finished.

Flags are **ritual-scoped**. They are shown during the survey and do not travel
into the record: parking records are handoffs, not provenance artefacts. Where
provenance matters for a thread, it goes in the record's `## Context` prose.

## The next action, and why it is asked for

<!-- evidence: Masicampo & Baumeister 2011 — a specific written plan, not
     completion, releases the unfinished-task pull. Specificity is the active
     ingredient, which is why the ritual asks for a starting point. It is also
     why the check that follows must not become a grade: the effect comes from
     the human having a plan they believe, not from passing a test. -->

A written plan releases an unfinished thread's pull, and **specificity is the
active ingredient** rather than the writing. "Continue work" is a written plan
and does nothing.

So the ritual asks for one concrete resume step per thread, and
`scripts/next-action-hint.sh` decides whether to ask **once more**.

### The anchor grammar

A next action carries an anchor when it contains at least one of:

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
asking*, not what makes a next action good.

The decision row exists because the other five are all artefacts of code-shaped
work, and much of what gets parked is a spec, a piece of prose, or a decision.
Without it the check would tax the dominant kind of thread at every close.

### When the human repeats themselves

Park it. The record's `## Next action` carries their answer plus a line in
their own voice noting they were asked for a starting point and confirmed this
was enough.

That line, not a frontmatter flag, is where the override lives. A flag
recording that a human's answer failed a check would be an agent-authored
verdict about the person — permanent, committed, and countable across records.

## Closing a record

A parking record is closed by writing a `.resumed.md` transition, never by
editing or deleting. When the ritual runs and open records exist, the Coda asks
per record whether it is still live; a "no" writes the transition immediately.

Without that, closure would depend on someone remembering a command and the
corpus would only ever grow. Note the asymmetry: a session registry entry is a
*lease*, where forgetting costs nothing because it expires. A parking record is
the inverse — open by default until an act of bookkeeping closes it — so
forgetting produces an overcount, and the overcount is what a human sees at
every session start.

## Anti-patterns

An implementation doing any of these has stopped being a Coda:

1. **Refusing a next action.** The check asks; it never rejects. A sentinel
   that traps someone at the end of a session has become the thing it was
   built to prevent.
2. **Deciding the grouping alone.** That judgement determines the whole shape
   of the handoff and belongs to the human.
3. **Recording why the human stopped.** That a session closed and what was
   parked is the record. Why is not, ever.
4. **Continuing the ritual after being asked to stop.** Say what has already
   been written — records are append-only, so nothing can be withdrawn — and
   stop.
5. **Writing a file from the agent.** The agent returns content; the command
   persists it.
6. **Surfacing parked records more than once a session.** `SessionStart`
   re-fires on resume, clear and compact. Handing a thread back mid-session is
   the surface this exists to reduce.
