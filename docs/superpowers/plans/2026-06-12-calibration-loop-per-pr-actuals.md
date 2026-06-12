# Implementation Plan — S6 — Calibration loop (per-PR actuals capture)

Companion to
`docs/superpowers/specs/2026-06-12-calibration-loop-per-pr-actuals-design.md`.
Tracking issue #373. Plugin version 0.46.0 → 0.47.0 (new integration-agent
responsibility + new actuals format + calibration ingestion — minor bump).
This is the **final slice** of the cost-estimator pipeline.

## Approach

Three deliverables: a per-PR actuals **format**, an integration-agent **capture
step**, and the **feedback path** (methodology + agent ingestion). All honour two
human decisions taken at spec time: the actuals source is **hybrid
(auto-structural + human-supplied figures, else `unavailable`)**, and calibration
reach is **token ranges only** (no estimate-record format change).

## Steps

1. **Spec + plan** (this PR; spec is the spec-only first commit) — done.
2. **Per-PR actuals format** — new `cost-tracking/references/per-pr-actuals-format.md`:
   field set, `observability/costs/per-pr/` home, the no-fabrication /
   `unavailable` rule, two worked examples (supplied + unavailable), checklist.
3. **cost-tracking SKILL pointer** — document the two actuals records (quarterly
   snapshot + per-PR).
4. **Integration-agent capture step** — new `### 1a` after CHANGELOG, before
   commit; auto-capture structural facts, invite `/cost` figures non-blockingly,
   write to `observability/costs/per-pr/`, stage it with the commit (ships in the
   PR, never to `main`).
5. **Feedback path** —
   - cost-estimation SKILL: rewrite the calibration section from named to
     implemented (token ranges only, no format change); fix the internal anchor
     link and the stale "does NOT do" lines.
   - cost-estimator agent: glob `per-pr/`, narrow per-stage token ranges, emit a
     `kind: calibration` grounding entry + disclosure; absent dir → pre-S6
     behaviour.
   - estimate-record-format reference: update the calibration-seam note to point
     at the shipped format; no field change.
6. **Version ceremony** — plugin.json; README badge + table cell; marketplace
   `plugin_version` + `plugins[]` entry; CHANGELOG 0.47.0.
7. **Docs** — concept page calibration-loop section + See-also entries.
8. **PR ceremony** — feature; spec-only first commit; full diaboli + cartograph;
   CI green before merge.

## Risks / watch-items

- **No-fabrication is the load-bearing honesty contract.** A code-mode diaboli
  should probe every path for a fabricated/zero token figure or a silent
  inference. `unavailable` must stay explicit and non-numeric.
- **No commit to main.** The capture writes before commit so the record ships in
  the PR; verify no path commits the actuals record to `main`.
- **No format change.** Calibration must not add an estimate-record field — only
  the permitted `kind: calibration` entry and a disclosure.
- **Clean degradation.** Zero/absent per-PR history must reproduce exact pre-S6
  behaviour.
