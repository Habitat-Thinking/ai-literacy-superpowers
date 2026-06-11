---
component: cost-estimation
component_type: skill
tier: structural
---

# Scenario: cost-estimation ships a well-formed skill and a complete estimate-record format contract

## Given

The `cost-estimation` skill is S1 of the cost-estimator capability
(spec `docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md`).
It ships exactly two artefacts and nothing else:

- `ai-literacy-superpowers/skills/cost-estimation/SKILL.md` — the
  methodology and the disclosure/confidence contract as loadable prose.
- `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`
  — the canonical, stable definition of the estimate-record field set,
  the artefact a downstream command's Output Validation Checkpoint
  references by path.

This scenario fixes the structural contract both files must satisfy
(spec §4, §5, §6, §8.1, §8.2; FR-1 through FR-11, FR-8a, FR-14).

The **format-revision slice** (#377, spec
`docs/superpowers/specs/2026-06-11-format-revision-per-stage-cost-design.md`)
extends this contract in place — this slice **owns** the reference. The
additional `Then` assertions below (under "Format-revision slice (#377)
additions") fix the per-stage `cost_usd` sub-field, the two new
validation-checklist lines, the re-derived Example 2 bands, the
`generated_by` reserved-prefix grammar, and the grounding-path sentinel
(format-revision spec §4, §4.4, §4.4.1, §4.5, §5, §6; FR-1, FR-2, FR-3,
FR-3b, FR-4, FR-7, FR-9).

## When

The skill and its format reference are read directly from the
filesystem during the design pass for the S2 agent, the S3 command, or
the S4 orchestrator fold-in — the consumers that parse this contract.

## Then

**SKILL.md frontmatter and sections** (`FR-1`):

- **YAML frontmatter present** with `name: cost-estimation` and a
  non-empty `description` — required by the
  `All frontmatter has name and description` HARNESS constraint.
- **Body contains the required sections**, each surfaced as a heading:
  - the grounding **methodology** (how MODEL_ROUTING.md grounds token
    and time, and how a snapshot grounds cost);
  - the **disclosure/confidence contract**;
  - the **time split** (agent-compute vs human-gate);
  - the **calibration seam** (S6, future-only);
  - the **sibling** relationship to `cost-tracking`;
  - a **"What this skill does NOT do"** section stating it does not
    dispatch, does not write files, and does not decide go/no-go.
- The body **references the format file** by relative path.

**Format reference field set** (`FR-2`, `FR-3`):

- The reference defines a frontmatter field table listing every field
  of spec §4.2: `target`, `target_kind`, `generated_at`, `generated_by`,
  `grounding_sources`, `tokens`, `tokens_by_stage`, `cost_usd`,
  `cost_basis`, `agent_compute_time`, `human_gate_time`, `confidence`,
  and `failure_direction`.
- `cost_usd` and `cost_basis` are marked **conditional
  (present-when-grounded)**, not required.
- `confidence` is a **per-axis object** with keys `tokens`, `time`, and
  (only when `cost_usd` is present) `cost`.
- Every **present** quantitative field (`tokens`,
  `tokens_by_stage[].tokens`, `cost_usd` when present,
  `agent_compute_time`) is specified as a `{low, high}` range.
- There is **no** point-value, `recommendation`, `verdict`, or `proceed`
  field anywhere in the field set.

**Time split** (`FR-5`):

- `agent_compute_time` and `human_gate_time` are **two separate required
  fields with different shapes**: `agent_compute_time` is a numeric
  `{low, high}` range; `human_gate_time` is a **qualitative caveat
  string, NOT a range**.
- The reference states `human_gate_time` is **not estimated numerically
  at S1** because the gate set lives in the orchestrator (S4, #371),
  which this slice does not touch, and that human-gate latency dominates
  wall-clock and is the least-predictable term.

**Disclosure body** (`FR-4`):

- The reference mandates the **four-part disclosure body**: Included,
  Excluded, Confidence rationale, Failure direction. A record missing
  any of the four fails validation.

**Per-axis confidence mapping** (`FR-6`):

- The reference defines the **`target_kind` ceiling** for `tokens`/`time`
  (raw `task-text` capped at `low`; `slicing-record`/`slice` at most
  `medium`; `spec` may reach `high`) and an **independent
  snapshot-quality rule** for the conditional `cost` axis, so a
  spec-grounded target can carry `tokens: high` beside `cost: low`.

**Tier→model→$/token binding** (`FR-7`, `FR-8a`):

- The reference contains a named **tier→model→$/token binding table**
  mapping `Most capable → claude-opus-4`, `Standard → claude-sonnet-4`,
  and the implementer's `Standard / Capable` **split row spanning two
  distinct models** — low bound `claude-sonnet-4`, high bound
  `claude-opus-4` — so the split-tier widening produces a real spread.

**Calibration seam** (`FR-9`):

- The `grounding_sources[]` field permits a `kind: calibration` entry
  alongside `model-routing` and `cost-snapshot`, and the methodology
  describes calibration as **range-refinement**, without implementing S6.

**Sibling** (`FR-10`):

- The reference/skill names `cost-tracking` as the retrospective sibling
  and states the estimate reads the `observability/costs/` snapshots
  that `cost-tracking` writes.

**Worked examples and validation checklist** (`FR-11`, `FR-14`):

- The reference contains **two complete worked example records** — one
  **cost-omitted** (today's default: `cost_usd`/`cost_basis` absent,
  `confidence` with `tokens`/`time` only) and one **cost-present**
  (`cost_basis: snapshot-actuals`, `confidence.cost` present). In both
  examples `human_gate_time` is a qualitative caveat string, not a range.
- The **cost-present** example demonstrates the **split-tier widening**:
  its implementer stage carries a **non-zero cost band** whose low bound
  uses `claude-sonnet-4` and high bound uses `claude-opus-4`, visibly
  wider than the token-range spread alone.
- Neither worked example files an inclusion caveat under `Excluded`
  (O10).
- The reference contains a **"Validation checklist"** subsection
  enumerating the checks a consuming command runs, including the
  two-layer no-verdict guarantee (the field-absence check **and** the
  positive-content scan of §5.3).

---

## Format-revision slice (#377) additions

The following assertions are added by the format-revision slice. They
fail against the S1-era reference and pass only once the slice's edits
land. All are structural — verifiable by inspection of the field table,
the validation checklist, the worked examples, and the field
descriptions in `references/estimate-record-format.md`.

**Per-stage `cost_usd` sub-field — field table** (`FR-1`):

- The field table (or a sub-row note under `tokens_by_stage`) defines a
  `tokens_by_stage[].cost_usd` sub-field as an **optional**
  `{ low, high }` range object.
- The sub-field is documented as **one-directionally coupled**, stated as
  such **in the field table itself**: **sub-field present ⟹ top-level
  `cost_usd` present** (enforced); **top-level `cost_usd` present ⟹ bands
  SHOULD be populated by emitters but their absence does NOT invalidate
  the record**.
- The coupling is **NOT** stated as an `iff` / biconditional in the field
  table — the word `iff` does not describe this sub-field's coupling (the
  asymmetry is stated explicitly), so a literal reader cannot tighten it
  into a class-B-breaking mandate.

**Per-stage `cost_usd` sub-field — range enumeration** (`FR-2`):

- The "Range representation" section's enumeration of **present**
  quantitative ranges that must have `low ≤ high` names
  `tokens_by_stage[].cost_usd` **when present** (so an absent sub-field is
  never checked).

**New validation-checklist line — "Per-stage cost coupling"** (`FR-3`):

- The validation checklist carries a **"Per-stage cost coupling"** line
  that: (a) **fails** a record carrying a per-stage `cost_usd` with no
  top-level `cost_usd` (the incoherent inverse); (b) **passes vacuously**
  when no per-stage sub-field is present (old records and cost-omitted
  records are not rejected); (c) explicitly **does NOT mandate** per-stage
  bands on a cost-present record (so S1-era class-B records stay valid),
  while stating emitters SHOULD populate them.

**New validation-checklist line — "Split-tier spread"** (`FR-3b`):

- The validation checklist carries a **"Split-tier spread"** line
  requiring, for **every present** `tokens_by_stage[].cost_usd` whose
  `model_tier` is a **split tier**, a **strictly-positive ordered spread**
  `low < high` (strict, not merely `low ≤ high`). A collapsed band
  (`low == high`) on a split-tier stage **fails** this line. **Single-tier
  stages are exempt**, and an absent sub-field satisfies the line
  vacuously.
- The split-tier trigger is stated as a **CLOSED rule**: a `model_tier`
  **is a split tier if and only if its label contains a `/`** (after the
  join-key whitespace normalisation), and the reference confirms no single
  (non-split) tier label contains a slash (`Most capable`, `Standard`
  contain none), so "contains `/`" is a sound **total** classifier — not
  merely an example.
- The cheaper-at-low / dearer-at-high pricing ordering is stated as an
  **emitter convention in the methodology prose**, **NOT** as a predicate
  the checklist line tests — the only predicate the line tests on a
  present split-tier band is `low < high`.

**The §4.4.1 CAN/CANNOT honest-floor note** (`FR-3b`):

- The reference carries a note stating the validator **CAN** assert
  presence/coupling, `low ≤ high` on every present band, and that a
  split-tier band is **non-collapsed (strictly spread, `low < high`)**.
- The same note states the validator **CANNOT** assert that the band
  **spans two tiers** (a `{ 99.0, 100.0 }` band passes the strict-spread
  check), nor that the bounds **equal** the absolute
  `claude-sonnet-4`/`claude-opus-4` snapshot rates — that absolute-rate
  check is **deferred to S3** (the snapshot-grounded Output Validation
  Checkpoint), not this format-only slice.
- The note records that **option (a)** — carrying the per-model rates in
  the record so the check is fully self-contained — was **rejected**
  (it would add data the merged S2 agent does not emit, re-introducing a
  required field and breaking backward-compat).

**Re-derived Example 2 (cost-present) bands** (`FR-4`):

- Example 2's three `tokens_by_stage[]` entries each carry a `cost_usd`
  sub-field with the concrete re-derived bands:
  - **spec-writer** (`Most capable`): `{ low: 1.00, high: 2.00 }`
  - **tdd-agent** (`Standard`): `{ low: 0.20, high: 0.60 }`
  - **implementer** (`Standard/Capable`, split): `{ low: 0.40, high: 5.00 }`
- Each band is **rate × tokens** from two fixed per-tier rates (sonnet
  `4.0e-6`, opus `2.0e-5` $/token): each single-tier band's low and high
  equal its tier-rate × the respective token bound; the split-tier
  implementer band widens from the cheaper rate at low (`4.0e-6 × 100000 =
  0.40`) to the dearer rate at high (`2.0e-5 × 250000 = 5.00`).
- The split-tier implementer band has a **strictly-positive spread**
  (`0.40 < 5.00`), satisfying the "Split-tier spread" line, and matches
  the Included prose's `$0.40–$5.00`.
- Example 2's whole-record `cost_usd` is updated to **`{ low: 1.60, high:
  7.60 }`** — the exact sum of the three per-stage bands (the old
  `{ 0.95, 7.50 }` is replaced) — and the Included prose, if it cites a
  whole-record dollar figure, reads `$1.60–$7.60`.

**Example 1 (cost-omitted) carries no per-stage band** (`FR-5`, locked
here too; primarily asserted in `cost-conditional.md`):

- Example 1's `tokens_by_stage[]` entries carry **no** `cost_usd`
  sub-field on any stage.

**`generated_by` reserved-prefix grammar** (`FR-7`):

- The `generated_by` field description admits **both** a concrete model
  identifier (e.g. `"cost-estimator / claude-opus-4-8"`) **and** a
  `tier:<tier>` routing-tier label (e.g. `"cost-estimator / tier:Standard"`)
  when the concrete model is unavailable to the emitter at emit time.
- The description defines **`tier:` as a reserved provenance prefix**: the
  provenance token after the ` / ` separator is a **tier label iff it
  begins with the literal `tier:`**, otherwise it is a **concrete model
  identifier** (a concrete model id never begins with `tier:`), so a
  consumer can mechanically distinguish the two forms **without any
  rejecting check** being added.
- The description states the value is **never** a guessed or hard-coded
  model string.

**Grounding-path directory sentinel** (`FR-9`):

- The `grounding_sources` description and/or the three-grounding-states
  section documents the directory path **`observability/costs/` (trailing
  slash)** as the **named cost-omitted sentinel** for the mandatory
  `cost-snapshot` entry: the entry is **never dropped**, **never given a
  fabricated file path**, and a **snapshot file path** is used in state 3.
- The reference **names the entrenchment** — a `cost-snapshot` entry's
  `path` carries two meanings (a **file** = grounded in that snapshot; a
  **trailing-slash directory** = looked-and-found-nothing) — rather than
  claiming the tension is resolved.
- The reference carries the **consumer special-case** note: an aggregator
  counting snapshot-grounded records **must not** count a trailing-slash
  directory `path` as a grounding (it is a sentinel for the *absence* of a
  snapshot).

## Rubric

This is a Layer 1 structural scenario: every assertion is mechanically
checkable by reading `SKILL.md` and `references/estimate-record-format.md`
and matching against frontmatter, headings, the field table, the binding
table, and the two worked example blocks. The scenario passes only when
every assertion in `Then` — including every "Format-revision slice (#377)
additions" assertion above — can be verified by inspection of the two
files.

A scenario reviewer checking the format-revision additions verifies: the
field-table coupling is stated as a one-directional asymmetry and the word
`iff` is **not** used for it; both new checklist lines are present with
their backward-safe wording (coupling fails the inverse and passes
vacuously; split-tier spread requires strict `low < high` with the closed
`contains-/` trigger); the §4.4.1 note states both the CAN and the CANNOT
honestly (record-internal spread, not absolute rates, S3-deferred);
Example 2 carries exactly the three re-derived bands summing to
`{ 1.60, 7.60 }`; the `generated_by` description admits `tier:<tier>` and
reserves the `tier:` prefix; and the grounding-path directory sentinel
(with entrenchment + consumer special-case) is documented.

A future Layer 3 scenario could load the skill and ask a model to emit a
record against the format, asserting the result validates — that
behavioural verification is deferred (no dispatchable side-effect ships
in S1; spec §9 targets `[structural, trigger]` only).

## Notes

Scope is S1 only. This scenario does NOT assert anything about the S2
agent, the S3 command, the S4 orchestrator wiring, the S5 ballpark, or
the S6 calibration implementation — only that the methodology and format
contract those slices consume are present and well-formed.
