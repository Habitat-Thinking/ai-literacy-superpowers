---
title: Your first sentinels
---
# Your first sentinels

Most agents in this plugin act on an artefact. Sentinels act on **you** — they
inform, challenge, surface, or warn, and then stop. None of them writes code,
merges anything, or decides.

This tutorial runs three of them across one session, in the order you would
meet them. It takes about twenty minutes and changes nothing you cannot undo.

**You will need** a repository with the plugin installed. Any repository —
these three need no setup and no declaration files.

## What you are about to do

1. Close a session on purpose with `/coda`
2. Come back and see what it left for you
3. Ask `/reservoir` what it can actually observe
4. Attack a spec with `/diaboli` before approving it

If you stop after step 2, you will still have got the most valuable one.

## Step 1 — End a session deliberately

Do some work first. Anything real: fix something small, start something and
leave it half-done. Then:

```text
/coda
```

The Coda surveys what landed and what is still live, and asks you a question
per open thread:

```text
Threads still live:

  1. The retry backoff — you changed the constant but the test still
     asserts the old value
  2. Docs for the new flag

What is the next action for thread 1?
```

**Answer it as if writing to yourself on Monday.** "Continue the retry work" is
a label; "change the assertion in test_retry.py:44 to 500ms, then check whether
the docs example still matches" is a next action.

The Coda will push back once if what you wrote does not look like a starting
point. It asks — it does not refuse, and it does not record that it asked.

### What just happened

- It **proposed** a thread grouping and you confirmed or changed it.
- It **drafted** the records; the command wrote them after you agreed.
- The agent itself holds no `Write`. That is not a policy — it is the tool
  boundary, and it is why the words in the record are yours.

## Step 2 — Come back

Start a new session in the same repository. Before you type anything:

```text
You parked 2 threads in an earlier session:

  · The retry backoff — change the assertion in test_retry.py:44 to 500ms,
    then check whether the docs example still matches
  · Docs for the new flag — write the upgrade note; the flag defaults
    differently for existing users
```

**This is the payoff, and it is the whole argument for the ritual.** The value
of writing a next action is not the writing; it is that a version of you with no
context can act on it immediately.

A record nobody ever sees again is a diary. This is a handoff — to yourself.

## Step 3 — Ask what can actually be observed

```text
/reservoir
```

You get something like:

```text
Session span      4h 20m          observed
Decision volume   31 commits      observed
Context switches  3 repositories  inferred
Wall-clock hour   21:40 local     observed
```

**Read the flags, not just the numbers.** `observed` means it counted
something real. `inferred` means it derived it and could be wrong. There is no
third thing where it guesses and does not say so.

Notice what is *not* there: no score, no "you seem tired", no percentage of
anything. The Reservoir Warden watches the one actor the harness cannot
verify — you — and it is trustworthy precisely because it has no teeth and
wants none. It will offer one recommendation if a threshold is crossed:
**decide your stop before the next session begins.** That is all.

It persists nothing about you. Run it, read it, and it is gone.

## Step 4 — Have a spec attacked

Now the other kind. Take a spec — a real one, or write three paragraphs
describing something you are about to build:

```text
/diaboli docs/superpowers/specs/2026-08-20-my-feature.md
```

The Advocatus Diaboli reads it and raises the strongest objections it can, each
in one of six categories, each with evidence quoted from the spec itself.

Then it stops, and every objection sits at `disposition: pending`.

**Nothing proceeds until you write a disposition in the file yourself.** Not
because a rule says so — because the agent holds no `Write` and cannot fill
that field. It is a hard gate, and the gate *is* the tool boundary.

Open the record and write, per objection, `accepted`, `deferred` or `rejected`,
with a rationale. Argue back where you disagree; a `rejected` with a reason is a
complete answer and the record is better for containing it.

### The thing worth noticing

You just spent real thought on objections you did not have to engage with. That
is the point of the whole category. An unchallenged spec is not a good spec — it
is an untested assertion, and the friction you just felt is the quality.

## What you have learned

| | |
| --- | --- |
| **They propose; you dispose** | Every gate ends in a human writing something. No sentinel auto-approves or silently blocks. |
| **The boundary is the mechanism** | They hold no `Write`. The disposition field cannot be filled by an agent, so engagement is structural rather than requested. |
| **They say how they know** | `observed`, `inferred`, `asked`. When a value cannot be observed, they say so instead of estimating. |
| **They persist nothing about you** | Records describe sessions, work and decisions — never an assessment of your state. |

## Where to go next

There are **ten** sentinels. You have met three.

- **[Sentinels](../explanation/sentinels.md)** — the full roster and, in *Using
  them*, which to reach for when
- **[The cadence discipline](../explanation/cadence-discipline.md)** — `coda`,
  `mast`, `wip-warden`, `convener`: the shape of the work around decisions
- **[The decision-discipline triad](../explanation/decision-discipline-triad.md)**
  — `carpaccio`, `advocatus-diaboli`, `choice-cartographer`

If you adopt one more, make it `/mast`: write down a limit while you are calm,
and find out whether it survives the moment it governs.
