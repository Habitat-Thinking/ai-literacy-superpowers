---
id: HDR-2026-08-25-workflow-step-masking-declined
title: A failing step still cancels every check after it, and on 2026-08-25 it cancelled the two that govern governance
status: rejected
classification: script-validator
enforcement: validated
surfaces: [ci]
provisional: false
evidence:
  - .github/workflows/harness.yml
  - .github/workflows/gc.yml
  - harness/decisions/HDR-2026-08-25-retire-periodic-check-suite-runner.md
  - harness/assay/2026-08-25T08-08Z-assay.md#finding-2
  - HARNESS.md
  - harness/assay/2026-08-25T11-59Z-assay.md#finding-2
proposer:
  agent: harness-assayer
  model: claude-opus-5
  assay: harness/assay/2026-08-25T11-59Z-assay.md
supersedes: null
superseded_by: null
---

## Finding

`.github/workflows/harness.yml` — the PR gate — runs eight constraint steps
sequentially. Only the final `Summary` step carries `if: always()` (`observed`,
lines 25–81). The last two constraint steps, in order, are
*Harness decision records are well-formed* and
*Harness governance is applied and undrifted*: the two validators that hold the
identifier grammar, the required fields, the two-assay promotion threshold, the
three-per-cycle cap, the frozen-record check and the expiry check.

Being last, they are the most maskable steps in the file. That is not
hypothetical. On run `32836457544` (branch `harness-write-path-integrity`,
PR #552) and again on run `32839441437` (branch `harness-validator-binding`,
PR #561), step 8 *Constraint: ShellCheck compliance* is recorded `failure` and
steps 9, 10 and 11 — *Sentinel integrity*, *Harness decision records are
well-formed*, *Harness governance is applied and undrifted* — are all recorded
`skipped` (`observed`, `gh api .../actions/runs/<id>/jobs`, per-step
conclusions). Both of those PRs were changing
`ai-literacy-superpowers/scripts/check-harness-decisions.py` and
`harness-registrar.py`. The two checks that exist to catch a governance
regression did not run on two of the PRs that rewrote the governance code. Both
PRs later merged with every check `pass`, so nothing shipped unverified — but
that was a re-push, not the gate working.

`.github/workflows/gc.yml` is unchanged in this phase and has the same shape:
eleven `GC:` steps, one `if: always()`, on `Summary` (`observed`). The
*Garbage Collection* schedule has failed six consecutive runs, 2026-07-20
through 2026-08-24 (`observed`, `gh run list`). It has not run since, so I make
no claim about a seventh.

Assay 1's finding-2 observed this on `gc.yml`. Its errata narrowed the count of
declared rules the workflow covers and states that "The masking observation - a
failing step silencing every later step - is unaffected and stands"
(`observed`). Its record was accepted, corrupted its target, and was retired;
the retirement's `## Rejected alternatives` closes with "**Re-propose
immediately with `HARNESS.md` as the target.** Deferred, not rejected"
(`observed`). Every fact above was re-read at `b1982b0` rather than carried
forward, and the corrected count forms no part of this claim — I counted the
steps in both files directly.

## Assayer's reasoning

_Written by the Assayer, carried verbatim._

**Why this layer, and what is different from the retired record.** The retired
record pointed at `.github/workflows/gc.yml` as its `target` and the compiler
appended markdown to YAML. `script-validator` now has a fixed route to
`HARNESS.md` (#552, and pinned in `harness/surfaces.yaml`), so the rule text
lands in a document that can hold it and the workflows are named in **Tool**,
which is where the retirement record says they always belonged. I name no
`target` in the metadata: the route wins, and since #568 a routed
classification refuses one.

`/harness-gc` still cannot own this. It runs the rules on demand and reports
each individually; what it cannot observe is the behaviour of a runner nobody
invoked. And `/harness-gc` has no visibility into `harness.yml` at all, which
is the half of this finding that is new.

**Overfitting risk: low.** The rule states a property of any enforcement
workflow and encodes neither ShellCheck, nor release-tag completeness, nor
snapshot staleness — the three rules that happened to fail. It would have
applied identically to all eight observed runs.

**Validation plan.** Push a branch with a deliberately failing early step in
`harness.yml` and assert that (a) every later step produces a conclusion, (b)
the job still concludes `failure`, and (c) no step reports `skipped` for a
reason other than an explicit `if:` condition. The third assertion is the one
that matters: a fix that makes the job green by tolerating failures is worse
than the defect and would satisfy (a) and nothing else.

## Rejection

Declined. The defect this rule was written against has been repaired directly,
and the rule cannot now be corroborated because the thing it would have observed
no longer exists.

Both workflows now carry a per-step guard and derive the job conclusion from the
collected outcomes: eleven GC steps under `!cancelled()`, eight constraint steps
under `always()`, and an aggregation in each that fails the job when any step
failed and — separately — when any step did not run at all. A check that did not
run is reported as not run, which is the three-state behaviour objection O5 said
`if: always()` alone could not deliver.

The rule text is not wrong. It is unreachable. Its classification is
`harness-loop`, it holds evidence from one countable assay against a threshold of
two, and the only route to a second was a fourth assay observing masking still
present. Repairing the defect closes that route.

Taking it deliberately rather than by omission. The alternative was to leave a
known defect standing so that an assay could corroborate a rule about it, which
is the incentive objection O2 of
`docs/superpowers/objections/harness-reassuring-default.md` named this morning:
"the cheapest way to promote any future finding becomes observe a defect, do not
fix it, observe it again next cycle." That objection was about a different record
and it arrived here four hours later, live.

The precedent is assay 1 finding-1, declined on evidence while its defect was
fixed anyway. The assay records the outcome: "the transcription fix travelled and
the rule did not need to."

What this costs, stated plainly: there is no regression guard. Nothing prevents a
future workflow from adding an enforcing step without a guard, and nothing will
notice if someone removes the aggregation. The repair is in two files and rests
on whoever edits them next reading why the comments are there. If that recurs and
a later assay observes it, this record is the evidence that the fix-without-a-rule
route was tried and did not hold.
