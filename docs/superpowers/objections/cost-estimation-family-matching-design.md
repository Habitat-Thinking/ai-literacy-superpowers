---
spec: docs/superpowers/specs/2026-06-15-cost-estimation-family-matching-design.md
date: 2026-06-15
mode: spec
diaboli_model: claude-opus-4-8[1m]
adjudication: all 12 accepted; human disposed the §3 fork to Option B′ (engineer the proxy properly) — absorbed into the spec
objections:
  - id: O1
    category: implementation
    severity: critical
    claim: "Option B's proxy collapses the implementer split-tier band to low == high (Sonnet end proxied to the Opus rate), which fails the existing 'Split-tier spread' (low < high, strict) validation check — the recommended option produces records the current validator rejects, on the exact snapshot it targets."
    disposition: accepted
    disposition_rationale: "The split-tier strict-spread check assumes both ends bind DIFFERENT representative models; a cross-tier proxy breaks that assumption legitimately. Resolution: the 'Split-tier spread' check is amended to apply only when both ends bind directly (non-proxied); a split-tier stage with a proxied end is EXEMPT and may collapse, with the collapse disclosed. Format-reference validation-checklist change (B′ embraces format change)."
  - id: O2
    category: implementation
    severity: critical
    claim: "A proxied figure carries cost_basis: snapshot-actuals, which the format defines as the rate derived from THAT tier's Model Breakdown row — so the field asserts a grounding the figure lacks, and a machine consumer cannot distinguish a proxied dollar from a directly-grounded one."
    disposition: accepted
    disposition_rationale: "Adopt O11: add an additive cost_basis enum value `snapshot-actuals-proxied`. Any record with ≥1 proxied tier carries it; fully-direct records keep `snapshot-actuals`. Machine-distinguishable; backward-compatible (old records unaffected; an unaware consumer treats the new value as grounded-with-caveat). Resolves the contract lie."
  - id: O3
    category: premise
    severity: high
    claim: "The 'observed snapshot rate, never list price → no-list-price-fallback intact' defence equivocates: an Opus rate applied to Standard traffic is not the observed cost of the thing being priced, regardless of provenance."
    disposition: accepted
    disposition_rationale: "Reframed: the proxy is NOT defended as 'still snapshot-actuals'. It is a distinct, named third basis (`snapshot-actuals-proxied`) — an explicitly-typed, confidence-floored, direction-forced approximation the human opted into. It differs from list-price in being anchored in THIS repo's observed spend AND in being typed so it can never masquerade as direct grounding. The no-list-price rule is untouched (vendor cards are still never used); the proxy is a new basis, not a smuggled list price."
  - id: O4
    category: implementation
    severity: high
    claim: "'Dearest-present = conservative' is asserted as absolute, but an over-estimate misleads a 'too cheap to bother / track' read and contaminates the cost trend the snapshot itself asks for."
    disposition: accepted
    disposition_rationale: "A proxied record FORCES `failure_direction: likely-overrun` and the disclosure states the figure is a deliberate over-estimate unsuitable for trend aggregation. The directional bias is named, not implied; 'conservative' is replaced with 'deliberately over-stating, disclosed as such'."
  - id: O5
    category: risk
    severity: high
    claim: "confidence.cost: low + prose is the sole proxy honesty control, but `cost: low` is already routine for stale snapshots, so a proxy is indistinguishable from a normal low-confidence grounded estimate to a non-prose consumer."
    disposition: accepted
    disposition_rationale: "Resolved by O2/O11: the `snapshot-actuals-proxied` basis is the structured, machine-readable proxy marker; `confidence.cost: low` is retained as a secondary signal, not the sole one. A consumer keys on the basis, not the confidence tier."
  - id: O6
    category: specification quality
    severity: high
    claim: "§5 promises a 'Layer-1 assertion that family matching resolves claude-opus-4-8 → Most capable', but resolution happens in the read-only agent's prose reasoning and leaves no machine-readable trace — the named test may be structurally unwritable."
    disposition: accepted
    disposition_rationale: "Test surfaces clarified: Layer-1 asserts the STATIC contract data (the family-stem rule + delimiter, the new `snapshot-actuals-proxied` enum value, the amended split-tier-spread exemption — all documented in the format reference and agent body, grep-able). The behavioural claim (agent resolves opus-4-8 → Most capable on a fixture snapshot) is Layer-2/3 acceptance documentation, gated on an API key — NOT a Layer-1 assertion. The spec no longer promises a structural test of agent-internal resolution."
  - id: O7
    category: implementation
    severity: medium
    claim: "Multi-row family aggregation (Σcost ÷ Σtokens) silently blends different model generations at different rates into one figure with no disclosure obligation, unlike the input/output blended-rate skew which must be surfaced."
    disposition: accepted
    disposition_rationale: "A disclosure obligation is added: when >1 Model Breakdown row is aggregated into a family rate, the agent names it in Confidence rationale (mirroring the blended-rate-skew disclosure)."
  - id: O8
    category: implementation
    severity: medium
    claim: "Prefix-on-family-stem is an unbounded forward match: `claude-opus-4` would bind a hypothetical claude-opus-40/claude-opus-4o, and a renamed family (claude-opus-5) silently fails to match — recreating #411 a generation later."
    disposition: accepted
    disposition_rationale: "Delimiter rule added: the stem matches iff the next character is `-` or end-of-string (so `claude-opus-4` matches `claude-opus-4` and `claude-opus-4-8`, NOT `claude-opus-40`/`claude-opus-4o`). The false-negative side (a future `claude-opus-5` family) is named as a deliberate, signalled maintenance point: the stem table is versioned per model generation (added to §6 / a maintenance note), not a silent miss — a no-family-resolves snapshot is state 2 (omit), which is loud, not silent."
  - id: O9
    category: specification quality
    severity: medium
    claim: "The proxy firing condition '≥1 family present (a usable rate exists)' is ambiguous for a haiku-only snapshot: haiku has a usable rate but resolves to no estimating tier — undefined whether the proxy fires from haiku or falls to state 2."
    disposition: accepted
    disposition_rationale: "Clarified: only ESTIMATING-TIER families (opus-4 / sonnet-4) count as 'present'. Haiku is never a proxy source. A haiku-only snapshot has no estimating-tier family → state 2 (omit). The firing condition reads '≥1 estimating-tier family resolves'."
  - id: O10
    category: scope
    severity: medium
    claim: "The spec bundles the contentious proxy (B) with the uncontroversial family-matching fix (§2) and writes §4/§5 as if B ships, raising the cost of choosing Option A."
    disposition: accepted
    disposition_rationale: "The human disposed to B′, so both ship — but the revised spec/surfaces explicitly tag each change as FAMILY-MATCHING (firm core) or PROXY (B′), so the two remain separable in the implementation and the audit trail (and so a future revert of the proxy would not disturb family-matching)."
  - id: O11
    category: alternatives
    severity: medium
    claim: "A more honest middle path is unacknowledged: add an additive cost_basis enum value (snapshot-actuals-proxied) so a proxy is machine-distinguishable — preserving B's relief while removing the O2 contract lie at the cost of one backward-compatible enum value."
    disposition: accepted
    disposition_rationale: "Adopted as the core of B′ (see O2). This is what makes the engineered proxy honest and contract-clean."
  - id: O12
    category: specification quality
    severity: low
    claim: "§4 rewords the state-2 'missing model key' trigger to 'no tier family resolves' without restating the agent's closed four-condition omission set, risking a divergent re-implementation."
    disposition: accepted
    disposition_rationale: "The spec restates the FULL post-change closed omission set: (1) no snapshot; (2) snapshot but no usable Model Breakdown; (3) Model Breakdown present but NO estimating-tier family resolves → omit (the merged successor of the old 'unmapped tier' + 'missing model key'). ≥1 estimating-tier family resolves → cost present (with proxy for absent families, B′)."
---

## Summary

Spec-mode diaboli on the cost-estimation family-matching spec (#411) raised
**12 objections — 2 critical, 4 high, 5 medium, 1 low** — across premise (1),
implementation (5), risk (1), specification quality (3), scope (1), and
alternatives (1). **All 12 accepted.** The family-matching premise (§2) was
explicitly *not* challenged; the two criticals (O1, O2) and O3/O5/O11 all struck
the **recommended cross-tier proxy** as originally specced.

The human disposed the §3 load-bearing fork to **Option B′ — engineer the proxy
properly** (rather than retreat to precise-omission Option A). The engineered
proxy absorbs the objections via:

- **O2/O11/O5** — a new additive `cost_basis` enum value
  **`snapshot-actuals-proxied`** makes a proxied figure machine-distinguishable
  (backward-compatible; direct figures keep `snapshot-actuals`).
- **O1** — the "Split-tier spread" validator is amended: a split-tier stage with a
  **proxied** end is exempt from the strict `low < high` requirement (the check
  assumed both ends bind different models).
- **O3** — the proxy is reframed as a distinct, named, opted-into third basis, not
  "still snapshot-actuals"; the no-list-price rule is untouched.
- **O4** — a proxied record forces `failure_direction: likely-overrun` and
  discloses it is a deliberate over-estimate unsuitable for trend aggregation.
- **O7/O8/O9/O12** — multi-row aggregation disclosure; a stem **delimiter rule**
  (next char `-` or end-of-string); haiku-only → state 2 (only estimating-tier
  families count); and the agent's full closed omission set restated.
- **O6** — test surfaces clarified: Layer-1 asserts the static contract data; the
  agent's runtime resolution is Layer-2/3 acceptance, not a Layer-1 test.
- **O10** — family-matching (firm) and the proxy (B′) are tagged separately in the
  surfaces list so they stay separable.

## What was NOT challenged (diaboli disclosure)

- The §1 diagnosis (exact-key binding silently omits cost on the real snapshot) —
  correct and well-evidenced.
- §2 family matching as the right *shape* of fix (the objections are about its
  bounds, not its premise).
- Keeping haiku out of the estimating tiers (a defensible scope line).
- The version-bump/CHANGELOG mechanics (routine minor bump).
- The blended-rate-skew simplification staying unchanged (separately sanctioned).
- Deferring capture-time `/cost-capture` validation (reasonable complementary
  slice).
