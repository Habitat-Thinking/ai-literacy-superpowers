# Diagnostic Legibility — Task-Scoped Conceptual Pipeline Map — Capability Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-03 |
| Status | In implementation — P1 (ConceptualPipelineMap template, v0.6.0, #363/#402), P2 (task→bounded scope resolution, v0.7.0, #364/#403, hand-validated), P3 (flow-tracing, `mode: pipeline`, v0.8.0, #365/#404), and P4 (three-way six-pair cross-check + `pipeline_cross_check_status`, v0.9.0, #366/#405) shipped; P5 (`/pipeline-map` command + vendored-Mermaid HTML) in progress; P6 deferred. §2.2 vendoring revised at P5 (pin+SHA+cache, not committed blob) |
| Author | claude-opus-4-8[1m] (interactive session with russmiles) |
| Capability | Given a work task a developer is considering, derive the bounded slice of the process that task touches, model it as a flow perspective over the architectural and domain models, and render it as a self-contained HTML pipeline map |
| Slicing record | `docs/superpowers/slices/diagnostic-legibility-pipeline-map.md` (slices P1–P6) |
| Plugin version target | `diagnostic-legibility` v0.5.0 → v0.6.0+ (one minor bump per behavioural slice; exact numbers set at implementation) |
| Reference image | `design-resources/conceptual-pipeline-map-example.png` |

---

## 1. Premise

The shipped `diagnostic-legibility` plugin (v0.5.0) builds two **static
enumerations** of a codebase scope — an architectural collection (moving
parts) and a domain collection (concepts) — refines each with a
five-question self-challenge (`Q<N>`), cross-checks the two (`CC<N>`), and
surfaces the result through `/diagnose` as a markdown report. Two
properties of that design are what this capability changes:

1. The collections answer *what is here*, not *how it runs* — no ordering,
   edges, or control flow.
2. The **scope is handed in by the human** (`/diagnose <scope>`), and the
   agent merely inspects it.

The reference image shows a different artefact — a **conceptual pipeline
map**: a traced process through the codebase, with numbered stages each
grounded in a file path, a decision **gate** carrying a condition,
**branches** to alternative paths with sub-steps, labelled branch edges,
**convergence**, and **terminals**.

And the use case this spec targets inverts the scoping direction. The map
is invoked by a developer **considering a work task** — a change they are
about to make — who wants a legible map *limited to the slice of the
process that work will touch*, so they understand the process before they
modify it. The developer does not hand in a code area; they state the
**task**, and the capability **derives** the bounded scope from it.

So this capability adds two new things to the discipline: a **flow
perspective** (control flow connecting the architectural moving parts and
domain concepts into a traced process), and a **task → bounded-scope
resolution** step (relevance scoping) that does not exist anywhere in the
shipped plugin.

## 2. Fixed design inputs

Five design calls were made by the human before this spec was written
(interactive session, 2026-06-03). They are **fixed inputs**, not open for
re-litigation here.

1. **Static structure first; live overlay deferred.** Slice 1 ships the
   static pipeline map with **no** execution-status overlay. The
   green-check / grey-circle "(live)" overlay and the `Actual: 0.82 (true)`
   gate annotation become a later slice (P6). The static slices must keep
   that seam open but not implement it.
2. **Vendored Mermaid render.** The flow diagram is a **Mermaid flowchart**
   inside a single self-contained HTML file, Mermaid's JS **version-pinned
   and inlined into the report** (the output **never** carries a CDN
   `<script src>`) — a deliberate, scoped exception to the repo's
   "readable-without-JS / no-external-deps" norm, justified because a
   branching flow graph needs a real layout engine.

   > **Revised at P5 (implementation, 2026-06-15).** The original wording
   > "vendored **locally**" implied committing the ~2.7 MB
   > `mermaid.min.js` blob into the repo. That is **not** required to meet
   > this design input's intent (a portable, CDN-free report) and was
   > revised, with the human's decision, to **pin + SHA-verify + cache
   > locally** instead: a small provenance **manifest** in the repo
   > records `{version, source URL, SHA-256}`; the `/pipeline-map` command
   > fetches the pinned bundle on first use into a **gitignored cache**,
   > verifies the SHA-256 against the manifest (**aborting** on mismatch),
   > and **inlines** the verified bytes into each report. This keeps the
   > supply-chain *integrity* the diaboli O6 cared about (the exact pinned
   > bytes are SHA-checked before inlining; a tampered or substituted CDN
   > artefact fails the check) and the output portability (still a
   > single self-contained file, no CDN link in the report), while
   > keeping a multi-megabyte third-party binary out of git history. The
   > trade accepted: generation needs network on first use (until the
   > cache is warm), and the guarantee is "integrity-verified" rather than
   > "exact bytes vendored offline". O6's *output* requirement (inlined,
   > portable) is unchanged; only the *source* of the inlined bytes moves
   > from committed-blob to pinned-and-verified-cache.
3. **New `/pipeline-map` command.** A new command parallel to `/diagnose`,
   not a flag on it, not a render-only skill.
4. **Third model, full treatment — maximal cross-check.** The pipeline is a
   **first-class `LegibilityModel` collection** — built, self-challenged
   (`Q<N>`), and cross-checked against the architectural and domain
   collections (`CC<N>`) — not a derived rendering that skips the
   challenge/cross-check cycle. The cost of this call was weighed against
   the cheaper derived-projection alternative (diaboli O10) and the
   **maximal** option chosen deliberately: Phase C runs **all six directed
   pairs** touching the pipeline (§6.3), accepting the combinatorial token
   cost as the price of maximal mutual correction.
5. **Task-scoped, not area-scoped.** *(This revision.)* The command's
   input is the **work task a developer is considering**, and the scope is
   **derived from that task and limited to it** — not a code area the human
   hands in. Deriving and bounding that scope honestly is a first-class
   part of the capability, not a parameter parse.

Everything below implements these five calls.

## 3. The task-scoping reframing

This is the heart of the revision, so it is stated before the schema.

### 3.1 The scoping direction is inverted

| | `/diagnose` (shipped) | `/pipeline-map` (this capability) |
| --- | --- | --- |
| Input | a code **scope** (dir / file list / area description) | a **work task** the developer is considering |
| Scope source | **handed in** by the human | **derived** by the agent from the task |
| Agent's job on scope | inspect what it was given | *resolve* the task to a bounded slice, then inspect |
| Boundary risk | none (scope is ground truth) | **prediction** that can under- or over-reach |

Because the bound is a prediction rather than ground truth, the capability
carries an **honesty obligation the shipped plugin never had**: the agent
must disclose *what it judged in-scope, what it consciously excluded as
adjacent, and how confident it is in the bound* — never present a silent
boundary as fact. This disclosure is recorded in the model
(`scope_resolution`, §4.3) and surfaced in the render (the scope panel,
§7.3).

**The relevance bound is the load-bearing bet (diaboli O1), so it is
validated before anything is built on it.** Two commitments follow. First,
the **standalone "what does my task touch?" surface ships first** — the
first human-visible slice renders `scope_resolution` alone (no map), so a
developer inspects the in-scope / adjacent-excluded / confidence disclosure
on real tasks after **one** slice rather than after four (§9.5, sequencing).
Second, the scope-resolution slice (P2) carries an explicit **acceptance
step**: hand-validation against a handful of worked tasks on a real repo
before P3 traces flow inside the bound. Disclosure keeps a bad bound
*honest*; the early standalone surface is what keeps the bet *inspectable
for usefulness*.

### 3.2 The bound is "the touched process + immediate context"

Limiting policy: the map covers the **directly-touched process** plus
**one hop** of upstream/downstream context, with the context stages marked
distinctly from the touched core. This keeps the map *limited* (the
developer's point) while not stranding the touched process without the
context needed to understand it. Two failure modes bound the policy:
under-reach (the bound misses a file the task needs) and over-reach (the
bound stops being limited); §3.1's disclosure is the mitigation for both.

**Disclosing the failure direction (diaboli O4).** A single
`scope_confidence` enum cannot say *which way* an uncertain bound failed,
and the two failures demand opposite remedies (widen vs narrow). So the
disclosure contract is strengthened: whenever `scope_confidence` is below
`high`, the producer must name the **suspected direction** in the
`scope_resolution` prose — under-reach ("may have missed needed files") or
over-reach ("may be wider than the task touches"). The scalar stays a
single enum (avoiding a precision/recall schema split every later slice
would freeze against); the direction lives in the prose where a human
reads it.

### 3.3 What this is *not* (yet)

Deriving the bounded scope ("what does my task touch?") is distinct from
predicting the **change site** ("which node will I edit?"). The task
framing makes the second a natural follow-on — the relevance pass surfaces
much of the signal — but it carries its own honesty burden and is **not**
in these slices. It is recorded as a candidate follow-on (§9, and the
slicing record's "explicitly not slicing on"). This spec scopes the map to
the task; it does not predict the edit.

## 4. The model is its own artefact (slice P1)

The conceptual pipeline map is defined as a **standalone data model** in
its own template — `diagnostic-legibility/templates/conceptual-pipeline-map.md`
— **not** as a collection bolted onto `LegibilityModel`. The full field
contract lives in that template; this section states the architectural
stance and why it matters for this capability.

### 4.1 The decoupling principle — and what it does *not* claim (diaboli O2)

`ConceptualPipelineMap` is **presentation-agnostic** and
**producer-agnostic**. Three roles are kept independently replaceable:

```
producer  ──emits──▶  ConceptualPipelineMap  ──projected by──▶  renderer
(the agent)            (the standalone model)                    (Mermaid/HTML, P5)
```

- The **model** is free of all *presentation*: no numbering, shapes,
  colours, layout, node text, or target format.
- The **renderer** (P5) derives every presentation concern *from* the
  model: the `"1"/"5A"/"5A.1"` numbering, the diamond/rectangle/stadium
  shapes, the node text, the layout, and the Mermaid/HTML output.
- The **producer** (the diagnostic-legibility agent today; any tracer
  tomorrow) is not baked in; the model records nothing about *how* it was
  traced, persisted, or rendered.

**What the model is deliberately *not* agnostic about.** It is **not
structure-free**, and that is by design. It embeds a **conceptual
control-flow ontology**: a process genuinely *has* an order, decision
points, and terminal outcomes, independent of how any of them are drawn.
So `kind: decision` is a **conceptual** property of a stage ("this stage
branches"), not a rendering hint; the *diamond* is the renderer's
projection of that property. The decoupling holds for the **glyph**, not
for the **existence** of the decision — and that is correct. The earlier
draft's wording "implementation-agnostic" over-claimed (diaboli O2): the
honest claim is presentation- and producer-agnostic over a model that
deliberately commits to a control-flow ontology.

This is the architectural answer to a concrete risk: if the pipeline were
a collection on `LegibilityModel` it would accrete whatever the first
renderer needed (a `kind` that means "draw a diamond", an `id` that
encodes a display number). Keeping it standalone forces every field to
justify itself as **conceptual** rather than presentational, and lets the
same map be projected to a Graphviz graph, a JSON export, or a future
live-overlay layer without a schema change.

### 4.2 What this changes versus the earlier draft

| Earlier draft (display-coupled) | This revision (decoupled) |
| --- | --- |
| `pipeline` collection on `LegibilityModel` | standalone `ConceptualPipelineMap` in its own template |
| `PipelineNode` / `PipelineEdge` | `PipelineStage` / `PipelineTransition` (conceptual terms, not graph/render terms) |
| `id` carries display numbering (`"5A.1"`) | `id` is a stable **opaque** slug (`risk-review`); numbering is renderer-derived |
| sub-steps implied by dotted `id` | sub-steps expressed structurally via `part_of` |
| `kind: gate` ("a diamond") | `kind: decision` (a conceptual role); the diamond is the renderer's choice |
| Mermaid shapes discussed in the schema | Mermaid lives only in the renderer (§7.2) |

The model still reuses the legibility discipline's `confidence` and
`challenge_notes[]` on each stage — those are **epistemic** properties (how
well-grounded and how-challenged the claim is), not display or
implementation, so they belong to a *legible* model. It still records the
`task` and a `ScopeResolution` (the disclosed, auditable derived bound,
§3.1). And a stage may **cross-reference** an architectural element and/or
domain concept via `realises` — a conceptual link, by name, that leaves
the map valid on its own.

### 4.3 Relationship to `LegibilityModel`

The map references the legibility models; it does not contain them. When
the agent runs in pipeline mode it emits the `ConceptualPipelineMap`
alongside the `architectural[]` / `domain[]` collections it cross-checked
against (the cross-check, §6, reads all three), but the map's schema embeds
neither — `realises` links are by element name. The runtime/execution
overlay (P6) is likewise a *separate* layer that references stages by `id`,
never a field inside this static model.

**Empty-result contract across the three collections (diaboli O7).** Two
distinct degenerate-output sentinels now coexist in one run, and they do
not conflict because each governs a different collection:

- The **map's empty-task sentinel** (template §Validation) governs the
  *map* only: a task that resolves to no process yields an empty
  `stages: []` plus a populated `scope_resolution` whose `scope_confidence`
  is `low` and whose reasons explain the empty result.
- The shipped **`(empty scope)` sentinel** (legibility-element.md) governs
  the *architectural[] / domain[]* collections independently, exactly as
  today.

The two may **co-occur** (a task that touches no process yields an empty
map; if the bound also surfaced no parts or concepts, an `(empty scope)`
element appears in `architectural[]`). A consumer matches the map's empty
state on `stages == []` and the legibility empty state on the `(empty
scope)` element — never one rule on the other collection. The §6.2
scope-relevance loop short-circuits on an empty-task map (there is no flow
to re-test).

> **Open for cartographer:** `realises` on the stage vs. reconstructed from
> shared evidence at cross-check time; whether `PipelineTransition.evidence`
> earns its keep at P1; and whether the cross-model bundle (map + arch +
> domain) is one agent-output envelope or three separately-persisted
> artefacts.
>
> **Resolved at P3 (implementation, 2026-06-15):** `realises` is carried
> **on the stage** (the seam P1 fixed); `PipelineTransition.evidence`
> **earns its keep** (a transition is a refutable claim — P3 grounds
> non-trivial transitions). The cross-model bundle is **one agent
> response carrying two clearly-delimited, standalone fenced YAML
> blocks** — first a `ConceptualPipelineMap`, then a `LegibilityModel`
> (`scope` = the resolved bound) — *not* a new merged envelope and *not*
> three separate dispatches. This keeps each model pure and standalone
> (the map embeds neither collection — P1's decoupling holds), while
> letting the P4 three-way cross-check and the P5 renderer consume both
> from a single dispatch. This also reconciles the spec §7 shorthand
> "dispatch in `mode: full`": the task-scoped pipeline runs under a
> dedicated **`mode: pipeline`** marker (the same add-a-mode choice P2
> made for `scope-resolution` rather than overloading `full`), and
> `/pipeline-map` (P5) dispatches `mode: pipeline`.

## 5. Task → bounded scope resolution (slice P2)

The new front-of-pipeline capability. The agent's read-only trust boundary
(`Read`, `Glob`, `Grep`) is **unchanged** — resolving scope is more
reading, not more capability.

1. **Interpret the task intent.** From the natural-language task, identify
   the process/capability it concerns (its nouns and verbs: "fraud-hold",
   "risk evaluation", "refund eligibility").
2. **Locate implicated code.** `Glob`/`Grep` for the task's terms, biased
   toward the optional `--near <path>` hint when given (a starting prior,
   not a hard bound — §7.1; the agent may follow the real process outside
   it and discloses when it does). Without the hint the agent searches the
   scope it can see.
3. **Bound the slice.** Apply the §3.2 limiting policy — touched process +
   one hop of context, context marked distinctly.
4. **Disclose.** Populate `scope_resolution`: `in_scope` (with per-entry
   reasons), `adjacent_excluded` (what was seen and left out, with
   reasons), and `scope_confidence`. Honesty rule: a thin or uncertain
   bound ships `scope_confidence: low` with the uncertainty named, never a
   confident silent boundary.

P2's resolved scope is independently observable — "what does my task
touch?" is answerable from `scope_resolution` before any flow is traced.

## 6. Flow-tracing, self-challenge, and three-way cross-check (slices P3–P4)

### 6.1 Phase A — trace the flow *within the bound* (P3)

Within the P2 bound, the agent traces control flow and emits a
`ConceptualPipelineMap`: discover entry points, follow the dominant
call/data path, classify a fork as a `decision` stage, classify a sink as
an `outcome` stage, record `realises` links, and ground each stage and
non-trivial transition in `evidence`. One dominant pipeline per task at P3
(multiple independent pipelines is out of scope, §8).

### 6.2 Phase B — flow-flavoured self-challenge (P3)

Working-hypothesis cover (revisable from disposition data, like the
existing covers): **phantom edge**, **condition fidelity**, **missed
branch**, **smeared step**, **ungrounded node** — plus a **scope-relevance**
check that re-tests the P2 bound against what the trace surfaced and feeds
corrections back into `scope_resolution` (closing the predicted-vs-traced
loop). `Q<N>` notation and the Phase A→B reframing carry over unchanged.

### 6.3 Phase C — three-way cross-check (P4)

Phase C generalises from two collections to three; the pipeline is where
cross-check pays off most (a stage's `condition`/`realises` is exactly what
the other models can refute).

- **All six directed pairs run (diaboli O10).** The maximal cover was
  chosen deliberately over a cheaper subset: `A↔D` (the existing two
  directions) plus the four pipeline-touching pairs `P→A`, `A→P`, `P→D`,
  `D→P`. The combinatorial token cost is accepted as the price of maximal
  mutual correction. (The cheaper derived-projection alternative — pipeline
  as a view with no third cross-check participant — was weighed and
  rejected; §2.4.)
- **Direction-flavoured weighting.** `P→A` weights a stage whose
  `condition`/boundary assumes an architectural boundary the arch model
  does not commit to; `A→P` weights an architectural element whose
  behaviour the pipeline's flow contradicts. `P→D` weights a stage whose
  `label` silently redefines a domain concept; `D→P` weights a domain
  concept the flow mis-sequences. `A↔D` weighting is unchanged from S3.
- **Audit trail unchanged.** `CC<N>` on the subject element only;
  side-effects named in the subject's prose, never double-written. The
  graph-rooted-at-subjects invariant extends cleanly to three collections.
- **`cross_check_status` — backward-compatible value contract (diaboli
  O8).** The existing scalar `cross_check_status` keeps its meaning
  **unchanged**: the **arch↔domain** outcome (`completed |
  skipped_asymmetric | not_run`, absence = `not_run`). A three-collection
  run sets it exactly as today. The pipeline's outcome is reported in a
  **new** field `pipeline_cross_check_status` with the **same** legal enum
  and the same absence semantics. `/diagnose`, which reads only the scalar,
  is unaffected and ignores the new field. This is the full value contract,
  not just a field name — a v0.5.0 consumer's scalar reading provably stays
  valid because the scalar's meaning never changes.

## 7. The `/pipeline-map` command and HTML render (slice P5)

Structurally mirrors `/diagnose` (S4) — dispatch in `mode: pipeline`
(the dedicated task-scoped mode resolved at §4.3; the original "dispatch
in `mode: full`" shorthand is reconciled there), render, validation
checkpoint, summary, confirm-before-write — but with a **task-driven**
input and a Mermaid HTML target. The agent stays read-only;
the command is the dispatcher that performs the single `Write`, the
`mkdir -p`, and the `<DISPATCHER: ...>` substitution.

### 7.1 Signature

```text
/pipeline-map "<task>" [--near <path>] [--out <dir>]
```

- `"<task>"` — **required** positional. A natural-language description of
  the work the developer is considering. Passed to the agent as the task to
  scope from. This is the input the reframing turns on — the developer
  states intent, not a code area.
- `--near <path>` — optional hint that **biases, but does not bound**, the
  scope-resolution search (diaboli O3). The agent treats `--near` as a
  strong starting prior for where to look, but **may** resolve the true
  touched process outside it; when it does, it records the out-of-hint
  inclusion and its reason in `scope_resolution`. This removes the
  wrong-guess footgun (a developer who narrows to the wrong module cannot
  silently exclude the real process) while keeping the cost/relevance
  benefit of a starting point. Optional: the agent can resolve scope
  without it.
- `--out <dir>` — optional output-directory override.
- Default output path:
  `diagnostic-legibility/output/<task-slug>-pipeline-<YYYY-MM-DD>.html`
  (the `output/` directory is already gitignored; `<task-slug>` derived
  from the task description with the existing slug rules). Extension `.html`.

### 7.2 The Mermaid projection (renderer-owned)

The renderer is the **only** place display concerns live. It reads the
display-agnostic `ConceptualPipelineMap` and *derives* a Mermaid flowchart;
none of the right-hand column below is a model field.

| Model (conceptual) | Renderer-derived display |
| --- | --- |
| traversal of `entry` + `transitions` + `part_of` | the `"1" / "5A" / "5A.1"` presentation numbering |
| `stage.kind: step` | rectangle `id["<n> <label><br/><path>"]` |
| `stage.kind: decision` | diamond `id{"<n> <label><br/><path>"}` |
| `stage.kind: outcome` | stadium `id(["<label>"])` |
| `stage.condition` | the decision's branch-transition labels and/or a side note |
| `transition` (plain) | `from --> to` |
| `transition.condition_label` | `from -->|<label>| to` |
| `part_of` grouping | a Mermaid `subgraph` or indentation |
| context vs. touched (§3.2) | `classDef context …` on adjacent-context stages |

The renderer composes node text (number + label + first `evidence.path`)
to match the reference image's three-line nodes — a presentation choice the
model is deliberately silent about. The same model could instead be
projected to Graphviz, JSON, or a plain-text outline; only this table
changes.

**No live-status styling at P5 (diaboli O12).** The static render carries
**no** executed/not-executed `classDef` and **no** reserved live legend —
those appear only when P6 actually ships the execution overlay. A static
map must not be dressed as a present-but-empty live view. The `id`
stability that P6's overlay binds to is preserved, but no visual seam for
it is rendered now.

### 7.3 The HTML page

A single self-contained, **portable** file projected from the model:

- **"Structural — not executed" banner (diaboli O12).** A visible header
  banner stating the map is a *static structural* view, not a record of an
  executed run — so the "(live)"-style idiom the reference image uses
  cannot be misread as observed runtime facts. Gate `condition` values
  render as conceptual rules, never as evaluated results.
- **Header** — the **task** (not a code path), `generated_at`,
  `generated_by`, stage count. `<DISPATCHER: ...>` placeholders substituted
  by the command.
- **Scope-resolution panel** *(task-framing specific)* — surfaces
  `scope_resolution`: the task, the `in_scope` set with reasons, the
  `adjacent_excluded` set with reasons, `scope_confidence`, and (when
  confidence < high) the suspected failure direction (§3.2). This is what
  makes the *limiting* legible: the developer sees not just the map but
  **why this slice and what was left out**. Without it the bound would be a
  silent boundary — the exact honesty failure §3.1 forbids.
- **The Mermaid diagram** (`<div class="mermaid">…</div>` + the **inlined,
  vendored, version-pinned** `mermaid.min.js`), with context stages styled
  distinctly from the touched core.
- **No-JS static fallback (diaboli O5).** Inside `<noscript>`, the
  **plain-text / indented-outline projection** of the same model (the
  projection §7.2 already names). A reader with JavaScript disabled, a
  script-stripping email client, or a PDF export still sees the flow
  structure rather than an empty box — restoring the portfolio-dashboard
  "readable without JavaScript" norm the Mermaid exception otherwise broke.
  Mermaid is the *enhanced* view; the outline is the *floor*.
- **Stage-detail table** — one row per stage: evidence paths, `confidence`,
  grouped `Q<N>`/`CC<N>` notes — so the discipline's audit trail survives
  into the visual surface.
- **Legend** — stage kinds and the touched/context distinction. (No
  executed/not-executed key until P6 ships — O12.)
- Inline CSS. No CDN. **The Mermaid bundle is inlined** into each report
  (diaboli O6) so the file is a genuinely portable single artefact a
  developer can share; provenance (source URL + SHA + pinned version) is
  recorded where the bundle is vendored. The per-file size cost is accepted
  as the price of portability.

### 7.4 Validation checkpoint

`/pipeline-map` joins the CLAUDE.md "Output Validation Checkpoints" list.
After rendering, before the confirm-before-write gate, read the HTML back
and check: the "structural — not executed" banner is present; header names
the task with no `<DISPATCHER:` leak; the scope-resolution panel is present
and reports `in_scope`, `adjacent_excluded`, and `scope_confidence`
consistent with the model (and the failure direction when confidence <
high); the `<noscript>` outline fallback is present and lists every
`stage.id`; every `stage.id` appears in both the Mermaid source and the
detail table; every `transition` references rendered stages; the Mermaid
source parses to a single `flowchart`; counts consistent. Deviations fixed
in place; the agent is not re-dispatched. The human accept gate remains the
last line of defence.

## 8. Out of scope

- **The live overlay (P6).** Execution-status colouring and `Actual: …`
  annotations. Deferred per call §2.1; the static slices keep the seam.
- **Change-site prediction.** Which node the task will *edit*, as opposed to
  which slice it *touches* (§3.3). A candidate follow-on, not these slices.
- **Multiple pipelines per task.** P3 traces one dominant pipeline.
- **An interactive / queryable map.** One-shot, stateless, one artefact —
  like `/diagnose`.
- **A runtime schema validator.** Validation stays agent-enforced + command
  checkpoint.
- **Re-using `/diagnose` to emit the map.** Separate command (call §2.3);
  `/diagnose` is untouched except where shared schema changes ride along.

Docs are **not** out of scope: the `/pipeline-map` how-to and reference
pages are an explicit P5 deliverable shipped in the same PR (diaboli O9,
per CLAUDE.md Docs Site Review and the `/diagnose` precedent).

## 9. Sequencing and remaining open questions

### 9.1 Sequencing — fixed (diaboli O11)

The slice order is committed, not left open:

1. **P1** — the `ConceptualPipelineMap` schema.
2. **P2** — task → bounded scope resolution, shipped with a **standalone
   "what does my task touch?" surface** (a minimal render of
   `scope_resolution`, **no map**). This is the **first human-visible
   slice**, so the relevance bet (O1) is inspectable on real tasks after
   one slice, and it carries the hand-validation acceptance step (§3.1).
3. **P3** — flow-tracing within the bound + self-challenge.
4. **P4** — the three-way (six-pair) cross-check.
5. **P5** — the `/pipeline-map` command + Mermaid HTML render (with the
   no-JS fallback, the structural banner, and the docs pages).
6. **P6** — live overlay (deferred).

The full Mermaid map therefore lands at P5, already cross-corrected by P4;
but the relevance bound it rests on was made human-inspectable back at P2.

### 9.2 Remaining open questions (for the cartographer)

The diaboli-resolved questions are closed (§10). These remain for
`/choice-cartograph` and per-slice specs:

1. **P1:** `realises` on the stage vs. reconstructed at cross-check time;
   whether `PipelineTransition.evidence` earns its keep at P1; whether the
   cross-model bundle (map + arch + domain) is one agent-output envelope or
   three separately-persisted artefacts.
2. **P3:** the exact flow-flavoured challenge cover (the five names are a
   working hypothesis).
3. **Naming / contract:** is the change-site-prediction follow-on (§3.3)
   wanted soon enough that P1 should reserve a `task_relevance` marker on
   stages now, rather than add it later?

## 10. Spec-mode diaboli gate outcomes

The spec-mode `/diaboli` gate raised **12 objections**
(`docs/superpowers/objections/dl-pipeline-map-design.md`), **all 12
accepted** and absorbed into this spec. The load-bearing resolutions:

- **O1 / O11 (the relevance bet + sequencing)** — the standalone "what does
  my task touch?" surface ships **first** (§9.1); P2 carries a
  hand-validation acceptance step (§3.1). The bet is inspectable after one
  slice.
- **O2 (decoupling leak)** — the claim is reframed (§4.1): the model is
  **presentation- and producer-agnostic**, not structure-free; it
  deliberately embeds a conceptual control-flow ontology, so `kind:
  decision` is conceptual and only the diamond is the renderer's.
- **O3 (`--near`)** — pinned to **biases, does not bound** (§7.1).
- **O4 (`scope_confidence`)** — single enum kept; failure **direction**
  disclosed in prose when confidence < high (§3.2).
- **O5 (no-JS)** — `<noscript>` plain-text-outline fallback required (§7.3).
- **O6 (portability)** — Mermaid bundle **inlined**; portable single file
  (§7.3).
- **O7 (empty-result)** — map sentinel and `(empty scope)` sentinel govern
  different collections and may co-occur (§4.3).
- **O8 (cross-check status)** — full value contract: scalar unchanged
  (arch↔domain), new `pipeline_cross_check_status` mirrors its enum (§6.3).
- **O9 (docs)** — how-to + reference are an explicit P5 deliverable (§8).
- **O10 (cross-check cost)** — full **six directed pairs** run deliberately;
  cost weighed and recorded (§2.4, §6.3).
- **O12 (static-but-"(live)")** — "structural — not executed" banner; no
  reserved live legend until P6 (§7.2, §7.3).

## 11. References

- Slicing record: `docs/superpowers/slices/diagnostic-legibility-pipeline-map.md`.
- Diaboli objection record: `docs/superpowers/objections/dl-pipeline-map-design.md`.
- Reference image: `design-resources/conceptual-pipeline-map-example.png`.
- The new standalone model: `diagnostic-legibility/templates/conceptual-pipeline-map.md`.
- Related (cross-referenced, not extended) schema: `diagnostic-legibility/templates/legibility-element.md`.
- Agent this extends: `diagnostic-legibility/agents/diagnostic-legibility.agent.md`.
- Surfacing precedent: `diagnostic-legibility/commands/diagnose.md` and its spec `docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md`.
- HTML-render precedent and self-contained norm: `ai-literacy-superpowers/skills/portfolio-dashboard/SKILL.md`.
- Cross-check precedent: `docs/superpowers/specs/2026-05-29-dl-s3-cross-check-mechanism-design.md`.
- `CLAUDE.md` — Semantic Versioning, Marketplace Versioning, Docs Site Review, Output Validation Checkpoints.
