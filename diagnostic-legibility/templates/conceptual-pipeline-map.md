# ConceptualPipelineMap

The data model for a **conceptual pipeline map**: a traced process through
a codebase scope, expressed as stages connected by transitions, with
decision points, grounding, and the provenance of the scope it was drawn
for.

This model is defined **in its own right** — independent of who produces
it and independent of how it is shown. It is:

- **Presentation-agnostic.** The model carries no numbering, shapes,
  colours, layout, node text, or target format. A renderer derives all of
  those. The same model can be projected to a Mermaid flowchart, a Graphviz
  graph, an SVG, a JSON export, or a plain-text outline without changing
  one field.
- **Producer-agnostic.** The model says nothing about how it was traced,
  where it is stored, or what renders it. The diagnostic-legibility agent
  is the first producer, but the model does not depend on it.

**What the model is *not* agnostic about.** It is **not structure-free**,
and that is deliberate. It embeds a **conceptual control-flow ontology** —
a process genuinely *has* an order, decision points, and terminal
outcomes, independent of how any of them are drawn. So `kind: decision` is
a **conceptual** property of a stage ("this stage branches"), not a render
hint; the *diamond* a renderer draws for it is the presentation. The
decoupling holds for the **glyph**, not for the **existence** of the
decision. (Hence "presentation-agnostic", not the over-broad
"implementation-agnostic": the model commits to *what the process is*, and
declines only to say *how it looks*.)

The point of the separation: the **producer**, the **model**, and the
**renderer** are independently replaceable. A consumer (a tool, a report,
a future live-overlay layer) reads the model without knowing or caring how
it was built or how it will be drawn.

## Why its own model (not a collection on `LegibilityModel`)

`LegibilityModel` (see `legibility-element.md`) holds two **flat
enumerations** — `architectural[]` and `domain[]` — that answer *what is
here*. A pipeline map answers *how a process runs*: it has ordering,
branching, decisions, and convergence, which a flat list cannot express.
Folding the pipeline into `LegibilityModel` would entangle two distinct
artefacts and tempt the schema toward whatever the first renderer happened
to need. Keeping `ConceptualPipelineMap` standalone lets it be produced,
cross-checked, rendered, and consumed on its own terms.

It **cross-references** the legibility models (a stage may `realises` an
architectural element and/or a domain concept by name), but it does not
**contain** them and is valid without them.

## Top-level: `ConceptualPipelineMap`

| Field | Type | Required | Purpose |
| --- | --- | --- | --- |
| `task` | string | yes | The work task the map was scoped to — the question it answers (e.g. `"add a fraud-hold step after risk evaluation"`). Conceptual provenance, not a code path. |
| `scope_resolution` | `ScopeResolution` | yes | The derived, disclosed bound the map covers (§`ScopeResolution`). Because the scope is *inferred from the task* rather than handed in, the model records the inference so a reader can audit it. |
| `entry` | list of string | yes | The `id`(s) of the stage(s) where the process begins. Each must reference an existing stage. |
| `stages` | list of `PipelineStage` | yes | The conceptual stages of the process. May be empty **only** to express "the task resolved to no process" (see validation). |
| `transitions` | list of `PipelineTransition` | yes | The directed flow between stages, with optional branch conditions. |
| `pipeline_cross_check_status` | enum | no (additive, v0.9.0) | The outcome of the **pipeline's** participation in the three-way cross-check (Phase C across pipeline + architectural + domain). One of `completed \| skipped_asymmetric \| not_run`; **absence means `not_run`** (back-compat with v0.8.0 maps that pre-date the field). It is the pipeline-side sibling of the `LegibilityModel.cross_check_status` scalar — which keeps its **unchanged** meaning, the *arch↔domain* outcome. Kept on the **map** (not the `LegibilityModel`) so each model stays self-describing about its own cross-check; a v0.5.0/v0.8.0 consumer reading only `cross_check_status` is unaffected and ignores this field. See §Cross-check status. |
| `generated_at` | string (ISO 8601) | yes | Provenance timestamp. Dispatcher-filled via the `<DISPATCHER: ...>` placeholder, as in `LegibilityModel`. |
| `generated_by` | string | yes | Producer + model identifier. Dispatcher-filled. |

## `PipelineStage`

A single conceptual stage of the process. A first-class, challengeable
element: it reuses the legibility discipline's `confidence` and
`challenge_notes[]` so a stage is an auditable claim, not a bare vertex.

| Field | Type | Required | Purpose |
| --- | --- | --- | --- |
| `id` | string | yes | A **stable, opaque** identifier (a slug such as `risk-gate`, not a display number). Referenced by `entry`, `transitions`, `part_of`, and cross-model links. Stable across re-runs where the code is unchanged — this stability is the seam a future live-overlay binds to. **Not** a presentation number: `"1"`, `"5A"`, `"5A.1"` are *renderer-derived*, never stored here. |
| `label` | string | yes | Human-readable name of the stage (`"Risk Gate"`, `"Request Ingestion"`). |
| `kind` | enum | yes | Conceptual role: `step` (an ordinary stage), `decision` (a branch point; carries a `condition`), or `outcome` (a terminal result/sink). The conceptual category only — *not* a shape. |
| `condition` | string | no | **`decision` stages only.** The decision rule in the terms the process expresses it (`"riskScore > 0.65"`). A conceptual rule, *not* a runtime value — the actual evaluated result is live data and is not part of this static model. |
| `part_of` | string | no | Optional conceptual grouping: the `id` of a stage or sub-process this stage is a sub-step of. Expresses hierarchy **structurally**; any sub-step numbering (e.g. the renderer showing `5A.1`) is derived from this, never stored. |
| `realises` | object | no | Optional cross-references to the legibility models: `{ architectural?: <element name>, domain?: <concept name> }`. The map is valid without them; they are the seam cross-check uses. |
| `evidence` | list of `{ path, excerpt? }` | yes | Grounding citations for the stage. At least one entry when `confidence` is `medium` or `high` (same rule as `LegibilityElement`). Grounding is provenance, not an implementation binding. |
| `confidence` | enum | yes | `low` \| `medium` \| `high`. Epistemic calibration of this stage as a claim. |
| `challenge_notes` | list of string | yes | The diagnostic audit trail: `Q<N> (question-name):` self-challenge notes, `CC<N> (question-name):` cross-check notes, and the two reserved sentinels — exactly the convention in `legibility-element.md`. May be empty only before the challenge protocol has run. |

## `PipelineTransition`

A directed flow from one stage to another. A transition is a claim too
("control passes from `risk-gate` to `risk-review` when `riskScore > 0.65`"),
so it may carry its own grounding.

| Field | Type | Required | Purpose |
| --- | --- | --- | --- |
| `from` | string | yes | Source stage `id`. |
| `to` | string | yes | Target stage `id`. |
| `condition_label` | string | no | The branch condition under which this transition is taken (`"≤ 0.65"`). Absent on a plain sequence transition. Conceptual. |
| `kind` | enum | no | Conceptual role: `sequence` \| `branch` \| `converge`. Defaults to `sequence`. |
| `evidence` | list of `{ path, excerpt? }` | no | Optional citation of the branch/dispatch site that realises the transition. |

## `ScopeResolution`

The disclosed provenance of the **derived** scope. The scope is inferred
from the `task`, not handed in, so it is a *prediction* that can under- or
over-reach. This record makes the prediction auditable; a producer must
not present a silent boundary as fact.

| Field | Type | Required | Purpose |
| --- | --- | --- | --- |
| `in_scope` | list of `{ path, reason }` | yes | The files/areas judged part of the touched process, each with a one-line reason. |
| `adjacent_excluded` | list of `{ path, reason }` | yes (may be empty) | What was seen and **consciously left out** as adjacent-but-not-touched, each with a reason. The load-bearing honesty field: it names the boundary the producer chose. |
| `scope_confidence` | enum | yes | `low` \| `medium` \| `high`. Confidence in the derived bound. **When below `high`, the producer must name the suspected failure *direction* in `adjacent_excluded`/`in_scope` reasons** — under-reach ("may have missed needed files") or over-reach ("may be wider than the task touches") — since a bare scalar cannot say which way an uncertain bound failed, and the two demand opposite remedies. |

## Equivalent type signature (documentation only)

```
ConceptualPipelineMap = {
  task: string,
  scope_resolution: ScopeResolution,
  entry: [string],
  stages: [PipelineStage],
  transitions: [PipelineTransition],
  pipeline_cross_check_status?: "completed" | "skipped_asymmetric" | "not_run",
  generated_at: string,
  generated_by: string,
}

PipelineStage = {
  id: string,
  label: string,
  kind: "step" | "decision" | "outcome",
  condition?: string,
  part_of?: string,
  realises?: { architectural?: string, domain?: string },
  evidence: [{ path: string, excerpt?: string }],
  confidence: "low" | "medium" | "high",
  challenge_notes: [string],
}

PipelineTransition = {
  from: string,
  to: string,
  condition_label?: string,
  kind?: "sequence" | "branch" | "converge",
  evidence?: [{ path: string, excerpt?: string }],
}

ScopeResolution = {
  in_scope: [{ path: string, reason: string }],
  adjacent_excluded: [{ path: string, reason: string }],
  scope_confidence: "low" | "medium" | "high",
}
```

## Cross-check status (three-way, v0.9.0)

When the map is produced alongside the architectural/domain
`LegibilityModel` (the `mode: pipeline` two-block bundle), Phase C
cross-checks **all three** collections against each other. The outcome is
reported by **two independent scalar fields**, one per model, so that
each model stays self-describing and a pre-v0.9.0 consumer is unaffected:

| Field | Lives on | Reports | Legal values |
| --- | --- | --- | --- |
| `cross_check_status` | `LegibilityModel` | the **arch↔domain** outcome — **unchanged** from v0.4.0 | `completed \| skipped_asymmetric \| not_run` |
| `pipeline_cross_check_status` | `ConceptualPipelineMap` | the **pipeline's** outcome against its peers | `completed \| skipped_asymmetric \| not_run` |

Both share the same enum and the same **absence ⇒ `not_run`** rule. The
split is the backward-compat contract: a consumer that read only
`cross_check_status` before v0.9.0 keeps reading exactly the arch↔domain
fact it always did; the pipeline outcome is additive and ignorable.

**The six directed pairs.** The maximal cover runs deliberately: the
existing `A↔D` (two directions) plus the four pipeline-touching pairs
`P→A`, `A→P`, `P→D`, `D→P`. Each pair carries direction-flavoured
weighting and its own named failure mode (agent file). `CC<N>` notes are
written on the **subject** element of each pair only — the single-writer
audit trail extended to three collections; a side-effect on another
collection is named in the subject's prose, never double-written.

**Status assignment.**

- `pipeline_cross_check_status: completed` — the pipeline was cross-checked
  against **at least one** non-empty peer collection (arch and/or domain).
- `pipeline_cross_check_status: skipped_asymmetric` — the pipeline is
  non-empty but **no** peer collection is non-empty (nothing to
  cross-check against), or the pipeline itself is the `stages: []`
  empty-task map (no stages to cross-check).
- `cross_check_status` follows its **existing** v0.4.0 rule, governing the
  arch↔domain pair only — entirely unaffected by the pipeline's presence.

A map emitted **without** running Phase C (e.g. the P3-era `mode: pipeline`
build, or any producer that stops before cross-check) carries
`pipeline_cross_check_status: not_run` (or omits it — absence means the
same).

## Validation rules

- Every `entry` id and every `transition.from` / `transition.to` must
  reference an existing `stage.id`.
- `condition` is legal **only** on a `decision` stage.
- `part_of`, when present, must reference an existing `stage.id` and must
  not form a cycle.
- `evidence` must have at least one entry when `confidence` is `medium` or
  `high`; `low`-confidence stages may have empty `evidence: []`.
- **Empty-task sentinel.** A map whose `task` resolves to no process emits
  an **empty `stages: []`** with a populated `scope_resolution` whose
  `scope_confidence` is `low` and whose reasons explain the empty result.
  This is the task-framing analogue of the `(empty scope)` sentinel in
  `legibility-element.md`: an explicit "nothing matched", never an
  invented pipeline.

  **Coexistence with the `(empty scope)` sentinel.** This sentinel governs
  the **map only** (`stages == []`). The `architectural[]` / `domain[]`
  collections emitted alongside the map follow their *own* `(empty scope)`
  rule — the `LegibilityModel` degenerate-output convention defined by the
  `diagnostic-legibility` agent (`agents/diagnostic-legibility.agent.md`)
  over the `legibility-element.md` schema — independently. The two may
  co-occur: a
  task that touches no process yields an empty map, and — if the bound also
  surfaced no parts or concepts — an `(empty scope)` element in
  `architectural[]`. A consumer matches the map's empty state on
  `stages == []` and the legibility empty state on the `(empty scope)`
  element; never one rule on the other collection.

## Boundaries — what this model deliberately excludes

These belong to **renderers** and **producers/consumers**, never to the
model. Stating them keeps the decoupling enforceable.

**Display concerns (a renderer derives these):**

- **Presentation numbering** — `"1"`, `"4"`, `"5A"`, `"5A.1"`. Derived from
  `entry` + `transitions` + `part_of` by a traversal at render time.
- **Visual form** — shapes (rectangle / diamond / stadium), colours,
  borders, icons, the executed/not-executed styling a live overlay adds.
- **Node text composition** — e.g. "number + label + file path on three
  lines" is a renderer's choice of what to show, not a model field.
- **Layout** — direction (top-down vs left-right), positioning, spacing,
  grouping boxes.
- **Target format** — Mermaid, Graphviz/DOT, SVG, HTML, JSON, plain text.
  The model is the single source all of these project from.

**Implementation concerns (a producer/consumer owns these):**

- **How the map was traced** — entry-point discovery, how far calls are
  followed, the static-analysis strategy.
- **Persistence** — whether and where the map is stored; file paths and
  formats on disk.
- **Runtime/execution overlay** — executed/not-executed status and actual
  evaluated condition values (`Actual: 0.82 (true)`). That is a *separate
  live layer* that references stages by `id`; it is not part of this
  static model.

## Example

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
      reason: "downstream notification; reached by the process but not modified by this task"
  scope_confidence: medium
entry: ["request-ingestion"]
stages:
  - id: request-ingestion
    label: "Request Ingestion"
    kind: step
    evidence:
      - path: src/refund/api/ingest.ts
    confidence: high
    challenge_notes:
      - "Challenge applied; no questions surfaced changes"
  - id: risk-gate
    label: "Risk Gate"
    kind: decision
    condition: "riskScore > 0.65"
    realises:
      domain: "Risk"
    evidence:
      - path: src/refund/risk/gate.ts
        excerpt: "if (riskScore > 0.65) return reviewPath()"
    confidence: high
    challenge_notes:
      - "Q2 (evidence): confirmed the 0.65 threshold against gate.ts rather than the comment in evaluate.ts."
  - id: risk-review
    label: "Risk Review Path"
    kind: step
    part_of: risk-gate
    evidence:
      - path: src/refund/risk/review.ts
    confidence: medium
    challenge_notes: []
transitions:
  - from: request-ingestion
    to: risk-gate
    kind: sequence
  - from: risk-gate
    to: risk-review
    condition_label: "> 0.65"
    kind: branch
generated_at: "<DISPATCHER: ISO 8601 timestamp>"
generated_by: "diagnostic-legibility / <DISPATCHER: active model identifier>"
```

Note what the example does **not** contain: no node numbers, no shapes, no
Mermaid, no layout. A renderer reading this assigns `request-ingestion`
the number `1`, draws `risk-gate` as a decision diamond, numbers
`risk-review` as a sub-step of the gate, and lays it out — all derived,
none stored.
