# Pact file format

`~/.claude/pacts.md` holds the limits you set for yourself, in advance, in
clear weather. The cadence sentinels read it; none of them writes it except
`/mast tune`, and nothing creates it on your behalf.

## Why it is not in `HARNESS.md`

`HARNESS.md` is the **repository's** declaration surface. A pact file is the
**person's**.

A stop hour, a focus window, and a concurrency limit are properties of a
human, not of a project. A repo-scoped pact file cannot answer "whose pact is
this" in a project with five contributors, and a per-repo concurrency limit
compared against a machine-global session count is a units mismatch — the same
three live sessions would be compliant in one repo and in breach in another,
with the advisory depending on which directory you happened to be sitting in.

The pact file is per-machine, per-person, and never committed. Nothing about
you is written into any repository's history.

`## Cognitive reservoir` stays in `HARNESS.md` and is unchanged.

## Everything here is optional

A sentinel that finds its block missing says so and carries on:

```text
no `Budgets` block declared — running in observe-only mode
```

Absence is never an error, never a warning, and never a gate. A block you have
not declared is not a failure — it is a pact you have not made.

## Three states

| State | Meaning | Behaviour |
| --- | --- | --- |
| **Absent** | No file, or no such heading | Observe-only note, continue |
| **Malformed** | Heading present, but a mandatory clause is missing | Observe-only note plus a line naming what is missing, continue |
| **Declared** | Heading present and well-formed | Read it |

Malformed degrades to observe-only, never to a gate. If you delete a block's
governing clause, no sentinel will hold you to that pact.

## Writing values

Keep each value on its own clean `key: value` line, and keep notes in prose
**below** the values — never as a trailing `#` comment on a value line. The
parser reads everything after the first colon, so an inline comment silently
becomes part of the value.

Values may contain colons and spaces. `hard_stop_hour: 18:30` reads as
`18:30`, and `daily_cost_ceiling: not observable` keeps its space.

## `## Session WIP`

```text
- max_concurrent_sessions: 2
- max_switches_per_hour: 4
- stale_after_hours: 12
- enforcement: advisory
```

| Key | Grammar | Required | Meaning |
| --- | --- | --- | --- |
| `max_concurrent_sessions` | integer | yes | How many live sessions you will accept, counted across every repository on this machine |
| `max_switches_per_hour` | integer | no | |
| `stale_after_hours` | integer | no (default 12) | How long a session may go without finishing a turn before it is treated as gone |
| `enforcement` | `advisory` \| `strict` | no (default `advisory`) | See below |

**Mandatory clause:** *This is a gate on sessions, never on the person. It
counts; it does not assess.*

`enforcement: advisory` reports a breach and proceeds. `enforcement: strict`
also **asks** for a disposition — park an existing session, or say what is
urgent enough to keep them all open.

**Neither mode can stop you.** Hooks in this plugin are advisory and never
block, and a `SessionStart` hook in particular emits a message into a session
that is already starting. `strict` is a stronger ask, not a gate, and the WIP
Warden says so plainly rather than implying a power it does not have.

An earlier version of this page described `strict` as requiring a disposition
*before the session proceeds*, and an override recorded on the record. Neither
was deliverable: nothing can hold a session, and the mechanism that would carry
the override to a record is a later slice. What you say in answer is not
written down yet, and the Warden tells you so.

`stale_after_hours` is the registry lease length. Raise it if you routinely
leave a session parked mid-thought: liveness is measured as *recency of a
completed turn*, so a session where you are reading or thinking emits no
heartbeat.

## `## Budgets`

```text
- daily_cost_ceiling: not observable
- sessions_per_day: 3
- hard_stop_hour: 18:30
- focus_blocks: 09:00-12:00, 14:00-17:00
- notification_policy_after_stop: digest
- authored_at: 2026-08-08
- authored_via: tune
```

| Key | Grammar | Meaning |
| --- | --- | --- |
| `daily_cost_ceiling` | free text | The literal `not observable` is a valid, honest value — better than an estimate nobody can ground |
| `sessions_per_day` | integer | |
| `hard_stop_hour` | `HH:MM`, 24-hour, local | Contains a colon |
| `focus_blocks` | comma-separated `HH:MM-HH:MM` ranges | Contains colons and spaces |
| `notification_policy_after_stop` | `digest` \| `none` | Declared intent only — see below |
| `authored_at` | `YYYY-MM-DD` | |
| `authored_via` | `tune` | Records that you made this pact rather than inherited it |

**Mandatory clause:** *Unspent budget is not a debt.*

The clause is part of the block, not a comment on it. Delete it and the block
reads as malformed. Because detection is literal-string matching, the wording
is an interface: you may re-wrap the sentence across lines, but rewording it
is a spec-first change and a coordinated migration.

> **`notification_policy_after_stop` is declared intent.** It records the
> pact so a platform hook can honour it where one exists. Push and digest
> enforcement is platform-side and outside this plugin's hands, so it sits at
> the **Unverified** rung of the hardening ladder by design.

## `## Sync cadence` (reserved)

```text
- interrupt_mode: coalesced
- sync_points: 09:00, 16:00
```

| Key | Grammar |
| --- | --- |
| `interrupt_mode` | `streaming` \| `coalesced` |
| `sync_points` | comma-separated `HH:MM` times, or the literal `on-demand` |

> **Reserved.** No sentinel reads this block yet. Values declared here are
> **inert**; the slice that adds a consumer will define their behaviour.
>
> It ships now so the vocabulary arrives whole rather than block by block, and
> it is marked reserved so a value you declare in good faith does not bind a
> future consumer to behaviour nobody has designed.

## The weather check

`/mast` notes when the budget it is reading was **tuned today** — a pact
authored hours ago has not been lived with yet, and that is worth a line when
it asks something of you tonight.

**It discloses its own blind spot, and you should know it too:**

| You do | `authored_at` | Note fires |
| --- | --- | --- |
| Hand-edit your stop hour at 18:00 | unchanged | **no** |
| Run `/mast tune` on a calm Tuesday morning | today | **yes**, that evening |

The stamp moves only when Tune writes it, so an edit made in any other way is
invisible to the check — permanently. Something stronger is not available: the
pact file is never committed, so there is no diff and nothing can compare it
against a previous state.

A check that claimed to catch in-the-moment edits would be worse than one that
admits it cannot, because you would learn to read its silence as an all-clear.

## Authoring

Run `/mast tune`. Nothing writes this file on your behalf, and nothing
scaffolds a default one at install.

That is deliberate. Limits a person set for themselves hold; limits that
arrived as somebody else's default do not. Authorship is the active
ingredient, so the authoring dialogue proposes nothing — it asks.

## `$CLAUDE_PACTS_FILE`

The reader honours a `$CLAUDE_PACTS_FILE` environment variable in place of
`~/.claude/pacts.md`. It exists so the deterministic tests need no home
directory, and it is **not intended for production use**.

Worth knowing it is there, because the whole clear-weather argument turns on
authorship: a pact holds because its keeper wrote it. Anything that can set an
environment variable for a session — a direnv file, a project rc, a wrapper
script — can therefore substitute the pact a sentinel reads, and no sentinel
can tell. If you use it, use it knowingly.
