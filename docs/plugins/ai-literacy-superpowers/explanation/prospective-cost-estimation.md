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

At its first slice this skill is **methodology and a format contract**.
It describes how an estimate is derived and what an estimate record must
contain — it does not dispatch an agent, write a file, or decide
go/no-go. Emitting and validating a record is the job of downstream
consumers (a read-only `cost-estimator` agent, a `/cost-estimate`
command, and an orchestrator fold-in) that inherit this contract.

## See also

- [Track AI Costs](../how-to/track-ai-costs.md) — the retrospective
  sibling capture workflow.
- `ai-literacy-superpowers/skills/cost-estimation/SKILL.md` — the skill.
- `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`
  — the stable estimate-record format contract.
- Spec: `docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md`.
