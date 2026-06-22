---
name: dynamic-workflows
description: This skill should be used when an agent is deciding whether to author a dynamic workflow — a self-authored, ephemeral multi-agent harness — for a task. Use when the user asks about "dynamic workflows", "multi-agent harness", "fan-out", "subagents in parallel", "adversarial verification", "the ultracode trigger", "should I use a workflow", or when a task looks long-running, massively parallel, highly structured, or adversarial. Names the six composable patterns, the election rubric for when NOT to spend the extra compute, and the two governance invariants (INV-1 ephemeral-proposes, INV-2 quarantine).
---

# Dynamic Workflows

A **dynamic workflow** is a self-authored, ephemeral multi-agent harness:
a small program an agent writes for one task, runs once, and discards. It
spawns subagents, gives each its own clean context window and model tier,
optionally isolates them in worktrees, and coordinates their results. The
capability and its patterns originate from Anthropic's "A harness for
every task: dynamic workflows in Claude Code" (Shihipar & Bidasaria,
2026); the runtime is triggered by the word `ultracode`.

This skill is **knowledge agents read, not a script they run** — a
sibling of [`harness-engineering`](../harness-engineering/SKILL.md) and
[`context-engineering`](../context-engineering/SKILL.md). It answers three
questions before any workflow is authored:

1. **When** is a workflow warranted? — see
   [`references/when-not-to-use.md`](references/when-not-to-use.md).
2. **Which** pattern fits? — see
   [`references/patterns.md`](references/patterns.md).
3. **How** does the plugin's governance constrain it? — see
   [`references/governance.md`](references/governance.md).

## Runtime scope — Claude Code only

Dynamic workflows are a **Claude Code runtime capability** and are **not
transferable** to GitHub Copilot CLI or any other coding agent — those
trees have no workflow runtime. This plugin ships to both the Claude Code
and Copilot CLI trees, so this skill is **knowledge everywhere, runtime
only on Claude Code**:

- **On Claude Code:** workflows can be authored and spawned; the patterns,
  election rubric, and templates are executable.
- **On Copilot CLI or any other agent:** there is no workflow runtime, so
  this skill is **guidance only** — the patterns and governance below are
  still worth reading, but no workflow can be spawned. An agent on such a
  tree must fall back to its existing static behaviour; it must never error
  or pretend to fan out.

Read the rest of this skill as a reasoning model that applies everywhere;
act on it as a runtime only where Claude Code provides one.

## Static harness vs. dynamic workflow

The plugin is, by default, a **static harness**: a fixed pipeline
(`spec-writer → GATE → tdd-agent → implementer → code-reviewer →
GUARDRAIL → integration-agent`) that must work for every task and
therefore tends toward the generic. A static harness is the right tool
for ordinary coding work, and it stays the default.

A dynamic workflow is the opposite: generated per task, disposable, and
able to hand each subagent a clean context window. That shape defeats
three failure modes the static pipeline is exposed to when one context
does too much:

| Failure mode | What it looks like |
| --- | --- |
| **Agentic laziness** | Declaring a multi-part job done after partial progress (35 of 50 constraints checked) |
| **Self-preferential bias** | An agent preferring its own output when asked to verify or judge it |
| **Goal drift** | Losing fidelity to the original objective across turns, worsened by lossy compaction |

Dynamic workflows are a **new execution substrate beneath the existing
agents** — they do not replace them, and they do not weaken governance.

## The six composable patterns

Authored workflows compose six patterns. Each is worked through with a
concrete micro-example in [`references/patterns.md`](references/patterns.md);
in brief:

- **classify-and-act** — route a task by type before doing it.
- **fan-out-and-synthesize** — split work across parallel subagents, then
  merge at a synthesis barrier.
- **adversarial verification** — a separate agent tries to refute a result
  before it is accepted.
- **generate-and-filter** — over-generate candidates, then prune.
- **tournament** — score independent attempts against a rubric, keep the
  winner.
- **loop-until-done** — iterate until a measurable completion test passes.

## Elect deliberately — the discipline

Workflows cost more tokens and suit complex, high-value tasks. Most
coding tasks do not need a panel of reviewers. Before authoring one, run
the four-question rubric in
[`references/when-not-to-use.md`](references/when-not-to-use.md): is the
task **long-running, massively parallel, highly structured, or
adversarial**? If none apply, use the static pipeline. A workflow should
be *elected*, never reflexive — over-orchestration is treated as a
regression.

Token budgets and model-tier routing for elected workflows live in the
project's `MODEL_ROUTING.md` (the *workflow election* section).

## The two governing invariants

Both are stated in full, for agents, in
[`references/governance.md`](references/governance.md):

- **INV-1 — Ephemeral proposes, durable curates.** A workflow is
  ephemeral; `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, and `MODEL_ROUTING.md`
  are durable and human-curated. A workflow may **propose** changes to
  them but may **never write them directly**. Discoveries flow through
  `REFLECTION_LOG.md → human curates → AGENTS.md`.
- **INV-2 — Quarantine.** Any workflow agent that reads untrusted or
  public content (web pages, external issues, third-party PRs) is withheld
  high-privilege tools. Acting on such information is done only by
  separate, trusted agents in the same workflow.

## The workflow template library

A library of opinionated, habitat-aligned workflow *templates* ships with
this skill under [`workflows/`](workflows/). They are **templates to adapt
per task, never scripts to run verbatim** — each carries a literate
preamble stating its pattern, its token budget and per-role model tiers,
and the INV-1 boundary it respects. Adapt the prompts, model tiers, and
budgets to your task, and confirm the runtime primitives against the live
[workflow documentation](https://code.claude.com/docs/en/workflows) before
running.

| Template | Pattern | Use it for |
| --- | --- | --- |
| [`workflows/enforcer-fanout.workflow.js`](workflows/enforcer-fanout.workflow.js) | fan-out-and-synthesize + adversarial verification | One verifier subagent per harness constraint, skeptic-filtered — defeats the "35 of 50 checked" lazy stop |
| [`workflows/adversarial-review.workflow.js`](workflows/adversarial-review.workflow.js) | adversarial verification | Review in a context distinct from the implementer's — one verifier per CUPID/literate property |
| [`workflows/reflection-mining.workflow.js`](workflows/reflection-mining.workflow.js) | generate-and-filter + adversarial verification | Cluster reflections, vet candidates, shortlist promotions for a human (never writes durable memory) |
| [`workflows/deep-assessment.workflow.js`](workflows/deep-assessment.workflow.js) | fan-out-and-synthesize + adversarial verification | Long repo scans (assessment/audit) — fan out by area, verify each finding, synthesise a cited report |

Every template honours both invariants: it proposes, it never writes a
durable artefact (INV-1), and any untrusted-content reader is quarantined
from high-privilege tools (INV-2). The deterministic firewall in
`scripts/inv-firewall.sh` enforces both on every template at PR time.
