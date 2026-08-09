# Pacts

Fixture for B11 — a hand-edited pact file carrying ordinary standalone
comment lines inside a block.

Under the general markdown rule "a span ends at the next heading of
equal-or-higher level", `# revisit this in Q4` parses as a level-1 heading,
truncates the block, drops every key below it AND the mandatory clause, and
flips a perfectly good block to `malformed` with no line telling the human
which sentence broke it.

## Session WIP

- max_concurrent_sessions: 2

# revisit this in Q4

- stale_after_hours: 6
- enforcement: strict

This is a gate on sessions, never on the person. It counts; it does not
assess.

## Budgets

- hard_stop_hour: 18:30

#### A sub-heading, which was always safe

- sessions_per_day: 3

Unspent budget is not a debt.
