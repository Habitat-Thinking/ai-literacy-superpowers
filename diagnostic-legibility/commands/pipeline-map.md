---
name: pipeline-map
description: Render the task-scoped conceptual pipeline map for a work task you are considering. /pipeline-map "<task>" drives the diagnostic-legibility agent in mode:pipeline (resolve bound → trace flow → three-way cross-check) and renders the bounded pipeline as a self-contained HTML flowchart (vendored, SHA-pinned Mermaid inlined; no CDN), with a scope-resolution panel, a node-detail table, and a no-JS plain-text fallback. Add --predict-change to also predict which stages the task will modify and where it will insert new ones (mode:change-prediction), highlighted as disclosed predictions (never directives) with a predicted-change-sites panel.
---

# /pipeline-map "\<task\>" [--near \<path\>] [--out \<dir\>] [--predict-change]

`/pipeline-map` is the human-facing surface for the task-scoped
conceptual pipeline map. A developer states the **work they are
considering**; the command dispatches the `diagnostic-legibility` agent
in `mode: pipeline` (resolve the bounded scope → trace control flow →
three-way cross-check), renders the returned map as a **self-contained
HTML flowchart**, and — after the human accepts — writes it to disk.

This mirrors `/diagnose` structurally (dispatch → render → validation
checkpoint → confirm-before-write → single Write, agent stays read-only),
but its input is a **task** (not a code area) and its target is a
**Mermaid HTML** file rather than a markdown report.

The command chooses `mode: pipeline` on the human's behalf — the full
task-scoped pipeline, the same depth `/diagnose` gives a scope. The
agent's `scope-resolution`, `full`, and `cross-check-only` modes are
**not** exposed here; they remain bare-`Task`-tool affordances.

## Usage

```text
/pipeline-map "<task>" [--near <path>] [--out <dir>] [--predict-change]
```

- `"<task>"` — **required** positional. A natural-language description of
  the work the developer is considering (e.g. `"add a fraud-hold step
  after risk evaluation"`). Passed to the agent's `task:` line verbatim.
  This is the input the capability turns on — the developer states
  intent, not a code area.
- `--near <path>` — **optional** hint that **biases, but does not bound**,
  the agent's scope search (the agent may resolve the touched process
  outside it and discloses when it does). Forwarded to the agent's
  `near:` line.
- `--out <dir>` — **optional** directory override for where the HTML is
  written. The filename convention still applies beneath it.
- `--predict-change` — **optional** flag. When present, the command
  dispatches **`mode: change-prediction`** instead of `mode: pipeline`,
  so the map additionally **predicts which stages the task will *modify*
  and where it will *insert* new stages** (distinct from which it
  *touches*), and the render highlights those predicted sites and adds a
  predicted-change-sites panel. Without it, behaviour is exactly as
  before — no prediction, no panel, no highlight. The prediction is a
  disclosed *prediction*, never a directive (see §The predicted-change
  surface).

There are no subcommands — `/pipeline-map` is a single verb.

## Flow

The order is fixed; the human disposition (step 8) **precedes** the
single Write (step 9).

### 1. Parse args

1. **`"<task>"`** — required positional. If absent or empty, surface the
   usage error `/pipeline-map requires a "<task>" argument` and abort: no
   agent dispatch, no fetch, no file written.
2. **`--near <path>`** — optional hint.
3. **`--out <dir>`** — optional directory override.
4. **`--predict-change`** — optional boolean flag. When present, the
   dispatch mode (step 2) is `change-prediction` and the render (step 6)
   gains the predicted-change surface.

### 2. Dispatch the agent (`mode: pipeline`, or `change-prediction` with `--predict-change`)

Dispatch the `diagnostic-legibility` agent via the `Task` tool:

- `subagent_type`: `diagnostic-legibility`
- `description`: a short imperative, e.g. `"Map the fraud-hold task"`
- `prompt`: first line `mode: change-prediction` **if `--predict-change`
  was supplied**, else `mode: pipeline`; then `task: <task>` (verbatim),
  then `near: <path>` **only if** `--near` was supplied.

In `change-prediction` mode the returned `ConceptualPipelineMap`
additionally carries a `change_prediction` block; everything else about
the two-block response is identical.

The agent returns **one of**:

- a markdown response carrying **two standalone fenced YAML blocks** — a
  `ConceptualPipelineMap` then a `LegibilityModel` (labelled
  `ConceptualPipelineMap:` and `LegibilityModel:` per the agent's
  contract), or
- a single structured refusal line `diagnostic-legibility refusal:
  <reason>.` with **no** YAML blocks.

### 3. Handle a refusal

If the response contains a `diagnostic-legibility refusal:` line:

1. Surface it **verbatim**.
2. **Abort** — render nothing, fetch nothing, write nothing, `mkdir`
   nothing.

**Fail safe.** A refusal line routes here and aborts **even if** YAML
blocks also appear — the agent contract forbids that composite, so a
refusal-plus-YAML response is malformed and refusing to render is the
safe choice. The only documented `mode: pipeline` refusal reachable
through this command is a missing/empty `task:` (already caught at step
1); the path is retained as a defensive contract.

### 4. Resolve the Mermaid bundle (fetch → verify → inline)

Per `diagnostic-legibility/assets/mermaid-vendor.md` (the pinned version,
source URL, and SHA-256). The report inlines the bundle — it **never**
emits a CDN `<script src>`.

1. **Cache path:** `diagnostic-legibility/assets/cache/mermaid-<version>.min.js`
   (gitignored). `mkdir -p assets/cache/` if needed.
2. **Cache hit:** if the cached file exists, compute its SHA-256 and
   compare to the manifest. On match, use it (no network). On mismatch,
   delete it and fall through to fetch.
3. **Fetch (cache miss):** `curl -fsSL <source_url>` into the cache path.
   A network failure aborts the command with a clear message (`could not
   fetch the pinned Mermaid bundle; generation needs network until the
   cache is warm`) — **no report written**.
4. **Verify:** compute the SHA-256 of the bytes and compare to the
   manifest. **On mismatch, abort** — delete the bad file, surface
   expected-vs-actual hashes, write **no** report. The pin is only as
   strong as this check.
5. **Hold** the verified bytes for inlining at step 6.

This step is the supply-chain gate; it runs **before** rendering so a
report is never produced from an unverified bundle.

### 5. Parse and substitute placeholders

Parse both YAML blocks. Substitute the `<DISPATCHER: ...>` placeholders in
each block's `generated_at` / `generated_by` with the resolved instant and
model identifier **before** rendering (the same resolved date supplies the
filename's `<YYYY-MM-DD>` at step 7). The map's `scope_resolution` and
`pipeline_cross_check_status`, and the model's `cross_check_status`, are
read for the panels and detail table.

### 6. Render the HTML (renderer owns all display concerns)

The renderer derives **every** presentation concern from the
display-agnostic `ConceptualPipelineMap` (the model stores none of them).
Produce a single self-contained HTML file with, in order:

1. **Structural-not-executed banner** (diaboli O12) — a visible header
   banner stating the map is a *static structural* view, **not** a record
   of an executed run. Gate `condition` values render as conceptual
   rules, never as evaluated results. **No** executed/not-executed
   styling and **no** reserved "live" legend ship at P5.
2. **Header** — the **task** (not a code path), the resolved
   `generated_at`, `generated_by`, and the stage count.
3. **Scope-resolution panel** — surfaces `scope_resolution`: the `task`,
   the `in_scope` set with reasons, the `adjacent_excluded` set with
   reasons, `scope_confidence`, and (when confidence < `high`) the
   suspected failure direction from the reasons. This makes the
   *limiting* legible — the developer sees both the map **and** why this
   slice was chosen and what was left out.
4. **The Mermaid diagram** — a `<div class="mermaid">…</div>` carrying the
   derived flowchart source, plus the **inlined** verified
   `mermaid.min.js` (step 4) in a `<script>…</script>` element and a
   `mermaid.initialize({ startOnLoad: true })` call. The projection
   (renderer-derived, none of it model fields):
   - traversal of `entry` + `transitions` + `part_of` → the `1 / 5A /
     5A.1` presentation numbering;
   - `stage.kind: step` → rectangle `id["<n> <label><br/><path>"]`;
   - `stage.kind: decision` → diamond `id{"<n> <label><br/><path>"}`;
   - `stage.kind: outcome` → stadium `id(["<label>"])`;
   - `transition` → `from --> to`; `transition.condition_label` →
     `from -->|<label>| to`;
   - `part_of` grouping → a `subgraph` or indentation;
   - context-vs-touched (from `scope_resolution`) → a `classDef context`
     on adjacent-context stages.
5. **No-JS static fallback** (diaboli O5) — inside `<noscript>`, the
   **plain-text / indented-outline** projection of the same model, listing
   every `stage.id` with its label, kind, and first evidence path, and the
   transitions. A reader with JS disabled, a script-stripping client, or a
   PDF export still sees the flow structure, not an empty box. Mermaid is
   the *enhanced* view; the outline is the *floor*.
6. **Stage-detail table** — one row per stage: `id`, label, kind, evidence
   paths, `confidence`, and the grouped `Q<N>` (self-challenge) then
   `CC<N>` (cross-check) notes — so the discipline's audit trail survives
   into the visual surface.
7. **Cross-check summary** — the map's `pipeline_cross_check_status` and
   the model's `cross_check_status`, each glossed in human terms, plus
   per-direction "elements revised" counts (elements carrying ≥1 `CC<N>`
   entry) across the six directed pairs.
8. **Legend** — stage kinds (step / decision / outcome) and the
   touched/context distinction. **No** executed/not-executed key (O12 —
   that ships only when P6 adds the live overlay).

Inline CSS. No CDN. The Mermaid bundle is **inlined** (O6) so the file is
a genuinely portable single artefact; provenance (the manifest's URL +
SHA + version) is recorded where the bundle is vendored, not in every
report.

### 7. Resolve output path

Default output path:

```text
diagnostic-legibility/output/<task-slug>-pipeline-<YYYY-MM-DD>.html
```

- **Directory** — default `diagnostic-legibility/output/` (already
  gitignored — reports are derived, regenerable artefacts), overridden by
  `--out <dir>`. Created with `mkdir -p` at write time (step 9), only on
  accept.
- **`<task-slug>`** — a filesystem-safe slug from the task: lowercased,
  non-`[a-z0-9]` runs collapsed to single hyphens, leading/trailing
  hyphens trimmed, length-capped (≤ 50 chars). The slug is **never a
  path** — it cannot contain `/` or `..`, so it cannot move the write
  target out of the resolved directory. If empty after trimming, fall
  back to the literal `task`.
- **`<YYYY-MM-DD>`** — the date the command resolved at step 5; the body's
  `generated_at` and the filename stamp derive from the same instant.
- **Extension** — `.html`.

### 8. Validation checkpoint, then summary and confirm

**Output validation checkpoint** (this command joins the CLAUDE.md
"Output Validation Checkpoints" list). Read the rendered HTML back and
check — referencing the model, **fixing structural deviations in place**,
**never** re-dispatching the agent:

1. **Structural-not-executed banner present** — the report names itself a
   static structural view.
2. **No unsubstituted placeholders** — no literal `<DISPATCHER:`
   substring (the load-bearing leak check).
3. **No CDN script** — there is **no** `<script src=` referencing an
   external/CDN URL; the Mermaid bytes are inlined.
4. **Scope-resolution panel present** — reports `in_scope`,
   `adjacent_excluded`, and `scope_confidence` consistent with the model
   (and the failure direction when confidence < `high`).
5. **No-JS fallback present** — the `<noscript>` outline exists and lists
   **every** `stage.id`.
6. **Diagram ↔ model agreement** — every `stage.id` appears in both the
   Mermaid source and the stage-detail table; every `transition`
   references rendered stages; the Mermaid source parses to a single
   `flowchart`.
7. **No live-status styling** — no executed/not-executed `classDef` or
   reserved live legend (O12).
8. **Counts consistent** — header stage count matches the rendered nodes,
   the detail-table rows, and the parsed YAML.
9. **Predicted-change surface (only when `--predict-change`)** — the
   predicted-change-sites panel is present and consistent with
   `change_prediction`; every `modify` `target` and `insert` `anchor`
   references a rendered `stage.id` **that is in the scope panel's
   in-scope set**; `change_direction` is present and rendered when
   `change_confidence < high`; each highlighted node carries the
   "predicted" badge and the legend keys the highlight to "prediction,
   not instruction"; and **no imperative/directive phrasing** ("edit X",
   "you must/should") appears in the panel or banner. (Skipped entirely
   when the flag is absent — no `change_prediction` is expected.)

If the YAML cannot be parsed at all (malformed, not a refusal), surface
the failure and abort without writing a partial report. The checkpoint is
**not** an independent oracle for renderer correctness — the human accept
gate is the genuine last line of defence.

**Summary and confirm-before-write.** Then print the conversation summary
(below) naming the **resolved** target path, the stage count, the
`scope_confidence`, and both cross-check statuses; **flag an overwrite**
if the resolved path already exists; and **prompt the human to accept or
abort**. This accept/abort step — not the checkpoint — is the last line of
defence before write.

### 9. Write the file (on accept only)

1. `mkdir -p` the resolved output directory.
2. Write the rendered HTML to the resolved path; confirm the written path.

Runs only after the human accepts at step 8 — a real pre-write
disposition (agent-emit + dispatcher-persist + human-disposes), never a
post-hoc read of an already-written file.

## The predicted-change surface (`--predict-change`)

When `--predict-change` is set, the render projects the map's
`change_prediction` block (renderer-derived; the model stores no styling)
**as a prediction, never a directive** — the framing lives at the point of
emphasis, not only in a banner:

- **Highlighted sites with a per-node "predicted" badge.** A
  `classDef change-site` styles each `modify` `target` stage, and a marked
  insertion indicator sits at each `insert` `anchor`+`position`. Every
  highlighted node carries a small **"predicted"** badge so the colour is
  never read as a bare instruction.
- **Legend entry.** The legend keys the change-site highlight to
  **"predicted edit site — a prediction, not an instruction"**.
- **A "Predicted change sites" panel** listing each site (`kind`,
  `target` or `anchor`+`position`, `reason`, `evidence`),
  `change_confidence`, and — when confidence < `high` — the
  `change_direction` (over-/under-prediction). Each site is phrased as
  "the task **likely** edits …" / "**likely** inserts … after …", never
  "edit …".
- **Flagged in the outline and detail table.** The `<noscript>` outline
  and the stage-detail table mark which stages are predicted change sites
  (and note insert anchors).
- **Banner.** The structural banner additionally states the change sites
  are **predictions, not directives**.

The panel sits beside the scope-resolution panel; because every predicted
`target`/`anchor` is in the in-scope set (agent contract), the two panels
never contradict each other.

## Conversation summary

```text
Pipeline map ready to write: <resolved target path>
  (this path already exists and will be overwritten)   # only if it exists
Task: <task>
Scope confidence: <low | medium | high>   In-scope: <N>   Adjacent-excluded: <M>
Stages: <S>   pipeline_cross_check_status: <status>   cross_check_status: <status>
Predicted change sites: <P> (<change_confidence>, <change_direction>)   # only with --predict-change
Mermaid: mermaid@<version> (SHA-256 verified, inlined; no CDN)
Write this map? (accept / abort)
```

## See also

- The agent: `diagnostic-legibility/agents/diagnostic-legibility.agent.md` (`mode: pipeline`, `mode: change-prediction`)
- The model: `diagnostic-legibility/templates/conceptual-pipeline-map.md`
- Mermaid vendoring manifest: `diagnostic-legibility/assets/mermaid-vendor.md`
- How-to: `docs/plugins/diagnostic-legibility/how-to/run-the-pipeline-map-command.md`
- Reference: `docs/plugins/diagnostic-legibility/reference/pipeline-map-command.md`
- Design spec: `docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md` (§7); change-site prediction `docs/superpowers/specs/2026-06-15-dl-change-site-prediction-design.md`
