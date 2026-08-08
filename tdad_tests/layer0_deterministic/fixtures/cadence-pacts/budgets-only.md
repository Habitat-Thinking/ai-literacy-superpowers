# Pacts

Fixture: a pact file declaring only `Budgets`. Exercises B5 — an absent block
inside a file that exists — which is a different path from B4, where the file
itself is missing.

`sessions_per_day` is deliberately omitted so B9 can assert that `block_key`
returns its supplied default for an absent optional key.

## Budgets

- daily_cost_ceiling: not observable
- hard_stop_hour: 18:30
- focus_blocks: 09:00-12:00, 14:00-17:00
- notification_policy_after_stop: none
- authored_at: 2026-08-08
- authored_via: tune

Unspent budget is not a debt.
