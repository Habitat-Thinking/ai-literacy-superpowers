# Per-PR Actuals Format

The **per-PR actuals record** is the single-task, structural sibling of the
quarterly provider snapshot. The integration-agent writes one at integration
time; the `cost-estimator` agent reads accumulated records as a
`kind: calibration` grounding source to narrow per-stage token ranges against
**this repo's own history** (slice S6, spec
`docs/superpowers/specs/2026-06-12-calibration-loop-per-pr-actuals-design.md`).

It is **not** the quarterly snapshot. The quarterly
`observability/costs/<YYYY-MM-DD>-costs.md` is a **provider-level aggregate**
(spend and tokens across all work for a billing period). A per-PR actual is **one
task's** structural footprint plus, when a human supplies them, that task's
token/cost figures. The two never share a file or a directory.

## Home

```text
observability/costs/per-pr/<YYYY-MM-DD>-<branch-slug>-actuals.md
```

The `per-pr/` subdirectory keeps single-task records separate from the quarterly
snapshots in `observability/costs/`, so neither a human reader nor the estimator
mistakes a per-PR actual for a provider aggregate. `<branch-slug>` is the feature
branch name (always known at integration time); the PR number, known later, is
recorded in the `pr` field rather than the filename.

## The no-fabrication rule (the load-bearing honesty contract)

A subagent cannot reliably read "tokens spent on this PR" programmatically. The
record therefore splits cleanly:

- **Structural fields are auto-captured** from the orchestrator context object and
  git — always present, always observed.
- **Token/cost figures are human-supplied or `unavailable`.** When a human pastes
  session figures (e.g. from Claude Code's `/cost`), they are recorded with
  `figures_source: human-supplied`. When nothing is supplied, **every** token/cost
  field is the literal string `unavailable` and `figures_source: unavailable`.

**`unavailable` is never `0` and is never inferred.** An unsupplied figure
contributes structural signal only (which stages this repo exercises); it
contributes nothing to numeric token narrowing. There is no `inferred`
`figures_source` value — figures are observed-and-supplied or they are absent.

## Field set

YAML frontmatter:

| Field | Type | Source | Notes |
| --- | --- | --- | --- |
| `date` | string `YYYY-MM-DD` | auto | Integration date. |
| `branch` | string | auto | The feature branch slug. |
| `issue` | string \| null | auto | Linked issue number (e.g. `#373`), or `null`. |
| `pr` | string \| null | auto | PR number/URL when known, else `null`. |
| `task_summary` | string | auto | One sentence from the context object. |
| `progressed_slice` | string \| null | auto | The slice id this PR delivered (e.g. `S6`), or `null`. |
| `stages_run` | list of strings | auto | Pipeline stages that actually ran — a subset of `spec-writer`, `tdd-agent`, `implementer`, `code-reviewer`, `integration-agent` — inferred from the context object (`spec_changes` ⇒ spec-writer; `failing_tests` ⇒ tdd-agent; `review_result` ⇒ code-reviewer; etc.). |
| `review_cycles` | integer | auto | Reviewer→implementer cycle count (from `review_result`). |
| `files_changed` | integer | auto | From `git diff --name-only main...HEAD`. |
| `languages` | list of strings | auto | Distinct languages/extensions touched. |
| `tokens_by_stage` | list of objects | supplied \| `unavailable` | Each entry: `stage` (string, matching the estimate-record stage labels so the join key is identical) and `tokens` (integer actual, or `unavailable`). |
| `tokens_total` | integer \| `unavailable` | supplied | Whole-task token actual. |
| `cost_usd` | number \| `unavailable` | supplied | Whole-task dollar actual, if the human has it. |
| `figures_source` | enum | auto | `human-supplied` \| `unavailable`. Never `inferred`. |

Body: a short disclosure paragraph stating what was auto-captured versus supplied,
and — when figures are `unavailable` — an explicit line to that effect.

## Validation checklist

1. Frontmatter present with every auto field populated (`date`, `branch`,
   `stages_run`, `review_cycles`, `files_changed`, `languages`,
   `figures_source`).
2. `figures_source` is exactly `human-supplied` or `unavailable`.
3. If `figures_source: unavailable`, **every** token/cost field is the literal
   `unavailable` (no zeros, no blanks, no invented numbers).
4. If `figures_source: human-supplied`, at least `tokens_total` or one
   `tokens_by_stage[].tokens` is a number.
5. `stages_run` entries are drawn from the five known stage labels.
6. The body discloses the auto-vs-supplied split, and states the
   figures-unavailable case explicitly when it applies.

## Worked example — figures supplied

```markdown
---
date: 2026-06-20
branch: feature/widget-export
issue: "#412"
pr: "#418"
task_summary: Add CSV export to the widget report view.
progressed_slice: S2
stages_run: [spec-writer, tdd-agent, implementer, code-reviewer, integration-agent]
review_cycles: 1
files_changed: 7
languages: [go, markdown]
tokens_by_stage:
  - stage: spec-writer
    tokens: 62000
  - stage: tdd-agent
    tokens: 88000
  - stage: implementer
    tokens: 141000
  - stage: code-reviewer
    tokens: 54000
  - stage: integration-agent
    tokens: 39000
tokens_total: 384000
cost_usd: 4.10
figures_source: human-supplied
---

Structural fields auto-captured from the context object and git. Token and cost
figures supplied by the human from `/cost` at integration time. These calibrate
this repo's per-stage token magnitudes for the cost-estimator.
```

## Worked example — figures unavailable

```markdown
---
date: 2026-06-21
branch: fix/legend-overlap
issue: "#420"
pr: "#421"
task_summary: Fix the legend overlapping the chart at narrow widths.
progressed_slice: null
stages_run: [implementer, code-reviewer, integration-agent]
review_cycles: 2
files_changed: 2
languages: [typescript]
tokens_by_stage:
  - stage: implementer
    tokens: unavailable
  - stage: code-reviewer
    tokens: unavailable
  - stage: integration-agent
    tokens: unavailable
tokens_total: unavailable
cost_usd: unavailable
figures_source: unavailable
---

Structural fields auto-captured from the context object and git. Token and cost
figures were not supplied at integration time, so they are recorded as
unavailable — never fabricated. The structural facts (which stages ran, review
cycles, files touched) still calibrate which stages this repo exercises; they
contribute nothing to token-magnitude narrowing.
```
