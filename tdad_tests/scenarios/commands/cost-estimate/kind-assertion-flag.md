---
component: cost-estimate
component_type: command
tier: behavioural
fixture: cost-estimate-kind-assertion
---

# Scenario: an asserted --kind is flagged in the review summary, not silently trusted (O4) (runnable-today)

## Given

A fixture repository with a target that is really a **slice fragment** but reads
superficially like a spec, a readable `MODEL_ROUTING.md` whose tables parse, and
an empty `observability/costs/`. The command is run two ways:

1. With **`--kind spec`** asserted on the slice-fragment target.
2. With **no `--kind`** (the agent infers the kind from content).

**Runnable-today** — both arms are exercised by a real grounding read on today's
repo (spec §10.6a; FR-8a).

## When

The command summarises the validated record for disposition in each arm.

## Then

The **`--kind` assertion-flag oracle** asserts:

- **Asserted arm (`--kind spec`)** — the review summary **flags `target_kind` as
  HUMAN-ASSERTED (not agent-inferred)**, states that the asserted kind **raised
  the tokens/time confidence ceiling** (to `high` for `spec`) **with no agent
  inference basis**, and asks the human to **re-confirm the ceiling they raised**
  before disposing.
- **Inferred arm (no `--kind`)** — the summary instead **carries the agent's
  inference-basis line as emitted** (classified by signal) and **does NOT** show
  a human-asserted flag.

## Rubric

Layer 3 behavioural, graded by the **`--kind` assertion-flag oracle** (spec §9):
the asserted arm carries an asserted-not-inferred flag naming the raised ceiling
and no inference basis; the inferred arm carries the inference-basis line and no
asserted flag. The target and `--kind` invocation are fixture-pinned. The oracle
checks for the presence/absence of the named flag and the inference-basis line —
never the exact summary prose.

## Cleanup

Remove the temporary fixture repository (including any written
`cost-estimates/` directory).

## Implementation note

The runner drives the command twice against the same slice-fragment target — once
with `--kind spec`, once with no `--kind` — and asserts the asserted-not-inferred
flag (with the raised-ceiling note) appears only in the asserted arm, and the
agent's inference-basis line appears only in the inferred arm.
