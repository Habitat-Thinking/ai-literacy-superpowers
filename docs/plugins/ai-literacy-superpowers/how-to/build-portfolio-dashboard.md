---
title: Build an AI Literacy Portfolio Dashboard
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 8
redirect_from:
  - /how-to/build-portfolio-dashboard/
  - /how-to/build-portfolio-dashboard.html
---

# Build an AI Literacy Portfolio Dashboard

Turn your portfolio assessment data into a shareable HTML dashboard
showing AI literacy levels across your repos.

{: .note }
> The plugin includes a `portfolio-dashboard` skill that knows how to
> generate this dashboard. You can ask Claude directly — "build me a
> dashboard from my portfolio assessments" — and the skill handles
> the rest. This guide explains the process step by step for those
> who want to understand or customise what happens.

---

## Prerequisites

You need at least one portfolio assessment. If you haven't run one
yet, use `/portfolio-assess` with the discovery mode that fits your
situation:

```bash
# All repos in a GitHub org
/portfolio-assess --org Habitat-Thinking

# Repos tagged with a specific topic
/portfolio-assess --topic ai-literacy

# Repos in a local directory
/portfolio-assess --local ~/code/myorg/

# Org filtered by topic
/portfolio-assess --org Habitat-Thinking --topic harness
```

This produces `assessments/YYYY-MM-DD-portfolio-assessment.md` in
your current repo. The file contains a level distribution table, a
repo detail table with discipline scores, shared gaps, outliers, and
an improvement plan.

If individual repos have their own `assessments/` directories with
full assessment documents (from `/assess`), the dashboard can pull
discipline-level detail from those too. The portfolio document is
the primary source; individual assessments add depth.

For trend data, you need two or more portfolio assessments taken at
different times. Run `/portfolio-assess` quarterly and keep the
previous files — each one becomes a data point in the trend view.

---

## 1. Generate the Dashboard

Ask Claude Code to read your portfolio assessment files and generate
a self-contained HTML dashboard:

```text
Read all portfolio assessment files in assessments/ (matching
*-portfolio-assessment.md) and generate a self-contained HTML
dashboard (inline CSS, no external dependencies) that visualises:

1. Summary header — portfolio name, date, repo count, median level
2. Level distribution — colour-coded bar or grid showing how many
   repos at each level (L0 grey, L1 light blue, L2 blue, L3 teal,
   L4 green, L5 gold)
3. Trends — if multiple portfolio assessments exist, show how the
   level distribution has changed over time. Median level trend,
   number of repos at L3+ over time, assessment coverage trend.
4. Repo table — each repo with level, confidence, discipline scores,
   last assessed date. Colour-code the level cells. If a repo
   appeared in previous assessments, show its level trajectory
   (e.g. L1 → L2 → L3).
5. Shared gaps — table of gaps affecting 3+ repos with repo count
   and recommended action
6. Improvement plan — organisation-wide actions first, then cluster,
   then individual

Save to assessments/portfolio-dashboard.html
```

The dashboard is self-contained: inline CSS, no external dependencies,
no build step. It opens in any browser and can be emailed or shared
in Slack as a single file.

With a single assessment file, the trends section is omitted. With
two or more, the dashboard automatically shows the trajectory — making
the quarterly cadence visible. Each time you re-run `/portfolio-assess`
and regenerate the dashboard, the trend data grows.

---

## 2. Customise

The dashboard is a generated HTML file. Ask Claude to adjust it to
fit your needs. Useful refinements:

- **Filter repos** — "only show repos tagged `backend`"
- **Add a threshold** — "highlight repos below L2 in red"
- **Add a timestamp** — "add a 'last updated' footer with the
  generation date"
- **Collapse sections** — "make the improvement plan an expandable
  section"
- **Dark mode** — "add a dark mode toggle"
- **Sortable tables** — "make the repo table sortable by clicking
  column headers"

Each refinement is a follow-up prompt. The dashboard stays
self-contained — no external JavaScript libraries needed for basic
interactivity.

---

## 3. Share

Four options depending on your audience:

**Open locally:**

```bash
open assessments/portfolio-dashboard.html
```

**Commit to the repo:** The dashboard lives alongside the assessment
data, versioned in git. Anyone with repo access can open it.

**GitHub Pages:** If the portfolio repo has Pages enabled, the
dashboard is automatically hosted and accessible via a URL.

**Email or Slack:** Attach the single HTML file. No dependencies
means it renders correctly on any machine without setup.

---

## 4. Keep It Current

After each quarterly `/portfolio-assess` run, regenerate the
dashboard with the same prompt. The trends update automatically
because the prompt reads all assessment files in the directory.

The workflow becomes:

1. Run `/portfolio-assess` (quarterly)
2. Regenerate the dashboard (same prompt as step 1 above)
3. Commit both files
4. Share the updated dashboard

Over time, the trend panels tell the story: which repos improved,
which stalled, whether organisational actions (shared templates,
cadence changes) moved the needle.
