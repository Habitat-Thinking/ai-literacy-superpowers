# Observatory Signal Checklist

The authoritative list of all data signals the Habitat Observatory
expects to read from projects running ai-literacy-superpowers. The
`/observatory-verify` command reads this file to determine what to
check.

Update this checklist when new signals are added to format specs
or when the Observatory's expectations change.

---

## Source 1: Snapshot Sections

**File**: `observability/snapshots/YYYY-MM-DD-snapshot.md`
**Format reference**: `references/snapshot-format.md`

| Signal | Section Heading | Key Fields |
| --- | --- | --- |
| Enforcement count | `## Enforcement` | `Constraints: N/M enforced (P%)` |
| Tier breakdown | `## Enforcement` | `Deterministic: X \| Agent: Y \| Unverified: Z` |
| Drift flag | `## Enforcement` | `Drift detected: yes/no` |
| Advisory loop | `## Enforcement Loop History` | `Advisory (edit-time): active since YYYY-MM-DD` |
| Strict loop | `## Enforcement Loop History` | `Strict (merge-time): active since YYYY-MM-DD` |
| Investigative loop | `## Enforcement Loop History` | `Investigative (scheduled): active since YYYY-MM-DD` |
| GC rules count | `## Garbage Collection` | `Rules active: N/M` |
| GC findings | `## Garbage Collection` | `Findings since last snapshot: N` |
| GC cadence | `## Garbage Collection` | `Cadence compliance: on schedule / overdue` |
| Mutation rates | `## Mutation Testing` | Kill rate per language or "not applicable" |
| Mutation trend | `## Mutation Testing` | `Trend: stable/improving/declining` |
| Reflection count | `## Compound Learning` | `REFLECTION_LOG entries: N (M new)` |
| AGENTS.md entries | `## Compound Learning` | `AGENTS.md entries: N (X gotchas, Y arch decisions)` |
| Promotions | `## Compound Learning` | `Promotions since last snapshot: N` |
| Signal coverage | `## Session Quality` | `Reflections with signal: N/M (P%)` |
| Signal distribution | `## Session Quality` | `context: X \| instruction: Y \| workflow: Z \| failure: W` |
| Quality trend | `## Session Quality` | `Quality trend: improving/stable/declining` |
| Days since audit | `## Operational Cadence` | `Last /harness-audit: YYYY-MM-DD (N days ago)` |
| Days since assess | `## Operational Cadence` | `Last /assess: YYYY-MM-DD (N days ago)` |
| Days since reflect | `## Operational Cadence` | `Last /reflect: YYYY-MM-DD (N days ago)` |
| Outer loop overdue | `## Operational Cadence` | `Outer loop overdue: yes/no` |
| Model routing | `## Cost Indicators` | `Model routing configured: yes/no` |
| Cost data | `## Cost Indicators` | `Last cost capture: YYYY-MM-DD / never` |
| Snapshot currency | `## Meta` | `Snapshot cadence: on schedule / overdue` |
| Cadence compliance | `## Meta` | `Cadence compliance: N/4 on schedule` |
| Learning flow | `## Meta` | `Learning flow: active / stalled / inactive` |
| GC effectiveness | `## Meta` | `GC effectiveness: productive / silent` |
| Trend alerts | `## Meta` | `Trend alerts: none / [list]` |
| Health status | `## Meta` | `Health: Healthy / Attention / Degraded` |
| Snapshot stale | `## Regression Indicators` | `Snapshot stale: yes/no` |
| Snapshot age | `## Regression Indicators` | `Snapshot age: N days` |
| Cadence non-compliance | `## Regression Indicators` | `Cadence non-compliance: N of 4` |
| Reflection drought | `## Regression Indicators` | `Consecutive weeks without reflections: N` |
| Regression flag | `## Regression Indicators` | `Regression flag: yes/no` |
| Constraints added | `## Changes Since Last Snapshot` | List or "none" |
| Constraints promoted | `## Changes Since Last Snapshot` | List or "none" |
| Constraints removed | `## Changes Since Last Snapshot` | List or "none" |
| Assessments completed | `## Changes Since Last Snapshot` | Dates and levels or "none" |
| Governance audits | `## Changes Since Last Snapshot` | Dates or "none" |
| Trend table | `## Trends` | Per-metric comparison table |

---

## Source 2: Governance Summary

**File**: `observability/governance/audit-YYYY-MM-DD.md`
**Format reference**: `governance-auditor.agent.md`

| Signal | Field | Format |
| --- | --- | --- |
| Total constraints | `- Total constraints: N` | Integer |
| Falsifiable | `- Falsifiable: N (with verification criteria)` | Integer + annotation |
| Vague | `- Vague: N (lacking operational meaning)` | Integer + annotation |
| Falsifiability ratio | `- Falsifiability ratio: N%` | Percentage |
| Drift stage | `- Semantic drift stage: N/5` | Integer 1-5 |
| Drift velocity | `- Drift velocity: stable/increasing/decreasing` | Enum |
| Debt items | `- Governance debt items: N` | Integer |
| Debt score | `- Aggregate debt score: N (sum of severity x blast radius)` | Integer + annotation |
| Frame alignment | `- Frame alignment score: N%` | Percentage |

**Heading contract**: Must be exactly `## Governance Summary`.

---

## Source 3: Reflection Entries

**File**: `REFLECTION_LOG.md`
**Format reference**: `commands/reflect.md`

| Signal | Field | Format |
| --- | --- | --- |
| Date | `- **Date**: YYYY-MM-DD` | Date |
| Agent | `- **Agent**: [name]` | Free text |
| Task | `- **Task**: [summary]` | Free text |
| Surprise | `- **Surprise**: [text]` | Free text |
| Proposal | `- **Proposal**: [text or "none"]` | Free text |
| Improvement | `- **Improvement**: [text]` | Free text |
| Signal | `- **Signal**: [type]` | Enum: context, instruction, workflow, failure, none |
| Constraint | `- **Constraint**: [text or "none"]` | Free text |
| Duration | `- Duration: [time or "unknown"]` | Free text |
| Model tiers | `- Model tiers used: [distribution or "unknown"]` | Free text |
| Pipeline stages | `- Pipeline stages completed: [stages or "unknown"]` | Free text |
| Agent delegation | `- Agent delegation: [type or "unknown"]` | Enum: full pipeline, partial, manual, unknown |

---

## Source 4: HARNESS.md Structure

**File**: `HARNESS.md`
**Format reference**: `templates/HARNESS.md`

| Signal | Location | Required |
| --- | --- | --- |
| Context section | `## Context` | yes |
| Stack subsection | `### Stack` | yes |
| Conventions subsection | `### Conventions` | yes |
| Constraints section | `## Constraints` | yes |
| GC section | `## Garbage Collection` | yes |
| Observability section | `## Observability` | yes |
| Operating cadence | `### Operating cadence` | yes |
| Health thresholds | `### Health thresholds` | yes |
| Regression detection | `### Regression detection` | yes |
| Status section | `## Status` | yes |
| Last audit field | `Last audit: YYYY-MM-DD` | yes |
| Constraints enforced | `Constraints enforced: N/M` | yes |
| GC active | `Garbage collection active: N/M` | yes |
| Drift detected | `Drift detected: yes/no` | yes |

---

## Source 5: Assessment Document

**File**: `assessments/YYYY-MM-DD-assessment.md`
**Format reference**: `ai-literacy-assessment/references/assessment-template.md`

| Signal | Section | Required |
| --- | --- | --- |
| Observable evidence | `## Observable Evidence` | yes |
| Level assessment | `## Level Assessment` | yes |
| Level number | Integer 1-5 in Level Assessment | yes |
| Discipline maturity | `### Discipline Maturity` (table) | yes |
| Strengths | `## Strengths` | yes |
| Gaps | `## Gaps` | yes |
| Recommendations | `## Recommendations` | yes |

---

## Signal Count

| Source | Signals |
| --- | --- |
| Snapshot sections | 39 |
| Governance summary | 9 |
| Reflection entries | 12 |
| HARNESS.md structure | 14 |
| Assessment document | 7 |
| **Total** | **81** |
