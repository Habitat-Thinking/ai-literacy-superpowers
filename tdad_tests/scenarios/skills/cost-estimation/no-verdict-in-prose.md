---
component: cost-estimation
component_type: skill
tier: structural
---

# Scenario: the no-verdict guarantee is structural in two layers — field-absence plus a positive-content prose scan

## Given

The `cost-estimation` skill carries confidence but **never** a verdict,
recommendation, or go/no-go (spec §5.3; O12). The estimate informs a
human's choice; it does not anchor or make it, in service of the
AGENTS.md "agent-emit + dispatcher-persist + human-disposes" trust
architecture.

The spec makes this guarantee **structural in two layers** rather than
relying on field absence alone, because O12 showed a verdict could be
smuggled into the free-text disclosure prose:

1. **Field-absence layer** — no `recommendation`, `verdict`, or
   `proceed` field exists.
2. **Positive-content layer** — the four disclosure sections describe
   inputs and uncertainty only and MUST NOT contain imperative
   recommendation or go/no-go language; a validation check scans the
   disclosure prose for prohibited patterns and **fails the record** if
   any appear.

This scenario fixes what the format reference's validation checklist and
worked examples must contain (`FR-14`, supporting `FR-3`).

## When

The format reference at
`ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`
is read — specifically the "Validation checklist" subsection and the two
worked example records.

## Then

**Field-absence layer** (spec §5.3 layer 1):

- The validation checklist lists a **field-absence check**: no
  `recommendation`, no `verdict`, and no `proceed` field may appear in
  the record frontmatter.

**Positive-content layer** (spec §5.3 layer 2):

- The validation checklist lists a **positive-content check** that
  **fails a record** whose disclosure prose contains imperative
  recommendation or go/no-go language.
- The checklist enumerates representative prohibited patterns, including
  "so proceed", "do not proceed", "I recommend", "you should
  [ship|skip|approve|reject]", and "go/no-go".
- The reference states the **Failure direction** section describes
  uncertainty only and must contain no imperative recommendation — i.e.
  a sentence like "failure direction: likely-overrun, so do not proceed"
  **fails** the positive-content check even though it passes the
  field-absence check.

**The worked examples are clean** (spec §10.2a; O12):

- Neither worked example record contains "so proceed", "do not proceed",
  "I recommend", "you should ship/skip/approve/reject", or any other
  imperative recommendation or go/no-go language in its disclosure prose.

## Rubric

Layer 1 structural: the validation-checklist assertions are verifiable
by reading the checklist subsection of the format reference; the
worked-example assertions are verifiable by scanning the two example
blocks' disclosure prose for the prohibited patterns. The scenario fails
if either the field-absence check or the positive-content check is
missing from the checklist, or if either worked example's prose carries
go/no-go language.

## Notes

The positive-content check is what makes the no-verdict guarantee a
property of the format itself rather than of any agent's good behaviour.
This scenario asserts the **contract describes the check**; it does not
itself execute the scan against arbitrary records — that runtime
enforcement is the S3 command's Output Validation Checkpoint job, out of
scope for S1.
