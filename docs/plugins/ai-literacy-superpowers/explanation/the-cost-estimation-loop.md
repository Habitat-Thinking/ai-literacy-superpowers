---
title: The Cost Estimation Loop
---
# The cost estimation loop

This page explains how the cost-estimation capability works **as a whole**
and how it threads through the orchestrator workflow. It is the
end-to-end, lifecycle view. For *what each piece is* — the range-not-point
contract, the read-only agent, the `/cost-estimate` command — see
[Prospective Cost Estimation](prospective-cost-estimation.md). For the
pipeline those pieces fold into, see [Agent Orchestration](agent-orchestration.md).

## The loop in one sentence

A task is **estimated** before and during the pipeline, the work **runs**,
the integration-agent **captures what it actually cost**, and those
captured actuals **sharpen the next estimate** — a prospective-then-
retrospective cycle that calibrates against this repo's own history.

```text
        ┌──────────────────────────────────────────────────────────────┐
        │                                                                │
        v                                                                │
  raw task ──▶ T0 ──▶ carpaccio ──▶ T1 ──▶ spec ──▶ T2 ──▶ build ──▶ merge
   text       │       (slice)      │               │                  │
              │                    │               │                  │
          ballpark            per-slice        spec-grounded     integration-agent
        (pre-slice,          estimates,        estimate, fuller   captures per-PR
         ephemeral)          informational     block at Plan      actuals record
                             fields at Slice   Approval                 │
                             Adjudication                               │
                                                                        │
                  observability/costs/per-pr/  ◀───────────────────────┘
                  (per-PR actuals)                       writes
                          │
                          │  read as kind: calibration
                          ▼
                  narrows future per-stage token ranges  ──┐
                                                           │
        (feeds back into the next T0 / T1 / T2 estimate) ──┘
```

The dotted return path is the part S6 added — it is what makes this a
**loop** rather than a one-shot estimator.

## The contract every estimate inherits

Before the surfaces, the thing they all share. An estimate in this system
is **a range with disclosed confidence, never a point value**, carrying a
four-part disclosure body — *Included*, *Excluded*, *Confidence rationale*,
*Failure direction* — and **no verdict**. Token and agent-compute-time
figures are always present; a **dollar figure appears only when an
`observability/costs/` snapshot grounds it** (never a list-price guess).
This honesty contract is defined once, in the `cost-estimation` skill, and
every surface below emits records that conform to it. See
[Prospective Cost Estimation](prospective-cost-estimation.md) for the full
contract.

The component that *produces* a record is the read-only `cost-estimator`
agent. Its trust boundary is the mechanism the whole loop rests on: it
holds **`Read`, `Glob`, `Grep` only**. It emits the record content as a
string and can neither persist it nor decide go/no-go. Whoever dispatches
it — a command, or the orchestrator at a gate — owns the write, and the
human reads the ranges. The agent **refuses** rather than fabricate an
ungroundable estimate.

## Four surfaces, three of them inside the workflow

The estimator is dispatched from four places. Three are **insertion points
in the orchestrator pipeline**; one is a **standalone command** for ad-hoc
use. The defining design choice across all of them: an estimate is an
**informational field, never a new gate** — it never blocks, never adds a
keypress, and never carries a verdict.

### T0 — the pre-carpaccio ballpark

**When:** after the orchestrator creates the branch and the issue, and
immediately *before* carpaccio slices the task.

**What:** a coarse whole-task estimate from the **raw task text only**
(`target_kind: task-text`, the `low` confidence ceiling). A go/no-go
sniff-test — "this looks small" versus "this looks enormous" — before any
slicing or spec exists.

**How it behaves:** deliberately **inline-only and ephemeral**. It is
surfaced once, loudly framed as low-confidence ("a sniff-test, not an
estimate to plan against"), and written **nowhere** — not persisted, not
even threaded into the context object. This is a conscious asymmetry with
T1/T2: the least-accurate number must never read as an authoritative
artefact, so there is no file for a later reader to mistake for fact. The
orchestrator proceeds to carpaccio regardless.

### T1 — per-slice estimates at Slice Adjudication

**When:** after carpaccio produces the slicing record and it is validated,
folded into the existing **Slice Adjudication** gate.

**What:** the orchestrator dispatches the estimator **once per slice, in
parallel** (`target_kind: slice`, `medium` ceiling), persists each record
under `cost-estimates/`, and appends a **compact one-line cost summary** to
each slice's block (tokens, cost-or-"not grounded", confidence, failure
direction).

**Why here:** this is the highest-value moment. You are choosing which
slice to progress, file, or defer — and now you can see each slice's cost
*while* you choose. The existing hard gate is unchanged; the cost lines
inform the disposition, they do not replace it.

### T2 — the spec-grounded estimate at Plan Approval

**When:** after spec-writer, the spec-mode advocatus-diaboli, and the
choice-cartographer complete, folded into the existing **Plan Approval**
gate.

**What:** one dispatch against the progressed slice's **spec**
(`target_kind: spec`, the `high` ceiling — the tightest estimate the
pipeline produces, because the spec enumerates scenarios and files). A
fuller cost block is surfaced alongside `cartograph_pending_count` —
tokens, agent-compute time, cost, the **verbatim `human_gate_time`
caveat**, and an excluded-pointer.

**Why a fuller block:** this is the last gate before code is written, and
the estimate is at its most confident. The `human_gate_time` caveat is
surfaced verbatim as the honesty reminder that wall-clock is dominated by
gate latency the estimate does not count.

### `/cost-estimate` — the standalone surface

Off the pipeline entirely: point `/cost-estimate` at a slice, a spec, a
slicing record, or pasted task text and it dispatches the same agent,
persists the record to `cost-estimates/`, and runs an Output Validation
Checkpoint — the prospective counterpart to the retrospective
`/cost-capture`. Use it to ask "what would this cost?" without running a
full pipeline.

### Why T0 is ephemeral but T1/T2 persist

T1 and T2 are decision-support folded into gates, with audit and
observability value, so they are **written to disk and validated** (the
same write-then-summarise shape every other pipeline record uses). T0 is
the earliest, least-grounded number, so it is **ephemeral**. The split is
deliberate, and it is the same reasoning each time: confidence and
durability should track each other, so a low-confidence figure never
acquires the authority of a persisted artefact.

## What grounds an estimate

| Source | Supplies | Always available? |
| --- | --- | --- |
| `MODEL_ROUTING.md` Token Budget Guidance | per-stage token ranges | yes |
| `MODEL_ROUTING.md` Agent Routing | the agent→model-tier mapping | yes |
| `observability/costs/<date>-costs.md` snapshot | the `$/token` rate for a dollar figure | only when a snapshot exists |
| `observability/costs/per-pr/` per-PR actuals | calibration — narrows per-stage token ranges against repo history | only once history accumulates |

The first two are generic — the same for every repo. The snapshot is what
turns a token estimate into a dollar estimate. The fourth is what closes
the loop.

## Closing the loop — calibration

Everything above grounds in *generic* budgets. The **calibration loop**
(slice S6) lets the estimator learn what work in **this** repo actually
costs.

**Capture.** At integration time — after the CHANGELOG, before the commit,
so the record ships *in the PR* and never commits to `main` — the
integration-agent writes a **per-PR actuals record** to
`observability/costs/per-pr/`. It auto-captures the structurally-observable
facts (which stages ran, review-cycle count, files and languages touched,
the progressed slice) from the context object and git, and records the
task's token/cost figures **when a human supplies them** (for example,
pasted from Claude Code's `/cost`).

**Feedback.** On its next dispatch, the estimator globs
`observability/costs/per-pr/`, and when records exist it adds a
`kind: calibration` grounding source and **narrows its per-stage token
ranges** toward the observed history (raising the `tokens` confidence when
there is enough of it). Every future T0, T1, T2, and `/cost-estimate`
benefits — that is the loop.

Two honesty rules bound the capture, and they are the load-bearing part of
the design:

- **No fabrication.** A subagent cannot read "tokens spent on this PR"
  programmatically, so when a human supplies no figures they are recorded
  as the literal `unavailable` — never invented, never `0`. An
  `unavailable` record still calibrates *which stages this repo exercises*;
  it contributes nothing to the token magnitudes.
- **Token ranges only.** Calibration narrows token ranges; it never touches
  the dollar rate, which stays bound to the snapshot
  (`cost_basis: snapshot-actuals`). True to the seam the skill kept open
  from S1, the whole loop ships with **no change to the estimate-record
  format** — just the already-permitted `kind: calibration` entry and a
  disclosure.

## The invariants that hold across the whole loop

These are the properties that make the loop trustworthy rather than a
source of anchoring or friction:

1. **Informational, never a gate.** No surface blocks, adds a keypress, or
   introduces a decision point. Estimates fold into *existing* gates (T1,
   T2) or sit beside them (T0); the human's existing dispositions are
   unchanged. This mirrors the orchestrator's `cartograph_pending_count`
   precedent.
2. **A read-only emitter, a separate writer.** The agent emits; a
   dispatcher persists; the human disposes. The agent holds no write tool,
   so it cannot bypass the human.
3. **A range with disclosed confidence, never a verdict.** Every record
   discloses what it included, excluded, its confidence, and its failure
   direction — and carries no recommendation.
4. **No fabrication.** Dollars appear only when a snapshot grounds them;
   per-PR figures appear only when a human supplies them; everything else
   is an explicit omission or `unavailable`.
5. **Graceful degradation.** A refusal, a dispatch error, an absent
   snapshot, or zero calibration history each reduce a surface to "estimate
   unavailable" or to the generic-budget baseline — never to a broken
   pipeline. With no history at all, the loop behaves exactly as it did
   before calibration existed.

## How it connects to the rest of the habitat

The cost loop is the **prospective** half of the cost capability; the
**retrospective** half is the `cost-tracking` skill and `/cost-capture`,
which records quarterly provider snapshots. The two halves meet at
`observability/costs/`: the trackers write, the estimator reads. The per-PR
actuals format is the second thing `cost-tracking` owns — a single-task,
structural sibling of the quarterly aggregate.

The loop also rides the existing **decision-discipline** philosophy of the
pipeline: like the advocatus-diaboli's objections and the choice
cartographer's stories, a cost estimate is derived judgment surfaced for a
human to dispose — never an agent's decision.

## See also

- [Prospective Cost Estimation](prospective-cost-estimation.md) — what each
  component is (the contract, the agent, the command).
- [Agent Orchestration](agent-orchestration.md) — the pipeline and its
  gates that T0/T1/T2 thread through.
- [Estimate Task Cost](../how-to/estimate-task-cost.md) — the
  `/cost-estimate` walkthrough.
- [Track AI Costs](../how-to/track-ai-costs.md) — the retrospective sibling.
- [Decision Discipline Triad](decision-discipline-triad.md) — the
  emit/dispatch/dispose philosophy the loop inherits.
- Specs: `docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md`
  (S1) through
  `docs/superpowers/specs/2026-06-12-calibration-loop-per-pr-actuals-design.md`
  (S6).
