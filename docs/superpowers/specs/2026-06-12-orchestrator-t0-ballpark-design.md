# Cost Estimation — S5 — T0 pre-carpaccio ballpark — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-12 |
| Status | Draft |
| Author | spec-writer (interactive session with russmiles) |
| Slice | S5 of the slicing record at `docs/superpowers/slices/cost-estimator-pipeline.md` |
| Progressed slice | S5 (this spec) |
| Tracking issue | #372 |
| Upstream (merged on main) | S1 (skill + `estimate-record-format.md`); S2 (#369, the read-only `cost-estimator` agent); S3 (#370, the `/cost-estimate` command); S4 (#371, the T1/T2 orchestrator fold-in) |
| Downstream slices | S6 (#373, calibration loop) — out of scope here |
| Plugin version target | `ai-literacy-superpowers` v0.45.0 → v0.46.0 (behavioural change to the orchestrator agent — minor bump) |
| Marketplace listing | Top-level `version` unchanged at v0.4.0; `plugin_version` and the `plugins[]` entry both 0.45.0 → 0.46.0 |
| PR ceremony | feature — full `/diaboli` (spec + code) and `/choice-cartograph` |
| Governing decisions | AGENTS.md **"agent-emit + dispatcher-persist + human-disposes"** trust architecture; AGENTS.md **"disclosure-of-derived-judgment"** decision; the S4 **"informational fold-in, never a gate"** precedent; the S1 **loud-low-confidence disclosure** contract. |

---

## 1. Premise

The cost-estimator pipeline now reaches into the orchestrator at two **existing
gates**: T1 (Slice Adjudication) and T2 (Plan Approval), shipped by S4 (#371).
S5 adds the **earliest and weakest** insertion: **T0**, a coarse whole-task
ballpark from **raw task text only**, dispatched **before carpaccio** (before
orchestrator step 0).

T0 is a different kind of thing from T1/T2. T1 and T2 fold into gates the
orchestrator already owns and hard-enforces; T0 lives **outside any gate**
entirely. It is a **cheap go/no-go sniff-test**: before the task is sliced or
specced, the human gets a loud, explicitly low-confidence ballpark — "this looks
like a small thing" vs "this looks enormous" — and can choose to walk away before
investing in slicing, specs, and code.

This slice's load-bearing decision is the one the slicing record's
`decision_focus` names: **is the lowest-confidence, earliest insertion worth
shipping at all, and where exactly does it fire?** T0 estimates from raw text
alone are the least accurate and the **most prone to anchoring** a human on a
number before the work is understood. The decision weighs the go/no-go value of a
pre-pipeline ballpark against that anchoring risk. S5 commits to shipping T0 —
because the S1 loud-low-confidence disclosure is what makes a raw-text ballpark
defensible — under **two human dispositions taken at spec time** (§8):

1. **Firing position: after branch and issue creation, immediately before
   carpaccio.** The issue body is the canonical raw task text, and this is the
   cleanest, most consistent place to read "the task" from. T0 is **non-blocking**
   either way, so firing position does not change what ceremony is "saved" — it
   chooses the cleanest task-text source and the clearest "right before step 0"
   placement.
2. **Inline-only, never persisted.** A deliberate **asymmetry with S4**: the
   gate-folded T1/T2 estimates persist to `cost-estimates/` (decision-support with
   audit value), but the **earliest, least-accurate sniff-test stays ephemeral**.
   It is surfaced once, loudly low-confidence, in the orchestrator's pre-carpaccio
   output — and written **nowhere**. There is no authoritative file a later scan
   could read as fact, which is the strongest structural answer to the anchoring
   risk the slice flags.

T0 is a **pure consumer** of S1/S2. It adds no field to the estimate-record
format, reuses the S2 agent unchanged (the `task-text` target it already
accepts), and adds no new skill, agent, or command. The only file whose
**behaviour** changes is `ai-literacy-superpowers/agents/orchestrator.agent.md`.

## 2. Scope and non-goals

### 2.1 In scope (S5)

- A **T0 pre-step** in the orchestrator's "Before dispatching carpaccio"
  sequence: after branch creation and issue creation, and **immediately before**
  carpaccio (step 0), dispatch the `cost-estimator` **once** against the **raw
  task text** (the issue body / the user's plain-English task) as an **inline
  `task-text` target** with explicit `target_kind: task-text` (the `low`
  confidence ceiling).
- **Inline-only surfacing** of a compact ballpark with the **loud low-confidence
  disclosure** (§4, §5). **No file is written. No Output Validation Checkpoint
  runs** (nothing structured is persisted for a downstream consumer to parse).
- The **non-blocking / no-gate** guarantee: T0 surfaces and the orchestrator
  **proceeds to carpaccio without pausing** (§4.2). The human may abort the task
  manually; the orchestrator does not enforce a stop.
- The **never-degrades** handling: a `REFUSED:` string or a dispatch error
  surfaces "T0 ballpark unavailable (*reason*)" and the orchestrator proceeds to
  carpaccio exactly as today (§6).
- The deliberate decision to **keep T0 out of the context object** (§4.3) — it is
  surfaced to the human once and is not threaded to any downstream agent, which
  reinforces the ephemeral, anti-anchoring intent.
- Version bump, CHANGELOG, marketplace `plugin_version` **and** the `plugins[]`
  entry, README badge **and** the plugin-table cell, and the docs updates that
  turn the cost-estimation concept page's T0/T1/T2 picture complete.

### 2.2 Out of scope (S5)

- **T1 / T2** — already shipped by S4 (#371). S5 does not touch the existing
  gates.
- Any change to the **estimate-record format** (S1), the **`cost-estimator`
  agent** (S2), or the **`/cost-estimate` command** (S3).
- **Persisting** the T0 ballpark, or running a checkpoint on it — explicitly
  rejected (§8), the central anti-anchoring commitment.
- Turning T0 into a **hard gate, a block, or a keypress-bearing prompt** — the
  explicit anti-goal. The slice scope is unambiguous: "does not block carpaccio;
  carries no gate."
- The **calibration loop** (S6, #373).

## 3. Grounding in the existing pipeline

### 3.1 Why T0 fires from the issue body, immediately before carpaccio

The orchestrator's "Before dispatching carpaccio" section already does two
things: confirm/create the branch, then create the GitHub issue. The issue body
**is** the canonical raw task text the carpaccio agent is about to slice. Firing
T0 right after issue creation means T0 and carpaccio read the **same** task text,
and T0 sits exactly where the slice names it — "before orchestrator step 0." T0
is **non-blocking**, so an earlier firing position would not save the branch/issue
ceremony anyway; the deciding factor is the cleanest task-text source and the
clearest placement, which is here.

### 3.2 Why T0 is inline-only while T1/T2 persist

S4 persists its gate estimates because they are **decision-support folded into a
gate**, with audit and observability value, validated by the S3 checkpoint. T0 is
the opposite case on the one axis that matters here — **accuracy**. It is the
`task-text` ceiling (`low`), the least-grounded estimate the pipeline can produce,
fired before any decomposition exists. A persisted low-confidence number reads as
more authoritative than it is — the exact anchoring failure the slice's
`decision_focus` warns about. Keeping T0 **ephemeral** (surfaced once, written
nowhere) is the structural mitigation: there is no file, so there is nothing for a
later scan, an observability tool, or a future reader to mistake for fact. The
honesty of T0 rests entirely on the **loud low-confidence disclosure** at the
moment it is surfaced, not on a durable record.

### 3.3 Why T0 follows the S4 "informational, never a gate" philosophy

T0 inherits S4's central commitment — an estimate is **informational, never a
decision point**. It carries no verdict (the S1 two-layer no-verdict guarantee),
adds no block and no keypress, and lets no agent write a disposition (the agent is
read-only and T0 persists nothing for any agent to fill). The human reads the
ballpark and may act on it (continue, or abort the task), but the orchestrator's
flow does not branch on it.

## 4. The T0 mechanism

### 4.1 Placement and dispatch

Inserted into orchestrator §"Before dispatching carpaccio" as a new **Step 3 — T0
ballpark (bonus, non-blocking)**, after branch creation (Step 1) and issue
creation (Step 2), and before the "After carpaccio completes" section's "Step 1:
Dispatch carpaccio":

1. Dispatch the `cost-estimator` agent **once** with the **raw task text** (the
   issue body created in Step 2, or the user's plain-English task) supplied as an
   **inline string**, and an **explicit** `target_kind: task-text` (the
   dispatcher-stated-kind path — no inference-basis line required; and the `low`
   confidence ceiling is correct for raw text).
2. The agent returns the estimate-record content as a string (or a `REFUSED:`
   string). The orchestrator reads the returned string to extract the ballpark
   fields for the inline summary (§5). It **does not write the string to disk**
   and **does not run a checkpoint**.

### 4.2 Surface and proceed (non-blocking)

The orchestrator surfaces the compact ballpark (§5) to the human as part of its
pre-carpaccio output, then **proceeds directly to carpaccio (step 0)**. It does
**not** PAUSE-and-wait, does **not** add a keypress, and does **not** ask a
go/no-go question. The human, seeing a ballpark that alarms them, retains the
standing ability to interrupt and take over (as they may at any point); T0 adds no
new enforced stop. This is the "carries no gate" requirement, satisfied
structurally.

### 4.3 T0 is not threaded into the context object

Unlike S4's `t1_estimate_*` / `t2_estimate_*` fields, T0 is **deliberately not
added to the orchestrator context object** and is **not** passed to carpaccio or
any downstream agent. It is surfaced to the human once and then discarded. This is
intentional: threading a low-confidence raw-text number downstream would
re-introduce the anchor the inline-only decision exists to avoid. The orchestrator
notes this asymmetry inline so a future maintainer does not "helpfully" add a
persisted T0 field.

## 5. What surfaces (the loud low-confidence ballpark)

A compact block in the orchestrator's pre-carpaccio output, framed to make the
coarseness **loud**, not buried:

> **T0 ballpark (pre-slice, coarse — low confidence)**
> - tokens `<low>`–`<high>` (confidence **low** — raw task text only, before any
>   slicing or spec)
> - cost `<$low>`–`<$high>` *(or* "not grounded — no snapshot" *)*
> - *<the record's `Confidence rationale` one-liner and `Failure direction`
>   clause, surfaced verbatim — e.g. "scope is a guess; the stage set is assumed;
>   more likely to underrun than overrun">*
> - This is a **go/no-go sniff-test, not an estimate to plan against.** The
>   per-slice numbers at Slice Adjudication (T1) and the spec-grounded number at
>   Plan Approval (T2) are the figures to actually weigh.

The "low confidence" label and the "sniff-test, not an estimate to plan against"
framing are **required** — they are what keep a raw-text ballpark from anchoring.
The cost line shows "not grounded — no snapshot" rather than a list-price guess
(the S1 no-fallback rule).

## 6. Failure modes — T0 never degrades the run

The governing invariant: **an unavailable or failed T0 changes nothing about the
run.** T0 is a bonus; its absence subtracts nothing.

- **The agent REFUSES** (e.g. an absent `MODEL_ROUTING.md`, or task text too thin
  to classify): no file is written (none ever is), and the orchestrator surfaces
  "T0 ballpark unavailable (*verbatim reason*)" and proceeds to carpaccio.
- **The dispatch errors:** treated identically — "T0 ballpark unavailable", then
  proceed.
- **No snapshot to ground cost:** not a failure — the agent emits a valid
  tokens-only ballpark; the cost line shows "not grounded — no snapshot". Tokens
  are the honest day-one value; cost is the actuals-gated enhancement.

No T0 outcome — refusal, error, or thin text — is ever a block, a keypress, or a
reason not to run carpaccio.

## 7. Acceptance scenarios

```gherkin
Scenario: T0 surfaces a coarse ballpark before carpaccio, then proceeds
  Given the orchestrator has created the branch and the GitHub issue for a task
  When it reaches the point immediately before dispatching carpaccio
  Then it dispatches the cost-estimator once against the issue body as an inline task-text target with explicit target_kind: task-text
  And it surfaces a compact ballpark labelled low confidence, with the "sniff-test, not an estimate to plan against" framing
  And it writes no file and runs no Output Validation Checkpoint
  And it proceeds directly to carpaccio with no pause, no keypress, and no go/no-go prompt

Scenario: T0 is ephemeral — not persisted and not threaded downstream
  Given the orchestrator surfaces a T0 ballpark
  Then no estimate record is written to cost-estimates/ for T0
  And the T0 figures are not added to the context object passed to carpaccio or any downstream agent

Scenario: A refused or errored T0 never blocks the run
  Given the cost-estimator returns REFUSED: for the task text, or the dispatch errors
  When the orchestrator processes the outcome
  Then it writes no file
  And it surfaces "T0 ballpark unavailable" with the verbatim reason
  And it proceeds to carpaccio exactly as it would today

Scenario: No snapshot yields a valid tokens-only ballpark
  Given no observability/costs/ snapshot supplies a usable $/token rate
  When the cost-estimator emits the T0 ballpark
  Then the ballpark shows tokens and confidence with the cost line as "not grounded — no snapshot", never a list-price guess

Scenario: T0 carries no verdict
  Given the orchestrator surfaces a T0 ballpark
  Then the surfaced text contains no recommendation, verdict, or go/no-go directive
  And the human reads the ranges and decides whether to continue, with the orchestrator proceeding regardless
```

## 8. Decisions taken (for the choice-cartographer and the record)

- **Ship T0 at all** — yes. The go/no-go value of a pre-pipeline ballpark is real,
  and the S1 loud-low-confidence disclosure is the forcing function that keeps a
  raw-text number honest. *(The in/out decision the slice names.)*
- **Firing position: after branch + issue, immediately before carpaccio** — chosen
  for the cleanest task-text source (the issue body) and the clearest "right
  before step 0" placement; T0 is non-blocking, so position does not trade off
  ceremony. *(Open decision, dispositioned by the human at spec time.)*
- **Inline-only, never persisted** — the central anti-anchoring commitment, a
  deliberate asymmetry with S4's persisted gate estimates. No file, no checkpoint,
  honesty resting on the surfaced disclosure. *(Open decision, dispositioned by
  the human at spec time.)*
- **Not threaded into the context object** — T0 is surfaced once and discarded, so
  a low-confidence raw-text number is never carried downstream as an anchor.
- **Non-blocking, no gate, no verdict** — inherits the S4 "informational, never a
  decision point" philosophy; satisfies the slice's "does not block carpaccio;
  carries no gate" requirement structurally.

## 9. TDAD discipline note

The orchestrator agent file has **no** TDAD scenario files and is **exempt** under
Amendment 2 §A2.6 of
`docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md` — the
discipline applies forward to PRs that **add** a new component, not to
**modifications** of an existing agent file. S5 **modifies** the existing
orchestrator file (adding a T0 pre-step); it adds no new skill, agent, or command
artefact. The exemption continues to hold. This modification is recorded here and
the exemption should be reviewed at the next quarterly `/governance-audit` (target
2026-07-19), as the in-file exemption comment directs.

## 10. Affected files

| File | Change |
| --- | --- |
| `ai-literacy-superpowers/agents/orchestrator.agent.md` | Add the T0 pre-step (Step 3 of "Before dispatching carpaccio"); note T0 in the Pipeline overview as a pre-step-0 bonus; record the "not threaded into the context object" asymmetry; update the exemption comment to reference this spec. |
| `ai-literacy-superpowers/.claude-plugin/plugin.json` | Version 0.45.0 → 0.46.0. |
| `README.md` | Plugin version badge **and** plugin-table cell 0.45.0 → 0.46.0. |
| `.claude-plugin/marketplace.json` | `plugin_version` **and** the `plugins[]` entry's `version` 0.45.0 → 0.46.0 (listing `version` unchanged). |
| `CHANGELOG.md` | New 0.46.0 section describing the T0 ballpark. |
| `docs/plugins/ai-literacy-superpowers/explanation/prospective-cost-estimation.md` | Add T0 to the fold-in/insertion picture, with the inline-only-vs-persisted asymmetry called out. |
| `docs/plugins/ai-literacy-superpowers/explanation/agent-orchestration.md` | One sentence noting the pre-pipeline T0 ballpark. |
| `docs/superpowers/plans/2026-06-12-orchestrator-t0-ballpark.md` | Implementation plan (companion to this spec). |
