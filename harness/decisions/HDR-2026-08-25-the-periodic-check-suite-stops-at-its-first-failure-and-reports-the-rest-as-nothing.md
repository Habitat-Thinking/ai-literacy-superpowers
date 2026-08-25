---
id: HDR-2026-08-25-the-periodic-check-suite-stops-at-its-first-failure-and-reports-the-rest-as-nothing
title: The periodic check suite stops at its first failure, and reports the rest as nothing
status: accepted
classification: script-validator
enforcement: validated
surfaces: [ci]
provisional: true
expires: 2026-11-23
target: .github/workflows/gc.yml
evidence:
  - .github/workflows/gc.yml
  - HARNESS.md
  - observability/snapshots/2026-07-21-snapshot.md
  - harness/assay/2026-08-25T08-08Z-assay.md#finding-2
proposed_cost: |
  One-off: adding `if: always()` to fourteen steps and a final aggregation step
  that fails the job when any collected result failed — perhaps thirty minutes,
  once. Recurring cost is the honest one and it is not zero: the weekly run stops
  reporting one failure and starts reporting between one and ten, so the first
  few weeks after the fix will look worse than the six weeks before it. Whoever
  holds the cadence inherits a backlog that was already there and was being
  hidden, and the temptation at that moment is to demote whichever rule is
  noisiest rather than fix it.

  Two ways it can be gamed. **Making the job green rather than complete** —
  collecting results and then not failing on them, which satisfies the letter
  ("a result for every rule") while removing the signal entirely; this is the
  likely failure and it is why the rule names the job conclusion explicitly.
  **Deleting a chronically-failing rule from the workflow instead of from
  `HARNESS.md`** — the rule stays declared, nothing runs it, and the run reports
  a complete pass over a smaller set. The second is caught by *Convention parity*
  only if someone thinks to check the workflow against the GC section, which
  nothing currently does.

  ---
cost: |
  We will implement the fourteen absent checks rather than demote them.

  As we are a tiny team the CI build being green will be a focus immediately, so
  the period where the weekly run looks worse than before should be short.

  I can't think of a circumstance when we might retire this rule yet.
proposer:
  agent: harness-assayer
  model: claude-opus-5
  assay: harness/assay/2026-08-25T08-08Z-assay.md
approver: Russ Miles <russ@russmiles.com>
approved_at: 2026-08-25T09:48Z
supersedes: null
superseded_by: null
---

## Finding

`.github/workflows/gc.yml` runs nineteen declared GC rules as sequential steps.
Only the final `Summary` step carries `if: always()`. Every rule step therefore
depends on its predecessor succeeding.

On the 2026-08-24 run, step 5 (*GC: Snapshot staleness*) failed and steps 6
through 14 are recorded `skipped` — *Sentinel integrity*, both shell-script
checks, all three plugins' *Release tag completeness*, *Observability archive*,
*Reflection log archival of promoted entries*, and *Affordance review
staleness* (`observed`, run 32712709028, per-step conclusions). On the five
runs before it — 2026-07-20 through 2026-08-17 — *Release tag completeness*
failed at step 9 and steps 10 through 14 did not run (`observed`, run history
and step conclusions).

So for six consecutive weeks the repository received a single red signal that
named one rule, while between five and nine other rules produced no result at
all. Two of the silenced rules are the ones that watch the learning loop
(*Reflection log archival*) and the observability corpus (*Observability
archive*). Nothing in the run summary distinguishes a rule that passed from a
rule that never ran, and a reader checking "did GC pass?" sees one failure
rather than one failure and nine unknowns.

The masking is bidirectional and this window shows both directions. Before
2026-08-24, an unsatisfiable release-tag check hid everything after it. On
2026-08-24 a newly-actionable signal — the snapshot at
`observability/snapshots/2026-07-21-snapshot.md` crossing the 30-day threshold
declared in HARNESS.md — moved to the front and hid the release-tag failure
that is still there.

## Rule

````markdown
- **Rule**: A periodic check suite must produce a result for every rule it
  declares, in every run. A failing rule may not prevent a later rule from
  running: each rule step in `.github/workflows/gc.yml` carries
  `if: always()`, and the job's conclusion is derived from the collected
  results rather than from the first failure. A rule that did not run is
  reported as not run — never omitted, and never counted as passing. The
  point of a weekly job is the weeks nobody reads it, so a run that
  silently stops partway is a run that reports a smaller world than it
  checked.
- **Enforcement**: deterministic
- **Tool**: `.github/workflows/gc.yml` (weekly schedule)
- **Scope**: pr
````

## Cost

We will implement the fourteen absent checks rather than demote them.

As we are a tiny team the CI build being green will be a focus immediately, so
the period where the weekly run looks worse than before should be short.

I can't think of a circumstance when we might retire this rule yet.

## Why this layer

`/harness-gc` owns running the rules and reporting their individual results, and
it would have found both failures on demand — which is why "the release tags are
missing" and "the snapshot is stale" are rejected candidates in the assay rather
than findings. What `/harness-gc` cannot own is the behaviour of the scheduled
runner when nobody invokes it. The whole value of a weekly job is the weeks
nobody looks, and on-demand tooling is definitionally absent in exactly those
weeks.

This is a defect in a validator and the remedy is a change to that validator, so
`script-validator` is the layer. It is deliberately not `harness-loop`: the
declared rules are correct as written, and routing this to `HARNESS.md` would be
classifying at the layer that feels most decisive rather than the one that owns
the behaviour. The two-assay threshold would also refuse it, and reclassifying
to clear a threshold is the failure this corpus exists to prevent — but that is
a consequence of the classification, not a reason for it.

**The scope this record binds is wider than the evidence that produced it, and
that is a deliberate choice by the approver.**

The assay observed *masking*: a failing step silences every later step. That is
verified — six consecutive red runs, and on 2026-08-24 a failure at step 5 left
steps 6 through 14 recorded `skipped`, including the sentinel-integrity check
that guards the Assayer's own read-only boundary.

Checking the rule against the workflow surfaced a second and larger gap the
assay did not see, and stated incorrectly: the assay says `gc.yml` "runs
nineteen declared GC rules as sequential steps". It does not. `HARNESS.md`
declares nineteen active GC rules; `gc.yml` carries eleven rule steps covering
**five** of them. Fourteen declared rules have never run on a schedule at all.
Four workflow steps correspond to no active declared rule, one of which
(*Affordance review staleness*) is commented out in `HARNESS.md` while running
in CI.

The rule text says a check suite must produce a result for "every rule it
declares". Read narrowly that means every step already in the workflow, and
`if: always()` satisfies it. Read widely it means every rule `HARNESS.md`
declares, and satisfying it means implementing fourteen absent checks. **The
wide reading binds here.** A suite that reports a complete pass over five
nineteenths of what it declares is telling a more comfortable lie than the one
the assay caught, and the narrow fix would leave that lie in place while
producing a green tick that reads as coverage.

The honest objection to this, recorded so a later reader can weigh it: the
evidence in hand is about masking, and it is being used to mandate coverage. A
future assay may find that the coverage half was under-evidenced at the moment
it was accepted. That is the risk the approver took, knowingly, and the cost
below is written against the wide scope rather than the assay's estimate.

## Enforcement

`surfaces: [ci]`, and `harness/surfaces.yaml` records `ci` as supporting
`validated` and `blocked`. The rule declares `validated`.

**Intended `validated`, achieved `validated`. No enforcement gap on the only
surface it targets.**

What `validated` buys and what it does not: the GC workflow runs on a weekly
schedule, not on pull requests, so a violation is *reported* rather than
*refused*. Nothing here blocks a merge. Choosing `blocked` would have been
dishonest — `ci` supports it, but a scheduled job has no merge to stop.

The rule is invisible to the five advisory surfaces — `claude-code`, `codex`,
`cursor`, `copilot`, `windsurf` — and is not listed on them. This is correct
rather than a gap: the rule governs the shape of a workflow file, not the
behaviour of anyone writing code, so there is nothing for an instruction file to
tell an agent. Listing those surfaces would have produced five rows in the
enforcement report reading `advisory` intended and `advisory` achieved, which
would look like reach and mean nothing.

The one thing genuinely unenforced: nothing checks that `gc.yml`'s steps and
`HARNESS.md`'s declared GC rules stay reconciled. *Convention parity* reads only
the `## Constraints` section, so the fourteen-rule gap is invisible to every
existing check. Under the wide reading this rule requires that reconciliation,
and the validation below has to establish it, because no current mechanism does.

## Validation

Four assertions. The first three are the assay's and test the masking defect;
the fourth tests the coverage scope the approver chose.

1. Re-run the workflow with a deliberately failing early step, and assert every
   later step still produces a conclusion.
2. Assert the job still concludes `failure`.
3. Assert no step reports `skipped` for a reason other than an explicit
   condition.
4. Assert that every active GC rule heading in `HARNESS.md` has a corresponding
   step in `gc.yml`, and that every rule step in `gc.yml` maps to an active
   declared rule — failing on a mismatch in either direction.

**Assertion 3 is the one that matters, and it is the falsification criterion.**
A fix that makes the job green by tolerating failures is worse than the defect:
it satisfies "a result for every rule" while removing the signal entirely. If
the implementation reaches green by collecting results and not failing on them,
this rule has been defeated and should be recorded as such rather than counted
as working.

Assertion 4 is what makes the wide reading falsifiable. Today it fails 14 times
in one direction and 4 in the other, and that count is the baseline: if it is
not materially closer to zero at the next review, the rule was written and not
followed, which is the outcome this record most needs to be able to detect.

How anyone would know later whether this helped: the weekly run stops being a
single red signal that names one rule. If in ninety days the GC workflow is
either green with all nineteen rules reporting, or red with a specific and
shrinking list, it helped. If it is still red for the same reason as
2026-07-20, it did not, and the honest move at review is demotion rather than
renewal.

## Rejected alternatives

**No change.** Rejected. The weekly job has failed six consecutive runs —
2026-07-20 through 2026-08-24 — and the failure has been ignored throughout, in
a repository whose own S0 spec argues that "the predictable result is that
people learn to ignore a red check". Nine rules were silenced on the most recent
run, among them the check that enforces the Assayer's read-only trust boundary.
Leaving this is choosing to keep a signal that is known to be misreported. The
option is real and was weighed; it lost on the six weeks of evidence.

**The narrow reading — `if: always()` only.** Rejected, and this is the closest
call in the record. It is cheaper, it matches the assay's evidence exactly, and
it fixes the verified defect. It was rejected because it would leave fourteen
declared rules unscheduled while making the workflow *look* complete: every step
reporting, job conclusion derived, and a green tick over five nineteenths of the
declared surface. That is a better-disguised version of the defect being fixed.
The cost of the wide reading is days rather than thirty minutes, and the
approver accepted that.

**Route it to `/harness-gc`.** Rejected on ownership. `/harness-gc` runs the
rules on demand and reports each result, and it would have surfaced both
underlying failures. It cannot observe the scheduled runner, because it is never
the thing the schedule invokes. The behaviour belongs to the workflow.

**Promote to `harness-loop` and write it into `HARNESS.md`.** Rejected. The
nineteen declared rules are correct as declared; the defect is in the mechanism
that runs them. Promotion would also require evidence from two distinct assays,
and this is the first assay this repository has run — so promoting would have
meant either waiting or reclassifying to clear a gate, and the second is
precisely what this corpus is built to refuse.

**Demote or delete the chronically failing rules.** Rejected, and named in the
rule text as a gaming mode rather than an option. *Release tag completeness* has
failed since 2026-07-20 with an auto-fix that cannot reach green
(`Cannot find commit for v0.29.1 — manual tag needed`). Deleting it from the
workflow while leaving it declared in `HARNESS.md` would produce a complete pass
over a smaller set — the exact failure this record exists to stop. If a rule
should go, it goes through `/harness-review` and a superseding record, not by
quietly leaving the runner.
