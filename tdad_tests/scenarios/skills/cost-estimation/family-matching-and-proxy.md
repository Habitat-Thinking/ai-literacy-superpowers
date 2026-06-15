---
component: cost-estimation
component_type: skill
tier: structural
---

# Scenario: tier→model binding resolves by family stem, and an absent family is priced by a disclosed, distinctly-typed cross-tier proxy

## Given

The family-matching slice (#411, spec
`docs/superpowers/specs/2026-06-15-cost-estimation-family-matching-design.md`)
fixes the silent cost-omission #411 surfaced: the cost-estimation binding
matched representative model keys **literally** (`claude-opus-4`,
`claude-sonnet-4`), but real snapshots key their Model Breakdown by the
**actual** model ids (`claude-opus-4-8`), so cost was omitted on every run.

This is a **structural** scenario. Per the diaboli's O6, family resolution is
agent-internal reasoning that leaves no machine-readable trace in the record;
this scenario therefore asserts the **static contract text** of the format
reference
(`ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`)
and the `cost-estimator` agent body — **not** the output of the agent run
(that behavioural falsification is Layer-2/3 acceptance, API-gated, out of
scope here).

## When

The edited format reference's binding table, `cost_basis` field, three
grounding states, and validation checklist — and the agent's mechanical
cost-omission section — are read as the closed contract.

## Then

**Family matching (the core fix):**

- The binding table resolves a tier's representative **by family stem** with a
  **delimiter rule**: a snapshot key matches the stem (`claude-opus-4` /
  `claude-sonnet-4`) iff it starts with the stem **and** the next character is
  `-` or end-of-string. So `claude-opus-4-8` resolves Most capable, and
  `claude-opus-40` / `claude-opus-4o` do **not** — the delimiter closes the
  false-positive match.
- Multiple matching rows in one family **aggregate** into one blended rate
  (`Σ cost ÷ Σ tokens`), and aggregating **>1** row carries a **disclosure
  obligation** in `Confidence rationale`.
- Only `claude-opus-4` / `claude-sonnet-4` are **estimating-tier** families;
  `claude-haiku-4-5` and other keys resolve to **no** tier and are never a
  binding or proxy source.

**The closed omission/grounding set (restated under family resolution):**

- States 1–2 (no snapshot; snapshot but no usable Model Breakdown) → omit,
  unchanged.
- **State 3 — Model Breakdown present but NO estimating-tier family resolves**
  (e.g. a **haiku-only** snapshot) → **omit**, naming the cause. This merges
  the old "unmapped tier" + "missing model key" triggers.
- **State 4 — ≥1 estimating-tier family resolves** → `cost_usd` **present**.

**The disclosed cross-tier proxy (Option B′):**

- When an exercised tier's family is **absent** but ≥1 estimating-tier family
  resolves, the missing tier is **priced by a proxy** at the **dearest present
  estimating family's** rate — **not** omitted.
- A proxied record is **distinctly typed**: `cost_basis:
  snapshot-actuals-proxied` (the additive enum value, machine-distinguishable
  from direct `snapshot-actuals`). The `cost_basis` field documents both
  values, and the enum is additive/backward-compatible.
- A proxied record **forces** `failure_direction: likely-overrun` and
  `confidence.cost: low`, and **names every proxied tier and its source** in
  `Included`/`Confidence rationale` — the "Cost pairing" checklist line
  requires this trio under `snapshot-actuals-proxied`.
- The proxy uses **only** observed snapshot rates — the
  **no-list-price-fallback** rule is **untouched** (no vendor price card).

**The split-tier-spread exemption (diaboli O1):**

- The "Split-tier spread" checklist line requires a strict `low < high` on a
  present split-tier band **only when `cost_basis` is `snapshot-actuals`**. A
  `snapshot-actuals-proxied` split-tier band **may collapse** (`low == high`) —
  the cross-tier proxy legitimately prices one end at the same present-family
  rate, so the both-ends-bind-different-models assumption no longer holds.

**The agent applies it mechanically:**

- The agent's cost-omission section resolves tiers by **family stem** (the
  family-resolution check), restates the **closed** omission/grounding set, and
  carries the **cross-tier proxy** step (dearest present family, the
  `snapshot-actuals-proxied` basis, the forced overrun + low cost confidence +
  per-tier disclosure). It **never** invents a binding or uses a list price.

## Rubric

Layer 1 structural. Every assertion is verifiable by reading the binding table,
the `cost_basis` field definition, the three-grounding-states text, the
validation checklist ("Split-tier spread", "Cost pairing"), and the agent's
mechanical cost-omission section — not by running the agent.

The scenario **passes** only when: the binding resolves by family stem with the
delimiter rule; family aggregation carries a >1-row disclosure obligation;
`cost_basis` documents both `snapshot-actuals` and `snapshot-actuals-proxied` as
an additive, backward-compatible enum; a haiku-only / no-estimating-family
snapshot omits (state 3); a proxied record is distinctly typed and forces
`likely-overrun` + `cost: low` + per-tier disclosure; the split-tier strict-
spread predicate applies only under `snapshot-actuals`; and the no-list-price
rule is reaffirmed.

The scenario **fails** if a future edit reverts to exact-key matching, drops the
delimiter rule (re-admitting `claude-opus-40`), lets a proxy reuse
`snapshot-actuals` (the diaboli-O2 contract lie), drops the `likely-overrun` /
`cost: low` / disclosure forcing on a proxy, applies the split-tier strict-
spread check to a proxied band, or introduces a vendor-list-price fallback.

## Notes

Scope is the #411 family-matching slice only. Capture-time validation (a
`/cost-capture` warning for unbindable snapshot keys) and stem-table
auto-discovery are explicitly deferred (spec §6). The behavioural claim — the
agent, run against the opus-only 2026-06-13 snapshot, actually grounds
Most-capable directly and proxies Standard — is Layer-2/3 acceptance, gated on
an API key, not asserted here.
