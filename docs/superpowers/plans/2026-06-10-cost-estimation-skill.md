# Cost Estimation — S1 — cost-estimation skill + estimate-record format — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship S1 of the cost-estimator capability — the `cost-estimation` skill, the estimate-record format reference, and a TDAD scenario for the skill. This slice ships the methodology and the format contract that S2–S6 consume. No agent, no command, no orchestrator wiring. Plugin version bumps `0.40.0 → 0.41.0`.

**Architecture:** A new skill (methodology + disclosure contract as loadable prose) plus a references file (the estimate-record format as a stable contract, one contract per file per the AGENTS.md references-file idiom). The format reference is the artefact the downstream S3 command's Output Validation Checkpoint references by path. The day-one deliverable is a **token + time estimate**, both grounded from `MODEL_ROUTING.md` (token budgets + tier mapping). The dollar figure is **actuals-gated**: `cost_usd` is present only when an `observability/costs/` snapshot supplies a usable per-model $/token rate (via a named tier→model→$/token binding table); otherwise it is **omitted with disclosure** — there is no list-price fallback. Every present quantitative figure is a range; confidence is recorded **per axis** (`tokens`/`time`/conditional `cost`); the time field is split into agent-compute (a numeric range) vs human-gate latency, with `human_gate_time` carried as a **qualitative caveat, not estimated numerically at S1** (its grounding — the orchestrator gate set — is S4 scope, #371). The no-verdict guarantee is structural in two layers (no verdict field + a positive-content check forbidding recommendation prose). The calibration seam (S6) is kept open via a `kind: calibration` grounding-source value without being implemented.

**Revision note:** This plan reflects the post-diaboli revision in which all 12 objections (O1–O12) were adjudicated `accepted`. The central restructure — `cost_usd` optional-until-actuals (O11, resolving O2/O3/O4) — changes the schema from a required dollar field to a conditional one and removes the list-price fallback. The disclosure body is now framed as a contract this spec proposes, not a pre-existing AGENTS.md decision (O1).

**Tech Stack:** Markdown + JSON. No new dependencies, no code.

**This is one slice of a six-slice capability.** Downstream issues: S2 #369 (read-only agent), S3 #370 (`/cost-estimate` command), S4 #371 (orchestrator T1/T2 fold-in), S5 #372 (T0 ballpark), S6 #373 (calibration loop). None of them ship here.

**Spec reference:** `docs/superpowers/specs/2026-06-10-cost-estimation-skill-design.md`

---

## Modules / files touched

```
ai-literacy-superpowers/
├── .claude-plugin/plugin.json                          # MODIFIED: 0.40.0 → 0.41.0
├── CHANGELOG.md                                         # MODIFIED: new 0.41.0 entry
└── skills/cost-estimation/
    ├── SKILL.md                                         # NEW — methodology + disclosure contract
    └── references/
        └── estimate-record-format.md                   # NEW — the format contract

tdad_tests/scenarios/skills/cost-estimation/
├── format-and-contract.md                              # NEW — structural scenario
├── cost-conditional.md                                 # NEW — structural: cost present-when-grounded, three states, no fallback
├── no-verdict-in-prose.md                              # NEW — structural: positive-content no-verdict check
└── triggers-on-prospective-cost.md                     # NEW — trigger scenario

docs/plugins/ai-literacy-superpowers/...                # NEW or MODIFIED — prospective-cost docs page (satisfies docs-reference-parity)

.claude-plugin/marketplace.json                          # MODIFIED: ai-literacy-superpowers entry version + plugin_version 0.40.0 → 0.41.0
README.md                                                # MODIFIED: plugin badge 0.40.0 → 0.41.0
```

Top-level marketplace `version` stays at `0.4.0`. No agent, command, or orchestrator file touched.

---

## Algorithm / key decisions (not pseudocode)

- **Range, never point.** Every **present** quantitative field (`tokens`, `tokens_by_stage[].tokens`, `cost_usd` when present, `agent_compute_time`, `human_gate_time`) is a `{low, high}` object. There is no point-value, verdict, recommendation, or go/no-go field. This is the load-bearing schema decision (spec §3) and is checked by the structural scenario.
- **`cost_usd` is conditional (present-when-grounded) — the central restructure (O11).** The day-one deliverable is token + time. `cost_usd` (plus `cost_basis`) appears only when a snapshot supplies a usable per-model rate; otherwise it is **omitted with disclosure** in `excluded`. **No list-price fallback.** Three grounding states: no snapshot / snapshot-without-usable-breakdown (both omit) / snapshot-with-breakdown (present, `cost_basis: snapshot-actuals`) (spec §6.2, §6.4, O2/O3/O8).
- **Cost binding is named, not agent discretion (O5); split widens across two distinct models (O1).** A tier→model→$/token binding table ships in the reference; the per-model rate is `estimated_cost ÷ total_tokens` from the snapshot Model Breakdown. The implementer's `Standard / Capable` split is widened across **two distinct representative models** — low bound `claude-sonnet-4` (`Standard`), high bound `claude-opus-4` (`Most capable`, since MODEL_ROUTING.md has no standalone `Capable` model) — so the widening produces a real spread, not a zero-width band. The cost-present worked example demonstrates the non-zero implementer band.
- **Time split is field-level, with different shapes (O2).** `agent_compute_time` and `human_gate_time` are two separate required fields. `agent_compute_time` derives from token volume as a numeric `{low, high}` range. `human_gate_time` is a **disclosed qualitative caveat, not estimated numerically at S1**: the withdrawn `gate_count × per-gate band` derivation had an ungrounded `gate_count` and reached into the orchestrator gate topology (S4, #371) the slice declares out of scope, so it is replaced by prose stating wall-clock is dominated by human availability and is not given a number until S4 fixes the gate set. Human-gate latency dominates wall-clock (spec §4.3, §6.3).
- **Disclosure body is mandatory and four-part — proposed by this spec (O1).** included / excluded / confidence-rationale / failure-direction. This is a contract THIS SPEC PROPOSES; it is **not** a pre-existing "disclosure-of-derived-judgment" AGENTS.md decision (no such decision exists). It serves the real "agent-emit + dispatcher-persist + human-disposes" ARCH_DECISION (spec §5).
- **Confidence is per-axis (O4, O6).** `confidence` is an object keyed `tokens`/`time`/conditional `cost`. `tokens`/`time` are capped by a `target_kind` ceiling (raw text → `low`); the `cost` axis exists only when `cost_usd` does and is set from snapshot quality, independent of `target_kind`. No collision on the empty-snapshot default because cost is simply omitted (spec §5.2).
- **No-verdict guarantee is structural in two layers (O12).** Field-absence (no verdict/recommendation/proceed field) plus a positive-content check that fails a record whose disclosure prose carries imperative recommendation or go/no-go language (spec §5.3).
- **Calibration seam open, not implemented.** `grounding_sources[]` accepts `kind: calibration`; methodology says calibration refines existing ranges rather than adding a field (spec §7). No per-PR capture, no integration-agent change. **Watch item (O7):** cost stays omitted across S2–S5 until S6; resequencing S6 earlier is a slicing decision to revisit, flagged not resolved.
- **References-file idiom.** The format lives in `references/estimate-record-format.md`, one contract per file, so the S3 command's validation checkpoint references it by path (spec §8.2; AGENTS.md ARCH_DECISION on cross-cutting methodology).

---

## FR mapping table

| FR | Requirement (abbrev) | Covering test case(s) |
| --- | --- | --- |
| FR-1 | SKILL.md present, well-formed, required sections | `format-and-contract.md` (structural) |
| FR-2 | Format reference defines full field set; `cost_usd`/`cost_basis` conditional; `confidence` per-axis | `format-and-contract.md` |
| FR-3 | Every present quantitative field a range; no verdict field | `format-and-contract.md` |
| FR-4 | Four-part disclosure body mandated | `format-and-contract.md` |
| FR-5 | Time split: two separate required fields — `agent_compute_time` a numeric range, `human_gate_time` a qualitative caveat not estimated numerically at S1 (gate set is S4 scope) | `format-and-contract.md` |
| FR-6 | Per-axis confidence; target_kind ceiling for tokens/time; independent cost axis | `format-and-contract.md` |
| FR-7 | Token ranges + tiers grounded in MODEL_ROUTING.md; split-tier widened across two distinct models (low `claude-sonnet-4`, high `claude-opus-4`) | `format-and-contract.md` (section presence) |
| FR-8 | `cost_usd` conditional (present-when-grounded); no list-price fallback; three grounding states | `format-and-contract.md` + `cost-conditional.md` |
| FR-8a | Named tier→model→$/token binding table in reference | `format-and-contract.md` |
| FR-9 | calibration grounding source permitted; range-refinement | `format-and-contract.md` |
| FR-10 | Names cost-tracking sibling; reuses observability/costs | `format-and-contract.md` + `triggers-on-prospective-cost.md` |
| FR-11 | Two worked examples (cost-omitted + cost-present) + validation checklist; no inclusion caveat under excluded | `format-and-contract.md` |
| FR-12 | Version bump 0.41.0 across all four locations | local version-consistency check (Task 5) |
| FR-13 | TDAD structural + trigger scenarios present | all scenario files exist |
| FR-14 | Validation checklist includes positive-content no-verdict check | `format-and-contract.md` + `no-verdict-in-prose.md` |

---

## Test case list

(In the same form as the existing TDAD scenario corpus — `Given/When/Then` markdown scenarios under `tdad_tests/scenarios/skills/cost-estimation/`.)

- `format-and-contract.md` (tier: structural) — SKILL.md frontmatter well-formed; required sections present (methodology, disclosure contract, time split, calibration seam, sibling, NOT-do); format reference exists; field table lists all of §4.2 including `cost_usd`/`cost_basis` marked conditional and a per-axis `confidence` object; every present quantitative field is a range; `agent_compute_time` is a numeric range and `human_gate_time` is a qualitative caveat string (not a range); no verdict/recommendation field; four-part disclosure body present; per-axis confidence with target_kind ceiling; named tier→model→$/token binding table present with the split row spanning two distinct models (`claude-sonnet-4` low … `claude-opus-4` high); the cost-present worked example shows a non-zero widened implementer band; calibration grounding-source value present; both cost-omitted and cost-present worked examples present; validation checklist present (including the positive-content no-verdict check).
- `cost-conditional.md` (tier: structural) — the methodology defines `cost_usd` as present only when a snapshot supplies a usable per-model rate; defines the three grounding states (no snapshot → omit; snapshot without usable breakdown → omit; snapshot with breakdown → present); states there is **no list-price fallback**; the cost-omitted example carries a cost-omission disclosure in `excluded` and a confidence object with no `cost` axis.
- `no-verdict-in-prose.md` (tier: structural) — the validation checklist enumerates both the field-absence check and the positive-content check; the worked examples contain no imperative recommendation or go/no-go language in their disclosure prose.
- `triggers-on-prospective-cost.md` (tier: trigger) — skill description fires on "how much will this feature cost", "estimate the tokens for this spec", "what will this slice cost to build"; does NOT fire on "record our Anthropic spend", "capture the quarterly cost snapshot" (those belong to `cost-tracking`).

---

## Phase 1 — The skill and the format reference

### Task 1: Write the format reference

- Create `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`.
- Content: the §4.2 frontmatter field table (with `cost_usd`/`cost_basis` marked **conditional** and `confidence` a **per-axis object**; `human_gate_time` typed as a qualitative caveat string, not a range); the §4.4 range rules (absent `cost_usd` is valid; `human_gate_time` exempt from range rules); the §4.3 time-split requirement — `agent_compute_time` a numeric range with the §6.3 token→wall-clock band, `human_gate_time` a qualitative caveat **not estimated numerically at S1** (no per-gate band, no gate count); the §5.1 four-part disclosure body; the §5.2 **per-axis** confidence mapping; the §6.2 **tier→model→$/token binding table** (split row spanning `claude-sonnet-4` low … `claude-opus-4` high, widened per §6.1); the §5.3 **two-layer** no-verdict guarantee; **two** worked example records — one **cost-omitted** (today's default) and one **cost-present** (`cost_basis: snapshot-actuals`, demonstrating the non-zero widened implementer band); a "Validation checklist" subsection for the downstream S3 command, including the positive-content recommendation-prose scan (O12) and the `cost_usd`/`cost_basis` both-present-or-both-absent rule.

### Task 2: Write the skill

- Create `ai-literacy-superpowers/skills/cost-estimation/SKILL.md`.
- Frontmatter: `name: cost-estimation`; a `description` triggering on prospective-cost queries and naming the `cost-tracking` sibling.
- Body: why estimate prospectively; the day-one token + time deliverable; the range-not-point decision; the grounding methodology (MODEL_ROUTING.md for token + time always; cost from a snapshot **only when grounded**, omitted-with-disclosure otherwise, **no list-price fallback**); the named tier→model→$/token binding and split-tier widening across two distinct models; the per-axis disclosure/confidence contract (framed as a contract this spec proposes, serving the agent-emit/dispatcher-persist/human-disposes ARCH_DECISION); the time split — `agent_compute_time` as a numeric range with its token→wall-clock band, `human_gate_time` as a qualitative caveat not estimated numerically at S1; the calibration seam (one paragraph, future) with the O7 cost-axis watch-item note; the sibling relationship; a "What this skill does NOT do" section (no dispatch, no file writes, no go/no-go — consumers' jobs).
- Reference the format file by relative path.

---

## Phase 2 — TDAD scenarios

### Task 3: Author the structural + trigger scenarios

- Create `tdad_tests/scenarios/skills/cost-estimation/format-and-contract.md`, `cost-conditional.md`, `no-verdict-in-prose.md`, and `triggers-on-prospective-cost.md` per the test case list and the corpus format in `tdad_tests/README.md`.
- These are the RED-phase deliverables of the tdd-agent's agent-artefact branch; the spec §8.3 / §10 fixes their `Then` shape.

---

## Phase 3 — Docs

### Task 4: Prospective-cost docs page

- Add or extend a page under `docs/plugins/ai-literacy-superpowers/` (how-to or explanation quadrant) describing prospective cost estimation and its relationship to the retrospective `cost-tracking` sibling. Satisfies the docs-reference-parity CI check that fires on the new skill.

---

## Phase 4 — Version bumps

### Task 5: Bump plugin.json, CHANGELOG, marketplace.json, README

- `ai-literacy-superpowers/.claude-plugin/plugin.json`: `version` `0.40.0` → `0.41.0`.
- `ai-literacy-superpowers/CHANGELOG.md`: new `## 0.41.0 — 2026-06-10` heading with entries for the skill, the format reference, and the disclosure contract.
- `.claude-plugin/marketplace.json`: bump the `ai-literacy-superpowers` `plugins[]` entry `version` and the top-level `plugin_version` to `0.41.0`; leave top-level `version` at `0.4.0`.
- `README.md`: bump the `ai-literacy-superpowers` badge `v0.40.0` → `v0.41.0`.
- Verify version consistency:

```bash
python3 -c "
import json
pj = json.load(open('ai-literacy-superpowers/.claude-plugin/plugin.json'))
m = json.load(open('.claude-plugin/marketplace.json'))
entry = next(p for p in m['plugins'] if p['name']=='ai-literacy-superpowers')
assert pj['version']=='0.41.0', pj['version']
assert entry['version']=='0.41.0', entry['version']
assert m['plugin_version']=='0.41.0', m['plugin_version']
assert m['version']=='0.4.0', m['version']
print('version consistency OK')
"
```

---

## Phase 5 — Verify and ship

### Task 6: Local CI gate checks

- Spec-first ordering — first commit on branch is the spec:

```bash
git log main..HEAD --reverse --oneline | head -1
```

- TDAD scenario presence — the new skill ships with a scenario:

```bash
ls tdad_tests/scenarios/skills/cost-estimation/*.md
```

- Markdown lint, docs build, and the deterministic TDAD fast suite (Layers 0+1) pass.

### Task 7: Push, PR, CI, merge

- Push the `cost-estimator-pipeline` branch, open a PR (feature ceremony — full `/diaboli` spec + code and `/choice-cartograph` already run on the spec).
- PR body states what ships (skill + format reference + scenarios + docs + version bump) and what does NOT (S2–S6, issues #369–#373).
- Watch CI green; merge `--squash --delete-branch`; sync the marketplace cache.

---

## Out of scope (deferred to S2–S6)

- The read-only `cost-estimator` agent (S2, #369).
- The `/cost-estimate` command and its Output Validation Checkpoint against this format (S3, #370).
- Orchestrator fold-in at T1 (Slice Adjudication) and T2 (Plan Approval) (S4, #371).
- The T0 pre-carpaccio ballpark (S5, #372).
- The calibration loop — per-PR actuals capture and the integration-agent change (S6, #373). S1 keeps the seam open only.
- Any runtime validator of estimate-record instances (a consuming command's checkpoint does this in S3, not a standalone validator here).
