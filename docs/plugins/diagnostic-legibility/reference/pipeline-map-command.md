# Reference: /pipeline-map command

Task-driven command that renders a self-contained HTML conceptual
pipeline map. Dispatches the `diagnostic-legibility` agent in
`mode: pipeline`; the command owns the single `Write`, the agent stays
read-only.

## Signature

```text
/pipeline-map "<task>" [--near <path>] [--out <dir>] [--predict-change]
```

| Argument | Required | Meaning |
| --- | --- | --- |
| `"<task>"` | yes | Natural-language work task; forwarded to the agent's `task:` line verbatim. Empty/absent → usage error, no dispatch. |
| `--near <path>` | no | Search-bias hint; forwarded to the agent's `near:` line. Biases, does **not** bound. |
| `--out <dir>` | no | Output-directory override; the derived filename still applies beneath it. |
| `--predict-change` | no | Dispatch `mode: change-prediction` instead of `mode: pipeline`; the map gains a `change_prediction` block and the render gains the predicted-change surface (see below). |

## Output path

```text
diagnostic-legibility/output/<task-slug>-pipeline-<YYYY-MM-DD>.html
```

- Default directory `diagnostic-legibility/output/` (gitignored),
  overridable by `--out`. Created with `mkdir -p` at write time, on
  accept only.
- `<task-slug>`: lowercase, `[a-z0-9]` runs hyphenated, trimmed, ≤ 50
  chars; never a path (no `/` or `..`); falls back to `task` if empty.
- `<YYYY-MM-DD>`: the same resolved instant that fills the body's
  `generated_at`.
- Extension `.html`.

## Dispatch contract

- `subagent_type: diagnostic-legibility`; prompt first line
  `mode: change-prediction` if `--predict-change` else `mode: pipeline`,
  then `task: <task>`, then `near: <path>` if supplied.
- Agent returns **two standalone fenced YAML blocks**
  (`ConceptualPipelineMap` then `LegibilityModel`) **or** a single
  `diagnostic-legibility refusal: <reason>.` line. With
  `--predict-change`, the `ConceptualPipelineMap` additionally carries a
  `change_prediction` block.
- A refusal is surfaced verbatim and aborts (render nothing, fetch
  nothing, write nothing) — even if YAML also appears.

## Change-site prediction (`--predict-change`, v0.11.0)

Dispatches `mode: change-prediction` (a superset of `mode: pipeline`): the
agent builds the map, then predicts which stages the task will **modify**
and where it will **insert** new ones, in the `change_prediction` block —
distinct from `scope_resolution` (which stages the task *touches*).

- **Model** — `change_prediction.predicted_sites[]`:
  `kind: modify` (a `target` stage.id) or `kind: insert` (a typed
  `anchor` stage.id + `position: after | before`); each with a `reason`
  and `evidence`. `change_confidence` is the **minimum** over sites;
  `change_direction` (`over-prediction | under-prediction`) is present iff
  confidence < `high`. Targets/anchors must be in
  `scope_resolution.in_scope`. See the template's §Change-site prediction.
- **Render** — predicted sites highlighted with a per-node **"predicted"
  badge**; the legend keys the highlight to *"prediction, not
  instruction"*; a **Predicted change sites** panel; outline + detail
  table flags. The banner states the sites are **predictions, not
  directives**.
- **Honesty** — predict-never-direct (no imperatives); `modify`/`insert`
  is a best-judgement label; an empty prediction is honest.
- **Checkpoint additions (flag-only)** — predicted-sites panel
  consistent; every `target`/`anchor` is a rendered, in-scope `stage.id`;
  `change_direction` present below `high`; no directive phrasing.

## Mermaid vendoring (pin + SHA + cache)

| Field | Value |
| --- | --- |
| Manifest | `diagnostic-legibility/assets/mermaid-vendor.md` |
| Version | `mermaid@11.6.0` (pinned) |
| Integrity | SHA-256 recorded in the manifest; verified before inlining |
| Cache | `diagnostic-legibility/assets/cache/` (gitignored), warmed on first use |
| Output | bundle **inlined** into each report — **no** CDN `<script src>` |

On SHA mismatch or fetch failure the command **aborts** and writes no
report. Spec §2.2 (revised at P5) chose pin+SHA+cache over a committed
blob: integrity-verified, portable output, repo stays light; first
generation needs network until the cache is warm.

## HTML report structure

In order: a **structural-not-executed banner** (diaboli O12) · **header**
(task, generated_at, generated_by, stage count) · **scope-resolution
panel** (in_scope / adjacent_excluded with reasons, scope_confidence,
failure direction when < high) · **Mermaid flowchart** (inlined bundle)
· **`<noscript>` plain-text outline fallback** (diaboli O5) ·
**stage-detail table** (evidence, confidence, grouped `Q<N>`/`CC<N>`) ·
**cross-check summary** (`pipeline_cross_check_status` +
`cross_check_status`, per-direction elements-revised counts) ·
**legend** (stage kinds + touched/context; **no** live-status key).

### Mermaid projection (renderer-derived)

| Model (conceptual) | Rendered (renderer's choice) |
| --- | --- |
| traversal of `entry` + `transitions` + `part_of` | `1 / 5A / 5A.1` numbering |
| `stage.kind: step` | rectangle `id["… "]` |
| `stage.kind: decision` | diamond `id{"… "}` |
| `stage.kind: outcome` | stadium `id(["… "])` |
| `transition` | `from --> to` |
| `transition.condition_label` | `from -->|label| to` |
| `part_of` | `subgraph` / indentation |
| context vs touched | `classDef context` |

None of the right column is a model field — the `ConceptualPipelineMap`
is presentation-agnostic; the renderer derives all of it.

## Output validation checkpoint

This command is on the CLAUDE.md "Output Validation Checkpoints" list.
After rendering, before the confirm-before-write gate, read the HTML back
and check: structural banner present; **no** `<DISPATCHER:` leak; **no**
CDN `<script src=`; scope-resolution panel present and consistent;
`<noscript>` outline present and listing every `stage.id`; every
`stage.id` in both the Mermaid source and the detail table; every
`transition` references rendered stages; Mermaid parses to a single
`flowchart`; no live-status `classDef`/legend; counts consistent.
Deviations are fixed in place; the agent is **not** re-dispatched. The
human accept gate — not the checkpoint — is the last line of defence.

## Scope

- Drives `mode: pipeline` by default, or `mode: change-prediction` with
  `--predict-change`; the agent's `scope-resolution`, `full`, and
  `cross-check-only` modes are not exposed here.
- Renders a **static structural** map — no execution overlay (P6).
- Change-site prediction is a **disclosed prediction, never a directive**,
  and is opt-in via `--predict-change` (#368). The
  consume-an-existing-map prediction variant is a deferred follow-on.

## See also

- How-to: [run-the-pipeline-map-command](../how-to/run-the-pipeline-map-command.md)
- Agent: `diagnostic-legibility/agents/diagnostic-legibility.agent.md`
- Model: `diagnostic-legibility/templates/conceptual-pipeline-map.md`
- Spec: `docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md` (§7)
