---
name: assess
description: Run an AI literacy assessment — scan the repo for evidence, ask clarifying questions, produce a timestamped assessment document, apply immediate habitat fixes, recommend workflow changes, capture a reflection, and add a literacy level badge to the README
---

# /assess

Run an AI literacy assessment for this project.

Read the `ai-literacy-assessment` skill before proceeding — it contains
the scoring heuristic, evidence signals, assessment template, and the
immediate adjustment and workflow recommendation phases.

## Process

### 1. Scan

The scan has two sub-phases — habitat document discovery first, then
broader signal scanning.

#### 1a. Habitat document discovery

Apply the discovery methodology defined in
`ai-literacy-superpowers/skills/ai-literacy-assessment/references/habitat-discovery.md`.
That reference lists the alternative paths to scan and the content
markers that confirm a match for `HARNESS.md`, `AGENTS.md`, and
`CLAUDE.md` — including the case where a project's habitat
documents live at non-conventional paths or are embedded inside
other files.

Produce the discovery report described in the reference as the
**first output of `/assess`**, before any maturity claim. Each
finding cites the path matched and the content markers confirmed,
so the user can verify the discovery rather than trust it.

If discovery returns ambiguities (two or more candidate files for
the same habitat document type), STOP and ask the user to confirm
which file is the canonical record before continuing. The
discovery layer never silently picks one — silent picks produce
confidently-wrong assessments.

#### 1b. Broader signal scan

Once the habitat documents are identified, scan the repository for
the rest of the framework evidence: CI workflows, test coverage,
vulnerability scanning, mutation testing, custom skills, agents,
commands, hooks, specifications, implementation plans, orchestrator
safety gates, and platform-level tooling. The detailed search list
lives in the `assessor` agent's Phase 1b instructions.

Record every signal found (with file path) and every signal not
found. For habitat documents specifically, follow the Phase 1a
discovery report — a document found at an alternative path is
*present* and should be treated as such by the maturity
calculation.

### 2. Present and Question

Present what the scan found in a structured summary. Then ask 3-5
clarifying questions to fill gaps — focus on workflow habits, team
practices, cost awareness, and how consistently the observable tools
are actually used.

Ask ONE question at a time. Wait for each answer.

The four **operational axes** (ALCI Part D) are placed **evidence-first**
by default from the scan; fold one or two axis-specific questions in
here only where an axis's evidence is ambiguous. Then offer the **opt-in
40-statement ALCI Part D survey** for teams wanting the rigorous
per-axis score (see the `ai-literacy-assessment` skill and
`references/operational-axes.md`).

### 3. Assess

Apply the scoring heuristic: the assessed level is the highest level
where the team has substantial evidence across all three disciplines
(context engineering, architectural constraints, guardrail design).
The weakest discipline is the ceiling.

### 4. Document

Create `assessments/YYYY-MM-DD-assessment.md` using the template from
the skill's references. Fill every section with specific evidence —
including the **Operational Axes (ALCI Part D)** table (Composition,
Testing, Observability, Governance, each placed L1–L5 with evidence)
and the **Habitat Build Gap** block (level − axes mean = signed gap +
interpretation regime). State which placement mode was used
(evidence-first or survey).

### 5. Validate Assessment Document

**This step is mandatory.** After writing the assessment document,
read `assessments/YYYY-MM-DD-assessment.md` and verify its structure
against `ai-literacy-assessment/references/assessment-template.md`.

**Structural checks:**

1. Required sections present: Observable Evidence, Level Assessment,
   Discipline Maturity, Operational Axes (ALCI Part D), Habitat Build
   Gap, Strengths, Gaps, Recommendations
2. Level Assessment contains a level number (1-5) and a level name
   (e.g. "Level 3 — Adaptive Collaboration")
3. Discipline Maturity contains a markdown table with rows for each
   scored discipline
4. Gaps section contains at least one item (every project has gaps)
5. Operational Axes table names all four axes (Composition, Testing,
   Observability, Governance), each with a placement and evidence
6. Habitat Build Gap block is internally consistent: the gap equals
   level placement minus the operational axes mean (to one decimal),
   and the interpretation matches the regime for that gap (`abs < 0.5`
   → Coherent; `≥ +0.5` → Ambition outpaces enablement; `≤ −0.5` →
   Inherited habitat)
7. The Governance axis placement matches the Governance Dimension
   level (the two governance views must not diverge)

If any check fails, fix the document in place:

- Add missing sections using the structure from the assessment
  template reference
- Recompute the gap and correct the interpretation if they are
  inconsistent; reconcile the Governance axis with the Governance
  Dimension if they diverge
- Ensure the level number is a single digit 1-5 that downstream
  portfolio aggregation can parse

Do not re-dispatch the assessor agent. Fix the output directly.

### 6. Immediate Habitat Adjustments

Identify and apply fixes that require no team discussion — habitat
hygiene that should always be current:

- **Stale HARNESS.md Status**: If the constraint count, enforcement
  ratio, or GC count doesn't match the actual declarations, update it
- **Stale README badges**: If harness badge, mutation testing badge,
  or AI Literacy badge show outdated numbers, update them
- **Stale README mechanism map**: If new agents, commands, hooks,
  skills, or CI workflows exist but aren't in the map, add them
- **Stale README enforcement table**: If constraint type counts are
  wrong, fix them
- **Stale README framework document section**: If new appendices or
  themes exist but aren't listed, add them
- **Empty AGENTS.md sections**: If the assessment revealed gotchas
  or patterns that should be in AGENTS.md, propose additions

Present each adjustment. Apply immediately. Record what was changed
in the assessment document.

### 7. Workflow Operation Recommendations

Based on gaps identified, recommend changes to how existing artifacts
are *operated* (not built — they exist, they just need different usage
patterns). Present each recommendation ONE at a time. For each:

- Describe the recommendation
- Explain why it matters (which gap it closes)
- Ask: "Accept this change?" (yes/no)

If accepted, apply immediately:

- **Operating cadences** → add to CLAUDE.md as a workflow rule
- **Harness constraint promotions** → update HARNESS.md enforcement
  field from unverified to agent or deterministic
- **Artifact activation** → add operating notes to AGENTS.md or
  CLAUDE.md
- **Habit recommendations** → add to AGENTS.md GOTCHAS

Record accepted and rejected recommendations in the assessment
document.

### 7b. Improvement Plan

Invoke the `literacy-improvements` skill with the assessed level from
step 3 and the gaps from section 7 of the assessment document. The
skill asks the user to choose a target level, generates a prioritised
plan, and walks through each improvement interactively
(accept/skip/defer).

Phase 7 recommendations (operate better) and 7b improvements (build
toward next level) are complementary — run both.

### 8. Assessment Reflection

Append a structured reflection to REFLECTION_LOG.md:

- **Date**: today
- **Agent**: assessor (via /assess)
- **Task**: AI literacy assessment
- **Surprise**: what the scan revealed vs what was expected
- **Proposal**: any patterns to add to AGENTS.md
- **Improvement**: what would make the next assessment better

### 9. Check README for broader updates

Beyond the specific adjustments in step 6, do a final check:
has anything else in the README become stale? Update if needed.

### 10. Badge

Add or update an AI Literacy badge in the README:

```text
[![AI Literacy](https://img.shields.io/badge/AI_Literacy-Level_N-COLOUR?style=flat-square)](assessments/YYYY-MM-DD-assessment.md)
```

Colours: L0=808080, L1=87CEEB, L2=4682B4, L3=20B2AA, L4=2E8B57, L5=DAA520

### 10b. Tag Repository

If the assessed level is L3 or above and the project is hosted on
GitHub, add the `agent-harness-enabled` topic tag:

```bash
gh repo edit --add-topic agent-harness-enabled 2>/dev/null
```

Also add the harness-enabled badge to the README if not already present:

```text
[![Agent Harness Enabled](https://img.shields.io/badge/Agent_Harness-Enabled-000000?style=flat-square)](HARNESS.md)
```

If `gh` is not available, the repo is not on GitHub, or the level is
below L3, skip silently.

### 11. Commit

```bash
mkdir -p assessments
git add assessments/ README.md HARNESS.md AGENTS.md CLAUDE.md reflections/active/ REFLECTION_LOG.md
git commit -m "AI Literacy Assessment: Level N — LEVEL_NAME (YYYY-MM-DD)

Assessment with immediate adjustments and accepted workflow changes."
```

### 12. Report

Present a summary to the user:

- Assessed level with one-line rationale
- Top 3 strengths
- Top 3 gaps
- Immediate adjustments applied (count and summary)
- Workflow changes accepted vs rejected
- Top 3 recommendations for longer-term work
- Link to the full assessment document

## Large-repository workflow path (Claude Code only)

On a repository above the deep-research threshold — **file count `> 300`**
— the dispatched `assessor` elects its **workflow mode**: a deep-research
dynamic workflow that fans out by area and adversarially verifies each
finding before synthesis (see the assessor agent doc). This path requires
the **Claude Code** runtime; on Copilot CLI or wherever the workflow
runtime is absent, the assessor **falls back** to its single-context scan
and the assessment proceeds unchanged. The output location and format are
identical on either path.
