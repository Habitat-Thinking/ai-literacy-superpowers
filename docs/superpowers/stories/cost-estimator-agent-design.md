---
spec: docs/superpowers/specs/2026-06-11-cost-estimator-agent-design.md
date: 2026-06-11
mode: spec
cartographer_model: claude-opus-4-8[1m]
stories:
  - id: 1
    lens: [patterns, defaults]
    title: Fifth instance mirrors the read-only-emitter architecture
    disposition: accepted
    disposition_rationale: >
      Accepted. The read-only-emitter mirror is the right default; recorded that
      the boundary is INHERITED (5th instance), not re-justified for the numeric
      case — so a future divergent emitter knows it must write an explicit
      exception story rather than conform by gravity.
  - id: 2
    lens: [patterns, forces]
    title: Disclosure-of-derived-judgment's third independent surfacing
    disposition: promoted
    disposition_rationale: >
      Promoted. Marks the THIRD independent surfacing of the
      disclosure-of-derived-judgment decision (format contract → task→scope
      resolution → agent behaviour), firing the Rule of Three. The existing
      AGENTS.md ARCH_DECISION is updated in this PR to confirm it as a
      cross-cutting decision (still not an enforced invariant beyond each
      component's validation checklist), citing this story #2.
  - id: 3
    lens: [forces, consequences]
    title: Mechanical omission chosen over trusted agent restraint
    disposition: accepted
    disposition_rationale: >
      Accepted. Mechanical-over-discretionary cost-omission enforces
      emit-not-decide by construction — the right call; the new dependency on
      the S1 join-key normalisation is tracked and fixed (code-mode O1/O2).
  - id: 4
    lens: [forces, alternatives]
    title: Honest tier-label provenance over a fabricated model id
    disposition: accepted
    disposition_rationale: >
      Accepted. Disclosing unverifiable provenance as a tier label rather than
      fabricating a model id is correct; the spec↔contract faithfulness tension
      is flagged to #377 (not silently widened), and the implementation echoes
      the tier it reads rather than hard-coding it (code-mode O3, fixed).
  - id: 5
    lens: [patterns, consequences]
    title: Consumer slice refuses to mutate its contract
    disposition: accepted
    disposition_rationale: >
      Accepted. The consumer-doesn't-mutate-its-contract precedent is a reusable
      boundary discipline; recorded so the next slice tempted to widen an
      upstream contract has a worked instance to point at. A latent promote
      candidate if it recurs (the un-fold to #377 is its first worked precedent).
  - id: 6
    lens: [patterns, forces]
    title: Inferred classification must disclose its basis
    disposition: accepted
    disposition_rationale: >
      Accepted. Inference-basis disclosure on a derived target_kind is
      disclosure-of-derived-judgment applied to classification — coherent with
      the now-confirmed cross-cutting decision (story #2), with the
      supplied-vs-derived split as the honest trigger.
  - id: 7
    lens: [forces, consequences]
    title: Empty snapshot emits, only missing tokens refuse
    disposition: accepted
    disposition_rationale: >
      Accepted. The three-state grounding model (refuse / cost-omitted /
      cost-present) keyed on token-grounding is the only shape that keeps the
      empty-snapshot default-repo case honest rather than refusing on every
      estimate.
  - id: 8
    lens: [patterns, alternatives]
    title: Deterministic oracle with an honest descope
    disposition: accepted
    disposition_rationale: >
      Accepted. The deterministic-oracle-with-honest-descope is the right posture
      for grading a non-deterministic agent — structure and refusal routing
      graded, semantic content explicitly named out-of-scope rather than
      rubber-stamped (code-mode O3 area, fixed).
  - id: 9
    lens: [defaults, consequences]
    title: Standard routing tier inherited from read-and-author kinship
    disposition: revisit
    disposition_rationale: >
      Revisit (per the cartographer's flag). The Standard tier is chosen by
      analogy to tdd-agent, not measurement; revisit once S6 (#373) calibration
      data exists to test whether it under-serves the failure-direction
      reconciliation. Note the coupling: the tier:Standard provenance fallback
      (#4) moves with the tier, so a re-tier must keep them in sync.
  - id: 10
    lens: [forces, alternatives]
    title: One target per dispatch over batch estimation
    disposition: accepted
    disposition_rationale: >
      Accepted. One-target-per-dispatch keeps the contract and conformance oracle
      single-valued; the batch/aggregation concern is deliberately the
      dispatcher's (S3/S4) to answer, a clean foreclosure rather than a gap.
---

## Story #1 — Fifth instance mirrors the read-only-emitter architecture

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimator-agent-design.md` (§3.1, §2.1)
**Lens:** patterns / defaults
**Refs:** —

**Context.** S2 specs a new agent at `agents/cost-estimator.agent.md` with a
`Read, Glob, Grep` tool boundary that returns the estimate-record as a string,
explicitly "mirroring the carpaccio / advocatus-diaboli / choice-cartographer /
model-card-researcher read-only-emitter pattern" (§2.1) and naming itself "the
next instance" (§3.1) of the AGENTS.md agent-emit/dispatcher-persist/
human-disposes decision.

**Forces.** Fidelity to an established trust architecture versus fit to this
agent's actual job. A cost estimate is a number with a confidence band, not a
prose artefact like an objection record or a model card; the question the spec
resolves silently is whether a numeric-emitter benefits from the same
research-and-author tool boundary as a text-emitter, or whether the cost case
wanted something different (e.g. a tool that could read a live pricing API).
The spec resolved hard toward mirror, treating the architecture as load-bearing
across content type.

**Options not taken.**
- *Diverge for the numeric case* — give the estimator a narrow compute
  affordance, accepting an architecture exception. Rejected silently; the spec
  never weighs it.
- *Re-derive the boundary from first principles for cost* — argue the
  read-only boundary from the disposition-seat requirement specific to
  estimates, rather than inheriting it. The spec inherits rather than re-derives.

**Choice as written.** The spec chose to be the fifth faithful instance of a
named architecture, importing the tool boundary, the string-return contract,
and the dispatcher-persist split verbatim. It chose by mirroring: §2.1 and §3.1
cite the precedent agents rather than rebuilding the rationale.

**Consequences.** The pattern is now firmly past Rule-of-Three as an
architecture (four prior instances), so future content-emitting agents inherit
this as the default with near-zero deliberation cost — which is the value, and
also the risk: the fifth mirror makes the sixth automatic, and an agent whose
job genuinely wanted a different boundary would face strong gravity to conform.
This forecloses, by convention rather than by rule, the option of a divergent
emitter without an explicit exception story.

**Pattern.** The architecture is an instance of the read-only-emitter trust
boundary (a project-local ARCH_DECISION) and structurally a Command/Mediator
split (GoF) — the agent produces, a separate dispatcher persists, decoupling
production from the side-effect.

**Notes.** This is the cheapest cognitive-debt payment in the record: naming
that the boundary is *inherited*, not chosen here, so a future reader knows the
estimator did not independently re-justify its read-only-ness.

## Story #2 — Disclosure-of-derived-judgment's third independent surfacing

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimator-agent-design.md` (§1, §5.4, §6.3)
**Lens:** patterns / forces
**Refs:** —

**Context.** The AGENTS.md disclosure-of-derived-judgment decision (sourced from
S1 story #8, promoted) records two independent surfacings — the cost-estimation
skill and the diagnostic-legibility pipeline-map — and explicitly marks "Rule of
Three pending a third." S2 operationalises that obligation in at least three new
places: the inference-basis disclosure on a derived `target_kind` (§4.2), the
tier-label provenance on a derived `generated_by` (§5.4), and the blended-rate
skew disclosure on a derived cost (§6.3).

**Forces.** S1 operationalised the disclosure obligation as a *format contract*
— what a record must contain. S2 operationalises it as *agent behaviour* — what
the emitter must do when it derives a value a human or upstream previously
supplied. The unspoken force is whether S2 is a second surfacing of the same
feature-local decision, or a genuinely independent third instance that the
AGENTS.md note was waiting for. S2 applies the obligation to three *new* derived
values (the classification, the provenance, the rate skew) that S1's format did
not name — which reads as independent extension, not mere conformance.

**Options not taken.**
- *Treat the obligation as already-discharged by emitting an S1-conforming
  record* — rely on the format contract and add no behavioural disclosures.
  Rejected: the spec adds inference-basis and skew disclosures the format never
  required.
- *Defer the provenance and classification disclosures as out-of-scope
  refinements* — emit a bare derived value. Rejected: §4.2 and §5.4 make
  disclosure mandatory.

**Choice as written.** The spec chose to apply the disclosure obligation to the
agent's *own* derived judgments — its read of the target's kind and its read of
its own provenance — not just to the cost numbers S1 already covered. It chose,
by §5.4's explicit framing ("the disclosure-of-derived-judgment contract applied
to the provenance field itself"), to treat the principle as cross-cutting.

**Consequences.** If a human disposes this story as the third surfacing, the
AGENTS.md "Rule of Three pending a third" watch resolves and the obligation
graduates from "design discipline these specs propose" toward a cross-cutting
invariant — a promotion-worthy outcome the cartographer cannot make but should
surface. Left unsurfaced, the third instance lands silently and the watch stays
open indefinitely.

**Pattern.** Disclosure-of-derived-judgment (AGENTS.md ARCH_DECISION, from S1
story #8). This story is the meta-observation that S2 is its third instance, not
a fourth restatement of the same instance.

**Notes.** The disposition that matters here is whether to `promote` — the
human, reading three instances, decides if the Rule of Three has fired.

## Story #3 — Mechanical omission chosen over trusted agent restraint

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimator-agent-design.md` (§6.2)
**Lens:** forces / consequences
**Refs:** O2

**Context.** The round-1 draft told the agent to omit `cost_usd` when an
unmapped tier was "load-bearing" for the target's stage set — a discretionary
judgment. The revision (§6.2, driven by round-1 O4) replaced it with a
mechanical rule: omit cost whenever ANY exercised stage's tier is unmapped, with
"no agent judgment about whether a tier matters."

**Forces.** Trust-the-agent ergonomics versus enforce-the-boundary-by-
construction. A discretionary "load-bearing" test reads naturally and avoids
over-omitting on irrelevant tiers, but it is exactly where an emit-not-decide
agent quietly becomes a decider — choosing the record's shape on its own read of
salience, a derived decision the read-only tool boundary cannot constrain. The
spec resolved toward a mechanical yes/no check, accepting blunter behaviour in
exchange for a rule the tool boundary *can* enforce.

**Options not taken.**
- *Keep the discretionary "load-bearing" test* — fewer false omissions, but the
  agent decides. Explicitly rejected by O4.
- *Refuse on any unmapped tier* rather than degrade to cost-omitted — simpler,
  but conflates an honestly-omittable cost with an ungroundable target (see
  Story #7). Not taken.

**Choice as written.** The spec chose mechanical omission: any exercised
unmapped tier triggers a cost-omitted record, with the cause disclosed and no
salience judgment. It chose to make "emits, never decides" true by a rule rather
than by trusting restraint.

**Consequences.** The mechanical rule introduced a new dependency the discretion
never had: the mapped/unmapped test is only correct if it applies the S1
join-key normalisation (prefix-strip + whitespace-insensitive tier compare),
or it over-omits cost on the implementer split tier that dominates both S1
worked examples. That coupling is the substance of O2 (accepted, fixed now) —
the mechanical choice traded a discretion risk for a normalisation-coupling risk.
The remaining-failure surface belongs to the diaboli record; what belongs here
is that mechanical-over-discretionary was a deliberate choice with a new
upstream dependency.

**Pattern.** Constraint-by-construction over constraint-by-behaviour — the same
move as the read-only tool boundary itself (Story #1), applied to the
record-shape decision rather than the persistence decision.

## Story #4 — Honest tier-label provenance over a fabricated model id

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimator-agent-design.md` (§5.4, §7)
**Lens:** forces / alternatives
**Refs:** O1

**Context.** The S1 format requires `generated_by` to carry "agent name + model
identifier" (its example: `cost-estimator / claude-opus-4-8`). But the agent
runs `model: inherit` and is never told its resolved concrete model. §5.4
resolves this with a two-branch convention: record the resolved id iff the
dispatcher supplies it; otherwise record the routing-tier label
`cost-estimator / tier:Standard`, never a guessed model string.

**Forces.** Faithfulness to the format's documented field shape versus refusal
to fabricate. A concrete model id is what the field is documented to hold, but
the agent cannot honestly know it — so honouring the field's *form* would force
a guess, the exact fabrication the refusal discipline exists to prevent. The
spec resolved toward honesty-of-content over fidelity-of-form, treating the
`tier:` prefix as an explicit marker that this is a tier, not a model.

**Options not taken.**
- *Hard-code or inherit the worked example's `claude-opus-4-8`* — satisfies the
  field's documented shape, fabricates provenance. Explicitly forbidden.
- *Omit `generated_by`* — but S1 makes it required; omission breaks the
  contract.
- *Mutate the S1 field to admit a tier label* — forbidden by the §2.3
  consumer-no-mutation rule (Story #5); deferred to #377.

**Choice as written.** The spec chose to disclose unverifiable provenance as a
tier label rather than assert it as a concrete model — the
disclosure-of-derived-judgment contract (Story #2) applied to the agent's own
provenance field.

**Consequences.** This makes the *most common* record the agent emits carry a
`generated_by` value the format's field description and both worked examples
would not recognise as a model identifier, with no validation signal that
anything differs — a spec↔contract tension. O1 (accepted) flags exactly this:
the tension is to be raised with #377 (the format owner), the same class as the
cost-snapshot-path flag. The choice here is to take the honest-but-non-conforming
value now and route the format question to the slice that owns the contract,
rather than silently widening the field by convention.

**Pattern.** Disclosure-of-derived-judgment (AGENTS.md) applied to a provenance
field; structurally a Null Object / honest-placeholder convention — a typed
sentinel (`tier:` prefix) standing in for an unavailable concrete value.

## Story #5 — Consumer slice refuses to mutate its contract

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimator-agent-design.md` (§2.3, §6.1)
**Lens:** patterns / consequences
**Refs:** —

**Context.** An earlier S2 draft folded a per-stage `tokens_by_stage[].cost_usd`
sub-field into the merged S1 format reference from inside this emitter slice. The
revision (the headline un-fold, round-1 O1/O2/O8) reverts S2 to consuming the S1
format "exactly as-merged, with no mutation," and splits the format change to a
dedicated slice (issue #377) that owns the contract and runs its own diaboli
pass.

**Forces.** Convenience of co-locating a needed format change with the emitter
that wants it versus boundary discipline that keeps a consumer from granting
itself a unilateral mutation of its upstream contract. The unspoken force is
review focus: a format change bundled into an emitter slice rides the emitter's
review; a backward-compatibility claim against a strict S1-era validator gets
asserted, not demonstrated. The spec resolved toward strict consumer/owner
separation, accepting that S2 ships a less complete capability (no
machine-checkable per-stage band) to keep the contract change adversarially
reviewed on its own terms.

**Options not taken.**
- *Fold the sub-field in and assert backward-compatibility* — the original
  draft. Rejected by O1/O2/O8: an `iff`-coupled conditional field is not
  trivially additive against a closed-world validator.
- *Make the sub-field required* — a breaking change, never seriously on the
  table.
- *Defer the split-tier widening entirely* — but S2 still prices it into the
  whole-record band and discloses it in prose, so the capability is honoured
  without the format mutation.

**Choice as written.** The spec chose that a consumer slice does not mutate the
contract it consumes; format changes get their own slice. It chose, by §2.3's
"full stop, no exception" framing, to make this a precedent rather than a
one-off accommodation.

**Consequences.** This establishes a reusable boundary-discipline precedent: the
next slice tempted to widen an upstream contract for its own convenience now has
a worked instance to point at. It also defers a real capability — the
machine-checkable per-stage cost band — to the format-revision slice, accepting
that S2's widening lives only in prose and a whole-record band until then. The
deferral is a recorded, intentional incompleteness, not an oversight.

**Pattern.** Consumer/Owner separation (a Bounded Context boundary, Evans DDD —
the consumer does not edit the shared kernel). The split-to-its-own-slice move is
Strangler-adjacent: the format evolves in its own slice rather than by in-place
mutation from a dependent.

**Notes.** The dedicated format-revision slice is GitHub issue #377; it owns the
per-stage `cost_usd` sub-field and the backward-compatibility demonstration.

## Story #6 — Inferred classification must disclose its basis

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimator-agent-design.md` (§4.2)
**Lens:** patterns / forces
**Refs:** —

**Context.** The agent classifies its target into the `target_kind` enum, which
sets the S1 confidence *ceiling* (`task-text` → low; slicing-record/slice →
medium; spec → high). The round-1 O6 fix (§4.2) adds a blanket rule: on any
*inferred* (non-explicit) classification, the agent must disclose the inference
basis — "classified as `<kind>` by `<signal>`" — even when it detects no
ambiguity. An explicit dispatch-stated kind needs no such disclosure.

**Forces.** Catching a *confident* mis-read versus disclosure noise. The
existing ambiguity safeguard only fires when the agent *recognises* the target
as ambiguous; a confident single-shape match that is silently wrong would
up-classify the ceiling unseen. The spec resolved toward disclosing every
inferred classification, accepting a disclosure line on every inferred record in
exchange for making a confident wrong up-classification human-catchable —
because the classification *sets* the ceiling, so a wrong one presents a ceiling
as fact.

**Options not taken.**
- *Disclose only on detected ambiguity* — the pre-O6 behaviour; misses the
  confident wrong single-match.
- *Disclose on every classification including explicit ones* — symmetric but
  noisy; the dispatcher's asserted kind is not the agent's mis-read, so the spec
  exempts it.

**Choice as written.** The spec chose to disclose the inference basis on exactly
the derived classifications (inferred, not supplied), drawing the line at "is
this the agent's own judgment?" — disclosure-of-derived-judgment (Story #2)
applied to classification, with the supplied/derived split as the trigger.

**Consequences.** Every inferred record now carries an inference-basis line,
which is the intended cost. The exemption for explicit kinds keeps the
disclosure aligned with the principle (a supplied input cannot be the agent's
mis-read) rather than blanket-applying it, which keeps the signal interpretable.

**Pattern.** Disclosure-of-derived-judgment (AGENTS.md) applied to a
classification ceiling — the supplied-vs-derived distinction is the same one the
parent decision draws between an inspected fact and a derived prediction.

## Story #7 — Empty snapshot emits, only missing tokens refuse

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimator-agent-design.md` (§5.2, §5.3)
**Lens:** forces / consequences
**Refs:** —

**Context.** The agent has a `REFUSED:` convention for ungroundable targets (the
model-card-researcher precedent). §5.3 carves out a crucial distinction: an
empty `observability/costs/` (today's default — no cost snapshot) is *not* a
refusal; the agent emits a valid cost-omitted record. Refusal is reserved for an
unreadable/unclassifiable target or absent/unparseable *token* grounding
(`MODEL_ROUTING.md`, §5.2 triggers 2–3). The dividing line is the token
grounding: present-and-parseable → emit; absent or unparseable → refuse.

**Forces.** A single "ungroundable → refuse" rule is simpler, but it would make
the agent refuse on *every* estimate in today's repo (empty costs is the
default), which is the opposite of the S1 "no-cost case is honest, not a
failure" decision. The spec resolved by drawing the refuse/emit line at the
token grounding specifically, not at grounding-in-general — accepting a more
nuanced three-state behaviour (refuse / cost-omitted / cost-present) to preserve
the honest-omission case.

**Options not taken.**
- *Refuse on any missing grounding* — collapses the snapshot case into refusal;
  refuses on today's repo.
- *Emit a cost-present record with a guessed rate when the snapshot is empty* —
  fabrication; the exact false-precision the capability opposes.
- *Treat unparseable `MODEL_ROUTING.md` as a cost-omitted record* — but with no
  token grounding the *token* ranges would be fabricated, so that case must
  refuse, not omit.

**Choice as written.** The spec chose a token-grounding dividing line: the
absence of the *cost* snapshot is an honest omission (emit), while the absence or
unparseability of the *token* grounding is ungroundable (refuse). It made the
refuse/emit boundary turn on which grounding is missing, not on whether grounding
is complete.

**Consequences.** The agent now has three distinct output states the dispatcher
must distinguish (refusal string / cost-omitted record / cost-present record),
which is more for S3/S4 to handle than a binary, but is the only shape that keeps
the default-repo case honest. The §5.2.3 readable-but-tableless `MODEL_ROUTING.md`
state is a genuinely third refusal trigger distinct from both file-unreadable and
empty-snapshot — a subtlety the spec names precisely.

**Pattern.** A three-state grounding model (refuse / omit-with-disclosure /
ground) — the omit-with-disclosure state is disclosure-of-derived-judgment
(Story #2) again: an honestly-absent value disclosed, not guessed.

## Story #8 — Deterministic oracle with an honest descope

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimator-agent-design.md` (§8)
**Lens:** patterns / alternatives
**Refs:** O3

**Context.** The agent is `model: inherit` and non-deterministic, so the
behavioural TDAD layer cannot assert exact free-text. §8 (round-1 O9) scopes the
behavioural scenarios to deterministically-checkable structural properties of the
emitted string — a conformance parse, presence/absence oracles, and a `REFUSED:`
prefix oracle over fixture-pinned grounding — and explicitly descopes
model-dependent semantic content (exact token numbers, prose wording, the
`human_gate_time` caveat's content).

**Forces.** A behavioural guarantee that can fail honestly versus the
non-falsifiability of grading a non-deterministic model's prose. The spec
resolved by grading only what holds across any conforming model output
(structure, field presence, refusal routing) and explicitly *naming* what it
cannot grade — choosing an honest partial guarantee over a "guarantee in name
only" that pretends to grade semantics it cannot falsify.

**Options not taken.**
- *Assert exact prose/numbers* — non-falsifiable against a non-deterministic
  agent; a guarantee in name only.
- *Skip the behavioural layer entirely* — leaves the refusal routing and
  field-absence (no-verdict) checks ungraded, the high-value regressions.
- *Wait for a wired consumer (S3/S4) to drive end-to-end tests* — defers all
  behavioural coverage; the spec instead exercises the agent directly against
  pinned fixtures, the same way carpaccio's scenarios run pre-wiring.

**Choice as written.** The spec chose a deterministic-oracle suite with an
*explicit* descope: it grades structural conformance and refusal routing, and
lists `human_gate_time`'s prose content alongside exact numbers as out of
deterministic-grading scope rather than folding it under the conformance
oracle's "field set" claim (the precise correction O3 accepted).

**Consequences.** The behavioural layer is honestly partial — `human_gate_time`'s
*faithfulness* is asserted only as presence-and-not-a-range, never as content
correctness, and the spec says so. A future reader is told what the suite does
*not* guarantee, which prevents false confidence; the residual risk that a
semantic property regresses ungraded is real but named, not hidden.

**Pattern.** Test oracle with an explicit descope boundary — the "descope, do
not rubber-stamp" discipline. Structurally a Humble Object (Meszaros): the
non-deterministic content is pushed outside the gradeable boundary so the
testable structural shell can be asserted deterministically.

## Story #9 — Standard routing tier inherited from read-and-author kinship

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimator-agent-design.md` (§7)
**Lens:** defaults / consequences
**Refs:** —

**Context.** §7 adds a `MODEL_ROUTING.md` Agent Routing row placing the
`cost-estimator` at the **Standard** tier, justified by kinship: it is a
read-and-author agent "like `tdd-agent` (Standard), not a judgment-heavy one like
`advocatus-diaboli` or `spec-writer` (Most capable)."

**Forces.** Cost/throughput versus estimation quality. A cost estimate involves
real derivation — token modelling, tier mapping, failure-direction reconciliation
across conflicting drivers (§6.3) — which has a judgment flavour the Standard
tier may under-serve; against that, the work is "apply a specified methodology to
named inputs and emit a structured record," which the spec classes as
read-and-author throughput work. The spec resolved toward Standard by analogy to
`tdd-agent`, accepting the cheaper tier on the argument that the methodology is
fixed and the agent follows rather than synthesises.

**Options not taken.**
- *Most capable* — by analogy to the judgment-heavy agents; the spec argues the
  estimator's derivation is methodology-following, not adversarial synthesis, so
  declines it.
- *Leave the tier unset / inherit ambient* — but a new agent needs a routing row,
  and the tier label is also what `generated_by: tier:Standard` (Story #4) is
  grounded in.

**Choice as written.** The spec chose Standard by tier-kinship analogy to the
existing read-and-author agent (`tdd-agent`), classing cost derivation as
structured-output work rather than judgment work.

**Consequences.** The Standard tier is now load-bearing in a second place: it is
also the honest-placeholder provenance value (`tier:Standard`, Story #4). If a
future calibration loop (S6) finds Standard under-serves the failure-direction
reconciliation and the tier is bumped, the `generated_by` placeholder value moves
with it — a small coupling between the routing decision and the provenance
disclosure worth noting. The choice is a defensible default, but it is an analogy
("like tdd-agent"), not a measured one; S6 calibration is where it would be
tested.

**Pattern.** — (a routing-tier default by analogy; no named software pattern).

**Notes.** The kinship argument leans entirely on `tdd-agent` as the
read-and-author exemplar; if that analogy is the whole justification, the human
may want to dispose this as `revisit` pending S6 calibration data.

## Story #10 — One target per dispatch over batch estimation

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimator-agent-design.md` (§4.1)
**Lens:** forces / alternatives
**Refs:** —

**Context.** §4.1 states "the agent accepts exactly one target per dispatch,"
one of raw task text, a slicing record, a single slice, or a spec. The
single-target constraint is asserted in one clause and never revisited.

**Forces.** Per-dispatch simplicity and a clean input contract versus batch
ergonomics. A slicing record naturally contains many slices; a caller wanting a
per-slice cost breakdown must dispatch the agent once per slice rather than once
for the record. The spec resolved toward one-target-per-dispatch silently —
keeping the classification rule and the return contract single-valued (one
target → one record-or-refusal) — without weighing the batch case.

**Options not taken.**
- *Accept a slicing record and return a record per slice* — richer output, but a
  multi-valued return contract that complicates the conformance oracle (Story #8)
  and the dispatcher's persist/refuse logic.
- *Accept a list of targets* — explicit batch; the spec's "exactly one" forecloses
  it.

**Choice as written.** The spec chose single-target dispatch by assertion — one
target in, one record-or-refusal out. It chose by near-silence: the constraint is
stated once and its alternative is never named.

**Consequences.** A per-slice cost breakdown across a whole slicing record now
requires N dispatches orchestrated by the caller (S3/S4), not one agent call —
pushing any batch/aggregation concern entirely downstream. The single-valued
return keeps S2's contract and its oracle simple, which is the trade. This is a
clean foreclosure, not a failure; it simply means the batch question is the
dispatcher's to answer, and the spec does not say so explicitly.

**Pattern.** — (a single-valued request/response contract; no named pattern).

## Resolved cross-references

- **Story #3 → O2** — the mechanical cost-omission choice depends on the S1
  join-key normalisation; O2 (accepted, fixed now) is the objection that the
  mechanical "unmapped" test must apply that normalisation or it over-omits cost
  on the dominant split tier.
- **Story #4 → O1** — the honest tier-label provenance choice creates the
  spec↔contract faithfulness gap O1 (accepted) flags for the format-revision
  slice (#377).
- **Story #5** — the per-stage `cost_usd` sub-field was split out to the
  format-revision slice (#377), which demonstrates backward-compatibility on its
  own diaboli pass (recorded in prose, not a story/objection cross-reference).
- **Story #8 → O3** — the honest-descope choice is the precise correction O3
  (accepted) asked for: list `human_gate_time`'s prose content as out of
  deterministic-grading scope rather than folding it under the conformance
  oracle's "field set" claim.
