---
spec: docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md
date: 2026-06-11
mode: code
diaboli_model: claude-opus-4-8
objections:
  - id: O1
    category: implementation
    severity: medium
    claim: "Both worked-example agent_compute_time low bounds contradict the stated throughput band, so the canonical examples the S2 agent will pattern-match against teach an unreproducible derivation."
    evidence: "estimate-record-format.md:83 fixes the band at '~1–3 minutes per 10k tokens generated' applied to the tokens range; Example 1 (line 246, tokens.low 250000; line 260, agent_compute_time.low 23m) should yield 25m (250000/10000×1); Example 2 (line 312, tokens.low 200000; line 325, agent_compute_time.low 18m) should yield 20m (200000/10000×1)."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix now. Correct the two low bounds (23m→25m, 18m→20m) so the
      worked examples reproduce exactly from the stated throughput band.
  - id: O2
    category: implementation
    severity: medium
    claim: "The cost-derivation formula multiplies a whole-stage token range by the per-tier $/token rate but never specifies which of input vs output tokens it means, while the only blended rate it can compute is derived from a snapshot that distinguishes them — leaving the dominant cost figure ambiguous at the contract level."
    evidence: "estimate-record-format.md:164-170 defines '$/token as estimated_cost ÷ (input_tokens + output_tokens)' (a blended rate over both) but then 'cost_usd = Σ over stages (stage tokens range × tier $/token)' where stage tokens (line 30, line 246) is a single undifferentiated total; cost-tracking SKILL.md:50 keys the breakdown by separate input/output columns. The MODEL_ROUTING Token Budget Guidance ranges the estimate consumes (MODEL_ROUTING.md:18-26) are also undifferentiated totals, so the input/output split is silently dropped without the contract saying so."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix now. Add one sentence at the derivation disclosing the
      input/output collapse as a deliberate, accepted simplification (the
      sanctioned spec-round O4 skew), so a downstream S2 author knows it is
      by-design, not a bug to fix.
  - id: O3
    category: risk
    severity: medium
    claim: "The positive-content no-verdict scan is specified as a fixed enumerated string-match list, which the format itself frames as 'representative' — a downstream command implementing exactly the listed patterns will pass verdict prose that paraphrases around them, so the structural guarantee is weaker than the contract claims."
    evidence: "estimate-record-format.md:221-229 lists eight literal patterns ('so proceed', 'do not proceed', 'I recommend', 'you should ship/skip/approve/reject', 'go/no-go') and §5.3 (SKILL.md:228-248) calls the guarantee 'a property of the format itself, independent of any agent's good behaviour'; a sentence such as 'the high bound makes this not worth building' or 'budget does not justify the spend' matches none of the eight literals yet is a verdict the contract claims to forbid."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix now. Downgrade the guarantee's wording from "independent of
      any agent's good behaviour" to an honest "tripwire for common verdict
      phrasings, not a proof"; keep the enumerated patterns as representative.
      Honesty about the scan's own coverage is exactly this skill's thesis.
  - id: O4
    category: implementation
    severity: low
    claim: "The methodology consumes a 'tokens_by_stage[].stage' value of 'integration' and an Agent Routing row keyed '{{LANGUAGE}}-implementer', but the field table and worked examples use the bare stage name 'implementer' and a tier label 'Standard/Capable' without the slash-space MODEL_ROUTING actually prints, so a strict downstream parser binding stage→routing-row by literal match has no defined join key."
    evidence: "MODEL_ROUTING.md:14 names the agent '{{LANGUAGE}}-implementer' with tier 'Standard / Capable' (slash-space); estimate-record-format.md:30 and :256 record model_tier as 'Standard/Capable' (no spaces) and stage as 'implementer'; the binding table (estimate-record-format.md:146) writes 'Standard / Capable (split)'. Three spellings of one tier and two of one stage are in play with no normalisation rule."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix now. Add a one-line normalisation rule: stage names map to
      MODEL_ROUTING agent rows by stripping the `{{LANGUAGE}}-` prefix; tier
      labels are compared whitespace-insensitively.
  - id: O5
    category: specification quality
    severity: low
    claim: "The validation checklist's 'Per-axis confidence within cap' check is not mechanically runnable as written because the cap depends on target_kind but the checklist does not restate the mapping, and the cost-axis exemption ('independent of target_kind') is stated only in prose elsewhere — a command author implementing the checklist literally would either over-constrain cost or have no cap table to apply."
    evidence: "estimate-record-format.md:210-212 says 'each present confidence axis is within the target_kind ceiling for tokens/time; the cost axis is present iff cost_usd is present' — it caps tokens/time but the ceiling table lives at lines 118-122 and the cost-axis independence at lines 130-134; the checklist item does not reference either, so the single 'Output Validation Checkpoint' the format is built to serve (lines 8-12) cannot execute this check from the checklist alone."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix now. Make the checklist item self-contained: cross-reference
      the target_kind ceiling table and the cost-axis exemption so a mechanical
      consumer can run the check from the checklist alone.
  - id: O6
    category: implementation
    severity: low
    claim: "The cost-present worked example's whole-record cost_usd is asserted but the per-stage cost contributions are never shown in tokens_by_stage, so the example demonstrates the split-tier widening only in prose, not in the machine-readable structure the S2 agent must reproduce — the one place the contract could have made widening parseable, it did not."
    evidence: "estimate-record-format.md:323 gives cost_usd { low: 0.95, high: 7.50 } and the Included prose (lines 339-345) narrates a '$0.40–$5.00' implementer band, but tokens_by_stage entries (lines 313-322) carry no cost_usd sub-field; the widening that §6.1/§6.2 make load-bearing is therefore unverifiable against the frontmatter and the cited $0.40–$5.00 + other-stage costs cannot be reconciled to the $0.95–$7.50 total by any reader."
    disposition: deferred
    disposition_rationale: >
      Deferred to S2 (#369). Making per-stage cost machine-checkable (a cost_usd
      sub-field on tokens_by_stage summing to the total) is a format addition
      better decided when the S2 agent that must reproduce widening is built; the
      prose demonstration suffices for S1, and adding the sub-field now would be
      speculative structure ahead of its consumer.
---

## O1 — implementation — medium

### Claim

The two worked example records are the canonical shapes the S2 agent will pattern-match against and the S3 validation checkpoint will treat as reference-valid. Both of their `agent_compute_time` **low** bounds are inconsistent with the single throughput band the same reference fixes. The contract therefore ships a worked derivation a careful reader cannot reproduce from the stated rule.

### Evidence

`estimate-record-format.md:83` fixes the derivation: "a **default throughput band of ~1–3 minutes per 10k tokens generated**" applied "to the `tokens` range."

- Example 1: `tokens.low` is `250000` (line 246). 250000 / 10000 × 1 min = **25m**. The record states `agent_compute_time: { low: 23m, ... }` (line 260).
- Example 2: `tokens.low` is `200000` (line 312). 200000 / 10000 × 1 min = **20m**. The record states `agent_compute_time: { low: 18m, ... }` (line 325).

Both high bounds (3h and 2h30m) check out exactly against the 3-min end, which makes the low-bound divergence look like an unreproducible adjustment rather than a deliberate documented one — nothing in the Included prose explains a downward nudge.

### Why this matters

The format reference explicitly instructs readers to "Treat the field table, the binding table, the disclosure body spec, and the validation checklist as precise — they are parsed, not read loosely" (lines 8-12). The worked examples are the executable specification of the band. An S2 agent that learns the band from the worked example will inherit a derivation it cannot defend; an S3 checkpoint author who spot-checks `agent_compute_time` against the band on a real record will see a "failing" record that matches the shipped example exactly. The fix is one of: correct 23m→25m and 18m→20m, or add a prose note explaining the adjustment. Either resolves it; leaving it silent bakes a contradiction into the contract every later slice consumes.

## O2 — implementation — medium

### Claim

The cost figure is the most consequential and most contested axis in this design, and its arithmetic is under-specified at exactly the input/output-token seam. The rate is defined as a blend over input + output tokens; the multiplication is defined against an undifferentiated stage token total. The contract never states that the input/output distinction is intentionally collapsed, so two faithful implementers can produce materially different `cost_usd` figures from the same snapshot and the same token range.

### Evidence

`estimate-record-format.md:164-170`:

> Compute a per-model `$/token` as `estimated_cost ÷ (input_tokens + output_tokens)` … `cost_usd = Σ over stages (stage tokens range × tier $/token)`

The rate's denominator sums two distinct quantities the snapshot keeps separate (`cost-tracking` SKILL.md:50: `| Model | Tokens (input) | Tokens (output) | Estimated cost |`). The `stage tokens` multiplier is a single total (`estimate-record-format.md:30`, `:246`), itself sourced from MODEL_ROUTING Token Budget Guidance ranges that are also undifferentiated (`MODEL_ROUTING.md:18-26`). Output tokens are typically priced several times input tokens in real provider billing; a blended-rate-over-total approach is a defensible simplification, but the contract neither names it as a simplification nor warns that the blend's accuracy depends on the estimated task's input/output mix matching the snapshot quarter's mix.

### Why this matters

This is the residual the spec-mode round acknowledged as O4 (blended-rate mix skew) and explicitly sanctioned as a documented S2 residual. The objection here is **not** that the skew is unsolved — that adjudication stands. The objection is that the *implementation does not disclose the collapse at all* at the point of derivation, where the spec's own framing ("the methodology computes a per-model `$/token` … a single blended rate") at least flagged "blended." A downstream S2 author reading only the reference's formula will not know the input/output collapse is a known, accepted approximation versus a bug to fix. One sentence in the Included-disclosure guidance ("the blended rate assumes the estimated task's input/output ratio resembles the snapshot quarter's") would close the gap the spec opened but the reference left implicit.

## O3 — risk — medium

### Claim

The two-layer no-verdict guarantee is the design's strongest honesty claim — "a property of the format itself, independent of any agent's good behaviour." The positive-content layer is implemented as a closed list of eight literal string patterns. A closed literal list does not deliver the open guarantee the prose claims; verdict prose that avoids the eight literals passes the scan, so the structural guarantee is narrower than advertised.

### Evidence

`estimate-record-format.md:221-229` enumerates the prohibited patterns as literals: `"so proceed"`, `"do not proceed"`, `"I recommend"`, `"you should ship"`, `"you should skip"`, `"you should approve"`, `"you should reject"`, `"go/no-go"`. `SKILL.md:240-247` frames the same check as making "the no-verdict guarantee a property of the format itself, independent of any agent's good behaviour."

A failure-direction sentence such as "likely-overrun, and the high bound is not worth the spend" or "this is too expensive to justify" or "skip building this" matches none of the eight literals while delivering precisely the go/no-go the contract claims to structurally forbid. The format's own hedge — "representative prohibited patterns" (line 224) — concedes the list is non-exhaustive, which contradicts the "independent of any agent's good behaviour" claim: catching the open class still depends on the agent not paraphrasing around the list.

### Why this matters

The S3 command that implements this checklist literally inherits the gap, and the gap is invisible at the contract level because the prose oversells what the literal list achieves. This is groundable now (code time) in a way it was not at spec time: the implementation chose a closed enumeration where the guarantee needed either a semantic check or an explicit, honest scoping ("this scan catches common verdict phrasings; it is a tripwire, not a proof"). Re-framing the guarantee's strength in the reference (downgrade "independent of any agent's good behaviour" to "a tripwire for the common phrasings") would make the contract honest about its own coverage — which is, after all, this skill's entire thesis.

## O4 — implementation — low

### Claim

The contract relies on a stage→routing-row join to read each stage's model tier, but the join key is spelled three ways for the tier and two ways for the implementer, with no normalisation rule. A strict downstream parser has no defined way to bind the worked example's `implementer` / `Standard/Capable` to the MODEL_ROUTING row `{{LANGUAGE}}-implementer` / `Standard / Capable`.

### Evidence

- `MODEL_ROUTING.md:14`: agent `{{LANGUAGE}}-implementer`, tier `Standard / Capable` (slash with spaces).
- `estimate-record-format.md:30` and `:256`: `stage: implementer` (bare), `model_tier: Standard/Capable` (no spaces).
- `estimate-record-format.md:146`: binding table row `Standard / Capable (split)`.

Three spellings of the tier (`Standard / Capable`, `Standard/Capable`, `Standard / Capable (split)`) and two of the stage (`implementer`, `{{LANGUAGE}}-implementer`) coexist with no stated canonicalisation.

### Why this matters

The reference is built to be "parsed, not read loosely" (lines 8-12) by the S2 agent and the S3 checkpoint. Reading the model tier from Agent Routing (SKILL.md:70-74) requires matching the stage to a routing row; the templated `{{LANGUAGE}}-` prefix and the slash-spacing variance mean a literal string match fails. It is low severity because a human reader resolves it trivially and the routing table has only one split tier, but it is a real seam a mechanical consumer will trip on, and a one-line "stage names map to MODEL_ROUTING agent rows by stripping the `{{LANGUAGE}}-` prefix; tier labels are compared whitespace-insensitively" note in the reference would remove the ambiguity before S2 builds against it.

## O5 — specification quality — low

### Claim

The validation checklist item for per-axis confidence cannot be executed from the checklist alone: it asserts a `target_kind` cap for tokens/time and a cost-axis exemption, but restates neither the cap mapping nor the exemption rule, so a command author implementing "the checklist a consuming command runs" must reach into prose elsewhere to know what to enforce — and a literal implementer risks applying the cap to the cost axis.

### Evidence

`estimate-record-format.md:210-212`:

> **Per-axis confidence within cap** — each present `confidence` axis is within the `target_kind` ceiling for `tokens`/`time`; the `cost` axis is present **iff** `cost_usd` is present.

The cap mapping (`task-text`→low, `slice`→medium, `spec`→high) lives at lines 118-122; the cost-axis "independent of `target_kind`" rule at lines 130-134. The checklist item references neither. The reference frames the checklist as the authoritative "checks a consuming command's Output Validation Checkpoint runs" (line 203).

### Why this matters

The whole point of a references-file Output Validation Checkpoint (per the CLAUDE.md convention the spec invokes in §8.2) is that the downstream command can implement the checks from the checklist. This item is the one check whose rule is non-trivial and table-driven, and it is the one the checklist leaves dangling. Low severity because the rules do exist in the same file a few sections up, but a checklist that is supposed to be self-contained for a mechanical consumer is, on its single hardest item, not. A cross-reference ("see Per-axis confidence mapping above") or an inline restatement closes it.

## O6 — implementation — low

### Claim

The cost-present example is the only artefact that demonstrates the split-tier widening the design treats as load-bearing (O5-era spec concern), but it demonstrates it solely in Included prose. The frontmatter `tokens_by_stage` entries carry no per-stage cost sub-field, so the widening is unverifiable against machine-readable structure, and the narrated per-stage band cannot be reconciled to the whole-record total by any reader or parser.

### Evidence

`estimate-record-format.md:323`: `cost_usd: { low: 0.95, high: 7.50 }`. The Included prose (lines 339-345) narrates the implementer stage's "$0.40–$5.00 cost band." The `tokens_by_stage` entries (lines 313-322) have no `cost_usd` key. There is no spec-writer or tdd-agent per-stage cost shown, so a reader cannot check that $0.40–$5.00 (implementer) plus the unshown spec-writer and tdd-agent contributions sum to the stated $0.95–$7.50 whole-record range. (The low bounds are in fact irreconcilable on their face: a $0.40 implementer low alone already implies the other two stages contribute $0.55 at the low end, which is never shown.)

### Why this matters

The spec made the split-tier widening a first-class requirement (FR-7) and required the cost-present example to "demonstrate the split-tier widening … its implementer stage carries a non-zero cost band." The implementation demonstrates it in prose but not in the parseable structure, which is the half that matters for the S2 agent that must *reproduce* widening and the S3 checkpoint that must *validate* it. Low severity because the prose does convey the mechanism to a human, but the contract had the opportunity to make widening machine-checkable (a `cost_usd` sub-field on `tokens_by_stage[]`, summing to the total) and did not, leaving the most contested axis demonstrated only in unverifiable prose.

## Explicitly not objecting to

- **The cost-omitted-by-default day-one shape**: omitting `cost_usd` when `observability/costs/` is empty and disclosing the omission in `Excluded` is faithfully implemented across SKILL.md, the reference field table, and Example 1 — this is the spec's central restructure and the implementation realises it cleanly.
- **The human_gate_time qualitative-caveat decision**: the implementation consistently carries `human_gate_time` as a caveat string (never a range) in the field table, the time-split section, both worked examples, and the validation checklist — the O2-era spec decision is realised without leakage into S4 gate-topology territory.
- **The binding-table model names matching the snapshot keys**: the tier→model map (`claude-opus-4`, `claude-sonnet-4`) matches the actual `cost-tracking` Model Breakdown row keys (cost-tracking SKILL.md:52-53), so the binding is groundable — I confirmed this against the sibling format rather than assuming it, and it holds.
- **O3/O4 spec-residual status**: the binding-table drift and blended-rate mix skew remain note-not-solved exactly as the spec-mode round-2 adjudication sanctioned; the implementation neither claims to solve them nor makes them worse, so per the dispatch scope I do not object to their being unresolved (O2 above objects only to an undisclosed *collapse*, not to the sanctioned skew itself).
- **The version-bump triplet and the test-edit loosening**: plugin.json/marketplace.json/README/CHANGELOG consistency at 0.41.0 and the `== 0.40.0` → `>= 0.40.0` assertion change in test_assess_operational_axes.py are legitimate and were already PASSed by the prior reviewer; I re-examined the assertion (line 259) and it correctly prevents future-bump regressions without weakening coverage.
- **The trigger carve against the retrospective sibling**: the `description` line distinguishes prospective ("before it runs", "how much will this cost to build") from retrospective capture and names the sibling, and the trigger scenario protects exactly that boundary — the carve is clean and I found no false-positive routing risk against `cost-tracking`.
