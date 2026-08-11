# Pacts

Your pacts — the limits you set for yourself, in advance, in clear weather.

This file lives at `~/.claude/pacts.md`. It is yours, it is per-machine, and
it is never committed. It belongs to **you**, not to any repository: a stop
hour and a concurrency limit are properties of a person, not of a project.
`HARNESS.md` remains the repo's declaration surface and does not hold pacts.

Nothing here gates anything. Every block is optional, and a sentinel that
finds its block missing says so and carries on in observe-only mode. A block
you have not declared is not a failure — it is simply a pact you have not
made.

**Authoring.** Run `/mast tune`. Budgets that hold are budgets their keeper
authored deliberately; a default someone else chose for you is not a pact, so
nothing writes this file on your behalf.

**One rule about editing.** Keep every value on its own clean `key: value`
line, and keep notes in prose below the values — never as a trailing `#`
comment on a value line. The parser reads everything after the first colon, so
an inline comment silently becomes part of the value.

---

## Session WIP

- max_concurrent_sessions: 2
- max_switches_per_hour: 4
- stale_after_hours: 12
- enforcement: advisory

This is a gate on sessions, never on the person. It counts; it does not
assess.

Field notes. `max_concurrent_sessions` is how many sessions you are willing to
have live at once, counted across every repository on this machine.
`max_switches_per_hour` is optional. `stale_after_hours` is how long a session
may go without finishing a turn before it is treated as gone — raise it if you
routinely leave a session parked mid-thought. `enforcement: advisory` reports
a breach and proceeds; `strict` also asks you to park something or say what is
urgent. **Neither can stop you** — nothing in this plugin can hold a session,
and the WIP Warden says so rather than implying otherwise. What you say in
answer is not written down anywhere yet.

## Budgets

- daily_cost_ceiling: not observable
- sessions_per_day: 3
- hard_stop_hour: 18:30
- focus_blocks: 09:00-12:00, 14:00-17:00
- notification_policy_after_stop: digest
- authored_at: 2026-01-01
- authored_via: tune

Unspent budget is not a debt.

Field notes. `daily_cost_ceiling` may honestly be `not observable` — say so
rather than let something estimate it. `hard_stop_hour` is local, 24-hour.
`focus_blocks` is a comma-separated list of ranges.
`notification_policy_after_stop` records what you want to happen after the
line; enforcing it is the platform's business, not this plugin's.
`authored_at` and `authored_via` record that you made this pact rather than
inherited it.

The clause above is part of the block. Delete it and the block reads as
malformed, and every sentinel drops back to observe-only rather than hold you
to a pact whose governing sentence is gone.

## Sync cadence

- interrupt_mode: coalesced
- sync_points: 09:00, 16:00

Reserved. No sentinel reads this block yet. Values declared here are inert;
the slice that adds a consumer will define their behaviour.

Field notes. `interrupt_mode` is `streaming` or `coalesced`. `sync_points` is
a comma-separated list of times, or the literal `on-demand`.
