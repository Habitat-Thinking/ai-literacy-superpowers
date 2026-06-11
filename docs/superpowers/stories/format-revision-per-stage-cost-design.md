---
spec: docs/superpowers/specs/2026-06-11-format-revision-per-stage-cost-design.md
date: 2026-06-11
mode: spec
cartographer_model: claude-opus-4-8[1m]
stories:
  - id: 1
    lens: [patterns, alternatives]
    title: Own-the-contract slice over in-place mutation
    disposition: promoted
    disposition_rationale: >
      Promoted to AGENTS.md ARCH_DECISIONS as the own-the-contract-slice rule: a
      change to a shared/merged contract gets its own owning slice with its own
      adversarial pass; a consumer never mutates the contract it consumes. This
      is the FIRST WORKED INSTANCE of the precedent S2 Story #5 named (accepted
      there) — watch for a third before treating it as a hard invariant (Rule of
      Three).
  - id: 2
    lens: [forces, consequences]
    title: Record-internal spread over absolute-rate binding
    disposition: accepted
    disposition_rationale: >
      Accepted. Record-internal spread now, absolute-rate check deferred to S3
      (which owns the snapshot). The honest §4.4.1 CAN/CANNOT floor is the durable
      artefact telling the S3 author which check is theirs to build.
  - id: 3
    lens: [patterns, forces]
    title: One-directional coupling over biconditional iff
    disposition: accepted
    disposition_rationale: >
      Accepted. One-directional coupling over a biconditional iff is the only
      resolution that keeps S1-era cost-present records (class B) valid while
      still rejecting the incoherent inverse.
  - id: 4
    lens: [forces, consequences]
    title: Directory sentinel over a clean token
    disposition: accepted
    disposition_rationale: >
      Accepted. Keep-the-directory-sentinel over a clean token — backward-compat
      over semantic cleanliness, with the entrenchment named (not "resolved") and
      the unenforced consumer special-case recorded as an honest residual (O5/O6).
  - id: 5
    lens: [patterns, defaults]
    title: Reserved tier-prefix grammar without a check
    disposition: accepted
    disposition_rationale: >
      Accepted. The tier: reserved-prefix grammar gives consumers a mechanical
      discriminator without a rejecting check — widen-and-mark over
      reshape-and-validate, keeping the merged S2 agent conformant.
  - id: 6
    lens: [forces, consequences]
    title: Whole-record cost set to per-stage sum
    disposition: accepted
    disposition_rationale: >
      Accepted. Whole-record cost set to the per-stage sum by construction so the
      canonical example would pass the deferred S3 absolute-rate validator (the
      round-2 O1 fix); the Example-2 prose flags this as by-construction, not a
      must-sum rule (code-mode O1).
  - id: 7
    lens: [alternatives, coherence]
    title: Emitter enhancement deferred, not bundled
    disposition: accepted
    disposition_rationale: >
      Accepted. Emitter enhancement deferred-and-filed (#380), not bundled —
      re-applying the same consumer/owner discipline (#1) to this slice's own
      residue rather than re-conflating them.
  - id: 8
    lens: [patterns, consequences]
    title: Widen-and-mark over reshape-and-validate
    disposition: accepted
    disposition_rationale: >
      Accepted. Widen-and-mark over reshape-and-validate is the unifying strategy
      the closed-world checklist makes safe (provably non-breaking additive
      evolution); each unenforced new convention is recorded as an honest
      residual rather than implying enforcement it lacks.
---

## Story #1 — Own-the-contract slice over in-place mutation

**Source:** `docs/superpowers/specs/2026-06-11-format-revision-per-stage-cost-design.md` (Slice header, §1, §7)
**Lens:** patterns / alternatives
**Refs:** —

**Context.** Three concerns accumulated against the merged S1 estimate-record
format reference during the S1 and S2 reviews. Rather than letting S2 — a pure
consumer of that reference — mutate the contract it consumes, the team carved
the format change into its own slice (#377) that *owns* `estimate-record-format.md`
and runs its own diaboli pass. This slice is the first worked instance of a
boundary-discipline precedent the S2 cartographer named but did not yet exercise.

**Forces.** Velocity (fold the three small fixes into S2 and move on) versus
contract integrity (a shared kernel with merged consumers should not be edited
by one of its consumers as a side-effect). A second, quieter force: adversarial
coverage — a contract change folded into a consumer slice inherits that slice's
diaboli pass, which is scoped to the consumer's behaviour, not the contract's
backward-compatibility. Splitting buys the contract change a *dedicated*
adversarial pass (it took two rounds, eight then five objections).

**Options not taken.**
- *Mutate the reference inside S2.* Lowest ceremony; conflates consumer and
  owner roles and gives the contract change only S2's diaboli budget.
- *Append the format fixes to a later sibling slice (S3, the command).* S3 owns
  the runtime checkpoint, not the contract; the format change would again ride a
  consumer's review.
- *A single combined "format + emitter" slice.* Re-creates the consumer/owner
  conflation in a different shape — see Story #7.

**Choice as written.** The spec declares the slice the *legitimate owner* of the
reference, the only slice that MAY modify it, and routes all three deferred
residues here. Ownership is asserted in the slice header (`Owns:`) and enforced
by the slice's whole structure.

**Consequences.** Establishes a reusable pattern: contract changes get their own
owning slice and their own adversarial pass, separate from any consumer. The cost
is slice proliferation — a three-line documentation fix now carries a full
feature-PR ceremony (spec + dual diaboli + scenarios + version bump). The team
has decided that contract-change ceremony is worth more than the throughput it
costs.

**Pattern.** Shared Kernel with a single owning Bounded Context (Evans, DDD) —
the reference is the kernel; the owning slice is its steward; consumers reference
it by path and inherit changes. Also an instance of the codebase's
"cross-cutting methodology lives in `skills/<name>/references/<contract>.md`"
AGENTS.md decision, here paired with an explicit *ownership* boundary the
decision implies but does not spell out.

**Notes.** This is the first worked precedent of the S2 "consumer slice refuses
to mutate its contract" decision. Strong promotion candidate: the ownership-plus-
dedicated-diaboli rule is reusable beyond cost-estimation.

## Story #2 — Record-internal spread over absolute-rate binding

**Source:** `docs/superpowers/specs/2026-06-11-format-revision-per-stage-cost-design.md` (§4.4, §4.4.1)
**Lens:** forces / consequences
**Refs:** O3, #1

**Context.** The slice exists to make S1's split-tier widening machine-checkable —
S1 demonstrated it only in prose and a worked example. The headline decision (O3)
is *what kind* of checkability to deliver now. The spec chose a record-internal
strict-spread invariant (`low < high` on split-tier bands) deliverable in this
format-only slice, and explicitly deferred the absolute-rate check (does the band
equal the snapshot's sonnet/opus rates?) to S3, which owns the snapshot.

**Forces.** Checkability-now versus checkability-complete. A stateless checklist
parser reading only the record cannot know the absolute `$/token` rates — those
live in the snapshot, out of scope here. The spec resolved toward delivering the
strongest invariant the *record alone* can carry, and being honest in §4.4.1 that
this is a floor: a `{99.0, 100.0}` band still passes the spread check while bearing
no relation to a genuine two-tier widening.

**Options not taken.**
- *Make the record carry the per-model rates it used* (option (a), §4.4.1), so the
  check is fully self-contained. Rejected: adds a field the merged S2 agent does
  not emit, breaking backward-compat and re-introducing a required field.
- *Defer all checkability to S3* and ship only "a place to put the band." Rejected
  by round-1 O3's disposition: the slice must deliver real record-internal
  checkability, not just a field.
- *Over-claim the spread check as "makes the widening machine-checkable."* The
  prior draft did exactly this in its headers and FRs; O3 forced every surface
  down to the honest "non-collapsed (strictly spread)" floor.

**Choice as written.** Deliver the record-internal half (strict-spread invariant)
now; defer the absolute-rate half to S3 explicitly. §4.4.1 states plainly what the
validator CAN assert (presence/coupling, `low ≤ high`, strict spread on split-tier
bands) and CANNOT (spans-two-tiers, equals-the-rates, magnitude-correct).

**Consequences.** The slice's value is genuine but partial, and the partition is
now load-bearing on S3 honouring its half. A future S3 author must build the
absolute-rate validator the deferred half names; if S3 forgets, the widening is
forever only spread-checked. The honest §4.4.1 floor is the durable artefact — it
tells the downstream author exactly which check is theirs to build.

**Pattern.** A split invariant across a deferred boundary — necessary-but-not-
sufficient checking, where the format owner proves the part it can and names the
part it cannot. Sibling to Story #1's owner/consumer split: the same discipline
that put the contract in its own slice also keeps the contract from claiming a
check that needs a consumer's data.

## Story #3 — One-directional coupling over biconditional iff

**Source:** `docs/superpowers/specs/2026-06-11-format-revision-per-stage-cost-design.md` (§4.1, §4.2, §4.3)
**Lens:** patterns / forces
**Refs:** —

**Context.** The new per-stage `cost_usd` sub-field is coupled to the existing
top-level `cost_usd`. The prior draft expressed this as an `iff` biconditional in
the field table. This revision splits the coupling into two directions of
different strength: sub-field present ⟹ top-level present (enforced by the
validator); top-level present ⟹ bands SHOULD be populated (an emitter obligation,
not a rejection rule).

**Forces.** Internal coherence of the format (a per-stage band with no whole-record
cost is genuinely incoherent and should fail) versus backward-compatibility with
S1-era cost-present records that have top-level cost but no per-stage bands
(class B). A biconditional satisfies the first force and *breaks* the second — it
would retroactively fail every S1-era cost-present record, including the merged
Example 2. The asymmetry is the only resolution that holds both.

**Options not taken.**
- *Biconditional `iff`* (the prior draft). A literal reader — and the reference
  instructs readers to parse, not read loosely — tightens it into a class-B-breaking
  mandate.
- *No coupling at all* — a per-stage band could appear on a cost-omitted record,
  the incoherent inverse the slice means to forbid.
- *Make the sub-field required when top-level cost is present.* Same class-B break
  as the biconditional, stated imperatively.

**Choice as written.** The enforced direction is the one that catches the
incoherent inverse (sub-field ⟹ top-level); the SHOULD direction (top-level ⟹
bands) is held as an emitter obligation with a falsifiable home in the deferred
follow-on issue (§4.3.1). The field table and the §4.4 check are made to say the
same thing.

**Consequences.** Class B stays valid; the genuinely incoherent shape still fails.
The cost is a SHOULD that no shipped emitter exhibits today (§4.3.1's honest scope
note: "the format admits the band; no producer yet populates it") — its only home
is a deferred issue's acceptance criterion (see Story #7). A reader who skims the
field table must hold the asymmetry in mind; the symmetry of the old `cost_usd`/
`cost_basis` pairing is deliberately *not* mirrored on the reverse direction.

**Pattern.** Postel-flavoured asymmetry (liberal in what a record may omit, strict
in the one shape that is incoherent) — and an instance of separating an emitter's
SHOULD-populate obligation from a validator's MUST-reject rule, the same
disclosure-vs-enforcement seam the codebase's disclosure-of-derived-judgment
decision draws elsewhere.

## Story #4 — Directory sentinel over a clean token

**Source:** `docs/superpowers/specs/2026-06-11-format-revision-per-stage-cost-design.md` (§6.1, §6.2)
**Lens:** forces / consequences
**Refs:** O5, #1

**Context.** When no cost snapshot file exists, the mandatory cost-snapshot
grounding entry's `path` points at the directory `observability/costs/` (trailing
slash). The field is documented as "the inputs the estimate was built from"; a
directory that grounded nothing strains that description. The spec chose to keep
the directory path and *document* it as the named cost-omitted sentinel, rather
than invent a cleaner token.

**Forces.** Semantic cleanliness (a directory path that grounded nothing overloads
"the inputs the estimate was built from") versus backward-compatibility (the merged
S2 agent already emits the directory path; Example 1 already uses it). The spec
resolved toward zero S2 change and zero new parse case, and pays for it by naming
the strain rather than removing it.

**Options not taken.**
- *Make the cost-snapshot entry optional when omitted.* Removes the deliberate "the
  record always shows it looked" honesty signal and breaks the merged S2 agent,
  which never drops the entry.
- *Invent a new sentinel token* (`path: <none>`, `kind: no-snapshot`). Cleanest
  semantically; introduces a value the S2 agent does not emit and a new enum/parse
  case for every consumer.
- *Keep the directory path and document it* — chosen. Zero S2 change, zero new
  parse case, ratifies the Example-1 precedent.

**Choice as written.** The reference now documents the trailing-slash directory as
the defined cost-omitted sentinel and explicitly states this *entrenches* an
overloaded meaning (file = grounded; trailing-slash directory =
looked-and-found-nothing) — "named and accepted," not "resolved." It adds a
consumer special-case: a snapshot-counting aggregator must not count a
trailing-slash path as a grounding.

**Consequences.** The overloaded field is now a deliberate, documented entrenchment.
The accepted residual (O5): the consumer special-case is advisory prose with no
checklist enforcement, so the same closed-world silence that proves backward-compat
also guarantees nothing catches an aggregator that miscounts. The cost is
externalised onto every downstream counter (S3, any cost aggregator) — a silent-
miscount risk the slice does not control. This is the same own-the-contract trade
as Story #1, seen from its cost side: ownership lets the slice choose entrenchment,
but it cannot enforce the special-case it depends on without widening scope.

**Pattern.** Overloaded sentinel value (a magic path encoding a negative fact) —
the classic backward-compat-over-cleanliness trade, here made honest by naming the
overload rather than hiding it.

## Story #5 — Reserved tier-prefix grammar without a check

**Source:** `docs/superpowers/specs/2026-06-11-format-revision-per-stage-cost-design.md` (§5.1, §5.3)
**Lens:** patterns / defaults
**Refs:** —

**Context.** The merged S2 agent honestly emits `cost-estimator / tier:Standard`
under `model: inherit` when it cannot resolve its concrete model — a value the
field's "model identifier" description does not recognise. The spec widens the
description to admit a `tier:<tier>` label and defines `tier:` as a *reserved
provenance prefix* so a consumer splitting on the ` / ` separator can mechanically
tell a tier label from a concrete model id — without adding any rejecting check.

**Forces.** Mechanical distinguishability (a consumer must be able to classify the
value deterministically) versus backward-compat (no new check may retroactively
fail a record, and the checklist keys on `generated_by` nowhere today). A naive fix
would add a `generated_by`-shape check; that risks retroactive failure. The spec
resolved toward a *grammar* (a prefix reservation) that gives a consumer a total
discriminator while the field stays unvalidated for rejection.

**Options not taken.**
- *Reshape `generated_by` into separate agent/model/tier fields.* Breaks the merged
  S2 agent (single string), adds required fields, solves a wording mismatch with a
  schema change.
- *Add a `generated_by`-shape validation check.* Could retroactively fail an old
  record; explicitly out of scope (§2.3).
- *Widen the description with no prefix reservation.* Leaves the value ambiguous —
  a consumer cannot tell `tier:Standard` from a model id when splitting on ` / `.

**Choice as written.** Widen the description to admit both forms; reserve `tier:`
as a prefix (a concrete model id never begins with `tier:`); add no check. A
grammar, not a validator.

**Consequences.** The most common record's provenance is now documentation-
conformant with zero agent change. The reservation is enforced only by convention —
nothing rejects a future model genuinely named `tier:...` (the spec argues none
exists in `MODEL_ROUTING.md` or any snapshot, making the prefix a sound total
discriminator *today*). A consumer that splits on the separator without testing the
prefix still mis-classifies; the grammar enables correct parsing but does not compel
it. Symmetric with Story #4: a parsing rule documented, not enforced.

**Pattern.** Reserved prefix / sentinel namespace (cf. reserved identifiers in
language grammars) — a discriminator carried in-band by convention rather than by a
separate typed field. The default being widened here is the inherited "model
identifier" framing from S1, which the merged S2 agent had already silently
outgrown.

## Story #6 — Whole-record cost set to per-stage sum

**Source:** `docs/superpowers/specs/2026-06-11-format-revision-per-stage-cost-design.md` (§4.5)
**Lens:** forces / consequences
**Refs:** O1, #2

**Context.** Example 2 (the cost-present worked example) is the reference's single
demonstration of a correctly-priced widening. Round-2 O1 showed the prior bands were
back-solved to hit a fixed whole-record envelope `{0.95, 7.50}`, so they could not
be reproduced from two consistent per-tier rates. The fix re-derives all three bands
from two fixed rates and sets the whole-record `cost_usd` to their exact sum
`{1.60, 7.60}` by construction.

**Forces.** Rate-groundedness (every band must be a fixed tier rate × a token bound,
so the example would pass the absolute-rate validator S3 is told to build) versus
sum-tidiness (a hand-author's instinct to make the per-stage figures add to a
pre-chosen whole-record band). The §4.4 correlation note *permits* the whole-record
band to differ from the sum — so the spec was free to let the sum land where the
rates put it, and then chose to make the whole-record figure equal that sum rather
than preserve the old envelope.

**Options not taken.**
- *Keep the old envelope `{0.95, 7.50}` and allocate bands to fit it* (the O1
  defect) — produces per-token rates that contradict the example's own declared
  rates; the canonical example would fail the deferred S3 validator.
- *Let the whole-record band differ from the sum* (permitted by the correlation
  note) — defensible, but leaves the example's two figures unrelated and invites a
  reader to wonder why they differ.
- *Set the whole-record band equal to the sum* — chosen, the cleanest fix: every
  number traceable to one of two rates, and the two figures reconcile by
  construction.

**Choice as written.** Two fixed rates (sonnet `4.0e-6`, opus `2.0e-5`), each
single-tier band = its rate × its token bounds, the split implementer band =
cheaper rate at low / dearer rate at high, and the whole-record band = the exact
sum. The worked example must itself pass the validator the slice defers to S3.

**Consequences.** The canonical example is now rate-grounded and would survive the
deferred absolute-rate check (Story #2) — the example that teaches the widening is
no longer the example that breaks the deferred validator. The cost: the whole-record
band is now *demonstrated* equal to the sum in the one canonical case, which a
careless reader could over-generalise into "whole-record always equals the sum,"
contradicting the correlation note that still permits divergence. The spec flags
this ("set equal by construction... though the correlation note permits them to
differ"); the example carries the weaker invariant only by construction, not as a
rule.

**Pattern.** Executable specification by exemplar — the worked example is held to
the same check the contract defines, so the demonstration cannot drift from the
checked invariant. This is the artefact-side counterpart to Story #2's deferred-
check honesty: the example pre-satisfies the check that the format itself cannot yet
run.

## Story #7 — Emitter enhancement deferred, not bundled

**Source:** `docs/superpowers/specs/2026-06-11-format-revision-per-stage-cost-design.md` (§7, §12, §4.3.1)
**Lens:** alternatives / coherence
**Refs:** #1, #3

**Context.** Concern 1 adds a sub-field the merged S2 agent does not emit. A natural
move is to also teach the S2 agent to populate per-stage bands on cost-present
records. The spec explicitly does *not* ship that emitter change; it files it as a
standalone follow-on issue against the `cost-estimator` agent, and ships only the
format that *admits* the band.

**Forces.** Completeness (a format field nothing populates feels half-finished)
versus boundary discipline (an emitter behaviour change belongs to the emitter's
slice, not the contract's). The decisive force is that bundling an emitter change
into the format slice re-creates the exact consumer/owner conflation that got this
slice split out of S2 in the first place — the slice would have to reason about both
the contract and a consumer's behaviour in one diaboli pass.

**Options not taken.**
- *Bundle the emitter change here.* Re-conflates owner and consumer; the spec calls
  this out directly (§7(c)).
- *Drop the SHOULD entirely* and make per-stage bands a pure MAY. Loses the emitter
  obligation that Story #3's asymmetry depends on; the SHOULD would be
  indistinguishable from a MAY.
- *Leave the follow-on implicit.* The AGENTS.md "a natural-home hand-off does not
  bind the next slice — re-file, do not leave implicit" decision forbids this; an
  unfiled hand-off is an orphaned obligation.

**Choice as written.** No S2 agent change ships (§7). The emitter enhancement is
named in §12 watch-items with a falsifiable acceptance criterion and is to be filed
as a standalone issue at adjudication. The SHOULD of Story #3 gets its falsifiable
home there.

**Consequences.** The slice stays format-only and its diaboli pass stays scoped to
the contract. The cost: the SHOULD has no shipped producer today — within this slice
the obligation is honestly "the format admits the band; no producer yet populates
it" (§4.3.1), and the only cost-present record carrying bands is the hand-authored
Example 2. The whole construction is coherent only if the follow-on issue is
actually filed; until it is, the SHOULD's falsifiable home is a watch-item, not a
tracked issue. The re-application of Story #1's own discipline to its own residue is
the coherence signal — the slice declines to do to S2 what it was created to stop S2
doing to the contract.

**Pattern.** Re-filing a hand-off as a tracked obligation (the AGENTS.md "re-file,
do not leave implicit" decision) — and a recursive application of the
owner/consumer boundary that created the slice (Story #1) to the slice's own
emitter residue.

## Story #8 — Widen-and-mark over reshape-and-validate

**Source:** `docs/superpowers/specs/2026-06-11-format-revision-per-stage-cost-design.md` (§2.3, §3, §5, §6)
**Lens:** patterns / consequences
**Refs:** #3, #4, #5

**Context.** All three concerns share a single resolution strategy, made possible by
the checklist's closed-world property (§3): the checklist rejects a record only when
a *named* check fails, never for carrying a field it does not mention. Every fix is
shaped to widen the format to admit existing output and mark new structure as
optional — never to reshape the contract or add a rejecting check that could
retroactively fail a record.

**Forces.** Contract evolution versus backward-compat against merged consumers. The
closed-world property is the lever: a new optional field is invisible to every check
that does not name it, so additive widening is provably non-breaking, while
reshaping (new required fields, new rejecting checks) is not. The spec resolved
*every* concern toward additive widening and named the guard rails (§2.3): if a
reviewer finds a required field, a new grounding state, a `generated_by`-shape
check, or a `path`-must-be-a-file check, that is scope creep to be cut.

**Options not taken.**
- *Reshape the contract per concern* (split `generated_by`, a new snapshot token, a
  required per-stage field) — each a backward-compat break, each rejected in its
  own section (§4.2, §5.2, §6.2).
- *Add rejecting checks to enforce the new semantics* (a `generated_by`-shape check,
  a `path`-must-be-a-file check, a biconditional coupling) — each risks retroactive
  failure; all declined.
- *Treat backward-compat as asserted* rather than demonstrated. The slice's load-
  bearing requirement is the opposite: trace the closed-world checklist against four
  record classes and show, not state, that all pass.

**Choice as written.** Widen-and-mark across all three concerns: an optional one-
directionally-coupled sub-field (Story #3), a description widening plus a non-
rejecting grammar (Story #5), documentation of an existing path convention (Story
#4). The closed-world property carries every backward-compat demonstration.

**Consequences.** Backward-compat is provable and proven; the merged S2 agent needs
no change. The accepted cost is that the new semantics the slice cares about (the
SHOULD-populate obligation, the trailing-slash special-case, the `tier:` prefix
reservation) are all *conventions the checklist does not enforce* — the same closed-
world silence that proves safety also guarantees nothing catches a consumer that
ignores them. The strategy buys zero breakage at the price of zero enforcement on
the new conventions; the slice records each unenforced convention's residual
honestly (O5 for the path, §4.3.2 for the inverse-rejection scope) rather than
implying enforcement it did not add.

**Pattern.** Tolerant Reader / additive schema evolution over a closed-world
validator — the unifying pattern beneath Stories #3, #4, and #5. The closed-world
checklist is the enabling mechanism; widen-and-mark is the strategy it makes safe.

---

## Cross-references — resolved summary

- **#1 → (none cited inward).** The owning-slice decision is the root; Stories #2,
  #4, and #7 all reference it as the discipline they inherit or re-apply.
- **#2 → O3, #1.** O3 forced the honest "non-collapsed (strictly spread)" floor that
  this story records as the chosen checkability level; #1 is the owner/consumer split
  whose discipline keeps the contract from claiming a snapshot-dependent check.
- **#3 → (no objection — round-1 resolved).** The `iff` trap is confirmed-resolved in
  the round-2 record's "Explicitly not objecting to" section, so no live O-id applies;
  the story records the decision, not a residual risk.
- **#4 → O5, #1.** O5 is the accepted residual (advisory consumer special-case, no
  enforcement) that this story records as the cost of the entrenchment; #1 is the
  ownership that licenses choosing entrenchment.
- **#5 → (no objection — round-1 resolved).** The `tier:` reserved-prefix grammar is
  confirmed-resolved (round-1 O6) in the not-objecting section; the story records the
  grammar-not-validator decision.
- **#6 → O1, #2.** O1 forced the re-derivation from two fixed rates (the defect that
  made the prior bands envelope-fitted); #2 is the deferred absolute-rate check that
  the re-derived example must pre-satisfy.
- **#7 → #1, #3.** #1 is the owner/consumer boundary this story re-applies to the
  emitter residue; #3 is the SHOULD whose falsifiable home is the deferred follow-on.
- **#8 → #3, #4, #5.** This is the coherence story over the three widen-and-mark
  fixes; it names the closed-world property as their shared enabling mechanism.
