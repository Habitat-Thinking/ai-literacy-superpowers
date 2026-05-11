# AI Literacy Assessment — ai-literacy-superpowers

**Date**: 2026-05-11
**Assessed by**: assessor (via /assess command)
**Assessed level**: Level 5 — Sovereign Engineering
**Previous assessment**: 2026-04-28 (Level 5)

---

## Habitat Document Discovery

| Document | Status | Path | Markers matched |
| --- | --- | --- | --- |
| `HARNESS.md` | Found, conventional | `HARNESS.md` (739 lines) | `## Constraints` heading; `## Garbage Collection` heading; `## Status` heading with last-audit date + enforcement ratio; multiple four-field constraint blocks (`**Rule**`/`**Enforcement**`/`**Tool**`/`**Scope**`); HTML template-version comment near top |
| `AGENTS.md` | Found, conventional | `AGENTS.md` (247 lines) | STYLE / GOTCHAS / ARCH_DECISIONS / TEST_STRATEGY / DESIGN_DECISIONS sections; references to `REFLECTION_LOG.md`; "promoted from reflections" entries with dates |
| `CLAUDE.md` | Found, conventional | `CLAUDE.md` (244 lines) | Direct address ("Never commit directly to `main`"); branch + PR + commit conventions; semver, output-validation checkpoints, docs review, quarterly + monthly operations sections |

No ambiguities. No alternative-path candidates needed.

## Observable Evidence

### Repository Signals

| Signal | Found | Level indicator |
| --- | --- | --- |
| CI workflows | Yes — 12 (`auto-tag-model-cards`, `auto-tag`, `docs-build-check`, `gc`, `harness`, `lint-markdown`, `pages`, `spec-first-check`, `spec-redaction-marker-check`, `tdad-scenario-check`, `tdad-tests-fast`, `version-check`) | L2 |
| Test coverage enforcement | Yes (new) — `tdad-tests-fast` Layer 0+1 PR-gate; `tdad_tests/` Python suite via `pyproject.toml` | L2 |
| Vulnerability scanning | Yes — gitleaks via secrets-check hook; `gc.yml` runs dependency-currency etc. | L2 |
| Mutation testing | N/A — content-only plugin | L2 |
| Linting in CI | Yes — markdownlint (`lint-markdown.yml` + PreToolUse), ShellCheck, bash -n, docs-build (mkdocs strict) | L2 |
| TDD-paced diffs | Yes — small spec→PR→reflection cycles visible in 81 commits since 2026-04-28 (Human Pace L2 signal) | L2 |
| CLAUDE.md | Yes — branch discipline, PR workflow, semver, marketplace versioning, spec-first exemptions, output-validation checkpoints, docs review, quarterly + monthly operations, sync-from-source, marketplace cache auto-sync | L3 |
| HARNESS.md | Yes — **25 constraints declared** + 1 governance template placeholder; **25 GC rules declared**; 3 Observability sub-headings; Read-side filtering and Status sections present | L3 |
| AGENTS.md | Yes — STYLE / GOTCHAS / ARCH_DECISIONS / TEST_STRATEGY / DESIGN_DECISIONS; promoted-pattern entries dated 2026-04-28 | L3 |
| MODEL_ROUTING.md | Yes — tier table, token budgets, sovereignty/data-classification, fallback strategy | L3 |
| Custom skills | Yes — **32** in `ai-literacy-superpowers/skills/` (added `component-design-with-tdad`, plus prior assessment's 30 plus one previously unrecorded) | L3 |
| Custom agents | Yes — 13 (assessor, advocatus-diaboli, choice-cartographer, code-reviewer, governance-auditor, harness-auditor, harness-discoverer, harness-enforcer, harness-gc, integration-agent, orchestrator, spec-writer, tdd-agent) | L3 |
| Custom commands | Yes — **25** (added `harness-affordance`/`harness-sync`/`harness-upgrade`/`observatory-verify` cluster and others since prior measurement) | L3 |
| Hooks configured | Yes — 10 scripts wired through `hooks.json` (PreToolUse: 2; Stop: 8; SessionStart: 1) | L3 |
| REFLECTION_LOG.md | Yes — **617 lines**; promoted-pattern policy active; monthly curation cadence practised | L3 |
| ONBOARDING.md | Yes — 527 lines, regenerated 2026-05-09 (after TDAD landed) | L3 |
| `.markdownlint.json` + `.markdownlint-cli2.jsonc` | Yes | L3 |
| Parallel-tool configs | Yes — `.cursor/rules/`, `.windsurf/rules/` populated; convention-sync command keeps them aligned | L3 |
| Specifications directory | Yes — **41 spec files** in `docs/superpowers/specs/` (33 → 41, +8) | L4 |
| Implementation plans | Yes — `docs/superpowers/plans/` (14 plan files) | L4 |
| Choice stories | Yes — `docs/superpowers/stories/` (3 records) | L4 |
| Objection records | Yes — `docs/superpowers/objections/` (11 records) | L4 |
| Orchestrator with safety gates | Yes — plan-approval AND integration-approval gates; TDAD scenario authoring now part of the pipeline | L4 |
| Adversarial review at gates | Yes — advocatus-diaboli at spec-time AND code-time; spec-conformance, adjudicated-objections, adjudicated-stories all PR constraints | L4+ |
| Decision archaeology | Yes — choice-cartographer agent + `/choice-cartograph` command + adjudicated-stories constraint | L5 |
| **TDAD subsystem** (NEW) | Yes — `tdad_tests/` directory with Layer 0 deterministic suite + Layer 1+2+3 scenarios + Python toolchain (`pyproject.toml`) + SDK runner; two new HARNESS constraints (Layers 0+1 fast-suite + scenario-shipping); new skill `component-design-with-tdad`; integrated into orchestrator pipeline (v0.36.0) | L5 |
| Fitness functions (GC) | Yes — `Layer boundary compliance`, `Complexity hotspots`, `Coupling trend`, `Dependency age budget` declared as GC rules | L5 |
| Plugin/platform tooling | Yes — published plugin **v0.37.0** (was v0.31.0; +6 minor releases / 81 commits in 13 days) | L5 |
| Cross-team templates | Yes — HARNESS.md, MODEL_ROUTING.md, CLAUDE.md, AGENTS.md, REFLECTION_LOG.md, ONBOARDING.md, 5 CI templates | L5 |
| Governance subsystem | Yes — governance-auditor + `/governance-audit` + `/governance-constrain` + `/governance-health` + `observability/governance/`; quarterly cadence anchored | L5+ |
| Docs site | Yes — Diataxis structure under `docs/plugins/<plugin-name>/`; GitHub Pages; strict-build CI; TDAD section added (PR #312); Contributing section added (PR #306) | L5 |
| Articles | Yes — 8 (stable since prior assessment) | L5 |
| Portfolio assessment | Yes — tooling + HTML dashboard + portfolio-assessment skill | L5 |
| Portfolio discovery tag | Yes — `agent-harness-enabled` topic | L5 |
| Cost-tracking infrastructure | Yes — `/cost-capture` + cost-tracking skill + MODEL_ROUTING.md | L5 |
| **Actual cost data captured** | **No — still never captured** (third consecutive assessment with this gap) | L5 gap |
| Sister plugin (`model-cards`) | Yes — populated `agents/`, `commands/`, `skills/`, `seed/`, `templates/`; independent versioning (v0.1.0) | L5 |
| Health snapshots | Yes — 7 archived; latest 2026-05-10 (monthly observability cadence maintained) | L5 |
| OTel configuration | N/A — content-only plugin | L5 |

### Changes Since Previous Assessment (2026-04-28, 13 days)

**Headline change:** the **TDAD pillar** shipped end-to-end and is now operationally adopted (per Q1 response). This is comparable in scope to the governance subsystem that landed in the prior assessment cycle — a new platform-level discipline integrated into HARNESS, CI, the docs site, the orchestrator pipeline, and the constraint set.

- Plugin v0.31.0 → **v0.37.0** (6 minor releases, **81 commits** over 13 days)
- Skills: 30 → **32** (+component-design-with-tdad, +1 other)
- Commands: 24 → **25**
- CI workflows: 7 → **12** (+tdad-scenario-check, +tdad-tests-fast, +docs-build-check, +spec-redaction-marker-check, +auto-tag-model-cards)
- HARNESS constraints declared: 19 → **25** (+TDAD fast-suite, +TDAD scenario shipping, +Spec redaction markers, +Reflections via PR, +Label PRs at creation, +Docs propagation when shipping commands, +Spec conformance, +Docs site builds in strict mode — and the [Governance constraint name] template placeholder remains)
- HARNESS GC rules declared: 15 → **25** (added redirect sunset, template currency, dependency currency, observability archive, convention file sync, reflection-driven regression detection, reflection log archival, reflection log aged-out review, objection record freshness, governance constraint freshness, semantic drift early warning, governance debt cycle check, layer boundary compliance, complexity hotspots, coupling trend, dependency age budget)
- Specs: 33 → **41** (+8)
- REFLECTION_LOG: 25 entries → **617 lines** (active, monthly curation practised per Q4 response)
- ONBOARDING.md regenerated 2026-05-09 (PR #305 — TDAD content)
- Health snapshots: monthly cadence maintained; latest 2026-05-10

**Observed drift on entry (now fixed in Phase 6 below):**

- README badge: Skills 31 (actual 32)
- HARNESS.md Status: enforcement 23/24, GC 18/18 (declared counts have grown to 25 and 25)
- README AI Literacy badge linked to 2026-04-28 assessment

### Evidence Summary

Three months into the L5 plateau, the plugin continues to ship platform-level subsystems at a roughly-quarterly cadence: governance (Apr), TDAD (May). Both have followed the same shape — design spec, sub-plugin scaffolding, HARNESS constraints, CI gates, orchestrator integration, docs site section, ONBOARDING regeneration. The pattern itself has become a meta-capability of the project.

The two persistent gaps from 2026-04-28 (cost capture cadence, AGENTS.md read-back loop) remain open per Q2 response. Neither lowers the L5 ceiling, but both are now the highest-value operational targets — the framework's own logic says you have all the *infrastructure* you need; you do not yet have all the *operational habits* the infrastructure was built to support.

## Clarifying Responses

- **Q1 / TDAD adoption**: **Fully operational** — scenarios written for every new component, orchestrator dispatches through it, fast-suite blocks PRs. Important: this confirms TDAD is not an aspirational artefact — it is an active feedback loop. Adoption strength matches infrastructure strength.
- **Q2 / persistent operational gaps**: **Both 1 and 2 still open** — cost capture cadence is still missing the calendar anchor; AGENTS.md read-back is still by-convention rather than enforced via session-start hook.
- **Q3 / quarterly cadence**: **Anchored, today is the scheduled quarterly** — /governance-audit and /cost-capture will run in this sitting too. (Closes the calendar-anchor part of Q2's cost-capture gap by sheer existence of this sitting; what remains is the *automation* of the trigger.)
- **Q4 / curation flow**: **Monthly review** — Monthly Operations item 2 is practised; patterns get promoted; log gets archived. AGENTS.md GOTCHAS gets fresh material monthly.
- **Q5 / human load**: **Sustainable, headroom available** — TDAD landed cleanly; harness is absorbing more of the work. Capacity exists for further expansion, but the persistent operational gaps suggest spending the headroom on consolidation/automation rather than another pillar.

## Level Assessment

### Primary Level: 5 — Sovereign Engineering

The project meets every L5 criterion with deepening evidence:

- **Platform-level tooling**: Published plugin shipped at v0.37.0; sister plugin (`model-cards`) on the marketplace independently versioned.
- **Cross-team templates**: HARNESS.md, MODEL_ROUTING.md, CLAUDE.md, AGENTS.md, REFLECTION_LOG.md, ONBOARDING.md, CI workflow templates — all shipped as plugin assets others can consume.
- **Organisational governance**: Governance subsystem (auditor + audit/constrain/health commands + observability dir) practised quarterly. Three-frame alignment, falsifiability scoring, debt inventory, drift detection.
- **Decision archaeology**: Choice-cartographer + adjudicated-stories constraint enforces the pattern at PR time, not as an after-the-fact discipline.
- **Adversarial review**: advocatus-diaboli operating in both spec-time and code-time modes, hard-wired as a PR constraint via adjudicated-objections.
- **Specification architecture**: Spec-first commit ordering enforced via `spec-first-check.yml`; spec-scoped changes constraint; spec-conformance constraint; spec captures intent constraint.
- **Sustainable pace as platform metric**: Change cadence drift GC rule live; small TDD-paced diffs visible in commit history; human-load self-report ("sustainable, headroom available") matches the observable signal.
- **TDAD pillar (new)**: Test-Driven Agent Development now adds a third major platform-level subsystem alongside governance and adversarial review. Layer 0 deterministic, Layers 1/2/3 SDK-runner, PR-time fast-suite, scenario-shipping constraint, scenario authoring integrated into orchestrator pipeline. Operationally adopted per Q1.

### Discipline Maturity

| Discipline | Strength (1-5) | Evidence |
| --- | --- | --- |
| Context Engineering | **5** | CLAUDE.md + AGENTS.md + MODEL_ROUTING.md + ONBOARDING.md (regenerated 2026-05-09) + 32 skills + parallel-tool configs (.cursor, .windsurf) kept in sync via /convention-sync. AGENTS.md curated monthly (Q4 confirmation). The one remaining weakness — read-back loop is by-convention only — is operational habit, not artefact absence. |
| Architectural Constraints | **5** | 25 declared HARNESS constraints (mostly deterministic/agent-enforced) + 25 GC rules including 4 fitness functions (layer boundary, complexity hotspots, coupling trend, dependency age budget). PR-time gates: spec-first, spec-redaction-marker, version-check, harness, lint-markdown, docs-build, tdad-fast-suite, tdad-scenario-check. Read-side filtering section addresses agent context curation. Status section is updated by `/harness-audit`; entry-time drift in counts is a known mode of the system, fixed by the same agent that detects it. |
| Guardrail Design | **5** | Orchestrator with plan-approval + integration-approval safety gates; dual-mode advocatus-diaboli (spec + code); choice-cartographer at spec time; TDAD scenarios for every new plugin component; PreToolUse constraint warnings; 8 Stop hooks closing every feedback loop (drift, snapshot, reflection, framework-change, secrets, gc-rotate, curation-nudge, governance-drift); SessionStart template-currency check; output-validation checkpoints baked into commands that emit structured markdown. |

### The Weakest Discipline

All three disciplines hold strong at L5. The ceiling-setting weakness is *operational* rather than *artefact-level*:

1. **AGENTS.md read-back loop** — capture and curation are strong; the session-start *trigger* that would surface promoted patterns into the agent's context window is by-convention only. This is a small architectural gap (one SessionStart hook would close it) sitting at the seam between context engineering and guardrail design.
2. **Cost-capture cadence** — infrastructure is complete; the trigger is missing. Today's /assess sitting can close this in real time by running `/cost-capture`.

Neither blocks L5 status; both define what *operational* L5 maturity needs to round out.

## Strengths

- **Two new platform-level subsystems shipped on a near-quarterly rhythm** (governance in April, TDAD in May) — each integrated end-to-end (HARNESS, CI, orchestrator, docs, ONBOARDING, constraint set). The shape of how to ship a new pillar is itself now a tacit pattern.
- **Cadence held under significant velocity** — 81 commits in 13 days, 8 new specs, 6 minor releases. Snapshots remain monthly. ONBOARDING.md regenerated immediately after TDAD landed. CLAUDE.md's quarterly cadence kept (Q3 response).
- **TDAD adoption matches infrastructure** (Q1) — scenarios authored for every new component is the signal that the framework's own discipline applies to its own work. Self-application is the L5 marker.
- **Monthly curation practised** (Q4) — REFLECTION_LOG → AGENTS.md promotion happens on a fixed monthly trigger, not opportunistically. Compound learning is operating.
- **Auditable drift detection on entry** — HARNESS Status section staleness and README badge drift were visible immediately because the framework declares ground truth in machine-checkable form. Drift is a feature, not a failure.

## Gaps

- **Cost-data capture has never been executed** (third consecutive assessment). The tool exists, the cadence is missing. Closing this today (within this quarterly sitting) eliminates the gap.
- **AGENTS.md read-back loop is by-convention only** — no SessionStart hook surfacing the curated patterns. A 10-line shell script + one hook entry closes the gap.
- **HARNESS.md Status section drifts faster than constraints are added** — adding constraints does not automatically update Status; only `/harness-audit` does. The Status field could be partly auto-maintained by a Stop hook that increments declared counts when new constraint blocks are written. (Optional; not a literacy gap.)
- **No explicit depletion-management cadence** — Q5 indicates sustainable pace with headroom, but the practice is still by-feel rather than instrumented. At L5 portfolio scale this becomes a platform metric worth measuring.
- **Sister plugin (`model-cards`) habitat doesn't yet declare its own HARNESS.md** — the parent project's harness applies to the marketplace, but a per-plugin HARNESS may be appropriate as the marketplace grows beyond two plugins.

## Recommendations

Ordered by impact, all consistent with the project's existing philosophy that infrastructure should serve operational habits.

1. **Run `/cost-capture` in this sitting** — closes the longest-standing operational gap. Today's quarterly anchor is exactly where it belongs. After it runs, add a brief reflection on whether the captured cost data changes any model-routing decision.

2. **Add a SessionStart hook that surfaces AGENTS.md promoted patterns** — closes the curation-to-read-back loop. The plugin already uses SessionStart for template-currency; one more entry that emits the AGENTS.md "Promoted Patterns" section (or a curated subset) gives the agent the context it currently relies on convention to import.

3. **Consider promoting "depletion check" to a soft cadence signal in the monthly health snapshot** — not a hard constraint, but a question included in the snapshot template ("Sustainable pace this month: yes / at-edge / over"). Captures the Q5 self-report as a longitudinal signal so trend lines become visible across snapshots.

4. **Audit the [Governance constraint name] template placeholder** — it's a vestigial template stub in the HARNESS Constraints section. Either remove it (if it was inserted by `/governance-constrain` scaffolding and never filled), or fill it. Currently it pads the constraint count without contributing enforcement.

5. **For the next L5 platform deepening: portfolio-level adoption signal** — the framework now has two plugins on the marketplace. Track installs, /assess invocations from other projects, and PRs into ai-literacy-for-software-engineers as a signal that the framework is being adopted beyond this repo. This is what L5 → "sovereign across an organisation" looks like in practice.

## Immediate Adjustments Applied

Applied during Phase 6 of this assessment (no team discussion required):

- **README badge**: Skills 31 → **32** (and anchor `#skills-31` → `#skills-32`)
- **README marketplace table**: "31 skills, 13 agents, 25 commands" → "32 skills, 13 agents, 25 commands"
- **README Skills heading**: `### Skills (31)` → `### Skills (32)`
- **README AI Literacy badge**: link `assessments/2026-04-28-assessment.md` → `assessments/2026-05-11-assessment.md`
- **HARNESS.md Status section**: **deliberately not manually edited** despite drift (declared constraints have grown from 24 → 25, GC rules from 18 → 25 since last audit). The block carries an explicit "Auto-updated by `/harness-audit` — do not edit manually" contract. Phase 7 recommends running `/harness-audit` in this quarterly sitting to refresh it via the proper mechanism.
- **README HARNESS badge** (`Harness-23%2F24_enforced`): same situation — depends on Status refresh; left for `/harness-audit` to update.

## Workflow Operation Changes

Walked through interactively during Phase 7. Five recommendations presented, all accepted.

- **R1 (run `/cost-capture` in this sitting)**: **Accepted** — user confirmed. To be run as the next command after this assessment commits, alongside `/governance-audit` per the quarterly cadence. Closes a three-assessment-old gap.
- **R2 (SessionStart hook for AGENTS.md read-back)**: **Accepted** — to be implemented as a follow-up PR with its own design spec, following spec-first discipline. Hook name suggestion: `agents-promoted-patterns-surface.sh`. Wires into the existing SessionStart hook alongside `template-currency-check.sh`. Closes the curation→read-back loop.
- **R3 (run `/harness-audit` in this sitting)**: **Accepted** — refreshes HARNESS.md Status section + README HARNESS badge via the proper mechanism. To be run as part of today's quarterly sitting.
- **R4 (add "Sustainable Pace" section to snapshot template)**: **Accepted and applied inline** —
  - `ai-literacy-superpowers/skills/harness-observability/references/snapshot-format.md` now defines a Sustainable Pace section with fields `This month's pace`, `Note`, `Trend`.
  - `ai-literacy-superpowers/commands/harness-health.md` updated to list the new section in both the writer step and the structural validator (14 sections → 16 sections).
  - Next `/harness-health` invocation will start populating the new section.
- **R5 (add "Portfolio Adoption" section to snapshot template)**: **Accepted and applied inline** —
  - Same files updated as R4. Portfolio Adoption now defines fields for plugin installs, /assess invocations from other projects, upstream PRs into ai-literacy-for-software-engineers, agent-harness-enabled tagged repos, and trend.
  - L5 → sovereign-across-an-organisation needs adoption telemetry; this starts capturing what's available.

**Follow-ups arising from these decisions (separate work, not part of this PR):**

- A small design spec for R2's SessionStart hook (`docs/superpowers/specs/YYYY-MM-DD-agents-promoted-patterns-hook-design.md`), then implementation.
- Optionally update `observatory-signals.md` (the 82-signal checklist) to register the new snapshot fields as observable signals. Not blocking — the format spec already defines them.
- Audit the `[Governance constraint name]` template placeholder block in HARNESS.md (it's inside an HTML comment, so it doesn't truly inflate the constraint count, but it does require careful counting). Optional housekeeping.

## Improvement Plan

- **Current level**: L5 (Sovereign Engineering)
- **Target level**: L5 — there is no level above; the framework tops out at L5
- **Skill invoked**: `literacy-improvements` (returned `N/A — Level 5 teams do not need this skill, they are already at the top`)
- **Substitute lever**: Phase 7's workflow recommendations (R1–R5) **are** the L5 → operationally-mature-L5 work. They close the gaps that the framework identifies as the remaining seams at this level — cost-capture cadence (R1), AGENTS.md read-back loop (R2), HARNESS.md Status auto-refresh (R3), sustainable-pace signal (R4), and portfolio-adoption telemetry (R5).
- **Accepted**: 5 / 5
- **Skipped**: 0
- **Deferred**: 0

At L5 the meaningful progression is portfolio adoption — the framework being installed and operated by other teams. R5 (portfolio-adoption telemetry) is the first step toward measuring that progression as a longitudinal signal rather than a self-report.

## Reflection

What the scan revealed that was surprising:

- **Velocity-without-drift**: 81 commits and 6 minor releases in 13 days, yet snapshot cadence, ONBOARDING regeneration, and monthly curation all held. The harness is now doing real load-bearing work — adding constraints didn't slow shipping, it shaped it.
- **TDAD shape-matched governance**: Both new subsystems followed the same arc — design spec → scaffold → constraints → CI gate → orchestrator integration → docs site section → ONBOARDING regen. The pattern is now reproducible.
- **Cost gap is a habit gap, not a tool gap**: Third assessment in a row to flag this. The tool has been ready for months. What's missing is the trigger; today's sitting is the trigger.
- **Status-section drift is *immediate* signal**: HARNESS Status said 23/24, declared count is 25, GC said 18/18, declared count is 25. The drift was visible within seconds of the scan because the artefact is machine-checkable. That's the L5 epistemic gain — knowing the system has drifted before any human had to notice.

## Next Assessment

Suggested re-assessment date: **2026-08-11** (quarterly, aligned with /governance-audit + /cost-capture).

Previous assessment: [2026-04-28](2026-04-28-assessment.md)
