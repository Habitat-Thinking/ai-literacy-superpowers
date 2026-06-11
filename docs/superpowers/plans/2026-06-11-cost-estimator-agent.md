# Cost Estimation — S2 — read-only cost-estimator agent — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship S2 of the cost-estimator capability — the **read-only
`cost-estimator` agent** that emits an estimate record (per the S1 format,
consumed **exactly as-merged**) and never decides. Build the agent at
`ai-literacy-superpowers/agents/cost-estimator.agent.md` with a `Read, Glob,
Grep` trust boundary, a defined input/target contract (with inference-basis
disclosure), the emit-not-write + refusal-string discipline (including the
readable-but-tableless `MODEL_ROUTING.md` refusal trigger), the **mechanical**
cost-omission rule, and the two **behaviour-only** folded-in S1 residuals
(binding-drift re-verification, blended-rate skew). Plugin version bumps
`0.41.0 → 0.42.0`.

**Revision note:** this plan was revised after the spec-mode diaboli pass (O1–O10,
all accepted). The central change: **S2 makes no change to the S1 format
reference.** The per-stage `tokens_by_stage[].cost_usd` sub-field that an earlier
draft folded in here is **split out to issue #377** (a dedicated format-revision
slice). S2 is a pure consumer of the merged S1 contract.

**This is slice 2 of a six-slice capability.** Downstream issues: S3 #370
(`/cost-estimate` command), S4 #371 (orchestrator T1/T2 fold-in), S5 #372 (T0
ballpark), S6 #373 (calibration loop). None ship here. S1 (the skill + format
reference) is already merged on main.

**Architecture:** A new agent file — a read-only derived-judgment emitter
mirroring `advocatus-diaboli` / `choice-cartographer` / `model-card-researcher`
(AGENTS.md "agent-emit + dispatcher-persist + human-disposes"). The agent loads
the S1 `cost-estimation` SKILL.md as reasoning context, reads `MODEL_ROUTING.md`
and the latest `observability/costs/` snapshot via `Read/Glob/Grep`, classifies
its target into a `target_kind`, applies the S1 methodology, and **returns the
estimate-record content as a string** conforming to the S1
`estimate-record-format.md` (referenced by path, not redefined). It writes
nothing — a dispatcher (S3/S4) persists after a human disposes. When it cannot
ground an estimate it returns a stable `REFUSED:` string (including when
`MODEL_ROUTING.md` reads as a file but its Token Budget Guidance / Agent Routing
tables are missing or unparseable — no token grounding = no honest estimate); an
empty cost snapshot is **not** a refusal (it emits a valid cost-omitted record).
Two **behaviour-only** S1 residuals fold in: binding-drift re-verification, where
the agent **omits `cost_usd` mechanically whenever ANY exercised stage's tier is
unmapped or otherwise ungrounded** (no "load-bearing" judgment — the agent stays
emit-not-decide); and the blended-rate-skew disclosure on cost-bearing records
(with a larger-magnitude precedence rule when failure-direction drivers conflict).
The third residual — the per-stage `cost_usd` **format-reference mutation** — is
**split out to #377** and is not part of S2; **S2 changes nothing in
`estimate-record-format.md`** and prices the split-tier widening into the
whole-record `cost_usd` band + prose only. The agent populates `generated_by`
honestly (resolved model id if the dispatcher supplies it, else the routing-tier
label `tier:Standard` — never a guessed model string), and discloses the
inference basis on any inferred `target_kind`.

**Tech Stack:** Markdown + JSON. No new dependencies, no code.

**Spec reference:** `docs/superpowers/specs/2026-06-11-cost-estimator-agent-design.md`

---

## Modules / files touched

```
ai-literacy-superpowers/
├── .claude-plugin/plugin.json                          # MODIFIED: 0.41.0 → 0.42.0
└── agents/
    └── cost-estimator.agent.md                          # NEW — read-only emitter agent
#   NOTE: skills/cost-estimation/references/estimate-record-format.md is NOT
#   touched — the per-stage cost_usd format change is split out to #377.

CHANGELOG.md                                              # MODIFIED: new 0.42.0 entry (repo root, not under the plugin dir)
MODEL_ROUTING.md                                          # MODIFIED: +cost-estimator Standard-tier Agent Routing row

tdad_tests/scenarios/agents/cost-estimator/
├── tool-boundary-and-charter.md                         # NEW — structural
├── emits-conforming-record.md                            # NEW — behavioural (cost-omitted, today's default; generated_by tier label; cost-snapshot grounding path)
├── classifies-target-kind.md                             # NEW — behavioural (ceiling per kind + inference-basis disclosure on inferred kinds)
├── inference-basis-disclosed.md                          # NEW — behavioural (O6: inferred discloses basis; explicit does not)
├── ambiguous-target-disclosed.md                         # NEW — behavioural (lower-grounding + disclosure)
├── refuses-ungroundable-target.md                        # NEW — behavioural (REFUSED string + O5 tableless-MODEL_ROUTING trigger)
├── empty-snapshot-not-refused.md                         # NEW — behavioural (cost-omitted, not REFUSED; O7 cost-snapshot path)
├── binding-drift-degrades.md                             # NEW — behavioural (O3/O4 MECHANICAL omit-on-any-unmapped-tier)
└── blended-rate-skew-surfaced.md                         # NEW — behavioural (O4/O2 disclosure + O10 precedence)
#   NOTE: no S1 skill scenario (format-and-contract.md) is modified — the
#   per-stage cost_usd change is split out to #377.

docs/plugins/ai-literacy-superpowers/
├── reference/<cost-estimator-agent>.md                  # NEW — agent reference page
└── explanation/prospective-cost-estimation.md           # MODIFIED — name the read-only emitter + refusal discipline

.claude-plugin/marketplace.json                           # MODIFIED: entry version + plugin_version 0.41.0 → 0.42.0
README.md                                                 # MODIFIED: plugin badge 0.41.0 → 0.42.0
```

Top-level marketplace `version` stays at `0.4.0`. No command or orchestrator
file touched.

---

## Algorithm / key decisions (not pseudocode)

- **Read-only by tool boundary (load-bearing).** Tools are **exactly** `Read,
  Glob, Grep`. No `Write`, no `Edit`, no `Bash`. The agent cannot persist the
  record — that enforces "emits, never decides" by construction (spec §3.2). The
  agent file stays `model: inherit`; routing is recorded in `MODEL_ROUTING.md`.
- **Emit a string, never write.** Deliverable is the estimate-record content as
  the agent's final message (frontmatter + four-part body), conforming to the S1
  format. The agent does not name the on-disk path or validate — that is the
  dispatcher's (S3/S4) job (spec §5.1). Mirrors choice-cartographer /
  model-card-researcher.
- **Reference S1 exactly as-merged, do not redefine OR extend.** The agent loads
  `skills/cost-estimation/SKILL.md` as reasoning context and emits a record per
  `skills/cost-estimation/references/estimate-record-format.md`, referenced by
  path. **S2 makes no change to the reference** — the per-stage `cost_usd`
  sub-field is split out to #377 (spec §2.3, §6.1). If the agent file or any task
  edits `estimate-record-format.md`, that is a defect.
- **Target/`target_kind` contract (new S2 surface).** Accepts task-text / slicing
  record / slice / spec; classifies via explicit-kind → content-inference →
  task-text default; ambiguity resolves to the **lower-grounding** kind and is
  **disclosed** in `Confidence rationale`, never silently up-classified. The kind
  drives the S1 confidence ceiling (spec §4).
- **Inference-basis disclosure (O6).** On any **inferred** (non-explicit)
  `target_kind`, the agent discloses the basis in `Confidence rationale`
  ("classified as `<kind>` by `<signal>`"), even with no detected ambiguity, so a
  confident mis-read that up-classifies the ceiling is human-catchable. An
  **explicit** dispatch-stated kind needs no such disclosure (spec §4.2).
- **`generated_by` provenance (O3, honest).** The agent runs `model: inherit` and
  is not told its resolved model. It records `cost-estimator / <resolved-id>` iff
  the dispatcher supplies a resolved model id, else the routing-tier label
  `cost-estimator / tier:Standard` — **never** a guessed/hard-coded model string
  (spec §5.4, §7).
- **Refusal-string convention.** A stable `REFUSED:` prefix on an unreadable,
  unclassifiable, or token-grounding-absent target — **including (O5)
  `MODEL_ROUTING.md` readable-as-a-file but with its Token Budget Guidance / Agent
  Routing tables missing or unparseable** (no token grounding = no honest
  estimate). The dispatcher detects the prefix and declines to persist (the
  *convention* is S2's; the *check* is S3/S4's). Mirrors model-card-researcher
  (spec §5.2).
- **Empty cost snapshot is NOT a refusal.** Per the S1 three grounding states, an
  empty `observability/costs/` yields a valid cost-omitted record. Refusal is
  reserved for ungroundable *targets* / absent-or-unparseable token grounding,
  never for an honestly-omittable cost (spec §5.3). This is the single most likely
  implementation error to guard against. **Cost-omitted grounding path (O7):** the
  mandatory `cost-snapshot` grounding entry is present with `path` =
  `observability/costs/` (the directory inspected), never dropped, never a
  fabricated file path (spec §5.3).
- **O3/O4 fold-in (MECHANICAL agent obligation).** At cost time the agent confirms
  every tier exercised by the target's stage set is mapped by the binding table
  and the snapshot has the named model keys; the omission rule is **mechanical —
  omit `cost_usd` whenever ANY exercised stage's tier is unmapped or otherwise
  ungrounded, with NO "load-bearing" judgment**. It discloses the cause, never
  edits the binding, never invents a rate (spec §6.2). The earlier discretionary
  "load-bearing" test is removed (O4) so the agent stays emit-not-decide.
- **O4/O2 fold-in (disclosure obligation).** On cost-present records the agent
  names the blended input/output rate simplification in the disclosure and
  accounts for it in `failure_direction`; it never reintroduces a per-direction
  rate (spec §6.3). **Precedence on conflict (O10):** name every driver in prose;
  set the single enum to the larger-magnitude driver (or `symmetric` when equal).
- **Per-stage `cost_usd` widening is SPLIT OUT to #377 — NOT in S2.** S2 prices
  the split-tier widening into the **whole-record `cost_usd` band** and discloses
  it in prose; it emits no machine-checkable per-stage cost band and changes
  nothing in the format reference (spec §6.1).
- **Behavioural grading (O9).** The behavioural scenarios grade a non-deterministic
  `model: inherit` dispatch via **deterministic oracles**: fixture-pinned grounding
  inputs + frontmatter conformance parse + presence/absence of named fields/markers
  + `REFUSED:` prefix on ungroundable fixtures. They never assert exact token
  numbers or prose wording — only properties that hold across any conforming model
  output (spec §8). A scenario that no oracle can grade is descoped, not
  rubber-stamped.
- **No-verdict, two layers.** The emitted record carries no verdict/recommendation/
  proceed field and no imperative recommendation or go/no-go prose — the agent
  honours the S1 two-layer guarantee (spec §10 FR-12).
- **MODEL_ROUTING row at Standard.** Read-and-author against a fixed methodology,
  not deep adversarial judgment — Standard tier, like tdd-agent (spec §7).

---

## FR mapping table

| FR | Requirement (abbrev) | Covering test case(s) |
| --- | --- | --- |
| FR-1 | Agent file present; tools exactly Read, Glob, Grep | `tool-boundary-and-charter.md` (structural) |
| FR-2 | Charter: emits string, never writes/validates/decides; cites agent-emit + ordering invariant | `tool-boundary-and-charter.md` |
| FR-3 | Loads S1 SKILL; emits per S1 format, referenced not redefined | `tool-boundary-and-charter.md` + `emits-conforming-record.md` |
| FR-4 | Accepts 4 target types; classifies target_kind per rule | `classifies-target-kind.md` |
| FR-5 | target_kind drives S1 confidence ceiling; never exceeded | `classifies-target-kind.md` |
| FR-6 | Ambiguous → lower-grounding + disclosed, never up-classified | `ambiguous-target-disclosed.md` |
| FR-6a | O6: inferred target_kind discloses basis; explicit needs none | `inference-basis-disclosed.md` + `classifies-target-kind.md` |
| FR-7 | Unreadable/unclassifiable/no-or-unparseable-token-grounding (incl. O5 tableless MODEL_ROUTING) → REFUSED, no fabrication | `refuses-ungroundable-target.md` |
| FR-8 | Empty observability/costs → cost-omitted record, NOT a refusal | `empty-snapshot-not-refused.md` + `emits-conforming-record.md` |
| FR-8a | O7: cost-omitted cost-snapshot grounding entry path = `observability/costs/` dir; never dropped/fabricated | `empty-snapshot-not-refused.md` + `emits-conforming-record.md` |
| FR-8b | O3: generated_by = resolved id iff supplied, else `tier:Standard`; never a guessed model | `emits-conforming-record.md` |
| FR-9 | **SPLIT OUT to #377** — per-stage `cost_usd` format change; S2 changes nothing in the reference | (no S2 test — #377 owns it) |
| FR-10 | O3/O4 MECHANICAL: omit cost_usd whenever ANY exercised tier unmapped/ungrounded (no "load-bearing" judgment); never edit binding | `binding-drift-degrades.md` |
| FR-11 | O4/O2: surface blended-rate skew on cost-present records + in failure_direction | `blended-rate-skew-surfaced.md` |
| FR-11a | O10: name all drivers in prose; enum = larger-magnitude (or symmetric) | `blended-rate-skew-surfaced.md` |
| FR-12 | No verdict/recommendation field or go/no-go prose in emitted record | `emits-conforming-record.md` |
| FR-13 | MODEL_ROUTING.md cost-estimator Standard-tier row | local check (Task 5) |
| FR-14 | TDAD structural + behavioural scenarios present, graded by deterministic oracles (O9); NO S1 scenario modified | all scenario files exist |
| FR-15 | Version bump 0.42.0 across four locations | local version-consistency check (Task 6) |
| FR-16 | Docs reference + how-to/explanation touch | docs-reference-parity check (Task 7) |

---

## Test case list

(In the same form as the existing TDAD agent scenario corpus — `Given/When/Then`
markdown scenarios under `tdad_tests/scenarios/agents/cost-estimator/`. The
structural scenario is Layer 1 ($0, every PR); the behavioural scenarios are
Layer 3 (nightly + label-gated), graded by the deterministic oracle strategy of
spec §8 so they fail honestly against a non-deterministic dispatch (O9). One
structural + eight behavioural = nine scenarios. **No S1 skill scenario is
modified** — the per-stage `cost_usd` format change is split out to #377.)

- `tool-boundary-and-charter.md` (tier: structural) — frontmatter well-formed;
  `tools` is exactly `Read, Glob, Grep` (no Write/Edit/Bash); charter states
  emits-a-string / never-writes / never-validates / never-decides; references the
  agent-emit + dispatcher-persist + human-disposes decision and the
  dispose-then-write ordering invariant; the input/target-contract, refusal, and
  S1-residual sections are present; the agent references the S1 SKILL and format
  reference by path and does not inline a competing field definition.
- `emits-conforming-record.md` (tier: behavioural) — dispatched against a real
  spec target (explicit `target_kind: spec`) with `MODEL_ROUTING.md` readable and
  `observability/costs/` empty, returns a markdown string with YAML frontmatter +
  four-part body conforming to the S1 field set; cost omitted with `Excluded`
  disclosure; the `cost-snapshot` grounding entry present with path
  `observability/costs/` (O7); `generated_by` = `cost-estimator / tier:Standard`
  (no resolved id supplied; O3); confidence object has tokens/time but no cost
  axis; no inference-basis line (kind was explicit); **no** verdict/recommendation/
  proceed field or go/no-go prose. Graded by conformance parse + presence/absence
  oracles (O9).
- `classifies-target-kind.md` (tier: behavioural) — task-text → `task-text`,
  ceiling `low`; slicing record → `slicing-record`, ceiling ≤ `medium`; spec →
  `spec`, may reach `high`. The confidence axes never exceed the ceiling; each
  **inferred** kind carries an inference-basis line in `Confidence rationale`.
- `inference-basis-disclosed.md` (tier: behavioural, O6) — a no-stated-kind path
  the agent confidently classifies carries an inference-basis line
  ("classified as `<kind>` by `<signal>`") even with no detected ambiguity; the
  same path with an explicit dispatch-stated kind carries **no** inference-basis
  line.
- `ambiguous-target-disclosed.md` (tier: behavioural) — a path matching neither a
  clear slicing record nor a clear spec resolves to the lower-grounding candidate
  kind; the ambiguity is disclosed in `Confidence rationale`; the ceiling is the
  lower candidate's.
- `refuses-ungroundable-target.md` (tier: behavioural) — an unreadable target (or
  `MODEL_ROUTING.md` unreadable) returns a string beginning `REFUSED:` naming
  reason / target / grounding-read and stating no record should be written; no
  fabricated estimate record. **Plus the O5 trigger:** `MODEL_ROUTING.md`
  readable-as-a-file but with its Token Budget Guidance / Agent Routing tables
  missing/unparseable also returns `REFUSED:` (no fabricated token ranges), and
  this is distinct from the empty-snapshot cost-omitted case. Graded by the
  `REFUSED:` prefix oracle (O9).
- `empty-snapshot-not-refused.md` (tier: behavioural) — a valid target with
  readable `MODEL_ROUTING.md` and empty `observability/costs/` returns a valid
  cost-omitted record, **not** a `REFUSED` string; the `cost-snapshot` grounding
  entry's path is the directory `observability/costs/` (O7);
  tokens/agent_compute_time are ranges; human_gate_time is the qualitative caveat
  string.
- `binding-drift-degrades.md` (tier: behavioural, O3/O4 MECHANICAL) — when a named
  model key is absent from the snapshot Model Breakdown, the agent omits
  `cost_usd` with a disclosure naming the missing key, and does not invent a rate;
  when `MODEL_ROUTING.md` carries an **exercised** unmapped tier, the agent
  **omits `cost_usd` regardless of whether the tier appears "load-bearing"** — the
  rule is mechanical (ANY exercised unmapped tier triggers omission) and the agent
  makes no discretionary salience judgment.
- `blended-rate-skew-surfaced.md` (tier: behavioural, O4/O2/O10) — on a
  cost-present record the disclosure names the single blended $/token
  (input+output collapsed) and its skew when the task mix diverges from the
  snapshot quarter; `failure_direction` accounts for it; no per-direction rate is
  reintroduced. **On conflicting drivers (O10)** the prose names every driver and
  the enum is set to the larger-magnitude driver (or `symmetric` when equal).

---

## Phase 1 — The agent

### Task 1: Write the cost-estimator agent

- [ ] Create `ai-literacy-superpowers/agents/cost-estimator.agent.md`.
- [ ] Frontmatter: `name: cost-estimator`; `description` (use after/when a
  prospective estimate is wanted against a target; read-only emitter); `tools:
  [Read, Glob, Grep]`; `model: inherit`.
- [ ] Body sections:
  - **Charter** — read-only derived-judgment emitter; emits a string; never
    writes/validates/decides (spec §3.1, FR-2).
  - **Your first action** — load the S1 `cost-estimation` SKILL.md
    (`ai-literacy-superpowers/skills/cost-estimation/SKILL.md`) as reasoning
    context and the format reference by path (FR-3).
  - **Trust boundary** — Read/Glob/Grep only; the mechanism, not a limitation;
    the dispose-then-write ordering invariant is the dispatcher's, downstream
    (spec §3.2, FR-1/FR-2).
  - **Input / target contract** — the four target types and the `target_kind`
    classification rule (explicit → inference → task-text default; ambiguity →
    lower-grounding + disclose) (spec §4, FR-4/FR-5/FR-6).
  - **Grounding** — read `MODEL_ROUTING.md` (Token Budget Guidance + Agent
    Routing) and the latest `observability/costs/` snapshot; apply the S1 three
    grounding states; the O3 binding re-verification at cost time (FR-10).
  - **Emit-not-write + refusal** — return the record as the final message; the
    `REFUSED:` convention and its trigger conditions; the empty-snapshot-is-not-
    a-refusal rule (spec §5, FR-7/FR-8).
  - **Disclosure obligations** — populate the four-part disclosure honestly
    (disclosure-of-derived-judgment); the O4/O2 blended-rate-skew surfacing on
    cost-present records (FR-11); the two-layer no-verdict guarantee (FR-12).
  - **Anti-patterns** — fabricating a record instead of refusing; writing a file
    (no Write tool); refusing on an empty cost snapshot; pricing against a stale
    binding; reintroducing a per-direction rate; emitting verdict/recommendation
    prose.

---

## Phase 2 — (REMOVED) the per-stage `cost_usd` format change is split out to #377

> **Was:** "Add optional `tokens_by_stage[].cost_usd` to the S1 reference."
> **Now:** this is a mutation of the merged S1 format reference and is **out of
> scope for S2** (O1/O2/O8). It moves to issue **#377** (the format-revision
> slice), which gets its own diaboli pass demonstrating backward-compatibility
> against the actual validator semantics. **S2 makes no edit to
> `estimate-record-format.md` and updates no S1 skill scenario.** There is no
> Task 2 in S2. (Phase/Task numbers below are intentionally left as-is so this
> revision note stays visible; the implementer skips straight to Phase 3.)

---

## Phase 3 — TDAD scenarios

### Task 3: Author the structural + behavioural scenarios

- [ ] Create the nine scenario files under
  `tdad_tests/scenarios/agents/cost-estimator/` per the test case list and the
  corpus format in `tdad_tests/README.md` (one structural, eight behavioural).
  Do **not** modify any `tdad_tests/scenarios/skills/cost-estimation/` scenario —
  the format change is #377's.
- [ ] Each behavioural scenario pins its grounding fixtures and is graded by the
  deterministic oracle strategy (spec §8, O9): frontmatter conformance parse,
  presence/absence of named fields/markers, `REFUSED:` prefix on ungroundable
  fixtures — never exact numbers or prose wording.
- [ ] These are the RED-phase deliverables of the tdd-agent's agent-artefact
  branch; the spec §8/§9 fixes their `Then` shape.

---

## Phase 4 — Routing + docs

### Task 4: MODEL_ROUTING.md row

- [ ] Add a `cost-estimator` row to the `MODEL_ROUTING.md` Agent Routing table at
  the **Standard** tier with the read-and-author rationale (spec §7).

### Task 5: Docs

- [ ] Add a reference page for the `cost-estimator` agent under
  `docs/plugins/ai-literacy-superpowers/reference/` (charter, tool boundary,
  input/target contract, refusal convention).
- [ ] Extend `docs/plugins/ai-literacy-superpowers/explanation/prospective-cost-estimation.md`
  to describe the read-only emitter and the emit-not-write + refusal discipline,
  linking the S1 skill and format reference. Satisfies docs-reference-parity.

---

## Phase 5 — Version bumps

### Task 6: Bump plugin.json, CHANGELOG, marketplace.json, README

- [ ] `ai-literacy-superpowers/.claude-plugin/plugin.json`: `version` `0.41.0` →
  `0.42.0`.
- [ ] `CHANGELOG.md` (repo root): new `## 0.42.0 — 2026-06-11`
  heading with entries for the new agent (read-only emitter, tool boundary,
  input/target contract with inference-basis disclosure, mechanical
  cost-omission rule, refusal discipline incl. the tableless-MODEL_ROUTING
  trigger, honest `generated_by` provenance), the MODEL_ROUTING row, and the
  docs. **Do not** list any format-reference change — there is none (split out to
  #377).
- [ ] `.claude-plugin/marketplace.json`: bump the `ai-literacy-superpowers`
  `plugins[]` entry `version` and the top-level `plugin_version` to `0.42.0`;
  leave top-level `version` at `0.4.0`.
- [ ] `README.md`: bump the `ai-literacy-superpowers` badge `v0.41.0` → `v0.42.0`.
- [ ] Verify version consistency:

```bash
python3 -c "
import json
pj = json.load(open('ai-literacy-superpowers/.claude-plugin/plugin.json'))
m = json.load(open('.claude-plugin/marketplace.json'))
entry = next(p for p in m['plugins'] if p['name']=='ai-literacy-superpowers')
assert pj['version']=='0.42.0', pj['version']
assert entry['version']=='0.42.0', entry['version']
assert m['plugin_version']=='0.42.0', m['plugin_version']
assert m['version']=='0.4.0', m['version']
print('version consistency OK')
"
```

---

## Phase 6 — Verify and ship

### Task 7: Local CI gate checks

- [ ] Spec-first ordering — first commit on branch is the spec:

```bash
git log main..HEAD --reverse --oneline | head -1
```

- [ ] TDAD scenario presence — the new agent ships with scenarios:

```bash
ls tdad_tests/scenarios/agents/cost-estimator/*.md
```

- [ ] Markdown lint, docs build, and the deterministic TDAD fast suite
  (Layers 0+1) pass.

### Task 8: Push, PR, CI, merge

- [ ] Push the `cost-estimator-s2-agent` branch, open a PR against #369 (feature
  ceremony — `/diaboli` spec runs on this spec next; code-mode runs after the
  code-reviewer PASS).
- [ ] PR body states what ships (agent + nine scenarios + MODEL_ROUTING row +
  docs + version bump) and what does NOT (S3–S6, issues #370–#373; **and the
  per-stage `cost_usd` format change, split out to #377**). State explicitly that
  S2 makes no change to `estimate-record-format.md`.
- [ ] Watch CI green; merge `--squash --delete-branch`; sync the marketplace
  cache.

---

## Out of scope (deferred to S3–S6)

- The `/cost-estimate` command, the on-disk record path, and the Output
  Validation Checkpoint against the format (S3, #370). The agent returns a
  string; the command persists and validates it.
- Orchestrator fold-in at T1 (Slice Adjudication) and T2 (Plan Approval) (S4,
  #371). No orchestrator change; no gate added or re-weighted. The gate
  topology that would ground `human_gate_time` numerically remains S4's.
- The T0 pre-carpaccio ballpark (S5, #372). The agent accepts a `task-text`
  target, but the firing position and bonus-step wiring are S5's.
- The calibration loop — per-PR actuals capture and the integration-agent change
  (S6, #373). The agent reads a `kind: calibration` grounding source if one
  exists (per the S1 seam) but neither produces nor requires it.
- Any standalone runtime validator of emitted records — the S3 command's
  checkpoint does that, not a validator shipped here.
- **The per-stage `tokens_by_stage[].cost_usd` sub-field and any change to
  `estimate-record-format.md`** (#377, the format-revision slice). S2 consumes the
  S1 format exactly as-merged; the machine-checkable per-stage cost band is #377's
  deliverable, demonstrated backward-compatible under its own diaboli pass.
