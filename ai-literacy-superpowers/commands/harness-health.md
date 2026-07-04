---
name: harness-health
description: Generate a harness health snapshot — enforcement status, mutation trends, learning velocity, cadence compliance, and meta-observability checks
---

# /harness-health

Generate a structured health snapshot of the harness's current state.
Optionally run deep verification and produce multi-period trend views.

## Modes

### Quick Mode (default)

No agents dispatched. Reads existing data sources directly:

- HARNESS.md Status section → enforcement ratio, drift status
- HARNESS.md constraint and GC rule definitions → type breakdowns
- REFLECTION_LOG.md → entry count, latest date, Signal field values
- AGENTS.md → gotcha and arch decision counts
- `assessments/` directory → latest assessment date
- MODEL_ROUTING.md → existence and content
- `observability/costs/` → latest cost snapshot for Cost Indicators
- `observability/snapshots/` → previous snapshot for trend comparison

### Deep Mode (`/harness-health --deep`)

Dispatches the `harness-auditor` agent to:

- Verify declared vs actual enforcement (same as /harness-audit)
- Run the five meta-observability checks
- Cross-reference GC rule findings from recent commits
- Check mutation testing CI artifacts for latest scores

Slower but authoritative. Use for quarterly reviews or when quick mode
data seems stale.

### Trends Mode (`/harness-health --trends`)

Reads all snapshots in `observability/snapshots/` and produces a
multi-period trend view. Use for quarterly reviews to see how the
harness has evolved.

## Process

### 1. Check Prerequisites

Verify HARNESS.md exists. If not, tell the user to run `/harness-init`.

Verify `observability/snapshots/` directory exists. If not, create it.

### 2. Gather Data

**Quick mode:** Read data sources listed above. Parse counts and dates.

**Deep mode:** Dispatch harness-auditor with meta-observability checks
enabled. Wait for results.

### 3. Find Previous Snapshot

List files in `observability/snapshots/` matching
`YYYY-MM-DD-snapshot.md`. Sort by filename. Take the most recent one
that is not today's date.

### 4. Compute Trends

If a previous snapshot exists:

1. Parse both snapshots' metric values
2. Compute deltas for each metric
3. Determine trend direction (improving/stable/declining) using ±2%
   threshold for percentages

If no previous snapshot exists, skip trends.

### 5. Compute Meta-Observability

Run the five meta-checks from
`references/meta-observability-checks.md`:

1. Snapshot currency (is the last snapshot < 30 days old?)
2. Cadence compliance (are audit/assess/reflect on schedule?)
3. Learning flow (are reflections being promoted?)
4. GC effectiveness (are GC rules finding anything?)
5. Trend direction (any 3+ snapshot declines?)

Determine aggregate health status: Healthy / Attention / Degraded.

### 6. Generate Markdown Sections

Write the snapshot to `observability/snapshots/YYYY-MM-DD-snapshot.md`
using the format defined in `references/snapshot-format.md`.

Include all sections: Enforcement, Enforcement Loop History, Garbage
Collection, Mutation Testing, Compound Learning, Session Quality,
Diaboli, Cartographer, Operational Cadence, Cost Indicators,
Sustainable Pace, Portfolio Adoption, Regression Indicators, Meta,
Changes Since Last Snapshot, and Trends (if previous snapshot exists).

### 7. Validate Snapshot Structure

**This step is mandatory.** After writing the snapshot file, read
`observability/snapshots/YYYY-MM-DD-snapshot.md` and verify its
structure against `references/snapshot-format.md`.

**Structural checks:**

1. All 16 section headings present in order: Enforcement,
   Enforcement Loop History, Garbage Collection, Mutation Testing,
   Compound Learning, Session Quality, Diaboli, Cartographer,
   Operational Cadence, Cost Indicators, Sustainable Pace, Portfolio
   Adoption, Regression Indicators, Meta, Changes Since Last Snapshot,
   Trends
2. Trends section is conditional — required only when a previous
   snapshot exists (step 3 found one)
3. No YAML `observatory_metrics` block anywhere in the file
   (deprecated in v0.16.0)
4. Each section contains the fields defined in
   `references/snapshot-format.md` for that section

If any check fails, fix the snapshot in place:

- Add missing sections using the field templates from
  `references/snapshot-format.md` with placeholder values
- Reorder sections if present but misordered
- Remove any YAML `observatory_metrics` block if found

Do not regenerate the snapshot. Fix the output directly.

### 8. Update README

Run the `update-health-badge` command (a plugin `bin/` shim, on PATH; do
not use a `${CLAUDE_PLUGIN_ROOT}` path — that variable is unset outside
hooks) to update:

- The health badge colour and text
- The health icon link target (point to the new snapshot)

### 9. Print Summary

Print the full snapshot to the session so the developer sees it
immediately.

If a previous snapshot exists, also print the delta summary:

```text
Since last snapshot (YYYY-MM-DD):
  Constraints: N/M → N/M (unchanged/changed)
  Mutation (Go): N% → N% (±N%)
  Reflections: N → N (+N)
  Reflections with signal: P% → P% (±N%)
  Cadence: on schedule / overdue
  Health: Healthy / Attention / Degraded
```

### 10. Nudge Overdue Actions

If any cadence is overdue, print a nudge:

```text
Overdue actions:
  - /harness-audit last ran N days ago (cadence: quarterly)
  - /reflect last ran N days ago (cadence: monthly)
```

## Reflection log + archive in compound-learning section

The `Compound learning` section of the snapshot now includes:

- Active log entry count: `grep -c '^---$' REFLECTION_LOG.md`
- Archive entry count: `grep -c '^---$' reflections/archive/*.md` summed
- Curation debt (unpromoted entries older than 180 days): scan active
  log for entries dated >180 days ago without a `Promoted` line; report
  count

These three counts appear in the snapshot's `Compound learning` section
alongside reflection cadence and AGENTS.md promotion velocity.
