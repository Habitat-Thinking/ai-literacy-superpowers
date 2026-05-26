---
title: Agents
---
# Agents

The plugin ships 13 agents organised into three groups: the
**spec-first pipeline** that coordinates feature work end to end,
the **harness agents** that verify and maintain infrastructure
conventions, and the **assessor** that measures AI literacy.

Every agent reads `CLAUDE.md` and `AGENTS.md` before acting.
Agents that modify files are read-write; agents that only inspect
are read-only. The trust boundary column in the summary table
makes this explicit.

---

## Pipeline Agents

These eight agents form the spec-first development pipeline. Carpaccio
runs first (step 0) against the raw task description and slices it into
thin, end-to-end-complete pieces; a human dispositions each slice and
chooses which one this iteration will progress. After spec-writer
produces the spec for that slice, the advocatus-diaboli reviews it
adversarially and a human adjudicates the objections (hard gate); the
choice-cartographer then maps the implicit decisions and a human
adjudicates the choice-stories (soft gate); only then is the plan
approved and tdd-agent, code-reviewer, and integration-agent run.

### orchestrator

- **Tools**: Read, Write, Edit, Glob, Grep, Bash, Agent, WebFetch
- **Dispatched by**: User (any task description) or slash commands
  that trigger the full pipeline
- **Trust boundary**: Read-write

Entry point for all changes. Receives a plain-English task
description and coordinates the specialist agents in the correct
sequence, passing context between them. Reads `CLAUDE.md`,
`AGENTS.md`, and `MODEL_ROUTING.md` before dispatching any work.
The only agent with the Agent tool, which it uses to dispatch
the other four pipeline agents and, when needed, harness agents.

### carpaccio

- **Tools**: Read, Glob, Grep
- **Dispatched by**: orchestrator (step 0, before spec-writer)
- **Trust boundary**: Read-only

Cadence governor. Reads the raw task description (typically the body of
a GitHub issue) and slices it into thin, end-to-end-complete pieces.
Produces a structured slicing record at
`docs/superpowers/slices/<task-slug>.md`. The third member of the
decision-discipline triad alongside the advocatus-diaboli (quality
challenger) and the choice-cartographer (decision archaeologist).

Five lenses applied in priority order: `decision-boundary` (primary, one
slice per material decision the human will engage with),
`acceptance-criterion` (fallback when decisions are weak),
`end-to-end` (each slice ships something observable), `independence`
(slices can land without blocking each other), `inseparability`
(terminal lens — slicing would harm correctness). Selectivity is
enforced inside the agent's reasoning protocol (bias toward 3–5
slices, hard cap of 9).

Cannot modify the slicing record. Cannot write dispositions. Cannot
create issues. The read-only boundary forces the human to disposition
each slice (`accepted | merged | dropped | revised`) and, for accepted
slices not being progressed this iteration, set `file_as_issue:
true|false`. The orchestrator drives `gh issue create` after the gate
clears, writing the returned URL back into the slicing record as the
audit trail.

The slice the human marks `progressed_slice` becomes the scope for
spec-writer — not the original task. This is the cognitive-budget
mechanism: the human engages with one decision at a time rather than
the whole proposal at once. The intellectual lineage is Alistair
Cockburn's *Elephant Carpaccio* exercise, reframed for AI-augmented
work where coherent decision streams arrive faster than human
attention can engage them.

When the task is genuinely atomic (security patch, schema migration,
single-coherent refactor), the agent produces a single-slice record
with `inseparable: true` and a defended `## Inseparability rationale`
section. The inseparability claim must be argued, not asserted —
naming the inseparable as inseparable is itself a useful output.

### spec-writer

- **Tools**: Read, Write, Edit, Glob, Grep
- **Dispatched by**: orchestrator (after carpaccio, against the progressed slice's scope)
- **Trust boundary**: Read-write

First specialist in every pipeline run. Updates `spec.md` and
`plan.md` to describe a change before any implementation code is
written. Produces user stories, acceptance scenarios in
Given/When/Then format, and numbered functional requirements that
the TDD agent will translate into tests.

### advocatus-diaboli

- **Tools**: Read, Glob, Grep
- **Dispatched by**: orchestrator (after spec-writer, before plan approval)
- **Trust boundary**: Read-only

Adversarial spec reviewer. Reads the spec file produced by spec-writer and
raises steel-manned objections across six categories: premise, scope,
implementation, risk, alternatives, and specification quality. Produces a
structured objection record at `docs/superpowers/objections/<spec-slug>.md`.

Cannot modify the spec. Cannot write objection dispositions. Both
constraints are structural: the read-only boundary makes it impossible to
alter the problem statement, and the absence of a disposition-writing tool
forces a human to open the record and adjudicate before the pipeline
proceeds. This human-cognition gate is the primary purpose of the agent —
not finding objections, but ensuring a human engages with them.

Applies the **Routing Rule** before emitting any candidate: a finding
belongs in the diaboli's record iff removing it would leave a class of
failures undetected. Findings shaped "this chose X over Y" without a
failure implication belong in the choice-cartographer's record (see
below). The two agents form a complete partition of findings worth
surfacing about a spec.

### choice-cartographer

- **Tools**: Read, Glob, Grep
- **Dispatched by**: orchestrator (after spec-mode advocatus-diaboli
  dispositions are resolved, before plan approval)
- **Trust boundary**: Read-only

Decision-archaeology agent. Reads the spec and the matching adjudicated
diaboli record, then maps the implicit decisions the spec has committed
to — defaults inherited, alternatives unspoken, patterns unnamed,
consequences accepted. Emits each material choice as a *choice story*
(Henney-style pattern story, POSA Vol. 5) for human disposition.
Produces a structured choice-story record at
`docs/superpowers/stories/<spec-slug>.md`.

Six lenses: forces, alternatives, defaults, patterns, consequences,
coherence. Selectivity is enforced inside the agent's reasoning protocol
(bias toward 5–8 stories per spec, hard cap of 15). Mirrors the diaboli's
read-only mechanism: cannot modify the spec, cannot write dispositions.

Applies the **Routing Rule** as the partition with the diaboli: a finding
belongs in the cartographer's record iff removing it would leave a
decision unrecorded but no failure undetected. The plan-approval gate is
**soft** — `cartograph_pending_count` is surfaced as observability but
does not block progression. The merge-time HARNESS constraint
**PRs have adjudicated choice stories** is the forcing function.

This release is spec-mode only. Code-mode behaviour is tracked under
[issue #209](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/209).

### tdd-agent

- **Tools**: Read, Write, Edit, Glob, Grep, Bash
- **Dispatched by**: orchestrator (after spec-writer, after user
  approves plan)
- **Trust boundary**: Read-write

Handles the RED phase of test-driven development only. Translates
acceptance scenarios from the spec into failing tests, runs them,
and confirms each fails for the right reason (missing feature, not
a syntax error). Does not write implementation code. Reports
failing test names and failure messages back to the orchestrator.

### code-reviewer

- **Tools**: Read, Glob, Grep, Bash
- **Dispatched by**: orchestrator (after tests are green)
- **Trust boundary**: Read-only

Reviews implementation code through two lenses: CUPID (Composable,
Unix philosophy, Predictable, Idiomatic, Domain-based) and Literate
Programming. Returns either PASS or a prioritised list of findings.
Does not modify any files. Its output either unblocks integration
or drives another revision cycle.

### integration-agent

- **Tools**: Read, Write, Edit, Bash
- **Dispatched by**: orchestrator (after code review passes)
- **Trust boundary**: Read-write

Handles everything after the code is written and reviewed. Updates
`CHANGELOG.md`, commits all changes, opens a PR, watches CI until
checks pass, merges when green, closes the linked GitHub issue, and
prunes the local branch. Follows the workflow rules in `CLAUDE.md`
exactly.

---

## Harness Agents

These four agents maintain the living harness that enforces project
conventions. They are dispatched by harness commands and scheduled
runs, not by the pipeline orchestrator.

### harness-discoverer

- **Tools**: Read, Glob, Grep, Bash
- **Model**: inherit
- **Color**: cyan
- **Dispatched by**: `/harness-init`, `/harness-constrain`
- **Trust boundary**: Read-only

Read-only project scanner. Discovers the tech stack (languages,
frameworks, build systems), existing linters and formatters, CI/CD
configuration, test frameworks, and pre-commit hooks. Produces a
factual baseline of what exists in the project so that other agents
can generate or verify `HARNESS.md` against reality.

### harness-auditor

- **Tools**: Read, Write, Edit, Glob, Grep, Bash
- **Model**: inherit
- **Color**: yellow
- **Dispatched by**: `/harness-audit`, `/harness-health --deep`
- **Trust boundary**: Read-write

Meta-agent that keeps `HARNESS.md` honest. Compares what the
harness declares (constraints, enforcement types, GC rules) against
what the project actually has. Detects drift in both directions:
rules declared but not enforced, and enforcement present but not
declared. Updates the Status section of `HARNESS.md` with audit
results.

### harness-enforcer

- **Tools**: Read, Glob, Grep, Bash
- **Model**: inherit
- **Color**: blue
- **Dispatched by**: CI constraint checks, `/harness-constrain` test
  runs
- **Trust boundary**: Read-only

Unified verification engine for harness constraints. Given a
constraint from `HARNESS.md`, either executes a deterministic tool
(linter, formatter, secret scanner) or performs an agent-based
review. Output format is identical in both cases, so CI can treat
all constraint results uniformly.

### harness-gc

- **Tools**: Read, Write, Edit, Glob, Grep, Bash
- **Model**: inherit
- **Color**: green
- **Dispatched by**: `/harness-gc`, scheduled weekly runs
- **Trust boundary**: Read-write

Entropy fighter. Runs garbage collection rules declared in the
Garbage Collection section of `HARNESS.md`. Handles both
deterministic checks (documentation staleness, dead code, shell
script hygiene) and agent-scoped checks (convention drift,
dependency currency). Either fixes issues directly or creates
GitHub issues for them.

---

## Assessment

### assessor

- **Tools**: Read, Write, Edit, Glob, Grep, Bash
- **Model**: inherit
- **Color**: yellow
- **Dispatched by**: `/assess`
- **Trust boundary**: Read-write

Runs an AI literacy assessment against the repository. Scans for
observable evidence of AI collaboration practices (harness files,
reflections, conventions, CI integration), asks clarifying
questions where evidence is ambiguous, and produces a timestamped
assessment document with a level determination. Updates the README
with a literacy level badge.

---

## Governance

### governance-auditor

- **Tools**: Read, Write, Edit, Glob, Grep, Bash
- **Dispatched by**: `/governance-audit`, `/governance-health`,
  orchestrator (for governance-related tasks)
- **Trust boundary**: Read + limited Write (audit reports and snapshot
  updates only)

Governance specialist for deep investigation. Detects semantic drift
using the five-stage model, inventories governance debt with severity
and blast radius scoring, checks three-frame alignment between
engineering, compliance, and AI system interpretations, and produces
structured audit reports to `observability/governance/`. Reads the
`governance-audit-practice`, `governance-constraint-design`, and
`governance-observability` skills before acting.

Does not modify `HARNESS.md` constraints directly — reports findings
for humans to decide on. Uses the best available model because
governance analysis requires nuanced judgement about meaning.

---

## Tool Summary

| Agent | Read | Write | Edit | Glob | Grep | Bash | Agent | WebFetch | Trust |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| orchestrator | x | x | x | x | x | x | x | x | read-write |
| carpaccio | x | | | x | x | | | | read-only |
| spec-writer | x | x | x | x | x | | | | read-write |
| advocatus-diaboli | x | | | x | x | | | | read-only |
| choice-cartographer | x | | | x | x | | | | read-only |
| tdd-agent | x | x | x | x | x | x | | | read-write |
| code-reviewer | x | | | x | x | x | | | read-only |
| integration-agent | x | x | x | | | x | | | read-write |
| harness-discoverer | x | | | x | x | x | | | read-only |
| harness-auditor | x | x | x | x | x | x | | | read-write |
| harness-enforcer | x | | | x | x | x | | | read-only |
| harness-gc | x | x | x | x | x | x | | | read-write |
| assessor | x | x | x | x | x | x | | | read-write |
| governance-auditor | x | x | x | x | x | x | | | read-write (limited) |

---

## Design Principles

**Least privilege.** Each agent receives only the tools it needs.
The code-reviewer and harness-enforcer are read-only by design
because their job is to observe and report, not to change. The
orchestrator is the only agent with the Agent tool because dispatch
authority should not be distributed.

**Specialist over generalist.** Each agent has a narrow, well-defined
responsibility. The spec-writer does not test. The tdd-agent does
not implement. The code-reviewer does not fix. This separation
makes failures easier to diagnose and prevents agents from
overstepping their mandate.

**Convention-driven.** Every agent reads `CLAUDE.md` and `AGENTS.md`
before acting. This ensures accumulated team knowledge and workflow
rules are honoured across sessions, not just in the session where
they were discovered.

**Reflection-aware.** Agents that make judgement calls (orchestrator,
harness-enforcer, harness-gc) read recent entries from
`REFLECTION_LOG.md` to avoid repeating past mistakes and to surface
areas of known degradation.
