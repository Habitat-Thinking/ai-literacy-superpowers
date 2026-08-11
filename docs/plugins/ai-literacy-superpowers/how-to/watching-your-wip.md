---
title: Watching your WIP
---
# Watching your WIP

Three sessions open across three repositories is not three times the work. It
is one person switching, and the switch is paid for in the quality of every
decision after it.

## See where you are

```text
/wip
```

You get how many sessions are live, which they are, how long since each last
took a turn, and where each one is.

If you have declared a limit, you get the comparison too.

## Set a limit

```text
/mast tune
```

`max_concurrent_sessions` is how many sessions you are willing to have live at
once, counted across every repository on this machine — **including the one you
are in**. Two means two.

If you have not set one, `/wip` says so and points you here. It will never pick
a number for you: a limit you did not choose is not a limit, it is a default
wearing one's clothes.

## What happens when you are over

At the start of a session, once:

```text
3 sessions live; your limit is 2.

  - sess-a — 4h since its last turn — ~/code/alpha
  - sess-b — 12m since its last turn — ~/code/beta
  - sess-c — 0m since its last turn — ~/code/gamma
```

The ages are what make that useful. `sess-a` has not taken a turn in four
hours — that is the one to park. Ages are measured from each session's **last
turn**, not from when it started, because otherwise the session you are
actively working in would always look like the oldest and therefore the obvious
one to close.

If you set `enforcement: strict`, it also asks — park one, or say what is
urgent enough to keep them all open.

**It cannot stop you.** Nothing in this plugin can hold a session, and it says
so rather than implying otherwise. If you keep going, you keep going. What you
say in answer isn't written down anywhere, and it tells you that too.

## Parking one

That is `/coda`'s ritual:

```text
/coda
```

It surveys what is live, asks for one concrete next step per thread, and writes
a parking record you can pick up later. `/wip` will offer it; it never parks
anything itself.

## What it will never tell you

It will not say you seem tired, or that you are taking on too much, or that
three is a lot. **It counts sessions. It does not watch you.**

That is deliberate, and it is what lets `/reservoir` — which *does* watch the
verifier — stay worth trusting. If one sentinel started inferring your state
from a session count, you would have reason to wonder what else was being read
from what you told the other.

Nothing enforces that boundary automatically. It is a promise held by the
people who write the output.

## Approximate counts

Sometimes you will see "at least 3 sessions live". That means the registry
could not be certain — a session's lease expired without being swept, or an
entry may stand for more than one session.

The count is never presented as exact when it is not. If you need certainty,
you know better than it does: it can only see sessions that have taken a turn
recently.
