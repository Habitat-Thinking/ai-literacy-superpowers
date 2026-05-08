---
title: Output Validation
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 7
redirect_from:
  - /reference/output-validation/
  - /reference/output-validation.html
---

# Output Validation

Output validation checkpoints verify that structured output matches expected formats before committing or proceeding. Eight commands implement this pattern to catch format deviations early.

---

## The Pattern

Every checkpoint follows the same structure:

1. Producer (agent or command logic) writes the output file
2. Command reads the file back
3. Structural requirements are checked against the format spec reference
4. Deviations are fixed in place — no agent re-dispatch

This verification layer runs synchronously within the command, ensuring consistent output without retry loops or re-delegation.

---

## Checkpoint Table

| Command | Output File | Format Reference | Key Checks |
| --- | --- | --- | --- |
| /harness-health | `observability/snapshots/YYYY-MM-DD-snapshot.md` | `references/snapshot-format.md` | 12 section headings in order, no deprecated YAML block |
| /assess | `assessments/YYYY-MM-DD-assessment.md` | `ai-literacy-assessment/references/assessment-template.md` | Required sections, parseable level number (1-5), discipline maturity table |
| /reflect | `REFLECTION_LOG.md` (last entry) | Entry template in `commands/reflect.md` | 8 mandatory fields, 4 session metadata subfields, Signal enum validation |
| /cost-capture | `observability/costs/YYYY-MM-DD-costs.md` | `cost-tracking/SKILL.md` | Period, total spend, model routing reference present |
| /harness-constrain | `HARNESS.md` (new constraint block) | `templates/HARNESS.md` | Rule/Enforcement/Tool/Scope fields, enum values, governance fields if applicable |
| /harness-init | `HARNESS.md` | `templates/HARNESS.md` | 4 top-level sections, subsections, Status fields, template version marker |
| /superpowers-init | `CLAUDE.md`, `AGENTS.md`, `MODEL_ROUTING.md`, `REFLECTION_LOG.md` | Corresponding `templates/` files | Required sections per file |
| /governance-audit | `observability/governance/audit-YYYY-MM-DD.md` | `governance-auditor.agent.md` | `## Governance Summary` heading, 9 structured fields, value format rules |

---

## Fix Strategy

Checkpoints fix output in place rather than re-dispatching the agent. Common fixes include:

- Adding missing sections from templates with placeholder content
- Normalising enum values to valid options
- Removing deprecated blocks that conflict with current specs
- Reordering sections to match canonical order
- Extracting and validating structured data (numbers, dates, references)

In-place repair is preferred because it preserves agent intent, handles edge cases gracefully, and avoids cascading re-runs that compound errors.

---

## Why Checkpoints Exist

Agents drift from format specs under cognitive load. Reference templates set intent but do not guarantee compliance at output time. Checkpoints are the verification layer — analogous to type checking in compiled code.

They serve two purposes:

- **Detection**: Catch format violations before they propagate downstream
- **Repair**: Fix common deviations locally without human intervention

This reduces friction in the harness loop and maintains data quality for observability, auditing, and report generation.
