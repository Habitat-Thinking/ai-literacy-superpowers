# How to resolve a task's scope ("what does my task touch?")

This guide covers the **v0.7.0** `mode: scope-resolution` surface of the
`diagnostic-legibility` agent — slice **P2** of the task-scoped
pipeline-map feature. It answers a single question before you start work:
**which bounded slice of the system does the change I am considering
touch?**

It is the *inverse* of `/diagnose`. With `/diagnose` you hand the agent a
code scope and it inspects it. With scope-resolution you state a **work
task** in plain English and the agent **derives** the scope — the files
and process the task touches — and discloses the boundary it drew.

> **Surface note.** v0.7.0 ships this via the **bare Task-tool** dispatch
> (the same lower-level surface [invoke-the-agent](invoke-the-agent.md)
> documents). The agent emits the bound alone — no flow diagram and no
> rendered map. The three-way cross-check (P4) and the `/pipeline-map`
> command with its Mermaid HTML render (P5) are later slices. Until P5
> lands, scope-resolution and pipeline modes are the agent-output surface.

> **Want the flow, not just the bound?** Since **v0.8.0** the agent also
> has **`mode: pipeline`** — it resolves the same bound and then *traces
> the control flow within it*, emitting a `ConceptualPipelineMap` (stages,
> decisions, transitions) plus the architectural/domain models. Use
> `mode: scope-resolution` (this guide) when you only want "what does my
> task touch?"; use `mode: pipeline` when you want the traced process
> inside the bound. The dispatch is identical except the first line is
> `mode: pipeline`. (Cross-check across the three models is P4; the
> rendered HTML map is P5.)

## Inputs

- **`task`** (required) — a natural-language description of the work you
  are considering, e.g. `"add a fraud-hold step after risk evaluation"`.
  You state *intent*, not a code area.
- **`near`** (optional) — a path hint that **biases, but does not
  bound**, the search, e.g. `src/refund/`. Treat it as a strong starting
  prior; the agent may still resolve the true touched process outside it
  and records any out-of-hint inclusion with its reason. A wrong hint
  cannot silently exclude the real process.

## Dispatch (bare Task-tool pattern)

Invoke the Task tool with:

- `subagent_type`: `diagnostic-legibility`
- `description`: a short imperative — e.g. `"Scope the fraud-hold task"`
- `prompt`: a body whose **first line is the mode marker** and whose
  following lines carry the task and optional hint:

```text
mode: scope-resolution
task: add a fraud-hold step after risk evaluation
near: src/refund/
```

The `near:` line is optional; omit it to let the agent search the scope
it can see.

## What you get back — a `ScopeResolution`

The agent returns a **`ScopeResolution`** YAML block (not a
`LegibilityModel`, and not a full pipeline map):

```yaml
task: "add a fraud-hold step after risk evaluation"
scope_resolution:
  in_scope:
    - path: src/refund/risk/gate.ts
      reason: "the risk gate the new fraud-hold step inserts after"
    - path: src/refund/risk/evaluate.ts
      reason: "produces the risk signal the gate branches on"
  adjacent_excluded:
    - path: src/notify/email.ts
      reason: "downstream notification reached by the process but not modified by this task"
  scope_confidence: medium
generated_at: "<DISPATCHER: ISO 8601 timestamp>"
generated_by: "diagnostic-legibility / <DISPATCHER: active model identifier>"
```

Read it as three honest claims:

- **`in_scope`** — the files/areas the agent judged the task touches, each
  with a one-line reason.
- **`adjacent_excluded`** — what the agent **saw and consciously left
  out** as adjacent-but-not-touched. This is the load-bearing honesty
  field: it names the boundary the agent chose, so a silent boundary
  can't masquerade as ground truth. It is never omitted (it may be `[]`
  only when nothing was genuinely seen to exclude).
- **`scope_confidence`** — `low | medium | high` in the derived bound.

### Reading the confidence — and the failure direction

The bound is a **prediction**, so it can fail two opposite ways:

- **under-reach** — it missed files the task needs.
- **over-reach** — it pulled in more than the task touches.

A single confidence scalar can't say *which* way an uncertain bound
failed, and the two demand opposite fixes (widen vs narrow). So **when
`scope_confidence` is below `high`, the agent names the suspected
direction in a `reason`** — look for "may have missed needed files"
(under-reach) or "may be wider than the task touches" (over-reach), and
adjust your reading accordingly.

### The empty result is honest, not an error

A well-formed task that resolves to no touched process comes back as a
valid `ScopeResolution` with `in_scope: []`, `scope_confidence: low`, and
a reason explaining why nothing matched — the scope-resolution analogue
of the `(empty scope)` sentinel. The agent **refuses** only when the
`task:` itself is missing or empty:

```text
diagnostic-legibility refusal: scope-resolution mode requires a non-empty task; none was supplied.
```

## When to use this

- Before you start a change, to understand the slice of the process you
  are about to modify.
- To sanity-check that a task is as localised (or as sprawling) as you
  assumed — the `adjacent_excluded` set and the confidence tell you how
  safe the bound is to rely on.

## What it does *not* do

- It does not trace control flow or draw a map (that is P3–P5).
- It does not predict the **change site** — which line you'll edit — only
  which slice the task **touches**. Change-site prediction is a deliberate
  follow-on ([#368](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/368)),
  not part of v0.7.0.
