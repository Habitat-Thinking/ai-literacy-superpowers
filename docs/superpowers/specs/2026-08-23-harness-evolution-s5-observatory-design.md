# Spec: Harness Evolution S5 — Observatory export

**Status:** Approved
**Date:** 2026-08-23
**Issue:** #539
**Epic:** Harness Evolution — the Harness Assayer and the Harness Registrar (#533)
**Depends on:** S0–S4.
**Scope:** `ai-literacy-superpowers` plugin — one command, one script subcommand,
one reference page.
**Explicitly out of scope:** `leap-companion` consumption of the feed; that lives
in the downstream repository.

---

## 1. Problem Statement

The Observatory's difference-in-differences design currently has to **infer**
when governance changed. The corpus knows exactly: when a rule entered, in which
direction, at what enforcement level, on which cohort, and when it stopped.

`/harness-timeline` emits that as a machine-readable intervention feed.

## 2. Why stdout, and not a file

A committed derivative is one more thing that can drift from its source, and
`/harness-check` would then have to police it — a third generated artifact whose
only job is to be regenerated.

The feed is derived on demand and written to stdout. Anyone who wants it in a
file can redirect it, and the fact that they chose to is then their problem
rather than the corpus's.

## 3. The feed carries no time-varying field

The build spec's example line does not say whether "expired" appears in the
feed. It must not.

Whether a rule is expired *right now* depends on the clock, so a feed carrying it
produces different output on different days from an unchanged corpus. That
defeats reproducibility for exactly the analysis the feed exists to serve: a
difference-in-differences run in November would disagree with the same run in
September about a corpus nobody touched.

So the feed emits **facts about the corpus**, never facts about the moment:

- `expires` is emitted **as data**. The consumer decides what it means at their
  analysis date.
- `state` is `in force` or `superseded`. Supersession is a corpus fact; expiry is
  a clock fact.

The command therefore takes no clock at all, and re-running it on an unchanged
corpus is byte-identical regardless of when.

## 4. An intervention needs an end, not only a start

The build spec's example line records when a rule started. A
difference-in-differences design needs to know when it **stopped** — an
intervention with no end is a step function that never steps back, and every rule
ever retired would still be counted as in force.

So each line also carries:

| Field | Why |
| --- | --- |
| `supersedes` | The record this one replaced, or `null` |
| `superseded_by` | Derived from the corpus — the successor, or `null` |
| `ends` | The successor's `approved_at` date, or `null`. The interval is `[date, ends)` |
| `state` | `in force` or `superseded` |

`superseded_by` is derived here exactly as it is everywhere else. The record on
disk stores `null`, per S4.

## 5. Direction

`direction` is the field the analysis actually turns on, and it is derived rather
than declared — a self-reported direction is a self-report.

| Case | Direction |
| --- | --- |
| No `supersedes`, `classification: no-change` | `none` |
| No `supersedes`, otherwise | `tighten` — a rule that was not there before |
| Retirement (`Withdrawn.`) | `loosen` |
| Supersedes, higher enforcement | `tighten` |
| Supersedes, lower enforcement | `loosen` |
| Supersedes, equal enforcement, more surfaces | `tighten` |
| Supersedes, equal enforcement, fewer surfaces | `loosen` |
| Supersedes, otherwise | `same` |

Surfaces break the tie only when enforcement is equal, and only when one set
contains the other. Two overlapping-but-different sets are `same`, because
nothing honest can be said about which is stronger.

**A `no-change` record is an intervention of size zero, and it belongs in the
feed.** It records that governance was examined at a known moment and
deliberately not changed — which for a difference-in-differences design is a
control observation, not an absence. Dropping it would silently convert "we
looked and decided no" into "nobody looked".

## 6. Which records appear

Every record with stored `status: accepted`, exactly once.

`proposed` records are not interventions — nothing was in force. `rejected`
records are not either. Both are visible in `index.md` where they belong.

## 7. Cohort

`cohort` is emitted from the record when present and `null` when absent, per the
build spec.

The epic considered joining it externally at analysis time to keep governance
artifacts cohort-blind (§14 Q4) and kept it on the record. Noting the tension
here rather than in a commit message: a cohort tag on a governance artifact is
visible to whoever writes the next rule, which is a route by which a study can
influence the thing it is studying. If that matters, the field can be dropped
from the record and joined externally without changing this command — it emits
`null` and the join happens downstream.

## 8. Acceptance criteria

| ID | Criterion |
| --- | --- |
| T1 | One line per accepted record; `proposed` and `rejected` emit nothing |
| T2 | Re-running on an unchanged corpus is byte-identical |
| T3 | No field derives from the current date: a record past its `expires` still reports `state: in force`, with `expires` emitted as data |
| T4 | Every line is valid JSON with a stable key order |
| T5 | A record with no predecessor is `tighten`; a `no-change` record is `none` |
| T6 | A retirement is `loosen` |
| T7 | Supersession with lower enforcement is `loosen`; higher is `tighten`; equal is `same` |
| T8 | At equal enforcement, a widened surface set is `tighten` and a narrowed one is `loosen`; overlapping-but-different is `same` |
| T9 | A superseded record carries `state: superseded`, its `superseded_by`, and `ends` |
| T10 | `cohort` is emitted when present and `null` when absent |
| T11 | Ordering is deterministic: by `date`, then by `id` |
| T12 | Round-trip: the line count equals the number of accepted records, with no duplicates and none missing |
| T13 | The command writes nothing to disk |

Tests: `tdad_tests/layer0_deterministic/test-harness-timeline.sh`.

## 9. Rejected alternatives

**Storing the feed as a file.** Rejected per §2 — a committed derivative drifts,
and then needs policing.

**Emitting `expired` as a state.** Rejected per §3. A feed that changes because
the clock moved cannot support a reproducible analysis, and the consumer can
derive it from `expires` at whatever date their analysis uses.

**Taking `direction` from a declared field.** Rejected. A self-reported direction
is a self-report, and the one field the analysis turns on is the last place to
accept one.

**Omitting `no-change` records.** Rejected per §5 — it would convert a control
observation into an absence, and the difference between "we looked and decided
no" and "nobody looked" is exactly what a governance study is trying to measure.
