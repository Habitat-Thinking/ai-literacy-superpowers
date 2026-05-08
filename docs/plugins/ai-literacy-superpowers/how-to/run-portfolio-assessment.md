---
title: Run a Portfolio Assessment
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 20
redirect_from:
  - /how-to/run-portfolio-assessment/
  - /how-to/run-portfolio-assessment.html
---

# Run a Portfolio Assessment

Aggregate AI literacy assessments across multiple repositories into an
organisational portfolio view showing level distribution, shared gaps,
outliers, and a prioritised improvement plan.

---

## 1. Decide how to discover repos

The `/portfolio-assess` command discovers repos through three modes, which
can be combined:

| Flag | What it does |
| --- | --- |
| `--local <path>` | Scan subdirectories under `<path>` for `.git` directories |
| `--org <name>` | List repos in a GitHub organisation via the GitHub CLI |
| `--topic <tag>` | Filter repos by GitHub topic tag |

At least one flag is required. If you omit all flags the command will ask
you to choose.

---

## 2. Pre-assess individual repos (recommended)

The portfolio assessment reads existing assessment documents. Run
`/assess` in each repo before running the portfolio command to get full
discipline scores and gap data:

```bash
cd /path/to/repo
/assess
```

Repos without existing assessments are handled by a lightweight evidence
scan that estimates a level but does not produce discipline scores. Pass
`--no-scan-unassessed` to skip the scan and mark those repos as "not
assessed" instead.

---

## 3. Run `/portfolio-assess`

From a portfolio or platform repo (where you want the output written):

```bash
# Scan a local directory of repos
/portfolio-assess --local ~/code/myorg/

# Scan a GitHub organisation
/portfolio-assess --org my-github-org

# Filter by topic tag
/portfolio-assess --org my-github-org --topic ai-literacy

# Combine local and org, skip unevaluated repos
/portfolio-assess --local ~/code/myorg/ --org my-github-org --no-scan-unassessed
```

The command reports progress as it works through discovery, gathering,
and aggregation:

```text
Discovered 12 repos:
  Local: 8 (from ~/code/myorg/)
  GitHub org: 6 (from my-github-org)
  Total after deduplication: 12

Gathering assessments...
  api-gateway: L3 (assessed 2026-04-01)
  billing-service: L2 (assessed 2026-03-15)
  new-service: L1 (estimated — no prior assessment)
  legacy-auth: not assessed (--no-scan-unassessed)
```

---

## 4. Review the portfolio view

After gathering, the command computes portfolio metrics and identifies
patterns:

- **Level distribution** — count of repos at each level (assessed vs estimated)
- **Portfolio median level** — median across all repos
- **Weakest discipline** — lowest average discipline score across assessed repos
- **Assessment coverage** — percentage of repos with full assessments
- **Shared gaps** — gaps appearing in 3 or more repos (organisational problems)
- **Outliers** — repos significantly above or below the median
- **Stale assessments** — repos not assessed in more than 90 days

Shared gaps drive the improvement plan because fixing them once lifts
multiple repos.

---

## 5. Review the improvement plan

The command generates a prioritised improvement plan grouped by impact
scope:

| Scope | Criteria | Typical actions |
| --- | --- | --- |
| Organisation-wide | Gap in 50%+ of repos | Deploy shared CI templates, establish org-wide cadences |
| Cluster | Gap in 2–4 related repos | Roll out a specific tool, share a constraint pattern |
| Individual | Gap unique to one repo | Defer to that repo's own improvement plan |

Organisation-wide items get highest priority because one action lifts
many repos.

---

## 6. Find the output document

The command writes its output to the current directory:

```text
assessments/YYYY-MM-DD-portfolio-assessment.md
```

Open this file to see the full portfolio view, repo table, shared gap
analysis, and improvement plan. This document is the input for
`/team-api` when updating your Team API with AI literacy data.

---

## 7. Re-run on a schedule

Stale assessments (older than 90 days) reduce the reliability of the
portfolio view. Schedule a regular portfolio assessment — quarterly is a
reasonable default for most organisations.

When individual repos are re-assessed, run `/portfolio-assess` again to
refresh the portfolio view with updated data.

---

## Summary

After completing these steps you have:

- A portfolio view of AI literacy levels across your repos
- Shared gaps identified at the organisational level
- A prioritised improvement plan grouped by impact scope
- A dated `assessments/YYYY-MM-DD-portfolio-assessment.md` document to
  drive team planning
