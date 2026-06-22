# Model Routing

<!-- This file guides the orchestrator when dispatching agents to different
     model tiers. The goal is to use the cheapest model that can reliably
     handle each agent's task type — without sacrificing quality on tasks
     that genuinely require stronger reasoning.

     Update this file whenever you add a new agent or discover that a
     routing decision is producing poor results. -->

## Agent Routing Table

| Agent | Tier | Rationale |
| ----- | ---- | --------- |
| orchestrator | Flagship | Coordinates the full pipeline, makes judgment calls about plan approval, review escalation, and skipping stages — requires strong reasoning |
| spec-writer | Flagship | Producing precise acceptance scenarios and functional requirements that drive tests and implementation demands careful thinking |
| advocatus-diaboli | Flagship | Adversarial reasoning, evidence-grounded objection — judgment-heavy, not throughput-heavy. Both spec-time and code-time dispatches use this tier; the judgment load is equivalent across modes. |
| tdd-agent | Balanced | Translating well-specified scenarios into test code is a structured task; a mid-tier model handles it well |
| code-reviewer | Balanced | Applying CUPID and literate programming lenses is systematic; a mid-tier model can work through the checklist reliably |
| integration-agent | Efficient | CHANGELOG updates, commit messages, and PR descriptions are templated tasks; a fast, cheap model is sufficient |

<!-- Tier definitions — adapt to your available models:
     Flagship  — most capable model, highest cost, use sparingly
     Balanced  — mid-tier, good reasoning, moderate cost
     Efficient — fastest/cheapest, suitable for templated or mechanical tasks -->

<!-- CUSTOMISE: Replace the tier names with the actual model identifiers
     your team uses. Examples:
     Flagship  → claude-opus-4-5, gpt-4o, gemini-ultra
     Balanced  → claude-sonnet-4-5, gpt-4o-mini, gemini-pro
     Efficient → claude-haiku-3-5, gpt-3.5-turbo, gemini-flash -->

## Token Budget Guidance

| Task type | Suggested max tokens | Notes |
| --------- | ------------------- | ----- |
| Spec writing | 8 000 | Enough for a user story, 3–5 scenarios, and a plan section |
| Test generation | 4 000 | Failing tests are small; the limit prevents over-engineering |
| Implementation (per file) | 6 000 | If a single file needs more, it may be doing too much |
| Code review | 4 000 | Findings should be concise; a long review is a smell |
| CHANGELOG + commit | 2 000 | Templated task; constrain to prevent padding |
| Orchestrator planning | 2 000 | Planning summaries should be short |

<!-- These are starting points, not hard limits. Adjust based on observed
     token usage in your pipeline runs. Consistently hitting limits is a
     signal that either the task is too large or the prompt is too verbose. -->

## When to override

Override the routing table when:

- A task is unexpectedly complex and the assigned tier is producing poor output.
  Escalate to the next tier and note the exception in AGENTS.md → GOTCHAS.

- A task is simpler than expected and you want to save cost. Move down a tier
  only if you have verified the output quality does not degrade.

Do not override silently — record the reason in the context object so the
orchestrator can learn from it.

## Workflow election

A *dynamic workflow* (a self-authored, ephemeral multi-agent harness; see
the `dynamic-workflows` skill) spends more tokens than a single agent and
is elected deliberately, never reflexively. Elect a workflow only when the
task is **long-running, massively parallel, highly structured, or
adversarial**; if none apply, use the static pipeline. Routing decisions
for an elected workflow live here.

### Token-budget convention

Every elected workflow declares an explicit **per-workflow token cap**
before it runs — for example, *"use 10k tokens"* — so its compute is
bounded and observable. A workflow that approaches its cap stops and
reports rather than silently overspending. The cap is part of electing the
workflow, not an afterthought: state it in the workflow's preamble
alongside the pattern it uses.

Suggested starting caps by workflow shape (adjust from observed usage):

| Workflow shape | Per-workflow cap (tokens) | Rationale |
| --- | --- | --- |
| Enforcer fan-out (one verifier per rule) | 10 000 | Each verifier is small and focused |
| Adversarial review (separate-context refute) | 12 000 | Per-property verifiers plus synthesis |
| Deep assessment / audit (fan-out by area) | 20 000 | Breadth across the repo, then a cited report |
| Reflection mining (generate-and-filter) | 8 000 | Cluster, filter, shortlist — proposal only |

### Model-routing classifier

For workflows whose subagents do not all need the same tier, front the
workflow with a **model-routing-classifier**: a cheap classifier agent
that researches the task's complexity, then routes each subagent role to
the right tier.

- **Haiku** — high-volume, mechanical, well-structured subagents (a single
  constraint check, a single-file read).
- **Sonnet** — the default working tier for most subagents.
- **Opus** — the hardest reasoning roles (synthesis, adversarial judging,
  ambiguous design calls).

Routing down a tier is a cost win only when output quality holds; record
any tier exception in the context object so the orchestrator can learn
from it, exactly as for the static routing table above.

> **Governance.** A workflow elected here proposes; it never writes this
> file or any other durable artefact directly (INV-1). `MODEL_ROUTING.md`
> changes are human-curated.
