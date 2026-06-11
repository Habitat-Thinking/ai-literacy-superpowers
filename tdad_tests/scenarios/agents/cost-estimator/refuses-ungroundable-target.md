---
component: cost-estimator
component_type: agent
tier: behavioural
fixture: cost-estimator-ungroundable
---

# Scenario: cost-estimator refuses rather than fabricating an ungroundable estimate (incl. O5 tableless MODEL_ROUTING)

## Given

A fixture repository supporting three ungroundable dispatches:

1. An **unreadable target** — a target path that does not resolve (or inline text
   so empty/vague that no stage set can be assumed at all).
2. **Absent token grounding** — a valid, readable target where `MODEL_ROUTING.md`
   **cannot be read** (the file does not resolve).
3. **Present-but-unparseable token grounding (O5)** — a valid, readable spec
   target where `MODEL_ROUTING.md` **resolves as a file** but its **Token Budget
   Guidance** and/or **Agent Routing** tables are **missing or unparseable**, so
   no token grounding can be derived.

No token grounding means no honest estimate, only a guess. This scenario covers
spec §9.5; FR-7. It is the deliberate counterpart to the empty-cost-snapshot
case (`empty-snapshot-not-refused.md`, §9.6), which is **not** a refusal.

## When

The cost-estimator agent runs to completion against each ungroundable dispatch.

## Then

For **each** of the three dispatches:

- The returned string **begins with the `REFUSED:` prefix**.
- The refusal **names the reason, the target, and what grounding was/was not
  readable** (the `Reason:`/`Target:`/`Grounding read:` fields of the convention).
- The refusal states **no estimate record should be written**.
- The returned string is **not** a conforming estimate record — it carries no
  estimate-record frontmatter and **no fabricated token ranges**.

For the **O5 (tableless `MODEL_ROUTING.md`) dispatch specifically**:

- The refusal names that `MODEL_ROUTING.md` was **readable as a file but its
  required tables were missing/unparseable** — distinguishing it from the
  file-unreadable case (dispatch 2).
- This is **explicitly distinguished** from the empty-`observability/costs/`
  case, which is cost-omitted (§9.6), **not** refused.

## Rubric

Layer 3 behavioural, graded by the **`REFUSED:` prefix oracle** (spec §8). The
oracle asserts the returned string starts with `REFUSED:`, contains the
reason/target/grounding-read fields, and does **not** parse as a conforming
estimate record (no YAML estimate frontmatter, no token range). The stable prefix
is the deterministic hook; each ungroundable input is fixture-pinned. The oracle
never asserts the exact reason wording — only the prefix, the named fields'
presence, and the absence of a fabricated record.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

The runner runs three single-agent sessions — one per ungroundable fixture —
and asserts the `REFUSED:` prefix and field presence on each, and that none
returns a parseable estimate record. The O5 dispatch additionally asserts the
"readable file, missing tables" distinction marker.
