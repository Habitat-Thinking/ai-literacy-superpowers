---
spec: docs/superpowers/specs/2026-06-16-affordances-section-and-add-design.md
date: 2026-06-16
mode: code
diaboli_model: claude-opus-4-8[1m]
objections:
  - id: O1
    category: implementation
    severity: high
    claim: "The A12 insertion anchor 'after Garbage Collection, before Status' is operationally ambiguous: the template actually places Affordances immediately before Observability, with Observability and Read-side filtering still between Affordances and Status. 'Before Status' does not uniquely identify the real insertion point."
    evidence: "templates/HARNESS.md order: GC -> Affordances -> Observability -> Read-side filtering -> Status; add step 7 and init step 7 name only GC and Status as anchors."
    disposition: amend
    disposition_rationale: "Change the anchor in both add and init to the unambiguous 'immediately before ## Observability (after ## Garbage Collection)'."
  - id: O2
    category: implementation
    severity: high
    claim: "harness-init's re-run section-boundary list enumerates five headings and omits Observability and Read-side filtering, so insert/replace logic keyed on the list can mis-bound the Affordances section and swallow the two omitted sections."
    evidence: "init step 7 boundary list: Context, Constraints, GC, Affordances, Status; template also has Observability and Read-side filtering between Affordances and Status."
    disposition: amend
    disposition_rationale: "Make the boundary list complete (all seven template headings) so the enumerated authority matches the general 'next ## heading' rule."
  - id: O3
    category: implementation
    severity: medium
    claim: "init step 8 validation is internally inconsistent with step 7 (different heading enumerations) and the optional-Affordances check only requires 'after GC', not the full ordered position, so a misplaced section passes validation."
    evidence: "step 8 check 1 lists Context/Constraints/GC/Observability; step 7 list omits Observability; check 6 requires only 'after GC'."
    disposition: amend
    disposition_rationale: "Reconcile the two enumerations and tighten check 6 to the precise placement (immediately before Observability)."
  - id: O4
    category: risk
    severity: medium
    claim: "The template ships template-version 0.29.0 while plugin.json is 0.54.0, so the Template Currency GC rule fires a false 'template stale' signal; the artefact that documents the 0.54.0 template claims to be the 0.29.0 template."
    evidence: "templates/HARNESS.md l.13 marker 0.29.0; plugin.json 0.54.0; this PR adds template content."
    disposition: amend
    disposition_rationale: "Bump the template-version marker to 0.54.0 — the template changed structurally in this release."
  - id: O5
    category: risk
    severity: medium
    claim: "The add permission check reads ~/.claude/settings.json (A2) but specifies no behaviour when that file is unreadable/absent, silently degrading to the project-only false-positive case A2 was meant to remove."
    evidence: "add step 6 lists the three files with no read-failure handling; A2/A6 rationale."
    disposition: amend
    disposition_rationale: "Specify: if a settings layer cannot be read, the warning distinguishes 'not found in readable settings (could not check ~/.claude)' from a clean absence, so the warning's meaning stays honest."
  - id: O6
    category: implementation
    severity: low
    claim: "The template intro comment writes 'Audit Trail' (capital T) while the field name everywhere else is 'Audit trail' (lower-case t)."
    evidence: "templates/HARNESS.md l.370 comment vs entry lines / reference / scanner / test."
    disposition: amend
    disposition_rationale: "Lower-case the comment to 'Audit trail' to match the field schema contract."
  - id: O7
    category: implementation
    severity: low
    claim: "The shell-write-to-tmp example narrowed Permission from the parent's two comma-joined patterns to one, sidestepping an A1 string-equality idempotency break, but the one-pattern-per-Permission rule is left undocumented."
    evidence: "parent example 'Bash(echo *), Bash(touch *)'; template 'Bash(echo *)'; A1 string-equality."
    disposition: amend
    disposition_rationale: "Add an explicit 'one permission pattern per Permission field' note to the schema reference (follows from the granularity rule and keeps A1 idempotency sound)."
  - id: O8
    category: implementation
    severity: low
    claim: "No template example or test exercises Mode: local-mcp, the one Mode value with no worked example, despite being a governance-relevant (local-but-may-call-remote) distinction."
    evidence: "template examples are cli/central-mcp/cli/hook; test asserts only hook + non-hook."
    disposition: acknowledge
    disposition_rationale: "Accepted as-is: the reference page defines local-mcp in prose and the table; adding a fifth example is not worth the template bloat. Noted for a future example refresh."
---

# Objection record — affordances section + harness-affordance add (code mode)

Eight objections (2 high, 3 medium, 3 low); no critical, no premise. The two
high objections (O1, O2) share one root: the template interleaves
`## Observability` and `## Read-side filtering` between `## Affordances` and
`## Status`, while every placement/boundary instruction named only Garbage
Collection and Status as anchors — operationally ambiguous against the real
artefact. Adjudicated 2026-06-16: seven **amend** (fixes applied in the same
PR), one **acknowledge** (O8). All fixes are in the implementation commit
that follows this record.

## Explicitly not challenged

- A1 idempotency keying on the Permission pattern (faithfully implemented
  across command, how-to, and reference).
- A4 status live-counting; A5 Layer 0 test scope honesty; A7 dropped forward
  suggestion; A8 newest-draft seeding; A11 human-authored-in-spirit framing.
- The how-to's `add` accuracy (no residual "add does not exist" claims).
