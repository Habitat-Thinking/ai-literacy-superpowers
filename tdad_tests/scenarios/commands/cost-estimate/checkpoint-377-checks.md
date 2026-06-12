---
component: cost-estimate
component_type: command
tier: behavioural
fixture: cost-estimate-377-bands
---

# Scenario: the checkpoint enforces the #377 per-stage coupling and split-tier strict-spread checks

## Given

A fixture repository pinning the **agent's returned record** to several
per-stage-cost shapes so the checkpoint's #377 checks (spec §7.1 lines 2–3) can
be exercised deterministically:

1. A **cost-present** record with a **split-tier** per-stage band — its
   `model_tier` **contains a `/`** — whose band is **collapsed** (`low == high`).
2. A cost-present record with a split-tier per-stage band that is **non-collapsed**
   (`low < high`).
3. A **cost-omitted** record carrying a **per-stage `cost_usd` band** while the
   top-level `cost_usd` is **absent** (the incoherent per-stage-coupling inverse).
4. A cost-omitted record with **no per-stage bands** at all.

Shapes 1–3 are **synthetic cost-present / cost-band fixtures** — they hand-author
the very split-tier bands the deferred absolute-rate check (spec §7.2) would
otherwise validate; the command's real grounding cannot produce a cost-present
band against today's empty `observability/costs/` (spec §10.4; FR-6).

## When

The command runs its Output Validation Checkpoint over each pinned record.

## Then

The **#377-check oracle** asserts:

- **Shape 1 (collapsed split-tier band)** — the **split-tier strict-spread check
  FAILS** (a `/`-tier per-stage band with `low == high` is not allowed); the
  command aborts without writing (widening would author a spread — a
  derived-value defect).
- **Shape 2 (non-collapsed split-tier band)** — the split-tier strict-spread
  check **PASSES** (`low < high` on the `/`-tier stage).
- **Shape 3 (per-stage band on a cost-omitted record)** — the
  **per-stage-coupling check FAILS** (a per-stage band requires a top-level
  `cost_usd`); the command aborts without writing.
- **Shape 4 (no per-stage bands)** — both checks **pass vacuously**.

## Rubric

Layer 3 behavioural, graded by the **#377-check oracle** on pinned fixtures
(spec §9): the split-tier strict-spread check fails on a collapsed `/`-tier band
and passes on a non-collapsed one; the per-stage-coupling check fails on a
per-stage band atop a cost-omitted record and passes vacuously with no bands.
Each band shape is fixture-pinned. The oracle never asserts exact cost numbers —
only the pass/fail outcome of each check and the no-file consequence of the
failing-check aborts.

## Cleanup

Remove the temporary fixture repository (including any written
`cost-estimates/` directory).

## Implementation note

The runner pins each per-stage-cost record shape as the agent's returned string,
runs the checkpoint, and asserts the named check passes or fails as above, and
that a failing #377 check aborts the flow with no file written.
