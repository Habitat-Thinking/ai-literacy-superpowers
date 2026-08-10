---
spec: docs/superpowers/specs/2026-08-10-cadence-sentinels-s3-mast-design.md
date: 2026-08-10
mode: spec
diaboli_model: claude-opus-5[1m]
objections:
  - id: O1
    category: scope
    severity: critical
    claim: "Section 4's mechanism requires changing the Coda's survey and the semantics of the Closed field — a contract S2 owns and shipped — yet S3 lists no S2 file, carves out no contract change, and declares 'No breaking changes'."
    evidence: "Spec 4: 'The Coda's survey reads these and includes them in the Closed field.' Section 5's file table lists five files, none of them agents/coda.agent.md, skills/coda/SKILL.md, or commands/coda.md. Section 8: 'No breaking changes.' Verified: the shipped commands/coda.md defines Closed as 'the filename of each record parked', and neither Coda file contains a single mention of a note."
    disposition: deferred
    disposition_rationale: "Dissolved for S3 by the O10 split and carried to #501, which owns the Coda contract change and must carve it explicitly as the third worked instance of the consumer-never-mutates rule. S3 as revised touches no S2 file and needs none."
  - id: O2
    category: implementation
    severity: critical
    claim: "lib/mast-notes.sh bundles mutation with read in one sourceable library that a role: sentinel agent must reach, re-opening precisely the channel S1 section 4.4 split two libraries to close."
    evidence: "Spec 5: 'lib/mast-notes.sh | the note store: append, read, consume, prune'. Spec 4: 'The Coda's survey reads these.' S1 4.4 and the shipped lib/session-registry-read.sh preamble: 'A single shared library exposing registry_prune to every sentinel would manufacture exactly that case — CI green while a role: sentinel agent deletes files.' sentinel-design generalised it: 'Split such libraries — a read surface a sentinel may source, a write surface only hooks and commands may.'"
    disposition: deferred
    disposition_rationale: "Dissolved for S3 by the split and carried to #501. S3 ships no note store and no library at all, so there is nothing for a sentinel to source."
  - id: O3
    category: implementation
    severity: high
    claim: "The once-per-session notice state is stored in the one file that consumption deletes and the pruner removes, so B2 and B3 are unenforceable on the most ordinary path — run /coda, then take one more turn."
    evidence: "Spec 4: 'The note file is removed once consumed, which is what bounds it.' Spec 4.1: 'The notes file also carries the once-per-session notice state.' S1 4.2 is the governing precedent and is never engaged: the Stop hook fires many times per session, and the note store would be its second destructive consumer."
    disposition: deferred
    disposition_rationale: "Dissolved for S3 by the split and carried to #501, with S1 section 4.2's precedent named in the issue: the Stop rail fires many times per session and a once-only guarantee must not live in a file another slice deletes."
  - id: O4
    category: specification quality
    severity: high
    claim: "The spec never says which budget keys generate boundary notices, and the 80% fraction's denominator is undefined for every key except hard_stop_hour — including the session-start value it measures from, whose source is an undeclared dependency on S1's registry."
    evidence: "Spec 3's table: 'at 80% of the way from session start to the line', with no key named; 3.1 works only hard_stop_hour. focus_blocks has two endpoints; sessions_per_day is a count flagged inferred; daily_cost_ceiling is unobservable. Section 1's Depends-on names only the pact file and pact-blocks.sh — not lib/session-registry-read.sh, the only thing that knows when a session started."
    disposition: deferred
    disposition_rationale: "Carried to #501 with the analysis intact — which keys notice, the fraction's endpoints per key, and the undeclared registry dependency. S3 as revised raises no notices, so the question does not arise here."
  - id: O5
    category: implementation
    severity: high
    claim: "The weather check's detection is inverted: authored_at changes only when Tune writes, so the hand-edit at 18:00 that the spec names as its target leaves it untouched and raises no note, while a calm morning tune followed by evening work raises one."
    evidence: "Spec 2.2 claims 'An authored_at of today, read at enforcement time, catches that and nothing else', where 'that' is 'raising hard_stop_hour at 18:00'. Spec 2.3 concedes the defeating channel: 'the file is the human's and they may edit it with any editor they like.' Spec 2.2 also states a calm Tuesday-morning tweak 'is exactly the deliberate authorship the rule wants' — which W1 pins as a note."
    disposition: accepted
    disposition_rationale: "The mechanism stays; the claim made for it does not. It detects a budget TUNED today, which is a true and useful thing to say — this pact has not been lived with yet. It does not detect weather-editing: authored_at moves only when Tune writes, so a hand-edit is invisible and always will be, and the reference page says so. The spec's 'catches that and nothing else' was exactly backwards and is removed."
  - id: O6
    category: specification quality
    severity: high
    claim: "Section 2.1's flag column does not match the behaviour its own prose describes: focus_blocks is flagged observed for a quantity as unobservable as sessions_per_day, and daily_cost_ceiling is flagged asked while the prose says nothing is asked."
    evidence: "Spec 2.1's table: 'focus_blocks | observed | wall clock' and 'daily_cost_ceiling | asked, or not observable'. That the clock sits inside a focus block is observed; that the human spent it working needs the day's history the same section says the registry lacks. For cost the prose says the Mast 'will report what the human declared and what it cannot check' — reporting a declared value back is not asking."
    disposition: accepted
    disposition_rationale: "focus_blocks drops to inferred — that the clock sits inside a block is observed, that the human spent it working needs the day's history the registry does not have. daily_cost_ceiling becomes 'not observable' rather than asked: reporting a declared value back is reading a pact, not asking a question, and an unearned asked flag would have invited an implementer to invent the question."
  - id: O7
    category: specification quality
    severity: high
    claim: "Tune's write is unspecified, so the only sanctioned authoring path can produce a file the shipped reader classifies as malformed, or on a second run append a duplicate heading _block_span silently ignores — and no acceptance scenario round-trips Tune's output through block_state."
    evidence: "Spec 2.3 gives three rules, none about the file's shape. pact-blocks.sh requires the literal mandatory clauses or the block reads malformed; _block_span exits at the second known heading, so an appended second Budgets block is silently unread. Section 7.4's A2-A6 assert asking, stamping, disclosure and no-agent-write; none asserts the result reads as declared."
    disposition: accepted
    disposition_rationale: "Tune's write is specified — rewrite the block in place, never append, always emit the mandatory clause and the reserved marker — and a scenario round-trips Tune's output through block_state, requiring declared for every block declared. Tune is the one component that PRODUCES the pact file, and its output is the input to every other sentinel."
  - id: O8
    category: risk
    severity: high
    claim: "The Mast's reached notice and the Reservoir Warden's advisory ride the same Stop rail, counsel the same act, and can fire on the same turn — falsifying the single-prompt mechanism the spec grounds its evidence claim on."
    evidence: "Spec 3: 'One recommendation, once... Ambient reminders are ignored and then resented.' Verified: reservoir-check.sh puts a declared early/lark chronotype into the suboptimal band at hour >= 20, so a hard_stop_hour of 20:00 for a lark lands both advisories on the same turn. cognitive-reservoir names the anti-pattern: 'A second nudge. One advisory, then silence.' Section 6 answers only 'No changes to the Reservoir Warden.'"
    disposition: deferred
    disposition_rationale: "Dissolved for S3 by the split and carried to #501. S3 raises no notices, so nothing collides with the warden. The issue carries the verified band: a declared lark enters the suboptimal band at hour 20, so a 20:00 hard stop would fire both advisories on one turn."
  - id: O9
    category: risk
    severity: high
    claim: "Section 4's destination is a committed, permanently archived, machine-aggregated artefact, so the override survives as exactly the cross-session record of working late that section 6 declares out of bounds."
    evidence: "Spec 4 routes the note to the reflection record; section 6 forbids 'a record of how often someone works late'. CLAUDE.md: REFLECTION_LOG.md is a generated, committed aggregate with a permanent archive under reflections/archive/<YYYY>.md. S2's O5 rejected a structurally identical record on the same grounds. Section 4.1 checks the carve-out's four conditions against the note file, which expires — not against the destination, which does not."
    disposition: deferred
    disposition_rationale: "Dissolved for S3 by the split and carried to #501. S3 records no override because it raises no notice to override. The issue carries the distinction the objection drew: the route is right, the destination's permanence is what needs deciding."
  - id: O10
    category: alternatives
    severity: medium
    claim: "Shipping Read and Tune alone, and deferring the boundary notices to a slice that can carve the Coda contract properly, is a materially smaller change that dissolves O1, O2 and O3 outright — and the spec does not weigh it."
    evidence: "Section 5's five files split cleanly: the agent/skill/command triple reads a file and touches nothing else; the hook and the note-store library are the entire source of this slice's cross-slice coupling, and section 1 attributes the S2 dependency solely to them. The epic already slices by mechanism — S1 gated nothing, S2 wired no trigger."
    disposition: accepted
    disposition_rationale: "The split. S3 becomes the gauge and the authoring ritual; boundary notices and the hard stop become #501. This dissolves O1, O2, O3, O8, O9 and O11 rather than mitigating them, and ships the higher-value half first: S1 shipped a template no path authors, so until Tune exists the pact file does not exist and every other sentinel is permanently in observe-only."
  - id: O11
    category: risk
    severity: medium
    claim: "Nothing states that ~/.claude/mast/ is created only for a human who declared a budget, repeating the silent-creation asymmetry sentinel-design records as the mistake that prompted the carve-out's fourth condition."
    evidence: "Section 7.2 B5 promises silence on stdout, not abstention on the filesystem. None of T1-T5 asserts the store is not created. sentinel-design: 'the registry was going to be created for every user silently. That asymmetry was backwards.' The fix is the self-gate reservoir-check.sh already uses: check the opt-in first, exit 0 before touching anything."
    disposition: deferred
    disposition_rationale: "Dissolved for S3 by the split and carried to #501. S3 creates no store. The issue carries the fix: self-gate on a declared block and exit 0 before touching the filesystem, as reservoir-check.sh does."
---

# Objection record — Cadence Sentinels S3: The Mast (spec mode)

Eleven objections: two critical, seven high, two medium.

The read half of this slice — agent, skill, command — is sound and carries
almost none of the risk. Nine of the eleven objections concentrate in the
notice/note half, and three of those (O1, O2, O3) are structural consequences
of one decision: that the Mast writes state which another slice must consume.

**Dispatcher verification note (2026-08-10).** Three claims were checked before
recording. O1: `agents/coda.agent.md` and `commands/coda.md` contain **zero**
occurrences of "note", and `Closed` is defined as "the filename of each record
parked" — the Coda knows nothing of this mechanism. O8: `reservoir-check.sh`
puts a declared `early`/`lark` chronotype into the suboptimal band at hour ≥ 20,
so a `hard_stop_hour: 20:00` for a lark fires both advisories on one turn. O5
was confirmed by reasoning over the spec's own text and needs no code: the stamp
moves only when Tune writes.

## O1 — scope — critical

§4's override mechanism does not exist unless the Coda changes. S2 shipped the
Coda's survey, its agent, its command, and the `Closed` field, and none of them
knows anything about a note store. S3 asserts the consumption as a fact about
the world rather than carving it as work it must do — while claiming no
breaking changes and listing no S2 file among its five.

Three consequences compound. The promoted ARCH_DECISION that a consumer never
mutates the contract it consumes is engaged and unhonoured — S2 §4.1 obeyed it
in the identical situation and called itself "the second worked instance"; S3
would be the third and slips it in. `consume` needs an actor, and the Coda agent
holds no `Write`, so removal must be done by the `/coda` command — a command S3
does not own, at a ritual step S3 does not name. And if the Coda is not changed
at all, the note is written, never read, and never removed: §4.1's boundedness
then rests entirely on the pruner, and the override reaches no record, leaving
constraint 6 satisfied only on paper.

## O2 — implementation — critical

`lib/mast-notes.sh` is described as one library exposing `append, read, consume,
prune`. Consume and prune are mutations, and §4 requires a `role: sentinel`
agent to read the notes. If it reaches them through this library, a sentinel has
a sourceable path to file deletion and `sentinel-integrity-check.sh` — which
reads only the frontmatter `tools:` list — stays green.

S1 spent a numbered section preventing exactly this, wrote the test (R9), and
promoted the rule into the category skill. Constraint 1 is not merely "sentinels
declare no Write"; it is "a library a sentinel may source must also be incapable
of mutation". S3's file table describes the single-library shape that rule
exists to forbid, and CI cannot catch it, because the breach is in a `.sh` file
rather than in frontmatter.

There is a coherent alternative reading — that the Coda reads the note files
directly with `Read`/`Glob` and never sources the library. If that is the
design it needs saying, because it makes the note file's line format a published
contract between two slices, which is a different problem with different
consequences.

## O3 — implementation — high

The at-most-once-per-session guarantee is stored in the file that consumption
deletes. Once `/coda` consumes the notes the notice state is gone, and any
further turn re-fires the reached notice.

The path is ordinary: `/coda`'s final step is "say what landed, what was parked,
and stop" — a statement, not a process termination. The session is still alive
and the Stop rail keeps firing.

S1 §4.2 is the governing precedent and the spec never engages with it. S1 made
correctness independent of firing frequency by renewing rather than deleting;
S3 does the opposite, making a once-only guarantee depend on a file another
slice removes. And the consequence is not cosmetic: §3's own evidence comment
says repeating a boundary prompt "would not make it work better, it would make
it work worse". A design whose once-only property fails on the path where the
human ran the recommended ritual and kept working converts the Mast into the
ambient reminder its evidence base says is counterproductive.

Secondary: §4.1 says the store is "lease-pruned otherwise" without saying what
the lease is measured from. If it is mtime under `stale_after_hours`, a long
quiet session loses its notice state the same way.

## O4 — specification quality — high

Two undefined quantities sit inside the notice trigger. The spec never says
which budget keys produce notices, and the 80% fraction's endpoints are defined
only for `hard_stop_hour`.

Read against the four declared keys: `hard_stop_hour` has a well-defined line
but no stated source for "session start"; `focus_blocks` is a range with two
endpoints and no rule for a session that began before or after it;
`sessions_per_day` is a count rather than a time, and is flagged `inferred`;
`daily_cost_ceiling` is unobservable and §6 does not say it never notices.

The undeclared dependency compounds it. The only thing on the machine that
knows when a session started is S1's registry, which §1, §5 and §8 all omit —
and S1 warned in terms that "no consumer may treat this count as an exact number
of open windows". A silent consumer is one that never read that sentence.

This is the clearest divergent-implementation risk in the spec: two implementers
ship different products and every B scenario passes for both.

## O5 — implementation — high

The weather check detects the wrong edits in both directions. `authored_at`
moves only when Tune writes, so a hand-edit of `hard_stop_hour` at 18:00 — the
exact failure §2.2 names as its target — leaves the stamp untouched and raises
no note. Meanwhile a deliberate morning `/mast tune` followed by an evening
session raises one, which §2.2 itself says is not the case worth flagging.

§2.3 concedes the channel that defeats it ("they may edit it with any editor
they like") and then asserts §2.2 covers the timing of such edits. It cannot:
by §2.3's own account only Tune moves the stamp.

The spec calls this "the clear-weather rule's actual mechanism". If it fires on
deliberate authorship and stays silent on weather-editing, the rule is not
implemented — a note appears on the honest path and never on the dishonest one,
and the human learns to read it as noise. W1 and W2 cannot surface this, because
they test the date comparison, which is correct; what is wrong is the claim made
for what the comparison detects.

## O6 — specification quality — high

§2.1's flag column, the section the spec calls "the whole job", does not survive
contact with the prose beside it.

`focus_blocks` carries `observed`. That the clock sits inside `09:00-12:00` is
observed; that the human *spent* that block working needs exactly the day's
history §2.1 correctly says the registry lacks — a sentence it applies only to
`sessions_per_day`.

`daily_cost_ceiling` carries `asked` for an act the same paragraph says does not
happen: reporting a declared ceiling back is reading a pact, not asking a
question. Constraint 3's `asked` means the human was asked and answered, as S1
and S2 both use it. An honesty flag that describes no act leaves the implementer
to invent one, and the plausible invention — asking what they spent today — is a
question about the person's spending that nothing authorises.

A1 cannot catch either: it verifies that a flag is printed, not that the flag is
true of the quantity beside it.

## O7 — specification quality — high

Tune is "the only sanctioned authoring path", but what it writes is never
specified. Nothing requires it to emit the mandatory clauses or the reserved
marker; nothing says what a second run does to an existing file.

The shipped reader is unforgiving. A `Budgets` block written without its literal
clause is `malformed`, and malformed degrades every consumer to observe-only —
so Tune, the sanctioned ritual, can author a pact the Mast then refuses to hold
anyone to, with no line saying which sentence is missing. Worse, `_block_span`
exits at the next known heading, so a second `## Budgets` appended to the file is
silently unread and the newly tuned values are invisible.

Every other component in this epic degrades safely when the pact file is wrong.
Tune is the one component that *produces* it, and its output is the input to all
six other sentinels. One scenario — Tune's output, run through `block_state`,
must return `declared` for every block declared — closes it and is cheap. Its
absence from §7 is the tell.

## O8 — risk — high

The Mast's reached notice and the Warden's advisory ride the same Stop rail,
counsel the same act, and can fire on the same turn. Verified: a declared
`lark` enters the Warden's suboptimal band at hour ≥ 20, so a `hard_stop_hour`
of 20:00 lands both.

Constraint 5 is honoured — nothing in S3 touches the Warden's files. But S2's
"mediated by no artefact" disposition answered a *coupling* question: should one
sentinel offer the other's ritual? It did not answer a *collision* question:
what does the human experience when two independent stop advisories arrive in
one payload?

The consequence is the one §3's own evidence comment predicts. Two simultaneous
messages about stopping is accumulated pressure, not a boundary-moment prompt,
and the spec's own reading is that this makes the mechanism work worse. The Mast
would be degrading the Warden's effectiveness without editing one of its files.

## O9 — risk — high

The override's destination is a committed, permanently archived, machine-
aggregated artefact. §6 declares that exact artefact out of bounds.

The note file is indeed consumed and gone. Its content is not: it lands in
`REFLECTION_LOG.md`, a generated committed aggregate with a permanent archive
under `reflections/archive/<YYYY>.md`. One `grep` returns every night the human
worked past their line, dated.

S2's O5 rejected a structurally identical record — "committed permanently and
aggregable across records — a longitudinal account of how often someone's
stopping answers were judged inadequate". Applying `sentinel-design`'s two tests
to "continued past the 20:00 stop by choice": the hook authored it, and it is an
observation about the person's conduct rather than a sentence they wrote.

§4.1 does careful work checking the carve-out's four conditions — against the
artefact that expires, not the one that persists. **This objection is not about
the route**, which was disposed and is right. It is about what the override
looks like once it lands: a durable machine-authored fact, or a sentence the
person would recognise as theirs. §6 currently reads as forbidding what §4
builds.

## O10 — alternatives — medium

Read and Tune are one product; the boundary notices and the note store are
another. §5's five files split cleanly along that seam, and §1 attributes the
entire S2 dependency to the second half.

Shipping the read half now dissolves O1, O2 and O3 outright: no contract owned
elsewhere, no third operational-state artefact, no sourceable mutation library,
no Stop-rail firing-semantics analysis. It is also the higher-value half —
S1 shipped a template no path authors, so **until Tune exists the pact file does
not exist and every other sentinel is permanently in observe-only.**

The counter-argument is real and the spec should make it if it disagrees: a Mast
that reports but never speaks at the boundary is a gauge nobody reads, which is
§1's own critique of an unread pact. Right now the alternative is not
acknowledged at all.

## O11 — risk — medium

Nothing restricts creation of `~/.claude/mast/` to humans who declared a budget.
B5 promises silence on stdout, not abstention on the filesystem, and no T
scenario asserts the store is not created.

This repeats the asymmetry `sentinel-design` records as the reason its fourth
condition exists: the pact file got a careful adoption ramp while the registry
was going to be created for every user silently. A directory appearing under
`~/.claude/` for someone who declared no pact, opted into nothing, and will
never see a notice is operational state with no operational purpose. Documenting
a store that should not exist is not disclosure — it is an explanation.

The fix is the self-gate `reservoir-check.sh` already uses: check the opt-in
first, exit 0 before touching anything.

## Explicitly not objecting to

- **The 80% fraction, the `authored_at` mechanism, the note-carried-by-Coda
  route, and Tune walking all three blocks** — all disposed at the design gate.
  O4 challenges what the fraction is taken *of*; O5 challenges the claim made
  for the mechanism, not the mechanism; O9 challenges the destination's
  retention, not the route.
- **The refusal to estimate spend.** The strongest paragraph in the spec, and it
  matches the `cost-estimator` precedent exactly: an ungroundable number against
  a real ceiling is worse than no number.
- **Not killing the session at the hard stop.** Required by constraint 6 and the
  sentinel signature; needs no defence.
- **Tune proposing no defaults.** The authorship-is-the-active-ingredient
  argument is the whole premise of the pact file.
- **`notification_policy_after_stop` at the Unverified rung.** Correct use of a
  real rung; declaring intent that nothing enforces, and saying so, is honest.
- **`sessions_per_day` flagged `inferred`.** Exactly right against S1's
  disclosed lease semantics, and the refusal to reconstruct a day's count is the
  honest call.
- **Adding an eleventh Stop hook.** A real but small operational concern that
  belongs at code time with a measurement, not at spec time as an assertion.
- **Language discipline.** No instance of "addiction" or "dopamine"; constraint
  8 satisfied.
