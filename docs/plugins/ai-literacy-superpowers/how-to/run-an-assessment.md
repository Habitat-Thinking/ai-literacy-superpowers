---
title: Run an Assessment
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 9
redirect_from:
  - /how-to/run-an-assessment/
  - /how-to/run-an-assessment.html
---

# Run an Assessment

Run an AI literacy assessment to determine where your team sits on the ALCI framework,
get a timestamped evidence document, and apply immediate habitat improvements.

---

## 1. Start the assessment

```text
/assess
```

The agent scans the repository for observable evidence, then asks 3-5 clarifying questions
to fill gaps that file inspection cannot answer.

---

## 2. Answer the clarifying questions

The agent asks one question at a time. Questions focus on:

- Whether you write specs before code or after
- How systematically you verify AI output
- Whether your team has shared AI conventions or each developer works independently
- Whether you track what AI tools cost per month
- Whether you capture lessons from AI sessions

Answer honestly — the assessment is most useful when it reflects actual practice,
not aspirations.

---

## 3. Review the assessment document

The agent creates `assessments/YYYY-MM-DD-assessment.md` with:

1. Team name, date, and assessed level
2. Observable evidence found (with file paths)
3. Summary of your answers
4. Level assessment with rationale
5. Discipline maturity ratings (context engineering, constraints, guardrail design)
6. Strengths at your current level
7. Gaps preventing the next level
8. 3-5 specific recommendations

The assessed level is the highest level where you have substantial evidence across all
three disciplines. The weakest discipline is the ceiling.

| Level | Minimum evidence required |
| ----- | ------------------------- |
| L0 | Repo exists, team is aware of AI tools |
| L1 | Some AI tool usage, basic prompting |
| L2 | Automated tests in CI, systematic verification of AI output |
| L3 | CLAUDE.md + 3 or more enforced harness constraints + custom agents or skills |
| L4 | Specifications before code + agent pipeline with safety gates |
| L5 | Platform-level governance + cross-team standards + observability |

---

## 4. Accept or decline immediate adjustments

The agent identifies habitat hygiene fixes that can be applied without team discussion:

- Stale constraint counts in HARNESS.md
- Outdated README badges
- Missing entries in AGENTS.md GOTCHAS
- Mechanism map gaps

For each adjustment, the agent describes the change and asks before applying it.
Accepted changes are applied immediately and recorded in the assessment document.

---

## 5. Accept or decline workflow recommendations

Based on the gaps found, the agent recommends changes to how existing artifacts are
operated (not what to build next). For each recommendation:

- The agent explains what to change and why
- You respond yes or no
- Accepted recommendations are applied immediately — cadences added to CLAUDE.md,
  constraints promoted in HARNESS.md, notes added to AGENTS.md

---

## 6. Check the README badge

After the assessment, the agent adds or updates a badge in the README:

```text
[![AI Literacy](https://img.shields.io/badge/AI_Literacy-Level_N-COLOUR?style=flat-square)](assessments/YYYY-MM-DD-assessment.md)
```

The badge links to the assessment document. Anyone who clicks it sees the full
evidence and rationale.

---

## 7. Re-assess quarterly

AI literacy changes as the team's practices evolve. Run `/assess` quarterly to track
progress and catch practices that have drifted from what the harness declares.

Add this to your `CLAUDE.md` operating cadence:

```markdown
## Operating Cadence

- Quarterly: run `/assess` to re-assess AI literacy level
```
