# Intervention feed format

`/harness-timeline` emits one JSON object per line to **stdout**: when a
governance rule entered, in which direction, at what enforcement level, on which
cohort, and when it stopped.

This is the timeline the Observatory's difference-in-differences design otherwise
has to infer.

## Not a stored artifact

A committed derivative is one more thing that can drift from its source, and
`/harness-check` would then have to police it — a third generated artifact whose
only job is to be regenerated.

Redirect it if you want a file. The fact that you chose to is then your problem
rather than the corpus's.

## A line

```json
{"id":"HDR-2026-01-01-observed-evidence","date":"2026-01-01","classification":"harness-loop","enforcement":"validated","direction":"tighten","surfaces":["claude-code","codex"],"cohort":"b","provisional":true,"expires":"2026-04-01","state":"superseded","supersedes":null,"superseded_by":"HDR-2026-02-01-weakened","ends":"2026-02-01"}
```

| Field | Meaning |
| --- | --- |
| `id` | The decision record |
| `date` | The date it was accepted — the start of the interval |
| `classification` | The layer that owns the rule |
| `enforcement` | The level it intends |
| `direction` | `tighten` · `loosen` · `same` · `none` — derived |
| `surfaces` | The surfaces it names |
| `cohort` | From the record, or `null` |
| `provisional` | Whether permanence is still unearned |
| `expires` | As data, or `null`. **Not** interpreted here |
| `state` | `in force` or `superseded` |
| `supersedes` | The record this replaced, or `null` |
| `superseded_by` | Derived from the corpus, or `null` |
| `ends` | The successor's date, or `null`. The interval is `[date, ends)` |

Ordered by `date`, then `id`. Re-running on an unchanged corpus is byte-identical.

## No field depends on today

Whether a rule is expired *right now* is a fact about the clock, not about the
corpus. A feed carrying it would produce different output on different days from
a repository nobody touched — so a difference-in-differences run in November
would disagree with the same run in September about the same data.

So `expires` is emitted **as data** and the consumer decides what it means at
their analysis date, and `state` is limited to `in force` and `superseded`, both
of which are corpus facts.

The command reads no clock at all.

## Every intervention has an end

`superseded_by` and `ends` are what make the feed usable. Without them, every
rule ever retired is still counted as in force: a step function that never steps
back.

A live rule has `superseded_by: null` and `ends: null`.

## `direction` is derived, never declared

A self-reported direction is a self-report, and this is the one field the
analysis turns on.

| Case | Direction |
| --- | --- |
| No predecessor, `classification: no-change` | `none` |
| No predecessor, otherwise | `tighten` — the rule was not there before |
| A retirement (`Withdrawn.`) | `loosen` |
| Supersedes, higher enforcement | `tighten` |
| Supersedes, lower enforcement | `loosen` |
| Supersedes, equal enforcement, surfaces widened | `tighten` |
| Supersedes, equal enforcement, surfaces narrowed | `loosen` |
| Supersedes, otherwise | `same` |

The ladder is `advisory < validated < blocked`. Surfaces break the tie only when
enforcement is equal **and** one set contains the other; two
overlapping-but-different sets are `same`, because nothing honest can be said
about which is stronger.

### `no-change` is in the feed on purpose

An intervention of size zero. It records that governance was examined at a known
moment and deliberately not changed — a **control observation**, not an absence.

Dropping it would silently convert "we looked and decided no" into "nobody
looked", and the difference between those two is exactly what a governance study
is trying to measure.

## What is excluded

`proposed` and `rejected` records. Nothing was ever in force, so neither is an
intervention. Both appear in `harness/decisions/index.md`.

## On the cohort tag

`cohort` lives on the decision record and is emitted from it.

Worth naming: a cohort tag on a governance artifact is visible to whoever writes
the next rule, which is a route by which a study can influence the thing it is
studying. If that matters for a given study, drop the field from the record and
join it externally at analysis time — this command emits `null` and the join
happens downstream, with no change here.

## See also

- [Harness Decision Record format](harness-decision-records.md)
- [Enforcement report format](enforcement-report-format.md)
- Spec: `docs/superpowers/specs/2026-08-23-harness-evolution-s5-observatory-design.md`
