# Cost Estimation — S1 — methodology, estimate-record format, and the disclosure/confidence contract — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-10 |
| Status | Draft |
| Author | spec-writer (interactive session with russmiles) |
| Slice | S1 of the slicing record at `docs/superpowers/slices/cost-estimator-pipeline.md` |
| Progressed slice | S1 (this spec) |
| Downstream slices | S2 (#369), S3 (#370), S4 (#371), S5 (#372), S6 (#373) — all out of scope here |
| Plugin version target | `ai-literacy-superpowers` v0.40.0 → v0.41.0 (new skill — minor bump) |
| Marketplace listing | Top-level `version` unchanged at v0.4.0; `plugin_version` 0.40.0 → 0.41.0 |
| PR ceremony | feature — full `/diaboli` (spec + code) and `/choice-cartograph` |
| Governing decision | AGENTS.md "agent-emit + dispatcher-persist + human-disposes" trust architecture (the pattern S2/S3 inherit). The four-part disclosure body in §5 is a contract THIS SPEC PROPOSES; it is not a pre-existing promoted decision. |

---

## 1. Premise

The plugin already ships a **retrospective** cost capability: the `cost-tracking`
skill and the `/cost-capture` command record actual spend into
`observability/costs/YYYY-MM-DD-costs.md`. This capability is the
**prospective** counterpart — a way to estimate, *before* work runs, the token
usage and the time of a task flowing through the orchestrator pipeline, with a
dollar cost added **only when observed actuals exist to ground it**.

**The day-one deliverable is a token + time estimate.** Both axes are fully
groundable from MODEL_ROUTING.md today (per-stage token budgets and the
agent→model-tier mapping), so they are the honest first-version value of this
capability. The dollar figure is an **actuals-gated enhancement**: it is present
and grounded ONLY when an `observability/costs/` snapshot supplies a usable
$/token rate; otherwise it is **omitted with an explicit disclosure**, not
emitted as a forced-low list-price guess. See §6.2 and §6.4. This is the central
restructure of this revision (resolving objections O2, O3, O4, O11): the dollar
axis is not presented as a first-class day-one deliverable, because on day one
there is no observed spend to ground it.

Before any agent or command can produce an estimate, the system needs a
definition of what an estimate *is*. This slice (S1) is that definition. It
ships exactly three things and nothing else:

1. **The estimation methodology** — how MODEL_ROUTING.md per-stage token
   budgets and the agent→model-tier mapping produce token and time ranges
   today, and how an `observability/costs/` snapshot adds a dollar figure when
   one exists.
2. **The estimate-record format** — the structured markdown artefact a future
   agent (S2) emits and a future command (S3) writes and validates, in which
   `cost_usd` is **conditional, not required** (present-when-grounded).
3. **The disclosure/confidence contract** — the honesty rules the record
   format follows. This four-part contract is **proposed by this spec**; it is
   not a pre-existing promoted AGENTS.md decision (see §5 and O1). It serves the
   real AGENTS.md **"agent-emit + dispatcher-persist + human-disposes" trust
   architecture** that S2 and S3 inherit.

This slice ships a **skill** (`SKILL.md`) and a **format reference file**. It
ships **no agent, no command, and no orchestrator wiring**. Those are S2–S6.
The deliverable is the contract every later slice consumes.

## 2. Scope and non-goals

### 2.1 In scope (S1)

- A new skill at `ai-literacy-superpowers/skills/cost-estimation/SKILL.md`
  describing the methodology and the disclosure contract in prose, for an
  agent to load into context as reasoning guidance.
- A format reference at
  `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`
  defining the estimate-record field set as a stable contract, suitable for a
  downstream command's Output Validation Checkpoint (per the CLAUDE.md
  convention).
- A TDAD scenario covering the skill (structural + trigger layers), authored
  under `tdad_tests/scenarios/skills/cost-estimation/`.
- The plugin version bump, CHANGELOG entry, marketplace `plugin_version`
  pointer update, and README badge — the maintenance steps that attach to any
  new component.

### 2.2 Out of scope (filed as separate issues)

The slicing record (`docs/superpowers/slices/cost-estimator-pipeline.md`)
carpaccio-sliced the whole capability into S1–S6. Only S1 ships here. The
following are explicitly **not** in this PR and are tracked elsewhere:

- **S2 — the read-only `cost-estimator` agent** (#369). No file under
  `ai-literacy-superpowers/agents/` is added by this slice. The skill defines
  what the agent *will* emit; it does not implement the emitter.
- **S3 — the `/cost-estimate` command** (#370). No file under
  `ai-literacy-superpowers/commands/`. The format reference is written to be
  consumable by that command's validation checkpoint, but the command does not
  exist yet.
- **S4 — orchestrator fold-in at T1/T2** (#371). No change to
  `agents/orchestrator.agent.md`. No gate is added, moved, or re-weighted.
- **S5 — T0 pre-carpaccio ballpark** (#372). No pre-step-0 touchpoint.
- **S6 — calibration loop** (#373). No per-PR actuals capture and no
  integration-agent change. S6 is accepted **in-scope for the capability** but
  ships later; S1's only obligation to S6 is to keep the methodology seam open
  (see §7), not to implement calibration.

This spec must not let any consumer leak into S1. If a reviewer finds the skill
describing *who dispatches it*, *which gate it appears in*, or *how a command
writes its output*, that is scope creep into S2–S5 and should be cut back to "a
consumer does X" without naming the consumer's mechanics.

## 3. What IS an estimate in this system (the decision)

The material decision this slice locks: **an estimate is a range with disclosed
confidence, never a point value.** The alternative — a single point figure — is
a different record schema with different downstream-trust properties, and it is
rejected here for the life of the capability.

The reasoning:

- An estimate is a **derived prediction**. The future agent derives a number a
  human would otherwise have guessed or supplied, then emits it for the human to
  dispose — mirroring the AGENTS.md **"agent-emit + dispatcher-persist +
  human-disposes" trust architecture** (the agent emits, the command persists,
  the human decides). Because the agent derives rather than observes, this spec
  proposes a disclosure contract (§5) so the derivation is interrogable: what was
  included, what was excluded, the confidence, and the failure direction. (NOTE:
  the contract is proposed here, not an existing promoted decision — see O1 and
  §5.)
- A point value invites false precision. "12k tokens" reads as fact;
  "10k–18k tokens, confidence medium, more likely to overrun than underrun
  because the implementer stage spans two model tiers" reads as a prediction the
  human can interrogate. The whole point of the capability is to *inform a
  human's choice*, not to anchor it on a number dressed as a fact.
- Locking range-with-confidence as the schema before any consumer is built is
  the cheapest place to honour the disclosure contract. Retrofitting it across
  an agent, a command, and three insertion points (S2–S5) would be expensive.
  This is also why `cost_usd` is made **conditional rather than required** now
  (§4.2, O11): the present-when-grounded shape needs no format change when the
  first actuals snapshot lands, whereas a required low-confidence field would
  bake the weakest axis into the contract.

Every quantitative field in the record is therefore a **range** (`low`–`high`),
and every record carries a confidence tier and the disclosures §5 requires.

## 4. The estimate-record format

The estimate record is the load-bearing deliverable. It is consumed by the S2
agent (emits it), the S3 command (writes and validates it), and the S4
orchestrator fold-in (surfaces fields from it). It must be a stable contract.

### 4.1 Canonical artefact and format

The record is a single markdown file with YAML frontmatter for the
machine-readable fields and a prose body for the disclosures. The canonical
field definitions live in the format reference file (§8.2); this section
defines the field set.

The frontmatter carries the structured fields a downstream validation
checkpoint parses. The body carries the human-readable disclosure prose.

### 4.2 Frontmatter field set

| Field | Type | Required | Purpose |
| --- | --- | --- | --- |
| `target` | string | yes | What was estimated — a path (slicing record, spec) or a short description of pasted task text. |
| `target_kind` | enum | yes | One of `task-text`, `slicing-record`, `slice`, `spec`. Signals the grounding richness available; richer targets warrant higher confidence (§5.2). |
| `generated_at` | string (ISO 8601) | yes | Timestamp the estimate was produced. |
| `generated_by` | string | yes | Agent name + model identifier (e.g. `"cost-estimator / claude-opus-4-8"`). |
| `grounding_sources` | list of objects | yes | The inputs the estimate was built from. Each entry has `path` (string) and `kind` (one of `model-routing`, `cost-snapshot`, `calibration`). At minimum a `model-routing` entry and a `cost-snapshot` entry; a `calibration` entry is permitted but never required (§7). |
| `tokens` | range object | yes | Estimated total token usage as `{ low: int, high: int }`. Low and high are the budget-derived bounds (§6.1). |
| `tokens_by_stage` | list of objects | yes | Per-stage breakdown. Each entry: `stage` (string — spec-writer, tdd-agent, implementer, code-reviewer, integration), `tokens` (range object), `model_tier` (string from the agent→model-tier mapping — may be a split tier such as `Standard/Capable`, see §6.1). May omit stages a target does not exercise; the omission must be reflected in the `excluded` prose (§5). |
| `cost_usd` | range object | **conditional** | Estimated dollar cost as `{ low: float, high: float }`. **Present ONLY when an `observability/costs/` snapshot supplies a usable per-tier $/token rate** (§6.2). When no usable rate exists, the field is **omitted entirely** and the omission is disclosed in the `excluded` section (§6.4). The format must not carry a placeholder, a null, or a forced list-price value. |
| `cost_basis` | enum | conditional | Present **iff** `cost_usd` is present. One of `snapshot-actuals` (rate derived from a snapshot Model Breakdown) — currently the only grounded basis. Records the provenance of the $/token rate so a reader knows the cost is observed, not guessed. |
| `agent_compute_time` | range object | yes | Estimated wall-clock spent in agent execution as `{ low: <duration>, high: <duration> }`. Durations are ISO 8601 durations or plain `"Nm"`/`"Nh"` strings — the reference fixes the form. Derived from token volume per §6.3. |
| `human_gate_time` | string (qualitative caveat) | yes | A **disclosed qualitative caveat**, not a numeric range: total wall-clock is dominated by human availability at the orchestrator's disposition gates, and **is not estimated numerically at S1** (§4.3). The field carries a short prose statement to that effect, never a `{ low, high }` range. It is not estimated as a number because the gate set and its per-target topology live in the orchestrator (S4, #371), which this slice does not touch (§2.2). |
| `confidence` | object | yes | Per-axis confidence (§5.2). An object with keys `tokens`, `time`, and (iff `cost_usd` present) `cost`, each one of `low`, `medium`, `high`. A whole-record summary tier MAY be reported as `min()` of the present axes, but the per-axis values are authoritative — a high-confidence token estimate and a low-confidence cost figure are representable independently (O4). |
| `failure_direction` | enum | yes | One of `likely-overrun`, `likely-underrun`, `symmetric`. The direction the estimate is most likely to be wrong in, with the rationale carried in the prose body (§5.1). |

### 4.3 The time split is a field-level property

`agent_compute_time` and `human_gate_time` are **two separate required fields**,
not a single "time" field — but they carry **different shapes**:
`agent_compute_time` is a numeric `{ low, high }` range, and `human_gate_time` is
a **qualitative caveat string** (§4.2). This is a deliberate constraint:

- **Agent-compute time** is the wall-clock the model spends generating. It is
  the predictable term — it tracks token volume and tier — and is estimated as a
  numeric range (§6.3).
- **Human-gate latency** is the wall-clock spent waiting for a human at the
  orchestrator's disposition gates. It dominates total wall-clock and is the
  least predictable term — it depends on when a human next sits down, not on the
  work itself.

Collapsing the two into one number would hide the dominant source of variance
and mislead a human reading the estimate. The record format keeps the split
mandatory: agent-compute time is always shown, and human-gate latency is always
named — but the latter is **named as a qualitative caveat rather than estimated
numerically at S1**.

**`human_gate_time` is a disclosed qualitative caveat, not a number (O2).** The
previous draft derived `human_gate_time = gate_count × per-gate latency band`.
That derivation was withdrawn because `gate_count` has no grounded S1 source: the
gate set (Slice Adjudication, Plan Approval, diaboli/cartograph dispositions,
code review, integration) **is the orchestrator's gate topology**, which §2.2
places squarely in S4 (#371) and forbids this slice from naming. Multiplying a
per-gate band by a gate count S1 cannot ground would re-introduce the very
false-precision the §3 range-not-point decision exists to prevent — two agents
would invent different gate counts for the same target. Rather than couple S1 to
S4's gate topology, the methodology **demotes `human_gate_time` to a disclosed
qualitative caveat**: the field states, in prose, that wall-clock is dominated by
human availability at disposition gates and **is not estimated numerically until
S4 fixes the gate set** (e.g. "human-gate latency dominates total wall-clock and
is not estimated numerically at S1; it depends on when a human next disposes a
gate, not on the work"). No gate count, no per-gate band, no numeric range. When
S4 lands the orchestrator gate topology, a future slice may add a grounded
numeric estimate; S1 deliberately does not. The failure-direction prose (§5.1)
must still reference it: an estimate whose wall-clock omits human-gate latency
(because gates cost wall-clock, not tokens) is `likely-underrun` on wall-clock
unless the human-gate caveat is read alongside it.

### 4.4 Range representation

Every quantitative field that is present (`tokens`, each
`tokens_by_stage[].tokens`, `cost_usd` *when present*, `agent_compute_time`) is a
two-key object `{ low, high }`. `human_gate_time` is **not** a quantitative range
— it is a qualitative caveat string (§4.2, §4.3) and is exempt from the range
rules below. Validation rules:

- `low` ≤ `high` for every present range.
- `cost_usd` is **conditional**: a record with `cost_usd` absent is valid (and
  is the expected day-one state); when present it must be a well-formed range and
  `cost_basis` must accompany it (§4.2, §6.2).
- A degenerate range where `low == high` is **permitted but discouraged** — it
  signals point-value thinking and should carry a `low` confidence tier and a
  prose note explaining why the range collapsed.
- The whole-record `tokens` range need not equal the arithmetic sum of
  `tokens_by_stage` ranges (stages may be correlated); when they differ the
  prose body must say why.

## 5. The disclosure/confidence contract

**This four-part disclosure body is a contract THIS SPEC PROPOSES (O1).** It is
*not* a pre-existing promoted AGENTS.md decision — a grep of AGENTS.md confirms
no "disclosure-of-derived-judgment" decision exists by that name or content. The
real governing decision it serves is the AGENTS.md **"agent-emit +
dispatcher-persist + human-disposes" trust architecture** (ARCH_DECISIONS),
under which a research-and-author agent emits content and the human disposes. The
disclosure contract below is this spec's proposal for *what an estimate must
disclose* so the human's disposition is informed; reviewers should evaluate it as
a new contract, not check it against an authority that does not exist.

The contract makes a prospective estimate honest rather than an anchoring number
dressed as fact. An estimate record that does not satisfy this contract is
invalid regardless of how good its numbers are.

### 5.1 Mandatory disclosure body

Every estimate record's prose body MUST contain four labelled sections:

1. **Included** — what the estimate counts, **and the provenance/quality of each
   included input**. E.g. "the five orchestrator agent stages at their
   MODEL_ROUTING tier; agent-compute time derived from token volume via a stated
   tokens→wall-clock band; *when* a cost figure is present: the $/token rate is
   derived from the [date] snapshot Model Breakdown (observed actuals)." Caveats
   about the *quality of an included input* (e.g. an assumed compute band, a
   snapshot of a given age) live HERE or in Confidence rationale, never under
   Excluded (O10).
2. **Excluded** — what the estimate does NOT count, stated plainly. E.g.
   "human-gate latency is excluded from `cost_usd` and `tokens` because gates
   cost wall-clock not tokens; re-runs and diaboli/cartograph cycles beyond one
   pass; any tdd/implementer stages a docs-only target does not exercise." **When
   `cost_usd` is omitted because no usable snapshot rate exists, that omission is
   disclosed here** — e.g. "cost_usd: omitted — no repo cost snapshot exists yet,
   so no observed $/token is available; cost not estimated" (§6.4). An omission is
   a genuine "does NOT count" case, so it belongs under Excluded; a *used*
   list-price input never belonged here, which is what O10 corrected. Excluded
   items are the single most important honesty signal — a number that silently
   omits a cost class is worse than no number.
3. **Confidence rationale** — why each confidence axis (`tokens`, `time`, and,
   when present, `cost`) is what it is (§5.2), in plain prose tied to the
   `target_kind` and the grounding richness. This is also where the
   quality-of-input caveats for *present* figures are explained (e.g. "cost
   confidence is `low` because the snapshot is one quarter old and aggregates
   models coarsely").
4. **Failure direction** — a one-line statement matching the
   `failure_direction` field, naming WHY the estimate is more likely wrong in
   that direction. E.g. "likely-overrun: budgets are upper-tier defaults and most
   slices land below them" or "likely-underrun on wall-clock: human-gate latency
   is unbounded and is not estimated as a number here, so total wall-clock will
   exceed the agent-compute range." **This section
   describes uncertainty only — it must contain no imperative recommendation and
   no go/no-go language** (§5.3, O12).

A record missing any of the four sections fails validation. This four-part body
is this spec's proposed disclosure contract: included + excluded + confidence +
failure-direction.

### 5.2 Confidence tiers (per-axis)

Confidence is recorded **per axis** (`tokens`, `time`, and — only when present —
`cost`), not as one whole-record tier (O4). Each axis takes one of three tiers,
mapped to grounding richness so the tier is not a free judgement. The mapping
sets a **ceiling tied to `target_kind`** for the *grounding-richness* axes
(`tokens`, `time`), and the *cost* axis has its own independent rule.

**Target-kind ceiling (applies to `tokens` and `time`):**

| Tier | When | Typical `target_kind` |
| --- | --- | --- |
| `low` | Estimate built from raw task text only, before slicing or spec. Scope is a guess; stage set is assumed. | `task-text` |
| `medium` | Estimate built from a slicing record or a single slice — the work is decomposed but scenarios/files are not yet enumerated. | `slicing-record`, `slice` |
| `high` | Estimate built from a spec that enumerates scenarios and files to touch — the stage set and rough volume are grounded in named artefacts. | `spec` |

The `tokens`/`time` ceiling is a **cap tied to grounding, not a verdict**. The
agent (S2) may set an axis below this cap if a target is unusually ambiguous, but
it must not exceed it — a raw-text estimate's token confidence can never be
`high`. This keeps the S5 T0 ballpark (raw text → `low`) honest by construction.

The `time` axis describes confidence in the **`agent_compute_time` estimate only**
— `human_gate_time` carries no numeric estimate at S1 (it is a qualitative
caveat, §4.3), so there is no human-gate number for the `time` axis to be
confident or unconfident about. The qualitative human-gate caveat is the honest
substitute for what a confidence-capped number would otherwise have claimed.

**Cost axis (independent rule, reconciles O6):**

The `cost` confidence axis exists **only when `cost_usd` is present** — i.e. only
when a snapshot supplies a usable $/token rate. There is therefore no collision
between a target-kind floor and a "no-snapshot force": on today's empty-snapshot
default, `cost_usd` is simply **omitted** (no axis, no forced-low value), and the
`tokens`/`time` axes keep their target-kind grounding independently. When a
snapshot does exist, the `cost` axis is set from the snapshot's quality (age,
breakdown granularity) and is **independent of `target_kind`** — a spec-grounded
target with a stale or coarse snapshot can carry `tokens: high` beside
`cost: low` without contradiction (O4). This is exactly the representation the
single whole-record enum could not express in the prior draft.

### 5.3 Confidence is disclosed, never decisive

The record format carries confidence; it does **not** carry a verdict, a
recommendation, or a go/no-go. The human reads the ranges and the disclosures and
decides. This supports the S2 "emits-not-decides" trust boundary, and this spec
makes the guarantee **structural in two layers** rather than relying on field
absence alone (O12):

1. **Field-absence layer** — there is no `recommendation` field, no `verdict`
   field, no `proceed` field. (Necessary but, as O12 showed, not sufficient: a
   verdict could be smuggled into the free-text disclosure prose.)
2. **Positive-content layer** — the four disclosure sections (§5.1) describe
   **inputs and uncertainty only**. They MUST NOT contain imperative
   recommendation or go/no-go language. A validation check (enumerated in §8.2)
   scans the disclosure prose for prohibited imperative/recommendation patterns
   (e.g. "so proceed", "do not proceed", "I recommend", "you should
   [ship|skip|approve|reject]", "go/no-go") and **fails the record** if any
   appear. A "failure direction: likely-overrun, so do not proceed" sentence —
   which passed every check in the prior draft — now fails the positive-content
   check.

Together these make the no-verdict guarantee a property of the format itself,
independent of any agent's good behaviour.

## 6. The grounding methodology

The skill describes how an estimate is derived. Token ranges and
`agent_compute_time` are **always** groundable from MODEL_ROUTING.md (§6.1, §6.3);
`human_gate_time` is **not estimated numerically at S1** — it is a qualitative
caveat whose grounding (the orchestrator gate set) lives in S4 (§4.3, §6.3). The
dollar figure is groundable **only when a snapshot supplies a usable $/token
rate** (§6.2); otherwise it is omitted (§6.4). The grounding sources are **fixed,
not chosen** — the methodology names them, it does not offer a choice between
them.

### 6.1 Token derivation from MODEL_ROUTING.md

`MODEL_ROUTING.md` carries two tables the methodology consumes:

- **Token Budget Guidance** — per-role ranges: spec-writer 50–100k, tdd-agent
  50–150k, implementer 100–250k, code-reviewer 50–100k, integration-agent
  30–80k. Each role's `low`–`high` becomes that stage's `tokens` range.
- **Agent Routing** — the agent→model-tier mapping (orchestrator, spec-writer,
  advocatus-diaboli → Most capable; tdd-agent, integration-agent → Standard;
  implementer → Standard/Capable; code-reviewer → Most capable). Each stage's
  `model_tier` is read from this table.

The per-stage token ranges sum into the whole-record `tokens` range (with the
correlation caveat of §4.4). Which stages a target exercises depends on
`target_kind` and is a methodology judgement the skill describes — e.g. a
docs-only spec may exercise spec-writer + review only, and the omitted stages
must be disclosed in `excluded`.

**Split-tier stages (O5).** The implementer stage maps to a **split tier**
`Standard / Capable` ("Depends on task complexity"), and it carries the largest
token budget (100–250k), so its rate dominates any cost figure. The methodology
does **not** leave the tier choice to agent discretion. Instead, a split-tier
stage is priced (when cost is computed at all, §6.2) by **widening its cost
contribution to span both ends of the split**: its low bound uses the cheaper
end (the `Standard` representative model) and its high bound uses the dearer end
(the `Most capable` representative model — the tier the implementer's split rises
to for complex tasks, since MODEL_ROUTING.md carries no standalone `Capable`
model). Because the two ends bind to **different** representative models
(`claude-sonnet-4` vs `claude-opus-4`, §6.2), the widening produces a genuine
spread for this dominant stage rather than collapsing to one rate. The same
widening applies to any stage MODEL_ROUTING.md lists with a slashed tier. The
`tokens_by_stage[].model_tier` field records the literal split label
(`Standard/Capable`) so the breakdown is traceable.

### 6.2 Cost derivation — only when a snapshot grounds it (O2, O3, O8, O11)

`cost_usd` is **present only when an `observability/costs/` snapshot supplies a
usable per-tier $/token rate.** Deriving that rate from the snapshot requires a
named binding, because MODEL_ROUTING.md tiers are abstract labels with no model
or price, and the snapshot's Model Breakdown is keyed by model name. The
methodology defines the binding explicitly:

**The tier→model→$/token binding.** A named **tier-binding table** ships in the
format reference (§8.2) and is the single source of the `tier → model` map:

| Model tier (MODEL_ROUTING) | Representative model (snapshot key) |
| --- | --- |
| Most capable | `claude-opus-4` |
| Standard | `claude-sonnet-4` |
| Standard / Capable (split) | spans `claude-sonnet-4` (low) … `claude-opus-4` (high), widened per §6.1 |

MODEL_ROUTING.md names exactly two non-frontier-vs-frontier tiers — `Standard`
and `Most capable` — and one complexity-dependent split, the implementer's
`Standard / Capable` ("Depends on task complexity"). There is **no standalone
`Capable` tier with its own model** in the routing table; the dearer end of the
implementer's split resolves to the `Most capable` tier. The binding therefore
maps the split's low bound to the `Standard` representative (`claude-sonnet-4`)
and its high bound to the `Most capable` representative (`claude-opus-4`), so the
widening (§6.1) produces a real cost spread rather than collapsing to a single
rate. (The reference fixes the representative model per tier and is the artefact
S6 may revise as routing evolves — the binding lives in a named place, not in
agent judgement.)

**Deriving a per-model rate from a snapshot.** The snapshot's `## Model
Breakdown` table gives, per model, quarter-aggregate input/output token volumes
and an estimated cost. The methodology computes a per-model `$/token` as
`estimated_cost ÷ (input_tokens + output_tokens)` for that model row — a single
blended rate per model derived from the quarter aggregate. The binding table then
maps each stage's tier to its representative model's blended rate, and
`cost_usd = Σ over stages (stage tokens range × tier $/token)`, with split-tier
stages widened per §6.1.

**The three grounding states (O8).** The snapshot's Model Breakdown is marked
"(if available)" in the cost-tracking format, so the methodology branches on
three states, not two:

1. **No snapshot exists** (today's state — `observability/costs/` is empty; the
   2026-05-29 health snapshot records "Last cost capture: never"). → `cost_usd`
   **omitted**, omission disclosed in `excluded` (§6.4).
2. **Snapshot exists but the Model Breakdown is absent or too coarse** to yield a
   per-tier rate (only the always-present Provider Spend table is populated, or
   the breakdown lacks the tiers the stage set needs). → `cost_usd` **omitted**,
   omission disclosed in `excluded` naming this specific cause ("a cost snapshot
   exists but carries no usable per-model breakdown"). The methodology does **not**
   silently fall through to list price.
3. **Snapshot exists with a usable Model Breakdown** → `cost_usd` **present**,
   `cost_basis: snapshot-actuals`, `cost` confidence set from the snapshot's age
   and granularity (§5.2), and the snapshot date/quality disclosed in `included`.

There is **no list-price fallback.** The prior draft's "produce a list-price
cost and force confidence low" path is removed (O3, O11): a list-price guess is
not an observed cost, and emitting it as a first-class figure was the false
precision this spec opposes. When cost cannot be grounded in actuals, it is
omitted with disclosure (§6.4), and the day-one deliverable remains the
token + time estimate.

**The no-cost case is honest, not a failure (O3, O11).** When `cost_usd` is
omitted (states 1 and 2 above), the record is **valid and complete** — it is the
expected day-one shape. The `excluded` section MUST carry an explicit omission
disclosure, e.g.:

> "cost_usd: omitted — no repo cost snapshot exists yet, so no observed $/token
> is available; cost is not estimated. Token and time figures stand."

The human reads a grounded token + time estimate and an honest statement that
dollars are not yet knowable — which is more informative than a low-confidence
list-price range that says "we don't really know" in numeric clothing. **No
format change is required when the first snapshot lands** (O11): the same
`cost_usd`/`cost_basis`/`confidence.cost` fields simply begin to appear. This is
the seam §7 already contemplates.

### 6.3 Time derivation (O2)

Both time fields are always present, but they have different shapes:

- **`agent_compute_time`** is derived from token volume: the methodology applies
  a disclosed tokens→wall-clock band (the reference fixes a default, e.g.
  "~1–3 min per 10k tokens generated") to the `tokens` range, per tier, yielding
  a numeric `{ low, high }` range. The band is stated as an assumption in
  `included`.
- **`human_gate_time`** is **not estimated numerically at S1**: it is a disclosed
  qualitative caveat (§4.3, §4.2). Its grounding — the orchestrator gate set and
  how many gates a given target passes through — lives in S4 (#371), which this
  slice does not touch (§2.2). Rather than multiply an ungrounded gate count by a
  per-gate band (the withdrawn O9-era derivation, which coupled S1 to S4 and
  invited the per-estimate invention of `gate_count`), the methodology states in
  prose that wall-clock is dominated by human availability and is not estimated
  as a number until the gate set is fixed. A future slice may add a grounded
  numeric human-gate estimate once S4 ships; S1 deliberately stops at the caveat.

`agent_compute_time`'s band does not claim to be an observed actual — it is a
stated assumption a human can interrogate. `human_gate_time` claims no number at
all, which is the honest position while its grounding lives downstream.

### 6.5 The retrospective sibling

The `cost-estimation` skill is the **prospective** counterpart to the
**retrospective** `cost-tracking` skill. The two reuse the same
`observability/costs/` data: `cost-tracking` *writes* the snapshots,
`cost-estimation` *reads* them as its $/token ground. The skill's frontmatter
description and a short "Sibling" note make the pair discoverable — a reader who
finds one should find the other. The two are symmetric:
`/cost-capture` records what was spent; the future `/cost-estimate` (S3)
predicts what will be spent.

## 7. The calibration seam (S6, do not implement)

S6 (the calibration loop, #373) is accepted in-scope for the capability but
ships after the estimator. S1's only obligation is to keep the seam open so
that a future per-PR actuals data source can be ingested **without a format
change**. The seam is already present in §4.2:

- `grounding_sources[]` permits a `kind: calibration` entry. Today only
  `model-routing` and `cost-snapshot` entries appear; tomorrow S6 can add a
  `calibration` entry pointing at per-PR actuals without altering the field
  set.
- The methodology (§6) is written so that calibration data, when it exists,
  **refines the $/token and the per-stage token ranges** — it slots into the
  same derivation, narrowing ranges and potentially raising confidence, rather
  than introducing a new field.

**Watch item — the cost axis cannot improve until S6 (O7).** Note for the
slicing record's future revisit: no slice between S1 and S6 produces actuals, and
S6 is currently sequenced last, so for the S2–S5 window `cost_usd` will be
**omitted on most records** (the optional-cost restructure of this revision, not
a forced low-confidence guess). The omission is honest and self-disclosing, which
softens the harm O7 raised — but whether to resequence S6 earlier (so the dollar
axis becomes groundable sooner) is a **slicing decision to revisit**, recorded
here as a flag rather than resolved in this spec. This is a NOTE, not a structural
change to S1.

S1 does NOT implement calibration: no per-PR actuals format, no
integration-agent change, no ingestion logic. The skill names calibration as a
*future* grounding source in one short paragraph and stops there. Implementing
it here would be scope creep into S6.

## 8. Files to add and modify

### 8.1 The skill (`SKILL.md`)

`ai-literacy-superpowers/skills/cost-estimation/SKILL.md` — frontmatter
(`name: cost-estimation`, a `description` that triggers on prospective cost /
estimate / "how much will this cost" queries and names the sibling), then prose
covering: why estimate prospectively, the range-not-point decision (§3), the
grounding methodology (§6) — including that cost is present only when a snapshot
grounds it (§6.2) and omitted-with-disclosure otherwise (§6.4) — the
disclosure/confidence contract (§5), the time split — `agent_compute_time` as a
numeric range with its token→wall-clock band, and `human_gate_time` as a
qualitative caveat not estimated numerically at S1 (§4.3, §6.3) — the calibration
seam (§7), the sibling relationship (§6.5), and a
"What this skill does NOT do" section (it does not dispatch, does not write
files, does not decide go/no-go — those are consumers' jobs).

### 8.2 The format reference

`ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`
— the canonical, stable definition of the estimate-record field set (§4) and
the disclosure body structure (§5.1), one contract per file per the AGENTS.md
references-file idiom. This is the file a downstream command's Output
Validation Checkpoint (S3) references by path. It contains:

- The frontmatter field table (§4.2), including `cost_usd` and `cost_basis`
  marked **conditional (present-when-grounded)** and the **per-axis `confidence`
  object**.
- The range representation rules (§4.4), including that an absent `cost_usd` is
  valid.
- The time-split requirement (§4.3): `agent_compute_time` as a numeric range and
  `human_gate_time` as a qualitative caveat string, and the §6.3 time
  derivation.
- The four-part disclosure-body structure (§5.1).
- The **per-axis confidence mapping** (§5.2): the `target_kind` ceiling for
  `tokens`/`time`, and the snapshot-quality rule for the conditional `cost` axis.
- The **tier→model→$/token binding table** (§6.2) — the named artefact the cost
  derivation reads, so the binding is not left to agent discretion (O2). It also
  fixes the split-tier widening rule for the implementer stage (O5).
- The **default throughput band** the time derivation uses (§6.3): the
  tokens→agent-compute band, stated as an assumption. (No per-gate human-gate
  band ships — `human_gate_time` is a qualitative caveat at S1, §4.3, O2.)
- The two-layer **no-verdict guarantee** (§5.3): field-absence plus the
  positive-content prohibition.
- **Two complete worked example records** so a reader sees both shapes. In both,
  `human_gate_time` is a **qualitative caveat string**, not a range (§4.3, O2),
  and `agent_compute_time` is a numeric range:
  1. a **cost-omitted** record (today's default — no snapshot; `cost_usd` and
     `cost_basis` absent; `confidence` has `tokens`/`time` only; `excluded`
     discloses the cost omission per §6.4),
  2. a **cost-present** record (a snapshot exists with a usable Model Breakdown;
     `cost_usd` + `cost_basis: snapshot-actuals` present; `confidence.cost`
     present and possibly below `tokens`). This example **demonstrates the
     split-tier widening (O5)**: its implementer stage carries a non-zero cost
     band whose low bound uses `claude-sonnet-4` and high bound uses
     `claude-opus-4` (§6.1, §6.2), so the widened band is visibly wider than the
     token-range spread alone. Neither example files an inclusion caveat under
     `excluded` (O10 fixed).
- A "Validation checklist" subsection enumerating the checks a consuming command
  runs:
  - every **present** range has `low ≤ high`;
  - all four disclosure sections present;
  - each present `confidence` axis is within the §5.2 cap for the `target_kind`
    (for `tokens`/`time`) and `cost` axis present iff `cost_usd` present;
  - `cost_usd` and `cost_basis` are either **both present or both absent**; when
    absent, the `excluded` section contains the cost-omission disclosure (§6.4);
  - both time fields present and separate — `agent_compute_time` a `{low, high}`
    range, `human_gate_time` a qualitative caveat string (not a range), per §4.3;
  - no verdict/recommendation **field** (field-absence layer); **and**
  - the disclosure prose contains **no imperative recommendation or go/no-go
    language** — a positive-content scan for patterns like "so proceed", "do not
    proceed", "I recommend", "you should [ship|skip|approve|reject]", "go/no-go"
    (O12 positive constraint, §5.3).

### 8.3 TDAD scenario

Per the `component-design-with-tdad` skill, a new skill warrants Layer 1
(structural) + Layer 2 (trigger) coverage. Add under
`tdad_tests/scenarios/skills/cost-estimation/`:

- A structural scenario asserting the skill frontmatter is well-formed and the
  required sections (methodology, disclosure contract, time split, sibling,
  NOT-do) are present, and that the format reference file exists and contains
  the field table (with `cost_usd` marked conditional and a per-axis
  `confidence` object), the tier→model→$/token binding table, the four-part
  disclosure body, and **both** the cost-omitted and cost-present worked
  examples.
- A trigger scenario asserting the skill description fires on prospective-cost
  queries ("how much will this feature cost", "estimate the tokens for this
  spec") and does NOT fire on retrospective-cost queries (those belong to
  `cost-tracking`).

The tdd-agent authors these in its agent-artefact branch; this spec fixes their
`Then` shape.

### 8.4 Maintenance files

| Path | Change |
| --- | --- |
| `ai-literacy-superpowers/.claude-plugin/plugin.json` | Bump `version` `0.40.0` → `0.41.0` (new skill — minor). |
| `ai-literacy-superpowers/CHANGELOG.md` | New `## 0.41.0 — 2026-06-10` heading with entries for the skill, the format reference, and the disclosure contract. |
| `.claude-plugin/marketplace.json` | Bump the `ai-literacy-superpowers` entry `version` and the top-level `plugin_version` `0.40.0` → `0.41.0`. Top-level `version` unchanged at `0.4.0`. |
| `README.md` (repo root) | Bump the `ai-literacy-superpowers` plugin version badge `v0.40.0` → `v0.41.0`. |

## 9. Component design (per component-design-with-tdad)

- **Type**: skill — the deliverable is methodology + a format contract loaded
  as reasoning context; it is not a dispatchable behaviour (that is the S2
  agent) nor a slash-command surface (that is the S3 command).
- **Justification**: the methodology and disclosure contract must exist as
  loadable guidance and a referenceable format before any agent or command can
  consume them; a skill is the canonical home for cross-cutting methodology, and
  the references-file idiom is the canonical home for a contract consumed by
  multiple downstream components.
- **TDAD layers targeted**: `[structural, trigger]` — Layer 1 always, Layer 2
  because a skill has a description-vs-query match to verify. Layer 3 deferred
  (no dispatchable side-effect ships in S1).
- **Scenario shape**: the structural `Then` asserts the SKILL.md sections and
  the format-reference field table exist; the trigger `Then` asserts the skill
  fires on prospective-cost queries and not on retrospective-cost queries.
- **Modification or new?** new — `skills/cost-estimation/`.
- **Scenario vs finding**: scenario only — every assertion is falsifiable
  (sections present, description triggers).

## 10. User stories and acceptance scenarios

### 10.1 Story — a future agent can emit a valid estimate record against the format

**As** the developer building the S2 cost-estimator agent
**I want** a committed, stable estimate-record format with a named field set
**So that** my agent emits a record the orchestrator, the command, and the gates
all parse identically.

```gherkin
Given the merged main on this PR
When I read ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md
Then it defines the frontmatter field set including target, target_kind,
    grounding_sources, tokens, tokens_by_stage, cost_usd, cost_basis,
    agent_compute_time, human_gate_time, confidence, and failure_direction
And cost_usd and cost_basis are marked conditional (present only when grounded)
And confidence is a per-axis object with keys tokens, time, and conditionally cost
And every present quantitative field is specified as a {low, high} range
And it specifies the four-part disclosure body (included, excluded,
    confidence rationale, failure direction)
And it contains a tier-to-model-to-$/token binding table
And it contains both a cost-omitted and a cost-present worked example record
And it contains a validation checklist a consuming command can run
```

### 10.2 Story — every estimate is a range with disclosed confidence, never a point value

**As** a human reading an estimate to decide whether to proceed
**I want** a range with disclosed confidence, included/excluded, and a failure
direction
**So that** I interrogate a prediction rather than anchor on a number dressed as
fact.

```gherkin
Given the estimate-record format reference
When I inspect how the quantities are represented
Then tokens and agent_compute_time are {low, high} ranges
And cost_usd, when present, is also a {low, high} range
And human_gate_time is a qualitative caveat string, not a range, because it is
    not estimated numerically at S1
And there is no point-value, verdict, recommendation, or go/no-go field
And the format mandates a failure_direction with a prose rationale
And the format mandates an explicit "excluded" disclosure section
And the disclosure prose is constrained to inputs and uncertainty only,
    with a validation check that rejects imperative recommendation or
    go/no-go language in the disclosure sections
```

### 10.2a Story — a verdict cannot be smuggled into disclosure prose

**As** a human relying on the estimator to emit, not decide
**I want** the no-verdict guarantee enforced on the prose, not just on field
presence
**So that** the failure-direction or confidence prose cannot deliver a go/no-go
the format claims to forbid.

```gherkin
Given the estimate-record format reference validation checklist
When I read how the no-verdict guarantee is enforced
Then it lists a field-absence check (no recommendation/verdict/proceed field)
And it lists a positive-content check that fails a record whose disclosure
    prose contains imperative recommendation or go/no-go language
And the worked examples contain no "so proceed" or "do not proceed" style text
```

### 10.3 Story — the time split is mandatory and separate

**As** a human estimating wall-clock for a feature
**I want** agent-compute time and human-gate latency surfaced as separate fields
**So that** the dominant, least-predictable term (human-gate latency) is never
hidden inside a single time number.

```gherkin
Given the estimate-record format reference
When I read the time fields
Then agent_compute_time and human_gate_time are two separate required fields
And agent_compute_time is a {low, high} range derived from token volume
And human_gate_time is a qualitative caveat string, not a numeric range
And the reference states human_gate_time dominates wall-clock and is least predictable
And the reference states human_gate_time is not estimated numerically at S1
    because the gate set lives in the orchestrator (S4), which this slice does
    not touch
And the failure-direction guidance references the exclusion of human-gate latency
    from the dollar/token figures
```

### 10.4 Story — token and time are the day-one deliverable; cost is present only when grounded

**As** the developer authoring the estimator against today's repo
**I want** the methodology to ground token and time from MODEL_ROUTING.md today,
and to add a dollar figure only when a snapshot supplies an observed $/token
**So that** the skill is honestly usable today even though `observability/costs/`
is empty, with no forced low-confidence list-price guess.

```gherkin
Given ai-literacy-superpowers/skills/cost-estimation/SKILL.md
When I read the grounding methodology
Then it derives per-stage token ranges from MODEL_ROUTING.md Token Budget Guidance
And it reads model tiers from MODEL_ROUTING.md Agent Routing
And it derives agent_compute_time from token volume
And it states human_gate_time is a qualitative caveat not estimated numerically
    at S1 (the gate set is S4 scope)
And it defines a named tier-to-model-to-$/token binding for cost derivation
And it widens a split-tier stage (implementer Standard/Capable) across both ends,
    binding the low end to claude-sonnet-4 and the high end to claude-opus-4
And it derives cost_usd only when a snapshot supplies a usable per-model rate
And it specifies no list-price fallback
```

### 10.4a Story — no snapshot means cost is omitted with disclosure, not guessed

**As** a human running the estimator on today's repo (empty `observability/costs/`)
**I want** the cost figure omitted with an explicit disclosure while token and
time still stand
**So that** I get a grounded estimate plus an honest "cost not yet knowable"
rather than a list-price number dressed as a prediction.

```gherkin
Given the estimate-record format reference and the SKILL.md methodology
And no observability/costs snapshot exists
When I read the methodology's no-snapshot behaviour
Then tokens and agent_compute_time are still produced as ranges
And human_gate_time is still produced as its qualitative caveat
And cost_usd and cost_basis are omitted entirely
And the "excluded" disclosure states cost is omitted because no observed
    $/token exists yet
And the confidence object carries tokens and time axes but no cost axis
And the cost-omitted worked example in the reference matches this shape
```

### 10.4b Story — a snapshot without a usable model breakdown also omits cost

**As** the developer reasoning about a sparse snapshot
**I want** the third grounding state handled (snapshot present, Model Breakdown
absent or coarse)
**So that** the methodology does not assume a breakdown that the cost-tracking
format marks "(if available)".

```gherkin
Given the SKILL.md grounding methodology
When I read how a snapshot lacking a usable Model Breakdown is handled
Then cost_usd is omitted (not derived from list price)
And the "excluded" disclosure names this specific cause
And only a snapshot with a usable Model Breakdown yields a present cost_usd
    with cost_basis snapshot-actuals
```

### 10.5 Story — the calibration seam is open without being implemented

**As** the developer who will later build S6 (calibration, #373)
**I want** the format and methodology to already accommodate a per-PR actuals
data source
**So that** S6 adds calibration data without a format change.

```gherkin
Given the estimate-record format reference and the SKILL.md methodology
When I look for how calibration data would enter
Then grounding_sources permits a kind: calibration entry alongside model-routing and cost-snapshot
And the methodology states calibration data refines existing ranges rather than adding a field
And no per-PR actuals capture, format, or integration-agent change ships in this slice
```

### 10.6 Story — the prospective and retrospective siblings are discoverable as a pair

**As** a user who knows `/cost-capture` and `cost-tracking`
**I want** the prospective estimation skill to be discoverable as the sibling
**So that** I find both halves of the cost capability from either one.

```gherkin
Given ai-literacy-superpowers/skills/cost-estimation/SKILL.md
When I read its frontmatter description and its body
Then it names cost-tracking as its retrospective sibling
And it states it reads the observability/costs snapshots that cost-tracking writes
And its description triggers on prospective-cost queries distinct from cost-tracking's capture queries
```

### 10.7 Story — the plugin version reflects the new skill

**As** the marketplace consumer
**I want** the plugin version to bump when a new skill is added
**So that** caches and version checks know the plugin changed.

```gherkin
Given the merged main on this PR
When I read ai-literacy-superpowers/.claude-plugin/plugin.json
Then the version is "0.41.0"
And the ai-literacy-superpowers entry in .claude-plugin/marketplace.json shows "0.41.0"
And plugin_version in .claude-plugin/marketplace.json is "0.41.0"
And the top-level marketplace version is unchanged at "0.4.0"
And CHANGELOG.md has a new "## 0.41.0 — 2026-06-10" entry
And README.md shows the v0.41.0 badge
```

## 11. Functional requirements

The requirements flow from the scenarios above and are numbered for the FR
mapping table in the plan.

- **FR-1** The skill ships at `ai-literacy-superpowers/skills/cost-estimation/SKILL.md`
  with well-formed frontmatter and the required sections (methodology,
  disclosure contract, time split, calibration seam, sibling, NOT-do).
- **FR-2** A format reference ships at
  `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`
  defining the full frontmatter field set of §4.2, with `cost_usd` and
  `cost_basis` marked **conditional (present-when-grounded)** and `confidence` a
  **per-axis object**.
- **FR-3** Every **present** quantitative field is a `{low, high}` range; the
  format contains no point-value, verdict, recommendation, or go/no-go field.
- **FR-4** The format mandates the four-part disclosure body (included,
  excluded, confidence rationale, failure direction).
- **FR-5** The format defines `agent_compute_time` and `human_gate_time` as two
  separate required fields with different shapes: `agent_compute_time` is a
  numeric `{low, high}` range derived from token volume, and `human_gate_time` is
  a **qualitative caveat string, not estimated numerically at S1** — it states
  that wall-clock is dominated by human availability at disposition gates and is
  not given a number because the gate set lives in the orchestrator (S4, #371),
  which this slice does not touch (O2). The format states the human-gate term
  dominates and is least predictable.
- **FR-6** The format defines **per-axis** confidence (§5.2): a `target_kind`
  ceiling for `tokens`/`time` (raw text capped at `low`) and an independent
  snapshot-quality rule for the conditional `cost` axis; the `tokens`/`time` and
  `cost` axes are representable independently (O4, O6).
- **FR-7** The methodology grounds token ranges in MODEL_ROUTING.md Token
  Budget Guidance and tiers in MODEL_ROUTING.md Agent Routing, and prices the
  split-tier implementer stage (`Standard / Capable`) by widening its cost
  contribution across **two distinct representative models** — low bound
  `claude-sonnet-4` (`Standard`), high bound `claude-opus-4` (`Most capable`) —
  so the widening produces a genuine spread rather than a zero-width band
  (O1, O5).
- **FR-8** `cost_usd` is **conditional**: present (with `cost_basis:
  snapshot-actuals`) only when an `observability/costs/` snapshot supplies a
  usable per-model Model Breakdown, derived via the named tier→model→$/token
  binding table; otherwise **omitted with disclosure** in `excluded`. There is
  **no list-price fallback** (O2, O3, O8, O11). The three grounding states
  (no snapshot / snapshot-without-usable-breakdown / snapshot-with-breakdown) are
  each defined.
- **FR-8a** The format reference contains the named **tier→model→$/token binding
  table** the cost derivation reads (O2).
- **FR-9** The format permits a `kind: calibration` grounding source and the
  methodology describes calibration as range-refinement, without implementing
  S6.
- **FR-10** The skill names `cost-tracking` as its retrospective sibling and
  states it reuses the `observability/costs/` data.
- **FR-11** The format reference contains **two** worked example records (a
  cost-omitted and a cost-present record) and a validation checklist suitable for
  a downstream Output Validation Checkpoint. Neither example files an inclusion
  caveat under `excluded` (O10).
- **FR-14** The validation checklist includes a **positive-content check** that
  fails a record whose disclosure prose contains imperative recommendation or
  go/no-go language, making the no-verdict guarantee structural rather than
  field-absence only (O12).
- **FR-12** The plugin version bumps to 0.41.0 across plugin.json,
  marketplace.json (`version` + `plugin_version`), CHANGELOG, and README.
- **FR-13** A TDAD scenario (structural + trigger) covers the skill under
  `tdad_tests/scenarios/skills/cost-estimation/`.

## 12. Compatibility and rollout

- **Backwards compatibility**: purely additive. No existing component changes.
  No consumer of the format exists yet (S2–S5), so the format can be set without
  migration concern — this is precisely why S1 ships first.
- **Cache behaviour**: `sync-marketplace-cache.sh` fires because
  `.claude-plugin/marketplace.json` changes (`plugin_version` bump).
  `sync-to-global-cache.sh` rsyncs the new skill into the versioned plugin
  cache.
- **CI gates**: spec-first is satisfied by this spec as the first commit.
  Version consistency is satisfied (plugin.json 0.41.0 = marketplace entry
  0.41.0 = `plugin_version` 0.41.0). The TDAD-scenario-presence constraint
  fires (a new skill file is added) and is satisfied by §8.3. The
  docs-reference-parity constraint fires (a new skill) and is satisfied by the
  docs check in §13.

## 13. Docs site

Per the CLAUDE.md Docs Site Review convention, a new skill warrants a docs
touch. The skill adds a prospective-cost capability, so:

- Add a how-to or explanation page under
  `docs/plugins/ai-literacy-superpowers/` describing prospective cost
  estimation and its relationship to the retrospective `cost-tracking` sibling,
  OR extend the existing cost-tracking docs page to name the prospective sibling
  and the estimate-record format. The plan fixes which.
- The docs-reference-parity CI check requires the new skill to be referenced;
  the docs touch satisfies it.

## 14. Open questions resolved during design

| Question | Decision |
| --- | --- |
| Point value vs range | Range with disclosed confidence, always. No point-value field. (§3) |
| Is `cost_usd` required? | **No — conditional (present-when-grounded).** Day-one deliverable is token + time; cost appears only when a snapshot grounds it. (§4.2, §6.2, O11) |
| Single time field vs split | Two separate required fields with different shapes: `agent_compute_time` a numeric range, `human_gate_time` a qualitative caveat. (§4.3) |
| Confidence as verdict vs disclosure | Disclosure only; no verdict field **and** a positive-content check forbidding recommendation prose. (§5.3, O12) |
| Confidence representation | **Per-axis** (`tokens`/`time`/conditional `cost`), not one whole-record enum. `target_kind` ceiling for tokens/time; independent snapshot-quality rule for cost. (§5.2, O4, O6) |
| Grounding sources | Token + time from MODEL_ROUTING.md (always); cost from a snapshot (conditional). Fixed, not chosen. (§6) |
| Cost binding | A named tier→model→$/token binding table in the reference; the implementer's `Standard / Capable` split is widened across two **distinct** representative models (low `claude-sonnet-4`, high `claude-opus-4`), so the spread is real not a no-op. (§6.1, §6.2, O1, O5) |
| No snapshot / no usable breakdown | **`cost_usd` omitted with disclosure** in `excluded`. No list-price fallback. Three grounding states defined. (§6.2, §6.4, O3, O8, O11) |
| `human_gate_time` derivation | **Demoted to a qualitative caveat — not estimated numerically at S1.** The withdrawn `gate_count × per-gate band` derivation had an ungrounded `gate_count` and reached into the orchestrator gate topology (S4 scope); a future slice may add a number once S4 fixes the gate set. (§4.3, §6.3, O2) |
| AGENTS.md authority for the disclosure body | The four-part body is **proposed by this spec**, not a pre-existing decision; it serves the real "agent-emit + dispatcher-persist + human-disposes" ARCH_DECISION. (§5, O1) |
| Cost axis vs S6 sequencing | Watch item: cost stays omitted across S2–S5 until S6; resequencing is a slicing decision to revisit. (§7, O7) |
| Calibration in S1 | Seam only — `grounding_sources` accepts `kind: calibration`; methodology describes range-refinement; no implementation. (§7) |
| Where the format lives | A references file, one contract per file, for downstream validation-checkpoint reference. (§8.2) |
| Version bump | 0.40.0 → 0.41.0 (new skill, minor). (§8.4) |

## 15. References

- Slicing record: `docs/superpowers/slices/cost-estimator-pipeline.md`.
- Downstream issues: S2 #369, S3 #370, S4 #371, S5 #372, S6 #373.
- Governing decision: AGENTS.md ARCH_DECISION **"agent-emit + dispatcher-persist
  + human-disposes"** trust architecture — the real promoted decision this
  capability's S2/S3 consumers inherit. NOTE: no "disclosure-of-derived-judgment"
  decision exists in AGENTS.md; the four-part disclosure body in §5 is a contract
  **this spec proposes**, not an operationalisation of a pre-existing decision
  (O1).
- Grounding source: `MODEL_ROUTING.md` (Token Budget Guidance + Agent Routing).
- Grounding source: `observability/costs/YYYY-MM-DD-costs.md` (none yet; format
  defined by the `cost-tracking` skill).
- Retrospective sibling: `ai-literacy-superpowers/skills/cost-tracking/SKILL.md`
  and `ai-literacy-superpowers/commands/cost-capture.md`.
- Component-design methodology: `ai-literacy-superpowers/skills/component-design-with-tdad/SKILL.md`.
- References-file idiom: AGENTS.md ARCH_DECISION on cross-cutting methodology in
  `skills/<name>/references/`.
- `CLAUDE.md` — Semantic Versioning, Marketplace Versioning, Output Validation
  Checkpoints, and Docs Site Review sections.
