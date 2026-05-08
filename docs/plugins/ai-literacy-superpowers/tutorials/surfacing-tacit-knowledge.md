---
title: Surfacing Tacit Knowledge
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 9
redirect_from:
  - /tutorials/surfacing-tacit-knowledge/
  - /tutorials/surfacing-tacit-knowledge.html
---

# Surfacing Tacit Knowledge

Most of what makes a team effective in a complex domain is not
written down. It lives in heads — the senior engineer who knows why
the flight-plan validator refuses certain route revisions, the ops
lead who remembers the 2023 incident that banned local timestamps in
the scheduling service, the architect who can tell at a glance that
a new module violates the dependency rule nobody ever formalised.
This is tacit knowledge: pattern recognition built from years of
reviews, production incidents, and architectural arguments.

Tacit knowledge transfers slowly. In a domain like Air Traffic
Management (ATM), a new engineer can spend months shadowing before
they start producing useful output. AI amplifies the problem: without
explicit conventions, AI-generated code can look plausible and be
quietly wrong — using the wrong time zone, violating an unwritten
dependency rule, re-introducing a pattern that caused a past
incident. Same codebase, same AI, completely different quality
depending on who is prompting.

This tutorial walks you through turning that tacit knowledge into
versioned, enforceable artefacts, and then using those artefacts to
onboard new engineers (and new AI agents) in days rather than
months. The approach has five phases, each with a clear purpose and
a specific command or practice:

1. **Scaffold the habitat** — create the files that will hold the
   extracted knowledge, so it lands in predictable places.
2. **Run a guided extraction session** — surface what lives in
   people's heads through pointed questions.
3. **Mine the artefacts you already have** — use AI to extract
   knowledge from code, PRs, wikis, and chat history.
4. **Capture decisions as they happen** — introduce a lightweight
   Architecture Decision Record (ADR) practice that prevents the
   same archaeology next quarter.
5. **Generate team-specific onboarding** — bridge the gap between a
   general onboarding programme and the deep domain knowledge new
   hires actually need.

Plan for about two hours the first time. Most of that is the
extraction conversation in Phase 2 — which is the point. The
conversation is where tacit knowledge becomes explicit.

Throughout the tutorial, examples are drawn from an ATM scheduling
service, but the pattern applies equally to any complex domain —
claims processing, medical devices, payment infrastructure, or
industrial control systems. Substitute your own domain when running
the commands; the shape of the output is the same.

---

## Prerequisites

You need:

- Claude Code installed with the ai-literacy-superpowers plugin (see
  [Getting Started](getting-started))
- A project repository the team works in — existing code, not a
  greenfield empty directory. Extraction depends on having artefacts
  to mine and a codebase to validate conventions against.
- Access to supporting artefacts: the team wiki, past pull
  requests, incident post-mortems, chat history on architecture
  channels. You do not need to collect these up front — Phase 3
  explains how to bring them in as you need them.
- Ideally, one or two senior engineers available for about an hour.
  The extraction session works either as a mob (preferred) or as
  structured one-on-ones.

---

## Phase 1: Scaffold the Habitat

### Why this first

Extraction produces artefacts. Without a place to put them, the
output scatters — notes in one document, constraints in another,
conventions in a README that nobody reads. Scaffolding first means
every piece of extracted knowledge lands in a predictable,
discoverable location that AI agents will read on every future
session.

### `/superpowers-init`

The plugin ships a single command that bootstraps the full
coordination habitat in eight steps:

1. **Discover the stack** — scan the project and identify primary
   language, build system, test framework, CI, and container
   strategy.
2. **Generate `CLAUDE.md`** — the top-level context file. Records
   the stack and leaves sections for conventions, style, and domain
   guidance that the next phases will fill.
3. **Generate `HARNESS.md`** — the source of truth for constraints,
   garbage-collection rules, and enforcement status. Starts with
   whatever deterministic checks the discoverer found in the repo
   (Prettier, ESLint, gitleaks, test runners).
4. **Generate `AGENTS.md`** — declares the agent team for the
   project and their responsibilities. The team then edits this
   directly to encode roles, style preferences, and architectural
   decisions.
5. **Generate `MODEL_ROUTING.md`** — records which model tier to use
   for which kind of task, and the cost data that justifies the
   choice. Starts with plug-in defaults that you refine over time.
6. **Generate `REFLECTION_LOG.md`** — the append-only journal of
   what was learned per session. Seeded with an initial entry that
   notes the habitat has been scaffolded.
7. **Scaffold CI templates** — add a GitHub Actions workflow that
   enforces the deterministic constraints the discoverer found, so
   the harness starts enforcing on day one.
8. **Produce an initial health snapshot** — write the first entry
   to `observability/snapshots/` so later runs have a baseline to
   compare against.

### How to run it

From the project root:

```text
/superpowers-init
```

Accept all defaults the first time. The command is safe to re-run —
it detects existing files and only adds what is missing, never
overwrites what you have.

### What you have at the end of Phase 1

Five coordination documents at the project root — `CLAUDE.md`,
`HARNESS.md`, `AGENTS.md`, `MODEL_ROUTING.md`,
`REFLECTION_LOG.md` — plus a CI workflow and a first health
snapshot. Most of these documents are mostly empty. That is
correct; the next phases fill them.

---

## Phase 2: Run a Guided Extraction Session

### Why this second

The habitat now exists but has very little real content. The
fastest way to fill it with high-signal conventions and
constraints is a structured conversation with the people who hold
the tacit knowledge. The conversation is where disagreements
surface — disagreements are not a failure mode, they are the
point. If two seniors have different answers to "what counts as a
clean refactor here," you have just discovered a convention that
was never explicit.

### `/extract-conventions`

The command runs a guided five-question session, informed by how
AI-assisted teams actually break in practice. Each question
surfaces a different kind of tacit knowledge:

1. **What architectural decisions should never be left to
   individual judgment?** Surfaces non-negotiable patterns —
   module boundaries, dependency direction, API design rules.
   These become **constraints** in `HARNESS.md`.

2. **Which conventions are corrected most often in AI-generated
   code?** Surfaces the gap between what AI produces by default
   and what the team expects. Highest-value convention category
   because the corrections happen every day. These become
   **conventions** in `CLAUDE.md`.

3. **Which security checks are applied instinctively?** Surfaces
   embodied security knowledge — input validation, auth patterns,
   secrets handling — that seniors apply without thinking. These
   become **constraints** in `HARNESS.md` or entries in a
   project-specific security skill.

4. **What triggers an immediate rejection in review?** Surfaces
   hard boundaries — things that are never acceptable regardless
   of context. These become **critical checks** attached to the
   code-reviewer agent's instructions, or harness constraints
   with `pr` scope.

5. **What separates a clean refactoring from an over-engineered
   one?** Surfaces judgment about abstraction thresholds, YAGNI
   boundaries, when to stop. These usually become **style
   preferences** in `CLAUDE.md` rather than hard constraints —
   they depend on context.

The command does not just record answers. It **maps each answer to
a specific artefact** based on priority tier (must-follow,
should-follow, nice-to-have) and writes the edits into
`HARNESS.md` or `CLAUDE.md` in the right sections with the right
structure.

### How to run it

Gather the team (or, for one-on-ones, start with the most senior
engineer) and run:

```text
/extract-conventions
```

The command walks through the five questions one at a time. Answer
concretely. Examples for an ATM scheduling service:

```text
Question 1: What architectural decisions should never be left to
individual judgment?

→ All timestamps in persisted data must be UTC. We had an incident
  in 2023 where local-timezone timestamps in the flight-plan store
  caused phantom conflicts across timezone boundaries. Non-negotiable.

→ The scheduling service must not call the flight-plan validator
  synchronously. The validator can take up to 8 seconds on
  complex routes and must not block the scheduling pipeline.
```

```text
Question 2: Which conventions are corrected most often in
AI-generated code?

→ AI reaches for datetime.now() in local time. We catch it every
  week in review. Must always be datetime.now(timezone.utc) or
  our FlightClock abstraction.

→ AI invents new sector identifiers rather than looking them up
  in the sector registry. We have a fixed set from EUROCONTROL
  that should never be extended by the service itself.
```

The command maps Answer 1 to a `HARNESS.md` constraint with a
deterministic check (lint rule forbidding local timestamps in the
persistence layer), and Answer 2 to both a `CLAUDE.md` convention
entry and — because it is corrected weekly — a proposal to add a
linter constraint to `HARNESS.md`. You confirm or refine the
proposal; the edit is made.

### The "it depends" signal

If the answer to a question is always "it depends on context," the
convention needs decomposition before it can be encoded. Decompose
"it depends" into specific, observable cases. "It depends on
whether the flight plan is in filed or active state" is a usable
distinction; "it depends on the situation" is not. Carry
undecomposed items to the next extraction session rather than
forcing them into the habitat half-formed.

### What you have at the end of Phase 2

`CLAUDE.md` and `HARNESS.md` now contain real content — a handful
of strong conventions and two or three enforced constraints — all
grounded in actual team experience. The extraction session also
surfaces where the team disagrees; record those disagreements as
explicit ADRs in Phase 4 rather than letting them stay tacit.

---

## Phase 3: Mine the Artefacts You Already Have

### Why this third

The extraction session only surfaces knowledge participants
consciously recall under the pressure of the question. A huge
amount of domain knowledge lives in artefacts nobody reviews: old
pull requests, wiki pages, Slack threads in `#architecture` and
`#incidents`, code comments, runbooks, post-mortems. These
artefacts *remember* things people forget. This phase uses Claude
Code as a research partner to extract that knowledge
systematically.

This is not a plugin command. It is a workflow pattern that
combines Claude Code's general file-reading and research
capabilities with the `/harness-constrain` command for promoting
discoveries into enforced rules.

### Sources worth mining

| Source | What you will find |
| ---------- | ---------------------- |
| Review comments on merged PRs | Tacit rules reviewers apply — especially comments that repeat across PRs |
| Post-mortem documents | Constraints grounded in real incidents — the strongest kind |
| Wiki pages on architecture | Decisions made years ago that the team no longer articulates |
| Slack threads in `#architecture`, `#incidents` | Live disagreements and their resolutions |
| Runbooks | Operational knowledge — startup sequences, recovery procedures, dependency orderings |
| Code comments marked `// HACK`, `// FIXME`, `// TODO` | Known-bad patterns the team has not yet encoded as constraints |

### The extraction workflow

For each source, the pattern is the same:

1. **Bring the artefact into the session.** Export a wiki page to
   Markdown and place it in `docs/legacy/`. Download a Slack
   thread as plain text. Run `gh pr list --state merged --limit
   50` and have Claude read the PR bodies.

2. **Ask for candidate conventions and constraints, not prose.**
   The useful prompt shape is:

   ```text
   Read docs/legacy/flight-plan-validation-architecture.md and
   propose:
     - Candidate conventions for CLAUDE.md (things engineers should
       do by default)
     - Candidate constraints for HARNESS.md (rules that should fail
       CI if violated)
   For each, quote the specific passage that motivates it.
   ```

   Requiring a quote grounds the output in the artefact and makes
   it easy to verify. If the AI cannot find a quote, the proposal
   is probably a hallucination.

3. **Review the output with a senior engineer present.**
   Hallucinations do happen, especially when reading long
   documents. The senior catches "we never actually did that" and
   "that was true in 2022, not now."

4. **Commit the surviving proposals.** For conventions, edit
   `CLAUDE.md` directly — the proposed text usually needs light
   trimming. For constraints, run:

   ```text
   /harness-constrain
   ```

   Paste the proposed rule, choose `deterministic` if a tool
   exists or `agent` if it needs judgement, configure the scope
   (`commit` or `pr`), and let the command write the constraint
   into `HARNESS.md` with enforcement wired up.

### What "AI-assisted archaeology" looks like in practice

For an ATM team, one hour of mining a wiki export might surface:

- A convention about using nautical miles rather than kilometres in
  all horizontal distance calculations (originally a 2019 decision,
  never written into any README).
- A constraint about the maximum allowed call depth between the
  scheduling service and the conflict detector (originally to
  prevent cascading timeouts, encoded once in a Grafana alert and
  nowhere else).
- A rejected pattern — "do not poll the sector-assignment service
  from the flight-plan validator" — grounded in a 2024 incident.

Each of these was known to at most two people. After Phase 3, all
three live in `HARNESS.md` or `CLAUDE.md` where any engineer or
agent can see them.

### What you have at the end of Phase 3

`CLAUDE.md` and `HARNESS.md` now contain conventions and
constraints that were previously locked in artefacts nobody read.
Every entry is traceable to its source — the wiki page, the
incident, the review comment. When someone asks "why does this
rule exist," the answer is one link away.

---

## Phase 4: Capture Decisions as They Happen

### Why this fourth

Conventions record *what* the team does. They do not record *why*.
Without the *why*, decisions get re-litigated every quarter — new
engineers question rules whose original motivation has been
forgotten, and the arguments have to be rediscovered. Retroactive
documentation of decisions (writing the ADR six months after the
decision) is archaeology: expensive, lossy, usually skipped. The
only approach that works is capturing decisions in flight, when
the reasoning is fresh.

Lightweight ADRs are a cheap practice. One short Markdown file per
decision, written at the time the decision is made, referenced
from any constraint or convention it justifies.

### The two-tier practice

Not every decision warrants an ADR. Use two tiers:

**Tier 1 — micro-decisions.** Small judgement calls that happened
in a session ("we chose to retry on 503 with exponential backoff
rather than circuit-breaking because the downstream SLA is 99.5%").
Capture these with:

```text
/reflect
```

`/reflect` asks three questions — what was worked on, what was
surprising, what future agents should know — and appends a
structured entry to `REFLECTION_LOG.md`. Micro-decisions live in
the log's Surprise and Improvement fields. They are searchable,
dated, and classified by signal type, so later curation can
promote recurring patterns.

**Tier 2 — design decisions.** Larger architectural choices that
will shape months of work ("we picked an event-sourced store for
flight plans rather than a relational store"). These deserve a
dedicated ADR file.

### A minimal ADR template

Create `docs/adr/` and use a four-section template:

```markdown
# ADR-NNNN — Short Title

## Status
Proposed | Accepted | Superseded by ADR-XXXX | Deprecated

## Context
Two to five sentences. What forces are acting? What problem are
we solving? What are the relevant constraints from HARNESS.md?

## Decision
One to three sentences, stated as an active choice.
"We will ..."

## Consequences
Three to five bullet points. What becomes easier, what becomes
harder, what new constraints this introduces, what we are giving
up.
```

Name files as `docs/adr/NNNN-short-title.md` with a
monotonically-increasing number. Reference the ADR from any
`HARNESS.md` constraint grounded in it:

```markdown
### Flight-plan persistence in UTC only

- **Rule**: All timestamps in the flight-plan store must be UTC.
- **Enforcement**: deterministic
- **Tool**: custom lint rule `atm-utc-only`
- **Scope**: commit
- **Rationale**: See ADR-0014 — timezone handling after the 2023
  phantom-conflict incident
```

### How this prevents archaeology

A new engineer asking "why is everything UTC" in six months' time
gets answered by a file, not a meeting. An AI agent generating
code that imports a local-timezone helper sees the constraint,
sees the ADR reference, and understands both the rule and its
rationale. The cost of capturing the ADR at decision time is
around ten minutes. The cost of reconstructing it six months
later from memory, commits, and chat history can be hours.

### The discipline

Add an ADR whenever a decision meets any of these tests:

- You find yourself explaining the reasoning more than twice
- The decision overrides a convention elsewhere
- Reversing the decision would require a migration
- You expect new engineers to question the decision

Skip ADRs for decisions that are reversible within a single PR.
Those belong in the PR description or a `/reflect` entry.

### What you have at the end of Phase 4

A `docs/adr/` directory with the first few ADRs — one per
significant decision you have made recently or can remember
making in the last quarter. `HARNESS.md` constraints link to the
ADRs that justify them. `REFLECTION_LOG.md` is receiving
micro-decisions as they happen. The team now has a living
decision record that grows by minutes per week rather than hours
per retrospective.

---

## Phase 5: Generate Team-Specific Onboarding

### Why this fifth

New engineers joining an ATM team typically go through a general
onboarding programme — accounts, access, development environment,
corporate policies. None of that covers the domain knowledge they
actually need to ship a useful pull request. The gap between "my
laptop works" and "I understand why we never poll the
sector-assignment service from the validator" is where the team
loses weeks.

After Phases 1–4, all of that domain knowledge now lives in
`CLAUDE.md`, `HARNESS.md`, `AGENTS.md`, `REFLECTION_LOG.md`, and
`docs/adr/`. The habitat *is* the onboarding material — what is
missing is a friendly, prose-organised surface that a new
engineer can read on their first day. Writing that surface by
hand is the familiar trap: the document ages the moment it is
written and drifts from the source within weeks. The plugin
avoids this by generating the onboarding document *from* the
habitat, so it stays current by construction.

### `/harness-onboarding` (or `/harness-sync` for the multi-surface entry)

`/harness-onboarding` is one of the underlying primitives that
[`/harness-sync`](sync-harness.md)
composes. When the team-composition change you are absorbing also
warrants refreshing the convention files (Cursor, Copilot, Windsurf),
use `/harness-sync` — it runs `/harness-onboarding` and
`/convention-sync` together in one interactive pass, with a verification
scan at the end. Use `/harness-onboarding` directly only when you want
to refresh `ONBOARDING.md` alone.

The command reads three authoritative sources — `HARNESS.md`,
`AGENTS.md`, `REFLECTION_LOG.md` — and produces `ONBOARDING.md`
with ten sections organised around what a new contributor
actually needs:

1. **Welcome and scope** — what the project does, in plain terms.
2. **Tech stack** — languages, frameworks, tools, with versions.
3. **Conventions** — the `CLAUDE.md` content rendered as prose,
   grouped by topic.
4. **What's enforced and when** — constraints from `HARNESS.md`,
   with their scope (commit, pr, or scheduled) and the tool that
   enforces them.
5. **Common pitfalls** — synthesised from `REFLECTION_LOG.md`
   entries classified as `failure` — real mistakes the team has
   made and encoded.
6. **Architecture decisions** — a readable summary of
   `docs/adr/`, with links to the full ADRs.
7. **Testing approach** — how tests are structured, what the
   coverage target is, what fixtures exist.
8. **How the harness works** — a short explanation of the three
   enforcement loops (commit, PR, scheduled) so the new engineer
   understands why their pre-commit hook is running Prettier.
9. **Agent team** — which agents the project uses and what each
   one is responsible for, drawn from `AGENTS.md`.
10. **Your first PR checklist** — a concrete set of steps the new
    engineer can follow end to end to merge their first change
    without blocking a reviewer.

A validation checkpoint inside the command verifies all ten
sections are present and fixes any missing content before
committing the file. A garbage-collection rule checks monthly
whether `ONBOARDING.md` has drifted from its sources.

### How to run it

```text
/harness-onboarding
```

The command runs in under a minute on a mid-size habitat. Review
the output with a senior engineer before committing — the
synthesis step is the one place AI creativity can drift, and a
quick read catches any misrepresentation. Typical edits are small:
adjusting a tone, clarifying a pitfall, adding a link.

### The feedback loop

The onboarding document is not just an output — it is an input
back into the habitat. When a new engineer reads it and gets
confused, that confusion is a signal: either the habitat is
missing something, or it says something that does not match
reality. Encourage new hires to run `/reflect` after their first
week with a single question: "What did `ONBOARDING.md` not
prepare me for?" The answers surface gaps that regulars cannot
see because they stopped noticing.

### What you have at the end of Phase 5

`ONBOARDING.md` at the project root — a ten-section document
grounded in the habitat, with links back to the source files.
New engineers land on this as their first-day read. Because the
document regenerates from source, it does not drift — every
habitat edit over the next quarter is reflected the next time you
run `/harness-onboarding`.

---

## The Flywheel

Five phases look like a one-time exercise, but the practice is
cyclic. Each turn of the wheel makes the next turn cheaper:

```text
  extract ──► encode ──► onboard ──► new hires
     ▲                                    │
     │                                    ▼
     └────── /reflect ◄── questions, gaps, surprises
```

- Extract (Phase 2) surfaces tacit knowledge.
- Encode (Phases 1, 3, 4) turns it into artefacts.
- Onboard (Phase 5) uses the artefacts to bring new engineers up.
- New hires surface gaps regulars cannot see.
- `/reflect` captures those gaps; the habitat updates.
- Re-run `/harness-onboarding`; the next cohort benefits.

The first turn costs about two hours and feels like a lot.
Subsequent turns take minutes — a reflection captured after a
confusing session, a `/harness-constrain` promoting an unverified
rule, a regenerated `ONBOARDING.md` before the next hire starts.

---

## What You Have Now

After completing this tutorial you have:

- A full habitat: `CLAUDE.md`, `HARNESS.md`, `AGENTS.md`,
  `MODEL_ROUTING.md`, `REFLECTION_LOG.md`, all populated with real
  team knowledge rather than boilerplate
- A `docs/adr/` directory with the first ADRs, each linked from the
  `HARNESS.md` constraints they justify
- An `ONBOARDING.md` that regenerates from the habitat rather than
  aging into inaccuracy
- A lightweight capture discipline — `/reflect` for
  micro-decisions, ADRs for design decisions — that prevents the
  team from ever again relying on memory for what was decided

More importantly, the team has a vocabulary and a mechanism for
making tacit knowledge explicit. Extraction is no longer a one-off
project; it is a habit, triggered by reviews, incidents,
onboarding confusion, and scheduled quarterly revisits.

---

## Next Steps

- [The Improvement Cycle](the-improvement-cycle) — run `/assess`
  to measure where the habitat has moved you on the AI Literacy
  framework, and generate an improvement plan for the next level
- [Governance for Your Harness](governance-for-your-harness) — for
  conventions that are important enough to audit quarterly,
  promote them to governance constraints with falsifiability
  checks and three-frame alignment
- [How-to: Extract Conventions](extract-conventions.md) —
  a shorter, task-oriented reference for running
  `/extract-conventions` without the full tutorial context
- [How-to: Generate Onboarding](generate-onboarding.md) — a
  shorter reference for `/harness-onboarding`
- [Reference: Commands](commands.md) — full specification
  for every command used in this tutorial
