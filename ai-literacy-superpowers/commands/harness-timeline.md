---
name: harness-timeline
description: Emit the Observatory intervention feed to stdout — one JSON line per accepted decision record, with the direction derived rather than declared, and no field that depends on the current date; deliberately not a stored artifact, and it writes nothing
---

# /harness-timeline

Emit the governance intervention feed: when a rule entered, in which direction,
at what enforcement level, on which cohort, and when it stopped.

The Observatory's difference-in-differences design currently has to **infer**
all of that. The decision corpus knows it exactly.

## When to use

- When an analysis needs the intervention timeline
- Redirect it yourself if you want a file: `... timeline > interventions.jsonl`

## Why it is not a stored artifact

A committed derivative is one more thing that can drift from its source, and
`/harness-check` would then have to police it — a third generated artifact whose
only job is to be regenerated.

Deriving it on demand means the feed cannot disagree with the corpus. Anyone who
wants it on disk can redirect it, and the fact that they chose to is then their
problem rather than the corpus's.

## Process

```bash
python3 ai-literacy-superpowers/scripts/harness-registrar.py timeline
```

One JSON object per line, ordered by date then id.

## Two properties worth understanding before you use it

### It carries no field that depends on today

Whether a rule is expired *right now* depends on the clock. A feed carrying that
would produce different output on different days from a corpus nobody touched —
so a difference-in-differences run in November would disagree with the same run
in September.

`expires` is emitted **as data**. The consumer decides what it means at their
analysis date. `state` is `in force` or `superseded`, both of which are facts
about the corpus rather than about the moment.

The command takes no clock at all.

### Every intervention has an end

`superseded_by` and `ends` carry when a rule stopped. Without them, every rule
ever retired would still be counted as in force — a step function that never
steps back.

The interval is `[date, ends)`. A live rule has `ends: null`.

## Fields

| Field | Meaning |
| --- | --- |
| `id`, `date` | The record, and the date it was accepted |
| `classification`, `enforcement`, `surfaces` | What kind of rule, how strongly, reaching where |
| `direction` | `tighten` · `loosen` · `same` · `none` — **derived**, never declared |
| `cohort` | From the record, or `null` |
| `provisional`, `expires` | As data; the consumer decides what expiry means |
| `state` | `in force` or `superseded` |
| `supersedes`, `superseded_by`, `ends` | The chain, and when this intervention stopped |

### `direction` is derived

A self-reported direction is a self-report, and it is the one field the analysis
turns on.

A rule with no predecessor is a `tighten` — it was not there before. A retirement
is a `loosen`. A supersession compares enforcement on the ladder
`advisory < validated < blocked`; when those are equal, a surface set that
contains the old one is a `tighten` and one contained by it is a `loosen`. Two
overlapping-but-different sets are `same`, because nothing honest can be said
about which is stronger.

A `no-change` record is `none` — an intervention of size zero. It is in the feed
deliberately: it records that governance was examined at a known moment and
deliberately not changed, which is a control observation rather than an absence.
Dropping it would convert "we looked and decided no" into "nobody looked".

## What is not in the feed

`proposed` and `rejected` records. Nothing was ever in force, so neither is an
intervention. Both are visible in `harness/decisions/index.md`.

## What this command never does

- Write a file
- Read the clock
- Accept a declared direction
