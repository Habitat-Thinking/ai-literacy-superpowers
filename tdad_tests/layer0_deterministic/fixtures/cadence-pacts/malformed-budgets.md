# Pacts

Fixture: a `Budgets` block that is present, active, and parseable, but whose
prose has lost the mandatory clause. This is the reachable case — someone
edits their pact file and deletes a sentence they read as boilerplate — and
it must report `malformed`, not `declared` (spec §3.7).

Treating this as declared would let the Mast hold its keeper to a pact whose
governing clause they deleted.

## Budgets

- daily_cost_ceiling: not observable
- sessions_per_day: 3
- hard_stop_hour: 18:30
- focus_blocks: 09:00-12:00, 14:00-17:00
- notification_policy_after_stop: digest
- authored_at: 2026-08-08
- authored_via: tune

The mandatory clause that belongs here has been deleted on purpose.
