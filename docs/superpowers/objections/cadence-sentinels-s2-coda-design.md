---
spec: docs/superpowers/specs/2026-08-09-cadence-sentinels-s2-coda-design.md
date: 2026-08-09
mode: spec
diaboli_model: claude-opus-5[1m]
objections:
  - id: O1
    category: implementation
    severity: critical
    claim: "Invoking /reflect as ritual step 3 will, in this repo, create a branch, commit, push, open a PR, merge, and pull main — relocating the working tree away from the branch holding the uncommitted work the survey just enumerated, before any parking record is written."
    evidence: "Spec 2.3 'The Coda invokes the existing /reflect flow'; commands/reflect.md:159-173 'git checkout -b add-reflection-${slug}' ... 'gh pr merge <n> --squash --delete-branch and git pull on main'; HARNESS.md:413 'Reflections via PR workflow ... Applies to all /reflect invocations'."
    disposition: pending
    disposition_rationale: null
  - id: O2
    category: specification quality
    severity: high
    claim: "The Closed field's stated content cannot be known when the field is written: it names what was parked and how many, but parking is step 4 and the fragment is written (and committed) at step 3."
    evidence: "Spec 4.2 '- **Closed**: [what landed this session; what was parked, and how many]'; the ritual table places Reflection at 3 and Park at 4; section 2 defends that order as 'the design'."
    disposition: pending
    disposition_rationale: null
  - id: O3
    category: implementation
    severity: high
    claim: "'Abandons the ritual cleanly — no half-closed session, no partial parking' is unachievable after step 3 or mid-step-4, because /reflect has already committed a fragment and parking records are append-only and never deleted."
    evidence: "Spec 2.5 and A3; reference/parking-record-format.md 'never edited in place and never deleted'; commands/reflect.md step 8 'Commit the new fragment and the regenerated aggregate'."
    disposition: pending
    disposition_rationale: null
  - id: O4
    category: risk
    severity: high
    claim: "The survey's blanket observed flag is false for at least two enumerated items — merged PRs and an open PR awaiting checks come from the GitHub API, not disk — and the grouping of modified files into 'threads' is itself an inference."
    evidence: "Spec 2.1 'Enumerate, all flagged observed because all of it is read from disk:' followed by 'merged PRs' and 'an open PR awaiting checks'; and 'Nothing here is inferred.'"
    disposition: pending
    disposition_rationale: null
  - id: O5
    category: risk
    severity: high
    claim: "next_action_flag: asked-override is an agent-authored verdict about the human's own wording, persisted permanently in a committed repository file, and it fails both sentinel-design tests while being ineligible for the operational-state carve-out."
    evidence: "Spec 4.1 'Both values still mean the next action came from the human. Neither is an inference'; sentinel-design 'Who authored the claim? If the agent did, it is about the person'; the carve-out requires 'Local and never committed' and 'Bounded'; parking records are committed and permanent."
    disposition: pending
    disposition_rationale: null
  - id: O6
    category: specification quality
    severity: high
    claim: "Section 3.2's rule is not implementable as a deterministic shell heuristic and rule 1 is subsumed by rule 2, so V1's 'more work on the parser' turns entirely on an anchor definition the spec never gives."
    evidence: "Spec 3.2 'where the remainder is a bare noun phrase' needs a parts-of-speech parser; 'identifier-shaped token' is undefined; any text consisting solely of a vague stem already fails rule 2. V1 requires 'more work on the parser' to fail while V2 requires 'add the B12 fixture for a malformed Sync cadence block' to pass."
    disposition: pending
    disposition_rationale: null
  - id: O7
    category: implementation
    severity: high
    claim: "The anchor test measures token shape, not plan specificity, so it passes 'continue work in src/' and rejects concrete non-code actions — which is not the property section 3.1's evidence supports."
    evidence: "Spec 3.1 'specificity is the active ingredient'; 3.2 'passes on any next action carrying at least one anchor'; V5 blesses the false-positive path explicitly. A decision-shaped next action such as 'ask Russ whether the reserved block should ship at all' carries no anchor and fails, and the survey generates parking records for exactly such threads."
    disposition: pending
    disposition_rationale: null
  - id: O8
    category: implementation
    severity: high
    claim: "The resume hook is specified as firing 'at session start', but SessionStart fires on startup, resume, clear and compact with matcher '*' — so the list of parked threads is re-injected mid-session, re-opening a question S1 settled."
    evidence: "Spec 2.6; S1 section 4.2 'SessionStart fires on startup, resume, clear, and compact'; hooks/hooks.json registers SessionStart with matcher '*'; session-registry-start.sh repeats the warning."
    disposition: pending
    disposition_rationale: null
  - id: O9
    category: scope
    severity: high
    claim: "S2 ships no writer for the .resumed.md transition, so every parking record it creates stays open forever, the resume hook's output grows without bound, and H4 tests behaviour whose producer does not exist in this slice."
    evidence: "Spec section 5's file table lists no resume/transition writer; H4 tests a .resumed.md record; S1 section 5.1 states 'That query is the one S2's resume path depends on' and 'resuming is a write by the /coda command'."
    disposition: pending
    disposition_rationale: null
  - id: O10
    category: premise
    severity: medium
    claim: "The advertised attack surface exceeds what the mechanism can reach: the only defence against continuation dissolves the moment the human plainly asks to continue, which is the shape the named failure mode takes."
    evidence: "Spec 1 'Attacks: compulsive continuation'; 2.5 'If the human says plainly that they want to keep working, the Coda abandons the ritual cleanly'; 3.3 sets the standard: 'pretending otherwise would be the overclaiming this epic exists to avoid'."
    disposition: pending
    disposition_rationale: null
  - id: O11
    category: alternatives
    severity: medium
    claim: "The spec does not weigh extending /reflect with a closing mode against adding a fourth surface, even though its own argument against a second reflection path applies with equal force to a second session-closing ritual."
    evidence: "Spec 2.3 'duplicating any of that would create a second reflection path that drifts from the first'; section 5 adds an agent, skill, command, script and hook; 4.2 already extends /reflect's fragment schema. /reflect --mine is the established precedent for adding a mode rather than a command."
    disposition: pending
    disposition_rationale: null
  - id: O12
    category: specification quality
    severity: medium
    claim: "The 'Coda may be offered when the Warden's threshold is crossed' pathway has no implementation surface, and the same section forbids the only edit that would create one."
    evidence: "Spec 6 'No changes to the Reservoir Warden' alongside 'The Coda may be offered when the Warden's threshold is crossed'; the warden agent's output path never mentions /coda; section 8's docs list names no reservoir surface."
    disposition: pending
    disposition_rationale: null
---

# Objection record — Cadence Sentinels S2: The Coda (spec mode)

Twelve objections: one critical, eight high, three medium. The
agent-emits / command-persists split is the strongest structural choice in
the spec and is not objected to. The objections concentrate in three
places: what `/reflect` actually does when invoked (O1–O3), whether the
validator can be built and whether it measures the right thing (O6, O7),
and two questions S1 had already settled that S2 re-opens (O8, O9).

**Dispatcher verification note (2026-08-09).** O1 was verified before
recording: `commands/reflect.md:159-173` runs `git checkout -b`,
`gh pr create`, `gh pr merge --squash --delete-branch` and `git pull` on
main, and `HARNESS.md:413` declares that path binding on *all* `/reflect`
invocations. The `/reflect --mine` mode cited in O11 exists. The
command-invokes-command mechanism the spec relies on is real and has
precedent (`/harness-sync` invokes `/convention-sync`), which is why the
diaboli did not object to the mechanism itself — only to what the invoked
command does at its final step.

## O1 — implementation — critical

Ritual step 3 delegates to `/reflect`, and `/reflect` in this repository is
not a write-a-fragment-and-return operation. It is a full
branch-commit-push-PR-merge-pull cycle. Running it as the third of five
steps moves the working tree off the branch holding the uncommitted work
the survey enumerated in step 1, and does so before a single parking record
has been written in step 4.

The concrete failure sequence: step 1 surveys modified-but-uncommitted
files on the working branch; step 3 runs `git checkout -b
add-reflection-…` (carrying the dirty tree with it, or failing on
conflict), pushes, opens a PR, waits on CI, merges, deletes the branch, and
pulls `main`. Step 4 then writes parking records — on `main`, or on a
deleted branch, or wherever the merge left the tree. Step 5 "closes" a
session whose working tree is now somewhere the human did not put it.

This is worse than a bug, because the ritual's entire promise is that
stopping costs nothing. A closing ritual that rearranges your git state and
blocks on CI is the most expensive way to stop yet designed. §2.3's
reasoning — do not reimplement reflection — is sound; what it did not do is
examine what the delegated command does at its final step.

## O2 — specification quality — high

The `Closed` field is specified to carry "what was parked, and how many" —
a fact produced by step 4 — but is written into the fragment at step 3.
Under O1's PR path the fragment is not merely written by then but committed
and merged, so back-filling means editing a merged artefact.

An implementer has three incompatible readings: write at step 3 and drop
the parked counts (making the field's own spec text wrong); defer the
fragment until after step 4 (contradicting the order §2 calls "the
design"); or write and amend (editing a merged file). The field is the only
artefact §2.2 offers as the ritual's terminal cue, and a terminal cue whose
content is undefined at write time is not a cue.

## O3 — implementation — high

Clean abandonment is asserted, not designed. Once step 3 has run a fragment
is committed; once step 4 has begun, parking records exist and constraint 7
forbids deleting them.

The realistic abandonment point is late: a human who changes their mind
about stopping typically does so while being asked for the fourth concrete
next action, not before the survey. At that point three parking records are
permanent, and the resume hook will surface them next session describing
threads the human never actually parked, with next actions written in a
moment of intended closure that never happened.

A3 cannot pass except where abandonment occurs before step 3, and the spec
gives no rule confining it there.

## O4 — risk — high

The survey's blanket `observed` flag is stated as following from "all of it
is read from disk", which is not true of the list it flags. Merged PRs and
an open PR's check state come from `gh` — network, auth, rate limits. A
survey reporting "no merged PRs" because `gh` errored, flagged `observed`,
is exactly the laundering of inference as observation constraint 3 exists
to stop, and S1 §4.3 went to real trouble to make the flag a property of
the value rather than of the reader for this reason.

The thread-grouping problem is larger. Nine modified files are an
observation; that they constitute *two* threads rather than one or nine is
a judgement the Coda makes — and it is the judgement that determines how
many parking records exist and what each says. This is the Coda's core
epistemic act, and the spec flags it `observed` by assertion.
`sentinel-design` asks that the honesty rule be written before the
detection logic; S2 wrote the detection and declared the honesty rule to be
"all of it is observed".

## O5 — risk — high

`next_action_flag: asked-override` records a machine verdict about the
quality of the human's own words, authored by the agent, committed
permanently. §4.1 asserts this is not a judgement about the person; both of
`sentinel-design`'s tests say otherwise, and the operational-state
carve-out cannot rescue it because that carve-out requires the record never
be committed and be bounded, while parking records are committed and
permanent.

§4.1's defence conflates two claims. *That the next action came from the
human* is by-the-person and fine. *That the human's answer failed a check
and they insisted anyway* is agent-authored, and no human would describe
what they said as "asked-override". The spec's own framing gives it away:
"a later reader can see that the specificity check fired and that the human
overrode it" — that reader is learning something about the person's
behaviour at the end of a session, from a permanent committed file, and the
accumulated set is a longitudinal record of how often someone's stopping
answers were judged inadequate.

This is not an argument against recording the override, which constraint 6
requires. It is an argument that §4.1's justification does no work, and
that the honest placement may be the record's prose body — which the human
authored and would recognise — rather than a machine-legible enum that
aggregates across records. S5's consultation dispositions will inherit
whichever answer S2 sets.

## O6 — specification quality — high

§3.2 presents itself as "a deterministic heuristic, so it is testable", but
its first rule contains a clause no shell script can evaluate ("where the
remainder is a bare noun phrase" is a parts-of-speech judgement), its
second rule depends on an undefined term ("`identifier`-shaped token"), and
the two overlap such that rule 1 does no work — any text consisting solely
of a vague stem already contains no anchor and fails rule 2.

The acceptance scenarios then require the undefined term to draw a line the
spec never draws: V1 requires `more work on the parser` to fail while V2
requires `add the B12 fixture for a malformed Sync cadence block` to pass,
so `parser` must not be an anchor while `B12` must be. V4 fixes one end of
the anchor set; nothing fixes the other.

§3.3 promises "the check is stated in the skill and the reference page, so
a human can see why their wording failed". That promise cannot be kept if
the check's decisive term exists only in the implementation.

## O7 — implementation — high

Even implemented perfectly, the anchor test measures the presence of a
code-shaped token, not the specificity of a plan. V5 blesses the
false-positive path explicitly: append a filename to any vague stem and it
passes, so "keep going in `src/`" satisfies the rule.

The symmetric false negative matters more. "Re-read the governing-clause
matcher and decide whether reworking it needs its own spec-first change" is
concrete, actionable and well-formed, with no path, identifier, test name,
line reference or quoted string. So is "ask Russ whether the reserved block
should ship at all". Both fail — and the survey generates parking records
for exactly such threads, since it enumerates "objection or story records
still carrying `pending` dispositions".

The evidence in §3.1 concerns the specificity of the plan, a property of
meaning. The validator tests a property of lexical form. Where they
diverge, the mechanism does the opposite of what its evidence supports: it
rewards adding a filename to "continue work" and penalises a genuinely
concrete decision step. §3.3 discloses that a heuristic errs in both
directions; it does not address that the errors are *systematic* along the
code/non-code axis, and the Coda parks non-code threads by design.

## O8 — implementation — high

§2.6 specifies surfacing "at session start" and implements it as a
`SessionStart` hook — but S1 established, documented twice, and designed
around the fact that `SessionStart` fires on startup, resume, clear and
compact.

The behaviour is not merely noisy, it is counter-purposive. A parking
record's function is to release a thread's pull so the person can stop
holding it. A hook that prints "still parked: implement the retry branch of
slice 7" into the middle of an unrelated session hands the thread back,
repeatedly, at the moment the human is deepest in something else. That is
the compulsive-continuation surface the epic exists to reduce, generated by
the mechanism meant to reduce it.

The fix is small — a `source` guard or a once-per-session marker — but the
spec neither states it nor tests it: H1–H5 test emptiness, missing
directories and unreadable directories, and none tests firing frequency.

## O9 — scope — high

S2 ships the writer for parking records and nothing that ever closes one.
No path in this slice writes a `.resumed.md` or `.superseded.md`
transition, so `records_open` returns a monotonically growing set forever,
and H4 tests the handling of a file no component in S1 or S2 produces.

S1 assumed S2 owned this: "That query is the one S2's resume path depends
on", and "resuming is a *write* by the `/coda` command".

Without a resume path the corpus only grows. Session 5 surfaces the records
from sessions 1–4 whether or not those threads were finished, and combined
with O8's firing frequency the hook becomes a standing list of stale
obligations. §2.6 argues the surfacing "is the payoff that makes parking
trustworthy"; a surfacing that cannot distinguish live parked work from
work finished three days ago destroys precisely that trust.

## O10 — premise — medium

The headline claim is broader than the mechanism can reach. The only
defence against continuation is a refusal that dissolves on a plain request
to continue — and a plain request to continue is the form the named failure
mode takes.

This is not an argument for making the refusal firmer; the yield is
required by constraint 2, was disposed at the design gate, and a ritual
that could not be called off would be the gate-on-the-person anti-pattern.
The objection is about the *claim*. §3.3 states the epic's own standard:
"pretending otherwise would be the overclaiming this epic exists to avoid."
An epithet saying the Coda attacks compulsive continuation, attached to a
mechanism that by design steps aside for anyone who asks, is that same
overclaim in the sentence that names the sentinel.

What the Coda actually attacks is *drift* — the "while we're here"
extension nobody deliberately chose — plus the cold-start cost of an
unrecorded stop. Both are worth attacking, and naming them accurately sets
the right expectation for S3, where the hard-stop trigger arrives and the
continuation claim may become earnable.

## O11 — alternatives — medium

The spec does not weigh extending `/reflect` with a closing mode against
introducing a fourth surface. It already extends `/reflect`'s schema and
already delegates a ritual step to it, and its own argument against
duplicating reflection applies with equal force to standing up a second
session-closing ritual beside the one that exists. §4.2 records that a
third *record directory* was considered and rejected; no comparable
weighing appears for the *command* surface.

There are now two commands a person might run at the end of a session, one
of which calls the other, and no rule for which to reach for. That is the
drift §2.3 warns about, relocated one level up: `/reflect` will accumulate
closing-adjacent behaviour — it already has the `Closed` field and the
commit step — while `/coda` accumulates reflection-adjacent behaviour, and
in a year the boundary is folklore.

A `/reflect --close` shape, mirroring the existing `--mine` mode, would
carry the survey, the parking loop and the validator while leaving one
entry point and one owner for the fragment schema — dissolving §4.2's
contract-ownership problem entirely, since the field would then be added by
its owner. It may still lose: the Coda needs a `role: sentinel` agent, and
a mode flag on a command that commits is not obviously simpler. But it is
cheaper on the axis the spec cares about, and the spec should say why it
lost.

## O12 — specification quality — medium

§6 describes an interaction between the Reservoir Warden and the Coda while
the same section forbids the only change that could implement it, and §8
lists no surface where the offer would live. Nothing in the shipped tree
will ever offer `/coda` at a threshold crossing, because no artefact
mentions it and §6 forbids editing the ones that would.

The stakes are constraint 5, so the ambiguity is worth removing. Stating it
as a future possibility deferred to a later slice, or stating that the
offer is the human's own move with no artefact mediating it, both resolve
it. Prose describing an unbuilt mechanism next to a non-goal forbidding its
construction does not.

## Explicitly not objecting to

- **"The Coda invokes `/reflect`" as a mechanism.** Established in this
  plugin — `/harness-sync` invokes `/convention-sync` and
  `/harness-health`; `/reflect` invokes `/harness-constrain`. O1 objects to
  what the invoked command *does*, not to whether it can be invoked.
- **The agent holding `Bash`.** `reservoir-warden` is already
  `role: sentinel` with `Bash`, and S1 of the sentinel signature permits it
  for read-only inspection, so the Coda's grant sets no new precedent.
- **The agent-emits / command-persists split.** Exactly the
  `cost-estimator` pattern and the AGENTS.md agent-emit + dispatcher-persist
  decision; the strongest structural choice in the spec.
- **The three design-gate dispositions.** Reprompt-once-then-defer, the
  `Closed` field rather than a third record type, and abandon-on-plain-
  request. O3 objects to whether abandonment can be *clean*, not to whether
  it should happen; O6 objects to the rule's implementability, not to what
  follows a failure.
- **The version bump and CI-checked locations.** §8 matches `CLAUDE.md`
  exactly, including the component counts.
- **Ritual length being unbounded** (considered, below the cap): one
  validated next action per live thread, no cap, no batching, so the
  ritual's cost scales with the mess it finds at exactly the moment the
  human wants to stop. Worth raising at the code gate.
- **The `sentinel-design` roster table and README Sentinels section going
  stale** (considered, below the cap): §8 updates
  `explanation/sentinels.md` roster 5 → 6 but not the roster table in the
  skill or the README section — a small instance of the pinned-copy
  anti-pattern AGENTS.md names.
