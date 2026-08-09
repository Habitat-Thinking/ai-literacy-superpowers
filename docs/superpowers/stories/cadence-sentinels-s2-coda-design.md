---
spec: docs/superpowers/specs/2026-08-09-cadence-sentinels-s2-coda-design.md
date: 2026-08-09
mode: spec
cartographer_model: claude-opus-5[1m]
stories:
  - id: 1
    lens: [consequences, defaults]
    title: A record per thread, forever
    disposition: accepted
    disposition_rationale: "Retention stated on the record, mechanism deferred to issue #499. Records are permanent and committed because a handoff another person may read is repository content — but that is now a decision in the spec rather than a silence, along with the read-cost note that records_open tracks lifetime history rather than open work. Archival needs its own spec and its own adversarial pass, since S1 owns the contract."
  - id: 2
    lens: [coherence, alternatives]
    title: Closure declared, never leased
    disposition: accepted
    disposition_rationale: "The surfacing becomes the closing affordance: the next /coda asks, per open record, whether it is still live. That is asked rather than inferred, costs the human nothing they were not already being asked at that moment, and stops the parked list being a corpus only an explicit command can ever shrink."
  - id: 3
    lens: [patterns, consequences]
    title: The anchor grammar publishes an ontology
    disposition: accepted
    disposition_rationale: "A sixth anchor kind added — a decision: a question word, a named person, or ask/decide/choose between. The spec's own worked counter-example stops triggering. The reference page also reframes the table as a trigger heuristic whose complement is explicitly not 'vague', so the published grammar stops reading as the house definition of good work."
  - id: 4
    lens: [coherence, consequences]
    title: Honesty flags die at the record
    disposition: accepted
    disposition_rationale: "Provenance moves into the ## Context prose, where the override already lives — no schema change and no contract question — and the spec states plainly that flags are ritual-scoped and records are not provenance artefacts. S5 then inherits an answer rather than reconstructing a precedent from a neighbour that went the other way."
  - id: 5
    lens: [forces, coherence]
    title: The hardest judgement at the tiredest moment
    disposition: accepted
    disposition_rationale: "Propose-and-default-accept. The Coda's grouping stands unless the human changes it. Still asked in the sense that matters, since the human can always overrule, and it costs a depleted person one word instead of a partition. This is the plugin's own reservoir premise applied to its own ritual: the instrument that makes a moment safer should not add its heaviest work to that moment."
  - id: 6
    lens: [consequences, alternatives]
    title: Closed names a count, not records
    disposition: accepted
    disposition_rationale: "The Coda commits the parking records BEFORE invoking /reflect, and Closed names the record filenames rather than a count. Verified at the gate: /reflect stages only reflections/active/ and REFLECTION_LOG.md, so without this the ritual writes records, relocates the tree to main, and leaves them behind uncommitted while publishing a claim about them."
  - id: 7
    lens: [coherence, defaults]
    title: A Coda marker in S1's registry
    disposition: accepted
    disposition_rationale: "The guard keys off S1's existing entry — started_at is per-session and stable across compacts by design (R2) — so no new file class is created in another slice's directory. That removes the co-tenancy, the missing retention path, and the unbounded accumulation against a carve-out whose second condition is bounded."
  - id: 8
    lens: [defaults, consequences]
    title: A repo's CI politics becomes ritual
    disposition: accepted
    disposition_rationale: "The portable reason leads: Closed can only name what parking produced, which holds in every repository. The PR-workflow constraint becomes the local fact that makes the order non-negotiable here rather than the headline justification. Without that ordering a downstream maintainer reads the paragraph as a workaround for someone else's CI, which is precisely when a fixed order gets quietly reordered."
---

# Choice stories — Cadence Sentinels S2: The Coda

Eight stories from a spec that argues its explicit decisions unusually well.
The ritual reorder, the demoted check, the prose-body override, the per-item
flags, the once-per-session guard, the resume path, and the epithet narrowing
are all adjudicated on the objection record and reasoned in the spec's own
prose; none is restated here. These eight sit where that coverage stops: what
the records look like as a corpus rather than as artefacts, what the anchor
table teaches when read as a definition, where provenance stops travelling, and
which of S2's decisions S3–S5 will inherit without being told they are
inheriting anything.

**Dispatcher verification note (2026-08-09).** Two citations were checked
before recording. `commands/reflect.md:160` stages
`reflections/active/ REFLECTION_LOG.md` only — no parking-record path — so the
ritual's own reflection step does not commit the records the `Closed` field
describes, and then relocates the tree to main (story #6). And
`commands/reflect.md:131-133` enumerates exactly eight mandatory fields, so an
absent optional ninth is undetectable there (story #6).

## Story #1 — A record per thread, forever

**Source:** spec §2.2, §2.5, §6 · **Lens:** consequences, defaults

**Context.** The ritual writes one parking record per live thread, committed,
append-only, closed by writing a second file rather than deleting the first. S2
is the first producer for a directory S1 created and left empty.

**Forces.** Per-thread granularity makes each next action self-contained and
lets `records_open` answer "which threads" rather than "which sessions" —
genuinely the right unit. Pulling the other way, the corpus grows as sessions ×
threads, and a parked-then-resumed thread leaves at least two files behind
permanently. §6 discloses the ritual's unbounded *length*; the same force at a
longer time scale — the corpus's unbounded *size* — is not raised at all.

**Options not taken.**

- One record per session carrying a thread list. Fewer files, at the cost of
  per-thread resume ergonomics.
- Records outside the work tree, as S1 put the registry and the pact file, on
  the same reasoning that a person's operational residue is not repository
  content. S2 keeps them committed — defensible, since a handoff someone else
  may read is repo content — but the spec never states the choice.
- Adopt the reflection corpus's archival machinery from day one: `active/`
  plus `archive/<YYYY>.md` and a weekly GC rule, which this repo already runs
  and already specified.

**Choice as written.** Per-thread, committed, permanent — with retention,
archival, and GC all chosen by silence.

**Consequences.** This is the repo's first committed corpus keyed to *moments*
rather than to durable artefacts. Objections and stories grow one file per spec
and stay relevant; a parking record's value drops to zero the moment its thread
resumes, and it stays in the tree and in every clone regardless. Over months the
directory becomes the densest available account of when work was left unfinished
and how often — assembled from individually innocuous artefacts, which is the
aggregation shape O5 refused at field level and which the spec does not
re-examine at corpus level. Operationally, `records_open` scans and greps the
whole directory on every session start, so read cost tracks lifetime history
rather than open work; and the filename slug is the corpus's only human-readable
index, with nobody in the spec assigned to author it.

**Pattern.** An append-only log without a compaction story. The repo has solved
this shape once already, for reflections, with the fragment/archive split and a
GC rule — which makes the omission a decision to dispose of rather than an
oversight to discover in six months.

## Story #2 — Closure declared, never leased

**Source:** spec §2.5, §7.2 P3 · **Lens:** coherence, alternatives · **Refs:** O9, #1

**Context.** `/coda resume <record>` is the only thing that ever closes a
parking record. The spec argues carefully for why the resume path must exist in
this slice; it does not argue for why it is the only path.

**Forces.** The BY/ABOUT boundary genuinely forbids the Coda from concluding a
thread is finished — that would be an agent-authored claim about the person's
work. Against that: *resuming work* and *declaring you resumed it* are different
acts, and only the second is wired to anything. The spec resolves toward
declaration and never states what keeps the declaration happening.

**Options not taken.**

- Make the surfacing the closing affordance: the hook already prints the open
  list, and the next `/coda` could ask, per record, whether it is still live.
  That is `asked`, honest, and costs a human nothing they were not already
  being asked at that exact moment.
- Give records a lease, as S1 gave registry entries: an untouched record ages
  to a `stale` state. State-in-the-path already supports a third suffix.
- Close implicitly on an observable signal — a commit touching the next
  action's anchor path. Rejectable on honesty grounds, but it is the option the
  anchor grammar quietly makes available and it is not weighed.

**Choice as written.** Closure by explicit command, and by silence about
everything else.

**Consequences.** One epic now carries two opposite liveness models on one
substrate. S1's registry is a lease: a session stays live only by renewing, and
forgetting costs nothing because the lease expires. S2's corpus is the inverse —
a thread stays open by default and only bookkeeping closes it. The failure of
forgetting is opposite in each: the registry undercounts, the parked list
overcounts, and the overcounting one is what a human sees at every session
start. S3–S5 will each face this question, and whichever neighbour they read
first supplies their default.

**Pattern.** Lease-with-heartbeat-renewal against explicit lifecycle
transition. Both are correct patterns; having both in one substrate with no
stated rule for which applies is the coherence gap.

## Story #3 — The anchor grammar publishes an ontology

**Source:** spec §3.3, §3.4, §3.5 · **Lens:** patterns, consequences · **Refs:** O6, O7

**Context.** §3.3 states five anchor kinds exactly, and §3.5 reproduces the
table verbatim in the skill and the reference page so a human who is asked can
see why.

**Forces.** Arguability against reach. A rule whose decisive term lives only in
the implementation cannot be argued with, and the spec is right to pay for
publication. What it does not weigh is that publishing a rule also publishes a
definition of *good*: this table becomes the only written statement in the
plugin of what a concrete next action looks like, and all five kinds are
artefacts of code-shaped work.

**Options not taken.**

- Publish the worked examples from §3.1 rather than the token grammar — same
  arguability, and the implementation stays free to change.
- Add a non-code anchor kind: a named person, a decision verb, a question. The
  spec's own worked counter-example — "ask Russ whether the reserved block
  should ship at all" — is a shape the grammar could recognise and does not.
- Publish the table explicitly as a trigger heuristic whose complement is *not*
  "vague". §3.4 nearly does this; the reference page does not carry the framing.

**Choice as written.** Publish the token grammar verbatim, in two places, as
the definition the human is entitled to argue with.

**Consequences.** O7's systematic bias survives its own disposition, changed in
kind rather than removed: demoted to a trigger it renders no verdict, but it
still taxes one class of work with an extra question at closing time, now from a
published table that reads as the house definition of a concrete next step. Two
second-order effects. A human who reads the rule learns that backticking any
phrase silences it, so the disclosure ships the bypass with the rule — harmless
while the check only decides whether to ask, and worth knowing before any later
slice tries to make an anchor load-bearing. And S3–S5 inherit this table as the
epic's only vocabulary for specificity, in a plugin whose own work is mostly
specs, prose, and decisions.

**Pattern.** **Published Language** (Evans, *Domain-Driven Design*, 2003) — the
same pattern S1's story #3 named for `Sync cadence`, with the same caveat: a
published language is expensive to change. Here it is published in two documents
and pinned by seven scenarios before a single record has been written against it.

## Story #4 — Honesty flags die at the record

**Source:** spec §2.1, §2.2, §4 · **Lens:** coherence, consequences · **Refs:** O4, O5

**Context.** §2.1 replaces a blanket `observed` with per-item flags. §2.2 then
writes records whose only honesty field is `next_action_flag: asked`, a constant
fixed by S1's contract. The per-item flags exist in the ritual's conversation
and nowhere afterwards.

**Forces.** S1 §4.3 went to real trouble to make its flag a durable property of
the count rather than of the reader, precisely so uncertainty is not disclosed
to whoever read first and hidden from everyone after. S2's flags are the
opposite shape — computed per survey, shown once, discarded at write time.
Pulling the other way, S1 owns the parking-record contract and §4's own rule
says a consumer does not mutate what it consumes: persisting provenance would
have cost S2 a contract-owning slice. The spec takes the cheaper path without
naming the trade.

**Options not taken.**

- Carve the contract slice. §4 demonstrates the move one section later for the
  reflection fragment, so the spec plainly knows how.
- Record provenance in the `## Context` prose, where §3.4 already puts the
  override. No schema change, no contract question, and the human can see it.
- State explicitly that flags are ritual-scoped and records are not provenance
  artefacts, so S5 inherits an answer rather than a precedent.

**Choice as written.** By silence. Nothing says the flags stop at the record,
and nothing carries them across.

**Consequences.** A thread surveyed while `gh` was unavailable produces a record
indistinguishable from one surveyed cleanly; the honesty reaches the person
present at the close and nobody after. The epic ends up with two contradictory
precedents in the same directory tree: S1's consultation record carries a
per-voice `source_flag`, so S5's records *will* persist provenance, while S2's
will not. Worth noting which part of the record the flag does cover — the next
action, the one thing that came from the human — while the `## Context`
paragraph, a permanent committed agent-authored claim about the state of the
work, carries no flag and is the part `sentinel-design`'s two tests were never
run against.

**Pattern.** — . The closest frame is lineage computed and then dropped: the
survey derives provenance for the transform and discards it before the load.

## Story #5 — The hardest judgement at the tiredest moment

**Source:** spec §2.1, §6 · **Lens:** forces, coherence · **Refs:** O4, #4

**Context.** Thread grouping is `asked`, and the spec names it "the Coda's
central epistemic act": the Coda proposes a grouping and the human confirms or
regroups. §6 declines to cap ritual length and notes the cost scales with the
mess found, "at exactly the moment the human wants to stop".

**Forces.** Constraint 3's honesty — the grouping is a judgement, so it cannot
be flagged `observed` — against this plugin's own model of end-of-session
capacity. The plugin ships a `reservoir-warden` whose entire premise is that
judgement degrades across a session. The Coda places a synthesis task —
partition N modified files into threads, then name and justify each — at the
point the human has already decided they are finished. Both forces belong to
this epic; the spec names one.

**Options not taken.**

- Propose-and-default-accept: the Coda's grouping stands unless the human
  changes it. Still `asked` in the sense that matters — the human can always
  overrule — and it costs a depleted person one word instead of a partition.
- Flag the grouping `inferred` and let the resume path correct it. A disclosed
  inference is not a laundered one, and the correction lands when the person is
  fresh.
- Group by an observable proxy — commit adjacency, directory, mtime — and ask
  only about the residue that does not fall out cleanly.

**Choice as written.** A full human partition, every session, uncapped, before
any record can be written.

**Consequences.** The grouping decision is where §6's unbounded ritual length
actually comes from: the number of records, of next-action prompts, and of
anchor-check triggers all fall out of it. Nothing refuses, so the escape is
always available and cheap — a depleted human groups everything as one thread
and writes one vague next action, the check asks once, and the answer is parked.
The Coda therefore degrades toward a single low-value record rather than toward
resistance, and it degrades hardest on exactly the sessions whose handoff would
have been worth the most. S3 inherits this shape at the moment it makes the
ritual fire on a trigger rather than on request.

**Pattern.** — . Structurally this is the checklist paradox: the instrument that
makes a moment safer adds work to that moment, and the work lands on whoever is
least equipped to do it. The usual mitigation is to pre-compute the default and
ask only for the correction.

## Story #6 — Closed names a count, not records

**Source:** spec §2, §2.3, §4.1 · **Lens:** consequences, alternatives · **Refs:** O1, O2, #4

**Context.** The reorder makes `Closed` writable after parking, and its stated
content is "what landed this session; what was parked, and how many". It is
optional, free prose, supplied only by the Coda's invocation, and it travels
into `REFLECTION_LOG.md` — a generated, committed, published aggregate.

**Forces.** The field must be cheap and additive or it becomes a real change to
a contract S2 does not own; it must also be the ritual's terminal cue, since
closure needs an artefact. Cheapness won. What that bought — a field asserting
that three threads were parked without saying which three — is not named as a
cost.

**Options not taken.**

- Carry record filenames rather than a count, making the claim resolvable
  against `records_open` and giving a future reader a route from a reflection
  entry to the work it closed.
- Carry only what landed, and let `records_open` answer what is parked.
- Make the field mandatory in the Coda's fragment and extend `/reflect`'s
  validation checkpoint, which enumerates exactly eight mandatory fields and
  therefore cannot notice a missing ninth.

**Choice as written.** Free prose, optional, unvalidated, carrying a count.

**Consequences.** The reflection log becomes the durable, published trace of a
session's close, and the one cross-artefact claim it makes is the one nothing
can check. The reorder that made a truthful count possible is also what set the
two artefacts on different durability paths: `/reflect` branches, commits,
pushes, merges and pulls main while staging only `reflections/active/` and
`REFLECTION_LOG.md`, so the parking records the field describes remain
uncommitted in a tree the same command has just relocated to main. No step in
this spec commits a parking record and no slice is assigned to — the claim
reaches main by design, and the records it names reach main by whatever the
human does next. Trusting `Closed` therefore means trusting the count, not the
corpus.

**Pattern.** — . The shape is a denormalised summary without referential
integrity: a count held in one artefact about rows in another, with no key and
no reconciliation path. The cheap fix — store the ids — stays cheap only until
adopters hold fragments carrying the field.

## Story #7 — A Coda marker in S1's registry

**Source:** spec §2.5, §5 · **Lens:** coherence, defaults · **Refs:** O8, #2

**Context.** The once-per-session guard is "a per-session marker under the S1
registry directory" — `~/.claude/sessions/`, the machine-global store S1 built
for the WIP Warden's count, and the worked example in `sentinel-design`'s
operational-state carve-out.

**Forces.** The marker must be per-session, survive a compact, and live outside
every work tree; S1 built a directory with exactly those properties, so reuse is
the cheapest correct answer. Pulling the other way, that directory is not
general scratch space — it is a carve-out artefact permitted only while all four
of `sentinel-design`'s conditions hold, and §4 of this very spec establishes
that a consumer does not silently extend what another slice owns. The spec
applies that discipline to the reflection fragment one section later and not to
this.

**Options not taken.**

- Home the marker in the Coda's own state location, so the carve-out's four
  conditions are evaluated on its own terms rather than inherited.
- Key the guard off S1's existing entry: `started_at` is stable across compacts
  by design (R2) and is already per-session, so no new file is needed.
- Use the `source` field the hook receives and fire only on `startup` and
  `resume` — the smaller of the two fixes O8 named, leaving no residue at all.

**Choice as written.** A new file class in another slice's directory,
established in one clause and tested only for its behaviour (H5, H6), never for
its lifecycle.

**Consequences.** The registry's only removal path is the lease pruner, which
retires `*.json` by heartbeat and sweeps `*.tmp` older than the lease. An
artefact in neither shape has no removal path, so markers accumulate one per
session for the life of the machine — against a carve-out whose condition 2 is
*bounded*, with its own note that "a record with no expiry is an archive, and an
archive of where someone worked is a surveillance artefact whatever it was built
for". S1 set the inherited default with the undeleted `.retired` marker; S2 is
the second instance and the first that is one-file-per-session. The directory now
has two owning slices and one documented purpose, and any future change to the
registry's layout must account for a consumer S1 never knew about.

**Pattern.** — . The frame is co-tenancy in a bounded store: a second writer
inherits the store's location guarantees without inheriting its retention
contract, and the retention contract is the part the carve-out turns on.

## Story #8 — A repo's CI politics becomes ritual

**Source:** spec §2, §5 · **Lens:** defaults, consequences · **Refs:** O1, #6

**Context.** "The same sequence every invocation, no reordering." The order S2
fixes — park before reflect — is derived primarily from this repository's
`Reflections via PR workflow` constraint. The ritual ships in a plugin, and
`commands/reflect.md:153` already branches: where that constraint is not
declared, `/reflect` commits directly to the current branch and moves nobody's
tree.

**Forces.** A ritual with a stable order is one a person can learn, and fixing
one is right. Against that, the order's headline justification is an
environmental fact about a single adopter. The spec resolves toward a universal
fixed order and never marks which of its two reasons travels and which does not.

**Options not taken.**

- Lead with the portable reason — `Closed` can only name what was parked if
  parking precedes it, which holds in every repository — and state the git
  reason second, as the local fact that makes the order non-negotiable *here*.
- Make the order conditional on the constraint, mirroring the branch
  `commands/reflect.md` already makes for the same constraint.
- Take reflection out of the ritual entirely: the Coda emits the closure summary
  and the human carries it into `/reflect` whenever they choose, which also
  removes the ritual's dependency on a network round trip and a green CI run.

**Choice as written.** One fixed order, justified primarily by a constraint most
adopters will not have declared.

**Consequences.** In this repository the record is excellent — §2 names the
constraint, the command, and the line numbers. Downstream, that same paragraph
reads as a workaround for someone else's CI, which is the precise condition
under which a fixed order gets quietly reordered by a maintainer who believes
they are removing dead weight. The portable justification does exist, but it
appears second, in a sentence beginning "The reorder pays a second dividend" —
phrasing that marks it as a bonus rather than as the load-bearing reason it
becomes the moment the constraint is absent. This also sets the template for
S3–S5: each will fix its own ritual against this repo's harness, and the epic
has no convention for marking which parts of a ritual are environmental.

**Pattern.** — . The frame is a workaround promoted to a rule: a sequence
encodes an accidental property of one environment and is published as an
essential one. The practical test, worth writing into `sentinel-design` if this
story is promoted, is whether a ritual step's stated justification still reads as
a justification in a repository that does not share the constraint.
