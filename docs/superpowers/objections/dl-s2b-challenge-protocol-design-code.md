---
spec: docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md
date: 2026-05-29
mode: code
diaboli_model: claude-opus-4-7[1m]
objections:
  - id: O1
    category: specification quality
    severity: high
    claim: "The mandatory machine-parseable `Q<N> (question name):` prefix is ambiguous on capitalisation: the five-question section uses title-cased question names ('Boundary', 'Description integrity'), the prefix example uses lowercase ('Q1 (boundary):', 'Q5 (description integrity):'), and the dimension-weighting paragraph drops the parentheses entirely ('Q2 evidence', 'Q3 confounders', 'Q4 confidence'). Two reasonable runs will emit inconsistent prefixes; the downstream cross-check's grouping breaks silently."
    evidence: "diagnostic-legibility/agents/diagnostic-legibility.agent.md lines 162–184 use 'Boundary', 'Evidence', 'Confounders', 'Confidence', 'Description integrity' as bolded section headers (title case). Line 130 — the canonical worked example — uses 'Q1 (boundary):' (lowercase). Lines 120–121 use 'Q2 evidence', 'Q3 confounders', 'Q4 confidence' without parentheses, contradicting the format spec on line 127 (`Q<N> (question name):`). The agent must pick one form per element; with three forms modelled in its system prompt, it will pick inconsistently across elements within a single invocation."
    disposition: accepted
    disposition_rationale: "Real bug in the prompt content. Pin one canonical form: `Q<N> (lowercase-question-name):`. Section headers (lines 162–184) stay title-cased as human-readable section titles, but the surrounding text and every example must use the canonical lowercase-in-parens form. Fix lines 120–121 (`Q2 evidence` → `Q2 (evidence)` etc.), add an explicit 'canonical form' callout near the format spec, propagate to the explanation page table. Add a structural test asserting the canonical form appears in the agent body."
  - id: O2
    category: implementation
    severity: high
    claim: "The agent must populate `generated_at` (ISO 8601) and `generated_by` (agent + active model id) on every emission, but its Read/Glob/Grep trust boundary gives it no clock and no model-introspection capability. The agent file's Output section names the fields as required without explaining how the agent obtains them."
    evidence: "diagnostic-legibility/agents/diagnostic-legibility.agent.md line 41: 'Required top-level fields: scope, generated_at (ISO 8601), generated_by (your name plus the active model identifier).' Frontmatter line 4: 'tools: Read, Glob, Grep' (no Bash). Nowhere in the agent body, the how-to, or the explanation does any guidance appear for how to derive a current ISO 8601 timestamp or the active model identifier. Compare model-cards/agents/model-card-researcher.agent.md, which faces the same problem and resolves it by deferring persistence (and these fields) to the dispatcher; this agent's spec §2.4 also defers persistence to the dispatcher but still requires the agent to emit the fields."
    disposition: accepted
    disposition_rationale: "Defer to the dispatcher. Agent emits placeholders `generated_at: \"<DISPATCHER: ISO 8601 timestamp>\"` and `generated_by: \"diagnostic-legibility / <DISPATCHER: active model identifier>\"`; the dispatcher fills both at persistence time. The agent file's Output section names the deferral explicitly; the how-to page documents the dispatcher's responsibility to substitute. Matches the model-card-researcher pattern."
  - id: O3
    category: risk
    severity: high
    claim: "The structural test `test_marketplace_plugin_version_unchanged` hard-codes `assert marketplace['plugin_version'] == '0.39.1'`, contradicting the spec §9 rule that the integration-agent should take main's value verbatim if it has moved between spec-time and merge-time. The test will fail at integration exactly in the scenario the spec explicitly anticipated, with no mechanism to relax the assertion without violating the test's own message ('this test guards the spec-time snapshot for the branch's own diff')."
    evidence: "tdad_tests/tests/test_diagnostic_legibility_structural.py lines 122–135 hard-code '0.39.1'. Spec §9 says: 'If main has bumped ai-literacy-superpowers's plugin_version between spec-time and merge-time, take main's value verbatim during the integration-agent's rebase.' The test's own failure message acknowledges 'integration-agent may take a newer value from main at rebase time' but still hard-fails when it does. The version-check CI workflow at .github/workflows/version-check.yml lines 108–124 cross-validates plugin_version against ai-literacy-superpowers/plugin.json — so a moved main produces a CI-green but test-red state, the worst possible signal."
    disposition: accepted
    disposition_rationale: "Rewrite the test to assert `marketplace.plugin_version == ai-literacy-superpowers/.claude-plugin/plugin.json#version` (the canonical source) instead of the hard-coded literal. The test becomes a structural redundancy check on top of the CI version-check workflow, which is fine — its real value is catching local-edit drift before CI runs. Update the test's docstring and failure message to match the new assertion."
  - id: O4
    category: risk
    severity: high
    claim: "The two load-bearing sentinel strings (`(empty scope)` in `name`, `Challenge applied; no questions surfaced changes` in `challenge_notes`) are documented as pattern-match handles for downstream consumers, but the structural test suite asserts nothing about them — the test docstring explicitly defers the sentinel contract to the spec 'as acceptance documentation rather than executable tests.' A drift in the sentinel string (a typo, a punctuation change, a model paraphrase) ships unguarded through every CI gate."
    evidence: "tdad_tests/tests/test_diagnostic_legibility_structural.py lines 1–9 docstring: 'These are deterministic, file-shape assertions — the agent's behavioural contract (challenge_notes shape, Q<N> prefix, sentinels) is covered by the spec ... as acceptance documentation rather than executable tests.' The spec at §3.5 and §3.6 marks both sentinels as 'verbatim' / 'exactly this string' / 'do not paraphrase' — the strongest possible specification of an exact-match contract — yet no test, lint, or CI hook reads the agent file and asserts the literal strings appear unchanged. A reflexive edit (e.g. 'no question surfaced' → 'no questions surface') invalidates the downstream cross-check (#332) silently."
    disposition: accepted
    disposition_rationale: "Add two static-text guards to the structural test suite: assert the exact literal `(empty scope)` appears in the agent body; assert the exact literal `Challenge applied; no questions surfaced changes` appears in the agent body. These are static-text assertions on the agent file, not behavioural runtime tests — the test docstring's exclusion was right about behaviour but wrong about static guards. Cost: ~10 lines of test code. Benefit: drift in the contract surface fails CI."
  - id: O5
    category: implementation
    severity: medium
    claim: "The agent's frontmatter `description` — what the Claude Code skill matcher reads to route invocations — does not surface the two contract terms that matter most: the `Q<N>` prefix and the sentinel strings. A dispatcher (orchestrator, future /diagnose command, human grep) reading only the description has no signal that the agent emits a structured machine-parseable contract beyond 'LegibilityModel as YAML'."
    evidence: "diagnostic-legibility/agents/diagnostic-legibility.agent.md line 3 description: 'Use to build two refined models ... applies a five-question self-challenge cycle, and retains challenge notes on every element. Returns a LegibilityModel as YAML.' No mention of `Q<N>` prefix, the sentinel strings, or the `(empty scope)` handle. The structural test test_agent_description_mentions_legibility_model (lines 251–268) asserts only that 'LegibilityModel' appears — exposing what the test author thought needed protection. Spec §3.5 calls the prefix 'mandatory and machine-parseable' and the parent S3 cross-check (#332) groups notes by it; a discovery surface that doesn't name it under-advertises the contract."
    disposition: accepted
    disposition_rationale: "Extend the description with a closing clause that names the machine-parseable contract: 'Notes follow the Q<N> (question-name): prefix convention; degenerate scopes use the literal `(empty scope)` sentinel.' Update the matching structural test to assert both `Q<N>` and the `(empty scope)` literal appear in the description. Cheap and pulls the contract surface into the discovery layer."
  - id: O6
    category: operational
    severity: medium
    claim: "Both downstream surfaces that human users see — the marketplace listing's `description` field and the `diagnostic-legibility/README.md` Install section — are stale and contradict v0.3.0 status. The marketplace says 'First agent (in development)'; the README still tells installers to 'Wait for S2 (#331) to land before expecting functional behaviour.' Anyone discovering the plugin through either surface gets the v0.1.0 message."
    evidence: ".claude-plugin/marketplace.json line 29 (the diagnostic-legibility plugins[] entry): 'First agent (in development) builds, self-challenges, and cross-checks two models of a codebase scope.' diagnostic-legibility/README.md lines 60–62: 'The plugin will install successfully but offer no commands at v0.1.0. Wait for S2 (#331) to land before expecting functional behaviour.' Both files were modified for the version bump; both kept descriptive copy from earlier slices. The README Status section (lines 8–24) was updated; the Install section directly below it was not."
    disposition: accepted
    disposition_rationale: "Update both surfaces: the marketplace.json description loses 'in development' and names the shipped agent; the README Install section is rewritten to reflect v0.3.0 (the agent is dispatchable via bare Task tool; /diagnose command is parent S4)."
  - id: O7
    category: risk
    severity: medium
    claim: "The fresh-sub-context self-challenge architecture (spec §3.4, adjudicated) depends on the model treating Phase B as 'someone else's work.' The agent file asserts twice that 'the phase boundary is load-bearing' but provides no observability — no log, no marker in the emitted YAML, no count — that would let a future reader detect whether the boundary actually fires or collapses into rubber-stamping. The escalation trigger named in the explanation ('unusually high rates of sentinel-only challenge_notes[]') has no instrument."
    evidence: "diagnostic-legibility/agents/diagnostic-legibility.agent.md lines 56–61 ('the boundary is load-bearing — it is the mechanism') and 95–105 (Phase B re-framing). docs/plugins/diagnostic-legibility/explanation/challenge-refine-protocol.md lines 112–118: 'If a real-invocation corpus shows the middle option still degenerates to self-confirmation — e.g. unusually high rates of sentinel-only challenge_notes[] across diverse scopes — the architecture can escalate to (2).' But there is no corpus, no persistence path for invocations, no command to aggregate sentinel-vs-Q<N> ratios. The escalation criterion is asserted with no plan for gathering the evidence that would trigger it. The plugin ships the failure-mode acknowledgement and the architectural fix but not the falsification surface."
    disposition: deferred
    disposition_rationale: "Defer to parent S4 (#333). The sentinel-ratio escalation criterion requires invocation outputs to be persisted somewhere — that persistence is the surfacing-layer job, not the agent's job. Update the explanation page to be honest about the gap: at v0.3.0 escalation is a manual-review pattern (a human reading some invocation outputs and noticing a high sentinel rate). When #333's /diagnose command ships, the natural extension is for /diagnose to persist outputs to a known path and a follow-up rule aggregates ratios."
  - id: O8
    category: implementation
    severity: medium
    claim: "The agent has no instruction for ordering when both architectural and domain elements draft cleanly, but the empty-scope sentinel is documented as going only to `architectural[]` 'by convention.' A free-text scope that yields only domain concepts (e.g. 'the checkout pricing rules' against a docs-only directory) would have the agent emit a non-degenerate `domain[]` and an empty `architectural[]` — but the agent's reasoning protocol drafts architectural first, and 'if the scope yields nothing' triggers the architectural-only sentinel even when domain elements have not yet been attempted."
    evidence: "diagnostic-legibility/agents/diagnostic-legibility.agent.md Phase A steps 3 (draft architectural), 4 (draft domain), 5: 'If the scope yields nothing, emit the (empty scope) sentinel ... and skip Phase B.' But 'yields nothing' is checked after architectural drafting (step 3) and before domain drafting (step 4) is not contractually clear — the wording can be read either way. A scope with no architectural shapes but rich domain concepts is a foreseeable input (docs-only scope, domain-glossary scope) and the protocol's behaviour on it is implementation-implicit. The spec §3.6 only addresses the both-empty case."
    disposition: accepted
    disposition_rationale: "Restructure Phase A so the both-empty check is unambiguous: rename step 5 to 'After steps 3 AND 4 complete, if both architectural[] and domain[] are empty, emit the (empty scope) sentinel into architectural[] and skip Phase B.' Single-collection-empty (e.g. domain elements found, no architectural) is normal — emit the non-empty collection and run Phase B on it; the empty collection stays as an empty YAML list. Document this 'asymmetric output is valid' rule in the agent body."
  - id: O9
    category: risk
    severity: low
    claim: "The CHANGELOG, the spec, and the agent's how-to all forward-link to issue #339 (the *promote* follow-up for the cross-PR `plugin_version` rule) — but the rule remains a per-spec restatement at merge-time, not a CLAUDE.md governance constraint. The current PR ships under the same fragility every prior diagnostic-legibility PR has shipped under, and the next plugin bump will need the same restatement until #339 ships."
    evidence: "docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md §9 carries the per-spec rule. diagnostic-legibility/CHANGELOG.md lines 43–47 name #339 as the 'promote' follow-up to CLAUDE.md. The Tests/CI gates assume the rule will be applied at integration-time, but CLAUDE.md (the source of truth agents read on every session) currently carries no rule — the agent doing the integration has to discover the rule by reading the per-spec text. This makes #339's resolution time-sensitive in a way the spec deferred without flagging."
    disposition: deferred
    disposition_rationale: "Already tracked at #339; the current PR ships under the same per-spec discipline (§9). The O3 fix (canonical-version comparison) addresses the proximate brittleness in this PR; #339 closes the underlying governance gap for future PRs. No further action in this PR — the disposition is the audit trail."
---

# Adversarial Review — dl-s2b-challenge-protocol-design (code mode)

Code under review: branch `dl-s2b-challenge-protocol`. Spec at
`docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md`.
Spec-mode adjudication is at
`docs/superpowers/objections/dl-s2b-challenge-protocol-design.md` —
this record does not re-litigate those dispositions.

Nine objections raised: 4 high (O1, O2, O3, O4), 4 medium (O5, O6, O7, O8),
1 low (O9). Distribution across categories: 1 specification quality, 3
implementation, 4 risk, 1 operational, 0 premise/alternatives/scope.

The implementation is structurally sound. The agent file lands at the
spec-targeted length (245 lines), carries the read-only tool boundary,
preserves the two-phase construction protocol with explicit re-framing,
and ships the version-bump triplet correctly. The docs site quadrants
scaffold the pages the spec promised. The CHANGELOG names the follow-up
issues. What is weak is **the operationalisation of the load-bearing
string contracts** — the `Q<N>` prefix appears in three inconsistent
forms in the agent's own system prompt (O1), the sentinels have no
automated guard (O4), and the agent must emit fields it has no mechanism
to derive (O2). The marketplace.json and README staleness (O6) and the
brittle plugin_version test (O3) are the operational debts the spec §9
named but did not retire.
