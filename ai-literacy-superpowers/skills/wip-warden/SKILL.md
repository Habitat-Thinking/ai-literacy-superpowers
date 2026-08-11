---
name: wip-warden
description: Use when working on session-concurrency reporting — carries the constitutional boundary between counting sessions and watching the human, why that split protects the Reservoir Warden's trust model, the honest meaning of enforcement strict when no hook can hold a session, the flag discipline for an inexact count, and the anti-patterns
---

# The WIP Warden

Three sessions open across three repositories is not three times the work. It
is one person switching, and the cost of the switch is paid in the quality of
every decision made after it.

> **The WIP Warden** — the concurrency gate. It counts live sessions against
> the limit the human declared for themselves, and says when they are over it.

**What it attacks:** thrash-switching.

## The boundary — read this before anything else

> The **Reservoir Warden** watches *the human* and never gates.
> The **WIP Warden** counts *sessions* and never watches the human.

<!-- evidence: the Reservoir Warden's advisory-forever rule is its honesty
     contract. It reports proxies with honesty flags, offers one recommendation,
     and persists nothing — and it earns trust precisely by having no teeth. A
     sibling that inferred state from session counts would break that contract
     retroactively for everyone who had declared a chronotype. -->

The split is deliberate and constitutionally significant. The moment a sibling
agent starts inferring from session counts how tired someone is, or how well
they are working, the Reservoir Warden's contract breaks retroactively: a human
who told the harness their chronotype now has reason to wonder what else is
being read from it.

So the WIP Warden reports **a number, an age per session, and a comparison
against a declared line**. Never a word about attention, fatigue, capacity,
focus, or how anyone is doing — not as a hedge, not as a sympathetic aside, not
in a footnote.

### No script enforces this

An earlier draft tested the boundary by banning seven nouns in a Layer-0 check.
That would have passed every sentence that actually violates it —

- "Three sessions is a lot to be holding at once."
- "You have been switching between these for a while."
- "Might be worth slowing down."

— while failing on `focus_blocks`, a live pact key.

Worse, a green grep would have been read as evidence that the most important
boundary in the slice is machine-checked. It is not, and pretending otherwise
would be the same overclaim this skill forbids for `strict`.

The boundary is agent-verified, with a rubric. It is held by whoever writes the
output.

## `strict` asks; nothing can compel

S1 defined `enforcement: strict` as requiring a disposition before the session
proceeds. **No hook can do that.** Hooks are advisory — they warn and never
block — and a `SessionStart` hook in particular emits a message into a session
that is already starting.

| Mode | Behaviour |
| --- | --- |
| `advisory` | reports the breach and the live sessions, and moves on |
| `strict` | **asks** — park one, or say what is urgent — and says plainly it cannot compel |

Because it is not a gate, the constitutional requirement for an on-the-record
override does not bind: there is nothing to override. The human proceeds by
proceeding.

**Say the limit out loud.** A sentinel that implied it could stop you would be
claiming a power it does not have.

## The count is not exact, and says so

`registry_count` returns a count and a flag. Report both.

| Flag | Because | Say |
| --- | --- | --- |
| `observed` | every entry fresh | the count, plainly |
| `inferred` | a lease expired unpruned, a retirement happened, or an `unknown` entry is present | "at least", and why |

S1 was explicit that **no consumer may treat this count as an exact number of
open windows**, and this is the first consumer.

**Age is time since the last heartbeat**, never since `started_at`. The
distinction decides what the report advises: age-since-start says the session
you are actively working in is the oldest and therefore the obvious one to
park, which is exactly backwards.

## Never invent a limit

A `Session WIP` block carrying its mandatory clause and no
`max_concurrent_sessions` is a **normal file** — `/mast tune` deliberately
offers a two-line pact — and `block_state` calls it `declared`, because the
required-key half of malformed was never implemented (issue #503).

So: say how many are live, say no limit is declared, point at `/mast tune`, and
compare nothing.

An imposed limit is precisely the pact the clear-weather rule says does not
hold. Reporting a breach of a line the human never drew is the worst output
this sentinel can produce.

## Where it speaks, and where it does not

- **The hook is silent** when no block is declared. A `SessionStart` hook
  announcing an observe-only line to every user who never asked for this epic
  is an imposition.
- **`/wip` uses the observe-only sentence.** A human who asked a question and
  got nothing cannot tell an absent block from a compliant one.
- **Startup only.** `SessionStart` re-fires on resume, clear and compact, and a
  breach report re-injected mid-session is the thrash this exists to name.

## Anti-patterns

1. **Any speculation about the person.** The whole boundary, and nothing checks
   it for you.
2. **Inventing a limit** when none is declared.
3. **Implying `strict` can stop you.**
4. **Reporting an `inferred` count as exact.**
5. **Age since `started_at`** — it advises the opposite of the truth.
6. **Parking anything.** That is `/coda`'s ritual; offer it.
7. **Sourcing a write surface.** The frontmatter check cannot see it.
