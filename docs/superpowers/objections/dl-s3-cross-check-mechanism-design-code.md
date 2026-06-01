---
spec: docs/superpowers/specs/2026-05-29-dl-s3-cross-check-mechanism-design.md
date: 2026-06-01
mode: code
diaboli_model: claude-opus-4-7[1m]
objections:
  - id: O1
    category: implementation
    severity: medium
    claim: "The fixture-based ordering test (`test_canonical_ordering_invariant_on_fixture`) defines its own re-ordering helper inline (`_canonical_order`) and asserts the helper produces canonical output — but the helper is test code, not the agent's prompt content. The test verifies that *a re-ordering function exists* and would produce canonical output; it does not verify that the *agent's emit-time self-verification step* would actually re-order the same input. The two-layer enforcement claim from cartographer Story #7 is therefore architecturally accurate (one layer in the agent prompt, one layer as a structural test) but the structural-test layer exercises an external definition of canonical ordering rather than the agent's behaviour."
    evidence: "tdad_tests/tests/test_diagnostic_legibility_structural.py lines 736–812 (the new test). The `_canonical_order` helper is defined inside the test method (lines 770–779). The test then calls `_canonical_order(interleaved)` and asserts on the helper's output. Layer 3 (behavioural) would invoke the agent against the fixture; this structural-layer test cannot, by design (no API key at Layer 0/1). The spec at §7.2 names this constraint explicitly ('the structural-layer test exercises an external definition of canonical ordering rather than the agent's behaviour'), so the implementation matches the spec — but the cartographer Story #7 'defence-in-depth applied to contracts' claim is slightly stronger than what is delivered. A reader of the docs at cross-check-protocol.md §'Two-layer ordering enforcement' could reasonably infer that both layers verify *the agent's behaviour*; one layer verifies an external definition."
    disposition: accepted
    disposition_rationale: "Honest framing addition rather than test redesign. The structural test is the right shape for Layer 1 (offline, free, deterministic); a Layer 3 behavioural test exercising the agent's actual re-ordering is the genuine completion of the two-layer story. Add a one-paragraph note to cross-check-protocol.md §'Two-layer ordering enforcement' acknowledging that the structural-layer test asserts the invariant against a canonical-ordering definition, and that the genuine agent-behaviour verification belongs at Layer 3 if/when behavioural tests are added for diagnostic-legibility. Track this as a future-work item without filing a separate issue (the docs note carries the audit trail)."
  - id: O2
    category: implementation
    severity: medium
    claim: "Six precondition violations are documented in the agent file (unrecognised mode value, missing required field, unrevised input, empty challenge_notes, unfenced/multiple YAML payload, unsubstituted DISPATCHER placeholder) but only three of these are illustrated with example refusal lines. An implementer following the prompt has the shape of the contract but only three worked examples of how to phrase the reason clause; ambiguous violations may produce inconsistent refusal text."
    evidence: "diagnostic-legibility/agents/diagnostic-legibility.agent.md lines 90–98 (the three example refusal lines): unrecognised mode, missing populated challenge_notes, unsubstituted placeholder. The remaining three violation classes (missing required field other than challenge_notes; unfenced YAML; multiple YAML blocks) have no example refusal line. Spec §3.6's precondition table covers all six violation classes; the agent body covers three."
    disposition: accepted
    disposition_rationale: "Add three more example refusal lines (one per remaining violation class) to the agent's Inputs section. Cheap; reduces the implementer's interpretive load. The shape is identical so the additions are mechanical: `diagnostic-legibility refusal: cross-check-only mode requires a fenced ```yaml code block; payload appears unfenced.`, `diagnostic-legibility refusal: cross-check-only mode requires exactly one YAML payload; N blocks found.`, `diagnostic-legibility refusal: cross-check-only payload missing required field 'scope'.`"
  - id: O3
    category: specification quality
    severity: low
    claim: "The version-bump triplet test (`test_plugin_json_at_0_4_0`, `test_marketplace_entry_at_0_4_0`, `test_changelog_has_0_4_0_heading`) hard-codes the 0.4.0 literal in three places. When the next S4 slice bumps to 0.5.0, the same triplet of tests will need parallel updates. The test class layout makes the triplet visible together, but the three updates required across renames + literal updates is fragile — the dl-s2b precedent had the same pattern."
    evidence: "tdad_tests/tests/test_diagnostic_legibility_structural.py: test_plugin_json_at_0_4_0 (line 74, was 0_3_0 at v0.3.0), test_marketplace_entry_at_0_4_0 (line 89), test_changelog_has_0_4_0_heading (line 153). All three hard-code '0.4.0'. The pattern is identical to v0.3.0 (where they hard-coded '0.3.0'); each version bump renames the methods and updates the literals."
    disposition: deferred
    disposition_rationale: "The pattern is honest: each version's structural test pins that version's expected literal. The version-bump rename ceremony (function name + literal update at three sites) is small and the next slice (S4) is the first natural test of whether the pattern needs refactoring. If S4 surfaces the same friction, refactor to read the current version from plugin.json and compute the expected CHANGELOG literal — that is a separate, scoped piece of test-infrastructure work. Not blocking S3."
  - id: O4
    category: implementation
    severity: low
    claim: "The agent file's Phase C algorithm step 1 (precondition check for asymmetric input) sets `cross_check_status: skipped_asymmetric` and 'skip the rest of Phase C' — but the wording does not specify whether the agent should still emit the `Cross-check applied;` sentinel on the populated collection's elements before skipping. The spec at §3.6 is clear that the asymmetric case emits the wrapper field only and no per-element CC strings; the agent body could be tightened to make this unambiguous."
    evidence: "diagnostic-legibility/agents/diagnostic-legibility.agent.md lines 305–315 (Phase C step 1): 'If only one collection is populated (`(empty scope)` sentinel on one side; the other side has elements), skip the rest of Phase C. Set `cross_check_status: skipped_asymmetric` on the wrapper and emit the YAML. The populated collection is still individually refined by Phase B; that is the user-visible v0.4.0 result for asymmetric scopes.' No statement that *no* CC-applied sentinel is appended to the populated collection's elements. A careful reader infers this from the broader 'no per-element CC-skipped sentinel' rule, but the algorithm step itself is silent on the no-CC-applied case."
    disposition: accepted
    disposition_rationale: "Add one sentence to Phase C step 1: 'No CC-applied sentinel is appended to the populated collection's elements in this case; the model-level field carries the cross-check status alone.' Cheap clarification; closes the inference loop the spec already intends."
---

# Adversarial Review — dl-s3-cross-check-mechanism-design (code mode)

Code under review: branch `dl-s3-cross-check`. Spec at `docs/superpowers/specs/2026-05-29-dl-s3-cross-check-mechanism-design.md` (post-diaboli rewrite). Spec-mode adjudication is at `docs/superpowers/objections/dl-s3-cross-check-mechanism-design.md` (10/10 accepted). Cartographer at `docs/superpowers/stories/dl-s3-cross-check-mechanism-design.md` (7 stories: 3 promoted, 4 accepted).

Code-reviewer ran a pre-diaboli pass that surfaced six blocking findings; all six were addressed in the revision cycle before this code-mode review. The remaining concerns below are scoped to gaps the spec-mode adjudication did not anticipate and the code-reviewer pass did not surface — they are about edge cases in the implementation surface, not about the substantive design.

Four objections raised: 0 critical, 0 high, 2 medium (O1, O2), 2 low (O3, O4).

Distribution across categories:
- implementation: 3 (O1, O2, O4)
- specification quality: 1 (O3)
- premise / scope / alternatives / risk: 0

The implementation is structurally sound. The structural test suite delivers 9 new assertions (the cross-check class) plus the fixture-based ordering invariant test that the spec at §7.2 commits to. The schema template additive field, the mode-marker contract, the structured refusal lines, the subject-only audit trail, the direction-specific failure modes, and the Honesty-rules + Anti-patterns extensions are all present in the agent file. What is weak is **completeness of the implementer-facing surface** — three precondition violation classes lack worked refusal-line examples (O2); the Phase C step-1 algorithm is not explicit about the no-CC-applied sentinel branch (O4); the structural-layer ordering test verifies an external definition of canonical ordering rather than the agent's behaviour (O1, which the spec also acknowledged); and the version-bump test triplet hard-codes literals (O3, a pattern carried over from v0.3.0). None of these are blockers.
