# Estimate-Record Format Reference

The canonical, stable definition of the **estimate record** — the
structured markdown artefact a future cost-estimator agent emits, a
future `/cost-estimate` command writes and validates, and the
orchestrator fold-in surfaces fields from. It must be a stable contract.

A downstream command's **Output Validation Checkpoint** references this
file by path. Treat the field table, the binding table, the disclosure
body spec, and the validation checklist as precise — they are parsed, not
read loosely.

## Canonical artefact

The record is a single markdown file with **YAML frontmatter** for the
machine-readable fields and a **prose body** for the disclosures. The
frontmatter carries the structured fields a validation checkpoint parses;
the body carries the human-readable disclosure prose.

## Frontmatter field set

| Field | Type | Required | Purpose |
| --- | --- | --- | --- |
| `target` | string | yes | What was estimated — a path (slicing record, spec) or a short description of pasted task text. |
| `target_kind` | enum | yes | One of `task-text`, `slicing-record`, `slice`, `spec`. Signals the grounding richness available; richer targets warrant higher confidence. |
| `generated_at` | string (ISO 8601) | yes | Timestamp the estimate was produced. |
| `generated_by` | string | yes | Agent name plus **either** a concrete model identifier (e.g. `"cost-estimator / claude-opus-4-8"`) **or** a `tier:<tier>` routing-tier label when the concrete model is not available to the emitter at emit time (e.g. `"cost-estimator / tier:Standard"` — an agent running `model: inherit` that is not told its resolved model records the routing tier it reads from `MODEL_ROUTING.md`). The value is **never** a guessed or hard-coded model string. See the `generated_by` provenance grammar note below for the reserved `tier:` prefix. |
| `grounding_sources` | list of objects | yes | The inputs the estimate was built from. Each entry has `path` (string) and `kind` (one of `model-routing`, `cost-snapshot`, `calibration`). At minimum a `model-routing` entry and a `cost-snapshot` entry; a `calibration` entry is permitted but never required. When no snapshot **file** exists (states 1 and 2 — cost-omitted), the mandatory `cost-snapshot` entry's `path` is the **directory** `observability/costs/` (trailing slash) — the **defined cost-omitted sentinel**; see the grounding-path sentinel note below. |
| `tokens` | range object | yes | Estimated total token usage as `{ low: int, high: int }`. The budget-derived bounds. |
| `tokens_by_stage` | list of objects | yes | Per-stage breakdown. Each entry: `stage` (string — spec-writer, tdd-agent, implementer, code-reviewer, integration), `tokens` (range object), `model_tier` (string from the agent→model-tier mapping — may be a split tier such as `Standard/Capable`). May omit stages a target does not exercise; the omission must be reflected in the `Excluded` prose. |
| `tokens_by_stage[].cost_usd` | range object `{ low, high }` | **optional, one-directionally coupled** — **present ⟹ top-level `cost_usd` present** (enforced); top-level `cost_usd` present ⟹ bands **SHOULD** be populated by emitters, but their **absence does NOT invalidate** the record (**not** an `iff` — the asymmetry is deliberate) | The per-stage dollar contribution. Makes the split-tier widening a machine-readable disclosure surface and a **record-internal** spread check: a validator can assert a split-tier stage's band is **non-collapsed (strictly spread)** — `low < high` — consistent with the binding table's tier ordering. It **cannot** assert the bounds equal the absolute `claude-sonnet-4`/`claude-opus-4` rates — those live in the snapshot, not the record (see the per-stage cost validation notes below). |
| `cost_usd` | range object | **conditional (present-when-grounded)** | Estimated dollar cost as `{ low: float, high: float }`. **Present ONLY when an `observability/costs/` snapshot supplies a usable per-tier $/token rate.** When no usable rate exists, the field is **omitted entirely** and the omission is disclosed in `Excluded`. The format must not carry a placeholder, a null, or a forced list-price value. |
| `cost_basis` | enum | **conditional (present-when-grounded)** | Present **iff** `cost_usd` is present. One of `snapshot-actuals` (rate derived from a snapshot Model Breakdown) — currently the only grounded basis. Records the provenance of the $/token rate so a reader knows the cost is observed, not guessed. |
| `agent_compute_time` | range object | yes | Estimated wall-clock spent in agent execution as `{ low: <duration>, high: <duration> }`. Durations are ISO 8601 durations or plain `"Nm"`/`"Nh"` strings. Derived from token volume. |
| `human_gate_time` | string (qualitative caveat) | yes | A **disclosed qualitative caveat string**, NOT a numeric range. Total wall-clock is dominated by human availability at the orchestrator's disposition gates, and **is not estimated numerically at S1**. Carries a short prose statement to that effect, never a `{ low, high }` range. |
| `confidence` | object | yes | **Per-axis** confidence object with keys `tokens`, `time`, and (iff `cost_usd` present) `cost`, each one of `low`, `medium`, `high`. A whole-record summary tier MAY be reported as `min()` of the present axes, but the per-axis values are authoritative. |
| `failure_direction` | enum | yes | One of `likely-overrun`, `likely-underrun`, `symmetric`. The direction the estimate is most likely wrong in, with the rationale carried in the prose body. |

There is **no** point-value, `recommendation`, `verdict`, or `proceed`
field anywhere in the field set.

### `generated_by` provenance grammar — the reserved `tier:` prefix

The `generated_by` value carries the agent name, a ` / ` separator, and a
provenance token that is **either** a concrete model identifier **or** a
`tier:<tier>` routing-tier label (used when an `model: inherit` agent is not
told its resolved model and records the routing tier instead).

So the two forms are mechanically distinguishable, **`tier:` is a reserved
provenance prefix**: the provenance token after the ` / ` separator is a
**tier label if and only if it begins with the literal `tier:`**; otherwise it
is a **concrete model identifier**. A concrete model id **never** begins with
`tier:` — no model in `MODEL_ROUTING.md` or any snapshot is named with a
`tier:` prefix — so a consumer can mechanically decide which form it holds by
testing the `tier:` prefix, **without any rejecting check being added**. This
is a *grammar*, not a validator: the checklist adds **no** line that rejects a
malformed `generated_by`; the prefix reservation simply removes the ambiguity
for a consumer splitting on the separator. The value is **never** a guessed or
hard-coded model string.

### Per-stage `cost_usd` — the one-directional coupling

The optional `tokens_by_stage[].cost_usd` sub-field is coupled to the
top-level `cost_usd` as a **one-directional asymmetry, not a biconditional**
(it is **not** an `iff`):

- **Sub-field present ⟹ top-level `cost_usd` present** (enforced by the
  validation checklist — a per-stage band never appears on a cost-omitted
  record).
- **Top-level `cost_usd` present ⟹ bands SHOULD be populated** by emitters (so
  the per-stage decomposition that produced the whole-record figure is
  surfaced), but a cost-present record that omits them is **still valid** —
  this direction is an emitter obligation (a SHOULD), **not** a
  validation-rejection rule. This asymmetry is what keeps S1-era cost-present
  records (top-level cost, no per-stage bands) valid.
- **Top-level `cost_usd` absent** → **no** stage carries a per-stage
  `cost_usd`; the sub-field is absent everywhere (exactly as in Example 1).

The whole-record `cost_usd` band need **not** equal the arithmetic sum of the
per-stage bands (stages may be correlated, and the widening is applied per
stage), consistent with the existing same-rule for `tokens` vs
`tokens_by_stage[].tokens`. When they differ the prose body says why — no
**new** disclosure-body rule is added.

## Range representation

Every quantitative field that is **present** (`tokens`, each
`tokens_by_stage[].tokens`, each `tokens_by_stage[].cost_usd` *when present*,
`cost_usd` *when present*, `agent_compute_time`) is a two-key object
`{ low, high }`.
`human_gate_time` is **not** a quantitative range — it is a qualitative
caveat string and is exempt from these rules.

- `low ≤ high` for every present range.
- `cost_usd` is **conditional**: a record with `cost_usd` absent is valid
  (and is the expected day-one state); when present it must be a
  well-formed range and `cost_basis` must accompany it.
- A degenerate range where `low == high` is **permitted but discouraged**
  — it signals point-value thinking and should carry a `low` confidence
  tier and a prose note explaining why the range collapsed.
- The whole-record `tokens` range need not equal the arithmetic sum of
  `tokens_by_stage` ranges (stages may be correlated); when they differ
  the prose body must say why.

## The time split

`agent_compute_time` and `human_gate_time` are **two separate required
fields with different shapes**:

- **`agent_compute_time`** is a numeric `{ low, high }` range derived from
  token volume. The methodology applies a disclosed tokens→wall-clock
  band (default below) to the `tokens` range. The band is stated as an
  assumption in `Included`; it does not claim to be an observed actual.
- **`human_gate_time`** is a **qualitative caveat string, NOT a range**.
  It is **not estimated numerically at S1** because the gate set lives in
  the orchestrator (S4, #371), which this slice does not touch. Human-gate
  latency **dominates** total wall-clock and is the **least-predictable**
  term — it depends on when a human next disposes a gate, not on the work.
  Example value:

  > "human-gate latency dominates total wall-clock and is not estimated
  > numerically at S1; it depends on when a human next disposes a gate,
  > not on the work."

### Default throughput band (assumption)

`agent_compute_time` is derived by applying a **default throughput band
of ~1–3 minutes per 10k tokens generated** to the `tokens` range. This is
a stated assumption, not an observed actual, and must be named in
`Included`. No per-gate human-gate band ships — `human_gate_time` carries
no number at S1.

## The four-part disclosure body

Every estimate record's prose body MUST contain four labelled sections. A
record missing any of the four **fails validation**.

1. **Included** — what the estimate counts, and the provenance/quality of
   each included input (the stage set at its MODEL_ROUTING tier; the
   tokens→wall-clock band; *when a cost figure is present:* the $/token
   rate derived from the dated snapshot Model Breakdown). Quality-of-input
   caveats live here or under Confidence rationale.
2. **Excluded** — what the estimate does NOT count: human-gate latency
   (excluded from `cost_usd` and `tokens` because gates cost wall-clock
   not tokens); re-runs and diaboli/cartograph cycles beyond one pass; any
   stages a target does not exercise. **When `cost_usd` is omitted, the
   omission is disclosed here** (naming the cause). A *used* input never
   appears here.
3. **Confidence rationale** — why each present confidence axis (`tokens`,
   `time`, and, when present, `cost`) is what it is, in plain prose tied
   to `target_kind` and grounding richness.
4. **Failure direction** — a one-line statement matching the
   `failure_direction` field, naming WHY the estimate is more likely wrong
   in that direction. **Describes uncertainty only — no imperative
   recommendation, no go/no-go language.**

## Per-axis confidence mapping

Confidence is recorded **per axis**, not as one whole-record tier.

### Target-kind ceiling (applies to `tokens` and `time`)

| Tier | When | Typical `target_kind` |
| --- | --- | --- |
| `low` | Built from raw task text only, before slicing or spec. Scope is a guess; stage set is assumed. | `task-text` |
| `medium` | Built from a slicing record or a single slice — work decomposed but scenarios/files not yet enumerated. | `slicing-record`, `slice` |
| `high` | Built from a spec that enumerates scenarios and files to touch. | `spec` |

The ceiling is a **cap tied to grounding, not a verdict**. An axis may
sit below the cap, but a raw-text estimate's token confidence can never
be `high`.

### Cost axis (independent rule)

The `cost` axis exists **only when `cost_usd` is present**. It is set from
the snapshot's quality (age, breakdown granularity) and is **independent
of `target_kind`** — a spec-grounded target with a stale or coarse
snapshot can carry `tokens: high` beside `cost: low` without
contradiction.

## Tier→model→$/token binding table

The single source of the `tier → model` map for cost derivation. The cost
derivation reads this table so the binding is **not left to agent
discretion**.

| Model tier (MODEL_ROUTING) | Representative model (snapshot key) | $/token source |
| --- | --- | --- |
| Most capable | `claude-opus-4` | blended rate from the snapshot Model Breakdown row for `claude-opus-4` |
| Standard | `claude-sonnet-4` | blended rate from the snapshot Model Breakdown row for `claude-sonnet-4` |
| Standard / Capable (split) | spans `claude-sonnet-4` (low) … `claude-opus-4` (high) | **widened**: low bound uses the `claude-sonnet-4` rate, high bound uses the `claude-opus-4` rate |

`MODEL_ROUTING.md` names exactly two tiers — `Standard` and `Most
capable` — and one complexity-dependent split, the implementer's
`Standard / Capable`. There is **no standalone `Capable` tier with its own
model**; the dearer end of the split resolves to `Most capable`.

**Stage/tier normalisation (the join key).** A `tokens_by_stage[].stage`
maps to a MODEL_ROUTING Agent Routing row by **stripping the
`{{LANGUAGE}}-` prefix** — so `implementer` ↔ `{{LANGUAGE}}-implementer`.
Tier labels are compared **whitespace-insensitively** — so `Standard/Capable`
↔ `Standard / Capable`. This gives a mechanical consumer a defined join key
across the prefix and slash-spacing variants.

**Split-tier widening rule.** The implementer stage (`Standard / Capable`,
"Depends on task complexity") carries the largest token budget
(100–250k), so its rate dominates any cost figure. Its cost contribution
is **widened to span both ends of the split**: low bound priced at the
`claude-sonnet-4` rate, high bound at the `claude-opus-4` rate. Because
the two ends bind to **different** representative models, the widening
produces a genuine spread rather than collapsing to one rate. The same
widening applies to any stage MODEL_ROUTING.md lists with a slashed tier.
`tokens_by_stage[].model_tier` records the literal split label
(`Standard/Capable`) so the breakdown stays traceable.

**Per-stage band pricing convention (emitter methodology, NOT a checked
invariant).** When an emitter surfaces a per-stage `tokens_by_stage[].cost_usd`
band, a **split-tier** stage prices its **low** bound at the **cheaper**
representative model (`claude-sonnet-4`) and its **high** bound at the
**dearer** one (`claude-opus-4`), per the binding table. Because the two ends
bind to different rates, a genuine widening produces a strictly-positive spread
(`low < high`). The validator **cannot** confirm which bound binds to which
model from the record alone (it sees two numbers and their order, never the
per-model pricing); the cheaper-at-low / dearer-at-high ordering is therefore an
**emitter convention**, not a checkable invariant. The only predicate the
"Split-tier spread" checklist line tests on a present split-tier band is
`low < high`.

**Deriving a per-model rate from a snapshot.** The snapshot's
`## Model Breakdown` table gives per-model quarter-aggregate
input/output token volumes and an estimated cost. Compute a per-model
`$/token` as `estimated_cost ÷ (input_tokens + output_tokens)`, then bind
each stage's tier to its representative model's rate.
`cost_usd = Σ over stages (stage tokens range × tier $/token)`, with
split-tier stages widened.

The input/output token distinction is **deliberately collapsed** into this
single blended rate — this is the sanctioned spec-round blended-rate skew,
an accepted simplification, not a bug to fix. The blend's accuracy assumes
the estimated task's input/output ratio resembles the snapshot quarter's;
when those mixes diverge the figure skews. This is by design, so a
downstream S2 author should not "fix" it by reintroducing a per-direction
rate.

## The three grounding states for cost

1. **No snapshot exists** → `cost_usd` and `cost_basis` **omitted**;
   omission disclosed in `Excluded`. `tokens`/`agent_compute_time` still
   produced; `human_gate_time` caveat still produced.
2. **Snapshot present but Model Breakdown absent or too coarse** →
   `cost_usd` **omitted**; `Excluded` names this specific cause ("a cost
   snapshot exists but carries no usable per-model breakdown"). **No**
   silent fall-through to list price.
3. **Snapshot present with a usable Model Breakdown** → `cost_usd`
   **present**, `cost_basis: snapshot-actuals`, `confidence.cost` from the
   snapshot's age/granularity, snapshot date/quality disclosed in
   `Included`.

**There is no list-price fallback.** When cost cannot be grounded in
actuals, it is omitted with disclosure — the no-cost record is **valid and
complete**, not a failure. **No format change is required when the first
usable snapshot lands**: the same `cost_usd`/`cost_basis`/`confidence.cost`
fields simply begin to appear.

### The cost-snapshot grounding-path sentinel

When no snapshot **file** exists (states 1 and 2 — cost-omitted), the
mandatory `cost-snapshot` grounding entry's `path` is the **directory** the
emitter inspected, written with a trailing slash (`observability/costs/`). This
is the **defined cost-omitted sentinel**: the entry remains *present*
(satisfying the "at minimum a cost-snapshot entry" rule), and the directory
path records what the emitter actually read — the directory it inspected and
found empty (or without a usable snapshot). The `Excluded` prose names that the
directory held no usable snapshot. The entry is **never dropped** and **never
given a fabricated snapshot file path**. When a usable snapshot file exists
(state 3), the `path` is that **file** (e.g.
`observability/costs/2026-08-15-costs.md`).

**Consumer special-case (do not double-count).** Because the trailing-slash
directory path means *looked-and-found-nothing* rather than
*grounded-in-a-snapshot*, an aggregator that counts "how many records were
grounded in a cost snapshot" **must not** count a `cost-snapshot` entry whose
`path` ends in `/` as a grounding — it is a sentinel for the *absence* of a
snapshot. Test the trailing slash (directory) versus a file path to distinguish
the two meanings.

**This does not "resolve" the semantic tension — it entrenches an overloaded
meaning, deliberately.** A `cost-snapshot` entry's `path` now carries two
meanings depending on whether it resolves to a **file** (grounded in that
snapshot) or a **trailing-slash directory** (looked-and-found-nothing — the
negative fact "no snapshot here"). Naming the directory a `grounding_sources`
entry widens "the inputs the estimate was built from" to admit "a location an
input was looked for and not found." This was chosen over inventing a new
sentinel token on backward-compat grounds (zero consumer change, zero new parse
case), and paid for with the consumer special-case above. The strain is
**named and accepted**, not eliminated. **Noted residual:** the trailing-slash
consumer special-case is **advisory/unenforced** — no validation-checklist line
keys on `grounding_sources[].path` shape — so it externalises a silent-miscount
risk onto every downstream counter; nothing catches a consumer that counts a
trailing-slash directory entry as a real grounding. This is an accepted residual
of the deliberate keep-the-directory-sentinel trade.

## The calibration seam

`grounding_sources[]` permits a `kind: calibration` entry alongside
`model-routing` and `cost-snapshot`. Calibration data, when it exists,
**refines** existing $/token and per-stage token ranges (narrowing ranges,
potentially raising confidence) rather than introducing a new field. No
per-PR actuals capture, format, or integration-agent change ships in this
slice.

## Validation checklist

The checks a consuming command's Output Validation Checkpoint runs:

- [ ] **Ranges well-formed** — every **present** range
  (`tokens`, each `tokens_by_stage[].tokens`, each
  `tokens_by_stage[].cost_usd` when present, `cost_usd` when present,
  `agent_compute_time`) has `low ≤ high`.
- [ ] **Per-stage cost coupling** — if **any**
  `tokens_by_stage[].cost_usd` is present, the record's top-level `cost_usd`
  must also be present (per-stage cost bands never appear on a cost-omitted
  record). A record with **no** per-stage `cost_usd` sub-fields satisfies this
  check vacuously — **old records and cost-omitted records are not rejected.**
  This check does **not** mandate that a cost-present record carry per-stage
  bands; it only forbids the incoherent inverse (a per-stage band with no
  whole-record cost). Emitters SHOULD populate per-stage bands on cost-present
  records, but a cost-present record without them remains valid for
  backward-compatibility with S1-era records.
- [ ] **Split-tier spread** — for **every present**
  `tokens_by_stage[].cost_usd` whose `model_tier` is a **split tier**, the band
  must have a **strictly-positive ordered spread**: `low < high` (strict, not
  merely `low ≤ high`). A `model_tier` **is a split tier if and only if its
  label contains a `/`** (after the join-key whitespace normalisation);
  otherwise it is a single tier. A collapsed band (`low == high`) on a
  split-tier stage fails this check. **Single-tier** stages are exempt (they
  may carry `low == high`, governed only by "Ranges well-formed"). A record
  with no per-stage `cost_usd` satisfies this check vacuously. (`model_tier` is a
  **required** sub-field of every `tokens_by_stage[]` entry, so a cost-bearing
  stage with an absent `model_tier` is a structural failure caught by the
  field-required checks — not a vacuous pass on this line.) (The
  cheaper-at-low / dearer-at-high pricing rationale lives in the split-tier
  widening methodology above, **not** here — the only predicate this line tests
  is `low < high`.) The split-tier trigger is a **closed rule**: `MODEL_ROUTING.md`
  names exactly the single tiers `Most capable` and `Standard` (neither contains
  `/`) plus the one complexity-dependent split `Standard / Capable`, so
  "contains `/`" is a sound *total* classifier over every tier label the
  reference admits — and emitters **MUST** write only those enumerated labels
  into `model_tier` (the field is documented as a `string` for forward-
  compatibility, but is not free-form), so the classifier's totality holds for
  every conformant record.
- [ ] **All four disclosure sections present** — Included, Excluded,
  Confidence rationale, Failure direction. A record missing any fails.
- [ ] **Per-axis confidence within cap** — each present `confidence` axis
  is within the `target_kind` ceiling for `tokens`/`time`; the `cost` axis
  is present **iff** `cost_usd` is present. Cap the `tokens`/`time` axes by
  `target_kind` (`task-text`→`low`, `slicing-record`/`slice`→`medium`,
  `spec`→`high`; see the Target-kind ceiling table above). Do **NOT** cap
  the `cost` axis by `target_kind` — it is independent (see the Cost axis
  rule above), so a `cost: low` beside `tokens: high` is valid.
- [ ] **Cost pairing** — `cost_usd` and `cost_basis` are **both present or
  both absent**; when absent, the `Excluded` section contains the
  cost-omission disclosure.
- [ ] **Time split** — both time fields present and **separate**:
  `agent_compute_time` a `{ low, high }` range, `human_gate_time` a
  qualitative caveat string (NOT a range).
- [ ] **No-verdict, field-absence layer** — no `recommendation`,
  `verdict`, or `proceed` field appears in the frontmatter.
- [ ] **No-verdict, positive-content layer** — the disclosure prose
  contains **no imperative recommendation or go/no-go language**. The scan
  **fails the record** if any of the following representative prohibited
  patterns appear: `"so proceed"`, `"do not proceed"`, `"I recommend"`,
  `"you should ship"`, `"you should skip"`, `"you should approve"`,
  `"you should reject"`, `"go/no-go"`. The **Failure direction** section
  describes uncertainty only — a sentence like "failure direction:
  likely-overrun, so do not proceed" **fails** the positive-content check
  even though it passes the field-absence check. This scan is a **tripwire
  for the common verdict phrasings, not a proof**: the pattern list is a
  closed enumeration, so a paraphrased verdict ("the high bound makes this
  not worth building", "budget does not justify the spend") can evade it.
  Its strength is "catches the common cases", not "independent of any
  agent's behaviour" — unlike the field-absence layer, which is structural.

### Per-stage cost — what the validator CAN and CANNOT assert

The per-stage `cost_usd` sub-field makes a split-tier band's **non-collapsed
(strictly-spread)** shape record-internally checkable. This is a **floor**, not
the full widening — state it plainly:

- The validator **CAN** assert: (1) **presence/coupling** — a per-stage band
  implies top-level cost; (2) `low ≤ high` on every present band; (3) a
  **strictly-positive ordered spread** (`low < high`) on every present
  **split-tier** band — i.e. that the band is **non-collapsed (strictly
  spread)**. A `{ 99.0, 100.0 }` band still *passes* `low < high`, so the check
  earns only the move from "any ordered band (including a collapsed `{x, x}`)"
  to "a non-collapsed split-tier band". It does **not** earn "the band spans two
  tiers": a non-collapsed band is necessary, but not sufficient, for a genuine
  two-tier widening.
- The validator **CANNOT** assert: that the band **spans two tiers** (a
  `{ 99.0, 100.0 }` band passes the strict-spread check while bearing no
  relationship to the two rates), that the absolute `low`/`high` **equal** the
  specific `claude-sonnet-4`/`claude-opus-4` rates, nor that the spread's
  magnitude is *correct* for those rates — all three require the snapshot, which
  the record does not carry. That absolute-rate falsification is a **runtime,
  snapshot-grounded check** and is **deferred to S3's Output Validation
  Checkpoint** (which can read both the record and the snapshot), not this
  format-only contract edit.

**Option (a) — having the record carry the per-model rates it used so the check
is fully self-contained — was rejected**: it adds data the merged emitter does
not emit, which (i) breaks backward-compat against every record that lacks the
new field and (ii) re-introduces a new required field. The chosen mechanism is
the **record-internal spread invariant** above (option (b)) — the strongest
invariant available without snapshot data.

## Worked examples

### Example 1 — cost-omitted (today's default: no usable snapshot)

```markdown
---
target: docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md
target_kind: spec
generated_at: 2026-06-10T14:22:00Z
generated_by: "cost-estimator / claude-opus-4-8"
grounding_sources:
  - path: MODEL_ROUTING.md
    kind: model-routing
  - path: observability/costs/
    kind: cost-snapshot
tokens: { low: 250000, high: 600000 }
tokens_by_stage:
  - stage: spec-writer
    tokens: { low: 50000, high: 100000 }
    model_tier: Most capable
  - stage: tdd-agent
    tokens: { low: 50000, high: 150000 }
    model_tier: Standard
  - stage: implementer
    tokens: { low: 100000, high: 250000 }
    model_tier: Standard/Capable
  - stage: code-reviewer
    tokens: { low: 50000, high: 100000 }
    model_tier: Most capable
agent_compute_time: { low: 25m, high: 3h }
human_gate_time: "human-gate latency dominates total wall-clock and is not estimated numerically at S1; it depends on when a human next disposes a gate, not on the work."
confidence:
  tokens: high
  time: medium
failure_direction: likely-underrun
---

## Included

The four orchestrator agent stages this spec exercises (spec-writer,
tdd-agent, implementer, code-reviewer) at their MODEL_ROUTING tier, with
token ranges from the Token Budget Guidance table. Agent-compute time is
derived from token volume via the default band of ~1–3 minutes per 10k
tokens generated, stated here as an assumption.

## Excluded

cost_usd: omitted — no repo cost snapshot exists yet (observability/costs/
is empty), so no observed $/token is available; cost is not estimated.
Token and time figures stand. Also excluded: human-gate latency (gates
cost wall-clock, not tokens); re-runs and any diaboli/cartograph cycles
beyond one pass; the integration stage, which this spec-only target does
not exercise.

## Confidence rationale

tokens: high — the target is a spec that enumerates scenarios and files,
so the stage set and rough volume are grounded in named artefacts. time:
medium — the throughput band is an assumption, not an observed actual, so
the derived wall-clock is one tier below the token grounding.

## Failure direction

likely-underrun on wall-clock: human-gate latency is unbounded and is not
estimated as a number here, so total wall-clock will exceed the
agent-compute range when the human-gate caveat is read alongside it.
```

### Example 2 — cost-present (a snapshot with a usable Model Breakdown exists)

```markdown
---
target: docs/superpowers/slices/cost-estimator-pipeline.md
target_kind: slice
generated_at: 2026-09-01T09:00:00Z
generated_by: "cost-estimator / claude-opus-4-8"
grounding_sources:
  - path: MODEL_ROUTING.md
    kind: model-routing
  - path: observability/costs/2026-08-15-costs.md
    kind: cost-snapshot
tokens: { low: 200000, high: 500000 }
tokens_by_stage:
  - stage: spec-writer
    tokens: { low: 50000, high: 100000 }
    model_tier: Most capable
    cost_usd: { low: 1.00, high: 2.00 }
  - stage: tdd-agent
    tokens: { low: 50000, high: 150000 }
    model_tier: Standard
    cost_usd: { low: 0.20, high: 0.60 }
  - stage: implementer
    tokens: { low: 100000, high: 250000 }
    model_tier: Standard/Capable
    cost_usd: { low: 0.40, high: 5.00 }
cost_usd: { low: 1.60, high: 7.60 }
cost_basis: snapshot-actuals
agent_compute_time: { low: 20m, high: 2h30m }
human_gate_time: "human-gate latency dominates total wall-clock and is not estimated numerically at S1; it depends on when a human next disposes a gate, not on the work."
confidence:
  tokens: medium
  time: medium
  cost: low
failure_direction: likely-overrun
---

## Included

The spec-writer, tdd-agent, and implementer stages at their MODEL_ROUTING
tier, with token ranges from the Token Budget Guidance table.
Agent-compute time derived from token volume via the ~1–3 min per 10k
tokens band. The $/token rate is derived from the 2026-08-15 snapshot
Model Breakdown (observed actuals): claude-sonnet-4 and claude-opus-4
blended per-model rates. Each stage's per-stage dollar contribution is
surfaced as a `tokens_by_stage[].cost_usd` band (not only described): spec-writer
$1.00–$2.00 (Most capable → claude-opus-4), tdd-agent $0.20–$0.60 (Standard →
claude-sonnet-4), implementer $0.40–$5.00 (Standard/Capable, split). The
implementer stage (Standard/Capable) is priced by widening across both ends of
the split — its low bound uses the claude-sonnet-4 rate, its high bound uses the
claude-opus-4 rate — so its $0.40–$5.00 cost band is visibly wider than its
token-range spread alone would imply. The three per-stage bands sum to the
whole-record $1.60–$7.60 cost band **here by construction** — this exact
equality is a property of this worked example, **not** a contract rule: the
"Ranges well-formed" correlation note above permits the whole-record band to
differ from the per-stage sum (a record whose bands deliberately diverge is
valid, provided its prose says why). Do not read this example as a must-sum
mandate.

## Excluded

human-gate latency (gates cost wall-clock, not tokens, so they are
excluded from cost_usd and tokens); re-runs and diaboli/cartograph cycles
beyond one pass; the code-reviewer and integration stages, which this
slice target does not yet enumerate.

## Confidence rationale

tokens: medium — the target is a single slice; work is decomposed but
scenarios and files are not yet enumerated, so the stage set is partly
assumed. time: medium — the throughput band is an assumption. cost: low —
the snapshot is one quarter old and aggregates models coarsely, so the
$/token rate is a stale blended figure; this is independent of the
token grounding, which is why cost sits below tokens.

## Failure direction

likely-overrun: the per-stage budgets are upper-tier defaults and most
slices land below them, so the high bound is more likely loose than the
low bound is tight.
```

Neither worked example files an inclusion caveat under `Excluded`, and
neither contains imperative recommendation or go/no-go language.
