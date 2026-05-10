---
title: Agent Orchestration
---
# Agent Orchestration

Agent orchestration is the practice of distributing AI-assisted development work across multiple specialised agents, each with a defined role and bounded permissions, rather than funnelling all tasks through a single omniscient conversation. This page explains why that separation matters, how trust boundaries enforce it, and where the approach breaks down.

---

## The Single-Agent Bottleneck

Most teams use AI coding assistants in a single loop: describe what you want, read the output, spot problems, ask for fixes, spot new problems, fix the rest yourself, commit. In this model, you are the only quality gate. Every line of output passes through your eyes. Every mistake is yours to catch.

This is the single-agent bottleneck. As the work grows, the constraint is not the AI's ability to generate code. The constraint is your ability to review it. The AI scales; you do not.

{: .note }
> **Try this:** Think about the last time you used an AI assistant for a substantial task. How long did you spend *generating* the code versus *reviewing and fixing* the code? If the ratio surprises you, you have found the bottleneck.

---

## Separation of Concerns Applied to Agents

On a well-run engineering team, nobody does everything:

- A **product person** writes the spec — what and why
- A **developer** implements it
- A **reviewer** checks the work — different eyes, different perspective
- A **QA engineer** tries to break it
- A **tech lead** makes architectural calls

Nobody reviews their own work. The person who wrote something is the worst person to check it. You already know this from experience: you stare at a bug for two hours, a colleague finds it in thirty seconds.

The same principle applies to AI agents.

---

## Specialised Agents, Defined Roles

Instead of one agent that does everything, you build a team of specialised agents, each with a focused job:

**The Spec Writer** takes your requirements and turns them into a precise specification. What exactly are you building? What are the acceptance criteria? What is in scope? This agent only writes specs. It does not write code. It thinks about *what* before anyone thinks about *how*.

**The Test Writer** takes the spec and writes failing tests. Not code — tests. This is TDD discipline enforced structurally: the implementation agent has not been invoked yet, so implementation code literally cannot be written at this stage.

The Test Writer carries two operating branches. For generic code work, it writes failing tests in the project's test framework (Go, Python, etc.) — the conventional sense of RED. For **agent artefact work** — specs that add a new file under `skills/`, `agents/`, or `commands/` — it authors a TDAD scenario file at `tdad_tests/scenarios/<type>/<name>/<aspect>.md` describing the expected behaviour with `Given / When / Then / Rubric` sections. The orchestrator detects which branch applies by inspecting the plan's intended file paths, and the deterministic CI workflow `tdad-scenario-check.yml` enforces that any added agent artefact ships with a non-`finding`-tier scenario at PR time. Modifications to existing agent artefacts are out of scope for the constraint — the orchestrator surfaces the question but does not enforce an answer (acknowledged limitation per the spec at `docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md`).

**The Implementer** writes the minimal code to make those tests pass. Nothing more. It does not decide what to build (the spec already did that). It does not decide what "correct" means (the tests already did that). It makes green lights appear.

**The Reviewer** looks at the implementation with fresh context and different instructions. It checks for convention violations, architectural drift, and things the implementer missed. It has never seen this code before. The implementer was focused on making tests pass; the reviewer is focused on whether the code *should have been written that way*. It does this instantly, every time, without calendar coordination.

**The Integrator** handles the mechanical aftermath: changelog, commit message, PR, CI. The work that still needs to be right but does not need creative judgement.

> **The Sceptic:** "Five agents? That's a lot of overhead for what one agent can do in a single conversation."
>
> **The Veteran:** "One agent *can't* do it in a single conversation. One agent does five different jobs poorly, and then you spend an hour cleaning up the mess."
>
> **The Sceptic:** "How do you know?"
>
> **The Veteran:** "Because I spent six months as the human duct tape between an AI and my codebase before I figured out the problem wasn't the AI."

---

## Trust Boundaries

Giving agents different roles is not enough. You need to give them different **permissions**. This is where the architecture becomes enforceable.

If your reviewer agent can also modify the code it is reviewing, you do not have a reviewer. You have another implementer pretending to review. If your implementer can merge its own PRs, you have eliminated the review step entirely.

This is **bounded trust** — the principle of least privilege applied to AI agents. Every agent gets exactly the permissions it needs to do its job, and not one permission more.

| Agent | Can do | Cannot do |
| ------- | -------- | ----------- |
| Spec Writer | Read requirements, write specs | Execute code, access shell |
| Test Writer | Read specs, write test files | Write implementation code |
| Implementer | Read tests, write implementation | Approve or merge PRs |
| Reviewer | Read code, flag issues, approve/reject | Modify implementation |
| Integrator | Commit, push, create PRs | Write or change application code |

The boundary that matters most — the one people violate first — is between the implementer and the tests. If the implementer can edit test files, it can make the tests match the implementation instead of the other way around. TDD collapses. The tests were written before the implementer existed. They define correctness. The implementer does not get to redefine it.

{: .warning }
> Here is what happens without trust boundaries: you set up an agent that can write code, review its own code, approve its own review, and merge its own PR. You have built an automated system with zero quality gates. Every mistake goes straight to production. This is not a hypothetical. People build this. It goes badly.

The temptation to give every agent full permissions — just to make things easier, just this once — is strong. Resist it. "Just this once" is how every trust boundary dies.

---

## The Pipeline

These agents work together in a pipeline with gates:

```text
Requirements
    |
    v
[Spec Writer] --> Spec document
    |
    v
[Advocatus Diaboli] --> Objection record
    |
    v
*** HUMAN ADJUDICATES OBJECTIONS (hard gate) ***
    |
    v
[Choice Cartographer] --> Choice-story record
    |
    v
*** HUMAN ADJUDICATES STORIES (soft gate) ***
    |
    v
*** HUMAN REVIEWS AND APPROVES SPEC ***
    |
    v
[Test Writer] --> Failing tests
    |
    v
(tests run automatically to confirm they fail)
    |
    v
[Implementer] --> Implementation code
    |
    v
(tests run automatically to confirm they pass)
    |
    v
[Reviewer] --> Approve / Request changes
    |                       |
    |                       v
    |               [Implementer fixes]
    |                       |
    |               [Reviewer re-checks]
    |               (max 3 cycles!)
    |                       |
    v                       v
[Integrator] --> Changelog, commit, PR, CI
```

Three things matter here.

**The human gates.** There are now three. First, the advocatus-diaboli reviews the spec and produces an objection record — you adjudicate each objection, writing your disposition and rationale inline. The agent cannot do this for you: its trust boundary is read-only. The diaboli's gate is **hard** — the pipeline refuses to advance while any disposition is `pending`. Second, the choice-cartographer maps the implicit decisions the spec has made and produces a choice-story record — you write dispositions for each story (the same trust-boundary mechanism applies). The cartographer's gate is **soft** — `cartograph_pending_count` is surfaced as observability and the pipeline continues; the merge-time HARNESS constraint blocks the PR until dispositions are written. Third, you review and approve the *spec* itself. Not line 47 of a 200-line diff — the plan. "Is this what I actually want? Does this approach make sense? Are we building the right thing?" That is the highest-leverage decision in the process. Once you approve the spec, the pipeline can run without you. See [Decision Archaeology](decision-archaeology.md) for why the cartographer's gate is soft and the diaboli's is hard.

**The cycle limit.** When the reviewer rejects and the implementer fixes, there is a maximum of three cycles. Without a limit, you get agent ping-pong: the reviewer keeps finding issues, the implementer keeps introducing new ones, and the token cost keeps climbing. Three cycles is enough for genuine iteration. If it is not resolved in three, a human needs to look — and the problem is usually in the spec, not the code.

{: .note }
> **Try this:** Imagine you are building an agent pipeline for a different domain — say, writing documentation instead of code. What agents would you create? What would each one's trust boundary be? Where would you put the human gates? Sketch it before reading on. Designing trust boundaries is the skill this section teaches.

---

## Fireside Chat: Bounded Trust in Practice

> **Reviewer Agent:** I flagged three issues in your implementation. The error handling in the payment flow does not match the project conventions.
>
> **Implementer Agent:** I see the flags. I will fix them. But I could also fix that formatting issue in the test file while I am at it.
>
> **Reviewer Agent:** That test file is not yours. The Test Writer owns test files. You own implementation files.
>
> **Implementer Agent:** That seems inefficient. It is a one-line change.
>
> **Reviewer Agent:** It is a one-line trust boundary violation. If you can edit test files, you can make the tests match your implementation instead of the other way around. The tests were written *before* you existed. They define correctness. You do not get to redefine it.
>
> **Implementer Agent:** ...fair point.
>
> **Reviewer Agent:** And I cannot edit your code either. I can only flag it. If I could edit it, I would stop being a reviewer and start being a second implementer with opinions. That is not the same thing.

---

## Where This Breaks Down

The pipeline assumes clean handoffs. In practice, specs are ambiguous. The test writer interprets a spec one way; the implementer interprets it another. The reviewer flags a "convention violation" that is actually a judgement call. The three-cycle limit expires on something that needed a conversation, not more iterations.

**Over-specifying.** If your spec is too detailed, the pipeline becomes a Rube Goldberg machine — you spend more time writing the spec than writing the code would have taken. The spec should capture *intent and constraints*, not implementation decisions. If you are describing function signatures in the spec, you have gone too far.

**Agents that agree too easily.** A reviewer that approves everything is worse than no reviewer, because it gives you false confidence. You need to tune your reviewer's instructions to be genuinely adversarial — not hostile, but sceptical. "What is wrong with this?" is a better reviewer prompt than "Is this OK?"

The structural solution to sycophantic reviewers is not better instructions — it is a separate agent whose entire charter is disagreement, dispatched before any implementation artefacts exist. This is the advocatus-diaboli: a read-only agent that reviews the spec, raises evidence-grounded objections, and cannot write its own dispositions. The last constraint is structural: a human must open the objection record and adjudicate before the pipeline proceeds. This is not a quality filter — it is a cognitive-engagement gate. See [Adversarial Review](adversarial-review.md) for the full conceptual background.

**Context loss between agents.** Each agent starts fresh. That is the point — fresh eyes. But it also means the implementer's reasoning about *why* it made a particular trade-off does not reach the reviewer. The reviewer sees a choice and flags it as wrong without knowing the constraint that forced it. Good pipeline design mitigates this with structured handoff documents, but it does not eliminate it.

> **The Pragmatist:** "OK but what do I actually do on Monday?"
>
> Start by noticing where you are doing mechanical work that an agent could do. Every time you manually check a PR for naming conventions, that is a reviewer agent's job. Every time you write a changelog entry, that is an integrator's job.
>
> You do not need to build the whole pipeline at once. Start with one separation. Maybe a review step that runs automatically. Then add another. The architecture is the insight. The implementation is incremental.

---

### FAQ

**Q: Is five agents more expensive than one?**

Each agent is simpler and more focused, which means it needs less context and produces more predictable output. A focused agent with a clear, small job often uses fewer tokens than an omniscient agent juggling five responsibilities and losing track of three of them. But measure it for your situation — this is an empirical claim, not a universal truth.

**Q: What if the agents disagree?**

That is the review process working. The reviewer can reject, and the implementer fixes. If they cannot converge in three cycles, the human steps in. It is the same thing that happens when a human reviewer requests changes on a PR. The difference is it happens in seconds, not days.

---

## Key Takeaways

- **The single-agent bottleneck** — one agent doing everything makes *you* the only quality gate. That does not scale.
- **Specialised agents** — spec writer, adversarial reviewer, test writer, implementer, reviewer, integrator. Six focused jobs, no overlap.
- **Trust boundaries** — each agent gets exactly the permissions it needs. The reviewer cannot write code. The implementer cannot merge. The implementer cannot edit tests. This is least privilege applied to AI.
- **The pipeline** — agents work in sequence with gates. The most important gate is the human approving the spec before any code is written.
- **Where it breaks** — ambiguous specs, compliant reviewers, and context loss between agents. The architecture helps; it does not solve everything.

---

## Further reading

- [Agents Reference](../reference/agents.md) — detailed catalogue of all agents in this plugin
- [Adversarial Review](adversarial-review.md) — the concepts behind the advocatus-diaboli and the human-cognition gate
- [Decision Archaeology](decision-archaeology.md) — the choice-cartographer's role; intent debt and cognitive debt; the soft gate / hard gate asymmetry
- [Compound Learning](compound-learning.md) — how agent output feeds the learning loop
- [Constraints and Enforcement](constraints-and-enforcement.md) — the constraints agents enforce
- [Harness Engineering](harness-engineering.md) — the broader framework that agent orchestration fits within
