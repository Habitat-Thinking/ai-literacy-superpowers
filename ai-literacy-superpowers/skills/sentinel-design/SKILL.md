---
name: sentinel-design
description: Use when designing, reviewing, or classifying an agent that guards the human — defines the sentinel category, the three-part signature (S1 read-only, S2 advisory-to-human, S3 explicit honesty rule), the near-miss gallery that explains why read-only-plus-advisory is not sufficient, the honesty-rule-before-detection-logic discipline, and the three anti-patterns that eject an agent from the category
---

# Sentinel Design

Most agents in this plugin act on an artefact. The spec-writer edits a
spec, the tdd-agent writes tests, the integration-agent commits and
merges, the harness-gc rewrites stale documentation. Their object of
care is a thing in the repository, and you judge them by what they did
to that thing.

A **sentinel** is different. Its object of care is not the codebase, the
pipeline, or the harness — it is **the human**. A sentinel protects and
supports the understanding and judgement of the person in the workflow.
It informs, challenges, surfaces, or warns. It never fixes, writes,
merges, or decides.

> **Sentinel** — any agent whose primary purpose is to protect and
> support the understanding and judgement of the human in the workflow.

The category emerged organically. Four agents — the decision-discipline
triad (`carpaccio`, `advocatus-diaboli`, `choice-cartographer`) plus the
`reservoir-warden` — and later the `cost-estimator` were all built to
the same shape without anyone naming the shape. This skill names it, so
that the next one can be built deliberately rather than rediscovered.

## Why sentinels exist: the debts AI moves upstream

The category has a reason to exist, and it comes from Margaret-Anne
Storey's **triple-debt model** (*From Technical Debt to Cognitive and
Intent Debt: Rethinking Software Health in the Age of AI*, 2026;
arXiv:2603.22106, expanded in ACM Queue). Storey argues that generative
AI produces code faster than a team can comprehend it, which shifts where
the real risk to software health lives. Three debts interact:

- **Technical debt** lives in the **code** — the debt the pipeline and
  harness agents already fight.
- **Cognitive debt** lives in the **people** — the erosion of shared
  understanding, leaving inadequate mental models for safely changing the
  system.
- **Intent debt** lives in the **artefacts** — the absence of the
  explicit rationale, goals, and constraints humans and agents need to
  evolve the system safely.

In AI-assisted development, cognitive and intent debt may matter *more*
than technical debt — and neither is paid down by cleaner code. They are
paid down by protecting the human's grip on the system. **A sentinel is
the agent pattern that services the human side of that ledger.** It works
to establish and protect the human's **understanding, judgement, and
discernment** so those two debts do not silently accrue.

These are three edges of one commitment, each holding back a debt:

- **Understanding** — the shared mental model of what the system does and
  why (holds back cognitive debt). Guarded by `carpaccio` (keeps each
  decision holdable) and `choice-cartographer` (surfaces implicit
  decisions).
- **Judgement** — the quality of the human's *yes* at the gate (cognitive
  debt). Guarded by `reservoir-warden` (watches the decider) and
  `advocatus-diaboli` (steel-mans the objections).
- **Discernment** — the ability to tell a *good* AI output from a
  *plausible-but-wrong* one (cognitive + intent debt). This is the
  sharpest edge and the one AI erodes most quietly: a plausible spec, a
  confident estimate, and a clean-looking diff all *read* as correct.
  Guarded by `advocatus-diaboli` (names what could be wrong) and
  `cost-estimator` (refuses an ungroundable estimate rather than
  fabricating a confident one).

A sentinel's advisory record also pays down intent debt directly: a
choice-story or objection record *is* externalised rationale — the very
artefact whose absence Storey names as intent debt. Keep this in view
when authoring: prefer emitting a durable "why" the next human or agent
can read over a verdict that evaporates once the gate closes.

## The sentinel signature

An agent is a sentinel if and only if it satisfies all three criteria.

### S1 — Read-only trust boundary

The agent's frontmatter denies `Write` and `Edit`. It may hold `Read`,
`Glob`, `Grep`, and `Bash` — `Bash` is permitted for read-only
inspection (`git log`, `date`), not for mutation. A sentinel that can
write can change the thing it is supposed to be watching from the
outside, and the boundary that keeps it honest is gone.

S1 is the one criterion a machine can check. The
`sentinel-integrity-check.sh` script parses every agent's `role:` tag
and `tools:` list; a `role: sentinel` agent granted `Write` or `Edit`
fails CI. This is what makes the category load-bearing rather than
decorative: mislabel an agent and the build goes red.

### S2 — Advisory output for a human

The agent's output is a record, an objection, a story, an estimate, or a
recommendation that a **human** disposes. It triggers no automated
action. Nothing downstream reads the sentinel's output and *acts* on it
without a person in between. The reservoir-warden's stop recommendation,
the diaboli's objection record, the cartographer's choice stories, the
carpaccio's slice dispositions, the cost-estimator's estimate record —
each is deposited in front of a human who decides what to do with it.

### S3 — Explicit epistemic honesty rule

The agent declares the *status* of its claims. It does not launder
inference as observation. Concretely, each existing sentinel carries
its own honesty discipline:

- **reservoir-warden** — `observed` / `inferred` / `asked` flags on
  every proxy; every `inferred` claim must sit on an `observed` one;
  never a combined fatigue score.
- **advocatus-diaboli** — six objection categories, each with an
  evidence requirement; discloses what it did *not* challenge.
- **choice-cartographer** — a six-lens map that declares what was found
  in the spec versus what was inferred.
- **cost-estimator** — ranges with a disclosed confidence label;
  refuses rather than fabricating an ungroundable estimate.

The common thread: a sentinel would rather say "I don't know" than
invent a number, and always tells the human which of its claims are
solid and which are precaution under uncertainty.

## The roster

| Agent | Guards |
| ----- | ------ |
| `reservoir-warden` | The decider — the verifier's cognitive reservoir |
| `advocatus-diaboli` | Decisions at both gates — spec-time premises, code-time risks |
| `choice-cartographer` | Understanding of the implicit decisions a spec has made |
| `carpaccio` | Judgement scale — keeps each decision small enough to hold |
| `cost-estimator` | The decision's inputs — what a choice will cost before it is made |

Narrative: the decision-discipline triad guards *decisions*; the
reservoir-warden guards *the decider*; the cost-estimator guards *the
decision's inputs*.

## The near-miss gallery

The signature has a trap. **Read-only plus advisory is not sufficient.**
Two agents in this plugin satisfy S1 and S2 and are still not sentinels,
because the category turns on the *object of care*, not the trust
boundary.

- **code-reviewer** — read-only (S1 ✓), reports findings to a human
  (S2 ✓). Not a sentinel: its object of care is **the code**. Its
  finding is "this function violates the joinability property", not
  "you, the human, are about to approve something you do not
  understand".
- **harness-auditor** — read-only on everything but the Status section
  (S1 ✓ in spirit), reports to a human (S2 ✓). Not a sentinel: its
  object of care is **the harness** — whether declared enforcement
  matches reality. Its finding is about an artefact that happens to be
  reported to a person.

The test: does the finding describe *what the human can or should hold
in mind* (sentinel), or *the state of an artefact* that is merely
reported to a human (near-miss)? If you catch yourself justifying a new
agent's sentinel status with "well, it's read-only and a human reads its
output", you have found a near-miss, not a sentinel.

## Design discipline: honesty rule before detection logic

When you author a new sentinel, **write S3 before you write what it
detects.** This mirrors the `cognitive-reservoir` skill's
contested-versus-robust science discipline: the reservoir-warden's
honesty rule (which findings are precaution, which claims are never
asserted as fact) was fixed *before* its proxy-counting logic, so the
counting could never quietly outrun what the evidence supports.

A sentinel that grows its detection logic first, and bolts on an honesty
rule afterwards, will always be tempted to over-claim — the detection
found something, so surely it can be stated plainly. Fixing the honesty
rule first bounds what the detection is *allowed* to say. Decide what
you will refuse to assert, then build only what you can honestly report.

## Anti-patterns

An agent that does any of these has left the category, whatever its
`role:` tag says:

1. **Scores the human.** A sentinel reports proxies and precautions; it
   never emits a single number that grades the person (a "fatigue score",
   a "judgement quality index"). Composite scores invite the human to
   argue with the number instead of attending to their own state.
2. **Persists a record of the human's state.** The reservoir-warden has
   no `Write` *by design* — it never writes down that the human was
   tired at 21:00. A sentinel that files human-state records has built a
   surveillance artefact, not a guardrail. (This is also why S1 is
   enforced, not merely recommended.)
3. **Gates automatically.** A sentinel feeds an existing human gate; it
   does not become one. The moment its output blocks or advances the
   pipeline without a person disposing it, S2 is violated and the human
   has been removed from their own decision.

## When you have a candidate

1. Check S1, S2, S3 against the candidate. All three, or it is not a
   sentinel.
2. Run it past the near-miss test: object of care is the human's
   understanding, not an artefact.
3. Write the honesty rule first.
4. Add `role: sentinel` to the frontmatter, confirm no `Write`/`Edit`,
   and let `sentinel-integrity-check.sh` enforce it.
5. Add it to the roster in the README Sentinels section and the
   `explanation/sentinels.md` docs page.
