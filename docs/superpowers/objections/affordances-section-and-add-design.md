---
spec: docs/superpowers/specs/2026-06-16-affordances-section-and-add-design.md
date: 2026-06-16
mode: spec
diaboli_model: claude-opus-4-8[1m]
objections:
  - id: O1
    category: implementation
    severity: high
    claim: "Idempotency keyed on heading-name matching is undermined by the scanner's order-dependent disambiguation suffixes, so a re-run add can edit the wrong entry or create a duplicate under a shifted name."
    evidence: "spec add behaviour step 6; scanner unique_name() assigns -2/-3 suffixes from lex-sorted scan order; how-to claims stability only against array re-ordering."
    disposition: amend
    disposition_rationale: "Key idempotency on the Permission pattern (the parent spec's 'one affordance per permission pattern' identity + string-equality matching), not the heading name. The heading is the human's label; add matches/edits the entry whose Permission field equals the new entry's pattern."
  - id: O2
    category: specification quality
    severity: high
    claim: "The permission-existence validation says 'some settings file' but the scanner reads only project-level settings, not user-level settings where the parent spec's own examples place MCP permissions."
    evidence: "spec add step 6; parent honeycomb-mcp example uses user-level settings; scanner reads only project settings."
    disposition: amend
    disposition_rationale: "Name the exact files add checks: project .claude/settings.json, .claude/settings.local.json, AND user ~/.claude/settings.json. Reading user-level settings is what makes warn-not-block safe (see O6)."
  - id: O3
    category: specification quality
    severity: high
    claim: "FR3 does not specify how Affordances integrates with harness-init's fixed five-row feature menu, placeholder-marker re-run mechanism, and mandatory four-section validation step."
    evidence: "spec FR3; harness-init.md steps 3, 7, 8."
    disposition: amend
    disposition_rationale: "Specify: add a sixth 'Affordances' feature row, default OFF (opt-in) on first run, additive on re-run; define its placeholder marker; step-8 validation treats Affordances as optional (present iff selected), so a project without it still validates."
  - id: O4
    category: specification quality
    severity: medium
    claim: "FR4 ('count affordances') is underspecified: harness-status presents a fixed template from parsed Status fields, not live section parsing."
    evidence: "spec FR4; harness-status.md steps 2, 5."
    disposition: amend
    disposition_rationale: "Status live-counts '### ' headings under '## Affordances' at status time (no new persisted Status field) and adds an 'Affordances: N declared' line to the summary; omit the line when the section is absent."
  - id: O5
    category: implementation
    severity: medium
    claim: "The proposed Layer 0 test over the static template block exercises no behaviour add performs, giving false confidence about the riskiest paths."
    evidence: "spec Risks; listed assertions cover only static template shape."
    disposition: accept
    disposition_rationale: "Reframe the Risks section honestly: the Layer 0 test validates the TEMPLATE schema only (the static artefact). add's write logic is model-mediated and is NOT covered by it — covered instead by the add validation checkpoint and the manual acceptance scenarios. Do not present the template test as testing add."
  - id: O6
    category: risk
    severity: medium
    claim: "Warn-not-block plus the scanner not reading user-level settings means the common MCP case warns on every legitimate add, eroding a safety signal."
    evidence: "spec add step 6; parent Chained Constraints; scanner read scope."
    disposition: amend
    disposition_rationale: "Resolved by O2 (add reads user-level settings too, cutting the false-positive rate). Keep warn-not-block: an affordance may legitimately precede its grant, and this step does not own the blocking affordance-without-permission constraint (that is step 4)."
  - id: O7
    category: scope
    severity: medium
    claim: "The add step-8 suggestion of a harness-constrain 'chained-constraint hook for steps 4-5' either dead-ends or leaks step 4-5 design into this step."
    evidence: "spec add step 8; Out of scope lists steps 4-5."
    disposition: amend
    disposition_rationale: "Drop the forward-pointing /harness-constrain suggestion from step 3. add ends after the write + validation checkpoint. The chaining suggestion returns in step 4 when the constraints that consume it exist."
  - id: O8
    category: specification quality
    severity: medium
    claim: "The seed step matches against a dated discovery scratch file but does not say which date's file is used when multiple coexist, nor what happens when none exist."
    evidence: "spec add step 1; scanner writes a fresh dated file per run."
    disposition: amend
    disposition_rationale: "Seed from the NEWEST .claude/affordance-discovery-*.md (lexically last, since names are date-stamped). If none exists or no entry matches by Permission, prompt for everything."
  - id: O9
    category: risk
    severity: medium
    claim: "The schema-lock claim conflates the finished template (concrete values) with the TODO-laden draft; the schema acceptance scenario tests the template, not add applied to a real draft."
    evidence: "spec Schema-is-locked; scanner emits TODO placeholders."
    disposition: accept
    disposition_rationale: "Reframe the claim: the scanner output matches only the machine-derivable SUBSET (Mode/Permission), with Identity/Audit trail/Last reviewed as TODO placeholders the human fills. The add validation checkpoint is the guard that the placeholder->filled transform produces a schema-valid entry (no leftover TODO)."
  - id: O10
    category: risk
    severity: low
    claim: "The #205 hook-wrapper gap means a wrapper-named draft seeds a misleading name; the name-correction burden interacts with O1's name-stability problem."
    evidence: "spec Schema-is-locked; scanner header."
    disposition: acknowledge
    disposition_rationale: "Note in the spec that a wrapper-hook draft seeds a wrapper-derived name the human renames at add time. Structurally mitigated by O1 (idempotency keys on Permission, not name), so a later rename does not create a duplicate."
  - id: O11
    category: alternatives
    severity: low
    claim: "The idempotent direct-write into HARNESS.md reintroduces the pattern the parent spec rejected as a Non-Goal without re-stating why add is exempt; the emit-for-paste alternative is not acknowledged."
    evidence: "spec add step 7; parent Non-Goals + Goal 7."
    disposition: amend
    disposition_rationale: "User-confirmed: keep direct write. State the resolution explicitly in the spec: a guided add is human-authored in spirit — the human invokes it and dictates every governance field; the command only transcribes their answers (no autonomous agent authorship). Acknowledge the emit-for-paste alternative and why it was not chosen (UX parity with /harness-constrain)."
  - id: O12
    category: specification quality
    severity: low
    claim: "'Creating the section if it is absent' does not specify the insertion point, producing noisy diffs and interacting badly with init's section-boundary logic."
    evidence: "spec add step 7; harness-init.md step 7."
    disposition: amend
    disposition_rationale: "Insertion rule: when absent, add inserts '## Affordances' after '## Garbage Collection' and before '## Status' (matching the template's section order), so init's heading-to-heading boundary logic stays stable."
---

# Objection record — affordances section + harness-affordance add (spec mode)

Twelve objections (3 high, 6 medium, 3 low); no critical or premise. All
adjudicated 2026-06-16: ten **amend** (fold the fix into the spec), two
**accept/acknowledge** (reframe a claim honestly). O11 (direct-write vs
emit-for-paste) was the one genuine fork and was decided by the user in
favour of direct write, with the human-authored-in-spirit rationale made
explicit. The adjudication is captured in the spec's "Adjudication" section
and drives implementation.

## Explicitly not challenged

- The premise that a scanned draft is a dead end without a promotion path.
- Auto-dating Last-reviewed to today on add (a genuine first review).
- Reusing the parent field schema verbatim rather than re-deriving it.
- The minor version bump 0.53.3 to 0.54.0.
- The Mode/Trigger pairing rule.
- Including docs (explanation + reference + how-to update) in scope.
