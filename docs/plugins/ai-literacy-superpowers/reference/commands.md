---
title: Commands
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 3
redirect_from:
  - /reference/commands/
  - /reference/commands.html
---

# Commands

All 24 slash commands registered in `commands/`. Each command is
invoked as `/command-name` in a Claude Code session.

---

## Harness Lifecycle

Commands for initialising, monitoring, constraining, and maintaining
the living harness.

### /harness-init

- **Skills read**: harness-engineering, context-engineering
- **Agents dispatched**: harness-discoverer

Set up a living harness for the project. Interactive feature selection
walks through context, constraints, garbage collection, CI templates,
and observability. Dispatches the harness-discoverer agent to scan the
repo and identify the stack before generating `HARNESS.md`. Safe to
re-run — subsequent runs add features incrementally without
overwriting existing configuration.

### /harness-status

- **Skills read**: none
- **Agents dispatched**: none

Quick harness health read with no agent overhead. Reads `HARNESS.md`
and cross-references project state to produce a summary of
enforcement ratio, drift since last audit, and garbage collection
state. Use this for a fast pulse check between deeper audits.

### /harness-audit

- **Skills read**: none
- **Agents dispatched**: harness-discoverer, harness-auditor

Full meta-verification of the harness. Dispatches the
harness-discoverer agent to scan the repo, then the harness-auditor
agent to compare what `HARNESS.md` claims against what the project
actually contains. Reports mismatches, stale constraints, and
missing enforcement. Use this after significant changes to the
project structure or CI pipeline.

### /harness-constrain

- **Skills read**: constraint-design, verification-slots
- **Agents dispatched**: none

Add a new constraint or promote an existing one. Interactive — asks
what rule you want to enforce, helps design the constraint (including
choosing between agent-scoped and deterministic enforcement), and
writes it into the Constraints section of `HARNESS.md`. Also
configures the verification slot if deterministic enforcement is
selected.

### /harness-gc

- **Skills read**: garbage-collection
- **Agents dispatched**: harness-gc

Manage and run garbage collection rules. Two modes:

- **Add**: Define a new periodic GC rule — what to check, how often,
  and whether it needs agent judgement or can be deterministic.
- **Run**: Execute existing GC rules on demand, outside their normal
  schedule.

Dispatches the harness-gc agent to perform rule evaluation.

### /harness-health

- **Skills read**: none
- **Agents dispatched**: harness-auditor (Deep mode only)

Generate a comprehensive health snapshot. Two modes:

- **Quick**: Reads existing data only — no agents dispatched. Produces
  enforcement ratio, mutation trends, learning velocity, cadence
  compliance, and meta-observability status.
- **Deep**: Dispatches the harness-auditor agent for a full audit
  before generating the snapshot. Use this for scheduled health checks.

Snapshots are saved to `observability/snapshots/` with a datestamped
filename.

### /harness-onboarding

- **Skills read**: harness-onboarding
- **Agents dispatched**: none
- **Primitive of**: `/harness-sync` (the multi-surface entry point composes this command alongside `/convention-sync`)

Generate `ONBOARDING.md` — a human-readable onboarding guide for new
team members. Reads three sources (HARNESS.md, AGENTS.md,
REFLECTION_LOG.md) and synthesises them into friendly, practical prose
organised by what a new contributor needs to know: tech stack,
conventions, what's enforced and when, common pitfalls, architecture
decisions, testing approach, how the harness works, and a first-PR
checklist. Includes a validation checkpoint that verifies all 10
sections are present and fixes any missing content. A GC rule checks
monthly whether ONBOARDING.md has become stale relative to its
sources.

### /observatory-verify

- **Skills read**: none
- **Agents dispatched**: none

Verify that all data signals the Habitat Observatory expects are
present and correctly formatted. Runs an 82-signal checklist across
five source categories (harness health snapshots, assessment documents,
reflection logs, governance audit reports, and cost snapshots).
Reports each signal as PRESENT, PARTIAL, or MISSING with a summary
table showing coverage by category. Use this after generating new
output files to confirm the Observatory contract is satisfied.

### /harness-upgrade

- **Skills read**: none
- **Agents dispatched**: none

Adopt new template content after a plugin upgrade. Compares the
`<!-- template-version: X.Y.Z -->` marker in your `HARNESS.md` against
the installed plugin version. Categorises changes as New (items in the
template not in your HARNESS.md), Updated (changed items), and Removed
(items you have that the template no longer includes). Each item can be
accepted or dismissed individually. Dismissing writes a
`.claude/.harness-upgrade-dismissed` marker so the SessionStart hook
does not re-prompt until the next plugin update.

### /harness-affordance

- **Skills read**: none
- **Agents dispatched**: none
- **Subcommands**: `discover` (implemented), `add` and `review`
  (planned)

Manage the project's affordance inventory — the declared tools the
agent can invoke, with the identity each tool runs under, the audit
trail each tool produces, and the permission allowlist that
authorises it. See the
[harness-affordances design spec](../../superpowers/specs/2026-04-26-harness-affordances-design.md)
for the full schema.

`/harness-affordance discover` reads `.claude/settings.json`,
`.claude/settings.local.json`, and `.mcp.json`, and writes a draft
affordance inventory to `<project>/.claude/affordance-discovery-<date>.md`
(gitignored). One draft entry per permission pattern, hook entry, and
MCP server. Machine-derivable fields (`Mode`, `Trigger` for hooks,
`Permission`, `Notes` when needed) are filled in; human-owned
governance fields (`Identity`, `Audit trail`, `Last reviewed`) are
left as `TODO` placeholders. The scanner is the **backfill path** for
existing harness adopters: running it once produces a draft for every
existing permission. See
[Discover Affordances](discover-affordances.md) for the
full how-to.

`/harness-affordance add <name>` (planned, sequencing step 3 of the
affordances design) will guide annotation of a draft entry —
prompts for Identity, Audit trail, optional Notes, then appends the
completed entry to `HARNESS.md`.

`/harness-affordance review <name>` (planned, sequencing step 6)
will walk through the three re-validation checks (Identity, Audit
trail, Permission) and bump `Last reviewed` if all pass.

---

## Assessment & Improvement

Commands for evaluating AI literacy and aggregating assessments
across repositories.

### /assess

- **Skills read**: ai-literacy-assessment
- **Agents dispatched**: none

Run a full AI literacy assessment against the ALCI framework. Scans
the repo for evidence of literacy practices, asks clarifying questions
where evidence is ambiguous, and produces a timestamped assessment
document. After assessment, applies immediate habitat fixes,
recommends workflow changes, captures a reflection, and adds a
literacy level badge to the project README.

### /portfolio-assess

- **Skills read**: portfolio-assessment
- **Agents dispatched**: none
- **Flags**:
  - `--local <path>` — scan repos under a local directory
  - `--org <github-org>` — discover repos from a GitHub organisation
  - `--topic <tag>` — filter repos by GitHub topic

Multi-repo assessment aggregation. Discovers repositories using the
specified source, gathers individual assessments, and produces a
portfolio view with level distribution, shared gaps, outliers, and a
prioritised improvement plan grouped by organisational impact.

---

## Habitat Setup

Commands for bootstrapping and monitoring the complete AI Literacy
habitat.

### /superpowers-init

- **Skills read**: harness-engineering, context-engineering
- **Agents dispatched**: harness-discoverer

Bootstrap the full AI Literacy habitat in eight steps:

1. Discover the stack
2. Generate `CLAUDE.md`
3. Generate `HARNESS.md`
4. Generate `AGENTS.md`
5. Generate `MODEL_ROUTING.md`
6. Generate `REFLECTION_LOG.md`
7. Scaffold CI templates
8. Produce initial health snapshot

Safe to re-run — existing files are preserved and only missing
components are added.

### /superpowers-status

- **Skills read**: none
- **Agents dispatched**: none

Full habitat health dashboard. Checks every component of the AI
Literacy habitat and reports status per section:

- **Habitat files** — presence of CLAUDE.md, HARNESS.md, AGENTS.md,
  MODEL_ROUTING.md, REFLECTION_LOG.md
- **Harness enforcement** — constraint count and enforcement ratio
- **Agent team** — agent definitions and availability
- **Compound learning** — reflection entries and curation state
- **Model routing** — routing table and cost data
- **CI status** — workflow presence and recent run health

Each section reports **OK**, **WARNING**, or **MISSING**.

---

## Workflow

Commands for day-to-day development workflow support.

### /reflect

- **Skills read**: none
- **Agents dispatched**: none

Capture a post-task reflection. Appends a structured entry to
`REFLECTION_LOG.md`. Asks three questions:

1. What was worked on?
2. What was surprising?
3. What should future agents know?

Classifies the signal type (technique, constraint, tooling, process)
so that reflections can be filtered and curated later.

### /cost-capture

- **Skills read**: cost-tracking
- **Agents dispatched**: none

Capture AI tool cost data for the current period. Finds the previous
cost snapshot, guides you through provider dashboards to collect
current spend and token usage, records the data, compares against the
previous period, and updates `MODEL_ROUTING.md` with observed cost
trends.

### /extract-conventions

- **Skills read**: convention-extraction
- **Agents dispatched**: none

Guided convention extraction session. Surfaces tacit team knowledge
through five structured questions covering naming, error handling,
testing, architecture, and code style preferences. Maps answers to
concrete `CLAUDE.md` conventions and `HARNESS.md` constraints. Use
this when onboarding AI to an existing codebase or after team
composition changes.

### /harness-sync

- **Skills read**: none (composes underlying commands directly)
- **Agents dispatched**: none
- **Composes**: `/convention-sync` and `/harness-onboarding` as underlying primitives

The unified, human-instigated entry point for keeping every push-direction
control surface in sync with `HARNESS.md`. Detects drift across the convention
files (`.cursor/rules/`, `.github/copilot-instructions.md`, `.windsurf/rules/`)
and `ONBOARDING.md`, presents the full picture as a multi-select prompt, and
applies the user's selected fixes via the underlying primitives in one
interactive pass — followed by a verification scan that confirms the surfaces
are in sync before committing.

Branch enforcement at start-of-run refuses to apply changes on `main` and
offers to create a `chore/sync-surfaces-YYYY-MM-DD` branch (the `chore/`
prefix satisfies the spec-first-check exemption deterministically). A
pre-commit guard enforces the trust boundary mechanically: the command never
writes to `HARNESS.md`, `AGENTS.md`, or `REFLECTION_LOG.md`. Idempotent — a
second consecutive run with no `HARNESS.md` changes between is a no-op.

Use `/harness-sync` as the typical entry point. The single-surface commands
(`/convention-sync`, `/harness-onboarding`) remain available for focused work
when you only want to touch one surface.

### /convention-sync

- **Skills read**: convention-sync
- **Agents dispatched**: none
- **Primitive of**: `/harness-sync` (the multi-surface entry point composes this command alongside `/harness-onboarding`)

Sync `HARNESS.md` conventions to other AI coding tools. Reads the
Context and Constraints sections of `HARNESS.md` and generates
tool-specific convention files for Cursor, Copilot, and Windsurf.
Ensures all AI coding tools in the team share the same project rules
regardless of which editor is used.

### /diaboli

- **Skills read**: advocatus-diaboli
- **Agents dispatched**: advocatus-diaboli

Run the adversarial spec reviewer on a spec file. Takes a path to a spec
file under `docs/superpowers/specs/` and produces a structured objection
record at `docs/superpowers/objections/<spec-slug>.md`.

The record contains up to 12 objections across six categories — premise,
scope, implementation, risk, alternatives, and specification quality — each
rated critical, high, medium, or low severity. Every objection must include
evidence quoted from the spec. The agent cannot raise objections without
grounding them in the spec text.

Objection dispositions must be written by a human before the plan-approval
gate allows the pipeline to proceed. The agent's trust boundary is
read-only — it cannot write dispositions for itself. This is the structural
mechanism that enforces human cognitive engagement before implementation
begins.

Run `/diaboli <spec-path>` after spec-writer completes and before approving
the plan. Re-run it if the spec is substantively edited after initial review.

### /choice-cartograph

- **Skills read**: choice-cartographer
- **Agents dispatched**: choice-cartographer

Run the Choice Cartographer (decision-archaeology agent) on a spec file.
Takes a path to a spec file under `docs/superpowers/specs/` and produces
a structured choice-story record at
`docs/superpowers/stories/<spec-slug>.md`.

The record contains up to 15 stories across six lenses — forces,
alternatives unspoken, defaults inherited, patterns unnamed, consequences
accepted, and story coherence. Each story names a choice the spec made
implicitly: a force resolved silently, a default inherited, a pattern
not named. The agent biases toward 5–8 stories per spec; selectivity is
the value, and pedantic enumeration is dropped in the agent's reasoning
protocol.

The agent applies the **Routing Rule** with the diaboli before emitting
any candidate: a finding belongs in the cartographer's record iff
removing it would leave a decision unrecorded but no failure undetected.
Findings shaped "this could fail" belong in the diaboli's record
instead.

Story dispositions must be written by a human, but the plan-approval
gate is **soft** — `cartograph_pending_count` is surfaced as
observability and progression is allowed even with pending stories.
The merge-time HARNESS constraint
**"PRs have adjudicated choice stories"** is the forcing function:
PR merge is blocked while any story is `pending`.

Disposition values: `accepted`, `revisit` (deferred), `promoted`. All
three are passing values at the merge gate — `revisit` carries the
"captured-but-deferred" semantic, not "spec needs to change."

Run `/choice-cartograph <spec-path>` after spec-mode `/diaboli`
dispositions are resolved. Re-run it if the spec is substantively
edited after initial mapping.

This release is spec-mode only. Code-mode behaviour is tracked under
[issue #209](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/209).

### /worktree

- **Skills read**: none
- **Agents dispatched**: none

Manage git worktrees for parallel agent isolation. Three modes:

- **`/worktree spin [name]`** — Create a new isolated worktree
  branched from the current HEAD. Use this to give a sub-agent its
  own working directory without interference.
- **`/worktree merge [name]`** — Merge the named worktree back into
  the current branch.
- **`/worktree clean [name]`** — Remove the named worktree and its
  branch.

---

## Governance

Commands for writing, auditing, and monitoring governance constraints.

### /governance-constrain

- **Skills read**: governance-constraint-design
- **Agents dispatched**: none

Guided authoring of governance constraints. Walks through six
prompts: governance requirement, operational meaning, verification
method, evidence and failure action, and three-frame alignment check.
Writes the result to `HARNESS.md` using the governance constraint
template with all extended fields. Suggests a promotion path after
writing.

### /governance-audit

- **Skills read**: governance-audit-practice, governance-observability
- **Agents dispatched**: governance-auditor

Deep governance investigation. Dispatches the governance-auditor
agent to scan `HARNESS.md`, score falsifiability, detect semantic
drift, build a governance debt inventory, check three-frame
alignment, and produce a structured report to
`observability/governance/audit-YYYY-MM-DD.md`. Updates governance
metrics in the harness health snapshot. Intended cadence: quarterly,
alongside `/assess` and `/harness-audit`.

### /governance-health

- **Skills read**: governance-observability
- **Agents dispatched**: none (dispatches governance-auditor only
  for snapshot governance section)

Quick governance pulse check. Reads the most recent audit report and
current `HARNESS.md` to display a summary table with constraint
count, falsifiability ratio, drift score, debt inventory size, frame
alignment score, last audit date, and drift velocity. Pass
`--dashboard` to generate a self-contained HTML governance dashboard
at `observability/governance/governance-dashboard.html`.
