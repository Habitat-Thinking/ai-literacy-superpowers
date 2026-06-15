---
spec: docs/superpowers/specs/2026-06-15-cost-capture-binding-gap-warning-design.md
date: 2026-06-15
mode: spec
diaboli_model: claude-opus-4-8[1m]
adjudication: all 10 accepted (3 high, 5 medium, 2 low) — absorbed into the spec
objections:
  - id: O1
    category: specification quality
    severity: high
    claim: "The three-outcome classification is not total — it omits states 1 (no snapshot) and 2 (Model Breakdown absent / step-4 'if not available, skip'), so a breakdown-less snapshot has no defined advisory or gets a misdiagnosing state-3 message."
    disposition: accepted
    disposition_rationale: "Added a FOURTH outcome — 'No per-model data' (states 1–2): when the snapshot carries no Model Breakdown, the advisory states the cause is structural (no per-model rows recorded), distinct from the haiku-only 'no estimating-tier family' case, and points at recording per-model data IF the dashboard exposes it."
  - id: O2
    category: implementation
    severity: high
    claim: "'References, does not restate the stem list' defends the stem data but not the resolution ALGORITHM (delimiter, aggregation, dearest-present); the command becomes a second executor of that algorithm — the real drift surface."
    disposition: accepted
    disposition_rationale: "Scoped the advisory to the MINIMAL check: family PRESENCE only — does any Model Breakdown key match the `claude-opus-4` stem? the `claude-sonnet-4` stem? (applying the stem + delimiter rule by reference). It does NOT compute rates, family aggregation, or the dearest-present proxy source — those stay estimator-only. This removes nearly all the drift surface; the command shares only the two stems + the delimiter rule, not the pricing procedure."
  - id: O3
    category: specification quality
    severity: high
    claim: "The advisory states the estimator's outcome as a property of the snapshot ('will proxy', 'will omit'), but proxying is conditioned on a future target EXERCISING the absent tier."
    disposition: accepted
    disposition_rationale: "Reworded conditionally for the proxy case: 'estimates that exercise the absent tier(s) will be proxied; estimates exercising only the present family ground directly.' The 'no estimating-tier family' WARN stays unconditional ('estimates will omit cost') because every estimate exercises ≥1 estimating tier, so if neither family resolves, every estimate omits — that 'will' is correct."
  - id: O4
    category: risk
    severity: medium
    claim: "Baking the literal '#414' into shipped user-facing command output couples it to an unbuilt follow-on; if #414 is closed/renamed the advisory points at a dead reference."
    disposition: accepted
    disposition_rationale: "The command's advisory TEXT describes the action ('update the binding stem table for the newer model generation') with no issue number. The spec/CHANGELOG may reference #414 as the tracking issue, but no GitHub issue number ships in the command's user-facing output."
  - id: O5
    category: specification quality
    severity: medium
    claim: "'Distinct from the step-10 validation checkpoint' is asserted but not enforced — a '10b' under the mandatory gate invites folding it into the pass/fail contract."
    disposition: accepted
    disposition_rationale: "The advisory's non-gating nature is specified as an enforceable constraint: it emits NO pass/fail token, NEVER modifies the snapshot, and runs+prints REGARDLESS of the step-10 result. Named explicitly as an 'informational advisory', not a validation sub-step."
  - id: O6
    category: specification quality
    severity: medium
    claim: "The 'Grounds, but proxied' advisory's `<tier(s)>`/`<family>` placeholders are under-specified — unclear whether `<family>` is the absent enrichment target or the present proxy source."
    disposition: accepted
    disposition_rationale: "Specified: name the ABSENT estimating tier and its family (the enrichment target — 'the Standard tier / claude-sonnet-4 family is absent'); the remedy names capturing a snapshot that includes that family's spend. The advisory does NOT name a 'dearest present' proxy source (that is pricing — estimator-only, per O2)."
  - id: O7
    category: risk
    severity: medium
    claim: "The advisory is conversational + a summary line — no parseable artefact, so its correctness is untestable, reproducing the silent-error class the feature exists to reduce."
    disposition: accepted
    disposition_rationale: "The outcome is recorded as a structured one-line entry in the snapshot's `## Observations` — `Cost-estimate grounding: grounds | proxied (<absent tiers>) | omitted (no estimating-tier family) | omitted (no per-model breakdown)` — a written, version-controlled, parseable artefact a Layer-1 / validation check can assert, and a consumer can corroborate. The advisory prose echoes this line."
  - id: O8
    category: premise
    severity: medium
    claim: "The premise assumes the capturing human can fix the gap ('add a missing model row'), but a Sonnet row can only be added if Sonnet spend occurred and the dashboard broke it out — for genuinely opus-only work there is nothing to add."
    disposition: accepted
    disposition_rationale: "The advisory distinguishes 'thin because per-model data was not recorded/available' (actionable: record it) from 'thin because the work genuinely used only some tiers this period' (NOT a defect — the honest note is 'no Standard-tier spend this period; nothing to do'). It explicitly does NOT nudge fabricating rows for spend that did not occur."
  - id: O9
    category: alternatives
    severity: low
    claim: "A cheaper consumer-side placement (harness-health / the estimator, where resolution already runs) would avoid the second-executor drift; the spec does not weigh it."
    disposition: accepted
    disposition_rationale: "Recorded the trade: capture-time was chosen for TIMELINESS (the human is in the loop at capture and can act immediately), with the drift surface minimised to a presence check (O2). The structured Observations line (O7) means consumer-side surfaces (harness-health, portfolio) can ALSO read the outcome later WITHOUT re-resolving — so the placement is not exclusive."
  - id: O10
    category: scope
    severity: low
    claim: "The cost-tracking SKILL pointer creates a coherence obligation against the SKILL's '(if available)' framing and its haiku example row, left unscoped."
    disposition: accepted
    disposition_rationale: "The SKILL pointer is scoped to note estimating-tier coverage drives prospective grounding AND annotates that a non-estimating family (e.g. haiku) row, while a valid breakdown entry, does not by itself ground cost — reconciling the example rather than implying it is deficient."
---

## Summary

Spec-mode diaboli on the cost-capture binding-gap-warning spec (#413) raised
**10 objections — 3 high, 5 medium, 2 low** — across premise (1), scope (1),
implementation (1), risk (2), alternatives (1), specification quality (4). **All
10 accepted.** The premise (a capture-time feedback loop is worth building) and
the advisory-not-gate shape were explicitly *not* challenged.

The three highs reshape the design materially and for the better:

- **O2 — thin presence check, not an algorithm re-run.** The advisory performs
  only **family-presence** detection (is there a `claude-opus-4` row? a
  `claude-sonnet-4` row?, via the stem + delimiter rule) — it does **not**
  re-implement the estimator's aggregation / dearest-present pricing. Drift
  surface minimised.
- **O7 — a structured, falsifiable artefact.** The outcome is written as a
  `Cost-estimate grounding:` line in the snapshot's `## Observations`, not just
  spoken — so it is testable and a consumer can corroborate.
- **O3 — conditional wording.** Proxy advisories are conditioned on a future
  target exercising the absent tier; only the no-estimating-family omission is
  stated unconditionally (correctly).

O1 adds the missing **no-per-model-data** outcome (states 1–2); O6 pins the
enrichment-target naming; O8 stops the advisory nudging fabricated rows; O4
keeps the issue number out of shipped command text; O5 makes the non-gating
property an enforceable constraint; O9/O10 record the placement trade and scope
the SKILL pointer.

## What was NOT challenged (diaboli disclosure)

- The core premise (a capture-time feedback loop closing the #411 latency).
- The advisory-not-gate intent (O5 challenges only its under-enforcement).
- The §5 out-of-scope boundaries (no binding/proxy/format change; no Haiku tier).
- The §12 summary line as a reporting surface (O7 challenges its testability).
- Naming non-estimating families so the human knows *why* a populated breakdown
  still won't ground (called out as good design).
