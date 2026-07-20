---
title: Watching the Verifier
---
# Watching the Verifier

Every enforcement mechanism in the plugin checks the **output** of an
agentic session — commit and PR constraints, mutation tests,
convention-drift garbage collection, the advocatus diaboli. None of them
checks the state of the **human who approves that output**. A green
checkmark at 09:00 and a green checkmark at 21:00 are the same colour in
the merge log and carry the same authority, but they were not
necessarily produced by the same quality of verification. The faculty
that says *yes, this belongs in our system* runs on a finite human and
has, until now, been unobserved by the harness that trusts it.

The `cognitive-reservoir` skill, the `reservoir-warden` agent, the
`/reservoir` command, and the `reservoir-check` Stop hook together close
that gap. They are the framework's honest-confidence principle applied
reflexively: the framework finally observes the one actor it has always
trusted blindly, and does so without pretending to a precision it lacks.

## Why "stop when you feel tired" fails

The intuitive control fails because the metacognition that would notice
the fatigue draws on the same capacity being spent. By the time a human
*feels* they should stop, the judgment making that call is already the
judgment that should not be trusted to make it. The corrective therefore
has to be **external and count/time-based**, not judgment-based — it
counts what it can see rather than asking the human how they feel.

## Observable proxies, never a diagnosis

The mechanism counts only four **observable** proxies over a recent git
window:

- **continuous session span** — the vigilance decrement says sustained
  time-on-task reliably degrades performance;
- **decision volume** — approval-like events (commits/merges) as the
  proxy for "times the human said yes";
- **context switches** — distinct work streams touched; task-switching
  cost / attention residue says the cost scales with the *switching*,
  not the agent count, which is exactly what multi-agent orchestration
  accumulates invisibly;
- **wall-clock hour** — mapped to a circadian band only when a
  chronotype is declared.

Every statement carries one confidence flag. Counts are `observed`. Risk
read off the counts is `inferred` and always defeasible. Anything about
the human — chronotype, whether a break was real rest — is `asked` and
never assumed. The mechanism **never combines the proxies into a single
fatigue score**: that would manufacture a precision the inputs cannot
support.

## Honest about contested science

The popular "decision fatigue" narrative rests on two contested pillars
that this mechanism deliberately **does not assert as fact**:

- **Ego depletion** — the strong "willpower is a finite resource that
  drains with use" model. A 2016 multi-lab Registered Replication Report
  (23 labs, N ≈ 2,141) found an effect of d = 0.04 with a confidence
  interval crossing zero. *"The reservoir empties"* is a useful
  **metaphor** — and the name of the skill — but not a measured
  mechanism.
- **The hungry-judges study** — the headline "65% → near 0%" figure
  depends on case ordering that later work challenged. It must not be
  quoted as established.

What the design stands on instead is robust: task-switching cost,
vigilance decrement, chronotype-dependent circadian variation, and (as
suggestive context) Ericsson's 4–5 h/day deliberate-practice ceiling.
Every output is framed as a **precaution under uncertainty**, never a
diagnosis. This honesty is a hard requirement of the design, not
editorial flavour.

## Advisory only, never a gate

The mechanism is **opt-in per project** via a `Cognitive reservoir` block
in `HARNESS.md`, which doubles as the marker the Stop hook greps for. It
is deliberately **not** modelled as a Constraint. Constraints are gates
with a scope that can fail CI; wiring a human-state advisory into a
blocking gate would both defeat its purpose and overclaim a measurement
the proxies cannot support. So it never blocks a commit, merge, or
session, never fails CI, and never persists a record of the human's
state to disk — the human edits the `HARNESS.md` block themselves.

When a threshold is crossed it surfaces the proxies and the inferred
risk with caveats, then offers the one firm principle:

> Decide your stop **before the next session begins**, while the
> judgment making the decision is still the kind you would trust. Do not
> negotiate the boundary with your tired self.

It pairs that with one concrete, time-boxed option — "re-review today's
last two approvals tomorrow morning on a full reservoir" — and then goes
silent. No lecture, no second nudge, no score.

## The prohairesis stays with the engineer

The lineage is the *Twentieth Watt* essay and Epictetus: the governance
of one's own cognitive state is the one thing the framework cannot do
for the engineer. The *prohairesis* — the capacity for reasoned choice —
remains theirs. The warden watches; it never chooses. A cluster of
advisories a human routinely ignores is a signal to tune the
`HARNESS.md` thresholds, not to weaken the honesty rule — and certainly
not to take the decision out of human hands.

## See also

- The [how-to guide](../how-to/watch-your-cognitive-reservoir.md) for
  opting in, reading, and tuning.
- The `reservoir-warden` agent and `reservoir-check` hook entries in the
  [Agents](../reference/agents.md) and [Hooks](../reference/hooks.md)
  reference.
- The [Decision Discipline Triad](decision-discipline-triad.md) — the
  carpaccio / diaboli / cartographer agents that protect the human's
  decision budget at the *input* side, complementary to the warden's
  watch on the verifier at the *output* side.
- [Sentinels](sentinels.md) — the reservoir-warden is one of five
  sentinels: agents whose object of care is the human's understanding
  and judgement rather than an artefact.
