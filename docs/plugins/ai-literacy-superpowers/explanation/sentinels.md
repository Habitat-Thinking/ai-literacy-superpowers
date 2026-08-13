---
title: Sentinels
---

# Sentinels — the agents that guard the human

Most agents in the plugin act on an artefact. The `spec-writer` edits a
spec, the `tdd-agent` writes tests, the `integration-agent` commits and
merges, the `harness-gc` rewrites stale documentation. You judge each by
what it did to the thing it touched.

A **sentinel** is different. Its object of care is not the codebase, the
pipeline, or the harness — it is the human.

> **Sentinel** — any agent whose primary purpose is to protect and
> support the understanding and judgement of the human in the workflow.
> It informs, challenges, surfaces, or warns — it never fixes, writes,
> merges, or decides.

The category emerged organically before it was named. The
[decision-discipline triad](decision-discipline-triad.md) — `carpaccio`,
`advocatus-diaboli`, `choice-cartographer` — plus the `reservoir-warden`
(see [Watching the verifier](watching-the-verifier.md)) and later the
`cost-estimator` were all built to the same shape without anyone naming
the shape. Naming it lets the next one be built deliberately, and lets
the shape be enforced rather than merely hoped for.

## Why the category exists: the debts AI moves upstream

Margaret-Anne Storey's **triple-debt model** gives the sentinel category
its reason to exist.[^storey] Storey argues that generative AI generates
code faster than a team can comprehend it, and that this shifts *where*
the most significant risk to software health lives. Three debts interact:

- **Technical debt** lives in the **code** — the quality shortcuts in the
  codebase itself. This is the debt the plugin's pipeline and harness
  agents already fight (TDD, CUPID review, garbage collection).
- **Cognitive debt** lives in the **people** — "the erosion of shared
  understanding across a team", leaving increasingly inadequate mental
  models for reasoning about and safely changing the system.
- **Intent debt** lives in the **artefacts** — the absence or erosion of
  the explicit rationale, goals, and constraints that both humans and
  agents need in order to evolve the system safely.

Storey's claim is that in AI-assisted development, cognitive and intent
debt may matter *more* than technical debt — and neither is paid down by
making the code cleaner. They are paid down by protecting the human's
grip on the system. **Sentinels are the agent pattern that services the
human side of that ledger.** A sentinel does not touch the code; it works
to establish and protect the human's **understanding, judgement, and
discernment** so that cognitive and intent debt do not silently accrue as
the AI produces output faster than a person can absorb it.

### Three edges of one commitment

*Understanding, judgement,* and *discernment* are not three separate
goals — they are three edges of the same commitment to keep the human in
genuine command of an AI-accelerated workflow. Each maps to a debt a
sentinel holds back:

| Edge | What it protects | Debt it holds back | Sentinels |
| --- | --- | --- | --- |
| **Understanding** | The human's shared mental model of what the system does and why | Cognitive debt | `carpaccio` keeps each decision small enough to hold; `choice-cartographer` surfaces the implicit decisions a spec has made |
| **Judgement** | The quality of the human's *yes* at the gate | Cognitive debt | `reservoir-warden` watches the state of the decider; `advocatus-diaboli` steel-mans the objections before the human commits |
| **Discernment** | The human's ability to tell a *good* AI output from a *plausible-but-wrong* one | Cognitive + intent debt | `advocatus-diaboli` names what could be wrong; `cost-estimator` refuses an ungroundable estimate rather than fabricating a confident one |

Discernment is the sharpest edge — and the one AI erodes most quietly. A
plausible spec, a confident estimate, a clean-looking diff all *read* as
correct; discernment is what lets a human tell the genuinely-sound from
the merely-fluent. The `advocatus-diaboli` exists to make that
distinction visible, and the `cost-estimator`'s refusal-over-fabrication
rule exists so a fluent-but-baseless number never passes for a grounded
one.

Several sentinels also pay down **intent debt directly**: the
`choice-cartographer`'s choice-story records and the `advocatus-diaboli`'s
objection records are *externalised rationale* — exactly the artefacts
whose absence Storey names as intent debt. A sentinel's advisory output
is not only consumed by the human at the gate; once written it becomes
the durable "why" that a later human or agent needs.

[^storey]: Margaret-Anne Storey, *From Technical Debt to Cognitive and
    Intent Debt: Rethinking Software Health in the Age of AI*, 2026 —
    [arXiv:2603.22106](https://arxiv.org/abs/2603.22106), with an
    expanded version in [ACM Queue](https://queue.acm.org/detail.cfm?id=3807966).
    See also [margaretstorey.com](https://margaretstorey.com/).

## The sentinel signature

An agent is a sentinel if and only if it satisfies all three criteria.

| # | Criterion | Testable form |
| --- | --- | --- |
| S1 | **Read-only trust boundary** | Frontmatter denies Write/Edit (Bash may be permitted for read-only inspection, e.g. `git log`) |
| S2 | **Advisory output for a human** | The output is a record, objection, story, estimate, or recommendation a *human* disposes; it triggers no automated action |
| S3 | **Explicit epistemic honesty rule** | The agent declares the status of its claims (observed/inferred/asked flags, objection categories with evidence requirements, refusal over fabrication) |

**S1 is machine-checkable.** The
`sentinel-integrity-check.sh` script parses every agent's `role:` tag and
`tools:` list; a `role: sentinel` agent granted Write or Edit fails CI,
and so does any `role:` value outside the enum `{sentinel}`. The check
runs at PR time (`harness.yml`), weekly in the GC sweep (`gc.yml`), and
as a Layer-0 test with red/green fixtures. This is what makes the
category *load-bearing* rather than decorative: mislabel an agent and the
build goes red. S2 and S3 are agent-verifiable via the harness-enforcer.

## The roster

| Agent | Guards | Signature evidence |
| ----- | ------ | ------------------ |
| `carpaccio` | Judgement scale — keeps each decision small enough to hold | Read-only; slice dispositions are a hard human gate |
| `advocatus-diaboli` | Decisions at both gates — spec-time premises, code-time risks | Read-only; six-category objection record disposed by human; evidence requirements per objection |
| `choice-cartographer` | Understanding of implicit decisions | Read-only; choice stories disposed at a soft gate; six-lens map declares what was found vs. inferred |
| `reservoir-warden` | The decider — the verifier's cognitive reservoir | Read-only (no Write/Edit); single decide-your-stop-first recommendation; observed/inferred/asked flags; persists no record of human state |
| `cost-estimator` | The decision's inputs — what a choice will cost before it is made | Read-only; human disposes the estimate record; refuses rather than fabricating an ungroundable estimate |
| `mast` | The pact — that a limit set in clear weather survives contact with the moment it governs | Read-only; recites before measuring; refuses to estimate spend; discloses its own check's blind spot; never gates |
| `wip-warden` | The count — how much is open at once, against a line the person drew | Read-only; counts sessions and never watches the human; reports the count's flag; never invents a limit; says plainly that `strict` cannot compel |
| `coda` | The ending — that a session stops by decision rather than by attrition | Read-only; returns record content for `/coda` to persist; per-item observed/inferred/asked flags; never refuses a next action and never records why someone stopped |
| `convener` | The room — that a spec is not decided by everyone it affects being absent | Read-only; voices disposed at a soft gate; observed/inferred/asked per voice; never contacts anyone and never drafts a message to send |

The roster splits into **two disciplines**, plus one agent in neither.

The [decision discipline](decision-discipline-triad.md) asks whether a decision
is sound. The [cadence discipline](cadence-discipline.md) — `coda`, `mast`,
`wip-warden`, `convener` — guards the *shape of the work* around decisions: how
a session ends, what limits survive the moment they govern, how much is open at
once, and who was never asked. Those questions assume a person in a condition to
answer them; the cadence discipline is about that condition.

The `reservoir-warden` belongs to neither, and deliberately: it watches *the
decider*, so gating lives in the cadence sentinels and the one agent observing
the human never acquires teeth.

The narrative: the decision-discipline triad guards *decisions*; the
`reservoir-warden` guards *the decider*; the `cost-estimator` guards
*the decision's inputs*; the `coda` guards *the ending* — that a
session stops by decision rather than by attrition, and that what was
left open is written down rather than carried — and the `mast` guards
*the pact*, so that a limit set in clear weather is still there when the
weather changes. The `wip-warden` guards *the count*, and the `convener`
guards *the room* — a spec can be internally excellent and still be wrong
because the person who wrote it never asked the one question that would
have changed it, and that failure is invisible from inside.

## Using them

The roster above says what each sentinel *guards*. This says when to reach for
one.

| Sentinel | Reach for it when | Run | Guide |
| --- | --- | --- | --- |
| `carpaccio` | A task is big enough that you cannot hold the whole decision at once | `/carpaccio` | [Slicing a task](../how-to/slicing-a-task.md) |
| `advocatus-diaboli` | A spec is about to be approved, or code is about to be integrated | `/diaboli` | [Review a spec adversarially](../how-to/review-a-spec-adversarially.md) |
| `choice-cartographer` | A spec has made decisions nobody wrote down as decisions | `/choice-cartograph` | [Run choice-cartograph](../how-to/run-choice-cartograph.md) |
| `convener` | A change reaches past the room — a published surface, a default, an error message | `/convene` | [Convening the voices](../how-to/convening-the-voices.md) |
| `cost-estimator` | You want the token and time cost of a task **before** committing to it | `/cost-estimate` | [Estimate task cost](../how-to/estimate-task-cost.md) |
| `reservoir-warden` | You have been at it a while and want the observable proxies, not a verdict | `/reservoir` | [Watch your cognitive reservoir](../how-to/watch-your-cognitive-reservoir.md) |
| `wip-warden` | You suspect more is open at once than you can hold | `/wip` | [Watching your WIP](../how-to/watching-your-wip.md) |
| `mast` | You want a limit you set in clear weather to survive the moment it governs | `/mast` | [Keeping a pact](../how-to/keeping-a-pact.md) |
| `coda` | A session is ending and you would rather stop by decision than by attrition | `/coda` | [Closing a session](../how-to/closing-a-session.md) |

### You do not have to adopt them all

Nothing here is required, and nothing cascades. Each sentinel reads its own
declaration surface and stays silent when you have not declared one — a
`Session WIP` block you never wrote means `/wip` reports no limit rather than
inventing one, and a project with no `## Stakeholders` section gets a shorter,
`inferred`-flagged voice list rather than a warning.

**The four in the pipeline run whether you ask or not.** `carpaccio`,
`advocatus-diaboli`, `choice-cartographer` and `convener` have positions in the
orchestrator's flow, because the failures they catch are invisible from inside
the work — the people who most need them are the people who would not think to
run them. The commands above are for running one on demand.

**The other five are yours to call.** `/reservoir`, `/wip`, `/mast`, `/coda` and
`/cost-estimate` answer when asked and otherwise stay out of the way.

### If you only try one

`/coda`, at the end of a session you would otherwise let trail off. It is the
cheapest to adopt — no declaration surface to write first — and it produces the
thing the others depend on: a session that ended on purpose, with what was left
open written down rather than carried.

### A second declaration surface: the pact file

The **cadence sentinels** now under construction — the Coda, the Mast,
the WIP Warden, and the Convener — read a surface that did not exist
before them: `~/.claude/pacts.md`, documented at
[Pact file format](../reference/pacts-format.md).

The split matters, and it is not an accident of filing. `HARNESS.md` is
the **repository's** declaration surface: what this project requires of
anyone who works on it. The pact file is the **person's**: what one human
has decided about how they work. A stop hour and a concurrency limit
belong to a person, not to a project, so they live outside every work
tree and are never committed — nothing about the human is written into
any repository's history.

That boundary is the sentinel ethic applied to storage. It also draws a
line that every sentinel author needs: *persist nothing about the person*
forbids claims an agent makes **about** someone — inference, telemetry,
scoring. It does not forbid a pact the person authored themselves, which
is a statement **by** them. A pact that is not durable is not a pact.
`## Cognitive reservoir` has always worked this way, holding a
self-declared `chronotype` while forbidding any recorded claim about
cognitive state.

## The near-miss gallery

The signature has a trap. **Read-only plus advisory is not sufficient.**
Two agents satisfy S1 and S2 and are still not sentinels, because the
category turns on the *object of care*, not the trust boundary.

- **`code-reviewer`** — read-only (S1 ✓), reports findings to a human
  (S2 ✓). Not a sentinel: its object of care is the *code*. Its finding
  is "this function violates the joinability property", not "you are
  about to approve something you do not understand".
- **`harness-auditor`** — read-only but for the Status section (S1 ✓ in
  spirit), reports to a human (S2 ✓). Not a sentinel: its object of care
  is the *harness* — whether declared enforcement matches reality.

The test: does the finding describe *what the human can or should hold
in mind* (sentinel), or *the state of an artefact* that happens to be
reported to a person (near-miss)?

## Extending the category

When you author a new sentinel:

1. Check S1, S2, S3. All three, or it is not a sentinel.
2. Run the near-miss test — object of care is the human's understanding,
   not an artefact.
3. **Write the honesty rule (S3) first**, before the detection logic.
   This mirrors the `cognitive-reservoir` skill's contested-vs-robust
   science discipline: fixing what you refuse to assert *first* bounds
   what the detection is allowed to say, so the logic can never quietly
   outrun the evidence.
4. Add `role: sentinel` to the frontmatter, confirm no Write/Edit, and
   let `sentinel-integrity-check.sh` enforce it.
5. Add the agent to the README Sentinels section and this page.

Avoid the three anti-patterns — an agent that **scores the human**,
**persists a record of the human's state**, or **gates automatically**
has left the category, whatever its `role:` tag says.

The full authoring guidance lives in the `sentinel-design` skill, and
the step-by-step walkthrough is the
[Design a Sentinel Agent](../how-to/design-a-sentinel.md) how-to guide.

## What this is not

- **Not a new gate.** Sentinels feed existing gates; the category adds
  none.
- **Not a behavioural change.** Every roster agent behaves exactly as
  before; the `role: sentinel` tag is additive.
- **Not cross-plugin (yet).** The `diagnostic-legibility` plugin's
  charter ("maintaining human understanding") makes it a natural future
  sentinel host, but that migration is deferred to a separate spec.
