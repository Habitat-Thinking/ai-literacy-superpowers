---
name: cost-estimation
description: Use when the user wants to estimate or predict the cost, token usage, or time of a task BEFORE it runs — "how much will this feature cost to build", "estimate the tokens for this spec", "what will this slice cost", "predict the agent-compute time before I commit" — produces a token + time estimate as a range with disclosed confidence, adding a dollar figure only when an observability/costs snapshot grounds it. The prospective sibling of cost-tracking, which records actual spend after the fact.
---

# Cost Estimation

Estimate, *before* work runs, the token usage and time a task will
consume flowing through the orchestrator pipeline — and a dollar cost
**only when observed actuals exist to ground it**.

This is the **prospective** counterpart to the **retrospective**
`cost-tracking` skill. `cost-tracking` *records* what was spent into
`observability/costs/YYYY-MM-DD-costs.md`; this skill *reads* those same
snapshots as its $/token ground and *predicts* what a task will spend.
The two are siblings — a reader who finds one should find the other (see
[Sibling relationship](#sibling-relationship-to-cost-tracking)).

The day-one deliverable is a **token + time estimate**. Both axes are
fully groundable from `MODEL_ROUTING.md` today, so they are the honest
first-version value of this capability. The dollar figure is an
**actuals-gated enhancement** — present and grounded only when an
`observability/costs/` snapshot supplies a usable $/token rate, otherwise
omitted with an explicit disclosure (never a forced list-price guess).

This skill is **methodology and a format contract**. It describes how an
estimate is derived and what an estimate record must contain. It does not
dispatch an agent, write a file, or decide go/no-go — see
[What this skill does NOT do](#what-this-skill-does-not-do).

## An Estimate Is a Range, Never a Point

The material decision this skill locks: **an estimate is a range with
disclosed confidence, never a point value.**

A point value invites false precision. "12k tokens" reads as fact;
"10k–18k tokens, confidence medium, more likely to overrun than underrun
because the implementer stage spans two model tiers" reads as a
prediction a human can interrogate. The whole point of the capability is
to *inform* a human's choice, not to anchor it on a number dressed as a
fact.

Every quantitative field is therefore a `{ low, high }` range, and every
record carries per-axis confidence and the disclosures the contract
requires. The canonical field definitions live in the format reference:

**Format reference: [`references/estimate-record-format.md`](references/estimate-record-format.md)** — the
stable estimate-record field set, the tier→model→$/token binding table,
the four-part disclosure body, the validation checklist, and two worked
examples. A downstream command's Output Validation Checkpoint references
that file by path.

## Grounding Methodology

The grounding sources are **fixed, not chosen** — the methodology names
them, it does not offer a choice between them. Token ranges and
agent-compute time are **always** groundable from `MODEL_ROUTING.md`. The
dollar figure is groundable **only when a snapshot supplies a usable
$/token rate**; otherwise it is omitted. Human-gate time is **not
estimated numerically at S1**.

### Token derivation from MODEL_ROUTING.md

`MODEL_ROUTING.md` carries two tables the methodology consumes:

- **Token Budget Guidance** — per-role ranges: spec-writer 50–100k,
  tdd-agent 50–150k, implementer 100–250k, code-reviewer 50–100k,
  integration-agent 30–80k. Each role's `low`–`high` becomes that stage's
  `tokens` range.
- **Agent Routing** — the agent→model-tier mapping (orchestrator,
  spec-writer, advocatus-diaboli → `Most capable`; tdd-agent,
  integration-agent → `Standard`; implementer → `Standard / Capable`;
  code-reviewer → `Most capable`). Each stage's `model_tier` is read from
  this table.

The per-stage token ranges sum into the whole-record `tokens` range
(stages may be correlated, so the whole-record range need not equal the
arithmetic sum — when they differ the prose body must say why). Which
stages a target exercises depends on `target_kind`: a docs-only spec may
exercise spec-writer + review only, and the omitted stages **must** be
disclosed in `Excluded`.

**Split-tier stages.** The implementer stage maps to a **split tier**
`Standard / Capable` ("Depends on task complexity"), and it carries the
largest token budget (100–250k), so its rate dominates any cost figure.
The methodology does **not** leave the tier choice to agent discretion.
A split-tier stage is priced (when cost is computed at all) by **widening
its cost contribution to span both ends of the split**: its low bound
uses the cheaper end (`claude-sonnet-4`, the `Standard` representative)
and its high bound uses the dearer end (`claude-opus-4`, the `Most
capable` representative — the tier the split rises to for complex tasks,
since `MODEL_ROUTING.md` carries no standalone `Capable` model). Because
the two ends bind to **different** representative models, the widening
produces a genuine spread for this dominant stage rather than collapsing
to one rate. The `tokens_by_stage[].model_tier` field records the literal
split label (`Standard/Capable`) so the breakdown stays traceable.

### Cost derivation — only when a snapshot grounds it

`cost_usd` is **present only when an `observability/costs/` snapshot
supplies a usable per-tier $/token rate.** Deriving that rate requires a
named binding, because `MODEL_ROUTING.md` tiers are abstract labels with
no model or price, while the snapshot's Model Breakdown is keyed by model
name. The binding is fixed in the format reference's
**tier→model→$/token binding table**:

| Model tier (MODEL_ROUTING) | Representative model (snapshot key) |
| --- | --- |
| Most capable | `claude-opus-4` |
| Standard | `claude-sonnet-4` |
| Standard / Capable (split) | spans `claude-sonnet-4` (low) … `claude-opus-4` (high), widened |

`MODEL_ROUTING.md` names exactly two tiers — `Standard` and `Most
capable` — and one complexity-dependent split, the implementer's
`Standard / Capable`. There is **no standalone `Capable` tier with its
own model**; the dearer end of the split resolves to `Most capable`.

**Deriving a per-model rate from a snapshot.** The snapshot's
`## Model Breakdown` table gives, per model, quarter-aggregate
input/output token volumes and an estimated cost. The methodology
computes a per-model `$/token` as
`estimated_cost ÷ (input_tokens + output_tokens)` — a single blended rate
per model. The binding table maps each stage's tier to its representative
model's blended rate, and
`cost_usd = Σ over stages (stage tokens range × tier $/token)`, with
split-tier stages widened as above.

**Per-stage `cost_usd` bands (cost-present records only).** When a record is
cost-present (state 3 below), the emitter also surfaces the per-stage
decomposition that produced the whole-record figure: each exercised stage
carries a `tokens_by_stage[].cost_usd` `{ low, high }` band (the stage's
`tokens` range × its tier rate), with split-tier stages priced `low` at the
cheaper representative model and `high` at the dearer one so the spread is
strictly positive (`low < high`). This follows the format reference's
**per-stage band pricing convention** — an emitter obligation (a SHOULD), not a
validation-rejection rule, and not a new derivation. On a cost-omitted record no
stage carries the sub-field (the coupling is one-directional: a per-stage band
never appears without the top-level `cost_usd`).

**The three grounding states.** The snapshot's Model Breakdown is marked
"(if available)" in the cost-tracking format, so the methodology branches
on **three** states, not two:

1. **No snapshot exists** — today's state; `observability/costs/` is
   empty (the 2026-05-29 health snapshot records "Last cost capture:
   never"). → `cost_usd` **omitted**, omission disclosed in `Excluded`.
2. **Snapshot exists but the Model Breakdown is absent or too coarse**
   to yield a per-tier rate (only the always-present Provider Spend table
   is populated, or the breakdown lacks the tiers the stage set needs). →
   `cost_usd` **omitted**, omission disclosed in `Excluded` **naming this
   specific cause** ("a cost snapshot exists but carries no usable
   per-model breakdown"). The methodology does **not** silently fall
   through to list price.
3. **Snapshot exists with a usable Model Breakdown** → `cost_usd`
   **present**, `cost_basis: snapshot-actuals`, `confidence.cost` set from
   the snapshot's age and granularity, and the snapshot date/quality
   disclosed in `Included`.

**There is no list-price fallback.** A list-price guess is not an
observed cost; emitting it as a first-class figure was the false
precision this methodology opposes. When cost cannot be grounded in
actuals, it is **omitted with disclosure**, and the day-one deliverable
remains the token + time estimate.

**The no-cost case is honest, not a failure.** When `cost_usd` is omitted
(states 1 and 2), the record is **valid and complete** — it is the
expected day-one shape. The `Excluded` section carries an explicit
omission disclosure, e.g.:

> "cost_usd: omitted — no repo cost snapshot exists yet, so no observed
> $/token is available; cost is not estimated. Token and time figures
> stand."

A grounded token + time estimate plus an honest "dollars are not yet
knowable" is more informative than a low-confidence list-price range that
says "we don't really know" in numeric clothing. **No format change is
required when the first snapshot lands** — the same
`cost_usd`/`cost_basis`/`confidence.cost` fields simply begin to appear.
This is the seam the [calibration loop](#the-calibration-loop-s6) now
closes.

## The Disclosure / Confidence Contract

This four-part disclosure body is a contract **this skill proposes** — it
is not a pre-existing promoted AGENTS.md decision. It serves the real
AGENTS.md **"agent-emit + dispatcher-persist + human-disposes"** trust
architecture: a research-and-author agent emits content and the human
disposes. The disclosure contract makes the derivation interrogable so
the human's disposition is informed. An estimate record that does not
satisfy this contract is invalid regardless of how good its numbers are.

### Mandatory four-part disclosure body

Every estimate record's prose body MUST contain four labelled sections:

1. **Included** — what the estimate counts, and the provenance/quality of
   each included input. Caveats about the *quality of an included input*
   (an assumed compute band, a snapshot of a given age) live here or
   under Confidence rationale, never under Excluded.
2. **Excluded** — what the estimate does NOT count, stated plainly:
   human-gate latency (excluded from `cost_usd` and `tokens` because
   gates cost wall-clock not tokens); re-runs and diaboli/cartograph
   cycles beyond one pass; any stages a target does not exercise. **When
   `cost_usd` is omitted because no usable snapshot rate exists, that
   omission is disclosed here.** Excluded items are the single most
   important honesty signal — a number that silently omits a cost class
   is worse than no number.
3. **Confidence rationale** — why each confidence axis (`tokens`, `time`,
   and, when present, `cost`) is what it is, tied to the `target_kind`
   and the grounding richness.
4. **Failure direction** — a one-line statement matching the
   `failure_direction` field, naming WHY the estimate is more likely
   wrong in that direction. **This section describes uncertainty only —
   it must contain no imperative recommendation and no go/no-go
   language.**

A record missing any of the four sections fails validation.

### Per-axis confidence

Confidence is recorded **per axis** (`tokens`, `time`, and — only when
`cost_usd` is present — `cost`), not as one whole-record tier. The
`tokens`/`time` axes have a **ceiling tied to `target_kind`**; the `cost`
axis has its own independent rule.

- **Target-kind ceiling (tokens/time):** `task-text` caps at `low`;
  `slicing-record`/`slice` at most `medium`; `spec` may reach `high`. The
  ceiling is a cap, not a verdict — an axis may sit below it, but a
  raw-text estimate's token confidence can never be `high`.
- **Cost axis (independent):** exists only when `cost_usd` is present.
  Set from the snapshot's quality (age, breakdown granularity), and
  **independent of `target_kind`** — a spec-grounded target with a stale
  snapshot can carry `tokens: high` beside `cost: low` without
  contradiction.

The `time` axis describes confidence in the `agent_compute_time` estimate
**only** — `human_gate_time` carries no numeric estimate at S1, so there
is no human-gate number for the `time` axis to qualify.

### Confidence is disclosed, never decisive — the two-layer no-verdict guarantee

The record carries confidence; it does **not** carry a verdict,
recommendation, or go/no-go. The human reads the ranges and disclosures
and decides. This guarantee has **two layers of differing strength**:

1. **Field-absence layer (structural)** — there is no `recommendation`,
   `verdict`, or `proceed` field. This layer IS a property of the format
   itself, independent of any agent's behaviour: a field that does not
   exist cannot carry a verdict. (Necessary but not sufficient: a verdict
   could be smuggled into free-text prose.)
2. **Positive-content layer (tripwire, not proof)** — the four disclosure
   sections describe **inputs and uncertainty only**. They MUST NOT
   contain imperative recommendation or go/no-go language. A validation
   check scans the disclosure prose for prohibited patterns ("so proceed",
   "do not proceed", "I recommend", "you should [ship|skip|approve|reject]",
   "go/no-go") and **fails the record** if any appear. A "failure
   direction: likely-overrun, so do not proceed" sentence fails this check
   even though it passes field-absence. But this scan is a **closed
   enumeration of common verdict phrasings — a tripwire, not a proof**: a
   paraphrased verdict ("the high bound makes this not worth building")
   can evade the listed patterns. Its strength is "catches the common
   cases", not "independent of any agent's behaviour".

The field-absence layer is a structural guarantee; the positive-content
layer catches the common cases and leans on the agent not paraphrasing
around the list. The enumerated checks live in the format reference's
validation checklist.

## The Time Split

`agent_compute_time` and `human_gate_time` are **two separate required
fields** with **different shapes**:

- **`agent_compute_time`** is the wall-clock the model spends generating
  — the predictable term. It is derived from token volume by applying a
  disclosed tokens→wall-clock band (the reference fixes a default, e.g.
  "~1–3 min per 10k tokens generated") to the `tokens` range, yielding a
  numeric `{ low, high }` range. The band is stated as an assumption in
  `Included`; it is not claimed to be an observed actual.
- **`human_gate_time`** is the wall-clock spent waiting for a human at
  the orchestrator's disposition gates. It **dominates** total wall-clock
  and is the **least predictable** term — it depends on when a human next
  sits down, not on the work itself. It is **not estimated numerically at
  S1**: it is a disclosed **qualitative caveat string**, not a range. Its
  grounding — the orchestrator gate set and how many gates a target
  passes through — lives in the orchestrator (S4), which this slice does
  not touch. Multiplying an ungrounded gate count by a per-gate band
  would re-introduce the very false precision the range-not-point
  decision exists to prevent.

Collapsing the two into one number would hide the dominant source of
variance. The failure-direction prose must reference this: an estimate
whose wall-clock omits human-gate latency is `likely-underrun` on
wall-clock unless the human-gate caveat is read alongside it.

## The Calibration Loop (S6)

The calibration loop is **implemented** (slice S6). The integration-agent
captures a **per-PR actuals record** at merge time — defined in
[`cost-tracking/references/per-pr-actuals-format.md`](../cost-tracking/references/per-pr-actuals-format.md)
and written to `observability/costs/per-pr/` — and this methodology reads the
accumulated records to refine estimates against **this repo's own history**.
True to the seam S1 promised, calibration ships with **no format change**: it is
the already-permitted `kind: calibration` `grounding_sources[]` entry plus a
disclosure, nothing more.

**What calibration refines — token ranges only.** Calibration narrows the
**per-stage token ranges** toward the observed history and, when enough records
exist for a stage, **raises the `tokens` confidence** one tier (never above the
`target_kind` ceiling). It does **not** touch `cost_usd` or `cost_basis`: the
$/token ground stays the snapshot (`cost_basis: snapshot-actuals`), and a per-PR
record's dollar figure — when present at all — is not promoted to a rate. This is
the deliberate token-ranges-only reach.

**How the records are read:**

- Glob `observability/costs/per-pr/` for actuals records. For each stage, gather
  the **supplied** per-stage token actuals (`tokens_by_stage[].tokens` that are
  numbers, not the literal `unavailable`) across the accumulated records and use
  their central tendency to narrow that stage's range.
- A record whose figures are `unavailable` still contributes its **structural**
  signal: its `stages_run` tells you which stages this repo actually exercises, so
  a stage the repo never runs can be dropped (disclosed in `Excluded`).
  `unavailable` is **not** zero — it never pulls a token magnitude down.
- Add a `kind: calibration` `grounding_sources[]` entry naming the `per-pr/`
  directory, and disclose the basis in `Confidence rationale` — how many records
  informed the narrowing and over what date range (e.g. "token ranges narrowed
  against 9 per-PR actuals, 2026-06 to 2026-08; cost unchanged — calibration
  refines tokens only").

**Zero history is the valid day-one state.** When `observability/costs/per-pr/` is
absent or empty, the methodology behaves exactly as it did before S6: generic
`MODEL_ROUTING.md` budgets, no `calibration` entry, no calibration disclosure. The
loop degrades cleanly to the pre-S6 behaviour.

**Calibration never overrides the disclosure contract.** A calibrated estimate is
still a range with disclosed confidence and a stated failure direction.
Calibration can narrow a range and raise its confidence; it can never collapse a
range to a point or suppress the `Excluded`/`Confidence rationale` disclosures.

## Sibling Relationship to cost-tracking

The `cost-estimation` skill is the **prospective** counterpart to the
**retrospective** `cost-tracking` skill. The two reuse the same
`observability/costs/` data:

- `cost-tracking` **writes** the snapshots (via `/cost-capture`).
- `cost-estimation` **reads** them as its $/token ground.

`/cost-capture` records what *was* spent; the future `/cost-estimate`
predicts what *will be* spent. A user who knows one half of the cost
capability should discover the other from either skill's description.

## What This Skill Does NOT Do

- **Does not dispatch an agent.** The read-only `cost-estimator` agent
  that *emits* a record is a downstream consumer, not this skill.
- **Does not write files or run a command.** Writing and validating a
  record is a downstream command's job; this skill defines what such a
  record must contain.
- **Does not wire into the orchestrator.** No gate is added, moved, or
  re-weighted by this skill; the orchestrator fold-in lives in the
  orchestrator agent (T0/T1/T2).
- **Does not capture calibration actuals.** This skill defines the
  calibration *methodology* (how per-PR actuals refine token ranges), but
  the per-PR actuals are written by the integration-agent and the format is
  owned by `cost-tracking` — this skill only reads them.
- **Does not decide go/no-go.** It emits ranges and disclosures for a
  human to dispose; it carries no verdict, recommendation, or
  recommendation prose.
