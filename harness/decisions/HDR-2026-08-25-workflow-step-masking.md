---
id: HDR-2026-08-25-workflow-step-masking
title: A failing step still cancels every check after it, and on 2026-08-25 it cancelled the two that govern governance
status: proposed
classification: harness-loop
enforcement: validated
surfaces: [ci]
provisional: true
expires: 2026-11-23
overfitting_risk: low
proposed_rule: |
  - **Rule**: In a workflow that enforces declared constraints or
    garbage-collection rules, every enforcing step carries `if: always()`, and
    the job's conclusion is derived from the collected step results rather than
    from the first failure. A check that did not run is reported as not run —
    never omitted, and never counted as passing. This binds
    `.github/workflows/harness.yml` and `.github/workflows/gc.yml`. On the PR
    gate the two harness-governance checks are the last two steps, so any
    earlier constraint failure hides them; on the weekly job the whole value is
    the weeks nobody reads it. A run that stops partway reports a smaller world
    than it declared it would check.
  - **Enforcement**: deterministic
  - **Tool**: `.github/workflows/harness.yml` and `.github/workflows/gc.yml`
  - **Scope**: pr
evidence:
  - .github/workflows/harness.yml
  - .github/workflows/gc.yml
  - harness/decisions/HDR-2026-08-25-retire-periodic-check-suite-runner.md
  - harness/assay/2026-08-25T08-08Z-assay.md#finding-2
  - HARNESS.md
  - harness/assay/2026-08-25T11-59Z-assay.md#finding-2
proposed_cost: |
  One-off: `if: always()` on eight steps in `harness.yml` and eleven in
  `gc.yml`, plus an aggregation step in each that fails the job when any
  collected result failed. Perhaps forty minutes, once.

  The recurring cost is the honest one and it is not zero, and it differs by
  workflow. On the **PR gate** it makes red PRs noisier: a branch with a
  ShellCheck error will now show three failures instead of one, and the temptation
  is to read the extra two as noise rather than as two governance checks that were
  never going to pass either. On the **weekly job** it converts one failure into
  between one and ten. The six weeks of *Garbage Collection* failures already
  hide an unknown number of results; whoever holds the cadence inherits a backlog
  that was always there. The moment of maximum temptation is the first Monday
  after the fix, and the tempting move is to demote whichever rule is loudest.

  Two ways it can be gamed. **Making the job green rather than complete** —
  collecting results and then not failing on them satisfies "a result for every
  step" while deleting the signal entirely. This is the likely failure, and it is
  why the rule names the job conclusion explicitly rather than only the steps.
  **Deleting a chronically failing step from the workflow instead of retiring the
  rule from `HARNESS.md`** — the rule stays declared, nothing runs it, and the run
  reports a complete pass over a smaller set. *Convention parity* does not catch
  this; it compares `HARNESS.md` against its three prose mirrors, not against the
  workflows. Nothing currently checks a declared GC rule against a workflow step,
  and this rule does not add that. It is a real hole and I am naming it rather
  than widening the proposal to cover it.

  ---
cost: ""
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

_Written by the Assayer, carried verbatim. Not the approver's words, and not a substitute for the sections below._

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

## Rule

````markdown
- **Rule**: In a workflow that enforces declared constraints or
  garbage-collection rules, every enforcing step carries `if: ${{ !cancelled() }}`, and
  the job's conclusion is derived from the collected step results rather than
  from the first failure. A check that did not run is reported as not run —
  never omitted, and never counted as passing. This binds
  `.github/workflows/harness.yml` and `.github/workflows/gc.yml`. A run that stops partway reports a smaller world
  than it declared it would check.
- **Enforcement**: deterministic
- **Tool**: `.github/workflows/harness.yml` and `.github/workflows/gc.yml`
- **Scope**: pr
````

## Cost

_Proposed by the Assayer. To be replaced at acceptance by the approver's own words:_

One-off: `if: always()` on eight steps in `harness.yml` and eleven in
`gc.yml`, plus an aggregation step in each that fails the job when any
collected result failed. Perhaps forty minutes, once.

The recurring cost is the honest one and it is not zero, and it differs by
workflow. On the **PR gate** it makes red PRs noisier: a branch with a
ShellCheck error will now show three failures instead of one, and the temptation
is to read the extra two as noise rather than as two governance checks that were
never going to pass either. On the **weekly job** it converts one failure into
between one and ten. The six weeks of *Garbage Collection* failures already
hide an unknown number of results; whoever holds the cadence inherits a backlog
that was always there. The moment of maximum temptation is the first Monday
after the fix, and the tempting move is to demote whichever rule is loudest.

Two ways it can be gamed. **Making the job green rather than complete** —
collecting results and then not failing on them satisfies "a result for every
step" while deleting the signal entirely. This is the likely failure, and it is
why the rule names the job conclusion explicitly rather than only the steps.
**Deleting a chronically failing step from the workflow instead of retiring the
rule from `HARNESS.md`** — the rule stays declared, nothing runs it, and the run
reports a complete pass over a smaller set. *Convention parity* does not catch
this; it compares `HARNESS.md` against its three prose mirrors, not against the
workflows. Nothing currently checks a declared GC rule against a workflow step,
and this rule does not add that. It is a real hole and I am naming it rather
than widening the proposal to cover it.

---

## Why this layer

script-validator writes rule text into HARNESS.md while skipping the two-assay threshold that exists to protect it. Reclassified to harness-loop so the threshold applies. That makes this record unacceptable as it stands - assay 1's finding-2 carries an erratum and does not corroborate, leaving one countable assay against a threshold of two - and the classification is chosen for what owns the behaviour rather than for what clears.

## Enforcement

Intended validated on ci. Achieved is none: the proposer emits no validator key and no .yml can satisfy the runnability test, so no amount of editing the workflows moves this up the ladder. Reaching validated needs a runnable checker that reads both workflows and asserts the property.

## Validation

Nothing will tell us whether this rule helped. There is no measurement that would separate a repository where it worked from one where it was ignored, and the drafted plan named a criterion nobody can evaluate. Provisional on that basis, expiring 2026-11-23. The review at expiry is a judgement, not a reading.

## Rejected alternatives

The narrow reading, if: always() only - this record re-proposes it, and it is the reading already rejected in writing when the record it supersedes was accepted. Conceded rather than defended. One job per check - the native mechanism for independent conclusions, which makes the likeliest failure mode structurally impossible; not weighed by the finding, and to be weighed in the redraft. No change - rejected: six consecutive failing runs with two auto-fix rules masked behind them.
