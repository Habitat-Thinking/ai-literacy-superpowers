# Pacts

Fixture: a fully declared pact file. Every block well-formed, and the
`Budgets` values deliberately chosen to break the inherited `read_key`
extraction — a colon-bearing time, a comma-and-space-bearing list, and a
two-word literal (spec §3.6).

## Session WIP

- max_concurrent_sessions: 2
- max_switches_per_hour: 4
- stale_after_hours: 12
- enforcement: advisory

This is a gate on sessions, never on the person. It counts; it does not
assess.

## Budgets

- daily_cost_ceiling: not observable
- sessions_per_day: 3
- hard_stop_hour: 18:30
- focus_blocks: 09:00-12:00, 14:00-17:00
- notification_policy_after_stop: digest
- authored_at: 2026-08-08
- authored_via: tune

Unspent budget is not a debt.

## Sync cadence

- interrupt_mode: coalesced
- sync_points: 09:00, 16:00

Reserved. No sentinel reads this block yet. Values declared here are inert;
the slice that adds a consumer will define their behaviour.
