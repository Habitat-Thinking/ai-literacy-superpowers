# How to run the /pipeline-map command

`/pipeline-map` turns a **work task you are considering** into a
**self-contained HTML flow map** of the slice of the system that task
touches. State the change in plain English; the command resolves the
bounded scope, traces the control flow within it, cross-checks the result
against the architectural and domain models, and renders a portable HTML
flowchart you can open in any browser or share as a single file.

It is the human-facing surface for the agent's `mode: pipeline`. Use
[resolve-task-scope](resolve-task-scope.md) when you only want the bound
("what does my task touch?"); use `/pipeline-map` when you want the
**traced, cross-checked, rendered** map.

## Usage

```text
/pipeline-map "<task>" [--near <path>] [--out <dir>]
```

- `"<task>"` — **required**. The work you are considering, e.g.
  `"add a fraud-hold step after risk evaluation"`. You state intent, not
  a code area.
- `--near <path>` — **optional** hint that **biases, but does not bound**,
  the scope search. A wrong hint cannot silently exclude the real
  process; the agent follows the flow where the evidence leads and
  discloses any out-of-hint inclusion.
- `--out <dir>` — **optional** output-directory override.

## What it does, end to end

1. **Dispatches** the `diagnostic-legibility` agent in `mode: pipeline`
   with your task (and `--near` hint, if given).
2. The agent **resolves the bound**, **traces the flow** into a
   `ConceptualPipelineMap`, **builds** the architectural/domain models,
   self-challenges everything, and **cross-checks** all three.
3. The command **resolves the Mermaid bundle** — fetches the pinned,
   SHA-verified version into a gitignored cache on first use, reusing it
   thereafter (see [Mermaid vendoring](#mermaid-vendoring)).
4. It **renders** a self-contained HTML file, runs an **output validation
   checkpoint**, prints a **summary**, and writes the file **only after
   you accept**.

## What you get — the HTML report

A single portable `.html` file (default
`diagnostic-legibility/output/<task-slug>-pipeline-<YYYY-MM-DD>.html`,
gitignored) containing, top to bottom:

- a **"structural — not executed" banner** — the map is a *static*
  structural view, not a record of a run; gate conditions are conceptual
  rules, never evaluated results;
- a **header** naming the task, generation time, and stage count;
- a **scope-resolution panel** — the in-scope set, the
  adjacent-but-excluded set (each with reasons), the scope confidence,
  and the suspected failure direction when confidence is below `high` —
  so you see both the map **and** why this slice was chosen;
- the **Mermaid flowchart** — steps as rectangles, decisions as diamonds,
  outcomes as stadiums, branch conditions as edge labels, context stages
  styled distinctly from the touched core;
- a **no-JS fallback** — inside `<noscript>`, a plain-text outline of the
  same flow, so the file is still readable with JavaScript disabled, in a
  script-stripping client, or as a PDF export;
- a **stage-detail table** — per stage: evidence, confidence, and the
  grouped `Q<N>` (self-challenge) then `CC<N>` (cross-check) notes;
- a **cross-check summary** and a **legend**.

## Mermaid vendoring

The flowchart needs Mermaid to render in a browser. The report **inlines**
a **version-pinned, SHA-256-verified** Mermaid bundle — it never links a
CDN, so the file renders offline and is safe to share. The pin and hash
live in `diagnostic-legibility/assets/mermaid-vendor.md`; the command
fetches the bundle once into a gitignored cache
(`diagnostic-legibility/assets/cache/`), verifies its SHA-256, and
**aborts without writing** if the hash does not match. First generation
needs network until the cache is warm.

## The confirm-before-write gate

Nothing is written until you accept. The command prints a summary naming
the resolved path (flagging an overwrite if the file exists), the stage
count, the scope confidence, and both cross-check statuses; you `accept`
or `abort`. On abort, no file and no directory are created.

## When to use it

- Before starting a change, to see the traced process you are about to
  modify — not just which files it touches, but how control flows through
  them and where the decision points are.
- To share a legible, self-contained map of a slice with a colleague or
  attach it to a design discussion.

## What it does not do

- It renders a **static structural** map — not a live execution trace
  (the green-check/grey-circle "(live)" overlay is the deferred P6).
- It does not predict the **change site** (which node you will edit), only
  the slice the task **touches** (deferred follow-on
  [#368](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/368)).

## See also

- [resolve-task-scope](resolve-task-scope.md) — the bound only, no map.
- [run-the-diagnose-command](run-the-diagnose-command.md) — the
  area-scoped sibling (you hand in a scope; it builds arch + domain).
- Reference: [pipeline-map command](../reference/pipeline-map-command.md).
