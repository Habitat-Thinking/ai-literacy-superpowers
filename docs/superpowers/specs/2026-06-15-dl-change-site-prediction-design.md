# Diagnostic Legibility — Change-Site Prediction — Capability Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-15 |
| Status | Drafted — ready for spec-mode diaboli, then plan/implementation |
| Author | claude-opus-4-8[1m] (interactive session with russmiles) |
| Capability | Given a work task and its task-scoped pipeline map, predict **which pipeline nodes the task will modify** (and where new nodes will be inserted) — distinct from which slice the task *touches* — and disclose the prediction honestly |
| Follow-on of | the task-scoped conceptual pipeline map (P1–P5, spec `2026-06-03-dl-pipeline-map-design.md`); filed as #368 |
| Plugin version target | `diagnostic-legibility` v0.10.0 → v0.11.0 |

---

## 1. Premise

The shipped pipeline map (P1–P5) answers *"what does my task touch?"* —
it resolves a bounded scope (`scope_resolution`), traces the control flow
within it (`mode: pipeline`), and renders it (`/pipeline-map`). It is
deliberately silent on a second, closely-related question the task framing
invites: *"which node will I actually **edit**?"*

That second question — **change-site prediction** — was deferred from
P1–P5 (spec §3.3, slicing record "explicitly not slicing on") and filed
as #368 *for the human to dispose*, precisely because it carries a
**distinct and heavier honesty burden**:

- **Scope is verifiable; the change site is a prediction about future
  human action.** "These files are touched" can be checked by reading the
  code. "You will edit *here*" is a guess about what a developer will do
  next — far easier to assert with false confidence.
- The two are genuinely different sets. A node can be **in scope but not a
  change site** (read/traversed to understand the flow, never modified),
  and the touched bound usually contains *more* nodes than the change
  touches.

This capability adds the prediction **as an explicit, opt-in layer** over
the existing map — never silently, never as a directive.

## 2. Fixed design inputs (human decisions, 2026-06-15)

1. **Opt-in, not always-on.** Change-site prediction ships as a new
   `mode: change-prediction` and a `/pipeline-map --predict-change` flag.
   `mode: pipeline` is **unchanged** — it still emits a map with **no**
   change prediction. This honours the original deferral ("a separable
   feature … not folded into these slices") and keeps the riskier
   prediction off the default path.
2. **v1 predicts both modify and insert sites.** It predicts both edits to
   **existing** stages and **insertion points** for **new** stages (the
   motivating task — "add a fraud-hold step after risk evaluation" — is an
   insertion). Removal/rerouting is out of scope for v1.
3. **It predicts; it never directs.** The output is a disclosed
   prediction with reasons and a confidence, never an instruction ("edit
   X"). The honesty contract (§5) is the heart of the feature, not polish.

## 3. The model — an additive `change_prediction` block (no new template)

Change-site prediction is recorded as an **additive, optional
`change_prediction` block on the `ConceptualPipelineMap` wrapper**
(`templates/conceptual-pipeline-map.md`) — not a new model and not a
field on every `PipelineStage`. Rationale:

- It is **about the map**, referencing stages **by `id`** (exactly as
  `scope_resolution` references files by `path`), so it belongs on the map
  wrapper, keeping each `PipelineStage` clean.
- **Additive and optional**: absence means "change prediction was not
  run" (back-compat — every v0.10.0 map is still valid). The map remains
  valid and renderable without it; P1's decoupling holds.

### 3.1 Shape

```yaml
change_prediction:
  predicted_sites:
    - target: risk-gate              # an existing stage id (kind: modify)
      kind: modify
      reason: "the task changes the post-risk routing; the gate's branch is edited"
    - target: "after:risk-gate"      # an insertion point relative to a stage (kind: insert)
      kind: insert
      reason: "'add a fraud-hold step after risk evaluation' inserts a new stage on the path out of the risk gate"
  change_confidence: medium
```

| Field | Type | Required (within the block) | Purpose |
| --- | --- | --- | --- |
| `predicted_sites` | list of object | yes (may be empty) | The predicted edit locations. Empty `[]` is a valid honest result ("the task touches this process but no edit site could be predicted"). |
| `predicted_sites[].target` | string | yes | For `kind: modify`, an existing `stage.id`. For `kind: insert`, an **insertion point** written `after:<stage-id>` or `before:<stage-id>` (the new stage does not exist yet, so it has no id — it is located relative to one that does). |
| `predicted_sites[].kind` | enum | yes | `modify` (edit an existing stage) or `insert` (add a new stage at the insertion point). The two have different epistemic bases and are never conflated. |
| `predicted_sites[].reason` | string | yes | Why this is a predicted edit site, in the task's terms. The per-site honesty unit. |
| `change_confidence` | enum | yes | `low \| medium \| high` in the prediction as a whole. |

### 3.2 Distinct from `scope_resolution`

`scope_resolution.in_scope` is the **touched** set (read or needed);
`change_prediction.predicted_sites` is the **edited** set (modified or
inserted). The predicted sites are normally a **subset of, or insertions
relative to,** the in-scope stages — but the block does **not** re-derive
scope, and a `modify` target **must** reference a stage that exists in
`stages`. An `insert` target's `after:`/`before:` anchor must likewise
reference an existing `stage.id`.

## 4. The agent — `mode: change-prediction` (v0.11.0)

A fifth mode, a **superset of `mode: pipeline`**:

1. Run the full **Pipeline protocol** (resolve bound → Phase A trace +
   build → Phase B self-challenge → Phase C three-way cross-check),
   exactly as `mode: pipeline`.
2. Then run the **change-prediction pass**: from the task intent and the
   built map, predict the modify/insert sites and populate
   `change_prediction`.

Inputs are identical to `mode: pipeline` (`task:` required, `near:`
optional). Output is the same **two-block** response
(`ConceptualPipelineMap` + `LegibilityModel`); the map additionally
carries the `change_prediction` block. Read-only trust boundary
(`Read`, `Glob`, `Grep`) is **unchanged** — predicting is reasoning over
what was already read, not new capability.

### 4.1 The change-prediction pass

1. **Read the task's change verbs.** Distinguish *add/insert/new* (→
   `insert`) from *change/alter/modify/fix* (→ `modify`). A task may imply
   both.
2. **Locate the site against the built map.** For an insert, find the
   anchor stage and direction (`after:`/`before:`) the task's phrasing
   implies. For a modify, find the existing stage whose logic/condition
   the task changes.
3. **Ground each site in a reason** in the task's terms, and **only**
   against stages that exist in the map (a `modify` target must be a real
   `stage.id`; an `insert` anchor must be a real `stage.id`).
4. **Disclose** per the honesty contract (§5).

## 5. The honesty contract (the load-bearing part)

Change-site prediction is a prediction about future human action, so the
contract is **stronger** than scope resolution's:

- **Predict, never direct.** Every site is phrased as a prediction
  ("the task likely edits …"), never an instruction ("edit …"). No
  imperative, no "you must/should". A directive phrasing is an
  anti-pattern.
- **Per-site reasons are mandatory.** Each `predicted_sites[]` entry
  carries a `reason` grounded in the task and the map. No bare site.
- **Failure direction below `high`.** When `change_confidence` is below
  `high`, at least one `reason` (or a clearly-marked note) names the
  suspected failure **direction**:
  - **over-prediction** — "may flag a node the task will not actually
    edit" (the prediction reached too far);
  - **under-prediction** — "may miss a node the task will edit" (the
    prediction is too narrow).
  A single scalar cannot say which way an uncertain prediction failed, and
  the two demand opposite remedies — exactly the §3.2 rationale from the
  pipeline-map spec, applied to edits.
- **Empty is honest.** A task that touches a process but yields no
  confident edit-site prediction emits `predicted_sites: []` with
  `change_confidence: low` and a reason — never an invented site.
- **`modify` vs `insert` never conflated.** They rest on different
  evidence (an existing stage's logic vs the task's add-a-thing phrasing);
  mislabelling one as the other is an anti-pattern.

## 6. The command — `/pipeline-map … --predict-change`

`--predict-change` is an optional flag on the existing command. When
present:

- The command dispatches `mode: change-prediction` instead of
  `mode: pipeline`.
- The render gains:
  - **Predicted change sites highlighted** in the Mermaid diagram — a
    `classDef change-site` on `modify` stages, and a marked insertion
    indicator at each `insert` anchor (renderer-derived from
    `change_prediction`; the model stores no styling).
  - **A "Predicted change sites" panel** surfacing `predicted_sites`
    (target, kind, reason), `change_confidence`, and the suspected failure
    direction when confidence < `high`.
  - The `<noscript>` outline and the stage-detail table **flag** which
    stages are predicted change sites.
  - The **structural banner** already states the map is not an executed
    run; with `--predict-change` it also states the change sites are
    **predictions, not directives**.

Without the flag, `/pipeline-map` behaves exactly as v0.10.0 (no change
prediction, no panel, no highlight). The output validation checkpoint
gains (only when the flag is set): the predicted-sites panel is present
and consistent with `change_prediction`; every `modify` target and every
`insert` anchor references a rendered `stage.id`; no directive phrasing
leaked into the render.

## 7. Out of scope

- **Removal / rerouting prediction.** v1 predicts modify + insert only.
- **Ranking or effort-sizing the edits.** No "this is a 2-hour change".
- **Multi-task prediction.** One task per invocation, as the map is.
- **Auto-editing.** The agent predicts; it never edits (read-only).
- **A new model or a per-stage field.** The prediction is an additive
  wrapper block, nothing more.

## 8. Spec-mode diaboli

This spec goes through the spec-mode `/diaboli` gate before
implementation; objections are recorded at
`docs/superpowers/objections/dl-change-site-prediction-design.md` and
absorbed here.

## 9. References

- Pipeline-map spec (the feature this extends): `docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md` (esp. §3.2 failure-direction, §3.3 the deferral).
- Slicing record follow-on disposition: `docs/superpowers/slices/diagnostic-legibility-pipeline-map.md` ("Explicitly not slicing on").
- The model: `diagnostic-legibility/templates/conceptual-pipeline-map.md`.
- The agent: `diagnostic-legibility/agents/diagnostic-legibility.agent.md` (`mode: pipeline`).
- The command: `diagnostic-legibility/commands/pipeline-map.md`.
- Issue: #368.
