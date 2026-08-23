---
name: harness-review
description: List every lapsed harness rule and the three things a human can do about each — re-evidence, weaken, or demote; read-only, and every outcome produces a new superseding record rather than editing a frozen one, so a retired rule leaves a record of what it cost and why it went
---

# /harness-review

Run this when `/harness-check` reports a lapsed rule.

Permanence is earned at review, not at creation. A rule accepted ninety days ago
is due an answer, and this is where it gets one.

## When to use

- When CI fails with an expired rule still in force
- On the quarterly governance cadence, alongside `/governance-audit`
- Never to "clear" a lapse. A lapse is a question, and the answer takes a
  decision

## What it does not do

It writes nothing. Every outcome goes through `/harness-accept`, because every
outcome is a decision with a cost that a human writes.

## Process

### 1. Run it

```bash
python3 ai-literacy-superpowers/scripts/harness-registrar.py review
```

### 2. Present the lapsed rules

For each, show the id, title, expiry date, enforcement, and surfaces. Then the
three options — and state plainly that **all three produce a new record**:

| Outcome | What it means | The new record |
| --- | --- | --- |
| **Re-evidence** | It still earns its place, and there is fresh evidence | Cites that evidence; may set `provisional: false` — this is where permanence is earned |
| **Weaken** | It was too strong | Lower `enforcement`, or narrower `surfaces` |
| **Demote** | It should go | `## Rule` section says `Withdrawn.` |

**Nothing edits the old record.** An accepted record is frozen, and
`/harness-check` compares it against its content at the commit that accepted it.
Supersession is derived from the new record's `supersedes:` field, so the old one
is never touched — and the record that the rule existed, what it cost, and why it
was retired survives, which is the output of this whole mechanism rather than its
residue.

### 3. Surface the triggers separately

Records carrying a `review_trigger` and no `expires` appear under **Triggers
nothing can evaluate**.

Say plainly what that means: a trigger is free text, nothing evaluates it
mechanically, so those records **never lapse, never fail CI, and are permanent by
construction** — the opposite of permanence being earned. Offer the human the
choice of evaluating the trigger now, by hand, or giving the rule an expiry.

Do not quietly treat a trigger as satisfied.

### 4. Draft the outcomes the human chose

For each, `/harness-propose` from an assay finding if one exists, or draft the
record directly when the decision came from this review rather than from an
assay. A review-driven record carries `proposer.agent: harness-review` and cites
the record it supersedes as evidence.

Then `/harness-accept`, where the human writes what the change costs. **A
demotion has a cost too** — usually the behaviour the rule was holding back
returning — and the validator refuses an empty one just the same.

### 5. Validation checkpoint

- **R1** — every new record names the old one in `supersedes:`, and the old
  record is unchanged on disk
- **R2** — `superseded_by` is `null` in both. Supersession is derived
- **R3** — neither record stores `status: superseded` or `expired`. Those are
  derived states, and storing one is a record claiming a fact only the corpus can
  know
- **R4** — a demotion's `## Rule` section says `Withdrawn.` and carries no fenced
  block
- **R5** — after `/harness-accept`, `/harness-check` is clean and the retired
  rule has left every generated region
- **R6** — the old record is still on disk. It is never deleted

### 6. Report

```text
<n> rules lapsed, <k> superseded.

  Withdrawn: <ids>
  Weakened:  <ids>
  Re-evidenced: <ids>

<t> records carry a review trigger and no expiry. They will not lapse
on their own.
```

## What this command never does

- Edit an accepted record
- Delete a record
- Extend an expiry in place. A rule that deserves more time deserves a new
  decision, with a cost, written by whoever is granting it
