---
title: Your First Assessment
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 4
redirect_from:
  - /tutorials/your-first-assessment/
  - /tutorials/your-first-assessment.html
---

# Your First Assessment

An AI literacy assessment tells you where your team stands in its AI
collaboration practices — not by what you intend, but by observable
evidence in the repository combined with a short conversation. The result
is a timestamped document, a level rating, a gap analysis, and a
prioritised improvement plan.

This tutorial walks you through running `/assess` from start to finish:
what it scans for, what it asks, how to read the output, and how to
act on the improvement plan it generates.

It takes about thirty minutes, most of which is answering clarifying
questions.

---

## Prerequisites

Before running an assessment, your project should have at least some AI
tooling in place — a CI workflow, a CLAUDE.md, some test coverage, or
the beginnings of a harness. An assessment on a completely bare repository
is technically valid (it will return Level 0) but not very interesting.

You also need:

- Claude Code installed with the ai-literacy-superpowers plugin (see
  [Getting Started](getting-started))
- Access to the project repository from your terminal

The assessor can see everything Claude Code can see — files, CI
configuration, directory structure. It does not need credentials or
external access.

---

## Step 1: Run `/assess`

Open a Claude Code session in your project directory and run:

```text
/assess
```

The assessor dispatches a scan immediately. You will not be asked
anything yet — it gathers evidence first, then asks questions.

---

## Step 2: Understand the Scan Results

After a few seconds, the assessor presents a structured summary of what
it found. The output groups findings by framework level:

```text
## Repository Scan

### Level 2 signals (Verification)
  CI workflows: .github/workflows/ci.yml ✓
  Test coverage enforcement: no threshold configured ✗
  Vulnerability scanning: not detected ✗
  Markdownlint: not configured ✗

### Level 3 signals (Habitat Engineering)
  CLAUDE.md: found — 52 lines ✓
  HARNESS.md: found — 2 constraints, 1 enforced ✓
  AGENTS.md: not found ✗
  MODEL_ROUTING.md: not found ✗
  Custom skills: .claude/skills/ — 1 skill ✓
  Custom agents: not found ✗
  Hooks: not configured ✗
  REFLECTION_LOG.md: not found ✗

### Level 4 signals (Specification Architecture)
  Specifications directory: not found ✗
  Implementation plans: not found ✗
  Orchestrator with safety gates: not found ✗

### Level 5 signals (Sovereign Engineering)
  Platform tooling: not detected ✗
  OTel configuration: not detected ✗
```

Read this list from top to bottom. Your level is determined by the
highest level where you have substantial evidence across all three
disciplines — context engineering, architectural constraints, and
guardrail design. **The weakest discipline is the ceiling.**

In the example above: Level 2 signals are present (CI exists) but
coverage enforcement is missing. Level 3 signals show a CLAUDE.md and
HARNESS.md but no AGENTS.md, hooks, or reflection log. The assessment
will land around Level 2-3 depending on what the clarifying questions reveal.

---

## Step 3: Answer the Clarifying Questions

After presenting the scan, the assessor asks 3-5 clarifying questions to
fill gaps that files alone cannot answer. It asks one at a time and waits
for each response before continuing.

Typical questions:

```text
Do you write specs before code, or after — or not at all?
```

```text
When AI generates code for this project, do you verify it
systematically (tests, review) or trust it if it looks right?
```

```text
Does your team have shared AI conventions, or does each developer
work with AI in their own way?
```

```text
Do you know roughly what your AI tools cost per month?
```

Answer honestly. The questions disambiguate between adjacent levels —
a team that writes tests but does not check AI output systematically is
at a different level than one that does both. The assessor is not
grading intent; it is calibrating the evidence.

---

## Step 4: Read the Assessment Document

After the questions, the assessor creates
`assessments/YYYY-MM-DD-assessment.md`. Open it.

The document has several sections:

### Level Assessment

```markdown
## Level Assessment

### Primary Level: 2 — Verification

The project has CI and tests in place, and CLAUDE.md shows awareness
of context engineering, but enforcement is thin (1 of 2 harness
constraints enforced) and verification habits are not systematic —
AI output is reviewed visually rather than through automated checks.
The absence of test coverage thresholds and vulnerability scanning
puts the ceiling at L2 despite the presence of L3 context artifacts.
```

This is the primary finding. Read the rationale — it explains not just
the level but what is holding the project there.

### Discipline Maturity

```markdown
### Discipline Maturity

| Discipline | Strength (1-5) | Evidence |
| --- | --- | --- |
| Context Engineering | 3 | CLAUDE.md present, 1 custom skill, no AGENTS.md |
| Architectural Constraints | 2 | 1 enforced constraint, 1 unverified |
| Guardrail Design | 1 | CI exists, no coverage threshold, no mutation testing |
```

The weakest discipline (here, Guardrail Design at 1) is the ceiling.
This tells you where to invest first — not the area where you are
strongest, but the area holding you back.

### Gaps

```markdown
## Gaps

- No test coverage threshold — AI-generated code could reduce coverage
  without triggering a failure
- No vulnerability scanning in CI — known vulnerabilities in dependencies
  would not be caught automatically
- Hooks not configured — convention enforcement is documentation-only,
  not real-time
- REFLECTION_LOG.md absent — learning from sessions is not captured,
  patterns are lost
```

This is the list of specific, concrete things missing for the next level.
Each gap has a path to closure — that path appears in the improvement
plan.

---

## Step 5: Accept or Defer Immediate Habitat Adjustments

Before the improvement plan, the assessor identifies fixes it can make
right now without requiring team discussion or code changes. These are
habitat hygiene items:

```text
Immediate adjustment 1/3:
  HARNESS.md Status section shows "Constraints enforced: 1/1"
  but the file now has 2 constraints.
  I'll update this to "Constraints enforced: 1/2".

  Apply this fix? (yes/no)
```

```text
Immediate adjustment 2/3:
  README.md harness badge shows "0/1 enforced" but the harness
  now has 1 enforced and 1 unverified.
  I'll update the badge count.

  Apply this fix? (yes/no)
```

Accept these. They take seconds and keep the harness accurate. Each
accepted fix is recorded in the assessment document.

---

## Step 6: Walk Through the Improvement Plan

After the immediate adjustments, the assessor presents the improvement
plan item by item. For each item, you choose to accept, skip, or defer.

```text
Improvement 1/5 (Level 2 → Level 3):
  Gap: No hooks configured
  Action: Run /harness-init and select CI configuration
  Priority: High — hooks are the real-time enforcement layer. Without
  them, conventions are documentation, not enforcement.

  Accept / Skip / Defer?
```

```text
Improvement 2/5 (Level 2 → Level 3):
  Gap: No REFLECTION_LOG.md
  Action: Run /reflect after your next significant session
  Priority: Medium — capturing learnings prevents the same mistakes
  from recurring across sessions.

  Accept / Skip / Defer?
```

If you accept an improvement that involves running a command (like
`/harness-init`), the assessor runs it immediately and resumes the plan
when it completes. If you defer, the item stays in the plan for the next
assessment to pick up.

Use defer for items that need team discussion or that you cannot address
right now. Do not skip an item unless you have a specific reason it does
not apply to your project — skipped items are removed from future
assessments.

The plan is also recorded in the assessment document with an accept /
skip / defer count.

---

## Step 7: Check the README Badge

After the plan, the assessor adds or updates an AI Literacy badge in
your README:

```markdown
[![AI Literacy](https://img.shields.io/badge/AI_Literacy-Level_2-4682B4?style=flat-square)](assessments/2026-04-08-assessment.md)
```

The badge links to the full assessment document. Its colour reflects
the level — blue for Level 2, teal for Level 3, green for Level 4. The
link is always to the most recent assessment, so anyone who clicks it
sees the current evidence.

Check that the badge appears correctly in your README. If the project is
on GitHub and the assessed level is L3 or above, the assessor also adds
the `agent-harness-enabled` topic tag to the repository.

---

## What You Have Now

After completing this tutorial you have:

- A timestamped assessment document at `assessments/YYYY-MM-DD-assessment.md`
  with a level rating, rationale, discipline scores, and specific gaps
- Immediate habitat fixes applied — stale counts, missing badge entries,
  outdated status sections, all corrected
- Workflow operation recommendations: specific changes to how you use
  existing artifacts, accepted or deferred
- An improvement plan with accepted items already run and deferred items
  recorded for the next assessment
- A README badge that shows the current level and links to the evidence

The assessment is a snapshot. It reflects the state of the project at
the time it ran. Run it again in three months and compare — the
discipline scores and gaps tell you whether you are moving in the right
direction.

---

## Planning the Next Quarterly Assessment

The last section of the assessment document includes a suggested
re-assessment date (three months from today). Add that to your calendar
now, before you close the document.

Before the next assessment:

- Work through any deferred improvements — they will show up again
- Run `/harness-audit` to check for drift between declared and actual
  enforcement
- Add entries to `REFLECTION_LOG.md` after significant sessions — the
  assessor checks whether it has recent entries
- If your team composition changed, run `/extract-conventions` to
  re-surface tacit knowledge that may have shifted

When you run `/assess` again, the assessor will compare the new findings
against the previous assessment document. You will see what has changed
and what gaps you have closed.

---

## Next Steps

- [Harness for an Existing Codebase](harness-from-scratch) — if the
  assessment revealed gaps in your harness, start here
- [Creating Your First Skill](your-first-skill) — encode domain knowledge
  the assessor found was missing
- [How-to: Set Up Secret Detection](../how-to/set-up-secret-detection.md) —
  a common Level 2 → Level 3 gap
- [Reference: Commands](../reference/commands.md) — full specification for
  `/assess`, `/reflect`, and `/harness-audit`
