---
title: Adversarial Review
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 19
redirect_from:
  - /explanation/adversarial-review/
  - /explanation/adversarial-review.html
---

# Adversarial Review

The advocatus-diaboli agent runs at two points in the pipeline: once before plan
approval (spec mode — challenging the premise and design before any code exists) and
once before integration (code mode — challenging the implementation for threat-model,
failure-mode, and operational concerns). This page explains why the mechanism is
designed the way it is — the structural sycophancy problem it addresses, its historical
and philosophical roots, and what the human-cognition gate actually does.

---

## The sycophancy problem

Agentic pipelines structurally suppress disagreement.

The spec-writer agent produces a plan. The orchestrator presents it. The tdd-agent
translates it into tests. At no point does any agent in that sequence have a charter to
disagree. Disagreement is structurally absent — not because agents are incapable of it,
but because no component has been given the role of adversary.

When you ask spec-writer to review its own spec, or orchestrator to critique the plan it
just presented, you do not get adversarial review. You get refinement. The agent's prior
output becomes the anchor; subsequent reasoning adjusts around it. This is not a flaw in
any particular agent — it is a structural property of single-agent self-review. The only
remedy is a separate agent with a different charter.

The third structural problem is timing. Once tdd-agent has written tests, once
implementers have written code, the cost of a premise-level objection rises sharply.
"The spec solves the wrong problem" becomes "we'd have to throw away the tests and the
implementation." Human reviewers and agents alike are subject to sunk-cost pressure. The
premise-level objection must be raised before any implementation artefacts exist.

---

## The Promoter of the Faith

The advocatus-diaboli takes its name from the *Promotor Fidei* — the Vatican official
appointed to argue against a candidate's beatification. The role existed to prevent
hagiographic bias from corrupting consequential decisions: to find reasons to doubt, to
challenge miracles, to expose the motivated reasoning of the faithful.

The role was abolished in 1983 under John Paul II. After its abolition, the rate of
beatifications increased sharply. This history is instructive: removing the adversarial
gate did not improve the quality of decisions. It accelerated them. The correlation
between the absence of adversarial review and the acceleration of commitments is not a
coincidence. It is the mechanism working in reverse.

We are reinstating the gate in a different domain.

---

## Popperian falsifiability

The epistemic basis for adversarial review is Popperian. A claim is only meaningful if
it can be falsified. A spec that has not been challenged is not a strong spec — it is
an unchallenged assertion. The adversarial agent's job is to attempt falsification
before commitment.

What survives adversarial review is not necessarily correct. But it is stronger than
what has not been reviewed. The value is not in finding objections — it is in forcing
the spec to survive a systematic attempt to find them.

A spec with ten objections, all of which were considered and rejected with substantive
rationale, is stronger than a spec with no objections that was never challenged. The
objection record is a record of that strength.

---

## What the agent must not do

Schopenhauer's *Art of Being Right* (*Eristische Dialektik*) catalogues 38 rhetorical
stratagems for winning arguments regardless of truth — strawmanning, shifting the burden
of proof, exploiting ambiguity, appealing to authority, exhausting the opponent through
volume. These are the tools of debate-club victory, not truth-seeking.

The advocatus-diaboli is explicitly not that.

Every objection must be grounded in evidence from the spec itself. If the evidence
cannot be quoted or directly cited, the objection is inadmissible. The agent wins
nothing by raising objections that do not survive scrutiny — a hollow objection list
that the human dismisses in two minutes is a failure of the adversarial review, not a
success.

Winning for its own sake is a failure mode. The goal is not maximum objections. The
goal is maximum quality of engagement with the objections that are raised.

---

## The human-cognition gate

The agent's trust boundary is read-only. It cannot modify the spec. It cannot write
its own objection dispositions.

The second constraint is the load-bearing one. If the agent could write `accepted` or
`rejected` next to its own objections, a human could delegate the entire adjudication
step back to an agent. The gate would be nominal — present in structure, absent in
practice. By making disposition-writing physically impossible for the agent, the
mechanism forces a human to open the record, read each objection, and write a rationale.

That act of writing is the cognitive engagement. It is not a checkbox. A human who
writes `rejected — this concern is addressed by the constraint already in HARNESS.md`
has engaged with the objection. A human who writes `looks fine` has not. The format
requires a rationale precisely because a blank approval is indistinguishable from a
thoughtful approval.

The pipeline gate checks for `pending` dispositions. While any are `pending`, the
plan-approval step will not advance. This is not punitive — it is the mechanism that
makes the adversarial review load-bearing rather than advisory.

---

## Disposition patterns as a signal

Over time, the distribution of dispositions across objection records becomes observable.
These patterns are surfaced in `/superpowers-status` (Section 7: Diaboli Activity) and
the harness-health snapshot (Diaboli panel), both of which report disposition distribution
and mean objections split by mode (spec-mode and code-mode) alongside overall totals.
No thresholds are set yet — the panel is diagnostic, not evaluative.

Cross-mode patterns carry additional signal: code-time objection counts trending up may
indicate spec-time charter is too loose; code-time counts trending down may indicate
spec-time is working OR code-time charter is too narrow. See the observability reference
for interpretation guidance.

Patterns carry information:

**Clustering of `low` severity objections that are all deferred:** The agent is raising
real but unimportant concerns. The objection charter in SKILL.md may need tuning toward
higher-leverage categories.

**Clustering of `critical` objections that are all accepted:** Specs are consistently
underprepared when they reach adversarial review. The spec-writer process may need
strengthening upstream — more explicit requirements gathering, or earlier human review
of the problem statement.

**Consistently empty objection records:** Either the specs are genuinely strong, or the
agent is not challenging them. Read a few objection records against their specs
side-by-side and judge.

**High rejection rate with substantive rationale:** The adversarial review is working —
the agent is raising real concerns, and the humans are engaging with them and deciding
against them with reasons. This is the healthy pattern.

---

## How this fits the three loops

Adversarial review operates in the commit-time loop — it fires twice per feature PR:
once before implementation begins (spec mode) and once before merge (code mode).

Objection records accumulate in `docs/superpowers/objections/` and feed the other loops:

- **GC loop**: A weekly GC rule checks whether any spec has been modified more recently
  than its corresponding objection record. A stale record is flagged for regeneration.
- **Reflection loop**: Recurring patterns in objection types — `scope` objections
  appearing on every PR, for example — are candidates for HARNESS.md constraints or
  CLAUDE.md conventions. When a pattern repeats, it belongs in the harness.
- **Observability loop**: Disposition distribution, mean objections per spec, and
  median days to adjudication are surfaced in the Diaboli panel of `/superpowers-status`
  and the harness-health snapshot. These accumulate across records and become visible on
  the normal health cadence, without requiring a separate audit.

---

## Further reading

- [How to: Review a Spec Adversarially](../how-to/review-a-spec-adversarially.md) — the practical steps for running `/diaboli` and adjudicating the record
- [Decision Archaeology](decision-archaeology.md) — the paired Choice Cartographer agent that runs after diaboli adjudication; the Routing Rule that partitions findings between the two
- [How to: Run the Choice Cartographer](../how-to/run-choice-cartograph.md) — practical steps for `/choice-cartograph`
- [Agent Orchestration](agent-orchestration.md) — the full pipeline in which adversarial review sits
- [Agents Reference](../reference/agents.md) — the advocatus-diaboli agent's tools and trust boundary
- [Commands Reference: /diaboli](../reference/commands.md) — command invocation and output format
