---
title: The Three Enforcement Loops
---
# The Three Enforcement Loops

The plugin structures verification into three loops — inner, middle, and outer — that operate at different timescales and with different tolerances for friction. The inner loop runs at edit time and is advisory, surfacing issues as suggestions without blocking work. The middle loop runs at PR time and is strict, with the authority to block a merge until failures are addressed. The outer loop runs on a schedule and is investigative, producing reports that feed back into the harness rather than blocking any single piece of work.

The [introductory page on constraints and enforcement](constraints-and-enforcement.md) explains why enforcement timing matters as much as enforcement strictness. This page goes deeper into the mechanics: what each loop actually runs, how the loops interact, and how to decide which loop a new constraint belongs in.

---

## The Inner Loop (Edit Time / Advisory)

The inner loop runs while you are working. Its job is to make problems visible early, while the context of the change is still fresh in your mind. It never blocks. It nudges.

### What runs

The inner loop is implemented as Claude Code hooks — lightweight checks that fire on specific tool events during a coding session. The plugin registers two hook events:

**PreToolUse: Edit-time checks.** Every time Claude invokes the `Write` or `Edit` tool, two hooks run in parallel. A prompt-based hook reads the Constraints section of `HARNESS.md`, identifies any constraints scoped to `commit`, and evaluates whether the file being written or edited would violate them. A deterministic command hook runs `markdownlint` on `.md` files, catching formatting issues that the prompt-based check might miss. Both hooks return warnings without blocking the write. They surface issues so that you — or the AI — can address them before the change goes further.

**Stop: End-of-session checks.** When a Claude session ends, seven scripts run in sequence:

- **Drift check** — examines the most recent commit for changes to CI workflows, linter configs, hook configs, or dependency manifests. If any of these changed, the harness itself may need updating. The script outputs a nudge to run `/harness-audit`.
- **Snapshot staleness check** — looks at the most recent health snapshot in `observability/snapshots/`. If the snapshot is older than 30 days, it suggests running `/harness-health` to update the baseline.
- **Reflection prompt** — counts commits made in the last four hours. If work happened, it nudges you to run `/reflect` so that learnings are captured before they evaporate.
- **Framework change prompt** — detects modifications to framework-level files and prompts for a review of whether the change was intentional.
- **Secrets check** — scans for accidentally committed secrets or credentials.
- **Rotating GC check** — picks one deterministic GC rule per session (rotating by day-of-year) and runs a fast check. This catches entropy between the weekly scheduled CI runs, ensuring that garbage collection is not purely periodic but also opportunistic during active development.
- **Curation nudge** — compares the number of entries in `REFLECTION_LOG.md` against the curated entries in `AGENTS.md`. If reflections are piling up without promotion, it nudges you to review and curate. This closes the gap in the compound learning lifecycle where reflections are captured but never read.

### Why advisory, not strict

The inner loop operates during the creative phase of work. Strict blocking at edit time interrupts flow, generates frustration, and trains developers to work around the system rather than with it. Advisory feedback respects the developer's judgment: you see the warning, you decide whether to act on it now, later, or not at all.

This is a deliberate design trade-off. The inner loop accepts a higher rate of missed violations in exchange for lower friction. The middle loop exists precisely to catch what the inner loop surfaces but does not enforce.

{: .note }
> The inner loop is also the cheapest place to catch problems. A violation detected at edit time costs seconds to fix. The same violation detected at PR time costs minutes of CI pipeline and context-switching. The inner loop's value is not in its enforcement power but in its proximity to the moment of creation.

---

## The Middle Loop (Merge Time / Strict)

The middle loop runs when code attempts to enter the main branch. It has the authority to say no. Nothing merges until the middle loop passes.

### What runs

The middle loop is implemented as CI gates on pull requests. The plugin provides a GitHub Actions workflow template (`ci-github-actions.yml`) that enforces PR-scoped constraints from `HARNESS.md` against changed files. This template is the skeleton; as constraints are promoted to deterministic enforcement, their tool invocations are added as steps in the workflow.

Beyond deterministic checks, the middle loop includes agent-based review. The orchestrator agent coordinates a pipeline that runs through these stages:

1. **Spec verification** — the spec-writer agent confirms that any behavioural change has a corresponding spec update.
2. **Test verification** — the TDD agent confirms that new behaviour has failing tests before implementation, and that all tests pass after.
3. **Code review** — the code-reviewer agent examines implementations against the project's constraints, conventions, and CUPID properties. If it finds issues, it sends the code back to the implementer. This review-fix cycle repeats up to three times before escalating to a human.
4. **Integration** — the integration-agent updates the changelog, commits, opens the PR, and watches CI. It does not merge until all checks are green.

### What blocks and what does not

Deterministic checks — linters, formatters, type checkers, structural tests — produce binary pass/fail results. A failure blocks the merge unconditionally. There is no override mechanism short of removing the check.

Agent-based reviews produce findings that the orchestrator must resolve. The orchestrator dispatches fixes and re-runs the review. If three cycles do not resolve the findings, the orchestrator escalates to the human rather than forcing the merge or looping indefinitely. This bounded-trust design prevents agent disagreements from deadlocking the pipeline while keeping humans as the final authority.

{: .warning }
> A common mistake is putting a new, untested constraint directly into the middle loop. The first developer to hit it on a Friday afternoon will override it, and that override becomes the new convention. New constraints should start in the inner loop (advisory) and graduate to the middle loop only after they have proven their value and precision. This is the [progressive hardening](progressive-hardening.md) principle.

### The orchestrator's role

The orchestrator agent is the entry point for the middle loop. It does not write code, edit specs, or create commits. It coordinates the specialist agents in sequence, maintains a context object that passes between them, and enforces the pipeline's control flow — including the plan approval gate that requires human sign-off before implementation begins.

The orchestrator reads `REFLECTION_LOG.md` at the start of every pipeline run. If past reflections mention failures in the area being worked on, the orchestrator adjusts its strategy — dispatching deterministic checks earlier, briefing subagents about known pitfalls, or tightening the review criteria. This is one of the channels through which compound learning feeds into enforcement.

---

## The Outer Loop (Scheduled / Investigative)

The outer loop runs on a schedule — daily, weekly, or whatever cadence the team has chosen for each rule. It does not respond to individual changes. It responds to the passage of time.

### What runs

Three categories of check live in the outer loop:

**Garbage collection rules.** Declared in the Garbage Collection section of `HARNESS.md`, these are periodic sweeps for entropy that neither the inner loop nor the middle loop can catch. Documentation staleness, dead code accumulation, abandoned conventions, dependency currency — these are problems that no single commit causes but that cumulative time produces. The `harness-gc` agent reads each GC rule, runs its check (deterministic or agent-based), and either auto-fixes the issue or creates a GitHub issue describing it.

**Harness audits.** The `harness-auditor` agent performs a meta-verification: does `HARNESS.md` still match reality? For each deterministic constraint, it checks whether the backing tool is actually installed and configured. It scans for undeclared enforcement — linters or CI checks that exist in the project but are not listed in the harness. It calculates the enforcement ratio, updates the Status section of `HARNESS.md`, and reports drift in both directions (declared but missing, present but undeclared).

**Fitness functions.** These are objective measurements of architectural health — dependency boundaries, test coverage thresholds, security posture, module coupling. Unlike constraint enforcement, fitness functions track trends over time. A single measurement is informative; a sequence of measurements reveals whether the codebase is improving, stable, or degrading. See [Fitness Functions](fitness-functions.md) for details.

### Why periodic beats continuous

Some properties of a codebase are invisible at the granularity of a single change. Test coverage dropping from 85% to 84% in one PR is not alarming. Test coverage dropping from 85% to 72% over three months is a crisis — but no individual PR caused it. The outer loop exists to detect these slow trends.

Running these checks on every PR would be expensive, slow, and noisy. A weekly GC sweep that produces a clear report is more useful than a per-PR check that produces a marginal data point and slows down every merge. The outer loop is optimised for signal quality over response time.

### How reports feed back

The outer loop produces reports, not blocks. But those reports are not just for human consumption. The harness-auditor updates the Status section of `HARNESS.md`, which every agent reads before starting work. The GC agent creates GitHub issues that enter the team's backlog. Fitness function trends are recorded in health snapshots that the orchestrator consults when planning pipeline runs.

The outer loop's output is input to the other two loops. A GC finding about documentation staleness may lead to a new constraint in `HARNESS.md`, which the inner loop will then check at edit time and the middle loop will enforce at PR time. This is the feedback mechanism that prevents the outer loop from becoming a report that nobody reads.

---

## How the Loops Interact

The three loops are not independent systems that happen to coexist. They form a feedback cycle where each loop's output improves the others.

### Inner to middle

The inner loop catches issues early and gives developers a chance to fix them before the middle loop even runs. When the inner loop is working well, the middle loop sees fewer violations — its CI gates pass more often, its agent reviews find fewer problems, and the overall merge velocity increases. The inner loop is a filter that reduces the load on the middle loop.

### Middle to outer

The middle loop generates data. Every PR that passes or fails, every agent review finding, every CI gate result is a data point. The outer loop reads this history. The harness-auditor looks for patterns: are the same constraints being violated repeatedly? If so, that is a signal. Maybe the constraint needs stronger enforcement. Maybe the context document does not explain the rationale clearly enough. Maybe the constraint itself is wrong.

### Outer to inner and middle

The outer loop's findings feed back as changes to `HARNESS.md`. A new constraint added by the team after a GC finding immediately becomes visible to the inner loop's PreToolUse hook (which reads the Constraints section on every write) and to the middle loop's CI gates (which enforce PR-scoped constraints). The outer loop improves the other loops by updating the document they enforce.

### The reflection channel

Reflections captured at session end (prompted by the inner loop's Stop hook) accumulate in `REFLECTION_LOG.md`. The orchestrator reads recent reflections before starting a pipeline run (middle loop). The GC agent reads reflections when running entropy checks (outer loop). Reflections are the mechanism that carries learning from the inner loop's moment-of-work observations into the broader enforcement system.

```text
Inner loop                Middle loop               Outer loop
(edit time)               (merge time)              (scheduled)
    |                         |                         |
    |--- warnings ---------->|                          |
    |                         |--- violation data ----->|
    |                         |                         |
    |<--- new constraints ---|<--- updated HARNESS.md --|
    |                         |                         |
    |--- reflections ------->|--- reflections -------->|
```

---

## Choosing the Right Loop

When you add a new constraint, the question of which loop it belongs in is a design decision with consequences. The wrong loop either fails to catch problems or creates friction that erodes trust.

### Put it in the inner loop when

- The constraint is new and untested — you want to observe how it behaves before giving it blocking authority.
- The constraint is about style or convention — something that benefits from early visibility but should not block a merge if occasionally violated.
- The constraint can be checked quickly (under 30 seconds) — slow inner-loop checks interrupt flow and defeat the purpose.
- You want the developer to have agency over when and how to address the issue.

### Put it in the middle loop when

- The constraint has been battle-tested in the inner loop and you are confident in its precision.
- The constraint protects an architectural boundary — something where a violation reaching `main` would cause real damage.
- The constraint can be expressed deterministically — a linter rule, a type check, a structural assertion — or has a reliable agent-based review.
- The cost of a false positive (blocking a valid PR) is lower than the cost of a false negative (letting a violation through).

### Put it in the outer loop when

- The constraint is about trends, not individual changes — coverage thresholds, dependency freshness, documentation currency.
- The constraint requires scanning the entire codebase, not just changed files — dead code detection, convention drift analysis.
- The constraint produces a report that is more useful than a gate — something the team discusses in a weekly review rather than acts on immediately.
- The check is expensive to run — full dependency audits, comprehensive security scans, cross-module coupling analysis.

### When in doubt

Start in the inner loop. A constraint that nudges at edit time and does no harm is strictly better than a constraint that blocks at merge time and turns out to be wrong. You can always promote a constraint to a stricter loop. Demoting one — after developers have learned to distrust it — is much harder.

---

## Further Reading

- [Constraints and Enforcement](constraints-and-enforcement.md) — the introductory concepts of constraint maturity and enforcement timing
- [Progressive Hardening](progressive-hardening.md) — the promotion ladder from unverified to deterministic
- [Harness Engineering](harness-engineering.md) — the three components (context, constraints, GC) and how this plugin implements them
- [Garbage Collection](garbage-collection.md) — detailed mechanics of entropy-fighting rules
- [Fitness Functions](fitness-functions.md) — periodic architectural health measurements
- [The Self-Improving Harness](self-improving-harness.md) — how reflections and audit history close the learning loop
- [Codebase Entropy](codebase-entropy.md) — the drift that enforcement loops exist to fight
