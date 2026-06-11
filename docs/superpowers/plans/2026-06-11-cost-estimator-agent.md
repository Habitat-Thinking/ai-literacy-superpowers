# Cost Estimation — S2 — read-only cost-estimator agent — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship S2 of the cost-estimator capability — the **read-only
`cost-estimator` agent** that emits an estimate record (per the S1 format) and
never decides. Build the agent at
`ai-literacy-superpowers/agents/cost-estimator.agent.md` with a `Read, Glob,
Grep` trust boundary, a defined input/target contract, the emit-not-write +
refusal-string discipline, and the three folded-in S1 residuals (O6/O3/O4).
Plugin version bumps `0.41.0 → 0.42.0`.

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
ground an estimate it returns a stable `REFUSED:` string; an empty cost snapshot
is **not** a refusal (it emits a valid cost-omitted record). Three S1 residuals
fold in: O6 adds a backward-compatible optional `tokens_by_stage[].cost_usd`
sub-field to the S1 reference so the split-tier widening is machine-checkable;
O3 makes the agent re-verify the binding against `MODEL_ROUTING.md` + the
snapshot at cost time and degrade to cost-omission on drift; O4/O2 makes the
agent surface the blended-rate skew on cost-bearing records.

**Tech Stack:** Markdown + JSON. No new dependencies, no code.

**Spec reference:** `docs/superpowers/specs/2026-06-11-cost-estimator-agent-design.md`

---

## Modules / files touched

```
ai-literacy-superpowers/
├── .claude-plugin/plugin.json                          # MODIFIED: 0.41.0 → 0.42.0
├── CHANGELOG.md                                         # MODIFIED: new 0.42.0 entry
├── agents/
│   └── cost-estimator.agent.md                          # NEW — read-only emitter agent
└── skills/cost-estimation/references/
    └── estimate-record-format.md                        # MODIFIED (O6): +optional tokens_by_stage[].cost_usd (backward-compatible)

MODEL_ROUTING.md                                          # MODIFIED: +cost-estimator Standard-tier Agent Routing row

tdad_tests/scenarios/agents/cost-estimator/
├── tool-boundary-and-charter.md                         # NEW — structural
├── emits-conforming-record.md                            # NEW — behavioural (cost-omitted, today's default)
├── classifies-target-kind.md                             # NEW — behavioural (ceiling per kind)
├── ambiguous-target-disclosed.md                         # NEW — behavioural (lower-grounding + disclosure)
├── refuses-ungroundable-target.md                        # NEW — behavioural (REFUSED string)
├── empty-snapshot-not-refused.md                         # NEW — behavioural (cost-omitted, not REFUSED)
├── widening-verifiable.md                                # NEW — behavioural (O6 per-stage cost_usd)
├── binding-drift-degrades.md                             # NEW — behavioural (O3 degrade-to-omission)
└── blended-rate-skew-surfaced.md                         # NEW — behavioural (O4/O2 disclosure)

tdad_tests/scenarios/skills/cost-estimation/
└── format-and-contract.md                               # MODIFIED (O6): assert optional per-stage cost_usd is additive

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
- **Reference S1, do not redefine.** The agent loads
  `skills/cost-estimation/SKILL.md` as reasoning context and emits a record per
  `skills/cost-estimation/references/estimate-record-format.md`, referenced by
  path. The only S1 change is the additive O6 sub-field (spec §2.3).
- **Target/`target_kind` contract (new S2 surface).** Accepts task-text / slicing
  record / slice / spec; classifies via explicit-kind → content-inference →
  task-text default; ambiguity resolves to the **lower-grounding** kind and is
  **disclosed** in `Confidence rationale`, never silently up-classified. The kind
  drives the S1 confidence ceiling (spec §4).
- **Refusal-string convention.** A stable `REFUSED:` prefix on an unreadable,
  unclassifiable, or token-grounding-absent target; the dispatcher detects it and
  declines to persist (the *convention* is S2's; the *check* is S3/S4's). Mirrors
  model-card-researcher (spec §5.2).
- **Empty cost snapshot is NOT a refusal.** Per the S1 three grounding states, an
  empty `observability/costs/` yields a valid cost-omitted record. Refusal is
  reserved for ungroundable *targets* / absent token grounding, never for an
  honestly-omittable cost (spec §5.3). This is the single most likely
  implementation error to guard against.
- **O6 fold-in (backward-compatible).** Add an **optional** `tokens_by_stage[].cost_usd`
  `{low, high}` range to the S1 reference, present iff top-level `cost_usd` is
  present. Records without it stay valid. The agent populates it on cost-present
  records so a validator can assert the implementer band spans two rates
  (sonnet-4 low, opus-4 high). Extend the S1 cost-present worked example; add a
  validation-checklist line (spec §6.1).
- **O3 fold-in (agent obligation, bounded).** At cost time the agent confirms
  `MODEL_ROUTING.md` tiers match the binding table and the snapshot has the named
  model keys; on drift it **degrades to cost-omission-with-disclosure** (naming
  the cause) and never edits the binding or invents a rate (spec §6.2).
- **O4/O2 fold-in (disclosure obligation).** On cost-present records the agent
  names the blended input/output rate simplification in the disclosure and
  accounts for it in `failure_direction`; it never reintroduces a per-direction
  rate (spec §6.3).
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
| FR-7 | Unreadable/unclassifiable/no-token-grounding → REFUSED string, no fabrication | `refuses-ungroundable-target.md` |
| FR-8 | Empty observability/costs → cost-omitted record, NOT a refusal | `empty-snapshot-not-refused.md` + `emits-conforming-record.md` |
| FR-9 | O6: backward-compatible optional `tokens_by_stage[].cost_usd`; verifiable widening | `widening-verifiable.md` + `format-and-contract.md` (S1 scenario update) |
| FR-10 | O3: re-verify binding at cost time; degrade to cost-omission on drift; never edit binding | `binding-drift-degrades.md` |
| FR-11 | O4/O2: surface blended-rate skew on cost-present records + in failure_direction | `blended-rate-skew-surfaced.md` |
| FR-12 | No verdict/recommendation field or go/no-go prose in emitted record | `emits-conforming-record.md` |
| FR-13 | MODEL_ROUTING.md cost-estimator Standard-tier row | local check (Task 5) |
| FR-14 | TDAD structural + behavioural scenarios present; S1 scenario updated for O6 | all scenario files exist |
| FR-15 | Version bump 0.42.0 across four locations | local version-consistency check (Task 6) |
| FR-16 | Docs reference + how-to/explanation touch | docs-reference-parity check (Task 7) |

---

## Test case list

(In the same form as the existing TDAD agent scenario corpus — `Given/When/Then`
markdown scenarios under `tdad_tests/scenarios/agents/cost-estimator/`. The
structural scenario is Layer 1 ($0, every PR); the behavioural scenarios are
Layer 3 (nightly + label-gated).)

- `tool-boundary-and-charter.md` (tier: structural) — frontmatter well-formed;
  `tools` is exactly `Read, Glob, Grep` (no Write/Edit/Bash); charter states
  emits-a-string / never-writes / never-validates / never-decides; references the
  agent-emit + dispatcher-persist + human-disposes decision and the
  dispose-then-write ordering invariant; the input/target-contract, refusal, and
  S1-residual sections are present; the agent references the S1 SKILL and format
  reference by path and does not inline a competing field definition.
- `emits-conforming-record.md` (tier: behavioural) — dispatched against a real
  spec target with `MODEL_ROUTING.md` readable and `observability/costs/` empty,
  returns a markdown string with YAML frontmatter + four-part body conforming to
  the S1 field set; `target_kind: spec`; cost omitted with `Excluded` disclosure;
  confidence object has tokens/time but no cost axis; **no** verdict/recommendation/
  proceed field or go/no-go prose.
- `classifies-target-kind.md` (tier: behavioural) — task-text → `task-text`,
  ceiling `low`; slicing record → `slicing-record`, ceiling ≤ `medium`; spec →
  `spec`, may reach `high`. The confidence axes never exceed the ceiling.
- `ambiguous-target-disclosed.md` (tier: behavioural) — a path matching neither a
  clear slicing record nor a clear spec resolves to the lower-grounding candidate
  kind; the ambiguity is disclosed in `Confidence rationale`; the ceiling is the
  lower candidate's.
- `refuses-ungroundable-target.md` (tier: behavioural) — an unreadable target (or
  `MODEL_ROUTING.md` unreadable) returns a string beginning `REFUSED:` naming
  reason / target / grounding-read and stating no record should be written; no
  fabricated estimate record is returned.
- `empty-snapshot-not-refused.md` (tier: behavioural) — a valid target with
  readable `MODEL_ROUTING.md` and empty `observability/costs/` returns a valid
  cost-omitted record, **not** a `REFUSED` string; tokens/agent_compute_time are
  ranges; human_gate_time is the qualitative caveat string.
- `widening-verifiable.md` (tier: behavioural) — against a target with a usable
  snapshot, each `tokens_by_stage` entry carries an optional `cost_usd` range
  present iff top-level `cost_usd` is present; for the implementer
  (`Standard/Capable`) stage `cost_usd.low` is the sonnet-4 rate and `cost_usd.high`
  the opus-4 rate so `low < high`.
- `binding-drift-degrades.md` (tier: behavioural) — when a named model key is
  absent from the snapshot Model Breakdown, the agent omits `cost_usd` with a
  disclosure naming the missing key, and does not invent a rate; when
  `MODEL_ROUTING.md` carries an unmapped tier, the agent discloses it and omits
  cost if the tier is load-bearing.
- `blended-rate-skew-surfaced.md` (tier: behavioural) — on a cost-present record
  the disclosure names the single blended $/token (input+output collapsed) and
  its skew when the task mix diverges from the snapshot quarter; `failure_direction`
  accounts for it; no per-direction rate is reintroduced.
- `format-and-contract.md` (tier: structural, **S1 scenario UPDATE**) — extend the
  existing S1 skill structural scenario to assert the `tokens_by_stage[].cost_usd`
  sub-field is **optional and additive** (records without it remain valid) and
  that the cost-present worked example now shows the per-stage cost band.

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

## Phase 2 — The O6 format-reference fold-in (backward-compatible)

### Task 2: Add optional `tokens_by_stage[].cost_usd` to the S1 reference

- [ ] In `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`:
  - Add `tokens_by_stage[].cost_usd` to the field description as **optional**,
    present **iff** the top-level `cost_usd` is present; note the whole-record
    `cost_usd` need not equal the per-stage sum (correlation caveat).
  - Extend the **cost-present worked example** (Example 2) to carry per-stage
    `cost_usd`, with the implementer stage's band priced low at `claude-sonnet-4`
    and high at `claude-opus-4` so the widening is visible.
  - Add a **validation-checklist** line: per-stage `cost_usd` present iff
    top-level present; slashed-tier stages show `low < high`. Keep all existing
    checks and the cost-omitted example unchanged (backward-compatible).
- [ ] Update the S1 structural scenario
  `tdad_tests/scenarios/skills/cost-estimation/format-and-contract.md` to assert
  the sub-field is optional/additive (records without it remain valid).

---

## Phase 3 — TDAD scenarios

### Task 3: Author the structural + behavioural scenarios

- [ ] Create the nine scenario files under
  `tdad_tests/scenarios/agents/cost-estimator/` per the test case list and the
  corpus format in `tdad_tests/README.md` (one structural, eight behavioural).
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
- [ ] `ai-literacy-superpowers/CHANGELOG.md`: new `## 0.42.0 — 2026-06-11`
  heading with entries for the agent, the O6 format-reference addition, the
  MODEL_ROUTING row, and the docs.
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
- [ ] PR body states what ships (agent + O6 format addition + scenarios +
  MODEL_ROUTING row + docs + version bump) and what does NOT (S3–S6, issues
  #370–#373).
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
