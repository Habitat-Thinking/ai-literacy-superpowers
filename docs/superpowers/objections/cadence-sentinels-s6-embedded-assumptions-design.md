---
spec: docs/superpowers/specs/2026-08-13-cadence-sentinels-s6-embedded-assumptions-design.md
date: 2026-08-13
mode: spec
diaboli_model: claude-opus-5[1m]
objections:
  - id: O1
    category: premise
    severity: high
    claim: "The load-bearing premise — that all six categories interrogate the spec rather than the artefact — is false of the shipped charter at code time, where `risk` is explicitly directed at evidence from the implementation, and the spec concedes the contradiction two paragraphs later."
    evidence: "SKILL.md Dispatch Modes, Code-time: 'risk: code time is when threat-model, failure-mode, and operational concerns become groundable with specific evidence from the implementation — API surface exposures, error path gaps, resource-management failures, and operational blind spots.' Section 1 asserts 'All six interrogate what the spec says or fails to say'; section 2.2 then says 'Both could hold the finding'."
    disposition: pending
    disposition_rationale: null
  - id: O2
    category: alternatives
    severity: high
    claim: "The materially cheaper alternative — adding the four sub-kinds as a named hunt-list under the existing code-time weighting for `risk` and `implementation` — delivers the spec's own stated requirement without a taxonomy change, a checker change, or a six-to-seven edit across sixteen surfaces, and the spec's rejection argues against silent folding rather than against this."
    evidence: "Section 2.2 rejects fold-in because 'neither risk nor implementation instructs anyone to hunt for what the artefact assumes silently'. But SKILL.md's code-time weighting already carries exactly such a hunt-list for risk — 'API surface exposures, error path gaps, resource-management failures, and operational blind spots' — which is the mechanism the spec says does not exist."
    disposition: pending
    disposition_rationale: null
  - id: O3
    category: specification quality
    severity: high
    claim: "The spec never says what a pending embedded-assumptions objection looks like on emission, and both readings break something: a pre-filled null fails the checker's own remedy validation, while omitting the key forces the human to insert a new YAML key rather than substitute a value."
    evidence: "Section 4 makes CANONICAL_REMEDIES 'validated only where present', and null is not among the four values in the section 3.2 table. The established convention for human-filled fields is pre-filled null — SKILL.md's schema emits `disposition_rationale: null`, and orchestrator.agent.md step 2 validates 'disposition: pending, disposition_rationale: null'. E4 and E6 pass under either reading."
    disposition: pending
    disposition_rationale: null
  - id: O4
    category: scope
    severity: high
    claim: "The six-category vocabulary is enumerated verbatim in the HARNESS.md constraint body and mirrored into three assistant convention files, none of which the Files table lists — and check-convention-parity.py matches headings only, so the resulting divergence between the stated constraint and its enforcement is invisible to every deterministic gate."
    evidence: "HARNESS.md:399-402 lists the six categories in the rule body, mirrored at .cursor/rules/constraints.mdc:187, .windsurf/rules/constraints.md:181 and .github/copilot-instructions.md:148. check-convention-parity.py matches constraint HEADINGS only, with no body comparison. The Files table also hedges 'if duplicated there'; it is, and .github/prompts/diaboli.prompt.md is absent from the table entirely."
    disposition: pending
    disposition_rationale: null
  - id: O5
    category: implementation
    severity: high
    claim: "The new docs/superpowers/objections/README.md lands inside a directory that two shipped consumers glob as every objection record, and the harness snapshot will count it as a spec-mode record with slug README, skewing four published metrics."
    evidence: "check-objection-taxonomy.py globs 'docs/superpowers/objections/*.md' and reports len() as the record count. snapshot-format.md:176 counts all such files 'excluding .gitkeep'; :169 defines a spec-mode record as matching <slug>.md; :181-184 derive Spec-mode records present, Fully-resolved rate and Mean objections per record from that set. S1's record-paths.sh already special-cases README.md by name and the spec does not apply the precedent."
    disposition: pending
    disposition_rationale: null
  - id: O6
    category: specification quality
    severity: medium
    claim: "E7 pins the literal '45 committed records' as its regression baseline, and that number is stale before the slice can merge — this objection record is the 46th, and the new README would make the glob match 47."
    evidence: "Section 7.1: 'E7 — the 45 committed records pass unchanged.' Exactly 45 records exist today. AGENTS.md: harness artefacts 'derive from the source of truth — they do not pin a copy of it', failure shape (1) 'A pinned literal goes stale on a legitimate change'. S5's O9 filed #507 on this exact pattern."
    disposition: pending
    disposition_rationale: null
  - id: O7
    category: specification quality
    severity: medium
    claim: "The spec's second supporting argument misquotes the Routing Rule: the shipped test partitions findings between three agents, not lenses between categories, and the restated version proves nothing because it is satisfied by any category whatsoever."
    evidence: "SKILL.md: 'A finding belongs in your objection record iff: removing it would leave a class of failures undetected' — a three-way partition between diaboli, Cartographer and Convener. Section 2.2 restates it as 'a finding belongs to a category iff removing that category would leave a class of findings unsurfaced', which is true by construction of any named category."
    disposition: pending
    disposition_rationale: null
  - id: O8
    category: scope
    severity: medium
    claim: "Two of the four sub-kinds characteristically produce findings the shipped Convener tie-break assigns to the Convener, and the spec adds a seventh category to a declared three-way partition without re-deriving that partition or giving a worked routing example."
    evidence: "SKILL.md: 'A finding about a person who should be asked is the Convener's even when it also names a failure class, because the remedy is a conversation rather than a change to the artefact', and 'the three agents together form a complete partition'. The usability/accessibility and environmental sub-kinds are the paradigm cases where the remedy is asking someone. S5 shipped 2026-08-12; the non-goals do not mention the Convener."
    disposition: pending
    disposition_rationale: null
  - id: O9
    category: premise
    severity: medium
    claim: "The Choice Cartographer's defaults lens already surfaces the class the problem statement describes, in almost the spec's own words, and the accept-as-stated remedy restates the Cartographer's stated purpose — so the gap is narrower than the spec claims and the spec never mentions the nearest existing home."
    evidence: "choice-cartographer/SKILL.md defaults lens: 'An inherited default is a decision the team did not make but now owns. Naming the default's source is the cheapest cognitive-debt payment available.' Section 1: 'defaults that arrived with the code and were never noticed'. Section 3.2 accept-as-stated: 'Write it down so the next reader inherits a decision rather than a default.' The Cartographer is spec-mode-only pending #209."
    disposition: pending
    disposition_rationale: null
  - id: O10
    category: risk
    severity: medium
    claim: "Rule 3 makes remedy populated, not honoured: revise-spec and add-test name work that nothing tracks to completion, and the merge gate reads only disposition — so the predictable steady state is consciously-carry as the zero-friction default, which the spec pre-blesses against being read as lesser."
    evidence: "Section 4: 'Rule 3 is what stops the field decaying into decoration.' The gate it rides on resolves dispositions only. No check, GC rule, or snapshot field observes whether a revise-spec or add-test remedy happened; snapshot-format.md computes a disposition distribution and knows nothing about remedies. The spec names the decay failure mode itself, clearing the spec-time grounding bar."
    disposition: pending
    disposition_rationale: null
  - id: O11
    category: specification quality
    severity: medium
    claim: "The Files table instructs the implementer to update a reference page that does not exist, while marking only the objections README as new — and creating both would put the objection schema in three places at once."
    evidence: "The table lists docs/.../reference/objection-record-format.md unmarked, beside the README marked new. The reference directory contains consultation-record-format.md and parking-record-format.md but no objection-record-format.md. The schema's only current home is SKILL.md's Output Format section. 'the two dispositions' in the README row does not parse — disposition has four values and remedy has four."
    disposition: pending
    disposition_rationale: null
  - id: O12
    category: specification quality
    severity: medium
    claim: "The additivity argument covers one of the three checker changes: rule 3 is a new error condition, not a set addition, and 'all 45 existing records stay valid by construction' holds only because no existing record happens to use the new category — a contingent fact, not construction."
    evidence: "Section 4 lists three changes; section 4.1 defends only the first. Rule 3 — 'an embedded-assumptions objection with a non-pending disposition and no remedy is an error' — is a tightening, and monotonicity says nothing about it. As written the paragraph licenses 'we only added things, so nothing can break' for a change that also tightens a rule."
    disposition: pending
    disposition_rationale: null
---
# Objection record — Cadence Sentinels S6: Embedded Assumptions (spec mode)

Twelve objections: no critical, five high, seven medium.

**The premise is the finding.** Section 1 rests on the claim that all six
categories interrogate what the spec says. Verified against the shipped
charter, that is false at code time: `risk` is already directed at "specific
evidence from the implementation — API surface exposures, error path gaps,
resource-management failures, and operational blind spots." Section 2.2
concedes it two paragraphs later ("Both could *hold* the finding"), which
leaves the spec resting entirely on the weaker attention-direction argument
(O1).

And that argument is contested by the mechanism it denies exists. Section 2.2
rejects fold-in because "neither `risk` nor `implementation` instructs anyone
to hunt for what the artefact assumes silently" — but the code-time weighting
**is** such a hunt-list, and appending four items to it is a one-paragraph edit
to one file, against a specified approach touching sixteen surfaces (O2).

**Four surfaces the Files table missed**, all verified: the HARNESS.md
constraint *body* and its three convention-file mirrors enumerate the six
verbatim, and `check-convention-parity.py` compares headings only — so this
divergence is invisible to every deterministic gate (O4). A `README.md` in
`docs/superpowers/objections/` is counted by the harness snapshot as a
spec-mode record named `README`, skewing four published metrics, when S1's own
`record-paths.sh` already special-cases exactly that filename (O5).
`objection-record-format.md` does not exist though the Files table lists it as
a page to update (O11). And `.github/prompts/diaboli.prompt.md` is absent
entirely.

**The pinned literal, for the third time in one epic.** E7 asserts "the 45
committed records pass unchanged". This record makes it 46. The promoted
`ARCH_DECISION` at `AGENTS.md:481` has now caught this pattern in the S7
structural test, twice in the README count badges, in the sentinel rosters
(#507), and here (O6).

## Explicitly not objecting to

- **Skipping the dated cutover.** Verified and correct: the 2026-04-19 date
  exists because that migration *retired* vocabulary. This one retires nothing,
  and a second date constant guarding nothing would be the
  live-looking-but-dead mechanism section 4.1 itself warns against. O12 objects
  to the argument's coverage, not its conclusion.
- **`remedy` as a new field rather than a widened `disposition`.** Section 3.3
  is sound and understated — widening would also break `snapshot-format.md`'s
  disposition-distribution metric, a fourth consumer section 3.1 does not
  count.
- **`consciously-carry` as a complete answer.** The best idea in the spec, and
  consistent with S5's O4 disposition on honest reasons.
- **The four sub-kinds as prompts rather than schema.** A required enum would
  be a fifth thing to fill in and police, on categories with fuzzy edges.
- **Component counts.** Verified: 41 skills, 20 agents, 32 commands.
- **Contradicting issue #496's cutover note in writing, with reasoning.** That
  is the behaviour this pipeline wants.
