---
title: Prospective Cost Estimation
---
# Prospective cost estimation

The `cost-estimation` skill answers a question you ask *before* work
runs: **how much will this cost to build?** It estimates the token
usage and agent-compute time a task will consume as it flows through
the orchestrator pipeline — and a dollar figure, but only when observed
actuals exist to ground it.

It is the **prospective** half of a pair. Its **retrospective** sibling,
`cost-tracking`, records what *was* spent after the fact (see
[Track AI Costs](../how-to/track-ai-costs.md)). The two reuse the same
`observability/costs/` data: `cost-tracking` **writes** the snapshots
via `/cost-capture`; `cost-estimation` **reads** them as its $/token
ground. A reader who finds one half of the cost capability should be
able to discover the other.

## An estimate is a range, never a point

The material decision this skill locks: **an estimate is a range with
disclosed confidence, never a point value.**

A point value invites false precision. "12k tokens" reads as a fact;
"10k–18k tokens, confidence medium, more likely to overrun than
underrun because the implementer stage spans two model tiers" reads as
a prediction a human can interrogate. The whole point is to *inform* a
human's choice, not to anchor it on a number dressed as a fact. Every
quantitative field is therefore a `{ low, high }` range carrying
per-axis confidence and the disclosures the contract requires.

## What is grounded, and what is not

The grounding sources are **fixed, not chosen**:

- **Token ranges and agent-compute time** are *always* groundable from
  `MODEL_ROUTING.md` — its Token Budget Guidance table gives per-stage
  ranges, and its Agent Routing table gives each stage's model tier. The
  per-stage ranges sum into the whole-record `tokens` range. These two
  axes are the honest day-one deliverable.
- **The dollar figure is an actuals-gated enhancement.** `cost_usd`
  appears *only* when an `observability/costs/` snapshot supplies a
  usable per-tier $/token rate, derived through a fixed
  tier→model→$/token binding. When no usable rate exists, the field is
  **omitted with an explicit disclosure** — never a forced list-price
  guess. The no-cost record is valid and complete, not a failure; the
  same fields simply begin to appear once the first usable snapshot
  lands, with no format change.
- **Human-gate latency is not estimated numerically at S1.** It
  dominates total wall-clock but depends on when a human next disposes a
  gate, not on the work, so it is carried as a qualitative caveat rather
  than a number that would re-introduce false precision.

## Confidence is disclosed, never decisive

The estimate record carries confidence; it does **not** carry a verdict,
recommendation, or go/no-go. Confidence is recorded **per axis**
(`tokens`, `time`, and — only when `cost_usd` is present — `cost`), with
a ceiling tied to how richly grounded the target is: a raw task text
caps low, a slice or slicing record at medium, a full spec may reach
high. The cost axis follows its own rule, set from the snapshot's age
and granularity, independent of the target.

Every record's prose body must contain four labelled sections —
**Included**, **Excluded**, **Confidence rationale**, and **Failure
direction** — so the derivation is interrogable. The Excluded section is
the single most important honesty signal: a number that silently omits a
cost class is worse than no number. The no-verdict guarantee is
structural in two layers: there is no recommendation field, *and* a
validation check scans the disclosure prose for imperative or go/no-go
language. The human reads the ranges and disclosures and decides.

## Methodology and a format contract, not a command

The skill itself is **methodology and a format contract**. It describes
how an estimate is derived and what an estimate record must contain — it
does not dispatch an agent, write a file, or decide go/no-go. Emitting
and validating a record is the job of downstream consumers (the
read-only `cost-estimator` agent, the `/cost-estimate` command, and the
orchestrator fold-in at the Slice Adjudication and Plan Approval gates)
that inherit this contract.

## The read-only emitter — the `cost-estimator` agent

The skill defines what an estimate *is*; the **`cost-estimator` agent**
is the thing that *produces* one. Given a target it reads the grounding
sources, applies the skill's methodology, and **returns the
estimate-record content as a string** — it is a derived-judgment
**emitter**, not a decider.

The load-bearing decision is the agent's **trust boundary**: it holds
`Read`, `Glob`, and `Grep` only — no `Write`, no `Edit`, no `Bash`. This
is the mechanism, not a limitation. Because the agent **cannot persist**
the record, the human disposition the disclosure contract depends on
cannot be bypassed by an agent that quietly writes its own output. The
agent emits; a dispatcher persists the string **after a human disposes**
— the **dispose-then-write ordering invariant** of the AGENTS.md
**agent-emit + dispatcher-persist + human-disposes** decision. The
`cost-estimator` is the next instance of that pattern, alongside
`advocatus-diaboli`, `choice-cartographer`, and `model-card-researcher`.

Three behaviours make the emitter honest rather than confidently wrong:

- **Inference-basis disclosure.** When the agent *infers* the
  `target_kind` (rather than the dispatcher stating it), it discloses the
  signal it classified on — `classified as <kind> by <signal>` — so a
  confident mis-read that would silently raise the confidence ceiling is
  catchable by the human reading the record. An ambiguous target resolves
  to the *lower-grounding* candidate and is disclosed, never silently
  up-classified.
- **Mechanical cost-omission.** When a snapshot would let the agent price
  cost, it first re-verifies the binding *mechanically* — every exercised
  tier mapped (after the normalisation that makes `Standard/Capable` ↔
  `Standard / Capable`), every named model key present. It omits
  `cost_usd` with disclosure whenever **any** exercised tier is unmapped
  or a key is missing, with **no** judgment about whether the tier
  "matters". This keeps the agent emit-not-decide while making it honest
  when the static binding drifts from reality.
- **Refuse rather than fabricate.** On an unreadable or unclassifiable
  target, or a `MODEL_ROUTING.md` that is absent or whose required tables
  are missing/unparseable, the agent returns a machine-greppable
  `REFUSED:` string — no token grounding means no honest estimate. The
  deliberate counterpart: an **empty `observability/costs/` is a
  cost-omitted record, not a refusal**, because the token grounding is
  intact.

## The dispatcher that persists — the `/cost-estimate` command

The agent emits a string; the **`/cost-estimate` command** is the
dispatcher that turns it into a file — and the only place a `Write`
happens. It dispatches the agent on one target, runs the **Output
Validation Checkpoint** against the format contract, surfaces a review
summary, and writes the record **only after the human disposes**
(`accept` / `edit` / `re-run` / `abort`). This is the other half of the
dispose-then-write invariant: the human reviews a *validated* record and
the write is unambiguously downstream of `accept`.

The checkpoint is bounded at **structural-only vs derived-value**: it may
fix a purely structural deviation in place (in practice, deleting a stray
verdict field) and records the change as a diff, but it **aborts — never
authors — on any derived-value defect** (a missing `cost_basis`, an
out-of-cap confidence, a verdict phrased in prose). On a `REFUSED:` emit
it surfaces the refusal verbatim and writes nothing. Records land in a
new top-level `cost-estimates/` directory — deliberately **outside**
`observability/`, because a forward-looking prediction is not telemetry
and must never be co-located with captured actuals where a later scan
could read it as fact.

## Folded into the orchestrator's gates, never a new gate

The `/cost-estimate` command is the *ad hoc* surface. The estimator's
highest-value home is **inside the orchestrator's existing
human-disposition gates**, where cost lands at the moment it most changes
a choice — surfaced as **informational fields, never a new gate**:

- **T1 — Slice Adjudication.** After carpaccio slices the task and the
  record is validated, the orchestrator dispatches the `cost-estimator`
  **once per slice in parallel** and appends a compact one-line cost
  summary (tokens, cost-or-"not grounded", confidence, failure direction)
  to each slice's block. The human sees per-slice cost *while choosing
  which slice to progress* — the moment the slicing record names as the
  most valuable.
- **T2 — Plan Approval.** After spec-writer, the spec-mode diaboli, and
  the choice-cartographer complete, the orchestrator dispatches the
  estimator **once** against the progressed slice's spec — the
  pipeline's highest confidence ceiling — and surfaces a fuller cost
  block (tokens, agent-compute time, cost, the **verbatim
  `human_gate_time` caveat**, an excluded pointer) alongside
  `cartograph_pending_count`.

Both fold-ins follow the orchestrator's established
`cartograph_pending_count` rule: a structured informational field, **not**
a decision point. They add **no block and no keypress**, no agent writes a
disposition, and the estimate carries no recommendation or verdict — the
human reads the ranges and makes the *existing* slice / plan-approval
choice. Crucially, the gate **never degrades**: a `REFUSED:` emit, a
dispatch error, or a checkpoint abort reduces the affected estimate to
"unavailable" and the existing gate proceeds exactly as before. The
estimate is purely additive decision-support, and the orchestrator owns
the write so the agent stays read-only.

## The earliest, weakest insertion — the T0 ballpark

Before any of that — before carpaccio even slices the task — sits **T0**,
a coarse whole-task **ballpark from raw task text only**. After the
orchestrator creates the branch and the issue, and immediately before
carpaccio, it dispatches the `cost-estimator` once against the issue body
as a `task-text` target (the **`low`** confidence ceiling) and surfaces a
loud low-confidence sniff-test: "this looks small" versus "this looks
enormous", before you have invested in slicing, specs, or code.

T0 is deliberately the **opposite** of T1/T2 on the one axis that matters
— durability. Where the gate-folded estimates **persist** to
`cost-estimates/` (decision-support with audit value), T0 is
**inline-only and ephemeral**: surfaced once, written **nowhere**, and not
even threaded into the context object passed downstream. The reasoning is
anchoring. T0 is the least-grounded number the pipeline can produce, fired
before any decomposition exists; a *persisted* low-confidence raw-text
figure would read as more authoritative than it is. Keeping it ephemeral
means there is no file for a later scan, an observability tool, or a future
reader to mistake for fact — the honesty rests entirely on the loud
low-confidence disclosure at the moment it is surfaced, framed explicitly
as "a go/no-go sniff-test, not an estimate to plan against". Like T1/T2 it
is non-blocking and carries no gate, no keypress, and no verdict; the
orchestrator proceeds to carpaccio regardless, and an unavailable T0
changes nothing about the run.

## Closing the loop — calibration against this repo's history

Everything above grounds in the **generic** `MODEL_ROUTING.md` token
budgets — the same numbers for every repo. The **calibration loop** lets
the estimator learn what work in *this* repo actually costs. At
integration time the **integration-agent** writes a **per-PR actuals
record** to `observability/costs/per-pr/`: which stages ran, how many
review cycles, the files and languages touched — auto-captured — plus the
task's token/cost figures **when a human supplies them** (e.g. from
Claude Code's `/cost`). The estimator then reads the accumulated records
as a `kind: calibration` grounding source and **narrows its per-stage
token ranges** toward the observed history.

Two honesty commitments shape the design. First, **no fabrication**: a
subagent cannot read "tokens spent on this PR" programmatically, so when a
human supplies no figures they are recorded as `unavailable` — never
invented, never `0`. An `unavailable` record still calibrates *which
stages this repo exercises*; it contributes nothing to the token
magnitudes. Second, **token ranges only**: calibration narrows token
ranges and may raise their confidence, but the dollar rate stays bound to
the cost snapshot (`cost_basis: snapshot-actuals`). True to the seam the
skill kept open from the start, the whole loop ships with **no change to
the estimate-record format** — just the already-permitted
`kind: calibration` entry and a `Confidence rationale` disclosure. With
zero history (the day-one state), the estimator behaves exactly as it did
before the loop existed.

## See also

- [Estimate Task Cost](../how-to/estimate-task-cost.md) — the
  `/cost-estimate` command walkthrough.
- [Track AI Costs](../how-to/track-ai-costs.md) — the retrospective
  sibling capture workflow.
- `ai-literacy-superpowers/skills/cost-estimation/SKILL.md` — the skill.
- `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`
  — the stable estimate-record format contract.
- [Agents reference — `cost-estimator`](../reference/agents.md#cost-estimator)
  — the read-only emitter's tool boundary and contract.
- Skill spec: `docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md`.
- Agent spec: `docs/superpowers/specs/2026-06-11-cost-estimator-agent-design.md`.
- Command spec: `docs/superpowers/specs/2026-06-11-cost-estimate-command-design.md`.
- Orchestrator fold-in spec: `docs/superpowers/specs/2026-06-12-orchestrator-cost-fold-in-design.md`.
- T0 ballpark spec: `docs/superpowers/specs/2026-06-12-orchestrator-t0-ballpark-design.md`.
- Calibration loop spec: `docs/superpowers/specs/2026-06-12-calibration-loop-per-pr-actuals-design.md`.
- Per-PR actuals format: `ai-literacy-superpowers/skills/cost-tracking/references/per-pr-actuals-format.md`.
