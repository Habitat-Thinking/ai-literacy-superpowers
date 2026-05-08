---
title: Verify Observatory Signals
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 37
redirect_from:
  - /how-to/verify-observatory-signals/
  - /how-to/verify-observatory-signals.html
---

# Verify Observatory Signals

Run `/observatory-verify` to check that all data signals the Habitat
Observatory expects are present and correctly formatted.

## Prerequisites

- At least one output file exists to verify (a harness health
  snapshot, assessment, reflection log, governance audit report, or
  cost snapshot).

---

## 1. Run the command

```text
/observatory-verify
```

The command runs an 82-signal checklist across five source categories:

- **Harness health snapshots** — enforcement ratios, GC findings,
  mutation scores, compound learning metrics, meta-observability
  checks, YAML metrics block
- **Assessment documents** — level, discipline scores, gaps,
  improvement plans
- **Reflection logs** — entry format, signal classification, session
  metadata
- **Governance audit reports** — drift scores, debt inventory, frame
  alignment, governance summary format
- **Cost snapshots** — spend totals, token usage, model-tier
  breakdown, trend comparison

---

## 2. Read the results

Each signal is reported as one of:

- **PRESENT** — the signal exists and is correctly formatted
- **PARTIAL** — the signal exists but is incomplete or uses a
  deprecated format
- **MISSING** — the signal is absent from the output files

A summary table shows coverage by category and an overall signal
count.

---

## 3. Fix gaps

For PARTIAL or MISSING signals, the report suggests which command
to re-run. Common fixes:

- Missing harness health signals: run `/harness-health`
- Missing governance signals: run `/governance-audit`
- Missing assessment signals: run `/assess`
- Missing cost signals: run `/cost-capture`
- Incomplete reflection entries: check REFLECTION_LOG.md entry format
  against the template header comment

---

## What you have now

A verified signal contract — confirmation that the Observatory can
read all the data it needs from your project's output files.

---

## Next steps

- Run this after generating new snapshots or assessments to confirm
  coverage.
- Fix any PARTIAL signals by regenerating the affected output.
- Use `/harness-health` to generate a fresh snapshot if health
  signals are missing.
