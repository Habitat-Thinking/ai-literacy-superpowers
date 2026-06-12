---
component: cost-estimate
component_type: command
tier: behavioural
fixture: cost-estimate-ungroundable
---

# Scenario: a REFUSED estimate is surfaced verbatim and never persisted (runnable-today)

## Given

A fixture repository supporting an **ungroundable** dispatch — an unreadable
target path, or a valid target where `MODEL_ROUTING.md` cannot be read or reads
but its tables are missing/unparseable — so the S2 agent returns a string
beginning with the stable `REFUSED:` prefix. No pre-existing `cost-estimates/`
directory.

**Runnable-today** — the REFUSED path is exercised by a real ungroundable
grounding read (spec §10.3; FR-5).

## When

The command dispatches the agent and the agent returns a `REFUSED:` string.

## Then

The **REFUSED oracle** and the **no-file oracle** assert:

- The command **surfaces the refusal reason, the target, and the grounding-read
  line verbatim** (the agent's `REFUSED:` output is passed through, not
  re-authored).
- **No validation checkpoint runs** — there is nothing conforming to validate.
- **No file is written** — nothing exists under `cost-estimates/` (or the
  resolved output dir).
- The flow **aborts**.

## Rubric

Layer 3 behavioural, graded by the **REFUSED-prefix oracle** (the surfaced
output retains the `REFUSED:` prefix) and the **no-file oracle** (no file at the
resolved path), per spec §9. The ungroundable input is fixture-pinned. The oracle
never asserts the exact refusal wording — only that the `REFUSED:` content is
surfaced and that no record is persisted.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

The runner runs the command against the ungroundable fixture, asserts the
surfaced output carries the `REFUSED:` prefix, and asserts no file exists under
the default `cost-estimates/` path (and that no checkpoint-fix change-list is
produced, since no checkpoint ran).
