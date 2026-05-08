---
title: Garbage Collection
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 12
redirect_from:
  - /explanation/garbage-collection/
  - /explanation/garbage-collection.html
---

# Garbage Collection

Entropy accumulates in any codebase over time: dead code, stale dependencies, abandoned conventions, TODO comments that outlive their relevance. Garbage collection in the harness engineering sense is the scheduled practice of declaring what "clean" looks like and running periodic checks to measure how far the codebase has drifted from that standard. GC rules do not block individual merges; they produce reports that draw attention to accumulating problems before they become costly to unwind.

For the conceptual case -- why entropy is inevitable, why AI accelerates it, and why periodic detection beats continuous checking -- see [Codebase Entropy](codebase-entropy.md). This page covers the mechanics: how GC rules are declared, what the built-in rules do, how the GC agent operates, and how to write your own rules.

---

## GC Rule Anatomy

Every garbage collection rule in `HARNESS.md` is a structured declaration with five fields. The format is consistent across all rules so that both humans and agents can parse them reliably.

```markdown
### Rule name

- **What it checks**: A concrete description of the entropy being detected.
  Specific enough that a reviewer could verify the check independently.
- **Frequency**: weekly | monthly | daily | manual
- **Enforcement**: deterministic | agent
- **Tool**: The command or agent that runs the check
- **Auto-fix**: true | false
```

Each field carries a specific design intent:

**What it checks** is the most important field. It defines the detection boundary. A vague description like "code quality" cannot be checked. A precise description like "whether README, HARNESS.md, and inline doc comments reference files, functions, or conventions that no longer exist" can be. The precision of this field determines whether the rule is useful.

**Frequency** sets the cadence. Different types of entropy operate at different speeds, so inspection frequency must match. See cadence matching below.

**Enforcement** declares whether the check is run by a deterministic tool (a script, a CLI command, a file date check) or by an agent that reads the description and uses judgement. Deterministic checks are faster and more reliable. Agent checks are necessary when the entropy cannot be detected mechanically.

**Tool** names the specific mechanism. For deterministic rules, this is a command that can be executed directly. For agent rules, this is typically `harness-gc agent`, which reads the "what it checks" description and scans the codebase accordingly.

**Auto-fix** controls what happens when the check finds something. When `true`, the GC agent applies the fix directly -- moving files, updating references, bumping versions -- and commits the result. When `false`, the agent creates a GitHub issue with file and line references and a suggested remediation. Auto-fix is appropriate only when the fix is deterministic, local, verifiable, and reversible. Fixes that require judgement, have ripple effects, or are destructive should always create issues instead.

---

## Built-in GC Rules

The `HARNESS.md` template ships with a set of default rules that cover the most common forms of codebase entropy. Each rule is active from the moment the harness is initialised. Teams can disable, modify, or extend them.

### Documentation freshness

- **What it checks**: Whether README, HARNESS.md, and inline doc comments reference files, functions, or conventions that no longer exist.
- **Frequency**: weekly
- **Enforcement**: agent
- **Auto-fix**: false

Documentation staleness is the most common form of entropy and the most dangerous, because stale docs are worse than no docs. A developer or AI that follows outdated guidance will produce code that conflicts with the current state of the codebase. This rule asks the GC agent to cross-reference documentation against the actual codebase and flag any references to things that no longer exist.

### Secret scanner operational

- **What it checks**: Whether gitleaks is installed and the "No secrets in source" constraint is still enforced as deterministic (not regressed to unverified).
- **Frequency**: weekly
- **Enforcement**: deterministic
- **Tool**: `gitleaks --version && gitleaks detect --source . --no-banner --exit-code 1`
- **Auto-fix**: false

This is a constraint-decay check. It does not look for secrets directly (that is the constraint's job). It checks whether the tool that looks for secrets is still installed and operational. Constraint decay -- the quiet disabling of enforcement mechanisms -- is one of the most insidious forms of entropy because a disabled check does not announce itself. It just stops catching things.

### Snapshot staleness

- **What it checks**: Whether the most recent harness health snapshot in `observability/snapshots/` is less than 30 days old.
- **Frequency**: weekly
- **Enforcement**: deterministic
- **Tool**: file date check
- **Auto-fix**: false

Health snapshots are the harness's own observability layer. If no snapshot has been generated in 30 days, the harness is operating without telemetry. This is a meta-check: it verifies that the observation infrastructure itself is being maintained.

### Command-prompt sync

- **What it checks**: Whether commands in `commands/` and their corresponding prompt files in `.github/prompts/` have diverged -- one modified without updating the other.
- **Frequency**: weekly
- **Enforcement**: agent
- **Auto-fix**: false

Commands and their corresponding prompt files are paired artefacts. When one is updated without the other, the prompt that GitHub Copilot or other tools see diverges from the command that Claude Code executes. This rule catches the divergence before it causes confusing behaviour.

### Dependency currency

- **What it checks**: Whether project dependencies have known vulnerabilities or are more than one major version behind latest.
- **Frequency**: weekly
- **Enforcement**: agent
- **Auto-fix**: false

Dependencies rot silently. Libraries get abandoned. CVEs get published. APIs change. This rule asks the GC agent to check whether the project's dependency tree contains known vulnerabilities or has fallen significantly behind current releases. The threshold of one major version is a reasonable default; teams with stricter requirements can tighten it.

### Convention file sync

- **What it checks**: Whether `.cursor/rules/`, `.github/copilot-instructions.md`, and `.windsurf/rules/` exist and reflect the current HARNESS.md conventions.
- **Frequency**: weekly
- **Enforcement**: agent
- **Auto-fix**: false

If the team uses multiple AI coding assistants, each assistant has its own convention file. These files must stay in sync with `HARNESS.md` as the source of truth. When they diverge, different assistants produce code that follows different conventions, accelerating convention drift.

### Observability archive

- **What it checks**: Whether snapshots older than 6 months exist in `observability/snapshots/` and should be moved to `observability/archive/`.
- **Frequency**: monthly
- **Enforcement**: deterministic
- **Tool**: file date check
- **Auto-fix**: true (move to archive directory)

This is the only built-in rule with auto-fix enabled. Moving old snapshots to an archive directory is deterministic (the criteria are date-based), local (no other file depends on the snapshot's location), verifiable (the file exists in the new location), and reversible (it can be moved back). It is a clean example of when auto-fix is appropriate.

### Reflection-driven regression detection

- **What it checks**: Whether REFLECTION_LOG.md contains recurring failure patterns (same type of surprise across 2+ entries) that are not yet covered by a HARNESS.md constraint.
- **Frequency**: weekly
- **Enforcement**: agent
- **Auto-fix**: false

This is a learning-driven GC rule. Most GC rules scan code for entropy. This rule scans the team's own reflections for patterns. When the same kind of surprise appears in two or more reflection entries without a corresponding constraint in `HARNESS.md`, the rule flags it. The signal is clear: the team keeps encountering the same problem, but the harness has not adapted to prevent it. The GC agent creates an issue proposing a new constraint, with evidence (reflection dates and quotes), a suggested enforcement type, and a suggested scope.

---

## Cadence Matching

Different types of entropy operate at different speeds. Matching inspection frequency to entropy rate is a design decision that affects both signal quality and noise levels.

### Weekly

Weekly is the default cadence for most GC rules. Documentation freshness, convention file sync, dependency currency, command-prompt sync, secret scanner operational, snapshot staleness, and reflection-driven regression detection all run weekly. These are entropy types that accumulate meaningfully over the course of a week's development activity but do not change fast enough to warrant daily checking.

Weekly checks produce a manageable volume of findings. A weekly GC run that surfaces three or four issues gives the team time to address them before the next run. A daily run surfacing the same findings repeatedly becomes noise.

### Monthly

Monthly cadence is for entropy that accumulates slowly. The observability archive rule runs monthly because snapshots do not age into the archive threshold (6 months) fast enough to justify weekly checking.

Constraint audits -- checking whether enforcement mechanisms are still active, whether tools are still installed, whether CI checks are still enabled -- are good candidates for monthly cadence if the team's CI pipeline is stable.

### Quarterly

The template does not include quarterly rules by default, but the cadence is appropriate for architectural fitness functions that measure system-wide properties: layer boundary compliance, coupling trends, complexity hotspot trajectories. These properties change slowly and require more expensive analysis to check.

### Daily

Daily cadence is rarely appropriate. The only scenario where it makes sense is a codebase with very high commit velocity where a specific type of entropy accumulates measurably within a single day. If you find yourself adding daily GC rules, consider whether the entropy would be better caught by a PR-time constraint instead.

### Choosing the right cadence

The principle is simple: the cadence should match the rate at which the entropy accumulates and the cost of letting it persist. If a week of drift is harmless, check weekly. If a month of drift is costly, check weekly. If a quarter of drift is harmless, check monthly. Start with weekly for any new rule and adjust based on what you observe.

---

## The GC Agent

The `harness-gc` agent is the mechanism that executes garbage collection. It is a bounded agent -- it has read and write access to the codebase, but it does not merge changes, does not push to remote, and does not modify production code without confirmation.

### What it reads

The agent reads three things before running any checks:

1. **HARNESS.md** -- specifically the Garbage Collection section. It parses every rule to extract the check description, frequency, enforcement type, tool command, and auto-fix setting.

2. **REFLECTION_LOG.md** -- the 10 most recent entries. Reflections that mention entropy, drift, or staleness are signals about where the codebase is degrading. These inform what the agent looks for beyond the declared rules.

3. **The codebase itself** -- for agent-enforced rules, the agent scans files, cross-references documentation, checks dependencies, and evaluates whatever the "what it checks" field describes.

### What it produces

For each rule, the agent produces one of three outcomes:

- **No findings.** The rule passes. The agent reports it as clean.
- **Findings with auto-fix false.** The agent creates a GitHub issue for each finding. Each issue includes the rule name, the specific finding, file and line references, and a suggested remediation.
- **Findings with auto-fix true.** The agent applies the fix directly. In interactive mode, it asks for confirmation before committing. It describes exactly what was changed and why.

After processing all rules, the agent produces a summary report:

```text
## Garbage Collection Results

### Documentation freshness -- 2 findings
- README.md:45 references parseConfig() which no longer exists
- HARNESS.md:12 lists Python 3.10 but go.mod shows no Python
Action: GitHub issues created (#42, #43)

### Dependency currency -- 1 finding
- package.json: lodash 4.17.20 has CVE-2021-23337 (high)
Action: GitHub issue created (#44)

### Convention file sync -- 0 findings
All convention files match HARNESS.md.

---
Summary: 3 checks, 3 findings, 0 auto-fixed, 3 issues created
```

### Trust boundary

The GC agent operates with bounded trust. It can read any file in the repository. It can write fixes for auto-fixable rules. It cannot merge, push, or deploy. It cannot modify `HARNESS.md` itself (that would allow the agent to relax its own constraints). It cannot disable other checks.

This boundary is deliberate. The agent is a reporter and fixer, not a decision-maker. Humans review its findings, decide which issues to address, and determine whether the harness itself needs to change.

---

## How GC Rules Are Triggered

Declaring a GC rule in `HARNESS.md` does not, by itself, cause the rule to run. Rules need an execution mechanism. The plugin provides three:

**Weekly CI workflow.** A scheduled GitHub Actions workflow (`gc.yml`) runs every Monday at 09:00 UTC. It executes all deterministic GC rules -- secret scanner operational, snapshot staleness, shell syntax checks, and strict mode checks. Deterministic rules are well-suited to CI because they require no LLM judgement and produce binary pass/fail results. The workflow can also be triggered manually via `workflow_dispatch`.

**Rotating Stop hook.** A session-end hook picks one deterministic GC rule per session (rotating by day-of-year) and runs it as a lightweight check. This ensures entropy is caught between weekly CI runs during active development. Each check runs in under five seconds and is advisory only -- it warns but does not block. The rotation means that over the course of a working week, all deterministic rules are checked at least once even if CI does not run.

**Manual invocation.** Agent-scoped GC rules (documentation freshness, command-prompt sync, convention file sync, plugin manifest currency, reflection-driven regression detection) require LLM judgement and cannot be automated with a shell script. These run when a user invokes `/harness-gc` or `/harness-health --deep`, which dispatches the GC agent to evaluate each rule.

The combination of scheduled CI, opportunistic session hooks, and on-demand agent runs means that deterministic rules are checked continuously while agent rules are checked periodically. This matches the enforcement model: deterministic checks are cheap and reliable enough to run often, while agent checks are expensive and should be reserved for deliberate review moments.

---

## Writing Custom GC Rules

The built-in rules cover common entropy types. Every codebase has its own entropy patterns. Writing custom GC rules follows the same pattern as the built-ins.

### Step 1: Identify the entropy

What drifts over time in this codebase? What have you noticed degrading during past code reviews, incident retrospectives, or reflection sessions? Common candidates:

- API documentation that falls behind the actual endpoints
- Feature flags that are never cleaned up after launch
- Test fixtures that reference data schemas from three migrations ago
- Environment variable documentation that does not match `.env.example`
- Migration files that are no longer referenced by the ORM

### Step 2: Describe the check

Write a "what it checks" description precise enough that a reviewer could verify the check independently. "Code quality" is too vague. "Whether all public API endpoints have a corresponding entry in `docs/api/`" is precise.

### Step 3: Choose frequency

How fast does this entropy accumulate? If the team adds new API endpoints weekly, check weekly. If environment variables change quarterly, check monthly.

### Step 4: Decide enforcement

Can a deterministic tool check this? File existence, date comparisons, dependency version checks, and structural assertions are all good candidates for deterministic enforcement. If the check requires understanding intent, cross-referencing prose, or evaluating "how much" something has drifted, it needs agent enforcement.

### Step 5: Apply the auto-fix rubric

Auto-fix is safe when the fix satisfies all four criteria:

- **Deterministic** -- there is exactly one correct fix
- **Local** -- the fix does not affect other files or systems
- **Verifiable** -- you can confirm the fix is correct after applying it
- **Reversible** -- the fix can be undone without data loss

If any criterion is not met, set auto-fix to false.

### Step 6: Add the rule to HARNESS.md

Add a new subsection under the Garbage Collection heading in `HARNESS.md`, following the five-field format. The rule is active immediately -- the next GC run will include it.

---

## GC vs Constraints

Garbage collection and constraints both fight entropy, but they operate at different scales and timescales. Understanding when to use each is important for harness design.

**Constraints** operate at the level of individual changes. They run at commit time or PR time. They ask: "Does this specific change violate a rule?" A constraint catches a developer (or AI) introducing a secret, breaking a naming convention, or bypassing a required abstraction. Constraints are preventive. They stop bad changes from landing.

**GC rules** operate at the level of the codebase over time. They run on a schedule. They ask: "Has the codebase drifted from its intended state?" GC catches problems that no single change causes -- the gradual staleness of documentation that was correct when written, the slow accumulation of unused dependencies that were each justified when added, the quiet disabling of enforcement mechanisms that happened one exception at a time.

The distinction maps to a familiar pattern in medicine. Constraints are like hygiene: practices that prevent contamination at the point of contact. GC is like a periodic health check: an examination that detects conditions that develop slowly and are invisible in daily life.

Some problems exist in both categories. Dependency management, for example, has a constraint dimension (do not add a dependency with a known CVE) and a GC dimension (have any existing dependencies developed CVEs since they were added?). The constraint catches the acute problem. The GC rule catches the chronic one.

A rule of thumb: if a single PR could cause the problem, it is a constraint. If no single PR causes the problem but the problem emerges over time, it is a GC rule.

---

## Reporting and Remediation

GC produces reports, not blocks. This is a deliberate design choice that distinguishes GC from constraints.

Constraints block progress. A failing constraint prevents a merge. This is appropriate because the constraint is evaluating a specific change that a specific person is responsible for, and the fix is usually within that person's control.

GC findings are different. The entropy they detect was not caused by any single person or any single change. Blocking progress on a finding that accumulated over weeks or months penalises whoever happens to trigger the check, not the people who contributed to the drift. This creates perverse incentives -- teams learn to avoid running GC rather than fixing the findings.

Instead, GC produces reports. Findings are surfaced as GitHub issues with clear descriptions, file and line references, and suggested remediations. The team triages these issues alongside other work. Urgent findings (a dependency with a critical CVE) get immediate attention. Non-urgent findings (a slightly outdated docstring) enter the normal backlog.

Over time, GC findings feed back into the harness itself. A GC rule that repeatedly finds the same type of drift is evidence that a constraint is missing. The team can respond by adding a PR-time constraint that prevents the drift from accumulating in the first place. This is how GC and constraints evolve together: GC detects patterns of drift, constraints prevent those patterns from recurring.

The reflection-driven regression detection rule embodies this feedback loop explicitly. It reads past reflections, identifies recurring patterns, and proposes new constraints. But any GC rule can drive the same evolution implicitly -- a finding that keeps reappearing is a signal that the harness needs to grow.

---

## Further reading

- [Codebase Entropy](codebase-entropy.md) -- the conceptual foundation: why entropy is inevitable, why AI accelerates it, and how GC fights it
- [Harness Engineering](harness-engineering.md) -- the three-component model that GC is part of, including context engineering and constraints
- [Three Enforcement Loops](three-enforcement-loops.md) -- how GC fits into the outer (scheduled) enforcement loop
- [Constraints and Enforcement](constraints-and-enforcement.md) -- the constraint side of the GC-vs-constraints distinction
- [Compound Learning](compound-learning.md) -- how reflections feed into learning-driven GC rules
