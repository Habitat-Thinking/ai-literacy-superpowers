# Cost Estimation — S4 — Orchestrator fold-in at T1 and T2 — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-12 |
| Status | Draft |
| Author | spec-writer (interactive session with russmiles) |
| Slice | S4 of the slicing record at `docs/superpowers/slices/cost-estimator-pipeline.md` |
| Progressed slice | S4 (this spec) |
| Tracking issue | #371 |
| Upstream (merged on main) | S1 (skill + `estimate-record-format.md`, incl. the #377 per-stage `cost_usd` additions); S2 (#369, the read-only `cost-estimator` agent); S3 (#370, the `/cost-estimate` command + `cost-estimates/` output convention + Output Validation Checkpoint) |
| Downstream slices | S5 (#372, T0 pre-carpaccio ballpark); S6 (#373, calibration loop) — both out of scope here |
| Plugin version target | `ai-literacy-superpowers` v0.44.0 → v0.45.0 (behavioural change to the orchestrator agent — minor bump) |
| Marketplace listing | Top-level `version` unchanged at v0.4.0; `plugin_version` 0.44.0 → 0.45.0 |
| PR ceremony | feature — full `/diaboli` (spec + code) and `/choice-cartograph` |
| Governing decisions | AGENTS.md **"agent-emit + dispatcher-persist + human-disposes"** trust architecture (with its **dispose-then-write ordering invariant**); AGENTS.md **"disclosure-of-derived-judgment"** decision; CLAUDE.md **Output Validation Checkpoints** convention; the orchestrator's existing **`cartograph_pending_count` informational-field-not-a-gate** precedent. |

---

## 1. Premise

The cost-estimator pipeline has shipped its foundation and its standalone
surface. S1 defined what an estimate record **is** (the `cost-estimation` skill
+ `estimate-record-format.md`). S2 (#369) shipped the read-only `cost-estimator`
**emitter**. S3 (#370) shipped the human-facing `/cost-estimate` **command** — a
dispatcher that owns the single `Write`, persists the record to `cost-estimates/`,
and runs an Output Validation Checkpoint against the format reference.

S4 is the **highest-value insertion** the slicing record names: it wires the
estimator into the orchestrator's **existing** human-disposition gates so a human
sees cost *at the moment a cost figure most changes a choice* — without adding a
new gate, a new keypress, or a block.

Two insertion moments:

- **T1 — Slice Adjudication gate (orchestrator step 0, after carpaccio).** The
  human is choosing which slice to **progress / file / defer**. A **per-slice**
  cost breakdown surfaced *inside that gate's presentation* lets cost inform the
  progression choice. The slicing record calls this the most valuable moment
  precisely because cost most changes the choice here.
- **T2 — Plan Approval gate (after spec-writer, diaboli, cartographer).** The
  human is approving the plan for the **progressed slice**. A **tighter,
  spec-grounded** estimate (higher confidence ceiling) surfaced inside that gate's
  presentation lets cost inform the approve / request-changes / take-over choice.

This slice's load-bearing decision is the one the slicing record's
`decision_focus` names: **do estimates fold into existing gates as informational
fields, or do they become new decision points?** S4 commits to **informational
fold-in into the existing gates, never a new hard gate** — exactly mirroring the
orchestrator's existing treatment of `cartograph_pending_count` (surfaced as a
structured field at Plan Approval, explicitly *not* a separate decision point,
adding no keypress). The estimate is **additive decision-support**: it does not
block, does not add a keypress, does not let any agent write dispositions, and
its absence or refusal degrades the existing gate to exactly today's behaviour.

S4 is a **pure consumer** of S1/S2/S3. It adds no field to the estimate-record
format (the format reference at line 6 already names "the orchestrator fold-in
[that] surfaces fields from" it as the reason the contract must be stable), it
reuses the S2 agent unchanged, and it reuses the S3 persistence + Output
Validation Checkpoint discipline. The only file whose **behaviour** changes is
`ai-literacy-superpowers/agents/orchestrator.agent.md`.

## 2. Scope and non-goals

### 2.1 In scope (S4)

- **T1 fold-in** into the Slice Adjudication gate (orchestrator §"After carpaccio
  completes"): after carpaccio's record is written and validated, and **before**
  surfacing the slicing record to the human, dispatch the `cost-estimator`
  **once per slice in parallel** (`target_kind: slice`), persist each returned
  record under `cost-estimates/`, run the S3 Output Validation Checkpoint on
  each, and surface a **compact one-line-per-slice** cost summary *inside* the
  existing Slice Adjudication presentation (Step 3).
- **T2 fold-in** into the Plan Approval gate (orchestrator §"After spec-writer
  completes"): after the choice-story record is surfaced (soft gate) and before
  the Plan Approval prompt, dispatch the `cost-estimator` **once** against the
  **progressed slice's spec file** (`target_kind: spec`), persist the returned
  record, run the Output Validation Checkpoint, and surface a fuller cost summary
  *inside* the existing Plan Approval presentation (Step 7).
- The exact **fields** that surface in each gate summary (§5), chosen to add
  cognitive value without cognitive friction.
- The **non-blocking / no-keypress / no-disposition** guarantees, the **REFUSED**
  and **dispatch-failure** handling that keeps the existing gate behaviour intact
  when an estimate is unavailable (§6), and the **dispose-then-write ordering**
  reconciliation for a record that carries no disposition (§4.3).
- Orchestrator **context-object** additions so observability tooling can read the
  estimate state (§5.3).
- Version bump, CHANGELOG, marketplace `plugin_version`, README badge, and docs
  updates (the concept page's "future orchestrator fold-in" forward-reference
  becomes present-tense; the orchestration explanation page gains the fold-in).

### 2.2 Out of scope (S4)

- **T0** (the pre-carpaccio whole-task ballpark) — that is S5 (#372), a new
  pre-step-0 touchpoint outside any existing gate. S4 touches only the two
  **existing** gates.
- Any change to the **estimate-record format** (S1) or the **`cost-estimator`
  agent** (S2). S4 consumes both exactly as merged.
- Any change to the **`/cost-estimate` command** (S3). S4 dispatches the agent
  directly (the slicing record's S4 entry states the orchestrator "can dispatch
  the agent directly at T1/T2 without the command").
- The **calibration loop** (S6, #373) and per-PR actuals capture.
- Turning the estimate into a **new gate, a block, a keypress, or a verdict** —
  the explicit anti-goal and the central architectural commitment.
- **Human-gate-time numeric estimation.** `human_gate_time` remains the
  qualitative caveat string S1 defined; S4 surfaces it verbatim, it does not
  numerically estimate per-gate latency.

## 3. Grounding in the existing pipeline

### 3.1 The precedent S4 mirrors

The orchestrator already folds one informational signal into a hard gate without
making it a decision point: `cartograph_pending_count` at Plan Approval. The
orchestrator file states it plainly — it is "presented in the summary above as
informational observability — it is **not** a separate decision point at this
gate … the orchestrator proceeds … without further prompting." S4 makes the cost
estimate the **second** such informational field, at **both** gates, under the
same rule. This is not a new pattern; it is a second instance of an established
one, which is what keeps the fold-in low-risk.

### 3.2 Why T1 dispatches per slice

The estimate-record format is **one record per target**. The S2 agent accepts a
single slice as a target (`target_kind: slice`, `medium` confidence ceiling). A
true **per-slice** breakdown — the thing that lets a human compare slices when
choosing which to progress — therefore requires **one dispatch per slice**. At
the moment T1 fires (immediately after carpaccio, before the human disposes),
every slice is `disposition: pending`, so S4 estimates **all** slices in the
record. The dispatches are **independent and read-only**, so they run in
**parallel** in a single message (the orchestrator's existing PARALLEL
affordance), keeping wall-clock to a single dispatch's latency.

The alternative — one dispatch against the whole slicing record
(`target_kind: slicing-record`) — was rejected: it yields a single whole-task
figure with no per-slice comparison, which is exactly the decision support the
ticket names as highest-value. (Disposition recorded in §8.)

### 3.3 Why estimates are persisted, not inline-only

Every other agent-emitted record in the pipeline (carpaccio, diaboli,
cartographer) is **written to disk, validated, then summarised** at its gate. S4
follows the same shape: persist each estimate to `cost-estimates/` (the S3
convention), run the S3 Output Validation Checkpoint, then surface a compact
summary. This gives an **audit trail** and an **observability artefact**
(harness-health / superpowers-status can read persisted estimates), and it
satisfies the CLAUDE.md **Output Validation Checkpoints** convention, which
requires any step that produces structured markdown parsed downstream to read it
back and validate it. Inline-only (persist nothing) was rejected as inconsistent
with the pipeline and unobservable. (Disposition recorded in §8.)

## 4. The fold-in mechanism

### 4.1 T1 — Slice Adjudication gate

Inserted into orchestrator §"After carpaccio completes — Slice Adjudication
Gate", **between** Step 2 (Validate the slicing record) and Step 3 (Surface the
slicing record). New **Step 2a — Estimate per-slice cost (informational
fold-in)**:

1. For **each** slice in the validated slicing record, dispatch the
   `cost-estimator` agent with that slice as the target and an **explicit**
   `target_kind: slice` (the dispatcher-stated-kind path — no inference-basis
   line required of the agent). Dispatch all slices **in parallel** in a single
   message.
2. For each returned string:
   - If it begins with `REFUSED:` — do **not** write a file. Record the refusal
     reason for that slice's summary line (§6.1).
   - Otherwise, write the returned content to
     `cost-estimates/<YYYY-MM-DD>-<task-slug>-<slice-id>-estimate.md` (the S3
     output convention, extended with the slice id so per-slice records do not
     collide), then run the **Output Validation Checkpoint** (§4.4) on it.
3. Proceed to Step 3, which now surfaces the per-slice cost summary **inside** the
   existing presentation (§5.1). The existing **hard gate is unchanged**: the
   human still sets `disposition` and `progressed_slice` exactly as today.

T1 fires **before** the human disposes the slices (it must, to inform the
disposition). Steps 4–7 of the existing gate (re-dispatch on revised, create
issues, update context, dispatch spec-writer) are unchanged. On a `revised`
re-dispatch of carpaccio (Step 4), the per-slice estimates are **re-run** against
the new record (the old per-slice records are overwritten).

### 4.2 T2 — Plan Approval gate

Inserted into orchestrator §"After spec-writer completes", **between** Step 6
(Surface the choice-story record — soft gate) and Step 7 (Plan Approval Gate).
New **Step 6a — Estimate progressed-slice cost (informational fold-in)**:

1. Dispatch the `cost-estimator` agent **once** against the **progressed slice's
   spec file** with an explicit `target_kind: spec` (the `high` confidence
   ceiling — the tightest estimate the pipeline produces).
2. If the returned string begins with `REFUSED:` — do not write; record the
   refusal for the summary (§6.1). Otherwise write it to
   `cost-estimates/<YYYY-MM-DD>-<spec-slug>-estimate.md` and run the Output
   Validation Checkpoint (§4.4).
3. Proceed to Step 7, which surfaces the estimate summary **inside** the existing
   Plan Approval presentation (§5.2). The existing **hard+soft composite gate is
   unchanged**: the approve / request-changes / take-over choice is exactly as
   today, and `cartograph_pending_count` continues to surface alongside.

On a **request-changes** re-dispatch of spec-writer, the T2 estimate is re-run
against the revised spec (the prior record is overwritten).

### 4.3 Dispose-then-write ordering for a record with no disposition

The **dispose-then-write ordering invariant** says a record the human
**adjudicates** must be disposed before it is written. An estimate record carries
**no disposition** — it is informational, never adjudicated (the S1 two-layer
no-verdict guarantee means it has no `recommendation`/`verdict`/`proceed` field
and no go/no-go prose). So there is nothing to dispose *about the estimate* before
writing it. The orchestrator persists the estimate as **gate-preparation**,
exactly as it already writes the carpaccio, diaboli, and cartographer records to
disk **before** the human disposes the *slices / objections / stories* those
files carry. The invariant is preserved because:

- The **agent stays read-only** — the orchestrator owns the write, never the
  estimator (the trust boundary that makes the whole pattern honest).
- The estimate has **no disposition fields** for an agent to fill, so no agent
  can write a disposition (the explicit ticket anti-goal "do NOT let any agent
  write dispositions" is satisfied vacuously *and* structurally).
- The human's **existing** dispositions (slice progression at T1; plan approval
  at T2) still come **after** the estimate is surfaced — the estimate *informs*
  those dispositions, it does not replace or precede the human's engagement with
  the records that **do** carry dispositions.

### 4.4 Output Validation Checkpoint (reused from S3)

Each persisted estimate record is read back and checked against every line of
`ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`'s
validation checklist — **identically to the S3 command**, including the #377
per-stage cost coupling and the split-tier strict-spread checks. The checkpoint
operates under the same **transparency-at-the-disposition-seat** discipline S3
established:

- It **fixes structural-only deviations in place** (routinely just deleting a
  stray verdict field) and **aborts — never authors — on any derived-value
  defect** (a malformed range, an ungrounded cost figure). An abort on one
  per-slice record at T1 drops **that slice's** cost line to an "estimate
  unavailable" state (§6.1); it never blocks the gate.
- It does **not** re-dispatch the agent (CLAUDE.md checkpoint convention).
- Because the checkpoint logic is identical across the `/cost-estimate` command
  and this fold-in, the orchestrator **references** the S3 checkpoint description
  by name rather than re-inlining the checklist — the single-source-of-truth
  discipline the orchestrator already uses for the carpaccio and cartographer
  validation references.

## 5. What surfaces in each gate

The fields are deliberately **compact** — the design risk the ticket names is
that a verbose cost dump turns decision-support into cognitive friction.

### 5.1 T1 — per-slice cost line (Slice Adjudication)

Appended to each slice's existing presentation block (title, scope,
`decision_focus`), **one line per slice**:

> **Est. cost** — tokens `<low>`–`<high>`; cost `<$low>`–`<$high>` *(or* "not
> grounded — no snapshot" *)*; confidence `<tier>`; *<one-clause failure
> direction>*.

- `tokens` low/high from the record's whole-record `tokens` range.
- `cost` low/high from the whole-record `cost_usd` range **when present**;
  otherwise the literal phrase "not grounded — no snapshot" (never a list-price
  guess — the S1 no-fallback rule, surfaced honestly).
- `confidence` is the record's `min()`-of-axes summary tier (for a slice target,
  the `tokens`/`time` ceiling is `medium`).
- The **failure direction** is a single clause lifted from the record's `Failure
  direction` body section (e.g. "more likely to overrun"), so the human sees the
  asymmetry, not just a midpoint.

A slice whose estimate **refused or failed the checkpoint** shows:

> **Est. cost** — unavailable (*<short reason>*).

### 5.2 T2 — progressed-slice estimate block (Plan Approval)

Added to the Plan Approval summary as a labelled block, alongside the existing
`cartograph_pending_count` and `carpaccio_progressed_slice` fields:

> **Cost estimate (spec-grounded, this slice)**
> - tokens `<low>`–`<high>` (confidence `<tier>`)
> - agent-compute time `<low>`–`<high>`
> - cost `<$low>`–`<$high>` *(or* "not grounded — no snapshot" *)*
> - human-gate time: *<the verbatim `human_gate_time` caveat string>*
> - excluded: *<one-line pointer to the record's `Excluded` section>*

The fuller shape than T1 is warranted because the spec-grounded estimate is
higher confidence and this is the last gate before code is written. The
**`human_gate_time` caveat is surfaced verbatim** so the human is reminded that
wall-clock is dominated by gate latency the estimate does not count — the single
most important honesty signal at the moment of plan approval.

### 5.3 Context-object additions

The orchestrator context object (the running string passed between agents) gains
structured fields so observability tooling can read estimate state:

```text
t1_estimate_slugs: [<task-slug>-<slice-id>, …] | []     # persisted T1 records
t1_estimate_refused_count: N                              # slices that refused/failed
t2_estimate_slug: <spec-slug> | null                     # persisted T2 record
t2_estimate_grounded: true | false                        # cost_usd present?
```

These are **informational observability**, not decision points — mirroring how
`cartograph_pending_count` is "surfaced as a structured field, not just prose, so
observability tooling can read it."

## 6. Failure modes — the gate never degrades

The governing invariant: **an unavailable estimate leaves the existing gate
exactly as it is today.** The estimate is additive; its failure subtracts
nothing.

### 6.1 The agent REFUSES

The S2 agent returns a stable `REFUSED:` string when it cannot ground an estimate
(missing `MODEL_ROUTING.md`, unreadable/unclassifiable target). On `REFUSED:`:

- No file is written (the agent already wrote nothing; the orchestrator writes
  nothing for that target).
- T1: that **slice's** cost line shows "unavailable (*<reason>*)" (§5.1); the
  other slices' estimates are unaffected; the gate proceeds.
- T2: the Plan Approval cost block shows "estimate unavailable (*<reason>*)"; the
  gate proceeds to the unchanged approve/request-changes/take-over prompt.

The refusal reason is surfaced **verbatim** (transparency), never re-interpreted.

### 6.2 The dispatch errors, or the checkpoint aborts

If an estimator dispatch errors, or the Output Validation Checkpoint **aborts**
on a derived-value defect, the affected target's estimate is treated exactly as a
refusal (§6.1): "unavailable", gate proceeds. **No estimator outcome — refusal,
error, or checkpoint abort — is ever a gate block or an extra keypress.** This is
the structural guarantee that the fold-in cannot reduce the orchestrator's
existing reliability.

### 6.3 No snapshot to ground cost

When no `observability/costs/` snapshot supplies a usable $/token rate, the agent
emits a valid record with **tokens + time but no `cost_usd`** (the S1
actuals-gated rule). This is **not** a failure — the estimate is valid and
surfaces tokens + time, with the cost slot showing "not grounded — no snapshot".
The token + time axes are the honest day-one value; cost is the actuals-gated
enhancement.

## 7. Acceptance scenarios

```gherkin
Scenario: T1 surfaces a per-slice cost breakdown inside the Slice Adjudication gate
  Given carpaccio has produced and validated a multi-slice slicing record
  When the orchestrator reaches the Slice Adjudication gate
  Then it dispatches the cost-estimator once per slice in parallel with explicit target_kind: slice
  And it persists each non-refused record under cost-estimates/<date>-<task-slug>-<slice-id>-estimate.md
  And it runs the S3 Output Validation Checkpoint on each persisted record
  And each slice's presentation block gains a one-line cost summary (tokens, cost-or-"not grounded", confidence, failure direction)
  And the human still sets disposition and progressed_slice exactly as before, with no extra keypress and no block

Scenario: T2 surfaces a tighter spec-grounded estimate inside the Plan Approval gate
  Given spec-writer, the spec-mode diaboli, and the choice-cartographer have completed for the progressed slice
  When the orchestrator reaches the Plan Approval gate
  Then it dispatches the cost-estimator once against the progressed slice's spec with explicit target_kind: spec
  And it persists the record and runs the Output Validation Checkpoint
  And the Plan Approval summary gains a cost-estimate block (tokens, agent-compute time, cost-or-"not grounded", verbatim human_gate_time caveat, excluded pointer) alongside cartograph_pending_count
  And the approve / request-changes / take-over choice is unchanged, with no extra keypress and no block

Scenario: A refused estimate never blocks the gate
  Given the cost-estimator returns a REFUSED: string for a target at T1 or T2
  When the orchestrator processes the result
  Then it writes no file for that target
  And it surfaces "estimate unavailable" with the verbatim refusal reason in that target's summary slot
  And the gate proceeds to its existing human disposition exactly as today

Scenario: A dispatch error or checkpoint abort is treated as unavailable, not a block
  Given an estimator dispatch errors, or the Output Validation Checkpoint aborts on a derived-value defect
  When the orchestrator processes the outcome
  Then the affected target's estimate shows "unavailable"
  And the existing gate proceeds with no block and no extra keypress

Scenario: No snapshot yields a valid tokens+time estimate with cost ungrounded
  Given no observability/costs/ snapshot supplies a usable $/token rate
  When the cost-estimator emits a record for a T1 slice or the T2 spec
  Then the record is valid with tokens and time but no cost_usd
  And the gate summary shows the cost slot as "not grounded — no snapshot", never a list-price guess

Scenario: No agent writes a disposition at either fold-in
  Given the orchestrator dispatches the read-only cost-estimator at T1 or T2
  Then the estimator holds Read/Glob/Grep only and writes nothing
  And the persisted estimate record carries no disposition, recommendation, or verdict field
  And only the human writes the existing slice / plan dispositions, after the estimate is surfaced
```

## 8. Decisions taken (for the choice-cartographer and the record)

- **Informational fold-in, never a new gate** — the central commitment, locked by
  the carpaccio slicing record's S4 `decision_focus` and confirmed here. Mirrors
  the existing `cartograph_pending_count` precedent.
- **Persist + validate + summarise** (not inline-only) — chosen for audit trail,
  observability, and consistency with every other pipeline record; satisfies the
  Output Validation Checkpoints convention. *(Open decision, dispositioned by the
  human at spec time.)*
- **T1 dispatches per slice, in parallel** (not one whole-record dispatch) —
  chosen to deliver the true per-slice comparison the ticket names as
  highest-value; the read-only dispatches parallelise to one dispatch's
  wall-clock. *(Open decision, dispositioned by the human at spec time.)*
- **T2 dispatches once against the spec** — the single progressed slice, `spec`
  kind, the pipeline's highest confidence ceiling.
- **Compact T1 line, fuller T2 block** — field selection tuned so the highest-
  frequency surface (per-slice at T1) stays terse while the once-per-iteration
  surface (T2) carries the fuller honesty signals (verbatim `human_gate_time`,
  excluded pointer).
- **Reuse S3's persistence + checkpoint by reference** — no re-inlined checklist;
  the orchestrator points at the S3 checkpoint discipline, keeping a single source
  of truth.

## 9. TDAD discipline note

The orchestrator agent file has **no** TDAD scenario files at
`tdad_tests/scenarios/agents/orchestrator/`, and is **exempt** under Amendment 2
§A2.6 of `docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md`
— the discipline applies forward to PRs that **add** a new component, not to
**modifications** of an existing agent file. S4 **modifies** the existing
orchestrator file (adding fold-in steps to two existing gates); it adds no new
skill, agent, or command artefact. The exemption therefore continues to hold for
this change. Per the existing in-file exemption comment, this modification is
recorded here and the exemption should be reviewed at the next quarterly
`/governance-audit` (target 2026-07-19) alongside cartograph stories #5 and #6.

## 10. Affected files

| File | Change |
| --- | --- |
| `ai-literacy-superpowers/agents/orchestrator.agent.md` | Add T1 Step 2a and T2 Step 6a fold-in; extend the gate presentations (Step 3, Step 7) with the cost summaries; add the context-object fields; update the exemption comment to reference this spec. |
| `ai-literacy-superpowers/.claude-plugin/plugin.json` | Version 0.44.0 → 0.45.0. |
| `README.md` | Plugin version badge 0.44.0 → 0.45.0. |
| `.claude-plugin/marketplace.json` | `plugin_version` 0.44.0 → 0.45.0 (listing `version` unchanged). |
| `CHANGELOG.md` | New 0.45.0 section describing the T1/T2 fold-in. |
| `docs/plugins/ai-literacy-superpowers/explanation/prospective-cost-estimation.md` | Turn the "future orchestrator fold-in" forward-reference present-tense; add a short fold-in section. |
| `docs/plugins/ai-literacy-superpowers/explanation/agent-orchestration.md` | Note the cost fold-in at the two existing gates. |
| `docs/superpowers/plans/2026-06-12-orchestrator-cost-fold-in.md` | Implementation plan (companion to this spec). |
