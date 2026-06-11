---
component: cost-estimation
component_type: skill
tier: structural
---

# Scenario: the per-stage `cost_usd` sub-field is backward-compatible — four record classes validate, only the incoherent inverse is rejected

## Given

The format-revision slice (#377, spec
`docs/superpowers/specs/2026-06-11-format-revision-per-stage-cost-design.md`)
adds an **optional, one-directionally coupled** `tokens_by_stage[].cost_usd`
sub-field to the estimate-record format
(`ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`).

The slice's **load-bearing requirement is demonstrated backward-compatibility,
not asserted** (spec §1, §4.3): adding a conditional sub-field coupled to
top-level cost is *not* trivially additive against the reference's
**closed-world validation checklist**, so the claim must be **shown** by
tracing the actual checklist semantics against every record class.

This is a **structural** scenario. Per the spec's O7 honest framing (§8), it
asserts the **checklist TEXT** and the **four-class argument a human traces** —
not the output of a parser actually run. The runtime falsification (an actual
closed-world parser executed over the four classes) lands with S3's Output
Validation Checkpoint, which is out of scope here. The assertions below are
therefore restated as the verdicts a faithful closed-world parser *would*
return, each grounded in directly-readable text of the reference (the presence
of named checklist lines and the absence of others).

This scenario isolates the demonstrated-not-asserted backward-compat invariant
into its own falsifiable file, so a future edit that "tightens" the per-stage
coupling into a class-B-breaking `iff` mandate, or that drops the split-tier
spread rule, fails this scenario loudly (FR-3, FR-3b, FR-5, FR-6, FR-8, FR-10).

## When

The edited reference's **validation checklist** is read as a closed-world
parser (it rejects a record **only** when one of its named checks fails; it
does **not** reject a record for carrying a field the checklist does not
mention — spec §3), and traced against the four record classes of spec §4.3
plus the two genuinely-rejected shapes.

## Then

**The four record classes all validate** (spec §4.3 classes A–D; FR-5, FR-6):

- **Class A — old cost-omitted** (S1/S2-era; Example 1; merged S2 day-one
  default): no top-level `cost_usd`, no per-stage `cost_usd` → **VALID**. Every
  new per-stage check keys on the **presence of the sub-field**; with no
  sub-field present, each fires **vacuously**, and the closed-world property
  guarantees no other check names the sub-field.
- **Class B — old cost-present without per-stage bands** (S1-era; Example 2
  before this slice): top-level `cost_usd` present, **no** per-stage
  `cost_usd` → **VALID**. This is the **load-bearing** case: the "Per-stage
  cost coupling" check keys on **sub-field presence, not top-level presence**,
  so a cost-present record with no bands is **never rejected**. The check does
  **NOT** mandate per-stage bands on a cost-present record.
- **Class C — new cost-omitted**: no top-level `cost_usd`, no per-stage
  `cost_usd` → **VALID** (identical to class A — every new check fires
  vacuously).
- **Class D — new cost-present with per-stage bands** (Example 2 after this
  slice): top-level `cost_usd` present, per-stage `cost_usd` on each stage →
  **VALID**. The new checks confirm the enforced coupling holds (sub-field
  present ⟹ top-level present), `low ≤ high` on each band, and a
  strictly-positive ordered spread (`low < high`) on each **split-tier**
  band — the implementer band `{ 0.40, 5.00 }` satisfies the spread rule.

**The two genuinely-rejected shapes** (spec §4.3, §4.4; FR-3, FR-3b):

- A record carrying a **per-stage `cost_usd` with NO top-level `cost_usd`**
  (the incoherent inverse) is **REJECTED** by the **"Per-stage cost coupling"**
  check. The reference also records that this inverse is a
  **not-yet-producible shape** — the merged S2 agent emits only cost-omitted
  records, so nothing today can create it; the check is kept as a **cheap guard
  rail for S3-era emitters**, and the reference does not overstate its net-new
  enforcement surface.
- A record whose **split-tier stage carries a collapsed band** (`low == high`
  on a `model_tier` whose label contains `/`) is **REJECTED** by the
  **"Split-tier spread"** check, which requires a **strict** `low < high` on
  every present split-tier band. **Single-tier** stages with `low == high` are
  **not** rejected by this line (they are exempt, governed only by "Ranges
  well-formed").

**The present-guard keeps absence un-checked** (spec §4.4; FR-2):

- The **"Ranges well-formed"** enumeration includes
  `tokens_by_stage[].cost_usd` **"when present"**, so an **absent** sub-field
  is **never** checked — classes A, B, and C pass this line unchanged.

**No retroactively-failing checks were added** (spec §5.3, §6.3; FR-8, FR-10):

- **No** validation-checklist line keys on the **shape or content of
  `generated_by`** — readable as the **absence** of any `generated_by`-shape
  check in the reference's checklist. The `generated_by` change is a
  description widening only, so the `tier:<tier>` form (the merged S2 agent's
  day-one default) is never retroactively rejected.
- **No** validation-checklist line requires `grounding_sources[].path` to be a
  **file** — readable as the **absence** of any `path`-must-be-a-file check in
  the reference's checklist. The directory-path sentinel
  (`observability/costs/`) on Example 1 and the merged S2 default record is
  therefore never retroactively rejected.

## Rubric

This is a Layer 1 structural scenario. Every assertion is verifiable by reading
the **validation checklist text** and the **field/range rules** in
`references/estimate-record-format.md` and tracing the closed-world semantics —
**not** by running a parser. The "rejects" and "no check exists" assertions are
claims about the **checklist text** and the **non-presence of named checks**,
both directly readable.

The scenario passes only when: the two new checklist lines ("Per-stage cost
coupling", "Split-tier spread") are present with backward-safe wording; the
coupling is keyed on **sub-field presence** (not a top-level ⟺ per-stage
biconditional), so class B (cost-present, no bands) is **not** rejected; the
split-tier spread line requires a **strict** `low < high` on split-tier bands
and exempts single-tier bands; the "Ranges well-formed" line carries the
"when present" guard; and **neither** a `generated_by`-shape check **nor** a
`path`-must-be-a-file check appears anywhere in the checklist.

The scenario **fails** if a future edit tightens the per-stage coupling into a
biconditional (`iff`) that would reject class B, drops or weakens the split-tier
spread rule, removes the "when present" guard from the range enumeration, or
adds a `generated_by`-shape or `path`-must-be-a-file check that would
retroactively fail an S1/S2-era record.

## Notes

Scope is the format-revision slice (#377) only. This scenario asserts the
**record-internal** half of the S1-O6 checkability (the strictly-spread
split-tier invariant); the **absolute-rate** half — confirming a split-tier
band's bounds equal the snapshot's `claude-sonnet-4`/`claude-opus-4` rates — is
a **runtime, snapshot-grounded check explicitly deferred to S3** (spec §4.4.1),
not asserted here. A `{ 99.0, 100.0 }` band passes the strict-spread check; the
scenario does **not** claim the spread check proves a genuine two-tier widening.

No S2 agent scenario is touched: this slice changes the format the agent
consumes, not the agent (spec §7, FR-11).
