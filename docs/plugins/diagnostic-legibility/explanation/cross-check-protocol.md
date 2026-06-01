# The cross-check protocol

At v0.4.0 the `diagnostic-legibility` agent adds **Phase C**, the
cross-check step that turns two individually-refined collections
into mutually-corrected ones. Where Phase B challenges each element
against its own evidence, Phase C uses each *collection* to challenge
the other.

This page covers the protocol design and why the agent ships in the
shape it does at v0.4.0.

## What Phase C does

After Phase B (per-element self-challenge) completes, the agent
re-frames itself once more and runs Phase C:

1. **Precondition check.** If one collection is empty (the
   `(empty scope)` sentinel on one side; the other side populated),
   skip Phase C and set the model-level `cross_check_status` field
   to `skipped_asymmetric`. The populated collection is still
   individually refined; Phase C does not run for asymmetric inputs
   at v0.4.0.
2. **A→D direction.** The architectural collection is the subject;
   the domain collection is the challenger. Iterate architectural
   elements in YAML order. For each subject, apply the five
   cross-check questions with **CC1 (boundary contradiction)
   weighted heavily**.
3. **D→A direction.** The domain collection is the subject; the
   architectural collection is the challenger. Iterate domain
   elements in YAML order. For each subject, apply the five
   cross-check questions with **CC5 (mutual description integrity)
   weighted heavily**.
4. **Subject-only audit trail.** A `CC<N>` entry is written on the
   subject element only. Side-effects on sibling elements are named
   in the subject's prose body, not appended as duplicate CC entries
   on the side-effect element.
5. **Emit-time ordering self-verification.** Before serialising, the
   agent verifies that every element's `challenge_notes[]` has
   `Q<N>` entries ordered before `CC<N>` entries; re-orders in
   place if needed.
6. **Set wrapper status.** `cross_check_status: completed` if Phase
   C ran on both collections; `skipped_asymmetric` if step 1
   triggered.

## The five cross-check questions

| # | Name | Catches | Heavy in |
| - | ---- | ------- | -------- |
| CC1 | **Boundary contradiction** | The subject's description assumes a boundary the other collection contradicts | A→D |
| CC2 | **Evidence overlap** | Two elements cite the same evidence file but describe contradictory things | — |
| CC3 | **Cross-confounders** | An element in the other collection looks similar by name but is semantically distinct | — |
| CC4 | **Cross-confidence calibration** | The subject's `confidence` is miscalibrated against the other collection's evidence base | — |
| CC5 | **Mutual description integrity** | The subject silently assumes something the other collection defines differently | D→A |

Each cross-check question targets a **cross-collection** failure
mode — an error that single-collection Phase B self-challenge cannot
catch because it requires reading both collections together.

## Direction-specific failure modes

The dimension-flavoured weighting (CC1 in A→D, CC5 in D→A) targets
two named cross-collection failure modes:

### A→D direction (CC1 weighted) — architectural-implicit assumption in domain description

A domain element whose description implicitly assumes architectural
behaviours the architectural collection does not commit to.

*Example.* The domain element `Credential` is drafted as "validated
through the AuthenticationService's issuance pipeline." The
architectural collection's `AuthenticationService` element describes
the service's responsibilities and explicitly names credential
validation and session issuance — but does not name an "issuance
pipeline" as a structural element. Phase B challenging `Credential`
against `Credential`'s own evidence (the codebase paths citing
Credential) would not surface this; only A→D cross-check, with the
architectural collection as challenger, can see that the domain
element's description implies architecture the architecture does
not commit to.

### D→A direction (CC5 weighted) — domain-concept smear in architectural element

An architectural element whose description silently conflates
infrastructure with domain meaning that the domain collection
explicitly defines.

*Example.* The architectural element `SessionStore` is drafted as
"stores user sessions." The domain collection's `Session` element
is explicit that a `Session` is the **authenticated artefact**
returned after successful credential validation — not the raw
storage record. The architectural element has smeared the storage
shape with the domain term. Phase B challenging `SessionStore`
against its own evidence (the storage code paths) would not surface
this; only D→A cross-check, with the domain collection as
challenger, can see that the architectural description silently
conflates the two layers.

## Why the schema gained a wrapper field

The original draft of S3 recorded the asymmetric-input case (Phase
C skipped because one collection was empty) by appending a
per-element sentinel to every element of the populated collection.
The diaboli surfaced two issues with this:

1. The sibling sentinel (`Cross-check skipped; only one collection
   present`) differed from the clean-run sentinel (`Cross-check
   applied; no questions surfaced changes`) only in one verb;
   downstream prefix-matching consumers would conflate them.
2. The fact recorded — *cross-check could not run on this model* —
   is a property of the whole model, not of any element. Recording
   it N times at element granularity is one fact per element for a
   one-fact-per-model situation.

The post-diaboli spec adopts a **granularity-routing** discipline:

- **Per-element facts** (vary across elements) go through the
  `challenge_notes[]` string-prefix convention (`Q<N>`, `CC<N>`,
  the `(empty scope)` element-name sentinel, the
  `Challenge applied; ...` and `Cross-check applied; ...`
  per-element clean-run sentinels).
- **Model-level facts** (apply to the whole record) go in an
  additive wrapper field on `LegibilityModel`. Phase C's outcome is
  the first such field: `cross_check_status` with three legal
  values (`completed`, `skipped_asymmetric`, `not_run`).

The field is additive — v0.3.0 outputs without the field are valid
against v0.4.0 consumers, with field-absence semantically meaning
`not_run`. The discipline is recorded as a paired-promoted
cartographer story (Stories #1 + #4, follow-up issue
[#347](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/347))
and is expected to govern future schema decisions across the
diagnostic-legibility plugin and its siblings.

## Subject-only audit trail

When a cross-check critique on subject X surfaces a side-effect
revision on sibling Y, the `CC<N>` entry is written on **X only**.
The side-effect on Y is named in X's prose body (e.g. "CC1
(boundary contradiction): clarified that AuthenticationService
handles session issuance only; surfaced a corresponding tweak to
Credential's description in the domain collection.").

The rule preserves the single-writer invariant: every CC entry has
exactly one author and exactly one subject. The audit trail becomes
a graph rooted at subjects — to know *why* Y's description changed
in a cross-check pass, a consumer follows back-references from X's
CC prose body rather than reading Y's `challenge_notes[]` in
isolation. This costs the downstream `/diagnose` rendering layer
some work but keeps the contract coherent (cartographer Story #3).

## The mode-marker contract

Two modes ship at v0.4.0:

- **`mode: full`** (default if no `mode:` line is given) — Phase A +
  Phase B + Phase C. This is the superset of v0.3.0 behaviour;
  v0.3.0 dispatchers get cross-check as a free upgrade.
- **`mode: cross-check-only`** — Phase C only, against a fenced YAML
  payload (a previously-emitted `LegibilityModel` in a
  ```` ```yaml ```` ... ```` ``` ```` block in the prompt body). The
  agent skips Phase A and Phase B and runs cross-check against the
  supplied YAML.

An earlier draft included `mode: construct-only` (Phase A + Phase B
only, the v0.3.0 behaviour exactly). The diaboli surfaced that no
named consumer existed for this mode — `mode: full` already preserves
v0.3.0 behaviour as a superset. The mode was dropped at adjudication
and can be re-added in the same PR as its first named consumer
(cartographer Story #2 / diaboli O2).

## Structured refusal contract

When an input violates a precondition, the agent emits a structured
refusal line and no YAML block:

```
diagnostic-legibility refusal: <single-sentence reason>.
```

Programmatic dispatchers pattern-match on "no YAML block + presence
of `diagnostic-legibility refusal:`" to route to error handling.

There is **no silent fallback** anywhere in the agent's protocol. A
mistyped mode value, an unfenced YAML payload in cross-check-only,
an unsubstituted `<DISPATCHER: ...>` placeholder, or an unrevised
input element with empty `challenge_notes[]` all trigger refusal.

This is the third time the project has reached this design point —
choice-cartographer's structured `cartograph_pending_count` over
prose narration, this spec's refusal on unrecognised modes, this
spec's unified precondition table. Promoted to a cartographer story
(#6, follow-up issue
[#348](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/348))
as a project-wide convention candidate.

## Two-layer ordering enforcement

The contract that `CC<N>` entries follow `Q<N>` entries in every
element's `challenge_notes[]` is enforced at two layers:

1. **Emit-time self-verification.** Step 6 of the cross-check
   algorithm — the agent verifies the ordering invariant on every
   element before serialising, and re-orders in place if needed.
2. **Fixture-based structural test.** A test in
   `tdad_tests/tests/test_diagnostic_legibility_structural.py`
   loads a deliberately-interleaved input and asserts the re-ordering
   produces canonical ordering.

Both layers verify the same invariant; neither subsumes the other.
The pairing is defence-in-depth applied to contracts (cartographer
Story #7).

One honest qualification: the structural-layer test asserts the
invariant against a *canonical-ordering definition* expressed in test
code, not against the agent's own emit-time re-ordering behaviour. It
confirms that canonical ordering is well-defined and that interleaved
input maps to it — a necessary property — but it cannot, at this layer,
invoke the agent (Layer 0/1 run offline, with no API key). Genuine
verification of the agent's re-ordering behaviour belongs at Layer 3
(behavioural tests) if and when those are added for
diagnostic-legibility. Until then, Layer 1 guards the definition and
the agent prompt (Step 6) guards the behaviour.

## What this slice does not do

- **Surface the models to a human.** A `/diagnose` command is the
  deliverable of parent S4,
  [#333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333).
- **Validate `LegibilityModel` instances at runtime.** The schema
  spec (v0.2.0) explicitly deferred this; the agent enforces the
  contract through its prompt, not through a separate validator.
- **Iterate the cross-check loop until convergence.** Single-pass
  per direction at v0.4.0; iteration can be added in a later slice
  if disposition data shows the single pass under-refines.

## Further reading

- [How to invoke the agent](../how-to/invoke-the-agent.md) —
  task-oriented dispatch guide, including mode markers and the
  cross-check-only payload format.
- [The challenge-refine protocol](challenge-refine-protocol.md) —
  Phase B (self-challenge), the prior context this slice builds on.
- `diagnostic-legibility/templates/legibility-element.md` (in the
  repository) — the schema, now including the `cross_check_status`
  wrapper field.
- [Sub-S3 design spec](../../../superpowers/specs/2026-05-29-dl-s3-cross-check-mechanism-design.md)
  — the full design record this protocol descends from, including
  the diaboli + cartographer adjudication trail.
