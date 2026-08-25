---
name: observatory-verify
description: Verify that all data signals the Habitat Observatory expects are present and correctly formatted — runs the 81-signal checklist against the latest output files
---

# /observatory-verify

Run the Observatory signal contract verification. Checks that all
data signals the plugin produces match what the Habitat Observatory
expects to read.

## Process

### 1. Read the Signal Checklist

Read `${CLAUDE_PLUGIN_ROOT}/skills/harness-observability/references/observatory-signals.md`.
This is the authoritative list of all signals to verify — 81 signals
across 5 sources.

### 2. Find Latest Output Files

For each signal source, find the latest output file:

- **Snapshot**: most recent file in `observability/snapshots/`
  matching `*-snapshot.md`
- **Governance audit**: most recent file in
  `observability/governance/` matching `audit-*.md`
- **Reflection log**: `REFLECTION_LOG.md` at the project root
- **HARNESS.md**: `HARNESS.md` at the project root
- **Assessment**: most recent file in `assessments/` matching
  `*-assessment.md`

If a source file does not exist, mark all signals from that source
as `NO_OUTPUT` and continue to the next source.

### 3. Verify Each Signal

For each signal in the checklist, read the output file and check:

- **PRESENT** — the expected heading or field exists and contains
  data in the expected format
- **PARTIAL** — the heading or section exists but a required field
  is missing or uses the wrong format
- **MISSING** — the heading or field is not found in the output
- **NO_OUTPUT** — no output file exists for this source

For the Governance Summary, also verify the heading is exactly
`## Governance Summary` (not a variant).

For Reflection entries, check the most recent 3 entries (not all
entries — older entries may predate format changes).

### 4. Produce the Report

Print a table to the session grouped by source:

```text
## Observatory Signal Verification

### Source 1: Snapshot (N/M signals)

| Signal | Expected Location | Status | Notes |
| --- | --- | --- | --- |
| Enforcement count | ## Enforcement | PRESENT | |
| Tier breakdown | ## Enforcement | PRESENT | |
| ... | ... | ... | ... |

### Source 2: Governance Summary (N/M signals)

| Signal | Expected Location | Status | Notes |
| --- | --- | --- | --- |
| ... | ... | ... | ... |

[repeat for all 5 sources]
```

### 5. Print Summary

```text
## Summary

| Source | Present | Partial | Missing | No Output | Total |
| --- | --- | --- | --- | --- | --- |
| Snapshot | N | N | N | N | 39 |
| Governance | N | N | N | N | 9 |
| Reflections | N | N | N | N | 12 |
| HARNESS.md | N | N | N | N | 15 |
| Assessment | N | N | N | N | 7 |
| **Total** | **N** | **N** | **N** | **N** | **81** |
```

If any signals are PARTIAL or MISSING, list them with a brief note
on what's missing and which file would need to change to fix it.

### 6. Recommend Actions

For MISSING signals, suggest the specific fix:

- Missing snapshot section → run `/harness-health`
- Missing governance summary field → run `/governance-audit`
- Missing reflection fields → check `/reflect` command for format
  updates
- Missing HARNESS.md section → run `/harness-init` or
  `/harness-upgrade`
- Missing assessment section → run `/assess`

For PARTIAL signals, describe what's incomplete and how to fix it
in place.
