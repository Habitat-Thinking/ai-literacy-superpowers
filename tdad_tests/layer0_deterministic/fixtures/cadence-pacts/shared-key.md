# Pacts

Fixture for B8 — block-scoped key isolation.

Both blocks declare `enforcement`, with different values. This is the only
fixture that can distinguish a block-scoped parser from a whole-file one: a
whole-file `read_key`-style lookup returns the first match in document order
for both queries, so it returns `advisory` twice and passes a single-block
test while failing this one.

The key is shared deliberately. Nothing in today's vocabulary shares a key
name, which is precisely why a single-block fixture would leave the property
that justifies building a second parser entirely unverified (spec §3.6).

## Session WIP

- max_concurrent_sessions: 2
- enforcement: advisory

This is a gate on sessions, never on the person. It counts; it does not
assess.

## Budgets

- sessions_per_day: 3
- hard_stop_hour: 18:30
- enforcement: strict

Unspent budget is not a debt.
