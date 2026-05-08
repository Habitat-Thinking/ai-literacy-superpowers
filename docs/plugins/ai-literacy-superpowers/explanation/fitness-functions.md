---
title: Fitness Functions
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 13
redirect_from:
  - /explanation/fitness-functions/
  - /explanation/fitness-functions.html
---

# Fitness Functions

Fitness functions are periodic, objective measurements of architectural health — metrics and checks that tell you whether the codebase still conforms to properties that matter to the team: dependency boundaries, test coverage thresholds, security posture, module coupling, and similar structural qualities. Unlike constraint enforcement that runs at PR time, fitness functions are designed to track trends over time and surface slow degradation that no single change causes but that cumulative change produces.

The concept originates from Ford, Parsons, Kua, and Sadalage's *Building Evolutionary Architectures* (O'Reilly, 2017/2022). Their central observation: architecture degrades not through single bad changes but through accumulated small violations. Each individual change looks reasonable in isolation. The damage is cumulative and invisible until it becomes painful. Fitness functions are the mechanism that makes the invisible visible.

---

## What Fitness Functions Are

A fitness function is a periodic, automated check that measures whether a system-wide architectural property still holds. It is not a test in the conventional sense. A test verifies that a specific behaviour works. A fitness function verifies that a structural property of the entire system -- a property that emerges from the interaction of many components -- remains within acceptable bounds.

Examples of the properties fitness functions track:

- Whether modules respect declared layer boundaries
- Whether coupling between components is increasing or stable
- Whether any files are becoming complexity hotspots -- high change frequency correlated with growing cognitive complexity
- Whether test coverage is declining in architecturally significant layers
- Whether dependency freshness is within budget

These checks are often too slow or expensive to run on every pull request. Full dependency graph analysis, coupling metric computation, and churn-complexity correlation require scanning the entire codebase and its history. But they are too important to skip entirely. Running them on a weekly schedule -- aligned with the outer enforcement loop's garbage collection cadence -- balances thoroughness against cost.

### The Difference from Constraints

Constraints and fitness functions are both harness enforcement, but they operate at different timescales and answer different questions.

A **constraint** gates an individual change. It runs at PR time and asks: "Does this specific change violate a rule?" A constraint that forbids UI code from importing database internals will catch the violation the moment someone writes the import. The scope is narrow: one change, one rule, one verdict.

A **fitness function** measures a system-wide property over time. It runs on a schedule and asks: "Has the system drifted from a property it should maintain?" A fitness function tracking coupling between two modules will not fire when any single import is added. It fires when the accumulated coupling across many changes crosses a threshold or shows a sustained upward trend. The scope is broad: the whole system, a measured trend, an interpreted signal.

| Aspect | Constraint | Fitness Function |
| --- | --- | --- |
| Scope | Per-change (commit or PR) | System-wide (weekly) |
| What it checks | This change violates a rule | The system has drifted from a property |
| Trigger | Code is written or merged | Scheduled GC run |
| Example | "This file imports from a forbidden layer" | "Coupling between modules A and B has increased 15% over 4 weeks" |
| Enforcement | Deterministic or agent | Deterministic (tool output) + agent (trend interpretation) |

Constraints answer: "Is this change OK?" Fitness functions answer: "Is the system still healthy?" Both are necessary. Constraints prevent known-bad changes. Fitness functions detect emergent degradation that no single change caused.

---

## The Four Categories

Fitness functions divide into four categories, each targeting a different dimension of architectural health.

### Structural

Structural fitness functions verify that code organisation respects declared architectural boundaries. These are the most binary of the four categories: a layer boundary is either respected or it is not.

**Layer boundary violations** detect imports that cross declared architectural boundaries. If the team has decided that UI code must not import from the database layer, a structural fitness function scans the entire import graph and reports any violations. Tools like dependency-cruiser, ArchUnit, import-linter, and go-cleanarch automate this check.

**Circular dependency detection** finds cycles in the module dependency graph. Circular dependencies create hidden coupling: changing module A requires changing module B, which requires changing module A. The cycle makes both modules harder to reason about, test, and deploy independently. Tools like dependency-cruiser and JDepend detect these cycles automatically.

**Import direction enforcement** verifies that imports flow in the intended direction. In a layered architecture, dependencies should point downward (controller depends on service, service depends on repository, not the reverse). When imports flow against the grain, the architecture's layering becomes decorative rather than structural.

Structural fitness functions are almost always deterministic. The tool produces a clear pass/fail result. No agent interpretation is needed. Either the boundaries are respected or they are not.

### Coupling

Coupling fitness functions track how tightly connected modules are and whether that coupling is changing over time. Unlike structural checks, coupling metrics are continuous rather than binary. A module is not "coupled" or "not coupled." It has a degree of coupling that can increase, decrease, or remain stable.

**Afferent and efferent coupling** measure how many modules depend on a given module (afferent coupling, Ca) versus how many modules it depends on (efferent coupling, Ce). A module with high afferent coupling is depended on by many others -- changes to it have wide ripple effects. A module with high efferent coupling depends on many others -- it is fragile because any of its dependencies can break it.

**The instability index** is the ratio Ce / (Ca + Ce). A module with an instability index near 1.0 is maximally unstable: it depends on many things and nothing depends on it. A module near 0.0 is maximally stable: many things depend on it and it depends on little. Neither extreme is inherently bad, but modules that are both highly important (high Ca) and highly unstable (high Ce) are architecturally fragile. These are the modules most likely to cause cascading failures when they change.

**Fan-in and fan-out** measure the number of incoming and outgoing dependencies at the module level. Modules with excessive fan-out are doing too much or know too much about the rest of the system. Modules with excessive fan-in are potential bottlenecks. Tracking fan-in and fan-out over time reveals whether the architecture is converging toward a healthy dependency structure or drifting away from one.

Coupling metrics require agent interpretation. A coupling score of 0.7 is not inherently good or bad. The fitness function's value lies in tracking the trend: is coupling increasing, stable, or decreasing? The agent compares the current snapshot against previous snapshots and interprets whether the direction is healthy.

### Complexity and Hotspots

Complexity fitness functions find files where growing complexity correlates with high change frequency -- the "hotspot" pattern from Adam Tornhill's *Your Code as a Crime Scene* and the code-maat/CodeScene approach.

**Cognitive complexity** measures how difficult a piece of code is for a human (or AI) to understand. Unlike cyclomatic complexity, which counts execution paths, cognitive complexity penalises nesting, non-linear control flow, and breaks in the reading sequence. A file with rising cognitive complexity is becoming harder to work with, which means changes to it are more likely to introduce bugs.

**File size growth** tracks files that are expanding beyond a threshold. A file that grows continuously is often accumulating responsibilities that should be separated. Size alone is a weak signal, but combined with complexity it becomes meaningful.

**Churn-complexity correlation** is the most powerful signal in this category. It identifies files that change often AND are complex. A complex file that never changes is stable technical debt -- unpleasant but not actively dangerous. A simple file that changes often is fine -- it is easy to work with. But a file that is both complex and frequently modified is an active hotspot: every change to it carries elevated risk, and it demands changes often. These hotspots deserve priority attention for refactoring.

The churn-complexity analysis works by combining two data sources: git log (to measure how often each file has changed over a time window) and a complexity tool (to measure each file's current complexity score). Files that appear in the upper-right quadrant -- high churn and high complexity -- are the hotspots. Tracking the number and severity of hotspots over time tells you whether the codebase is becoming more or less maintainable.

### Coverage and Quality

Coverage fitness functions verify that testing effort is distributed appropriately across the architecture.

**Test coverage per architectural layer** detects layers where coverage is declining. Overall coverage numbers can mask problems: if coverage is rising in the UI layer but falling in the domain layer, the aggregate number looks stable while the most architecturally significant code is becoming undertested. Layer-level coverage tracking reveals these imbalances.

**Mutation testing kill rate** measures whether tests are actually catching bugs, not just exercising code. A test suite with 90% line coverage can still have a 60% mutation kill rate, meaning 40% of introduced mutations -- small, realistic bugs -- survive without any test failing. The mutation kill rate is a more honest measure of test effectiveness than coverage alone.

**Documentation coverage** tracks whether public APIs, architectural decisions, and key interfaces have accompanying documentation. This matters especially in AI-assisted environments: if a module's intent is undocumented, an AI agent working in that area has no context to guide its decisions.

Coverage fitness functions combine deterministic measurement (coverage tools produce exact numbers) with agent interpretation (deciding whether a decline is noise or a trend worth acting on).

---

## Fitness Functions vs GC Rules

Both fitness functions and [garbage collection](garbage-collection.md) rules are periodic checks that run in the outer enforcement loop. They share a cadence (typically weekly), a reporting mechanism (snapshots and issues rather than PR blocks), and a home in HARNESS.md's GC section. But they serve different purposes.

**Fitness functions measure trends against thresholds.** They ask: "Is this metric within bounds? Is the trend healthy?" A coupling fitness function measures coupling this week, compares it to last week and the week before, and reports whether the trajectory is stable, improving, or degrading. The output is a measurement and a trend interpretation.

**GC rules detect specific types of drift.** They ask: "Has this specific thing degraded?" A GC rule checking for stale TODO comments scans the codebase for TODOs older than a threshold and reports what it finds. The output is a list of violations. There is no trend to track -- the TODOs are either there or they are not.

The distinction matters for how results are interpreted. A fitness function that reports a single bad reading is reporting noise -- one week of slightly higher coupling is not meaningful. A fitness function that reports three consecutive weeks of increasing coupling is reporting a signal. GC rules do not have this temporal dimension. A stale dependency is stale regardless of how long it has been stale.

In practice, every fitness function is declared as a GC rule in HARNESS.md because the GC system provides the scheduling infrastructure. But fitness functions carry additional metadata: the previous snapshot values, the trend direction, and the threshold that separates "acceptable" from "concerning."

---

## Implementation

### Declaring Fitness Functions

Each fitness function is declared as a GC rule in the `## Garbage Collection` section of HARNESS.md. A deterministic fitness function specifies the exact tool command:

```markdown
### Layer boundary compliance

- **What it checks**: Whether modules respect declared architectural
  boundaries (no imports from forbidden layers)
- **Frequency**: weekly
- **Enforcement**: deterministic
- **Tool**: npx dependency-cruiser --validate .dependency-cruiser.js src/
- **Auto-fix**: false
```

An agent-interpreted fitness function delegates trend analysis to the GC agent:

```markdown
### Coupling trend

- **What it checks**: Whether inter-module coupling metrics have
  increased since the last snapshot
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent (using dependency-cruiser metrics output
  or custom coupling script)
- **Auto-fix**: false
```

Most fitness functions set **auto-fix to false**. Architectural issues require human judgement about the right solution -- splitting a module, introducing an interface, restructuring layers. The GC agent creates an issue instead of attempting a fix.

### CI Integration

Fitness functions integrate with CI through scheduled workflow runs. A weekly mutation testing job, for example:

```yaml
name: Weekly Fitness Functions
on:
  schedule:
    - cron: '0 6 * * 1'  # Every Monday at 06:00 UTC
  workflow_dispatch: {}

jobs:
  fitness-functions:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for churn analysis
      - name: Run fitness function suite
        run: |
          # Layer boundary check
          npx dependency-cruiser --validate .dependency-cruiser.js src/
          # Coupling metrics snapshot
          npx dependency-cruiser --output-type metrics src/ > metrics.json
          # Churn-complexity analysis
          git log --format=format: --name-only --since="4 weeks ago" | sort | uniq -c | sort -rn > churn.txt
```

The full git history (`fetch-depth: 0`) is necessary for churn analysis. The job runs on a schedule rather than on push, keeping PR pipelines fast.

### Integration with the Outer Enforcement Loop

Fitness functions sit in the [outer enforcement loop](three-enforcement-loops.md) -- the investigative loop that runs on a schedule and produces reports rather than blocks. The outer loop's GC agent reads the fitness function declarations from HARNESS.md, runs each tool, compares results against previous snapshots, and writes findings into the health snapshot.

When a fitness function detects sustained degradation, the agent creates a GitHub issue with the trend data. This issue may eventually lead to a new constraint in HARNESS.md's Constraints section -- a per-PR check that prevents the specific violation pattern from recurring. This is the reverse of the normal [progressive hardening](progressive-hardening.md) ladder: instead of unverified to agent to deterministic, it is periodic observation to targeted constraint.

---

## Interpreting Results

Fitness functions produce trend data, not pass/fail verdicts. A single reading is a data point. A sequence of readings is a signal.

| Trend | Interpretation | Action |
| --- | --- | --- |
| Stable or improving | The architecture is holding | No action -- record the snapshot |
| Slow decline (1-2 snapshots) | Early warning -- worth watching | Note in the snapshot, no issue yet |
| Sustained decline (3+ snapshots) | Active degradation | Create an issue with the trend data |
| Sudden spike | Likely a specific recent change | Investigate the commits since last snapshot |

### Setting Thresholds

Thresholds are project-specific. There is no universal "correct" coupling score or complexity limit. The process for setting thresholds is empirical:

1. Run the fitness function against the current codebase to establish a baseline
2. Observe the readings over several weeks to understand the natural variance
3. Set the threshold at a level that captures genuine degradation without triggering on normal fluctuation
4. Adjust as the project matures -- early-stage projects have more variance than stable ones

A threshold set too tight produces false alarms that train the team to ignore the fitness function. A threshold set too loose misses real degradation. Start loose and tighten as you accumulate data.

### What "Good" Looks Like

- **Layer boundary violations**: zero. This is binary -- either boundaries are respected or they are not.
- **Coupling metrics**: stable or decreasing over time.
- **Complexity hotspots**: the number of files in the "high churn + high complexity" quadrant is stable or decreasing.
- **Coverage per layer**: stable or increasing, with no layer dropping below a project-defined threshold.
- **Mutation kill rate**: stable or increasing. A declining kill rate means new code is being added with weaker tests.

---

## Complexity Hotspot Detection

The churn-times-complexity analysis deserves special attention because it produces the highest-signal findings of any fitness function category.

The insight behind hotspot detection is that neither complexity nor change frequency is dangerous alone. A complex file that never changes is stable debt. A simple file that changes constantly is easy to modify. But a file that is both complex and frequently modified is actively dangerous: it demands attention often, and every time someone works in it the complexity makes mistakes more likely.

The analysis combines two data sources:

**Git churn** is extracted from `git log`. For each file, count the number of commits that touched it over a rolling window (typically four weeks). Files with high churn are the files the team is actively working in.

**Cognitive complexity** is measured by a static analysis tool appropriate to the language (eslint's complexity rule, SonarQube, or custom scripts). Each file receives a complexity score that reflects how difficult it is to understand.

Plotting these two dimensions produces a scatter chart with four quadrants:

- **Low churn, low complexity**: healthy code. No action needed.
- **Low churn, high complexity**: stable debt. Monitor but do not prioritise.
- **High churn, low complexity**: active but manageable. No action needed.
- **High churn, high complexity**: hotspots. These files deserve refactoring attention.

The fitness function tracks the hotspot quadrant over time. If the number of hotspots is growing, the codebase is becoming harder to maintain. If the number is shrinking, refactoring efforts are paying off. A single file moving into the hotspot quadrant is a signal worth investigating. A file that has been in the hotspot quadrant for months is a priority for structural improvement.

---

## Dependency Age Budget (Libyear)

Dependency freshness is an architectural property that degrades silently. Individual dependencies go stale one at a time. No single stale dependency is alarming. But the cumulative staleness of all dependencies -- measured as the total number of years behind the latest releases -- is a meaningful signal.

**Libyear** is the metric: for each dependency, calculate the difference in years between the version in use and the latest available version, then sum across all dependencies. A project with a libyear of 5 has dependencies that are collectively five years behind current. A project with a libyear of 50 has a serious freshness problem.

The value of libyear as a fitness function is that it reduces a complex, multi-dimensional problem (dozens of dependencies, each with its own update cadence) to a single number that can be tracked over time. A rising libyear means the project is falling further behind. A stable libyear means the team is keeping pace with upstream releases. A declining libyear means the team is actively catching up.

### Setting a Budget

A libyear budget is a threshold the team sets based on their risk tolerance. A strict budget (libyear under 5) means aggressive dependency updates. A relaxed budget (libyear under 20) means updates happen less frequently but the project stays within a reasonable window of current.

The budget should account for the project's dependency profile. A project with three dependencies can maintain a libyear under 1. A project with two hundred dependencies will struggle to stay under 5. The budget is a commitment to a rate of freshness, not an absolute standard.

When the fitness function detects that libyear has exceeded the budget, the GC agent creates an issue listing the most stale dependencies in order of contribution to the total. This gives the team a prioritised list: updating the single most stale dependency may reduce the libyear by several points.

---

## Further Reading

- [Harness Engineering](harness-engineering.md) -- the three-component model that fitness functions extend
- [Garbage Collection](garbage-collection.md) -- the scheduling and reporting infrastructure fitness functions run within
- [The Three Enforcement Loops](three-enforcement-loops.md) -- how the outer loop accommodates periodic fitness function checks
- [Progressive Hardening](progressive-hardening.md) -- the promotion ladder, and how fitness function findings can become per-PR constraints
- [Codebase Entropy](codebase-entropy.md) -- the broader problem of accumulated degradation that fitness functions are designed to detect
- [Constraints and Enforcement](constraints-and-enforcement.md) -- the per-change enforcement model that fitness functions complement
