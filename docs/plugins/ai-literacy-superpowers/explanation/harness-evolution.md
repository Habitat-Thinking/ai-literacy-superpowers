---
title: Harness Evolution
sentinels: [harness-assayer]
---

# Harness evolution

The plugin governs the loop and the turn. `HARNESS.md` says how work moves
through the project; `AGENTS.md` says how a single turn should go.

Nothing governed how those two documents themselves change.

## The failure that has no name

Harness rules accrete. One enters because somebody was annoyed once, and it never
leaves, because leaving requires somebody to remember it exists.

Nobody is careless. The rule was reasonable when it was written. But over a year
the loop acquires a dozen of them, none carrying the evidence that justified it,
none saying who owns it, none saying what it costs, and none with an expiry. The
document that governs the work becomes the least governed thing in the
repository.

That is a governance failure with no incident behind it, which is why it is
rarely fixed: nothing ever goes wrong on a Tuesday because of it.

## Two roles, and why they are two

**The Harness Assayer** is a sentinel. It reads evidence from completed work,
classifies findings by ownership, proposes a bounded change set, and stops. It is
read-only with respect to every governance artifact.

**The Harness Registrar** is an ordinary agent. It applies human-approved
changes, keeps the decision record, compiles governance to each control surface,
and reports enforcement gaps. It writes governance; it never authors it.

The separation is the point:

> An agent that both diagnoses failures and writes the rules can rationalise its
> own findings into rules that make its next diagnosis easier.

Diagnosis and legislation stay in different hands, with a human approval gate
between them. And the separation is mechanical rather than instructed: the
Assayer carries `role: sentinel`, and `sentinel-integrity-check.sh` fails CI if
it is ever granted `Write`.

## The loop

```text
work happens
    ↓
/harness-assay        the Assayer reads evidence, returns findings, stops
    ↓
(a human reads it)
    ↓
/harness-propose      a decision record is drafted, rule text copied verbatim
    ↓
/harness-accept       the human writes the cost; the rule is applied and compiled
    ↓
/harness-check        CI verifies what is written down is what is in force
```

Three gates, none implied by another: drafting, accepting, committing.
Applying and compiling are deliberately not gates — once a record is accepted
there is no decision left in either step, and a gate with no decision behind it
is the shape of approval theatre.

## What makes it hard to game

Each of these exists because the obvious version of this mechanism fails in a
specific way.

**The cost is human-authored.** The approver writes, in their own words, what the
rule will demand of whoever works here next and how it might be gamed. The
validator refuses a cost identical to the Assayer's proposal — because a
copy-pasted cost reads exactly like a considered one, and nothing downstream
could tell them apart.

**Rules are provisional by default.** Ninety days, or a review trigger.
Permanence is earned at review, not at creation. An expired rule still in force
fails CI, so retiring a rule never depends on anyone remembering to reflect.

**A single incident cannot reach the loop layer.** A change to `HARNESS.md`
requires evidence from two distinct assays. One bad afternoon is not a governance
finding.

**Three accepted records per cycle, maximum.** Excess proposals stay `proposed`
and carry forward, competing with whatever the next assay found. A finding that
cannot win a slot twice running probably was not worth a rule.

**`no-change` is a first-class outcome.** An assay in which every finding
resolves to `no-change` is a successful assay. Without this, the mechanism
rewards finding something, and an agent that must find something will.

## The enforcement gap is the point

`harness/enforcement-report.md` states, for every rule on every surface, the
enforcement level **intended** and the level **achieved**.

A rule intending `blocked` on a surface that can only advise is reported as a
gap, never silently downgraded. Failing the build over it would push authors to
declare the weakest enforcement any surface supports, which discards exactly the
information the report exists to carry.

The report also asks whether a declared validator resolves to a file that
exists. Without that, a rule declaring `blocked` reports as blocked while nothing
anywhere refuses anything — a confident, legible, wrong answer from the mechanism
whose whole purpose is telling *enforced* from *written down*.

## The overlap, stated rather than denied

The Assayer reads the same artifacts as `/harness-audit`, `/governance-audit` and
`/reflect`, and the plugin's own anti-proliferation rule says to prefer tightening
an existing owner over adding a new one.

The distinction: those three audit **rules that already exist**. The Assayer
governs **the act of changing one** — it produces the evidence-bearing proposal a
decision record is built from, and nothing else produces that.

It is enforced rather than asserted. A finding one of those three already reports
is not a finding; it is a **rejected candidate**, recorded with the owner named.
An assay that never rejects anything on those grounds has stopped checking.

## See also

- [Assay a phase](../how-to/assay-a-phase.md)
- [Record a governance change](../how-to/record-a-governance-change.md)
- [Harness Decision Record format](../reference/harness-decision-records.md)
- [Enforcement report format](../reference/enforcement-report-format.md)
- [Sentinels](sentinels.md)
