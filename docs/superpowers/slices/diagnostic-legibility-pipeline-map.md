---
task: "Add a task-scoped conceptual pipeline map to the Diagnostic Legibility plugin — given a work task a developer is considering, derive the bounded slice of the process that task touches and render it as an HTML flow map"
task_slug: diagnostic-legibility-pipeline-map
date: 2026-06-03
carpaccio_model: claude-opus-4-8[1m]
inseparable: false
progressed_slice: none
slices:
  - id: P1
    title: ConceptualPipelineMap — a standalone, display- and implementation-agnostic data model
    scope: >
      Define the conceptual pipeline map as its OWN data model in its own template
      (diagnostic-legibility/templates/conceptual-pipeline-map.md), NOT as a
      collection bolted onto LegibilityModel: a ConceptualPipelineMap wrapper
      (task, scope_resolution, entry, stages, transitions, provenance), a
      PipelineStage record (id, label, kind, condition, part_of, realises,
      evidence, confidence, challenge_notes), a PipelineTransition record (from,
      to, condition_label, kind, evidence), and a ScopeResolution record (in_scope,
      adjacent_excluded, scope_confidence). The model holds only conceptual content
      — it carries NO display concerns (numbering, shapes, layout, node text,
      target format) and NO implementation concerns (tracing strategy, persistence,
      runtime overlay). No agent logic and no rendering. Structural-test visible,
      mirroring sub-S2a.
    decision_focus: >
      How is a traced process represented as a model in its own right, decoupled
      from how it is produced and how it is shown? Two coupled decisions. First,
      the conceptual shape: stages + transitions with typed stages
      (step/decision/outcome), decision conditions, structural sub-step grouping
      (part_of), and a stable OPAQUE id — so that all display concerns (the
      "1/5A/5A.1" numbering, diamond/rectangle shapes, node text, Mermaid/HTML) are
      DERIVED by a renderer and never stored. Second — new to the task framing —
      how the derived scope is made auditable: because the scope is inferred from a
      task rather than handed in, the model records a ScopeResolution (in_scope,
      adjacent_excluded, scope_confidence). The decision also fixes how a stage
      cross-references the architectural moving part and domain concept it realises
      (the P4 cross-check seam) by name, leaving the map valid standalone.
    lens_used: decision-boundary
    disposition: filed
    disposition_rationale: >
      Filed as a tracked issue (human decision, 2026-06-10): the whole P1–P5
      package was queued as issues with none flagged to progress now. Build in
      the fixed order P1→P2→P3→P4→P5 (diaboli O11).
    file_as_issue: true
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/363
    merged_into: null

  - id: P2
    title: Task → bounded scope resolution — derive the slice of the system a work task touches
    scope: >
      Give the agent the new front-of-pipeline capability the task framing
      requires: take a natural-language description of a work task a developer is
      considering ("add a fraud-hold step after risk evaluation"), optionally
      narrowed by a `--near <path>` hint, and resolve it into a *bounded, disclosed*
      set of in-scope files/process — not the whole codebase. The observable output
      is the resolved scope: the in-scope set, the adjacent-but-excluded set, and a
      scope confidence, populated into the P1 `scope_resolution` provenance. This is
      independently valuable ("what does my task touch?" is a question on its own,
      answerable before any flow is traced).
    decision_focus: >
      How does a work task become a *limited* scope, and how is the limiting made
      honest? This is genuinely new analytical work — relevance scoping — distinct
      from the shipped behaviour where the human hands the agent a scope and the
      agent merely inspects it. The decision covers the relevance policy (how the
      task intent is interpreted into entry points and code paths; how `--near`
      bounds the search; how aggressively the scope is limited — the touched process
      alone, or the touched process plus one hop of context marked distinctly), and
      the honesty contract for a derived scope (task→scope is a *prediction* that can
      under- or over-reach; the agent must disclose what it excluded and a scope
      confidence rather than present a silent boundary). Precision/recall on the
      bound is the central failure mode this decision must address.
    lens_used: decision-boundary
    disposition: filed
    disposition_rationale: >
      Filed as a tracked issue (human decision, 2026-06-10): the whole P1–P5
      package was queued as issues with none flagged to progress now. P2 is the
      load-bearing risk slice (diaboli O1) and the first human-visible surface;
      build in the fixed order P1→P2→P3→P4→P5 (diaboli O11).
    file_as_issue: true
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/364
    merged_into: null

  - id: P3
    title: Flow-tracing within scope and self-challenge — build the pipeline collection
    scope: >
      Within the bounded scope P2 resolved, extend Phase A so the agent traces
      control flow and emits the pipeline collection alongside architectural[] and
      domain[], and extend Phase B to self-challenge every pipeline node with
      flow-flavoured weighting (including a scope-relevance question that re-checks
      the P2 bound against what the trace actually surfaced). Observable: a
      LegibilityModel whose pipeline collection is individually refined (Q<N> notes)
      but not yet cross-checked. Agent-output visible via the bare Task tool,
      mirroring sub-S2b.
    decision_focus: >
      What does the flow-tracing pass analyse, and what is the flow-specific
      challenge cover? Control-flow inference from static code is more error-prone
      than enumeration — edges, conditions, and ordering are claims a static reader
      can assert with false confidence. The decision fixes the tracing strategy
      (entry-point discovery within the P2 bound, how far calls are followed before
      a node becomes terminal, when a branch is promoted to a gate node) and the
      flow-flavoured five-question cover (candidate failure modes: phantom edge,
      condition fidelity, missed branch, smeared step, ungrounded node — plus a
      scope-relevance check feeding corrections back to the P2 bound).
    lens_used: decision-boundary
    disposition: filed
    disposition_rationale: >
      Filed as a tracked issue (human decision, 2026-06-10): the whole P1–P5
      package was queued as issues with none flagged to progress now. Build in
      the fixed order P1→P2→P3→P4→P5 (diaboli O11).
    file_as_issue: true
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/365
    merged_into: null

  - id: P4
    title: Three-way cross-check — the pipeline corrects and is corrected by arch and domain
    scope: >
      Extend Phase C from a two-collection cross-check to a three-collection one:
      the pipeline collection challenges and is challenged by the architectural and
      domain collections, producing CC<N> notes on pipeline nodes and side-effects
      on the other two. Observable: a mutually-corrected three-collection
      LegibilityModel. Mirrors S3, generalised from two collections to three.
    decision_focus: >
      How does cross-check scale to three collections without a six-direction
      combinatorial blow-up? Two collections gave A→D and D→A; three give up to six
      directed pairs. The decision is which directed pairs run, how the
      direction-flavoured weighting generalises (a pipeline node whose condition
      assumes an architectural boundary the arch model does not commit to; a step
      whose label silently redefines a domain concept), and how the subject-only
      audit-trail invariant and the cross_check_status wrapper field extend to three
      collections under a backward-compat constraint (v0.5.0 consumers read a scalar
      status). This delivers the "third model, full treatment" depth chosen over a
      derived rendering.
    lens_used: decision-boundary
    disposition: filed
    disposition_rationale: >
      Filed as a tracked issue (human decision, 2026-06-10): the whole P1–P5
      package was queued as issues with none flagged to progress now. The
      six-directed-pair cover is settled (diaboli O10) but carries story #6's
      revisit/falsify watch item — trim any pair that never fires a correction on
      real invocations. Build in the fixed order P1→P2→P3→P4→P5 (diaboli O11).
    file_as_issue: true
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/366
    merged_into: null

  - id: P5
    title: /pipeline-map command — task-driven signature, vendored-Mermaid self-contained HTML
    scope: >
      Add the human-facing command. Its signature is task-driven:
      /pipeline-map "<task>" [--near <path>] [--out <dir>] — the developer states the
      work they are considering, the command drives the full pipeline (P2 scope
      resolution → P3 trace → P4 cross-check) in mode: full, and renders the bounded
      pipeline as a Mermaid flowchart inside a single self-contained HTML file
      (Mermaid vendored locally, version-pinned). The page pairs the diagram with a
      node-detail table (evidence, confidence, Q/CC notes) and a scope panel
      surfacing the P2 scope_resolution (task, in-scope, adjacent-excluded,
      confidence) so the developer sees both the map and why this slice was chosen.
      Output validation checkpoint; confirm-before-write gate. First polished
      human-visible artefact; mirrors S4 structurally.
    decision_focus: >
      How does a *task-scoped* flow graph become a self-contained HTML artefact that
      honours the project's surfacing pattern? The decision is the command's
      task-driven contract (the required quoted task description, the optional
      --near hint, the task-derived output filename), the Mermaid mapping (node kinds
      → flowchart shapes, conditions/branch labels → edge labels, node text → number
      + label + file path), the vendoring/provenance discipline for the Mermaid asset
      (self-contained / no-CDN; pinned; SHA recorded — a supply-chain decision), and
      the page layout (diagram + node-detail table + scope-resolution panel + legend).
      The command is the dispatcher: single Write, <DISPATCHER: ...> substitution,
      human accept gate; the agent stays read-only.
    lens_used: decision-boundary
    disposition: filed
    disposition_rationale: >
      Filed as a tracked issue (human decision, 2026-06-10): the whole P1–P5
      package was queued as issues with none flagged to progress now. Diaboli-gate
      deliverables (noscript fallback O5, inlined Mermaid O6, structural banner
      O12, same-PR docs O9) are fixed on the issue. Build in the fixed order
      P1→P2→P3→P4→P5 (diaboli O11).
    file_as_issue: true
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/367
    merged_into: null

  - id: P6
    title: Live overlay — execution-trace status on the map (deferred)
    scope: >
      Make the map "live": accept an execution trace (OpenTelemetry span dump,
      structured log, or coverage file), match trace records to pipeline nodes by
      file-path grounding, and colour each node executed / not-executed (Mermaid
      classDef) — restoring the green-check / grey-circle overlay and the
      "Condition: … Actual: 0.82 (true)" annotation from the reference image.
      Deferred per the human's slice-1 decision; recorded so the earlier slices keep
      the seam open (stable node ids, per-node file evidence, a Mermaid class hook).
    decision_focus: >
      Where does execution status come from and how is it bound to nodes? The
      trace-input format and the node↔trace matching contract (by file-path
      evidence? by an explicit node-id annotation in traced code? by span name?),
      plus the honesty handling of unmatched nodes (no matching record means "not
      observed", distinct from "not executed"). Deferred, not decided.
    lens_used: decision-boundary
    disposition: deferred
    disposition_rationale: >
      The human chose to ship the static structural map first and add the live
      overlay later (design call, 2026-06-03). P6 is recorded so P1–P5 preserve the
      seam it needs but is not scheduled now.
    file_as_issue: false
    issue_url: null
    merged_into: null
---

## P1 — ConceptualPipelineMap — a standalone, display- and implementation-agnostic data model — decision-boundary

**Context**

The shipped plugin (v0.5.0) emits a `LegibilityModel` with two flat
collections — `architectural[]` and `domain[]` — that answer *what is
here*, not *how it runs*, and whose scope is **handed in by the human**.
A task-scoped conceptual pipeline map is a different artefact on three
axes: it is a traced process (sequence, decisions, branches, convergence,
outcomes — the structure in
`design-resources/conceptual-pipeline-map-example.png`); its scope is
**derived from a work task**, not supplied; and — the constraint that
shapes this slice — it must be a **model in its own right**, decoupled
from how it is produced and how it is displayed, so the same map can be
projected to Mermaid today and to other formats (or a live overlay) later
without a schema change.

**Decision content**

How a traced process is represented **as its own model**, decoupled from
production and display. The map is defined in its own template
(`templates/conceptual-pipeline-map.md`), **not** as a collection on
`LegibilityModel`. The conceptual shape: `stages` + `transitions`, with
typed stages (`step | decision | outcome`), a `condition` on decisions,
structural sub-step grouping via `part_of`, and a **stable opaque `id`** —
the load-bearing decoupling choice, because it forces all display concerns
(the `1 / 5A / 5A.1` numbering, the diamond/rectangle/stadium shapes, the
node text, the Mermaid/HTML output) to be *derived by a renderer* rather
than stored. The model carries the legibility discipline's `confidence` +
`challenge_notes[]` on each stage (epistemic, not display); the `task` and
a `ScopeResolution` (`in_scope`, `adjacent_excluded`, `scope_confidence`)
making the *derived* bound auditable; and a `realises` cross-reference (by
name) to the architectural/domain element a stage realises — the P4
cross-check seam — that leaves the map valid standalone. The decision is
equally about what the model **excludes**: numbering, shapes, layout,
target format (renderer concerns) and tracing strategy, persistence, and
runtime overlay (producer/consumer concerns).

**Dependencies**

None beyond the shipped v0.5.0 schema. P1 lands first; every later slice
consumes the contract it defines.

**Rationale**

Defining the map as its own artefact — rather than a `pipeline` collection
on `LegibilityModel` — is what keeps display and implementation concerns
out of it. A collection bolted onto the existing wrapper would accrete
whatever the first renderer needed (a `kind` that means "draw a diamond",
an `id` that encodes a display number); a standalone model forces every
field to justify itself as conceptual and keeps the producer, the model,
and the renderer independently replaceable. The scope-provenance fields are
not optional polish: once the agent *infers* scope from a task, the
inference becomes a claim the discipline must record and later challenge.
Mirrors sub-S2a's role of fixing the schema before any consumer is built.

---

## P2 — Task → bounded scope resolution — derive the slice of the system a work task touches — decision-boundary

**Context**

In the shipped plugin the human hands the agent a scope (a directory, a
file list, a free-text area) and the agent inspects it. The task framing
inverts this: the developer states *the work they are considering*, and
the agent must work out *which slice of the system that work touches* and
bound the map to it. This relevance-scoping step does not exist anywhere
in the current plugin — it is the load-bearing new capability the whole
task-scoped framing rests on.

**Decision content**

How a work task becomes a *limited* scope, and how the limiting is made
honest. The relevance policy: how the task intent is interpreted into
entry points and code paths (Glob/Grep on the task's nouns and verbs,
guided by an optional `--near <path>` hint that bounds the search space);
how aggressively the scope is limited (the directly-touched process
alone, or the touched process plus one hop of upstream/downstream context
marked distinctly so "what I'll change" stays separable from "what I need
to understand around it"); and the honesty contract for a *derived*
scope. Because task→scope is a prediction that can under-reach (miss
files the task needs) or over-reach (stop being "limited"), the agent
must **disclose** what it judged adjacent-but-excluded and a scope
confidence, rather than present a silent boundary as ground truth. The
precision/recall trade-off on the bound is the failure mode this decision
exists to manage.

**Dependencies**

P1 (the `scope_resolution` provenance shape must exist for the resolved
scope to be recorded against).

**Rationale**

Relevance scoping is a distinct decision from flow tracing (P3) — *which
files* is a different question from *how control flows through them* — and
it is the riskiest new capability, so it earns its own slice and its own
disposition. It is also independently observable: a developer can ask
"what does my task touch?" and get a disclosed bounded scope before any
flow diagram is drawn, which is a useful product on its own.

---

## P3 — Flow-tracing within scope and self-challenge — build the pipeline collection — decision-boundary

**Context**

With a bounded scope resolved (P2), the agent traces control flow *within
that bound* and self-challenges the result, exactly as it already
constructs and self-challenges the architectural and domain collections.
The construction is a genuinely new analytical capability: tracing flow,
not enumerating parts.

**Decision content**

What the flow-tracing pass analyses and the flow-specific challenge cover.
The tracing strategy (entry-point discovery within the P2 bound, how far
calls are followed before a node becomes terminal, when a branch is
promoted to a gate node) and the flow-flavoured five-question cover Phase
B applies (candidate failure modes: phantom edge, condition fidelity,
missed branch, smeared step, ungrounded node). One question is
scope-aware: a *scope-relevance* check that re-tests the P2 bound against
what the trace actually surfaced and feeds corrections back into the
`scope_resolution` provenance — closing the loop between the predicted
scope and the traced reality.

**Dependencies**

P2 (a bounded scope to trace within) and P1 (the pipeline schema to
populate).

**Rationale**

Separating the flow build + self-challenge from the cross-check (P4)
keeps the two decisions distinct, as sub-S2b was kept separate from S3.
Building *within* the P2 bound is what keeps the trace limited and cheap
rather than wandering the whole codebase.

---

## P4 — Three-way cross-check — the pipeline corrects and is corrected by arch and domain — decision-boundary

**Context**

Phase C today cross-checks the architectural and domain collections
against each other (A→D, D→A) with direction-flavoured weighting and a
subject-only audit trail. Adding the pipeline as a third collection
generalises this. The pipeline is where cross-check pays off most: a
node's condition or `realises` link is exactly the kind of claim the
other two models can refute.

**Decision content**

How cross-check scales to three collections without a six-direction
combinatorial blow-up. Which directed pairs run (is the pipeline both
subject and challenger against each of the other two, or only ever the
subject?); how direction-flavoured weighting generalises to the new pairs
(a pipeline node whose `condition` assumes an architectural boundary the
arch model does not commit to; a step whose `label` silently redefines a
domain concept the domain model pins differently); and how the
subject-only audit-trail invariant and the `cross_check_status` wrapper
field extend to three collections under a backward-compat constraint
(v0.5.0 consumers read a scalar status, so the change must keep the scalar
reading valid — e.g. add a `pipeline_cross_check_status` rather than
re-type the existing field).

**Dependencies**

P3 (the pipeline must be built and individually refined before it can
cross-check the others). Builds on the shipped S3 Phase C.

**Rationale**

The cross-check mechanism is architecturally independent from pipeline
construction, as S3 was from S2. Slicing it separately keeps the
combinatorial-scaling decision — the genuinely hard part of going from two
collections to three — out of the tracing logic.

**Resolved (diaboli O10).** The "which directed pairs run" decision is
settled in favour of the **maximal** cover: all six directed pairs — `A↔D`
(existing) plus `P→A`, `A→P`, `P→D`, `D→P` — run deliberately, the
combinatorial token cost accepted as the price of maximal mutual
correction. The backward-compatible status reporting is fixed too: the
scalar `cross_check_status` keeps meaning the arch↔domain outcome
unchanged, and a new `pipeline_cross_check_status` (same enum, same
absence semantics) carries the pipeline's outcome. See spec §6.3.

---

## P5 — /pipeline-map command — task-driven signature, vendored-Mermaid self-contained HTML — decision-boundary

**Context**

`/diagnose` (S4) is the surfacing precedent: a human types a command, it
drives the full pipeline in `mode: full`, renders the model, and writes
on a confirm-before-write gate with the agent read-only and the command
as dispatcher. The pipeline map needs the same pattern but a **task-driven
input** (the developer states the work they are considering, not a code
area) and a **Mermaid HTML** render target.

**Decision content**

How a task-scoped flow graph becomes a self-contained HTML artefact that
honours the project's surfacing pattern. The command's task-driven
contract (`/pipeline-map "<task>" [--near <path>] [--out <dir>]` — a
required quoted task description, an optional search-narrowing hint, a
task-derived output filename); the Mermaid projection (stage `kind` →
flowchart shape; `condition` and `PipelineTransition.condition_label` →
edge labels; node text → number + label + file path — all renderer-derived
from the display-agnostic model); the vendoring and provenance
discipline for the Mermaid asset (self-contained, no CDN, version-pinned,
SHA recorded — a supply-chain decision the repo's dependency-audit culture
cares about); and the page layout — the diagram, a node-detail table
(evidence, confidence, Q/CC notes), and a **scope-resolution panel** that
surfaces the P2 provenance (task, in-scope, adjacent-excluded, confidence)
so the developer sees both the map and why this slice was chosen. The
command owns the single Write, substitutes `<DISPATCHER: ...>`, runs an
output validation checkpoint (joining the CLAUDE.md checkpoint list), and
gates on a human accept.

**Dependencies**

P3 at minimum (a pipeline collection to render) and P2 (the
scope-resolution panel's content). P4 is the design target ("full
treatment") but can be pulled after P5 if a visible map is wanted sooner
— see the sequencing note.

**Rationale**

Separating the surfacing interface makes the output contract a deliberate
decision and makes the end-to-end completeness of P1–P4 observable: those
slices are verified structurally, but P5 is where a developer states a
real task and sees the bounded map, and can judge whether the legibility
goal is met. Mirrors S4's role for `/diagnose`.

**P5 deliverables fixed by the diaboli gate.** (1) A `<noscript>`
plain-text-outline **static fallback** so the artefact is readable without
JavaScript (O5). (2) The Mermaid bundle is **inlined** for a portable
single file (O6). (3) A **"structural — not executed" banner** and **no**
reserved live legend, so the static map is not misread as a live view
(O12). (4) The **how-to and reference docs-site pages** ship in the same
PR as an explicit deliverable, not a follow-on (O9). See spec §7.

---

## P6 — Live overlay — execution-trace status on the map (deferred) — decision-boundary

**Context**

The reference image is titled "(live)" and overlays execution status —
green check / grey circle — and a "Condition: … Actual: 0.82 (true)"
annotation on the gate. That is ground-truth runtime data, not static
structure.

**Decision content**

Where execution status comes from and how it binds to nodes: the
trace-input format and the node↔trace matching contract (by file-path
evidence? by an explicit node-id annotation in traced code? by span
name?), plus the honesty handling of unmatched nodes — no matching record
means "not observed", distinct from "not executed".

**Dependencies**

P1–P5 (a rendered task-scoped static map to overlay). Deferred per the
human's slice-1 decision; recorded so P1–P5 keep the seam open (stable
node ids, per-node evidence, a Mermaid `class` hook on every node).

**Rationale**

Deferring keeps the first increment a clean static-structure map and
avoids binding the schema to a trace format before the static map has
proven its shape.

---

## Sequencing recommendation — committed (diaboli O11)

P1 → P2 → P3 → P4 → P5, then P6 when scheduled. The ordering is **fixed**,
not left open (diaboli O11 / O1):

- **P2 ships a standalone "what does my task touch?" surface** — a minimal
  render of `scope_resolution`, **no map** — as the **first human-visible
  slice**. The task→scope relevance bound is the load-bearing bet (diaboli
  O1); putting a human in front of the in-scope / adjacent-excluded /
  confidence disclosure after *one* slice (rather than after four) is the
  cheapest lever on that risk. P2 also carries an explicit acceptance step:
  hand-validation against a handful of worked tasks on a real repo before
  P3 builds on the bound.
- **P4 stays before P5**, so the full Mermaid map a developer first sees at
  P5 is already mutually corrected by the three-way cross-check. (The
  earlier "pull P5 ahead of P4" option is **not** taken — the standalone P2
  surface already supplies the early human-visible feedback that
  motivated it.)

This is a near-strict dependency order regardless: the schema must exist
before scope-resolution provenance can be recorded; the task must be
resolved to a bound before flow is traced within it; the pipeline must be
built before it can be cross-checked; and the cross-checked, task-scoped
model is what the full surface renders.

## Explicitly not slicing on

- **Marking which nodes the task will *modify* (change-site prediction).**
  Resolving the bounded scope (P2) and predicting *where in the pipeline
  the change lands* are close but distinct: the first is "what does my task
  touch?", the second is "which node will I edit?". The task framing
  invites the second as a natural extension (and the P2 relevance pass
  surfaces most of the signal for it), but it is a separable feature with
  its own honesty burden and is **not** folded into these slices. It is
  recorded here as a candidate follow-on for the human to dispose, not a
  scheduled slice. **Disposed (2026-06-10): filed as follow-on issue
  [#368](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/368)**
  — tracked, not scheduled into P1–P5.

- **Mermaid as a sub-slice of P5.** Wiring the renderer is the
  implementation of P5's rendering decision, not a separate decision.

- **Entry-point discovery as its own slice.** How the flow-tracing pass
  finds where a process starts is implementation inside P3.

- **`--near` parsing / scope-hint heuristics as a slice.** The optional
  hint is a parameter of P2's relevance decision, not a decision of its
  own.

- **The node-detail table vs. diagram vs. scope-panel layout.** Where each
  renders in the HTML is layout implementation within P5.

- **Version-bump and marketplace registration steps.** Mechanical per-slice
  follow-ons per CLAUDE.md, not slices.

- **Hallucination reduction on flow and scope claims.** A quality property
  of P2's disclosure, P3's challenge cover, and P4's cross-check, not a
  separable feature with its own observable output.
