---
title: HARNESS.md, the Document
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 9
redirect_from:
  - /explanation/harness-md/
  - /explanation/harness-md.html
---

# HARNESS.md, the Document

`HARNESS.md` is the human-readable, central description of how the
project's harness operates. It is not the harness itself — the harness
is the running collection of CI gates, hooks, skills, sandboxes,
sub-agents, and tool configurations that surrounds AI-assisted code
generation. `HARNESS.md` is the **declared specification** of that
running system, and the source from which the runtime artefacts are
derived, audited, and kept honest.

This page answers three concrete questions readers usually arrive
with: what is `HARNESS.md`, how is it operated, and how does it
compare to the things people reach for first — `AGENTS.md`, CI
configuration, and hooks.

---

## Agent = Model + Harness

Addy Osmani's framing of agent harness engineering is useful here:

> Agent = Model + Harness. The model is one input; everything else —
> prompts, tools, context policies, hooks, sandboxes, feedback loops —
> comprises the harness. A decent model with a great harness beats a
> great model with a bad harness.

The harness, in this framing, is *every piece of code, configuration,
and execution logic that isn't the model itself*: system prompts,
skill files, agent guidelines, tool definitions, MCP integrations,
bundled infrastructure, orchestration logic, hooks and middleware,
observability and monitoring. That's a lot of moving parts. Without a
central document declaring what they are collectively *supposed to
enforce*, the parts drift independently, and the team loses the
ability to reason about the system as a whole.

`HARNESS.md` is that central document. It exists because the harness
itself is not legible from any single artefact. You can read the CI
workflow file and learn what one gate enforces. You can read a hook
script and learn what one trigger does. You can read `AGENTS.md` and
learn what an agent is told. None of these tells you what the
*harness* — the composed system — is for, or whether it is currently
working as declared.

---

## How HARNESS.md compares to AGENTS.md, CI config, hooks

The single sharpest distinction:

> `AGENTS.md` is what the agent reads. `HARNESS.md` is what the
> harness runs — and the agent only feels `HARNESS.md` indirectly,
> through hook output, sync'd conventions, sub-agent reviews, and CI
> gates.

### Differences at a glance

| Dimension | AGENTS.md | HARNESS.md |
| --------- | --------- | ---------- |
| Layer | Inside the agent's context window | Outside it — describes the surrounding system |
| Mode | Descriptive guidance | Declared, verifiable contract |
| Audience | The model, on this turn | CI, hooks, GC sweeps, audit agents, humans |
| Drift handling | None — silent rot | Audited; Status block auto-updated |
| Time horizon | Snapshot of now | Continuous, with cadence and regression detection |

Two clarifications matter to make this table land cleanly.

**The "Audience: CI, hooks, GC sweeps, audit agents, humans" row does
not mean CI directly reads `HARNESS.md`.** CI reads its own workflow
files; hooks read their own scripts. What `HARNESS.md` does is
*facilitate* those artefacts — it is the driving record from which
they are generated, audited, and kept in sync. The harness is managed
*through* `HARNESS.md`, but the running enforcement happens in the
control surfaces available in the given context (CI workflows, hook
scripts, skill files, convention files, sub-agent prompts). The
audience column lists the systems whose configuration `HARNESS.md`
governs, not the systems whose runtime parses it.

**The same flow holds for `AGENTS.md` and `CLAUDE.md`.** When a new
constraint or convention enters `HARNESS.md`, the rubber meets the
road for the agent through changes propagated *into* `AGENTS.md` or
`CLAUDE.md` (which the agent reads on every turn) and into the skill
files, hooks, and CI gates that surround the agent. The harness is
configured through `HARNESS.md`; the agent's lived experience of the
harness arrives via the artefacts the harness generates.

### Why each artefact exists

| Artefact | What it is | Read by |
| --- | --- | --- |
| `HARNESS.md` | Declared specification of the surrounding system | Humans (directly), audit agents, harness-upgrade flow |
| `AGENTS.md` | Compound-learning memory the agent reads on every turn | The model, on every dispatch |
| `CLAUDE.md` | Project conventions in the agent's context window | The model, on every dispatch |
| CI config (e.g. `.github/workflows/`) | Mechanical enforcement at PR time | GitHub Actions runner |
| Hook scripts (e.g. `.claude/settings.json`) | Mechanical enforcement at edit time | Claude Code at lifecycle events |
| Convention files (`.cursor/rules/`, `.github/copilot-instructions.md`, `.windsurf/rules/`) | Mirror conventions for other AI tools | Cursor, Copilot CLI, Windsurf |

`HARNESS.md` sits above all of them and is not read by any runtime
component directly. Its job is to be the legible record of what the
harness *intends* to do, against which the runtime artefacts can be
audited.

---

## How HARNESS.md is operated

`HARNESS.md` is operated through four flows, each of which is
documented in the harness commands.

### 1. Signal capture

Amendments enter the document from several pathways. The framework
treats reflections as the primary one and arranges the others around
it. The pathways below are ordered roughly from continuous
observation to event-triggered elicitation to escape hatch.

- **Reflections.** Every coding session ends with `/reflect`, which
  captures what was surprising, what failed, what should change, and
  classifies the signal type (`context`, `instruction`, `workflow`,
  `failure`, or `none`). A `failure` classification triggers an
  **auto-constraint proposal**: `/reflect` offers to draft a new
  HARNESS constraint covering the failure mode, and if the human
  accepts, it invokes `/harness-constrain` directly. This is the
  ratchet — every preventable mistake becomes a rule. Workflow
  signals route to `AGENTS.md` (compound learning memory) rather
  than to `HARNESS.md`, but they are still proposed and adjudicated
  through the same reflection flow. `REFLECTION_LOG.md` is the
  durable trail.
- **Audit and GC findings.** `/harness-audit`, `/governance-audit`,
  and the garbage-collection sweeps surface drift between the
  declared state and the runtime reality. A constraint listed as
  `deterministic` whose tool no longer runs becomes a candidate for
  re-promotion or retirement. A GC rule reporting recurring
  violations becomes a candidate for hardening into a constraint.
  The harness-auditor, governance-auditor, and harness-gc agents
  emit reports; the human routes findings into amendments.
- **Convention extraction.** `/extract-conventions` runs a guided
  session that surfaces tacit team knowledge through structured
  questions (naming, file structure, error handling, documentation
  style, and similar) and proposes additions to the Context section
  of `HARNESS.md` (and to `CLAUDE.md`). The pathway exists because
  some conventions are real but never get written down — the team
  follows them without articulating them, and the AI cannot follow
  what it cannot read. Extraction is the framework asking the team
  to articulate.
- **Assessment-driven improvements.** `/assess` runs an AI literacy
  assessment that scans the repo for evidence, asks clarifying
  questions, produces a timestamped assessment document, and routes
  identified gaps to specific plugin commands and skills via the
  `literacy-improvements` skill. Several of those gaps map to
  `HARNESS.md` amendments (e.g. a missing constraint that the
  assessment level requires). The improvement plan is grouped by
  target level; the human accepts or defers each item, and accepted
  items invoke the relevant authoring command.
- **Affordance discovery and sibling-artefact promotion.** Two
  related pathways for promoting structured artefacts into `HARNESS.md`.
  `/harness-affordance discover` scans `.claude/settings*.json` and
  `.mcp.json` to produce a draft affordance inventory at
  `.claude/affordance-discovery-<date>.md`; the how-to guide
  describes the promote-to-`HARNESS.md` flow for affordances the
  team wants to govern. Choice stories with `disposition: promoted`
  (the third disposition value emitted by the choice-cartographer)
  are an emerging pathway: the routing mechanism is tracked under
  issue #211, but the disposition value is captured today so the
  signal is preserved while the routing is built.
- **Template upgrades.** `/harness-upgrade` discovers new
  constraints, GC rules, sections, and optional blocks that have
  been added to the plugin's `templates/HARNESS.md` since the user's
  harness was last upgraded. Each new item is presented for review
  and selectively adopted. The pathway exists because the plugin
  evolves; new template content reflects framework-level signal
  (failures, patterns, regulations) accumulated by the plugin's
  community of users, and `/harness-upgrade` is how that signal
  reaches an individual project. It is the only signal pathway
  that originates outside the project's own running observation.
- **Direct human authoring.** External requirements — a new
  governance obligation, a stack change, a team decision — can land
  in `HARNESS.md` at any time via `/harness-constrain`,
  `/governance-constrain`, or `/harness-init` re-runs. Direct
  authoring is the smallest pathway in volume but the necessary
  escape hatch when a constraint is required before the team has
  experienced its absence as a failure.

The reflection pathway is what makes Osmani's "every line in a good
AGENTS.md should be traceable back to a specific thing that went
wrong" actually work. Without reflections, the framework would
depend on memory and discipline to surface failures; with
reflections, the surfacing is part of the workflow. The other
pathways extend the same logic: extraction surfaces what was tacit;
assessment surfaces what was missing; affordance discovery surfaces
what was implicit in configuration; template upgrades surface what
the wider community has learned. See
[Compound Learning](compound-learning.md) for
the broader treatment of how these signals become shared infrastructure.

### 2. Authoring and amendment

Once a signal has produced a candidate amendment, the constraint
or GC rule is written into `HARNESS.md` via `/harness-init`,
`/harness-constrain`, `/governance-constrain`, or
`/harness-upgrade`. Each flow surfaces the implications and writes
the constraint with a declared enforcement state (`unverified`,
`agent`, or `deterministic`). See
[Constraints and Enforcement](constraints-and-enforcement.md)
for the field-level shape.

### 3. Verification and propagation

When a constraint reaches `agent` or `deterministic` status, the
corresponding runtime artefact is created or updated — a CI
workflow, a hook script, a sub-agent prompt, an entry in a
convention file. The harness-enforcer agent is the unified
verification engine; it reads `HARNESS.md`, identifies which
constraints apply at the requested scope (commit, pr, weekly,
manual), and either executes the deterministic tool or performs
the agent-based review. Propagation to the push-direction surfaces
(convention files for Cursor / Copilot / Windsurf, plus
`ONBOARDING.md`) happens via `/harness-sync`, the unified
multi-surface entry point that composes `/convention-sync` and
`/harness-onboarding` as its underlying primitives.

### 4. Audit and self-correction

`/harness-audit` runs the meta-verification — it checks that
`HARNESS.md`'s declared state matches reality. The Status block in
`HARNESS.md` is auto-updated based on what the audit finds.
Garbage-collection rules run periodically via `/harness-gc` and
detect entropy that neither real-time hooks nor PR gates catch.
Audit findings feed back into flow 1 as fresh signals — the loop
closes. The
[Self-Improving Harness](self-improving-harness.md)
page describes the feedback loop in detail.

### The shape of the loop

The pattern is:

> **reflection / audit → signal → amendment → declarative document
> → runtime artefacts → reality → reflection / audit → …**

The document is the only stable node in the loop. Every runtime
artefact is generated, audited, or regenerated against it; every
amendment originates in observed signal rather than aspiration.
Reflections are what keep the loop turning between audits — they
catch failure modes the audit has not yet been built to detect, and
they propose the constraint that the next audit will check for.

---

## Why keep HARNESS.md if the runtime artefacts already exist?

This is the most legitimate critique of the design, and it deserves
the question taken seriously. Once a CI workflow exists and a hook
fires, the constraint *is* enforced. Reading the constraint out of
`HARNESS.md` looks like reading source code that has already been
compiled into a binary — useful for the human author, redundant for
the runtime.

A useful analogy: would you delete the source code if you had the
binary executable?

The harness is the documented set of expectations of how things
should operate; the implementation is dispersed across hooks, CI
workflows, sub-agent prompts, skill files, and tool configurations.
You can absolutely run a harness without `HARNESS.md`. What you lose
is:

1. **The ability to evolve the harness as a whole.** Constraints get
   tightened, retired, or migrated from agent to deterministic
   enforcement over time
   ([Progressive Hardening](progressive-hardening.md)).
   That evolution happens through edits to `HARNESS.md` first, then
   propagation outward. Without the document, evolution becomes a
   distributed editing problem: change three CI files, two hook
   scripts, four convention files, and hope the changes are
   internally consistent.

2. **Drift detection.** The harness-auditor agent compares declared
   state against runtime state. Without a declaration, drift is
   undetectable — the runtime simply *is*, and the team has no
   reference against which to notice it has drifted from intent.
   `HARNESS.md` is what makes the harness *legible* enough to audit.

3. **Observation in action.** The Status block, the harness-health
   snapshot, and the `/superpowers-status` dashboard all read
   `HARNESS.md` and the constraint metadata it carries. These
   surfaces would be expensive to reconstruct from runtime artefacts
   alone, and would lose the "intended state" signal entirely.

4. **The human-readable centre.** A harness evolves through
   reflections, audits, and amendments captured in `REFLECTION_LOG.md`
   and surfaced in `HARNESS.md`'s constraint history. Without the
   document, there is no place that reads cleanly to a human who is
   trying to understand what the harness is for.

### The single-source-of-truth tension

A fair counter: keeping `HARNESS.md` alongside the runtime artefacts
seems to violate the single-source-of-truth principle. Two surfaces
can drift, and now we have to audit them against each other.

Two responses, both partial.

**The "compilation step" already exists, just not as a single
build.** The framework's loops — `/harness-audit`, `/harness-gc`,
`/reflect`, `/harness-sync` (which composes `/convention-sync` and
`/harness-onboarding` as its underlying primitives), the
harness-enforcer agent — are the continuous compilation. Drift between `HARNESS.md` and the runtime
artefacts is detected by the audit and surfaced by the Status block.
This is closer to a watch-mode build than to a checked-in binary.
Drift is minimal in practice because the loops run constantly.

**Single-source-of-truth was already diluted.** The expression of
harness control is necessarily dispersed across CI configuration,
hook scripts, sub-agent prompts, skill files, convention files for
multiple AI tools, and IDE-specific config. There is no realistic
shape in which one file alone can drive every surface — the surfaces
have different schemas, different runtimes, and different lifecycles.
`HARNESS.md` is not adding a new source of truth alongside a unified
one; it is providing a *comprehensible whole* across a system that is
already plural.

The trade-off is conscious: a small amount of declared/runtime drift
is accepted in exchange for the ability to reason about the harness
as a single entity, evolve it over time, and audit its current state
against intent. This is the same trade-off that source code makes
against compiled binaries — the source is technically duplicate
information, but it is the surface humans can think with.

---

## A note on Osmani's "every line earned" discipline

Osmani makes a sharp observation about `AGENTS.md`:

> Every line in a good AGENTS.md should be traceable back to a
> specific thing that went wrong.

The same discipline applies to `HARNESS.md`, with one calibration.
`AGENTS.md` lives inside every agent's context window, so each line
costs token budget on every dispatch — selectivity is enforced by
cost. `HARNESS.md` is read by humans and audit agents but not by
every dispatched agent; its cost shape is different. The line-earning
discipline still applies: a constraint that is not driven by an
observed failure or an explicit requirement does not belong in
`HARNESS.md`. But the binding pressure is *audit signal-to-noise*
rather than *token budget*. A `HARNESS.md` cluttered with aspirational
constraints makes the audit useless — every audit run reports drift
on the unverified ones, and the team learns to ignore the audit.

The shape of the discipline also matches Osmani's observation that
"harnesses don't shrink, they shift." Constraints that have moved
from `agent` to `deterministic` enforcement remain in the document;
their entries describe the deterministic tool that now enforces them.
Constraints that are no longer relevant (the convention they
enforced was abandoned, the failure mode the model used to hit was
solved by a model upgrade) should be retired, not kept around as
historical curiosities. The Status block is what makes retirement
visible: a constraint that has been `unverified` for six months with
no path to enforcement is a candidate for removal.

---

## See also

- [Harness Engineering](harness-engineering.md) —
  the broader framing of the practice; where the term comes from and
  how the three components (context engineering, architectural
  constraints, garbage collection) compose
- [The Self-Improving Harness](self-improving-harness.md) —
  the audit-and-amendment feedback loop that keeps `HARNESS.md`
  honest
- [Constraints and Enforcement](constraints-and-enforcement.md) —
  how constraints land in `HARNESS.md` and migrate from `unverified`
  to `agent` to `deterministic`
- [Progressive Hardening](progressive-hardening.md) —
  the promotion ladder for constraints
- [Agent Orchestration](agent-orchestration.md) —
  how `AGENTS.md` and `HARNESS.md` interact in the spec-first pipeline
- [HARNESS.md format reference](harness-md-format.md) —
  the field-by-field reference for the document itself
- [How to: Add a Constraint](add-a-constraint.md) —
  practical guide for amending `HARNESS.md`

External: Addy Osmani's
[Agent Harness Engineering](https://addyosmani.com/blog/agent-harness-engineering/)
crystallises the model-plus-harness framing that this page builds on.
Birgitta Boeckeler's
[Harness Engineering on martinfowler.com](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html)
is the original article from which this plugin's framing derives.
