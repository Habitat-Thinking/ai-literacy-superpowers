---
spec: docs/superpowers/specs/2026-05-29-dl-s3-cross-check-mechanism-design.md
date: 2026-06-01
mode: spec
cartographer_model: claude-opus-4-7[1m]
stories:
  - id: 1
    lens: [patterns, defaults]
    title: Additive wrapper field as schema-evolution discipline
    disposition: promoted
    disposition_rationale: "Promoted as a pair with Story #4. The granularity-routing rule — per-element facts go through challenge_notes[] prefix discipline; model-level facts earn a wrapper field — is the kind of design discipline that should govern future schema decisions across the diagnostic-legibility plugin and its siblings. This story is the concrete instance; Story #4 is the general statement. Follow-up: file a single issue (paired with #4's promotion) tracking an AGENTS.md ARCH_DECISIONS entry titled something like 'Schema evolution by granularity routing'. The instance-level fact (cross_check_status as additive wrapper field) is also recorded in the spec § 3.3, which serves as the working example."
  - id: 2
    lens: [alternatives, consequences]
    title: Drop construct-only — YAGNI as standing commitment
    disposition: accepted
    disposition_rationale: "Recorded as the project's second action on the 'no surface area without a named consumer' YAGNI form (first occurrence: choice-cartographer adjudicated O3 — the reserved --mode code flag). Two occurrences is below the three-occurrence promotion threshold dl-s2b used, but the explicit framing as commitment is worth keeping accessible. Watch for a third occurrence on the next feature spec; if it appears, this story becomes a promotion candidate alongside the two earlier instances."
  - id: 3
    lens: [patterns, coherence]
    title: Subject-only audit trail — one writer per CC entry
    disposition: accepted
    disposition_rationale: "Slice-specific application of the single-writer audit invariant. The general statement (where each fact lives is a design choice, not a default) lives in Story #4's promoted-pair rule. This story records the concrete subject-only rule and the consequence (S4's /diagnose render must follow back-references from subject to side-effect element). When the S4 spec is written (issue #333), the render contract here is an input constraint."
  - id: 4
    lens: [coherence, patterns]
    title: Per-element vs model-level — facts routed by granularity
    disposition: promoted
    disposition_rationale: "Promoted as a pair with Story #1. Story #1 is the concrete instance (cross_check_status as additive wrapper field); this is the general statement of the granularity-routing discipline — facts that depend on the whole row live on the row; facts that depend on the whole table live on the table. The same rule already governs the schema split in dl-s2a (per-element LegibilityElement + LegibilityModel wrapper) and now extends to wrapper-field additions. Promotion target: an AGENTS.md ARCH_DECISIONS entry covering both schema-design granularity and audit-trail single-writer invariants, paired with the worked example from §3.3 and the Story #3 subject-only application. File one issue tracking the paired #1+#4 promotion."
  - id: 5
    lens: [forces, coherence]
    title: Direction-specific failure modes named, not inherited
    disposition: accepted
    disposition_rationale: "The meta-pattern (analogy-with-explicit-re-justification when mirroring precedent) is now twice-observed — diaboli surfaced it at S2b's spec-mode O3+O6 (fresh-sub-context vs S2b's mirror of single-context) and again at S3's O1. Two occurrences is the watch threshold. If a third spec mirrors a precedent and the diaboli has to surface the same 'analogy doing too much work' gap, promote this story (with the two precedents) to AGENTS.md. For now: accept, record, watch."
  - id: 6
    lens: [patterns, defaults]
    title: Structured refusal over forgiving fallback — third occurrence
    disposition: promoted
    disposition_rationale: "Third occurrence; cartographer explicitly flagged as promotion candidate. The three instances: choice-cartographer adjudicated O7 (operational shape C — structured henney_pending_count field over prose narration), dl-s3 O6 (refuse unrecognised mode-marker rather than fall back), dl-s3 O7 (unified precondition table with structured refusal line). Concrete promotion target named by the story: an AGENTS.md ARCH_DECISIONS entry titled 'Dispatcher-first error contracts for agent output' with the rule 'agents producing structured output for programmatic consumers must specify a structured refusal shape and must not silently fall back on unrecognised input'. File a follow-up issue tracking the promotion — sister to #339 (plugin_version rule promotion), both queued for the next AGENTS.md curation pass."
  - id: 7
    lens: [patterns, consequences]
    title: Two-layer ordering enforcement — agent self-verify plus fixture
    disposition: accepted
    disposition_rationale: "Recorded. The defence-in-depth pairing (agent emit-time self-verification + fixture-based structural test) is a v0.4.0 refinement of S2b Story #6's 'mechanism over decoration' stance — the underlying pattern is the same (the agent's prompt is load-bearing code, not ambient guidance) with a CI-time complement now added. The pairing is genuinely new but the parent pattern is already implicit in the project's discipline. Not promotion-worthy yet; if a third spec adds the same dual-layer pattern, consider promoting alongside S2b Story #6 as a generalised 'executable specification at multiple lifecycle points' rule."
---

## Story #1 — Additive wrapper field as schema-evolution discipline

**Source:** `docs/superpowers/specs/2026-05-29-dl-s3-cross-check-mechanism-design.md` (§2.2, §3.3, §7.2)
**Lens:** patterns, defaults
**Refs:** O9

**Context.** Since sub-S2a (PR #336) committed the v0.2.0 `LegibilityElement` / `LegibilityModel` schema, no subsequent slice has touched it. Sub-S2b exploited the schema's deliberate string-unopinionated `challenge_notes[]` field to layer the `Q<N>` prefix convention on top without changing the schema. S3 makes the *first* post-S2a schema touch: an additive optional `cross_check_status` field on the `LegibilityModel` wrapper. The decision is non-trivial because §3.3 articulates a positive argument for the prefix-on-existing approach for per-element evidence — and then immediately carves out an exception when the fact being recorded is model-level rather than per-element.

**Forces.** Schema stability (sub-S2a's stability promise; downstream consumers like S4 are still being designed against the v0.2.0 surface) versus expressiveness of the audit trail (the asymmetric-input case carries a fact about the whole model, not about any element). The cheaper move — N per-element CC-skipped sentinels — was the original draft. The spec resolved toward "schema touch is *sometimes* the right move, when the fact's granularity demands it" — establishing an evolving discipline rather than an absolute rule.

**Options not taken.**

- Per-element CC-skipped sentinel on every element of the populated collection (the original draft). One fact per element for a model-level fact; the §3.3 single-list defence does not apply because the granularity is wrong.
- A wholly new `LegibilityModelMetadata` record type carrying status fields. Heaviest path; would have forced sub-S2a's schema page to grow a second top-level type without enough material to justify it at v0.4.0.
- Encoding status in `generated_by` as a structured substring. Reuses an existing field but smears two unrelated facts into one string; downstream parsers would need to split.

**Choice as written.** One additive optional field on the wrapper, with three enum values, documented in the schema template and ignored gracefully by v0.3.0-shaped consumers. The defence: "the §3.3 defence still holds for per-element history; `cross_check_status` is orthogonal to it" (§3.3). The discipline being committed to is **granularity-routing for schema touches** — per-element facts go through `challenge_notes[]` prefix discipline; model-level facts earn a wrapper field.

**Consequences.** A precedent is now set that the schema *can* grow when the granularity argument carries the weight. Future slices will inherit the implicit licence to add wrapper fields for model-level facts (and the implicit prohibition on adding per-element fields for facts that don't actually vary per element). The discipline is currently load-bearing on §3.3's two-paragraph defence; if §3.3 is pruned in a future edit, the granularity rule becomes folklore. The optional-field choice also means v0.3.0 outputs remain valid against v0.4.0 consumers, which is a real backwards-compatibility win — but it depends on consumers treating field-absence as `not_run`, which is documented in §2.2 and nowhere else.

**Pattern.** Additive evolution / open-closed schema extension (Meyer; widely cited in API-versioning discussions). Closely related to JSON-Schema's `additionalProperties: true` posture and Protocol Buffers' "new fields are always optional" rule. The named cousin is **discriminated union by presence** — the field's absence is itself a meaningful state (`not_run`), which is a sentinel pattern operating at the field level rather than the value level.

**Notes.** Pairs with Story #4 — the granularity argument here is the same one §3.5 makes for keeping the per-element CC-applied sentinel while dropping the per-element CC-skipped sentinel. The two stories together describe one coherent design move.

---

## Story #2 — Drop construct-only — YAGNI as standing commitment

**Source:** `docs/superpowers/specs/2026-05-29-dl-s3-cross-check-mechanism-design.md` (§2.4, §3.7, §8, §10)
**Lens:** alternatives, consequences
**Refs:** O2

**Context.** The original draft shipped three modes: `full`, `construct-only`, `cross-check-only`. The `construct-only` mode existed to reproduce v0.3.0 behaviour after v0.3.0 behaviour was already preserved by `mode: full`-without-marker fallback. The diaboli surfaced that no concrete consumer was named for the third mode. The post-diaboli spec ships two modes; §8 records the escalation path: "if a v0.3.0-exact-output consumer materialises later, `construct-only` can be added in the same PR as that consumer."

**Forces.** Surface-area conservatism (every mode is a parsed string, a documented value, a tested literal, and a description-field token) versus completeness of the dispatcher contract (a v0.3.0 user *could* hypothetically want exactly v0.3.0 output and not the upgrade). The hypothetical consumer never had a named referent — the spec was inventing a constituency to justify the surface. The deeper force: whether the project commits to "ship surface area when a consumer exists, not in anticipation of one."

**Options not taken.**

- Ship all three modes anyway, on the grounds that the surface cost is small. Carries the dead-surface tax indefinitely; sets a precedent that hypothetical consumers justify contract growth.
- Drop `cross-check-only` and ship only `full`. Would have foreclosed the round-trip use case (layer cross-check onto persisted output) for which a concrete consumer exists.
- Ship `construct-only` behind a feature flag or marked experimental. Splits the contract surface into two grades of stability — worse than a clean drop.

**Choice as written.** Two modes ship: `full` (default, strict superset of v0.3.0 behaviour) and `cross-check-only` (Phase C against a fenced YAML payload). The agent description explicitly does not name `construct-only`; the anti-patterns name "build the third mode without a named consumer" as a future temptation to resist. The §8 "Out of scope" entry restates the escalation path so it survives the spec being read in isolation.

**Consequences.** The project has now twice acted on a YAGNI commitment at the spec level — first by deferring the `/diagnose` slash-command to S4 because no v0.4.0 consumer needs it, and now by dropping `construct-only` because no consumer needs it. A pattern is forming: features earn their place by named-consumer demand. The cost: if a v0.3.0-exact consumer *does* materialise, that PR must do the work of adding `construct-only`, updating tests, regenerating the agent description, and re-running the structural assertions. That work is bounded and named, which is the point.

**Pattern.** YAGNI (Beck / *Extreme Programming Explained*), specifically the "named consumer" form — features ship when a consumer is identified, not when a category of consumer can be imagined. Closely related to **Lean Software Development's "decide as late as possible"** (Poppendieck). The escalation-path-with-trigger form (§8) is the operational shape that prevents YAGNI from degrading into permanent foreclosure.

**Notes.** The decision is also a recoverable one — adding `construct-only` later is purely additive — which is why it is safe to drop at v0.4.0. The cartographer's signal: every future "should we ship surface X for consumer-shape Y?" question can cite this story as precedent.

---

## Story #3 — Subject-only audit trail — one writer per CC entry

**Source:** `docs/superpowers/specs/2026-05-29-dl-s3-cross-check-mechanism-design.md` (§3.5, §4.3 step 5, §5.2)
**Lens:** patterns, coherence
**Refs:** O3

**Context.** When the cross-check finds that a critique on subject X surfaces a revision on sibling Y in the opposite collection, the question is: where is the audit record written? The original draft wrote a `CC<N>` entry on Y (the side-effect target) in addition to revising Y. The diaboli surfaced that two write paths to a single element's `challenge_notes[]` (as subject during its own iteration; as side-effect during the opposite iteration) silently violated the audit-trail contract's implicit assumption of one writer per entry. The spec now writes the `CC<N>` entry only on X and names the side-effect on Y in X's prose body.

**Forces.** Audit-trail completeness from Y's perspective (a reader of Y's `challenge_notes[]` sees its full history including being revised as a side-effect) versus single-source-of-truth integrity (every CC entry has exactly one author, exactly one direction, exactly one subject). The deeper force: the §3.3 defence of "reading one element's `challenge_notes[]` sees its complete history" presumed one writer per entry — the bidirectional rule quietly violated its own foundational claim.

**Options not taken.**

- Bidirectional CC writes (the original draft). Two writers per Y entry; the §3.3 defence collapses on inspection.
- A separate per-element `revised_by_side_effect: bool` flag on Y. Schema change; redundant with what the subject's prose body now names.
- A model-level cross-reference table mapping subject→side-effects. Heavyweight; downstream consumers would have to join two structures to reconstruct the audit story.

**Choice as written.** `CC<N>` entries are written on the subject element only. When the critique surfaces a side-effect revision on Y, the subject's CC prose body names Y by `name` and points to Y's Phase A revision. Y's `challenge_notes[]` is not amended. The honesty rules and anti-patterns in the agent file name the rule explicitly so future implementers do not re-introduce the bidirectional write.

**Consequences.** A reader of Y's `challenge_notes[]` who wants to know *why* Y's description changed in a cross-check pass must look across at X's CC entry — the audit trail is a graph rooted at subjects, not a flat per-element list. Downstream consumers (S4's `/diagnose`) need to render this correctly: when surfacing Y's history, they must follow the back-reference from X's CC prose body. This is more work for S4 than a flat per-element history would have been; the trade is that the *contract* is now coherent (one author per entry) rather than the *display* being convenient (history fully visible from Y alone). S4 is the consumer that pays the cost; #332's parent owns ensuring S4's spec accounts for it.

**Pattern.** Single-writer invariant — the audit-log equivalent of "one source of truth" applied to append-only records. Close kin: **command-query separation** (Meyer) where the audit log is the query surface and the cross-check is the command; one command writes to one record. Also resembles event-sourcing's "one aggregate writes one event" invariant — side-effects on sibling aggregates are recorded as references, not as duplicate events.

**Notes.** Pairs with Story #4 — together they record the spec's commitment to "where each fact lives is itself a design choice, not a default." The bidirectional draft was a default that emerged from the structural mirror with S2b; the post-diaboli choice is a deliberate departure from that default.

---

## Story #4 — Per-element vs model-level — facts routed by granularity

**Source:** `docs/superpowers/specs/2026-05-29-dl-s3-cross-check-mechanism-design.md` (§3.3, §3.5, §3.6)
**Lens:** coherence, patterns
**Refs:** O4, O9, #1

**Context.** The original draft introduced two per-element sentinels with sibling shapes: `Cross-check applied; no questions surfaced changes` and `Cross-check skipped; only one collection present`. They differ in one verb. The diaboli surfaced that they look like two sibling "clean" sentinels to a downstream prefix-matching consumer. The post-diaboli spec keeps the **CC-applied** sentinel (per-element, because it records that *this particular element* was reached cleanly by Phase C) and pulls the **skip-case** up to the model-level `cross_check_status` field (because the skip fact applies to the whole model, not per-element). The decision is a routing rule, not a removal: every fact still gets recorded, just at the layer where its granularity actually lives.

**Forces.** Symmetry of the sentinel idiom (two sibling sentinels mirror nicely; the v0.3.0 Q-sentinel established the shape) versus correctness of granularity (recording a model-level fact at element granularity is N records for a 1-record fact, and the disambiguation collapses on prefix-match). The deeper force: a symmetric idiom *feels* like the right answer because the symmetry is visible and elegant; the granularity rule is invisible until the consumer surfaces it.

**Options not taken.**

- Keep both per-element sentinels with sharper wording (e.g. "Cross-check no-op" vs "Cross-check completed clean"). Solves the prefix-match collision; does not solve the N-records-for-1-fact granularity violation.
- Pull *both* sentinels up to the model level. Symmetric but throws away the per-element evidence that the CC-applied sentinel actually carries.
- Add a per-element boolean `cross_checked: bool`. Schema change at element layer; redundant with the model-level field for the skip case and redundant with sentinel presence for the clean case.

**Choice as written.** One per-element CC sentinel (CC-applied, recording per-element evidence) plus one model-level field (`cross_check_status`, recording the whole-model status). The §3.5 disambiguation rule reads: "Cross-check status is read from the model-level field, **not** inferred from the absence of CC entries." The schema's load-bearing layers are now: per-element `challenge_notes[]` (per-element history with prefix discipline) + model-level wrapper field (model-level status). Each layer carries facts at its native granularity.

**Consequences.** A reader of the spec who wants to know "did cross-check run on this element?" now has to consult two locations — the per-element `challenge_notes[]` (for the CC-applied sentinel) and the model-level `cross_check_status` field (for the disambiguation between "skipped" and "completed"). The two layers are deliberately orthogonal and the spec is explicit that consumers should not infer one from the other. The cost: downstream consumers must read both. The benefit: each fact has exactly one canonical home and the prefix-match collision is dissolved.

**Pattern.** Granularity-routing for record placement — a special case of the **separation of concerns** principle applied to schema design. Close kin: **layered headers** in HTTP, where request-level headers and connection-level headers serve distinct purposes; or **frontmatter vs body** in markdown specs (this very spec's frontmatter encodes plugin-level status, the body encodes section-level status). Also resembles relational normalisation: facts that depend on the whole row live on the row, facts that depend on the whole table live on the table.

**Notes.** Pairs with Story #1 (schema additive change) — both stories surface the granularity-routing discipline. The routing rule that emerged here is now a candidate for promotion if a third slice reaches for the same shape.

---

## Story #5 — Direction-specific failure modes named, not inherited

**Source:** `docs/superpowers/specs/2026-05-29-dl-s3-cross-check-mechanism-design.md` (§3.4)
**Lens:** forces, coherence
**Refs:** O1

**Context.** S2b §3.5 named two per-element failure modes ("smeared services" for Q1 in architectural elements; "textbook-definition drift" for Q5 in domain elements) and weighted Q1 and Q5 accordingly. S3 mirrors the weighting shape: CC1 weighted in A→D direction, CC5 weighted in D→A. The original draft paraphrased S2b's per-element failure modes as the direction-specific weighting rationale. The diaboli surfaced that the paraphrase was structural mirroring without genuine per-direction evidence — the per-element failure modes from S2b had been smuggled in to justify a per-direction weighting they don't actually describe. The post-diaboli spec names two genuinely cross-collection failure modes: **architectural-implicit assumption in domain description** (A→D's catch) and **domain-concept smear in architectural element** (D→A's catch).

**Forces.** Structural elegance of mirroring (the dimension/direction analogy is visible and pedagogically clean) versus epistemic honesty about what each layer actually catches (the per-element failure mode is *not* identical to the per-direction failure mode, even though the weightings look the same). The deeper force: when a spec is built by structural analogy with a precedent, the analogy carries assumed authority — surfacing what the analogy is and is not doing is the cartographer's job, and the diaboli surfaced it here.

**Options not taken.**

- Inherit S2b's per-element failure modes verbatim (the original draft). Looks correct; describes the wrong failure mode at the wrong granularity.
- Drop the weighting entirely and treat all five CC questions as equal-weight per direction. Foreclosed by §3.4's claim that the directions *are* asymmetric and the spec wants to operationalise the asymmetry.
- Run all five CC questions twice per element (once per direction) without weighting. Doubles the work; loses the operational signal that some questions catch direction-specific failures.

**Choice as written.** Two direction-specific failure modes named with worked examples: A→D targets domain elements whose descriptions implicitly assume architectural behaviours that the architectural collection does not commit to; D→A targets architectural elements whose descriptions silently conflate infrastructure with domain meaning that the domain collection explicitly defines. Both are explicitly framed as **genuinely cross-collection** failures — failures that single-collection Phase B self-challenge cannot catch.

**Consequences.** The spec now carries two failure-mode names that are S3's own, not S2b's. Future slices that touch direction-flavoured weighting (an iterative cross-check loop, or an orchestrator-level multi-pass) can challenge or extend these names directly. If disposition data shows neither failure mode actually fires in real invocations, the named claim is falsifiable — the working-hypothesis-with-falsification-surface frame from S2b Story #1 applies again here, with two named hypotheses ready to be tested. The deeper consequence: the project has now learned, twice in a row, that structural mirroring of a precedent requires explicit re-justification at the new layer — the cartographer's job and the diaboli's job converge on this lesson.

**Pattern.** Working hypothesis with named falsification surface (Popper); see S2b Story #1 for the precedent in this project. The newer pattern visible here is **analogy-with-explicit-re-justification** — when a spec inherits a structural shape from a precedent, the inheritance is named and the per-layer rationale is restated, rather than the analogy being allowed to carry the argument by itself.

**Notes.** Worth re-reading the next time a spec proposes "this mirrors precedent X." The mirror is fine; the mirror doing the spec's argumentative work is not.

---

## Story #6 — Structured refusal over forgiving fallback — third occurrence

**Source:** `docs/superpowers/specs/2026-05-29-dl-s3-cross-check-mechanism-design.md` (§3.6, §3.7)
**Lens:** patterns, defaults
**Refs:** O6, O7

**Context.** The original draft had a "forgiving" mode-marker parser: an unrecognised `mode:` value would fall back to `mode: full` with a warning sentence in the response prose. The diaboli surfaced that programmatic dispatchers consuming the YAML block would never see the prose warning, and a mistyped mode (e.g. `cross-check_only` with underscore) would silently re-run Phase A over a payload intended only for Phase C. The post-diaboli spec replaces the forgiving fallback with a **structured refusal line**: a single-line pattern-matchable string with no YAML block. The same pattern extends to other precondition violations (§3.6 class (b)).

**Forces.** Forgiving ergonomics (users mistype things; falling back is helpful) versus contract clarity (a programmatic dispatcher needs binary signals, not prose hints). The deeper force: the project has now reached this decision point three times — choice-cartographer's adjudicated O7 (operational shape C), this spec's O6, and this spec's O7. Three independent decisions, all settling on the same posture: structured signals over prose narration, refusal over fallback when the input violates an explicit precondition.

**Options not taken.**

- The original forgiving fallback. Asymmetric error mode — humans see the warning, machines do not.
- A halfway shape: emit YAML *with* a `warning:` field on the wrapper. Pollutes the wrapper with transport-layer concerns; a parsed YAML payload with a warning is still ambiguous to a dispatcher that only checks for presence-of-YAML.
- Refuse with a freeform error message (no structured prefix). Slightly more readable; harder to pattern-match programmatically.

**Choice as written.** A single-line refusal of the form `diagnostic-legibility refusal: <reason>.` with no YAML block emitted. Programmatic dispatchers pattern-match on "no YAML code block + presence of `diagnostic-legibility refusal:`" and route to error handling. The §3.6 precondition-violation table makes the failure shape comprehensive: every violation either emits valid YAML (asymmetric case only, with the model-level status field) or refuses structurally. There is no silent fallback anywhere in the spec.

**Consequences.** The project has now codified a **dispatcher-first error contract** for at least three agent surfaces. A pattern is emerging: when an agent's output is the input to another machine, the error path must be as structured as the success path. The cost: human users who mistype a mode marker get a refusal rather than the closest-match fallback they might have hoped for. The benefit: round-trip discipline (dispatcher → agent → dispatcher) becomes machine-verifiable. The recurring decision is now strong enough that it warrants promotion to a project-level convention — every agent's output contract should specify both the success shape and the structured-refusal shape, and silent fallbacks should be a named anti-pattern.

**Pattern.** Fail-fast with structured signal (Shore / *The Art of Agile Development*) applied to LLM-agent output contracts. Closely related to the **Tolerant Reader / Strict Producer** asymmetry in service design (Postel's principle inverted for machine-to-machine contracts — be strict in what you emit, because what you emit is what other machines parse). The structured-refusal shape is also kin to HTTP's "well-formed error response" convention: error responses obey the same response-shape grammar as success responses, with status discriminating which is which.

**Notes.** Three occurrences of the same decision is the threshold this project has used before to consider promotion (see S2b's `plugin_version` story, disposition `promoted`). A reasonable next move on this story is `promoted` with a target convention: "agents producing structured output for programmatic consumers must specify a structured refusal shape and must not silently fall back on unrecognised input." The cartographer flags the candidate; the human picks the disposition.

---

## Story #7 — Two-layer ordering enforcement — agent self-verify plus fixture

**Source:** `docs/superpowers/specs/2026-05-29-dl-s3-cross-check-mechanism-design.md` (§3.5, §4.3 step 6, §7.2)
**Lens:** patterns, consequences
**Refs:** O5

**Context.** The spec ships an ordering contract: `CC<N>` entries must follow `Q<N>` entries in any element's `challenge_notes[]`. The original draft asserted the contract at three layers (§3.5, §4.4 anti-pattern, §6.1 acceptance) and verified it at none. The diaboli surfaced that an asserted Then with no verifier is documentation, not a contract. The post-diaboli spec adds two enforcement layers: **emit-time self-verification** inside the agent (§4.3 step 6, re-orders in place if needed) and a **fixture-based structural test** that loads an interleaved input and asserts canonical ordering (§7.2 test #10). The two layers operate at different times and against different failure modes.

**Forces.** Trust in the agent's prompt (the agent file *says* to maintain the order; should that be enough?) versus verifiability of the contract (the next slice's consumer cannot inspect the agent's reasoning and must be able to assume the ordering holds). The deeper force: when the contract crosses a process boundary (agent → dispatcher → downstream consumer), the contract is no longer a property of one execution — it is a property of every execution that ever produces output, and the only way to make it that property is to verify it.

**Options not taken.**

- Single-layer enforcement at emit-time only. Trusts the agent to self-verify correctly; no out-of-band check that the agent actually does what it says.
- Single-layer enforcement via the structural test only. Catches the violation after the fact (in CI); does not prevent the agent from emitting wrong-order output in a real invocation that never sees the test.
- No enforcement; treat the ordering as a strong recommendation. The original draft's posture; collapses under the question "what does the consumer assume?"
- Schema-level ordering enforcement (e.g. JSON Schema's `items` with positional schemas). Foreclosed by the schema being `list[str]` with no internal positional structure.

**Choice as written.** Two enforcement layers, deliberately operating at different points in the lifecycle: (1) the agent self-verifies and re-orders in place at emit time, so live invocations produce correctly-ordered output regardless of how the model reasons through the questions; (2) a fixture-based structural test loads a deliberately-interleaved input and asserts the re-ordering rule produces canonical ordering, so PR-time CI catches any future agent-file edit that weakens the self-verification step. Both layers verify the same invariant; neither subsumes the other.

**Consequences.** The agent file's emit-time self-verification step is now load-bearing prompt content — trimming it weakens the live-invocation guarantee. The structural test is now load-bearing CI — modifying the fixture in a way that no longer interleaves the entries silently weakens the PR-time guarantee. A future contributor reading either layer in isolation may not see the pairing; the spec section §3.5 names both layers together but the artefacts themselves (agent file, test file) live in different directories. The cost: two artefacts to maintain in concert. The benefit: the asserted Then is now a verifier at both runtime and CI time.

**Pattern.** Defence in depth applied to contracts — the same posture that motivates having both a build-time type-checker and a runtime assertion for the same invariant. Closely related to **executable specification** (Fowler / Cohn) — the contract is realised as code at two layers rather than documented as prose. Also resembles the **belt-and-suspenders** idiom in safety-critical systems: when the cost of silent contract violation is high (here: downstream consumer breakage), redundant enforcement is cheap insurance.

**Notes.** Mirrors S2b Story #6's "mechanism over decoration" stance — both choices treat the agent's prompt as load-bearing code rather than as ambient guidance. The pairing of agent self-check + structural test is the v0.4.0 generalisation of that stance. Worth re-reading the next time a spec asserts an ordering or sequencing contract without naming a verifier.
