---
title: A First-Time Tour of Every Capability
---
# A First-Time Tour of Every Capability

The plugin ships with twenty-two slash commands, a dozen agents, and
dozens of skills. Opened all at once, that is a lot of surface area.
This tutorial gives you a single route through it — every capability
in the order it is most useful on a first run, with the reason each
step comes where it does.

Plan for about ninety minutes if you work through the whole tour in
one sitting. You can also stop at the end of any phase; each phase
leaves the project in a coherent, better-off state than when you
started.

The tour assumes you have already completed
[Getting Started](getting-started.md) — the plugin is installed and you
have a project to try it against. If not, do that first.

---

## How the Tour Is Structured

The capabilities fall into eight phases. Each phase has one reason
for existing, and each command in the phase contributes to that reason:

1. **Orient** — see the lay of the land before you touch anything.
2. **Establish the foundation** — create `HARNESS.md`.
3. **Measure where you are** — run an assessment.
4. **Adjust the harness** — encode the findings.
5. **Start the learning loop** — capture and curate.
6. **Add governance** — promote the rules that matter most.
7. **Set the cadence** — audit, measure, and track cost.
8. **Share and scale** — onboard new people and other repos.

The dependencies between phases are real. `/assess` only makes sense
once there is a harness to assess against. `/reflect` only produces
useful entries once you have done something worth reflecting on.
`/governance-audit` only has material once constraints exist to
audit. Skipping phases forward is possible, but the output thins out
quickly.

---

## Phase 1: Orient (five minutes)

### `/superpowers-status`

**Why first.** Before you create anything, look at the empty baseline.
`/superpowers-status` reports the state of every habitat component:
`CLAUDE.md`, `HARNESS.md`, `AGENTS.md`, `MODEL_ROUTING.md`,
`REFLECTION_LOG.md`, agent definitions, CI workflows, and learning
artefacts. On a fresh project almost everything reports **MISSING**.
That is the point — you want the picture of where you start.

**What it does.** Reads the project filesystem and compares it to
the expected habitat. No agents are dispatched. Runs in seconds.

**How to run it.**

```text
/superpowers-status
```

The output is a dashboard of OK / WARNING / MISSING flags per
section. Read it and take a screenshot or copy the output into a
note. You will compare against this at the end of the tour.

---

## Phase 2: Establish the Foundation (twenty minutes)

Every other capability reads from `HARNESS.md` or one of the habitat
files it creates. Without these, the later phases have nothing to
operate on.

You have a choice here — `/harness-init` for a minimal, focused start,
or `/superpowers-init` for the full habitat in one pass. Pick one; do
not run both. The tour continues the same way afterwards.

### Option A — `/harness-init`

**Why.** Minimal, conversational, and interactive. You choose which
of five feature areas (context, constraints, garbage collection, CI,
observability) to configure on this run. The command is safe to
re-run later to add the ones you skipped.

**What it does.** Dispatches the `harness-discoverer` agent to scan
your stack, walks you through a short convention interview, then
generates `HARNESS.md` and a CI workflow scaffold.

**How to run it.**

```text
/harness-init
```

Accept all defaults the first time. The command generates `HARNESS.md`
with your conventions, an initial set of constraints, and a CI entry.

### Option B — `/superpowers-init`

**Why.** Full habitat in one go. Generates `CLAUDE.md`, `HARNESS.md`,
`AGENTS.md`, `MODEL_ROUTING.md`, `REFLECTION_LOG.md`, CI templates,
and an initial health snapshot in an eight-step flow. Choose this if
you already know you want the full habitat and do not want to layer
it in over time.

**How to run it.**

```text
/superpowers-init
```

The output is the same set of files `/harness-init` produces, plus the
additional habitat files listed above. Either path lands you at a place
where every later capability has something to read.

### `/harness-status`

**Why next.** You just generated files. Verify the harness actually
registered what you wrote.

**What it does.** Reads `HARNESS.md` and reports enforcement ratio,
drift since the last audit, and garbage-collection state. No agents.

**How to run it.**

```text
/harness-status
```

If the ratio looks reasonable (for example, 3/4 enforced) and no
drift is reported, the foundation is sound. Move on.

---

## Phase 3: Measure Where You Are (thirty minutes)

The harness now exists. Before you start tuning it, find out where
your overall AI collaboration practice sits. The assessment gives
you a framework level, a set of prioritised gaps, and — crucially —
an improvement plan that will drive the next two phases.

### `/assess`

**Why here and not earlier.** `/assess` looks for evidence of each
literacy level. On a bare project it returns Level 0–1 regardless
of team practice, because the evidence is absent. Running it *after*
the foundation means the L2–L3 signals the assessment checks for
(CI, CLAUDE.md, HARNESS.md) are already in place and the result
reflects the real starting point.

**What it does.** Scans for observable evidence, asks three to five
clarifying questions, writes `assessments/YYYY-MM-DD-assessment.md`,
applies immediate habitat fixes, walks an improvement plan you
accept or defer item by item, and adds a level badge to the README.

**How to run it.**

```text
/assess
```

Keep the assessment document open in another tab. You will refer
back to the **Gaps** and **Improvement Plan** sections throughout
the rest of the tour.

---

## Phase 4: Adjust the Harness (twenty minutes)

The assessment told you what is missing. The next three commands
translate those findings into changes in the harness itself.

### `/extract-conventions`

**Why here.** The `/harness-init` convention interview is short on
purpose. If the assessment flagged thin conventions — or if your
team has tacit rules that were never written down — this is where
you surface them.

**What it does.** Runs a guided five-question session covering
naming, error handling, testing, architecture, and style. Maps the
answers to concrete entries in `CLAUDE.md` and `HARNESS.md`.

**How to run it.**

```text
/extract-conventions
```

Skip this step if your convention section already feels accurate.
Run it if the assessment scored **Context Engineering** low.

### `/harness-constrain`

**Why next.** You now have conventions. Some of them should be
enforced. `/harness-constrain` is the general-purpose tool for
adding a new constraint or promoting an existing one from
`unverified` to `agent` or `deterministic`.

**What it does.** Asks what rule you want to enforce, helps design
it, checks for supporting tooling (for example, `gitleaks` for the
secrets constraint), and writes the result into the Constraints
section of `HARNESS.md`. For deterministic constraints, it also
configures the verification slot so the tool actually runs.

**How to run it.**

```text
/harness-constrain
```

Run this once per constraint you want to add. A reasonable first
target list: no secrets in source (deterministic), tests must pass
(deterministic), architecture layer boundaries (agent).

### `/convention-sync` (or `/harness-sync` for the multi-surface entry)

**Why last in this phase.** Once the conventions and constraints
exist in `HARNESS.md`, other tools the team uses — Cursor, Copilot,
Windsurf — need the same rules. Running this after the harness is
stable avoids re-syncing every time you add a constraint.

**What `/convention-sync` does.** Reads the Context and Constraints
sections of `HARNESS.md` and generates `.cursor/rules`,
`.github/copilot-instructions.md`, and `.windsurf/rules` files with
the equivalent content.

**The unified entry point.** `/convention-sync` is one of the
underlying primitives that
[`/harness-sync`](../how-to/sync-harness.md)
composes. For multi-surface propagation in one interactive pass —
across the convention files *and* `ONBOARDING.md` together — use
`/harness-sync`. Use `/convention-sync` directly only when you want
to focus on the convention files alone.

**How to run it.**

```text
/harness-sync         # multi-surface entry (recommended)
/convention-sync      # focused single-surface alternative
```

Skip the convention-sync step if the team only uses Claude Code.
Run it if anyone works in a different AI coding environment against
this repo.

---

## Phase 5: Start the Learning Loop (ongoing)

The harness is now in place. The next capabilities turn it from a
static set of rules into something that improves with use.

### `/reflect`

**Why now.** You have just done real work — set up a harness, added
constraints, synced conventions. That session contains signal. The
learning loop starts with capturing it.

**What it does.** Appends a structured entry to `REFLECTION_LOG.md`.
Asks three questions: what was worked on, what was surprising, what
should future agents know. Classifies the entry as `technique`,
`constraint`, `tooling`, or `process` so future curation can filter.

**How to run it.**

```text
/reflect
```

Run `/reflect` at the end of any session where something non-obvious
came up. The entries compound — thirty or forty of them and you
have a genuine body of project knowledge that agents can read.

### `/harness-gc`

**Why here.** Commit hooks and PR checks run on every change. They
catch fast drift. Garbage-collection rules run on a schedule and
catch the slow drift those per-change checks miss — stale docs,
deprecated dependencies, broken links.

**What it does.** Two modes. In *add* mode you declare a new GC
rule: what to check, how often, whether it needs agent judgement or
can be a tool. In *run* mode it executes existing rules on demand.

**How to run it.**

```text
/harness-gc
```

Good defaults for a first GC set: documentation freshness (weekly,
agent), dependency currency (weekly, agent), and a monthly check
that your secret scanner is still operational.

---

## Phase 6: Add Governance (varies — run when ready)

Regular constraints protect code. Governance constraints protect
*meaning* — the shared understanding of what a rule enforces and why.
This phase can wait until the team has agreed which constraints
matter enough to treat as governance.

### `/governance-constrain`

**Why here and not in Phase 4.** Regular constraints are cheap and
fast to add. Governance constraints take more care — each one
requires a three-frame alignment check and an explicit operational
definition. You only want this overhead on the rules that will be
audited quarterly.

**What it does.** Walks six prompts: governance requirement,
operational meaning, verification method, evidence, failure action,
and three-frame alignment check. Writes a governance-grade constraint
into `HARNESS.md` using the extended template.

**How to run it.**

```text
/governance-constrain
```

### `/governance-health`

**Why next.** A fast pulse before you commit to a full audit. Reads
the most recent audit report and current `HARNESS.md` and reports
constraint count, falsifiability ratio, drift score, debt inventory,
frame alignment, and last audit date.

**How to run it.**

```text
/governance-health
```

Pass `--dashboard` to generate an HTML governance dashboard:

```text
/governance-health --dashboard
```

### `/governance-audit`

**Why last in the phase.** Full investigation. Dispatches the
`governance-auditor` agent, which takes noticeably longer than the
other commands and produces a structured report. Do this *after* you
have written governance constraints — an audit of an empty governance
section is not interesting.

**What it does.** Scans `HARNESS.md` for governance constraints,
scores falsifiability, detects semantic drift, builds a governance
debt inventory, checks three-frame alignment, and writes a report
to `observability/governance/audit-YYYY-MM-DD.md`.

**How to run it.**

```text
/governance-audit
```

Intended cadence: quarterly, alongside `/assess` and `/harness-audit`.

---

## Phase 7: Set the Cadence (thirty minutes; recurs quarterly)

These commands are about keeping the harness honest over time.
Run them once now to see their output; thereafter they live on a
quarterly or monthly cadence.

### `/harness-audit`

**Why here.** Drift is real. Files get moved, tools get renamed, CI
jobs get disabled. `/harness-audit` compares what `HARNESS.md`
claims against what the project actually contains, and flags the
gaps.

**What it does.** Dispatches `harness-discoverer` and then
`harness-auditor`. Reports mismatches, stale constraints, and
missing enforcement. Intended cadence: quarterly, or after any
structural change to the project.

**How to run it.**

```text
/harness-audit
```

### `/harness-health`

**Why next.** A persistent record of harness state over time. Each
snapshot is a datapoint you can graph or compare.

**What it does.** Two modes. *Quick* reads existing data only —
enforcement ratio, mutation trends, learning velocity, cadence
compliance. *Deep* runs `harness-auditor` first for a full audit.
Writes the snapshot to `observability/snapshots/` with a datestamp.

**How to run it.**

```text
/harness-health
```

First time: run in *deep* mode so the snapshot is grounded in a
fresh audit. Subsequent runs can be *quick*.

### `/cost-capture`

**Why here.** Cost data anchors the rest. Without it, decisions about
model routing, constraint scope, and agent use are made without knowing
what they cost. One cost snapshot per quarter is enough.

**What it does.** Finds the previous snapshot, walks you through
provider dashboards to collect current spend and tokens, records
the data, compares period over period, and updates `MODEL_ROUTING.md`.

**How to run it.**

```text
/cost-capture
```

### `/observatory-verify`

**Why last in the phase.** Observability is only useful if the data
signals downstream consumers expect are actually present. This
command runs an 82-signal checklist across the artefacts the
previous commands in this phase produced — snapshots, assessments,
reflections, governance reports, and cost data.

**What it does.** Reports each signal as PRESENT, PARTIAL, or
MISSING with a summary table by category. Use it after generating
snapshots to confirm the Observatory contract is satisfied.

**How to run it.**

```text
/observatory-verify
```

---

## Phase 8: Share and Scale (when ready)

The harness now reflects your practice and is being kept honest on
a cadence. The final phase is about letting other people — and
other repositories — benefit from that practice.

### `/harness-onboarding` (or `/harness-sync` for the multi-surface entry)

**Why here.** Once the habitat is real, new team members need a way
in. `ONBOARDING.md` is the friendly face of the harness — the same
information, but synthesised into prose organised around what a new
contributor actually needs to know.

**What `/harness-onboarding` does.** Reads `HARNESS.md`, `AGENTS.md`,
and `REFLECTION_LOG.md` and produces a ten-section `ONBOARDING.md`:
tech stack, conventions, enforcement, pitfalls, architecture, testing,
how the harness works, and a first-PR checklist. A GC rule checks
monthly whether it has become stale against its sources.

**The unified entry point.** `/harness-onboarding` is one of the
underlying primitives that
[`/harness-sync`](../how-to/sync-harness.md)
composes. For multi-surface propagation in one interactive pass —
when you want to refresh both `ONBOARDING.md` *and* the convention
files together — use `/harness-sync`. Use `/harness-onboarding`
directly only when you want to refresh `ONBOARDING.md` alone (for
example, just before a new engineer joins, while leaving the
convention files untouched).

**How to run it.**

```text
/harness-sync         # multi-surface entry (recommended)
/harness-onboarding   # focused single-surface alternative
```

### `/portfolio-assess`

**Why here.** One repo with a level rating is useful. A whole
portfolio with level distribution, shared gaps, outliers, and a
prioritised plan is actionable at organisation level. Run this
after at least a few repos in your org have been individually
assessed.

**What it does.** Discovers repos via `--local <path>`, `--org <name>`,
or `--topic <tag>`, aggregates their assessments, and produces a
portfolio view with level distribution, shared gaps, outliers, and
a plan grouped by organisational impact.

**How to run it.**

```text
/portfolio-assess --org my-github-org
```

Or point it at a local directory of checkouts:

```text
/portfolio-assess --local ~/code/my-org
```

---

## Two Day-to-Day Capabilities Worth Knowing

These are not part of the tour sequence, but you will reach for them
regularly once the habitat is running.

### `/worktree`

**What it does.** Manages git worktrees for parallel agent
isolation. `/worktree spin [name]` creates an isolated worktree so
a sub-agent can work without interfering with your current branch;
`/worktree merge [name]` merges it back; `/worktree clean [name]`
removes it.

**When to reach for it.** Any time you want to dispatch multiple
agents on independent work streams, or run a risky refactor in
isolation from your main workspace.

### `/diaboli`

**What it does.** Dispatches the advocatus-diaboli agent against a
spec file and produces a structured objection record at
`docs/superpowers/objections/<slug>.md`. The agent raises up to 12
objections across six categories (premise, scope, implementation,
risk, alternatives, specification quality), each with a severity
rating (critical, high, medium, low). Objection dispositions must
be written by a human — the agent cannot do this for itself.

**When to reach for it.** After spec-writer produces a spec and
before you approve the plan. The orchestrator invokes it
automatically in the pipeline; run it manually when working outside
the full pipeline or when a spec is substantially revised after
initial review.

```text
/diaboli docs/superpowers/specs/2026-04-19-my-feature.md
```

### `/harness-upgrade`

**What it does.** Compares the template version marker in your
`HARNESS.md` against the installed plugin version and offers any
new, updated, or removed template content item by item. You accept
or dismiss each one.

**When to reach for it.** After every plugin update. The
SessionStart hook will prompt you the first time a new version is
available — you can run it on demand any time after that.

---

## What You Have Now

After running every capability in this tour you have:

- A `HARNESS.md` with conventions, constraints, and GC rules
- A first assessment at `assessments/YYYY-MM-DD-assessment.md`
  with a level rating and improvement plan
- Constraints synced to any other AI coding tools the team uses
- A `REFLECTION_LOG.md` with the first entry and a beginning curation
- Governance constraints for the rules that matter most, plus an
  initial audit report
- A harness audit, a health snapshot, cost data, and an observatory
  verification — the cadence artefacts set up for quarterly use
- An `ONBOARDING.md` for new team members
- Optionally, a portfolio view if you assessed multiple repos

Re-run `/superpowers-status` now and compare against the dashboard
you captured in Phase 1. Nearly every section should have moved
from MISSING to OK. That is the shape of the work the plugin has
helped you do.

---

## What Happens Next

The tour is a one-time exercise. The quarterly rhythm that follows
it is short:

- `/assess` — where are we now?
- `/harness-audit` — has the harness drifted?
- `/harness-health` — record a snapshot
- `/cost-capture` — record cost
- `/governance-audit` — deep check of governance constraints

Between quarters: `/reflect` after meaningful sessions,
`/harness-constrain` to promote unverified constraints as tooling
arrives, `/harness-upgrade` when plugin updates land,
`/diaboli <spec-path>` after spec-writer when starting any feature —
before plan approval.

---

## Next Steps

- [The Improvement Cycle](the-improvement-cycle.md) — a focused walk
  through one L2 → L3 cycle, if you want more depth on the
  assessment-driven path
- [Governance for Your Harness](governance-for-your-harness.md) — a
  full walkthrough of the governance phase in isolation
- [Harness for an Existing Codebase](harness-from-scratch.md) —
  strategies for retrofitting a harness into a mature project
- [Reference: Commands](../reference/commands.md) — the full
  specification for every command mentioned above
