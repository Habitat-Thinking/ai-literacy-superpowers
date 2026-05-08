---
title: Run a Governance Audit
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 30
redirect_from:
  - /how-to/run-a-governance-audit/
  - /how-to/run-a-governance-audit.html
---

# Run a Governance Audit

Investigate governance health — falsifiability, semantic drift,
governance debt, and three-frame alignment across all governance
constraints.

---

## Prerequisites

- `HARNESS.md` with at least one governance constraint (a constraint
  that uses governance language or has a `Governance requirement`
  field)
- The ai-literacy-superpowers plugin is installed

---

## 1. Run the audit

```text
/governance-audit
```

The command dispatches the governance-auditor agent, which scans
`HARNESS.md` and runs the full audit process.

---

## 2. Read the falsifiability scores

Each governance constraint is scored on a three-point scale:

| Score | Meaning |
| ----- | ------- |
| Falsifiable | Has verification criteria, evidence, and failure action |
| Partially operationalised | Has some operational detail but gaps |
| Vague | Governance language without operational meaning |

Vague constraints are governance debt. Rewrite them with
`/governance-constrain`.

---

## 3. Check the drift stages

Each constraint gets a drift stage from 1 to 5:

| Stage | Signal |
| ----- | ------ |
| 1 | Healthy — meaning matches reality |
| 2 | Adopted without frame — language present, context missing |
| 3 | Implemented from wrong frame — verification checks form, not substance |
| 4 | Audited from wrong frame — compliance passes, risk persists |
| 5 | Crisis — governance failure has caused real harm |

Constraints at Stage 3 or higher need immediate attention.

---

## 4. Review the debt inventory

Governance debt items are scored by severity (1–3) multiplied by blast
radius (1–3). A score of 9 means critical — the constraint language is
fundamentally misaligned and other constraints depend on it.

| Score | Priority |
| ----- | -------- |
| 1–2 | Address next quarter |
| 3–4 | Address this quarter |
| 6 | Address within two weeks |
| 9 | Address immediately |

---

## 5. Act on recommendations

The audit report ends with prioritised recommendations. Common actions:

- **Vague constraint** → run `/governance-constrain` to rewrite
- **Drifted constraint** → update the operational meaning and re-run
  the three-frame check
- **Debt cycle detected** → review the connected constraints together

The report is saved to `observability/governance/audit-YYYY-MM-DD.md`.

---

## What you have now

A governance audit report with falsifiability scores, drift stages,
debt inventory, and prioritised recommendations.

## Next steps

- [Check governance health](check-governance-health) for a quick
  pulse between audits
- [Build a governance dashboard](build-a-governance-dashboard) to
  visualise trends
- Add `/governance-audit` to your quarterly operating cadence
