# Specification — Dynamic Workflows S1: Foundational Skill + Election Discipline

**Plugin:** `ai-literacy-superpowers` (Habitat-Thinking)
**Slice:** S1 of the Dynamic Workflows Alignment epic (D1 + D8 clustered)
**Umbrella spec:** `docs/superpowers/specs/2026-06-22-dynamic-workflows-alignment-design.md`
**Slicing record:** `docs/superpowers/slices/dynamic-workflows-alignment.md` (§ S1)
**Issue:** <https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/438>
**Spec status:** Draft for implementation
**Spec version:** 0.1.0
**Owner:** Russ Miles / Habitat Thinking
**Branch:** `dynamic-workflows-s1-skill`

> **Implementer note (read first).** This slice ships **knowledge that agents
> read**, not a runtime they execute. No `*.workflow.js` files and no CI grep
> rule land here — those belong to S2 (#439). The `dynamic-workflows` skill is a
> sibling of `harness-engineering` and `context-engineering`: SKILL.md plus a
> `references/` folder, loaded as context for an agent's reasoning. The exact
> runtime function names for spawning subagents are **not** reproduced; consult
> <https://code.claude.com/docs/en/workflows> as authoritative when S2 writes
> templates.

---

## 1. Context and motivation

The plugin is architecturally a **static harness** — a fixed pipeline
(`spec-writer → GATE → tdd-agent → implementer(s) → code-reviewer → GUARDRAIL →
integration-agent`). The Dynamic Workflows Alignment epic introduces *dynamic
workflows* — ephemeral, per-task, disposable multi-agent harnesses — as a new
execution substrate beneath the existing agents, governed by two invariants
(INV-1 ephemeral-proposes / INV-2 quarantine).

The epic is sliced into seven independently-shippable pieces. **S1 is the
foundation** the other six reference. Per umbrella §6, the build order opens with
**D1** (the foundational `dynamic-workflows` knowledge skill) and **D8** (the
compute-discipline election rubric), clustered here because the skill is the
vehicle and the election rubric is the decision the vehicle carries — separating
them would ship a skill with no discipline, or a discipline with no home.

S1 establishes:

- the shared **conceptual model** — the six composable patterns, the decision
  rubric, and INV-1/INV-2 restated for agents;
- the **election discipline** — the compute-discipline rubric (D8) that makes
  every later workflow *elected*, not reflexive, plus the `MODEL_ROUTING.md`
  workflow-election section and token-budget convention.

An agent that has read this skill can name *when* a workflow is warranted,
*which* pattern fits, and *how* governance constrains it — before any template
or behavioural change exists to run.

---

## 2. Scope

### 2.1 In scope (this slice)

1. **`ai-literacy-superpowers/skills/dynamic-workflows/SKILL.md`** — YAML
   frontmatter (`name`, `description` with trigger conditions), an introduction
   to the six patterns, the decision rubric, and the two invariants. Shaped to
   match `harness-engineering` / `context-engineering` SKILL.md. May
   *forward-reference* the workflow template library as forthcoming (S2) but must
   be valid and markdownlint-clean **without** depending on any file S2 adds.
2. **`ai-literacy-superpowers/skills/dynamic-workflows/references/patterns.md`** —
   the six composable patterns with worked micro-examples: classify-and-act,
   fan-out-and-synthesize, adversarial verification, generate-and-filter,
   tournament, loop-until-done.
3. **`ai-literacy-superpowers/skills/dynamic-workflows/references/when-not-to-use.md`** —
   the compute-discipline election rubric (D8): *does this task really need more
   compute? is it long-running, massively parallel, highly structured, or
   adversarial?* If none apply, use the static pipeline.
4. **`ai-literacy-superpowers/skills/dynamic-workflows/references/governance.md`** —
   INV-1 (ephemeral proposes, durable curates — workflows may **never** write
   `HARNESS.md` / `AGENTS.md` / `CLAUDE.md` / `MODEL_ROUTING.md` directly) and
   INV-2 (quarantine untrusted-content readers from high-privilege tools),
   restated for agents.
5. **`ai-literacy-superpowers/templates/MODEL_ROUTING.md`** — extend with a
   *workflow election* section and a **token-budget convention** (an explicit
   per-workflow cap, e.g. "use 10k tokens"), plus the *model-routing-classifier*
   idea (a classifier agent that researches complexity, then routes
   Haiku/Sonnet/Opus tiers).
6. **Supporting CI / docs surfaces** (see §6): the plugin version bump, the
   `### dynamic-workflows` reference entry, the TDAD scenario, and the
   reference-parity / docs-impact updates that the new skill obliges.

### 2.2 Out of scope (explicitly deferred — do not blur)

| Deferred concern | Owning slice | Why not here |
| --- | --- | --- |
| The `*.workflow.js` template library under `skills/dynamic-workflows/workflows/` | **S2 (#439)** | S1 ships no executable templates; SKILL.md only forward-references them |
| The INV-1 CI **grep firewall** rule (§5.1 of umbrella) | **S2 (#439)** | The firewall has teeth only once templates exist to grep |
| The INV-2 lint rule on templates | **S2 (#439)** | No templates to lint in S1 |
| D3 fan-out threshold (= 8) | **S3 (#440)** | Riding open-question 1; not a skill-level decision |
| D4 routing default (opt-in flag) | **S5 (#442)** | Riding open-question 2 |
| D6 staging-artefact location (`REFLECTION_STAGING.md`) | **S6 (#443)** | Riding open-question 3 |
| Skill-count badge correction (`35 → 36`) + README "Dynamic Workflows" section + advisory Stop hook + Copilot degradation | **S7 (#444)** | Per umbrella D9; see §6.3 deferral note |

**Boundary rule.** S1's SKILL.md introduces the patterns and governance and may
say the template library is *forthcoming*; it must not import, link as a runnable
dependency, or assume the existence of any `.workflow.js` file. Keep S1 valid and
lint-clean standalone.

---

## 3. User story

> **As an** agent (or engineer) operating inside the ai-literacy-superpowers
> harness, **I want** a single authoritative knowledge skill that names the
> dynamic-workflow patterns, the rule for *when not* to spend extra compute, and
> the two governance invariants, **so that** I can decide deliberately whether a
> task warrants a workflow and, if so, which pattern fits — without reflexively
> reaching for parallel agents or breaching the durable/ephemeral boundary.

This is "agents propose; humans curate" applied at the harness layer. The skill
is the shared vocabulary every later slice (S2–S7) references.

---

## 4. Acceptance scenarios (Given / When / Then)

Each scenario carries its **verification-slot** tag from the umbrella taxonomy:
*deterministic* (CI-checkable), *agent-backed* (checked by an agent /
Layer-2-3 TDAD), or *unverified* (declared intent). The tdd-agent should turn
the deterministic and agent-backed scenarios into failing checks first.

### From D1 — the foundational skill

**AC-1 *(deterministic)*.**
**Given** the plugin is installed,
**When** skills are enumerated,
**Then** `dynamic-workflows` appears and its `SKILL.md` frontmatter validates
against the existing skill schema (non-empty `name: dynamic-workflows` and a
non-empty `description`).

**AC-2 *(deterministic)*.**
**Given** `SKILL.md` and the three reference files,
**When** markdownlint runs (existing PreToolUse hook + CI),
**Then** they pass with no new violations.

**AC-3 *(deterministic)*.**
**Given** the `dynamic-workflows/references/patterns.md` file,
**When** it is read,
**Then** all six patterns are named and each carries a worked micro-example:
classify-and-act, fan-out-and-synthesize, adversarial verification,
generate-and-filter, tournament, loop-until-done.

**AC-4 *(deterministic)*.**
**Given** `dynamic-workflows/references/governance.md`,
**When** it is read,
**Then** it restates **INV-1** (workflows may never write `HARNESS.md`,
`AGENTS.md`, `CLAUDE.md`, or `MODEL_ROUTING.md` directly; discoveries flow
through `REFLECTION_LOG.md → human curates → AGENTS.md`) and **INV-2**
(untrusted-content readers are withheld high-privilege tools), each named and
stated in full.

**AC-5 *(agent-backed)*.**
**Given** a task that benefits from parallel, isolated subagents,
**When** an agent consults `dynamic-workflows`,
**Then** it can name the matching pattern and cite INV-1/INV-2.

**AC-6 *(agent-backed, trigger)*.**
**Given** a Claude session with the plugin loaded,
**When** a user query about self-authored multi-agent harnesses, dynamic
workflows, the `ultracode` trigger, fan-out/adversarial-verification patterns, or
"when should I use a workflow" is sent,
**Then** the model identifies `dynamic-workflows` as a skill to invoke
(description carries the concept, not only literal tokens).

### From D8 — the compute-discipline election rubric

**AC-7 *(deterministic)*.**
**Given** `dynamic-workflows/references/when-not-to-use.md`,
**When** it is read,
**Then** it states the election rubric as four discriminating questions — *is the
task long-running, massively parallel, highly structured, or adversarial?* — and
the default: **if none apply, use the static pipeline.**

**AC-8 *(agent-backed)*.**
**Given** a task that fails the election rubric (none of the four questions apply),
**When** an agent considers a workflow,
**Then** it declines and uses the static path, citing `when-not-to-use.md`.

**AC-9 *(deterministic)*.**
**Given** `templates/MODEL_ROUTING.md`,
**When** it is read,
**Then** it contains a **workflow-election** section, a **token-budget
convention** that states an explicit per-workflow cap (e.g. "use 10k tokens"),
and the **model-routing-classifier** idea (a classifier agent that researches
complexity, then routes Haiku/Sonnet/Opus tiers).

**AC-10 *(unverified, declared)*.**
The election discipline is advisory guidance an agent reads, not a CI gate;
deterministic enforcement of "a workflow was elected, not reflexive" is **not**
shipped in S1 and is not implied by it. (Recorded so the absence is not mistaken
for an oversight; no later slice promotes this to a gate either.)

> **Note on the D3 threshold.** The constraint-count threshold (= 8) at which the
> enforcer switches to fan-out mode is **not** decided in S1 — it rides on S3
> (#440). `when-not-to-use.md` may mention that a fan-out threshold exists but
> must not fix its value.

---

## 5. Functional requirements

Numbered and testable; each maps to one or more acceptance scenarios in §7.

- **FR-1.** A `dynamic-workflows` skill exists at
  `ai-literacy-superpowers/skills/dynamic-workflows/SKILL.md` with valid YAML
  frontmatter: `name: dynamic-workflows` and a non-empty `description` whose
  trigger conditions cover dynamic workflows, self-authored multi-agent
  harnesses, the `ultracode` trigger, the six patterns, and "when to use a
  workflow."
- **FR-2.** `SKILL.md` introduces the six composable patterns, the decision
  rubric, and the two invariants, in the shape of the sibling knowledge skills
  (`harness-engineering`, `context-engineering`) — knowledge agents read, not a
  script they run.
- **FR-3.** `references/patterns.md` names all six patterns (classify-and-act,
  fan-out-and-synthesize, adversarial verification, generate-and-filter,
  tournament, loop-until-done), each with a worked micro-example.
- **FR-4.** `references/when-not-to-use.md` states the four-question election
  rubric and the "if none apply, use the static pipeline" default, **without**
  fixing the D3 fan-out threshold value.
- **FR-5.** `references/governance.md` restates INV-1 and INV-2 for agents, each
  named in full, INV-1 enumerating the four durable artefacts and the
  human-curation flow.
- **FR-6.** `templates/MODEL_ROUTING.md` gains a workflow-election section, an
  explicit per-workflow token-budget convention, and the
  model-routing-classifier idea (Haiku/Sonnet/Opus tiering).
- **FR-7.** `SKILL.md` and all reference files pass markdownlint with no new
  violations and contain no runnable dependency on any S2 `.workflow.js` file;
  any reference to the template library is an explicit forward-reference.
- **FR-8.** The plugin version is bumped `0.57.0 → 0.58.0` across all five
  CI-enforced locations (§6.1), and the human-facing README plugin-table cell is
  updated.
- **FR-9.** A reference-page entry `### dynamic-workflows` is added to
  `docs/plugins/ai-literacy-superpowers/reference/skills.md` (docs-reference-parity
  gate).
- **FR-10.** A TDAD scenario for the new skill is added under
  `tdad_tests/scenarios/skills/dynamic-workflows/` with frontmatter `tier:` one
  of `structural` / `trigger` / `behavioural` (tdad-scenario-check gate).

---

## 6. CI, version, and docs checklist

### 6.1 Version bump — adding a skill is behavioural (minor)

Adding a new skill is a behavioural change → **minor bump `0.57.0 → 0.58.0`**.
The `Version Check` CI enforces **five** locations (per CLAUDE.md / the live
`version-check.yml`). Update **every** one:

1. `ai-literacy-superpowers/.claude-plugin/plugin.json` — `"version"` (canonical;
   currently `0.57.0`)
2. `README.md` — shields.io **badge** `ai--literacy--superpowers-v0.58.0`
   (line 6; currently `v0.57.0`)
3. `CHANGELOG.md` — new top heading `## 0.58.0 — 2026-06-22`
4. `.claude-plugin/marketplace.json` — top-level `plugin_version` (currently
   `0.57.0`; owned by ai-literacy-superpowers PRs)
5. `.claude-plugin/marketplace.json` — the `ai-literacy-superpowers`
   `plugins[].version` entry (currently `0.57.0`)

Also update, for human-facing consistency (**not** CI-enforced): the `README.md`
plugin-table row cell (`| v0.57.0 |` → `| v0.58.0 |`, line 31).

> The marketplace listing `version` (`0.4.0`) does **not** change — S1 alters no
> listing contract (no description/keyword/permission/plugins-array change).

Before committing, grep for the **old** version to surface every spot at once:

```text
grep -rn 'v0\.57\.0\|0\.57\.0' README.md .claude-plugin/marketplace.json \
  ai-literacy-superpowers/.claude-plugin/plugin.json CHANGELOG.md
```

### 6.2 Component-coverage gates

- **`docs-reference-parity-check`** — a new skill added at
  `ai-literacy-superpowers/skills/dynamic-workflows/SKILL.md` requires a matching
  `### dynamic-workflows` heading in
  `docs/plugins/ai-literacy-superpowers/reference/skills.md`, **in the same PR**.
- **`tdad-scenario-check`** — the new skill requires at least one TDAD scenario
  at `tdad_tests/scenarios/skills/dynamic-workflows/<aspect>.md` whose frontmatter
  declares `tier:` as `structural`, `trigger`, or `behavioural` (a `finding` tier
  does not satisfy the gate). The tdd-agent authors this file. A **structural**
  scenario (assert the six patterns, the four-question rubric, and INV-1/INV-2 are
  all present — mirroring AC-3/AC-4/AC-7) is the natural first scenario; a
  **trigger** scenario for AC-6 (description fires on workflow queries) is the
  natural second.
- **`spec-first-check`** — satisfied by this spec being the first commit on the
  branch. No exemption label is needed; this is feature work.
- **`lint-markdown`** — SKILL.md, the three references, and MODEL_ROUTING.md must
  pass markdownlint (AC-2). The PreToolUse hook catches violations at edit time.

### 6.3 Skill-count badge — deliberate deferral to S7

The README badge currently reads `Skills-35` (line 9) and the plugin-table cell
reads "**35 skills**" (line 31). Landing this skill makes the true count **36**.

**This is intentionally deferred to S7 (#444), not corrected in S1.** The
slicing record assigns the badge/count update to S7 (D9). Confirmed against the
live repo: the `Skills-35` badge is **not** grep-enforced by any CI workflow
(no skill-count check exists in `.github/workflows/`), so leaving it stale does
**not** redden CI. Recording the deferral here so a reviewer does not read the
stale `35` as an S1 oversight. S7 will reconcile the badge and table to the
filesystem count when the full epic lands.

### 6.4 Docs-impact note (CLAUDE.md "Docs Site Review")

- **Reference (required, gated).** `### dynamic-workflows` entry in
  `reference/skills.md` — see §6.2. Place it in a sensible category (a new
  "Dynamic Workflows" subsection or under "Harness Core"); the gate only checks
  the heading exists.
- **How-to (judgement call — recommend deferring to S7).** A how-to guide under
  `docs/plugins/ai-literacy-superpowers/how-to/` is *warranted in principle* for
  a new skill, but a "how to use dynamic workflows" guide is not actionable until
  the template library (S2) and the behavioural workflow modes (S3–S6) exist —
  S1 ships *reading material*, not a runnable workflow a guide could walk a user
  through. **Recommendation:** defer the how-to guide to S7 (alongside the README
  "Dynamic Workflows" section and badge), where the full substrate exists to
  document end-to-end. The reference entry (gated, required now) plus the SKILL.md
  itself are sufficient for S1. *(Surface this to the human at the GATE as an
  explicit decision, not a silent omission.)*
- **Explanation / tutorials.** None required for S1 — no existing explanation
  page references behaviour S1 changes (this is net-new).

---

## 7. FR → acceptance-scenario mapping

| FR | Covered by | Slot |
| --- | --- | --- |
| FR-1 | AC-1, AC-6 | deterministic + agent-backed |
| FR-2 | AC-5 | agent-backed |
| FR-3 | AC-3 | deterministic |
| FR-4 | AC-7 | deterministic |
| FR-5 | AC-4 | deterministic |
| FR-6 | AC-9 | deterministic |
| FR-7 | AC-2 | deterministic |
| FR-8 | (CI: Version Check) | deterministic |
| FR-9 | (CI: docs-reference-parity-check) | deterministic |
| FR-10 | AC-6 via TDAD scenario | deterministic (presence) + agent-backed (content) |

Cross-cutting agent-backed behaviour AC-8 (decline a workflow that fails the
rubric) maps to FR-4 and is verified by a Layer-2/3 TDAD behavioural scenario if
the tdd-agent elects to add one; otherwise it stands as declared intent
alongside AC-10.

---

## 8. Risks and open questions

**Risks.**

- *Forward-reference leakage.* SKILL.md could accidentally hard-link a
  `.workflow.js` file S2 has not shipped, reddening markdownlint or misleading a
  reader. Mitigation: FR-7's standalone-validity requirement; review every
  template mention as an explicit "forthcoming (S2)" forward-reference.
- *Election rubric overreach.* `when-not-to-use.md` could imply deterministic
  enforcement that S1 does not ship. Mitigation: AC-10 records the advisory-only
  status explicitly.
- *Stale badge misread as oversight.* Mitigated by §6.3's explicit deferral note.

**Open questions.** None block S1. The four umbrella open questions
(Q1 threshold → S3, Q2 routing default → S5, Q3 staging → S6, Q4 Copilot → S7)
all ride later slices and are explicitly out of scope here (§2.2).
