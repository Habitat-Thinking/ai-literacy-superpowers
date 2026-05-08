---
title: Build a Governance Dashboard
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 33
redirect_from:
  - /how-to/build-a-governance-dashboard/
  - /how-to/build-a-governance-dashboard.html
---

# Build a Governance Dashboard

Generate an HTML dashboard visualising governance health, constraint
quality, debt trends, and frame alignment.

---

## Prerequisites

- At least one `/governance-audit` run (the dashboard reads audit
  report data)

---

## 1. Generate the dashboard

```text
/governance-health --dashboard
```

This creates a self-contained HTML file at
`observability/governance/governance-dashboard.html`.

---

## 2. Open and review

Open the HTML file in a browser. The dashboard has six sections:

| Section | What it shows |
| ------- | ------------- |
| Health summary | Overall score, constraint quality distribution, last audit date |
| Constraint quality table | Each constraint with falsifiability, drift risk, frame alignment, promotion level |
| Governance debt inventory | Debt items sorted by severity × blast radius score |
| Drift timeline | Line chart showing drift score over quarterly audit data points |
| Three-frame alignment heatmap | Per-constraint grid showing engineering, compliance, and AI system alignment |
| Trend comparison | Sparkline charts for falsifiability ratio, debt size, drift velocity |

---

## 3. Read the signals

Key things to watch:

- **Constraint quality distribution** — if the vague (red) bar is
  growing, governance constraints are being added without
  operationalisation
- **Drift timeline** — an upward trend means governance language is
  diverging from reality faster than you are fixing it
- **Three-frame heatmap** — red cells indicate specific constraints
  where the three frames disagree

---

## 4. Regenerate after each audit

Run `/governance-health --dashboard` after each quarterly
`/governance-audit` to update the trend data. The dashboard reads all
audit reports in `observability/governance/` for historical comparison.

---

## What you have now

A self-contained HTML governance dashboard with no external
dependencies, showing health metrics, debt trends, and frame alignment.

## Next steps

- Share the dashboard with your team for governance visibility
- The governance data also feeds into the
  [portfolio dashboard](build-portfolio-dashboard) when using
  `/portfolio-assess`
