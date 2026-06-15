---
title: Explore the scope and impact of a change
---
# Explore the scope and impact of a change

You are about to make a change to a codebase, and before you touch
anything you want to understand it: **which part of the system does this
change touch, how does that part actually flow, and which bits will I end
up editing?** This tutorial walks you through that, end to end, using the
`diagnostic-legibility` plugin's key workflow — the `/pipeline-map`
command.

By the end you will have generated, for a change of your choosing, a
self-contained HTML map that shows:

- **the scope** — the bounded slice of the system the change touches, and
  what was deliberately left out;
- **the flow** — how control actually moves through that slice (steps,
  decisions, branches, outcomes);
- **the impact** — a *prediction* of which nodes you will modify and where
  you will insert new ones.

It takes about fifteen minutes. You will run two commands and read two
maps.

---

## Prerequisites

You need Claude Code installed and working. If `claude` does not yet run
in your terminal, follow
[Anthropic's Claude Code installation guide](https://docs.anthropic.com/en/docs/claude-code)
and come back.

You also need a **git repository to try this on** — ideally one you know
reasonably well, so you can sanity-check what the map tells you. Any
language is fine; the agent reads code with `Read`/`Glob`/`Grep`, it does
not run or build anything.

The **first** map you generate needs network access for a moment (the
command fetches a pinned, checksum-verified Mermaid bundle once and caches
it locally). Every map after that works offline.

---

## Step 1: Install the plugin

From any terminal:

```bash
claude plugin marketplace add Habitat-Thinking/ai-literacy-superpowers
claude plugin install diagnostic-legibility
```

Claude Code registers the plugin in every session. You should see the
`/pipeline-map` and `/diagnose` commands become available.

---

## Step 2: Choose a change to explore

The workflow starts from a **task** — a plain-English description of the
work you are considering. You state *intent*, not a code area; the plugin
works out the area for you.

For this tutorial, pick a real change you might make to your repo. A good
task names a thing and where it goes, for example:

- `"add a rate-limit check before the login handler"`
- `"add a fraud-hold step after risk evaluation"`
- `"change the cache eviction policy in the report service"`

Throughout this tutorial we use the example
`"add a fraud-hold step after risk evaluation"`. **Substitute your own
task wherever you see it.**

> **Tip.** Keep the task to one coherent change. The map traces *one
> dominant process per task* — "add X and also refactor Y and rename Z"
> will give you a blurrier result than three separate runs.

---

## Step 3: Map the scope and the flow

Open Claude Code in your repository and run:

```text
/pipeline-map "add a fraud-hold step after risk evaluation"
```

The command drives the whole pipeline for you — it resolves the bounded
scope, traces the control flow inside it, and cross-checks the result —
then renders a single self-contained HTML file and shows you a summary
like this before writing anything:

```text
Pipeline map ready to write: diagnostic-legibility/output/add-a-fraud-hold-step-pipeline-2026-06-15.html
Task: add a fraud-hold step after risk evaluation
Scope confidence: medium   In-scope: 4   Adjacent-excluded: 2
Stages: 6   pipeline_cross_check_status: completed   cross_check_status: completed
Mermaid: mermaid@11.6.0 (SHA-256 verified, inlined; no CDN)
Write this map? (accept / abort)
```

Type `accept`. The command writes the `.html` file and tells you the path.

> **Nothing is written until you accept.** If the summary looks wrong
> (way too many in-scope files, a confidence of `low` you don't trust),
> type `abort` and refine your task — no file is created.

---

## Step 4: Read the map — the scope

Open the `.html` file in any browser (it is a single portable file — no
internet needed to view it). Work top to bottom.

First, the banner reminds you this is a **structural** map — a picture of
how the code *is written*, not a recording of an executed run.

Then read the **scope-resolution panel**. This is the answer to *"what
does my task touch?"*:

- **In scope** — the files/areas the change touches, each with a one-line
  reason (e.g. `src/refund/risk/gate.ts — the risk gate the new step
  inserts after`).
- **Adjacent, excluded** — what the agent *saw and deliberately left out*
  as nearby-but-not-touched (e.g. `src/notify/email.ts — downstream
  notification, not modified by this task`). This is the honest part: it
  shows you the boundary it drew, so a silent omission can't hide.
- **Scope confidence** — `low` / `medium` / `high`. When it is below
  `high`, the panel names which way it might be wrong: **under-reach**
  ("may have missed needed files") or **over-reach** ("may be wider than
  the task touches"). Read that and adjust your trust accordingly.

Sanity-check this against what you know. If a file you're sure is involved
is missing, that's the panel telling you honestly it may have under-reached
— worth a closer look before you start.

---

## Step 5: Read the map — the flow

Now the **diagram**. The plugin renders the touched process as a
flowchart:

- **rectangles** are ordinary steps,
- **diamonds** are decision points (each carries the condition it branches
  on, e.g. `riskScore > 0.65`),
- **stadium shapes** are terminal outcomes,
- **labelled arrows** are the branches between them,
- **context** stages (the one-hop surroundings) are styled distinctly from
  the **touched core**.

Below the diagram, the **stage-detail table** lists every stage with its
evidence (the file paths behind it), a confidence, and the audit trail of
self-challenge and cross-check notes. This is how the map stays honest:
every node is grounded in code you can open.

> **No JavaScript?** The same flow is written out as a plain-text outline
> inside the page, so it is still readable in a script-stripped email
> client or a PDF export.

At this point you understand the change's **scope** (what it touches) and
its **flow** (how that slice runs). Now for the impact.

---

## Step 6: Predict the impact

Run the same command again with one extra flag:

```text
/pipeline-map "add a fraud-hold step after risk evaluation" --predict-change
```

This re-runs the map and adds a **change-site prediction**: it narrows the
(deliberately wide) touched scope down to the few nodes the change is
predicted to **edit**, and marks where it predicts you'll **insert** a new
stage. Accept the write as before, and open the new file.

---

## Step 7: Read the impact — and treat it as a prediction

Two things are different in this map.

In the **diagram**, predicted change sites are **highlighted** and each
carries a small **"predicted"** badge. The legend spells out what the
highlight means: *a prediction, not an instruction.*

In the new **Predicted change sites** panel, you'll see entries like:

- **modify** `risk-gate` — "the task edits the gate's post-risk routing to
  reach the new step" (with the evidence behind it);
- **insert** after `risk-gate` — "'add a fraud-hold step after risk
  evaluation' inserts a new stage after the gate".

and an overall **change confidence**, plus — when it's below `high` — the
direction it might be wrong in (**over-prediction**: may flag a node you
won't actually edit; **under-prediction**: may miss one).

This is the crucial bit to internalise: **the impact is a prediction about
what you'll do next, not a to-do list.** Predicting a future edit is far
less certain than reading what code exists today, so the map never says
"edit this" — it says "the task *likely* edits this", shows you *why*, and
tells you which way it might be wrong. Use it to orient and to spot
surprises; then verify against the code before you start cutting.

---

## Recap

You took a change you were considering and, in two commands, learned:

1. **its scope** — the bounded slice it touches, with the boundary
   disclosed (Step 4);
2. **its flow** — how control actually moves through that slice (Step 5);
3. **its impact** — a disclosed prediction of which nodes you'll modify
   and where you'll insert new ones (Steps 6–7).

The whole workflow is built to keep you in the loop honestly: it discloses
what it left out, grounds every claim in code, tells you how confident it
is and which way it might be wrong, and never writes a file or issues an
instruction without you seeing it first.

---

## Where to go next

- Want just the bound, without the full render? See
  [How to resolve a task's scope](../how-to/resolve-task-scope.md) — the
  lower-level "what does my task touch?" surface.
- The full command reference (flags, output path, the Mermaid vendoring
  and validation contract):
  [/pipeline-map command reference](../reference/pipeline-map-command.md).
- Already have a code *area* in mind rather than a task? The sibling
  [/diagnose command](../how-to/run-the-diagnose-command.md) builds the
  architectural and domain models for a scope you hand it.
- Curious how the maps stay trustworthy? The
  [challenge–refine](../explanation/challenge-refine-protocol.md) and
  [cross-check](../explanation/cross-check-protocol.md) concept pages
  explain the discipline behind every node.
