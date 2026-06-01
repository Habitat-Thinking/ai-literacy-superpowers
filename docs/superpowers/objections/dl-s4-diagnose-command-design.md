---
spec: docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md
date: 2026-06-01
mode: spec
diaboli_model: claude-opus-4-8[1m]
objections:
  - id: O1
    category: scope
    severity: high
    claim: "/diagnose writes the report file automatically with no human review-before-write step, dropping the disposition gate the model-card precedent it claims to mirror makes load-bearing. The 'human-disposes' architecture the spec invokes (§3.4) is satisfied by the agent being read-only and the command persisting — but the model-card precedent puts a human accept/edit/re-run/abort gate between render and write, and /diagnose removes it."
    evidence: "§2.2: 'The command writes the full report to a file AND prints a summary to the conversation. This mirrors the model-card command's write-then-confirm pattern.' But the model-card command's Flow (model-cards/commands/model-card.md, step 7 'Ask for disposition' — accept/edit/re-run-section/abort) gates the write on a human decision; the file is written only 'On accept (post-validation)' (step 9). /diagnose §4.7→§4.8 goes validation-checkpoint → write with no disposition step. §3.4 claims 'agent-emit + dispatcher-persist + human-disposes' is preserved, but the human's only disposition in /diagnose is post-hoc (reading the printed summary after the file already exists)."
    disposition: accepted
    disposition_rationale: "Accepted. A confirm-before-write gate is added between the validation checkpoint and the file write: the command renders the report, runs the checkpoint, prints the summary, then prompts the human to accept or abort, surfacing the resolved target path. The file is written only on accept; an abort writes nothing. The report is a human-facing artefact, so the human should see the rendered result and dispose of it before it lands on disk, restoring the load-bearing accept/abort step the model-card precedent makes explicit. This disposition also closes O4: the same gate surfaces the resolved path and flags when the write would overwrite an existing file, so there is no silent data loss."
  - id: O2
    category: specification quality
    severity: high
    claim: "§6.9's empty-scope acceptance scenario asserts 'cross_check_status is skipped_asymmetric' for a scope that yields nothing, but the agent contract for the all-empty case never sets that status. The agent emits the (empty scope) sentinel into architectural[] and skips Phase B entirely (agent lines 199-208, 498-515); Phase C's skipped_asymmetric is set only when 'only one collection is populated' (agent lines 309-317). An (empty scope) sentinel element technically makes architectural[] non-empty and domain[] empty, so whether the agent reaches Phase C step 1 at all — and thus whether cross_check_status is skipped_asymmetric, not_run, or unset — is undefined, yet the report's Cross-check status row (§5.1) and summary (§5.2) depend on it."
    evidence: "Spec §6.9 (empty-scope scenario): 'Then the agent returns the (empty scope) sentinel element / And the report renders the single (empty scope) element / And cross_check_status is skipped_asymmetric'. Agent file lines 199-208: when both collections empty, 'emit the (empty scope) sentinel element into architectural[] per §Honesty rules and skip Phase B (the sentinel carries its own pre-populated challenge note)' — Phase B is skipped, and Phase C's status-setting is reached via Phase A→B→C only in mode: full with non-empty collections. Agent Phase C step 1 (lines 309-317) sets skipped_asymmetric for the one-populated-one-empty case. The (empty scope) case is a third state the agent does not map to a cross_check_status value; the report contract assumes it lands on skipped_asymmetric without the agent committing to that."
    disposition: accepted
    disposition_rationale: "Accepted. The empty-scope cross_check_status is made explicit. The both-empty path emits the (empty scope) sentinel into architectural[], which leaves architectural[] nominally populated (one sentinel element) and domain[] empty. Phase C step 1 then sees exactly one nominally-populated collection — the one-populated/one-empty shape — and emits cross_check_status: skipped_asymmetric. The agent's both-empty branch is amended to state this committed value explicitly so the contract is defined rather than inferred, grounding Scenario 6.9's assertion that the report renders skipped_asymmetric for a scope that yields nothing."
  - id: O3
    category: risk
    severity: high
    claim: "The default output path is repo-local and inside the marketplace-synced plugin tree, so generated reports are at risk of being committed to the repo and rsynced into the global plugin cache. The model-card precedent the spec mirrors deliberately defaults out-of-repo (~/.claude/model-cards/...) to avoid exactly this. The spec acknowledges the question (§10.3) but ships the repo-local default as the proposal."
    evidence: "§4.3: 'The default output path: diagnostic-legibility/output/<scope-slug>-legibility-<YYYY-MM-DD>.md'. Compare model-cards/commands/model-card.md step 2: 'Default: ~/.claude/model-cards/<provider>/<model-name>.md' (out-of-repo). CLAUDE.md 'Marketplace Cache Auto-Sync' documents sync-to-global-cache.sh which 'rsyncs plugin content into the versioned plugin cache (runs on every Stop)' — a diagnostic-legibility/output/ directory inside the plugin tree is plugin content by that rule and would be swept into the cache. §10.3 names the concern ('reports are not accidentally committed') but §4.3 ships the repo-local default and no .gitignore entry is named in §7.1/§7.2."
    disposition: accepted
    disposition_rationale: "Accepted. The repo-local default output directory is kept (it keeps reports reviewable in the working tree and matches the slug+date filename convention), but diagnostic-legibility/output/ is added to .gitignore so generated reports are never committed to the repo nor rsynced into the plugin cache. This closes the operational risk the objection names without losing the convenience of a predictable repo-relative default."
  - id: O4
    category: risk
    severity: medium
    claim: "The slug+date filename silently overwrites prior reports when two distinct scopes collapse to the same slug, or the same scope is re-run the same day. The slug derivation (lowercase, non-alphanumeric runs to hyphens, trim) maps ./src/auth/, ./src/auth, and src-auth all to 'src-auth'; combined with the date stamp this is a deterministic same-path collision with no overwrite guard, unlike model-card which prompts on an existing file."
    evidence: "§4.3 slug rule: 'lowercase, non-alphanumeric runs collapsed to single hyphens, leading and trailing hyphens trimmed. ./src/auth/ → src-auth'. §8: 'two runs the same day overwrite.' No collision check is specified in §4.8 (Write the file) — it is bare 'mkdir -p' then 'Write the rendered report to the resolved path'. Compare model-cards/commands/model-card.md step 3: 'Check for existing card at target path / If present, ask the user: overwrite / skip / load-existing-as-base'. /diagnose has no equivalent existence check, so distinct scopes that slug-collide on the same day silently destroy the earlier report."
    disposition: accepted
    disposition_rationale: "Accepted, subsumed by O1. The confirm-before-write gate added for O1 surfaces the resolved target path in the accept/abort prompt and explicitly flags when that path already exists and would be overwritten. The human therefore sees the collision before any write, so a slug-collision or same-day re-run can no longer silently destroy an earlier report; no separate existence-check step is needed beyond what the O1 gate already shows."
  - id: O5
    category: specification quality
    severity: medium
    claim: "The correction-count semantics in §5.2 are ambiguous between 'number of CC<N> entries' and 'number of elements revised'. An element can carry multiple CC<N> entries (CC1 and CC3 both fired on one subject); §5.2 says to count entries, but the human-facing label reads as an element count. The validation checkpoint (§5.5 check 3) only verifies the counts are present, not which semantic they use, so two implementers could ship divergent counts that both pass."
    evidence: "§5.2: 'Correction counts by direction, derived by counting CC<N> entries across elements'. §5.3 rendered label: 'A→D corrections (architectural elements revised by the domain frame): <count>' — 'elements revised' implies an element count, but 'counting CC<N> entries' yields an entry count, which differs whenever any element has more than one CC<N> entry. §5.5 check 3: 'reports both A→D and D→A correction counts' — presence only, no semantic pin. The agent allows multiple CC<N> entries per element (agent lines 337-350 list five distinct CC prefixes, any subset of which may fire on one subject)."
    disposition: accepted
    disposition_rationale: "Accepted. The correction-count semantic is pinned to a single definition: the number of elements in that direction's collection carrying at least one CC<N> entry ('elements revised'), matching the human-facing label rather than a raw entry count. §5.2 and §5.3 are aligned to this one definition, and the validation checkpoint asserts the rendered count matches the count derived from the parsed YAML under this definition, so two implementations can no longer ship divergent numbers that both pass."
  - id: O6
    category: implementation
    severity: medium
    claim: "The §5.5 validation checkpoint reads back and 'fixes in place' a report that the command itself just rendered from the agent's YAML — so the checkpoint and the renderer share the command's own logic, and a rendering error (e.g. a mis-grouped CC entry) is checked by the same component that produced it, with no independent oracle and no human gate. model-card's checkpoint sits before a human accept; /diagnose's sits before an automatic write, making it the last line of defence while being self-referential."
    evidence: "§4.7→§4.8: validation checkpoint then 'Write the file' with no intervening human step. §5.5: 'the command reads the rendered report back and checks its structure against §5 ... Deviations are fixed in place; the agent is not re-dispatched.' The checks (§5.5 1-6) are structural-presence checks the command's own renderer is responsible for satisfying — e.g. check 5 'Notes grouped by prefix and ordered' is exactly what §4.6 rendering does. If the renderer mis-buckets a CC<N> entry, the checkpoint that re-derives buckets the same way will not catch it. CLAUDE.md 'Output Validation Checkpoints' prescribes 'Check structure against the format spec reference' — the spec reference here is §5, authored alongside the renderer, not an independent contract."
    disposition: accepted
    disposition_rationale: "Accepted. The checkpoint's stated scope is narrowed to what it can genuinely verify against the parsed agent YAML: no literal <DISPATCHER: leak, header completeness, both collections rendered, correction counts consistent with the parsed YAML under O5's elements-revised definition, and Q/CC grouping and ordering present. The prior implication that the checkpoint catches renderer mis-bucketing is dropped, since a self-consistent renderer would mis-bucket identically on re-read. §5.5 now records that the human accept gate (O1) — not the checkpoint — is the genuine last line of defence before write."
  - id: O7
    category: specification quality
    severity: medium
    claim: "The side-by-side geometry is left genuinely undecided (§5.3, §10.1): the spec permits either a two-column table or adjacent ### Architectural / ### Domain subsections, and the structural tests assert only that 'both collections appear' and 'Q/CC grouping is present'. Two implementers will ship structurally different reports that both pass the tests, and the 'side-by-side' contract in the user story (§6.1) and Scenario 4 is not pinned to either geometry."
    evidence: "§5.3: 'A side-by-side table is the canonical form ... the implementation MAY instead render the side-by-side as two adjacent ### Architectural / ### Domain subsections ... The structural tests (§6) assert that both collections appear and that the Q/CC grouping is present, not a specific HTML/table geometry.' §10.1 flags this as 'the most likely diaboli target'. Scenario 4 (§6, lines 507-515): 'Then it documents a side-by-side report of architectural vs domain models' — 'side-by-side' is asserted as the contract but §5.3 admits adjacent subsections (stacked, not side-by-side) as a legal rendering, so the word 'side-by-side' in the user-facing contract does not constrain the artefact."
    disposition: accepted
    disposition_rationale: "Accepted. The report geometry is pinned: a compact two-column cross-check summary table near the top (the genuine at-a-glance side-by-side), followed by the model bodies as two stacked ### Architectural model / ### Domain model subsections, each element grouping its Q<N> then CC<N> notes in canonical order. 'Side-by-side' is reserved for the summary table; the report body is described as stacked, so the contract word now matches the artefact rather than admitting two divergent legal renderings. Scenario 4 and §5.3/§6 are updated so the structural tests assert the summary table is present (both columns), both model subsections are present, and the Q/CC grouping and ordering are present."
  - id: O8
    category: alternatives
    severity: medium
    claim: "The embedded raw-YAML appendix (§5.4) is proposed default-on to make the report round-trippable into mode: cross-check-only, but no consumer for that round-trip is named in S4 — §3.3 and §8 explicitly keep cross-check-only off /diagnose and name no caller. A default-off (or omitted) appendix is the simpler alternative; embedding the YAML by default adds a second copy of the model whose only justification is a round-trip the spec scopes out."
    evidence: "§5.4: 'the default proposal is to include it as a collapsible appendix, because it makes the report round-trippable and costs little.' §3.3: 'mode: cross-check-only surface (S3 §2.4) ... is not exposed through /diagnose at v0.5.0.' §8: 'A /diagnose --from <yaml-file> re-render mode could be added later ... but no consumer is named for it now.' So the round-trip the appendix enables has no S4 consumer; §10.2 itself raises the drift counter-argument ('does embedding the YAML duplicate the report and invite drift'). The cheaper default is to omit it until a round-trip consumer exists, mirroring the spec's own §8 'no consumer is named' reasoning for cross-check-only."
    disposition: accepted
    disposition_rationale: "Accepted. The embedded raw-YAML appendix is flipped to default-off and omitted from the report. S4 names no consumer for the round-trip it would enable (cross-check-only stays off /diagnose), so embedding a second copy of the model only invites prose/YAML drift for no current benefit. The default-on proposal is removed from §5.4; the appendix can be revisited if a --from / re-render consumer is ever added."
  - id: O9
    category: specification quality
    severity: medium
    claim: "Whether the marketplace entry's description rewrite forces a top-level listing version bump is left to the gate (§9, §10.4), but CLAUDE.md's Marketplace Versioning rule is unambiguous that a description change is a listing-contract change requiring a version bump — and Scenario 7 asserts the top-level version is unchanged. The spec ships a test (Scenario 7) that may directly contradict the stated convention, and the CI version-consistency gate's behaviour on that contradiction is not analysed."
    evidence: "§7.2 (marketplace.json row): 'Update the entry's description to replace ... Top-level version and plugin_version per §9.' §9: 'the top-level version stays unchanged unless the diaboli gate decides the entry's description rewrite counts as a metadata change'. CLAUDE.md Marketplace Versioning: 'Bump when the listing contract itself changes: - Description, keywords, or owner metadata change'. Scenario 7 (§6, line 552): 'And the marketplace top-level version is unchanged (per §9)' — asserted as a test while §9 admits the convention may require the opposite. The two are in tension and the spec defers rather than resolving, leaving a structural test that may encode a convention violation."
    disposition: accepted
    disposition_rationale: "Accepted, resolved by git-history precedent. The per-plugin entry description IS rewritten for S4, as every prior slice did: the false trailing sentence 'Human-facing /diagnose command lands in a later slice.' is removed and replaced with one terse clause stating the /diagnose command surfaces the mutually-corrected models on demand, matching the existing description's style. The diagnostic-legibility entry version bumps 0.4.0 -> 0.5.0 (required by the CI per-plugin sync: plugin.json version == plugins[] entry version). The top-level listing version STAYS 0.4.0. This is the established, precedent-backed contract: the top-level marketplace version has been 0.4.0 across S1, S2a, S2b, and S3 and has never bumped per slice, yet S3 (commit b7c19ea) rewrote the diagnostic-legibility entry description substantially AND bumped the entry version 0.3.0 -> 0.4.0 with the top-level version staying 0.4.0. The CI version-consistency job enforces only that each plugin's plugin.json version equals its plugins[] entry version; it does NOT check the top-level version. The standing reading therefore is: a per-plugin entry's description is part of that plugin's own contract (tracked by the entry version), not the top-level listing contract — so rewriting it each slice to reflect new capability is the normal pattern and does NOT bump the top-level listing version. This is the standing exception to CLAUDE.md's 'description change -> bump listing version' rule that the diaboli flagged: that rule applies to the top-level listing description/metadata, not to a per-plugin entry's description. Stated explicitly here so the next slice does not re-litigate it. Scenario 7's assertion that the top-level marketplace version is unchanged is therefore CORRECT and stays."
  - id: O10
    category: scope
    severity: low
    claim: "S4 closes parent #327 ('build the agent, then surface it on demand') but the slicing record's S4 decision_focus names 'whether they are cacheable' as in-scope for this decision, and §8 scopes caching out. The slice's own framing put cacheability inside the surfacing decision; the spec defers it, so the slice closes the parent with a named sub-decision of its decision_focus left unaddressed."
    evidence: "Slicing record (docs/superpowers/slices/diagnostic-legibility-plugin.md, S4 decision_focus, lines 86-88): 'This decision defines the output format and command signature, which affects how the results are consumed and whether they are cacheable.' §8: 'Caching/memoisation of reports across runs. The command is stateless and re-runs the pipeline each invocation ... A content-hash cache is a future optimisation, not an S4 decision.' §1: 'When it ships, the parent task ... is complete, and parent issue #327 closes.' Cacheability was named as part of S4's decision_focus but is scoped out, so the parent closes with that thread deferred rather than decided."
    disposition: accepted
    disposition_rationale: "Accepted. The spec adds one sentence at parent #327 closure (§1 and §8) recording that cacheability — named in S4's decision_focus — is deliberately deferred, not decided: stateless re-run is the v0.5.0 default and a content-hash cache is future work. This keeps the parent-closing claim honest about the one decision_focus thread that S4 chose not to resolve."
  - id: O11
    category: risk
    severity: low
    claim: "--out takes an arbitrary human-supplied directory that the command mkdir -p's and writes into, with no stated constraint (no repo-root containment, no rejection of absolute or traversal paths). At spec time this is a low-grounded note, but the command is the only Write-capable component in the pipeline and the spec gives its single write target a fully unconstrained directory input."
    evidence: "§3.2 (--out row): 'Output directory override. The report filename (§4.3) still applies beneath whatever directory is resolved.' §4.8: '1. mkdir -p the resolved output directory. 2. Write the rendered report to the resolved path.' No validation of <dir> is specified in §4.1 ('--out <dir> — optional directory override') beyond it being optional. The model-card --out precedent (model-cards/commands/model-card.md step 2) has the same unconstrained shape, so this is an inherited pattern rather than a new exposure — hence low."
    disposition: deferred
    disposition_rationale: "Deferred (not absorbed). --out is an inherited model-card pattern with low grounding: the operator supplies the path themselves, and the O1 confirm-before-write gate now surfaces the resolved path before any write, so an unintended directory is visible before it is committed. A repo-containment or traversal constraint can be revisited if one is ever wanted, but no constraint is added to the S4 spec now."
---

# Adversarial Review — dl-s4-diagnose-command-design (spec mode)

Spec under review: `docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md`. Mode: `spec`. Reviewer: `claude-opus-4-8[1m]`. Eleven objections raised: 3 high (O1–O3), 6 medium (O4–O9), 2 low (O10–O11).

Distribution across categories: 2 scope, 4 specification quality, 1 alternatives, 3 risk, 1 implementation, 0 premise. (Premise was examined and not challenged — see closing section; the surfacing need is well-established by the slicing record and the prior shipped slices.)

The spec is competently structured and faithful to its `model-card` precedent on the surfaces it copies. Its weaknesses cluster in two places. First, **the command silently diverges from the precedent on the load-bearing parts** — the human disposition gate before write (O1) and the existing-file overwrite check (O4) are exactly the two places where `model-card` protects the human, and `/diagnose` drops both while claiming to mirror the pattern. Second, **the report contract leans on agent behaviour the agent does not actually commit to**: the empty-scope `cross_check_status` value (O2) and the correction-count semantics (O5) are asserted by the report spec but not pinned by the agent file. The repo-local default output directory (O3) is a genuine operational risk the spec names but ships anyway. The four §10 open questions are real and three of them (O3, O7, O8) survive as honest objections rather than being adequately pre-resolved; the fourth (O9, listing bump) is a convention tension the spec defers in a way that may encode a test contradicting CLAUDE.md.

None of these block shipping the one-shot-report contract. They are debts the spec should pay before merge or name as revisitable.

## O1 — scope — high

### Claim

`/diagnose` writes the report file automatically after the validation checkpoint, with no human review-before-write step. The spec invokes the project's "agent-emit + dispatcher-persist + human-disposes" architecture and claims to mirror `model-card`'s write-then-confirm pattern, but `model-card`'s pattern puts a human accept/edit/re-run/abort gate *between* render and write. `/diagnose` removes that gate: the human's only disposition is reading a summary after the file already exists.

### Evidence

§2.2: "The command writes the full report to a file AND prints a summary to the conversation. This mirrors the model-card command's write-then-confirm pattern." But `model-cards/commands/model-card.md` step 7 ("Ask for disposition" — accept/edit/re-run-section/abort) gates the write, and step 9 writes "On accept (post-validation)". `/diagnose`'s Flow goes §4.7 validation checkpoint → §4.8 write with no disposition step between. §3.4 claims the "human-disposes" architecture is preserved.

### Why this matters

If the surfacing goal is "aid human understanding" and the report can contain agent errors (mis-grouped notes, mis-derived counts), an automatic write commits a possibly-wrong artefact before the human sees it. The spec borrows `model-card`'s authority ("mirrors the model-card pattern") for a contract that is materially different on the one step that protects the human. Either the divergence is deliberate (one-shot is the point) and should be stated as a conscious departure from the precedent, or the human gate should be added.

## O2 — specification quality — high

### Claim

§6.9's empty-scope acceptance scenario asserts the report shows `cross_check_status: skipped_asymmetric`, but the agent contract never commits the all-empty `(empty scope)` case to that status. The agent emits the sentinel into `architectural[]` and skips Phase B; Phase C's `skipped_asymmetric` is defined for the one-populated/one-empty case. Which status the `(empty scope)` case carries is undefined, yet the report header and summary depend on it.

### Evidence

Spec §6.9: "Then the agent returns the (empty scope) sentinel element ... And cross_check_status is skipped_asymmetric". Agent file lines 199-208: when both collections are empty, "emit the (empty scope) sentinel element into architectural[] ... and skip Phase B". Agent Phase C step 1 (lines 309-317) sets `skipped_asymmetric` when "only one collection is populated". The `(empty scope)` sentinel makes `architectural[]` contain one element and `domain[]` empty — whether the agent treats this as "one populated" (→ `skipped_asymmetric`) or as the all-empty short-circuit that skips Phase B before any status is set is not stated in either document.

### Why this matters

The report's Cross-check status row (§5.1) and summary (§5.2) render whatever the agent emits. If the agent emits no `cross_check_status` (or `not_run`) for the empty-scope case while the spec's test asserts `skipped_asymmetric`, the structural/acceptance scenario will be written against a value the implementation does not produce — a divergent-implementation trap that surfaces precisely on the degenerate input the empty-scope handling exists to make safe.

## O3 — risk — high

### Claim

The default output directory is repo-local and inside the marketplace-synced plugin tree, exposing generated reports to accidental commit and to being rsynced into the global plugin cache. The `model-card` precedent the spec otherwise mirrors deliberately defaults out-of-repo. The spec names the concern in §10.3 but ships the repo-local default as its proposal, with no `.gitignore` entry in the file list.

### Evidence

§4.3: "The default output path: diagnostic-legibility/output/<scope-slug>-legibility-<YYYY-MM-DD>.md". `model-cards/commands/model-card.md` step 2: "Default: ~/.claude/model-cards/<provider>/<model-name>.md" (out-of-repo). CLAUDE.md "Marketplace Cache Auto-Sync": `sync-to-global-cache.sh` "rsyncs plugin content into the versioned plugin cache (runs on every Stop)" — `diagnostic-legibility/output/` is plugin content by that rule. §10.3 raises the concern but §4.3 ships the repo-local default; §7.1/§7.2 add no `.gitignore` entry for `output/`.

### Why this matters

Every `/diagnose` run drops a markdown file into the plugin's own tree. A developer who runs the command and then commits will sweep reports into the repo and into the synced cache, polluting both. The spec's counter-argument ("repo-local makes reports reviewable in a PR") is weak — reports are derived artefacts, not source, and the precedent already solved this by defaulting outside the repo.

## O4 — risk — medium

### Claim

The `<scope-slug>-legibility-<date>.md` filename silently overwrites a prior report whenever two distinct scopes collapse to the same slug, or the same scope is re-run the same day. There is no existence check before write, unlike the precedent which prompts the user.

### Evidence

§4.3 slug rule collapses non-alphanumeric runs and trims, so `./src/auth/`, `./src/auth`, and `src-auth` all map to `src-auth`. §8: "two runs the same day overwrite." §4.8 is bare "mkdir -p" then "Write the rendered report to the resolved path" — no collision check. `model-cards/commands/model-card.md` step 3: "Check for existing card at target path / If present, ask the user: overwrite / skip / load-existing-as-base".

### Why this matters

Distinct scopes that slug-collide on the same day destroy the earlier report with no warning. The collision is deterministic, not probabilistic, so it is reproducible data loss. The precedent's existence check would close this; the spec drops it alongside the disposition gate (O1).

## O5 — specification quality — medium

### Claim

The correction-count semantics in §5.2 are ambiguous between counting `CC<N>` entries and counting elements revised. An element can carry multiple `CC<N>` entries; "counting CC<N> entries" yields a different number from "elements revised", but the rendered label reads as the latter. The checkpoint verifies only that counts are present, so divergent implementations both pass.

### Evidence

§5.2: "Correction counts by direction, derived by counting CC<N> entries across elements". §5.3 label: "A→D corrections (architectural elements revised by the domain frame): <count>". The agent permits multiple CC prefixes per subject element (agent lines 337-350). §5.5 check 3 verifies presence only.

### Why this matters

The cross-check summary is the headline number a human reads to judge how much mutual correction happened. If one implementation reports entry-counts and another element-counts, the same model yields different summaries, and the "corrections" figure the human trusts is undefined.

## O6 — implementation — medium

### Claim

The §5.5 validation checkpoint reads back and "fixes in place" a report the command itself rendered, using the same logic that rendered it — a self-referential check with no independent oracle and (unlike the precedent) no human gate behind it. A rendering error is checked by the component that produced it.

### Evidence

§4.7→§4.8: checkpoint then write, no human step. §5.5: "the command reads the rendered report back and checks its structure against §5 ... Deviations are fixed in place; the agent is not re-dispatched." Check 5 ("Notes grouped by prefix and ordered") re-derives exactly what §4.6 rendering produced. CLAUDE.md "Output Validation Checkpoints" prescribes checking "against the format spec reference" — here §5, authored alongside the renderer.

### Why this matters

The checkpoint is positioned as the last line of defence before an automatic write (O1), but a self-consistent renderer that mis-buckets a note will mis-bucket it identically on re-read. The genuinely catchable deviations are narrow (unsubstituted `<DISPATCHER:`, count mismatches against the parsed YAML); the prose frames the checkpoint as broader assurance than its self-referential structure delivers.

## O7 — specification quality — medium

### Claim

The side-by-side geometry is genuinely undecided: §5.3 permits either a two-column table or stacked adjacent subsections, and the tests assert only that both collections appear and notes are grouped. The user-facing "side-by-side" contract is not pinned to either geometry, so two implementers ship structurally different reports that both pass.

### Evidence

§5.3: "the implementation MAY instead render the side-by-side as two adjacent ### Architectural / ### Domain subsections ... The structural tests (§6) assert that both collections appear and that the Q/CC grouping is present, not a specific HTML/table geometry." §10.1 calls this "the most likely diaboli target." Scenario 4 asserts "a side-by-side report" while §5.3 admits stacked subsections (not side-by-side) as legal.

### Why this matters

"Side-by-side" is the word the user story sells, but the spec admits a stacked rendering that is not side-by-side and still passes. The load-bearing claim ("both models visible, notes grouped") is sound, but shipping "side-by-side" in the contract while permitting non-side-by-side output means the contract word and the artefact can diverge. Either pin the geometry or stop calling it side-by-side.

## O8 — alternatives — medium

### Claim

The embedded raw-YAML appendix is proposed default-on to enable a `mode: cross-check-only` round-trip, but S4 names no consumer for that round-trip and explicitly keeps `cross-check-only` off `/diagnose`. The simpler alternative — omit the appendix until a round-trip consumer exists — mirrors the spec's own reasoning for deferring `cross-check-only`.

### Evidence

§5.4: "the default proposal is to include it ... because it makes the report round-trippable and costs little." §3.3 keeps `cross-check-only` off `/diagnose` at v0.5.0; §8: "no consumer is named for it now." §10.2 raises the drift counter-argument itself.

### Why this matters

Default-on embedding ships a second copy of the model into every report to serve a round-trip with no caller, and (per §10.2) invites prose/YAML drift. The spec's own "no consumer is named" logic, applied consistently, argues for default-off until the round-trip is real.

## O9 — specification quality — medium

### Claim

Whether the marketplace description rewrite forces a top-level listing version bump is deferred to the gate, but CLAUDE.md states unambiguously that a description change is a listing-contract change requiring a bump. Scenario 7 asserts the top-level version is unchanged — encoding as a test a position that may contradict the convention. The CI version-consistency interaction is not analysed.

### Evidence

§7.2 changes the entry `description`; §9 leaves the top-level `version` "unchanged unless the diaboli gate decides". CLAUDE.md Marketplace Versioning: "Bump when the listing contract itself changes: - Description, keywords, or owner metadata change". Scenario 7 (line 552): "And the marketplace top-level version is unchanged (per §9)".

### Why this matters

The spec defers a question its own referenced convention already answers, and ships a structural test asserting the deferred-to outcome. If the convention is taken at face value, the test encodes a violation; if the convention has an unstated exception for per-plugin description touches, that exception should be written down, not left to the gate.

## O10 — scope — low

### Claim

S4 closes parent #327, but the slicing record's S4 `decision_focus` named cacheability as part of this decision, and §8 scopes caching out. The slice closes the parent with a named sub-thread of its own decision focus deferred rather than decided.

### Evidence

Slicing record S4 `decision_focus` (lines 86-88): "whether they are cacheable." §8: "Caching/memoisation of reports across runs ... a future optimisation, not an S4 decision." §1: "the parent task ... is complete, and parent issue #327 closes."

### Why this matters

Closing the parent issue signals the decision focus is fully resolved; deferring a thread the decision focus explicitly named leaves a small gap between "what the slice was scoped to decide" and "what it decided." Low because the deferral is reasonable and stateless re-run is a defensible default — but the closure claim should acknowledge cacheability is deferred, not decided.

## O11 — risk — low

### Claim

`--out` accepts an arbitrary human-supplied directory that the command `mkdir -p`'s and writes into, with no stated containment or traversal constraint. The command is the only Write-capable component in the pipeline, and its single write target takes an unconstrained directory input.

### Evidence

§3.2 (--out): "Output directory override ... beneath whatever directory is resolved." §4.8: "mkdir -p the resolved output directory. ... Write the rendered report to the resolved path." §4.1 adds no validation. The `model-card --out` precedent (step 2) has the same unconstrained shape.

### Why this matters

Low because this is an inherited pattern and the operator supplies the path themselves. Noted so the gate can decide whether the only Write surface in an otherwise read-only pipeline deserves a containment constraint that the precedent never added.

## Explicitly not objecting to

- **The premise (surfacing is needed).** The slicing record, the parent task's stated "aid human understanding" purpose, and the four shipped prior slices establish the need for a human-facing surface beyond raw YAML; the why is sound and was not challenged.
- **`mode: full` as the only dispatch mode (§3.3).** Choosing `mode: full` on the human's behalf and keeping `cross-check-only` off the command is well-justified and consistent with S3's anticipation; the simplest correct choice, not worth contesting.
- **Keeping the agent and schema unchanged (§7.4, §8).** S4 as a pure surfacing slice that consumes the agent as-is is the right boundary; touching the agent would re-open S3 decisions for no S4 benefit.
- **The refusal pass-through contract (§4.5).** Surfacing `diagnostic-legibility refusal:` verbatim and aborting with no write directly mirrors both the agent's refusal contract and `model-card` step 5; correct and unambiguous.
- **The minor version bump 0.4.0 → 0.5.0 (§9).** A new command is a behavioural addition; the minor bump and the plugin.json/README/CHANGELOG triplet follow CLAUDE.md Semantic Versioning exactly (the *listing-level* bump question is a separate matter, raised as O9).
- **Deferring invocation persistence / observability (§8, §10.5).** Keeping S4 a single-report surfacing slice and leaving the Phase-C-escalation corpus to a later decision is a clean scope line; folding it in would bloat the slice. This is decision-archaeology (a recorded choice with no failure shape), so it routes to the Cartographer, not here.
