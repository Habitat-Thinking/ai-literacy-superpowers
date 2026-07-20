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
