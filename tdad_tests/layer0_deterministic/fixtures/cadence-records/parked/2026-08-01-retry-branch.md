---
session: sess-alpha
repo: /tmp/toy
created: 2026-08-01
state: parked
supersedes: null
next_action_flag: asked
---

## Context

Fixture: a parking record that was later resumed. Its successor below
supersedes it, so the glob must NOT return this file.

## Next action

Implement the retry branch of slice 7's error path, starting from the
failing test in test_retry.py.
