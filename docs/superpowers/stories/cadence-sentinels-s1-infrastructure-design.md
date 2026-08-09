---
spec: docs/superpowers/specs/2026-08-08-cadence-sentinels-s1-infrastructure-design.md
date: 2026-08-08
mode: spec
cartographer_model: claude-opus-5[1m]
stories:
  - id: 1
    lens: [forces, patterns]
    title: Prose promoted to a required field
    disposition: accepted
    disposition_rationale: "Deliberate and testable; kept. Spec gains a note naming who may reword the clause and the coordinated-migration cost of doing so, so the brittleness is disclosed rather than discovered."
  - id: 2
    lens: [patterns, consequences]
    title: Observe-only is the resting state
    disposition: accepted
    disposition_rationale: "This is constraint 6 working as intended. The Null Object framing is adopted into the spec: block_absent_note plus block_key's default let consumers run one path, and S2-S5 are told never to branch on absence."
  - id: 3
    lens: [patterns, alternatives]
    title: Sync cadence published before its consumer
    disposition: accepted
    disposition_rationale: "Sync cadence ships, marked reserved in its prose and in the reference page, reusing the placeholder device the spec already invented. An adopter who declares values knows they are inert, so the eventual consumer is not bound by declarations made before its behaviour existed."
  - id: 4
    lens: [forces, consequences]
    title: One keeper per repo, assumed silently
    disposition: accepted
    disposition_rationale: "Resolved structurally rather than by note: pacts move to a user-scoped ~/.claude/pacts.md. A stop hour is a property of the human, not of a repository, and a file with one author and many readers could never answer 'whose pact is this'. The story is dissolved, not carried."
  - id: 5
    lens: [coherence, forces]
    title: A repo's limit against a person's count
    disposition: accepted
    disposition_rationale: "Dissolved by the same move as #4. With pacts user-scoped, limit and count are both person-scoped and the units mismatch disappears; no combination rule is needed because there is only one declaration."
  - id: 6
    lens: [consequences, coherence]
    title: The live harness pinned as fixture
    disposition: accepted
    disposition_rationale: "Largely dissolved by the #4 move -- the live pact file is no longer in the repo, so no deterministic test can pin it. The residue is fixed as proposed: block tests run against fixtures, and no test asserts a value the human is expected to change. Second worked instance of the AGENTS.md:481 pin-a-copy decision."
  - id: 7
    lens: [defaults, consequences]
    title: Twelve untunable hours define liveness
    disposition: accepted
    disposition_rationale: "stale_after_hours becomes a declarable key in the Session WIP block, default 12. Every other threshold in this harness is human-tunable; a slice premised on the human declaring the pacts should not introduce the first one they cannot. The lease-with-heartbeat-renewal naming is adopted into the spec."
  - id: 8
    lens: [defaults, patterns]
    title: Record schemas homed in directory READMEs
    disposition: accepted
    disposition_rationale: "Schemas move to reference/parking-record-format.md and reference/consultation-record-format.md, matching the repo's three existing format pages and actually reaching the published site. The record-directory READMEs point at them rather than duplicating them, which also removes the two-copies problem the story identifies."
  - id: 9
    lens: [coherence, patterns]
    title: Append-only declared, transitions written in place
    disposition: accepted
    disposition_rationale: "State moves into the path: a transition writes a new file rather than editing a key. Append-only and the state read then agree, 'what is still parked' stays a glob, and S2's resume path becomes a write -- which fits the Coda's read-only agent and its command-writes dispatcher."
---

# Choice stories — Cadence Sentinels S1: Shared Infrastructure

Nine stories from a spec that is already unusually decision-complete. Its
divergence notes, its adjudicated objection record, and its explicit
non-goals cover most of what it chose deliberately. These nine concentrate
where that coverage does not reach: the vocabulary the substrate publishes,
the scope its pacts assume, and the numbers and locations it fixed without
naming them as choices. Every one of them binds S2–S5 through the substrate
this slice creates.

**Dispatcher verification note (2026-08-08).** Two citations were checked
before this record was written. Story #6's ARCH_DECISION is real and sits at
`AGENTS.md:481`, promoted 2026-07-22, with the `Skills-36` pin at
`AGENTS.md:487` as its worked example. Story #8's publication claim is
correct: `mkdocs.yml:15-16` carries `exclude_docs: superpowers/`, so a README
in a record directory is committed but never published, unlike the three
`reference/*-format.md` pages it would otherwise sit beside.

## Story #1 — Prose promoted to a required field

**Source:** spec §3.2, §3.3, §3.6
**Lens:** forces, patterns
**Refs:** —

**Context.** §3.3 mandates the literal sentence `Unspent budget is not a
debt.` inside the `Budgets` block's prose body, and §3.2 mandates a matching
clause for `Session WIP`. §3.6 makes a missing mandatory clause one of the
two triggers for the `malformed` state, and B2 tests for the literal string.
English sentences are now parsed data with a state transition attached to
their presence.

**Forces.** A pact declared without its governing sentence can be enforced
against a person who never agreed to the framing — that is the spec's stated
worry, and it is a good one. Pulling the other way: a checker that matches
literal English is brittle to rewording, localisation, a typo fix, or a
markdown reflow, and what it verifies is bytes, not assent. The spec
resolved toward literal-presence checking without naming the brittleness,
and without saying who may reword the clause or how a reworded clause
migrates across adopters.

**Options not taken.**

- Home the normative sentence in `skills/sentinel-design/SKILL.md`, where
  every other normative rule in this epic lives, and leave the block to
  values only. This spec already carries one distinction into that skill
  (§2's BY/ABOUT boundary), so the precedent is in the document itself.
- Make acknowledgement a key — `debt_clause_ack: true` — so the check runs
  against structured data and the prose stays freely editable.
- Check for a stable marker (an HTML comment, a heading anchor) rather than
  the sentence, decoupling wording from detection.

**Choice as written.** The sentence is the unit of both meaning and
detection, and its absence downgrades the entire block to `malformed`.

**Consequences.** The clause becomes an interface. It cannot be reworded,
translated, shortened, or split across lines in any downstream `HARNESS.md`
without the block silently ceasing to read as `declared`. Because
`Session WIP` already carries an equivalent clause, the substrate has
committed to a convention where each block in the sentinel vocabulary ships
English that a script matches — S2–S5 will inherit the expectation. And
since `/harness-upgrade` pushes template content downstream, any future
rewording is a coordinated migration across every adopter rather than a
template edit.

**Pattern.** No catalogue pattern fits cleanly. The closest working frame is
a *checksum on intent* — the sentence functions the way a magic-number
header functions in a file format: its content is meaningful to humans, its
bytes are meaningful to the parser, and the two must not drift. Distant
relative: literate configuration.

**Notes.** The diaboli explicitly declined to object here ("unusual, but it
is deliberate, testable, and directly serves the epic's language
discipline"), which routes the decision to this record rather than that one.

## Story #2 — Observe-only is the resting state

**Source:** spec §3.1, §3.6, §6
**Lens:** patterns, consequences
**Refs:** #1

**Context.** §3.1 ships all three blocks commented out. §3.6 gives absent and
malformed the same behaviour — observe-only, plus a fixed sentence emitted
by the library so every consumer says the same thing. §6 confirms nothing
gates. The only route from absent to declared is a human deleting a `<!--`
fence, or `/harness-upgrade` surfacing the template as adoptable content
(§9).

**Forces.** Progressive hardening (constraint 6) and the plugin's standing
"hook scripts never block, only warn" decision push hard toward opt-in and
silence. Pulling the other way: a substrate nobody opts into does nothing for
anybody — S2, S3, S4 and S5 each degrade to a note. The spec resolved toward
opt-in and then supplied no adoption ramp, which makes observe-only the
expected steady state of a downstream project rather than a transient one.

**Options not taken.**

- Ship the blocks activated in the template with conservative defaults, so
  declaration is the default and opting *out* is the edit. Rejected
  implicitly, and for a good reason the spec states elsewhere (§3.5: an
  imposed default is exactly what the clear-weather rule says does not
  hold) — but the reason is never connected to the adoption question.
- Give each block an authoring dialogue the way S3's Tune authors `Budgets`.
  One of the three blocks gets an authoring path anywhere in S1–S7; the
  other two get none.
- Emit the observe-only note once per project per period rather than once
  per consumer per invocation.

**Choice as written.** Opt-in by uncommenting, with a fixed sentence emitted
per consumer. Chosen substantially by silence: the spec never describes how
a human comes to declare a block.

**Consequences.** The modal downstream experience of the whole Cadence epic
is several sentinels each reporting "no `X` block declared — running in
observe-only mode". The un-adopted project is the noisiest one, and the noise
scales with the number of consumers rather than the number of undeclared
blocks. Because absent and malformed both land in observe-only, an adopter
who half-adopts is behaviourally indistinguishable from one who never
adopted — only the accompanying note differs. S2's and S5's record
directories will exist and stay empty in every project that never opts in.

**Pattern.** **Null Object** (Woolf, *Pattern Languages of Program Design 3*,
1997). `block_absent_note` plus `block_key`'s default argument let every
consumer run one code path whether or not the block exists — that is exactly
the Null Object guarantee, and naming it explains *why* absent and malformed
collapse to one behaviour rather than that collapse being a coincidence. It
also states the library's real contract to S2–S5: consumers never branch on
absence.

## Story #3 — Sync cadence published before its consumer

**Source:** spec §3.4, §3.5, §9
**Lens:** patterns, alternatives
**Refs:** O11, #2

**Context.** §3.4 defines `interrupt_mode` and `sync_points`; §6 states no
S1–S7 sentinel consumes them; §3.5 activates the block anyway in this repo's
root `HARNESS.md`; §9 adds it to the `harness-md-format.md` reference page
that adopters read to learn what may appear in a harness. The spec's stated
reason is vocabulary coherence — splitting the three blocks across slices
would leave the template internally inconsistent.

**Forces.** Template coherence against declaration-without-definition. The
spec names the first force and discloses the trade honestly. What it does not
weigh is the *cost of publication*: once a downstream human writes
`interrupt_mode: coalesced` in good faith, the eventual consumer must honour
a declaration made before any behaviour was defined for it.

**Options not taken.**

- Ship the two consumed blocks now and `Sync cadence` in the slice that
  consumes it. The internal-inconsistency argument is a template-aesthetics
  argument; a template that grows one block per slice is ordinary.
- Ship it in the template but do not activate it here. Activating a block
  nothing reads tests nothing — B1 and B3 only assert that the text exists.
- Ship it with an explicit reserved marker in the block prose, so an adopter
  knows a declaration is inert today. The spec has the machinery for exactly
  this: `authored_via: placeholder` is that device, applied to `Budgets`.

**Choice as written.** Full publication — template, this repo's live harness,
and the public reference page.

**Consequences.** The vocabulary is now a contract with adopters. The future
consumer inherits `interrupt_mode`'s two tokens without having chosen them
and cannot rename or re-enumerate them without a migration — which is
precisely the argument O11 made about `enforcement: strict`. That objection
was accepted and `strict` gained semantics in S1; `interrupt_mode` and
`sync_points` shipped under the same publication risk and gained none. The
cheapest correction — delete the block — is foreclosed the moment an adopter
holds values in it.

**Pattern.** **Published Language** (Evans, *Domain-Driven Design*, 2003) — a
shared vocabulary published ahead of the systems that speak it. The pattern's
own caveat is the material point: a published language is expensive to
change, which is why it is normally published *after* consumers have agreed
on it rather than before the first one exists. Fowler's *speculative
generality* smell also reads on this, though the spec's coherence argument is
a genuine counterweight rather than an excuse.

## Story #4 — One keeper per repo, assumed silently

**Source:** spec §3.2, §3.3, §3.5
**Lens:** forces, consequences
**Refs:** O7

**Context.** §3.2 describes `max_concurrent_sessions` as "this repo's opinion
about your WIP". §3.3 gives `Budgets` a `hard_stop_hour`, `focus_blocks`, and
`sessions_per_day`. §3.5 activates both in this repo's committed root
`HARNESS.md`. §2 settles, per O7, that a declared pact is a statement *by* the
person rather than a claim *about* them. It does not settle *which* person,
in an artefact every contributor clones, reviews, and edits.

**Forces.** A pact that is not durable is not a pact (the spec's argument),
and `HARNESS.md` is the harness's declaration surface, so putting pacts there
is the path of least resistance. Pulling the other way: every value in both
blocks is singular-possessive — one human's stop hour, one human's focus
windows, one human's session ceiling — while the file has more readers than
authors. The spec resolved toward the repo-scoped home without naming that
mismatch.

**Options not taken.**

- A user-scoped pact file (`~/.claude/...`), symmetric with the machine-global
  registry this same spec chose for this same reason — thrash-switching is a
  property of the human, and so is a stop hour.
- A keyed block, so a shared repo can hold several pacts and a sentinel reads
  the current author's.
- Scope the committed blocks to single-keeper repos explicitly in the block
  prose, the way the reservoir block scopes itself with "you edit this block
  yourself".

**Choice as written.** Repo-scoped, committed, single-valued, and
unqualified — chosen by silence. The spec never says who the "you" in "your
WIP" is when the repo has five contributors.

**Consequences.** In a multi-contributor project the pact either belongs to
whoever wrote it — and the others are held to a stop hour they never
declared — or it belongs to nobody, in which case S3's clear-weather rule
cannot be evaluated at all: `authored_via: tune` records *how* the values
came to hold, not *whose* they are. S3 inherits this directly, because Tune
writes over a shared file. Adding an owner dimension later means changing the
block schema after adopters hold values in it. The reservoir block has had
the same shape at one-token scale (`chronotype: intermediate`); S1 scales it
to a full working day, which is where the single-keeper assumption starts to
bind.

**Pattern.** — . The closest useful frame is an aggregate without a root
(Evans, DDD): the pact carries no owner identity, so it belongs to whatever
container it sits in.

## Story #5 — A repo's limit against a person's count

**Source:** spec §3.2, §4.1
**Lens:** coherence, forces
**Refs:** O2, #4

**Context.** §4.1 makes the registry machine-global because thrash-switching
is a property of the human; §3.2 keeps `max_concurrent_sessions` declared
per-repo. The spec states the split in one sentence — "The limit is declared
per-repo; the count it is compared against is global" — and stops. No rule
combines limits when the human is working in more than one declaring repo,
which is the exact situation the global count exists to see.

**Forces.** The count must be person-scoped or it cannot observe cross-repo
concurrency (O2, accepted, correctly). The limit must be repo-scoped because
`HARNESS.md` is the only declaration surface the harness has (see #4). These
two forces pull in opposite directions, and the spec resolves each on its own
terms without resolving the pair — which is what makes this a coherence
story rather than two separate choices.

**Options not taken.**

- Declare the limit where the count lives — a user-level pact — making both
  sides person-scoped.
- Define the combination rule in S1: the effective limit is the minimum
  across declaring repos, or the limit of the repo the new session starts in.
  One sentence in S1; S4 then inherits a defined rule, exactly the move the
  spec already made for `enforcement: strict`.
- Keep both per-repo and accept the undercount, with Note E's `asked`
  fallback as the honest cross-repo answer.

**Choice as written.** By silence. The semantics that falls out of the spec
as written is positional: whichever repo the human is sitting in supplies the
threshold, so the same three live sessions are compliant in repo A (limit 4)
and in breach in repo B (limit 2), and which advisory fires depends on where
the human happens to be typing. Nothing in the spec says this, and nothing in
the spec forbids it.

**Consequences.** The pact's meaning becomes a property of location rather
than of the person who declared it. S4 must invent the combination rule at
implementation time, against declarations already live in the wild — the same
failure shape §1 exists to prevent, transposed from parsers to thresholds. It
also puts quiet pressure on the `Session WIP` mandatory clause: a limit that
changes with the room the human is standing in still "counts and does not
assess", but it advises inconsistently about one underlying state.

**Pattern.** — . Structurally this is a units mismatch: a per-repo scalar
compared against a per-person gauge, with no conversion declared.

## Story #6 — The live harness pinned as fixture

**Source:** spec §3.5, §7.1 B3
**Lens:** consequences, coherence
**Refs:** #4

**Context.** §3.5 activates all three blocks in this repo's root `HARNESS.md`.
B3 asserts, in the Layer 0 deterministic suite, that all three are active
*and* that `Budgets` declares `authored_via: placeholder`. §3.5 also states
that S3's Tune "will overwrite these values and set `authored_via: tune`".

**Forces.** Dogfooding is real, and the spec argues it well — a sentinel
tested only against its own fixtures is tested against nothing. Pulling the
other way: a live artefact under test is an artefact a human can no longer
edit freely, and this particular artefact is the one the entire epic exists
to invite the human to author. The spec resolved toward dogfooding and pinned
a literal without noticing which artefact it had pinned.

**Options not taken.**

- Assert presence and well-formedness of the three blocks in the live
  harness, and assert the `placeholder`/`tune` enum only against a fixture.
  Dogfooding survives; the human's own values stop being assertions.
- Keep live-activation checking out of the deterministic suite and let
  `/harness-audit` report it — the repo's established home for harness-state
  reporting.
- Pin the literal but carry the comment AGENTS.md requires, naming what makes
  it change and why it was not derived.

**Choice as written.** The repo's own declared pact is a test fixture, with
one of its values pinned as a literal whose legitimate change is already
scheduled in a named later slice.

**Consequences.** Editing your own budget block becomes a CI event. The first
act the epic is building toward — S3's Tune writing a real pact — turns B3
red, so the human's experience of authoring their pact is a failing build.
That inverts the sentinel ethic the spec otherwise holds carefully: a
substrate built so nothing gates the person acquires one surface where the
person's own declaration gates the build. It also quietly converts the
reservoir block's "you edit this block yourself" invitation into "you edit
this block yourself, and the suite has an opinion about the result".

**Pattern.** The promoted ARCH_DECISION "harness artefacts derive from the
source of truth — they do not pin a copy of it or re-derive it
heuristically" (`AGENTS.md:481`, promoted 2026-07-22). Its own worked example
is the `Skills-36` guard that went red for the *right* change when the 37th
skill landed — a pin whose legitimate change was foreseeable, from this same
sentinel epic three weeks ago. B3 is the same shape with the change already
on the roadmap.

**Notes.** Routing check applied deliberately: the B3-goes-red event is a
single foreseeable CI failure at a known time, not an undetected class of
failures, so it does not belong in the objection record. What belongs here is
the decision the pin encodes — that the live harness is a tested artefact and
the human's pact is therefore CI-load-bearing.

## Story #7 — Twelve untunable hours define liveness

**Source:** spec §4.2, §4.3, §5.1
**Lens:** defaults, consequences
**Refs:** O1, O4

**Context.** §4.2 retires any registry entry whose `heartbeat` is older than
`SESSION_STALE_HOURS` (default 12). Heartbeats are written only by
`SessionStart` and `Stop`. §4.3 makes any retirement flag every subsequent
count `inferred`, durably and correctly.

**Forces.** Retire too eagerly and a genuinely long-running session vanishes
from exactly the count the WIP Warden exists to take. Retire too slowly and
crashed sessions accumulate as ghosts — and because §4.3's flag is durable,
a ghost does not merely inflate a count, it flags every future count
`inferred` permanently. Twelve hours sits at roughly one working day. The
spec resolves the tension with a number and never states the model of "a
session" that the number encodes.

**Options not taken.**

- Declare the threshold as a key in the `Session WIP` block. Every sibling
  threshold in this substrate's own model — the whole `## Cognitive
  reservoir` block, `window_hours` through `chronotype` — is declared in
  `HARNESS.md` and tuned by the human. `SESSION_STALE_HOURS` is the first
  threshold in this harness the human cannot tune, in a slice whose entire
  premise is that the human declares the pacts.
- Define liveness by process rather than by recency — is the pid alive, is
  the tty open — which needs no threshold, no pruner, and no honesty flag.
- Two-stage retirement (mark suspect, retire later), so `inferred` can
  distinguish "aged out once" from "aged out and never came back".

**Choice as written.** Liveness is *recency of a completed assistant turn*,
capped at twelve hours, in a constant. A session where the human is reading,
thinking, or waiting on a long tool run emits no heartbeat; a session left
open overnight is dead by definition, whatever the human believes.

**Consequences.** Three later slices inherit a definition of "live" that has
no name in the spec. Because the flag is durable, any thirteen-hour gap on
any machine flags every count `inferred` from then on — so the steady state
of the honesty flag on a real developer's machine is plausibly `inferred`
rather than `observed`, which drains information from the signal exactly
where the spec wants it to carry weight. It also puts a clock on the parking
record: §5.1 keys a permanent record to `session` and `repo`, borrowed from a
store that forgets in twelve hours, so S2's resume path can only ever treat
that id as opaque provenance, never as a lookup into the registry.

**Pattern.** **Lease with heartbeat renewal** — the standard
distributed-systems liveness idiom, and the right one; the spec arrived at it
under adversarial pressure (O1) without naming it. Naming it earns something,
because the idiom's known corollaries are precisely the questions left open:
the renewal interval must be comfortably shorter than the lease, and the
lease holder should own its own renewal. Here the renewal interval is
"whenever the agent finishes a turn", which is unbounded above.

## Story #8 — Record schemas homed in directory READMEs

**Source:** spec §5, §7.3 C1
**Lens:** defaults, patterns
**Refs:** O6, O10

**Context.** §5 declares both record schemas in full and states each will be
carried in a `README.md` inside its new directory; C1 tests that each README
contains every field named in §5.1 and §5.2. This repo already has three
homes for a format contract, and S1 chose a fourth — in the same document
that, per O10, adds two `reference/` pages for its other two surfaces.

**Forces.** The schemas must be declared in S1 (O6, accepted), and S1 ships
no agent, so the usual home — the emitting agent's skill, where the diaboli's
objection-record format and the cartographer's own story format live — has no
occupant yet. Pulling the other way: a schema co-located with its data rather
than with its producer is a schema no producer owns. The spec resolved toward
the directory README silently, without weighing the homes the repo already
uses.

**Options not taken.**

- `docs/plugins/ai-literacy-superpowers/reference/parking-record-format.md`,
  matching `affordance-invocation-format.md` and
  `governance-summary-format.md` — the repo's established home for a record
  format that humans and machines both read, and the home §9 uses for this
  slice's other two surfaces.
- The emitting agent's skill, deferred to S2 and S5 — which is precisely what
  O6 ruled out, and rightly.
- `skills/sentinel-design/references/<contract>.md`, the shape the promoted
  contract-ownership decision presumes and the one place in the epic that
  already carries cross-slice normative content (§2's BY/ABOUT boundary).

**Choice as written.** A `README.md` in each record directory — a location
`mkdocs.yml:15-16` excludes from the site via `exclude_docs: superpowers/`,
so unlike every other format contract in the repo, this one is committed but
never published.

**Consequences.** S1 now *owns* two contracts that S2 and S5 consume, which
activates the promoted decision that "a change to a shared/merged contract
gets its own owning slice with its own adversarial pass — a consumer never
mutates the contract it consumes". The first time S2 needs a field the
parking schema lacks, it must carve a contract-owning slice rather than edit
the README. The spec does not say this, and placing the README *inside the
consumer's own output directory* actively invites the opposite reading. C1
also creates two copies of each schema — spec §5 and the README — with a test
asserting the README carries the spec's fields, but nothing keeping §5
current once the README moves on.

**Pattern.** The AGENTS.md ARCH_DECISION on contract-owning slices (sourced
from `stories/cost-estimator-agent-design.md` #5 and
`stories/format-revision-per-stage-cost-design.md` #1). That entry carries an
explicit Rule-of-Three watch item and has one worked instance; S1→S2/S5 would
be the second, which is why recording the applicability now compounds rather
than merely documents.

## Story #9 — Append-only declared, transitions written in place

**Source:** spec §5, §5.1, §5.2
**Lens:** coherence, patterns
**Refs:** O6, #8

**Context.** §5 makes both records append-only per constraint 7: a superseded
entry "gains `status: superseded` and a `superseded_by` pointer, and is never
edited in place or deleted". §5.1 then defines the ordinary lifecycle
transition as "Resuming appends `status: resumed`". Both schemas carry
`status` as a single frontmatter key.

**Forces.** Constraint 7 wants an unerasable history; the records want a
cheaply readable current state — is this session parked or resumed, is this
consultation open. That is the classic event-sourcing versus state-storage
trade. The spec takes both halves: append-only as the stated rule, a mutable
`status` key as the mechanism, without registering that they are in tension.

**Options not taken.**

- Put state in the path — `parked/` and `resumed/`, or a status suffix — so a
  transition is a new file and the append-only rule and the state read agree.
- Genuine append-only: transitions are new records pointing back with a
  `supersedes` field, current state derived by following the chain.
  `superseded_by` already implies this shape for one of the two transitions.
- Drop append-only for these two records and say so. Git history is already
  append-only, which is the argument §2 makes about a different question.

**Choice as written.** A single `status` key edited in place for
`parked → resumed`, and a supersession chain for `→ superseded`. Two
transition mechanisms in one schema, chosen without noticing they are two.
"Appends `status: resumed`" is ambiguous between adding a second `status`
line and editing the existing one; only the second is expressible in YAML
frontmatter, and only the first is append-only.

**Consequences.** S2 must pick one of the two mechanisms at implementation
time, and whichever it picks, "append-only" means something different for the
two states in the same file. §5.2 inherits the tension more sharply: `voices`
is a list inside frontmatter with a per-voice `disposition`, so adding or
disposing a voice mid-review edits an existing record's frontmatter under a
rule that says records are never edited in place. Worth noting that the spec
demonstrates the alternative discipline one field earlier —
`next_action_flag: asked` is a value fixed by policy rather than by
mutation — applied to a single field and not to the state machine.

**Pattern.** **Event Sourcing versus State Storage** (Fowler, 2005) — the
records are specified with event sourcing's rule and state storage's schema.
The coherence angle: §4.3 goes to real trouble to derive the honesty flag
from durable state precisely so it does not depend on read order, and §5 then
stores mutable state its own rule forbids restating. Note also that the
sibling records these two sit beside — objections, stories — dodge the
problem entirely by never transitioning: a human writes a disposition once
and the record is not revisited. So the neighbouring precedent offers S2 and
S5 no guidance here, which is part of why the gap is easy to miss.
