---
title: Commands
---
# Commands

All 28 slash commands registered in `commands/`. Each command is
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
- **Subcommands**: `discover`, `add <name>`, `review <name>` (all
  implemented)

Manage the project's affordance inventory — the declared tools the
agent can invoke, with the identity each tool runs under, the audit
trail each tool produces, and the permission allowlist that
authorises it. See the
[harness-affordances design spec](../../../superpowers/specs/2026-04-26-harness-affordances-design.md)
for the full schema, the
[affordance schema reference](affordance-schema.md) for the
field-by-field definitions, and
[Maintain Your Affordance Inventory](../how-to/maintain-affordance-inventory.md)
for the end-to-end lifecycle.

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
[Discover Affordances](../how-to/discover-affordances.md) for the
full how-to.

`/harness-affordance add <name>` promotes one draft entry into the
`## Affordances` section of `HARNESS.md`. Use it after `discover` (or
when declaring a new tool by hand). It seeds from the newest discovery
draft when one matches the permission, then prompts only for the
governance fields the human must decide — `Identity` (one of
`user-sso`, `service-account`, `current-user`, `runtime-resolved`,
`none`), `Audit trail` (where a record of the action would be found;
`none` is a valid, useful answer), and optional `Constraint references`
and `Notes`. It sets `Last reviewed` to today (an `add` is a genuine
first review), validates the required fields and the `Mode`/`Trigger`
pairing, and **warns without blocking** if the permission pattern is
absent from every readable settings allowlist. Idempotency keys on the
**permission pattern**, not the heading: re-running `add` for the same
pattern edits the existing entry in place rather than appending a
duplicate, even under a different name. The command only transcribes
the human's answers, so `HARNESS.md` stays human-authored in spirit.

`/harness-affordance review <name>` re-validates one existing
affordance and bumps its `Last reviewed` date to today **only if all
three checks pass** — so the date attests to a real human
re-validation, not a file mtime. It walks the three checks, each with
an explicit `yes / no / needs-edit` prompt: **Identity** (the named
credential still exists and belongs to the named principal; for
`runtime-resolved`, the resolution chain in `Notes` still holds),
**Audit trail** (the endpoint still exists with the stated retention
and access scope), and **Permission** (the pattern is still present in
a settings allowlist). If all three pass, the date bumps and any
`[review-gap: …]` Notes lines are cleared. A `needs-edit` opens the
field for an inline edit but does **not** bump the date on its own — a
bump after any edit requires re-answering all three checks. An
unresolved `no` leaves the date unchanged and records a single
`[review-gap: <check>]` Notes line for the failing check. Use `review`
to clear what the **Affordance review staleness** GC rule reports.

### /harness-propose

Usage: `/harness-propose <assay-path> <finding-id>`

- **Skills read**: none
- **Agents dispatched**: `harness-registrar`

Drafts a Harness Decision Record from one finding in an assay, at
`status: proposed`, in `harness/decisions/HDR-<date>-<slug>.md`.

The rule text and the evidence list are copied **by the script**, byte for byte.
That is not a convenience: a model asked to copy text usually copies it and
occasionally improves it — a typo fixed, a bullet tidied, a line rewrapped — and
every one of those is a silent edit to a rule a human is about to approve
believing it to be the Assayer's words. The command's validation checkpoint
requires diffing the two blocks rather than eyeballing them, and a deviation is
reported as a defect rather than fixed in place.

`cost` is left **empty**. The approver writes it at the acceptance gate.

For a tier-2 classification (`harness-loop`, `script-validator`, `new-agent`)
four sections are written as placeholders. Acceptance is refused until a human
fills them — neither the Assayer nor the Registrar is entitled to write the
argument for why a rule belongs at the loop layer.

Pass `--slug` only to resolve a filename collision; the script never overwrites.

### /harness-accept

Usage: `/harness-accept <hdr-path>`

- **Skills read**: none
- **Agents dispatched**: `harness-registrar`

The single write transaction of the harness evolution loop, and the only place
the `cost` is ever written.

**Refusals run before the cost prompt.** Making someone compose a considered
cost for a rule that is about to be refused for citing a single assay spends
exactly the human attention the mechanism exists to protect, so the order is
load-bearing rather than stylistic.

The cost question is asked verbatim:

```text
Cost of this rule, in your own words. What will it demand of whoever
works here next, and how might it be gamed?
```

The answer is passed as `--cost-file`, never as an argument — it is multi-line
prose, and an argument would put the approver's own words into shell history one
copy-paste from the next HDR. If asked to write the cost, the command declines:
a copy-pasted cost reads exactly like a considered one, so nothing downstream
can tell them apart.

Acceptance is all-or-nothing. The script validates a staged copy of the whole
corpus — necessary because the cycle cap and the promotion threshold compare
HDRs against each other — and writes only on success, so a refusal leaves the
HDR `proposed` and the corpus byte-identical.

Acceptance covers three things in one transaction: the record is accepted, its
rule text is applied to the artifact its classification routes it to, and every
generated region is recompiled. Applying and compiling are deliberately **not**
separate gates — once a record is accepted there is no decision left in either
step, and a gate with no decision behind it is the shape of approval theatre.

It does not commit, push, or open a pull request. Three gates exist — drafting,
accepting, committing — and none is implied by another.

### /harness-compile

Usage: `/harness-compile`

- **Skills read**: none
- **Agents dispatched**: `harness-registrar`

Idempotent repair. Regenerates the generated region of every target artifact, the
decision index, and `harness/enforcement-report.md`.

You should rarely need it: acceptance compiles as part of its own transaction, so
the occasions that call for it are a hand-edit to a generated region and a merge
that combined two branches.

Compilation writes **only** between the markers, and refuses — writing nothing at
all — when a target artifact does not exist, or when a marker pair is ambiguous.
There is no safe default for an ambiguous pair: taking the outermost swallows
everything between two regions, taking the innermost silently orphans one. A
human repairs those.

It does not write into `.github/copilot-instructions.md`, `.cursor/rules/` or
`.windsurf/rules/` — `/convention-sync` generates those from `HARNESS.md`, and
two generators on one file emit the same rule twice in two voices.

### /harness-check

Usage: `/harness-check`

- **Skills read**: none
- **Agents dispatched**: `harness-registrar`

Read-only drift detection, and the CI entry point rather than something anyone
types. Non-zero exit on: an invalid corpus, malformed markers, an accepted record
that was never applied, region drift, report or index drift, or a **frozen-record
violation**.

**A failure is a build failure, not a warning.** A governance check that can be
ignored is a governance check that will be.

The frozen-record check is git-backed, and it is the one byte-identity cannot
perform. Region drift catches a hand-edit to a compiled rule; it cannot catch an
agent rewording the rule in the *accepted record* and recompiling, because the
region would then match the corpus exactly and every byte-identity check would
pass. So each accepted record is compared against its content at the commit that
accepted it.

Known limit, stated rather than hidden: a record accepted but never committed has
no accepted revision to compare against, and is skipped with a note. That window
is closed by human review of the diff.

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
- **Workflow routing** — orchestrator routing posture (opt-in / off by
  default vs enabled) and the last route taken when traceable, else
  unavailable
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

An optional `--mine` mode (Claude Code runtime only) clusters the reflection
corpus, adversarially pre-filters candidate rules, and writes a vetted
shortlist to a gitignored `REFLECTION_STAGING.md` for a human to promote —
never to `AGENTS.md` (INV-1). It augments human curation, never replaces it.

### /cost-capture

- **Skills read**: cost-tracking
- **Agents dispatched**: none

Capture AI tool cost data for the current period. Finds the previous
cost snapshot, guides you through provider dashboards to collect
current spend and token usage, records the data, compares against the
previous period, and updates `MODEL_ROUTING.md` with observed cost
trends.

### /cost-estimate

- **Skills read**: cost-estimation (via the dispatched agent)
- **Agents dispatched**: cost-estimator (read-only)

Estimate a target's tokens, agent-compute time, and (only when a cost
snapshot grounds it) cost **before** it runs — the prospective sibling
of `/cost-capture`. Signature:
`/cost-estimate <target> [--kind <target-kind>] [--out <dir>]`.

**Accepted targets** — exactly one per invocation, matching the
`cost-estimator` agent's one-target-per-dispatch contract: pasted task
text, a slicing-record path, a single-slice path, or a spec path. The
command distinguishes path vs inline text by filesystem resolution and
forwards any `--kind` (`task-text` | `slicing-record` | `slice` |
`spec`) as the explicit dispatch-stated kind; it does not itself
re-classify the `target_kind` or re-implement the methodology.

**Flow** — parse/resolve target → dispatch the read-only
`cost-estimator` agent → handle a `REFUSED:` return (surfaced verbatim,
no checkpoint, no file) → **Output Validation Checkpoint** against
`skills/cost-estimation/references/estimate-record-format.md` →
review summary → disposition (`accept` / `edit` / `re-run` / `abort`)
→ on `accept`, the single `Write`. The human disposition **precedes**
the write (the dispose-then-write ordering invariant): the command owns
the single `Write`; the agent only emits a string.

**Output path** — default
`cost-estimates/<YYYY-MM-DD>-<target-slug>-estimate.md`, a top-level
directory **outside** `observability/` (predictions are not telemetry),
gitignored as a derived, regenerable artefact. `--out <dir>` overrides
the directory; the derived filename still applies beneath it. Same-day
collisions are disambiguated under both the default and `--out` — an
existing estimate is never silently overwritten.

**Validation checkpoint** — checks the returned record against every
line of the format reference's validation checklist (including the #377
per-stage cost coupling and split-tier strict-spread checks), fixing
only **structural-only** deviations in place (routinely just deleting a
stray verdict field) and **aborting — never authoring** — on any
derived-value defect. The review summary surfaces a change-list of what
the checkpoint altered, flags a human-asserted `--kind` as
asserted-not-inferred, and reports a trailing-slash `cost-snapshot`
grounding path as "no snapshot", not a grounding. The `edit` path is
validate-and-report — a human edit is never silently reverted.

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

### /carpaccio

- **Skills read**: carpaccio
- **Agents dispatched**: carpaccio

Run the cadence governor against a task description and produce a
structured slicing record. Takes either a GitHub issue reference
(`/carpaccio #326`) or a plain-English task description and writes the
record to `docs/superpowers/slices/<task-slug>.md`.

The record contains 1–9 slices across five lenses — `decision-boundary`
(primary), `acceptance-criterion` (fallback), `end-to-end`, `independence`,
and `inseparability`. Each slice ships with `disposition: pending`,
`file_as_issue: pending`, `issue_url: null`, and `merged_into: null`.
The agent never pre-fills these — the human writes them inline in the
record before the orchestrator's step-0 gate will advance.

Disposition values: `accepted` (this slice is a unit of work), `merged`
(fold into another slice by id), `dropped` (do not pursue), `revised`
(push back; the agent will re-slice on the next dispatch). The human
also sets `progressed_slice:` at the top of the frontmatter to mark
which slice this iteration will work on. For `accepted` slices that
are not the progressed slice, the human sets `file_as_issue: true`
(orchestrator runs `gh issue create` and writes the returned URL to
`issue_url:`) or `false` (tracked elsewhere).

When a task is genuinely atomic, the agent emits a single-slice record
with `inseparable: true` and a defended `## Inseparability rationale`
section. The single slice still requires disposition. The orchestrator
then passes the full task description to spec-writer rather than a
slice scope.

Run `/carpaccio` at orchestrator step 0 (the orchestrator invokes it
automatically) or manually before spec-writer when running the
pipeline by hand. Re-run on `disposition: revised` — the prior record
is overwritten, prior dispositions reset.

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

### /coda

- **Skills read**: `coda`
- **Agents dispatched**: `coda` (survey and draft records)

Closes a session deliberately rather than by attrition. Four steps, same order
every time: **survey** what landed and what is still live, **park** each open
thread with a concrete next action, write the **closure summary** through
`/reflect`, and **close**.

`/coda resume <record>` closes a parked thread by writing a `.resumed.md`
transition naming its predecessor — never by editing or deleting the original.

**`/coda` versus `/reflect`.** `/reflect` writes a learning. `/coda` closes a
session, and calls `/reflect` as part of doing so. Capturing one surprise and
carrying on is `/reflect`; stopping is `/coda`.

Two design points worth knowing before you use it:

- **Parking happens before reflection**, and records are committed there.
  `/reflect` stages only the reflection paths and, where a *Reflections via PR
  workflow* constraint is declared, relocates the tree to `main` — so a ritual
  that reflected first would publish a summary describing records it left
  behind uncommitted.
- **Nothing is refused.** The next-action check asks one more question when it
  finds no anchor; whatever you answer is parked, including the same words
  again. It renders no verdict on your wording.

Stoppable at any point. If you say plainly that you want to keep working, the
ritual stops and states exactly what has already been written — records are
append-only, so nothing can be withdrawn. A request for *new work* mid-ritual
is different: that gets parked, because it is the drift the ritual exists for.

See the `coda` skill, [Closing a session](../how-to/closing-a-session.md), and
[Parking record format](parking-record-format.md).

---

### /mast

- **Skills read**: `mast`
- **Agents dispatched**: `mast` (Read mode)

Reads the pact you set for yourself, or authors one. Two modes:

- **`/mast [read]`** (default) — recites your declared budget and says where
  you stand, each key flagged for what can honestly be seen. If no block is
  declared it says so and **offers Tune**; if one is malformed it names the
  missing clause and continues in observe-only.
- **`/mast tune [BLOCK]`** — the only sanctioned path that creates or amends
  `~/.claude/pacts.md`. Reads your current values back as context (not as
  defaults), asks the stop hour first and offers to stop there, says what
  nothing reads yet before asking, then composes the block, shows it, and
  writes only on accept — followed by a validation checkpoint.

**It never estimates spend.** Nothing in this plugin observes it, and a
fabricated figure against a real ceiling is worse than no figure.

The weather note says when a budget was tuned today, and discloses its own
blind spot: a pact hand-edited outside Tune never moves the stamp. Something
stronger is not available — the pact file is never committed, so there is no
diff and no CI can see it.

Advisory throughout: absent, malformed, and tuned-today are all reports, and
none changes what you may do next. Boundary notices and the hard stop are a
separate slice.

See the `mast` skill and [Keeping a pact](../how-to/keeping-a-pact.md).

---

### /wip

- **Skills read**: `wip-warden`
- **Agents dispatched**: `wip-warden`

Counts live sessions against the limit you declared in your `Session WIP`
block, and lists which sessions and how long since each last took a turn.

**It counts sessions and never says anything about you.** That boundary is what
keeps `/reservoir` trustworthy, and no script enforces it — it is held by
whoever writes the output.

Three things it will not do:

- **Invent a limit.** If your block declares none, it says so and points at
  `/mast tune`. An imposed limit is exactly the pact the clear-weather rule says
  does not hold.
- **Report an inexact count as exact.** When the registry's flag is `inferred`
  it says "at least", and why.
- **Stop you.** `enforcement: strict` asks — park one, or say what is urgent —
  and says plainly that nothing here can hold a session.

An override you speak is not recorded; the command says so rather than implying
otherwise. Ages are measured from each session's last turn, not from when it
started — the latter would point you at the session you are working in as the
obvious one to park.

The `SessionStart` hook reports the same breach once, on startup only. Unlike
the hook, `/wip` answers even when no block is declared: you asked.

See the `wip-warden` skill and [Watching your WIP](../how-to/watching-your-wip.md).

---

### /convene

Usage: `/convene <spec-path>`

- **Skills read**: `convener`
- **Agents dispatched**: `convener`

Maps the roles and groups a spec affects, drafts the one concrete question worth
asking each, and writes the consultation record at
`docs/superpowers/consultations/<spec-slug>.md`.

**It never contacts anyone.** You carry every conversation, or the conversation
does not happen.

The dialogue runs both ways: it asks which proposed voices do not apply, **and
who it missed**. A voice you name is flagged `asked` — the flag records who
named the voice, not who wrote the question. The one the agent could not derive
is usually the one worth the most.

Records are append-only. Re-running against a spec that already has a record
writes a `.superseded.md` transition rather than editing the existing file.

Two dispositions are complete answers: `consulted` with what came back, and
`deliberately-not-consulted` with the because. Each needs a one-line `outcome`,
and **no two voices may share one** — the merge-time check refuses one string
standing for several decisions, and never judges a reason.

The plan-approval gate is soft. The merge constraint **PRs have disposed
consultation voices** is deterministic but **complete-if-present**: a PR with no
consultation record passes, because running `/convene` is a choice.

See the `convener` skill and [Convening the voices](../how-to/convening-the-voices.md).

---

### /reservoir

- **Skills read**: `cognitive-reservoir`
- **Agents dispatched**: `reservoir-warden` (Read mode)

An on-demand, read-only advisory on **you**, the verifier — not on the
code. Two modes:

- **`/reservoir [read]`** (default) — dispatch the `reservoir-warden`
  agent for a fuller read than the automatic Stop-hook advisory: a proxy
  table (continuous span, decision volume, context switches, wall-clock
  hour), each line flagged `observed` / `inferred` / `asked`, and — if a
  threshold is crossed — the single decide-your-stop-first
  recommendation.
- **`/reservoir tune`** — help you edit the `Cognitive reservoir` block
  in `HARNESS.md` (thresholds and an optional `chronotype`), proposing
  edits for you to confirm.

Advisory-only and **not** a Constraint: it never blocks, never scores,
and records no claim about your cognitive state. See the
[Watching the Verifier](../explanation/watching-the-verifier.md) concept
page and the [how-to guide](../how-to/watch-your-cognitive-reservoir.md).

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
