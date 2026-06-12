---
spec: docs/superpowers/specs/2026-06-11-cost-estimate-command-design.md
date: 2026-06-12
mode: spec
diaboli_model: claude-opus-4-8[1m]
objections:
  - id: O1
    category: specification quality
    severity: medium
    claim: "The §7.1a per-checklist-line table classifies line 7 (Time split) as a partial FIX ('fix-in-place only a pure structural mistyping with no value change'), but no such fixable case is constructible without touching a derived value, so the one non-trivial 'fix' the table admits beyond line 8 is undefined — the ambiguity O2 was meant to remove was relocated into line 7, not eliminated."
    evidence: "§7.1a table row 7: 'ABORT if a value is missing/mistyped (authoring); fix-in-place only a pure structural mistyping with no value change.' The format reference defines agent_compute_time as a `{low, high}` range and human_gate_time as a qualitative string (estimate-record-format.md:364-366). A shape-mistyping of either either changes a value (range bounds) or is indistinguishable from a missing/wrong field — so 'pure structural mistyping with no value change' has no worked instance."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Collapse §7.1a row 7 (Time split) to a clean ABORT
      (consistent with rows 1-6): any time-field defect aborts, since no
      no-value-change time mistyping is constructible. Removes the relocated
      ambiguity.
  - id: O2
    category: implementation
    severity: low
    claim: "The O1-fix (change-list) and the O2-fix (abort on all derived-value defects) interact so that the change-list can contain only one thing — a deleted stray verdict field (line 8) — making 'an explicit change-list of exactly what the command altered' a near-always-trivial or empty disclosure, and the two fixes therefore deliver far less transparency than their prose implies."
    evidence: "§7.1a: 'In practice the only routinely-fixed line is #8 (delete a stray verdict field).' Every other table row is ABORT. §5 step 5 / FR-6a require a change-list 'when the checkpoint changed anything', and otherwise 'no checkpoint changes — record as emitted by the agent.' The union of fixable cases is {delete a stray recommendation/verdict/proceed field}."
    disposition: accepted
    disposition_rationale: >
      Accepted as a noted observation. The change-list is bounded to line-8
      deletions given the structural-only boundary — but the disclosure
      obligation is honest and worth keeping; recorded that the mechanism's yield
      is narrow, not a defect. No change.
  - id: O3
    category: risk
    severity: medium
    claim: "`cost-estimates/` is a new committed top-level directory (the spec declines to mandate gitignoring it), so S3 begins committing prospective estimate records — files whose `target` may reference an unmerged spec or a since-deleted slice — into version control, with no decision on staleness, rotation, or what happens when the referenced target changes after the estimate is committed."
    evidence: "§6.1: 'the spec does not mandate gitignoring them (they are inspectable artefacts), but flags it as a docs-reference note.' The existing .gitignore gitignores the analogous derived /diagnose output (diagnostic-legibility/output/) precisely because it is 'derived, regenerable'. An estimate is likewise a regenerable guess, yet S3 leaves it committed-by-default with no staleness story."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Gitignore cost-estimates/ by default (consistent with the
      /diagnose derived-output convention) — estimates are derived, regenerable
      guesses referencing moving targets. State it as a decision (gitignored by
      default + add the .gitignore line in this slice), not a deferred docs-note.
  - id: O4
    category: scope
    severity: medium
    claim: "The O6-fix's 'blocking acceptance criterion' is keyed on an event no scheduled slice produces — 'the first slice that produces a cost-present estimate record' requires a usable observability/costs/ snapshot to first land, but landing a snapshot is not itself a scheduled deliverable of any slice (S6 is the calibration loop, not a snapshot-capture slice), so the criterion may never fire and the absolute-rate check can still be orphaned exactly as O6 feared."
    evidence: "§7.2: 'the absolute-rate check becomes BLOCKING on — and is a required deliverable of — the first slice that produces a cost-present estimate record (equivalently, the first slice under which a usable observability/costs/ snapshot lands…). On today's roadmap that is S6 (#373).' But §7.2 also states the repo 'cannot produce' a cost-present record because observability/costs/ is empty, and no slice in S4-S6 is described as capturing a snapshot — S6 consumes actuals (calibration), it is not the slice that first makes a snapshot exist. The trigger is a soft pointer in an issue body, not a gate any CI or slicing record enforces."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix the homing. Bind the absolute-rate check to a slice NUMBER
      directly (or name the slice that captures the first snapshot) so the trigger
      is reachable — don't leave it keyed on an event no scheduled slice produces.
      The re-filed issue must name a concrete blocking slice, not a precondition
      the roadmap never causes.
  - id: O5
    category: specification quality
    severity: low
    claim: "Five of the nine per-checklist-line classifications (lines 1, 2, 3, and the cost halves of 5 and 6) key on cost_usd / per-stage bands that no record the command can emit today carries — by the spec's own closed-world argument — so the §7.1a table spends five rows on ABORT paths unreachable until a snapshot lands, while the only live abort paths today are lines 4, 8, 9; the table reads as uniformly live when two-thirds of it is dormant."
    evidence: "§7.2: 'every record S3 writes today is cost-omitted — it carries no cost_usd and no per-stage cost_usd band.' estimate-record-format.md:320-363: lines 2 (per-stage coupling), 3 (split-tier spread), and the cost axis of lines 5-6 'pass vacuously' on a cost-omitted record, so their ABORT branches are unreachable today."
    disposition: accepted
    disposition_rationale: >
      Accepted as a noted observation (cheap one-line flag welcome): mark in the
      spec that, against today's cost-omitted-only records, the live checklist
      surface is lines 4/8/9; the cost-band rows are dormant until a snapshot
      lands — consistent with the absolute-rate-deferral closed-world reasoning.
  - id: O6
    category: specification quality
    severity: low
    claim: "The scenario set grew to eleven Gherkin blocks, several of which (10.4b's cost-present abort, 10.6b's re-run-into-a-cost-present-record) require fixtures pinning a cost-present world the command's real grounding never produces today, and the synthetic cost-present fixtures must hand-author the very split-tier bands the deferred absolute-rate check would validate — yet the flat FR-17 list does not distinguish runnable-today scenarios from synthetic-future ones."
    evidence: "§10.4b 'Given a returned cost-present record'; §10.6b 'the re-validated record can now carry cost_usd'; §9 'pins … an empty or populated observability/costs/'; FR-17 lists all scenarios flat with no runnable-today vs synthetic-fixture split."
    disposition: accepted
    disposition_rationale: >
      Accepted as a noted observation (cheap one-line flag welcome): mark which
      scenarios are runnable-today (empty-snapshot, REFUSED) vs synthetic-
      cost-present-fixture (10.4b, 10.6b), and that the synthetic fixtures
      hand-author bands the deferred absolute-rate check would validate.
---

## O1 — specification quality — medium

### Claim

The round-1 O2 disposition asked for the fix-in-place boundary to be defined
*per checklist line*. The revision delivers the table in §7.1a, and for eight of
nine lines it is unambiguous (one FIX, the rest ABORT). But line 7 (Time split)
carries a split classification — "ABORT if a value is missing/mistyped
(authoring); **fix-in-place only a pure structural mistyping with no value
change**" — and that fixable sub-case has no constructible instance. The two
time fields are a numeric range and a qualitative string; any mistyping of
either changes a value or is indistinguishable from a missing field. The line
therefore re-opens, on a single row, the exact "what counts as structural-only"
ambiguity the table was added to close.

### Evidence

> §7.1a table, row 7: "**ABORT** if a value is missing/mistyped (authoring);
> fix-in-place only a pure structural mistyping with no value change"

The format reference defines the shapes that make a no-value-change mistyping
unconstructible: `agent_compute_time` a `{ low, high }` range, `human_gate_time`
a qualitative caveat string (estimate-record-format.md:364-366). A YAML shape-fix
to `agent_compute_time` touches its bounds (a derived number); a shape-fix to
`human_gate_time` either changes the caveat text (authoring) or is a no-op. There
is no third case.

### Why this matters

O2 was accepted specifically to stop two implementers drawing the structural/
derived line differently. Eight rows now agree; row 7 leaves one implementer free
to "fix" a time-field shape and another to abort. The fix is cheap — either
collapse row 7 to a clean ABORT (consistent with rows 1-6), or supply the one
worked instance of a no-value-change time mistyping that justifies keeping the
FIX half. As written, the table relocated the ambiguity rather than removing it
on this row.

## O2 — implementation — low

### Claim

The O1-fix (a change-list of what the checkpoint altered) and the O2-fix (abort
on every derived-value defect) interact so the change-list's content is bounded
to a single possibility: a deleted stray `recommendation`/`verdict`/`proceed`
field. The spec itself concedes line 8 is "the only routinely-fixed line." So the
elaborate change-list machinery (FR-6a, §5 step 5, scenario 10.4a) discloses
either nothing ("no checkpoint changes") or one deletion. The two accepted fixes
are individually sound but together deliver far less transparency than their
prose frames.

### Evidence

> §7.1a: "In practice the only routinely-fixed line is **#8 (delete a stray
> verdict field)** — a pure removal that authors nothing. Every line that would
> require the checkpoint to *supply* a derived value aborts."

> FR-6a: "When the checkpoint changes anything at step 4, the review summary
> surfaces an explicit change-list … when it changes nothing, the summary says
> so."

The union of fixable deviations across the nine lines is {line 8 deletions}
(line 7's FIX half being unconstructible per O1).

### Why this matters

Not a correctness defect — the composite is honest — but it signals the two fixes
may be over-engineered relative to their yield. A reviewer disposing O1/O2 should
know that "transparent agent-vs-command composite" almost always means "the
agent's record verbatim, or that record minus one forbidden field." If that is
acceptable, the change-list could be a one-line note rather than a diff apparatus.
Low because nothing is wrong; it flags the mechanism's cost may exceed the bounded
fix-set's value.

## O3 — risk — medium

### Claim

`cost-estimates/` is a new top-level directory, and the spec explicitly declines
to mandate gitignoring it ("they are inspectable artefacts"). So S3's default
behaviour commits prospective estimate records into version control. An estimate
is a regenerable guess whose `target` field may point at an unmerged spec, a slice
that is later renamed, or a task description that changes — yet the spec gives no
staleness, rotation, or invalidation story for the committed corpus, and treats
the gitignore question as a deferred docs-note rather than a decision.

### Evidence

> §6.1: "the spec does **not** mandate gitignoring them (they are inspectable
> artefacts), but flags it as a docs-reference note."

The repo's existing convention for the directly-analogous artefact points the
other way: `.gitignore` excludes the `/diagnose` output "because it is derived,
regenerable … Never committed." A `/cost-estimate` record is equally derived and
regenerable, but S3 leaves it committed-by-default and undecided.

### Why this matters

Committing estimates creates a growing body of stale guesses that reference moving
targets, with no rule for when a committed estimate becomes misleading (a spec is
exactly the kind of target that mutates between estimate and merge). The spec
already invokes O5/O7 reasoning that "predictions are not facts" to keep estimates
out of `observability/`; the same reasoning argues for treating committed
predictions as derived output (gitignored, regenerable) by default, consistent
with `/diagnose`. Leaving it to a downstream "docs-reference note" defers a
decision that shapes what the command does on its very first run.

## O4 — scope — medium

### Claim

The O6-fix replaced a soft "most naturally S6" hand-off with a "blocking
acceptance criterion." But the criterion is keyed on an event no scheduled slice
is committed to produce. It fires on "the first slice that produces a cost-present
record," which requires a usable `observability/costs/` snapshot to first exist —
and *landing a snapshot* is not a deliverable of any slice in the roadmap. S6 is
the calibration loop, which consumes a snapshot; nothing in S4-S6 is described as
the slice that first *captures* one. So the trigger may never fire, and the
absolute-rate check can stay orphaned for the same reason O6 named.

### Evidence

> §7.2: "the absolute-rate check becomes BLOCKING on — and is a required
> deliverable of — the **first slice that produces a cost-present estimate
> record** … On today's roadmap that is **S6 (#373)**."

But the same section establishes the precondition is unmet and unscheduled:
`observability/costs/` is empty so every record today is cost-omitted, and S6 is
"the slice that closes the actuals loop" — a *consumer* of actuals, not the slice
that captures the first snapshot. The criterion lives in a re-filed issue's body,
not in a slicing record, a CI gate, or a contract any pipeline step checks.

### Why this matters

O6 was accepted to convert a hand-off into a committed home with a falsifiable
trigger. The revision's trigger is falsifiable in principle but unreachable in
practice on the stated roadmap: if no slice captures the first snapshot, no slice
"produces the first cost-present record," and the blocking criterion never binds.
The spec should either name the slice that captures the first snapshot (making the
trigger reachable) or bind the check to a slice number directly, rather than to a
precondition the roadmap does not schedule.

## O5 — specification quality — low

### Claim

Five of the nine per-checklist-line classifications (lines 1, 2, 3, and the cost
halves of 5 and 6) key on `cost_usd` / per-stage bands that no record the command
can emit today carries — by the spec's own closed-world argument. So the §7.1a
table devotes five rows to ABORT paths unreachable until a snapshot lands, while
the only abort paths the command can actually hit today are lines 4 (missing
disclosure section) and 9 (verdict prose), plus the line-8 fix. The table reads as
complete, but most of its rows describe a world §7.2 says does not yet exist.

### Evidence

> §7.2: "every record S3 writes today is **cost-omitted** — it carries no
> `cost_usd` and no per-stage `cost_usd` band."

estimate-record-format.md:320-363: lines 2, 3, and the cost axis of 5-6 "pass
vacuously" / are "both absent" on a cost-omitted record, so their ABORT branches
never reach on today's producible records.

### Why this matters

This is the same closed-world condition O4/§7.2 use to defer the absolute-rate
check — applied consistently, the cost-band abort rows are equally untestable
today. The spec presents a nine-row table as uniformly live when two-thirds of it
is dormant; a reviewer adjudicating checkpoint testability should know the live
surface against today's records is lines 4, 8, 9 only. Low because the rows are
correct once cost-present records exist.

## O6 — specification quality — low

### Claim

The scenario set grew to eleven Gherkin blocks — one per accepted objection plus
the originals — but several (10.4b's cost-present abort, 10.6b's re-run yielding a
cost-present record) require fixtures pinning a cost-present world the command's
real grounding never produces today. The synthetic cost-present fixtures must
hand-author the very split-tier bands the absolute-rate check (deferred per O4)
would otherwise validate. The flat FR-17 list does not distinguish runnable-today
scenarios from synthetic-future ones.

### Evidence

> §10.4b "Given a returned **cost-present** record"; §10.6b "the re-validated
> record **can now carry cost_usd**"; §9 "pins … an **empty or populated**
> observability/costs/"; FR-17 lists all scenarios flat, "graded by the
> deterministic oracles of §9," with no runnable-today vs synthetic split.

### Why this matters

The scenarios are individually sound and the fixture-driven approach is right. The
gap is presentational-but-load-bearing: an implementer reading FR-17 cannot tell
that 10.4b/10.6b will never be exercised by a real grounding read and exist only
to pin future behaviour against a synthetic snapshot — and that those synthetic
fixtures encode hand-authored cost bands the spec elsewhere declines to check.
Flagging which scenarios are synthetic-future would let a reviewer see the
cost-present test surface rests on hand-authored bands, not a grounded emit. Low
because the scenarios are honest; the omission is which ones are reachable.

## Explicitly not objecting to

- **O1 round-1 (checkpoint silently edits before disposition) — confirmed
  resolved.** §5 step 5, §7.1a, and FR-6a require the review summary to surface an
  explicit change-list of exactly what the checkpoint altered, and to state "no
  checkpoint changes" otherwise; the human disposes over a transparent composite.
  (My O2 notes the change-list is near-trivial, but the disclosure obligation is
  fully met.)
- **O2 round-1 (unbounded "fix in place") — confirmed resolved, save one row.**
  §7.1a draws the structural-only vs derived-value boundary per checklist line and
  removes the inverted "insert a missing cost_basis" example, replacing it with an
  explicit ABORT. Eight of nine rows are unambiguous; only line 7 (my O1) retains a
  residual.
- **O3 round-1 (edit path silently reverts) — confirmed resolved.** §7.1b and
  FR-6b put the post-edit checkpoint into validate-and-report mode: "a human edit
  is never reverted without the human seeing and re-confirming it."
- **O4 round-1 (asserted `--kind` silently buys a higher ceiling) — confirmed
  resolved.** §4.1, §5 step 5, FR-8a, and scenario 10.6a flag a human-asserted
  kind as asserted-not-inferred with a raised, basis-free ceiling and ask the human
  to re-confirm.
- **O5 round-1 (estimates under `observability/`) — confirmed resolved.** §6.1
  moves the default home to top-level `cost-estimates/` with a documented read of
  every current `observability/` consumer showing none globs the tree wholesale.
  (My O3 is a *new* concern about committing that directory, distinct from the
  resolved location.)
- **O7 round-1 (unguarded trailing-slash sentinel residual) — confirmed
  resolved.** §7.3, FR-14a, scenario 10.5 record in the spec that S3 ships the
  first records carrying the unguarded sentinel.
- **O8 round-1 (re-run re-reading the snapshot) — confirmed resolved.** §5 step 6,
  FR-8b, scenario 10.6b state re-run is a full fresh dispatch re-reading grounding
  incl. the now-populated `observability/costs/`.
- **O9 round-1 (`--out` collision) — confirmed resolved.** §6.2, FR-11a, scenario
  10.6c apply same-day disambiguation under `--out`; never silently overwrites.
- **The premise and pure-consumer discipline** — unchanged and still sound; §3
  argues the standalone surface well, §2.2/§2.3 refuse to mutate the S1 format or
  S2 agent from a consumer seat.
