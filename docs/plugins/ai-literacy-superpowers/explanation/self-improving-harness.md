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

> A harness that doesn't evolve becomes a museum exhibit. The
> conventions that worked last quarter may not work this quarter.
> The constraints that mattered when the team was small may be
> ceremony when the team is large. The harness has to keep up — and
> the cheapest way to do that is to make every session a contribution.

## Why iteration matters

The conventions captured in HARNESS.md were correct *when they were
written*. The codebase changes; the team changes; tooling changes;
expectations change. Without a path for the harness to evolve in
response, three failure modes appear:

- **Drift** — what's enforced no longer matches what should be enforced.
  Either too strict (ceremony) or too lax (escape hatches). Either
  way, trust in the harness erodes.
- **Calcification** — the team stops pushing back on bad rules
  because the rules are "what we do." Conventions become identity
  rather than judgement.
- **Stagnation** — patterns the team has actually learned in the
  trenches never make it into the harness, because no one writes
  them down. Knowledge stays in heads.

The cure is to make every session a chance for the harness to
update.

## How sessions become contributions

The plugin shapes sessions so that lessons accumulate without
requiring a separate "process":

- **`/reflect`** captures one session's surprise, classified by
  signal (`failure`, `workflow`, `context`, `none`). Cheap to write,
  cheap to merge via PR.
- **`REFLECTION_LOG.md`** is the running journal. Most entries stay
  there forever as historical record.
- **The `Reflection-driven regression detection` GC rule** fires
  weekly to find recurring patterns — the signal that a one-off
  surprise has become a class of surprise.
- **`/harness-sync`** surfaces those recurring patterns in its drift
  table as `[manual]` candidate-constraint rows.
- **`/harness-constrain`** authors the new constraint when the
  pattern warrants it.
- **`AGENTS.md`** is the curated subset — the lessons the team has
  decided are part of the project's identity, not just the log.

Every session contributes raw material. The aggregating mechanisms
(GC rule, sync, constrain) turn that into structured, enforced
knowledge over time.

## The compound-learning principle

Two ideas underlie this:

**Lessons compound.** A team that captures lessons consistently is
strictly better off than a team that doesn't, regardless of which
specific lessons. The activation cost of `/reflect` (write three
lines) is low enough that it's worth doing for every session — the
compound effect over a year of sessions is large.

**Curation is human.** The plugin captures aggressively (every
reflection is appended) but promotes conservatively (only patterns
recurring twice or more become constraints, only after the GC rule
finds them, only after a human runs `/harness-constrain`). This
asymmetry is deliberate. False captures cost nothing; false promotions
add ceremony. The harness errs on the side of capturing too much and
promoting too little.

## What "self-improving" actually means

It does not mean the harness rewrites itself autonomously. Every
mutation is human-initiated:

- A reflection is written by a human (or by an agent the human
  reviews).
- A constraint is promoted by a human running `/harness-constrain`.
- A template upgrade is accepted by a human running `/harness-upgrade`.

It means the harness has the *machinery* for evolution wired in: the
journal, the recurrence detector, the promotion path, the curation
target. Without that machinery, evolution requires a separate
discipline that can be skipped under pressure. With it, evolution is
a side effect of normal work.

## Where this fits in the lifecycle

The self-improving aspect is the long-arc view of the
"drifted → in sync" transition described in
[The Harness Lifecycle](the-harness-lifecycle.md). What looks like
drift in one session is signal for the next session's improvement.

## Related reading

- [The Harness Lifecycle](the-harness-lifecycle.md) — the everyday
  three-state model.
- [The Harness Tuning Loop](the-harness-tuning-loop.md) — the focused
  signal-capture → constraint-promotion sub-flow.
- [Compound Learning](compound-learning.md) — the deeper conceptual
  background on why lessons compound.
