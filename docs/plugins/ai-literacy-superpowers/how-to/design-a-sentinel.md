---
title: Design a Sentinel Agent
---
# Design a Sentinel Agent

Author a new **sentinel** — an agent whose object of care is the human's
understanding and judgement rather than an artefact — so that it earns
its `role: sentinel` tag and passes the integrity constraint.

There is no `/sentinel` command; the category is a design discipline
carried by the [`sentinel-design`](../reference/skills.md#sentinel-design)
skill and enforced by a deterministic constraint. This guide walks
through creating one from scratch.

For the *why* — the definition, the roster, and the narrative framing —
read the [Sentinels](../explanation/sentinels.md) concept page first.
This page is the *how*.

---

## Before you start

Load the skill so its guidance is in context:

```text
Read the sentinel-design skill
```

A sentinel must satisfy all three parts of the **sentinel signature**:

| # | Criterion | What it means in practice |
| --- | --- | --- |
| S1 | Read-only trust boundary | Frontmatter grants no `Write`/`Edit` (`Bash` is allowed for read-only inspection like `git log`) |
| S2 | Advisory output for a human | The output is a record, objection, story, estimate, or recommendation a *human* disposes — it triggers no automated action |
| S3 | Explicit epistemic honesty rule | The agent declares the status of its claims (observed/inferred flags, evidence requirements, refusal over fabrication) |

If your candidate fails any one of these, it is not a sentinel — see
[Is it actually a sentinel?](#is-it-actually-a-sentinel) below.

---

## 1. Confirm the object of care is the human

The category turns on *what the agent cares about*, not its trust
boundary. Ask: does the agent's output describe **what the human can or
should hold in mind**, or the **state of an artefact** that merely gets
reported to a human? A sentinel exists to hold back the *cognitive* and
*intent* debt of Storey's
[triple-debt model](../explanation/sentinels.md#why-the-category-exists-the-debts-ai-moves-upstream)
— it establishes and protects the human's understanding, judgement, and
discernment, not the health of the code.

- "You are about to approve a spec whose cost you have not seen" →
  sentinel (guards the decider).
- "This function violates the joinability property" → not a sentinel;
  its object of care is the code (this is the `code-reviewer`'s job).

Read-only-plus-advisory is **not** sufficient. The `code-reviewer` and
`harness-auditor` both satisfy S1 and S2 and are still not sentinels —
their objects of care are the code and the harness. The skill's
near-miss gallery covers this trap in full.

---

## 2. Write the honesty rule (S3) *before* the detection logic

This is the load-bearing discipline. Decide what your agent will
**refuse to assert** before you write what it detects. Fixing S3 first
bounds what the detection is *allowed* to say, so the logic can never
quietly outrun the evidence.

This mirrors the
[`cognitive-reservoir`](../reference/skills.md#cognitive-reservoir)
skill's contested-versus-robust science discipline: the
`reservoir-warden`'s
honesty rule (which claims are precaution, which figures are never
asserted as fact) was fixed before its proxy-counting logic. Do the
same. Concretely, decide:

- Which claims are **observed** (directly counted), which are
  **inferred** (defeasible), and which require **asking** the human.
- What the agent does when it *cannot* ground a claim — a sentinel
  refuses rather than fabricating.
- What it will never emit (a score of the human, a single composite
  verdict, a diagnosis).

Only once that is written should you design the detection or estimation
logic.

---

## 3. Author the agent file

Create `ai-literacy-superpowers/agents/<your-sentinel>.agent.md` with
read-only tools and the `role: sentinel` tag:

```markdown
---
name: your-sentinel
description: Use when … — reads …, reports … with observed/inferred flags,
  and offers … for a human to dispose; read-only by design, never writes
  a record of the human's state
tools: [Read, Glob, Grep]
role: sentinel
---

# Your Sentinel Agent

You watch … . You count what you can see, report it honestly with
confidence flags, and offer the human a single disposable
recommendation. You do not decide. You do not score. You do not write.

## Your first action

Read the `sentinel-design` skill in full, then …
```

Notes:

- `role: sentinel` is an **enum with a single value**. A typo (e.g.
  `role: sentinal`) fails the integrity check loudly rather than
  silently exempting the agent.
- Add `Bash` to `tools` only if you need read-only inspection
  (`git log`, `date`). Never add `Write` or `Edit`.
- If you back the agent with a skill (recommended for anything with a
  methodology), author the skill too and have the agent read it as its
  first action — the way each existing sentinel reads its own skill.

---

## 4. Let the integrity constraint enforce S1

The [Sentinel integrity](../explanation/sentinels.md#the-sentinel-signature)
constraint makes the category load-bearing: mislabel an agent and CI
goes red. Run the check locally before you push:

```bash
bash ai-literacy-superpowers/scripts/sentinel-integrity-check.sh \
  ai-literacy-superpowers/agents
```

- **Green** — every `role: sentinel` agent is read-only and every
  `role:` value is in the enum.
- **Red** — the message names the offending agent and the violated
  criterion (S1 for a Write/Edit grant; the invalid value for a bad
  enum).

The same script runs at PR time (`harness.yml`) and in the weekly
garbage-collection sweep (`gc.yml`), so the boundary is enforced
continuously, not just at authoring time.

---

## 5. Ship the required companions

Because you are adding a new plugin component, two harness constraints
apply. Include these in the *same* PR:

- **A TDAD scenario.** Add at least one scenario under
  `tdad_tests/scenarios/agents/<your-sentinel>/<aspect>.md` whose
  frontmatter declares `tier: structural`, `trigger`, or `behavioural`.
  A good structural scenario asserts the agent declares `role: sentinel`,
  is read-only, and carries its honesty rule.
- **A reference-page entry.** Add a `### <your-sentinel>` heading to
  `docs/plugins/ai-literacy-superpowers/reference/agents.md`.

Then surface the agent to humans:

- Add a row to the **Sentinels** table in `README.md` and to the roster
  in [`explanation/sentinels.md`](../explanation/sentinels.md).
- If it is invoked by a command, add a how-to guide for that command.

See [Update the Plugin](update-the-plugin.md) for the version-bump
locations a new component requires.

---

## Is it actually a sentinel?

Run the candidate past this checklist. All three, or it is not a
sentinel:

1. **S1** — no `Write`/`Edit` in frontmatter.
2. **S2** — a human disposes the output; nothing automated acts on it.
3. **S3** — the agent declares the status of every claim and refuses
   rather than fabricating.

Then confirm the object of care is the human's understanding, not an
artefact.

### Anti-patterns — these eject an agent from the category

- **It scores the human.** A single "fatigue score" or "judgement
  index" invites arguing with the number instead of attending to the
  state. Report proxies and precautions, never a composite grade.
- **It persists a record of the human's state.** No `Write` *by design*
  — a sentinel that files human-state records has built surveillance,
  not a guardrail. (This is also why S1 is enforced, not merely advised.)
- **It gates automatically.** A sentinel *feeds* an existing human gate;
  it does not become one. The moment its output blocks or advances the
  pipeline without a person disposing it, S2 is violated.

---

## When to use this

- When a new failure mode threatens the human's *understanding or
  judgement* — not the code, the pipeline, or the harness — and no
  existing sentinel covers it.
- When you catch yourself justifying a read-only advisory agent as
  "protecting the human" and want to make that claim enforceable rather
  than aspirational.

## Related

- [Sentinels](../explanation/sentinels.md) — the concept, the roster,
  and the near-miss gallery.
- [`sentinel-design`](../reference/skills.md#sentinel-design) skill —
  the authoring reference this guide operationalises.
- [Watch Your Cognitive Reservoir](watch-your-cognitive-reservoir.md) —
  the `reservoir-warden`, the archetypal sentinel.
- [Review a Spec Adversarially](review-a-spec-adversarially.md) and
  [Slicing a Task](slicing-a-task.md) — the decision-discipline triad,
  three more sentinels in action.
