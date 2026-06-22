---
component: harness-enforcer
component_type: agent
tier: structural
fixture: enforceable-constraint-inventory
---

# Scenario: the count-equality guarantee is declared — no silent drop (AC-3 / FR-3, FR-5)

## Given

The file
`ai-literacy-superpowers/agents/harness-enforcer.agent.md`, and (for the
optional counting-rule fixture) a small synthetic
enforceable-constraint inventory mixing `deterministic`, `agent`, and
`unverified` enforcement values.

## When

The workflow-mode section is read (structural); and the counting rule it
declares is applied to the fixture inventory (optional behavioural-fixture
form).

## Then

**Structural (deterministic, the primary assertion):**

- The section declares the **count-equality guarantee in checkable
  language**: when the enforcer reports **"all constraints checked"**, the
  count of **verifier results equals the count of enforceable
  constraints** (the phrase "all constraints checked" and a
  results-equal-enforceable statement both appear).
- The section defines the **enforceable count** as constraints whose
  enforcement is `deterministic`, `agent`, or `deterministic + agent`,
  and **explicitly excludes `unverified`** constraints (they are skipped,
  not checked — the word "unverified" and "exclud"/"excluded" appear
  together).
- The section states **no enforceable constraint is silently dropped**
  (the phrase "no silent drop" / "silently drop" appears) — the all-N
  synthesis barrier makes the "35 of 50 checked" lazy stop structurally
  impossible.

**Optional counting-rule fixture (behavioural — exercises the rule, not a
live fan-out):**

- Given the fixture inventory with `D` deterministic + `A` agent +
  `U` unverified constraints, the declared counting rule yields
  **enforceable count `== D + A`** (the `U` unverified are excluded), and
  the asserted relation `len(results) == len(enforceable)` holds against
  that fixed input.

## Rubric

Per §6 decision 2, the *runtime* count-equality is agent-backed; what is
**deterministically assertable in this repo's TDAD layers** is that the
**guarantee is declared**. The primary assertion is structural (a file
read). The fixture form is *optional* and tests the **counting rule** on
fixed synthetic input — it does **not** spawn a real fan-out and must not
be read as doing so.

The check must reject any wording that promises the *runtime* equality is
CI-proven on live input — the deterministic surface is the declaration and
the counting rule, not the fan-out itself.

## Evaluation

The structural half is evaluated deterministically by
`tests/test_s3_enforcer_fanout_structural.py` (file-read phrase
assertions). RED now: no "all constraints checked" count-equality
guarantee, no `unverified`-excluded definition, and no "no silent drop"
statement exist in the agent doc. The optional fixture is a synthetic
inventory the implementer may add under `fixtures/`; it is not required
for the scenario to be RED — the structural declaration alone is RED.
