---
component: cost-estimation
component_type: skill
tier: structural
---

# Scenario: cost_usd is present only when a snapshot grounds it — three states, no list-price fallback

## Given

The `cost-estimation` skill's central restructure (spec §1, §6.2, §6.4;
O2/O3/O8/O11) is that the dollar figure is an **actuals-gated
enhancement**, not a day-one deliverable. The day-one deliverable is a
**token + time estimate**, both groundable from MODEL_ROUTING.md today.
`cost_usd` appears only when an `observability/costs/` snapshot supplies
a usable per-model $/token rate; otherwise it is **omitted with an
explicit disclosure** — never emitted as a forced-low list-price guess.

The grounding source — `observability/costs/` — is **empty today** (the
2026-05-29 health snapshot records "Last cost capture: never"), so the
cost-omitted shape is the expected default.

This scenario fixes the cost-conditional behaviour the methodology in
`SKILL.md` and the field rules in
`references/estimate-record-format.md` must describe (`FR-8`).

## When

The grounding methodology in `SKILL.md` and the conditional-cost rules
in the format reference are read, with attention to how each of the
three snapshot grounding states is handled.

## Then

**The three grounding states are each defined** (spec §6.2):

- **State 1 — no snapshot exists** (today's state): `cost_usd` and
  `cost_basis` are **omitted entirely**; `tokens` and
  `agent_compute_time` are still produced as ranges; `human_gate_time`
  is still produced as its qualitative caveat.
- **State 2 — snapshot present but Model Breakdown absent or too coarse**
  to yield a per-tier rate: `cost_usd` is **omitted**, and the
  `Excluded` disclosure **names this specific cause** ("a cost snapshot
  exists but carries no usable per-model breakdown"). The methodology
  does NOT silently fall through to list price.
- **State 3 — snapshot present with a usable Model Breakdown**:
  `cost_usd` is **present**, accompanied by `cost_basis:
  snapshot-actuals`, with `confidence.cost` set from the snapshot's age
  and granularity and the snapshot date/quality disclosed in `Included`.

**No list-price fallback** (spec §6.2; O3, O11):

- The methodology states explicitly that there is **no list-price
  fallback** anywhere — the prior "produce a list-price cost and force
  confidence low" path is absent. When cost cannot be grounded in
  actuals, it is omitted with disclosure, not guessed.

**The omission is honest, not a failure** (spec §6.4):

- The methodology states a record with `cost_usd` omitted is **valid and
  complete** (the expected day-one shape), provided the `Excluded`
  section carries the cost-omission disclosure (e.g. "cost_usd: omitted —
  no repo cost snapshot exists yet, so no observed $/token is available;
  cost is not estimated. Token and time figures stand.").

**The cost-omitted worked example matches the no-snapshot shape** (spec
§6.4, §8.2):

- The cost-omitted worked example in the reference has `cost_usd` and
  `cost_basis` absent, a `confidence` object carrying **`tokens` and
  `time` axes but no `cost` axis**, and an `Excluded` section carrying
  the cost-omission disclosure.

**Format-stability seam** (spec §6.4; O11):

- The methodology states **no format change is required** when the first
  usable snapshot lands — the same `cost_usd`/`cost_basis`/
  `confidence.cost` fields simply begin to appear.

## Rubric

Layer 1 structural: each assertion is verifiable by reading the
methodology prose in `SKILL.md` and the conditional-cost field rules and
the cost-omitted worked example in the format reference. The scenario
fails if the methodology describes a list-price fallback, treats the
no-cost case as an error, collapses the three states into two, or if the
cost-omitted worked example carries a `cost` axis or a `cost_usd` value.

## Notes

This scenario is the honesty guarantee for the dollar axis. A snapshot
fixture is NOT needed at Layer 1 — the assertions are about what the
methodology and the worked example *describe*, not about running an
estimate against a live snapshot. The watch-item (O7: cost stays omitted
across S2–S5 until S6) is noted in the spec §7 but is a slicing decision
to revisit, not a falsifiable assertion of this slice.
