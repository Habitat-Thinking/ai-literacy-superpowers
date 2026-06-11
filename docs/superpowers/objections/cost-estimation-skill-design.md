---
spec: docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md
date: 2026-06-11
mode: spec
diaboli_model: claude-opus-4-8[1m]
objections:
  - id: O1
    category: design
    severity: major
    claim: "The split-tier widening that resolves round-1 O5 collapses to a zero-width band, because the new tier-binding table (§6.2) maps BOTH `Standard` and `Capable` to the same representative model `claude-sonnet-4` — so the implementer's low and high cost bounds use an identical $/token and the 'widening' produces no spread at all."
    evidence: "Spec §6.2 binding table (lines 394-396) lists `Standard → claude-sonnet-4` and `Capable → claude-sonnet-4`, and the split row as 'spans claude-sonnet-4 (low) … claude-sonnet-4 (high)'. §6.1 (lines 371-378) defines split-tier widening as 'its low bound uses the cheaper tier (Standard) and its high bound uses the dearer tier (Capable)'. When both tiers bind to one model, low rate == high rate; the widening the spec presents as the O5 fix is a no-op for the only stage it was written for (implementer, 100-250k, the dominant cost term)."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix now. Either bind Capable to a dearer representative model
      than Standard so the widening produces a real spread, or state the tiers
      carry no cost distinction and drop the widening machinery as dead weight.
      Whatever is chosen, the cost-present worked example must be able to
      demonstrate it.
  - id: O2
    category: design
    severity: major
    claim: "`human_gate_time` is derived from `gate_count`, but S1 has no grounded source for the gate count of a target: the gate set lives in the orchestrator (S4, #371), which this slice explicitly does not touch, and the count depends on which stages a target exercises — a methodology judgement the spec leaves to the agent. The O9 fix replaced one ungrounded number (the gate-time range) with a formula whose own input (`gate_count`) is ungrounded at S1, and reaches into orchestrator topology the slice declares out of scope."
    evidence: "Spec §4.3 (lines 197-205) and §6.3 (lines 459-464) define `human_gate_time = gate_count × per-gate latency band`, where gate_count is 'the number of human-disposition gates the target's stage set passes through (Slice Adjudication, Plan Approval, diaboli/cartograph dispositions, code review, integration)'. §2.2 (lines 83-101) places the orchestrator gate topology in S4 (#371) and instructs that S1 must not name 'which gate it appears in'. The gate list enumerated in §4.3 is exactly the orchestrator's gate set; no rule derives gate_count from target_kind."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix now. Add a gate_count-from-target_kind rule in the
      methodology (accepting and flagging that it duplicates knowledge S4 will
      own), OR demote human_gate_time from a required numeric range to a
      disclosed qualitative caveat until S4 fixes the gate set. A required
      multiplier with no derivation is the false-precision the spec opposes.
  - id: O3
    category: operational
    severity: minor
    claim: "The tier→model binding table is a new hardcoded maintenance artefact that will silently drift from MODEL_ROUTING.md and from reality: it pins representative model names (`claude-opus-4`, `claude-sonnet-4`) that are not derived from any source the methodology reads, and nothing in S1 keeps it synchronised when routing or model names change."
    evidence: "Spec §6.2 binding table (lines 391-396) fixes `Most capable → claude-opus-4`, `Standard → claude-sonnet-4`, etc. These names appear in neither MODEL_ROUTING.md (which carries only abstract tiers, confirmed lines 8-16) nor in any other read source — they are authored into the reference. §6.2 line 398-400 says 'the reference fixes the representative model per tier and is the artefact S6 may revise as routing evolves', i.e. it is hand-maintained and only revisited at S6. The cost-tracking snapshot uses `claude-opus-4`/`claude-sonnet-4` keys (cost-tracking SKILL.md lines 52-54), so a future model rename breaks the join silently."
    disposition: accepted
    disposition_rationale: >
      Accepted as a documented residual; resolve at S2 implementation. Add a
      methodology note that the tier→model binding must be re-verified against
      MODEL_ROUTING.md and the latest snapshot's model keys whenever cost is
      computed. Not blocking the spec.
  - id: O4
    category: failure
    severity: minor
    claim: "The per-model rate formula `estimated_cost ÷ (input_tokens + output_tokens)` (§6.2) blends input and output token prices into one rate, but real provider pricing charges output tokens several times the input rate; applied to the estimate's own token ranges (which are total-token budgets, not input/output-split), the derived cost can be materially wrong in a direction the spec does not disclose as a failure-direction case."
    evidence: "Spec §6.2 (lines 402-409): 'computes a per-model $/token as estimated_cost ÷ (input_tokens + output_tokens) for that model row — a single blended rate per model'. MODEL_ROUTING.md Token Budget Guidance (lines 20-26) gives per-role total-token ranges with no input/output split, and the snapshot Model Breakdown (cost-tracking SKILL.md lines 50-54) reports input and output volumes separately. A stage whose generation mix differs from the quarter-aggregate mix is mispriced by the blended rate, and §5.1's failure_direction guidance (lines 269-275) never names blended-rate skew as a source of cost error."
    disposition: accepted
    disposition_rationale: >
      Accepted as a documented residual; resolve at S2 implementation. Name
      blended-rate (input/output) mix skew in the §5.1 failure_direction
      guidance / cost-confidence rationale so the snapshot-grounded dollar
      figure discloses its mix-assumption. Not blocking the spec.
---

<!--
  Round 2. This record OVERWRITES the round-1 review (12 objections, all
  accepted) that drove the spec revision; the "Explicitly not objecting to"
  section below documents which round-1 objections were confirmed genuinely
  resolved (verified against source). Validation note: the dispatched diaboli
  returned O2 under the code-mode category 'specification quality'; remapped to
  the spec-mode category 'design' in place (its core is a structural
  scope-coupling flaw), per advocatus-diaboli.agent.md lines 54-61. All other
  categories/severities were returned valid.
-->

## O1 — design — major

### Claim

The split-tier widening introduced to resolve round-1 O5 collapses to a zero-width band. The new tier-binding table maps both `Standard` and `Capable` to the same representative model (`claude-sonnet-4`), so the implementer stage's low and high cost bounds are computed from an identical $/token rate. The "widening" the spec presents as the fix produces no spread for the very stage it was written for.

### Evidence

The §6.2 binding table (spec lines 391-396) reads:

> | Standard | `claude-sonnet-4` |
> | Capable | `claude-sonnet-4` |
> | Standard / Capable (split) | spans `claude-sonnet-4` (low) … `claude-sonnet-4` (high), widened per §6.1 |

§6.1 (lines 371-378) defines the widening: "its low bound uses the cheaper tier (`Standard`) and its high bound uses the dearer tier (`Capable`)." But when `Standard` and `Capable` both bind to `claude-sonnet-4`, the cheaper and dearer tier resolve to one rate. The split row even spells this out: "spans `claude-sonnet-4` (low) … `claude-sonnet-4` (high)" — the same model on both ends. The implementer carries the largest budget (100-250k, MODEL_ROUTING.md line 24) and §6.1 says "its rate dominates any cost figure," so the no-op widening governs the dominant cost term.

### Why this matters

Round-1 O5 was accepted with the explicit instruction to "widen the cost range to span Standard..Capable rather than leaving the dominant term's rate to agent discretion." The revision added the widening mechanism but bound both tiers to the same model, which silently re-defeats the fix: the dominant stage's cost contribution has no tier-driven spread, and the only spread it carries is the token-range spread it would have had anyway. Either the binding table is wrong (Capable should bind to a dearer model than Standard), or the MODEL_ROUTING.md distinction between `Standard` and `Capable` carries no cost consequence — in which case the spec should say so and drop the widening machinery as dead weight rather than ship a mechanism the worked example cannot demonstrate. As written, a reviewer authoring the cost-present worked example (§8.2) cannot show a widened implementer band, because the table forbids one.

## O2 — design — major

### Claim

`human_gate_time` is derived as `gate_count × per-gate latency band`, but S1 supplies no grounded source for `gate_count`. The gate set lives in the orchestrator, which this slice explicitly does not touch (S4, #371), and which gates a given target passes through depends on its stage set — a methodology judgement the spec leaves unspecified. The O9 fix replaced one ungrounded number (the human-gate range) with a formula whose own input is ungrounded at S1, and in doing so reaches into orchestrator topology the slice declares out of scope.

### Evidence

§4.3 (spec lines 197-205) and §6.3 (lines 459-464) define `human_gate_time = gate_count × per-gate latency band`, where `gate_count` is "the number of human-disposition gates the target's stage set passes through (Slice Adjudication, Plan Approval, diaboli/cartograph dispositions, code review, integration)." That parenthetical IS the orchestrator's gate set. Yet §2.2 (lines 98-101) instructs: "If a reviewer finds the skill describing ... *which gate it appears in* ... that is scope creep into S2-S5 and should be cut back to 'a consumer does X' without naming the consumer's mechanics." S4 (#371, "orchestrator fold-in at T1/T2") is where gates are defined. The spec gives no rule for deriving `gate_count` from `target_kind` — only the §6.1 token-stage rule ("a docs-only spec may exercise spec-writer + review only", lines 364-367), which is about token stages, not gate count, and the two sets are not the same.

### Why this matters

A required numeric range whose multiplier (`gate_count`) has no derivation rule will be invented per estimate — precisely the false-precision failure mode the §3 range-not-point decision exists to prevent, and the same failure O9 was raised to close. The fix moved the invented number down one level: the per-gate band is at least avowed as an assumption, but `gate_count` is presented as if it were a known quantity when its source (the orchestrator gate topology) does not ship until S4. Two reasonable agents will count gates differently for the same target (does a docs-only change pass diaboli? does it pass integration?), producing divergent `human_gate_time` ranges from an identical input — the divergent-implementation hazard the methodology was meant to eliminate. The spec should either define the gate-count derivation from `target_kind` as a stated table (accepting that it duplicates knowledge S4 will own, and flagging the coupling), or demote `human_gate_time` to a disclosed qualitative caveat until S4 fixes the gate set.

## O3 — operational — minor

### Claim

The tier→model binding table is a new hand-maintained artefact that will drift silently. Its representative model names are authored into the reference, derived from no source the methodology reads, and synchronisation is deferred to S6 — so between S1 and S6 a routing change or a model rename breaks the snapshot join with no signal.

### Evidence

The §6.2 binding table (spec lines 391-396) pins `Most capable → claude-opus-4`, `Standard → claude-sonnet-4`, `Capable → claude-sonnet-4`. These names appear nowhere in MODEL_ROUTING.md, which carries only abstract tier labels (confirmed lines 8-16) — the binding is authored, not derived. §6.2 (lines 398-400) states "the reference fixes the representative model per tier and is the artefact S6 may revise as routing evolves," i.e. it is revisited only at S6. The snapshot Model Breakdown is keyed by these same model names (cost-tracking SKILL.md lines 52-54), so the cost derivation's join key is a hardcoded constant in two places that no S1-S5 mechanism keeps aligned.

### Why this matters

The spec's central honesty claim is that cost is grounded in observed actuals, not guesses. But the tier→model binding — the join that turns a snapshot rate into a per-stage rate — is itself an ungrounded editorial assertion ("`claude-opus-4` is the representative model for Most capable"). If routing shifts a stage to a different model, or the provider renames a model in the snapshot, the join silently maps to the wrong rate or to nothing, and the methodology has no check that flags the mismatch. This is the round-1 O2 problem relocated rather than removed: round-1 O2 said the tier→model→$/token binding was undefined; the revision defined it as a static table, which is correct in form but introduces a maintenance-drift surface the spec acknowledges only as "the artefact S6 may revise." A note in the methodology that the binding must be re-verified against MODEL_ROUTING.md and the latest snapshot's model keys whenever cost is computed would close it.

## O4 — failure — minor

### Claim

The per-model $/token rate is computed as a single blended rate over input + output tokens, then multiplied against the estimate's total-token ranges. Because output tokens are priced well above input tokens in real provider billing, a stage whose generation mix differs from the snapshot's quarter-aggregate mix is mispriced, and the spec does not name blended-rate skew as a failure-direction case.

### Evidence

§6.2 (spec lines 402-409): "computes a per-model `$/token` as `estimated_cost ÷ (input_tokens + output_tokens)` for that model row — a single blended rate per model derived from the quarter aggregate. The binding table then maps each stage's tier to its representative model's blended rate, and `cost_usd = Σ over stages (stage tokens range × tier $/token)`." MODEL_ROUTING.md Token Budget Guidance (lines 20-26) gives total-token ranges with no input/output split; the snapshot Model Breakdown reports input and output volumes separately (cost-tracking SKILL.md lines 50-54). The §5.1 failure_direction guidance (lines 269-275) names "budgets are upper-tier defaults" and "human-gate latency is unbounded" as skew sources but never the blended-rate mix mismatch.

### Why this matters

The spec opposes numbers dressed as fact, and the blended rate quietly assumes the estimated task has the same input/output token ratio as a whole quarter of mixed activity. An estimate dominated by long-generation stages (implementer, spec-writer) will systematically under-price against a quarter blend weighted toward input-heavy usage, and vice versa. This is a smaller concern than O1/O2 because cost is conditional and disclosed-as-derived, but it is a real, undisclosed source of directional error in the one axis the spec works hardest to make honest. The failure_direction guidance (§5.1) or the cost-confidence rationale should name it so a reader knows the snapshot-grounded dollar figure still carries a mix-assumption, not just an age/granularity caveat.

## Explicitly not objecting to

- **O1 (round-1) — the AGENTS.md authority over-claim is genuinely resolved.** AGENTS.md line 104-105 carries the "agent-emit + dispatcher-persist + human-disposes" ARCH_DECISION exactly as the revised §5/§15 now cite it, and the spec correctly states (and a grep confirms) that no "disclosure-of-derived-judgment" decision exists — the four-part body is now honestly framed as a contract this spec proposes. I confirmed this against the source rather than trusting the revision note.
- **O3 and O11 (round-1) — the cost-optional-until-actuals restructure is genuinely resolved.** `cost_usd` is now conditional (§4.2 line 164), the list-price fallback is removed (§6.2 lines 430-433), and the no-cost case is defined as valid-and-complete with disclosure (§6.4); the binding table carries no hardcoded prices — prices come only from a snapshot — so the day-one deliverable is honestly a token + time estimate. This is a clean fix and I am no longer objecting to the day-one cost grounding.
- **O4 and O6 (round-1) — per-axis confidence is genuinely resolved.** `confidence` is now an object keyed `tokens`/`time`/conditional `cost` (§4.2 line 168, §5.2 lines 281-317), and the empty-snapshot collision is dissolved because the `cost` axis simply does not exist when `cost_usd` is absent — there is no longer a floor-vs-force contradiction, and the interaction with conditional cost (`confidence.cost` present iff `cost_usd` present) is specified cleanly in the §8.2 validation checklist.
- **O8 (round-1) — the third grounding state is genuinely resolved.** §6.2 (lines 411-426) now defines all three states (no snapshot / snapshot-without-usable-breakdown / snapshot-with-breakdown) and routes the middle state to omit-with-disclosure rather than silently falling through, correctly modelling the "(if available)" optionality of the snapshot Model Breakdown.
- **O10 and O12 (round-1) — disclosure placement and the positive-content no-verdict check are genuinely resolved.** The list-price inclusion caveat is gone, the omission caveat correctly belongs under Excluded as a genuine "does NOT count" case (§5.1 item 2), and the two-layer no-verdict guarantee with a positive-content prose scan (§5.3 lines 330-338, §8.2 checklist) closes the smuggled-verdict gap O12 raised.
- **The range-not-point decision (§3):** Endorsed in round 1 and unchanged; it remains a sound schema choice that leaves no failure class undetected.
- **The version-bump and maintenance mechanics (§8.4, §12):** A linter/convention concern, not an objection; the four-location 0.40.0→0.41.0 bump is correct per CLAUDE.md.
