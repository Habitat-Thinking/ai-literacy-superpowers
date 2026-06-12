# Cost Estimation — S6 — Calibration loop (per-PR actuals capture) — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-12 |
| Status | Draft |
| Author | spec-writer (interactive session with russmiles) |
| Slice | S6 of the slicing record at `docs/superpowers/slices/cost-estimator-pipeline.md` |
| Progressed slice | S6 (this spec) |
| Upstream (merged on main) | S1 (skill + `estimate-record-format.md`, incl. the calibration **seam**); S2 (#369, the `cost-estimator` agent); S3 (#370, `/cost-estimate`); S4 (#371, T1/T2 fold-in); S5 (#372, T0 ballpark) |
| Tracking issue | #373 |
| Downstream slices | none — S6 is the final slice of the cost-estimator pipeline |
| Plugin version target | `ai-literacy-superpowers` v0.46.0 → v0.47.0 (new integration-agent responsibility + new actuals format + calibration ingestion — minor bump) |
| Marketplace listing | Top-level `version` unchanged at v0.4.0; `plugin_version` and the `plugins[]` entry both 0.46.0 → 0.47.0 |
| PR ceremony | feature — full `/diaboli` (spec + code) and `/choice-cartograph` |
| Governing decisions | AGENTS.md **"agent-emit + dispatcher-persist + human-disposes"**; AGENTS.md **"disclosure-of-derived-judgment"**; the S1 **calibration seam** (`kind: calibration` grounding source, **no format change**); the repo-wide **no-fabrication** contract. |

---

## 1. Premise

S1 named a **calibration seam** and deliberately did not build it: the
estimate-record format permits a `grounding_sources[]` entry of
`kind: calibration`, and the methodology is written so calibration data, when it
exists, **refines** the estimate "without a format change" — but S1 shipped "no
per-PR actuals format, no integration-agent change, no ingestion logic." S6 is
the slice that **closes that loop**.

Today the only actuals in `observability/costs/` are the **quarterly,
provider-level** snapshots written by `/cost-capture` (and at time of writing
there are none — "Last cost capture: never"). The estimator therefore calibrates
only against the **generic** `MODEL_ROUTING.md` token budgets, which are the same
for every repo. S6 gives the estimator **this repo's own history** to learn from:
the integration-agent captures a **per-PR actuals record** at integration time,
and the estimation methodology reads accumulated per-PR records to **narrow the
per-stage token ranges** against what work in *this* repo actually costs.

The slice's in/out decision_focus — "in scope for v1 or recorded follow-on?" — was
already resolved by the human on 2026-06-10 (**accepted in-scope**), which is why
S1 kept the seam open. S6's remaining design decisions, dispositioned by the human
at spec time (§8), are shaped by one hard constraint: **a subagent cannot
reliably read "tokens spent on this PR" programmatically, and the repo's
no-fabrication contract forbids inventing the number.** Two decisions follow:

1. **Actuals source: hybrid — auto-structural + human-supplied figures.** The
   integration-agent **always** auto-captures the structurally-observable per-PR
   facts (which stages ran, review-cycle count, files & languages, dates, the
   progressed slice) from the context object and git. It records **token/cost
   figures only when a human supplies them** (e.g. pasted from Claude Code's
   `/cost`), marking them explicitly **`unavailable`** otherwise. It **never
   fabricates** a figure. The structural facts alone already calibrate *which
   stages this repo exercises*; the supplied figures, when present, calibrate
   *how many tokens each stage actually costs here*.
2. **Calibration reach: token ranges only.** Accumulated per-PR actuals narrow
   the **per-stage token ranges** (and may raise the `tokens` confidence) against
   repo history. The **$/token rate stays bound to the snapshot** — `cost_basis`
   remains `snapshot-actuals`. Calibration adds **no field** to the estimate-record
   format: it is a `kind: calibration` `grounding_sources[]` entry (already
   permitted) plus a disclosure in `Confidence rationale`. This honours the S1
   seam's "no format change" promise.

## 2. Scope and non-goals

### 2.1 In scope (S6)

- **A per-PR actuals format** — a new reference under the **`cost-tracking`**
  skill (the retrospective/actuals skill that owns `observability/costs/`):
  `ai-literacy-superpowers/skills/cost-tracking/references/per-pr-actuals-format.md`.
  It defines the per-PR record's field set, its on-disk home
  (`observability/costs/per-pr/<YYYY-MM-DD>-<branch-slug>-actuals.md`), the
  auto-captured-vs-supplied split, and the `unavailable` honesty discipline. It is
  **distinct** from the quarterly provider snapshot (per-PR + structural +
  single-task granularity vs provider-level aggregate).
- **A new integration-agent responsibility** — a capture step (new `### 1a`,
  after CHANGELOG and before the commit) that writes the per-PR actuals record,
  auto-filling structural fields and recording supplied token/cost figures (or
  `unavailable`), and stages it so it ships **in the PR** (avoiding any
  commit-to-`main`). **Non-blocking**: it never gates the merge and never
  fabricates a figure.
- **The feedback path** — wiring the captured actuals back into estimation:
  - `cost-estimation/SKILL.md` — the "Calibration Seam" section moves from
    *named* to *implemented*: how accumulated per-PR records are read as a
    `kind: calibration` grounding source to narrow per-stage token ranges, with
    disclosed confidence and **no format change**.
  - `cost-estimator` agent (S2) — reads per-PR actuals from
    `observability/costs/per-pr/` when present, emits a `kind: calibration`
    `grounding_sources[]` entry, and discloses the calibration basis in
    `Confidence rationale`. Token-range refinement only; `cost_basis` untouched.
  - `estimate-record-format.md` — the calibration-seam note updates from "no
    per-PR actuals capture ships in this slice" to point at the now-shipped
    format; **no field-set change**.
- Version bump, CHANGELOG, marketplace `plugin_version` + `plugins[]` entry,
  README badge + table cell, and docs (the concept page's calibration section).

### 2.2 Out of scope (S6)

- **Any change to the estimate-record format field set.** Calibration ships as a
  permitted `kind: calibration` grounding-source entry and value-refinement only
  (decision §8 — token ranges only). `cost_basis` stays `snapshot-actuals`; no
  new enum value.
- **Automatic/programmatic token capture.** No telemetry/OTEL integration is
  assumed; figures are auto-captured **only** when structurally observable
  (they are not, for tokens/cost) and **human-supplied otherwise**. No
  fabrication, no diff-size proxy passed off as actuals.
- **$/token calibration** from per-PR cost — explicitly deferred by the
  token-ranges-only decision; the snapshot remains the cost ground.
- **A new command.** Capture is an integration-agent responsibility, as the slice
  scope directs — not a new `/cost-*` surface.
- **Backfilling history.** S6 starts the loop; it does not reconstruct actuals for
  past PRs. The estimator simply uses whatever per-PR records exist (zero is the
  valid day-one state, identical to today's generic-budget behaviour).

## 3. The per-PR actuals format

Defined in full in
`ai-literacy-superpowers/skills/cost-tracking/references/per-pr-actuals-format.md`.
Summary of the contract:

- **Home:** `observability/costs/per-pr/<YYYY-MM-DD>-<branch-slug>-actuals.md`.
  The `per-pr/` subdirectory keeps these single-task records separate from the
  quarterly `observability/costs/<YYYY-MM-DD>-costs.md` snapshots, so a reader (and
  the estimator) never confuses a per-PR actual with a provider aggregate.
- **Frontmatter fields** (auto-captured unless noted):
  - `date`, `branch`, `issue`, `pr` (the PR number/URL when known, else `null`),
    `task_summary`, `progressed_slice` (from the context object).
  - `stages_run` — the ordered list of pipeline stages that actually ran
    (spec-writer, tdd-agent, implementer(s), code-reviewer, integration-agent),
    inferred from the context object (e.g. `spec_changes` present ⇒ spec-writer
    ran; `failing_tests` ⇒ tdd-agent; `review_result` ⇒ code-reviewer).
  - `review_cycles` — the reviewer→implementer cycle count (from `review_result`).
  - `files_changed`, `languages` — from `git diff --name-only main...HEAD`.
  - `tokens_by_stage` — per-stage token actuals **when human-supplied**, else the
    stage entries carry `tokens: unavailable`. The shape mirrors the
    estimate-record `tokens_by_stage[]` stage labels so the join key is identical.
  - `tokens_total`, `cost_usd` — **human-supplied or `unavailable`**.
  - `figures_source` — `human-supplied` | `unavailable` (never `inferred` — there
    is no inference path for figures).
- **Body** — a short disclosure: what was auto-captured vs supplied, and an
  explicit statement when figures are `unavailable` ("token/cost figures were not
  supplied at integration time; structural facts stand"). This is the
  no-fabrication contract made visible in the record itself.

The format file carries two worked examples — one **figures-supplied** record and
one **figures-unavailable** record — and a short validation checklist, matching
the house style of `estimate-record-format.md`.

## 4. The integration-agent capture step

A new **`### 1a. Capture per-PR actuals (calibration)`** in
`ai-literacy-superpowers/agents/integration-agent.agent.md`, placed **after**
`### 1. Update CHANGELOG.md` and **before** `### 2. Commit`, so the record is
staged and committed **with the PR** (never to `main`).

1. **Auto-capture structural facts** from the context object and git: `date`,
   `branch`, `issue`, `task_summary`, `progressed_slice`, `stages_run`,
   `review_cycles`, `files_changed`, `languages`. The `pr` field is filled later
   if known, else left `null` (the record's provenance is the PR it ships in).
2. **Invite figures, non-blocking.** Surface a brief one-line invitation: "If you
   want token/cost actuals captured for calibration, paste the session figures
   from `/cost`; otherwise I'll record them as unavailable." Record supplied
   figures into `tokens_by_stage`/`tokens_total`/`cost_usd` and set
   `figures_source: human-supplied`; if nothing is supplied, set every figure to
   `unavailable` and `figures_source: unavailable`. **Never fabricate.** This
   invitation does **not** block the pipeline — absence of a reply means
   `unavailable` and the agent proceeds.
3. **Write** the record to
   `observability/costs/per-pr/<YYYY-MM-DD>-<branch-slug>-actuals.md` (the agent
   `mkdir -p`s the directory), conforming to the format reference.
4. **Stage it with the commit.** Step 2's named-file staging list includes the
   per-PR actuals record, so it ships in the PR. No commit to `main`, no amend,
   no force-push — consistent with the agent's existing constraints.

The capture is **purely additive**: it never blocks the merge, and a missing or
`unavailable` figure set produces a valid structural-only record.

## 5. The feedback path (ingestion)

### 5.1 Methodology (`cost-estimation/SKILL.md`)

The "Calibration Seam (S6)" section is rewritten from *named, not built* to
*implemented*:

- When per-PR records exist in `observability/costs/per-pr/`, they are a
  `kind: calibration` grounding source. The methodology uses the **per-stage
  token actuals** across the accumulated records to **narrow** that stage's token
  range (e.g. toward the observed central tendency) and, when enough records
  exist for a stage, **raise** the `tokens` confidence one tier — never above the
  `target_kind` ceiling.
- Records whose figures are `unavailable` still contribute their **structural**
  signal: which `stages_run` this repo actually exercises (so the estimator can
  drop a stage the repo never uses, disclosed in `Excluded`). They contribute
  **nothing** to the numeric token narrowing — `unavailable` is not zero.
- Calibration **never** touches `cost_usd`/`cost_basis` (token-ranges-only
  decision). The $/token ground stays the snapshot.
- **No format change.** Calibration adds the `kind: calibration` entry (already
  permitted) and a `Confidence rationale` disclosure naming how many records
  informed the narrowing and over what date range. The disclosure contract is
  honoured: a calibrated range is still a range with disclosed confidence, and the
  failure direction still stated.

### 5.2 The `cost-estimator` agent (S2)

- On any dispatch, **Glob** `observability/costs/per-pr/` for actuals records. If
  present, ingest the per-stage token actuals per §5.1, add a `kind: calibration`
  `grounding_sources[]` entry naming the directory, and disclose the calibration
  basis in `Confidence rationale` ("token ranges narrowed against N per-PR
  actuals, 2026-06-… to …; cost unchanged — calibration refines tokens only").
- If the directory is **absent or empty** (today's state), behaviour is
  **identical to pre-S6**: generic `MODEL_ROUTING.md` budgets, no `calibration`
  entry, no calibration disclosure. The loop degrades cleanly to the current
  behaviour with zero history.
- The agent's read-only trust boundary is unchanged (`Read`, `Glob`, `Grep`); it
  consumes calibration data, it never writes it. The integration-agent writes;
  the estimator reads — the same emit/persist split the whole pipeline uses.

### 5.3 The format reference note

`estimate-record-format.md`'s calibration-seam note changes from "no per-PR
actuals capture, format, or integration-agent change ships in this slice" to a
pointer at the now-shipped per-PR actuals format and a one-line statement that a
`kind: calibration` entry is populated when history exists. **No field is added,
removed, or retyped.**

## 6. Failure modes and honesty guarantees

- **No history (zero per-PR records):** the day-one state. The estimator behaves
  exactly as pre-S6 (generic budgets), with no `calibration` grounding entry. Not
  a failure.
- **Figures unavailable on a record:** the record is valid and structural;
  it calibrates the stage set but not the token magnitudes. The `unavailable`
  marker is explicit; nothing is fabricated.
- **Integration-agent can't reach the context object / git data:** it writes the
  fields it can and marks the rest `unavailable`; it never blocks the merge to
  obtain a complete record.
- **Calibration never overrides disclosure:** a calibrated estimate is still a
  range with disclosed confidence and a stated failure direction. Calibration can
  narrow and raise confidence, but it cannot turn a range into a point or suppress
  the `Excluded`/`Confidence rationale` disclosures.

## 7. Acceptance scenarios

```gherkin
Scenario: Integration-agent captures a per-PR actuals record in the PR
  Given a pipeline run is at the integration stage with a populated context object
  When the integration-agent runs the per-PR actuals capture step
  Then it writes observability/costs/per-pr/<date>-<branch-slug>-actuals.md with the auto-captured structural fields (stages_run, review_cycles, files_changed, languages, progressed_slice)
  And it stages the record so it ships in the PR, never committing to main
  And it never blocks the merge to obtain the record

Scenario: Supplied figures are recorded; absent figures are marked unavailable, never fabricated
  Given the integration-agent reaches the actuals capture step
  When the human supplies token/cost figures from /cost
  Then the record carries those figures with figures_source: human-supplied
  And when no figures are supplied the record sets every token/cost field to unavailable with figures_source: unavailable
  And in neither case does the agent invent a token or cost number

Scenario: The estimator narrows token ranges against per-PR history
  Given observability/costs/per-pr/ holds per-PR actuals records with supplied per-stage token figures
  When the cost-estimator estimates a target
  Then it adds a kind: calibration grounding_sources entry naming the per-pr directory
  And it narrows the per-stage token ranges toward the observed history and discloses the calibration basis in Confidence rationale
  And cost_usd and cost_basis are unchanged (calibration refines tokens only)
  And no field is added to the estimate-record format

Scenario: Zero history degrades cleanly to pre-S6 behaviour
  Given observability/costs/per-pr/ is absent or empty
  When the cost-estimator estimates a target
  Then it uses the generic MODEL_ROUTING budgets exactly as before S6
  And it emits no kind: calibration entry and no calibration disclosure

Scenario: Unavailable-figure records still calibrate the stage set
  Given per-PR records exist but their figures are unavailable
  When the cost-estimator estimates a target
  Then it may use stages_run to refine which stages the repo exercises (disclosed in Excluded)
  And it does not narrow token magnitudes from those records
```

## 8. Decisions taken (for the choice-cartographer and the record)

- **Ship the calibration loop in v1** — settled 2026-06-10 (in-scope), which is
  why S1 kept the seam open. S6 builds it.
- **Actuals source: hybrid (auto-structural + human-supplied figures, else
  `unavailable`)** — the only design that both captures real actuals and honours
  the no-fabrication contract, given no programmatic per-PR token source exists.
  *(Open decision, dispositioned by the human at spec time.)*
- **Calibration reach: token ranges only** — narrows per-stage token ranges from
  repo history; `$/token`/`cost_basis` stay snapshot-bound; **no estimate-record
  format change**, honouring the S1 seam. *(Open decision, dispositioned by the
  human at spec time.)*
- **Capture lives in the integration-agent and ships in the PR** — written after
  CHANGELOG, before commit, so it never commits to `main`; non-blocking, never
  gating the merge.
- **Per-PR actuals format owned by `cost-tracking`** — the retrospective/actuals
  skill that already owns `observability/costs/`; `cost-estimation` consumes it as
  calibration. Keeps the prospective/retrospective sibling symmetry.
- **`unavailable` is explicit and is not zero** — an unsupplied figure contributes
  structural signal only, never a fabricated or zero-valued magnitude.

## 9. TDAD discipline note

S6 **modifies** existing components (`integration-agent.agent.md`,
`cost-estimator.agent.md`, `cost-estimation/SKILL.md`, `cost-tracking/SKILL.md`,
`estimate-record-format.md`) and **adds one reference file** under an existing
skill (`cost-tracking/references/per-pr-actuals-format.md`). It adds **no new
skill, agent, or command artefact** — the TDAD-scenario requirement (which the
`tdad-scenario-check` workflow scopes to new `SKILL.md` / `*.agent.md` /
`commands/*.md` components) does not trigger. A new `references/` file under an
existing skill is not a new component. The modifications follow the same
forward-applies-to-additions exemption the orchestrator changes (S4/S5) relied on.

## 10. Affected files

| File | Change |
| --- | --- |
| `ai-literacy-superpowers/skills/cost-tracking/references/per-pr-actuals-format.md` | **New.** The per-PR actuals format contract + worked examples + checklist. |
| `ai-literacy-superpowers/skills/cost-tracking/SKILL.md` | Add a pointer to the per-PR actuals format as the per-PR sibling of the quarterly snapshot. |
| `ai-literacy-superpowers/agents/integration-agent.agent.md` | New `### 1a` capture step; add the record to step 2's staged-files list. |
| `ai-literacy-superpowers/skills/cost-estimation/SKILL.md` | Rewrite "The Calibration Seam (S6)" from named to implemented (§5.1). |
| `ai-literacy-superpowers/agents/cost-estimator.agent.md` | Ingest per-PR actuals as a `kind: calibration` source; disclose basis; token-range refinement only (§5.2). |
| `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md` | Update the calibration-seam note to point at the shipped format; no field change (§5.3). |
| `ai-literacy-superpowers/.claude-plugin/plugin.json` | 0.46.0 → 0.47.0. |
| `README.md` | Badge + table cell 0.46.0 → 0.47.0. |
| `.claude-plugin/marketplace.json` | `plugin_version` + `plugins[]` entry 0.46.0 → 0.47.0. |
| `CHANGELOG.md` | New 0.47.0 section. |
| `docs/plugins/ai-literacy-superpowers/explanation/prospective-cost-estimation.md` | Add a "calibration loop" section (the seam, now closed). |
| `docs/superpowers/plans/2026-06-12-calibration-loop-per-pr-actuals.md` | Implementation plan. |
