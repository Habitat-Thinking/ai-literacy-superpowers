---
spec: docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md
date: 2026-06-01
mode: code
diaboli_model: claude-opus-4-8[1m]
objections:
  - id: O1
    category: implementation
    severity: medium
    claim: "The new TestDiagnosticLegibilityDiagnoseCommand assertions are pure token-presence checks against the command body, so a command file that documents the report geometry *incorrectly* would still pass every assertion. test_command_documents_report_geometry asserts only that the substrings `side-by-side`, `### Architectural model`, `### Domain model`, `A→D`, `D→A`, `completed`, `skipped_asymmetric`, `not_run`, `CC<N>`, and `elements revised` each appear somewhere in the body — it cannot detect a body that placed CC before Q, swapped the A→D/D→A definitions, or mis-described the elements-revised semantic. This is the same shape as the S3 code-mode O1 finding (the structural test verifies a token's presence, not the agent's behaviour)."
    evidence: "tdad_tests/tests/test_diagnostic_legibility_structural.py lines 1013–1052 (test_command_documents_report_geometry). Each assertion is `assert \"<literal>\" in body`. The literals are all present in diagnostic-legibility/commands/diagnose.md (the side-by-side table at lines 230–235, the stacked-models prose at lines 237–256, the A→D/D→A labels at lines 204–207). No assertion ties `A→D` to *architectural elements revised* or checks that `CC<N>` renders after `Q<N>` in any worked example — the command's correctness on those points rests entirely on the prose an implementing agent reads, not on the test."
    disposition: accepted
    disposition_rationale: "Accepted — honest framing addition plus a cheap test strengthening, not a redesign. Structural tests run offline at Layer 0/1 and cannot exercise a live render; token-presence is the right shape for that layer, and genuine behavioural verification of the rendered geometry belongs at Layer 3 if/when behavioural tests are added for diagnostic-legibility (same disposition as S3 code-mode O1). Two concrete improvements absorbed: (1) strengthen test_command_documents_report_geometry with relative-ordering assertions an offline test CAN make — `### Architectural model` appears before `### Domain model`, and the A→D definition string co-locates `A→D` with `architectural`; (2) add a one-line note in the command/spec that the structural layer pins documented tokens, not rendered behaviour. Tracked via the docs note; no separate issue."
  - id: O2
    category: implementation
    severity: medium
    claim: "The elements-revised count derivation is under-specified for an implementing agent at exactly the seam where the agent's subject-only audit-trail contract bites. The command defines an A→D / D→A count as 'architectural/domain elements carrying ≥1 CC<N> entry' and explicitly excludes side-effect revisions (named in a subject's CC prose but carrying no CC<N> entry on the side-effect target). But an architectural element that was genuinely revised *as a D→A side effect* is a real correction the human cares about, yet it is invisible to the count and to the validation checkpoint, which can only re-derive the same CC-entry-presence number the renderer used. The headline 'corrections' figure therefore systematically under-reports cross-collection corrections, and neither the command nor the checkpoint flags this."
    evidence: "diagnostic-legibility/commands/diagnose.md lines 204–209 (count definition) and the validation checkpoint check 3 at lines 130–133 ('each consistent with the parsed YAML under the elements-revised definition'). The agent's subject-only audit trail (diagnostic-legibility/agents/diagnostic-legibility.agent.md lines 357–368, 540–548) writes the CC<N> entry on the subject only and names the side-effect on the sibling in prose, with no CC<N> entry on the sibling. So a D→A cross-check that revises an architectural sibling produces zero architectural CC<N> entries → the architectural side-effect does not count toward any direction. The command (line 209) states the non-double-count rule but does not acknowledge that the consequence is an under-count of genuinely-revised elements; the checkpoint at line 133 re-derives from CC<N> entries identically, so it cannot surface the gap (the spec-mode O6 disposition already conceded the checkpoint is not an independent oracle)."
    disposition: accepted
    disposition_rationale: "Accepted — name the under-count honestly rather than re-engineer the count. Re-deriving a side-effect-inclusive count would require parsing free-text CC prose for sibling names, which is exactly the kind of fuzzy inference the subject-only audit trail was designed to avoid; the count stays anchored to CC<N>-entry presence. The fix is a one-line clarification in the command's Cross-check summary section and the reference page: the A→D/D→A figures count elements revised *as the subject of a cross-check* (carrying ≥1 CC<N> entry); side-effect revisions named in a subject's prose are real corrections but are not counted, so the figure is a lower bound on elements touched. This makes the surfacing honest about what the headline number means."
  - id: O3
    category: implementation
    severity: medium
    claim: "The `not_run` cross_check_status branch is rendered, documented, and pinned by a structural test, but is unreachable through `/diagnose`. The v0.5.0 agent emits only `completed` or `skipped_asymmetric` (never `not_run`), and `/diagnose` always dispatches a fresh `mode: full` run whose emitted model always carries the field — so the report's `not_run` rendering, the reference table's `not_run` row, and the test assertion `assert \"not_run\" in body` exercise a path no `/diagnose` invocation can produce. This is dead surface that an implementing agent must nonetheless carry, and a structural test that pins a literal for a state the command never reaches."
    evidence: "diagnostic-legibility/agents/diagnostic-legibility.agent.md lines 110–113: 'not_run — reserved for backwards-compatibility with v0.3.0 outputs... The v0.4.0 agent itself only emits completed or skipped_asymmetric; it never emits not_run.' The command renders all three (diagnose.md lines 187, 198–199) and the test forces all three present (test_diagnostic_legibility_structural.py lines 1039–1043, loop over `(\"completed\", \"skipped_asymmetric\", \"not_run\")`). Because `/diagnose` always runs `mode: full` (diagnose.md lines 79–87) against a freshly-emitted model, field-absence (the only route to `not_run`) cannot occur. The branch is defensible as forward-compatible rendering, but nothing in the command or docs marks it as a never-from-/diagnose case, so a reader cannot tell it apart from a live branch."
    disposition: accepted
    disposition_rationale: "Accepted — keep the forward-compatible branch, label it. The rendering of all three values is correct defensive completeness (the report renderer should handle any legal LegibilityModel, including an externally-supplied v0.3.0 model with the field absent); the gap is only that nothing marks `not_run` as unreachable via /diagnose. Add a one-line note in the command and reference page: `not_run` is not produced by a /diagnose run (which always dispatches mode: full against a freshly-emitted model); it is rendered for forward-compatibility with externally-supplied / v0.3.0-era models. The structural test asserting all three values stays (it pins documentation completeness)."
  - id: O4
    category: risk
    severity: medium
    claim: "For the scope-yields-nothing case, the report surfaces `cross_check_status: skipped_asymmetric` with the human-language gloss 'only one collection was populated' — but nothing was populated; the agent synthesised a single `(empty scope)` sentinel element. A command whose entire purpose is human legibility renders, for the empty result, a status line that contradicts what actually happened (scope yielded nothing, not 'one collection was populated'). The S2-era both-empty clause added in this PR (O2-accepted at spec gate) is correct mechanically but the surfacing layer inherits a misleading human gloss."
    evidence: "Agent both-empty branch (diagnostic-legibility/agents/diagnostic-legibility.agent.md lines 199–203): both-empty emits the (empty scope) sentinel into architectural[] and sets cross_check_status: skipped_asymmetric. The command's human-terms line for skipped_asymmetric (diagnose.md lines 197–199 / spec §5.2) reads 'Cross-check was skipped: only one collection was populated.' The reference page reinforces this (docs/plugins/diagnostic-legibility/reference/diagnose-command.md line 77: 'Only one collection was populated (including the empty-scope sentinel case)'). For a genuinely empty scope, the human reads 'one collection was populated' next to a report whose only element is the (empty scope) placeholder — the gloss and the artefact disagree. Scenario 6.9 (spec lines 707–717) confirms this is the intended rendering, so the contradiction ships as designed."
    disposition: accepted
    disposition_rationale: "Accepted — branch the human gloss on the sentinel, leave the wrapper value alone. The agent's cross_check_status: skipped_asymmetric is the honest machine label and stays (no agent change). What changes is the command's human-facing rendering: when the populated collection contains only the (empty scope) sentinel, render a dedicated gloss — e.g. 'Scope yielded no elements; cross-check did not run.' — instead of 'only one collection was populated.' Update the command's Cross-check summary rendering rules and the reference page's status table so the empty-scope case reads honestly. This is the surfacing layer's job: the same wrapper value can carry two distinct human meanings (true asymmetric vs empty scope) and the command should distinguish them for the human."
  - id: O5
    category: implementation
    severity: low
    claim: "The side-by-side summary table gives no per-cell label tying each count to its direction definition, leaving the A→D / D→A placement ambiguous for an implementing agent. The table row 'Elements revised (cross-check)' renders `<A→D count>` under the Architectural column and `<D→A count>` under the Domain column. But 'A→D' reads naturally as 'architectural challenges domain → domain elements revised', the opposite of the command's actual definition ('A→D = architectural elements carrying ≥1 CC entry'). The prose resolves it; the table does not, so an agent rendering the table from the table spec alone could transpose the two counts and still pass O1's token-presence test."
    evidence: "diagnose.md lines 230–235 (the table: `| Elements revised (cross-check) | <A→D count> | <D→A count> |` under `| | Architectural | Domain |`) versus the definition at lines 204–207 ('A→D corrections — architectural elements carrying ≥1 CC<N> entry'). The direction arrow A→D names the challenger→subject relation in the agent (architectural subject challenged BY domain is 'A→D' per agent lines 322–328), so the count under the Architectural column is architectural-elements-revised — correct, but only derivable by cross-reading the agent's direction convention, not from the table cell itself."
    disposition: accepted
    disposition_rationale: "Accepted — disambiguate the table cell. Annotate the table so each cell binds its count to the definition: e.g. the Architectural column's revised cell reads `<count> (A→D)` and the Domain column's reads `<count> (D→A)`, or add a one-line caption under the table tying 'elements revised in the Architectural column' to the A→D definition. Cheap; removes the transposition trap for an agent copying the table template. Folds in with O1's broader 'pin the artefact, not just the tokens' fix."
  - id: O6
    category: specification quality
    severity: low
    claim: "The refusal-detection rule ('a line matching `diagnostic-legibility refusal:` AND no YAML code block') leaves the malformed-both case undefined: if the agent emits a refusal-shaped line AND a YAML block in one response, the command falls through to the render path (because a YAML block is present) and would try to render a model the agent meant to refuse. The command carries the refusal path explicitly as a 'defensive contract' for `mode: full`, but the one composite malformation the defence exists to catch is the one it routes past."
    evidence: "diagnose.md lines 96–101 ('If the response contains a line matching `diagnostic-legibility refusal:` and no YAML code block') and lines 102–106 (the defensive-contract rationale). The detection is conjunctive on 'no YAML code block', so refusal-line-plus-YAML routes to step 6 render. The agent contract (diagnostic-legibility.agent.md lines 80–81: 'The line is the entire response — no YAML code block follows') makes this malformation contractually impossible, which is why it is low — but the command's own validation checkpoint catches a malformed-YAML parse failure (diagnose.md lines 143–144) while this refusal-plus-YAML case has no named handling."
    disposition: accepted
    disposition_rationale: "Accepted — one-line fail-safe, consistent with the defensive framing. Since the command already justifies the refusal path as defensive degradation against unexpected agent behaviour, make the rule fail safe: if a `diagnostic-legibility refusal:` line is present at all, treat the response as a refusal and abort with no write, even if a YAML block also appears (the agent contract forbids the composite, so this only ever fires on genuinely malformed output, where refusing is the safe choice). Update the refusal-handling step wording. Low effort, closes the one composite the defence was framed to catch."
  - id: O7
    category: implementation
    severity: low
    claim: "The version-bump test fragility deferred at S3 (S3 code-mode O3) has reproduced verbatim at S4, and the deferral's own stated trigger — 'the next slice is the first natural test of whether the pattern needs refactoring' — has now fired without the refactor. S4 hard-codes `0.5.0` at three sites (plugin.json, marketplace entry, CHANGELOG heading) plus a new fourth site hard-coding `0.4.0` (the top-level-version-unchanged assertion), so the next slice's bump ceremony is now a four-site rename rather than three."
    evidence: "tdad_tests/tests/test_diagnostic_legibility_structural.py: test_plugin_json_at_0_5_0 (line 74), test_marketplace_entry_at_0_5_0 (line 89), test_changelog_has_0_5_0_heading (line 153) — all hard-code '0.5.0', renamed from the '0_4_0' / '0.4.0' forms at S3. test_marketplace_top_level_version_still_0_4_0 (lines 1135–1151) adds a fourth hard-coded literal ('0.4.0'). S3 code-mode O3 (docs/superpowers/objections/dl-s3-cross-check-mechanism-design-code.md O3) deferred this with the rationale 'the next slice (S4) is the first natural test of whether the pattern needs refactoring. If S4 surfaces the same friction, refactor to read the current version from plugin.json'. S4 surfaced the same friction and reproduced the pattern."
    disposition: accepted
    disposition_rationale: "Accepted as a conscious, terminal accept-the-fragility — NOT a third deferral (which would be the deferred-concern-accretion anti-pattern promoted to AGENTS.md from this slice's cartographer Story #8). The human explicitly accepts the four-site hard-coded version literals as they stand: S4 is the LAST slice of the diagnostic-legibility plugin, so there is no imminent next bump to pay the rename ceremony, and each test honestly pins its slice's expected literal. This closes the S3-deferred thread by deciding it (accept), rather than kicking it forward again or opening a follow-up issue for work with no near-term trigger. If a future diagnostic-legibility slice ever reopens version churn, the refactor-to-read-from-plugin.json option remains available then, on evidence."
---

# Adversarial Review — dl-s4-diagnose-command-design (code mode)

Code under review: branch `dl-s4-diagnose-command` (the S4 work, `git diff b7c19ea..HEAD`). Primary artefact: `diagnostic-legibility/commands/diagnose.md`. Spec at `docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md`. Spec-mode adjudication is at `docs/superpowers/objections/dl-s4-diagnose-command-design.md` (11 objections: 10 accepted, 1 deferred — O11 `--out` containment). The cartographer gate is recorded at `docs/superpowers/stories/dl-s4-diagnose-command-design.md` (2 promoted / 5 accepted / 1 revisit). The code-reviewer PASS is in.

This review is scoped to gaps in the **implementation surface** that the spec-mode adjudication did not anticipate and the code-reviewer pass did not surface. It does **not** re-litigate the eleven adjudicated spec-mode objections. Code-mode weighting applies: `implementation` and `risk` emphasised; `premise` deprioritised (none raised — the premise was adjudicated at the spec gate).

Seven objections raised: 0 critical, 0 high, 4 medium (O1–O4), 3 low (O5–O7).

Distribution across categories:
- implementation: 4 (O1, O2, O5, O7)
- risk: 1 (O4)
- specification quality: 1 (O6)
- premise / scope / alternatives: 0

The implementation is faithful to the adjudicated spec and the `model-card` precedent. The command file is well-structured, the docs are consistent with it on the surfaces they describe, and the confirm-before-write gate (the load-bearing spec-mode fix) is present and correctly ordered after the checkpoint. The weaknesses cluster in two places. First, **the implementer-facing contract leans on prose an implementing agent must read correctly without a test backstop**: the structural tests are token-presence checks that would pass on a command that documented the geometry, the count direction, or the Q/CC order *wrongly* (O1, O5), and the elements-revised count silently under-reports the genuine side-effect corrections the subject-only audit trail produces (O2). Second, **two rendered branches carry a human-legibility mismatch or are dead through `/diagnose`**: the empty-scope `skipped_asymmetric` gloss contradicts what happened (O4), and the `not_run` branch is unreachable yet pinned by a test (O3). The refusal-plus-YAML composite is undefined (O6, low, contractually impossible per the agent), and the version-triplet fragility deferred at S3 has reproduced and grown to four sites (O7, low). None of these block integration.

## O1 — implementation — medium

### Claim

The new `TestDiagnosticLegibilityDiagnoseCommand` assertions are pure token-presence checks against the command body. A command file that documented the report geometry *incorrectly* — CC before Q, the A→D/D→A definitions swapped, the elements-revised semantic mis-stated — would still pass every assertion, because every assertion only asks whether a literal substring appears somewhere in the body. This is the same failure shape as S3 code-mode O1: the structural test verifies a token's presence, not the behaviour the token names.

### Evidence

`tdad_tests/tests/test_diagnostic_legibility_structural.py` lines 1013–1052 (`test_command_documents_report_geometry`). Every assertion is `assert "<literal>" in body`. The literals (`side-by-side`, `### Architectural model`, `### Domain model`, `A→D`, `D→A`, `completed`, `skipped_asymmetric`, `not_run`, `CC<N>`, `elements revised`) are all present in `diagnostic-legibility/commands/diagnose.md` (table lines 230–235, stacked-models prose lines 237–256, direction labels lines 204–207). No assertion ties `A→D` to *architectural elements revised*, and none checks that any worked example renders `CC<N>` after `Q<N>`. The command's correctness on those points rests entirely on the prose an implementing agent reads.

### Why this matters

Because `/diagnose` is a markdown instruction contract executed by an agent, the structural tests are the only deterministic backstop the pipeline has before the human accept gate. If the backstop only checks for the presence of the right words in any order, it cannot catch the precise failures the geometry-pinning (spec O7) and count-definition (spec O5) dispositions were designed to prevent. The spec-mode adjudication pinned the contract in prose; the test layer does not pin the artefact to it.

## O2 — implementation — medium

### Claim

The elements-revised count systematically under-reports cross-collection corrections at the seam where the agent's subject-only audit trail bites. An architectural element revised *as a D→A side effect* is a genuine correction, but it carries no `CC<N>` entry (the entry lives on the domain subject; the side effect is named only in prose), so it counts toward neither direction. The command states the non-double-count rule but does not acknowledge that the consequence is an under-count, and the validation checkpoint — which re-derives the same CC-entry-presence number — cannot surface it.

### Evidence

`diagnostic-legibility/commands/diagnose.md` lines 204–209 (count definition and the side-effect exclusion at line 209) and checkpoint check 3 at lines 130–133. The agent's subject-only audit trail (`diagnostic-legibility/agents/diagnostic-legibility.agent.md` lines 357–368 and 540–548) writes the `CC<N>` entry on the subject only and names the sibling side effect in prose, with no `CC<N>` entry on the sibling. A D→A cross-check that revises an architectural sibling therefore produces zero architectural `CC<N>` entries, so the architectural side effect does not count in either direction. Spec-mode O6 already conceded the checkpoint is not an independent oracle.

### Why this matters

The cross-check summary is the headline number the human reads to judge how much mutual correction happened — it is the report's reason to exist. If side-effect corrections are silently dropped from the count, the human under-estimates the cross-check's effect, and the under-estimate is largest precisely when the cross-check did the subtle work. At minimum the command should name this as a known under-count so a reader does not treat the figure as the total number of elements the cross-check touched.

## O3 — implementation — medium

### Claim

The `not_run` cross_check_status branch is rendered, documented, and pinned by a structural test, but is unreachable through `/diagnose`. The v0.5.0 agent emits only `completed` or `skipped_asymmetric`; `/diagnose` always dispatches a fresh `mode: full` run whose emitted model always carries the field, so `not_run` (reachable only via field-absence on a v0.3.0-era model) cannot occur.

### Evidence

`diagnostic-legibility/agents/diagnostic-legibility.agent.md` lines 110–113 ('The v0.4.0 agent itself only emits completed or skipped_asymmetric; it never emits not_run. Consumers treat field-absence as not_run'). The command renders all three values (`diagnose.md` lines 187, 198–199) and the test forces all three present (`test_diagnostic_legibility_structural.py` lines 1039–1043). `/diagnose` always runs `mode: full` against a freshly-emitted model (`diagnose.md` lines 79–87), so field-absence — the only route to `not_run` — cannot arise.

### Why this matters

Carrying a forward-compatible rendering branch is defensible, but an unlabelled dead branch costs an implementing agent interpretive load and the structural test gives false assurance that a live path is covered. A one-line note marking `not_run` as 'not produced by `/diagnose`; rendered for forward-compatibility' would resolve the ambiguity.

## O4 — risk — medium

### Claim

For the scope-yields-nothing case the report surfaces `cross_check_status: skipped_asymmetric` with the human gloss 'only one collection was populated' — but nothing was populated; the agent synthesised a single `(empty scope)` sentinel. A command whose entire purpose is human legibility renders, for the empty result, a status line that contradicts what actually happened. The both-empty agent clause added in this PR is mechanically correct, but the surfacing layer inherits a misleading human-language gloss.

### Evidence

Agent both-empty branch (`diagnostic-legibility/agents/diagnostic-legibility.agent.md` lines 199–203): both-empty emits the `(empty scope)` sentinel into `architectural[]` and sets `cross_check_status: skipped_asymmetric`. The command's human-terms line for `skipped_asymmetric` (`diagnose.md` lines 197–199) reads 'Cross-check was skipped: only one collection was populated.' The reference page reinforces it (`docs/plugins/diagnostic-legibility/reference/diagnose-command.md` line 77). Scenario 6.9 (spec lines 707–717) confirms this is the intended rendering, so the contradiction ships as designed.

### Why this matters

The empty-scope case is exactly the degenerate input the sentinel exists to make safe and legible. Surfacing 'one collection was populated' for a scope that yielded nothing tells the human the opposite of the truth in the one case where they most need a clear signal. A dedicated human gloss for the sentinel case would make the report honest without changing the wrapper value the agent commits to.

## O5 — implementation — low

### Claim

The side-by-side summary table gives no per-cell label tying each count to its direction definition, leaving the A→D / D→A placement ambiguous for an implementing agent. The arrow `A→D` reads naturally as 'architectural challenges domain → domain elements revised', the opposite of the command's actual definition. The prose resolves it; the table cell does not, so an agent rendering from the table spec alone could transpose the two counts and still pass O1's token-presence test.

### Evidence

`diagnose.md` lines 230–235 (the table row `| Elements revised (cross-check) | <A→D count> | <D→A count> |` under columns `Architectural | Domain`) versus the definition at lines 204–207. The agent's direction convention (`diagnostic-legibility.agent.md` lines 322–328) is what makes the Architectural-column count equal architectural-elements-revised — correct, but derivable only by cross-reading the agent's convention.

### Why this matters

Low because the prose in the same file resolves the ambiguity for a careful reader, and O1 already covers the absence of a test backstop. Noted because the one place a hurried implementing agent would copy — the table template — is the one place the direction-to-definition binding is implicit.

## O6 — specification quality — low

### Claim

The refusal-detection rule ('a line matching `diagnostic-legibility refusal:` AND no YAML code block') leaves the malformed-both case undefined: a response carrying a refusal-shaped line *and* a YAML block routes to the render path. The refusal path is carried explicitly as a defensive contract, but the one composite malformation a defence would exist to catch is the one it routes past.

### Evidence

`diagnose.md` lines 96–101 (conjunctive detection) and lines 102–106 (the defensive-contract rationale). The agent contract (`diagnostic-legibility.agent.md` lines 80–81) makes the composite contractually impossible, which is why it is low. The validation checkpoint handles malformed-YAML parse failure (`diagnose.md` lines 143–144) but the refusal-plus-YAML composite has no named handling.

### Why this matters

Low because the agent contract forbids the composite. Noted because the command's stated reason for keeping the refusal path is defensive degradation against an agent that behaves unexpectedly, and a refusal line emitted alongside a stray YAML block is precisely that kind of unexpected behaviour — yet it falls through to render.

## O7 — implementation — low

### Claim

The version-bump test fragility deferred at S3 (S3 code-mode O3) has reproduced verbatim at S4, and the deferral's own stated trigger — 'the next slice is the first natural test of whether the pattern needs refactoring' — has now fired without the refactor. S4 hard-codes `0.5.0` at three sites plus a new fourth site hard-coding `0.4.0`, so the next slice's bump ceremony is now a four-site rename.

### Evidence

`tdad_tests/tests/test_diagnostic_legibility_structural.py`: `test_plugin_json_at_0_5_0` (line 74), `test_marketplace_entry_at_0_5_0` (line 89), `test_changelog_has_0_5_0_heading` (line 153) — all hard-code '0.5.0'. `test_marketplace_top_level_version_still_0_4_0` (lines 1135–1151) adds a fourth hard-coded literal. The S3 disposition deferred with 'If S4 surfaces the same friction, refactor to read the current version from plugin.json'. S4 surfaced the same friction and reproduced the pattern.

### Why this matters

Low and non-blocking — each test honestly pins its slice's expected literal. Noted because the explicit trigger the S3 deferral named has now been met. Re-deferring in place would be the deferred-concern-accretion anti-pattern this slice's cartographer Story #8 just promoted to AGENTS.md — so the principled resolution is to re-file as a standalone follow-up issue, not defer again.

## Explicitly not objecting to

- **The confirm-before-write gate ordering (§4.7 → §4.8 → §4.9).** Present, correctly after the checkpoint and before the write, surfaces the resolved path, flags overwrites, writes only on accept — exactly the spec-mode O1/O4 fix, faithfully implemented.
- **The `.gitignore` entry for `diagnostic-legibility/output/`.** Spec-mode O3 implemented and test-pinned; the operational risk is closed.
- **The agent / command `Write` and `mkdir -p` split.** The agent stays read-only and the command (the session-level dispatcher) performs the single write and the directory create — the trust architecture is preserved; not a boundary leak.
- **The listing-version-stays-0.4.0 decision.** Spec-mode O9 adjudicated with git-history precedent; the implementation matches the adjudication exactly.
- **The docs ↔ command consistency on the surfaces both describe.** No drift found between command, how-to, and reference — the inconsistencies reported (O3, O4) are shared by command and docs alike, i.e. faithful implementation of a contract gap, not divergence between artefacts.
- **Keeping `mode: cross-check-only` off `/diagnose` and omitting the raw-YAML appendix.** Settled spec-mode dispositions; honoured.
