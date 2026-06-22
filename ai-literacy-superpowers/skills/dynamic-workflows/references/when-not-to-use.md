# When *Not* to Use a Dynamic Workflow

A dynamic workflow spends more tokens and more wall-clock than a single
agent. It earns that cost only on tasks that genuinely need it. Most
coding tasks do not. This is the compute-discipline rubric (D8): the
mechanism that makes every workflow *elected*, not reflexive.

## The four-question election rubric

Before authoring a workflow, ask whether the task is any of:

1. **Long-running** — would a single context drift or run out of room
   before finishing? (Long repo scans, multi-stage migrations.)
2. **Massively parallel** — does it split into many independent units that
   could be checked at once? (One verifier per constraint, one reader per
   area.)
3. **Highly structured** — does it have a clear pipeline of stages with
   defined hand-offs, where isolating each stage in its own context helps?
4. **Adversarial** — does it benefit from a separate agent trying to
   refute the result? (Review, judging, self-preference-prone checks.)

**The default: if none of the four apply, use the static pipeline.** A
task that is an ordinary single-file change, a small fix, or a quick
lookup does not warrant a panel of subagents. Reaching for a workflow
anyway is over-orchestration — treated as a regression, because the
static pipeline must remain the default for ordinary work.

## How to decline

When a task fails the rubric, an agent should say so plainly and proceed
on the static path — "none of the four discriminators apply; this is a
routine change, so I am using the static pipeline rather than a workflow"
— and cite this file. Declining is the correct, expected outcome for the
common case, not a failure to be apologised for.

## When it *does* apply

If one or more questions apply, the task is a workflow candidate. Pick the
matching pattern from [`patterns.md`](patterns.md), set a token budget and
model tiering per the *workflow election* section of the project's
`MODEL_ROUTING.md`, and honour the two invariants in
[`governance.md`](governance.md) — above all INV-1: the workflow proposes,
it never writes a durable artefact.

> **Threshold note.** Some patterns (for example, switching the enforcer
> into fan-out mode) turn on once a count crosses a threshold. That a
> threshold exists is part of the rubric; its *numeric value* is decided
> per project in the slice that owns the behaviour, and is deliberately
> not fixed here.

## What this rubric is *not*

This is **advisory guidance an agent reads**, not a CI gate. The plugin
does not deterministically enforce "a workflow was elected, not
reflexive" — there is no check that fails a build for skipping the rubric.
The discipline lives in the agent's reasoning and in human review, in
keeping with "agents propose; humans curate."
