---
name: mast
description: Use when reading or authoring a self-declared pact — carries the two modes, the clear-weather rule and the exact blind spot of the check that enforces it, the flag discipline for a budget whose keys are mostly unobservable, the rules the pact writer guarantees, and the anti-patterns that would turn a pact-keeper into a gate
---

# The Mast

A limit you set for yourself in advance holds. A limit you set in the moment
you are about to breach it does not — you will simply move it, because the
thing you want at 18:00 is to keep working.

That is why the pact file exists, and why nothing scaffolds one: an imposed
default is not a pact. But a pact nobody reads is also not a pact, and a pact
nobody has authored is not one either.

> **The Mast** — the pact-keeper. It brings a pact into existence, and reads it
> back to you.

**What it attacks:** outsourced governance — the drift where the decision about
when to stop migrates from a person who decided it in advance to a person who
is tired and mid-thought.

It never stops anything itself.

## Two modes

| Mode | Does |
| --- | --- |
| `/mast` | recites the pact and says where you stand against it |
| `/mast tune` | the only sanctioned path that authors or amends it |

Boundary notices, the hard stop, and the override record are **not here** —
they are a separate slice. What lives here is the gauge and the ritual.

## Recite first, measure second

<!-- evidence: the intervention is the re-reading. A pact's force comes from
     having been authored deliberately and then brought back into view, not
     from being metered. This is why the report leads with the human's words. -->

Read mode opens with the human's own declared words, and annotates afterwards.
A report that opens with a table of what the plugin cannot see is an inventory
of limitations, not a gauge.

## The flags, and the honest cost of them

| Key | Flag | Why |
| --- | --- | --- |
| `hard_stop_hour` | `observed` | the clock is past it or not |
| `focus_blocks` | `inferred` | the clock being inside a block is not having spent it working |
| `sessions_per_day` | `inferred` | the registry is a lease over live sessions, not a day's log |
| `daily_cost_ceiling` | **not observable** | nothing here sees spend |

Two of these are easy to get wrong in the flattering direction.

`focus_blocks` looks observable because a focus block is a clock range. But
consumption against it is *did you spend it working*, which needs the day's
history the registry does not keep — the same sentence that disqualifies
`sessions_per_day`.

`daily_cost_ceiling` is not `asked`. Reporting a declared ceiling back is
reading a pact, not asking a question; `asked` means the human was asked and
answered. An unearned flag invites an implementer to invent the question, and
the plausible invention — asking what someone spent today — is a question about
their spending that nothing authorises.

**Never estimate.** A fabricated figure against a real ceiling would make a
person stop, or not stop, on a number nobody measured.

Only one key in four ever moves. That is the price of not fabricating the other
three, and it fixes what a budget *is* here: a declaration to be recited, not a
quantity to be metered.

## The clear-weather rule, and exactly what enforces it

<!-- evidence: self-authored limits hold where imposed or default limits fail;
     authorship is the active ingredient. This is why nothing scaffolds a pact,
     why Tune proposes no defaults, and why the check below is a note. -->

Tune stamps `authored_at`. Read mode notes when the budget it is reading was
**tuned today** — this pact has not been lived with yet, which is worth a line
when it asks something of you tonight.

**What the check does not see.** `authored_at` moves only when Tune writes it:

| The human does | Stamp | Note fires |
| --- | --- | --- |
| Hand-edits the stop hour at 18:00 | unchanged | **no** |
| Runs `/mast tune` on a calm Tuesday morning | today | **yes**, that evening |

It fires on the honest path and stays silent on the dishonest one. **Say so, in
the note itself.** A check that claims coverage it lacks is worse than one that
claims none, because silence gets read as an all-clear.

Something stronger is not available. The pact file is never committed, so there
is no diff and no CI can see it. Checksumming would catch the hand-edit, but it
would also flag the calm Tuesday tweak, which is the deliberate authorship the
rule *wants*. A disclosed note at the Unverified rung is the honest position —
the same call the flag table makes about spend, for the same reason.

It is a note, never a gate. Refusing to honour a pact because it was authored
recently would be second-guessing the person it serves.

## Tune

**It is an editor, not only an author.** It reads current values back as each
question's context — *your line is 18:30; what should it be?* That is not a
proposed default: what is shown is the human's own prior authorship, not the
template's illustration. Without it, changing one number means re-running the
whole ritual, and the cheapest path to a small edit becomes the editor — the
channel the weather check cannot see.

**The stop hour first**, then an offer to stop there. A useful two-line pact is
reachable in one question. A person asked cold for `max_switches_per_hour` has
no basis for an answer, and a number invented to move the dialogue along is not
more authored than one they declined to give.

**It says what nothing reads yet** — before asking. `Sync cadence` entirely;
three of `Session WIP`'s four keys until the WIP Warden ships;
`notification_policy_after_stop`, which is declared intent nothing enforces;
`daily_cost_ceiling`, which is never checkable. Disclosing for one block and
not the others would leave a human authoring their first pact under two
regimes without being told there were two.

**It composes, shows, then writes.** Per-value confirmation is not enough
alone: the parts the human did not author — the mandatory clause, the reserved
marker, the stamps — are exactly the parts that decide whether the block reads
as `declared`, and without a preview they land unseen.

**It proposes nothing as a default**, and every block is skippable.

## What the writer guarantees

`lib/pact-write.sh` — **commands and hooks only**, never sourced by a sentinel.

1. **Derives** the mandatory clause and reserved marker from the template,
   never from a copy. A restated clause agrees with the reader only by
   coincidence of wording.
2. **Replaces a block; never appends a second.** A duplicate heading is
   silently unread, so newly tuned values become invisible with no error.
3. **Stamps `Budgets` only**, where the grammar defines the stamps.
4. **Preserves the preamble** — which is the only content genuinely outside
   every block, since everything after a heading belongs to it.

Then the **validation checkpoint**: read the block back, assert `block_state`
returns `declared`, fix in place. Without it a malformed write is discovered
later, silently, as sentinels dropping to observe-only.

## Anti-patterns

1. **Estimating anything unobservable**, especially spend.
2. **Gating on the weather note.** It is a note.
3. **Claiming the weather check catches hand-edits.** It cannot, ever.
4. **Opening the report with what cannot be seen.** Recite first.
5. **Proposing a default in Tune.** A value accepted because it was pre-filled
   is not authored.
6. **Judging the pact.** A stop hour is not too late. It is theirs.
7. **Writing from the agent**, or sourcing the write library from one.
