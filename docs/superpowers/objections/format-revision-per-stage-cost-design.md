---
spec: docs/superpowers/specs/2026-06-11-format-revision-per-stage-cost-design.md
date: 2026-06-11
mode: spec
diaboli_model: claude-opus-4-8[1m]
objections:
  - id: O1
    category: specification quality
    severity: high
    claim: "Example 2's per-stage bands are presented as a reproducible derivation from two representative-model rates, but they cannot be back-solved to two consistent per-model $/token rates: the spec-writer (opus) and tdd-agent (sonnet) bands imply per-token rates that disagree with the very sonnet/opus rates the implementer band defines, so the worked example demonstrates a number-fitting to the sum envelope, not a rate-grounded widening."
    evidence: "§4.5 step 1 fixes sonnet=4.0e-6, opus=2.0e-5 from the implementer band. But spec-writer (Most capable/opus) implies 0.35/50000=7.0e-6 (low) and 1.50/100000=1.5e-5 (high) — neither equals opus 2.0e-5; tdd-agent (Standard/sonnet) implies 0.20/50000=4.0e-6 (low) and 1.00/150000=6.67e-6 (high) — the high exceeds sonnet 4.0e-6. The bands were allocated to hit {0.95,7.50} (§4.5 step 2), not computed from the two fixed rates."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Re-derive Example 2's three bands from two FIXED per-tier
      rates: each single-tier stage = its tier's rate × its token range; the
      split implementer = sonnet rate × low-tokens, opus rate × high-tokens. Let
      the per-stage sums land where they land and set the whole-record cost_usd
      to match (the correlation note permits ≠ envelope). The canonical example
      must PASS the absolute-rate validator S3 is told to build.
  - id: O2
    category: implementation
    severity: medium
    claim: "The 'Split-tier spread' check relies on a validator knowing a stage's model_tier is a 'split tier' by matching a slashed label, but the field reference permits the split label to be written either 'Standard/Capable' or 'Standard / Capable' and the binding table names a tier ('Capable') that does not exist as a standalone model — a record-internal validator has no closed list of which slashed labels are split tiers, so the check's trigger condition is under-specified."
    evidence: "§4.4 check keys on 'a slashed label such as Standard / Capable, normalised whitespace-insensitively per the join key'; reference line 30 writes the example label as 'Standard/Capable'; reference lines 148-151 state there is 'no standalone Capable tier'. The check names only one example split label, not an enumerated closed set the validator tests against."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. State the split-tier trigger as a CLOSED rule (a model_tier
      is a split tier iff its label contains "/" after the join-key
      normalisation; confirm no single-tier label contains a slash), not an
      example.
  - id: O3
    category: specification quality
    severity: medium
    claim: "The §4.4.1 CAN/CANNOT note honestly disclaims absolute-rate checking, but §1, §2, FR-3b, and the story title still describe the deliverable as making 'the WIDENING machine-checkable', when the check delivered (a strictly-positive ordered spread) only proves the band is non-collapsed — a {0.01, 99.0} implementer band passes while bearing no relation to a genuine two-tier widening, so the headline framing still over-claims relative to what the check earns."
    evidence: "§4.4 check-3 header: 'Split-tier spread (the O3 headline — makes the WIDENING, not just the band's presence, machine-checkable)'; FR-3b: 'the validator CAN assert a split-tier band spans two tiers'; §4.4.1 concedes the validator 'CANNOT assert ... the spread's magnitude is correct' and that a '{99.0,100.0} band still passes'. 'Spans two tiers' and 'passes any non-collapsed ordered band' are not the same claim."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Align FR-3b, the check-3 header, and the §11.1 story to
      §4.4.1's honest floor: the validator asserts a "non-collapsed
      (strictly-spread) split-tier band", NOT that it "spans two tiers" or makes
      the widening fully "machine-checkable". Every surface agrees with §4.4.1.
  - id: O4
    category: specification quality
    severity: low
    claim: "The 'Split-tier spread' check states the band 'prices its low bound at the cheaper representative model and its high bound at the dearer one (per the binding table)', asserting a low=cheaper/high=dearer ordering the validator cannot actually verify from the record — the validator sees only two numbers and their order, never which end binds to which model, so the binding-table sentence describes an emitter convention but reads as if it were a checkable invariant."
    evidence: "§4.4 check-3: 'A split-tier stage prices its low bound at the cheaper representative model and its high bound at the dearer one (per the binding table ...), so a genuine widening must produce a non-zero spread.' §4.4.1 confirms the validator CANNOT assert the bounds equal the rates — so 'cheaper at low, dearer at high' is unverifiable from the record alone."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. In the checklist line state ONLY what the check tests
      (low < high on split-tier bands); move the cheaper-at-low/dearer-at-high
      rationale into the methodology prose, where it is an emitter convention,
      not a checked invariant.
  - id: O5
    category: risk
    severity: low
    claim: "The grounding-path consumer special-case ('an aggregator must not count a cost-snapshot entry whose path ends in / as a grounding') is documented prose with no validation-checklist enforcement, so the same closed-world-silence argument used to prove backward-compat also guarantees nothing ever catches an aggregator that ignores the special-case — the de-duplication rule is advisory only."
    evidence: "§6.1 consumer special-case is stated in the grounding_sources description prose; §2.3 confirms 'no path-must-be-a-file check'; the validation checklist (§4.4) adds only the per-stage coupling and spread lines, none keying on grounding path shape. The trailing-slash convention is a parsing instruction, not an enforced check."
    disposition: accepted
    disposition_rationale: >
      Accepted as a noted residual. The trailing-slash consumer special-case
      stays advisory (no checklist enforcement is added); record in the spec that
      it externalises a silent-miscount risk onto downstream counters (S3 and any
      cost aggregator), consistent with the deliberate keep-the-directory-sentinel
      trade. No further change required in this slice.
---

## O1 — specification quality — high

### Claim

Example 2 is the single artefact that demonstrates the whole per-stage widening
mechanism, and §4.5 presents its three bands as a "reproducible, not invented"
derivation grounded in two representative-model `$/token` rates. But the three
bands cannot be reproduced from two consistent per-model rates. They were
back-solved to make the per-stage sums hit the whole-record envelope
`{ 0.95, 7.50 }` exactly (§4.5 step 2), and the resulting per-token rates for the
two single-tier stages contradict the sonnet/opus rates the implementer band
defines. The worked example therefore demonstrates *arithmetic that sums*, not
*a widening grounded in two snapshot rates* — which is the property the slice
claims to make checkable.

### Evidence

§4.5 step 1 fixes the two rates from the implementer band:

> cheaper-tier (sonnet) low bound `0.40 ÷ 100000 = 4.0e-6` $/token; dearer-tier
> (opus) high bound `5.00 ÷ 250000 = 2.0e-5` $/token.

Now apply those fixed rates to the other two stages' tiers:

- **spec-writer** is `Most capable` → `claude-opus-4`, so every per-token figure
  should be the opus rate `2.0e-5`. Its band `{0.35, 1.50}` over tokens
  `{50000, 100000}` implies `0.35 ÷ 50000 = 7.0e-6` (low) and
  `1.50 ÷ 100000 = 1.5e-5` (high). **Neither equals opus `2.0e-5`.**
- **tdd-agent** is `Standard` → `claude-sonnet-4`, so every per-token figure
  should be the sonnet rate `4.0e-6`. Its band `{0.20, 1.00}` over tokens
  `{50000, 150000}` implies `0.20 ÷ 50000 = 4.0e-6` (low — matches) and
  `1.00 ÷ 150000 = 6.67e-6` (high — **exceeds sonnet `4.0e-6`**).

§4.5 step 3 ("Tier-ordering sanity") only checks that opus figures are *greater
than* sonnet figures — which they are — but that is a far weaker property than
"each stage's band is its tier's single rate applied to its token range." The
spec's own §4.5 step 2 admits the construction: "allocated so the per-stage sums
hit the whole-record envelope `{ 0.95, 7.50 }` exactly."

### Why this matters

The round-1 O3 disposition demanded the slice "deliver the S1-O6 checkability the
slice exists for; do not settle for 'a place to put the band.'" The revision
answered with a record-internal spread check (defensible) *and* a worked example
billed as a reproducible derivation. But if Example 2 — the reference's own
demonstration of a correctly-priced widening — does not itself hold to "one rate
per tier applied to the token range," then a future S3 author who builds the
absolute-rate validator (the half deferred to S3 per §4.4.1) will find the
reference's canonical cost-present example *fails* that validator: spec-writer's
opus stage prices below the opus rate the same example declares. The example
that teaches the widening cannot be the example that breaks the deferred check.
Either the bands must be re-derived from two fixed per-tier rates (accepting the
sum will not land on `{0.95, 7.50}` exactly, which the correlation note already
permits), or §4.5 must stop calling the bands a rate-grounded derivation and
admit they are an envelope-fit chosen for arithmetic tidiness.

## O2 — implementation — medium

### Claim

The "Split-tier spread" check fires only on stages whose `model_tier` "is a split
tier (a slashed label)". For a record-internal validator to apply the check, it
must decide *which* labels are split tiers. The reference gives it only one
example label and a normalisation rule, not a closed set — and the one split tier
that exists names a phantom tier (`Capable`) with no standalone model. A validator
cannot reliably distinguish "a split tier that must have a strict spread" from "a
single tier that may collapse" without an enumerated list the reference does not
provide.

### Evidence

The check (§4.4, check-3):

> for **every present** `tokens_by_stage[].cost_usd` whose `model_tier` is a
> **split tier** (a slashed label such as `Standard / Capable`, normalised
> whitespace-insensitively per the join key) ...

The reference writes the label two ways — `Standard/Capable` (line 30, field
table) and `Standard / Capable` (line 146, binding table) — and states (lines
148-151) that `MODEL_ROUTING.md` "names exactly two tiers ... and one
complexity-dependent split" with "**no** standalone `Capable` tier." So "is it a
split tier?" reduces to "does the label contain a slash?" — but that heuristic is
asserted nowhere as the closed rule; the check says "such as," which is an example,
not a definition.

### Why this matters

The whole point of FR-3b is that a *collapsed* split-tier band fails while a
single-tier band may collapse. That distinction is only as strong as the
validator's ability to classify a label as split-or-not. If the trigger is "label
contains `/`," the spec should say so as a closed rule (and confirm no single
tier ever contains a slash); if it is "label appears in an enumerated split-tier
set," the set must be named. As written, the check's firing condition is an
example, which is exactly the kind of ambiguity that yields divergent validators
— one treating any slashed label as split, another requiring an exact match
against `Standard / Capable`.

## O3 — specification quality — medium

### Claim

§4.4.1 is an honest CAN/CANNOT note, and it materially narrows the over-claim
that round-1 O3 flagged. But the *headline framing* the note is meant to discipline
still survives intact elsewhere: §4.4's check-3 header, FR-3b, and the §11.1 story
all describe the deliverable as making "the WIDENING machine-checkable" and the
validator able to assert a band "spans two tiers." The check actually delivered
proves only that the band is *not collapsed*. The note rescues the honesty locally
while the load-bearing section headers still say more than the check earns.

### Evidence

§4.4 check-3 header:

> **Add one new check line — "Split-tier spread" (the O3 headline — makes the
> WIDENING, not just the band's presence, machine-checkable)**

FR-3b: "the validator CAN assert a split-tier band spans two tiers (positive
ordered spread, cheaper at low per the binding table)".

§4.4.1 then concedes the limit:

> A `{ 99.0, 100.0 }` band still *passes* `low < high` ... The validator
> **CANNOT** assert ... the spread's magnitude is *correct*.

"Spans two tiers" (FR-3b) and "passes for any non-collapsed ordered band, including
`{99.0, 100.0}`" (§4.4.1) are not the same claim. The first implies a relationship
to the two rates; the second is satisfied by any two distinct ascending numbers.

### Why this matters

This is the precise crux the round-1 disposition asked to be judged: did the slice
"quietly redefine machine-checkable widening down to non-collapsed band"? §4.4.1
answers honestly in one place — but a reader who reads §1, §2, the FR list, or the
user story (the surfaces most likely to be quoted downstream) still comes away
with "the widening is machine-checkable." The fix is small: make the FR-3b and
check-3 language say "a non-collapsed (strictly-spread) split-tier band" rather
than "spans two tiers," so every surface agrees with §4.4.1's honest floor. Left
as-is, the slice's own summary sections re-introduce the over-claim §4.4.1 was
written to retire.

## O4 — specification quality — low

### Claim

The "Split-tier spread" check sentence asserts the band "prices its low bound at
the cheaper representative model and its high bound at the dearer one (per the
binding table)." Read as part of a *validation* check, this implies the validator
verifies low-binds-to-cheaper / high-binds-to-dearer. It cannot: the validator
sees two numbers and their order, never which end was priced by which model.
§4.4.1 correctly says so, but the check line itself reads as if the ordering were
a checked invariant rather than an emitter convention the check cannot confirm.

### Evidence

§4.4 check-3:

> A split-tier stage prices its low bound at the **cheaper** representative model
> and its high bound at the **dearer** one (per the binding table — for
> `Standard / Capable`, `claude-sonnet-4` is the cheaper tier and `claude-opus-4`
> the dearer), so a genuine widening **must** produce a non-zero spread.

§4.4.1, by contrast:

> The validator **CANNOT** assert: that the absolute `low`/`high` **equal** the
> specific `claude-sonnet-4`/`claude-opus-4` rates.

If the validator cannot tie either bound to a model rate, it equally cannot
confirm "cheaper at low, dearer at high" — that ordering is unverifiable from the
record. The only thing the check verifies is `low < high`.

### Why this matters

This is low severity because §4.4.1 states the true boundary plainly, so a careful
reader is not misled. But the check-line prose mixes an emitter-side convention
("price low at the cheaper model") into the *checklist*, which is the section the
reference explicitly says is "parsed, not read loosely" (reference line 10). A
checklist line that describes behaviour the check does not perform invites a future
maintainer to "complete" it into the absolute-rate check §4.4.1 deliberately
defers to S3. Cleanest to state in the check line only what the check tests
(`low < high` on split-tier bands) and relocate the cheaper/dearer rationale to
the methodology prose, where it is a convention, not a check.

## O5 — risk — low

### Claim

The grounding-path resolution leans on a consumer special-case — an aggregator
"must not count a `cost-snapshot` entry whose `path` ends in `/` as a grounding" —
that lives entirely in description prose with no checklist enforcement. The same
closed-world-silence property the spec uses to prove backward-compatibility also
guarantees that nothing ever detects a consumer that ignores the special-case.
The de-duplication rule is therefore advisory, and a non-conforming aggregator
silently miscounts non-groundings as groundings with no validation signal.

### Evidence

§6.1 consumer special-case:

> an aggregator that counts "how many records were grounded in a cost snapshot"
> **must not** count a `cost-snapshot` entry whose `path` ends in `/` as a
> grounding.

§2.3 confirms the slice adds "no ... `path`-must-be-a-file check," and the
validation-checklist edits (§4.4) add only the per-stage coupling and spread
lines. No check keys on `grounding_sources[].path` shape. The special-case is a
parsing instruction to future consumers, not an enforced invariant.

### Why this matters

This is low severity and largely unavoidable given the deliberate (and correct)
choice to keep the directory-path sentinel rather than invent a new token —
O5/round-1 already accepted that trade and the spec now names the entrenchment
honestly. The residual note is that the *cost* of the entrenchment (every
snapshot-counting consumer must implement the trailing-slash special-case, with
nothing to catch one that does not) is borne by consumers the slice does not
control, including the S3 checkpoint and any future cost aggregator. Worth the
human noting that "named and accepted" entrenchment still externalises a silent
miscount risk onto every downstream counter, since this is the kind of overloaded
field a later reader will mis-handle precisely because no check guards it.

## Explicitly not objecting to

- **O1/round-1 (the `iff`) — confirmed resolved.** §4.1 removes `iff` from the
  field table and states the one-directional asymmetry there (sub-field present ⟹
  top-level cost present; reverse is an emitter SHOULD), and FR-1 matches; a literal
  reader can no longer tighten it into the class-B-breaking mandate.
- **O2/round-1 (under-specified Example 2) — confirmed resolved.** §4.5 now fixes
  all three bands concretely; the values are no longer discretionary (my O1 above
  challenges their *derivation*, not their *presence*).
- **The sum arithmetic — confirmed correct.** Low `0.35+0.20+0.40 = 0.95` and high
  `1.50+1.00+5.00 = 7.50` both equal the whole-record `{0.95, 7.50}` exactly, every
  band has `low ≤ high`, and the implementer split-tier band satisfies the strict
  spread (`0.40 < 5.00`); I do not challenge the envelope math, only what it claims
  to ground (O1).
- **O4/round-1 (SHOULD falsifiable home) — confirmed resolved.** §4.3.1 gives the
  SHOULD a falsifiable home (the deferred §12 emitter issue's acceptance criterion)
  and an honest scope note; it is now distinguishable from a MAY.
- **O5/round-1 (entrenchment named) — confirmed resolved.** §6.1 explicitly states
  the directory sentinel "entrenches an overloaded meaning, deliberately" rather
  than claiming the tension is resolved (my O5 above only flags that the
  special-case is unenforced).
- **O6/round-1 (`tier:` reserved prefix) — confirmed resolved.** §5.1 defines
  `tier:` as a reserved provenance prefix giving consumers a total mechanical
  discriminator without a rejecting check; the parse ambiguity is closed.
- **O7/round-1 (delivered-vs-deferred honesty) — confirmed resolved.** §8 cleanly
  separates what structural inspection delivers from what an actual parser run
  would falsify (deferred to S3); "demonstrated" is no longer over-claimed.
- **O8/round-1 (inverse-rejection scope note) — confirmed resolved.** §4.3.2
  records that the inverse-rejection rule guards a not-yet-producible shape and is
  kept as a cheap guard rail for S3-era emitters.
- **The decision to defer absolute-rate checking to S3 (§4.4.1)** and **no S2 agent
  change in this slice (§7)** — both the correct decomposition, unchanged from
  round 1.
