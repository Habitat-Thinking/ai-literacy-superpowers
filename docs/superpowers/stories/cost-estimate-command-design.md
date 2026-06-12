---
spec: docs/superpowers/specs/2026-06-11-cost-estimate-command-design.md
date: 2026-06-12
mode: spec
cartographer_model: claude-opus-4-8[1m]
stories:
  - id: 1
    lens: [patterns, consequences]
    title: Full vocabulary closes the /diagnose watch item
    disposition: promoted
    disposition_rationale: >
      Promoted. S3 shipped the full accept/edit/re-run/abort vocabulary, so the
      /diagnose accept/abort narrowing did NOT recur — the AGENTS.md agent-emit
      decision's watch item is marked RESOLVED (the divergence was a one-off, not
      a convention). A future reader should not re-litigate /diagnose's two-verb
      form as the norm.
  - id: 2
    lens: [patterns, forces]
    title: Checkpoint as a second derived-judgment discloser
    disposition: accepted
    disposition_rationale: >
      Accepted. The checkpoint as a second derived-judgment discloser
      (structural-only fix, change-list, abort-on-author; edit = validate-and-
      report) is a sound extension of disclosure-of-derived-judgment to a second
      mutating actor in the same record.
  - id: 3
    lens: [forces, alternatives]
    title: Predictions exiled from the actuals tree
    disposition: accepted
    disposition_rationale: >
      Accepted. Filing predictions outside observability/ (the actuals tree)
      removes the estimate-as-fact conflation at the source rather than via a
      guard marker every future scan must remember.
  - id: 4
    lens: [defaults, alternatives]
    title: Estimates inherit the /diagnose gitignore default
    disposition: accepted
    disposition_rationale: >
      Accepted. Estimates gitignored by default, inheriting the /diagnose
      derived-output convention; the staleness concern is moot once the corpus is
      regenerable rather than committed.
  - id: 5
    lens: [forces, alternatives]
    title: One target swallows the --near hint
    disposition: accepted
    disposition_rationale: >
      Accepted. --near dropped for --kind to honour the agent's one-target
      contract rather than splice a composite input from the consumer seat; if
      the nearby-grounding use case resurfaces it is an agent-contract change.
  - id: 6
    lens: [patterns, forces]
    title: Asserted --kind buys disclosure, not silence
    disposition: accepted
    disposition_rationale: >
      Accepted. An asserted --kind is flagged in the review summary
      (asserted-not-inferred, raised ceiling, no basis) — disclosure over a silent
      ceiling-raise; the command discloses but never re-classifies (pure consumer).
  - id: 7
    lens: [patterns, consequences]
    title: A deferred check bound to a deliverable, not a wish
    disposition: promoted
    disposition_rationale: >
      Promoted. Sharpens the AGENTS.md re-file decision: re-filing a hand-off must
      bind to a SCHEDULED deliverable (a slice that produces the triggering event),
      not merely "filed somewhere" keyed on an unscheduled trigger —
      re-file-to-an-unbound-issue is itself a buck-pass. Second worked instance
      (after #350). Folded into the existing re-file ARCH_DECISION.
  - id: 8
    lens: [forces, consequences]
    title: Honouring a special-case without enforcing it
    disposition: accepted
    disposition_rationale: >
      Accepted. Honouring the trailing-slash special-case only where the command
      consumes the field (not adding a checklist line) correctly applies
      own-the-contract; the residual is recorded in the spec for other consumers.
  - id: 9
    lens: [coherence]
    title: Pure-consumer discipline as the spine
    disposition: accepted
    disposition_rationale: >
      Accepted. The pure-consumer-discipline spine is the coherent organising
      principle of the spec; recorded so a future change to S3 has a spine to be
      evaluated against ("does this make the command mutate or re-derive a
      contract it consumes?").
---

## Story #1 — Full vocabulary closes the /diagnose watch item

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimate-command-design.md` (§5 step 6, §1)
**Lens:** patterns / consequences
**Refs:** —

**Context.** S3 is a command-surface dispatcher in the
agent-emit/dispatcher-persist/human-disposes architecture — the first since
`/diagnose`. The architecture's named disposition vocabulary is
accept/edit/re-run/abort. `/diagnose` shipped only accept/abort, and AGENTS.md
logged that narrowing as an explicit watch item: "if that narrowing recurs on
the next command spec, the divergence may warrant its own sub-rule." S3 is that
next command spec.

**Forces.** Minimalism (two verbs is a smaller surface to specify, test, and
explain) versus fidelity to the named architecture (the four-verb vocabulary is
what makes the human a genuine author rather than a yes/no gate). `/diagnose`
resolved toward minimalism and bought a watch item. S3 had the standing option
to inherit the narrowed precedent and call it consistency.

**Options not taken.**
- *Inherit /diagnose's accept/abort* — treat the most recent precedent as the
  living convention and narrow with it. This is the path the watch item was
  written to detect.
- *A different reduced set* (accept/re-run/abort, dropping edit) — plausible if
  the record were considered too structured to hand-edit safely.
- *Defer the vocabulary question to S4's orchestrator fold-in* — let the
  standalone surface ship narrow and widen later.

**Choice as written.** S3 ships the full accept/edit/re-run/abort vocabulary and
says so against the watch item by name (§1, §5): it "deliberately ships the full
accept/edit/re-run/abort vocabulary rather than the narrowed accept/abort
`/diagnose` shipped." This is a decision that *closes* a watch item rather than
opening one — the divergence does not recur, so the sub-rule the watch item
contemplated is not provoked.

**Consequences.** Each verb carries a downstream obligation the spec then has to
honour: `edit` forces the validate-and-report reconciliation (Story #2), and
`re-run` forces the fresh-grounding semantics that make add-a-snapshot-then-re-run
work. The full vocabulary is not free — it is what makes those two seams
load-bearing. The narrowed precedent could have ducked both. Choosing the full
set means S3 owns the harder edit/re-run design rather than the simpler gate.

**Pattern.** A worked instance of the agent-emit/dispatcher-persist/human-disposes
architecture (AGENTS.md), specifically resolving toward the canonical vocabulary
where the immediately prior instance diverged. The live question this instance
answers is not "is this a pattern" but "does the pattern hold its full shape
under the pull of the most recent narrower precedent."

**Notes.** Promotion candidate: an explicit AGENTS.md note that the watch item is
*resolved* (S3 did not narrow) would stop a future reader re-litigating whether
`/diagnose`'s two-verb form is the convention.

## Story #2 — Checkpoint as a second derived-judgment discloser

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimate-command-design.md` (§7.1a, §7.1b, §5 step 5)
**Lens:** patterns / forces
**Refs:** O1, O2

**Context.** The disclosure-of-derived-judgment contract was written for the
*agent* that derives a value a human once supplied. S3 introduces a second actor
into the same record: the Output Validation Checkpoint, run by the command, may
alter the agent's emitted record before the human disposes. The spec draws a
boundary — the checkpoint may fix structural-only deviations in place but never
authors a derived value, and it surfaces a change-list of exactly what it altered.

**Forces.** Convenience of a self-healing checkpoint (silently fix the record so
the human sees a clean draft) versus the integrity of what the human disposes
over (the `accept` must ratify a composite whose seams are visible). A checkpoint
that silently completes the agent's record would manufacture exactly the
correctness risk the four-part disclosure exists to contain — only now a *third*
party (the command) is the one over-reaching, invisibly. The spec resolves toward
transparency: structural-only fixes, recorded; everything that would touch a
derived value aborts.

**Options not taken.**
- *Self-healing checkpoint* — complete missing `cost_basis`, clamp inverted
  ranges, widen collapsed bands. The spec explicitly removed its own earlier
  "insert a missing `cost_basis`" example as the inversion of the rule.
- *No fix at all — abort on every deviation* — simpler and unimpeachable, but
  loses the cheap structural recovery (a stray verdict field) that costs nothing
  to the human's judgment.
- *Fix silently, no change-list* — the path that would have re-created the
  pre-diaboli /diagnose ordering defect in a new disguise.

**Choice as written.** The checkpoint is the disclosure contract applied to a
second actor: it fixes only what authors nothing (routinely just deleting a
forbidden field), records every change in the review summary, and aborts rather
than author on any derived-value defect. The `edit` path inverts the rule by
authorship (§7.1b): once the human edits, the content is theirs, so the
post-edit run is validate-and-report — a human edit is never silently reverted.

**Consequences.** As the diaboli noted (O2), the structural-only boundary
collapses the change-list's reachable content to essentially one case — a deleted
verdict field — so the elaborate diff apparatus discloses "nothing" or "one
deletion" almost always. That is a recorded yield-versus-machinery tension, not a
correctness defect; the disclosure obligation is honest even where its yield is
thin. The forward consequence the cartographer adds: once cost-present records
exist, the abort branches (currently dormant) become the dominant behaviour, and
the change-list stays narrow precisely because the spec chose abort over author.

**Pattern.** The disclosure-of-derived-judgment contract (AGENTS.md), extended
from the deriving agent to a *second mutating actor* in the same artefact
lifecycle. This is a genuinely new surface for the contract — prior instances
disclosed an agent's own derivation; this discloses one actor's edits to
another's derivation.

**Notes.** O1 (round 2) sharpened the boundary by collapsing the time-split row
to a clean abort, eliminating the one row where two implementers could have drawn
structural-vs-derived differently. The boundary is now uniform across all nine
checklist lines save the single fix line.

## Story #3 — Predictions exiled from the actuals tree

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimate-command-design.md` (§6.1)
**Lens:** forces / alternatives
**Refs:** —

**Context.** The earlier draft filed estimates under `observability/estimates/`,
a sibling of `observability/costs/`, "for symmetry" with `/cost-capture`. S3
moves the default home to a new top-level `cost-estimates/` directory,
deliberately outside `observability/`, on the ground that `observability/` is the
telemetry/actuals tree and an estimate is a forward-looking guess.

**Forces.** Discoverable symmetry (a reader who finds `/cost-capture`'s output
should find `/cost-estimate`'s next to it) versus data-kind integrity (a
prediction filed under the actuals root invites a future scan to read a guess as
an observed fact). The spec resolves the tension by *naming* rather than
*co-location*: `observability/costs/` (actuals) and `cost-estimates/`
(predictions) read as siblings-by-name without sharing a scanned root.

**Options not taken.**
- *`observability/estimates/` for symmetry* — the rejected earlier draft;
  co-locates two different data kinds under one tree.
- *`observability/estimates/` plus a guard marker* — keep the symmetry, add a
  sentinel every tree-wide scan must honour. Rejected because the guarantee then
  depends on every *future* consumer remembering the marker — a standing
  obligation a new scan can silently miss.
- *Bury it under an existing non-telemetry tree* (e.g. `docs/`) — loses the
  retrospective/prospective pairing entirely.

**Choice as written.** Move the home outside `observability/` and remove the
conflation at the source: predictions are not telemetry, so they do not live
under the telemetry root, and no `observability/` scan can misread an estimate
because no estimate is under `observability/` at all. The spec backs this with a
read of every current `observability/` consumer, confirming none globs the tree
wholesale today — then argues that "no consumer mis-reads it today" is the weaker
guarantee, and chooses the structural fix over the temporal one.

**Consequences.** The discoverable pair now rests on a naming convention
(`costs/` ↔ `cost-estimates/`) rather than directory adjacency, so a future
reorganisation of `observability/` will not automatically carry the estimate home
with it. The capability also acquires a *second* new top-level directory in the
repo root, a small cost to root-level tidiness accepted in exchange for
kind-integrity.

**Pattern.** —

## Story #4 — Estimates inherit the /diagnose gitignore default

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimate-command-design.md` (§6.1, FR-10a)
**Lens:** defaults / alternatives
**Refs:** O2, #3

**Context.** Having moved the output home out of `observability/` (Story #3), S3
faces a fresh question the earlier draft left as a deferred docs-note: is
`cost-estimates/` committed to version control? S3 decides it explicitly —
gitignored by default — and adds the `.gitignore` line in this slice.

**Forces.** Inspectability (a committed estimate is reviewable in a PR, citable,
durable) versus regenerability and staleness (an estimate's `target` may point at
an unmerged spec or a since-renamed slice, so a committed corpus drifts into a
body of stale guesses with no invalidation rule). The default chosen resolves
toward regenerability.

**Options not taken.**
- *Committed by default* — the earlier draft's de-facto posture ("inspectable
  artefacts"), which the diaboli flagged as committing a growing corpus of stale
  guesses with no staleness or rotation story.
- *Committed with a rotation/TTL policy* — keep the corpus but bound its
  staleness; more machinery than a regenerable artefact warrants.
- *Leave it a docs-note* — the deferred non-decision the spec explicitly
  replaces with a decision.

**Choice as written.** The default's source is named, which is the cheapest
cognitive-debt payment available: the repo *already* gitignores the directly
analogous `/diagnose` output (`diagnostic-legibility/output/`) as "derived,
regenerable artefacts … Never committed," and an estimate is the same artefact
kind. S3 does not invent a policy; it inherits an established one and says so.
The staleness concern is thereby moot — regenerable-on-demand, not committed.

**Consequences.** A human who wants a specific estimate retained must commit it
explicitly or write it elsewhere via `--out` — retention becomes an opt-in act
rather than the default. This forecloses any future workflow that assumes
estimates are present in a fresh checkout (CI that reads the estimate corpus, a
reviewer browsing committed estimates), but no such workflow exists today and S4
is the slice that would introduce one.

**Pattern.** An inherited default whose source is a sibling convention rather
than a framework — the highest-value kind to name, because the source
(`/diagnose`'s gitignore rationale) is non-obvious to a reader who has not met
that entry. Builds on the home-relocation of #3: the gitignore default only makes
sense once predictions are understood as derived/regenerable rather than as
actuals.

## Story #5 — One target swallows the --near hint

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimate-command-design.md` (§4.1, §12)
**Lens:** forces / alternatives
**Refs:** —

**Context.** The slicing record sketched the signature as
`/cost-estimate "<task>" [--near <path>] [--out <dir>]` — a primary target plus a
"nearby grounding hint." The merged S2 agent accepts exactly one target per
dispatch, with no target-plus-neighbour shape. S3 drops `--near` and adds
`--kind` in its place.

**Forces.** Fidelity to the slice sketch (the author imagined a nearby-context
affordance) versus fidelity to the merged agent's contract (one target, no
second-target slot). The command is a pure consumer of the agent; honouring the
agent's contract means the signature cannot offer an input shape the agent cannot
consume. The spec resolves toward the contract and treats the sketch as
provisional.

**Options not taken.**
- *Keep `--near` and have the command splice the hint into the target* — would
  make the command author a composite input, mutating the agent's
  one-target contract from the consumer seat (the very thing §2.3 forbids).
- *Keep `--near` and pass it as a second dispatch* — two dispatches per
  invocation, a different cost and grounding model the agent was not designed for.
- *Keep `--near` as a no-op* — honour the sketch's syntax while ignoring it; a
  signature that lies about what it does.

**Choice as written.** `--near` is dropped; `--kind` replaces it as the
disambiguation affordance and maps cleanly onto the agent's explicit-kind rule.
The reconciliation is explicit (§12): the sketch's two-input shape is rejected
because the agent accepts one target, and the new flag is chosen *because* it
lands on a rule the agent already has.

**Consequences.** The "estimate this task, grounded in that nearby slice"
use case the sketch implied has no home in S3 — a human who wants that must
choose a single richer target instead. Whether that use case was real or an
artefact of the sketch is now a closed question; if it resurfaces, it is a new
agent-contract change owned by the agent's slice, not a command flag.

**Pattern.** —

## Story #6 — Asserted --kind buys disclosure, not silence

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimate-command-design.md` (§4.1, §5 step 5)
**Lens:** patterns / forces
**Refs:** O1, #2

**Context.** An explicit `--kind` does two things: it suppresses the agent's
inference-basis disclosure line (the human asserted the kind, so the agent infers
nothing) *and* it raises the tokens/time confidence ceiling
(`task-text`→`low` … `spec`→`high`). A human who asserts `--kind spec` on a file
that is really a slice fragment thereby obtains a high-ceiling estimate with no
disclosed inference basis. S3 makes the review summary flag the asserted kind as
asserted-not-inferred.

**Forces.** Ergonomics of a single disambiguation flag (let the human override
the agent's classification cheaply) versus the integrity of the confidence
ceiling (an override that silently raises the ceiling is exactly the silent
over-claim the inference-disclosure contract exists to prevent). The flag's two
effects pull apart: one is benign (telling the agent the kind), one is dangerous
(buying a higher ceiling with no basis). The spec keeps the flag and neutralises
the danger by disclosure rather than by removing the ceiling-raise.

**Options not taken.**
- *Trust the flag silently* — the pre-diaboli posture; an asserted kind buys the
  ceiling with no flag, the silent over-claim.
- *Let `--kind` set the kind but not raise the ceiling* — keep the
  classification override, deny it the confidence benefit. Rejected implicitly:
  the ceiling is a property of the kind, so asserting the kind asserts the
  ceiling.
- *Have the command re-classify to check the human* — would make the command
  re-derive the agent's judgment, breaking the pure-consumer split (Story #9).

**Choice as written.** The command is a pure consumer of the agent's
classification (it does not re-classify), but it *owns the review summary*, so it
carries the disclosure the suppressed inference-basis line would otherwise have
carried: a prominent asserted-not-inferred flag stating the raised, basis-free
ceiling and asking the human to re-confirm the ceiling they raised. The human
disposes over a visible assertion, not a silent one.

**Pattern.** The disclosure-of-derived-judgment contract again — here applied not
to a derived value but to a *human-supplied override that suppresses* the agent's
own derivation. The command becomes the discloser-of-last-resort precisely
because the override silenced the agent's discloser. Same contract as #2, a
distinct surface: #2 discloses a second actor's *edits*; this discloses a human's
*assertion* standing in for the agent's inference.

## Story #7 — A deferred check bound to a deliverable, not a wish

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimate-command-design.md` (§7.2, FR-15)
**Lens:** patterns / consequences
**Refs:** O1

**Context.** The #377 format reference named "S3's Output Validation Checkpoint"
as the natural home for the snapshot-grounded absolute-rate falsification check.
S3 declines to build it (dead code against today's cost-omitted-only records) but
does not leave the concern implicit — it re-files the check as a standalone issue
and binds it to S6/#373 as a blocking required deliverable, extending S6 to also
own first-snapshot capture so the trigger is reachable.

**Forces.** YAGNI against a closed-world record set (the check is meaningless
until a cost-present record exists, which today's empty `observability/costs/`
cannot produce) versus the deferred-concern-accretion debt that accrues when a
named home declines an inherited hand-off and the concern falls through the gap.
The spec resolves both: defer the build (YAGNI) *and* commit the home
(anti-orphaning).

**Options not taken.**
- *Build the absolute-rate check now* — dead code against every record the
  command can currently emit, and it duplicates the agent's rate-derivation
  surface the read-only/dispatcher split exists to keep in one place.
- *Re-file to a fresh unbound issue* — a tracking home with no slice committed to
  build it; the diaboli (round 2, O4) caught the earlier revision keying the
  trigger on "the first cost-present record," an event no scheduled slice
  produces — so the check could orphan exactly as feared.
- *Leave it in S3's "out of scope" note* — the implicit-in-a-closed-slice path
  the re-file rule explicitly forbids.

**Choice as written.** Two acts, not one: re-file with its own lifecycle, *and*
bind to a concrete slice number. Critically, the binding is made reachable by
extending S6's deliverables to include capturing the first `observability/costs/`
snapshot — so S6 is the slice under which the first falsifiable cost-present
record comes into existence, and the check travels with snapshot-capture if the
roadmap reassigns it. The trigger is a named slice, not an unscheduled event.

**Consequences.** S6's scope grew: it now owns first-snapshot capture *and* the
calibration loop *and* the absolute-rate check — three deliverables bound
together because the check needs the snapshot the loop needs. If S6 later proves
too large, the snapshot-capture deliverable is the natural split point, and the
check follows it. The reachability fix trades a larger S6 for a trigger that
actually fires.

**Pattern.** The re-file-do-not-leave-implicit decision (AGENTS.md "natural-home
hand-off does not bind slice N+1"), with the round-2 sharpening that re-filing to
an *unbound* issue is itself a buck-pass — the home must be a deliverable the
roadmap schedules, not a precondition it never causes. This is a second worked
instance of that decision (after the #350 re-file), and it tightens the rule:
"re-file with its own lifecycle" now means "bound to a slice that produces the
triggering event," not merely "filed somewhere."

**Notes.** Promotion candidate: the sharpening (re-file must bind to a
*scheduled* deliverable, not an unscheduled trigger) is a refinement of the
existing AGENTS.md decision worth folding back into it.

## Story #8 — Honouring a special-case without enforcing it

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimate-command-design.md` (§7.3, FR-14, FR-14a)
**Lens:** forces / consequences
**Refs:** #7

**Context.** The #377 reference adds an advisory, unenforced consumer
special-case: a `cost-snapshot` grounding entry whose `path` ends in `/` is the
directory sentinel for looked-and-found-nothing and must not be counted as a real
grounding. No validation-checklist line keys on `grounding_sources[].path` shape.
S3 neither adds such a line nor ignores the special-case — it honours the test in
the one place the command itself consumes the field (the review summary).

**Forces.** Completeness (add the missing checklist line so every record is
machine-guarded) versus the own-the-contract discipline (a consumer that adds a
validation rule is mutating the format it consumes). The spec resolves toward the
discipline: it declines to add the line because that is the format-owning slice's
job, while refusing to be the consumer that itself miscounts.

**Options not taken.**
- *Add the checklist line in S3* — guards every record, but mutates the merged
  format from a consumer seat (forbidden by §2.3 / the consumer-never-mutates
  decision).
- *Ignore the special-case entirely* — the command's own summary would then
  report a directory sentinel as a real snapshot grounding, making the command
  the first consumer to fall into the trap it knows about.
- *Add the line and file it as a separate format-owning slice in the same PR* —
  conflates two slices' ceremony; the format change deserves its own adversarial
  pass.

**Choice as written.** S3 honours the special-case only at its own consumption
point — reporting a trailing-slash entry as "no snapshot — directory inspected,
no snapshot found," not a grounding — and records the residual (FR-14a): S3 ships
the *first* persisted estimate records, every cost-omitted one carrying the
unguarded sentinel, so any other consumer that omits the same trailing-slash test
silently miscounts.

**Consequences.** The protection is per-consumer and easy to omit: S4's
orchestrator fold-in and any future aggregator inherit a named failure rather
than a machine-enforced guard. The spec converts what would have been later
cartographer archaeology into a recorded residual in the spec itself — the
honest move, but one that accepts a standing per-consumer obligation until the
format-owning slice adds the line. The choice is coherent only because S3 holds
the pure-consumer line elsewhere too (Story #9); honouring-where-I-consume and
declining-to-mutate are the same discipline applied to one field.

**Pattern.** The consumer-never-mutates-the-contract decision (AGENTS.md), here
producing the unusual posture of *honouring an obligation the consumer refuses to
encode as a rule*. Pairs with #7: both are the own-the-contract discipline
deciding what S3 may and may not do to a contract it consumes — #7 about a
deferred check's home, this about an unenforced special-case.

## Story #9 — Pure-consumer discipline as the spine

**Source:** `docs/superpowers/specs/2026-06-11-cost-estimate-command-design.md` (§2.3, §4.2, §7, §7.2, §7.3)
**Lens:** coherence
**Refs:** #5, #6, #7, #8

**Context.** S3 makes a dozen distinct decisions — signature, output home,
gitignore, checkpoint boundary, asserted-kind disclosure, deferred-check homing,
trailing-slash handling. Read individually they could look like a bag of
independent choices. Read together they resolve along a single axis: S3 is a pure
consumer of the S1 format and the S2 agent, and every contested decision is
settled by asking what a consumer may and may not do.

**Forces.** The recurring tension across the whole spec is consumer-reach versus
contract-integrity. Each decision faced a tempting move that would have widened
the command's reach by mutating or re-deriving a contract it consumes; each was
declined on the same ground. The coherence question is whether the load-bearing
reason behind the individual choices is one principle or several.

**Options not taken (as a whole-document posture).**
- *Treat the command as the capability's integration point* — let it splice a
  `--near` neighbour (#5), re-classify the kind to check the human (#6), add the
  missing checklist line (#8), build the absolute-rate check (#7). Each would have
  made the command richer and the contracts dirtier.
- *Settle each decision on its own local merits* — produce a coherent-looking
  command with no spine, where the next change has nothing to be evaluated
  against.

**Choice as written.** The spec is coherent under one reading: S3 is a pure
consumer, and the consumer-never-mutates-the-contract decision is the spine that
settles the otherwise-independent choices. `--near` dropped because the agent
takes one target (#5); the command never re-classifies, it only disambiguates and
discloses (#6); the absolute-rate check is re-filed to the format/snapshot-owning
slice rather than built here (#7); the trailing-slash line is honoured-where-
consumed but not added to the format (#8). The checkpoint fixes structural-only
and aborts on derived values for the same reason — it consumes the agent's
judgment, it does not author it (#2). Each decision is the same principle applied
to a different field.

**Consequences.** The coherence is real and is the spec's chief virtue: a future
change to S3 has a spine to be evaluated against ("does this make the command
mutate or re-derive a contract it consumes?"). The cost the spine accepts is that
several genuine improvements (the missing checklist line, the absolute-rate
check) live elsewhere or later, so the capability is only complete once the
owning slices act — S3 is deliberately not the place those land.

**Pattern.** "Quality without a name" (Alexander) applied to decisions: the spec
reads as one decision made repeatedly rather than many decisions made once. The
named pattern underneath is the consumer-never-mutates-the-contract architecture
(AGENTS.md), here operating as the organising principle of an entire spec rather
than a single rule invoked once.

**Notes.** This is the one coherence story in the set, emitted because the
pure-consumer spine is genuinely visible across five or more otherwise-independent
decisions — not because every set needs a sixth-lens entry.
