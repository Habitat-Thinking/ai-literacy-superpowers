# Diagnostic Legibility — S3 — Cross-check mechanism for mutual model correction — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-05-29 |
| Status | Draft |
| Author | claude-opus-4-7[1m] (interactive session with russmiles) |
| Slice | S3 of the parent slicing record at `docs/superpowers/slices/diagnostic-legibility-plugin.md` (lines 53–93, 137–153) |
| Parent issue | [#332](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332) (Diagnostic Legibility — S3: Cross-check mechanism for mutual model correction) |
| Plugin version target | `diagnostic-legibility` v0.3.0 → v0.4.0 |
| Marketplace listing | Unchanged at v0.4.0; `plugin_version` (pointer to `ai-literacy-superpowers`) taken from main at integration time per §9 |
| PR ceremony | feature — full `/diaboli` (spec + code) and `/choice-cartograph` |
| Related work | S1 shipped (PR #334, scaffold v0.1.0); sub-S2a shipped (PR #336, schema v0.2.0); sub-S2b shipped (PR #341, working agent v0.3.0). S3 ships the cross-check that turns two individually-refined collections into a mutually-corrected `LegibilityModel`. S4 (issue #333) — the human-facing `/diagnose` command — remains out of scope here. |

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

- `scope`, `generated_at`, `generated_by` populated (the latter two
  may carry the `<DISPATCHER: ...>` placeholders if the dispatcher
  has not yet substituted them — cross-check passes the placeholders
  through unchanged).
- `architectural[]` and `domain[]` each present; at least one
  non-empty.
- Every element in either collection carries a non-empty
  `challenge_notes[]` — either one or more `Q<N> (question-name):`
  entries (the canonical lowercase form per sub-S2b §3.5) or the
  single sentinel `Challenge applied; no questions surfaced changes`.

Cross-check refuses to run on an input that violates these
preconditions; the failure mode is documented in §3.6.

### 2.2 Output

A single markdown response containing a `LegibilityModel` instance
serialised as YAML, conforming to the **same** v0.2.0 schema. No
schema change. The differences from the input are confined to
`challenge_notes[]` on individual elements: where the cross-check
surfaced a correction, a new entry is appended with a `CC<N>` prefix
(§3.2); where the cross-check ran cleanly on an element, the
cross-check sentinel `Cross-check applied; no questions surfaced
changes` is appended; where the cross-check did not run on an element
(the asymmetric-input case in §3.6), `challenge_notes[]` is left
unchanged.

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

The decision in this slice (§3.5 names the invocation contract):

- **Mode marker** — the prompt's first line is one of:
  - `mode: full` — run both Phase A (construction) and Phase B
    (self-challenge) from v0.3.0, **then** Phase C (cross-check)
    against the freshly-built collections. This is the new default
    when invoked without an explicit `--input` block.
  - `mode: cross-check-only` — read the supplied `LegibilityModel`
    YAML from the prompt body, run only Phase C against it, and emit
    the cross-checked YAML. Used when the v0.3.0 output has already
    been persisted and the dispatcher wants to add cross-check
    evidence without re-running construction.

Absent any `mode:` line, the prompt is interpreted as `mode: full`.
This preserves backwards compatibility with v0.3.0 invocations: a
dispatcher that does not know about cross-check still gets a working
two-collection output, plus the cross-check notes as a free upgrade.
A dispatcher that wants the v0.3.0 behaviour exactly (no cross-check)
adds `mode: construct-only`, the third recognised value, which skips
Phase C.

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

### 3.3 Schema impact — `CC<N>` prefix, no schema change

The v0.2.0 schema is **unopinionated about the string content of
`challenge_notes[]`**. Sub-S2b exploited this by establishing the
`Q<N> (question-name):` prefix convention for self-challenge notes
without changing the schema. S3 exploits the same affordance: the
cross-check appends entries to the existing `challenge_notes[]` field
with a `CC<N>` prefix instead of adding a new `cross_check_notes[]`
field.

**Why no schema change.** Three reasons:

1. **The schema is the contract for two downstream consumers** — the
   cross-check (this slice) and the surfacing command (S4, #333). If
   S3 changes the schema, S4 has to be re-planned against the new
   shape. Keeping `challenge_notes[]` as the single accumulator field
   means S4 can pattern-match by prefix (`Q<N>` for self-challenge,
   `CC<N>` for cross-check, sentinels for clean runs) without caring
   whether the schema grew.

2. **The schema already encodes the contract through sentinels.**
   The v0.3.0 self-challenge protocol distinguishes "challenge ran
   cleanly" (sentinel) from "challenge never ran" (empty list). The
   same disambiguation device works for cross-check: a fresh sentinel
   distinguishes "cross-check ran cleanly" from "cross-check never
   ran" (§3.5). No new field is needed to carry that distinction.

3. **A new field would split the audit trail.** Today, a human or
   downstream consumer reading one element sees the complete history
   of how the element was challenged in one list. A separate
   `cross_check_notes[]` field would force consumers to interleave
   two lists to reconstruct the same history. The single-list shape
   is the simpler audit surface.

**Defending the choice against the alternative.** A dedicated
`cross_check_notes[]` field would make the schema *explicitly* aware
of the cross-check phase, which has documentation value: a reader
encountering the schema for the first time would learn from the
field names that two challenge phases exist. The trade-off is real
but bounded. The schema reference page (the doc-site reference
quadrant, which does not yet exist for this plugin) will name the
`Q<N>` and `CC<N>` prefix conventions explicitly in v0.4.0's docs, so
the documentation value is recoverable without a schema change. The
*cost* of a schema change at v0.4.0 is replanning S4 and any future
runtime validator against a new shape, which is concrete and
asymmetric. Shipping the prefix convention is cheaper and reversible
(a future slice can split the field if a measured signal justifies
it).

### 3.4 Direction-flavoured cross-check questions

The cross-check is **asymmetric**: architectural critiques of domain
elements probe for different failure modes than domain critiques of
architectural elements. The agent operates on this asymmetry through
**direction-flavoured weighting**, mirroring sub-S2b §3.5's
dimension-flavoured weighting in Phase B.

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

**The two directions** the cross-check runs in:

- **Architectural-critiques-domain** (Direction A→D). Each
  architectural element is held up against the domain collection; the
  five CC questions are asked with the architectural element as the
  *subject* and the domain collection as the *frame*. CC1 weights
  heavily here (architectural smearing often shows up as colliding
  with domain ubiquitous-language terms).

- **Domain-critiques-architectural** (Direction D→A). Each domain
  element is held up against the architectural collection; the five
  CC questions are asked with the domain element as the *subject* and
  the architectural collection as the *frame*. CC5 weights heavily
  here (domain description drift often shows up as describing a
  concept in a way the architectural elements contradict).

The five questions are dimension-agnostic in form but the **weighting
shifts by direction**, mirroring sub-S2b §3.5's per-element weighting
in Phase B. This is the operationalisation of the "architectural vs
domain are not symmetric" intuition in option (d) above — without
requiring a separate orchestrator pass.

### 3.5 Sentinel for cross-check-ran-cleanly

Mirroring sub-S2b §3.5's `Challenge applied; no questions surfaced
changes` sentinel, S3 introduces:

```text
Cross-check applied; no questions surfaced changes
```

The cross-check sentinel is appended **per element** when all five CC
questions ran against that element (in either direction or both) and
none surfaced a change. The wording mirrors the v0.3.0 sentinel
exactly to make the parallel obvious; the difference is the verb
("Cross-check applied" vs "Challenge applied").

The disambiguation rule that the v0.3.0 schema is load-bearing on:

- **Empty `challenge_notes[]`** — the self-challenge protocol did not
  run. Still meaningful at v0.4.0 (e.g. an incomplete output from a
  failed agent invocation).
- **One or more `Q<N>` entries, possibly followed by the
  Q-sentinel** — the self-challenge ran. Cross-check has not yet run.
- **One or more `CC<N>` entries, or the CC-sentinel, present** — the
  cross-check ran. (`Q<N>` or Q-sentinel must also be present; the
  cross-check refuses to run on unrevised input per §2.1.)

The downstream consumer (S4's `/diagnose` command) groups notes by
prefix to render them in a structured report: Q-notes describe what
the element was challenged on within its own collection; CC-notes
describe what the cross-check revised when the other collection
challenged it. The structural assertion that **CC-notes always follow
Q-notes** in any element's `challenge_notes[]` is part of the contract
this spec ships.

### 3.6 Asymmetric output handling — the no-op case

When the v0.3.0 self-challenge produces an asymmetric output (one
collection populated, the other empty, per sub-S2b §4.3 Phase A step
5), Phase C is a **no-op**. Cross-check requires both collections to
be non-empty: there is nothing to critique architectural elements
against if the domain collection is empty, and vice versa.

The cross-check does not silently skip in this case. It explicitly
records the no-op by appending the following sentinel to every
element in the populated collection:

```text
Cross-check skipped; only one collection present
```

This is a third recognised string in the `challenge_notes[]` field —
distinct from `CC<N>` entries and distinct from the `Cross-check
applied; no questions surfaced changes` sentinel. The disambiguation
serves the downstream consumer:

- **`CC<N>` entries or CC-applied sentinel present** — cross-check
  ran fully; the element has been mutually corrected.
- **CC-skipped sentinel present** — cross-check could not run; the
  element is only individually refined.
- **Nothing CC-prefixed at all** — the dispatcher invoked the agent
  with `mode: construct-only` and explicitly opted out of
  cross-check. Distinct from "the input was asymmetric".

The `(empty scope)` degenerate case (sub-S2b §3.6) is one
specialisation of the asymmetric-output case: the placeholder element
under `architectural[]` has no counterpart in `domain[]`, so Phase C
appends the CC-skipped sentinel to it. The result is well-formed YAML
that still pattern-matches on `name == "(empty scope)"` for
downstream consumers, and now also carries explicit evidence that the
cross-check was not run.

### 3.7 The `mode:` marker and dispatcher contract

Per §2.4, the agent now recognises three modes via the `mode:` prompt
marker:

- `mode: full` — Phase A + Phase B + Phase C. Default when absent.
- `mode: construct-only` — Phase A + Phase B only (the v0.3.0
  behaviour). Used when the dispatcher wants the original two-model
  output without cross-check evidence.
- `mode: cross-check-only` — Phase C only, against a `LegibilityModel`
  YAML supplied in the prompt body. Used when a prior v0.3.0 output
  has been persisted and the dispatcher wants to layer cross-check
  evidence on top without re-running construction.

The mode marker is the **first line** of the prompt; the `scope:`
line (or, for `cross-check-only`, the YAML payload) follows. The
parser is forgiving: an unrecognised mode value falls back to `full`
with a warning sentence in the response prose (not in the YAML).

**Why this instead of a `--mode` flag or a separate agent.** A flag
would need a slash-command wrapper to be ergonomic; at v0.4.0 there
is no slash-command (parent S4). A separate agent would double the
prompt surface for a capability that is fundamentally extending the
same agent. The prompt-marker approach is the lightest mechanism that
preserves v0.3.0 backwards compatibility (no `mode:` line ≈ `mode:
full`, which is a strict superset of v0.3.0 behaviour) and gives a
dispatcher a way to opt down to construct-only when needed.

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
description: Use to build two refined models of a codebase scope — architectural moving parts and domain concepts — using the schema at diagnostic-legibility/templates/legibility-element.md. Constructs each element, applies a five-question self-challenge cycle (Q<N> prefix on notes) and a five-question cross-check cycle (CC<N> prefix on notes). Degenerate scopes use the literal `(empty scope)` sentinel. Returns a LegibilityModel as YAML; the dispatching command or human writes the file. Modes: `full` (default), `construct-only`, `cross-check-only`.
tools: Read, Glob, Grep
model: inherit
---
```

The tool boundary is unchanged. The `model: inherit` line is
unchanged.

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

For each direction (A→D, then D→A — order is fixed for determinism
of the audit trail), iterate the elements of the *subject*
collection. For each subject element, apply the **five CC questions**
(§3.4) with **direction-flavoured weighting** as an explicit
per-element step:

- **Direction A→D** (architectural element as subject): weight
  **CC1 (boundary contradiction)** heavily — probe for collisions
  between architectural names and domain ubiquitous-language terms.
- **Direction D→A** (domain element as subject): weight **CC5
  (mutual description integrity)** heavily — probe for the subject
  description using a term in a sense the other collection
  contradicts.
- The remaining three (CC2 evidence overlap, CC3 cross-confounders,
  CC4 cross-confidence calibration) are asked of every element with
  equal weight.

Where a question surfaces a change, **revise the subject element** and
append a `challenge_notes[]` entry prefixed `CC<N> (question-name):`
exactly per §3.5. Where all five surface no changes for an element,
append the cross-check sentinel `Cross-check applied; no questions
surfaced changes` verbatim.

For elements in the *non-subject* collection that the cross-check
revised as a side-effect of a critique (e.g. a CC5 revision to a
domain element that surfaces a corresponding revision in an
architectural element), append the corresponding `CC<N>` entry to
that element too, naming the bidirectional change in the prose body.

After both directions complete, emit the complete `LegibilityModel`
YAML.

### 4.4 New / modified sections

- `## The five cross-check questions` — new section, mirrors the
  existing `## The five-question challenge` section structurally.
  Names CC1–CC5 with one paragraph per question explaining the
  failure mode it targets. The direction-flavoured weighting is
  repeated here as a one-paragraph reminder; the operational guidance
  lives in Phase C above.

- `## Honesty rules` — extend with two bullets:
  - **`CC<N>` prefix convention.** Same shape as `Q<N>`: capital
    `CC`, a digit 1–5, single space, `(question-name)` lowercase in
    parens, colon, space, prose body. Canonical forms: `CC1 (boundary
    contradiction):`, `CC2 (evidence overlap):`, `CC3
    (cross-confounders):`, `CC4 (cross-confidence calibration):`,
    `CC5 (mutual description integrity):`.
  - **Cross-check refuses unrevised input.** If `mode:
    cross-check-only` is set and the supplied YAML carries any
    element with empty `challenge_notes[]`, the agent emits a refusal
    line and skips Phase C. The dispatcher must re-run construction
    first.

- `## Anti-patterns` — extend with three new entries:
  - **Padded `CC<N>` notes** — appending no-op cross-check notes to
    look diligent. The CC-applied sentinel covers the clean case;
    `CC<N>` entries are only for revisions that actually happened.
  - **Cross-check on asymmetric input without the skip sentinel** —
    leaving an element's `challenge_notes[]` unchanged when
    cross-check could not run. Use the `Cross-check skipped; only one
    collection present` sentinel instead.
  - **Mixing `Q<N>` and `CC<N>` order** — `CC<N>` entries must
    always appear *after* `Q<N>` entries in any element's
    `challenge_notes[]`. The temporal ordering (self-challenge first,
    cross-check second) is part of the audit-trail contract.

### 4.5 Length

Target: 280–360 lines (up from ~245 at v0.3.0). The agent file grows
by roughly 60–110 lines for Phase C, the five CC questions, and the
mode-marker handling. Length stays within the same order of
magnitude as the sibling read-only emitters; a few extra lines on
protocol clarity remain good value for the token cost.

## 5. Worked example (for the agent file and docs)

### 5.1 Input

A v0.3.0 `LegibilityModel` produced by the agent for scope
`./src/auth/`, with both collections non-empty and every element
carrying `Q<N>` notes or the Q-sentinel. The dispatcher invokes the
agent in `cross-check-only` mode with the YAML payload.

### 5.2 Expected output shape (truncated)

```yaml
scope: "./src/auth/"
generated_at: "<DISPATCHER: ISO 8601 timestamp>"
generated_by: "diagnostic-legibility / <DISPATCHER: active model identifier>"
architectural:
  - name: AuthenticationService
    description: |
      The HTTP-level entry point for credential validation...
    evidence:
      - path: src/auth/service.py
        excerpt: "class AuthenticationService:"
    confidence: high
    challenge_notes:
      - "Q1 (boundary): initially smeared AuthenticationService and SessionStore into one element; revised to keep them separate."
      - "CC5 (mutual description integrity): domain `Credential` describes credentials as 'username + password presented at login'; revised architectural description from 'the credentials store' to 'reads credential pairs from the credentials store' to align."
domain:
  - name: Credential
    description: |
      A username + password pair presented at login...
    evidence:
      - path: src/auth/models.py
        excerpt: "@dataclass\nclass Credential:"
    confidence: high
    challenge_notes:
      - "Challenge applied; no questions surfaced changes"
      - "Cross-check applied; no questions surfaced changes"
```

The example shows: a `CC5` revision on the architectural element
where the domain element's description forced a description tweak; a
CC-applied sentinel on the domain element where cross-check ran
cleanly; the canonical lowercase-name parenthesised prefix.

## 6. User stories and acceptance scenarios

### 6.1 Story — cross-check runs and produces notes on at least one element

**As** a developer who has run the v0.3.0 agent against a real
codebase scope
**I want** to dispatch the same agent with `mode: cross-check-only`
on the saved output
**So that** I receive a `LegibilityModel` whose `challenge_notes[]`
carry cross-check evidence in addition to the self-challenge
evidence.

```gherkin
Given a v0.3.0 LegibilityModel YAML for a non-trivial scope
And both collections are non-empty
And every element carries one or more "Q<N> (...):" entries or the
    "Challenge applied; no questions surfaced changes" sentinel
When I dispatch the diagnostic-legibility agent with mode:
    cross-check-only and the YAML in the prompt body
Then I receive a single markdown response
And the response contains a LegibilityModel YAML block conforming to
    the v0.2.0 schema
And at least one element in either collection carries a new
    challenge_notes entry prefixed "CC<N> (question-name):"
And every CC<N> entry follows the canonical form: capital CC, digit
    1–5, single space, parenthesised lowercase question-name, colon,
    space, prose body
And every CC<N> entry appears after the Q<N> entries (or Q-sentinel)
    in the same element's challenge_notes list
```

### 6.2 Story — cross-check ran cleanly, sentinel surfaces on every element

**As** a downstream consumer of the corrected model
**I want** to distinguish "cross-check ran cleanly" from "cross-check
never ran" on every element
**So that** I can pattern-match on the audit trail without ambiguity.

```gherkin
Given a LegibilityModel whose cross-check completed against a scope
    where no CC question surfaced a change
When I read any element in either collection
Then the element's challenge_notes list contains the exact literal
    string "Cross-check applied; no questions surfaced changes"
And that sentinel appears after any Q<N> entries or the Q-sentinel
And the sentinel is not paraphrased or split
```

### 6.3 Story — asymmetric input, cross-check is a no-op

**As** the dispatcher
**I want** the agent to surface an explicit "cross-check skipped"
sentinel when only one collection is non-empty
**So that** I can distinguish "cross-check could not run" from
"cross-check ran cleanly" and from "cross-check never ran".

```gherkin
Given a v0.3.0 LegibilityModel where one collection (architectural
    or domain) is non-empty and the other is an empty list
When the diagnostic-legibility agent processes it in mode: full or
    mode: cross-check-only
Then every element in the populated collection carries the literal
    sentinel "Cross-check skipped; only one collection present"
And no CC<N> entries appear in any element
And the empty collection remains an empty list
And the rest of the LegibilityModel YAML is unchanged from the input
    (in mode: cross-check-only) or freshly produced (in mode: full)
```

### 6.4 Story — schema continues to validate against v0.2.0

**As** a future consumer that parses against the v0.2.0 schema
**I want** the cross-check output to continue conforming to the
v0.2.0 schema rules
**So that** S3 does not break the contract sub-S2a settled.

```gherkin
Given a LegibilityModel emitted by the v0.4.0 agent in any of its
    three modes
When I validate the YAML against the schema rules in
    diagnostic-legibility/templates/legibility-element.md
Then every required field (name, description, evidence, confidence,
    challenge_notes) is present on every element
And confidence is one of "low", "medium", "high"
And every element with confidence "medium" or "high" has at least
    one entry in evidence
And challenge_notes is a list of strings (never null, never absent)
And the top-level LegibilityModel has scope, generated_at,
    generated_by, architectural, domain
And the empty-scope sentinel name "(empty scope)" still pattern-matches
    exactly when the scope yields nothing
```

### 6.5 Story — the agent description names the new contract terms

**As** a Claude Code skill matcher reading only the agent's
description field
**I want** to know the agent ships cross-check and the `CC<N>`
prefix convention
**So that** I can route a "cross-check this model" intent to the
right agent.

```gherkin
Given the merged main on this PR
When I read diagnostic-legibility/agents/diagnostic-legibility.agent.md
    frontmatter
Then the description names "cross-check" verbatim
And the description names the "CC<N>" prefix convention
And the description names "LegibilityModel"
And the description names the "(empty scope)" sentinel (carried
    forward from v0.3.0)
And the description names the three mode markers: full,
    construct-only, cross-check-only
```

### 6.6 Story — the plugin version reflects the new capability

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

### 6.7 Story — docs explain the cross-check protocol

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
And the page explains the two directions (A→D and D→A)
And the page explains the CC<N> prefix convention and the CC-applied
    and CC-skipped sentinels
And the existing how-to page invoke-the-agent.md is updated to name
    the three mode markers and link forward to issue #333 for the
    /diagnose command
```

## 7. Files to add and modify

### 7.1 New files

| Path | Purpose |
| --- | --- |
| `docs/plugins/diagnostic-legibility/explanation/cross-check-protocol.md` | Concept page on cross-check: the five CC questions, the two directions, the CC<N> prefix, the two sentinels (CC-applied and CC-skipped), and how the cross-check relates to the self-challenge. Linked from the how-to and from the existing challenge-refine-protocol.md page. |

### 7.2 Modified files

| Path | Change |
| --- | --- |
| `diagnostic-legibility/agents/diagnostic-legibility.agent.md` | Add Phase C to the construction protocol (§4.3). Add the "five cross-check questions" section (§4.4). Extend the description to name cross-check, CC<N>, and the mode markers (§4.2). Extend honesty rules and anti-patterns (§4.4). Charter section updated to remove the "you do not cross-check" carve-out and replace it with a positive statement of what cross-check does. |
| `diagnostic-legibility/.claude-plugin/plugin.json` | Bump `version` `0.3.0` → `0.4.0`. |
| `diagnostic-legibility/CHANGELOG.md` | New `## 0.4.0 — 2026-05-29` (or merge-date) heading naming the cross-check addition, the three modes, and the disposition of the S3 spec. |
| `.claude-plugin/marketplace.json` | Bump the `diagnostic-legibility` entry in `plugins[]` from `version: "0.3.0"` to `"0.4.0"`. The entry's `description` field is updated to name the cross-check capability. Top-level `version` unchanged at `0.4.0`. `plugin_version` taken from main at integration time per §9. |
| `README.md` (repo root) | Update the `diagnostic-legibility` badge from `v0.3.0` to `v0.4.0` and the marketplace table row's Version column. |
| `diagnostic-legibility/README.md` | Update the Status section to v0.4.0 and name the cross-check. Add a link to the new concept page. Mark issue #332 (this PR) as shipped; #333 remains open. |
| `docs/plugins/diagnostic-legibility/index.md` | Update the Status section to v0.4.0. Surface the new concept page as a live link. |
| `docs/plugins/diagnostic-legibility/how-to/invoke-the-agent.md` | Add a section on the three mode markers and one worked example of `mode: cross-check-only`. Add a paragraph on the CC-applied and CC-skipped sentinels. The existing forward link to issue #333 stays — #333 is still open. |
| `docs/plugins/diagnostic-legibility/explanation/challenge-refine-protocol.md` | Add a forward link to the new cross-check-protocol.md concept page in the "Further reading" or equivalent section. The body explaining the v0.3.0 self-challenge stays. |
| `tdad_tests/tests/test_diagnostic_legibility_structural.py` | Extend with cross-check-specific structural assertions. New tests: agent body contains the CC-applied sentinel; agent body contains the CC-skipped sentinel; agent body references the five canonical CC prefixes (`CC1 (boundary contradiction):`, `CC2 (evidence overlap):`, `CC3 (cross-confounders):`, `CC4 (cross-confidence calibration):`, `CC5 (mutual description integrity):`); agent description names "cross-check", "CC<N>", and the three mode markers; plugin.json version is 0.4.0; marketplace entry version is 0.4.0; CHANGELOG carries a 0.4.0 heading; the cross-check-protocol explanation page exists and references CC1–CC5. The existing v0.3.0 assertions are updated where the literals shifted (version strings, description content) and kept where they remain valid (Q<N> prefix forms, Q-sentinel literal). |

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
- **A schema change adding `cross_check_notes[]`.** §3.3 weighs and
  defers this; the ship reuses `challenge_notes[]` with the `CC<N>`
  prefix convention.
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
  cross-checked `LegibilityModel`. The schema is unchanged, so
  consumers parsing against the v0.2.0 schema continue to work. A
  dispatcher that wants the v0.3.0 output exactly (no cross-check
  notes) sets `mode: construct-only`.

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
| Schema impact: new field vs. prefix-on-existing | Prefix-on-existing — `CC<N>` entries in `challenge_notes[]` (§3.3). No schema change. v0.2.0 contract preserved. |
| Direction-flavoured questions vs. symmetric | Direction-flavoured weighting (§3.4). A→D weights CC1 heavily; D→A weights CC5 heavily; the other three are equal-weight. Mirrors sub-S2b §3.5's dimension-flavoured weighting. |
| Phase boundary discipline | Explicit prompt-segment boundary between Phase B and Phase C, mirroring the Phase A/B boundary from sub-S2b. The framing line is load-bearing prompt content. |
| Invocation surface at v0.4.0 | Bare Task-tool dispatch with `mode:` prompt marker. Three modes: `full` (default, supersets v0.3.0), `construct-only` (the v0.3.0 behaviour exactly), `cross-check-only` (Phase C against supplied YAML). `/diagnose` deferred to S4 / #333. |
| Cross-check-clean sentinel | `Cross-check applied; no questions surfaced changes` — verbatim string, parallel to the v0.3.0 self-challenge sentinel. |
| Asymmetric-input no-op handling | `Cross-check skipped; only one collection present` — explicit third sentinel, appended to every element in the populated collection (§3.6). Disambiguates "could not run" from "ran cleanly" and from "never ran". |
| Order of `Q<N>` and `CC<N>` entries | `CC<N>` always after `Q<N>` in any element's `challenge_notes[]`. Temporal ordering reflects construction → self-challenge → cross-check pipeline. |
| Cross-check on unrevised input | Refused. `mode: cross-check-only` with any element carrying empty `challenge_notes[]` returns a refusal line and skips Phase C. |
| Number and form of cross-check questions | Five (CC1 boundary contradiction, CC2 evidence overlap, CC3 cross-confounders, CC4 cross-confidence calibration, CC5 mutual description integrity). Working hypothesis revisable from disposition data, parallel to sub-S2b §3.5. |
| Plugin version bump | diagnostic-legibility 0.3.0 → 0.4.0 (minor: new behaviour). Marketplace listing top-level `version` unchanged at 0.4.0. `plugin_version` pointer taken from main at integration time per §9. |

## 11. References

- Issue [#332](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332) — this slice's parent.
- Parent slicing record: `docs/superpowers/slices/diagnostic-legibility-plugin.md`.
- Sub-S2a (schema) spec:
  `docs/superpowers/specs/2026-05-26-dl-s2a-legibility-element-schema-design.md`.
- Sub-S2b (working agent) spec:
  `docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md`.
- Schema artefact:
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
