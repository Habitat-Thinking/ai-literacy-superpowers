---
title: Check Governance Health
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 31
redirect_from:
  - /how-to/check-governance-health/
  - /how-to/check-governance-health.html
---

# Check Governance Health

Quick governance pulse check between quarterly audits.

---

## Prerequisites

- At least one previous `/governance-audit` run (for meaningful data)

---

## 1. Run the health check

```text
/governance-health
```

The command reads your most recent audit report and current
`HARNESS.md` to produce a summary table.

---

## 2. Read the metrics

| Metric | What it means |
| ------ | ------------- |
| Constraints | Total governance constraints in HARNESS.md |
| Falsifiability | Proportion scored as falsifiable (target: > 0.75) |
| Drift score | Overall semantic drift risk (low / medium / high) |
| Debt items | Number of governance debt items |
| Frame alignment | Proportion with confirmed three-frame alignment |
| Last audit | Date of most recent governance audit |
| Drift velocity | Whether drift is stable, increasing, or decreasing |

---

## 3. Interpret the colours

| Colour | Condition |
| ------ | --------- |
| Green | Falsifiability > 0.75, drift low, debt < 3, audit < 90 days |
| Amber | Falsifiability 0.50–0.75, drift medium, debt 3–5, audit 90–180 days |
| Red | Falsifiability < 0.50, drift high, debt > 5, audit > 180 days |

---

## 4. Act on recommendations

If the health check flags issues:

- **Audit stale** → run `/governance-audit`
- **Falsifiability low** → rewrite vague constraints with
  `/governance-constrain`
- **Drift high** → run a full audit to identify which constraints
  have drifted

---

## What you have now

A current view of governance health without running a full audit.

## Next steps

- [Run a governance audit](run-a-governance-audit) if any metric is
  red
- [Build a governance dashboard](build-a-governance-dashboard) for a
  visual overview
