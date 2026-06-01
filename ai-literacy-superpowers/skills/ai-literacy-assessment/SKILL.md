---
name: ai-literacy-assessment
description: This skill should be used when the user asks to "assess AI literacy", "run an assessment", "check literacy level", "evaluate our AI collaboration", "where are we on the framework", or wants to determine their team's AI literacy level using the ALCI instrument.
---

# AI Literacy Assessment

Assess a team's AI collaboration literacy level by combining observable
evidence from the repository with clarifying questions, then produce a
timestamped assessment document and a README badge.

## The Assessment Process

### Phase 1: Observable Evidence

Scan the repository for signals that indicate which framework level the
team is operating at.

**Habitat document discovery comes first.** Before scanning for any of
the level indicators below, apply the methodology in
`references/habitat-discovery.md` to find `HARNESS.md`, `AGENTS.md`,
and `CLAUDE.md` — including their alternative paths and embedded
forms. A habitat document found at a non-conventional path counts as
*present* for the Level 3 indicators that reference it; "not at the
default path" is not the same as "doesn't exist". Every absence claim
must come from a fully-completed search across known alternatives,
with the discovery report citing what was matched and where.

Each signal below maps to a specific level:

**Level 0-1 indicators (awareness + prompting)**:

- Does the repo exist and contain code? (baseline)
- Are there any AI-related configuration files at all?

**Level 2 indicators (verification)**:

- CI workflows that run tests (`*.yml` in `.github/workflows/`)
- Test coverage enforcement (coverage thresholds in CI or build files)
- Vulnerability scanning (govulncheck, OWASP, Docker Scout)
- Markdownlint or other linting in CI
- Mutation testing configuration
- Small, TDD-paced diffs visible in commit history (Human Pace signal)
- Depletion signals recognised — developer can name observable markers of degraded judgment (Depletable Collaborator signal)

**Level 3 indicators (habitat engineering)**:

- `CLAUDE.md` or equivalent context engineering file (apply
  `references/habitat-discovery.md` — alternative paths and embedded
  forms count as present)
- `HARNESS.md` with declared constraints (same — alternative paths
  count)
- `AGENTS.md` compound learning memory (same)
- **Parallel-tool config evidence**: `.cursor/rules/`,
  `.github/copilot-instructions.md`, `.windsurf/rules/`, or custom
  AI tooling locations expressing harness control through whichever
  AI surface the team uses. Apply `references/tool-config-evidence.md`
  for the methodology. A project with rich parallel-tool configs is
  at L3 context engineering even without `HARNESS.md`/`CLAUDE.md`,
  but tool-config evidence does NOT signal architectural constraints
  or compound learning by itself.
- `MODEL_ROUTING.md` model-tier guidance
- `.claude/skills/` project-local skills
- `.claude/agents/` custom agent definitions
- `.claude/commands/` custom commands
- Hooks configuration (`hooks.json`)
- `REFLECTION_LOG.md` with entries
- `.markdownlint.json` or equivalent config
- Spec-scoped changes constraint in HARNESS.md (Human Pace signal)
- Change cadence drift GC rule active (Human Pace signal)
- Session boundaries designed into workflow — time-based, not task-based (Depletable Collaborator signal)
- Recovery cadence visible in work log — gaps between sessions respected (Depletable Collaborator signal)
- Depletion Check practised — 90-minute time-based self-assessment (Depletable Collaborator signal)

**Level 4 indicators (specification architecture)**:

- `specs/` directory with specification files
- Implementation plans (`plan.md`, `plan-*.md`)
- Agent pipeline with orchestrator
- Plan approval gate in orchestrator
- Loop guardrails (MAX_REVIEW_CYCLES)
- Spec-to-PR mapping — each spec produces one PR (Human Pace signal)
- Team-level sustainability — spec decomposition accounts for human energy, not just modularity (Depletable Collaborator signal)

**Level 5 indicators (sovereign engineering)**:

- Platform-level tooling (reusable plugins)
- Cross-team harness templates
- OpenTelemetry configuration
- Organisational governance documentation
- Multiple agent teams or cloud async agents
- Change cadence metrics reviewed as team health signal (Human Pace signal)
- Sustainable pace as platform metric alongside cost and quality (Depletable Collaborator signal)
- Agent orchestration policies account for human verification capacity (Depletable Collaborator signal)

### Phase 2: Clarifying Questions

After scanning, ask questions to fill gaps that observable evidence
cannot answer. Focus on:

- **Workflow habits**: "Do you write specs before code, or after?"
- **Verification practices**: "Do you verify AI output systematically
  or trust it if it looks right?"
- **Cost awareness**: "Do you know what your AI tools cost per month?"
- **Team practices**: "Does your team have shared AI conventions, or
  does each developer work differently?"
- **Learning**: "Do you capture what you learn from AI sessions?"

Ask 3-5 questions maximum. Each question should disambiguate between
adjacent levels.

### Phase 3: Assessment Document

Produce a timestamped Markdown document at
`assessments/YYYY-MM-DD-assessment.md` with:

1. **Header**: team name, date, assessor, assessed level
2. **Observable evidence**: what was found in the repo (with file paths)
3. **Clarifying responses**: summary of answers
4. **Level assessment**: primary level with rationale
5. **Discipline maturity**: context engineering, architectural
   constraints, guardrail design — each rated
6. **Operational axes (ALCI Part D)**: Composition, Testing,
   Observability, Governance — each placed L1–L5 (see "Operational
   Axes" below)
7. **Habitat Build Gap**: the cognitive level minus the operational
   axes mean, with its interpretation (see below)
8. **Strengths**: what the team does well at their current level
9. **Gaps**: what's missing for the next level
10. **Recommendations**: 3-5 specific actions to progress
11. **Immediate adjustments applied**: what was fixed during this assessment
12. **Workflow operation changes**: accepted changes to how artifacts are used
13. **Reflection**: what the assessment itself revealed
14. **Next assessment date**: suggested quarterly re-assessment

### Phase 4: Immediate Habitat Adjustments

After documenting the assessment, identify adjustments that can be
made immediately — without changing any application code or
requiring team discussion. These are habitat hygiene fixes:

**Stale counts**: If HARNESS.md Status section shows outdated counts,
update them. If README badges show old numbers, update them.

**Missing entries**: If AGENTS.md GOTCHAS is empty but the assessment
revealed gotchas, add them. If REFLECTION_LOG.md has no entries from
this assessment, add one.

**Drift detection**: If HARNESS.md declares constraints that no longer
match reality (tools removed, workflows renamed), update the
declarations.

**Mechanism map staleness**: If the README mechanism map is missing
components that the scan found (new agents, commands, hooks, skills),
update it.

Present each adjustment to the user and apply it immediately. Record
what was adjusted in the assessment document.

### Phase 5: Workflow Operation Recommendations

Based on the gaps identified, recommend specific changes to how
existing workflows and artifacts are *operated* (not built — the
infrastructure exists, it just needs to be used differently):

**Operating rhythm**: Recommend cadences for harness audits, reflection
reviews, mutation score checks, and cost monitoring. Suggest adding
these to a calendar or checklist.

**Habit formation**: Identify which framework habits (from Part VII)
are not yet automatic and suggest specific practice exercises.

**Artifact activation**: Identify artifacts that exist but are not
actively used (e.g., AGENTS.md that isn't read at session start,
MODEL_ROUTING.md that isn't consulted when dispatching agents) and
recommend how to activate them.

**Promotion opportunities**: Identify unverified HARNESS.md constraints
that could be promoted to agent or deterministic with available tooling.

Present each recommendation to the user. For accepted recommendations,
apply the change (update CLAUDE.md with new cadences, promote
HARNESS.md constraints, add operating notes to AGENTS.md). Record
accepted and rejected recommendations in the assessment document.

### Phase 5b: Improvement Plan

After workflow recommendations, invoke the `literacy-improvements`
skill with the assessed level and the gaps from section 7 of the
assessment document. The skill handles target level selection, plan
generation, and interactive execution.

Phase 5 and Phase 5b are complementary:

- **Phase 5** = operate better at your current level
- **Phase 5b** = build toward the next level

The skill records its outcomes (accepted, skipped, deferred) in the
assessment document.

### Phase 6: Assessment Reflection

Capture a reflection on the assessment itself:

- What did the scan reveal that was surprising?
- Where did observable evidence diverge from the team's self-perception?
- What should future assessments pay attention to?

Append this to REFLECTION_LOG.md as a structured entry.

### Phase 7: README Badge

Add or update a badge in the project's README showing the assessed
level:

```text
[![AI Literacy](https://img.shields.io/badge/AI_Literacy-Level_N-COLOUR?style=flat-square)](assessments/YYYY-MM-DD-assessment.md)
```

Colour coding:

| Level | Colour | Hex |
| --- | --- | --- |
| L0 | Grey | `808080` |
| L1 | Light blue | `87CEEB` |
| L2 | Blue | `4682B4` |
| L3 | Teal | `20B2AA` |
| L4 | Green | `2E8B57` |
| L5 | Gold | `DAA520` |

Link target: the assessment document, so anyone who clicks the badge
sees the full assessment with evidence and rationale.

## Scoring Heuristic

The assessed level is the **highest level where the team has
substantial evidence across all three disciplines**. A team with L3
context engineering but L1 verification is assessed at L1 — the
weakest discipline is the ceiling.

| Level | Minimum evidence required |
| --- | --- |
| L0 | Repo exists, team is aware of AI tools |
| L1 | Some AI tool usage, basic prompting |
| L2 | Automated tests in CI, systematic verification of AI output |
| L3 | CLAUDE.md + at least 3 harness constraints enforced + custom agents or skills |
| L4 | Specifications before code + agent pipeline with safety gates |
| L5 | Platform-level governance + cross-team standards + observability |

### Content-shape sophistication adjustments

Surface counts (script count, hook count, agent count, command count)
are insufficient on their own. Apply the content-shape methodology in
`references/sophistication-markers.md` before assigning a level. That
reference defines simple-vs-sophisticated markers per artefact type
and the level adjustments they justify.

The principle: a project with one sophisticated state-based
orchestration script is not at the same maturity as one with ten
simple bash hooks. Sophistication markers raise the floor on the
discipline they evidence (orchestration sophistication → guardrail
design; state-based hook sophistication → architectural constraints).
The weakest-discipline-is-the-ceiling rule still applies — a single
sophisticated artefact does not raise the overall level unless the
other disciplines also have evidence at that level.

Every sophistication marker the assessor applies must be cited
explicitly in the assessment document — what was found and where —
so the level determination is auditable. No silent shifts.

The adjustments are introduced conservatively at this release —
prefer surfacing markers without changing previously-assigned levels
unless the evidence is unambiguous. As the framework accumulates
assessments using the markers, the adjustments will tune.

## Operational Axes (ALCI Part D)

The framework's ALCI was extended with **Part D — four operational
axes** that measure what the team's *habitat actually delivers*,
complementing the cognitive level placement from the scoring heuristic
above. The four axes, their L1–L5 marker statements, the evidence map,
the Habitat Build Gap formula, and the interpretation regimes are
defined in full in `references/operational-axes.md` — the single,
self-contained source (no external repo is read at runtime).

The axes:

- **Composition** — agent topology sophistication
- **Testing** — verification rigour
- **Observability** — agent-activity visibility and feedback loop
- **Governance** — formality/enforceability of AI-use governance

### Administration (hybrid)

- **Evidence-first (default).** During Phase 1b, gather observable repo
  evidence per axis (the evidence map in `references/operational-axes.md`)
  and place each axis L1–L5, citing evidence per axis exactly as the
  cognitive level is evidenced. Ask one or two clarifying questions for
  an axis only where evidence is ambiguous, within the 3–5 question
  budget.
- **Survey (opt-in).** Offer the full 40-statement ALCI Part D survey
  (4 axes × 5 levels × 2 statements) for teams wanting the rigorous
  instrument. Administer on the Strongly-Disagree (1) →
  Strongly-Agree (5) scale, taking the higher-scoring level per axis.
  Record which mode was used in the assessment document.

### Governance axis vs Governance Dimension

The **Governance axis** is the one-line operational placement. The
assessment document also carries the standalone **Governance Dimension**
deep-dive (with the `/governance-constrain` improvement ladder). The two
are cross-referenced and must report a **consistent** governance level —
the axis is the summary, the Dimension is the deep-dive.

### Habitat Build Gap

Combine the cognitive view with the operational view:

```text
Habitat Build Gap = level_placement − operational_axes_mean
```

`operational_axes_mean` is the mean of the four axis scores. Interpret:

| Gap | Name | Meaning |
| --- | --- | --- |
| `abs(gap) < 0.5` | **Coherent** | Team and habitat at the same level. |
| `gap ≥ +0.5` | **Ambition outpaces enablement** | Build the habitat the team's thinking implies. |
| `gap ≤ −0.5` | **Inherited habitat** | Literacy uplift before further harness extension. |

The headline signal is **coherence**, not the size of the level: a
coherent L2/L2 team is healthier than an incoherent L4/L1 team. See
`references/operational-axes.md` for the full treatment and output
format.
