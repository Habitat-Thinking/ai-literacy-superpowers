# Specification — Dynamic Workflows Alignment

**Plugin:** `ai-literacy-superpowers` (Habitat-Thinking)
**Target capability:** Claude Code *dynamic workflows* (self-authored multi-agent harnesses; trigger word `ultracode`)
**Spec status:** Draft for implementation
**Spec version:** 0.1.0
**Owner:** Russ Miles / Habitat Thinking
**Intended consumer:** Claude Code (orchestrator → spec-writer → tdd-agent → implementer pipeline)

> **Implementer note (read first).** The dynamic-workflows runtime exposes a small set of
> JavaScript functions for spawning and coordinating subagents, selecting per-agent models,
> and electing worktree isolation. The *exact* function names and signatures are not reproduced
> in this spec — consult the live documentation at
> <https://code.claude.com/docs/en/workflows> before writing any template, and treat the
> signatures there as authoritative over any pseudocode here. This spec governs *what* to build
> and *how it must behave*, not the runtime API surface.

---

## 1. Context and motivation

The plugin is, architecturally, a **static harness**. The orchestrator runs a fixed pipeline
(`spec-writer → GATE → tdd-agent → implementer(s) → code-reviewer → GUARDRAIL → integration-agent`).
Static harnesses must work for all edge cases and therefore tend toward the generic. Dynamic
workflows are the opposite: ephemeral, generated per task, disposable, and able to give each
subagent its own clean context window, its own model tier, and optional worktree isolation.

Three failure modes that dynamic workflows are designed to defeat are precisely the failure modes
several plugin agents are most exposed to:

| Failure mode | Definition | Most-exposed plugin component |
|---|---|---|
| **Agentic laziness** | Declaring a multi-part task done after partial progress (e.g. 35 of 50 items) | `harness-enforcer` checking many constraints in one context; `assessor` long scans |
| **Self-preferential bias** | Preferring one's own output when asked to verify or judge it | `code-reviewer`; `harness-auditor` auditing its own framework |
| **Goal drift** | Gradual loss of fidelity to the original objective across turns, worsened by lossy compaction | Long single-context orchestration runs |

This alignment introduces dynamic workflows as a **new execution substrate** beneath the existing
agents, without rewriting the agents themselves and without weakening the plugin's governance model.

---

## 2. Governing invariant (non-negotiable)

> **INV-1 — Ephemeral proposes, durable curates.**
> Dynamic workflows are *ephemeral and generated*. `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, and
> `MODEL_ROUTING.md` are *durable and curated*. A workflow may **propose** changes to durable
> artefacts but may **never** write to them directly. Anything a workflow discovers that is worth
> keeping flows through the existing human-curation gate (`REFLECTION_LOG.md → human curates →
> AGENTS.md`).

This is "agents propose; humans curate" applied at the harness layer rather than the rule layer.
It is the load-bearing principle of the entire alignment; every deliverable below must preserve it.
A second invariant constrains untrusted input:

> **INV-2 — Quarantine.** Any workflow agent that reads untrusted or public content (web pages,
> external issues, third-party PRs) must not be granted high-privilege actions. Acting on such
> information is performed only by separate, trusted agents in the same workflow.

---

## 3. Scope

**In scope.** A `dynamic-workflows` skill; a checked-in workflow template library distributed via
that skill; behavioural upgrades to `harness-enforcer`, the `orchestrator`, the `code-reviewer`
(with `Advocatus Diaboli`), the reflection-curation loop, and the `assessor`/`harness-auditor`;
a discipline gate governing *when not* to use workflows; documentation and badge updates.

**Out of scope.** Changes to the runtime API; replacing the static pipeline (it remains the default
for ordinary coding tasks); shipping language-specific implementers (still per-project); any change
that lets a workflow mutate a durable artefact (forbidden by INV-1).

---

## 4. Deliverables

Each deliverable carries acceptance scenarios in **Given/When/Then** form and a **verification slot**
classification using the plugin's own taxonomy: *deterministic* (CI-checkable), *agent-backed*
(checked by `harness-enforcer`), or *unverified* (declared intent). The tdd-agent should turn the
deterministic and agent-backed scenarios into failing checks first.

### D1 — `dynamic-workflows` skill (foundational knowledge)

**Purpose.** Give every agent the conceptual model for *when* a dynamic workflow is warranted, *which*
pattern fits, and *how* the plugin's governance constrains it. This is the sibling of
`harness-engineering` and `context-engineering`: knowledge agents read, not a script they run.

**Files.**
- `skills/dynamic-workflows/SKILL.md` — YAML frontmatter (`name`, `description` with trigger
  conditions), the six patterns, the decision rubric, and the two invariants.
- `skills/dynamic-workflows/references/patterns.md` — the six composable patterns with worked
  micro-examples: classify-and-act, fan-out-and-synthesize, adversarial verification,
  generate-and-filter, tournament, loop-until-done.
- `skills/dynamic-workflows/references/when-not-to-use.md` — the compute-discipline rubric (§D8).
- `skills/dynamic-workflows/references/governance.md` — INV-1 and INV-2 restated for agents.

**Acceptance.**
- *(deterministic)* **Given** the plugin is installed, **When** skills are enumerated, **Then**
  `dynamic-workflows` appears and its `SKILL.md` frontmatter validates against the existing skill schema.
- *(agent-backed)* **Given** a task that benefits from parallel, isolated subagents, **When** an agent
  consults `dynamic-workflows`, **Then** it can name the matching pattern and cite INV-1/INV-2.
- *(deterministic)* **Given** `SKILL.md`, **When** markdownlint runs (existing PreToolUse + CI), **Then**
  it passes with no new violations.

### D2 — Workflow template library (shipped via the skill)

**Purpose.** Ship opinionated, habitat-aligned workflow *templates* (not verbatim scripts) that agents
adapt per task. Distribution is by skill folder, per the documented mechanism: place the JavaScript
files in the skill and reference them from `SKILL.md`, prompting agents to treat them as templates.

**Files.**
- `skills/dynamic-workflows/workflows/enforcer-fanout.workflow.js`
- `skills/dynamic-workflows/workflows/adversarial-review.workflow.js`
- `skills/dynamic-workflows/workflows/reflection-mining.workflow.js`
- `skills/dynamic-workflows/workflows/deep-assessment.workflow.js`
- Each template carries a literate preamble (Knuth discipline) explaining intent, the pattern used,
  the model-tier rationale, and the INV-1 boundary it respects.

**Acceptance.**
- *(deterministic)* **Given** each `*.workflow.js`, **When** it is parsed, **Then** it is valid
  JavaScript and `SKILL.md` references it by relative path.
- *(agent-backed)* **Given** a template, **When** an agent loads it, **Then** it adapts (does not run
  verbatim) and no template contains a direct write to a durable artefact (INV-1).
- *(deterministic)* **Given** any template that spawns an agent reading untrusted content, **Then** that
  agent's declared tool permissions exclude high-privilege actions (INV-2), checkable by a lint rule.

### D3 — `harness-enforcer` fan-out upgrade *(highest leverage)*

**Purpose.** Replace single-context enforcement of many constraints with **one verifier subagent per
HARNESS.md rule**, plus a **skeptic persona** that reviews candidate violations to suppress false
positives. This directly defeats the enforcer's signature failure: the "35 of 50 constraints checked"
lazy stop.

**Pattern.** Fan-out-and-synthesize + adversarial verification.

**Files.**
- `agents/harness-enforcer.agent.md` — gains a "workflow mode" section: when the constraint count
  exceeds a threshold (default 8, configurable), author/adapt `enforcer-fanout.workflow.js`.
- `skills/verification-slots/SKILL.md` — document the fan-out slot as a first-class agent-backed slot.

**Acceptance.**
- *(agent-backed)* **Given** a HARNESS.md with N>8 commit-scoped constraints, **When** the enforcer
  runs in workflow mode, **Then** exactly N verifier subagents are spawned, one per rule, and the
  synthesis barrier waits for all N before reporting.
- *(agent-backed)* **Given** a candidate violation, **When** the skeptic persona reviews it, **Then**
  a documented false-positive rate reduction is observable versus single-context enforcement (capture
  in a `REFLECTION_LOG.md` entry the first time it runs).
- *(deterministic)* **Given** the enforcer reports "all constraints checked", **Then** the count of
  verifier results equals the count of enforceable constraints (no silent drop).

### D4 — `orchestrator` classify-and-act routing

**Purpose.** Stop running the full spec→tdd→review chain on tasks that do not need it. A classifier
front-end routes by task type: ordinary coding tasks keep the static pipeline; design/naming tasks get
a **tournament**; debugging gets **root-cause investigation** (disjoint-evidence hypotheses + a panel
of verifiers/refuters); large backlogs get **triage-at-scale** under quarantine (INV-2).

**Pattern.** Classify-and-act, composing tournament / root-cause / triage as needed.

**Files.**
- `agents/orchestrator.agent.md` — add a classification step *before* the existing pipeline; the
  default branch is unchanged (preserves current behaviour for regular coding).
- `commands/superpowers-status.md` — surface which route was taken in the dashboard.

**Acceptance.**
- *(agent-backed)* **Given** a routine single-file coding task, **When** the orchestrator classifies it,
  **Then** it selects the existing static pipeline (no workflow, no extra compute).
- *(agent-backed)* **Given** a taste-based task (naming, design), **When** classified, **Then** it routes
  to a tournament with a rubric-bearing judge agent.
- *(agent-backed)* **Given** a flaky-test or incident task, **When** classified, **Then** it routes to
  root-cause investigation with ≥3 independent hypotheses from disjoint evidence.
- *(unverified, declared)* The plan-approval GATE and `MAX_REVIEW_CYCLES=3` GUARDRAIL remain in force on
  every route.

### D5 — Adversarial verification for `code-reviewer` + `Advocatus Diaboli`

**Purpose.** Move review into a **separate context window** so the reviewer is not judging output from
the same context that produced it — defeating self-preferential bias. `Advocatus Diaboli` becomes the
adversary in the workflow rather than an in-pipeline pass.

**Pattern.** Adversarial verification.

**Files.**
- `agents/code-reviewer.agent.md` — add workflow mode invoking `adversarial-review.workflow.js`.
- `agents/advocatus-diaboli.agent.md` (existing) — declare its role as the rubric-bearing adversary.

**Acceptance.**
- *(agent-backed)* **Given** an implementation, **When** review runs in workflow mode, **Then** the
  reviewing agent operates in a context window distinct from the implementer's.
- *(agent-backed)* **Given** the CUPID + literate-programming rubric, **When** the adversary evaluates,
  **Then** each property is checked by a dedicated verifier and findings are synthesised, not collapsed.
- *(unverified, declared)* Review cycles still respect `MAX_REVIEW_CYCLES=3`.

### D6 — Reflection-mining curation workflow

**Purpose.** Raise the *proposal* quality of the compound-learning loop without touching the
human-curates principle. A workflow clusters `REFLECTION_LOG.md` entries with parallel agents,
adversarially pre-filters each candidate ("would this rule have prevented a real mistake?"), and
surfaces a vetted shortlist for the human to promote into `AGENTS.md`.

**Pattern.** Generate-and-filter + adversarial verification; reverse of the rule-adherence pattern.

**Files.**
- `commands/reflect.md` — add an optional `--mine` mode that triggers `reflection-mining.workflow.js`.
- `agents/integration-agent.agent.md` — note that mining augments, never replaces, human curation.

**Acceptance.**
- *(agent-backed)* **Given** an append-only `REFLECTION_LOG.md`, **When** mining runs, **Then** it emits
  a clustered, adversarially-filtered shortlist of promotion candidates to a *staging* artefact, not to
  `AGENTS.md` (INV-1).
- *(deterministic)* **Given** mining output, **Then** `AGENTS.md` is byte-for-byte unchanged until a human
  promotes an entry.
- *(agent-backed)* The existing "Stale AGENTS.md" GC rule's pressure is reduced because incoming
  proposals are pre-vetted (record the observation in a snapshot).

### D7 — `assessor` and `harness-auditor` as deep-research workflows

**Purpose.** Make long repo scans robust against agentic laziness and make the auditor robust against
auditing its own framework. Both adopt the deep-research shape: fan-out across the repo, adversarially
verify findings, synthesise a cited report.

**Pattern.** Fan-out-and-synthesize + adversarial verification (the deep-research shape).

**Files.**
- `agents/assessor.agent.md` and `agents/harness-auditor.agent.md` — add workflow mode invoking
  `deep-assessment.workflow.js`.
- `commands/assess.md`, `commands/harness-audit.md` — document the workflow path for large repos.

**Acceptance.**
- *(agent-backed)* **Given** a repo above a size threshold, **When** assessment runs in workflow mode,
  **Then** findings fan out by area and each is verified by a separate agent before synthesis.
- *(agent-backed)* **Given** the auditor checks the harness, **When** in workflow mode, **Then** at
  least one verifier is adversarial to the framework's own assumptions (self-preference guard).
- *(deterministic)* **Given** the assessment output, **Then** it remains a timestamped artefact in the
  existing assessment location with the existing format.

### D8 — Compute-discipline gate (when *not* to use workflows)

**Purpose.** Workflows cost more tokens and suit complex, high-value tasks; most coding tasks do not need
a panel of reviewers. Encode the discipline so the plugin reaches for workflows deliberately.

**Files.**
- `skills/dynamic-workflows/references/when-not-to-use.md` — the rubric: *does this task really need more
  compute? is it long-running, massively parallel, highly structured, or adversarial?* If none apply,
  use the static pipeline.
- `templates/MODEL_ROUTING.md` — extend with a "workflow election" section and a token-budget convention
  (e.g. an explicit per-workflow cap such as "use 10k tokens"); add the model-routing-classifier idea
  (a classifier agent that researches complexity, then routes Haiku/Sonnet/Opus tiers).

**Acceptance.**
- *(agent-backed)* **Given** a task failing the rubric, **When** an agent considers a workflow, **Then**
  it declines and uses the static path.
- *(deterministic)* **Given** any shipped template, **Then** it declares a token budget and a default
  model tier per agent role.

### D9 — Documentation, hooks, and badge

**Files.**
- `README.md` — new "Dynamic Workflows" section; skill count badge `19 → 20`; note the new substrate
  and INV-1/INV-2.
- `CHANGELOG.md` — entry under the next version.
- `hooks/hooks.json` — *optional* advisory `Stop` hook: when a session tackled a long/parallel/adversarial
  task without a workflow, nudge consideration of one (advisory only — warn, never block).
- `CLAUDE.md` / `templates/CLAUDE.md` — one line pointing agents to the `dynamic-workflows` skill.

**Acceptance.**
- *(deterministic)* Badge counts and the skills table match the filesystem.
- *(deterministic)* All new markdown passes markdownlint (PreToolUse + CI).
- *(unverified, declared)* The new hook is advisory and registered under `Stop`.

---

## 5. Cross-cutting acceptance criteria

1. *(INV-1)* No workflow template or workflow-mode agent writes directly to `HARNESS.md`, `AGENTS.md`,
   `CLAUDE.md`, or `MODEL_ROUTING.md`. Add a deterministic GC rule that greps templates for direct writes
   to these paths and fails CI if found.
2. *(INV-2)* Every template spawning an untrusted-content reader withholds high-privilege tools from it.
3. The static pipeline remains the **default** for ordinary coding tasks; workflows are opt-in by
   classification or by explicit trigger.
4. All three enforcement loops still hold: advisory hooks warn, CI blocks, scheduled GC/audit reports.
5. The plugin works identically from the Claude Code and Copilot CLI trees where the runtime supports it;
   where Copilot lacks the workflow runtime, the skill degrades to guidance only (document this clearly).

---

## 6. Recommended implementation sequence

Build in dependency order so each step has something to verify against:

1. **D1** (skill) — establishes the shared model the rest references.
2. **D8** (discipline gate) — so every subsequent workflow is elected, not reflexive.
3. **D2** (templates) — the concrete substrate.
4. **D3** (enforcer fan-out) — highest leverage; smallest blast radius; drop-in to verification-slots.
5. **D5** (adversarial review) and **D7** (deep assessment) — reuse the same patterns as D3.
6. **D4** (orchestrator routing) — the largest behavioural change; do it once the patterns are proven.
7. **D6** (reflection mining) — augments the learning loop last.
8. **D9** (docs/badge/hook) — finalise.

Each step should pass through the plugin's own pipeline: `spec-writer` updates the relevant spec,
`tdd-agent` turns the deterministic/agent-backed scenarios above into failing checks, the implementer
makes them pass, `code-reviewer` (ideally already in its D5 adversarial mode) reviews, and
`integration-agent` commits with a `REFLECTION_LOG.md` entry. The alignment dogfoods itself.

---

## 7. Risks and open questions

**Risks.**
- *Token cost.* Mitigated by D8's discipline gate and per-template budgets, but watch the cost panel
  after rollout; workflows are for high-value tasks.
- *Over-orchestration.* The orchestrator could over-classify routine work into workflows. The default
  branch must stay the static pipeline; treat any drift toward "everything is a workflow" as a regression.
- *Governance erosion.* INV-1 is the firewall protecting the team's curated theory of the system
  (Naur) from ephemeral churn. The CI grep rule in §5.1 is its teeth — do not ship without it.

**Open questions — dispositions (Russ, 2026-06-22).**
1. Constraint-count threshold for D3 fan-out: **8 (spec default)**, configurable per project. *(Resolved.)*
2. D4's tournament/root-cause/triage routes: **opt-in behind an explicit flag for the first release.**
   The static pipeline remains the sole default. *(Resolved.)*
3. D6's *staging* artefact: **a new `REFLECTION_STAGING.md`** (clean separation from the append-only
   log). *(Resolved.)*
4. Copilot CLI degradation (§5.5): **still open** — to be decided during the S7 build, since it shapes
   only the documentation and fallback it ships.

---

## 8. References

### Primary capability sources (Anthropic)
- *A harness for every task: dynamic workflows in Claude Code* — Thariq Shihipar & Sid Bidasaria,
  Anthropic, 2 June 2026. The patterns (classify-and-act, fan-out-and-synthesize, adversarial
  verification, generate-and-filter, tournament, loop-until-done), the three failure modes, the
  static-vs-dynamic distinction, the quarantine pattern, and the skill-distribution mechanism are drawn
  from this article.
  <https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code>
- Claude Code — *Dynamic workflows* documentation (authoritative for runtime API):
  <https://code.claude.com/docs/en/workflows>
- Claude Code — *Sub-agents*: <https://code.claude.com/docs/en/sub-agents>
- Claude Code — *Agent teams*: <https://code.claude.com/docs/en/agent-teams>
- Claude Code — *Glossary: agentic harness*: <https://code.claude.com/docs/en/glossary#agentic-harness>

### Framework foundations (this plugin's lineage, mapped to the alignment)
- **Birgitta Boeckeler**, "Harness Engineering," *Exploring Gen AI*, martinfowler.com (2026) — the three
  harness components; dynamic workflows sit as an ephemeral fourth layer beneath them.
- **John Boyd**, the OODA loop — observe-orient-decide-act as the replan-after-each-action cycle; a
  workflow structurally enforces OODA across isolated subagent contexts.
- **Edwin Hutchins**, *Cognition in the Wild* (1995) — distributed cognition; fan-out makes
  "intelligence as a property of systems, not individuals" literal.
- **Donella Meadows**, *Thinking in Systems* (2008) — leverage points; the ephemeral workflow is a new
  leverage point that must not destabilise the durable loops.
- **Peter Naur**, "Programming as Theory Building" — the curated harness *is* the team's theory of the
  system; INV-1 protects that theory from ephemeral churn.
- **Gojko Adzic**, *Specification by Example* — the Given/When/Then acceptance scenarios in §4 are the
  shared language between this intent and its implementation.
- **Addy Osmani**, "The Code Agent Orchestra" (2026) — subagent delegation, quality gates, compound
  learning; informs D4 routing and D5/D7 verification.
- **Donald Knuth**, "Literate Programming" (1984) — the literate preambles required on every workflow
  template in D2.
- **Daniel Terhorst-North**, "CUPID — for joyful coding" (2022) — the rubric the D5 adversary applies.
