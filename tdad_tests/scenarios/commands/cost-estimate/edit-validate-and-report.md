---
component: cost-estimate
component_type: command
tier: behavioural
fixture: cost-estimate-edit-path
---

# Scenario: the edit path validates-and-reports — a human edit is never silently reverted (O3)

## Given

A fixture repository where the command has produced a validated draft and the
human chooses the **`edit`** disposition, then changes the draft in `$EDITOR`.
The fixture pins a human edit that introduces a **tolerated structural change**
(the kind step 4 would have fixed in place on the agent's fresh output) and,
separately, a human edit that leaves a **remaining deviation**.

This scenario exercises the edit-path rule that the content is now the **human's**
and the post-edit checkpoint runs in **validate-and-report** mode, not
fix-in-place (spec §10.6d; FR-6b).

## When

The command runs the **post-edit checkpoint** over the human-edited content.

## Then

The **edit-validate-and-report oracle** asserts:

- The human's edited value is **preserved** — the post-edit checkpoint does
  **not** apply fix-in-place to human-edited content, and the edit is **not
  silently reverted** to the agent's original.
- When the edited record **still deviates**, the command **reports** the
  remaining deviation in the re-prompt (it surfaces it rather than auto-fixing
  it) and lets the human decide (re-edit, accept where structurally valid, or
  abort).
- **No edit of the human's is reverted without the human seeing and
  re-confirming it.**

## Rubric

Layer 3 behavioural, graded by the **edit-validate-and-report oracle** (spec §9):
the edited value is preserved across the post-edit checkpoint, and any remaining
deviation is surfaced in the re-prompt rather than auto-fixed. The edit content
is fixture-pinned. The oracle never asserts the exact re-prompt prose — only that
the human's edited value survives and that a remaining deviation is reported, not
silently corrected.

## Cleanup

Remove the temporary fixture repository (including any written
`cost-estimates/` directory).

## Implementation note

The runner drives the `edit` disposition with a pinned human edit (simulating the
`$EDITOR` return), runs the post-edit checkpoint, and asserts the edited value is
unchanged by the checkpoint and that a remaining deviation, if any, appears in
the re-prompt rather than being auto-corrected.
