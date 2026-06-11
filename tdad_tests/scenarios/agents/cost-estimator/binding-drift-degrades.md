---
component: cost-estimator
component_type: agent
tier: behavioural
fixture: cost-estimator-binding-drift
---

# Scenario: cost-estimator omits cost mechanically when any exercised tier is unmapped or a named key is missing (O3/O4)

## Given

A fixture repository with a populated `observability/costs/` snapshot (so a cost
figure is computable — S1 state 3) and a `MODEL_ROUTING.md` that parses, plus a
spec target. The fixture supports three configurations of the grounding:

1. **Missing model key** — the snapshot's Model Breakdown **lacks a
   representative model key the binding table names** (e.g. `claude-opus-4`
   absent).
2. **Exercised unmapped tier** — `MODEL_ROUTING.md` carries a tier the binding
   table does **not** map (tested **after** applying the S1 join-key
   normalisation — `{{LANGUAGE}}-` prefix strip + whitespace-insensitive tier
   compare), AND that tier is **exercised** by the target's stage set.
3. **Spacing-only split tier** — the binding's `Standard / Capable` split row vs
   a snapshot/routing label `Standard/Capable` differing **only by spacing** —
   the implementer split tier, the dominant cost driver in both S1 worked
   examples.

The omission rule is **mechanical** — no agent judgment about whether an unmapped
tier is "load-bearing." This scenario covers spec §9.8; FR-10 (O3/O4).

## When

The cost-estimator agent runs to completion against each configuration.

## Then

**Missing model key (config 1):**

- `cost_usd` is **omitted** (absent), with a disclosure **naming the missing key**
  as the omission cause.
- The agent does **not invent a substitute rate** (no fabricated `cost_usd`).

**Exercised unmapped tier (config 2):**

- `cost_usd` is **omitted** regardless of whether the unmapped tier appears
  "load-bearing" — the rule is mechanical: ANY exercised unmapped tier triggers
  omission.
- The agent **discloses the unmapped tier in `Confidence rationale`** and **names
  it in `Excluded`** as the omission cause.
- The agent does **not invent a binding** for the unmapped tier, and makes **no
  discretionary salience judgment** about whether the tier matters.

**Spacing-only split tier (config 3):**

- A correctly-mapped split tier that differs **only by tier-label spacing**
  (`Standard/Capable` ↔ `Standard / Capable`) is **NOT reported unmapped** — the
  normalisation prevents over-omitting cost on the implementer split tier.
- Where this is the only drift candidate, the record **carries `cost_usd`** (cost
  is **not** omitted on a spacing-only difference).

## Rubric

Layer 3 behavioural, graded by a **presence/absence oracle** (spec §8). For
configs 1 and 2 the oracle asserts `cost_usd`/`cost_basis` are **absent** and that
the `Excluded`/`Confidence rationale` body names the cause (missing key / unmapped
tier). For config 3 the oracle asserts `cost_usd` is **present** (the
spacing-only split tier was correctly mapped after normalisation, so cost is not
over-omitted). The grounding configurations are fixture-pinned so the
mapped/unmapped determination is deterministic. The oracle never asserts the
exact rate or the exact disclosure wording — only the omit/emit routing and the
named-cause presence.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

The runner runs one single-agent session per configuration with the pinned
snapshot + `MODEL_ROUTING.md`, then parses each returned record for `cost_usd`
presence/absence and greps the disclosure body for the named omission cause (or,
for config 3, asserts `cost_usd` present and no spurious unmapped-tier
disclosure).
