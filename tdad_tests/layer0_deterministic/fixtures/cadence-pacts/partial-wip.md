# Pacts

Fixture: a deliberately partial pact. The human declared `Session WIP` to tune
the registry lease and nothing else — which `/mast tune` explicitly supports,
because it asks the stop hour first and then offers rather than marches.

Nothing here is broken. `block_state` must call it `declared`, and a consumer
that needs `max_concurrent_sessions` must ask for it rather than assume.

## Session WIP

- stale_after_hours: 6

This is a gate on sessions, never on the person. It counts; it does not
assess.
