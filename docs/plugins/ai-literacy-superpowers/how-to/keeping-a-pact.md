---
title: Keeping a pact
---
# Keeping a pact

A limit you set for yourself in advance holds. A limit you set in the moment
you are about to breach it does not — you will simply move it, because the
thing you want at 18:00 is to keep working.

That is the whole idea. You author a pact in clear weather, and `/mast` brings
it back into view later.

## Make one

```text
/mast tune
```

It asks your **stop hour first**, then offers to stop there. A useful pact can
be two lines and one question.

If you keep going it offers the rest — how many sessions a day, your focus
blocks, a cost ceiling — and every one is skippable. Before it asks about
anything nothing reads yet, it says so, so you never declare a value believing
something acts on it.

It **never suggests a number.** Not even the template's. A limit you accepted
because it was pre-filled is not one you set, and being the one who set it is
the part that makes it work.

Then it shows you the block it composed and writes only if you accept.

Your pact lives at `~/.claude/pacts.md`. It is yours, it is per-machine, and it
is **never committed** — nothing about how you work goes into any repository.

## Read it

```text
/mast
```

It reads your own words back to you first, then says what it can and cannot
see:

| Key | What the Mast knows |
| --- | --- |
| `hard_stop_hour` | Whether the clock is past it |
| `focus_blocks` | Whether the clock is inside one — **not** whether you spent it working |
| `sessions_per_day` | Roughly, from live sessions only — it keeps no day's log |
| `daily_cost_ceiling` | **Nothing.** It cannot see spend, and will not guess |

Only one row ever really moves. That is deliberate: the alternative to saying
"I can't see this" is inventing a number, and a made-up spend figure against a
real ceiling would have you stop, or not stop, for no reason.

## Change one

```text
/mast tune budgets
```

It shows your current values as it asks — *your line is 18:30; what should it
be?* That is your own earlier answer, not a suggestion.

Changing your pact in calm weather is exactly what it is for. Do it whenever it
stops fitting.

## The one thing it notices

If you tuned your budget **today**, `/mast` says so — this pact hasn't been
lived with yet, which is worth knowing when it asks something of you tonight.

It also tells you what it cannot notice, and this is worth reading once:

> A pact edited outside `/mast tune` is invisible to this check.

If you open the file and change your stop hour by hand at 18:00, nothing will
mention it. That is a real limit, not a soft one — the file is never committed,
so there is nothing to compare against. The check is honest about what it
misses rather than implying it catches everything.

## What it will never do

- **Stop you.** Nothing here blocks, gates, or requires an answer.
- **Guess.** Especially not at spend.
- **Judge your pact.** Your stop hour is not too late. It is yours.
- **Write anything you didn't accept.** No pact is scaffolded, ever.

## See also

- [The cadence discipline](../explanation/cadence-discipline.md) — why this sentinel is built the way it is, and what it shares with the other three
