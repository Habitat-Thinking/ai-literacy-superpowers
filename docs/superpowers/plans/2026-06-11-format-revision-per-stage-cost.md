# Cost Estimation — format-revision slice — per-stage `cost_usd`, `generated_by` wording, grounding-path convention — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Resolve the three deferred format concerns against the estimate-record
format reference this slice **owns** — add an optional, **one-directionally
coupled** per-stage `tokens_by_stage[].cost_usd` sub-field with a **split-tier
spread check** (making a split-tier band's NON-COLLAPSED, strictly-spread shape
record-internally checkable — `low < high`; NOT the full widening, whose
absolute-rate check is deferred to S3), widen the `generated_by` field description
to admit a `tier:<tier>`
label with **`tier:` as a reserved prefix**, and document the directory
grounding-path (`observability/costs/`) as the named cost-omitted sentinel (an
**entrenched** overloaded meaning with a consumer special-case, honestly stated)
— with each change **demonstrated** backward-compatible against the closed-world
validation checklist. Plugin version bumps `0.42.0 → 0.43.0`.

**This is a format-revision slice, not a carpaccio slice.** It is a scoped residue
of S2's diaboli, deliberately split out so the contract mutation gets its own
adversarial pass with the backward-compat claim *demonstrated, not asserted*. It
ships **format-only** changes: the reference, its TDAD scenarios, and the version
tail. **No S3 command, no S4 orchestrator wiring, no S6 calibration.**

**No S2 agent change ships.** All three resolutions widen / document the format to
**admit the merged S2 agent's existing output** (cost-omitted shape, `tier:Standard`
provenance, directory grounding-path), so the merged agent stays conformant with
zero edits. The follow-on emitter enhancement (populate per-stage bands on
cost-present records) is named and deferred to a standalone issue, not shipped.

**Architecture:** A single canonical reference edit (the
`skills/<name>/references/<contract>.md` idiom per AGENTS.md). The reference is
referenced by path by its consumers (the merged S2 agent, the future S3
checkpoint); editing it in one place propagates. The validation checklist and the
worked examples both live in the reference and **must stay mutually consistent** —
the new checklist line and Example 2's per-stage bands are edited in the same
change.

**Tech Stack:** Markdown + JSON. No new dependencies, no code, no runtime validator.

**Spec reference:** `docs/superpowers/specs/2026-06-11-format-revision-per-stage-cost-design.md`

---

## Modules / files touched

```
ai-literacy-superpowers/
├── .claude-plugin/plugin.json                              # MODIFIED: 0.42.0 → 0.43.0
└── skills/cost-estimation/references/
    └── estimate-record-format.md                           # MODIFIED — this slice OWNS it:
                                                             #   + tokens_by_stage[].cost_usd sub-field (field table, one-directional coupling, NOT iff)
                                                             #   + "Per-stage cost coupling" + "Split-tier spread" checklist lines + Ranges-well-formed enum
                                                             #   + §4.4.1 "what the validator CAN/CANNOT assert" note (record-internal spread, not absolute rates)
                                                             #   + Example 2 per-stage cost_usd bands {1.00,2.00}/{0.20,0.60}/{0.40,5.00} (re-derived from sonnet 4.0e-6, opus 2.0e-5 $/token); whole-record cost_usd → {1.60,7.60}; Example 1 UNCHANGED
                                                             #   ~ generated_by description widened (admits tier:<tier>; tier: = reserved prefix)
                                                             #   ~ grounding_sources / three-grounding-states: directory-path sentinel documented
                                                             #     (entrenchment named + consumer special-case: don't count trailing-slash dir as a grounding)
#   NOTE: agents/cost-estimator.agent.md is NOT touched — the format is widened to
#   admit its existing output; no S2 agent change ships (spec §7, FR-11).

CHANGELOG.md                                                 # MODIFIED: new 0.43.0 entry (repo root, not under the plugin dir)

tdad_tests/scenarios/skills/cost-estimation/
├── format-and-contract.md                                  # MODIFIED — extend Then: sub-field in field table; new checklist line;
│                                                            #   Example 2 per-stage bands; generated_by tier form; grounding-path sentinel
├── cost-conditional.md                                     # MODIFIED — extend Then: cost-omitted shape carries NO per-stage band;
│                                                            #   directory-path sentinel is the documented cost-omitted convention
└── per-stage-cost-backward-compat.md                       # NEW — structural; the backward-compat invariant (four record classes
                                                             #   accepted, incoherent inverse rejected; no generated_by-shape check;
                                                             #   no path-must-be-a-file check)

.claude-plugin/marketplace.json                              # MODIFIED: entry version + plugin_version 0.42.0 → 0.43.0
README.md                                                    # MODIFIED: plugin badge 0.42.0 → 0.43.0
```

Top-level marketplace `version` stays at `0.4.0`. No agent, command, or
orchestrator file touched. No docs-site page change is required (the reference
content is the contract; the explanation page authored in S2 still describes the
emitter accurately — confirm at Task 5, add a note only if it references the old
`generated_by` wording).

---

## Algorithm / key decisions (not pseudocode)

- **Owner edits the contract (legitimate).** Unlike S2 (a pure consumer forbidden
  from mutating the reference), this slice OWNS
  `estimate-record-format.md` and edits it deliberately. The edits are minimal and
  backward-safe by construction (spec §2.3): one optional, one-directionally
  coupled sub-field (present ⟹ top-level cost present; NOT an `iff`), one
  description widening, one documentation note — no new required field, no new
  grounding state, no new shape-check.
- **Per-stage `cost_usd` — optional, ONE-DIRECTIONALLY coupled to top-level cost
  (NOT an `iff`).** Sub-field present ⟹ top-level `cost_usd` present (enforced);
  top-level present ⟹ bands SHOULD be populated by emitters but their absence does
  NOT invalidate the record. **State this asymmetry in the field table itself** —
  the prior draft's `iff` (a biconditional) was the O1 trap a literal reader would
  tighten into a class-B-breaking mandate. The field table and the §4.4 check must
  say the same thing. The whole-record band need not equal the per-stage sum
  (existing correlation note) (spec §4.1, O1).
- **The forward-optional checklist semantics (load-bearing — the class-B trap).**
  The "Per-stage cost coupling" check keys on the **presence of the sub-field**,
  NOT on the presence of top-level cost: sub-field present + no top-level cost →
  FAIL; sub-field present + top-level cost → check `low ≤ high`; sub-field absent →
  check does not fire (PASS). This keeps an S1-era cost-present record WITHOUT
  per-stage bands (class B) valid. The check must **NOT** be a biconditional
  ("top-level cost present ⟺ every stage has a band") — that would reject class B
  (spec §4.3).
- **The "Split-tier spread" check — asserts a NON-COLLAPSED (strictly-spread)
  split-tier band, NOT that it spans two tiers (O3 honest floor).** Add a SECOND new
  checklist line: for every present per-stage `cost_usd` whose `model_tier` is a
  **split tier**, require a **strictly-positive ordered spread** (`low < high`,
  strict). A collapsed band (`low == high`) on a split-tier stage FAILS. Single-tier
  stages are exempt (governed only by Ranges-well-formed). **The split-tier trigger
  is a CLOSED rule (O2): a `model_tier` is a split tier IFF its label contains a `/`
  (after the join-key whitespace normalisation), and no single (non-split) tier
  label contains a slash (`Most capable`, `Standard` — neither does), so "contains
  `/`" is a sound TOTAL classifier — not an example.** The checklist line states
  ONLY the testable predicate (`low < high` on present split-tier bands); the
  cheaper-at-low / dearer-at-high ordering is an **emitter convention** that lives
  in the methodology prose, NOT the checklist (O4 — the validator cannot confirm
  which bound binds to which model from the record alone). **The snapshot-dependency
  was resolved by choosing a record-internal invariant, NOT by exposing per-model
  rates in the record (option (a) rejected — it would add data the merged S2 agent
  does not emit, breaking backward-compat).** State plainly in a §4.4.1 note what the
  validator CAN assert (presence/coupling; `low ≤ high`; a non-collapsed / strictly-
  spread split-tier band) and CANNOT (that the band SPANS TWO TIERS — a `{99.0,100.0}`
  band passes — nor that the bounds equal the absolute claude-sonnet-4/claude-opus-4
  rates; that snapshot-grounded check is S3's) (spec §4.4, §4.4.1, O2, O3, O4).
- **The SHOULD-populate obligation has a falsifiable home (O4).** Keep the SHOULD
  distinct from the rejection rule, AND give it a falsifiable home: it is an
  acceptance criterion on the deferred follow-on emitter issue (§12). Honestly
  scope it within this slice as "the format admits the band; no producer yet
  populates it" — not indistinguishable from MAY (spec §4.3.1).
- **The inverse-rejection check guards a not-yet-producible shape (O8).** Keep the
  inverse-rejection rule but record in the reference/spec that no current emitter
  can produce the inverse (the merged S2 agent emits only cost-omitted records); it
  is a cheap guard rail for S3-era emitters (spec §4.3.2).
- **Ranges-well-formed enum extension is guarded by "present".** Add
  `each tokens_by_stage[].cost_usd when present` to the existing enumeration; the
  "every **present** range" guard means an absent sub-field is never checked
  (classes A/B/C unaffected) (spec §4.4).
- **Example 2 — three CONCRETE per-stage bands, RE-DERIVED from two fixed per-tier
  rates (O1).** Fix two rates: **sonnet (cheaper) = `4.0e-6` $/token**, **opus
  (dearer) = `2.0e-5` $/token** (5× sonnet, consistent with the binding table).
  Every band is a rate × a token bound — nothing is allocated to a sum envelope.
  Single-tier stages use one rate at both bounds; the split-tier implementer widens
  from the cheaper rate at low to the dearer rate at high:
  - spec-writer (opus, 50k–100k): `2.0e-5 × 50000 = 1.00` … `2.0e-5 × 100000 = 2.00`
    → `{ 1.00, 2.00 }`.
  - tdd-agent (sonnet, 50k–150k): `4.0e-6 × 50000 = 0.20` … `4.0e-6 × 150000 = 0.60`
    → `{ 0.20, 0.60 }`.
  - implementer (split, 100k–250k): `4.0e-6 × 100000 = 0.40` (cheaper rate, low) …
    `2.0e-5 × 250000 = 5.00` (dearer rate, high) → `{ 0.40, 5.00 }` (matches the
    Included prose `$0.40–$5.00`).

  **Whole-record `cost_usd` = the per-stage sum, set equal by construction:** low
  `1.00+0.20+0.40 = 1.60`; high `2.00+0.60+5.00 = 7.60` → `{ 1.60, 7.60 }` (replaces
  the old `{ 0.95, 7.50 }`). Each single-tier band's low and high equal its tier-rate
  × the respective token bound (so the band would PASS an absolute-rate check); the
  split-tier implementer band has a strictly-positive spread (`0.40 < 5.00`). Update
  the Included prose's whole-record dollar figure to `$1.60–$7.60`. Example 1 is
  UNCHANGED (spec §4.5).
- **`generated_by` — description widening + `tier:` reserved prefix, no rejecting
  check (O6).** Admit a concrete model id OR a `tier:<tier>` label; define `tier:`
  as a **reserved provenance prefix** so a consumer can mechanically distinguish a
  tier label from a model id (a concrete model id never begins with `tier:`)
  WITHOUT a rejecting check. State the value is never a guessed/hard-coded model.
  Add **no** `generated_by`-shape checklist line (a shape-check could retroactively
  fail a record; the prefix grammar closes the ambiguity without a check) (spec §5,
  O6).
- **Grounding-path — document the directory sentinel, name the entrenchment, no
  path-shape check (O5).** Keep `observability/costs/` (trailing slash) as the named
  cost-omitted sentinel; state-3 uses the snapshot file path. **Acknowledge this
  ENTRENCHES an overloaded meaning (file = grounded; trailing-slash directory =
  looked-and-found-nothing) rather than resolving the tension, and add a consumer
  special-case note** (an aggregator must not count a trailing-slash directory path
  as a grounding). Add **no** `path`-must-be-a-file check (it would retroactively
  fail Example 1 and the merged S2 default record). **Record the O5 noted residual:**
  the special-case is advisory/unenforced (no checklist line keys on path shape), so
  it externalises a silent-miscount risk onto downstream counters (S3, any
  aggregator) — an accepted residual, not a deferred fix (spec §6.1, O5).
- **Closed-world property is the backward-compat lever.** Every demonstration
  turns on the checklist being a closed enumeration: it rejects only on a named
  check failing, never for an un-named field. A new optional field is invisible to
  every check that does not name it; the one new check that names it passes on its
  absence (spec §3).
- **No S2 agent change (spec §7, FR-11).** The format is widened to admit the
  merged agent's output. The follow-on emitter enhancement (per-stage bands on
  cost-present records) is named and deferred to a standalone issue filed at
  adjudication — not shipped, not orphaned.
- **Structural TDAD only.** No dispatchable side-effect ships (the agent is
  unchanged; the S3 checkpoint is out of scope), so Layer 1 structural is the
  whole test surface — same posture as the S1 `format-and-contract` scenario
  (spec §8).

---

## FR mapping table

| FR | Requirement (abbrev) | Covering test case(s) |
| --- | --- | --- |
| FR-1 | `tokens_by_stage[].cost_usd` optional `{low,high}`, ONE-DIRECTIONAL coupling stated in field table (NOT iff) | `format-and-contract.md` (extended) |
| FR-2 | Sub-field named in "every present range has low≤high" enum (present-guarded) | `format-and-contract.md` (extended) |
| FR-3 | "Per-stage cost coupling" line: fails inverse, passes vacuously, does NOT mandate bands on cost-present | `format-and-contract.md` (extended) + `per-stage-cost-backward-compat.md` (new) |
| FR-3b | "Split-tier spread" line: split-tier band needs strictly-positive spread (low<high); rejects collapsed band; closed trigger rule (split tier IFF label contains `/`); asserts NON-COLLAPSED band NOT "spans two tiers"; cheaper-at-low/dearer-at-high is emitter convention in prose not checklist; §4.4.1 CAN/CANNOT note | `format-and-contract.md` (extended) + `per-stage-cost-backward-compat.md` (new) |
| FR-4 | Example 2 three concrete bands {1.00,2.00}/{0.20,0.60}/{0.40,5.00}, re-derived from two fixed per-tier rates, sum to whole-record {1.60,7.60}; each single-tier band = tier-rate × token bound; implementer split-tier spread matches prose | `format-and-contract.md` (extended) |
| FR-5 | Example 1 carries NO per-stage band, stays valid (class A/C) | `cost-conditional.md` (extended) + `per-stage-cost-backward-compat.md` (new) |
| FR-6 | Backward-compat invariant demonstrated: 4 classes valid, inverse rejected | `per-stage-cost-backward-compat.md` (new) |
| FR-7 | `generated_by` description admits model id OR `tier:<tier>`; defines `tier:` reserved prefix (mechanical distinction, no rejecting check); never guessed model | `format-and-contract.md` (extended) |
| FR-8 | No `generated_by`-shape checklist line (no retroactive rejection) | `per-stage-cost-backward-compat.md` (new) |
| FR-9 | Directory path documented as cost-omitted sentinel; never dropped/fabricated; state-3 uses file | `format-and-contract.md` (extended) + `cost-conditional.md` (extended) |
| FR-10 | No `path`-must-be-a-file checklist line (directory path stays valid) | `per-stage-cost-backward-compat.md` (new) |
| FR-11 | No S2 agent change; merged agent records conformant; follow-on named + deferred | (no scenario — verified by absence of any S2 edit in module-touch list at PR time) |
| FR-12 | Version bump 0.42.0 → 0.43.0 across four locations; checklist ↔ examples consistent | local version-consistency check (Task 4) |

---

## Test case list

(In the same form as the existing TDAD skill scenario corpus — `Given/When/Then`
markdown scenarios under `tdad_tests/scenarios/skills/cost-estimation/`, all
Layer 1 structural ($0, every PR). Two existing scenarios extended, one new
scenario. No scenario deleted.)

- `format-and-contract.md` (tier: structural, EXTENDED) — in addition to its
  current S1 assertions, the `Then` now asserts: the field table defines
  `tokens_by_stage[].cost_usd` as optional with a ONE-DIRECTIONAL coupling stated
  in the table (sub-field present ⟹ top-level cost present; reverse is an emitter
  SHOULD, NOT an `iff`); the "every present range has `low ≤ high`" enumeration
  names the per-stage sub-field; the validation checklist carries the "Per-stage
  cost coupling" AND "Split-tier spread" lines with their backward-safe wording
  (coupling fails the inverse, passes vacuously, does not mandate bands on
  cost-present; spread requires `low < high` on split-tier stages, with the split
  trigger a CLOSED rule — split tier IFF label contains `/`); a §4.4.1-style note
  states the validator CAN assert the split-tier band is NON-COLLAPSED (strictly
  spread) but CANNOT assert it spans two tiers nor the absolute snapshot rates, and
  the cheaper-at-low/dearer-at-high ordering is an emitter convention in the prose,
  not the checklist; Example 2 carries the three concrete bands (spec-writer
  `{1.00,2.00}`, tdd-agent `{0.20,0.60}`, implementer `{0.40,5.00}`), each a fixed
  tier-rate × token bound, summing to the whole-record `{1.60,7.60}`, with the
  split-tier implementer band showing a strictly-positive spread and matching the
  Included prose; Example 1 carries no per-stage band; the
  `generated_by` description admits the `tier:<tier>` form, defines `tier:` as a
  reserved prefix, and forbids a guessed model; the grounding-path directory
  sentinel (with its entrenchment note and consumer special-case) is documented.
- `cost-conditional.md` (tier: structural, EXTENDED) — in addition to its current
  three-grounding-states assertions, the `Then` now asserts: the cost-omitted
  worked example (and the cost-omitted shape generally) carries NO
  `tokens_by_stage[].cost_usd` sub-field; the cost-snapshot grounding entry's
  directory path `observability/costs/` is the documented cost-omitted sentinel
  (present, never dropped, never a fabricated file path), with the consumer
  special-case note (an aggregator must not count the trailing-slash directory as a
  grounding).
- `per-stage-cost-backward-compat.md` (tier: structural, NEW) — a STRUCTURAL
  scenario (asserts the checklist TEXT and the four-class argument a human traces,
  NOT the output of a parser actually run — that runtime falsification is S3's).
  Reads the edited reference's validation checklist as a closed-world parser and
  asserts: an old cost-omitted record (no top-level cost, no per-stage band) is
  VALID; an old cost-present record with top-level cost but NO per-stage bands is
  VALID (the coupling check does not mandate the sub-field); a new cost-omitted
  record is VALID; a new cost-present record with per-stage bands on every stage is
  VALID; a record with a per-stage `cost_usd` and NO top-level `cost_usd` is
  REJECTED (the incoherent inverse — a not-yet-producible shape, a guard rail for
  S3-era emitters); a record whose split-tier stage carries a collapsed band
  (`low == high`) is REJECTED by "Split-tier spread"; no checklist line keys on
  `generated_by` shape; no checklist line requires `grounding_sources[].path` to be
  a file. This is the load-bearing backward-compat invariant in its own falsifiable
  scenario.

---

## Phase 1 — The format reference edit

### Task 1: Edit `estimate-record-format.md` (this slice owns it)

- [ ] **Field table** — add a row (or a sub-row note under `tokens_by_stage`) for
  `tokens_by_stage[].cost_usd`: type `range object { low, high }`, required
  **optional, one-directionally coupled — sub-field present ⟹ top-level `cost_usd`
  present (enforced); top-level present ⟹ bands SHOULD be populated but absence
  does NOT invalidate**. **Do NOT use the word `iff`** — state the asymmetry in the
  field table (the iff-removal fix). Purpose: "per-stage dollar contribution; a
  record-internal spread check on split-tier bands (asserts a non-collapsed,
  strictly-spread band — `low < high`; cannot assert the absolute snapshot rates)"
  (spec §4.1, FR-1).
- [ ] **Range representation section** — add `each tokens_by_stage[].cost_usd
  (when present)` to the list of present quantitative ranges that must have
  `low ≤ high` (spec §4.4, FR-2).
- [ ] **Validation checklist** — extend the "Ranges well-formed" line to name the
  per-stage sub-field "when present"; add a **"Per-stage cost coupling"** line
  immediately after the existing "Cost pairing" line (fails an inverse record,
  passes vacuously on absence, does NOT mandate per-stage bands on a cost-present
  record; emitters SHOULD populate them); add a **"Split-tier spread"** line
  requiring a strictly-positive ordered spread (`low < high`) on every present
  split-tier band, rejecting a collapsed band, single-tier stages exempt, vacuous on
  absence. **State the split-tier trigger as a CLOSED rule (O2): a `model_tier` is a
  split tier IFF its label contains a `/` (after the join-key whitespace
  normalisation); confirm in prose that no single tier label contains a slash, so
  "contains `/`" is a total classifier — not an example.** **The checklist line
  states ONLY the testable predicate (`low < high`); the cheaper-at-low /
  dearer-at-high ordering moves to the methodology prose as an emitter convention,
  NOT the checklist (O4).** Exact wording per spec §4.4 (spec §4.4, FR-3, FR-3b, O2,
  O4).
- [ ] **Add the §4.4.1 CAN/CANNOT note** — a short note stating the validator CAN
  assert presence/coupling, `low ≤ high`, and that a split-tier band is NON-COLLAPSED
  (strictly spread, `low < high`), but CANNOT assert the band SPANS TWO TIERS (a
  `{99.0,100.0}` band passes) nor that the bounds equal the absolute
  claude-sonnet-4/claude-opus-4 rates (that snapshot-grounded check is S3's). Make
  explicit that option (a) — carrying per-model rates in the record — was rejected
  (it would add data the merged S2 agent does not emit) (spec §4.4.1, FR-3b, O3).
- [ ] **Methodology/prose** — add a short note that a new emitter SHOULD populate
  per-stage `cost_usd` on cost-present records while a cost-present record without
  them stays valid for S1-era backward-compat — keeping the SHOULD distinct from
  the validation-rejection rule; AND note its falsifiable home is the deferred
  follow-on emitter issue (§12), honestly scoped within this slice as "the format
  admits the band; no producer yet populates it"; AND note the inverse-rejection
  check guards a not-yet-producible shape (O8); **AND state the cheaper-at-low /
  dearer-at-high pricing as an emitter convention here in the prose (O4) — the
  validator cannot confirm which bound binds to which model, so this is a
  convention, not a checked invariant** (spec §4.3, §4.3.1, §4.3.2, §4.4, O4).
- [ ] **Example 2 (cost-present) — UPDATE** — add `cost_usd: { low, high }` to each
  of the three `tokens_by_stage[]` entries with the CONCRETE bands RE-DERIVED from
  two fixed per-tier rates (sonnet `4.0e-6`, opus `2.0e-5` $/token):
  spec-writer `{ low: 1.00, high: 2.00 }` (opus rate × 50k/100k), tdd-agent
  `{ low: 0.20, high: 0.60 }` (sonnet rate × 50k/150k), implementer
  `{ low: 0.40, high: 5.00 }` (sonnet rate × 100k low … opus rate × 250k high). They
  sum to the whole-record `{ 1.60, 7.60 }` — **also update the whole-record
  `cost_usd` to `{ 1.60, 7.60 }`** (set equal by construction; replaces the old
  `{ 0.95, 7.50 }`). The implementer (split-tier) band has a strictly-positive
  spread; it matches the Included prose's `$0.40–$5.00`. Update the Included prose to
  say the per-stage bands are surfaced as fields and to cite the whole-record band as
  `$1.60–$7.60` if it states a dollar figure (spec §4.5, FR-4).
- [ ] **Example 1 (cost-omitted) — DO NOT TOUCH the per-stage entries** — confirm
  no `tokens_by_stage[].cost_usd` is added (spec §4.5, FR-5).
- [ ] **`generated_by` description — WIDEN + define the reserved prefix** — admit a
  concrete model id OR a `tier:<tier>` routing-tier label when the concrete model
  is unavailable; define **`tier:` as a reserved provenance prefix** (a concrete
  model id never begins with `tier:`, so a consumer can mechanically distinguish
  the two forms without any rejecting check); state the value is never a
  guessed/hard-coded model; add no `generated_by`-shape check (spec §5, FR-7, FR-8,
  O6).
- [ ] **`grounding_sources` description + three-grounding-states — DOCUMENT the
  sentinel, NAME the entrenchment, add the consumer special-case** — the directory
  path `observability/costs/` (trailing slash) is the named cost-omitted sentinel
  for the mandatory cost-snapshot entry; the entry is never dropped, never given a
  fabricated file path; state-3 uses the snapshot file path; **acknowledge this
  entrenches an overloaded meaning (file = grounded; trailing-slash directory =
  looked-and-found-nothing) rather than resolving the tension, and add the consumer
  special-case note** (an aggregator must not count a trailing-slash directory path
  as a grounding); **record the O5 noted residual** — the special-case is
  advisory/unenforced, externalising a silent-miscount risk onto downstream counters
  (S3, any aggregator); add no `path`-must-be-a-file check (spec §6, §6.1, FR-9,
  FR-10, O5).
- [ ] **Consistency self-check** — re-read the checklist and both worked examples
  together; confirm the new checklist lines (coupling + spread), the field table,
  Example 2's three re-derived per-stage bands, and the whole-record `cost_usd` are
  mutually consistent (the bands sum exactly to the whole-record `{1.60,7.60}`, each
  single-tier band = its tier-rate × token bound, and the implementer band satisfies
  the spread rule) (spec §9).

---

## Phase 2 — TDAD scenarios

### Task 2: Extend two scenarios, add one

- [ ] **Extend `format-and-contract.md`** with the per-stage sub-field
  (one-directional coupling stated in the field table, NOT `iff`), BOTH new
  checklist lines (coupling + split-tier spread), the §4.4.1 CAN/CANNOT note,
  Example 2's three concrete bands, the `generated_by` widening with the reserved
  `tier:` prefix, and the grounding-path sentinel (with entrenchment + consumer
  special-case) assertions (test case list above). Keep all existing S1 assertions
  intact.
- [ ] **Extend `cost-conditional.md`** with the no-per-stage-band-on-cost-omitted
  and directory-sentinel assertions, including the consumer special-case note. Keep
  all existing assertions intact.
- [ ] **Create `per-stage-cost-backward-compat.md`** (tier: structural) — a
  STRUCTURAL scenario (asserts the checklist TEXT + the four-class argument, NOT a
  parser actually run — runtime falsification is S3's): the four-record-class
  backward-compat invariant, the rejected inverse (a not-yet-producible guard rail
  for S3-era emitters), the rejected collapsed split-tier band, and the
  no-`generated_by`-shape-check / no-`path`-file-check assertions. Follow the
  corpus format in `tdad_tests/README.md` and the existing
  `cost-estimation` scenario frontmatter (`component: cost-estimation`,
  `component_type: skill`, `tier: structural`).
- [ ] Confirm **no S2 agent scenario** under `tdad_tests/scenarios/agents/cost-estimator/`
  is modified — this slice changes the format the agent consumes, not the agent.

---

## Phase 3 — Version bumps

### Task 3: Bump plugin.json, CHANGELOG, marketplace.json, README

- [ ] `ai-literacy-superpowers/.claude-plugin/plugin.json`: `version` `0.42.0` → `0.43.0`.
- [ ] `CHANGELOG.md` (repo root): new `## 0.43.0 — <today>` heading with entries
  for: the optional, one-directionally coupled per-stage `cost_usd` sub-field
  (backward-compatible; the split-tier spread check makes the widening
  record-internally checkable — the absolute-rate check is deferred to S3); the
  `generated_by` description widening (admits the `tier:<tier>` label the merged S2
  agent emits, with `tier:` as a reserved prefix); the grounding-path directory
  sentinel documentation. State the change is backward-compatible and ships no S2
  agent change.
- [ ] `.claude-plugin/marketplace.json`: bump the `ai-literacy-superpowers`
  `plugins[]` entry `version` and the top-level `plugin_version` to `0.43.0`; leave
  top-level `version` at `0.4.0`.
- [ ] `README.md`: bump the `ai-literacy-superpowers` badge `v0.42.0` → `v0.43.0`.
- [ ] Verify version consistency:

```bash
python3 -c "
import json
pj = json.load(open('ai-literacy-superpowers/.claude-plugin/plugin.json'))
m = json.load(open('.claude-plugin/marketplace.json'))
entry = next(p for p in m['plugins'] if p['name']=='ai-literacy-superpowers')
assert pj['version']=='0.43.0', pj['version']
assert entry['version']=='0.43.0', entry['version']
assert m['plugin_version']=='0.43.0', m['plugin_version']
assert m['version']=='0.4.0', m['version']
print('version consistency OK')
"
```

---

## Phase 4 — Verify and ship

### Task 4: Local CI gate checks

- [ ] Spec-first ordering — first commit on the `format-revision-per-stage-cost`
  branch is the spec:

```bash
git log main..HEAD --reverse --oneline | head -1
```

- [ ] Reference ↔ scenario consistency — the three scenario files exist and assert
  the edited reference content:

```bash
ls tdad_tests/scenarios/skills/cost-estimation/*.md
```

- [ ] Markdown lint, docs build, and the deterministic TDAD fast suite (Layers 0+1)
  pass.

### Task 5: Docs touch (confirm-or-update only)

- [ ] Confirm `docs/plugins/ai-literacy-superpowers/explanation/prospective-cost-estimation.md`
  (authored in S2) does not reference the old `generated_by` "model identifier"
  wording in a way the widening now contradicts. Update only if it does; no new
  page is required (the reference is the contract, and this is a format-detail
  change, not a new command/skill/agent).

### Task 6: Push, PR, CI, merge

- [ ] Push the `format-revision-per-stage-cost` branch, open a PR against #377
  (feature ceremony — `/diaboli` spec runs on this spec next; code-mode runs after
  the code-reviewer PASS).
- [ ] PR body states what ships (the three format changes + two extended scenarios
  + one new backward-compat scenario + version bump) and what does NOT (S3–S6; **no
  S2 agent change** — the format is widened to admit the merged agent's output; the
  follow-on emitter enhancement is filed as a standalone issue at adjudication).
- [ ] Watch CI green; merge `--squash --delete-branch`; sync the marketplace cache.

### Task 7: File the deferred follow-on (at adjudication, per AGENTS.md)

- [ ] File a standalone issue against the `cost-estimator` agent: "populate
  per-stage `cost_usd` bands on cost-present records once a usable snapshot
  exists." Do not leave it implicit in this slice's out-of-scope section (the
  AGENTS.md "re-file, do not leave implicit" decision). Link it from #377.

---

## Out of scope (deferred)

- The `/cost-estimate` command and its Output Validation Checkpoint that *runs* the
  checklist against an on-disk record (S3, #370). This slice defines the checklist
  line; it ships no runtime validator.
- Orchestrator fold-in (S4, #371); the T0 ballpark (S5, #372); the calibration loop
  (S6, #373). The `kind: calibration` grounding seam is untouched and the per-stage
  sub-field is not a calibration input.
- **The S2 agent enhancement to populate per-stage bands on cost-present records.**
  Named in spec §12 and §7; filed as a standalone issue at adjudication (Task 7).
  Not shipped here, to avoid re-creating the consumer/owner conflation this slice
  exists to resolve.
- Any change to the cost-derivation methodology (the binding table, the blended-rate
  skew, the join key). This slice surfaces an already-computed widening as a field;
  it does not change how the widening is computed.
```

