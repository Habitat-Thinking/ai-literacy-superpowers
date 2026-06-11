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
| Sibling slice (split out at revision) | **#377 — format-revision slice (per-stage `cost_usd` sub-field)** — out of scope here; gets its own diaboli pass |
| Revision | This is a **revision** pass: advocatus-diaboli (spec mode) raised O1–O10; all accepted. The central change is that S2 reverts to consuming the S1 format reference **exactly as-merged, with no mutation** — the per-stage `cost_usd` sub-field is split out to #377. See §6 for the per-objection dispositions. |
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
   An **inferred** (non-explicit) classification must disclose its inference
   basis so a confident mis-read is human-catchable (§4.2, O6).
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
  `estimate-record-format.md` **exactly as-merged** (referenced by path, **not**
  redefined and **not** extended — see §2.3).
- The agent's **input/target contract**: the accepted target types and the
  `target_kind` classification rule, including the **inference-basis disclosure**
  for any inferred classification (§4).
- The agent's **emit-not-write discipline** and **refusal-string convention**
  for ungroundable or unreadable targets, including the **mechanical
  cost-omission rule** and the **`MODEL_ROUTING.md`-tables-missing refusal
  trigger** (§5).
- The **deferred-from-S1 behaviour-only residual decisions** (O3, O4) resolved
  (§6) as agent obligations. The third S1 residual — the per-stage `cost_usd`
  format change formerly folded in here — is **split out to #377** (a dedicated
  format-revision slice) and is **out of scope**. S2 makes **no** change to the
  S1 format reference.
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
- **#377 — format-revision slice (per-stage `cost_usd` sub-field)** (split out at
  this revision). The optional `tokens_by_stage[].cost_usd` sub-field — which
  would make the split-tier widening machine-checkable on an emitted record — is
  a **mutation of the merged S1 format reference**, and a slice that *owns* the
  contract is the right home for it (consumer/owner separation; O1/O2/O8). #377
  gets its own diaboli pass, where the backward-compatibility claim is
  **demonstrated against a strict S1-era validator, not asserted**. S2 makes no
  change to `estimate-record-format.md` and emits against it exactly as-merged.
  S2 prices the split-tier widening into the whole-record `cost_usd` band and
  discloses it in prose (the S1 reference already documents the widening in
  methodology prose); the *machine-checkable per-stage band* is #377's
  deliverable, not S2's.

This spec must not let any consumer leak into S2. If a reviewer finds the agent
charter naming *which command writes its output*, *which gate surfaces its
fields*, or *where on disk the record lands*, that is scope creep into S3–S5 and
should be cut back to "a dispatcher does X" without naming the dispatcher's
mechanics.

### 2.3 What S2 consumes from S1 (do not redefine)

S2 is a **pure consumer** of the S1 contract. It does **not** redefine, extend,
or otherwise mutate the estimate record — **full stop, no exception**.
Specifically:

- The **field set, range rules, time split, per-axis confidence, binding table,
  three grounding states, validation checklist, and worked examples** live in
  `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`.
  The agent **references that file by path** and emits a record conforming to it
  **exactly as-merged**. S2 adds no field, removes no field, and changes no
  validation rule. (The per-stage `cost_usd` sub-field that an earlier draft
  folded in here is split out to the #377 format-revision slice — see §2.2 and
  §6.) If a reviewer finds this spec adding or widening anything in
  `estimate-record-format.md`, that is a defect to cut: S2 is read-and-emit
  against the contract as it stands.
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

**Inference-basis disclosure (O6 — catching the confident mis-read).** The
ambiguity safeguard above only fires when the agent *recognises* the target as
ambiguous. A confident single-shape match that is *wrong* (e.g. a slicing record
whose frontmatter superficially matches the spec heuristic) would otherwise
up-classify the ceiling silently. To make a confident mis-read human-catchable,
the spec adds a blanket rule:

- **On any INFERRED (non-explicit) `target_kind` classification** — i.e.
  whenever the kind came from content inference (rule 2) or the `task-text`
  default (rule 3), *not* from an explicit dispatch-stated kind (rule 1) — the
  agent **discloses the inference basis** in the `Confidence rationale` body,
  naming the signal it classified on. Form: *"classified as `<kind>` by
  `<signal>`"* (e.g. *"classified as `spec` by: a `## N.` numbered-section
  header table and a Gherkin acceptance-scenario block"*). This holds even when
  the agent is confident and detects no ambiguity — the disclosure is what makes
  a confident wrong classification (which up-classifies the ceiling) visible to
  the human reading the record, rather than presenting the ceiling as fact.
- **An explicit (dispatch-stated) `target_kind` needs no such disclosure** — the
  dispatcher asserted the kind, so there is no agent inference to expose. The
  inference-basis line is required only when the kind is the agent's own derived
  judgment, consistent with the disclosure-of-derived-judgment contract (a
  *supplied* kind cannot be the agent's mis-read; a *derived* one can).

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
2. **The token grounding is absent — `MODEL_ROUTING.md` cannot be read** (the
   file does not resolve). The token and tier grounding is the day-one
   deliverable; without it there is no honest estimate, only a guess.
3. **The token grounding is present-but-unparseable (O5)** —
   `MODEL_ROUTING.md` **reads as a file** but its **Token Budget Guidance**
   and/or **Agent Routing** tables (the two tables the S1 methodology consumes,
   SKILL.md) are **missing or unparseable**. This is a *third* state distinct
   from both trigger 2 (file unreadable) and the empty-`observability/costs/`
   case (§5.3): the file exists and reads, but yields **no token grounding**, so
   any token range would be fabricated. **No token grounding = no honest
   estimate**, so the agent **REFUSES** rather than emitting a record with
   invented token figures. (Contrast §5.3: a missing *cost snapshot* still
   leaves the token grounding intact, so that case is cost-omitted, **not**
   refused. The dividing line is the token grounding: present-and-parseable →
   emit; absent or unparseable → refuse.)
4. **The target is unclassifiable** — it matches no `target_kind` shape and
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
for an **unreadable/unclassifiable target or absent/unparseable token grounding**
(`MODEL_ROUTING.md`, §5.2 triggers 2–3), never for an honestly-omittable cost
figure. Conflating the two would make the agent refuse on every estimate in
today's repo, which is the opposite of the S1 "no-cost case is honest, not a
failure" decision.

#### The cost-omitted `grounding_sources` cost-snapshot entry (O7)

The S1 format reference requires each record to carry, at minimum, a
`model-routing` grounding entry **and** a `cost-snapshot` grounding entry, each
with a `path` string. On today's default (empty `observability/costs/`) there is
**no snapshot file** to cite — so the spec must fix what the mandatory
`cost-snapshot` entry's `path` holds, rather than leaving it to the implementer.

**Convention (the day-one-default record):** when no snapshot file exists, the
agent emits the `cost-snapshot` grounding entry with its `path` set to the
**directory** `observability/costs/` (with a trailing slash, marking it as a
directory rather than a file) and notes in the `Excluded` prose that the
directory was read and held no snapshot. This is **one defined shape**: the
mandatory entry is *present* (satisfying the S1 "at minimum a cost-snapshot
entry" rule) and points at the directory the agent actually inspected, and the
absence of a concrete snapshot is disclosed in prose. The entry is **never
dropped** and **never given a fabricated file path**. This matches the S1 worked
Example 1, which already sets the empty-case cost-snapshot path to the directory
`observability/costs/`.

**Conflict flag (do not resolve here):** the S1 reference's field table calls
each `grounding_sources` entry a `path` and Example 1 uses a directory path for
the empty case, so the directory-path convention is *consistent with* the S1
reference as-merged. If a stricter reading of "path" as "file path only" is
later enforced by a validator, that is a **tension in the S1 reference itself**,
not something S2 may fix (S2 does not touch the reference — §2.3). Flag it for
**#377** (which owns the format) if it surfaces; S2 follows the as-merged
reference and its Example 1 precedent.

### 5.4 `generated_by` provenance — the honest-placeholder convention (O3)

The S1 format reference makes `generated_by` a **required** field carrying an
"agent name + model identifier" (its example is `cost-estimator /
claude-opus-4-8`). But the agent runs `model: inherit` (§7) and is **never told
its resolved concrete model** at emit time. Mandating a concrete model id the
agent cannot honestly know would force it to guess or hard-code one — fabricating
provenance, the exact failure the refusal discipline exists to prevent. The spec
resolves the provenance seam **honestly** with a two-branch convention:

- **(a) Resolved model id supplied → record it.** IF the dispatcher passes the
  **resolved model id** into the dispatch context (an explicit field the
  dispatching command/orchestrator may include), the agent records
  `generated_by: cost-estimator / <resolved-model-id>`. This is the preferred
  branch; whether the dispatcher supplies it is the dispatcher's (S3/S4) choice,
  out of scope here — S2 only states that *if* it is supplied, the agent uses it
  verbatim.
- **(b) Resolved model id not supplied → record the routing TIER label, never a
  guess.** When the concrete model is unknown to the agent (the default, since
  `model: inherit` does not surface the resolved id), the agent records the
  **routing tier** it was specced at instead of a model string:
  `generated_by: cost-estimator / tier:Standard`. The `tier:` prefix marks the
  value as a routing-tier label, not a concrete model — an honest "this is the
  tier I run at; the concrete model was not surfaced to me" rather than a
  fabricated id. The tier label is grounded in the `MODEL_ROUTING.md` Agent
  Routing row for `cost-estimator` (§7), which the agent reads anyway.

The agent **never** emits a guessed or hard-coded concrete model string (it must
not inherit the worked-example's `claude-opus-4-8` as if it were its own
provenance). The choice between (a) and (b) is mechanical: supplied id present →
(a); absent → (b). Both branches produce an honest `generated_by`; neither
fabricates. (This is the disclosure-of-derived-judgment contract applied to the
provenance field itself: provenance the agent cannot verify is disclosed as a
tier label, not asserted as a concrete model.)

## 6. The deferred-from-S1 residual decisions

S1's reviews left three items tagged for S2. At this **revision** the residuals
split: the two **behaviour-only** residuals (binding-drift re-verification and
blended-rate skew) stay folded into S2 as agent obligations; the **format
mutation** residual (the per-stage `cost_usd` sub-field) is **split out to a
dedicated format-revision slice (#377)** so the contract change gets its own
adversarial pass rather than riding the emitter slice's review. This resolves
O1 (no backward-reach into the merged contract), O2 (the backward-compat claim
is *demonstrated* in #377, not asserted here), and O8 (the consumer/owner
boundary is kept clean).

### 6.1 Per-stage `cost_usd` sub-field — **SPLIT OUT to #377 (was O6 fold-in)**

**Residual:** S1's split-tier widening (the implementer's `Standard/Capable`
priced low at `claude-sonnet-4`, high at `claude-opus-4`) is demonstrated only
in prose and a worked example — it is not machine-checkable on an emitted
record, because `tokens_by_stage[]` carries no per-stage cost.

**Decision (revised): SPLIT OUT, do not fold in.** The earlier draft added an
optional `tokens_by_stage[].cost_usd` sub-field to the S1 format reference from
inside this emitter slice. The diaboli (O1/O2/O8, all accepted) showed this:

- **crosses the slice boundary** S2 polices strictly elsewhere — S2 is a
  *consumer* of a merged, "stable contract" reference, and an emitter granting
  itself a unilateral mutation of the upstream contract is the asymmetry O1
  names;
- ships a **backward-compatibility claim that is asserted, not demonstrated**
  against a strict S1-era validator (O2) — an `iff`-coupled conditional field is
  *not* trivially additive against a closed-world validator;
- **bundles a contract mutation with pure emitter behaviour** (O8), so the
  format change would ride the agent slice's review instead of getting a focused
  pass on the contract change itself.

The sub-field therefore moves to its own slice, **filed as issue #377
("format-revision slice — per-stage `cost_usd` sub-field")**, whose decision
focus *is* the format. #377 runs its own diaboli pass and **demonstrates**
backward-compatibility (against the actual validation-checklist semantics — e.g.
the existing closed-world `cost_usd`/`cost_basis` pairing check), rather than
asserting it.

**What S2 does instead (no contract change):** S2 emits against the S1 format
**exactly as-merged**. The split-tier widening is still honoured — the agent
prices the slashed-tier (`Standard/Capable`) stage's cost contribution across the
two representative rates (`claude-sonnet-4` low, `claude-opus-4` high) and lets
that widen the **whole-record `cost_usd` band**, and it **discloses the widening
in the prose body** (the S1 reference already documents the widening in
methodology prose, so this is consumption, not extension). What S2 does **not**
emit is a *machine-checkable per-stage* `cost_usd` band — that is #377's
deliverable. S2 makes **no** edit to `estimate-record-format.md`, touches **no**
worked example, and adds **no** validation-checklist line.

### 6.2 O3 + O4 — binding-table drift → **mechanical cost-omission** (FOLD IN, as a mechanical agent obligation)

**Residual:** should the agent re-verify the tier→model binding (the S1 binding
table) against `MODEL_ROUTING.md`'s tiers and the snapshot's model keys when it
computes cost, rather than trusting the static binding table blindly? And when a
tier is unmapped, on what rule does it omit cost?

**Decision: FOLD IN, as a MECHANICAL agent obligation.** The earlier draft told
the agent to omit `cost_usd` "if that tier is **load-bearing** for the target's
stage set" — a discretionary judgment the agent would make about whether a tier
"matters." O4 (accepted) showed that this is exactly where an emit-not-decide
agent quietly becomes a decider: "load-bearing" is undefined, and choosing which
record shape to emit on the agent's own read of it is a derived decision the tool
boundary cannot constrain. **The discretionary "load-bearing" test is removed.**
The rule is now mechanical — **no agent judgment about whether a tier matters**:

When the agent computes a cost figure (state 3 — a usable snapshot exists), it
MUST:

1. **Tier-mapping check.** Confirm every tier exercised by the target's stage set
   (the `model_tier` of each `tokens_by_stage[]` entry the target actually
   exercises — including each side of a `Standard/Capable` split) is **mapped by
   the S1 binding table**. The mapped/unmapped test **applies the S1 join-key
   normalisation** defined in `estimate-record-format.md` (stage/tier
   normalisation, lines 153-158) **before** deciding a tier is unmapped: strip the
   `{{LANGUAGE}}-` prefix from the stage name, and compare tier labels
   **whitespace-insensitively** (so `Standard/Capable` ↔ `Standard / Capable`). A
   literal-string match is **not** sufficient — without the normalisation a
   correctly-mapped split tier (the implementer stage, the dominant cost driver in
   both S1 worked examples) would be falsely reported unmapped on a spacing
   mismatch and cost over-omitted. The mechanical omission rule:

   > **The agent omits `cost_usd` (emits a cost-omitted record with disclosure)
   > whenever ANY exercised stage's tier is unmapped by the binding table — or
   > otherwise ungrounded.** No judgment about whether the unmapped tier is
   > "load-bearing."

   On omission, the agent **discloses the unmapped tier(s) in `Confidence
   rationale`** and names them in `Excluded` as the omission cause. The agent
   does **not** invent a binding for an unmapped tier.

2. **Model-key check.** Confirm the representative model keys the binding table
   names (`claude-opus-4`, `claude-sonnet-4`) exist in the snapshot's Model
   Breakdown. A missing key is the same mechanical trigger as an unmapped tier:
   the binding is **ungrounded**, so the agent **omits `cost_usd` with
   disclosure** (the S1 **state 2**), naming the missing key as the cause. It
   does **not** invent a substitute rate.

This is bounded: the agent **does not edit** the binding table (it has no write
tool, and the binding table is the named S6-revisable artefact, not agent
judgement). It only **detects an ungrounded binding by a mechanical test and
degrades to cost-omission**, disclosing the cause. The agent stays
**emit-not-decide**: the only branch is "is every exercised tier mapped and every
named key present?" — a yes/no check, not a judgment about salience. This keeps
the binding "named, not agent discretion" (the S1 O5 decision) while making the
agent honest when the named binding no longer matches reality.

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

**Precedence rule when drivers conflict (O10).** `failure_direction` is a single
enum (`likely-overrun | likely-underrun | symmetric`), but multiple drivers can
point in opposite directions — e.g. the blended-rate skew may lean
`likely-underrun` (output-heavy task) while the upper-tier-default budgets lean
`likely-overrun` (most slices land below the per-stage budget ceilings, the
driver the S1 cost-present worked example uses). The spec fixes the
reconciliation:

- The prose body **names every driver** that bears on the direction (the
  blended-rate skew *and* the budget-default driver *and* any other), each with
  the direction it pushes.
- The single enum is set to the **larger-magnitude effect** — the driver the
  agent judges dominates the figure. If the agent judges the drivers
  roughly equal and opposite (no clear dominant), the enum is `symmetric`, with
  the prose naming both opposing drivers as the reason for the symmetric call.

This keeps the machine-readable `failure_direction` consistent with the prose:
the enum is never a coin-flip between conflicting signals — it is the dominant
driver, with the full driver set disclosed in prose so the human can see what was
reconciled.

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
| Per-stage `cost_usd` — widening not machine-checkable | code-mode | **Split out → #377** | A format mutation; moved to a dedicated format-revision slice with its own diaboli pass that *demonstrates* backward-compat. S2 makes no change to the format reference; it prices the widening into the whole-record `cost_usd` band and discloses it in prose |
| O3 + O4 — binding-table drift | spec-mode | **Fold in (mechanical)** | Agent re-verifies exercised tiers + named model keys at cost time; **omits `cost_usd` whenever ANY exercised stage's tier is unmapped or otherwise ungrounded** (mechanical — no "load-bearing" judgment); discloses the cause; never edits the binding |
| O4/O2 — blended-rate skew | spec/code-mode | **Fold in (disclosure)** | Agent surfaces the blended-rate skew in the disclosure + `failure_direction` of cost-bearing records; conflicting drivers reconciled by the larger-magnitude precedence rule (O10); never reintroduces per-direction rates |

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

**Provenance consequence (O3):** because the agent runs `model: inherit` and is
not told its resolved concrete model, the `generated_by` field cannot honestly
carry a concrete model id unless the dispatcher supplies one. Per §5.4, the agent
records the resolved model id **if the dispatcher passes it**, and otherwise
records the routing-tier label `tier:Standard` (grounded in this very
MODEL_ROUTING.md row) — never a guessed or hard-coded model string. The tier
label here in §7 is the honest fallback `generated_by` value.

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
- **Behavioural grading strategy (O9) — how a non-deterministic dispatch is
  graded honestly.** The agent is `model: inherit` with no wired consumer, so the
  behavioural scenarios cannot assert exact free-text. They are scoped to
  **deterministically-checkable structural properties of the emitted string**, so
  each scenario can fail honestly:
  - **Conformance oracle.** Parse the returned string's YAML frontmatter and
    assert the **structural** properties of the S1 estimate-record field set:
    required fields present, enum values in range, every present range has
    `low ≤ high`. For `human_gate_time` specifically the oracle asserts only that
    the field is **present** and is **not** a `{low, high}` range — it does **not**
    assert that the caveat's prose *content* is faithful (that human-gate latency
    dominates, etc.), which is a semantic property no structural parse can falsify
    and is therefore out of deterministic-grading scope (see the "Out of scope"
    bullet below). This is a structural parse, not a semantic judgment —
    deterministic.
  - **Presence/absence oracle.** Assert the **presence** of specific fields/prose
    markers a behaviour requires (e.g. `cost_usd` and `cost_basis` *absent* on a
    cost-omitted record; the `Excluded` section *present* and naming the
    omission; the inference-basis line *present* on an inferred classification;
    no `recommendation`/`verdict`/`proceed` key *anywhere*). Presence/absence of
    a named key or a greppable marker is deterministic.
  - **`REFUSED:` prefix oracle.** On ungroundable fixtures (unreadable target,
    `MODEL_ROUTING.md` absent, `MODEL_ROUTING.md` tables missing/unparseable),
    assert the returned string **begins with the `REFUSED:` prefix** and contains
    the named reason/target/grounding fields — and that it is **not** a
    conforming record. The stable prefix is the deterministic hook.
  - **Fixture-driven grounding.** Each behavioural scenario pins its grounding
    inputs (a fixture `MODEL_ROUTING.md`, an empty or populated
    `observability/costs/`, a target file of a known shape) so the *input* is
    deterministic even though the *model* is not; the assertions grade only
    properties that hold across any conforming model output.
  - **Out of scope for grading.** The scenarios do **not** assert the exact token
    *numbers*, the exact prose wording, or the **prose content of
    `human_gate_time`'s qualitative caveat** (all model-dependent semantic
    properties, not deterministically gradeable). For `human_gate_time` the
    oracles assert only its **presence** and that it is **not a `{low, high}`
    range** — never that its caveat says what the S1 field requires. They assert
    *that* a range is present and well-formed, *that* the required disclosure
    markers appear, and *that* the refusal/emit routing is correct — never the
    specific values. A scenario that cannot be graded by one of the oracles above
    is descoped, not rubber-stamped.
- **Scenario shape**: the structural `Then` asserts the tool boundary and the
  charter/refusal sections; the behavioural `Then` asserts that a dispatch
  returns a record conforming to the S1 format (or a `REFUSED:` string on an
  ungroundable target), with no verdict/recommendation field or prose — graded by
  the oracles above.
- **Modification or new?** new — `agents/cost-estimator.agent.md`. **No
  modification of the S1 format reference** — the per-stage `cost_usd` change is
  split out to #377 (§6.1); S2 leaves `estimate-record-format.md` and its
  scenarios untouched.
- **Scenario vs finding**: scenario only — every assertion is falsifiable by one
  of the deterministic oracles above (tool boundary, conformance parse,
  presence/absence of named fields, `REFUSED:` prefix).

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
And the dispatch states target_kind explicitly as "spec"
When the agent runs to completion
Then it returns a markdown string with YAML frontmatter and a four-part prose body
And the frontmatter conforms to the S1 estimate-record field set (parsed, not read loosely)
And target_kind is "spec" and the tokens/time confidence axes are within the
    spec ceiling (at most high)
And cost_usd and cost_basis are omitted (no snapshot), the omission disclosed in
    the Excluded section
And the grounding_sources list carries a cost-snapshot entry whose path is the
    directory "observability/costs/" (no snapshot file existed), per §5.3
And the confidence object carries tokens and time axes but no cost axis
And generated_by is "cost-estimator / tier:Standard" (the dispatch supplied no
    resolved model id, so the routing-tier label is recorded, never a guessed
    model string), per §5.4
And because target_kind was supplied explicitly, no inference-basis line is required
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
And because the kind was inferred (the task-text default), the Confidence
    rationale carries an inference-basis line naming the signal
    (e.g. "classified as task-text by: inline prose, no path, no stated kind")

When it is dispatched against a carpaccio slicing record file with no stated kind
Then it classifies target_kind as slicing-record
And the tokens and time confidence axes are capped at most medium
And because the kind was inferred, the Confidence rationale carries an
    inference-basis line naming the slicing-record signal it matched on

When it is dispatched against a spec file with no stated kind
Then it classifies target_kind as spec
And the tokens and time confidence axes may reach high
And because the kind was inferred, the Confidence rationale carries an
    inference-basis line naming the spec signal it matched on (so a confident
    mis-read that up-classifies the ceiling is human-catchable)
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

# O5 — readable-but-tableless MODEL_ROUTING.md is a refusal, distinct from
# the empty-cost-snapshot (cost-omitted) case
Given the cost-estimator agent dispatched against a valid, readable spec target
And MODEL_ROUTING.md resolves as a file but its Token Budget Guidance and
    Agent Routing tables are missing or unparseable
When the agent runs
Then it returns a string beginning with "REFUSED:" (no token grounding = no
    honest estimate)
And the refusal names that MODEL_ROUTING.md was readable but its required tables
    were missing/unparseable
And the agent does NOT emit a record with fabricated token ranges
And this is explicitly distinguished from the empty-observability/costs/ case,
    which is cost-omitted (§9.6), not refused
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
And the grounding_sources list still carries the mandatory cost-snapshot entry,
    with its path set to the directory "observability/costs/" (no snapshot file
    existed), and the Excluded prose notes the directory held no snapshot (§5.3, O7)
And the cost-snapshot grounding entry is never dropped and never given a
    fabricated snapshot file path
And tokens and agent_compute_time are produced as ranges
And human_gate_time is produced as its qualitative caveat string
```

### 9.7 Story — an inferred classification discloses its basis; an explicit one does not (O6)

**As** a human trusting the confidence ceiling
**I want** every inferred `target_kind` to disclose the signal it classified on,
while an explicit dispatch-stated kind needs no such disclosure
**So that** a confident mis-read that up-classifies the ceiling is catchable,
without noise on kinds the dispatcher asserted.

```gherkin
Given the cost-estimator agent dispatched against a path with no stated kind,
    whose frontmatter the agent confidently (but possibly wrongly) reads as a spec
When the agent classifies and emits a record
Then target_kind is the inferred kind
And the Confidence rationale carries an inference-basis line of the form
    "classified as <kind> by <signal>", naming the concrete signal
And the line is present even though the agent detected no ambiguity (so a
    confident wrong single-match is human-catchable)

Given the same agent dispatched against the same path but with target_kind
    stated explicitly in the dispatch
When the agent classifies and emits a record
Then it uses the stated kind
And no inference-basis line is required (the kind was supplied, not derived)
```

> **Note (was §9.7 widening-verifiable):** the scenario asserting a
> machine-checkable per-stage `cost_usd` band has been **removed from S2** and
> **moved to issue #377** (the format-revision slice that owns the per-stage
> sub-field). S2 makes no change to the S1 format reference, so there is no
> per-stage `cost_usd` field for S2 to assert. S2's split-tier widening is
> priced into the whole-record `cost_usd` band and disclosed in prose only.

### 9.8 Story — the agent omits cost mechanically when any exercised tier is unmapped (O3/O4)

**As** a human relying on a cost figure
**I want** the agent to omit cost by a mechanical rule whenever any exercised
stage's tier is unmapped (or a named model key is missing), with no judgment
about whether the tier "matters"
**So that** a confident-looking cost is never emitted against a binding that no
longer matches MODEL_ROUTING.md or the snapshot, and the agent stays
emit-not-decide.

```gherkin
Given the cost-estimator agent computing a cost figure
When the snapshot Model Breakdown lacks a representative model key the binding
    table names (e.g. claude-opus-4 absent)
Then the agent omits cost_usd with a disclosure naming the missing key as the cause
And it does not invent a substitute rate

When MODEL_ROUTING.md carries a tier the binding table does not map (tested after
    applying the S1 join-key normalisation — prefix-strip + whitespace-insensitive
    tier compare, so Standard/Capable ↔ Standard / Capable), AND that tier is
    exercised by the target's stage set
Then the agent omits cost_usd (cost-omitted record) regardless of whether the
    tier appears "load-bearing" — the rule is mechanical: ANY exercised unmapped
    tier triggers omission
And a correctly-mapped split tier that differs only by tier-label spacing is NOT
    reported unmapped (the normalisation prevents over-omitting cost on the
    implementer split tier)
And the agent discloses the unmapped tier in Confidence rationale and names it in
    Excluded as the omission cause
And it does not invent a binding for the unmapped tier
And the agent makes NO discretionary judgment about whether the tier matters
```

### 9.9 Story — the blended-rate skew is surfaced on cost-bearing records, with a precedence rule on conflict (O4/O2/O10)

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

# O10 — precedence when drivers conflict
Given a cost-present record whose blended-rate skew leans one direction while the
    upper-tier-default budgets lean the opposite direction
When I read the disclosure body and the failure_direction enum
Then the prose names EVERY driver bearing on the direction and the way each pushes
And the single failure_direction enum is set to the larger-magnitude (dominant)
    driver — or "symmetric" when the agent judges the opposing drivers roughly
    equal, with the prose naming both as the reason
And the enum is never inconsistent with the prose (no coin-flip between signals)
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
- **FR-6a** (**O6**) On any **INFERRED** (non-explicit) `target_kind`
  classification — content-inference or the `task-text` default — the agent
  **discloses the inference basis** in the `Confidence rationale` (form:
  *"classified as `<kind>` by `<signal>`"*), even when it detects no ambiguity,
  so a confident mis-read that up-classifies the ceiling is human-catchable. An
  **explicit** dispatch-stated kind needs **no** such disclosure.
- **FR-7** When the target is **unreadable**, **unclassifiable**, the **token
  grounding (`MODEL_ROUTING.md`) is absent**, **or** (**O5**) `MODEL_ROUTING.md`
  is readable but its **Token Budget Guidance / Agent Routing tables are missing
  or unparseable**, the agent returns a **refusal string** with a stable
  `REFUSED:` prefix naming the reason, the target, and the grounding read — and
  **does not fabricate** a record (no token grounding = no honest estimate). This
  is distinct from the empty-`observability/costs/` case (FR-8), which is
  cost-omitted, not refused.
- **FR-8** An **empty `observability/costs/`** (no cost snapshot) is **not** a
  refusal: the agent emits a valid **cost-omitted** record (per the S1 three
  grounding states), with the omission disclosed in `Excluded`.
- **FR-8a** (**O7**) On the cost-omitted (empty-directory) record, the mandatory
  `grounding_sources` `cost-snapshot` entry is **present** with its `path` set to
  the **directory** `observability/costs/` (the directory the agent inspected),
  and the `Excluded` prose notes the directory held no snapshot. The entry is
  **never dropped** and **never given a fabricated snapshot file path**. (This
  follows the as-merged S1 reference and its Example 1; S2 does not modify the
  reference. If a stricter "file-path-only" reading of `path` is later enforced,
  that tension belongs to **#377**, not S2.)
- **FR-8b** (**O3, provenance**) `generated_by` is populated honestly: the agent
  records `cost-estimator / <resolved-model-id>` **iff** the dispatcher supplies
  the resolved model id; otherwise it records the routing-tier label
  `cost-estimator / tier:Standard`. It **never** emits a guessed or hard-coded
  concrete model string. (The agent runs `model: inherit` and is not told its
  resolved model — §5.4, §7.)
- **FR-9** **(SPLIT OUT to #377 — no longer an S2 FR.)** The per-stage
  `tokens_by_stage[].cost_usd` sub-field that an earlier draft folded in here is
  a **mutation of the merged S1 format reference** and is moved to the dedicated
  format-revision slice **#377**, which demonstrates backward-compatibility under
  its own diaboli pass. **S2 makes no change to `estimate-record-format.md`.** S2
  prices the split-tier widening into the **whole-record `cost_usd`** band and
  discloses it in prose; it emits no per-stage cost band.
- **FR-10** (**O3/O4, fold-in — MECHANICAL**) At cost time the agent
  **re-verifies** that every tier exercised by the target's stage set is **mapped
  by the binding table** and that the named representative model keys exist in the
  snapshot Model Breakdown. The mapped/unmapped test **applies the S1 join-key
  normalisation** from `estimate-record-format.md` (strip the `{{LANGUAGE}}-`
  prefix; compare tier labels **whitespace-insensitively**, so `Standard/Capable`
  ↔ `Standard / Capable`) **before** deciding a tier is unmapped — a literal-string
  match is not sufficient, or a correctly-mapped split tier would be over-omitted
  on a spacing mismatch. The omission rule is **mechanical, with no "load-bearing"
  judgment**: the agent **omits `cost_usd` (cost-omitted record with disclosure)
  whenever ANY exercised stage's tier is unmapped (after normalisation) — or
  otherwise ungrounded (a named model key missing)** — naming the cause in
  `Confidence rationale`/`Excluded`. It never invents a binding or a rate, and
  never edits the binding table.
- **FR-11** (**O4/O2, fold-in**) On **cost-present** records the agent **surfaces
  the blended input/output rate skew** in the disclosure body and accounts for it
  in `failure_direction`; it never reintroduces a per-direction rate.
- **FR-11a** (**O10**) When failure-direction drivers conflict, the agent **names
  every driver in prose** and sets the single `failure_direction` enum to the
  **larger-magnitude (dominant)** driver — or `symmetric` when the opposing
  drivers are judged roughly equal — so the enum is never inconsistent with the
  prose.
- **FR-12** The emitted record carries **no** verdict/recommendation/proceed
  field and **no** imperative recommendation or go/no-go prose (the agent honours
  the S1 two-layer no-verdict guarantee).
- **FR-13** `MODEL_ROUTING.md` gains an Agent Routing row for `cost-estimator` at
  the **Standard** tier.
- **FR-14** A TDAD scenario set (structural + behavioural) covers the agent under
  `tdad_tests/scenarios/agents/cost-estimator/`. The behavioural scenarios are
  graded by the **deterministic oracle strategy of §8** (frontmatter conformance
  parse, presence/absence of named fields/markers, `REFUSED:` prefix on
  ungroundable fixtures) so each can **fail honestly** despite the agent being
  non-deterministic (**O9**). **No S1 skill scenario is modified** — the
  per-stage `cost_usd` format change is split out to #377, so
  `estimate-record-format.md` and its scenarios are untouched by S2.
- **FR-15** The plugin version bumps to **0.42.0** across plugin.json,
  marketplace.json (`version` + `plugin_version`), CHANGELOG, and README.
- **FR-16** A docs touch ships: a reference-page entry for the new agent and a
  how-to/explanation page (or extension) describing the prospective-cost emitter,
  satisfying the docs-reference-parity CI check.

## 11. Compatibility and rollout

- **Backwards compatibility**: purely additive — the new agent file changes **no
  existing component's behaviour and touches no existing artefact**. S2 makes
  **no** change to the S1 format reference (the per-stage `cost_usd` sub-field is
  split out to #377). Every S1-conforming record stays valid because S2 emits
  against the contract exactly as-merged; the S3 command's future checkpoint
  reading the reference is unaffected because the reference is unchanged.
- **No consumer wired yet**: no command or orchestrator dispatches the agent in
  this slice (S3/S4). The agent is exercised by its behavioural TDAD scenarios
  (direct dispatches against pinned fixtures), not by a shipped surface — the same
  way carpaccio's scenarios exercise it before the orchestrator wiring is read.
  The behavioural scenarios are made gradeable against a non-deterministic
  `model: inherit` agent by the §8 oracle strategy: fixture-pinned grounding
  inputs plus assertions scoped to deterministic structural properties (frontmatter
  conformance, presence/absence of named fields, `REFUSED:` prefix), never exact
  token numbers or prose wording (**O9**).
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
| Behaviour on unreadable/ungroundable target | A `REFUSED:` string (stable prefix), never a fabricated record — including the O5 readable-but-tableless `MODEL_ROUTING.md` case. (§5.2, FR-7) |
| Behaviour on empty `observability/costs/` | Emit a valid cost-omitted record — **not** a refusal. (§5.3, FR-8) |
| Cost-omitted `grounding_sources` path (O7) | The mandatory `cost-snapshot` entry's `path` is the directory `observability/costs/`; entry never dropped, never a fabricated file path. (§5.3, FR-8a) |
| `generated_by` provenance (O3) | Resolved model id **iff** the dispatcher supplies it; otherwise the routing-tier label `tier:Standard`; never a guessed/hard-coded model string. (§5.4, FR-8b) |
| Per-stage `cost_usd` widening (was O6) | **SPLIT OUT to #377** — a format-reference mutation; gets its own diaboli pass demonstrating backward-compat. S2 changes nothing in the reference and prices the widening into the whole-record band + prose. (§6.1, §2.2, FR-9) |
| Binding-table drift (O3/O4) | **Fold in (mechanical)** — agent re-verifies exercised tiers + named model keys at cost time and **omits `cost_usd` whenever ANY exercised tier is unmapped/ungrounded** (no "load-bearing" judgment); never edits the binding. (§6.2, FR-10) |
| Inference-basis disclosure (O6) | On any inferred `target_kind`, disclose "classified as `<kind>` by `<signal>`" in `Confidence rationale`; explicit kinds need none. (§4.2, FR-6a) |
| O4/O2 (blended-rate skew) | **Fold in** — agent surfaces the skew in disclosure + failure_direction of cost-bearing records; never reintroduces per-direction rates. (§6.3, FR-11) |
| failure_direction on conflict (O10) | Name all drivers in prose; set the enum to the larger-magnitude driver (or `symmetric` when equal). (§6.3, FR-11a) |
| Behavioural grading of a non-deterministic dispatch (O9) | Fixture-pinned grounding + deterministic oracles (conformance parse, presence/absence of named fields, `REFUSED:` prefix); never exact numbers/wording. (§8, FR-14) |
| Model tier | **Standard** — read-and-author against a fixed methodology, not deep judgment. (§7, FR-13) |
| Version bump | 0.41.0 → 0.42.0 (new agent, minor). (§9.10, FR-15) |
| TDAD layers | structural + behavioural (agent has an assertable returned-string side-effect). (§8, FR-14) |

## 14. References

- Slicing record: `docs/superpowers/slices/cost-estimator-pipeline.md` (slice S2).
- S1 spec: `docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md`.
- S1 skill (load as reasoning context):
  `ai-literacy-superpowers/skills/cost-estimation/SKILL.md`.
- S1 format reference (emit a conforming record **exactly as-merged**; S2 makes
  no change here — the per-stage `cost_usd` field is owned by #377):
  `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`.
- Downstream issues: S3 #370, S4 #371, S5 #372, S6 #373.
- Sibling format-revision issue: **#377 — per-stage `cost_usd` sub-field** (split
  out of S2 at this revision; owns the only change to the S1 format reference).
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
