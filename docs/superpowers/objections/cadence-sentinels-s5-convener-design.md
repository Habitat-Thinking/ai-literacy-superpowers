---
spec: docs/superpowers/specs/2026-08-12-cadence-sentinels-s5-convener-design.md
date: 2026-08-12
mode: spec
diaboli_model: claude-opus-5[1m]
objections:
  - id: O1
    category: implementation
    severity: critical
    claim: "The merge-time check cannot be built on S1's shipped query surface — dispositions exist only inside .resolved.md files, which records_open excludes by name, so V4 is unreachable and V5's 'its successor is checked' contradicts the only S1 code artefact over consultation records."
    evidence: "record-paths.sh excludes README.md, *.resumed.md, *.superseded.md and *.resolved.md from records_open. Verified. Since disposing voices writes a .resolved.md, that is the only place a non-pending disposition ever exists — so a spec with a resolved record yields an empty set and passes vacuously."
    disposition: accepted
    disposition_rationale: "records_latest is added to S1's record-paths.sh, carved as its own commit with its own scenarios, exactly as the registry_list repair was in S4. S1 built the query for 'what is still open' and never needed 'what is the current state of this record'; that is a genuine gap in the substrate rather than a consumer's special case, and every future consumer gets both queries. Re-deriving the walk inside the check would have been the second place in the repo that knows what .resolved.md means, which is the duplication S1's library exists to prevent."
  - id: O2
    category: specification quality
    severity: high
    claim: "Section 9.1's 'deterministic even though its enforcement is agent-mediated' does not resolve to a shippable artefact: section 7's file table lists no matcher for test-convene-check.sh to exercise, and if a matcher does ship then 'No deterministic enforcement' and the progressive-hardening argument are both false."
    evidence: "Every Layer 0 test in this epic asserts its subject is an executable file. check-objection-taxonomy.py is a matcher over records and its HARNESS entry reads Enforcement: deterministic. And 'agent-verified' is not a value of the enum — harness-md-format.md gives deterministic, agent, unverified."
    disposition: accepted
    disposition_rationale: "A matcher ships, and the constraint declares Enforcement: deterministic — which is what it is. Calling an LLM applying a rule 'deterministic' because the rule could be matched deterministically is exactly the overclaim this epic keeps catching, and 'agent-verified' was not even a value of the enum. Section 4.1's progressive-hardening argument is corrected rather than defended: the rung is deterministic, the reach is complete-if-present, and those are different axes. A harness that declares an enforcement it does not have is the drift the harness-auditor exists to find."
  - id: O3
    category: scope
    severity: high
    claim: "Section 3 inserts the Convener into the orchestrator pipeline but section 7 does not list orchestrator.agent.md, and 'No requirement to convene' contradicts a pipeline step — leaving it undecided whether the pipeline changes at all."
    evidence: "orchestrator.agent.md gives the cartographer a numbered step 1b, a named SOFT GATE, and a structured cartograph_pending_count field that observability tooling reads. None of that transfers by implication, and no sentinel since S1 has claimed a pipeline position."
    disposition: accepted
    disposition_rationale: "Wired properly: an orchestrator step, a named soft gate, and a structured convene_pending_count, mirroring step 1b. Section 1's argument is that this failure is invisible from inside — so the people who need the Convener are precisely the people who will not think to run it, and a manual-only command does not address the thing the slice exists for. The non-goal is narrowed to what it meant: the pipeline surfaces it, and a plan may still be approved with every voice pending."
  - id: O4
    category: risk
    severity: high
    claim: "The gate as designed converts a detectable failure into an undetectable one: pending fails the check, but N voices bulk-filled deliberately-not-consulted / 'no time' pass it, and the spec explicitly blesses that string as complete."
    evidence: "Section 4.2 blesses 'no time' as a complete disposition and section 8 forbids validating dispositions, while section 4.1 claims the target is the abandoned conversation. An all-declined record asserts N deliberate decisions that were not made, in a committed append-only file the next reader will trust."
    disposition: accepted
    disposition_rationale: "Each outcome must be distinct and name something specific to that voice, so a bulk-fill costs more than thinking. This is not the plugin judging anyone's reasons — 'no time; shipping Thursday and the docs owner is on leave' passes and is honest. It is refusing to let one string stand for eight decisions. An all-pending record is at least truthful about disengagement; an all-declined one launders it, and the record is append-only, so the lie is permanent."
  - id: O5
    category: implementation
    severity: high
    claim: "'No cap' plus 'propose and prune' plus a merge-time gate means the agent's verbosity sets the human's mandatory merge-time workload, and the spec does not engage with why both sibling sentinels cap."
    evidence: "advocatus-diaboli caps at 12 with a stated justification; choice-cartographer caps at 15 and biases toward 5-8, with 'do not pad'. Under the merge gate, a proposed voice the human does not actively delete becomes a mandatory disposition — so deleting is cheap and failing to delete is expensive and deferred."
    disposition: accepted
    disposition_rationale: "Cap at 8, bias toward 3-5, matching the siblings' discipline. Their caps are an honesty device aimed at the AGENT, not an ergonomic concession to the human: an uncapped generative agent pads, and padding is indistinguishable from thoroughness from the inside. The spec was overturning a settled position on two neighbouring components without noticing it was doing so."
  - id: O6
    category: specification quality
    severity: medium
    claim: "Nothing defines how the check resolves 'the consultation record for this spec' — S1's filename grammar carries a record date and an undefined slug, not the <spec-slug>.md convention the objection and story records use."
    evidence: "consultation-record-format.md gives <YYYY-MM-DD>-<slug>.md with no statement of what slug is or how it relates to the spec field. The date prefix is the record's date, not the spec's, so the strip-the-date-prefix derivation used by /diaboli and /choice-cartograph does not carry over."
    disposition: accepted
    disposition_rationale: "The record is named <spec-slug>.md, matching the objection and story records exactly, and the naming rule is added to S1's format page as part of the carved contract change alongside records_latest. This is the one place the no-contract-change claim did not hold: the schema needed no new field, but the check needed a naming rule the contract never stated."
  - id: O7
    category: implementation
    severity: medium
    claim: "S1's third honesty flag, asked, is unreachable under S5's prune-only flow — the human who knows a voice the agent missed has no path into the record, which is the isolation the Convener exists to attack."
    evidence: "Section 5.3 is prune-only and A4 pins two flags. The token asked appears nowhere in S5, while the shipped contract defines it as 'the human named it'. Section 5.3's own rationale is that the human knows their organisation and the agent does not."
    disposition: accepted
    disposition_rationale: "The dialogue gains an add step, and a human-named voice is flagged asked. The rationale argued for a two-way exchange and the mechanism delivered a one-way filter — which reproduces the Convener's own founding failure one level up: the highest-value voice in any session is the one the agent failed to derive, and there was nowhere to put it."
  - id: O8
    category: scope
    severity: medium
    claim: "Adding an active constraint heading to HARNESS.md deterministically fails check-convention-parity.py unless three convention files are updated in the same PR, and the constraint is not added to templates/HARNESS.md as its sibling was."
    evidence: "check-convention-parity.py requires every active constraint heading to appear in all three convention files. templates/HARNESS.md carries the sibling constraint in full; section 7 lists only the Stakeholders section for the template."
    disposition: accepted
    disposition_rationale: "All three convention files and templates/HARNESS.md are updated. The template asymmetry mattered most: an adopting project would have received the declaration surface without the constraint that gives it consequence, which is the opposite of how the sibling shipped."
  - id: O9
    category: scope
    severity: medium
    claim: "Section 10's 'roster 8 to 9' is true of only one of the three files section 7 names — README.md and sentinel-design/SKILL.md are both still at 5."
    evidence: "README.md reads '#### Sentinels (5)' with five rows; sentinel-design carries a five-row roster and a narrative sentence naming the old five. Coda, Mast and WIP Warden are absent from both, though all three ship as role: sentinel agents."
    disposition: accepted
    disposition_rationale: "All three rosters reconciled to 9 here, including the narrative sentence. The drift is S2's, S3's and S4's — each updated the explanation page and missed the other two surfaces, three slices running. Follow-up filed (#507): a roster is a pinned copy of a derived fact, which agents carry role: sentinel, and the same ARCH_DECISION already caught the README count badges twice in this epic."
  - id: O10
    category: specification quality
    severity: medium
    claim: "Section 2.3 states that nothing validates the question and A2 states that the question is validated; both cannot hold, and the two readings produce different agent files."
    evidence: "Section 2.3 says 'nothing validates it... there is nobody to gate'; A2 asserts 'every voice carries a concrete question, not sync with X', which is the phrase 2.3 uses for a bad question."
    disposition: accepted
    disposition_rationale: "Section 2.3 wins, and A2 is rewritten as what it always should have been: a rubric a human reviewer applies to the AGENT's output, not a check applied to anyone's words. The distinction matters because S2 built a lexical anchor check and then demoted it from judge to trigger after finding that lexical form does not measure specificity — an implementer reading the old A2 would have rebuilt exactly that defect."
  - id: O11
    category: risk
    severity: medium
    claim: "The never-draft-a-message guard has no stated test, and the spec's own worked example is simultaneously the question field's required content and a sendable message."
    evidence: "Section 2.1 forbids drafting a message to send and stakes the guard on there being no undo; section 2 requires drafting the question; the worked example is both. A6 has nothing to assert against."
    disposition: accepted
    disposition_rationale: "The skill draws the boundary explicitly: a question is one sentence a person could answer; a message has a salutation, a context paragraph, or a sign-off, and the moment any of those appears the agent has crossed. The read-only boundary forecloses every mechanical path already, so what remained was drift — an agent producing progressively more sendable questions — and drift needs a line, not a lock."
  - id: O12
    category: alternatives
    severity: medium
    claim: "A seventh Cartographer lens was not weighed against a fourth component, and the new record arrives without extending the documented diaboli/cartographer Routing Rule that currently partitions findings about a spec."
    evidence: "advocatus-diaboli's skill states that the two agents 'together form a complete partition of findings worth surfacing about a spec'. A finding like 'the docs owner should have been asked, and the published page will describe behaviour that no longer exists' is both a class of undetected failures and a voice — so with three records and a two-way partition it lands in two or neither."
    disposition: accepted
    disposition_rationale: "The fold-in is rejected on object of care: a choice story records a decision the spec made, and a voice is a person the spec affects — the Cartographer's lenses all interrogate the artefact, and none of them looks outward. But the Routing Rule half is accepted and acted on: it becomes three-way, with the tie-break stated. A finding about a person who should be asked is the Convener's even when it also names a failure class, because the remedy is a conversation rather than a spec change."
---
# Objection record — Cadence Sentinels S5: The Convener (spec mode)

Twelve objections: one critical, four high, seven medium. All accepted.

**Dispatcher verification note (2026-08-12).** Three claims were checked against
shipped code and all three held. `record-paths.sh` excludes `*.resolved.md`
from `records_open` by name — and that is the only place a non-`pending`
disposition ever lives. `harness-md-format.md` gives the enforcement enum as
`deterministic | agent | unverified`, so **"agent-verified" is not a value**.
And `README.md` reads `#### Sentinels (5)` with five rows while
`sentinel-design`'s roster carries the same five — Coda, Mast and WIP Warden
absent from both, three slices running.

**The claim that mattered most was half true.** §6 said "S5 changes no
contract", and the schema half is exactly right — every field this writes
exists, and `outcome` is already documented as required when the disposition is
`deliberately-not-consulted`, which is V4 verbatim. What the claim missed is
that a contract has a *query surface* and a *naming rule* as well as a schema,
and this slice needed both. `records_latest` and the `<spec-slug>.md`
convention are added to S1 in a carved commit, and §6's claim is narrowed to
what it can support.

**The pattern this gate names.** For the fourth slice running, the sharpest
finding traced to something written rather than something built — a docstring
in S4, an example line in S3b, an enum value here, and a roster that three
slices updated in one place out of three. A confident sentence is the most
dangerous artefact in a repository, because every consumer reads it instead of
the thing it describes.
