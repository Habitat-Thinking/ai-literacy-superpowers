---
id: HDR-2026-08-25-retire-periodic-check-suite-runner
title: Retire the periodic-check-suite rule — it cannot be applied to its target
status: accepted
classification: script-validator
enforcement: validated
surfaces: [ci]
provisional: false
target: .github/workflows/gc.yml
evidence:
  - harness/assay/2026-08-25T08-08Z-assay.md#finding-2
  - .github/workflows/gc.yml
  - ai-literacy-superpowers/scripts/harness-registrar.py
proposed_cost: |
  None. A retirement withdraws a rule; it adds no obligation to anyone.
cost: |
  Withdrawing where the rule was pointed, not the rule itself.
proposer:
  agent: human
  model: n/a
  assay: harness/assay/2026-08-25T08-08Z-assay.md
approver: Russ Miles <russ@russmiles.com>
approved_at: 2026-08-25T09:56Z
supersedes: HDR-2026-08-25-the-periodic-check-suite-stops-at-its-first-failure-and-reports-the-rest-as-nothing
superseded_by: null
---

## Finding

Accepting `HDR-2026-08-25-the-periodic-check-suite-stops-at-its-first-failure-and-reports-the-rest-as-nothing`
applied its rule text to `.github/workflows/gc.yml` and left the file invalid.

The compiler appends a markdown region — an HTML comment marker, a heading, and
a bullet list — to whatever artifact a record names as its `target`. `gc.yml` is
YAML. After acceptance the file failed to parse
(`Psych::SyntaxError: could not find expected ':' while scanning a simple key at
line 288 column 1`), which is the `<!-- BEGIN GENERATED -->` marker. GitHub
Actions could no longer load the workflow, so the weekly garbage-collection job
would not have run at all.

Three mechanisms that should have caught this did not. `compile_plan` checks
that a target exists and that its generated markers are unambiguous, and has no
notion of what syntax the file accepts. The `/harness-accept` refusal for "rule
text that does not apply cleanly to the target artifact" is a marker check, not
a syntax check. And `/harness-check` — the CI entry point — reported `OK`
against the corrupted file.

The root error is in the record being retired: its rule text is `HARNESS.md`
constraint syntax (`- **Rule**:` / `- **Enforcement**:` / `- **Tool**:` /
`- **Scope**:`), so it was always meant to live in `HARNESS.md`, with `gc.yml`
as the **Tool** rather than the **target**. The assay's finding metadata
conflated the two, and `/harness-accept` has no `--target` override, so the
target cannot be corrected from an append-only assay.

The underlying observation stands and is unaffected by this retirement: only the
`Summary` step of `gc.yml` carries `if: always()`; the workflow has failed six
consecutive scheduled runs; and on 2026-08-24 a failure at step 5 left steps 6
through 14 recorded `skipped`, including the sentinel-integrity check. That
evidence is in the assay and remains available to a later record that routes its
rule to an artifact able to hold it.

## Rule

Withdrawn.

## Cost

Withdrawing where the rule was pointed, not the rule itself.

## Why this layer

The rule being withdrawn was classified `script-validator`, and this record
withdraws it at the same layer. Nothing lower can retire it: the classification
is what determines where a rule's text is written, and it is the writing that
caused the damage.

The wider question this raises — that `script-validator` names code files as
targets while the compiler can only emit markdown — is a defect in the
Registrar, not in this rule, and belongs to a later record with its own
evidence. This one does the narrow thing: it takes the applied rule back out.

## Enforcement

None. A retirement compiles nothing and is absent from the enforcement report.
Once accepted, the superseded record is skipped by `compile_plan`, so
`/harness-compile` will no longer reapply the region to `gc.yml`.

That is the property that makes this the stable fix rather than reverting the
file by hand: a hand-revert leaves the superseded record `in force`, and the
next compile silently re-breaks the workflow.

## Validation

`gc.yml` parses as YAML and carries no `BEGIN GENERATED` marker — verified after
the working-tree revert, and to be re-verified after `/harness-compile` runs
with this retirement accepted. If a compile ever reintroduces the marker, this
retirement did not work.

`harness/enforcement-report.md` should carry no rows for the superseded record,
and `harness/decisions/index.md` should show it as `superseded`.

## Rejected alternatives

**No change — leave the rule in force and revert `gc.yml` by hand.** Rejected.
The record would stay `accepted` and `in force`, so the next `/harness-compile`
reapplies the region and breaks the workflow again, while `/harness-check`
continues to report `OK`. A landmine with a ninety-day fuse.

**Edit the accepted record to change its target.** Rejected, and not available.
An accepted record is frozen; editing one is the single thing the append-only
rule forbids, and it is the reason supersession exists.

**Delete the record and the assay finding.** Rejected. The rule was proposed on
real evidence, a human wrote its cost, and it was accepted. Deleting that leaves
no trace that governance was changed and reversed, which is precisely the
history this corpus exists to keep.

**Re-propose immediately with `HARNESS.md` as the target.** Deferred, not
rejected. The target is copied verbatim from an append-only assay and cannot be
corrected without a new assay finding. The evidence is intact and a later cycle
can carry it.
