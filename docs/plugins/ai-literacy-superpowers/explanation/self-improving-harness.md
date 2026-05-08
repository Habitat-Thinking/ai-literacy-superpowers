---
title: The Self-Improving Harness
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 11
redirect_from:
  - /explanation/self-improving-harness/
  - /explanation/self-improving-harness.html
---

# The Self-Improving Harness

A static harness reflects the team's understanding at one point in time and requires manual effort to improve. This plugin adds a self-improving layer: reflections captured after each session accumulate in a learnings log, agents read past learnings when reviewing new code, and the harness-audit agent analyzes violation history to propose new or strengthened constraints. The harness treats its own operational record as input data, generating improvement proposals that humans accept or reject -- closing the loop between observation and enforcement.

For the introductory treatment of compound learning and the curation process, see [Compound Learning](compound-learning.md). This page goes deeper into the mechanics: the data structures, the agent reading windows, the automated proposal pipeline, and the feedback loop that makes the harness self-referential.

---

## The Reflection Mechanism

A reflection is a structured note captured after a piece of work. It records what was surprising, what failed, what a future session should know, and -- critically -- whether the surprise suggests a new constraint. The `/reflect` command drives the capture process.

### What Gets Captured

Each reflection entry contains seven fields:

```text
---

- **Date**: YYYY-MM-DD
- **Agent**: [who did the work]
- **Task**: [one-sentence summary]
- **Surprise**: [anything unexpected during the work]
- **Proposal**: [pattern or gotcha to consider for AGENTS.md, or "none"]
- **Improvement**: [what would make the process smoother next time]
- **Signal**: [context | instruction | workflow | failure | none]
- **Constraint**: [proposed constraint text, or "none"]
```

The **Surprise** field is the most important. Surprises are signals. An edge case you did not anticipate, an assumption that broke, a tool that did not behave as documented -- each of these is raw material for improving the harness. The field exists to force the question: *what did the environment fail to tell the agent?*

The **Proposal** field captures a candidate for promotion to `AGENTS.md` -- a gotcha, a style note, an architectural decision that emerged during the work. The **Improvement** field captures process-level observations: a check that should have run earlier, a context document that was missing information, a tool configuration that needs updating.

The **Constraint** field is populated by the auto-constraint proposal step, described below. If the reflection describes a preventable failure -- a lint error that slipped through, a wrong branch, a missing check -- the `/reflect` command drafts a constraint and offers it to the user for acceptance.

The **Signal** field classifies what kind of learning the reflection represents, using the taxonomy from Birgitta Boeckeler's [Feedback Flywheel](https://martinfowler.com/articles/reduce-friction-ai/feedback-flywheel.html). A `context` signal means the priming document was missing something -- a convention, a version, a domain detail. An `instruction` signal means a prompt or command produced notably better or worse results. A `workflow` signal means a process pattern succeeded or failed in a way worth recording. A `failure` signal means the error was preventable -- a check that should have run, a tool that was misconfigured. The classification guides where the learning should route during curation: context signals route to HARNESS.md, instruction signals to skills or commands, workflow signals to AGENTS.md, and failure signals to constraints.

### When Reflections Are Captured

Reflections are captured at the end of a pipeline run by the integration agent, or manually by a developer using the `/reflect` command at the end of any coding session. The integration agent appends reflections automatically as part of its post-merge cleanup. Manual reflections are lightweight -- two minutes of thought, not an essay.

### The `/reflect` Command

The command follows a structured process:

1. Gather context -- what was worked on, what was surprising, what should future agents know.
2. Format the entry using the standard template.
3. Classify the signal type: review the Surprise and Improvement fields and propose a signal type (`context`, `instruction`, `workflow`, `failure`, or `none`) with a one-sentence rationale. The user confirms or overrides.
4. Run the auto-constraint proposal step: review the Surprise and Improvement fields for preventable failures. If one is found, draft a constraint with a rule, enforcement type, tool, and scope. A `failure` signal from step 3 feeds directly into this step.
5. If the user accepts the proposed constraint, invoke `/harness-constrain` to add it to `HARNESS.md` immediately. Record the constraint in the reflection entry.
6. Append the entry to `REFLECTION_LOG.md`.
7. Commit the updated log.

The constraint proposal step is what makes `/reflect` more than a journal. It is the mechanism that converts operational experience into enforcement infrastructure, with the human deciding which proposals deserve promotion.

---

## REFLECTION_LOG.md

`REFLECTION_LOG.md` is an append-only log. Entries are never modified or deleted. New entries are appended after the last existing entry, separated by `---` markers. The log grows over the lifetime of the project, accumulating the operational history of every session.

### Structure

The file opens with a header comment that explains the entry format and states the cardinal rule: entries propose changes to `AGENTS.md` but never modify it directly. The comment block serves as a contract between the agents that write to the log and the humans who curate it.

```text
# Reflection Log

<!-- Each entry is appended by integration-agent at the end of a pipeline run.
     Entries capture what was surprising, what went wrong, and what should be
     proposed for addition to AGENTS.md.

     Do NOT modify AGENTS.md directly from this log — only propose. Humans
     curate AGENTS.md. -->
```

After the header, entries accumulate chronologically. The most recent entry is at the bottom of the file.

### How Agents Read the Log

Different agents read different windows of the log, calibrated to their role and the cost of reading context:

| Agent | Reading window | Purpose |
| --- | --- | --- |
| Orchestrator | 20 most recent entries | Inform pipeline strategy -- avoid repeating past failures, adjust agent dispatch order |
| Harness enforcer | 10 most recent entries | Calibrate scrutiny -- pay attention to patterns that past reflections flagged as missed |
| Harness GC | 10 most recent entries | Detect entropy signals -- reflections mentioning drift, staleness, or documentation rot guide GC focus |

The orchestrator reads the deepest window because it makes strategic decisions that affect the entire pipeline. If a past reflection mentions a failure in the area about to be worked on, the orchestrator adjusts its strategy -- dispatching deterministic checks earlier, briefing subagents about known pitfalls, or allocating extra review cycles.

The enforcer reads reflections to catch patterns that agent-based review has previously missed. If a reflection says "the enforcer did not catch direct database access in the handler," the enforcer pays particular attention to that pattern in the current review. Reflections are evidence of where agent review has been insufficient.

The GC agent reads reflections to detect slow-burning entropy that declarative GC rules might not cover. A reflection about documentation drift is a signal that the documentation freshness rule needs tighter criteria or that a new GC rule is warranted.

---

## AGENTS.md and Compound Learning

Where `REFLECTION_LOG.md` is raw material, `AGENTS.md` is refined knowledge. It is the project's persistent memory across AI sessions -- curated patterns, gotchas, architectural decisions, and test strategy that every agent reads at session start.

### The Sections

`AGENTS.md` is organised into five sections, each serving a distinct purpose:

- **STYLE** -- patterns and idioms that work well in this codebase. Each entry states what to do and why it works here.
- **GOTCHAS** -- traps, surprises, and non-obvious constraints. Each entry states what the trap is and how to avoid it.
- **ARCH_DECISIONS** -- key architectural decisions with reasoning and rejected alternatives.
- **TEST_STRATEGY** -- how tests are structured, where they live, what patterns to follow.
- **DESIGN_DECISIONS** -- stable interface contracts and data shapes that agents should not second-guess.

### The Promotion Process

Reflections do not flow into `AGENTS.md` automatically. The path from raw reflection to curated entry requires human judgement:

1. A reflection is captured in `REFLECTION_LOG.md` with a non-empty Proposal field.
2. During a curation session (weekly or fortnightly), the developer reads recent reflections and asks: *does this keep happening?*
3. A gotcha that appeared once is an anecdote. A gotcha that appeared three times is a convention waiting to be written.
4. The developer promotes the recurring pattern into the appropriate section of `AGENTS.md`, writing it up with specificity -- not "better error handling" but "catch exceptions in service methods, wrap them in AppError with a code and message, and let the controller handle the HTTP response."
5. From that point forward, every agent reads the new entry at session start.

### Why Human Curation Matters

The log header states it plainly: "Do NOT modify AGENTS.md directly from this log -- only propose. Humans curate AGENTS.md."

This is a deliberate design choice, not a limitation. Raw reflections are noisy. Sometimes the AI got confused because of a bad prompt, not because of a missing convention. Sometimes the edge case was genuinely rare. Sometimes the reflection captures frustration rather than insight.

Human curation is the filter that separates signal from noise. An entry in GOTCHAS that does not reflect an actual problem that was actually solved is noise that increases the cognitive cost of every future session. The cost of a false positive in `AGENTS.md` is not a wrong entry -- it is a wrong entry read by every agent on every invocation, forever, until someone removes it.

The asymmetry is important: it is cheap to leave a reflection in the log (it costs nothing if no one promotes it) and expensive to promote a bad reflection to `AGENTS.md` (it costs tokens and attention on every session). The curation step enforces this asymmetry.

---

## Automated Constraint Proposals

The `/reflect` command does not only capture observations. It actively proposes constraints when the observation describes a preventable failure.

### The Auto-Constraint Pipeline

After formatting a reflection entry, `/reflect` reviews the Surprise and Improvement fields:

1. If either field describes a failure that a tool or check should have caught -- a lint error that slipped through, a wrong branch, a missing validation, a security check that did not run -- the command drafts a constraint proposal.
2. The proposal includes four elements:
   - **Rule**: a one-sentence description of what the constraint enforces
   - **Enforcement**: `deterministic` (tool-backed) or `agent` (LLM-reviewed)
   - **Tool**: the command that checks it, if known
   - **Scope**: when it runs -- `commit`, `pr`, `session-end`
3. The proposal is presented to the user. Accept or decline.
4. If accepted, `/reflect` invokes `/harness-constrain` to add the constraint to `HARNESS.md` immediately, with the specified enforcement type and scope.
5. The reflection entry records the outcome: either the constraint description and enforcement type, or "none."

This pipeline converts operational surprise into enforcement infrastructure in a single step. The human remains the decision-maker, but the work of identifying what could be automated -- noticing that a failure was preventable and drafting the rule -- is delegated to the agent.

### The Harness-Audit Agent's Role

The harness-audit agent operates at a different timescale. Where `/reflect` proposes constraints from individual sessions, the auditor analyses violation history across sessions to identify systemic patterns.

When the harness-audit agent runs, it does not only check whether current constraints are being met. It looks at the history of constraint violations to identify recurring patterns:

- Are the same constraints being violated repeatedly? That is a signal that the constraint needs a stronger enforcement mechanism -- promotion from agent to deterministic.
- Are violations clustered in a specific area of the codebase? That suggests the context document does not explain the rationale clearly enough for that area.
- Are constraints being violated despite clear documentation? That may indicate the constraint itself is wrong and needs to be reconsidered.

The auditor detects drift in both directions: constraints that are declared but not actually enforced (the tool is missing, the config is stale), and enforcement that exists but is not declared in `HARNESS.md` (a linter is running in CI but not listed as a constraint). Both directions represent a gap between what the team believes is true and what is actually true.

---

## The Feedback Loop

The complete self-improvement cycle has five stages:

**Work.** Agents and developers write code, guided by the current state of the habitat -- `CLAUDE.md`, `HARNESS.md`, `AGENTS.md`, and the constraint enforcement infrastructure.

**Reflect.** At the end of a session, the `/reflect` command captures what was surprising, what failed, what should change. If the reflection describes a preventable failure, a constraint is proposed.

**Curate.** Periodically, a developer reads recent reflections and promotes recurring patterns into `AGENTS.md` -- a new GOTCHA, a refined ARCH_DECISION, a TEST_STRATEGY update. Patterns that do not recur are left in the log without promotion.

**Promote.** Constraints that have proven their value at one enforcement level move up the [progressive hardening](progressive-hardening.md) ladder. An unverified constraint becomes agent-backed when a review prompt is written. An agent-backed constraint becomes deterministic when the pattern is understood well enough to encode as a script. The harness-audit agent identifies candidates for promotion by detecting recurring violations at a given level.

**Environment improves.** The updated `AGENTS.md` entries inform the next session's agents. The promoted constraints catch violations that previously slipped through. The new GC rules detect entropy that previously accumulated silently. The baseline is higher.

Then the cycle repeats. The work is better because the environment is better. The reflections are deeper because the basic mistakes have been eliminated. The curated entries are more subtle because the obvious patterns have already been captured. The constraints are tighter because the easy promotions have already happened.

This is why the learning compounds. Each pass through the loop raises the floor, which changes the character of the work, which changes the character of the observations, which changes the character of the improvements. The harness does not merely accumulate rules. It matures.

---

## Regression Detection

The append-only structure of `REFLECTION_LOG.md` makes it a natural source for regression detection. When the same failure appears in multiple reflections over time, that recurrence is a signal that the environment has not adequately addressed the underlying cause.

### Mining the Log

The harness-audit agent mines the log for recurring themes during its periodic runs. Two patterns trigger action:

**Repeated constraint violations.** If reflections mention the same constraint being violated across multiple sessions, the constraint's enforcement level is insufficient. An unverified constraint that keeps being violated needs agent enforcement. An agent-enforced constraint that keeps being violated needs deterministic enforcement -- or the rule itself needs to be rewritten to be clearer.

**Repeated entropy observations.** If reflections mention the same kind of drift -- documentation going stale in a particular area, dead code accumulating in a specific module, a naming convention eroding in new files -- that pattern suggests a missing or inadequate GC rule.

### The Regression Suite GC Rule

The GC agent has a specific responsibility: when running garbage collection, it reads the 10 most recent reflections and looks for entropy signals. Reflections that mention drift, staleness, or documentation rot are not merely interesting observations -- they are inputs to the GC agent's decision-making about where to focus its sweep.

If the GC agent finds that its declared rules do not cover a class of entropy that reflections keep mentioning, it reports that gap. The report becomes a prompt for the team to add a new GC rule, closing the loop between observation and enforcement.

---

## Bootstrapping

A self-improving harness needs a starting point. If the harness starts empty, the improvement loop has nothing to improve. If the harness requires weeks of manual configuration before it delivers value, teams will not adopt it.

### Harness-Init and Code Inference

The `/harness-init` command solves the cold-start problem. Rather than requiring the team to specify every convention and constraint from scratch, it dispatches a discovery agent to scan the existing codebase and infer what is already true:

- What tech stack and versions are in use
- What linters, formatters, and CI checks already exist
- What convention documentation is already written
- What pre-commit hooks are in place

The discoverer presents its findings and asks the developer to confirm, reject, or refine each inference. The human remains the authority -- the agent does the tedious work of reading the project and proposing a starting point. The initial cost of building the harness is substantially reduced because the agent bootstraps a candidate `HARNESS.md` from observed patterns rather than asking the developer to recall every convention from memory.

### Incremental Adoption

`/harness-init` supports selective feature configuration. Teams choose which areas to configure on the first run:

| Feature | What it configures |
| --- | --- |
| Context engineering | Stack declaration and conventions |
| Architectural constraints | Enforcement rules and secret detection |
| Garbage collection | Periodic entropy checks |
| CI configuration | GitHub Actions workflow and auto-enforcer |
| Observability | README badge and status section |

Unselected features are marked with a placeholder in `HARNESS.md`. Re-running `/harness-init` later detects which sections are already configured and which are not, defaulting to configuring only the unconfigured sections. Existing configuration is preserved across runs.

This means a team can start with just context engineering and constraints -- the two features that deliver the most immediate value. Once the value is proven, they add garbage collection and CI enforcement. The harness grows with the team's maturity rather than demanding full commitment upfront.

The incremental adoption model also means the feedback loop starts turning sooner. A team with just context and constraints can capture reflections, promote patterns to `AGENTS.md`, and experience the compound learning effect without needing the full infrastructure. Each feature they add later plugs into the existing loop and amplifies it.

---

## Further reading

- [Compound Learning](compound-learning.md) -- the introductory treatment: the Groundhog Day problem, raw reflections, curation, and the flywheel
- [Harness Engineering](harness-engineering.md) -- the full harness framework: context, constraints, garbage collection, and the three enforcement loops
- [HARNESS.md, the Document](harness-md.md) -- the central document the audit runs against; how it compares to `AGENTS.md`, CI config, and hooks
- [Progressive Hardening](progressive-hardening.md) -- the promotion ladder from unverified to agent to deterministic
- [The Three Enforcement Loops](three-enforcement-loops.md) -- inner, middle, and outer loops operating at different timescales
- [Garbage Collection](garbage-collection.md) -- fighting entropy with periodic checks and scheduled agents
- [Habitat Engineering](habitat-engineering.md) -- the broader environment that contains and shapes the harness
- [The Feedback Flywheel](https://martinfowler.com/articles/reduce-friction-ai/feedback-flywheel.html) -- Birgitta Boeckeler's framework for converting session-level learning into shared infrastructure through four signal types and four cadences
