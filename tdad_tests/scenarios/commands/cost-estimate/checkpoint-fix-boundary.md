---
component: cost-estimate
component_type: command
tier: behavioural
fixture: cost-estimate-checkpoint-boundary
---

# Scenario: the checkpoint fixes structural-only + records it, and aborts (never authors) on a derived-value defect (O1/O2)

## Given

A fixture repository pinning the **agent's returned record** to several shapes so
the checkpoint's structural-fix boundary (spec §7.1a) can be exercised
deterministically. The grounding (`MODEL_ROUTING.md` tables, target) is held
fixed; only the pinned record shape varies:

1. A record carrying a **stray `verdict` field** in the frontmatter (a
   structural-only defect — a forbidden field whose removal authors nothing).
2. A **clean** record the checkpoint need not touch.
3. A **cost-present** record that is **MISSING `cost_basis`** (a derived-value
   defect — supplying `cost_basis` would assert provenance the agent did not
   state).
4. A record with a **`low > high` range** (a derived-number defect).

Shapes 3 and 4 are **synthetic cost-present / derived-defect fixtures** — they
hand-author a record shape the command's real grounding cannot produce against
today's empty `observability/costs/`; they exist to pin the abort-never-author
behaviour, not to be produced by a grounded emit (spec §10.4a, §10.4b; FR-6,
FR-6a).

## When

The command runs its Output Validation Checkpoint over each pinned record.

## Then

The **structural-fix-boundary oracle** asserts:

- **Shape 1 (stray `verdict`, structural-only)** — the `verdict` field is
  **removed** from the validated record, AND the review summary's **change-list
  names the deletion** (the agent-content-vs-command-content provenance is
  surfaced). On `accept`, the written file carries no `verdict` field.
- **Shape 2 (clean)** — the review summary states **"no checkpoint changes —
  record as emitted by the agent"** (the change-list is empty).
- **Shape 3 (cost-present missing `cost_basis`, derived-value)** — the command
  **aborts without writing**: **no file** is written under the resolved path, and
  the validated record has **no `cost_basis` authored** (the checkpoint did not
  invent provenance). The failing checklist line (Cost pairing) is surfaced.
- **Shape 4 (`low > high` range, derived-number)** — the command **aborts
  without writing**: **no file** is written, and the range is **not** re-ordered
  or clamped (no derived number is altered).

## Rubric

Layer 3 behavioural, graded by the **structural-fix-boundary oracle** (spec §9):
field-removed + named-in-change-list for the structural-only defect; "no
checkpoint changes" for the clean record; no-file + no-authored-field for each
derived-value defect. Each record shape is fixture-pinned. The oracle never
asserts the exact change-list prose — only that the named field was removed and
listed, or that no file was written and no derived value was authored.

## Cleanup

Remove the temporary fixture repository (including any written
`cost-estimates/` directory).

## Implementation note

The runner pins each of the four record shapes as the agent's returned string,
runs the checkpoint, and asserts: removal + change-list entry for shape 1; empty
change-list ("no checkpoint changes") for shape 2; no-file + absent `cost_basis`
for shape 3; no-file + unaltered range for shape 4.
