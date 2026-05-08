---
title: The Harness Tuning Loop
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 18
redirect_from:
  - /explanation/the-harness-tuning-loop/
  - /explanation/the-harness-tuning-loop.html
---

# The Harness Tuning Loop

> A harness improves over time through a specific sub-flow: surprises
> get captured as reflections, recurring patterns become candidate
> constraints, candidate constraints get promoted via
> `/harness-constrain`. This page is about that sub-flow.

For the broader picture, see [The Harness Lifecycle](the-harness-lifecycle.md).
This page goes deeper on the part of the lifecycle that turns
*lessons* into *enforcement*.

## The four stages

### 1. Capture — write the reflection

When a session ends with something surprising — a wrong assumption,
an unexpected gotcha, a workflow hole — the integration agent (or you,
running `/reflect`) appends an entry to `REFLECTION_LOG.md`. Each
entry has:

- A one-sentence task summary
- The surprise — what went wrong or wasn't expected
- A proposal — what could prevent this next time
- A signal — `failure`, `workflow`, `context`, or `none`
- An optional proposed constraint

`failure` and `workflow` signals are the ones that feed this loop.

### 2. Detect — let the GC rule find recurring patterns

The `Reflection-driven regression detection` GC rule runs weekly. It
scans `REFLECTION_LOG.md` for recurring failure patterns — the same
type of surprise across two or more entries. When it finds one, it
flags the pattern as a candidate constraint.

`/harness-sync`'s drift table includes these candidates as
`[manual]` rows. The action command suggested is `/harness-constrain`.

### 3. Promote — author the constraint

`/harness-constrain` is the authoring path. It loads the
`constraint-design` skill, which walks through:

- The rule itself (must be falsifiable)
- The enforcement level (`unverified`, `agent`, `deterministic`)
- The tool, if deterministic
- The scope (`commit`, `pr`, `weekly`, `manual`)

The constraint gets added to `HARNESS.md`. From that point forward
it appears in `/harness-sync`'s convention-file drift detection
(if it changes the conventions text) and in `/harness-audit`'s
enforcement-ratio reporting.

### 4. Verify — let the constraint catch real violations

The newly authored constraint enters the active enforcement set. Its
behaviour over the next few PRs is the test of whether the promotion
was correct:

- If it catches real instances of the original surprise, promotion
  was right.
- If it never fires, the underlying assumption may have been wrong —
  the surprise was a one-off, or the constraint's rule isn't falsifiable
  enough to detect the real pattern. Either way, future reflections
  will say so.
- If it fires on innocent code, the constraint is too strict; the
  next reflection should propose softening it.

## Why the loop is structured this way

The loop deliberately separates *capture* from *promotion*. Reflections
should be cheap — write them down without judgement. The judgement
happens later, with the benefit of recurrence. A single failure isn't
enough evidence to add a constraint; two related failures often is.

This is also why the GC rule fires weekly rather than on every
reflection. Reflection-time pattern matching would over-promote
(every surprise becomes a constraint). Aggregated weekly review
catches genuine recurrence.

## Where this fits in the lifecycle

This loop is one of the contributors to the "drifted → in sync"
transition described in [The Harness Lifecycle](the-harness-lifecycle.md).
A recurring pattern is a kind of drift between *what should be
constrained* and *what is constrained*. `/harness-constrain` is the
remediation; the GC rule and `/harness-sync` are the detection.

## Related reading

- [The Harness Lifecycle](the-harness-lifecycle.md) — the broader
  detect-heal-pull frame.
- [The Self-Improving Harness](self-improving-harness.md) — why
  iteration matters and how compound learning fits in.
- [How to: write a governance constraint](../how-to/write-a-governance-constraint.md)
  — the deeper case for governance-flavoured constraints.
- [How to: add a constraint](../how-to/add-a-constraint.md) — the
  step-by-step for `/harness-constrain`.
