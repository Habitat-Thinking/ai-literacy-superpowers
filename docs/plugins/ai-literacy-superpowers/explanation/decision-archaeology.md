---
title: Decision Archaeology
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 20
redirect_from:
  - /explanation/decision-archaeology/
  - /explanation/decision-archaeology.html
---

# Decision Archaeology

The Choice Cartographer agent runs after the spec-mode `/diaboli`
dispositions are resolved and before plan approval. It maps the
implicit decisions a spec has committed to — the defaults inherited,
the alternatives unspoken, the patterns unnamed, the consequences
accepted — and emits each material choice as a *choice story* for
human disposition. This page explains why the mechanism is designed
the way it is — the two debts it pays down, why it is paired with
adversarial review rather than merged with it, and what the soft
plan-approval gate trades against the hard merge-time gate.

---

## Two debts

A spec captures *what was said*. It is poor at capturing *what was
assumed*.

**Intent debt** is the gap between what the team wanted and what the
spec wrote down. It accumulates in silences. A default inherited from
a framework or an AI training prior slips in unannounced; the spec
records the resolution but not the forces that produced it. Six
months later the team re-litigates the choice because nobody wrote
down why it was made. There was no seam in the workflow at which to
write it down.

**Cognitive debt** is the gap between what the spec implies and what
the team understands about why. It accumulates in unnamed patterns.
A spec that implements Mediator, Saga, Outbox, or Repository without
naming the pattern forces every future reader to recognise it
afresh. The named-pattern discount is the cheapest cognitive-debt
payment available — but no agent in the pre-Cartographer pipeline was
chartered to make it.

Both debts compound. Both are paid down by writing decisions down as
stories.

---

## Why a separate agent from the diaboli

Adversarial review and decision archaeology look adjacent — both
inspect the spec, both produce structured records, both have read-only
trust boundaries. They are not the same role.

The diaboli filters for **what could be wrong**. Risk surfacing,
premise challenges, alternatives that might be materially better. Its
selectivity bar is severity (12 objections, ranked). Its output drives
spec edits before plan approval.

The Cartographer filters for **what was chosen without saying so**.
Forces resolved silently. Defaults inherited. Patterns unnamed.
Consequences accepted. Its selectivity bar is leverage (5–8 stories,
ranked by what would compound if recorded). Its output drives compound
learning across specs over time.

Bundling the roles produces longer objection records that mix "this
might fail" with "this chose X over Y", and humans triage them
identically — usually by skimming. Two records with two charters and
two selectivity bars produces more signal per unit of attention than
one record trying to do both.

---

## The Routing Rule

The two records share a deterministic test that partitions findings:

> A finding belongs in the Cartographer's record iff: removing it
> would leave a decision unrecorded but no failure undetected.
>
> A finding belongs in the diaboli's record iff: removing it would
> leave a class of failures undetected.

When a finding satisfies both, it is a diaboli risk (failures
dominate decisions for routing purposes). When it satisfies neither,
it is dropped.

The rule is referenced from both skills (`advocatus-diaboli` and
`choice-cartographer`), applied by both agents before they emit
anything. Findings that violate the rule are routing errors and
should be flagged when adjudicating. The agents calibrate against
human disposition over time. Stories that the team consistently
dispositions `revisit` (deferred) carry a different signal than those
dispositioned `accepted` — frequent `revisit` on a particular lens
suggests the team is consistently capturing-but-not-committing on that
kind of decision, which is itself a finding the next adjudication
cycle should consider.

---

## The six lenses

Each story uses one or more of these. They overlap; the lens field
records the primary lens, and the prose reflects secondary ones.

1. **Forces** — the tensions this part of the spec resolved. Often
   unspoken. Surface them in the voice of the spec's author.
2. **Alternatives unspoken** — 2–3 realistic options the spec did
   not acknowledge.
3. **Defaults inherited** — where "the obvious choice" came from.
   Framework, training prior, team habit. The cheapest place to ask
   "did we choose this?"
4. **Patterns unnamed** — known patterns the spec implements without
   naming. The lens least replicated by the diaboli, and the highest
   leverage when it fires.
5. **Consequences accepted** — what the choice forecloses. Apply the
   Routing Rule rigorously here; many candidates belong to diaboli.
6. **Story coherence** — whether the spec's decisions form a
   coherent narrative. Used sparingly, but used when the spec
   genuinely doesn't cohere.

---

## The cartography metaphor

The role is mapping, not auditing.

A map makes implicit terrain legible. The spec is the territory that
has been built; the choice story is the map. Choices made silently
become marked features; alternatives not taken become the empty
regions; consequences foreclosed become the boundary. Maps are not
the territory; choice stories are not the decisions themselves —
they are aids to seeing what is otherwise invisible to a future
reader.

The format inside the map is Kevlin Henney's *pattern stories*
(POSA Vol. 5, 2007), in which a pattern is animated as a worked
narrative with forces, options, choice, and consequences laid out
as a story. The lineage matters: pattern stories are the smallest
unit of design rationale that compresses cognition rather than
expanding it. Each entry the Cartographer emits is a *choice
story* — pattern stories applied to specs.

---

## Brakes as acceleration

The Cartographer is friction by design. It slows the spec down at
the moment between adversarial review and plan approval — a moment
the team would otherwise skip past, going from "objections
adjudicated" straight to "let's build."

The justification is the racing line: cars go faster *because* they
have brakes. Without brakes, a fast car becomes an uncontrolled one.
A pipeline without decision archaeology is fast at producing code
and slow at producing decisions; the imbalance compounds. The
Cartographer trades a few minutes of plan-approval-time friction
for less re-litigation, less unnamed-pattern cost, and less default
inherited from outside the team's knowledge.

Needless friction discredits the role. The selectivity bar (5–8
stories, 15-cap inside the agent's reasoning) is calibrated to
this — pedantic enumeration produces noise that masks signal, and
the agent is instructed to drop weak candidates rather than pad to
hit a count.

---

## Soft gate at plan approval, hard gate at merge

The diaboli's plan-approval gate is **hard**: it refuses progression
while any objection is `pending`. Risk that has not been triaged
should not become test code, and certainly should not become merged
code.

The Cartographer's plan-approval gate is **soft**: it surfaces a
structured `cartograph_pending_count` field and allows progression
even with unresolved stories. The forcing function is at merge time:
the HARNESS constraint **PRs have adjudicated choice stories**
blocks the PR until every story has `disposition != pending`.

The asymmetry is deliberate. A `pending` objection is a risk that
has not been triaged. A `pending` choice story is not a risk — it
is a captured decision waiting for human curation. Blocking plan
approval on choice-story curation would compound the diaboli's
already-substantial gate cost; deferring the curation to merge time
trades a small amount of compound-learning velocity for a much
lighter plan-approval surface.

The trade is reversible. If the team finds choice-story
dispositions are routinely deferred to merge time and rushed at
that point, the gate can be re-tightened at plan approval. Both the
soft and hard gate read the same `cartograph_pending_count` field
— the difference between them is one configuration line, not a
mechanism redesign.

---

## Relationship to ADRs

Architecture Decision Records (Nygard, 2011) and choice stories
look adjacent. They are not the same.

ADRs are written by the **decision-maker** to explain a choice
they know they made. They are an act of self-documentation. They
require the author to know the choice was a choice — to have
recognised the alternative, named the force, identified the
pattern. ADRs are excellent when the author has that
recognition. They are absent when the author does not.

Choice stories are written by an **external observer** to surface
a choice the decision-maker may not have realised they were
making. They require no recognition from the spec author —
they are the recognition.

Both are rationale capture. Only the latter pays down intent
debt. A spec can have rich ADRs and still carry intent debt, if
the ADRs cover the choices the author noticed and miss the ones
they didn't.

---

## What the trust boundary actually does

The Cartographer's tools are Read, Glob, and Grep. It cannot
write any file. It cannot write its own choice-story output —
the orchestrator (or `/choice-cartograph` command) writes the
file using content the agent returns. It cannot write
dispositions — the only path is a human opening the
choice-story file and editing the YAML frontmatter directly.

This is not a limitation. It is the mechanism.

Dispositioning a choice story requires reading it, recognising
the choice it surfaces, deciding whether the choice is sound
(`accepted`), captured-but-deferred (`revisit`), or durable
enough to carry forward (`promoted`), and writing a rationale.
That is cognitive work. If an agent could fill in the
dispositions, the work would not get done. Empty boxes
mechanically ticked are functionally identical to no boxes at
all — the gate would exist but it would not gate anything.

The same mechanism underwrites the diaboli's dispositions. The
Cartographer inherits it.

---

## Compound learning across specs

A single choice-story record records the decisions a single spec
made implicitly. A *corpus* of choice-story records — across
many specs over time — records the decision shape of the
project itself.

Patterns visible only in aggregate become legible:

- Which lenses fire most often? If `defaults` dominates, the
  team is inheriting a lot of choices without owning them — a
  signal that conventions need work, not specs.
- Which dispositions cluster? If `revisit` is common on
  `patterns`, the team is implementing patterns without naming
  them, and the Cartographer is the one catching it.
- Which stories are `promoted`? Stories that earn promotion are
  candidates for AGENTS.md ARCH_DECISIONs or HARNESS.md
  constraints. The promotion mechanism itself is tracked at
  [issue #211](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/211).

These patterns are surfaced in `/superpowers-status` Section 8
and the harness-health snapshot Cartographer panel. They are
descriptive, not prescriptive — the team reads them to
calibrate, not to be measured.

---

## See also

- [Run the Choice Cartographer](run-choice-cartograph.md)
  — the practical guide to invoking it
- [Adversarial Review](adversarial-review.md)
  — the diaboli's role and why the two are paired
- [Compound Learning](compound-learning.md)
  — the broader frame for cross-record pattern surfacing
