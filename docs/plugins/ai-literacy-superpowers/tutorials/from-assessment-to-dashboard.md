---
title: From Assessment to Dashboard
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 5
redirect_from:
  - /tutorials/from-assessment-to-dashboard/
  - /tutorials/from-assessment-to-dashboard.html
---

# From Assessment to Dashboard

This tutorial walks you through running a portfolio assessment across
multiple repositories and generating a shareable HTML dashboard from
the results. By the end you will have a self-contained dashboard file
that shows AI literacy levels, shared gaps, and improvement priorities
across your whole organisation — shareable by email, Slack, or GitHub
Pages.

Plan for about thirty minutes, including time to work through the
discovery conversation and review the dashboard output.

---

## Prerequisites

You need:

- Claude Code with the ai-literacy-superpowers plugin installed
- Two or more repositories to assess
- At least one of those repositories already assessed with `/assess`
  (this gives you full discipline scores rather than estimates)
- The GitHub CLI (`gh`) if you want to discover repos by organisation
  or topic tag — optional if you are scanning a local directory

If you haven't run a single-repo assessment yet, follow the
[Getting Started](getting-started) tutorial first to install the
plugin and run `/harness-init`, then use `/assess` to get an
assessment document in at least one repo before continuing here.

---

## Step 1: Choose a Discovery Mode

The `/portfolio-assess` command needs to know which repositories to
include. It supports three discovery modes, and you can combine them.

### Local mode

If your repositories are all cloned on your machine under a shared
parent directory:

```text
/portfolio-assess --local ~/code/myorg/
```

The command scans every subdirectory under that path that contains a
`.git` directory. This is the fastest option — no network calls, no
authentication required.

### GitHub organisation mode

If your repositories live in a GitHub organisation and you have the
GitHub CLI authenticated:

```text
/portfolio-assess --org my-github-org
```

The command calls `gh repo list` to enumerate up to 200 repositories
in the organisation. Useful when you don't have all repos cloned
locally.

### GitHub topic mode

If your organisation uses topic tags to mark which repositories are
AI-literacy-tracked:

```text
/portfolio-assess --topic ai-literacy
```

Or combine with `--org` to scope to one organisation:

```text
/portfolio-assess --org my-github-org --topic ai-literacy
```

### Combining modes

Local repos take precedence when modes are combined — already-cloned
repos are not re-fetched from GitHub. Duplicates are removed by repo
name.

For this tutorial, pick the mode that matches your setup. If you're
not sure, start with `--local` pointed at the directory where you keep
your projects.

---

## Step 2: Run `/portfolio-assess`

Open Claude Code in the repo where you want the portfolio output
written — typically a platform repo or a dedicated `assessments` repo.
Then run the command with your chosen mode:

```text
/portfolio-assess --local ~/code/myorg/
```

The command works in three phases, reporting progress as it goes.

### Discovery

```text
Discovered 8 repos:
  Local: 8 (from ~/code/myorg/)
  Total after deduplication: 8
```

If you see fewer repos than expected, check that each one has a `.git`
directory at its root. Subdirectories of monorepos are not counted as
separate repos.

### Gathering assessments

The command checks each repo for an existing `assessments/` directory
and reads the most recent assessment file it finds:

```text
Gathering assessments...
  api-gateway:       L3 (assessed 2026-04-01)
  billing-service:   L2 (assessed 2026-03-15)
  auth-service:      L2 (assessed 2026-02-28)
  frontend:          L1 (estimated — no prior assessment)
  legacy-payments:   L1 (estimated — no prior assessment)
  data-pipeline:     L2 (assessed 2026-03-20)
  infra-modules:     L1 (estimated — no prior assessment)
  docs-site:         L0 (estimated — no prior assessment)
```

Repos marked `estimated` were scanned for observable evidence
(CI workflows, CLAUDE.md, HARNESS.md, test configuration) and given
an estimated level. Estimates lack discipline scores, so they appear
in the dashboard with lower confidence than fully assessed repos.

To get full scores for estimated repos, run `/assess` in each one
before re-running the portfolio command. For now, continue with the
mix — the dashboard distinguishes assessed from estimated.

If you want to skip estimated repos entirely, add
`--no-scan-unassessed` to the command. Those repos appear as "not
assessed" in the output.

### Completion summary

```text
Portfolio assessment complete.

  Repos: 8 total (4 assessed, 4 estimated, 0 not assessed)
  Median level: L2
  Shared gaps: 3 (affecting 3+ repos)
  Stale assessments: 1 (older than 90 days)
  Organisation-wide improvements: 2
  Document: assessments/2026-04-08-portfolio-assessment.md
```

---

## Step 3: Understand the Portfolio Assessment Document

Open the file the command just wrote:

```bash
open assessments/2026-04-08-portfolio-assessment.md
```

The document has four key sections you will use to understand where
the organisation stands.

### Level distribution

A table showing how many repos are at each level, split by confidence:

```text
| Level | Assessed | Estimated | Total |
|-------|----------|-----------|-------|
| L0    | 0        | 1         | 1     |
| L1    | 0        | 3         | 3     |
| L2    | 3        | 0         | 3     |
| L3    | 1        | 0         | 1     |
| L4    | 0        | 0         | 0     |
| L5    | 0        | 0         | 0     |

Portfolio median: L2
Assessment coverage: 50% (4/8 repos fully assessed)
```

The median level is the single most useful number for an organisation.
A median of L2 means most teams have systematic verification in place
but haven't yet invested in habitat engineering — CLAUDE.md, harness
constraints, and custom skills are the next frontier.

### Repo table

Each repo as a row with level, discipline scores (where available),
last assessed date, and a note for stale assessments:

```text
| Repo             | Level | Context | Constraints | Guardrails | Assessed     |
|------------------|-------|---------|-------------|------------|--------------|
| api-gateway      | L3    | 4/5     | 3/5         | 4/5        | 2026-04-01   |
| billing-service  | L2    | 3/5     | 2/5         | 3/5        | 2026-03-15   |
| auth-service     | L2    | 2/5     | 2/5         | 2/5        | 2026-02-28 ⚠ |
| data-pipeline    | L2    | 3/5     | 3/5         | 2/5        | 2026-03-20   |
| frontend         | L1    | —       | —           | —          | estimated    |
| legacy-payments  | L1    | —       | —           | —          | estimated    |
| infra-modules    | L1    | —       | —           | —          | estimated    |
| docs-site        | L0    | —       | —           | —          | estimated    |
```

The warning flag on `auth-service` indicates a stale assessment
(older than 90 days). Its data is less reliable for decisions.

### Shared gaps

Gaps that appear in three or more repos are organisational problems,
not individual repo problems. Fixing them once — through a shared CI
template, a skill library, or a team-wide cadence — lifts multiple
repos at the same time:

```text
Shared gaps (affecting 3+ repos):

1. No HARNESS.md or equivalent context file
   Repos affected: 6 (all estimated + auth-service, billing-service)
   Recommended action: /harness-init (run in each affected repo)
   Organisation-wide impact: High — HARNESS.md is the L3 foundation

2. No secret scanning
   Repos affected: 5
   Recommended action: /harness-constrain (add gitleaks constraint)

3. Tests not enforced in CI
   Repos affected: 4 (estimated repos)
   Recommended action: Add test step to CI workflow
```

### Improvement plan

The plan is grouped by impact scope:

**Organisation-wide (50%+ of repos):** One action lifts many repos.
These are your highest-leverage investments. In this example, rolling
out HARNESS.md through a shared template would move six repos toward L3
at once.

**Cluster (2-4 related repos):** Share a specific tool or constraint
pattern across a small group of related repos.

**Individual:** Unique to one repo. The plan defers these to each
repo's own assessment improvement plan.

---

## Step 4: Generate the HTML Dashboard

Now convert the portfolio assessment into a shareable dashboard. Ask
Claude Code directly:

```text
Read all portfolio assessment files in assessments/ (matching
*-portfolio-assessment.md) and generate a self-contained HTML
dashboard (inline CSS, no external dependencies) that visualises:

1. Summary header — portfolio name, date, repo count, median level
2. Level distribution — colour-coded showing how many repos at each
   level (L0 grey, L1 light blue, L2 blue, L3 teal, L4 green, L5 gold)
3. Repo table — each repo with level, confidence, discipline scores,
   last assessed date. Colour-code the level cells.
4. Shared gaps — table of gaps affecting 3+ repos with repo count
   and recommended action
5. Improvement plan — organisation-wide actions first, then cluster,
   then individual

Save to assessments/portfolio-dashboard.html
```

The `portfolio-dashboard` skill handles this end to end. Claude reads
every file matching `*-portfolio-assessment.md` in the `assessments/`
directory, parses the data, and produces the dashboard. When it
finishes:

```text
Dashboard generated: assessments/portfolio-dashboard.html

  Repos: 8 (4 assessed, 4 estimated, 0 not assessed)
  Median level: L2
  Trend data: 1 quarterly assessment (no trend yet)
  Shared gaps: 3

Open with: open assessments/portfolio-dashboard.html
```

---

## Step 5: Review the Dashboard Panels

Open the dashboard:

```bash
open assessments/portfolio-dashboard.html
```

The dashboard has six panels.

**Summary header.** Portfolio name (derived from your discovery
source), date, total repos, and median level shown prominently. This
is the one-line answer to "where are we?"

**Level distribution.** A colour-coded bar or grid showing the count
of repos at each level. Grey for L0, light blue for L1, blue for L2,
teal for L3, green for L4, gold for L5. Estimated repos are shown
with a lighter tint to distinguish them from fully assessed ones.

**Trends.** With only one assessment file, this section reads "no
trend data yet." After you run a second quarterly assessment and
regenerate the dashboard, it will show a median level trend line,
the count of repos at L3+ over time, and per-repo level trajectories.
This is the panel that makes the quarterly cadence worth maintaining.

**Repo table.** Each repo as a row. Level cells are colour-coded.
Discipline score columns (context, constraints, guardrails) show
numerical scores for assessed repos and "—" for estimated ones. A
warning icon marks stale assessments.

**Shared gaps.** The same gap table from the assessment document, now
formatted as a clickable reference. Each row shows the gap, the number
of repos affected, and the recommended command or action.

**Improvement plan.** Organisation-wide items first, in a highlighted
section. Cluster and individual items follow. The grouping makes it
easy to see which actions to prioritise when planning a quarterly
improvement sprint.

---

## Step 6: Customise the Dashboard

The dashboard is a generated HTML file — ask Claude to refine it after
generation. Each refinement is a follow-up prompt. Common requests:

**Filter to a subset of repos:**

```text
Rewrite the dashboard to only include repos tagged `backend`
```

**Highlight repos below a threshold:**

```text
Add red highlighting to any repo in the table that is below L2
```

**Add dark mode:**

```text
Add a dark mode toggle button to the dashboard
```

**Make the table sortable:**

```text
Make the repo table sortable by clicking any column header
```

**Collapse the improvement plan:**

```text
Make the improvement plan an expandable section — collapsed by default
```

All customisations stay self-contained. The skill's design constraint
is no external dependencies — no CDN links, no npm packages, no build
step. Basic interactivity (sort, collapse, toggle) is achievable with
a small amount of inline JavaScript.

---

## Step 7: Share the Dashboard

You have four options depending on your audience.

**Open locally.** The file opens in any browser with no setup:

```bash
open assessments/portfolio-dashboard.html
```

**Commit to the repo.** The dashboard lives alongside the assessment
data, versioned in git. Anyone with access to the repo can open it:

```bash
git add assessments/portfolio-dashboard.html assessments/2026-04-08-portfolio-assessment.md
git commit -m "Add Q2 2026 portfolio assessment and dashboard"
git push
```

**GitHub Pages.** If the portfolio repo has Pages enabled, the
dashboard is automatically hosted at a URL and accessible to anyone
you share the link with — no authentication required.

**Email or Slack.** Attach `portfolio-dashboard.html` as a file. No
dependencies means it renders correctly on any machine without setup.
The self-contained constraint makes this option reliable.

---

## Step 8: Keep It Current

The trend panel is what makes the quarterly cadence valuable. Each
time you run `/portfolio-assess` and regenerate the dashboard, the
historical data grows and the trend lines become meaningful.

The workflow is:

1. Run `/portfolio-assess` with the same flags (quarterly)
2. Regenerate the dashboard with the same prompt (or save the prompt
   as a custom command for convenience)
3. Commit both the new assessment file and the updated dashboard
4. Share the updated dashboard

After a year of quarterly assessments you will have four data points.
The trend panel will show whether shared gaps are closing, whether
the median level is rising, and which repos are improving fastest.
This is the evidence that turns AI literacy work from an assertion
into a measurable outcome.

{: .note }
> **Stale assessments.** Repos whose most recent assessment is older
> than 90 days are flagged in the portfolio view. Re-run `/assess` in
> those repos before the next portfolio run to keep the data current.

---

## What You Have Now

After completing this tutorial you have:

- A dated portfolio assessment document at
  `assessments/YYYY-MM-DD-portfolio-assessment.md` recording the
  current state of AI literacy across your repositories
- A self-contained HTML dashboard at
  `assessments/portfolio-dashboard.html` ready to share
- A list of shared gaps and an improvement plan grouped by
  organisational impact
- A quarterly regeneration workflow that adds trend data over time

---

## Next Steps

- [The Improvement Cycle](the-improvement-cycle) — walk one repo from
  L2 to L3 using the assessment's improvement plan
- [How-to: Run a Portfolio Assessment](run-portfolio-assessment.md)
  — flags, options, and edge cases for the `/portfolio-assess` command
- [How-to: Build a Portfolio Dashboard](build-portfolio-dashboard.md)
  — prompt variations and customisation recipes for the dashboard
- [Reference: Commands](commands.md) — full specification for
  `/portfolio-assess` and related commands
