---
spec: docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md
date: 2026-06-11
mode: spec
cartographer_model: claude-opus-4-8[1m]
stories:
  - id: 1
    lens: [forces, patterns]
    title: The format is the contract; consumers are downstream
    disposition: pending
    disposition_rationale: null
  - id: 2
    lens: [forces, consequences]
    title: cost_usd conditional rather than required-low
    disposition: pending
    disposition_rationale: null
  - id: 3
    lens: [forces, patterns]
    title: human_gate_time named but not numbered
    disposition: pending
    disposition_rationale: null
  - id: 4
    lens: [patterns, alternatives]
    title: Per-axis confidence object over a single enum
    disposition: pending
    disposition_rationale: null
  - id: 5
    lens: [defaults, consequences]
    title: The tier-binding table as an authored artefact
    disposition: pending
    disposition_rationale: null
  - id: 6
    lens: [patterns, forces]
    title: No-verdict enforced by positive-content scanning
    disposition: pending
    disposition_rationale: null
  - id: 7
    lens: [defaults, alternatives]
    title: Reusing the cost-snapshot format as ground
    disposition: pending
    disposition_rationale: null
  - id: 8
    lens: [coherence]
    title: A proposed contract, not an inherited decision
    disposition: pending
    disposition_rationale: null
---

## Story #1 — The format is the contract; consumers are downstream

**Source:** `docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md` (§1, §4)
**Lens:** forces, patterns
**Refs:** —

**Context.** S1 ships a skill and a format reference and nothing else — "no agent, no command, and no orchestrator wiring" (§1). The estimate-record format is named "the load-bearing deliverable" (§4) that S2 emits, S3 writes, and S4 surfaces. The whole slice exists to lock a data contract before any code reads or writes it.

**Forces.** The tension is between *something runnable now* and *something stable later*. A slice that shipped the agent first would demonstrate value immediately but would bake the record shape into emitter code, making the format expensive to change once three downstream consumers (S2–S5) depend on it. The spec resolves toward stability-first: lock the contract while it has zero consumers, when "the format can be set without migration concern" (§12).

**Options not taken.** (1) Ship the agent and command together and let the record shape emerge from the implementation — faster to a demo, but the format becomes whatever the first emitter happened to produce. (2) Define the format inline inside the eventual agent prompt rather than as a standalone reference file — couples the contract to one consumer. (3) Skip a formal format entirely and let each consumer parse loosely — defers the schema cost to integration time across three insertion points.

**Choice as written.** The spec makes the *artefact* — a markdown record with a YAML frontmatter field set and a four-part prose body — the unit of design, and treats every executing component as a downstream reader or writer of it. The skill is "methodology + a format contract loaded as reasoning context; it is not a dispatchable behaviour" (§9).

**Consequences.** S1 ships nothing a human can run end-to-end; its value is entirely realised through later slices, so the slice's worth is unverifiable except by reading the contract. Accepted deliberately: §12 notes no consumer exists yet, which is "precisely why S1 ships first." The cost is that a format error here is silent until S2.

**Pattern.** Data-contract-first / schema-first design (the published-interface discipline; cf. Fowler's *Published Interface*). Also a Tolerant Reader's mirror image — the producers and consumers are being designed against a fixed shared schema before either exists.

**Notes.** —

## Story #2 — cost_usd conditional rather than required-low

**Source:** `docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md` (§4.2, §6.2, §6.4)
**Lens:** forces, consequences
**Refs:** —

**Context.** The central restructure of this revision: `cost_usd` is "conditional, not required" (§4.2) — present only when an `observability/costs/` snapshot supplies a usable $/token rate, omitted-with-disclosure otherwise. The day-one deliverable is explicitly a token + time estimate; dollars are an "actuals-gated enhancement" (§1).

**Forces.** The tension is between *schema completeness* and *honest grounding*. A required `cost_usd` field gives every record a uniform shape and a dollar figure a human can sort on; but on day one there is no observed spend, so the only way to fill a required field is a list-price guess — "a number dressed as a fact" the spec exists to oppose (§3). Making the field conditional honours grounding at the cost of a record shape that varies by environment.

**Options not taken.** (1) Required `cost_usd` with a forced-`low` confidence list-price value — the prior draft's path, rejected as false precision (§6.2). (2) Required `cost_usd` carrying an explicit `null` sentinel — keeps shape uniform but invites consumers to treat absence and zero alike. (3) A separate record *type* for cost-present vs cost-absent — two schemas instead of one conditional field, doubling the validation surface.

**Choice as written.** A single field set where `cost_usd`/`cost_basis` are present-when-grounded and absent-but-valid otherwise, with the omission disclosed in the `excluded` prose (§6.4). "No format change is required when the first snapshot lands" (§6.4) — the same fields simply begin to appear.

**Consequences.** Consumers (S2–S4) must handle a record whose field set legitimately varies — a `cost_usd` absence is a valid state, not an error, and downstream UI/gates must render "cost not yet knowable" as a first-class outcome. The spec's own §7 watch-item flags that across the entire S2–S5 window `cost_usd` will be omitted on most records because no slice produces actuals until S6 — the conditional shape is the *normal* shape for the foreseeable lifetime of the capability, not an edge case.

**Pattern.** Option type / present-when-grounded (the same discipline as a nullable-but-meaningful absence; cf. Maybe/Optional rather than null). The "make-illegal-states-unrepresentable" instinct applied to *ungrounded* states: there is no representable forced-guess value.

**Notes.** This is the round-1 O11 restructure; the diaboli round-2 record confirms it genuinely resolved. The story records the *decision*, not the resolved objection.

## Story #3 — human_gate_time named but not numbered

**Source:** `docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md` (§4.3, §6.3)
**Lens:** forces, patterns
**Refs:** O2

**Context.** `human_gate_time` is a required field, but it carries "a disclosed qualitative caveat, not a numeric range" (§4.2). The field must always be present and must always name that wall-clock is dominated by human availability at disposition gates — but it is "not estimated numerically at S1" (§4.3).

**Forces.** Three forces collide: the dominant source of wall-clock variance must not be hidden; S1 has no grounded source for the gate count (the gate topology lives in S4); and the spec's own range-not-point principle forbids inventing a multiplier S1 cannot ground. A numeric estimate would satisfy the first force and violate the other two. Silence on the field would satisfy the last two and violate the first.

**Options not taken.** (1) Derive `human_gate_time = gate_count × per-gate band` — the withdrawn prior derivation, whose `gate_count` reached into S4's gate topology this slice forbids naming (§4.3). (2) Drop the field entirely until S4 — hides the dominant variance term and lets a reader treat the agent-compute range as total wall-clock. (3) Make the field optional — weakens the honesty signal to a maybe-present caveat.

**Choice as written.** A *required-but-qualitative* field: the dominant uncertainty is named on every record, in prose, without a fabricated number. "It claims no number at all, which is the honest position while its grounding lives downstream" (§6.3). The field shape itself encodes the decision — `agent_compute_time` is `{low, high}`, `human_gate_time` is a string.

**Consequences.** The record format now carries two time fields of *different shapes*, which every consumer and validator must special-case (the §8.2 checklist explicitly checks one is a range and one is not). It also defers a real numeric estimate to a future slice once S4 fixes the gate set — the field is a placeholder that has to be revisited, not a closed decision. Accepted as the honest position; the cost is a heterogeneous field set.

**Pattern.** Null Object's inverse — rather than a null or a fake default, a *named, speaking absence*: the field's job is to assert that the quantity exists and is deliberately not measured. Close to a documented "known unknown."

**Notes.** Descends from round-2 O2 (accepted, fixed via this demotion). The story records why the qualitative-caveat shape was chosen over the two numeric alternatives, which the objection disposition only gestures at.

## Story #4 — Per-axis confidence object over a single enum

**Source:** `docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md` (§4.2, §5.2)
**Lens:** patterns, alternatives
**Refs:** O2

**Context.** `confidence` is an object keyed `tokens`, `time`, and (only when cost is present) `cost`, each `low`/`medium`/`high` (§4.2). A whole-record summary "MAY be reported as `min()` of the present axes, but the per-axis values are authoritative" (§4.2). This replaced a single whole-record enum from the prior draft.

**Forces.** The tension is between *legibility of a single headline number* and *faithful representation of mixed grounding*. The token estimate can be spec-grounded and confident while the cost estimate rests on a stale, coarse snapshot — "a high-confidence token estimate and a low-confidence cost figure" (§4.2). A single enum forces these into one tier, and a `min()` collapse would drag a confident token range down to the weakest axis, hiding that the tokens are well-grounded.

**Options not taken.** (1) A single whole-record confidence enum — simpler to read and sort, but cannot express divergent per-axis grounding, "exactly the representation the single whole-record enum could not express" (§5.2). (2) A confidence field per *stage* rather than per *axis* — finer-grained but mixes the grounding-richness story (target_kind) with the per-stage token story. (3) Free-text confidence prose only, no structured tier — defeats the validation checkpoint.

**Choice as written.** Structured per-axis confidence with axis-specific rules: a `target_kind` ceiling for `tokens`/`time` (raw text capped at `low`), and an independent snapshot-quality rule for the conditional `cost` axis (§5.2). The axes are representable independently.

**Consequences.** The conditional `cost` axis is coupled to `cost_usd`'s conditional presence — `confidence.cost` exists iff `cost_usd` does, adding a cross-field invariant the validator must enforce. A consumer wanting one headline tier must compute the `min()` itself; the format deliberately does not pick one for them.

**Pattern.** Value Object decomposition — replacing a scalar with a structured value whose components carry independent meaning (cf. replacing a single status with a per-dimension health object). The axis-specific ceiling rule is a Specification-pattern constraint over the value's components.

**Notes.** This is the round-1 O4/O6 fix, confirmed resolved by the round-2 diaboli. Cross-referenced to O2 because the per-axis `time` confidence only describes `agent_compute_time` (Story #3) — the human-gate caveat carries no number to be confident about (§5.2).

## Story #5 — The tier-binding table as an authored artefact

**Source:** `docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md` (§6.2)
**Lens:** defaults, consequences
**Refs:** O3

**Context.** Cost derivation needs a `tier → model → $/token` map, because MODEL_ROUTING.md tiers are abstract labels with no model name and the snapshot is keyed by model name. The spec ships a named tier-binding table in the format reference that authors `Most capable → claude-opus-4`, `Standard → claude-sonnet-4`, and a widened split for the implementer (§6.2).

**Forces.** The tension is between *deriving the binding from a source* and *authoring it as a fixed artefact*. No source the methodology reads carries the tier→model mapping — MODEL_ROUTING.md has the tiers, the snapshot has the models, and nothing joins them. To compute cost at all, the join must be asserted *somewhere*. The spec chooses to assert it in a named, S6-maintained reference rather than leave it to per-estimate agent judgement.

**Options not taken.** (1) Let the agent pick the representative model per tier at estimate time — rejected because it "leaves the tier choice to agent discretion" (§6.1), reintroducing per-estimate divergence. (2) Add the model binding to MODEL_ROUTING.md itself so it lives at the routing source of truth — would make it derived rather than authored, but expands the scope into a file this slice does not own. (3) Derive a rate without a tier→model join — impossible given the two sources don't share a key.

**Choice as written.** A hand-authored binding table living "in a named place, not in agent judgement" (§6.2), explicitly flagged as "the artefact S6 may revise as routing evolves." The team accepts a known maintenance-drift surface in exchange for a single deterministic join point.

**Consequences.** A model rename or routing change between S1 and S6 silently breaks the snapshot join, with no S1–S5 mechanism keeping it aligned — a drift cost the human accepted as a documented residual (O3 disposition: re-verify at S2 implementation). The central honesty claim ("cost is grounded in observed actuals") rests on one ungrounded editorial assertion: that these specific model names represent these tiers.

**Pattern.** Adapter / anti-corruption layer (Evans, DDD) — the binding table is the translation seam between the routing domain's abstract tiers and the billing domain's concrete model keys. Also a lookup table as a Published Interface (the S6-revisable artefact).

**Notes.** Refs O3 (the accepted drift residual) and O5 (the round-1 split-tier widening this table enables). The cartographer records the *decision to author rather than derive*; the diaboli owns the *drift-failure* framing. Routing Rule applied: the decision is recorded here, the failure class stays in the objection record.

## Story #6 — No-verdict enforced by positive-content scanning

**Source:** `docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md` (§5.3)
**Lens:** patterns, forces
**Refs:** —

**Context.** The record "carries confidence; it does not carry a verdict" (§5.3). The spec makes this structural in two layers: field-absence (no `recommendation`/`verdict`/`proceed` field) *and* a positive-content scan that fails any record whose disclosure prose contains imperative or go/no-go language (§5.3).

**Forces.** The tension is between *trusting the emitter* and *enforcing the boundary in the format*. The S2 agent is meant to emit, not decide — but a verdict can be smuggled into free-text prose ("likely-overrun, so do not proceed") that passes every field-presence check. The spec resolves toward making the no-verdict guarantee "a property of the format itself, independent of any agent's good behaviour" (§5.3).

**Options not taken.** (1) Field-absence only — necessary but, as the spec admits, "not sufficient" because prose can carry a verdict (§5.3). (2) Rely on the agent's instructions to not recommend — trusts behaviour the format is trying to make structural. (3) Forbid free-text disclosure entirely and allow only enumerated values — would kill the interrogable disclosure prose that is the whole point of the contract.

**Choice as written.** A positive-content validation check that scans for prohibited imperative patterns ("so proceed", "I recommend", "you should [ship|skip|approve|reject]", "go/no-go") and fails the record (§5.3, §8.2). The guarantee is enforced on what the prose *says*, not just on which fields *exist*.

**Consequences.** The validator now depends on a pattern list that can never be exhaustive — a paraphrased verdict ("the smart move here is…") may slip past the enumerated patterns, so the check raises the bar without closing the gap completely. It also constrains legitimate disclosure prose, which must describe uncertainty in a register that avoids any imperative the scan might match. This is a trust-boundary mechanism enforced at validation time, mirroring the AGENTS.md agent-emit/human-disposes architecture in the format layer.

**Pattern.** Defence in depth (two independent layers for one guarantee). The positive-content scan is a denylist/Tolerant-Reader hybrid — structurally honest that it is a heuristic guard, not a proof.

**Notes.** Round-1 O12 fix, confirmed resolved by the round-2 diaboli. The story records the *two-layer enforcement choice* and its inherent incompleteness, which the resolved objection does not dwell on.

## Story #7 — Reusing the cost-snapshot format as ground

**Source:** `docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md` (§6.2, §6.5)
**Lens:** defaults, alternatives
**Refs:** —

**Context.** The prospective `cost-estimation` skill reads its $/token ground from the same `observability/costs/` snapshots the retrospective `cost-tracking` skill writes — "the two reuse the same data" (§6.5). The estimator derives a blended per-model rate from the snapshot's `## Model Breakdown` table.

**Forces.** The tension is between *reusing an existing retrospective format* and *defining a bespoke estimation-grounding format*. The snapshot was designed for human-readable quarterly spend capture, not for machine consumption by an estimator — its Model Breakdown is marked "(if available)" (§6.2) and aggregates models coarsely. Reusing it gives a single source of truth and a discoverable prospective/retrospective sibling pair; a bespoke format would fit estimation better but split cost data across two artefacts.

**Options not taken.** (1) Define a dedicated estimation-rate file the estimator owns — cleaner machine contract, but duplicates cost data and breaks the one-snapshot story. (2) Read provider list prices directly as ground — rejected wholesale (no list-price fallback, §6.2). (3) Wait for S6's per-PR actuals format and ground only on that — would leave cost ungroundable until the last slice.

**Choice as written.** The estimator consumes the retrospective sibling's existing output as its ground, accepting that output's optionality and coarseness as input-quality caveats it must disclose. The pair is made deliberately discoverable: "a reader who finds one should find the other" (§6.5), with the symmetry `/cost-capture` records spent : `/cost-estimate` predicts spend.

**Consequences.** The estimator inherits the snapshot's "(if available)" optionality directly into its grounding states (no snapshot / no usable breakdown / usable breakdown, §6.2), and the blended-rate derivation inherits the snapshot's input/output mix assumptions (the O4 residual). The estimator's accuracy is now coupled to a format it does not control and that is refreshed only quarterly.

**Pattern.** Shared Data integration (Hohpe/Woolf, *EIP*) — two components integrate through a common data store rather than a direct interface. Also a deliberate sibling-symmetry / discoverability pairing across the prospective/retrospective axis.

**Notes.** A largely silent choice — the spec presents the reuse as obvious rather than as a decision between reuse and a bespoke format. Worth recording because the coupling to the snapshot's shape and refresh cadence is inherited, not chosen at estimation time.

## Story #8 — A proposed contract, not an inherited decision

**Source:** `docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md` (§1, §5, §15)
**Lens:** coherence
**Refs:** #2

**Context.** The spec is emphatic — in the header table, §1, §5, §15, and the §14 resolution table — that the four-part disclosure body is "a contract THIS SPEC PROPOSES" and "not a pre-existing promoted AGENTS.md decision" (§5). A grep confirms no "disclosure-of-derived-judgment" decision exists. Yet the slicing record this spec descends from repeatedly cites exactly such a decision as governing the contract ("as required by the promoted AGENTS.md 'disclosure-of-derived-judgment' decision", slicing record §S1 scope and Context).

**Forces.** The tension is between *the slicing record's framing* and *the spec's corrected framing*. The slicing record was authored believing an AGENTS.md authority existed; the spec, after round-1 O1, discovered it does not and reframed the four-part body as a proposal serving the *real* "agent-emit + dispatcher-persist + human-disposes" ARCH_DECISION. The spec resolves the contradiction in its own favour but leaves the upstream slicing record carrying the now-falsified citation.

**Options not taken.** (1) Promote the disclosure contract to AGENTS.md first, then have the spec operationalise it — would make the slicing record's framing true, but inverts the order (the contract is being proposed *by* this spec, not promoted before it). (2) Strip the disclosure-contract framing and rely solely on the existing trust-architecture decision — loses the specific four-part structure that is S1's actual value. (3) Correct the slicing record to match — out of scope for a spec, but leaves a coherence gap across the two artefacts.

**Choice as written.** The spec chose to honestly re-label the contract as *proposed* and to serve the *existing* trust-architecture decision, even though this means the spec now contradicts the slicing record it descends from. The header table makes the re-labelling a first-class governing-decision note.

**Consequences.** Two living artefacts now disagree about whether the disclosure contract is governed by an existing decision: the slicing record asserts it is, the spec asserts it is not. A future reader reconciling them must know the spec's framing is the corrected one. If the disclosure contract is later promoted (a candidate `promoted` disposition for this very capability), the slicing record's citation becomes retroactively true — the inheritance gap would close from the wrong direction. This is a coherence flag across the spec/slicing boundary, not a failure within the spec.

**Pattern.** —

**Notes.** Coherence lens used sparingly and deliberately: the incoherence is visible only across the spec and its parent slicing record, not within the spec (which is internally consistent on this point). Refs Story #2 because the conditional-cost shape is the other place the spec corrected an inherited framing in this revision. This story is a strong candidate for a `promoted` disposition — promoting the four-part disclosure contract to AGENTS.md would resolve the inheritance contradiction at the source.
