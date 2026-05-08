---
title: Governance Summary Format
---
# Governance Summary Format

The machine-readable section in governance audit reports that the
Habitat Observatory and other downstream consumers parse by regex.

---

## Location

Written by the governance-auditor agent to
`observability/governance/audit-YYYY-MM-DD.md`. Must appear
immediately after the `# Governance Audit — YYYY-MM-DD` heading.

---

## Required Heading

```text
## Governance Summary
```

The heading must be exactly `## Governance Summary`. Not
`## Summary`, not `## Overview`. The Observatory parses this
heading by exact regex match.

---

## Required Fields

All nine fields must appear in this order, each on its own line.
Every field is mandatory even when the value is zero.

```text
## Governance Summary

- Total constraints: N
- Falsifiable: N (with verification criteria)
- Vague: N (lacking operational meaning)
- Falsifiability ratio: N%
- Semantic drift stage: N/5
- Drift velocity: stable/increasing/decreasing
- Governance debt items: N
- Aggregate debt score: N (sum of severity x blast radius)
- Frame alignment score: N%
```

---

## Field Computation

| Field | How to compute |
| --- | --- |
| Total constraints | Count governance constraints in HARNESS.md (those with a `Governance requirement` field) |
| Falsifiable | Count constraints scored "Falsifiable" in the audit |
| Vague | Count constraints scored "Vague" in the audit. Report `0` if none |
| Falsifiability ratio | `(falsifiable / total) * 100`, rounded to nearest integer |
| Semantic drift stage | Integer 1-5, followed by `/5`. 1 = no drift. Never use 0 |
| Drift velocity | Compare current drift stage with previous audit. `stable` if unchanged, `increasing` if rose, `decreasing` if fell. `stable` if no previous audit |
| Governance debt items | Count of items in the debt inventory. `0` if empty |
| Aggregate debt score | Sum of `severity x blast_radius` across debt items. `0` if none |
| Frame alignment score | `(aligned / total) * 100`, rounded to nearest integer |

---

## Validation

The `/governance-audit` command validates this section after the
governance-auditor agent writes the report (step 5). If the heading
is wrong, fields are missing, or values use the wrong format, the
command fixes the output in place.

See [Output Validation](output-validation.md)
for the general checkpoint pattern.
