# Diagnostic Legibility — S3 — Cross-check mechanism for mutual model correction — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-05-29 |
| Status | Draft (revised post-diaboli, 2026-06-01) |
| Author | claude-opus-4-7[1m] (interactive session with russmiles) |
| Slice | S3 of the parent slicing record at `docs/superpowers/slices/diagnostic-legibility-plugin.md` (lines 53–93, 137–153) |
| Parent issue | [#332](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332) (Diagnostic Legibility — S3: Cross-check mechanism for mutual model correction) |
| Plugin version target | `diagnostic-legibility` v0.3.0 → v0.4.0 |
| Marketplace listing | Unchanged at v0.4.0; `plugin_version` (pointer to `ai-literacy-superpowers`) taken from main at integration time per §9 |
| PR ceremony | feature — full `/diaboli` (spec + code) and `/choice-cartograph` |
| Related work | S1 shipped (PR #334, scaffold v0.1.0); sub-S2a shipped (PR #336, schema v0.2.0); sub-S2b shipped (PR #341, working agent v0.3.0). S3 ships the cross-check that turns two individually-refined collections into a mutually-corrected `LegibilityModel`. S4 (issue #333) — the human-facing `/diagnose` command — remains out of scope here. |
| Diaboli adjudication | `docs/superpowers/objections/dl-s3-cross-check-mechanism-design.md` (10 objections, all accepted; see §0). |

---

## 0. Diaboli absorption

This spec was reviewed under spec-mode `/diaboli` on 2026-06-01. Ten
objections were raised (5 high, 4 medium, 1 low) and all ten accepted.
The dispositions are absorbed into the sections named below. The
objection record at `docs/superpowers/objections/dl-s3-cross-check-mechanism-design.md`
remains the authoritative audit trail.

| ID | Category | Section(s) updated |
| --- | --- | --- |
| O1 | premise | §3.4 — direction-specific failure modes named (architectural-implicit assumption in domain description; domain-concept smear in architectural element). |
| O2 | scope | §2.4, §3.7, §4.4, §6, §7.2 — `mode: construct-only` dropped. Two modes ship: `full` (default) and `cross-check-only`. |
| O3 | implementation | §3.5, §4.3, §5.2 — subject-only audit trail. Side-effect revisions named in the subject element's prose body, not appended on the side-effect element. |
| O4 | implementation | §3.5, §3.6 — per-element `Cross-check skipped` sentinel removed. Asymmetric-input status lives at model level per O9. CC-applied sentinel stays (genuine per-element evidence). |
| O5 | implementation | §4.3, §7.2 — agent self-verifies ordering at emit time; structural test loads an interleaved fixture and asserts canonical ordering. |
| O6 | implementation | §3.7 — unrecognised `mode:` values refused with a structured refusal line. No silent fallback. |
| O7 | specification quality | §3.6 — precondition-violation table with three response classes (asymmetric → model-level status; missing field / unrevised / placeholder → refusal; unrecognised mode → refusal). |
| O8 | specification quality | §2.1, §2.4 — fenced YAML payload required for `cross-check-only`; unsubstituted `<DISPATCHER: ...>` placeholders are a precondition violation. |
| O9 | alternatives | §2.2, §3.6, §7.2 — `cross_check_status: completed \| skipped_asymmetric \| not_run` added to the `LegibilityModel` wrapper. Additive to v0.2.0. Template at `diagnostic-legibility/templates/legibility-element.md` updated. |
| O10 | specification quality | §4.3 — within-direction iteration in subject-collection YAML order; preserved in CC entries. Paired with O5's structural test. |

The plugin version bump (0.3.0 → 0.4.0) is unaffected: O9's schema
change is **additive** (no break to v0.3.0 outputs) and O2's
mode-contract simplification **removes** surface area rather than
adding it.

---

## 1. Premise

Sub-S2b shipped the working `diagnostic-legibility` agent at v0.3.0
([PR #341](https://github.com/Habitat-Thinking/ai-literacy-superpowers/pull/341)).
The agent now takes a codebase scope, drafts an architectural
collection and a domain collection of `LegibilityElement`s, runs a
five-question self-challenge in an explicit adversarial Phase B with
fresh-sub-context posture, and emits a complete `LegibilityModel` YAML
block with `challenge_notes[]` on every element. The schema is
unopinionated about the string content of those notes — by design, so
that later phases can extend the field without breaking the contract.

What is still missing is the **cross-check step**. The two refined
collections inside the v0.3.0 `LegibilityModel` are *individually*
strong: each element has been self-challenged through the five
questions in an adversarial posture. They have not yet been used to
challenge **each other**. An architectural element that claims
"the `Order` aggregate owns the cart-to-order transition" has not
been confronted with the domain element that frames `Order` as a
finalised purchase intent distinct from `Cart`. A domain element that
describes `Session` as "the authenticated artefact" has not been
confronted with the architectural element that draws `SessionStore`
and `AuthenticationService` as separate moving parts.

The parent task's stated outcome — *mutually-corrected models* — is the
deliverable of this slice. The agent (or whatever combination of agents
and orchestration this slice decides on) must take a v0.3.0
`LegibilityModel` as input and emit a mutually-corrected
`LegibilityModel`: the two collections still present, refined further
where one collection's evidence challenged the other's framing, with
cross-check evidence retained on each affected element.

The decision focus this slice owns is the **architecture of the
cross-check mechanism**: how many agent dispatches, how state moves
between them, when to stop, and where the cross-check evidence lives
inside the existing schema. Four candidate architectures are weighed
in §3; one is selected with substantive rationale.

What this slice deliberately does **not** own:

- **Surfacing the corrected model to a human.** That is the work of
  parent S4 / [issue #333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333),
  which delivers the `/diagnose` command. The cross-check produces a
  YAML block; how a human reads it is S4's contract.
- **A `/diagnose` slash-command wrapper.** Same reason. At v0.4.0 the
  cross-check is dispatched by the same bare-Task-tool pattern as the
  v0.3.0 self-challenge.
- **An iterative cross-check loop.** §3.3 weighs and defers this; the
  ship is single-pass mutual cross-check. Escalation to a loop remains
  available without breaking the schema or the external contract.
- **A runtime validator for `LegibilityElement` or `LegibilityModel`.**
  Sub-S2a deferred this, sub-S2b did not change the deferral, and S3
  does not change it either.

## 2. The cross-check's contract

### 2.1 Input

A `LegibilityModel` instance produced by the v0.3.0
`diagnostic-legibility` agent, conforming to the schema at
`diagnostic-legibility/templates/legibility-element.md`. Required
shape:

- `scope`, `generated_at`, `generated_by` populated.
- In `mode: full`, the `<DISPATCHER: ISO 8601 timestamp>` and
  `<DISPATCHER: active model identifier>` placeholders may pass
  through unchanged (Phase A emits them; the dispatcher substitutes
  on persist).
- In `mode: cross-check-only`, **any unsubstituted
  `<DISPATCHER: ...>` placeholder in `generated_at` or `generated_by`
  is a precondition violation** (O8). Round-trip discipline requires
  the dispatcher to substitute placeholders before resubmitting; this
  is precisely the v0.3.0 contract for those placeholders as
  dispatcher-fill markers, not durable values. The failure shape is
  documented in §3.6.
- `architectural[]` and `domain[]` each present; at least one
  non-empty.
- Every element in either collection carries a non-empty
  `challenge_notes[]` — either one or more `Q<N> (question-name):`
  entries (the canonical lowercase form per sub-S2b §3.5) or the
  single sentinel `Challenge applied; no questions surfaced changes`.

Precondition violations are handled per the unified table in §3.6:
the **asymmetric** case (one collection populated, the other empty)
records a model-level `cross_check_status: skipped_asymmetric` and
still emits a full YAML block; every other violation refuses with a
structured refusal line and emits **no YAML block**.

### 2.2 Output

A single markdown response containing a `LegibilityModel` instance
serialised as YAML, conforming to the v0.2.0 schema with one
**additive** extension: the wrapper carries a new
`cross_check_status` field with one of three legal values
(O9):

| Value | Meaning |
| --- | --- |
| `completed` | Phase C ran in full against both collections; per-element CC<N> entries and/or the CC-applied sentinel record what it found. |
| `skipped_asymmetric` | Phase C was a no-op because exactly one collection was non-empty. The rest of the model is valid v0.3.0 output. |
| `not_run` | Phase C did not run. Reserved for v0.3.0-compatible outputs and the `mode: full` invocation where Phase C is bypassed by a future explicit opt-out. At v0.4.0 the agent itself only emits `completed` or `skipped_asymmetric`; consumers should treat the field's absence as `not_run` for backwards-compatibility with v0.3.0 outputs. |

The field is **optional** under the schema (so v0.3.0 outputs without
it remain valid against v0.4.0 consumers); v0.4.0 agent outputs
always include it. The schema template at
`diagnostic-legibility/templates/legibility-element.md` is updated to
document the new field (see §7.2).

The differences from the input are otherwise confined to
`challenge_notes[]` on individual elements:

- Where the cross-check surfaced a correction, a new entry is
  appended on the **subject** element with a `CC<N>` prefix (§3.2).
  Subject-only audit trail: when a critique on subject X surfaces a
  side-effect revision on sibling Y, the side-effect is **named in
  X's prose body**; Y's `challenge_notes[]` is not amended (O3).
- Where the cross-check ran cleanly on an element, the cross-check
  sentinel `Cross-check applied; no questions surfaced changes` is
  appended.
- Where the cross-check did not run (asymmetric input — see §3.6),
  per-element `challenge_notes[]` is **left unchanged**; the no-op is
  recorded at the model level via `cross_check_status:
  skipped_asymmetric`.

The dispatcher persists the output the same way it did at v0.3.0 —
the agent does not write files. This continues the *agent-emit +
dispatcher-persist + human-disposes* pattern named in
AGENTS.md ARCH_DECISIONS.

### 2.3 Trust boundary

`Read`, `Glob`, `Grep`. No `Write`, no `Edit`, no `Bash`. Identical to
v0.3.0. The cross-check needs to re-inspect the codebase scope to
re-evaluate evidence claims; it does not need write or shell.

### 2.4 Invocation surface at v0.4.0

At v0.4.0 there is still no `/diagnose` slash-command (that is parent
S4 / #333). The cross-check is dispatched the same way the v0.3.0
self-challenge is: bare `Task` tool with `subagent_type:
diagnostic-legibility` and an explicit mode marker in the prompt.

Two modes ship at v0.4.0 (O2):

- **`mode: full`** — run Phase A (construction) and Phase B
  (self-challenge) from v0.3.0, then Phase C (cross-check) against the
  freshly-built collections. This is the new default when invoked
  without an explicit mode marker. `mode: full` is a strict superset
  of v0.3.0 behaviour: a dispatcher that does not know about
  cross-check still gets a working two-collection output, with
  cross-check evidence as a free upgrade.
- **`mode: cross-check-only`** — read a supplied `LegibilityModel`
  YAML, run only Phase C against it, and emit the cross-checked YAML.
  Used when the v0.3.0 output has already been persisted and the
  dispatcher wants to add cross-check evidence without re-running
  construction.

Absent any `mode:` line, the prompt is interpreted as `mode: full`.

**Payload shape for `cross-check-only`** (O8). The supplied
`LegibilityModel` YAML **must** appear as a single fenced code block
immediately after the `mode: cross-check-only` line:

````text
mode: cross-check-only

```yaml
scope: "./src/auth/"
generated_at: "2026-05-29T10:14:00Z"
generated_by: "diagnostic-legibility / claude-opus-4-7[1m]"
architectural:
  - ...
domain:
  - ...
```
````

The following payload shapes are **rejected** (precondition violation
per §3.6, class (b)):

- Prose-surrounded YAML (any non-whitespace text between the `mode:`
  line and the fenced block, or between the closing fence and the end
  of the prompt body).
- Inline / unfenced YAML.
- Multiple YAML code blocks (the first one wins is **not** the rule;
  the agent refuses).

A v0.3.0 dispatcher that wants the v0.3.0 output exactly (no
cross-check notes) is **not** supported at v0.4.0. The choice in
adjudication (O2) was to drop `mode: construct-only` rather than ship
a third surface with no named consumer; if a v0.3.0-exact consumer
materialises later, the construct-only mode can be added in the same
PR as that consumer. The `mode: full` superset semantics mean
existing dispatchers see cross-check as an upgrade, not a break.

A `/diagnose` slash-command that wraps these modes and chooses for the
human lands in parent S4. The how-to page in this slice (§7.1)
documents both mode markers as the v0.4.0 invocation surface and
links forward to #333 for the eventual command surface.

## 3. The cross-check mechanism — decision

The decision focus of this slice. Four candidate architectures, named
in the parent slicing record (lines 137–153) and elaborated below.
One is selected; the others are weighed.

### 3.1 The four candidates

**(a) Single-pass within the existing agent's Phase B.** Add a Phase
C "cross-check" after Phase B challenges in the same
`diagnostic-legibility` agent dispatch. One agent file, three phases,
one set of YAML output. Lowest surface change: no new agent file, no
new docs quadrant, no orchestrator wiring. The cross-check shares the
agent's trust boundary, model, and prompt context with construction
and self-challenge.

**(b) Single-pass structured comparison via a separate agent
(`diagnostic-legibility-cross-check`).** New agent file, takes the
v0.3.0 `LegibilityModel` YAML as input, emits cross-check notes per
element. Mirrors the read-only-emitter pattern (Read/Glob/Grep). The
dispatcher hands the second agent the first agent's output;
cross-check runs in a separate context with separate framing. Larger
surface (two agent files, two prompts to maintain) but cleaner
separation between "construct + self-challenge" and "cross-check".

**(c) Iterative loop within one agent.** Challenge → revise →
cross-check → re-revise → re-cross-check until stable or budget
exhausted. Highest quality ceiling. Carries a stopping-condition
sub-decision (token budget? change-rate threshold? fixed iteration
count?), variable cost, and a debugging surface that grows with
iteration count. The v0.3.0 spec (sub-S2b §3.2) explicitly deferred
iteration on the self-challenge for the same reasons; the same
reasoning applies again to cross-check.

**(d) Multi-pass within the orchestrator.** The orchestrator
dispatches sub-agents twice with different framing — one for each
direction (architectural critiques domain; domain critiques
architectural) — then merges the outputs. Orchestrator-level state
management. Maximally explicit about the asymmetry of the two
critique directions, but at v0.4.0 there is no orchestrator agent for
diagnostic-legibility — the dispatcher is either a human or a
generic Task-tool invocation. Building one for this slice is new
surface area without a clear consumer.

### 3.2 Selected: (a) single-pass Phase C within the existing agent

The cross-check ships as **Phase C** inside the existing
`diagnostic-legibility` agent file. The agent's construction protocol
grows from two phases to three; everything else stays the same.

**Why (a) over (b).** The cleaner separation in (b) sounds attractive
but the cost is twice the agent-file surface — two prompts to keep in
sync about the same schema, the same evidence model, the same
sentinel conventions. The v0.3.0 spec (sub-S2b §3.4) made an
equivalent decision when it picked **fresh-sub-context self-challenge
within one agent** over a separate `diagnostic-legibility-challenger`
agent. The same reasoning applies here: the *independence* the
cross-check needs comes from explicit re-framing inside the prompt
(Phase C's framing line, §4.3), not from a second agent file. The
escalation path from (a) to (b) — split into two files if disposition
data shows Phase C degenerates to rubber-stamping the construction —
remains available without breaking the schema or the external
contract. The conservative move is to ship (a) first.

**Why (a) over (c).** Iteration adds variable token cost and a
stopping-condition sub-decision. At v0.4.0 there is no measured signal
that a single mutual cross-check under-corrects. The schema
accommodates iteration without breaking — Phase C can be run twice in
a future slice by appending a second `CC<N>` block per element — so
the loop architecture is not foreclosed by shipping single-pass first.
The same reasoning sub-S2b §3.2 used for the self-challenge loop
applies again here: ship single-pass, observe a handful of real
invocations, decide whether the loop earns its keep on evidence.

**Why (a) over (d).** Orchestrator-level multi-pass would require
building an orchestrator for diagnostic-legibility, which at v0.4.0
does not exist. The dispatcher is a bare Task-tool invocation or a
human. Option (d) is therefore a prerequisite-adding move:
"build an orchestrator first, then do the cross-check inside it" is
strictly more work than "do the cross-check inside the agent that
already exists". The asymmetric-direction concern (d) is trying to
solve — architectural critiques domain ≠ domain critiques
architectural — is addressed in (a) by **direction-flavoured
weighting** inside Phase C, mirroring sub-S2b's dimension-flavoured
weighting in Phase B (§3.4 below). The directional asymmetry is
operationalised within one agent without a separate dispatch.

**The named failure mode for (a) is rubber-stamping.** The same model
that just argued for the v0.3.0 output may, in the same context,
defend it against the cross-check. The v0.3.0 spec named this as the
core risk for single-context challenge work and solved it with the
fresh-sub-context posture (sub-S2b §3.4). The same mechanism applies
here: Phase C begins with an explicit re-framing instruction that
names the cross-check as **separate work** from construction and
self-challenge, and the agent is instructed to disagree where the
evidence allows (§4.3). The mechanism is the same; only the framing
content differs (cross-collection mutual challenge rather than
per-element self-challenge).

### 3.3 Schema impact — `CC<N>` prefix plus one additive wrapper field

The v0.2.0 schema is **unopinionated about the string content of
`challenge_notes[]`**. Sub-S2b exploited this by establishing the
`Q<N> (question-name):` prefix convention for self-challenge notes
without changing the schema. S3 continues to exploit that affordance
for per-element evidence — the cross-check appends entries to the
existing `challenge_notes[]` field with a `CC<N>` prefix — and
introduces one **additive** wrapper field, `cross_check_status`, on
the `LegibilityModel` (not on `LegibilityElement`) to carry the
**model-level** fact "Phase C did / did not / could not run" (O9).

**Why the prefix-on-existing approach for per-element notes.** Three
reasons:

1. **The schema is the contract for two downstream consumers** — the
   cross-check (this slice) and the surfacing command (S4, #333). If
   S3 reshaped `LegibilityElement`, S4 would have to be re-planned
   against the new shape. Keeping `challenge_notes[]` as the single
   accumulator field means S4 can pattern-match by prefix (`Q<N>` for
   self-challenge, `CC<N>` for cross-check, sentinels for clean runs)
   without caring whether the schema grew.

2. **The schema already encodes the contract through sentinels.**
   The v0.3.0 self-challenge protocol distinguishes "challenge ran
   cleanly" (sentinel) from "challenge never ran" (empty list). The
   same disambiguation device works for cross-check at the
   per-element layer: the CC-applied sentinel records the
   ran-cleanly-on-this-element case (§3.5).

3. **A new per-element field would split the audit trail.** Today,
   a human or downstream consumer reading one element sees the
   complete history of how the element was challenged in one list. A
   separate `cross_check_notes[]` field would force consumers to
   interleave two lists to reconstruct the same history. The
   single-list shape is the simpler audit surface.

**Why the additive wrapper field for the model-level fact** (O9).
The fact "Phase C ran / was skipped / did not run" applies to the
*whole model*, not per-element. Recording it as a per-element
sentinel would repeat model-level information at element granularity
(N records per model for one fact). The wrapper-field alternative
carries the same disambiguation at one record per model without
touching `LegibilityElement`. The §3.3 defence above still holds for
per-element history; `cross_check_status` is orthogonal to it.

The field is **optional** for backwards-compatibility: v0.3.0 outputs
that lack it remain valid; v0.4.0 outputs always include it. The
schema template at `diagnostic-legibility/templates/legibility-element.md`
is updated to document the field on the `LegibilityModel` wrapper
(see §7.2).

### 3.4 Direction-flavoured cross-check questions

The cross-check is **asymmetric**: architectural critiques of domain
elements probe for different failure modes than domain critiques of
architectural elements. The agent operates on this asymmetry through
**direction-flavoured weighting**, mirroring sub-S2b §3.5's
dimension-flavoured weighting in Phase B — but, per the adjudicated
diaboli objection O1, the direction-specific failure modes are named
explicitly here, not inherited by structural analogy from S2b.

**The five cross-check questions (CC1–CC5):**

1. **Boundary contradiction (CC1).** Does this element's `name` or
   description collide with — or get contradicted by — an element in
   the *other* collection? *Catches cross-collection smearing.* For
   example: an architectural element named `OrderProcessor` and a
   domain element named `Order` may be internally consistent and
   become contradictory when compared (does `OrderProcessor` operate
   on the domain `Order`, or on a different thing also called
   "order"?).

2. **Evidence overlap (CC2).** Are the two collections citing the
   same evidence paths to support different claims? *Catches
   ungrounded reuse.* If `src/checkout/order.py` is cited as evidence
   for both `OrderProcessor` (architectural) and `Order` (domain),
   the descriptions should be consistent about what `order.py`
   contains. Inconsistency means at least one is wrong.

3. **Cross-confounders (CC3).** Does the *other* collection contain
   an element that could be confused with this one? *Catches
   cross-collection near-misses.* The mirror of Q3 inside one
   collection; here the confounder lives in the opposite collection.

4. **Cross-confidence calibration (CC4).** Does the other collection
   carry stronger evidence for this concept than this element does?
   *Catches calibration drift across collections.* For example: if
   the domain element for `Session` cites three paths and the
   architectural element for `SessionStore` cites one path with thin
   excerpts, the architectural confidence may be overclaiming.

5. **Mutual description integrity (CC5).** Do the two collections'
   descriptions of the same underlying concept agree? *Catches
   description divergence.* If the architectural element for
   `AuthenticationService` describes credential validation as
   "the credentials store" but the domain element for `Credential`
   describes credentials as "username + password presented at login",
   the architectural description is using "credentials store" in a
   sense the domain element does not support — one of them needs to
   revise.

**The two directions** the cross-check runs in, and the
direction-specific failure modes the weighting catches (O1):

- **Architectural-critiques-domain (Direction A→D).** Each
  architectural element is held up against the domain collection;
  the five CC questions are asked with the architectural element as
  the *subject* and the domain collection as the *frame*. **CC1
  weights heavily here**, because the direction-specific failure
  mode it catches is **architectural-implicit assumption in domain
  description** — a domain element whose description implicitly
  assumes architectural behaviours (lifecycle hooks, persistence
  ordering, transactional boundaries) that the architectural
  collection does not commit to. The architectural collection is
  the frame against which the domain description's implicit
  assumptions can be falsified. This is a genuinely cross-collection
  failure mode: single-collection Phase B self-challenge does not
  catch it, because the domain element looks internally coherent
  until compared against what the architectural collection actually
  says.

- **Domain-critiques-architectural (Direction D→A).** Each domain
  element is held up against the architectural collection; the five
  CC questions are asked with the domain element as the *subject*
  and the architectural collection as the *frame*. **CC5 weights
  heavily here**, because the direction-specific failure mode it
  catches is **domain-concept smear in architectural element** — an
  architectural element whose description silently conflates
  infrastructure with domain meaning that the domain collection
  explicitly defines (e.g. an architectural `SessionStore`
  description that uses "session" in a sense the domain `Session`
  element rules out). The domain collection is the frame against
  which the architectural description's conceptual conflation is
  visible. Again, single-collection Phase B self-challenge does not
  catch it, because the architectural element looks internally
  coherent until the domain ubiquitous-language is held up to it.

The five questions are dimension-agnostic in form but the **weighting
shifts by direction**, mirroring sub-S2b §3.5's per-element weighting
in Phase B. This is the operationalisation of the "architectural vs
domain are not symmetric" intuition in option (d) above — without
requiring a separate orchestrator pass.

### 3.5 Sentinel for cross-check-ran-cleanly, and audit-trail discipline

Mirroring sub-S2b §3.5's `Challenge applied; no questions surfaced
changes` sentinel, S3 introduces **one** per-element sentinel:

```text
Cross-check applied; no questions surfaced changes
```

The cross-check sentinel is appended **per subject element** when all
five CC questions ran against that element (in either direction or
both) and none surfaced a change. The wording mirrors the v0.3.0
sentinel exactly to make the parallel obvious; the difference is the
verb ("Cross-check applied" vs "Challenge applied").

**Subject-only audit trail (O3).** `CC<N>` entries are recorded on
the **subject** element only — the element being critiqued in the
current direction. When the cross-check against subject X surfaces a
side-effect revision on sibling Y in the opposite collection, the
**subject element's** `CC<N>` prose body names the side-effect
explicitly (e.g. "CC5 (mutual description integrity): revised
description; this critique also surfaced a tweak to `Y` in the other
collection — see `Y`'s Phase A revision"). The side-effect element
**does not** receive a `CC<N>` entry. This preserves the §3.3 defence
("reading one element's `challenge_notes[]` sees its complete
history") with one author per CC entry rather than two write paths
per element.

**The CC-skipped sentinel is removed** (O4 + O9). The
asymmetric-input case (one collection empty, the other populated) is
recorded at the model level via
`cross_check_status: skipped_asymmetric` (§3.6); no per-element
sentinel is appended in that case. The only per-element CC sentinel
that survives is **CC-applied**, which is genuine per-element
evidence ("this element was reached cleanly by cross-check"). The
sibling-sentinel ambiguity that O4 named (two strings differing only
in one verb, both prefix-matching to "cross-check ran") is dissolved
by removing one of them.

The disambiguation rule that the v0.4.0 schema is load-bearing on:

- **Empty `challenge_notes[]`** — the self-challenge protocol did not
  run on this element. Still meaningful at v0.4.0 (e.g. an incomplete
  output from a failed agent invocation).
- **One or more `Q<N>` entries, possibly followed by the
  Q-sentinel** — the self-challenge ran. Cross-check status is read
  from the model-level field, **not** inferred from the absence of
  CC entries.
- **One or more `CC<N>` entries, or the CC-applied sentinel,
  present** — the cross-check ran on this element and at least
  reached it. (`Q<N>` or Q-sentinel is required to also be present;
  the cross-check refuses to run on unrevised input per §2.1 and
  §3.6.)
- **Model-level `cross_check_status: skipped_asymmetric`** — Phase C
  was a no-op. The populated collection's elements may carry no CC
  entries at all; that is expected, not a failure mode.

The downstream consumer (S4's `/diagnose` command) groups per-element
notes by prefix to render them in a structured report — Q-notes
describe what the element was challenged on within its own
collection; CC-notes describe what the cross-check revised when the
other collection challenged it (with subject-only audit trail) — and
reads the model-level `cross_check_status` to distinguish "cross-check
completed" from "cross-check skipped (asymmetric input)" without
prefix-matching on similar strings.

**The structural assertion that CC-notes always follow Q-notes** in
any element's `challenge_notes[]` is part of the contract this spec
ships. Enforcement at two layers (O5) — agent self-verification at
emit time (§4.3) and a fixture-based structural test that loads an
interleaved input and asserts canonical ordering (§7.2) — converts
the asserted Then to a verifier.

### 3.6 Precondition violations — unified table

Per the adjudicated diaboli objection O7, the cross-check's
precondition violations fall into three response classes. §2.1 names
the preconditions; this table names each class's failure shape.

| Class | Trigger | Response | YAML emitted? |
| --- | --- | --- | --- |
| (a) Asymmetric input | `architectural[]` is non-empty and `domain[]` is empty (or vice versa) per sub-S2b §4.3 Phase A step 5. | Phase C is a **no-op**. The model-level field `cross_check_status: skipped_asymmetric` is set. No `CC<N>` entries or CC-applied sentinels are appended to any element. Phase A's output (or, in `cross-check-only` mode, the supplied YAML) is otherwise passed through unchanged. | **Yes — full YAML.** This is the only precondition-violation class that still emits a `LegibilityModel`. |
| (b) Missing field, unrevised input, or unsubstituted placeholder | Any required top-level field (`scope`, `generated_at`, `generated_by`, `architectural[]`, `domain[]`) absent; **or** in `mode: cross-check-only`, any element with empty `challenge_notes[]`; **or** in `mode: cross-check-only`, any unsubstituted `<DISPATCHER: ISO 8601 timestamp>` or `<DISPATCHER: active model identifier>` placeholder in `generated_at` or `generated_by` (O8); **or** in `mode: cross-check-only`, a payload that is not a single fenced YAML code block immediately after the `mode:` line (O8). | The agent emits a **structured refusal line** naming the violated precondition and the specific value(s) at fault. No phase runs. | **No.** Programmatic dispatchers see the absence of YAML and route to error handling. |
| (c) Unrecognised mode value | The first line is `mode: <something>` where `<something>` is not one of `full`, `cross-check-only`. | Per O6, the agent emits a **structured refusal line** naming the unrecognised value and the legal values (`full`, `cross-check-only`). No phase runs. No silent fallback to `mode: full`. | **No.** |

**Shape of the refusal line.** A single line of the form:

```text
diagnostic-legibility refusal: <one-sentence reason, naming the violated precondition and the offending value(s)>.
```

The refusal line is structured so a programmatic dispatcher
pattern-matching on the absence of a YAML code block plus the
presence of `diagnostic-legibility refusal:` can route the response
to error handling without parsing prose. Aligns with
choice-cartographer's adjudicated O7 (operational shape C) preferring
structured signals over prose narration.

**The `(empty scope)` degenerate case** (sub-S2b §3.6) is one
specialisation of the asymmetric-input case (a): the placeholder
element under `architectural[]` has no counterpart in `domain[]`,
so Phase C is a no-op and `cross_check_status: skipped_asymmetric`
is set. The output remains well-formed YAML that pattern-matches on
`name == "(empty scope)"` for downstream consumers, with the
model-level field carrying the explicit evidence that the
cross-check did not run.

### 3.7 The `mode:` marker and dispatcher contract

Per §2.4, the agent recognises **two** modes via the `mode:` prompt
marker (O2):

- `mode: full` — Phase A + Phase B + Phase C. Default when absent.
  Strict superset of v0.3.0 behaviour.
- `mode: cross-check-only` — Phase C only, against a `LegibilityModel`
  YAML supplied as a fenced YAML code block immediately after the
  `mode:` line (per §2.4 and O8). Used when a prior v0.3.0 output has
  been persisted and the dispatcher wants to layer cross-check
  evidence on top without re-running construction.

The mode marker is the **first line** of the prompt; the `scope:`
line (or, for `cross-check-only`, the fenced YAML payload) follows.

**Unrecognised mode values are refused** (O6). An unrecognised
`mode:` value is a precondition violation, class (c) in §3.6. The
agent emits the structured refusal line and runs no phase. There is
**no silent fallback** to `mode: full`. Programmatic dispatchers
benefit from explicit rejection: a dispatcher that mistypes
`mode: cross-check_only` (underscore for hyphen) sees the refusal and
can fix the prompt, rather than discovering — too late — that Phase
A re-ran construction over what was meant to be a cross-check-only
invocation.

**Why this instead of a `--mode` flag or a separate agent.** A flag
would need a slash-command wrapper to be ergonomic; at v0.4.0 there
is no slash-command (parent S4). A separate agent would double the
prompt surface for a capability that is fundamentally extending the
same agent. The prompt-marker approach is the lightest mechanism that
preserves v0.3.0 backwards compatibility (no `mode:` line ≈ `mode:
full`, which is a strict superset of v0.3.0 behaviour) and gives a
dispatcher a way to layer cross-check on persisted output via
`cross-check-only`. The `construct-only` mode is **dropped** at
v0.4.0 (O2): no consumer is named for it, and adding it later in the
same PR as a v0.3.0-exact consumer (if one materialises) is cheaper
than shipping dead surface area now.

## 4. The agent file

### 4.1 Path

`diagnostic-legibility/agents/diagnostic-legibility.agent.md` —
**modified**, not added. S3 extends the existing agent file with a
new Phase C section and updates the description, the construction
protocol, and the anti-patterns to reflect the new capability.

### 4.2 Frontmatter changes

The `description` field grows to name cross-check and the `CC<N>`
prefix convention, mirroring how sub-S2b's description named `Q<N>`
and `(empty scope)`. Draft frontmatter:

```yaml
---
name: diagnostic-legibility
description: Use to build two refined models of a codebase scope — architectural moving parts and domain concepts — using the schema at diagnostic-legibility/templates/legibility-element.md. Constructs each element, applies a five-question self-challenge cycle (Q<N> prefix on notes) and a five-question cross-check cycle (CC<N> prefix on notes). Records model-level cross_check_status (completed | skipped_asymmetric | not_run). Degenerate scopes use the literal `(empty scope)` sentinel. Returns a LegibilityModel as YAML; the dispatching command or human writes the file. Modes: `full` (default), `cross-check-only`.
tools: Read, Glob, Grep
model: inherit
---
```

The tool boundary is unchanged. The `model: inherit` line is
unchanged. Two modes (not three) appear in the description per O2.

### 4.3 New section — Phase C

The agent file's existing `## Construction protocol` section grows a
third phase between Phase B and the YAML emission. Draft Phase C
content (the exact wording is implementation; the spec names what it
must include):

**Phase C — Cross-check segment**, separated from Phase B by an
**explicit prompt-segment boundary** mirroring Phase B's boundary.
Begin with the framing instruction:

> *You are now the cross-checker. The two collections above were
> built and self-challenged independently. Your job is to use each
> collection as evidence against the other — to find where one
> collection's elements contradict, sharpen, or undermine the
> other's. Re-read both collections as if you wrote neither. Disagree
> where the evidence allows — silence is not the safe answer.*

The framing is the same mechanism as Phase B's: an explicit re-frame
that names the cross-check as separate work, so the model in the
same context does not rubber-stamp its own prior output.

**Algorithm.**

1. **Precondition check.** Apply the §3.6 precondition-violation
   table. If class (a) (asymmetric input) triggers, set the
   model-level `cross_check_status: skipped_asymmetric` and skip to
   step 4 (emit). If class (b) or (c) triggers, emit the structured
   refusal line and stop — no YAML.

2. **Direction order.** Run **A→D first, then D→A**. The direction
   order is fixed for determinism of the audit trail.

3. **Per-direction iteration order** (O10). Within each direction,
   iterate the elements of the *subject* collection in **the order
   they appear in the subject collection's YAML array**. The
   cross-check output preserves this order in the resulting `CC<N>`
   entries — across elements, the per-element CC entries appear in
   subject-collection YAML order in the emitted output.

4. **Per-subject-element challenge.** For each subject element,
   apply the **five CC questions** (§3.4) with
   **direction-flavoured weighting** as an explicit per-element step:

   - **Direction A→D** (architectural element as subject): weight
     **CC1 (boundary contradiction)** heavily — probe for
     architectural-implicit assumption in domain descriptions per
     §3.4.
   - **Direction D→A** (domain element as subject): weight **CC5
     (mutual description integrity)** heavily — probe for
     domain-concept smear in architectural element descriptions
     per §3.4.
   - The remaining three (CC2 evidence overlap, CC3 cross-confounders,
     CC4 cross-confidence calibration) are asked of every element
     with equal weight.

5. **Subject-only audit trail** (O3). Where a question surfaces a
   change on the **subject** element, revise the subject and append a
   `challenge_notes[]` entry on the **subject** prefixed
   `CC<N> (question-name):` exactly per §3.5. If the critique
   surfaces a **side-effect revision** on a sibling Y in the
   opposite collection, revise Y's `description` (or other field) in
   place, but **do not** append a `CC<N>` entry on Y. Name the
   side-effect in the subject's `CC<N>` prose body, naming Y by
   `name`. Where all five questions surface no changes for an
   element, append the cross-check sentinel
   `Cross-check applied; no questions surfaced changes` verbatim
   on the subject.

6. **Emit-time self-verification** (O5). Before serialising the
   `LegibilityModel`, the agent verifies that every element's
   `challenge_notes[]` has all `Q<N>` entries (and the Q-sentinel if
   present) ordered **before** all `CC<N>` entries (and the
   CC-applied sentinel if present). On detected violation, the agent
   **re-orders in place** rather than emitting unordered output. The
   ordering rule is part of the contract this spec ships; the
   emit-time check turns the asserted Then into a verifier.

7. **Model-level status field.** Set `cross_check_status: completed`
   on the wrapper if both directions ran. (Class (a) sets
   `skipped_asymmetric` at step 1.)

8. **Emit.** Emit the complete `LegibilityModel` YAML with the
   model-level `cross_check_status` field included.

### 4.4 New / modified sections

- `## The five cross-check questions` — new section, mirrors the
  existing `## The five-question challenge` section structurally.
  Names CC1–CC5 with one paragraph per question explaining the
  failure mode it targets. The direction-flavoured weighting and
  the direction-specific failure modes (architectural-implicit
  assumption; domain-concept smear) are restated here as a
  one-paragraph reminder; the operational guidance lives in Phase C
  above.

- `## Honesty rules` — extend with three bullets:
  - **`CC<N>` prefix convention.** Same shape as `Q<N>`: capital
    `CC`, a digit 1–5, single space, `(question-name)` lowercase in
    parens, colon, space, prose body. Canonical forms: `CC1 (boundary
    contradiction):`, `CC2 (evidence overlap):`, `CC3
    (cross-confounders):`, `CC4 (cross-confidence calibration):`,
    `CC5 (mutual description integrity):`.
  - **Cross-check refuses unrevised input.** If `mode:
    cross-check-only` is set and the supplied YAML carries any
    element with empty `challenge_notes[]`, the agent emits the
    structured refusal line per §3.6 class (b) and emits **no YAML**.
    The dispatcher must re-run construction first.
  - **Subject-only audit trail** (O3). `CC<N>` entries are written
    to the **subject** element only. Side-effect revisions on
    sibling elements are described in the subject's CC prose body,
    naming the side-effect target by `name`. The sibling element's
    `challenge_notes[]` is not amended.

- `## Anti-patterns` — extend with four new entries:
  - **Padded `CC<N>` notes** — appending no-op cross-check notes to
    look diligent. The CC-applied sentinel covers the clean case;
    `CC<N>` entries are only for revisions that actually happened.
  - **Per-element CC-skipped sentinel** (O4) — appending any
    "Cross-check skipped" text to an element's `challenge_notes[]`.
    The asymmetric-input case is recorded at the model level via
    `cross_check_status: skipped_asymmetric`. There is **no
    per-element CC-skipped sentinel** at v0.4.0.
  - **Mixing `Q<N>` and `CC<N>` order** — `CC<N>` entries must
    always appear *after* `Q<N>` entries in any element's
    `challenge_notes[]`. The temporal ordering (self-challenge first,
    cross-check second) is part of the audit-trail contract. The
    agent self-verifies this ordering at emit time (§4.3 step 6) and
    re-orders in place if needed.
  - **Bidirectional CC writes on sibling elements** (O3) — appending
    a `CC<N>` entry on a side-effect target. Side-effects are named
    in the subject's prose body only.

  Note: the v0.3.0 spec's draft anti-pattern about "Cross-check on
  asymmetric input without the skip sentinel" is **removed**, because
  the per-element skip sentinel no longer exists.

### 4.5 Length

Target: 290–380 lines (up from ~245 at v0.3.0). The agent file grows
by roughly 70–130 lines for Phase C, the five CC questions, the
mode-marker handling, the §3.6 precondition-violation logic, and the
emit-time ordering self-verification step. Length stays within the
same order of magnitude as the sibling read-only emitters; a few
extra lines on protocol clarity remain good value for the token cost.

## 5. Worked example (for the agent file and docs)

### 5.1 Input

A v0.3.0 `LegibilityModel` produced by the agent for scope
`./src/auth/`, with both collections non-empty, every element
carrying `Q<N>` notes or the Q-sentinel, and the `generated_at` /
`generated_by` placeholders **substituted** (per §2.1 + O8). The
dispatcher invokes the agent in `cross-check-only` mode, supplying
the persisted YAML as a fenced code block immediately after the
`mode: cross-check-only` line.

### 5.2 Expected output shape (truncated)

```yaml
scope: "./src/auth/"
generated_at: "2026-05-29T10:14:00Z"
generated_by: "diagnostic-legibility / claude-opus-4-7[1m]"
cross_check_status: completed
architectural:
  - name: AuthenticationService
    description: |
      The HTTP-level entry point for credential validation. Reads
      credential pairs (username + password) from the credentials
      store...
    evidence:
      - path: src/auth/service.py
        excerpt: "class AuthenticationService:"
    confidence: high
    challenge_notes:
      - "Q1 (boundary): initially smeared AuthenticationService and SessionStore into one element; revised to keep them separate."
      - "CC5 (mutual description integrity): domain `Credential` describes credentials as 'username + password presented at login'; revised architectural description from 'the credentials store' to 'reads credential pairs (username + password) from the credentials store' to align. This critique also surfaced a Phase A description tweak on `Credential` in the domain collection — see `Credential`'s description above."
domain:
  - name: Credential
    description: |
      A username + password pair presented at login. Validated by
      AuthenticationService against the credentials store...
    evidence:
      - path: src/auth/models.py
        excerpt: "@dataclass\nclass Credential:"
    confidence: high
    challenge_notes:
      - "Challenge applied; no questions surfaced changes"
      - "Cross-check applied; no questions surfaced changes"
```

The example shows (revised per O3, O4, O9):

- The model-level `cross_check_status: completed` field on the wrapper.
- A `CC5` entry on the **subject** architectural element
  (`AuthenticationService`), authored against the D→A direction with
  `Credential` as subject. **Per O3, the side-effect revision on
  `AuthenticationService` (the subject of A→D in that exchange — or,
  here, the receiving side of the D→A critique) is named in the
  subject's prose body.** In this example, `Credential`'s description
  was revised (Phase A tweak surfaced by D→A critique on
  `AuthenticationService`'s description); the subject's CC entry
  names the sibling tweak. No `CC<N>` entry is added on the
  side-effect target.
- A CC-applied sentinel on the `Credential` element where the
  D→A-subject pass ran cleanly against `Credential` (i.e. the domain
  description withstood the cross-check on its own merits). The
  sentinel appears **after** the Q-sentinel — the agent self-verified
  the ordering at emit time (§4.3 step 6).
- The canonical lowercase-name parenthesised prefix is preserved.

## 6. User stories and acceptance scenarios

### 6.1 Story — cross-check runs and produces notes on at least one element

**As** a developer who has run the v0.3.0 agent against a real
codebase scope
**I want** to dispatch the same agent with `mode: cross-check-only`
on the saved output
**So that** I receive a `LegibilityModel` whose `challenge_notes[]`
carry cross-check evidence in addition to the self-challenge
evidence, and whose wrapper carries the model-level
`cross_check_status: completed`.

```gherkin
Given a v0.3.0 LegibilityModel YAML for a non-trivial scope
And both collections are non-empty
And every element carries one or more "Q<N> (...):" entries or the
    "Challenge applied; no questions surfaced changes" sentinel
And the generated_at and generated_by placeholders have been
    substituted to concrete values
When I dispatch the diagnostic-legibility agent with mode:
    cross-check-only on the first line of the prompt
And the YAML is supplied as a fenced ```yaml block immediately
    after the mode line
Then I receive a single markdown response
And the response contains a LegibilityModel YAML block conforming to
    the v0.2.0 schema with the v0.4.0 additive cross_check_status
    field
And the wrapper carries cross_check_status: completed
And at least one element in either collection carries a new
    challenge_notes entry prefixed "CC<N> (question-name):"
And every CC<N> entry follows the canonical form: capital CC, digit
    1–5, single space, parenthesised lowercase question-name, colon,
    space, prose body
And every CC<N> entry appears after the Q<N> entries (or Q-sentinel)
    in the same element's challenge_notes list
And no CC<N> entry appears on a side-effect target element whose
    revision was surfaced by a critique on a different subject
```

### 6.2 Story — cross-check ran cleanly, sentinel surfaces on every element

**As** a downstream consumer of the corrected model
**I want** to distinguish "cross-check ran cleanly on this element"
from "cross-check never ran on this element"
**So that** I can pattern-match on the audit trail without ambiguity.

```gherkin
Given a LegibilityModel whose cross-check completed against a scope
    where no CC question surfaced a change on any element
When I read the wrapper
Then cross_check_status equals "completed"
When I read any element in either collection
Then the element's challenge_notes list contains the exact literal
    string "Cross-check applied; no questions surfaced changes"
And that sentinel appears after any Q<N> entries or the Q-sentinel
And the sentinel is not paraphrased or split
And no string of the form "Cross-check skipped; ..." appears on any
    element (the per-element CC-skipped sentinel is removed at
    v0.4.0)
```

### 6.3 Story — asymmetric input, cross-check is a no-op at the model level

**As** the dispatcher
**I want** the agent to surface a **model-level**
`cross_check_status: skipped_asymmetric` when only one collection is
non-empty
**So that** I can distinguish "cross-check could not run" from
"cross-check ran cleanly" via the wrapper field rather than
per-element string-matching.

```gherkin
Given a v0.3.0 LegibilityModel where one collection (architectural
    or domain) is non-empty and the other is an empty list
When the diagnostic-legibility agent processes it in mode: full or
    mode: cross-check-only
Then the agent emits a complete LegibilityModel YAML block
And the wrapper carries cross_check_status: skipped_asymmetric
And no CC<N> entry appears on any element
And no "Cross-check applied" sentinel appears on any element
And no "Cross-check skipped" string appears on any element (removed
    at v0.4.0 — the asymmetric case is recorded only at model
    level)
And the empty collection remains an empty list
And the rest of the LegibilityModel YAML is unchanged from the input
    (in mode: cross-check-only) or freshly produced (in mode: full)
```

### 6.4 Story — unrecognised mode value is refused

**As** the dispatcher
**I want** an unrecognised `mode:` value to produce a structured
refusal rather than a silent fallback to `mode: full`
**So that** mistyped mode values do not silently re-run construction
over what I meant to be a cross-check-only invocation.

```gherkin
Given a prompt whose first line is "mode: cross-check_only" (with an
    underscore in place of the hyphen) or any other unrecognised
    value
When the diagnostic-legibility agent processes the prompt
Then the agent emits no YAML code block
And the response includes a single line of the form
    "diagnostic-legibility refusal: <reason naming the unrecognised
    value and the legal values 'full' and 'cross-check-only'>."
And no phase (A, B, or C) runs
```

### 6.5 Story — precondition violations refuse structurally

**As** a programmatic dispatcher consuming the agent output
**I want** every precondition violation other than the asymmetric
case to produce a structured refusal with no YAML emitted
**So that** I can route to error handling by checking for absence of
a YAML code block plus presence of the refusal line.

```gherkin
Given a prompt in mode: cross-check-only whose payload is missing a
    required top-level field (scope, generated_at, generated_by,
    architectural, or domain)
Or whose payload contains an element with empty challenge_notes[]
Or whose payload contains an unsubstituted <DISPATCHER: ...>
    placeholder in generated_at or generated_by
Or whose payload is not a single fenced YAML code block immediately
    after the mode line (prose-surrounded, unfenced, or multiple
    blocks)
When the diagnostic-legibility agent processes the prompt
Then the agent emits no YAML code block
And the response includes a single line of the form
    "diagnostic-legibility refusal: <reason naming the violated
    precondition and the offending value(s)>."
And no phase runs
```

### 6.6 Story — schema continues to validate against v0.2.0 with one additive extension

**As** a future consumer that parses against the v0.2.0 schema
**I want** the cross-check output to continue conforming to the
v0.2.0 element schema, with the model-level `cross_check_status`
field treated as an additive v0.4.0 extension
**So that** S3 does not break the contract sub-S2a settled.

```gherkin
Given a LegibilityModel emitted by the v0.4.0 agent in either of its
    two modes
When I validate the YAML against the schema rules in
    diagnostic-legibility/templates/legibility-element.md
Then every required field on LegibilityElement (name, description,
    evidence, confidence, challenge_notes) is present on every
    element
And confidence is one of "low", "medium", "high"
And every element with confidence "medium" or "high" has at least
    one entry in evidence
And challenge_notes is a list of strings (never null, never absent)
And the top-level LegibilityModel has scope, generated_at,
    generated_by, architectural, domain
And the top-level LegibilityModel additionally has cross_check_status
    with a value in {"completed", "skipped_asymmetric", "not_run"}
And the empty-scope sentinel name "(empty scope)" still pattern-matches
    exactly when the scope yields nothing (in which case
    cross_check_status equals "skipped_asymmetric")
And a v0.3.0 LegibilityModel lacking the cross_check_status field
    still validates (the field is optional for back-compat)
```

### 6.7 Story — the agent description names the new contract terms

**As** a Claude Code skill matcher reading only the agent's
description field
**I want** to know the agent ships cross-check, the `CC<N>` prefix
convention, the `cross_check_status` model-level field, and the two
mode markers
**So that** I can route a "cross-check this model" intent to the
right agent.

```gherkin
Given the merged main on this PR
When I read diagnostic-legibility/agents/diagnostic-legibility.agent.md
    frontmatter
Then the description names "cross-check" verbatim
And the description names the "CC<N>" prefix convention
And the description names "cross_check_status"
And the description names "LegibilityModel"
And the description names the "(empty scope)" sentinel (carried
    forward from v0.3.0)
And the description names the two mode markers: full and
    cross-check-only
And the description does not name "construct-only" (dropped at
    v0.4.0 per the diaboli adjudication)
```

### 6.8 Story — the plugin version reflects the new capability

**As** the marketplace consumer
**I want** the diagnostic-legibility plugin version to bump when
cross-check ships
**So that** caches and version checks know the plugin has changed.

```gherkin
Given the merged main on this PR
When I read diagnostic-legibility/.claude-plugin/plugin.json
Then the version is "0.4.0"
And the entry in .claude-plugin/marketplace.json for
    diagnostic-legibility also shows version "0.4.0"
And the top-level marketplace `version` is unchanged at "0.4.0"
And the `plugin_version` field tracks the canonical
    ai-literacy-superpowers/.claude-plugin/plugin.json version
    (whatever main carries at integration time per §9)
And diagnostic-legibility/CHANGELOG.md has a new entry for 0.4.0
```

### 6.9 Story — docs explain the cross-check protocol

**As** a future reader of the docs site
**I want** to find a concept page explaining how cross-check works
and a how-to update naming the mode markers
**So that** I can use the v0.4.0 plugin without reading the agent
file.

```gherkin
Given the merged main on this PR
When I navigate to docs/plugins/diagnostic-legibility/explanation/
Then there is a page named cross-check-protocol.md
And the page explains the five cross-check questions (CC1–CC5)
And the page explains the two directions (A→D and D→A) and the
    direction-specific failure modes (architectural-implicit
    assumption in domain description; domain-concept smear in
    architectural element)
And the page explains the CC<N> prefix convention, the CC-applied
    sentinel, and the model-level cross_check_status field with its
    three values
And the page explains the subject-only audit trail
And the existing how-to page invoke-the-agent.md is updated to name
    the two mode markers (full, cross-check-only), the fenced YAML
    payload requirement for cross-check-only, and the structured
    refusal contract; it links forward to issue #333 for the
    /diagnose command
```

## 7. Files to add and modify

### 7.1 New files

| Path | Purpose |
| --- | --- |
| `docs/plugins/diagnostic-legibility/explanation/cross-check-protocol.md` | Concept page on cross-check: the five CC questions, the two directions and their direction-specific failure modes (architectural-implicit assumption in domain description; domain-concept smear in architectural element), the CC<N> prefix, the CC-applied sentinel, the model-level cross_check_status wrapper field with its three values, the subject-only audit trail, and the structured refusal contract. Linked from the how-to and from the existing challenge-refine-protocol.md page. |

### 7.2 Modified files

| Path | Change |
| --- | --- |
| `diagnostic-legibility/agents/diagnostic-legibility.agent.md` | Add Phase C to the construction protocol (§4.3), including the emit-time ordering self-verification step (O5) and the §3.6 precondition-violation logic. Add the "five cross-check questions" section (§4.4) naming the direction-specific failure modes per O1. Extend the description to name cross-check, CC<N>, cross_check_status, and the **two** mode markers (§4.2, per O2). Extend honesty rules (CC prefix, refuse-unrevised, subject-only audit trail) and anti-patterns (padded CC, no per-element skip sentinel, ordering, no bidirectional CC writes) per §4.4. Charter section updated to remove the "you do not cross-check" carve-out and replace it with a positive statement of what cross-check does. |
| `diagnostic-legibility/templates/legibility-element.md` | **Schema template update.** Add the optional `cross_check_status` field to the `LegibilityModel` wrapper documentation (O9). Field type: string enum, values `completed \| skipped_asymmetric \| not_run`. Required: optional at the schema layer (so v0.3.0 outputs remain valid); v0.4.0 agent outputs always include it. Add a one-paragraph note explaining the field's purpose (model-level cross-check disposition) and that it is orthogonal to per-element `challenge_notes[]`. The per-element schema (`LegibilityElement`) is **unchanged**. |
| `diagnostic-legibility/.claude-plugin/plugin.json` | Bump `version` `0.3.0` → `0.4.0`. |
| `diagnostic-legibility/CHANGELOG.md` | New `## 0.4.0 — 2026-05-29` (or merge-date) heading naming the cross-check addition, the two modes (per O2), the additive cross_check_status field (per O9), the subject-only audit trail (per O3), the unified refusal shape (per O6/O7), and the disposition of the S3 spec (referencing the objection record). |
| `.claude-plugin/marketplace.json` | Bump the `diagnostic-legibility` entry in `plugins[]` from `version: "0.3.0"` to `"0.4.0"`. The entry's `description` field is updated to name the cross-check capability. Top-level `version` unchanged at `0.4.0`. `plugin_version` taken from main at integration time per §9. |
| `README.md` (repo root) | Update the `diagnostic-legibility` badge from `v0.3.0` to `v0.4.0` and the marketplace table row's Version column. |
| `diagnostic-legibility/README.md` | Update the Status section to v0.4.0 and name the cross-check. Add a link to the new concept page. Mark issue #332 (this PR) as shipped; #333 remains open. |
| `docs/plugins/diagnostic-legibility/index.md` | Update the Status section to v0.4.0. Surface the new concept page as a live link. |
| `docs/plugins/diagnostic-legibility/how-to/invoke-the-agent.md` | Add a section on the **two** mode markers (full, cross-check-only) and one worked example of `mode: cross-check-only` showing the fenced YAML payload contract (O8). Add a paragraph on the CC-applied sentinel and the model-level cross_check_status field. Add a paragraph on the structured refusal contract. The existing forward link to issue #333 stays — #333 is still open. |
| `docs/plugins/diagnostic-legibility/explanation/challenge-refine-protocol.md` | Add a forward link to the new cross-check-protocol.md concept page in the "Further reading" or equivalent section. The body explaining the v0.3.0 self-challenge stays. |
| `tdad_tests/tests/test_diagnostic_legibility_structural.py` | Extend with cross-check-specific structural assertions. New tests: (1) agent body contains the CC-applied sentinel literal; (2) agent body references the five canonical CC prefixes (`CC1 (boundary contradiction):`, `CC2 (evidence overlap):`, `CC3 (cross-confounders):`, `CC4 (cross-confidence calibration):`, `CC5 (mutual description integrity):`); (3) agent description names "cross-check", "CC<N>", "cross_check_status", and the two mode markers ("full" and "cross-check-only"); (4) agent description does **not** name "construct-only"; (5) plugin.json version is 0.4.0; (6) marketplace entry version is 0.4.0; (7) CHANGELOG carries a 0.4.0 heading; (8) the cross-check-protocol explanation page exists and references CC1–CC5 and the direction-specific failure modes; (9) the schema template at `diagnostic-legibility/templates/legibility-element.md` documents the `cross_check_status` field with the three legal values; (10) **fixture-based ordering test (O5)** — load a sample agent-output YAML with Q and CC entries deliberately interleaved (e.g. `[Q1, CC2, Q2, CC1]`) and assert that, when the agent's emit-time self-verification is applied (or, equivalently, after the agent's documented re-ordering rule is invoked on the fixture), the resulting list orders all Q entries before all CC entries; (11) **subject-only audit trail** — assert that the agent file's honesty rules name the subject-only discipline and the anti-patterns name the "no bidirectional CC writes" rule; (12) **no per-element skip sentinel** — assert the agent body does **not** contain the v0.3.0-draft string `Cross-check skipped; only one collection present` (removed at v0.4.0 per O4). Existing v0.3.0 assertions are updated where the literals shifted (version strings, description content) and kept where they remain valid (Q<N> prefix forms, Q-sentinel literal). |

### 7.3 Removed files

None. Phase C grows the existing agent file rather than replacing
anything.

## 8. Out of scope

The slice narrowing keeps the following out of scope:

- **The `/diagnose` slash-command.** Reserved for parent S4 / issue
  #333. At v0.4.0 cross-check is dispatched via the bare Task tool
  with the `mode:` prompt marker.
- **An iterative cross-check loop.** §3.2 (and the parallel sub-S2b
  §3.2 reasoning) explicitly defers this; the ship is single-pass
  mutual cross-check.
- **A separate `diagnostic-legibility-cross-check` agent file.** §3.2
  weighs this as option (b) and defers it; the ship is option (a) —
  Phase C inside the existing agent. Escalation to a separate agent
  remains available if disposition data shows Phase C degenerates to
  rubber-stamping.
- **An orchestrator-level multi-pass.** §3.2 weighs this as option
  (d) and defers it; the directional asymmetry it tries to solve is
  addressed in-agent by direction-flavoured weighting in Phase C.
- **A `mode: construct-only` invocation (the v0.3.0 behaviour
  exactly).** Dropped at v0.4.0 per O2. If a v0.3.0-exact-output
  consumer materialises later, `construct-only` can be added in the
  same PR as that consumer. The `mode: full` superset semantics mean
  no current dispatcher loses access to cross-check.
- **A per-element `cross_check_notes[]` field on `LegibilityElement`.**
  §3.3 weighs and defers this; the ship reuses `challenge_notes[]`
  with the `CC<N>` prefix convention. The additive
  `cross_check_status` field on the `LegibilityModel` wrapper (O9)
  is **not** a per-element field and does not count as adding
  per-element structure.
- **A runtime validator for `LegibilityElement` or `LegibilityModel`.**
  Sub-S2a deferred, sub-S2b deferred, S3 continues to defer.
- **TDAD scenarios under `tdad_tests/scenarios/agents/diagnostic-legibility/`.**
  The TDAD-scenario-check workflow is scoped to `ai-literacy-superpowers/`
  only (see issue #338 — the meta-spec on cross-plugin discipline
  scoping). S3 stays within that scoping: structural tests in
  `tdad_tests/tests/test_diagnostic_legibility_structural.py` are
  the deterministic layer; behavioural acceptance is documented in
  this spec.
- **Docs-reference parity entries for the diagnostic-legibility
  plugin.** Same scoping; the docs-reference-parity workflow is
  scoped to `ai-literacy-superpowers/`. A reference quadrant for
  diagnostic-legibility (the schema reference page) is a future
  decision tied to the same meta-spec at #338.
- **Persisting cross-check invocations to a corpus.** The
  observability gap raised as O7 in the sub-S2b code-mode diaboli
  adjudication remains deferred. The escalation trigger for
  promoting Phase C to a separate agent (sentinel-only CC ratio
  across diverse scopes) needs invocation persistence, which belongs
  to S4.

## 9. Compatibility and rollout

- **Backwards compatibility:** v0.3.0 dispatchers that invoke the
  agent without a `mode:` marker get `mode: full` by default, which
  is a strict superset of v0.3.0 behaviour: they receive a
  cross-checked `LegibilityModel`. The per-element schema
  (`LegibilityElement`) is unchanged; the `LegibilityModel` wrapper
  carries one additive optional field (`cross_check_status`), so
  consumers parsing against the v0.2.0 schema continue to work
  (they ignore the field) and v0.3.0 outputs lacking the field
  remain valid against v0.4.0 consumers (the field is optional).

  The `mode: construct-only` surface from the original draft is
  **not shipped** (O2). A dispatcher that wants the v0.3.0 output
  exactly has no v0.4.0 invocation that produces it; the
  cross-check evidence is an additive upgrade. If a v0.3.0-exact
  consumer materialises later, `construct-only` lands in the same
  PR as that consumer.

- **Cache behaviour:** `sync-marketplace-cache.sh` fires when
  `.claude-plugin/marketplace.json` differs from `origin/main` —
  this PR triggers it because the per-plugin version bump.
  `sync-to-global-cache.sh` rsyncs the updated agent file into the
  versioned plugin cache.

- **`plugin_version` at integration time:** the `plugin_version`
  field in `.claude-plugin/marketplace.json` is a pointer to the
  current `ai-literacy-superpowers` plugin release. It is **not
  owned by this PR**. The operative rule at merge-time, mirroring
  sub-S2b §9 (and the pending promotion to CLAUDE.md tracked at
  #339):

  > If `main` has bumped `ai-literacy-superpowers`'s
  > `plugin_version` between spec-time and merge-time, take
  > `main`'s value verbatim during the integration-agent's rebase.
  > This PR only owns the `diagnostic-legibility` entry's
  > `plugins[]` version bump (0.3.0 → 0.4.0). Conflicts on
  > `plugin_version` are resolved in favour of `main`.

  The version-consistency CI check passes as long as the
  `diagnostic-legibility` entry's `version` matches
  `diagnostic-legibility/.claude-plugin/plugin.json`; the
  `plugin_version` pointer is checked independently against the
  `ai-literacy-superpowers` plugin and is not coupled to this
  slice. If #339 ships before this PR merges, the rule lives in
  CLAUDE.md and the per-spec restatement here becomes redundant
  (but harmless).

- **CI gates:**
  - Spec-first is satisfied by this spec being the first commit on
    the branch `dl-s3-cross-check`.
  - Version consistency: diagnostic-legibility's plugin.json (0.4.0)
    matches its marketplace entry (0.4.0).
  - TDAD scenario check: no-op (workflow scoped to
    `ai-literacy-superpowers/`).
  - Docs-reference parity check: no-op (same scoping).
  - Markdown lint, docs-build: must pass; the new concept page and
    the how-to update need to render cleanly.

## 10. Open questions resolved during brainstorming

| Question | Decision |
| --- | --- |
| Cross-check architecture (a/b/c/d) | (a) Phase C inside the existing agent (§3.2). One agent file, three phases, one dispatch. (b)/(c)/(d) weighed and deferred with named escalation paths. |
| Schema impact: new field vs. prefix-on-existing | Hybrid (post-O9): `CC<N>` prefix on per-element `challenge_notes[]` (no per-element schema change) **plus** one additive optional field `cross_check_status` on the `LegibilityModel` wrapper for model-level status. The per-element schema (`LegibilityElement`) is unchanged. v0.2.0 contract preserved. |
| Direction-flavoured questions vs. symmetric | Direction-flavoured weighting (§3.4). A→D weights CC1 heavily and catches "architectural-implicit assumption in domain description"; D→A weights CC5 heavily and catches "domain-concept smear in architectural element". The other three CC questions are equal-weight. Mirrors sub-S2b §3.5's dimension-flavoured weighting, with direction-specific failure modes named explicitly per O1. |
| Phase boundary discipline | Explicit prompt-segment boundary between Phase B and Phase C, mirroring the Phase A/B boundary from sub-S2b. The framing line is load-bearing prompt content. |
| Invocation surface at v0.4.0 | Bare Task-tool dispatch with `mode:` prompt marker. **Two** modes (per O2): `full` (default, supersets v0.3.0), `cross-check-only` (Phase C against supplied fenced-YAML payload). `construct-only` dropped — no consumer named. `/diagnose` deferred to S4 / #333. |
| Cross-check-only payload shape | Fenced YAML code block (\`\`\`yaml ... \`\`\`) immediately after the `mode:` line (per O8). Prose-surrounded, unfenced, and multiple-block payloads are refused. Unsubstituted `<DISPATCHER: ...>` placeholders are refused. |
| Cross-check-clean sentinel | `Cross-check applied; no questions surfaced changes` — verbatim string, parallel to the v0.3.0 self-challenge sentinel. **Single** per-element CC sentinel at v0.4.0 (the CC-skipped sentinel from the original draft is removed per O4). |
| Asymmetric-input no-op handling | Recorded at **model level** via `cross_check_status: skipped_asymmetric` (per O9). No per-element sentinel. Disambiguates "could not run" from "ran cleanly" and from "never ran" via the wrapper field. |
| Order of `Q<N>` and `CC<N>` entries | `CC<N>` always after `Q<N>` in any element's `challenge_notes[]`. Temporal ordering reflects construction → self-challenge → cross-check pipeline. Enforced at two layers (per O5): agent emit-time self-verification (§4.3 step 6) and a fixture-based structural test (§7.2). |
| Iteration order within direction | Subject-collection YAML array order (per O10). Preserved across CC entries in the emitted output. Pairs with O5's structural test. |
| Cross-check on unrevised input | Refused with the unified structured refusal shape (per O6/O7). `mode: cross-check-only` with any element carrying empty `challenge_notes[]` produces a refusal line and no YAML. |
| Unrecognised mode value | Refused with the unified structured refusal shape (per O6). No silent fallback to `mode: full`. |
| Subject-only audit trail | `CC<N>` entries are written only on the subject element (per O3). Side-effect revisions are named in the subject's CC prose body. The sibling element's `challenge_notes[]` is not amended. |
| Number and form of cross-check questions | Five (CC1 boundary contradiction, CC2 evidence overlap, CC3 cross-confounders, CC4 cross-confidence calibration, CC5 mutual description integrity). Working hypothesis revisable from disposition data, parallel to sub-S2b §3.5. |
| Plugin version bump | diagnostic-legibility 0.3.0 → 0.4.0 (minor: new behaviour). Marketplace listing top-level `version` unchanged at 0.4.0. `plugin_version` pointer taken from main at integration time per §9. The schema addition (O9) is additive; the mode-contract simplification (O2) removes surface area — neither affects the version-bump magnitude. |

## 11. References

- Issue [#332](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332) — this slice's parent.
- Parent slicing record: `docs/superpowers/slices/diagnostic-legibility-plugin.md`.
- Sub-S2a (schema) spec:
  `docs/superpowers/specs/2026-05-26-dl-s2a-legibility-element-schema-design.md`.
- Sub-S2b (working agent) spec:
  `docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md`.
- Spec-mode diaboli record for this spec:
  `docs/superpowers/objections/dl-s3-cross-check-mechanism-design.md`
  (10 objections, all accepted; absorbed in §0).
- Schema artefact (updated by this slice for the model-level field):
  `diagnostic-legibility/templates/legibility-element.md`.
- Current agent file (v0.3.0):
  `diagnostic-legibility/agents/diagnostic-legibility.agent.md`.
- Sibling agent pattern anchors:
  - `model-cards/agents/model-card-researcher.agent.md`
  - `ai-literacy-superpowers/agents/advocatus-diaboli.agent.md`
- AGENTS.md ARCH_DECISIONS — "agent-emit + dispatcher-persist + human-disposes" pattern; references-file idiom for cross-cutting methodology.
- `CLAUDE.md` — Semantic Versioning, Marketplace Versioning, and Docs Site Review sections.
- Issue [#339](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/339) — promotion of the `plugin_version` cross-PR coordination rule from per-spec restatement to CLAUDE.md.
- Issue [#338](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/338) — meta-spec on cross-plugin discipline scoping (TDAD-scenario-check and docs-reference-parity-check workflow scopes).
