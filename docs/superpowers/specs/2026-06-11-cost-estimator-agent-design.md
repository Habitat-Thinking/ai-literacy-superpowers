# Cost Estimation — S2 — read-only cost-estimator agent — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-11 |
| Status | Draft |
| Author | spec-writer (interactive session with russmiles) |
| Slice | S2 of the slicing record at `docs/superpowers/slices/cost-estimator-pipeline.md` |
| Progressed slice | S2 (this spec) |
| Tracking issue | #369 |
| Upstream (merged on main) | S1 (#—, merged): `cost-estimation` skill + estimate-record format reference |
| Downstream slices | S3 (#370), S4 (#371), S5 (#372), S6 (#373) — all out of scope here |
| Plugin version target | `ai-literacy-superpowers` v0.41.0 → v0.42.0 (new agent — minor bump) |
| Marketplace listing | Top-level `version` unchanged at v0.4.0; `plugin_version` 0.41.0 → 0.42.0 |
| PR ceremony | feature — full `/diaboli` (spec + code) and `/choice-cartograph` |
| Governing decisions | AGENTS.md **"agent-emit + dispatcher-persist + human-disposes"** trust architecture (with its **dispose-then-write ordering invariant**); AGENTS.md **"disclosure-of-derived-judgment"** decision (the four-part disclosure the agent must populate honestly). |

---

## 1. Premise

S1 shipped the **definition** of an estimate: the `cost-estimation` skill
(methodology + disclosure contract) and the `estimate-record-format.md`
reference (the stable field set, the tier→model→$/token binding table, the
four-part disclosure body, the validation checklist, two worked examples). S1
shipped **no emitter** — it defined what a record *is*, not the thing that
produces one.

S2 is that emitter: the **read-only `cost-estimator` agent**. Given a target
(raw task text, a slicing record, a slice, or a spec), it reads
`MODEL_ROUTING.md` and the latest `observability/costs/` snapshot, applies the
S1 methodology, and **returns the estimate-record content as a string** for a
dispatching command or orchestrator to write to disk. It is a derived-judgment
**emitter**, not a decider.

This slice's load-bearing decision is the one the slicing record's
`decision_focus` names: *does the estimator faithfully mirror the established
read-only-agent-emits-record-human-disposes pattern, or does it drift into
returning a recommendation?* The whole architecture hinges on the agent being a
derived-judgment emitter, not a "smart" component that picks the answer. S2
locks:

1. **The trust boundary** — `Read`, `Glob`, `Grep` only. No `Write`, no `Edit`,
   no `Bash`. The agent cannot persist the record; that is the dispatcher's job
   (S3 command / S4 orchestrator fold-in, both out of scope).
2. **The input/target contract** — exactly what targets the agent accepts and
   how it classifies a target into `target_kind` (`task-text` |
   `slicing-record` | `slice` | `spec`), which drives the S1 confidence ceiling.
3. **The emit-not-write + refusal-string discipline** — the agent returns the
   record as a string; when it cannot ground an estimate it returns a **refusal
   string** (mirroring `model-card-researcher`'s `REFUSED:` line) rather than
   fabricating, and the dispatcher refuses to persist a refusal.

S2 honours both governing AGENTS.md decisions, not merely the tool split: the
**dispose-then-write ordering invariant** (the human disposition must precede
the write — but the write itself is the dispatcher's, downstream of S2) and the
**disclosure-of-derived-judgment** contract (the agent must populate the
four-part disclosure honestly, since the estimate is a derived prediction, not
an inspected fact).

## 2. Scope and non-goals

### 2.1 In scope (S2)

- A new agent at `ai-literacy-superpowers/agents/cost-estimator.agent.md` with a
  `Read, Glob, Grep` tool boundary, mirroring the
  carpaccio / advocatus-diaboli / choice-cartographer / model-card-researcher
  read-only-emitter pattern.
- The agent's **charter**: load the S1 `cost-estimation` skill as reasoning
  context, read its grounding sources, and emit a record conforming to the S1
  `estimate-record-format.md` (referenced by path, **not** redefined).
- The agent's **input/target contract**: the accepted target types and the
  `target_kind` classification rule (§4).
- The agent's **emit-not-write discipline** and **refusal-string convention**
  for ungroundable or unreadable targets (§5).
- The **deferred-from-S1 residual decisions** (O6, O3, O4) resolved (§6),
  including a **backward-compatible** format-reference addition for O6.
- A TDAD scenario set covering the agent (structural + behavioural layers)
  under `tdad_tests/scenarios/agents/cost-estimator/` (§8).
- A new `MODEL_ROUTING.md` Agent Routing row for the `cost-estimator` (§7).
- The plugin version bump (0.41.0 → 0.42.0), CHANGELOG entry, marketplace
  `plugin_version` pointer, README badge, and a docs touch (reference +
  how-to/explanation) — the maintenance steps that attach to any new agent.

### 2.2 Out of scope (filed as separate issues)

Only S2 ships here. The following are explicitly **not** in this PR:

- **S3 — the `/cost-estimate` command** (#370). No file under
  `ai-literacy-superpowers/commands/`. The agent returns a string; **the
  command (S3) writes it to disk and runs the Output Validation Checkpoint**.
  S2 must not write any estimate record, must not define the on-disk path, and
  must not implement the validation checkpoint — those are the dispatcher's. The
  spec may say "a dispatcher persists the returned string"; it must not name
  *which* dispatcher, *where* the file lands, or *how* it is validated.
- **S4 — orchestrator fold-in at T1/T2** (#371). No change to
  `agents/orchestrator.agent.md`. No gate is added, moved, or re-weighted. The
  agent does not know which gate surfaces its fields or how many gates a target
  passes through — that gate topology remains the orchestrator's (and is exactly
  why `human_gate_time` carries no number at S1/S2; see §6, O-residual notes).
- **S5 — T0 pre-carpaccio ballpark** (#372). No pre-step-0 touchpoint. The agent
  *accepts* a `task-text` target (so S5 can reuse it), but the firing position
  and the bonus-step wiring are S5's.
- **S6 — calibration loop** (#373). No per-PR actuals capture, no
  integration-agent change. The agent reads a `kind: calibration` grounding
  source **if one exists**, per the S1 seam, but does not produce or require it.

This spec must not let any consumer leak into S2. If a reviewer finds the agent
charter naming *which command writes its output*, *which gate surfaces its
fields*, or *where on disk the record lands*, that is scope creep into S3–S5 and
should be cut back to "a dispatcher does X" without naming the dispatcher's
mechanics.

### 2.3 What S2 consumes from S1 (do not redefine)

S2 is a **consumer** of the S1 contract. It does **not** redefine the estimate
record. Specifically:

- The **field set, range rules, time split, per-axis confidence, binding table,
  three grounding states, validation checklist, and worked examples** live in
  `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`.
  The agent **references that file by path** and emits a conforming record. The
  one exception is the O6 residual (§6.1), which **adds** a field to that
  reference in a backward-compatible way — a deliberate, in-scope S2 change to
  the S1 reference, not a redefinition.
- The **methodology** (token derivation, cost derivation, the no-list-price-
  fallback rule, the disclosure contract) lives in
  `ai-literacy-superpowers/skills/cost-estimation/SKILL.md`. The agent loads it
  as reasoning context.

## 3. The agent's charter and trust boundary

### 3.1 Charter

The `cost-estimator` is a **read-only derived-judgment emitter**. Its single
job: given a target, produce the estimate-record content (per the S1 format)
and return it as a string. It applies the S1 methodology; it does not invent a
new one. It never decides go/no-go, never picks a confidence label as a verdict,
never writes a file.

The charter mirrors the four production read-only emitters
(`advocatus-diaboli`, `choice-cartographer`, `model-card-researcher`, and the
`/diagnose` agent) per the AGENTS.md **"agent-emit + dispatcher-persist +
human-disposes"** decision. The cost-estimator is the next instance.

### 3.2 Trust boundary (the load-bearing decision)

**Tools: `Read`, `Glob`, `Grep` only.** No `Write`, no `Edit`, no `Bash`.

This is not a limitation — it is the mechanism. The agent **cannot** write the
estimate record, so the human disposition that the S1 disclosure contract
depends on cannot be bypassed by an agent that quietly persists its own output.
The agent emits; a dispatcher persists *after a human disposes* (the
dispose-then-write ordering invariant, owned by the dispatcher in S3/S4, not
S2). The tool boundary is what makes "emits, never decides" enforceable by
construction rather than by good behaviour.

The trust-boundary decision is **two halves**, and the spec honours both per the
AGENTS.md ordering-invariant sharpening:

1. **Tool half (S2's responsibility)** — minimum trust surface: read-and-author
   only, no shell, no edit. S2 owns this and ships it.
2. **Ordering half (the dispatcher's responsibility, S3/S4)** — the human
   disposition PRECEDES the write. S2 cannot violate this (it has no write), but
   it must not be specced in a way that *assumes* a write happens before a human
   sees the record. The agent's deliverable is a *returned string*; the spec
   states plainly that nothing is persisted by S2.

A spec can honour the pattern's name and still break its invariant (the AGENTS.md
`/diagnose` worked instance). S2 cannot break the ordering invariant because it
holds no write tool — but the spec records the invariant explicitly so the S3/S4
dispatcher specs inherit it rather than re-deriving it.

## 4. The input / target contract

### 4.1 Accepted targets

The agent accepts exactly one target per dispatch, which is one of:

| Target | What it is | How supplied |
| --- | --- | --- |
| Raw task text | A pasted prose description of work, before any slicing or spec | Inline string in the dispatch |
| A slicing record | A carpaccio slicing record file (the whole multi-slice record) | A path |
| A single slice | One slice extracted from a slicing record | A path + slice id, or inline slice text |
| A spec | A design spec enumerating scenarios and files to touch | A path |

The agent reads a path target with `Read`/`Glob`/`Grep`. An inline-text target
(raw task text, or an inline slice) is read directly from the dispatch.

### 4.2 `target_kind` classification

The agent classifies its target into the S1 `target_kind` enum
(`task-text` | `slicing-record` | `slice` | `spec`). The classification is
**load-bearing** because it sets the S1 confidence **ceiling** for the
`tokens`/`time` axes (`task-text` → `low`; `slicing-record`/`slice` →
`medium`; `spec` → `high`). The classification rule, in priority order:

1. **Explicit kind in the dispatch** — if the dispatcher states the
   `target_kind`, the agent uses it (the dispatcher knows what it passed). This
   is the primary path: S3/S4/S5 dispatchers will state the kind.
2. **Inferred from a path's content** when no explicit kind is given:
   - A file whose frontmatter/structure matches a **slicing record** (a
     `slices:` array, carpaccio frontmatter) → `slicing-record`.
   - A file matching a **design spec** (a spec header table, numbered sections,
     acceptance scenarios) → `spec`.
   - A path naming a single slice, or a slice-shaped fragment → `slice`.
3. **Inline prose with no path and no stated kind** → `task-text` (the
   lowest-grounding, `low`-ceiling default).

When inference is **ambiguous** (a path that could be either a slicing record or
a spec, or a file that does not match any known shape), the agent does **not
guess silently**. It either (a) classifies to the **lower-grounding** kind of
the two candidates — the conservative choice, since a lower ceiling cannot
over-claim confidence — and **discloses the ambiguity in the
`Confidence rationale`** body section, **or** (b) when the target is genuinely
unreadable or unclassifiable, returns the **refusal string** (§5.2). The
spec mandates that an ambiguous classification is always disclosed, never
silently resolved to the higher ceiling.

### 4.3 Why the contract is in S2, not S1

S1 *defined* the `target_kind` enum and its confidence ceiling. S1 did **not**
define **how a concrete target becomes a `target_kind`** — that is a behaviour
of the emitter, and the emitter is S2. The classification rule (§4.2) is
genuinely new S2 surface: it is the agent's input contract, the thing a
dispatcher relies on to know what it gets back.

## 5. Emit-not-write and the refusal-string discipline

### 5.1 The agent emits a string; it never writes

The agent's deliverable is **the estimate-record content returned as its final
message** — YAML frontmatter plus the four-part prose body, conforming to the S1
format, and nothing outside of it. The agent does not write the record, name its
on-disk location, or validate it. A dispatcher (S3 command / S4 orchestrator,
out of scope) persists the returned string **after a human disposes**.

This mirrors `choice-cartographer` ("Return the complete content … the
orchestrator will write the content verbatim") and `model-card-researcher`
("You do not write the file. The dispatching command persists the output after a
human-in-the-loop review step").

### 5.2 The refusal-string convention

When the agent **cannot ground an estimate**, it returns a **refusal string**
instead of a fabricated record, mirroring `model-card-researcher`'s `REFUSED:`
line. A refusal is returned when, and only when:

1. **The target is unreadable** — a path that does not resolve, or inline text
   that is empty or so vague no stage set can be assumed at all.
2. **The grounding is absent** — `MODEL_ROUTING.md` cannot be read (the token
   and tier grounding is the day-one deliverable; without it there is no honest
   estimate, only a guess).
3. **The target is unclassifiable** — it matches no `target_kind` shape and
   inference under §4.2 cannot conservatively resolve it.

The refusal string has a stable, machine-greppable prefix so a dispatcher can
detect it and decline to persist:

```text
REFUSED: <one-line reason>. Target: <target description>. Grounding read: <what was/was not readable>. The dispatching command should surface this to the user; no estimate record should be written.
```

The dispatcher will not write a record when this `REFUSED:` string is the agent
output (the dispatcher's check is S3/S4 scope; the *convention* is S2's). This
prevents an authoritative-looking estimate record for a target the agent could
not honestly ground — the exact analogue of refusing to emit a model card for an
unconfirmed model.

### 5.3 The crucial distinction: an empty `observability/costs/` is NOT a refusal

A missing **cost snapshot** is **not** an ungroundable target. Per the S1 three
grounding states, an empty `observability/costs/` (today's default) yields a
**valid, complete cost-omitted record** — `cost_usd`/`cost_basis` omitted, the
omission disclosed in `Excluded`, and token + time figures standing. The agent
**emits the cost-omitted record**, it does **not** refuse. Refusal is reserved
for an **unreadable/unclassifiable target or absent token grounding**
(`MODEL_ROUTING.md`), never for an honestly-omittable cost figure. Conflating
the two would make the agent refuse on every estimate in today's repo, which is
the opposite of the S1 "no-cost case is honest, not a failure" decision.

## 6. The deferred-from-S1 residual decisions

S1's reviews left three items explicitly tagged for S2. This spec makes a
deliberate call on each.

### 6.1 O6 (S1 code-mode) — verifiable split-tier widening — **FOLD IN**

**Residual:** S1's split-tier widening (the implementer's `Standard/Capable`
priced low at `claude-sonnet-4`, high at `claude-opus-4`) is demonstrated only
in prose and a worked example — it is not machine-checkable on an emitted
record, because `tokens_by_stage[]` carries no per-stage cost.

**Decision: FOLD IN.** S2 adds a **backward-compatible** optional sub-field to
`tokens_by_stage[]` in the S1 format reference:

- `tokens_by_stage[].cost_usd` — an **optional** `{ low, high }` range giving
  the per-stage cost contribution, present **iff** the record's top-level
  `cost_usd` is present (i.e. only when a snapshot grounds cost). When the record
  is cost-omitted, the sub-field is absent on every stage, exactly as the
  top-level `cost_usd` is.

This makes the widening **verifiable**: for the implementer (or any slashed-tier)
stage, a validator can assert `cost_usd.low` was priced at the cheaper
representative model and `cost_usd.high` at the dearer one, so the per-stage band
is genuinely wider than a single-rate band would be. The whole-record `cost_usd`
need not equal the arithmetic sum of the per-stage sub-fields (same correlation
caveat as `tokens`); when they differ the prose body says why.

**Backward-compatibility is mandatory** (the S1 format is a stable contract with
the S3 command's checkpoint reading it): the sub-field is **optional and
additive**. Every S1-conforming record (which has no `tokens_by_stage[].cost_usd`)
remains valid. The S1 cost-omitted worked example is untouched. The S1
cost-present worked example is **extended** to show the per-stage `cost_usd` so
the widening is visible on a concrete record. The validation checklist gains a
check (per-stage `cost_usd` present iff top-level `cost_usd` present; slashed-tier
stages show a low<high cost band).

**Why fold in rather than re-defer:** O6 was tagged for S2 precisely because the
emitter is the first thing that *produces* a widened figure; making it verifiable
at the moment it first becomes producible is cheaper than retrofitting a third
time, and the addition is small and backward-compatible. Re-deferring it to a
later slice would orphan it (the deferred-concern-accretion risk AGENTS.md warns
about), since no later slice is named as its home.

### 6.2 O3 (S1 spec-mode) — binding-table drift re-verification — **FOLD IN (as an agent obligation)**

**Residual:** should the agent re-verify the tier→model binding (the S1 binding
table) against `MODEL_ROUTING.md`'s tiers and the snapshot's model keys when it
computes cost, rather than trusting the static binding table blindly?

**Decision: FOLD IN, as an agent obligation, but bounded.** When the agent
computes a cost figure (state 3 — a usable snapshot exists), it MUST:

1. Confirm the tiers it reads from `MODEL_ROUTING.md` Agent Routing are the tiers
   the S1 binding table names (`Standard`, `Most capable`, the `Standard/Capable`
   split). If `MODEL_ROUTING.md` has gained a tier the binding table does not map
   (e.g. a new standalone `Capable` model), the agent does **not** invent a
   binding — it **discloses the unmapped tier in `Confidence rationale`** and, if
   that tier is load-bearing for the target's stage set, **omits `cost_usd` with
   disclosure** (state-2-style) rather than guessing.
2. Confirm the representative model keys the binding table names
   (`claude-opus-4`, `claude-sonnet-4`) exist in the snapshot's Model Breakdown.
   If a required key is absent, that is the S1 **state 2** ("snapshot present but
   Model Breakdown absent or too coarse") → `cost_usd` **omitted with
   disclosure**, naming the missing key as the cause.

This is bounded: the agent **does not edit** the binding table (it has no write
tool, and the binding table is the named S6-revisable artefact, not agent
judgement). It only **detects drift and degrades gracefully to cost-omission**,
disclosing the cause. This keeps the binding "named, not agent discretion" (the
S1 O5 decision) while making the agent honest when the named binding no longer
matches reality.

**Why fold in:** the binding table is static; `MODEL_ROUTING.md` and snapshots
evolve. An agent that silently prices against a stale binding would emit a
confident-looking cost that is wrong — exactly the false precision the whole
capability opposes. The cheap, honest response (detect, disclose, degrade to
omission) is an emitter behaviour, so it belongs in S2.

### 6.3 O4 / O2 (S1 spec-mode / code-mode) — blended input/output rate skew — **FOLD IN (as a disclosure obligation)**

**Residual:** the S1 binding collapses input/output token rates into a single
blended $/token (the sanctioned spec-round simplification). The skew is disclosed
*in the S1 reference's prose*; should the **agent** surface it on each
cost-bearing record it emits?

**Decision: FOLD IN, as a disclosure obligation on cost-bearing records.** When
the agent emits a record with `cost_usd` **present**, it MUST surface the blended-
rate skew honestly in the disclosure body:

- The `Confidence rationale` (or `Included`) section names that the $/token rate
  is a **single blended figure** (input and output rates collapsed), derived from
  the snapshot quarter's mix, and that the figure **skews when the estimated
  task's input/output ratio diverges from the snapshot quarter's**.
- The `failure_direction` reasoning accounts for it: a task heavier on output
  than the snapshot quarter (output is dearer) leans `likely-underrun` on cost; a
  task heavier on input leans `likely-overrun`. The agent states the direction it
  judges, with the blended-rate skew named as a contributing reason.

The agent does **not** "fix" the skew by reintroducing a per-direction rate — S1
sanctioned the blend explicitly, and the S1 reference tells a downstream author
not to undo it. S2's obligation is to **surface** the known simplification on the
record, not to re-engineer the methodology. On **cost-omitted** records the
obligation does not apply (there is no rate to skew).

**Why fold in:** the skew is real and the S1 reference already discloses it in
methodology prose — but a *record* that prices cost without naming the
simplification reads as more precise than it is. The four-part disclosure
contract (the AGENTS.md disclosure-of-derived-judgment decision) exists precisely
to make derivation simplifications interrogable; surfacing the blended-rate skew
on cost-bearing records is that decision applied. It is an emitter behaviour, so
S2 owns it.

### 6.4 Residual summary

| Residual | S1 origin | S2 decision | Mechanism |
| --- | --- | --- | --- |
| O6 — widening not machine-checkable | code-mode | **Fold in** | Add backward-compatible optional `tokens_by_stage[].cost_usd` to the S1 reference; verifiable on cost-present records |
| O3 — binding-table drift | spec-mode | **Fold in** | Agent re-verifies tiers + model keys at cost time; degrades to cost-omission-with-disclosure on drift; never edits the binding |
| O4/O2 — blended-rate skew | spec/code-mode | **Fold in** | Agent surfaces the blended-rate skew in the disclosure + failure_direction of cost-bearing records; never reintroduces per-direction rates |

## 7. MODEL_ROUTING.md row

A new agent needs an Agent Routing row in `MODEL_ROUTING.md`. The
`cost-estimator` runs at the **Standard** tier:

| Agent | Model tier | Rationale |
| --- | --- | --- |
| cost-estimator | Standard | Read-and-author against a fixed methodology and named grounding sources — applies the S1 skill and emits a conforming record. It is not deep adversarial judgment (diaboli) or design synthesis (spec-writer); it follows a defined derivation. The throughput-shaped read-and-emit work fits Standard. |

The estimator is a **read-and-author** agent, like `tdd-agent` (Standard), not a
**judgment-heavy** one like `advocatus-diaboli` or `spec-writer` (Most capable).
Its task is to apply a specified methodology to named inputs and emit a
structured record — closer to "structured output from specs" than to "adversarial
reasoning". (A note: the agent file stays `model: inherit` per the
MODEL_ROUTING.md convention; the routing table records the tier, the agent file
does not pin a model.)

## 8. Component design (per component-design-with-tdad)

- **Type**: agent — the deliverable is a dispatchable read-only emitter with a
  tool boundary and a charter. Not a skill (the methodology it applies is the S1
  skill) and not a command (the dispatching surface is S3).
- **Justification**: S1 shipped the methodology + format as loadable context; S2
  is the dispatchable behaviour that *produces* a record. The read-only-emitter
  shape is the established pattern for content-emitting agents (AGENTS.md
  ARCH_DECISION); a new agent file is the canonical home.
- **TDAD layers targeted**: `[structural, behavioural]`. Layer 1 (structural)
  always — frontmatter well-formed, tool boundary is exactly `Read, Glob, Grep`,
  required charter/contract/refusal sections present. Layer 3 (behavioural)
  **applies here** because the agent has a clear assertable side-effect: a dispatch
  against a real target returns either a conforming estimate-record string or a
  `REFUSED:` string. Layer 2 (trigger) does not apply — agents have no
  description-vs-query match to verify.
- **Scenario shape**: the structural `Then` asserts the tool boundary and the
  charter/refusal sections; the behavioural `Then` asserts that a dispatch
  returns a record conforming to the S1 format (or a `REFUSED:` string on an
  ungroundable target), with no verdict/recommendation field or prose.
- **Modification or new?** new — `agents/cost-estimator.agent.md`. **Plus a
  backward-compatible modification** of the S1 format reference for O6 (§6.1) —
  its existing scenario(s) are updated to cover the additive sub-field.
- **Scenario vs finding**: scenario only — every assertion is falsifiable (tool
  boundary, returned-string shape, refusal on ungroundable input, no-verdict).

## 9. User stories and acceptance scenarios

### 9.1 Story — the agent is a read-only emitter, never a writer or decider

**As** a human who must stay in the disposition seat
**I want** the cost-estimator to be read-only by tool boundary and to return its
record as a string
**So that** no agent can persist an estimate or smuggle in a go/no-go, and the
human disposition the disclosure contract depends on cannot be bypassed.

```gherkin
Given ai-literacy-superpowers/agents/cost-estimator.agent.md
When I read its frontmatter and charter
Then its tools are exactly Read, Glob, Grep — no Write, no Edit, no Bash
And the charter states the agent returns the estimate-record content as a string
And the charter states the agent does not write the record, does not name where
    it is persisted, and does not validate it — those are a dispatcher's job
And the charter states the agent never decides go/no-go and never picks a
    confidence label as a verdict
And the charter references the AGENTS.md agent-emit + dispatcher-persist +
    human-disposes decision and its dispose-then-write ordering invariant
```

### 9.2 Story — the agent emits a conforming estimate record against a real target

**As** a dispatcher (S3 command / S4 orchestrator) that will write the record
**I want** the agent to return a string conforming to the S1 estimate-record
format
**So that** I can persist it and run the S1 validation checkpoint without
post-processing.

```gherkin
Given the cost-estimator agent dispatched against a real spec target
And MODEL_ROUTING.md is readable and observability/costs/ is empty (today's default)
When the agent runs to completion
Then it returns a markdown string with YAML frontmatter and a four-part prose body
And the frontmatter conforms to the S1 estimate-record field set
And target_kind is "spec" and the tokens/time confidence axes are within the
    spec ceiling (at most high)
And cost_usd and cost_basis are omitted (no snapshot), the omission disclosed in
    the Excluded section
And the confidence object carries tokens and time axes but no cost axis
And the returned string contains no recommendation, verdict, proceed, or go/no-go
    field or prose
```

### 9.3 Story — `target_kind` is classified, driving the confidence ceiling

**As** a human reading the estimate
**I want** the agent to classify the target into the correct `target_kind` and
honour the S1 confidence ceiling
**So that** a raw-text estimate can never claim `high` token confidence and a
spec-grounded one can.

```gherkin
Given the cost-estimator agent
When it is dispatched against raw task text with no path and no stated kind
Then it classifies target_kind as task-text
And the tokens and time confidence axes are capped at low

When it is dispatched against a carpaccio slicing record file
Then it classifies target_kind as slicing-record
And the tokens and time confidence axes are capped at most medium

When it is dispatched against a spec file
Then it classifies target_kind as spec
And the tokens and time confidence axes may reach high
```

### 9.4 Story — an ambiguous target is disclosed, never silently up-classified

**As** a human trusting the confidence ceiling
**I want** an ambiguous classification resolved conservatively and disclosed
**So that** the agent cannot quietly claim the higher ceiling on an unclear
target.

```gherkin
Given the cost-estimator agent dispatched against a path whose shape matches
    neither a clear slicing record nor a clear spec, with no stated kind
When the agent classifies the target
Then it resolves to the lower-grounding candidate kind
And the Confidence rationale section discloses the classification ambiguity
And the tokens/time confidence axes do not exceed the lower candidate's ceiling
```

### 9.5 Story — the agent refuses rather than fabricating an ungroundable estimate

**As** a dispatcher
**I want** a stable refusal string when the agent cannot ground an estimate
**So that** I can detect it and decline to persist a fabricated record.

```gherkin
Given the cost-estimator agent dispatched against an unreadable target path
    (or one where MODEL_ROUTING.md cannot be read)
When the agent runs
Then it returns a string beginning with "REFUSED:"
And the refusal names the reason, the target, and what grounding was/was not readable
And the refusal states no estimate record should be written
And the agent does not return a fabricated estimate record
```

### 9.6 Story — an empty cost snapshot is emitted, not refused

**As** a human running the estimator on today's repo (empty `observability/costs/`)
**I want** a valid cost-omitted record, not a refusal
**So that** I get a grounded token + time estimate plus an honest "cost not yet
knowable", per the S1 three grounding states.

```gherkin
Given the cost-estimator agent dispatched against a valid spec target
And MODEL_ROUTING.md is readable but observability/costs/ is empty
When the agent runs
Then it returns a valid cost-omitted estimate record (NOT a REFUSED string)
And cost_usd and cost_basis are omitted with the omission disclosed in Excluded
And tokens and agent_compute_time are produced as ranges
And human_gate_time is produced as its qualitative caveat string
```

### 9.7 Story — split-tier widening is verifiable on a cost-present record (O6)

**As** a validator (the S3 command's checkpoint)
**I want** the split-tier widening to be machine-checkable on the emitted record
**So that** I can assert the implementer band genuinely spans two model rates,
not collapse to one.

```gherkin
Given the cost-estimator agent dispatched against a target with a usable snapshot
When it emits a cost-present record
Then each tokens_by_stage entry carries an optional cost_usd {low, high} range
And the per-stage cost_usd is present iff the top-level cost_usd is present
And for the implementer (Standard/Capable) stage, cost_usd.low is priced at the
    claude-sonnet-4 rate and cost_usd.high at the claude-opus-4 rate, so low < high
And the S1 format reference's per-stage cost_usd sub-field is optional and
    additive, so records without it remain valid (backward compatible)
```

### 9.8 Story — the agent re-verifies the binding against reality at cost time (O3)

**As** a human relying on a cost figure
**I want** the agent to detect binding-table drift and degrade to cost-omission
rather than price against a stale binding
**So that** a confident-looking cost is never emitted against a binding that no
longer matches MODEL_ROUTING.md or the snapshot.

```gherkin
Given the cost-estimator agent computing a cost figure
When the snapshot Model Breakdown lacks a representative model key the binding
    table names (e.g. claude-opus-4 absent)
Then the agent omits cost_usd with a disclosure naming the missing key as the cause
And it does not invent a substitute rate

When MODEL_ROUTING.md carries a tier the binding table does not map
Then the agent discloses the unmapped tier in Confidence rationale
And it does not invent a binding for it; if the tier is load-bearing it omits
    cost_usd with disclosure
```

### 9.9 Story — the blended-rate skew is surfaced on cost-bearing records (O4/O2)

**As** a human reading a cost figure
**I want** the agent to surface the input/output blended-rate simplification on
the record
**So that** I read the cost as the simplified prediction it is, not as a precise
figure.

```gherkin
Given the cost-estimator agent emitting a cost-present record
When I read its disclosure body
Then the Confidence rationale or Included section names that the $/token rate is
    a single blended figure (input and output collapsed) from the snapshot quarter
And it states the figure skews when the task's input/output ratio diverges from
    the snapshot quarter's
And the failure_direction reasoning accounts for the blended-rate skew
And the agent does not reintroduce a per-direction rate
```

### 9.10 Story — the MODEL_ROUTING row and version reflect the new agent

**As** the marketplace consumer and the orchestrator dispatcher
**I want** the new agent to have a routing tier and the plugin version to bump
**So that** dispatch routing is defined and caches/version checks know the plugin
changed.

```gherkin
Given the merged main on this PR
When I read MODEL_ROUTING.md
Then it has an Agent Routing row for cost-estimator at the Standard tier

When I read ai-literacy-superpowers/.claude-plugin/plugin.json
Then the version is "0.42.0"
And the ai-literacy-superpowers entry in .claude-plugin/marketplace.json shows "0.42.0"
And plugin_version in .claude-plugin/marketplace.json is "0.42.0"
And the top-level marketplace version is unchanged at "0.4.0"
And CHANGELOG.md has a new "## 0.42.0 — 2026-06-11" entry
And README.md shows the v0.42.0 badge
```

## 10. Functional requirements

The requirements flow from the scenarios above and are numbered for the FR
mapping table in the plan.

- **FR-1** The agent ships at `ai-literacy-superpowers/agents/cost-estimator.agent.md`
  with well-formed frontmatter and a tool boundary of **exactly** `Read, Glob,
  Grep` (no `Write`, no `Edit`, no `Bash`).
- **FR-2** The charter states the agent **emits** the estimate-record content as
  a returned string, **never writes** the record, never names its on-disk
  location, never validates it, and never decides go/no-go or picks a confidence
  label as a verdict; it references the AGENTS.md agent-emit + dispatcher-persist
  + human-disposes decision and its dispose-then-write ordering invariant.
- **FR-3** The agent loads the S1 `cost-estimation` SKILL.md as reasoning context
  and emits a record conforming to the S1 `estimate-record-format.md`, referenced
  by path and **not redefined**.
- **FR-4** The agent accepts the four target types (raw task text, slicing
  record, slice, spec) and classifies each into the S1 `target_kind` enum per a
  defined classification rule (explicit kind → content inference →
  task-text default).
- **FR-5** The classified `target_kind` drives the S1 confidence ceiling for the
  `tokens`/`time` axes (`task-text` → `low`; `slicing-record`/`slice` →
  `medium`; `spec` → `high`); the agent never exceeds the ceiling.
- **FR-6** An **ambiguous** classification resolves to the **lower-grounding**
  candidate and is **disclosed** in the `Confidence rationale`; it is never
  silently up-classified.
- **FR-7** When the target is **unreadable**, **unclassifiable**, or the
  **token grounding (`MODEL_ROUTING.md`) is absent**, the agent returns a
  **refusal string** with a stable `REFUSED:` prefix naming the reason, the
  target, and the grounding read — and **does not fabricate** a record.
- **FR-8** An **empty `observability/costs/`** (no cost snapshot) is **not** a
  refusal: the agent emits a valid **cost-omitted** record (per the S1 three
  grounding states), with the omission disclosed in `Excluded`.
- **FR-9** (**O6, fold-in**) The S1 format reference gains a **backward-compatible
  optional** `tokens_by_stage[].cost_usd` `{low, high}` sub-field, present **iff**
  the top-level `cost_usd` is present; the agent populates it on cost-present
  records so the split-tier widening is machine-verifiable. Records without the
  sub-field remain valid.
- **FR-10** (**O3, fold-in**) At cost time the agent **re-verifies** the binding
  table's tiers against `MODEL_ROUTING.md` and its representative model keys
  against the snapshot Model Breakdown; on drift it **degrades to
  cost-omission-with-disclosure** (naming the cause) rather than pricing against a
  stale binding, and it never edits the binding table.
- **FR-11** (**O4/O2, fold-in**) On **cost-present** records the agent **surfaces
  the blended input/output rate skew** in the disclosure body and accounts for it
  in `failure_direction`; it never reintroduces a per-direction rate.
- **FR-12** The emitted record carries **no** verdict/recommendation/proceed
  field and **no** imperative recommendation or go/no-go prose (the agent honours
  the S1 two-layer no-verdict guarantee).
- **FR-13** `MODEL_ROUTING.md` gains an Agent Routing row for `cost-estimator` at
  the **Standard** tier.
- **FR-14** A TDAD scenario set (structural + behavioural) covers the agent under
  `tdad_tests/scenarios/agents/cost-estimator/`; the O6 format-reference change
  updates the existing S1 skill scenario(s).
- **FR-15** The plugin version bumps to **0.42.0** across plugin.json,
  marketplace.json (`version` + `plugin_version`), CHANGELOG, and README.
- **FR-16** A docs touch ships: a reference-page entry for the new agent and a
  how-to/explanation page (or extension) describing the prospective-cost emitter,
  satisfying the docs-reference-parity CI check.

## 11. Compatibility and rollout

- **Backwards compatibility**: additive. The new agent file changes no existing
  component's behaviour. The one change to an existing artefact — the O6
  `tokens_by_stage[].cost_usd` sub-field on the S1 format reference — is
  **optional and additive**, so every S1-conforming record stays valid and the
  S3 command's future checkpoint reading the reference is unaffected by absence of
  the sub-field.
- **No consumer wired yet**: no command or orchestrator dispatches the agent in
  this slice (S3/S4). The agent is exercised by its behavioural TDAD scenario
  (a direct dispatch), not by a shipped surface — the same way carpaccio's
  scenarios exercise it before the orchestrator wiring is read.
- **Cache behaviour**: `sync-marketplace-cache.sh` fires (`plugin_version` bump);
  `sync-to-global-cache.sh` rsyncs the new agent into the versioned cache.
- **CI gates**: spec-first is satisfied by this spec as the first commit. Version
  consistency is satisfied (0.42.0 across plugin.json / marketplace entry /
  `plugin_version`). The TDAD-scenario-presence constraint fires (new agent file)
  and is satisfied by §8/§FR-14. The docs-reference-parity constraint fires (new
  agent) and is satisfied by FR-16.

## 12. Docs site

Per the CLAUDE.md Docs Site Review convention, a new agent warrants a docs touch:

- A **reference** entry for the `cost-estimator` agent (its charter, tool
  boundary, input/target contract, refusal convention) under
  `docs/plugins/ai-literacy-superpowers/reference/`.
- A **how-to or explanation** touch: extend the existing
  `explanation/prospective-cost-estimation.md` page (or add a how-to) to describe
  the read-only emitter and the emit-not-write + refusal discipline, linking the
  S1 skill and format reference. The plan fixes which.

## 13. Open questions resolved during design

| Question | Decision |
| --- | --- |
| Tool boundary | `Read, Glob, Grep` only — no Write/Edit/Bash. The mechanism, not a limitation. (§3.2, FR-1) |
| Does the agent write the record? | **No.** It returns a string; a dispatcher (S3/S4, out of scope) persists it after a human disposes. (§5.1, FR-2) |
| What targets does it accept? | Raw task text, a slicing record, a single slice, a spec — one per dispatch. (§4.1) |
| How is `target_kind` classified? | Explicit kind in dispatch → content inference from a path → `task-text` default; ambiguity resolves to the lower-grounding kind and is disclosed. (§4.2, FR-4/FR-6) |
| Behaviour on unreadable/ungroundable target | A `REFUSED:` string (stable prefix), never a fabricated record. (§5.2, FR-7) |
| Behaviour on empty `observability/costs/` | Emit a valid cost-omitted record — **not** a refusal. (§5.3, FR-8) |
| O6 (widening not machine-checkable) | **Fold in** — add backward-compatible optional `tokens_by_stage[].cost_usd`; verifiable on cost-present records. (§6.1, FR-9) |
| O3 (binding-table drift) | **Fold in** — agent re-verifies tiers + model keys at cost time, degrades to cost-omission-with-disclosure on drift, never edits the binding. (§6.2, FR-10) |
| O4/O2 (blended-rate skew) | **Fold in** — agent surfaces the skew in disclosure + failure_direction of cost-bearing records; never reintroduces per-direction rates. (§6.3, FR-11) |
| Model tier | **Standard** — read-and-author against a fixed methodology, not deep judgment. (§7, FR-13) |
| Version bump | 0.41.0 → 0.42.0 (new agent, minor). (§9.10, FR-15) |
| TDAD layers | structural + behavioural (agent has an assertable returned-string side-effect). (§8, FR-14) |

## 14. References

- Slicing record: `docs/superpowers/slices/cost-estimator-pipeline.md` (slice S2).
- S1 spec: `docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md`.
- S1 skill (load as reasoning context):
  `ai-literacy-superpowers/skills/cost-estimation/SKILL.md`.
- S1 format reference (emit a conforming record; O6 adds a backward-compatible
  field here): `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`.
- Downstream issues: S3 #370, S4 #371, S5 #372, S6 #373.
- Governing decisions: AGENTS.md ARCH_DECISIONS — **"agent-emit +
  dispatcher-persist + human-disposes"** (tool boundary + dispose-then-write
  ordering invariant) and **"disclosure-of-derived-judgment"** (the four-part
  disclosure the agent populates).
- Read-only-emitter precedents: `ai-literacy-superpowers/agents/advocatus-diaboli.agent.md`,
  `ai-literacy-superpowers/agents/choice-cartographer.agent.md`,
  `model-cards/agents/model-card-researcher.agent.md` (the `REFUSED:` precedent).
- Grounding source: `MODEL_ROUTING.md` (Token Budget Guidance + Agent Routing).
- Grounding source: `observability/costs/YYYY-MM-DD-costs.md` (none yet).
- Component-design methodology:
  `ai-literacy-superpowers/skills/component-design-with-tdad/SKILL.md`.
- `CLAUDE.md` — Semantic Versioning, Marketplace Versioning, Output Validation
  Checkpoints, and Docs Site Review sections.
