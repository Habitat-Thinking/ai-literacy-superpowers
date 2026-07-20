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

The narrative: the decision-discipline triad guards *decisions*; the
`reservoir-warden` guards *the decider*; the `cost-estimator` guards
*the decision's inputs*.

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
- **Not a behavioural change.** The five roster agents behave exactly as
  before; the `role: sentinel` tag is additive.
- **Not cross-plugin (yet).** The `diagnostic-legibility` plugin's
  charter ("maintaining human understanding") makes it a natural future
  sentinel host, but that migration is deferred to a separate spec.
