# Spec: Cadence Sentinels S2 — The Coda

**Status:** Approved (revision 3, post-cartographer)
**Date:** 2026-08-09
**Issue:** #492
**Epic:** The Cadence Sentinels (S1–S7, issues #491–#497)
**Objections:** `docs/superpowers/objections/cadence-sentinels-s2-coda-design.md`
— 12 objections, 11 accepted, 1 rejected on the record
**Choice stories:** `docs/superpowers/stories/cadence-sentinels-s2-coda-design.md`
— 8 stories, all accepted
**Depends on:** S1 (#491, merged as 0.67.0) — the parking-record contract,
`records_open`, and the pact file
**Scope:** `ai-literacy-superpowers` plugin; one new agent, skill, command,
hook, and validator
**Explicitly out of scope:** the Mast (S3), the WIP Warden (S4), the Convener
(S5). S2 ships the ritual and the records it writes.

**Provenance:** *The Second Front — Arc Insertion Remit* (slide S5) and
*Compulsive Continuation — A Research Exploration*.

---

## 1. Problem Statement

An agentic session has no terminal cue. There is no compile, no deploy, no
colleague standing up to leave — the medium supplies nothing that says *this is
finished*. So sessions end by attrition rather than by decision: the human stops
when something external interrupts, and the work is left in whatever state the
interruption found it.

Two costs follow. The unfinished threads keep their pull, because nothing wrote
down where they were. And the next session opens cold, re-deriving from a diff
what the previous session knew.

The Coda is the good ending: a ritual that closes a session deliberately,
records what landed, and parks every live thread with a concrete resume step.

**Epithet:** *the good ending.*

**Attacks:** *drift* — the "while we're here" extension nobody deliberately
chose — and the cold-start cost of an unrecorded stop.

Not, in this slice, compulsive continuation itself. The Coda's only defence
against continuing is a refusal that steps aside the moment the human plainly
asks it to (§2.5), and a plain request to continue is the shape the failure
mode takes. Claiming otherwise would be the overclaim §3.3 forbids, in the
sentence that names the sentinel. S3's hard stop may make that claim earnable;
S2 does not earn it.

## 2. The Ritual

The same sequence every invocation, no reordering.

| # | Step | Produces |
| --- | --- | --- |
| 1 | **Survey** | landed work and live threads, per-item honesty flags |
| 2 | **Park** | one parking record per live thread |
| 3 | **Closure summary + reflection** | the `Closed` field, via `/reflect` |
| 4 | **Close** | the session ends |

**Why parking comes before reflection.** The portable reason first, because it
holds in every repository: the `Closed` field names what was parked, and it can
only do that if parking has already happened. A closure summary written before
the parking it describes can assert a count and nothing else.

The local reason makes the order non-negotiable *here*. `/reflect` in this
repository is not a
write-a-fragment-and-return operation: `HARNESS.md`'s *Reflections via PR
workflow* constraint binds every invocation to `git checkout -b`, `gh pr
create`, `gh pr merge --squash --delete-branch`, and `git pull` on main
(`commands/reflect.md:159–173`). Run before parking, it would move the working
tree off the branch holding the very uncommitted work the survey had just
enumerated — and then write parking records from wherever the merge left the
tree. A closing ritual that rearranges your git state and blocks on CI is the
most expensive way to stop yet designed.

So parking completes — and is **committed** (§2.2) — while the tree is still
where the human left it, and `/reflect` runs last.

Downstream adopters who have not declared that constraint get a `/reflect` that
commits directly to the current branch and moves nobody's tree. The order still
holds for them, on the first reason. Stating which reason travels matters: a
paragraph that reads as a workaround for someone else's CI is precisely the kind
a maintainer reorders believing they are removing dead weight.

**Divergence from the build spec, flagged for the PR.** The build spec fixed
the sequence as survey → closure summary → reflection → park → close and said
"no reordering". That order is unshippable here for the reason above.

### 2.1 Survey

Each item carries its own flag. A blanket claim would be false: some of this is
read from disk and some of it is a network call that can fail.

| Item | Flag |
| --- | --- |
| Commits on the branch | `observed` |
| Modified-but-uncommitted files | `observed` |
| Dispositions in objection and story records | `observed` |
| Records already parked (`records_open`) | `observed` |
| Merged PRs, open-PR check state | `observed` when `gh` succeeds; **`inferred`** when it does not |
| **Which files constitute one thread** | **`asked`** |

Two of these deserve their reasoning stated.

A `gh` read is a network call with auth and rate limits. Reporting "no merged
PRs" because `gh` errored, flagged `observed`, is exactly the laundering of
inference as observation constraint 3 exists to stop. When `gh` is unavailable
the Coda says so; it never silently reports an empty result as an observation.

**Flags are ritual-scoped.** They are shown to the human during the survey and
do not travel into the record — parking records are handoffs, not provenance
artefacts. Where provenance matters for a particular thread (a survey taken
while `gh` was unavailable, say), it goes in the record's `## Context` prose,
where the human can read it. This is stated so S5 inherits an answer: its
consultation records *do* carry a per-voice `source_flag`, and the difference is
deliberate rather than an accident of which slice was written first.

**Thread grouping is `asked`, and this is the Coda's central epistemic act.**
Nine modified files are an observation. That they constitute *two* threads
rather than one or nine is a judgement — and it is the judgement that decides
how many parking records exist and what each one says.

**Propose and default-accept.** The Coda proposes a grouping; it stands unless
the human changes it. The human can always overrule, which is what makes the
flag `asked` rather than `inferred` — but the default costs a word rather than a
partition.

This is the plugin's own premise applied to its own ritual. The
`reservoir-warden` exists because judgement degrades across a session, and this
step lands at the moment the human has already decided they are finished.
Demanding a full manual partition there would put the heaviest synthesis in the
ritual on whoever is least equipped to do it — and the escape would be cheap and
silent: group everything as one thread, answer once, and the handoff is worth
nothing on exactly the sessions where it would have been worth most.

### 2.2 Park

For every live thread, one parking record per the S1 contract
(`reference/parking-record-format.md`): frontmatter, a `## Context` paragraph,
and a `## Next action` section carrying one concrete resume step.

Every next action is **asked for**, and every answer the human gives is
**parked**. The Coda never refuses a next action — see §3, which is where the
prompting rule lives.

**S2 changes nothing in this contract.** `next_action_flag` stays `asked` for
every record. The first revision of this spec proposed an `asked-override`
value; it was removed at the gate (O5), which means S2 consumes S1's contract
without mutating it and the contract-ownership rule does not engage.

**Records are committed here, at step 2, before `/reflect` runs.** This is not
tidiness. `/reflect` stages `reflections/active/` and `REFLECTION_LOG.md` and
nothing else (`commands/reflect.md:160`), then relocates the tree to `main`.
Without an explicit commit at this step, the ritual would write parking records,
publish a `Closed` field describing them, and leave the records themselves
uncommitted in a tree that has just moved — the claim reaching `main` by design
and the records it names reaching `main` by whatever the human happened to do
next.

**Retention: permanent and committed, stated rather than assumed.** A handoff
another person may read is repository content, which is why these records live
in the tree rather than beside the pact file. Two consequences follow and are
accepted here rather than solved: the corpus grows as sessions × threads
forever, and `records_open` iterates the whole directory on every call, so the
session-start hook's cost tracks lifetime history rather than open work.
Archival is deliberately not built in this slice — see issue #499. It needs its
own spec and its own adversarial pass, because S1 owns the contract.

### 2.3 Closure summary and reflection

The Coda **invokes the existing `/reflect` flow**. It does not reimplement
reflection, does not ask the three questions itself, and does not write the
fragment directly. `/reflect` already owns the fragment schema, the signal
classification, and the auto-constraint proposal; duplicating any of that would
create a second reflection path that drifts from the first.

The closure summary — a short "what landed, what was parked" statement — is
supplied to `/reflect` as the optional `Closed` field (§4). Closure needs an
artifact; the medium supplies no terminal cue, so the ritual leaves one behind.

### 2.4 Close

The Coda **refuses to open new work in the closing breath.** Any work request
arriving after the ritual has started is parked, not executed.

"Almost done" is the state hardest to leave, and the closing breath is where
"while we're here" does its damage: the ritual that was about to end the session
becomes the preamble to another hour.

The refusal targets that drift, not the human's ability to change their mind. If
the human says plainly that they want to keep working, the Coda stops the ritual
and says exactly what has already been written.

**What "stopping cleanly" can and cannot mean.** Records are append-only, so
nothing already written can be withdrawn. The honest promise is therefore not
"no partial parking" but **nothing silently half-done**:

- Stopped during or before the survey — nothing has been written. Genuinely
  clean.
- Stopped after one or more records exist — the Coda names each record it
  wrote and offers to supersede it (§2.6), which is a write, not a deletion.
- Stopped after `/reflect` — the fragment is committed and merged; the Coda
  says so and does not pretend otherwise.

The first revision promised clean abandonment at any point. That was
unachievable under constraint 7 and is corrected here (O3).

### 2.5 Resumption, and closing a parked record

**Surfacing.** If any parking record for this repo is still open, surface it
once per session: id and next action, nothing more. This is the payoff that
makes parking trustworthy — a record nobody ever sees again is a diary, not a
handoff.

**Once per session is load-bearing.** `SessionStart` fires on startup, resume,
clear and compact (S1 §4.2), so an unguarded hook would re-inject the parked
list mid-session, every compact, for the rest of the day. A hook that prints
"still parked: implement the retry branch" while the human is deepest in
something unrelated hands the thread back — which is the surface this epic
exists to reduce, generated by the mechanism meant to reduce it. The guard keys off **S1's existing registry entry** rather than a new marker
file: `started_at` is per-session and stable across compacts by design (S1's R2
asserts exactly that), so the hook can tell a genuinely new session from a
re-fire without writing anything.

That matters beyond convenience. A new per-session marker file in
`~/.claude/sessions/` would have been a second file class in a directory another
slice owns, inheriting its location guarantees without inheriting its retention
contract — and the registry's only removal path is the lease pruner, which
retires `*.json` by heartbeat and sweeps `*.tmp`. A marker in neither shape has
no removal path and accumulates one per session for the life of the machine,
against a carve-out whose second condition is *bounded* and whose own text warns
that "a record with no expiry is an archive".

**Closing a record is also asked, not only commanded.** When the ritual runs
and open records exist, the Coda asks per record whether it is still live — the
human is already in a closing conversation, so this costs them nothing extra,
and a "no" writes the transition immediately.

Without that, closure would depend entirely on someone remembering to run a
command, and the corpus would only ever grow. Note the asymmetry this resolves:
S1's registry is a *lease*, where forgetting costs nothing because entries
expire; a parking record is the inverse, open by default until an act of
bookkeeping closes it. The failure of forgetting is an undercount in one and an
overcount in the other, and the overcount is the one a human sees at every
session start.

**Closing a record explicitly.** `/coda resume <record>` writes a `.resumed.md` transition
naming its predecessor in `supersedes:`, exactly as the S1 contract specifies.
S2 ships this because S1 assigned it here, and because without it
`records_open` returns a monotonically growing set: session five surfaces the
records of sessions one to four whether or not those threads were ever
finished, and a surfacing that cannot tell live parked work from work finished
three days ago destroys the trust it exists to build.

## 3. Asking for the Next Action

### 3.1 Why the next action matters

A written plan for an unfinished task releases its pull — but **specificity is
the active ingredient**, not the writing. "Continue work" is a written plan and
does nothing. "Implement the retry branch of slice 7's error path, starting from
the failing test in `test_retry.py`" is a written plan that works.

<!-- evidence: Masicampo & Baumeister 2011 — a specific written plan, not
     completion, releases the unfinished-task pull. Specificity carries the
     effect, which is why the ritual asks for a starting point rather than
     accepting whatever arrives first. -->

### 3.2 The check triggers a question — it never renders a verdict

`scripts/next-action-hint.sh <text>` exits 0 when a next action carries a
concrete anchor and 1 when it does not. **Exit 1 means "ask once more". It does
not mean "reject".**

The first revision made this a validator that refused a record until the text
passed. That was wrong twice over, and both were caught at the gate (O7):

- It measures **lexical form, not specificity**. "Keep going in `src/`" carries
  an anchor and would have passed; "ask Russ whether the reserved block should
  ship at all" carries none and would have failed — and the survey generates
  parking records for exactly such decision-shaped threads.
- Its errors are **systematic along the code/non-code axis**, not random. A
  heuristic that is reliably unfair to one kind of thread is worse than one
  that is noisy.

Demoted to a trigger, both error directions cost the same thing: one extra
question. A false positive asks about an already-concrete action; a false
negative fails to ask about a vague one. Neither produces a wrong verdict about
the human's words, and **the record is written either way**.

This also removes the gate. Nothing is refused, so constraint 6's
override-on-the-record machinery does not engage — there is nothing to override.

### 3.3 The anchor grammar, stated exactly

A next action **carries an anchor** when it contains at least one of:

| Anchor | Pattern |
| --- | --- |
| A path | a token containing `/` or a known file extension |
| A code identifier | a token containing `_`, `::`, or `()`, or in `Some.Case` form |
| A backticked span | anything inside `` ` `` |
| A scenario or ticket id | a letter-digit token such as `B12`, `R4`, `#492` |
| A line or section reference | `file:12`, `§3.2`, `line 40` |
| A decision | a question word, a named person, or `ask` / `decide` / `choose between` |

Nothing else counts. In particular a bare English noun does **not** — `parser`
is not an anchor, which is what makes `more work on the parser` trigger the
question while `add the B12 fixture` does not.

**The decision row exists because the other five are all artefacts of
code-shaped work**, and this plugin's own work is mostly specs, prose, and
decisions. Without it the table would tax the dominant kind of thread with an
extra question at every close, from a published rule that reads as the house
definition of a concrete next step. "Ask Russ whether the reserved block should
ship at all" is a perfectly good next action and now reads as one.

The first revision also carried a vague-stem rule. It is dropped: any text
consisting solely of a vague stem already carries no anchor, so the rule fired
only on inputs the anchor test had already caught (O6).

### 3.4 What the human sees

On a trigger, one question that **names what is missing** — a file, a test, or a
first step — never merely "too vague". Whatever the human answers next is
parked, including the same words again.

If the human repeats themselves, the record's `## Next action` section carries
their answer plus a line in **their own voice** noting they were asked for a
starting point and confirmed this was enough to go on.

That line, not a frontmatter enum, is where the override lives. An
`asked-override` flag would have been an agent-authored verdict on the human's
wording, committed permanently and aggregable across records — a longitudinal
account of how often someone's stopping answers were judged inadequate. Both of
`sentinel-design`'s tests classify that as a record *about* the person, and the
operational-state carve-out cannot rescue it because these records are committed
and permanent (O5).

### 3.5 The rule is disclosed

§3.3's table is reproduced verbatim in `skills/coda/SKILL.md` and
`reference/parking-record-format.md`, so a human who is asked can see exactly
why. A check whose decisive term exists only in the implementation cannot be
argued with, and this one is meant to be.

Both copies carry the same framing sentence: **this is a trigger heuristic, and
its complement is not "vague".** A next action that carries no anchor gets one
question; it does not get a verdict, and it is not being called imprecise. The
table says what makes the Coda *stop asking*, not what makes a next action good.

## 4. Contract Change

One contract owned elsewhere changes: the reflection fragment gains an optional
field. The parking-record contract is **unchanged** (§2.2).

### 4.1 Reflection fragment: a new optional `Closed` field

Owned by `/reflect` and `scripts/lib/reflection-log-helpers.sh`.

```text
- **Closed**: [what landed this session; the filename of each record parked]
```

**Filenames, not a count.** A count asserts that three threads were parked
without saying which three, and nothing can check it. Naming the records makes
the claim resolvable against `records_open` and gives a future reader a route
from a reflection entry to the work it closed. The reflection log is the
durable, published trace of a session's close; the one cross-artefact claim it
makes should not be the one nothing can verify.

Optional, and absent from every fragment `/reflect` writes on its own — only the
Coda's invocation supplies it. The change is additive: `extract_field` resolves
by name and `regenerate_log` concatenates fragments verbatim, so no existing
fragment, parser, or archive path is affected.

Because S2 is a consumer of this contract and not its owner, the change is
carved out here explicitly rather than slipped in, per the promoted ARCH_DECISION
that a consumer never mutates the contract it consumes. This is the second
worked instance of that decision, which its Rule-of-Three watch item asks to be
recorded.

The alternative — a third record directory — was rejected at the design gate:
the reflection fragment already *is* the session-scoped record, `/reflect`
already runs inside the ritual, and a third schema would need its own
contract-ownership treatment for no gain.

## 5. Files

| File | Purpose |
| --- | --- |
| `agents/coda.agent.md` | `role: sentinel`, `tools: [Read, Glob, Grep, Bash]` — surveys and returns record content |
| `skills/coda/SKILL.md` | the ritual, the evidence, the anchor grammar, the anti-patterns |
| `commands/coda.md` | dispatches the agent, asks for next actions, persists records; `/coda resume <record>` writes transitions |
| `scripts/next-action-hint.sh` | the anchor check (a trigger, not a judge) |
| `hooks/scripts/parked-resume-check.sh` | `SessionStart` — surfaces open records once per session |
| `hooks/hooks.json` | registers the hook |

**The agent holds no `Write`.** It returns parking-record content as a string;
`/coda` persists it. That is the `cost-estimator` precedent and what keeps the
Coda inside the sentinel category its own docs place it in.

### 5.1 Why `/coda` is a command and not `/reflect --close`

Recorded because the alternative is real and was rejected (O11).

`/reflect --mine` is the established precedent for adding a mode rather than a
surface, and folding the Coda in would have left one entry point and one owner
for the fragment schema — dissolving §4.1's contract-ownership problem, since
the field would then be added by its owner.

It loses on trust shape. The Coda dispatches a `role: sentinel` agent that
surveys and returns content and is forbidden to write; `/reflect` is a command
whose final step commits, pushes, and merges. Putting a read-only sentinel
inside a committing command muddles exactly the boundary S1 spent a slice
making load-bearing.

The objection's real worry — that the two commands drift until the boundary is
folklore — is answered directly: both commands state when to reach for which.
`/reflect` writes a learning. `/coda` closes a session, and calls `/reflect` as
part of doing so.

## 6. Non-Goals

- **No reimplementation of reflection.** The Coda calls `/reflect`.
- **No changes to the Reservoir Warden**, its block, its hook, or its skill.
  Whether to run `/coda` after the Warden recommends deciding a stop is the
  **human's own move, mediated by no artefact**. Nothing offers it, nothing is
  wired, and no file mentions the other. The first revision described an offer
  pathway next to a non-goal forbidding its construction (O12).
- **No automatic invocation.** S3 wires the hard-stop trigger; `/coda` is
  manual here.
- **No gates.** Nothing in this slice refuses, blocks, or requires a
  disposition. The ritual can be stopped at any point by saying so.
- **No claim about why the human stopped.** Records say a session closed and
  what was parked. Never why.
- **No cap on ritual length.** One next action per live thread, asked in
  sequence. Noted rather than solved: the cost scales with the mess found at
  exactly the moment the human wants to stop. If that bites, batching is the
  obvious answer and belongs in its own slice.

## 7. Acceptance Scenarios (TDAD)

Prefixed **N** for the anchor check, **P** for parking records, **H** for the
resume hook, and **A** for agent-verified ritual behaviour.

### 7.1 Anchor check — `tdad_tests/layer0_deterministic/test-next-action.sh`

The check exits 1 to mean *ask again*, never *reject*. These scenarios pin the
grammar in §3.3, which the skill and reference page reproduce.

- **N1 — no anchor triggers the question.** `continue work`, `carry on`,
  `keep going`, `finish this`, `pick up where I left off`, and
  `more work on the parser` each exit 1. A bare English noun is not an anchor.
- **N2 — each anchor kind is recognised.** One case per row of §3.3's table:
  a path (`src/parser.rs`), an identifier (`block_key()`), a backticked span,
  a scenario id (`B12`), and a line reference (`pact-blocks.sh:88`) each exit 0.
- **N3 — the message names what is missing.** A trigger mentions a file, a
  test, or a first step — never only "too vague".
- **N4 — a terse anchor passes.** `test_retry.py` alone exits 0: terse but
  concrete.
- **N5 — a vague stem with an anchor passes.** `continue the retry branch in
  test_retry.py` exits 0. This is a known false positive, disclosed in §3.2 —
  and it costs nothing, because the check only decides whether to ask.
- **N6 — empty and whitespace-only trigger the question.**
- **N8 — a decision anchor is recognised.** `ask Russ whether the reserved
  block should ship at all` and `decide between the lease and the explicit
  transition` each exit 0. This is the row that stops the grammar taxing the
  plugin's own dominant kind of work.
- **N7 — exit 1 is not a failure.** The script exits 1 without writing to
  stderr and without a non-zero-means-error message, so a caller cannot mistake
  a trigger for a fault.

### 7.2 Parking records — `test-record-contracts.sh` (extended)

- **P1 — the contract is unchanged.** `next_action_flag` still documents
  exactly one value, `asked`. S2 adds no enum value.
- **P2 — an override reads as prose.** A fixture whose `## Next action` carries
  a repeated answer plus a human-voice confirmation line satisfies every field
  of the S1 contract, and its frontmatter is indistinguishable from any other
  record.
- **P3 — a resumed record supersedes its predecessor.** A `.resumed.md`
  written by the resume path names its predecessor in `supersedes:`, and
  `records_open` returns neither.

### 7.3 Resume hook — `tdad_tests/layer0_deterministic/test-parked-resume.sh`

- **H1 — silent when nothing is parked.** Empty stdout, exit 0.
- **H2 — silent when the directory does not exist.** Exit 0.
- **H3 — surfaces an open record**, naming it and its next action.
- **H4 — a resumed record is not surfaced.**
- **H5 — once per session.** Given the hook has already fired for this session,
  a second invocation with the same session id is silent. This is the scenario
  that would have caught re-injection on every compact.
- **H6 — a new session surfaces again.** A different session id gets the list.
- **H7 — exits 0 unconditionally**, including when the parked directory is
  unreadable and when `HOME` is unset.
- **H8 — no marker file is written.** After the hook runs, the registry
  directory contains exactly the files it contained before. The guard reads
  `started_at`; it does not leave residue in a directory S1 owns.

### 7.4 Ritual — agent-verified, recorded in the skill

- **A1** — the four steps run in order: survey, park, closure summary and
  reflection, close.
- **A2** — thread grouping is proposed and confirmed, never decided alone.
- **A3** — a `gh` failure is reported as `inferred`, never as an empty
  `observed` result.
- **A4** — a post-ritual work request is parked, not executed.
- **A5** — a human who plainly says they want to continue gets the ritual
  stopped, with an explicit statement of what was already written.
- **A6** — the Coda writes no file itself; every record is persisted by the
  command after the human confirms.
- **A7** — parking records are committed before `/reflect` is invoked.
- **A8** — the proposed thread grouping stands when the human says nothing, and
  changes when they do.
- **A9** — when open records exist at ritual time, each is asked about, and a
  "no longer live" answer writes its transition.

## 8. Migration & Rollout

Minor bump, 0.67.0 → 0.68.0 — a new agent, skill, command, script, and hook.

Version locations: the five CI-checked ones plus the README plugin-table cell,
and the README component counts (37 skills → 38, 16 agents → 17, 28 commands →
29).

Docs, same PR:

- `how-to/closing-a-session.md` — the ritual, when to use it, what it writes
- `reference/parking-record-format.md` — the anchor grammar and the prose-body
  override convention (the field set is unchanged)
- `reference/hooks.md` — the resume hook, including once-per-session firing
- `reference/agents.md`, `reference/commands.md`, `reference/skills.md`
- `explanation/sentinels.md` — roster 5 → 6
- `skills/sentinel-design/SKILL.md` — the roster table, and the README
  Sentinels section, both of which the skill's own step 5 requires be kept in
  step with the roster

No breaking changes. The parking-record contract is untouched; the reflection
`Closed` field is optional and additive; the resume hook is silent until a
parking record exists.
