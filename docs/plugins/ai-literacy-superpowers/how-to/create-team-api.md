---
title: Create a Team API
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 23
redirect_from:
  - /how-to/create-team-api/
  - /how-to/create-team-api.html
---

# Create a Team API

Generate or update a Team Topologies Team API document populated with AI
literacy data from a portfolio assessment.

---

## 1. Run a portfolio assessment first

The Team API skill reads from the most recent portfolio assessment
document. If you have not run one yet:

```bash
/portfolio-assess --local ~/code/myteam/
```

This writes `assessments/YYYY-MM-DD-portfolio-assessment.md` to the
current directory. The Team API command reads this file for literacy
levels, discipline scores, shared gaps, and the improvement plan.

---

## 2. Invoke the Team API skill

From the directory that contains your `assessments/` folder:

```bash
/team-api
```

The skill finds the most recent portfolio assessment automatically:

```bash
ls assessments/*-portfolio-assessment.md | sort | tail -1
```

If no portfolio assessment exists, the skill stops and asks you to run
`/portfolio-assess` first.

---

## 3. Choose: update existing or generate new

The skill asks whether you have an existing Team API document:

```text
Do you have an existing Team API document to update?

1. Yes — provide the file path
2. No — generate a new one from the template
```

**Updating an existing file:** The skill reads the file, locates the
`## AI Literacy` or `## AI Engineering Maturity` section, and replaces it
with fresh data from the portfolio assessment. All other sections of your
existing Team API are preserved exactly.

**Generating a new file:** The skill asks for your team name and team type
(stream-aligned, enabling, complicated-subsystem, or platform), then
produces a `team-api.md` with the AI literacy section populated and
placeholder sections for you to complete.

---

## 4. Review what gets populated

The skill maps portfolio data into the Team API as follows:

| Portfolio field | Team API section |
| --- | --- |
| Portfolio median level | AI Literacy header |
| Assessment coverage | AI Literacy header |
| Repo detail table | Repo Levels table |
| Discipline scores | Discipline Scores table |
| Shared gaps | Active Shared Gaps table |
| Organisation-wide improvements | Current Improvement Focus |
| Next assessment date | Next assessment due |

The resulting AI Literacy section looks like this:

```markdown
## AI Literacy

**Portfolio median level**: L3 — Habitat Engineering
**Assessment coverage**: 80% of repos fully assessed
**Last portfolio assessment**: 2026-04-08
**Next assessment due**: 2026-07-08

### Repo Levels

| Repo | Level | Confidence | Last Assessed |
| --- | --- | --- | --- |
| api-gateway | L3 | assessed | 2026-04-01 |
| billing-service | L2 | assessed | 2026-03-15 |

### Active Shared Gaps

| Gap | Repos Affected | Recommended Action |
| --- | --- | --- |
| No harness GC rules | 4/5 | Run /harness-gc to add rules |
```

---

## 5. Complete the non-AI sections

The skill does not fill in the rest of the Team API — those sections are
your team's responsibility. For a new document, the generated file
contains clearly marked placeholders for:

- Communication preferences
- Service offerings and interaction modes
- Team dependencies
- Working agreements

Edit these sections directly in `team-api.md`.

---

## 6. Find the output

The skill reports what it produced:

```text
Team API updated: team-api.md

  AI Literacy section: populated from portfolio assessment (2026-04-08)
  Portfolio median: L3
  Repos covered: 5
  Shared gaps: 2
  Next assessment: 2026-07-08
```

Check the file into your team repository so it is visible to the rest of
the organisation.

---

## Summary

After completing these steps you have:

- A Team API document with an up-to-date AI literacy section
- Literacy levels, discipline scores, and shared gaps visible to other teams
- A documented next assessment date that keeps the data fresh
- Non-AI sections ready for the team to complete
