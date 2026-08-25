---
spec: harness/assay/2026-08-25T11-59Z-assay.md#finding-2
date: 2026-08-25
mode: spec
diaboli_model: claude-opus-5
objections:
  - id: O1
    category: scope
    severity: critical
    claim: "The finding re-proposes the narrow reading that this rule's own approver rejected in writing eight hours earlier, while presenting itself as carrying forward a retirement that deferred the wide one."
    evidence: "HDR-2026-08-25-the-periodic-check-suite... Rejected alternatives: 'The narrow reading — `if: always()` only. Rejected, and this is the closest call in the record ... It was rejected because it would leave fourteen declared rules unscheduled while making the workflow *look* complete ... That is a better-disguised version of the defect being fixed.' The finding proposes exactly `if: always()` plus aggregation and states 'Nothing currently checks a declared GC rule against a workflow step, and this rule does not add that.' The retirement it cites deferred 'Re-propose immediately with `HARNESS.md` as the target' — the same rule, not a narrower one."
    disposition: pending
    disposition_rationale: null
  - id: O2
    category: implementation
    severity: critical
    claim: "`enforcement: validated` is unreachable for this record by construction: `cmd_propose` emits no `validator` key, and the only artefacts the finding names are `.yml` files, which `validator_state` refuses as not runnable — so the rule compiles to achieved `none` on the one surface it targets."
    evidence: "harness-registrar.py `RUNNABLE_SUFFIXES = ('.py', '.sh', '.bash', '.js', '.rb')` and `validator_state`: 'if not (item.endswith(RUNNABLE_SUFFIXES) or os.access(path, os.X_OK)): return False, f\"validator is not runnable: {item}\"'. `cmd_propose` (lines 455–483) never emits a `validator:` line. `harness/surfaces.yaml`: `ci: supports: [validated, blocked]` — no `advisory`, so `achieved_for` returns 'none'. The finding declares `enforcement: validated` with `**Tool**: .github/workflows/harness.yml and .github/workflows/gc.yml`."
    disposition: pending
    disposition_rationale: null
  - id: O3
    category: implementation
    severity: critical
    claim: "Classifying as `script-validator` writes rule text into HARNESS.md while bypassing the two-assay corroboration threshold that exists to protect HARNESS.md — the precise move the retired record refused, now available for free because the route was hand-edited."
    evidence: "check-harness-decisions.py `_check_promotion_threshold`: 'if status != \"accepted\" or classification != \"harness-loop\" or imported: return'. `harness/surfaces.yaml` routes `script-validator: HARNESS.md`. The retired record: 'The two-assay threshold would also refuse it, and reclassifying to clear a threshold is the failure this corpus exists to prevent.' The finding: 'script-validator now has a fixed route to HARNESS.md (#552 ...), so the rule text lands in a document that can hold it.' The same assay's Unresolved questions: the routes table 'was hand-edited in 91cd510 (#552) ... with no decision record'."
    disposition: pending
    disposition_rationale: null
  - id: O4
    category: premise
    severity: high
    claim: "The half of the finding that is new — binding `harness.yml` — rests on two runs with no demonstrated harm, and the finding concedes the harm did not occur; on a blocking gate, first-failure masking costs a round trip, not safety."
    evidence: "Finding: 'Both PRs later merged with every check pass, so nothing shipped unverified — but that was a re-push, not the gate working.' No evidence is offered that any PR merged while a governance check was `skipped`, nor that the checks are or are not required statuses. Meanwhile the same assay routes the PR gate's real coverage gap elsewhere: 'harness.yml runs eight deterministic constraints and none of the agent-enforced ones' → Owner: /harness-audit."
    disposition: pending
    disposition_rationale: null
  - id: O5
    category: implementation
    severity: high
    claim: "`if: always()` cannot produce the three-valued reporting the rule text demands — it collapses 'did not run' into 'failed' — and the aggregation the rule mandates has no mechanism in the finding, only two mechanisms that each reintroduce a failure the rule forbids."
    evidence: "Rule text: 'A check that did not run is reported as not run — never omitted, and never counted as passing.' `if: always()` yields only `success`/`failure` for a step that executes; a step running after a failed `actions/checkout` reports `failure`, not 'did not run'. No step in either workflow carries an `id:`, which `steps.<id>.outcome` requires; the alternative, `contains(toJSON(steps), 'failure')`, is a substring scan over step output. Cost estimate: 'perhaps forty minutes, once.'"
    disposition: pending
    disposition_rationale: null
  - id: O6
    category: risk
    severity: high
    claim: "The rule mandates `if: always()` verbatim on a workflow that holds `contents: write` and five steps that commit and push, so a cancelled run keeps mutating the repository — and the cost estimate describes the masked steps as though they only report."
    evidence: "`gc.yml`: `permissions: contents: write`; three `Release tag completeness` steps run `git push origin \"$tag\"`, `Observability archive` runs `git commit`/`git push`, `Reflection log archival` runs `git commit`/`git push`. `always()` in GitHub Actions evaluates true when a run is cancelled. Cost estimate: 'On the weekly job it converts one failure into between one and ten' — no mention of writes."
    disposition: pending
    disposition_rationale: null
  - id: O7
    category: specification quality
    severity: high
    claim: "The validation plan names the wrong assertion as its falsification criterion: assertion (c) is vacuous once every step carries an explicit `if:`, and the gaming mode the finding says (c) catches is caught only by (b)."
    evidence: "Validation plan: '(c) no step reports `skipped` for a reason other than an explicit `if:` condition. The third assertion is the one that matters: a fix that makes the job green by tolerating failures ... would satisfy (a) and nothing else.' A green-by-tolerance implementation skips nothing, so it satisfies (a) and (c) and fails only (b) — 'the job still concludes `failure`'. After the fix every enforcing step carries `if: always()`, an explicit condition, so (c) cannot fail."
    disposition: pending
    disposition_rationale: null
  - id: O8
    category: scope
    severity: high
    claim: "The rule states a general property of enforcement workflows but binds two files by name; at least two other workflows enforcing declared HARNESS.md constraints have the identical defect and are exempt by construction, as is any workflow created tomorrow."
    evidence: "Rule text: 'In a workflow that enforces declared constraints or garbage-collection rules, every enforcing step carries `if: always()` ... This binds `.github/workflows/harness.yml` and `.github/workflows/gc.yml`.' `.github/workflows/version-check.yml` runs four sequential enforcing steps and `.github/workflows/convention-parity-check.yml` two, neither with `if: always()`; the repository holds nineteen workflows. Overfitting-risk claim: 'The rule states a property of any enforcement workflow.'"
    disposition: pending
    disposition_rationale: null
  - id: O9
    category: alternatives
    severity: high
    claim: "One job per check — the native GitHub Actions mechanism for independent conclusions — is not weighed anywhere, and it makes the finding's own likeliest gaming mode structurally impossible rather than merely forbidden in prose."
    evidence: "The finding's only alternatives discussion is 'Two ways it can be gamed', both failure modes rather than designs. Its named risk — 'Making the job green rather than complete — collecting results and then not failing on them ... This is the likely failure' — exists only because a single job's conclusion is computed by hand. Separate jobs (or a `matrix`) give each check its own conclusion with no aggregation step, and each becomes independently requireable in branch protection. `if: ${{ !cancelled() }}` is likewise unweighed against `always()`."
    disposition: pending
    disposition_rationale: null
  - id: O10
    category: specification quality
    severity: medium
    claim: "'Every enforcing step' is undefined against the two files the rule binds, and the rule text bakes a positional fact about today's file layout into a constraint that will outlive it."
    evidence: "Rule text: 'every enforcing step carries `if: always()`' and 'On the PR gate the two harness-governance checks are the last two steps.' `harness.yml` holds `actions/checkout` and a `Check HARNESS.md exists` guard alongside eight `Constraint:` steps; `gc.yml` holds eleven `GC:` steps of which `GC: Affordance review staleness` is 'Report-only: ... always exits 0'. The cost estimate says 'eight steps in harness.yml and eleven in gc.yml', which resolves the ambiguity in the estimate but not in the rule."
    disposition: pending
    disposition_rationale: null
  - id: O11
    category: risk
    severity: medium
    claim: "The rule's own recurring cost makes its named second gaming mode the cheapest available response, and the finding states that nothing detects it — so the most likely outcome of acceptance is a complete-looking pass over a smaller set."
    evidence: "Cost estimate: 'The moment of maximum temptation is the first Monday after the fix, and the tempting move is to demote whichever rule is loudest' and 'Deleting a chronically failing step from the workflow instead of retiring the rule from HARNESS.md — the rule stays declared, nothing runs it ... Nothing currently checks a declared GC rule against a workflow step, and this rule does not add that.' The loudest rule is already known unsatisfiable: gc.yml prints 'Cannot find commit for v$version — manual tag needed'."
    disposition: pending
    disposition_rationale: null
---

# Objections — assay finding-2, workflow step masking

Adversarial review of `harness/assay/2026-08-25T11-59Z-assay.md#finding-2`
only. The rest of the assay was read for context and is not under objection.
Mode: `spec`. The thing under review is the finding as an argument: its rule
text, its evidence, its "why this layer" reasoning, its overfitting claim, its
validation plan and its cost estimate.

## O1 — scope — critical

### Claim

The finding re-proposes the narrow reading that this rule's own approver
rejected in writing eight hours earlier, while presenting itself as carrying
forward a retirement that deferred the wide one.

### Evidence

The retired record's `## Rejected alternatives` weighs the narrow reading
explicitly and refuses it:

> **The narrow reading — `if: always()` only.** Rejected, and this is the
> closest call in the record. It is cheaper, it matches the assay's evidence
> exactly, and it fixes the verified defect. It was rejected because it would
> leave fourteen declared rules unscheduled while making the workflow *look*
> complete: every step reporting, job conclusion derived, and a green tick over
> five nineteenths of the declared surface. That is a better-disguised version
> of the defect being fixed.

The approver's own cost, in their words, was written against the wide scope:
"We will implement the fourteen absent checks rather than demote them."

The finding proposes the narrow reading. Its rule text requires `if: always()`
and a derived job conclusion, and its cost estimate closes:

> Nothing currently checks a declared GC rule against a workflow step, and this
> rule does not add that. It is a real hole and I am naming it rather than
> widening the proposal to cover it.

The retirement record it cites did not withdraw the wide scope. It withdrew the
rule because the target was wrong — "Withdrawing where the rule was pointed, not
the rule itself" — and deferred "Re-propose immediately with `HARNESS.md` as
the target." That deferral is a deferral of *that* rule. The finding never
mentions that the scope it chose is the one this approver already declined, and
the words "fourteen" and "coverage" appear nowhere in it.

### Why this matters

The approver will read this finding as the deferred re-proposal the retirement
promised. It is not. Accepting it silently reverses a recorded decision, and the
record the corpus keeps will show a rule accepted at a scope its approver
rejected — with no trace of the reversal, because the finding never surfaced it.
The outcome the approver called "a better-disguised version of the defect being
fixed" becomes the shipped state: a workflow where every step reports, over five
nineteenths of what HARNESS.md declares.

The honest paths are both open and both need saying out loud. Narrowing may well
be right — the coverage half was accepted on masking evidence, and the retired
record says so against itself: "the evidence in hand is about masking, and it is
being used to mandate coverage." But that is an argument the finding has to make
and did not.

## O2 — implementation — critical

### Claim

`enforcement: validated` is unreachable for this record by construction. The
proposer emits no `validator` key, and the only artefacts the finding names are
`.yml` files, which the runnability test refuses — so the rule compiles to
achieved `none` on the one surface it targets.

### Evidence

`harness-registrar.py`:

> `RUNNABLE_SUFFIXES = (".py", ".sh", ".bash", ".js", ".rb")`

and in `validator_state`:

> `if not (item.endswith(RUNNABLE_SUFFIXES) or os.access(path, os.X_OK)):`
> `    return False, f"validator is not runnable: {item}"`

`cmd_propose` (lines 455–483) writes `provisional`, `expires`, `target`,
`overfitting_risk`, `evidence`, `proposed_cost`, `cost`, `proposer`,
`supersedes`, `superseded_by` — and no `validator`. So `validator_state`
returns `(False, "no validator declared")`.

`harness/surfaces.yaml` gives `ci: supports: [validated, blocked]`. In
`achieved_for`, intended `validated` with `validated=False` and no `advisory`
in `supports` returns `("none", why)`.

The finding declares `enforcement: validated`, `surfaces: [ci]`, and
`**Tool**: .github/workflows/harness.yml and .github/workflows/gc.yml`.

### Why this matters

The enforcement report will read intended `validated`, achieved `none`, on the
rule's only surface. That is not a transitional gap that closes when someone
does the work — no `.yml` can ever satisfy the runnability test, so no amount of
editing the workflows moves this rule up the ladder. Reaching `validated`
requires a runnable checker that reads the two workflows and asserts the
property, and the finding proposes none, names none, and costs none.

Compare finding-1 in the same assay, which names
`check-command-cli-parity.py` as its Tool and states the gap explicitly:
"No such check exists today, so the first `/harness-compile` after acceptance
should report an enforcement **gap** on `ci` rather than `validated`."
Finding-2's "Why this layer" section says nothing about enforcement achievement
at all. Two findings by the same agent in the same assay, one of which
interrogates its own enforcement claim and one of which does not.

There is a second and quieter problem in the same field: **Tool** carries two
paths joined by the English word "and". Every mechanism that consumes a
validator list — `validator_state` iterates `items` — expects paths, not prose.

## O3 — implementation — critical

### Claim

Classifying as `script-validator` writes rule text into `HARNESS.md` while
bypassing the two-assay corroboration threshold that exists to protect
`HARNESS.md`. This is the move the retired record explicitly refused, and it is
available now only because the routing table was changed by hand.

### Evidence

`check-harness-decisions.py`, `_check_promotion_threshold`:

> `if status != "accepted" or classification != "harness-loop" or imported:`
> `    return`

with the docstring: "HARNESS.md governs the loop, so a change to it must survive
the loop below: evidence from at least two distinct assays."

`harness/surfaces.yaml` routes `script-validator: HARNESS.md`. So a
`script-validator` record's text lands in `HARNESS.md` and the threshold does
not fire.

The retired record refused this reasoning when the route did not yet exist:

> **Promote to `harness-loop` and write it into `HARNESS.md`.** Rejected. …
> Promotion would also require evidence from two distinct assays, and this is
> the first assay this repository has run — so promoting would have meant either
> waiting or reclassifying to clear a gate, and the second is precisely what
> this corpus is built to refuse.

The finding now relies on the route to reach the same destination:

> `script-validator` now has a fixed route to `HARNESS.md` (#552, and pinned in
> `harness/surfaces.yaml`), so the rule text lands in a document that can hold
> it.

And the same assay, in its own Unresolved questions, records that the route
arrived ungoverned: "It was hand-edited in `91cd510` (#552) to add
`script-validator: HARNESS.md` — a change that determines which artifact every
future rule of that classification lands in — with no decision record."

### Why this matters

The corroboration threshold is the mechanism that stops one incident becoming a
permanent rule in the document that governs the loop. It is keyed on
classification, not on destination. Once a classification that skips the
threshold routes to `HARNESS.md`, the threshold guards a name rather than a
document, and any finding that can plausibly be called a validator defect
reaches `HARNESS.md` on a single assay's evidence.

That is what would happen here. The evidence for the `gc.yml` half is assay 1's,
re-read rather than re-observed — the workflow has not run since, as the finding
says. The evidence for the `harness.yml` half is two runs on one day. This is
one incident, seen twice, arriving in `HARNESS.md` without corroboration, via a
route that itself has no record.

I am not claiming bad faith; the finding's reasoning for `script-validator` is
the same reasoning the retired record used, and it was sound then. The objection
is that the consequence changed underneath it when the route was added, and
nobody has weighed that.

## O4 — premise — high

### Claim

The half of the finding that is new — binding `.github/workflows/harness.yml` —
rests on two runs with no demonstrated harm, and the finding concedes the harm
did not occur. On a blocking gate, first-failure masking costs a round trip, not
safety.

### Evidence

The finding's own concession:

> Both PRs later merged with every check `pass`, so nothing shipped unverified —
> but that was a re-push, not the gate working.

And the framing it justifies: "`/harness-gc` has no visibility into
`harness.yml` at all, which is the half of this finding that is new."

No evidence is offered that any PR ever merged while a governance check was
recorded `skipped`. No evidence is offered about whether these are required
status checks. The project's own convention is "Merge only when green."

### Why this matters

"That was a re-push, not the gate working" is the load-bearing sentence and I
think it is wrong. A gate that refuses a merge until every check has produced a
green result *is* the gate working; a re-push is the mechanism by which it
works. The invariant that matters — nothing merges without a full green run —
held on both runs and the finding says so.

The two readings both cut against the binding. If the checks are required, the
masked steps always run before merge, and the cost is developer latency; the
remedy for latency is a faster gate, not a governance rule. If they are not
required, then a red PR can merge regardless of `if: always()`, and this rule
buys nothing — the missing thing is branch protection, which the finding does
not mention.

Meanwhile the assay itself records the PR gate's actual blind spot in its
Rejected candidates: "`.github/workflows/harness.yml` runs eight deterministic
constraints and none of the agent-enforced ones, so CI going green on these PRs
never spoke to this" — seven PRs shipped with no adjudicated objection record.
That is a coverage hole with observed consequences, routed to `/harness-audit`.
Binding `harness.yml` for ordering while the same file's coverage gap is
someone else's problem is the smaller half of the smaller problem.

## O5 — implementation — high

### Claim

`if: always()` cannot produce the three-valued reporting the rule text demands.
It collapses "did not run" into "failed". And the aggregation the rule mandates
has no mechanism in the finding — only two available mechanisms, each of which
reintroduces a failure the rule forbids.

### Evidence

Rule text:

> A check that did not run is reported as not run — never omitted, and never
> counted as passing.

`if: always()` produces `success` or `failure` for any step that executes. A
step that executes after `actions/checkout` failed — every enforcing step in
both files, under the proposed change — reports `failure`, which is neither
"passed" nor "not run".

For the job conclusion, `steps.<id>.outcome` requires an `id:`. Neither
`harness.yml` nor `gc.yml` gives any step an `id:`. The rule text does not
mention ids. The alternative generic form, `contains(toJSON(steps), 'failure')`,
is a substring scan over serialised step state.

Cost estimate: "`if: always()` on eight steps in `harness.yml` and eleven in
`gc.yml`, plus an aggregation step in each that fails the job when any collected
result failed. Perhaps forty minutes, once."

### Why this matters

The rule's whole value proposition is distinguishing three states, and the
mechanism it mandates delivers two. On a failed checkout the weekly run goes
from one honest failure to eleven meaningless ones, and the reader who was
supposed to learn which rules are red learns nothing — a different lie in the
same family as the one being fixed.

The aggregation is worse than the estimate implies. The enumerated form requires
adding an `id` to nineteen steps and hand-listing all nineteen in an expression;
that list is a second declaration of the step set, and a step omitted from it is
"counted as passing" by omission — the exact words the rule forbids, now in the
mechanism meant to enforce it. The `toJSON` form has no list to drift but
matches the literal string `failure` anywhere in serialised step state,
including in a step's own output. Neither is forty minutes' work if it is to be
trusted, and the rule text — which is what lands in `HARNESS.md` — chooses
neither, so the next implementer picks.

## O6 — risk — high

### Claim

The rule mandates `if: always()` verbatim on a workflow that holds
`contents: write` and five steps that commit and push. `always()` evaluates true
on cancellation, so a cancelled run keeps mutating the repository — and the cost
estimate describes the masked steps as though they only report.

### Evidence

`gc.yml` declares `permissions: contents: write`. Five steps mutate:

- three `GC: Release tag completeness` steps run `git tag` and
  `git push origin "$tag"`
- `GC: Observability archive` runs `mv`, `git add`, `git commit`, `git push`
- `GC: Reflection log archival of promoted entries (Path 1)` runs
  `archive-promoted-reflections.sh --dry-run=false`, then `git commit`,
  `git push`

`always()` in GitHub Actions is documented as returning true even when the
workflow is cancelled; `!cancelled()` or `success() || failure()` is the form
that stops on cancellation. The rule text specifies `if: always()` by name.

The cost estimate discusses only reporting volume: "On the **weekly job** it
converts one failure into between one and ten."

### Why this matters

The rule reads as a reporting change and is not one. Today, a failure at step 5
stops the four write steps that follow it. After the change they run —
including after a failed checkout, when the working tree is not what any of them
assume, and including after a cancel, when a human has explicitly asked the run
to stop. `harness.yml` is read-only and unaffected; `gc.yml` is where the rule's
evidence lives and where the write permission is.

There may be no live harm — the archive step guards on a directory, the
reflection step guards on file counts, the tag steps guard on `git tag -l`. That
is exactly the kind of thing that should be established before nineteen steps
are made unconditional under a write token, and the finding does not establish
it because it did not notice the writes. `!cancelled()` would keep the whole
benefit and remove the cancellation half of this at no cost, and the rule text
forecloses it by naming `always()`.

## O7 — specification quality — high

### Claim

The validation plan designates the wrong assertion as its falsification
criterion. Assertion (c) is vacuous once every step carries an explicit `if:`,
and the gaming mode the finding says (c) catches is caught only by (b).

### Evidence

> **Validation plan.** Push a branch with a deliberately failing early step in
> `harness.yml` and assert that (a) every later step produces a conclusion, (b)
> the job still concludes `failure`, and (c) no step reports `skipped` for a
> reason other than an explicit `if:` condition. The third assertion is the one
> that matters: a fix that makes the job green by tolerating failures is worse
> than the defect and would satisfy (a) and nothing else.

A green-by-tolerance implementation runs every step and skips nothing. It
satisfies (a) *and* (c). It fails only (b). And after the fix every enforcing
step carries `if: always()` — an explicit `if:` condition — so any `skipped`
outcome is attributable to one by definition, and (c) cannot fail.

The mislabel is inherited: the retired record says "Assertion 3 is the one that
matters, and it is the falsification criterion."

### Why this matters

A validation plan is the mechanism by which a rule can later be shown not to
have worked, and this one points at the assertion that discriminates nothing.
If the implementation reaches green by collecting outcomes and not failing on
them — which the finding calls "the likely failure" — the designated
falsification criterion passes, and the record is closed as validated over a
defeated rule.

The fix is small and should be made before acceptance rather than after:
(b) is the falsification criterion, and it needs the stronger form — assert the
job concludes `failure` *when and only when* at least one collected step result
is `failure`, tested in both directions. Naming the wrong one is the kind of
error that only shows up ninety days later, at review, as a green tick.

## O8 — scope — high

### Claim

The rule states a general property of enforcement workflows but binds two files
by name. At least two other workflows enforcing declared `HARNESS.md`
constraints have the identical defect and are exempt by construction, as is any
workflow created tomorrow.

### Evidence

Rule text, first sentence and third:

> In a workflow that enforces declared constraints or garbage-collection rules,
> every enforcing step carries `if: always()` … This binds
> `.github/workflows/harness.yml` and `.github/workflows/gc.yml`.

The repository holds nineteen workflows. `.github/workflows/version-check.yml`
runs four sequential enforcing steps — `Extract versions from all locations`,
`Check all three locations match`, `Check marketplace plugin_version matches
plugin.json`, `Check version bumped for plugin changes` — with no
`if: always()`. `.github/workflows/convention-parity-check.yml` runs two —
`Verify convention files mirror HARNESS.md constraints` and `Verify convention
files offer every constraint enum value` — with no `if: always()`. Both enforce
declared `HARNESS.md` constraints.

Overfitting-risk claim: "The rule states a property of any enforcement workflow
and encodes neither ShellCheck, nor release-tag completeness, nor snapshot
staleness."

### Why this matters

The overfitting argument is made about rule *content* and is true there. It is
false about rule *reach*: two hard-coded paths are the narrowest possible
binding, and they were chosen because they are where the evidence happened to
land. A reader of `HARNESS.md` in six months will find a constraint that
announces a general property and enforces it on two files, with nothing
explaining why `version-check.yml` masks three checks behind one and is fine.

It also opens a third gaming mode the finding does not name. It names two —
green-not-complete, and deleting a step. The third is cheaper than both: move
the noisy step into a new workflow file. The rule stays satisfied, the step
still runs, the declared rule is still declared, and nothing was deleted. A rule
scoped to a property rather than to two paths would not have this hole.

## O9 — alternatives — high

### Claim

One job per check — the native GitHub Actions mechanism for independent
conclusions — is not weighed anywhere, and it makes the finding's own likeliest
gaming mode structurally impossible rather than merely forbidden in prose.

### Evidence

The finding contains no alternatives section. Its nearest equivalent is "Two
ways it can be gamed", which enumerates failure modes rather than designs. The
first of those exists only because a single job's conclusion is computed by
hand:

> **Making the job green rather than complete** — collecting results and then
> not failing on them satisfies "a result for every step" while deleting the
> signal entirely. This is the likely failure, and it is why the rule names the
> job conclusion explicitly rather than only the steps.

Under separate jobs, each check's job conclusion *is* its result. There is no
aggregation step to write incorrectly, no `id` to add, no expression to
maintain, no list that can omit a step, and each check appears as its own status
on the PR so branch protection can require it individually. A `matrix` over the
check commands gives the same for the shell-based steps at one job definition.
`if: ${{ !cancelled() }}` is likewise unweighed against `always()` (see O6).

### Why this matters

Spec time is when alternatives are still live, and this one is materially
simpler in exactly the dimension the finding is worried about. The rule's
elaborate second clause — "the job's conclusion is derived from the collected
step results rather than from the first failure" — exists solely to compensate
for keeping everything in one job. Remove that constraint and the clause, the
gaming mode, the aggregation expression and half the cost estimate all go with
it.

I am not proposing the design; that is not my role, and there are real reasons to
prefer one job (runner minutes, checkout cost, sequencing). But those reasons are
not in the finding, and an approver reading it cannot tell whether the one-job
shape was chosen or inherited.

## O10 — specification quality — medium

### Claim

"Every enforcing step" is undefined against the two files the rule binds, and
the rule text bakes a positional fact about today's file layout into a
constraint meant to outlive it.

### Evidence

Rule text: "every enforcing step carries `if: always()`" and "On the PR gate the
two harness-governance checks are the last two steps, so any earlier constraint
failure hides them."

`harness.yml` holds an `actions/checkout` step and a `Check HARNESS.md exists`
guard alongside eight `Constraint:` steps. `gc.yml` holds eleven `GC:` steps, of
which `GC: Affordance review staleness` is documented in the file as
"Report-only: the scanner self-skips when there is no `## Affordances` section
and always exits 0."

The cost estimate resolves the count as "eight steps in `harness.yml` and eleven
in `gc.yml`" — i.e. neither the checkout nor the guard — but the rule text does
not, and it is the rule text that lands in `HARNESS.md`.

### Why this matters

The count lives in the cost estimate, which is discarded at compile time; the
ambiguity lives in the rule, which is what a future implementer and a future
checker read. Is a report-only step that never fails an "enforcing step"? Is the
guard? Two reasonable people produce two different workflows and both claim
compliance.

The positional sentence is a separate durability problem. "The two
harness-governance checks are the last two steps" is true of `harness.yml`
today and stops being true the first time anyone appends a constraint. A rule
that asserts a fact about a file rather than a property of it is a rule that
will read as false to someone who then has to decide whether the rule is wrong
or the file is.

## O11 — risk — medium

### Claim

The rule's own recurring cost makes its named second gaming mode the cheapest
available response, and the finding states that nothing detects it — so the most
likely outcome of acceptance is a complete-looking pass over a smaller set.

### Evidence

The finding's cost estimate:

> The moment of maximum temptation is the first Monday after the fix, and the
> tempting move is to demote whichever rule is loudest.

and

> **Deleting a chronically failing step from the workflow instead of retiring
> the rule from `HARNESS.md`** — the rule stays declared, nothing runs it, and
> the run reports a complete pass over a smaller set. *Convention parity* does
> not catch this … Nothing currently checks a declared GC rule against a
> workflow step, and this rule does not add that.

The loudest rule is already known to be unsatisfiable by its own auto-fix:
`gc.yml` prints `::error::Cannot find commit for v$version — manual tag needed`,
and the retired record records that this has failed since 2026-07-20.

### Why this matters

The finding is honest about this, which is why it is `medium` and not higher —
naming an uncovered hole is better than papering it. But an approver should see
the shape plainly: the rule creates new noise on a weekly job that has been red
for six weeks and unread, names the cheapest way to make that noise stop, states
that the way is undetectable, and proposes no detection. The rule's stated
success criterion — a shrinking list of specific failures — and its cheapest
failure mode are indistinguishable from the outside.

This is also the precise argument the retired record used to reject the narrow
reading, arriving from the other direction, which ties it back to O1.

## Explicitly not objecting to

- **Naming no `target` in the metadata**: the finding is right that
  `script-validator` has a fixed route and that since #568 a routed
  classification refuses a target; this is the correct handling of the defect
  that broke `gc.yml`, and my objection in O3 is about the route's governance,
  not about honouring it.
- **Citing a corrected finding as evidence**: `harness/assay/2026-08-25T08-08Z-assay.md#finding-2`
  carries an errata, but the errata itself says "The masking observation — a
  failing step silencing every later step — is unaffected and stands", and
  `--acknowledge-correction` exists precisely for this case.
- **Re-reading every fact at `b1982b0` rather than carrying it forward**: the
  finding says so explicitly and the step counts I checked in both workflows
  (eight `Constraint:` steps, eleven `GC:` steps, `if: always()` on `Summary`
  only) are accurate as stated.
- **The six-consecutive-failure evidence for `gc.yml`**: it is real, serious,
  and unaddressed; nothing in this record argues that the weekly job is fine.
- **The disclosure of two gaming modes and one uncovered hole**: this is the
  finding at its best and I would rather see more of it, not less — O11 objects
  to the consequence, not to the disclosure.
- **The refusal to widen into a declared-rule-versus-workflow-step check**:
  as a design instinct this is defensible and the finding argues it well; my
  objection (O1) is only that this approver already decided otherwise on this
  rule, and the finding does not say so.
- **The vestigial `Check HARNESS.md exists` guard**: it prints a warning and
  `exit 0`, so it gates nothing today and would gate nothing after this change
  either. It is a real defect and it is not this finding's.
- **The finding's title and framing as prose**: it is clear, it distinguishes
  observed from reported throughout, and it is the kind of writing that makes
  adversarial review possible at all.
