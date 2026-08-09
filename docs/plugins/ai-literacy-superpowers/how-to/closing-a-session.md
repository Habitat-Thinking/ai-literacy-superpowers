---
title: Closing a session
---
# Closing a session

An agentic session has no terminal cue. There is no compile, no deploy, no
colleague standing up to leave — nothing in the medium says *this is finished*.
So sessions tend to end by attrition: you stop when something interrupts, and
the work stays in whatever state the interruption found it.

`/coda` is the deliberate alternative.

## Run it

```text
/coda
```

That is the whole invocation. It takes a few minutes and asks you a small
number of questions.

## What happens

**1. It surveys.** What landed — commits, merged PRs, dispositions you
resolved. What is still live — uncommitted files, an open PR, records still
carrying `pending`, and anything parked in an earlier session.

Each line is flagged. `observed` for what it read off disk, `inferred` where a
`gh` call failed and it is telling you so rather than reporting an empty
result, `asked` for the one judgement it does not make alone.

**2. It proposes a grouping, and you correct it if it is wrong.** Nine modified
files might be one thread or three. That judgement decides how many records get
written and what each says, so it is yours — but the proposal stands unless you
change it. You are finishing, not starting; the ritual should not hand you its
hardest thinking at the moment you least want it.

**3. It asks for a next action per thread.** One concrete resume step.

If your answer carries nothing to start from, it asks once more — naming a
file, a test, or a decision. **It never refuses.** Whatever you say next is
parked, including the same words again; if you repeat yourself, the record
notes in your own voice that you were asked and confirmed this was enough.

That question exists for a reason worth knowing: a written plan for an
unfinished task releases its pull, and *specificity* is the active ingredient
rather than the writing. "Continue work" is a written plan and does nothing.

**4. It writes and commits the records**, then runs `/reflect` for the closure
summary, then stops.

## Picking a thread back up

Parked records surface at the start of your next session — once, on startup
only, so a compact or a resume never hands them back mid-session.

When one is finished:

```text
/coda resume 2026-08-08-retry-branch.md
```

That writes a `.resumed.md` transition naming its predecessor. Nothing is ever
edited or deleted; the trail stays intact.

`/coda` also asks about anything still open each time it runs, so a thread you
finished quietly gets closed without you having to remember a command.

## Stopping the ritual

Say so. It stops, and tells you exactly what has already been written.

Records are append-only, so a record already written cannot be withdrawn — it
will say which ones exist rather than pretending they can be undone.

One thing it will *not* do is take on new work once the ritual has started. A
"while we're here" request gets parked instead of executed. That drift is the
thing `/coda` is for: the ritual that was about to end the session becoming the
preamble to another hour.

Changing your mind about stopping is different, and always yours.

## `/coda` or `/reflect`?

| You want to | Run |
| --- | --- |
| Capture one surprise and keep working | `/reflect` |
| Stop for the day, or stop with this piece of work | `/coda` |

`/coda` calls `/reflect` as part of its own ritual, so you never need both.

## What it will never do

- Decide that your session should end. You invoke it.
- Grade your wording. The check asks a question; it renders no verdict.
- Record *why* you stopped. That a session closed and what was parked is the
  record. Why is not, ever.
