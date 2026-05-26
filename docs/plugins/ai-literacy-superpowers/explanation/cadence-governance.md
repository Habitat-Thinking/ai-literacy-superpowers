---
title: Cadence Governance
---
# Cadence Governance

The carpaccio agent runs at orchestrator step 0, before any spec
exists. It reads the raw task description, slices it into thin,
end-to-end-complete pieces, and hard-gates the pipeline until a human
dispositions each slice. This page explains why the mechanism is
designed the way it is — the cognitive-budget mismatch it addresses,
its intellectual lineage in Cockburn's *Elephant Carpaccio* exercise,
and why slicing is a discipline that must happen *before* the
proposal is plated, not after.

---

## The cognitive-budget mismatch

The binding constraint in AI-augmented engineering is no longer
engineer throughput. It is *human cognitive budget*.

A modern coding agent produces a coherent, internally-consistent
multi-file proposal in seconds. The human reviewing it operates at a
different timescale: reading carefully, holding alternatives in
working memory, constructing counterarguments against a finished
structure. The agent's output rate exceeds the human's engagement
rate by orders of magnitude.

The naïve response is "the human should review more carefully." That
response misreads the problem. The bottleneck is not the human's
diligence — it is the cognitive cost of constructing an alternative
to an internally-consistent proposal. Coherence is a cognitive trap:
disagreement requires holding the alternative in working memory while
the proposal sits in front of you, fully formed. That cost rises with
the size and internal coherence of the proposal. Past a threshold,
acceptance becomes the path of least resistance.

The compound effect is what matters. Each round of accepted-by-default
work weakens the decision-making muscle that should have engaged. The
next proposal arrives wider and faster, against a human whose engagement
muscle is slightly more atrophied than before. The trajectory ends in
a team that nominally approves but does not actually decide.

---

## Cockburn's Elephant Carpaccio

The exercise lineage is Alistair Cockburn's *Elephant Carpaccio*
workshop, run at agile gatherings since the late 2000s. The exercise:
a small team is given a feature and asked to slice it into 7–12
end-to-end-complete pieces. Each slice must ship something
observable; no slice can be only-internal. Teams routinely
under-estimate how thinly they can slice; the discovery that one's
first slicing is too coarse is the pedagogical core.

Cockburn framed the discipline as a release-strategy heuristic:
small slices give early feedback, reduce in-flight work, and keep
options open. Those benefits remain, but the harness-engineering
reframing of Carpaccio adds a structural argument. In AI-augmented
work, slicing is not just about delivery cadence — it is about
*cognitive cadence*. Each slice arrives at the human as one
decision, surrounded by enough context to engage with but not so
much that the alternative is more expensive than acceptance.

The thinness is not arbitrary. The slicing must reach the granularity
at which the human can actually hold a counterfactual in mind.

---

## Why a separate agent from spec-writer

A natural objection: "if proposals arrive too wide, write narrower
specs." Slicing inside spec-writer would seem to address the same
problem with fewer moving parts.

It does not, for two reasons.

The first is the **sunk-cost problem**. By the time the spec is
written, the framing has been committed. A spec is a coherent
artefact with internal consistency; slicing it after the fact means
unwinding choices the spec has already made. The human's pushback
arrives against work the spec-writer has already done, and the cost
of insisting on a thinner slicing rises accordingly. Slicing must
happen *before* any spec exists.

The second is the **charter problem**. Spec-writer's charter is to
articulate a coherent design. Carpaccio's charter is to refuse
coherence at the wrong scale — to insist the proposal be sliced
before any coherent description of it gets written. These are
different cognitive jobs. Bundling them produces a spec-writer that
under-slices (its anchor is "produce a complete spec") or a
carpaccio that over-specifies (its anchor is "describe the slicing
in detail"). Separate agents, separate charters, separate selectivity
bars.

The Cartographer and diaboli arguments for separation apply here too:
a single-agent self-review is structurally weaker than a separate
agent with a different charter. The cadence governor is the third
member of that triad, addressing a different layer.

---

## The trust-boundary mechanism

Carpaccio has Read, Glob, and Grep — no write capability, no Bash, no
issue-creation tools. The orchestrator writes the slicing record using
content the agent returns; humans fill `disposition` fields inline; the
orchestrator (which already has Bash and `gh`) drives issue creation
after the human approves it per-slice.

The boundary is not a limitation. It is the mechanism.

An agent that could fill its own `disposition` fields would eliminate
the human-cognition gate that gives the slicing record its value. An
agent that could create issues unilaterally would convert "slicing
proposal" into "fait accompli" — the human would be ratifying issues
rather than choosing whether the slicing was right. The discipline
depends on the human typing `accepted`, `merged`, `dropped`, or
`revised` into the file before anything else happens.

This is the same mechanism the diaboli and cartographer use. The
read-only boundary is what enforces engagement.

---

## The five lenses

The agent applies lenses in priority order:

1. **`decision-boundary`** *(primary)* — one slice per material
   decision the human will engage with. A decision is material when an
   alternative would produce visibly different downstream work, not a
   choice between equivalent implementations.

2. **`acceptance-criterion`** *(fallback)* — one slice per testable
   Given/When/Then. Used only when decision-boundary cannot legitimately
   fit; a vague task ("improve the install docs") has acceptance criteria
   but no decision content.

3. **`end-to-end`** *(filter)* — drops candidates that are only internal
   milestones with no observable output. This is Cockburn's original
   emphasis: every slice ships something a reader could see.

4. **`independence`** *(modifier)* — surfaces ordering across surviving
   slices. When slices can land in any order, the agent records that;
   when sequencing matters, the `sequencing_note` field captures it.

5. **`inseparability`** *(terminal)* — when slicing further would harm
   correctness (atomic migration, security patch, single-coherent
   refactor), the agent emits a single-slice record with a defended
   `## Inseparability rationale` section.

The vocabulary is closed. Each slice records which lens chose it in
the `lens_used` field. The agent also records what dimensions were
considered as slice boundaries but rejected — the `## Explicitly not
slicing on` section — typically including file boundaries, layer
separations, commit boundaries, and PR-reviewability heuristics. Naming
what was considered and discarded makes the slicing defensible.

---

## Naming the inseparable

Not all work can be sliced thinner. Atomic credential rotations,
schema migrations that must land coordinated with code changes,
security patches that introduce a vulnerability if applied in pieces —
these resist slicing not from lack of imagination but from a
correctness constraint.

The agent's response to genuinely atomic work is *not* to bypass the
slicing record. It is to produce a single-slice record with
`inseparable: true` and a defended `## Inseparability rationale`
section. The rationale must argue, not assert — "this is atomic" is a
contract break; the agent must explain *why* slicing would harm
correctness.

Naming the inseparable as inseparable is itself a useful output.
First, it records the claim so a future engineer reviewing the
slicing record can challenge or confirm it. Second, it surfaces the
distinction between "we judged this atomic" and "we did not bother to
slice." Atomic work that is *defended* as atomic is sturdier than
atomic work that is merely *assumed* to be atomic.

The human still dispositions the single slice. The orchestrator still
runs the gate. The discipline does not slacken on atomic work — only
the slice count changes.

---

## The four-value disposition vocabulary

Each slice receives one of four dispositions from the human:

- **`accepted`** — this slice is a valid unit of work.
- **`merged`** — fold this slice into another (`merged_into:` names
  the other slice's id).
- **`dropped`** — discard this slice entirely.
- **`revised`** — push back on the slicing; the agent re-dispatches
  with the human's `disposition_rationale` strings as guidance and
  overwrites the record.

Four values rather than two captures the natural human reactions to a
proposed slicing. A binary `accepted | rejected` would collapse
"fold this in" and "throw this away" into the same gesture, losing the
narrative of *what changed*. The `revised` value supports the
push-back loop: the human writes guidance, the agent re-slices, the
prior record is overwritten (matching the `/diaboli` and
`/choice-cartograph` overwrite semantics).

For `accepted` slices that are not the slice being progressed this
iteration, the human additionally sets `file_as_issue: true|false`.
The orchestrator runs `gh issue create` after the gate clears for
slices marked `true` and writes the returned URL into `issue_url:` —
the slicing record becomes the audit trail of what was filed and what
was not.

---

## Position in the triad

Three agents form the decision-discipline triad. Each operates at a
different layer:

- **carpaccio** asks *should we engage now, or break this into smaller
  engagements?* Acts on the raw task, before any spec exists.
- **advocatus-diaboli** asks *given we are engaging, what are the
  strongest objections to the proposal?* Acts on the spec (and later
  on the code).
- **choice-cartographer** asks *given the proposal stands, what
  decisions did it implicitly make?* Acts on the spec, after diaboli
  dispositions are resolved.

The questions look adjacent but demand different stances from the
human. Bundling them would produce decision fatigue and soften each
individual discipline. The three-agent split preserves the sharpness
of each question.

A single PR moves through the triad as follows: carpaccio slices the
task and the human dispositions the slicing; spec-writer writes a
spec against the progressed slice's scope; diaboli challenges that
spec and the human dispositions the objections; cartographer maps
that spec's silent decisions and the human dispositions the stories.
Three records, three gates, three stances. The human stays in the
decision stream because each slice — and each gate within the slice —
is small enough to taste.

---

## What the discipline buys

The visible cost is friction at the front of every pipeline run.
Carpaccio fires unconditionally on every orchestrator dispatch; the
human dispositions the slicing record before spec-writer is reached.
For tasks that turn out to be genuinely small or genuinely atomic,
the gate adds ceremony.

The compound benefit accrues at the level of the team's
decision-making muscle. Each cadence-governed task is a task in which
the human engaged with one decision at a time rather than ratifying a
proposal whole. Over weeks, the muscle is exercised. Acceptance
remains an option, but it is now a *chosen* option rather than the
path of least resistance. The next proposal arriving from the AI
meets a more engaged reader.

This is the same epistemic posture the diaboli and cartographer
support, applied one layer earlier. The triad is not three duplicate
gates. It is three different stances against three different failure
modes of AI-augmented work — coherent-but-too-wide proposals
(carpaccio), unchallenged proposals (diaboli), and proposals whose
silent decisions go unnamed (cartographer).

---

## See also

- [The decision-discipline triad](decision-discipline-triad.md) — the
  three agents and how they relate.
- [Adversarial Review](adversarial-review.md) — the diaboli's role.
- [Decision Archaeology](decision-archaeology.md) — the
  cartographer's role.
- [Slicing a task with `/carpaccio`](../how-to/slicing-a-task.md) —
  the how-to guide.
- Reference: [agents](../reference/agents.md), [skills](../reference/skills.md), [commands](../reference/commands.md).
