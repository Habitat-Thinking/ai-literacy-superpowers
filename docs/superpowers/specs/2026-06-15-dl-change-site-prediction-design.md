# Diagnostic Legibility — Change-Site Prediction — Capability Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-15 |
| Status | Diaboli-complete — 12 objections raised, all accepted and absorbed; ready for plan/implementation |
| Author | claude-opus-4-8[1m] (interactive session with russmiles) |
| Capability | Given a work task and its task-scoped pipeline map, predict **which pipeline nodes the task will modify** (and where new nodes will be inserted) — distinct from which slice the task *touches* — and disclose the prediction honestly |
| Follow-on of | the task-scoped conceptual pipeline map (P1–P5, spec `2026-06-03-dl-pipeline-map-design.md`); filed as #368 |
| Plugin version target | `diagnostic-legibility` v0.10.0 → v0.11.0 |
| Diaboli record | `docs/superpowers/objections/dl-change-site-prediction-design.md` (12 objections, all accepted) |

---

## 1. Premise

The shipped pipeline map (P1–P5) answers *"what does my task touch?"* —
it resolves a bounded scope (`scope_resolution`), traces the control flow
within it (`mode: pipeline`), and renders it (`/pipeline-map`). It is
deliberately silent on a second question the task framing invites:
*"which node will I actually **edit**?"* — **change-site prediction**,
deferred from P1–P5 and filed as #368 *for the human to dispose*.

**The primary value is narrowing, not the insert (diaboli O9).** The
strongest case for this capability is the **modify-narrowing** one: the
touched bound (`scope_resolution.in_scope`) is deliberately wide — the
directly-touched process **plus one hop of context** — and usually
contains *more* nodes than the change actually edits. Change-site
prediction narrows that wide touched-set to the **few nodes the task will
modify**, which is exactly where the two sets most diverge and where the
scope panel alone leaves the developer guessing. The secondary case is the
**insert**: a structural change (a new stage) located relative to an
existing one. (For a pure insert the anchor often restates the scope plus
the task verb, so its marginal information over the scope panel is
thinner — it earns its place as the structural complement to modify, not
as the headline.)

This is a prediction about **future human action**, which carries a
**distinct and heavier honesty burden** than the verifiable scope beside
it: "these files are touched" can be checked by reading; "you will edit
*here*" is a guess, far easier to assert with false confidence. The
capability therefore ships as an **explicit, opt-in layer** over the
existing map — never silently, never as a directive.

## 2. Fixed design inputs (human decisions, 2026-06-15)

1. **Opt-in, not always-on.** Ships as a new `mode: change-prediction`
   and a `/pipeline-map --predict-change` flag. `mode: pipeline` is
   **unchanged** — it still emits a map with **no** change prediction.
   This honours the original deferral and keeps the riskier prediction off
   the default path.
2. **v1 predicts both modify and insert sites.** Edits to **existing**
   stages and **insertion points** for **new** stages. Removal/rerouting
   is out of v1 scope.
3. **It predicts; it never directs.** A disclosed prediction with reasons,
   evidence, and a confidence — never an instruction. The honesty contract
   (§5) is the heart of the feature.

## 3. The model — an additive `change_prediction` block (no new template)

Change-site prediction is recorded as an **additive, optional
`change_prediction` block on the `ConceptualPipelineMap` wrapper**
(`templates/conceptual-pipeline-map.md`) — not a new model and not a
field on every `PipelineStage`. It is *about the map*, referencing stages
**by `id`** (as `scope_resolution` references files by `path`). Absence
means "change prediction was not run" (back-compat — every v0.10.0 map is
still valid and renderable; P1's decoupling holds).

**Closes the pipeline-map open question (diaboli O7).** The pipeline-map
spec §9.2.3 left open whether P1 should reserve a per-stage
`task_relevance` marker for this follow-on. This spec **closes** it: the
wrapper `change_prediction` block subsumes that need; **no** per-stage
marker is added. One representation of stage-level task implication.

### 3.1 Shape

```yaml
change_prediction:
  predicted_sites:
    - kind: modify                 # edit an existing stage
      target: risk-gate            # an existing stage.id
      reason: "the task changes the post-risk routing; the gate's branch is edited"
      evidence:
        - path: src/refund/risk/gate.ts
          excerpt: "if (riskScore > 0.65) return reviewPath()"
    - kind: insert                 # add a new stage at an insertion point
      anchor: risk-gate            # an existing stage.id the new stage is placed relative to
      position: after              # after | before
      reason: "'add a fraud-hold step after risk evaluation' inserts a new stage on the path out of the risk gate"
      evidence:
        - path: src/refund/risk/gate.ts
  change_confidence: medium
  change_direction: under-prediction   # required when change_confidence < high
```

| Field | Type | Required (within the block) | Purpose |
| --- | --- | --- | --- |
| `predicted_sites` | list of object | yes (may be empty) | The predicted edit locations. Empty `[]` is a valid honest result. |
| `predicted_sites[].kind` | enum | yes | `modify` (edit an existing stage) or `insert` (add a new stage). Different epistemic bases; **best-judgement labels** (see §5) — not a hard guarantee. |
| `predicted_sites[].target` | string | **`modify` only** | The existing `stage.id` the task edits. Must reference a stage in `stages` **and** be in `scope_resolution.in_scope` (§3.2). |
| `predicted_sites[].anchor` | string | **`insert` only** | The existing `stage.id` the new stage is placed relative to (typed, not an in-string convention). Same in-scope rule. |
| `predicted_sites[].position` | enum | **`insert` only** | `after` or `before` — where the new stage goes relative to `anchor`. |
| `predicted_sites[].reason` | string | yes | Why this is a predicted edit site, in the task's terms. |
| `predicted_sites[].evidence` | list of `{ path, excerpt? }` | required for `modify` at `change_confidence` ≥ medium; encouraged for `insert` | Grounding citation (diaboli O6) — the checkable artefact behind the prediction, bringing it in line with `PipelineStage`/transition grounding. |
| `change_confidence` | enum | yes | `low \| medium \| high`. The **minimum** over the predicted sites (the honest floor, diaboli O11) — a confident insert beside a guessy modify reports the lower value. |
| `change_direction` | enum | **required when `change_confidence < high`** | `over-prediction` (may flag a node the task will not edit) or `under-prediction` (may miss a node the task will edit). The **structured** carrier for the failure-direction disclosure (diaboli O1) — present even in the empty case, where no `reason` exists to hold it. Omitted only when `change_confidence: high`. |

### 3.2 Distinct from `scope_resolution`, and consistent with it

`scope_resolution.in_scope` is the **touched** set; `predicted_sites` is
the **edited** set — normally a subset of, or insertions relative to, the
in-scope stages. The rule (diaboli O8): a `modify` `target` and an
`insert` `anchor` **must reference a stage that is in
`scope_resolution.in_scope`**, not a context-only/adjacent stage — so the
prediction panel can never contradict the scope panel. If prediction needs
an edit site the bound disclosed as adjacent, that is an **under-reach
signal fed back into `scope_resolution`** (the same Phase B
scope-relevance loop the pipeline build uses), promoting the stage into
`in_scope` with a reason — never a silent contradiction across the two
panels.

### 3.3 Template validation rules (added to `conceptual-pipeline-map.md`)

- `change_prediction` is optional; absence ⇒ "not run".
- Each `predicted_sites[]` has a legal `kind` (`modify | insert`).
- `kind: modify` ⇒ `target` present, references an existing `stage.id`,
  and that id is in `scope_resolution.in_scope`. `anchor`/`position`
  absent.
- `kind: insert` ⇒ `anchor` present (existing `stage.id`, in `in_scope`)
  **and** `position` present and legal (`after | before`). `target`
  absent.
- `evidence` required on a `modify` site when `change_confidence` is
  `medium` or `high`.
- `change_confidence` legal enum; equals the minimum site confidence.
- `change_direction` present **iff** `change_confidence < high`, legal
  enum (`over-prediction | under-prediction`).
- Empty `predicted_sites: []` ⇒ `change_confidence: low` and
  `change_direction` present (the honest empty result).

## 4. The agent — `mode: change-prediction` (v0.11.0)

A fifth mode, a **superset of `mode: pipeline`**:

1. Run the full **Pipeline protocol** (resolve bound → Phase A trace +
   build → Phase B self-challenge → Phase C three-way cross-check).
2. Then run the **change-prediction pass** (§4.1), populating
   `change_prediction`.

Inputs are identical to `mode: pipeline` (`task:` required, `near:`
optional). Output is the same **two-block** response; the map additionally
carries `change_prediction`. Read-only trust boundary unchanged.

**Agent-file deltas this mode requires, in lockstep (diaboli O2).** The
agent currently recognises **four** modes and its refusal contract names
them as a **closed set**; adding a fifth without these edits would make the
agent refuse its own new mode. Implementation MUST update, together:

- the Inputs **mode list** ("Four modes … at v0.9.0" → "Five modes … at
  v0.11.0") with a `mode: change-prediction` bullet;
- the **inputs subsection** for the new mode (same `task:`/`near:` as
  pipeline);
- the **unrecognised-mode refusal example** (add `'change-prediction'` to
  the legal-values list);
- the **missing-task refusal example** for the new mode;
- the **frontmatter `description`** (five mode markers; name the
  capability and its `predict-not-direct` honesty contract).

**Alternative weighed (diaboli O12).** A cheaper *consume-an-existing-map*
prediction pass (mirroring `cross-check-only`'s fenced-payload pattern)
was considered: predict over a map already generated and trusted, without
re-paying for the trace + six-pair cross-check. The **superset
construction is chosen** for v1 because the primary surface is the
**one-shot** `/pipeline-map --predict-change` (the developer states a task
and gets the predicted map in a single step, not a two-step
map-then-feed). The consume-a-map payload form is recorded as a
**deliberately-deferred** follow-on affordance, not built in v1.

### 4.1 The change-prediction pass

1. **Read the task's change intent.** *add/insert/new* leans `insert`;
   *change/alter/modify/fix* leans `modify`. A task may imply **both** (the
   motivating example inserts a step **and** modifies the gate's routing).
2. **Locate the site against the built map.** For `insert`, the `anchor`
   stage and `position` the task implies. For `modify`, the existing stage
   whose logic/condition the task changes.
3. **Ground each site in evidence** (the implicated code) and a reason in
   the task's terms — only against stages that exist **and are in-scope**
   (§3.2). If a needed site is out-of-scope, feed it back to
   `scope_resolution` first.
4. **Disclose** per the honesty contract (§5): set `change_confidence` to
   the minimum site confidence and, when below `high`, the
   `change_direction`.

## 5. The honesty contract (the load-bearing part)

Stronger than scope-resolution's, because it predicts future human action:

- **Predict, never direct.** Every site is phrased as a prediction ("the
  task likely edits …"), never an instruction. No imperative, no
  "you must/should". Directive phrasing is an anti-pattern — enforced in
  the model text **and at the render's point of emphasis** (§6).
- **Per-site reasons and evidence.** Each site carries a `reason`; a
  `modify` site at `medium`/`high` confidence carries `evidence` (diaboli
  O6) — the checkable artefact, not prose alone.
- **Structured failure direction below `high` (diaboli O1).** When
  `change_confidence < high`, the `change_direction` field
  (`over-prediction | under-prediction`) is **mandatory** — a *structured*
  carrier present even in the empty case, so a programmatic consumer and
  the render checkpoint can read it. A single scalar cannot say which way
  an uncertain prediction failed, and the two demand opposite remedies.
- **`change_confidence` is the floor (diaboli O11).** The minimum over
  sites; mixed certainty is named in `change_direction`/reasons.
- **Empty is honest.** A process with no confident edit-site prediction
  emits `predicted_sites: []`, `change_confidence: low`, and a
  `change_direction` — never an invented site.
- **`modify` vs `insert` is best-judgement, not a guarantee (diaboli
  O5).** The kind is labelled from the task intent grounded in code
  evidence where available, and **may be wrong** — misclassification is one
  of the failures `change_direction` covers. The earlier "never conflated"
  claim is withdrawn; a task may legitimately imply both kinds.

## 6. The command — `/pipeline-map … --predict-change`

`--predict-change` is an optional flag on the existing command. When
present, the command dispatches `mode: change-prediction` (instead of
`mode: pipeline`) and the render gains:

- **Predicted change sites highlighted** in the Mermaid diagram — a
  `classDef change-site` on `modify` stages and a marked insertion
  indicator at each `insert` anchor (renderer-derived from
  `change_prediction`; the model stores no styling).
- **Anti-directive framing at the point of emphasis (diaboli O4)** — not
  just a banner. Every highlighted node carries a **"predicted" badge**;
  the **legend** keys the highlight to *"prediction, not instruction"*;
  the panel phrases every site as *"likely edits …"*. The structural
  banner additionally states the change sites are **predictions, not
  directives**.
- **A "Predicted change sites" panel** surfacing each site (kind, target
  or anchor+position, reason, evidence), `change_confidence`, and
  `change_direction` when confidence < `high`.
- The `<noscript>` outline and the stage-detail table **flag** which
  stages are predicted change sites.

Without the flag, `/pipeline-map` behaves exactly as v0.10.0. The output
validation checkpoint gains (only when the flag is set): the
predicted-sites panel is present and consistent with `change_prediction`;
every `modify` target and `insert` anchor references a rendered `stage.id`
**that is in the scope panel's in-scope set**; `change_direction` is
present and rendered when confidence < high; and **no imperative/directive
phrasing** appears in the panel or banner.

**Docs are an explicit same-PR deliverable (diaboli O10).** The
`run-the-pipeline-map-command` how-to and the `pipeline-map-command`
reference are updated for the `--predict-change` flag and the
predicted-change-sites surface (CLAUDE.md Docs Site Review). The CLAUDE.md
Output Validation Checkpoints entry for `/pipeline-map` already covers the
command; its checkpoint scope grows with the flag.

## 7. Out of scope

- **Removal / rerouting prediction.** v1 predicts modify + insert only.
- **Ranking or effort-sizing the edits.**
- **The consume-an-existing-map prediction mode** (diaboli O12 — deferred
  follow-on affordance).
- **Multi-task prediction; auto-editing** (the agent predicts, never
  edits — read-only).
- **A new model or a per-stage field** (the prediction is an additive
  wrapper block).

## 8. Spec-mode diaboli — outcomes

The spec-mode `/diaboli` gate raised **12 objections**
(`docs/superpowers/objections/dl-change-site-prediction-design.md`) —
1 critical, 4 high, 7 medium — **all accepted** and absorbed above. Load-
bearing: O2 (agent mode-enum lockstep deltas), O1/O11 (structured
`change_direction` + confidence-as-floor), O3 (typed `anchor`/`position`
+ template validation rules), O4 (anti-directive framing at the point of
emphasis), O5/O6/O8 (best-judgement kind + evidence grounding + in-scope
targets).

## 9. References

- Pipeline-map spec: `docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md` (§3.2 failure-direction, §3.3 the deferral, §9.2.3 the closed `task_relevance` question).
- Slicing record follow-on disposition: `docs/superpowers/slices/diagnostic-legibility-pipeline-map.md`.
- The model: `diagnostic-legibility/templates/conceptual-pipeline-map.md`.
- The agent: `diagnostic-legibility/agents/diagnostic-legibility.agent.md` (`mode: pipeline`).
- The command: `diagnostic-legibility/commands/pipeline-map.md`.
- Issue: #368.
