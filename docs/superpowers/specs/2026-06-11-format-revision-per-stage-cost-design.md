# Cost Estimation — format-revision slice — per-stage `cost_usd`, `generated_by` wording, cost-snapshot grounding-path convention — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-11 |
| Status | Draft |
| Author | spec-writer (interactive session with russmiles) |
| Slice | format-revision residue split out of S2 at its diaboli revision (a scoped residue of S2's diaboli — not a carpaccio slice) |
| Owns | `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md` — this slice is its legitimate owner and MAY modify it |
| Tracking issue | #377 |
| Upstream (merged on main) | S1 (#—, merged): `cost-estimation` skill + estimate-record format reference; S2 (#369, merged): read-only `cost-estimator` agent |
| Sibling slices | S3 (#370), S4 (#371), S5 (#372), S6 (#373) — all out of scope here |
| Origin | The three concerns this slice resolves are deferred residues: O6 code-mode (per-stage `cost_usd`, deferred from S1), S2 round-2 O1 (`generated_by` wording), and S1 code-mode O7 / S2 §5.3 flag (cost-snapshot grounding path). |
| Plugin version target | `ai-literacy-superpowers` v0.42.0 → v0.43.0 (format/schema change to a plugin reference file — minor bump). **Do NOT apply the bump at spec time** — it is an implementation-time step. |
| Marketplace listing | Top-level `version` unchanged at v0.4.0; `plugin_version` 0.42.0 → 0.43.0 |
| PR ceremony | feature — full `/diaboli` (spec + code) |
| Governing decisions | AGENTS.md **"disclosure-of-derived-judgment"** decision (the `cost_usd` per-stage band is a machine-checkable form of the same derived-cost disclosure); the **"cross-cutting methodology lives in `skills/<name>/references/<contract>.md`"** decision (this slice edits that one canonical reference; consumers — the S2 agent, the future S3 checkpoint — reference it by path and inherit the change). |

---

## 1. Premise

S1 shipped the **estimate-record format reference** — the stable contract an
estimate-record must satisfy: the field table, the tier→model→$/token binding
table, the four-part disclosure body, the closed-world **validation checklist** a
consuming command's Output Validation Checkpoint runs, and two worked examples
(one cost-omitted, one cost-present). S2 shipped the **emitter** — the read-only
`cost-estimator` agent — as a **pure consumer** of that reference, forbidden from
mutating it.

Three concerns accumulated against the reference across the S1 and S2 reviews,
and each was deliberately deferred to a slice that **owns** the contract rather
than merely consumes it:

1. **Per-stage `cost_usd` (S1 code-mode O6).** S1's split-tier widening (the
   implementer's `Standard/Capable` priced low at `claude-sonnet-4`, high at
   `claude-opus-4`) is demonstrated only in prose and a worked example — it is
   **not machine-checkable on an emitted record**, because `tokens_by_stage[]`
   carries no per-stage cost. A validator cannot assert the implementer band
   reflects a genuine two-tier spread; it can only read the whole-record figure.
   (The slice's resolution is a **record-internal spread invariant**, not an
   absolute-rate check — see §4.4 for exactly what the validator CAN and CANNOT
   assert.)
2. **`generated_by` wording (S2 round-2 O1).** The field is documented as a
   "model identifier", but the merged S2 agent honestly emits
   `cost-estimator / tier:Standard` under `model: inherit`. The most common
   record the merged agent emits carries a value the field's own description does
   not recognise — with no validation signal that anything is off.
3. **Cost-snapshot grounding-path convention (S1 code-mode O7 / S2 §5.3
   flag).** The cost-omitted record's mandatory `grounding_sources` cost-snapshot
   entry points at the **directory** `observability/costs/` when no snapshot file
   exists. The field is documented as "the inputs the estimate was built from" —
   a directory that grounded nothing strains that description, even though the
   "at minimum a cost-snapshot entry" presence rule is satisfied.

This slice **owns** `estimate-record-format.md` and resolves all three. Its
load-bearing requirement is **demonstrated backward-compatibility**, not asserted:
for **each** of the three changes, the spec states how the closed-world
validation checklist treats **both** old (S1/S2-era) records **and** new records,
and **demonstrates** — by tracing the actual checklist semantics — that both
remain valid. This is the entire reason these concerns were split out of S2: a
conditional sub-field coupled to top-level cost is *not* trivially additive against
a closed-world validator (and its coupling must be expressed as a one-directional
asymmetry, never an `iff` biconditional — see §4.1), so the claim must be shown, not
stated.

The slice is **format-only**. It is **not** the S3 command, **not** the S4
orchestrator fold-in, and **not** the S6 calibration loop. It changes the
reference file (and, where a change is unavoidable to keep the merged S2 agent
conformant, the S2 agent and its scenarios), the TDAD scenarios that assert the
reference's content and the backward-compat invariants, and the version-bump
maintenance steps.

## 2. Scope and non-goals

### 2.1 In scope

- **Edit `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`** — this slice owns the reference. Specifically:
  - Add an **optional** `tokens_by_stage[].cost_usd` `{ low, high }` sub-field
    under a **one-directional coupling**: sub-field present ⟹ top-level
    `cost_usd` present (enforced); top-level `cost_usd` present ⟹ bands SHOULD be
    populated by emitters but their absence does NOT invalidate the record (§4).
  - Add **two** validation-checklist lines — a **"Per-stage cost coupling"** line
    (the sub-field's one-directional coupling: present ⟹ top-level cost present)
    and a **"Split-tier spread"** line (a split-tier stage's band must have a
    strictly-positive ordered spread, `low < high`) — both written so they reject
    **neither** old records (no sub-field) **nor** new cost-omitted records (no
    sub-field), plus add the sub-field to the existing "Ranges well-formed"
    enumeration, plus a §4.4.1 note stating what the validator CAN and CANNOT assert
    about the widening (§4.4).
  - **Update the cost-present worked example (Example 2)** to carry per-stage
    `cost_usd` bands, demonstrating the implementer band spans
    `claude-sonnet-4` low … `claude-opus-4` high (§4.5). Leave the cost-omitted
    worked example (Example 1) **unchanged** (sub-field absent, still valid).
  - **Widen the `generated_by` field description** to admit a `tier:<tier>`
    routing-tier label when the concrete model is unavailable (§5).
  - **Document the cost-snapshot grounding-path convention** — keep the directory
    path `observability/costs/` and document it as the named cost-omitted
    sentinel, so the merged S2 agent's behaviour and Example 1 stay conformant
    (§6).
- **The minimal S2-agent reconciliation, IF AND ONLY IF a change is unavoidable**
  to keep the merged agent's emitted records conformant (§5.4, §6.3). The default
  is **no S2 change** — the format is widened to *admit* the agent's existing
  output. The spec states explicitly, per concern, whether an S2 change is needed
  (it concludes: **no S2 agent change is required** for any of the three — see
  §7).
- **TDAD scenarios** that assert the reference's new content **and** the
  backward-compat invariants, under `tdad_tests/scenarios/skills/cost-estimation/`
  (§8). Decide per concern whether to **extend** the existing `format-and-contract`
  / `cost-conditional` scenarios or **add** a new one (§8.1).
- **The version bump** (0.42.0 → 0.43.0) and its maintenance tail (CHANGELOG,
  marketplace `plugin_version`, README badge) — proposed here, applied at
  implementation time (§9).

### 2.2 Out of scope (deferred to S3–S6)

- **S3 — the `/cost-estimate` command** (#370). No file under
  `ai-literacy-superpowers/commands/`. The Output Validation Checkpoint that
  *runs* the checklist against an on-disk record is the command's; this slice
  only **defines** the checklist line, it does not implement a runtime validator.
- **S4 — orchestrator fold-in** (#371). No change to
  `agents/orchestrator.agent.md`; no gate added, moved, or re-weighted.
- **S5 — T0 ballpark** (#372).
- **S6 — calibration loop** (#373). No per-PR actuals capture; the
  `kind: calibration` grounding seam is untouched. The per-stage `cost_usd`
  sub-field is **not** a calibration input.
- **Any change to the cost-derivation methodology itself.** This slice makes a
  split-tier band's **non-collapsed (strictly-spread)** shape *record-internally
  checkable* (`low < high`; it does **not** make the full widening machine-checkable
  — the absolute-rate check is deferred to S3, §4.4.1); it does **not** alter how
  the widening is computed (the S1 binding table, the blended-rate skew, the join
  key all stand unchanged). The per-stage band is a **disclosure surface** for an
  already-computed widening, not a new computation.
- **A runtime validator binary or CI check.** The checklist is a specification a
  future consumer (S3) runs; no executable validator ships here. The TDAD
  scenarios assert the *reference's content* (the checklist line exists and reads
  correctly) and the backward-compat *invariants* structurally, by inspection of
  the reference and the worked examples.

### 2.3 What this slice does NOT widen by accident

The reference is a **stable contract** with merged consumers (the S2 agent; the
future S3 checkpoint). This slice changes it deliberately and minimally. The
guard rails:

- The sub-field is **optional and one-directionally coupled** to the existing
  top-level `cost_usd` (sub-field present ⟹ top-level present; not the reverse).
  It introduces **no new top-level field**, **no new required field**, and **no
  new grounding state**. The three grounding states (§ "three grounding states
  for cost") are untouched.
- The `generated_by` change is a **description widening**, not a new field or a
  new validation rule. No checklist line keys on `generated_by` today; this slice
  adds **none** (it does not introduce a `generated_by`-shape check that could
  retroactively fail an old record).
- The grounding-path change is a **documentation** of the existing convention
  (Example 1 already uses the directory path). It adds **no** check that a `path`
  must be a file, which would retroactively fail Example 1 and the merged S2
  agent's day-one-default record.

If a reviewer finds this slice adding a *required* field, a *new grounding
state*, a `generated_by`-shape check, or a `path`-must-be-a-file check, that is
scope creep that breaks backward-compatibility and must be cut.

## 3. The closed-world validation checklist — the thing backward-compat is measured against

The reference's **validation checklist** is the closed-world parser every
backward-compat claim in this spec is measured against. Today it runs these
checks (verbatim intent, `estimate-record-format.md` "Validation checklist"):

- **Ranges well-formed** — every **present** range (`tokens`, each
  `tokens_by_stage[].tokens`, `cost_usd` when present, `agent_compute_time`) has
  `low ≤ high`.
- **All four disclosure sections present** — Included, Excluded, Confidence
  rationale, Failure direction.
- **Per-axis confidence within cap** — each present `confidence` axis within the
  `target_kind` ceiling for `tokens`/`time`; the `cost` axis present **iff**
  `cost_usd` is present.
- **Cost pairing** — `cost_usd` and `cost_basis` **both present or both absent**;
  when absent, `Excluded` carries the cost-omission disclosure.
- **Time split** — both time fields present and separate.
- **No-verdict, field-absence layer** — no `recommendation`/`verdict`/`proceed`
  field.
- **No-verdict, positive-content layer** — the prose contains no imperative
  recommendation or go/no-go language.

**The closed-world property (load-bearing).** The checklist is a **closed
enumeration**. It rejects a record **only** when one of its named checks fails; it
does **not** reject a record for carrying a field the checklist does not mention.
This is the property the "Cost pairing" check already relies on — it asserts an
`iff` between two *named* fields and is silent about everything else. The
backward-compat demonstrations in §4–§6 all turn on this: a new optional field is
invisible to every check that does not name it, and the two new checks that do name
it (the "Per-stage cost coupling" and "Split-tier spread" lines of §4.4) are each
written to pass vacuously on its absence.

## 4. Concern 1 — the per-stage `cost_usd` sub-field

### 4.1 The decision (sub-field shape)

Add an **optional** sub-field to each `tokens_by_stage[]` entry:

| Sub-field | Type | Required | Purpose |
| --- | --- | --- | --- |
| `tokens_by_stage[].cost_usd` | range object `{ low, high }` | **optional, one-directionally coupled** — **present ⟹ top-level `cost_usd` present** (enforced); top-level `cost_usd` present ⟹ bands **SHOULD** be populated by emitters, but their **absence does NOT invalidate** the record | The per-stage dollar contribution. Makes the split-tier widening a machine-readable disclosure surface and a **record-internal** spread check: a validator can assert a split-tier stage's band has a strictly-positive ordered spread (`low < high`), consistent with the binding table's tier ordering. It **cannot** assert the absolute bounds equal the specific `claude-sonnet-4`/`claude-opus-4` rates — those live in the snapshot, not the record (see §4.4). |

The coupling is **one-directional, not a biconditional** (this is the deliberate
correction of the prior draft's `iff`, which a literal reader could tighten into a
class-B-breaking mandate). It mirrors the *enforced direction* of the existing
`cost_usd`/`cost_basis` pairing while leaving the reverse direction as an emitter
SHOULD:

- **Sub-field present ⟹ top-level `cost_usd` present** (state 3 — a usable
  snapshot grounds cost). This direction is **enforced** by the checklist: a
  per-stage band may never appear on a cost-omitted record.
- **Top-level `cost_usd` present ⟹ bands SHOULD be populated** by emitters (so the
  per-stage decomposition that produced the whole-record figure is surfaced), but a
  cost-present record that omits them is **still valid** — this direction is an
  emitter obligation, **not** a validation-rejection rule (§4.3, §4.4). This is the
  asymmetry that keeps S1-era class-B records valid.
- **Top-level `cost_usd` absent** (states 1 and 2 — cost-omitted) → **no**
  `tokens_by_stage[]` entry carries a per-stage `cost_usd`. The sub-field is
  absent everywhere, exactly as in the unchanged Example 1.

The whole-record `cost_usd` band need **not** equal the arithmetic sum of the
per-stage bands (stages may be correlated, and the widening is applied per stage),
consistent with the existing same-rule for `tokens` vs `tokens_by_stage[].tokens`.
When they differ the prose body says why — no **new** disclosure-body rule is
added; the existing "when they differ the prose body must say why" rule already
covers it.

### 4.2 Why optional-and-one-directionally-coupled, not required

A new **required** field would retroactively invalidate every old record and every
cost-omitted record (which has no per-stage cost to carry) — the exact
backward-compat break this slice exists to avoid. The **one-directional coupling**
to top-level `cost_usd` (present ⟹ top-level present) makes the enforced check a
function of an existing field, not a new mandate; the reverse direction (top-level
present ⟹ bands present) is held as an emitter SHOULD, so no record that predates
the sub-field is retroactively failed.

### 4.3 Backward-compatibility — DEMONSTRATED, not asserted

This is the defining requirement (S2 O2). The demonstration traces the **actual**
closed-world checklist semantics against four record classes:

| Record class | Has top-level `cost_usd`? | Has per-stage `cost_usd`? | Old checklist verdict | New checklist verdict | Why |
| --- | --- | --- | --- | --- | --- |
| **A. Old cost-omitted (S1/S2-era; Example 1, merged S2 day-one default)** | no | no | valid | **valid** | Every new per-stage check (§4.4) keys on the **presence of the sub-field**; with no sub-field present, each fires **vacuously**. No other check names the sub-field. Record unchanged, still valid. |
| **B. Old cost-present (S1-era; Example 2 before this slice)** | yes | no | valid | **valid** — the coupling is one-directional, not a biconditional; see the critical note below | This is the load-bearing case. The check keys on sub-field presence, not top-level presence, so a cost-present record with no bands is never rejected. See §4.4. |
| **C. New cost-omitted** | no | no | valid | valid | Identical to class A — the sub-field is absent, every new check fires vacuously. |
| **D. New cost-present (Example 2 after this slice)** | yes | yes | n/a (sub-field did not exist) | valid | The new checks assert the enforced coupling holds (sub-field present ⟹ top-level present), each per-stage band has `low ≤ high`, and each **split-tier** stage's band has a strictly-positive ordered spread (`low < high`). Example 2's implementer band `{0.40, 5.00}` satisfies the spread rule (§4.5). |

**The critical note on class B — the genuine backward-compat hazard.** A naive
**biconditional** check stated as *"top-level `cost_usd` present ⟺ every stage
carries a per-stage `cost_usd`"* would **reject class B** — an old cost-present
record that has top-level cost but no per-stage bands. That would be a
backward-compat break: S1's Example 2 (as merged) and any S1-era cost-present
record an old consumer produced would suddenly fail validation. This is precisely
the trap S2 O2 warned of — the prior draft of this spec **named the coupling
`iff`** (a biconditional) in the field table, which a literal reader (the reference
instructs readers to *parse*, not read loosely) would tighten into exactly this
class-B-breaking mandate. This revision removes the `iff` from the field table and
states the one-directional asymmetry there, so the field table and the §4.4 check
now say the same thing.

**The resolution.** The new check is written so the per-stage sub-field is
**forward-optional**: its presence is *permitted-and-coupled*, not *mandated*, by
top-level `cost_usd`. The exact checklist semantics (§4.4) are:

> When per-stage `cost_usd` sub-fields are **present on a record**, the record's
> **top-level `cost_usd` must also be present** (the sub-field never appears on a
> cost-omitted record), **every present** per-stage `cost_usd` has `low ≤ high`,
> and **every present split-tier** stage's band has a strictly-positive ordered
> spread (`low < high`).

Read carefully, this is a **one-directional** constraint keyed on the *presence of
the sub-field*, not on the presence of top-level cost:

- **Sub-field present, top-level absent** → **fail** (the genuinely incoherent
  case the check must catch).
- **Sub-field present, top-level present** → check `low ≤ high` on each, and
  `low < high` on each split-tier stage → pass for well-formed bands (class D).
- **Sub-field absent** → the check does not fire at all → pass (classes A, B, C).

Class B (old cost-present, no sub-field) **passes** because the sub-field is
absent, so the check does not fire. This is the demonstration: the constraint
catches the incoherent shape (a per-stage band with no whole-record cost) without
mandating the sub-field's presence on any record that predates it. The closed-world
property (§3) guarantees no *other* check rejects class B for the missing
sub-field, because no other check names it.

#### 4.3.1 The SHOULD-populate obligation — its falsifiable home (O4)

**The §4.1 "top-level cost present ⟹ bands SHOULD be populated" rule is an
emitter obligation, NOT a validation-rejection rule.** This is the load-bearing
distinction. The reference's *methodology prose* says a new emitter SHOULD populate
per-stage bands whenever it emits a top-level cost (so the widening is surfaced);
the *validation checklist* does **not** reject a record for omitting them, because
doing so would reject class B.

To keep this SHOULD distinguishable from a MAY (rather than aspirational
free-text), the spec gives it a **falsifiable home**: the SHOULD is stated as a
**requirement on the deferred follow-on emitter enhancement** (§12, the
standalone issue filed against the `cost-estimator` agent at adjudication). That
issue's acceptance criterion is "on a cost-present record, every exercised stage
carries a per-stage `cost_usd` band, and each split-tier stage's band has a
strictly-positive spread" — a falsifiable behavioural assertion a future Layer 3
scenario will grade once a snapshot fixture exists.

**Honest scope note for this slice.** No producer ships a cost-present record
today (the merged S2 agent emits only cost-omitted records — empty
`observability/costs/`). So within *this* format-only slice the obligation is
**"the format admits the band; no producer yet populates it."** The only
cost-present record carrying bands in this deliverable is the hand-authored
Example 2. The SHOULD is real and has a named, falsifiable home — but it is
honestly a documented obligation on a deferred enhancement, not a behaviour any
shipped emitter exhibits today.

#### 4.3.2 The inverse-rejection check guards a not-yet-producible shape (O8)

The one genuinely new *rejection* rule this slice adds — "fail a per-stage
`cost_usd` with no top-level `cost_usd`" — guards a shape **no consumer in
existence can currently produce**. The merged S2 agent emits only cost-omitted
records, which by construction carry no per-stage band; nothing today can create
the incoherent inverse. The check is kept anyway as a **cheap guard rail for
S3-era emitters** (a future buggy emitter could create it), and its enforcement
surface is honestly stated here: it protects against a shape only a future emitter
could create, while the *positive* obligation the slice cares about (bands
present, split-tier spread) is the SHOULD of §4.3.1, not a rejection rule. Not a
blocker; recorded so the slice's net-new enforcement surface is not overstated.

### 4.4 The validation-checklist edit

Three edits to the checklist, all backward-safe:

1. **Extend the existing "Ranges well-formed" enumeration** to name the new range:
   add `each tokens_by_stage[].cost_usd when present` to the bracketed list of
   present ranges that must have `low ≤ high`. Because the enumeration is
   guarded by "every **present** range", an absent sub-field is not checked —
   classes A, B, C pass unchanged.
2. **Add one new check line — "Per-stage cost coupling":**

   > **Per-stage cost coupling** — if **any** `tokens_by_stage[].cost_usd` is
   > present, the record's top-level `cost_usd` must also be present (per-stage
   > cost bands never appear on a cost-omitted record). A record with **no**
   > per-stage `cost_usd` sub-fields satisfies this check vacuously — **old
   > records and cost-omitted records are not rejected.** This check does **not**
   > mandate that a cost-present record carry per-stage bands; it only forbids the
   > incoherent inverse (a per-stage band with no whole-record cost). Emitters
   > SHOULD populate per-stage bands on cost-present records, but a cost-present
   > record without them remains valid for backward-compatibility with S1-era
   > records.

3. **Add one new check line — "Split-tier spread" (asserts a non-collapsed
   (strictly-spread) split-tier band — `low < high` — NOT that the band spans two
   tiers; the absolute-rate check is deferred to S3 per §4.4.1):**

   > **Split-tier spread** — for **every present** `tokens_by_stage[].cost_usd`
   > whose `model_tier` is a **split tier**, the band must have a
   > **strictly-positive ordered spread**: `low < high` (strict, not merely
   > `low ≤ high`). A `model_tier` **is a split tier if and only if its label
   > contains a `/`** (after the join-key whitespace normalisation); otherwise it
   > is a single tier. A collapsed band (`low == high`) on a split-tier stage fails
   > this check. **Single-tier** stages are exempt (they may carry `low == high`,
   > governed only by "Ranges well-formed"). A record with no per-stage `cost_usd`
   > satisfies this check vacuously.

   **The split-tier trigger is a CLOSED rule.** A `model_tier` is a split tier
   **iff its label contains a `/`** (after the join-key whitespace normalisation),
   so `Standard/Capable` and `Standard / Capable` both classify identically and a
   validator needs no enumerated set. No single (non-split) tier label contains a
   slash — `MODEL_ROUTING.md` names exactly the single tiers `Most capable` and
   `Standard` (neither contains `/`) plus the one complexity-dependent split
   `Standard / Capable` — so "contains `/`" is a sound *total* classifier over
   every tier label the reference admits.

   **Emitter convention (methodology, NOT a checked invariant).** By convention a
   split-tier stage prices its low bound at the **cheaper** representative model and
   its high bound at the **dearer** one (per the binding table — for
   `Standard / Capable`, `claude-sonnet-4` is the cheaper tier and `claude-opus-4`
   the dearer), so a genuine widening produces a non-zero spread. The validator
   **cannot** confirm which bound binds to which model from the record alone (it
   sees two numbers and their order, never the per-model pricing); this cheaper-at-
   low / dearer-at-high ordering is therefore an *emitter convention*, not a
   checkable invariant, and lives here in the methodology prose. The only predicate
   the checklist line tests on a present split-tier band is `low < high`.

The new lines are **written into the reference** so the demonstration lives in the
contract itself, next to the existing "Cost pairing" check they mirror. The TDAD
scenario (§8) asserts the lines' presence and their backward-compat wording.

#### 4.4.1 What the validator CAN and CANNOT assert (the O3 resolution)

The slice's reason to exist is to make a split-tier band's **non-collapsed
(strictly-spread)** shape record-internally checkable, not merely to add a place to
put the band — and to be honest that this is a *floor*, not the full widening. The
headline objection (O3) was that a `{ low: 99.0, high: 100.0 }` implementer band
would pass a presence/pairing/`low ≤ high` check while bearing no relationship to
the sonnet/opus rates the widening is defined by; the strict-spread check rejects
the collapsed `{x, x}` case but, as stated below, a `{99.0, 100.0}` band still
passes, so the check does not assert the band genuinely spans two tiers.

**The snapshot-dependency, and why option (a) is rejected.** A stateless checklist
parser reading **only the record** cannot know the **absolute** `claude-sonnet-4`
and `claude-opus-4` `$/token` rates — those live in the snapshot, not in the
emitted record. Option (a) — having the record carry the per-model rates it used
(e.g. in `grounding_sources` or a derivation field) so the check is fully
self-contained — is **rejected**: it adds data the merged S2 agent does not emit,
which (i) breaks backward-compat against every S1/S2-era record that lacks the new
field and (ii) re-introduces a new required field, the exact break §4.2 avoids.

**The mechanism chosen — option (b): a record-internal spread invariant.** The
"Split-tier spread" check above is the strongest **record-internal** invariant
available without snapshot data: on a split-tier stage the band MUST have a
strictly-positive ordered spread, and the binding table names which end is cheaper
(`claude-sonnet-4`, low) and which dearer (`claude-opus-4`, high). This rejects the
collapsed-band case (`{x, x}`) the widening cannot produce, turning the widening
from a pure prose/worked-example assertion into a record-internal check.

**State it plainly:**

- The validator **CAN** assert: (1) presence/coupling — a per-stage band implies
  top-level cost; (2) `low ≤ high` on every present band; (3) a strictly-positive
  ordered spread (`low < high`) on every present **split-tier** band — i.e. that the
  band is **non-collapsed (strictly spread)**. A `{ 99.0, 100.0 }` band still
  *passes* `low < high`, so the check earns only the move from "any ordered band
  (including a collapsed `{x, x}`)" to "a non-collapsed split-tier band". It does
  **not** earn "the band spans two tiers": a non-collapsed band is necessary, but
  not sufficient, for a genuine two-tier widening.
- The validator **CANNOT** assert: that the band **spans two tiers** (a
  `{99.0, 100.0}` band passes the strict-spread check while bearing no relationship
  to the two rates), that the absolute `low`/`high` **equal** the specific
  `claude-sonnet-4`/`claude-opus-4` rates, nor that the spread's magnitude is
  *correct* for those rates — all three require the snapshot, which the record does
  not carry. That absolute-rate falsification is a **runtime, snapshot-grounded
  check** and lands with S3's Output Validation Checkpoint (which can read both the
  record and the snapshot), not this format-only slice.

So this slice delivers the **record-internal** half of the S1-O6 checkability (the
spread invariant); the **absolute-rate** half is explicitly deferred to S3, where
the snapshot is in scope. This is the honest boundary, stated rather than
over-claimed.

### 4.5 The worked-example edit

- **Example 2 (cost-present) — UPDATE.** Add a `cost_usd: { low, high }` sub-field
  to each of the three `tokens_by_stage[]` entries with the **concrete** values
  derived below. The implementer entry's band, by the emitter convention, is priced
  at the cheaper representative model (`claude-sonnet-4`) at its low bound and the
  dearer (`claude-opus-4`) at its high bound. **Also update the whole-record
  `cost_usd` to `{ 1.60, 7.60 }`** — the exact sum of the three re-derived per-stage
  bands (the old `{ 0.95, 7.50 }` is replaced) — and update the Included prose: it
  now says the per-stage bands are surfaced as fields, not only described, and any
  dollar figure it cites for the whole-record band must read `$1.60–$7.60` (the
  implementer's `$0.40–$5.00` band is unchanged).

  **The three concrete bands (non-discretionary):**

  | Stage | `model_tier` | tokens `{ low, high }` | per-stage `cost_usd` `{ low, high }` |
  | --- | --- | --- | --- |
  | spec-writer | Most capable (`claude-opus-4`) | `{ 50000, 100000 }` | **`{ 1.00, 2.00 }`** |
  | tdd-agent | Standard (`claude-sonnet-4`) | `{ 50000, 150000 }` | **`{ 0.20, 0.60 }`** |
  | implementer | Standard / Capable (split) | `{ 100000, 250000 }` | **`{ 0.40, 5.00 }`** |

  **Derivation (reproducible from two fixed per-tier rates — every number is
  traceable to the two rates below):**

  1. **Fix two per-tier `$/token` rates**, ordered per the binding table
     (`claude-opus-4` dearer than `claude-sonnet-4`):
     - **sonnet (cheaper) = `4.0e-6` $/token**
     - **opus (dearer) = `2.0e-5` $/token** (5× sonnet)

     Every band below is one of these two rates applied to a token bound — nothing
     is allocated to hit a sum envelope. The single-tier stages use a single rate
     at both bounds; the split-tier implementer widens from the cheaper rate at its
     low bound to the dearer rate at its high bound.
  2. **Single-tier stages** = (that tier's rate) × (its token range, both bounds):
     - **spec-writer** (Most capable → opus): low `2.0e-5 × 50000 = 1.00`,
       high `2.0e-5 × 100000 = 2.00` → `{ 1.00, 2.00 }`.
     - **tdd-agent** (Standard → sonnet): low `4.0e-6 × 50000 = 0.20`,
       high `4.0e-6 × 150000 = 0.60` → `{ 0.20, 0.60 }`.
  3. **Split-tier implementer** (the widening) = sonnet rate × low-tokens … opus
     rate × high-tokens:
     - low `4.0e-6 × 100000 = 0.40` (cheaper rate, low bound),
       high `2.0e-5 × 250000 = 5.00` (dearer rate, high bound) → `{ 0.40, 5.00 }`.
     This matches the example's existing Included prose ("its `$0.40–$5.00` cost
     band") — the prose claim is now machine-checkable and rate-grounded.
  4. **Whole-record `cost_usd` = the resulting per-stage sum** (set equal by
     construction, the cleanest fix; the §4.4 correlation note permits the
     whole-record band to differ from the sum, but here they are made equal):
     - low `1.00 + 0.20 + 0.40 = 1.60`; high `2.00 + 0.60 + 5.00 = 7.60` →
       whole-record `cost_usd = { 1.60, 7.60 }`.

  **Every band satisfies the new checks AND an absolute-rate check (the deferred
  S3 validator):** all three have `low ≤ high`; each single-tier stage's low and
  high both equal its tier-rate × the respective token bound (so the band would
  pass an absolute-rate check); the **split-tier** implementer band has a
  strictly-positive spread (`0.40 < 5.00`), satisfying the §4.4 "Split-tier
  spread" rule, and its bounds are the cheaper rate at low / dearer rate at high.
  The whole-record `cost_usd` `{ 1.60, 7.60 }` is the exact sum of the three
  per-stage bands.
- **Example 1 (cost-omitted) — UNCHANGED.** No per-stage `cost_usd` appears. This
  is the demonstration-by-example of class A/C validity: the reference's own
  cost-omitted example still has no sub-field and still validates.

## 5. Concern 2 — `generated_by` field wording

### 5.1 The decision (widen the description)

**Widen the field's documented description** to admit a `tier:<tier>`
routing-tier label when the concrete model is unavailable. Do **not** reshape the
provenance contract, and do **not** require an S2 agent change.

The field description changes from:

> `generated_by` — Agent name + model identifier (e.g. `"cost-estimator / claude-opus-4-8"`).

to:

> `generated_by` — Agent name plus **either** a concrete model identifier (e.g.
> `"cost-estimator / claude-opus-4-8"`) **or** a `tier:<tier>` routing-tier label
> when the concrete model is not available to the emitter at emit time (e.g.
> `"cost-estimator / tier:Standard"` — an agent running `model: inherit` that is
> not told its resolved model records the routing tier it reads from
> `MODEL_ROUTING.md`). The value is **never** a guessed or hard-coded model string.
>
> **Recognised prefix grammar (so the two forms are mechanically
> distinguishable).** `tier:` is a **reserved provenance prefix**. The provenance
> token after the ` / ` separator is a **tier label** if and only if it begins with
> the literal `tier:`; otherwise it is a **concrete model identifier**. A concrete
> model id **never** begins with `tier:` (no model in `MODEL_ROUTING.md` or any
> snapshot is named with a `tier:` prefix), so a consumer can mechanically decide
> which form it holds by testing the `tier:` prefix — **without** any rejecting
> check being added. This is a *grammar*, not a validator: the slice adds no
> checklist line that rejects a malformed `generated_by`; it defines the prefix
> reservation so the field's two structurally distinct meanings are no longer
> ambiguous to a consumer splitting on the separator.

### 5.2 Why widen, not reshape

The merged S2 agent (`cost-estimator.agent.md`, "Provenance — `generated_by`")
**already emits** `cost-estimator / tier:Standard` on the common path, by a
deliberate two-branch convention the S2 review accepted as the honest least-bad
option. Reshaping the provenance contract (e.g. splitting `generated_by` into
`generated_by_agent` + `generated_by_model` + `generated_by_tier`) would:

- **break the merged S2 agent** (it emits a single `generated_by` string) and
  every S1/S2-era record;
- introduce new required fields — a backward-compat break;
- solve a wording mismatch with a schema change, which is disproportionate.

Widening the description **admits the merged agent's existing output** with zero
agent change. The honest `tier:` prefix the S2 agent already uses becomes the
documented, recognised form rather than an undocumented convention.

### 5.3 Backward-compatibility — DEMONSTRATED

The checklist has **no** check on `generated_by` shape or content today (confirmed
in S2 O1: "The validation checklist contains **no** check on the shape or content
of `generated_by`"). This slice adds **none**.

| Record class | `generated_by` value | Old checklist verdict | New checklist verdict | Why |
| --- | --- | --- | --- | --- |
| Old (Example 1/2, S1-era) | `cost-estimator / claude-opus-4-8` | valid (no check) | valid (no check) | No check fires on `generated_by`; the widened *description* admits both forms; no new check is added. |
| Merged S2 day-one default | `cost-estimator / tier:Standard` | valid (no check, but **contradicts the description**) | **valid AND now description-conformant** | The widened description recognises the `tier:` form; the record was always valid, and is now also documentation-conformant. |

The change is **description-only**, so it cannot reject any record — there is no
machine check to fire. Its value is **honesty-of-documentation**: the field's
description now matches what the merged emitter writes, closing the S2 O1
spec↔contract gap. Adding a `generated_by`-shape *check* is explicitly **out of
scope** (§2.3) — it would risk retroactively failing a record and is not needed to
resolve the concern.

**On the parse-ambiguity (O6).** Admitting the `tier:` form into a single
free-text field would, without further structure, leave a consumer unable to tell
a tier label from a concrete model id when splitting on the ` / ` separator. The
slice does **not** add a rejecting check (that would risk retroactive failures),
but it **does** close the ambiguity by defining `tier:` as a **reserved provenance
prefix** (§5.1): a concrete model id never begins with `tier:`, so the prefix test
is a total, mechanical discriminator. The field's content remains unvalidated *for
rejection*, but it is no longer *ambiguous*: the grammar gives a consumer a
deterministic rule to classify the value without a check. The merged S2 agent's
`tier:Standard` output satisfies this grammar with no agent change.

### 5.4 S2 agent change needed? — **No.**

The S2 agent already emits the `tier:` form by design. Widening the description
makes that output conformant. **No S2 agent edit is required for concern 2.**

## 6. Concern 3 — cost-snapshot grounding-path convention

### 6.1 The decision (keep the directory path, document it as the sentinel)

**Keep the directory path `observability/costs/` and document it as the named
cost-omitted sentinel.** Do **not** make the entry optional, and do **not**
introduce a new sentinel token. The mandatory cost-snapshot entry stays present,
its `path` carries the directory the emitter inspected (trailing slash marking it
a directory, not a file), and the reference now **documents** this as the defined
cost-omitted shape rather than leaving it as an undocumented Example-1 precedent.

The reference's `grounding_sources` field description and the "three grounding
states" section gain an explicit note:

> When no snapshot **file** exists (states 1 and 2 — cost-omitted), the mandatory
> `cost-snapshot` grounding entry's `path` is the **directory** the emitter
> inspected, written with a trailing slash (`observability/costs/`). This is the
> **defined cost-omitted sentinel**: the entry remains *present* (satisfying the
> "at minimum a cost-snapshot entry" rule), and the directory path records what
> the emitter actually read — the directory it inspected and found empty (or
> without a usable snapshot). The `Excluded` prose names that the directory held
> no usable snapshot. The entry is **never dropped** and **never given a
> fabricated snapshot file path**. When a usable snapshot file exists (state 3),
> the `path` is that **file** (e.g. `observability/costs/2026-08-15-costs.md`).
>
> **Consumer special-case (do not double-count).** Because the trailing-slash
> directory path means *looked-and-found-nothing* rather than *grounded-in-a-
> snapshot*, an aggregator that counts "how many records were grounded in a cost
> snapshot" **must not** count a `cost-snapshot` entry whose `path` ends in `/` as
> a grounding — it is a sentinel for the *absence* of a snapshot. Test the trailing
> slash (directory) versus a file path to distinguish the two meanings.

**This does not "resolve" the semantic tension — it entrenches an overloaded
meaning, deliberately (O5).** The `grounding_sources` field now carries two
meanings for a `cost-snapshot` entry depending on whether the `path` resolves to a
**file** (grounded in that snapshot) or a **trailing-slash directory**
(looked-and-found-nothing — the negative fact "no snapshot here"). The honest
framing: the directory *is* the thing the emitter read to *determine* that no
snapshot exists, so it is a real input in the weak sense — but naming it a
`grounding_sources` entry widens "the inputs the estimate was built from" to admit
"a location an input was looked for and not found." This slice chooses that
entrenchment over a new sentinel token (§6.2) on backward-compat grounds (zero S2
change, zero new parse case), and pays for it with the consumer special-case above.
The strain is **named and accepted**, not eliminated.

**Noted residual (O5).** The trailing-slash consumer special-case is
**advisory/unenforced** — no validation-checklist line keys on `grounding_sources[].path`
shape — so it externalises a **silent-miscount risk** onto every downstream counter
(S3's checkpoint, any cost aggregator): nothing catches a consumer that counts a
trailing-slash directory entry as a real grounding. This is an accepted residual of
the deliberate keep-the-directory-sentinel trade, not a fix deferred to a later slice.

### 6.2 Why keep, not make-optional or invent-a-sentinel

- **Make the entry optional when omitted** — rejected. The S1 "at minimum a
  cost-snapshot entry" rule is a deliberate honesty signal (the record always
  shows it *looked* for a snapshot). Dropping the entry on cost-omission would
  remove that signal and would **break the merged S2 agent**, which emits the
  entry with the directory path and explicitly "never drops" it.
- **Invent a new sentinel token** (e.g. `path: <none>` or a `kind: no-snapshot`)
  — rejected. It introduces a new value the merged S2 agent does not emit (an S2
  break) and a new enum/parse case for every consumer, to replace a directory
  path that already works and already appears in Example 1.
- **Keep the directory path and document it** — chosen. Zero S2 change, zero new
  parse case, and it ratifies the existing Example-1 precedent as the named
  convention. The only edit is **documentation** in the reference.

### 6.3 Backward-compatibility — DEMONSTRATED

| Record class | cost-snapshot `path` | Old checklist verdict | New checklist verdict | Why |
| --- | --- | --- | --- | --- |
| Old cost-omitted (Example 1, merged S2 default) | `observability/costs/` (directory) | valid | valid | No checklist line constrains `grounding_sources[].path` to be a file. The "at minimum a cost-snapshot entry" presence rule is satisfied by the present entry. The change is documentation only — it adds **no** path-shape check. |
| Cost-present (Example 2) | `observability/costs/2026-08-15-costs.md` (file) | valid | valid | Unchanged; a file path was always conformant. |

The demonstration: this slice adds **no** `path`-must-be-a-file check (which would
retroactively fail Example 1 and the merged S2 default record). It documents the
existing directory-path convention. The closed-world property (§3) means the
absence of a path-shape check is what keeps every record valid; the change is
purely additive documentation.

### 6.4 S2 agent change needed? — **No.**

The merged S2 agent already emits the directory path `observability/costs/` on the
cost-omitted path ("An empty `observability/costs/` is NOT a refusal" section) and
already notes in `Excluded` that the directory held no snapshot. Documenting the
convention ratifies that behaviour. **No S2 agent edit is required for concern 3.**

## 7. Does any S2 agent change ship in this slice? — **No.**

The deliberate design of all three resolutions is to **widen / document the format
to admit the merged S2 agent's existing output**, never to require the agent to
change:

| Concern | Resolution | S2 agent change? |
| --- | --- | --- |
| 1. Per-stage `cost_usd` | Add an optional, one-directionally coupled sub-field (present ⟹ top-level cost present; NOT an `iff`) with a split-tier spread check; **emitters SHOULD populate it on cost-present records** | **No change required for conformance.** The merged S2 agent emits cost-omitted records today (empty `observability/costs/`), which carry **no** per-stage band and stay valid (class A/C). The agent is **not broken** by the addition. A **follow-on enhancement** to have the S2 agent populate per-stage bands on cost-present records is **noted as a future emitter improvement**, NOT shipped here — it is out of scope and filed against the agent's own follow-up, because today the agent emits no cost-present records (no usable snapshot exists). |
| 2. `generated_by` wording | Widen the description to admit `tier:<tier>` | **No.** The agent already emits the `tier:` form. |
| 3. Grounding-path | Document the directory-path sentinel | **No.** The agent already emits the directory path. |

**The conscious call recorded here (for diaboli scrutiny):** concern 1 introduces
a sub-field the merged S2 agent does **not** emit. The spec chooses **not** to
ship an S2 agent change in this slice, and justifies it: (a) the agent emits no
cost-present records today (empty `observability/costs/`), so there is nothing for
it to under-populate against a live snapshot; (b) the format's checklist does
**not** mandate the sub-field on cost-present records (the §4.3 forward-optional
rule), so the agent stays conformant when a snapshot eventually lands even before
the follow-on; (c) bundling an emitter behaviour change with the format change
would re-create the exact consumer/owner conflation that got this concern split
out of S2 in the first place. The follow-on emitter enhancement is **named and
deferred**, not orphaned — it is recorded in the spec's §11 watch-items and SHOULD
be filed as a standalone issue against the `cost-estimator` agent at adjudication
(per the AGENTS.md "a natural-home hand-off does not bind the next slice; re-file,
do not leave implicit" decision).

## 8. Component design (per component-design-with-tdad)

- **Type**: a reference/format-contract edit — the deliverable is the modified
  `estimate-record-format.md` (a `skills/<name>/references/<contract>.md` file per
  the AGENTS.md cross-cutting-methodology decision) plus the scenarios that assert
  it. Not a new skill, agent, or command.
- **Justification**: the reference is the single canonical contract; editing it in
  one place propagates to every consumer that references it by path (the merged S2
  agent, the future S3 checkpoint). This is the exact idiom the AGENTS.md decision
  prescribes.
- **TDAD layers targeted**: `[structural]` only. Every assertion is mechanically
  checkable by reading `estimate-record-format.md` and matching against the field
  table, the validation checklist, and the two worked-example blocks. No
  dispatchable side-effect ships in this slice (the S2 agent is unchanged; the S3
  checkpoint is out of scope), so Layer 3 behavioural grading does not apply — the
  same posture as the S1 `format-and-contract` scenario, which is structural for
  the same reason. A future Layer 3 scenario (load the agent against a live
  snapshot, assert the emitted cost-present record carries conformant per-stage
  bands) is deferred to whichever slice wires a snapshot fixture (S6/calibration or
  the follow-on emitter enhancement).
- **What "demonstrated" means here vs what is deferred (O7 — honest framing).**
  This slice's load-bearing claim is *demonstrated backward-compatibility*. Be
  precise about what structural inspection delivers and what it does not:
  - **Delivered here (structural).** Inspection of the reference establishes the
    checklist **TEXT** (the "Per-stage cost coupling" and "Split-tier spread" lines
    exist with their backward-safe wording), and the **four-class argument a human
    traces** (§4.3 — that a faithful closed-world parser would accept classes A–D
    and reject only the incoherent inverse). The scenarios assert the *content of
    the contract* and the *coherence of the argument*, not the behaviour of a
    parser. The new-scenario phrasings ("rejects the incoherent inverse", "no
    `generated_by`-shape check exists", "no `path`-must-be-a-file check exists") are
    assertions about the **checklist text** and the **absence of named checks in the
    reference** — both directly readable — re-stated as the verdicts a faithful
    parser *would* return, not the output of a parser actually run.
  - **Deferred to S3 (runtime falsification).** An **actual closed-world parser run
    over the four record classes** — the falsification that would turn the traced
    argument into an executed demonstration — lands with S3's Output Validation
    Checkpoint, which implements the runtime validator. This slice **defines** the
    checklist; it does **not** run it. The claim here is therefore "the checklist
    text and the four-class argument are demonstrated by structural inspection", not
    "the closed-world behaviour is demonstrated by execution." The latter is honestly
    S3's, and the spec does not over-claim it.
- **Scenario vs finding**: scenario only — every assertion (the sub-field is in
  the field table; the new checklist line exists and is backward-safe; Example 2
  carries per-stage bands; Example 1 is unchanged; the `generated_by` description
  admits `tier:`; the grounding-path sentinel is documented) is falsifiable by
  inspection of the reference.

### 8.1 Extend or add scenarios — the decision

The existing S1 scenarios under `tdad_tests/scenarios/skills/cost-estimation/`
assert the S1 reference content. This slice changes that content, so the existing
scenarios must stay **consistent** with the edited reference, and new assertions
are needed for the new content. The decision, per concern:

- **`format-and-contract.md` — EXTEND.** It already asserts the field table, the
  binding table, and the two worked examples. Extend its `Then` to assert: the
  `tokens_by_stage[].cost_usd` sub-field is in the field table marked **optional and
  one-directionally coupled** (sub-field present ⟹ top-level cost present; the
  reverse is an emitter SHOULD, **not** an `iff`); the new "Per-stage cost coupling"
  **and** "Split-tier spread" checklist lines are present with their backward-safe
  wording; Example 2 carries the three concrete per-stage bands (spec-writer
  `{1.00, 2.00}`, tdd-agent `{0.20, 0.60}`, implementer `{0.40, 5.00}`, summing to
  the whole-record `{1.60, 7.60}`) with the
  split-tier implementer band showing a strictly-positive spread; Example 1 carries
  **no** per-stage band; the `generated_by` description admits the `tier:<tier>`
  form and defines `tier:` as a **reserved prefix**; the grounding-path sentinel
  (with its consumer special-case) is documented. Extending (not adding) keeps the
  single structural contract for the reference in one scenario, consistent with
  the corpus's one-scenario-per-contract shape.
- **`cost-conditional.md` — EXTEND minimally.** It asserts the cost-omitted shape
  and the three grounding states. Extend its `Then` to assert the cost-omitted
  worked example (and the cost-omitted shape generally) carries **no** per-stage
  `cost_usd` sub-field, and that the cost-snapshot grounding entry's directory-path
  sentinel is the documented cost-omitted convention — locking the class-A/C
  backward-compat invariant at the cost-conditional boundary where it belongs.
- **Add ONE new scenario — `per-stage-cost-backward-compat.md`.** A dedicated
  structural scenario whose entire job is the **backward-compatibility invariant**
  (the load-bearing requirement of this slice). Per the O7 framing above, it is a
  **structural** scenario: it asserts the **checklist text** and the **four-class
  argument**, not the output of a parser actually run (that runtime falsification is
  S3's). Its `Then` asserts that the checklist, **read as a closed-world parser**,
  accepts **all four record classes** of §4.3 (old cost-omitted, old cost-present
  without per-stage bands, new cost-omitted, new cost-present with per-stage bands);
  **rejects** the incoherent inverse (a per-stage band with no top-level cost); and
  **rejects** a collapsed split-tier band (`low == high` on a split-tier stage,
  which the "Split-tier spread" rule forbids). It also asserts the **absence** of
  two named checks in the reference — no `generated_by`-shape check and no
  `path`-must-be-a-file check — both directly readable as the non-presence of those
  lines. This isolates the demonstrated-not-asserted invariant into its own
  falsifiable scenario, so a future edit that "tightens" the per-stage coupling into
  a class-B-breaking mandate, or that drops the split-tier spread rule, fails this
  scenario loudly.

Three concerns, three scenario touches: two extensions of existing scenarios and
one new backward-compat scenario. No scenario is deleted.

## 9. Version bump and maintenance tail

This slice edits a plugin reference file (a format/schema change), so it warrants
a **minor** bump per the CLAUDE.md semver rules (a behavioural/format change to
plugin files):

- `ai-literacy-superpowers/.claude-plugin/plugin.json`: `version` 0.42.0 → 0.43.0.
- `CHANGELOG.md` (repo root): new `## 0.43.0 — <implementation date>` heading with
  entries for the per-stage `cost_usd` sub-field (optional, one-directionally
  coupled, backward-compatible; split-tier spread check makes the widening
  record-internally checkable), the `generated_by` description widening (with the
  `tier:` reserved prefix), and the grounding-path sentinel documentation.
- `.claude-plugin/marketplace.json`: bump the `ai-literacy-superpowers` entry
  `version` and the top-level `plugin_version` to 0.43.0; leave top-level
  `version` at 0.4.0.
- `README.md`: bump the plugin badge 0.42.0 → 0.43.0.

**Do NOT apply the bump at spec time** — it is an implementation-time step,
recorded here for the plan. The validation checklist and the worked examples both
live in the reference and **must stay mutually consistent** — the implementation
must edit both (the new checklist line AND Example 2's per-stage bands) in the same
change, and the `format-and-contract` scenario asserts that consistency.

## 10. Functional requirements

Numbered, testable, each traceable to a scenario in §8:

- **FR-1** — `estimate-record-format.md` defines `tokens_by_stage[].cost_usd` as
  an **optional** `{ low, high }` range sub-field under a **one-directional
  coupling**, stated as such **in the field table** (not as an `iff`): sub-field
  present ⟹ top-level `cost_usd` present (enforced); top-level `cost_usd` present
  ⟹ bands SHOULD be populated by emitters but their absence does NOT invalidate the
  record. The field table and the §4.4 check say the same thing.
- **FR-2** — The field table / range rules name the per-stage `cost_usd` sub-field
  in the "every present range has `low ≤ high`" enumeration (guarded by
  *present*, so absence is not checked).
- **FR-3** — The validation checklist carries a **"Per-stage cost coupling"** line
  that (a) fails a record carrying a per-stage `cost_usd` with no top-level
  `cost_usd`, (b) passes vacuously when no per-stage sub-field is present (old
  records, cost-omitted records), and (c) does **NOT** mandate per-stage bands on
  a cost-present record (so S1-era class-B records stay valid).
- **FR-3b** — The validation checklist carries a **"Split-tier spread"** line that,
  for every **present** per-stage `cost_usd` whose `model_tier` is a **split tier**,
  requires a **strictly-positive ordered spread** (`low < high`) — rejecting a
  collapsed band (`low == high`) on a split-tier stage. The split-tier trigger is a
  **closed rule**: a `model_tier` is a split tier **iff its label contains a `/`**
  (after the join-key whitespace normalisation), and no single (non-split) tier
  label contains a slash, so "contains `/`" is a sound total classifier (§4.4).
  Single-tier stages are exempt; an absent sub-field satisfies it vacuously. This is
  the record-internal half of the S1-O6 checkability: the validator CAN assert a
  split-tier band is **non-collapsed (strictly spread)** — `low < high` — but
  CANNOT assert the band **spans two tiers** (a `{99.0, 100.0}` band passes) nor
  that the bounds equal the absolute `claude-sonnet-4`/`claude-opus-4` rates (that
  snapshot-grounded check is S3's, per §4.4.1). The cheaper-at-low / dearer-at-high
  ordering is an **emitter convention** (methodology prose), not a checked invariant.
- **FR-4** — The cost-present worked example (Example 2) carries the three concrete
  per-stage `cost_usd` bands derived in §4.5 — spec-writer `{ 1.00, 2.00 }`,
  tdd-agent `{ 0.20, 0.60 }`, implementer `{ 0.40, 5.00 }` — each re-derived from
  two fixed per-tier rates (sonnet `4.0e-6`, opus `2.0e-5` $/token) applied to that
  stage's tokens, so each single-tier band's low and high equal its tier-rate ×
  the respective token bound (the band would pass an absolute-rate check); the
  per-stage bands sum exactly to the whole-record `{ 1.60, 7.60 }` (set equal by
  construction); the implementer split-tier band has a strictly-positive spread
  and matches the Included prose's stated `$0.40–$5.00` band.
- **FR-5** — The cost-omitted worked example (Example 1) carries **no** per-stage
  `cost_usd` sub-field and remains valid (class A/C).
- **FR-6** — The reference demonstrates (in a checklist note and by the two worked
  examples) that all four §4.3 record classes validate and only the incoherent
  inverse is rejected — the backward-compat invariant, shown not asserted.
- **FR-7** — The `generated_by` field description admits **both** a concrete model
  identifier **and** a `tier:<tier>` routing-tier label, defines **`tier:` as a
  reserved provenance prefix** (a concrete model id never begins with `tier:`, so a
  consumer can mechanically distinguish the two forms by the prefix without any
  rejecting check), and states the value is never a guessed/hard-coded model.
- **FR-8** — No validation-checklist line keys on `generated_by` shape (the
  widening is description-only; no record is retroactively rejected).
- **FR-9** — The reference documents the directory path `observability/costs/`
  (trailing slash) as the **named cost-omitted sentinel** for the mandatory
  cost-snapshot grounding entry; the entry is never dropped and never given a
  fabricated file path; a snapshot file path is used in state 3.
- **FR-10** — No validation-checklist line requires `grounding_sources[].path` to
  be a file (the directory-path convention stays valid; no record is retroactively
  rejected).
- **FR-11** — No S2 agent change ships in this slice; the merged S2 agent's
  emitted records (cost-omitted shape, `tier:Standard` provenance, directory
  grounding-path) are all conformant against the edited reference. The follow-on
  emitter enhancement (populate per-stage bands on cost-present records) is named
  and deferred, not orphaned.
- **FR-12** — The version bump (0.42.0 → 0.43.0) is proposed across the four
  locations and applied only at implementation time; the checklist and worked
  examples stay mutually consistent.

### 10.1 FR → scenario map

| FR | Covering scenario |
| --- | --- |
| FR-1 | `format-and-contract.md` (extended) |
| FR-2 | `format-and-contract.md` (extended) |
| FR-3 | `format-and-contract.md` (extended) + `per-stage-cost-backward-compat.md` (new) |
| FR-3b | `format-and-contract.md` (extended) + `per-stage-cost-backward-compat.md` (new — rejects collapsed split-tier band) |
| FR-4 | `format-and-contract.md` (extended) |
| FR-5 | `cost-conditional.md` (extended) + `per-stage-cost-backward-compat.md` (new) |
| FR-6 | `per-stage-cost-backward-compat.md` (new) |
| FR-7 | `format-and-contract.md` (extended) |
| FR-8 | `per-stage-cost-backward-compat.md` (new — asserts no `generated_by`-shape check exists) |
| FR-9 | `format-and-contract.md` (extended) + `cost-conditional.md` (extended) |
| FR-10 | `per-stage-cost-backward-compat.md` (new — asserts no path-shape check exists) |
| FR-11 | (no scenario — an out-of-scope assertion; verified by the absence of any S2 agent edit in the module-touch list, checked at PR time) |
| FR-12 | local version-consistency check (implementation-time) |

## 11. User stories and acceptance scenarios

### 11.1 Story — a split-tier band's non-collapsed spread is machine-checkable on a cost-present record

**As** a future Output Validation Checkpoint (S3) author
**I want** the per-stage `cost_usd` bands to be a field on the record, with a
record-internal strictly-spread invariant on split-tier stages
**So that** I can assert a split-tier band is non-collapsed (strictly spread,
`low < high`) from the record alone, rather than trusting prose — and know exactly
which absolute-rate check I must defer to my own snapshot-grounded validator.

```gherkin
Given ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md
When I read the frontmatter field table and the cost-present worked example
Then tokens_by_stage[].cost_usd is defined as an optional { low, high } range
    under a one-directional coupling (sub-field present implies top-level cost
    present; the reverse is an emitter SHOULD, not an iff)
And the cost-present worked example (Example 2) carries a per-stage cost_usd on
    each tokens_by_stage entry with the concrete bands spec-writer {1.00,2.00},
    tdd-agent {0.20,0.60}, implementer {0.40,5.00}, re-derived from two fixed
    per-tier rates (sonnet 4.0e-6, opus 2.0e-5 $/token)
And the implementer entry (a split tier) has a strictly-positive ordered spread
    (low < high), priced by the emitter convention at the cheaper representative
    model (low) and the dearer (high) per the binding table, matching the Included
    prose
And the reference states the validator CAN assert the split-tier band is
    non-collapsed (strictly spread) but CANNOT assert the band spans two tiers nor
    that the bounds equal the absolute snapshot rates (that check is S3's)
And the whole-record cost_usd band equals the per-stage sum {1.60,7.60} here (set
    equal by construction), though the existing correlation note permits them to
    differ in general
```

### 11.2 Story — old and new records both validate (backward-compat, demonstrated)

**As** the owner of the stable format contract
**I want** the new sub-field's validation to be demonstrated backward-compatible
against the closed-world checklist
**So that** neither S1/S2-era records nor new records are rejected, and only the
incoherent inverse is caught.

```gherkin
Given the edited estimate-record-format.md validation checklist read as a
    closed-world parser
When I trace it against the four record classes
Then an old cost-omitted record (no top-level cost, no per-stage band) is VALID
And an old cost-present record with top-level cost but NO per-stage bands is VALID
    (the per-stage coupling check does not mandate the sub-field)
And a new cost-omitted record (no sub-field) is VALID
And a new cost-present record with per-stage bands on every stage is VALID
And a record carrying a per-stage cost_usd with NO top-level cost_usd is REJECTED
    by the "Per-stage cost coupling" check
And a record whose split-tier stage carries a collapsed band (low == high) is
    REJECTED by the "Split-tier spread" check
And the "Ranges well-formed" enumeration includes tokens_by_stage[].cost_usd
    "when present", so an absent sub-field is never checked
And no checklist line keys on generated_by shape and no checklist line requires
    grounding_sources[].path to be a file (both readable as absent in the reference)
```

### 11.3 Story — the cost-omitted record is unchanged and still valid

**As** a human running the estimator on today's repo (empty `observability/costs/`)
**I want** the cost-omitted record shape unchanged by this slice
**So that** the merged S2 agent's day-one-default output stays conformant.

```gherkin
Given the edited estimate-record-format.md
When I read the cost-omitted worked example (Example 1)
Then it carries no tokens_by_stage[].cost_usd sub-field on any stage
And cost_usd and cost_basis remain absent with the omission disclosed in Excluded
And the mandatory cost-snapshot grounding entry's path is the directory
    "observability/costs/" (trailing slash), documented as the cost-omitted sentinel
And the record validates against the edited checklist (class A/C)
```

### 11.4 Story — `generated_by` admits the merged agent's tier label

**As** a reader or downstream consumer parsing `generated_by`
**I want** the field's description to recognise the `tier:<tier>` form the merged
S2 agent emits
**So that** the most common record's provenance value is documentation-conformant,
not a silent contradiction.

```gherkin
Given the edited estimate-record-format.md generated_by field description
When I read it
Then it admits both a concrete model identifier and a "tier:<tier>" routing-tier
    label when the concrete model is unavailable
And it defines "tier:" as a reserved provenance prefix, so a consumer can
    mechanically distinguish a tier label from a concrete model id (which never
    begins with "tier:") without any rejecting check
And it states the value is never a guessed or hard-coded model string
And no validation-checklist line keys on generated_by shape (no record is
    retroactively rejected by the widening)
And the merged S2 agent's "cost-estimator / tier:Standard" output is now
    description-conformant with no S2 agent change
```

### 11.5 Story — the grounding-path directory sentinel is documented

**As** a reader of the cost-omitted record
**I want** the directory grounding-path documented as a named sentinel
**So that** "the inputs the estimate was built from" reads coherently for the
empty-snapshot case, and the merged S2 agent's behaviour is ratified.

```gherkin
Given the edited estimate-record-format.md grounding_sources description and
    three-grounding-states section
When I read them
Then the directory path "observability/costs/" (trailing slash) is documented as
    the cost-omitted sentinel for the mandatory cost-snapshot entry
And the reference states this entrenches an overloaded meaning (file = grounded;
    trailing-slash directory = looked-and-found-nothing) rather than resolving it
And the reference carries a consumer special-case note: an aggregator counting
    snapshot-grounded records must not count a trailing-slash directory path as a
    grounding
And the entry is never dropped and never given a fabricated snapshot file path
And a usable snapshot (state 3) uses the snapshot file path instead
And no validation-checklist line requires grounding_sources[].path to be a file
    (no record is retroactively rejected)
And the merged S2 agent's directory-path output stays conformant with no S2 change
```

## 12. Watch-items (named, not orphaned)

- **Follow-on emitter enhancement (concern 1) — the falsifiable home of the
  SHOULD (O4).** Have the `cost-estimator` agent populate per-stage `cost_usd`
  bands on the cost-present records it emits once a usable snapshot exists. This is
  the **emitter requirement that satisfies the §4.1/§4.3.1 SHOULD** — without it the
  SHOULD would be indistinguishable from a MAY. Its acceptance criterion is
  falsifiable: "on a cost-present record, every exercised stage carries a per-stage
  `cost_usd` band, and each split-tier stage's band has a strictly-positive spread"
  — gradable by a future Layer 3 scenario once a snapshot fixture exists. **Not
  shipped here** (the agent emits no cost-present records today; bundling an emitter
  change with the format change re-creates the consumer/owner conflation this slice
  exists to avoid). **File as a standalone issue against the `cost-estimator` agent
  at adjudication**, per the AGENTS.md "a natural-home hand-off does not bind the
  next slice — re-file, do not leave implicit" decision. Until filed, it is recorded
  here; within this slice the obligation is honestly "the format admits the band; no
  producer yet populates it" (§4.3.1).
- **A future Layer 3 behavioural scenario** that dispatches the agent against a
  live snapshot fixture and asserts the emitted cost-present record's per-stage
  bands conform — deferred to whichever slice wires a snapshot fixture (the
  follow-on emitter enhancement or S6).
