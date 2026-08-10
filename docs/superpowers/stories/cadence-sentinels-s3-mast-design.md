---
spec: docs/superpowers/specs/2026-08-10-cadence-sentinels-s3-mast-design.md
date: 2026-08-10
mode: spec
cartographer_model: claude-opus-5[1m]
stories:
  - id: 1
    lens: [forces, coherence]
    title: Re-authoring everything to change one value
    disposition: accepted
    disposition_rationale: "Tune gains an amendment path. It reads the human's current declared values back as the question's context — not a proposed default, since what is shown is their own prior authorship rather than the template's illustration — and /mast tune <block> scopes an edit to one block. The mirror the spec names already works this way: /reservoir tune reads the current block first. Without this the cheapest way to change one number is the editor, which is exactly the channel the weather check cannot see."
  - id: 2
    lens: [patterns, coherence]
    title: Consent per value, not per artefact
    disposition: accepted
    disposition_rationale: "Tune composes the block from the answers, shows it, and takes accept / edit / abort before writing. Per-value confirmation stays, but there is now a point at which the whole pact can be refused — including the parts the human did not author, the mandatory clause and the stamps, which are also the parts that decide whether the block reads as declared. This makes Tune an instance of the agent-emit / dispatcher-persist / human-disposes architecture rather than a citation of its tool split."
  - id: 3
    lens: [alternatives, consequences]
    title: A verified reader, an improvised writer
    disposition: accepted
    disposition_rationale: "A validation checkpoint is added, and this turned out to be a convention violation rather than an option not taken: CLAUDE.md requires one of every command producing structured output that downstream consumers parse, and /mast tune produces the file pact-blocks.sh parses. After writing, Tune reads the block back, asserts block_state returns declared, and fixes in place. A write-side library is deliberately not built here — the checkpoint plus T1-T7 closes the runtime gap, and a pact-write.sh belongs with a slice that has more than one writer to serve."
  - id: 4
    lens: [forces, defaults]
    title: Asking everything, anchoring nothing
    disposition: accepted
    disposition_rationale: "The no-defaults rule stands; the empty-form cost is paid down differently. Tune asks the stop hour first — the one key that carries the epic and the one a person can answer cold — then offers to stop there, so a complete two-line pact is reachable in one question. The remaining keys are offered rather than marched through. Skipping a whole block was the only cheap exit, and it returns the human to observe-only, which is the state the epic exists to move them out of."
  - id: 5
    lens: [forces, consequences]
    title: A gauge with one working needle
    disposition: accepted
    disposition_rationale: "Read mode recites the pact first and annotates second. Section 1's own argument is that a pact nobody reads is not a pact, which makes re-reading the intervention — so the human's own declared words lead, and what can and cannot be measured follows as annotation. The honest position is unchanged; what changes is that the report stops reading as an inventory of the plugin's limits. Records the definitional consequence too: in this epic a budget is a declaration to be recited, not a quantity to be metered."
  - id: 6
    lens: [patterns, coherence]
    title: Sole writer of another slice's schema
    disposition: accepted
    disposition_rationale: "Tune derives the mandatory clauses and the reserved marker from the shipped template rather than restating them, per the promoted derive-from-the-source-of-truth decision — the spec had them in a third place, agreeing with pact-blocks.sh only because one string happens to contain the other. The stamps go back to Budgets only, where S1's grammar defines them; rule 4 had extended them to two blocks S3 does not own. And sentinel-design gains the writer role the epic's vocabulary lacked, so S4 knows that extending Tune's key set is a change to S3."
  - id: 7
    lens: [coherence, consequences]
    title: Inertness disclosed for one block only
    disposition: accepted
    disposition_rationale: "Disclosure moves from block level to the condition that triggers it. Tune says what nothing reads yet wherever that is true — Sync cadence entirely, three of Session WIP's four keys until S4 ships, and notification_policy_after_stop at the Unverified rung. The human was otherwise authoring their first pact under two regimes without being told there were two, warned about inert values in one block and not in the next."
  - id: 8
    lens: [consequences, alternatives]
    title: Nothing points at the only door
    disposition: accepted
    disposition_rationale: "Read mode offers Tune when the block is absent, exactly as /reservoir read does — said in the command's own prose, so S1's fixed observe-only sentence is untouched and no contract is carved. The slice's entire stated value was that Tune unblocks the epic, reached by a command nothing mentioned. Section 1's opening paragraph is also rewritten: it still promised the ritual offered at the line, which revision 2 moved to #501 and neither kept nor withdrew."
---

# Choice stories — Cadence Sentinels S3: The Mast

Eight stories from a spec already cut in half at its diaboli gate. The split,
the weather check's disclosed blind spot, the flag corrections, the refusal to
estimate spend, and Tune's write rules are all adjudicated on the objection
record; none is restated here.

These eight sit where that coverage stops — around the ritual's *shape* rather
than its output. Six turn on one under-examined fact: `/mast tune` is now the
only way a pact comes to exist, and the spec specified what it writes without
specifying what it *is* — an author, an editor, a form, or a conversation.

**Dispatcher verification note (2026-08-10).** Two citations were checked
before recording, and one of them changed the disposition. `CLAUDE.md:174`
requires a validation checkpoint of "every command that produces structured
output parsed by downstream consumers" — `/mast tune` produces the file
`pact-blocks.sh` parses, so story #3's checkpoint is a **convention
violation**, not an option not taken. And `commands/reservoir.md:31-35` has
read mode "offer Tune mode to add the block" when it is absent, which is the
direct precedent story #8 asks S3 to follow.

## Story #1 — Re-authoring everything to change one value

**Source:** spec §2, §2.3, §5 · **Lens:** forces, coherence · **Refs:** O5

**Context.** Tune walks all three blocks, rewrites in place, proposes nothing
as a default, and makes every block skippable. Nothing describes reading the
human's *existing* values back to them. So the only sanctioned way to move
`hard_stop_hour` from 18:30 to 19:00 is to re-run the ritual that asks every
question again.

**Forces.** Authorship-is-the-active-ingredient against the ergonomics of
amendment. A pact is meant to be lived with and revised in clear weather —
§2.2 names the calm Tuesday tweak as "the authorship the rule *wants*" — so
the honest revision path needs to be cheaper than the dishonest one, not more
expensive. The mirror the spec names points the other way: `/reservoir tune`
reads the current block first and presents a diff to confirm. That is an
editor; `/mast tune` as specified is an author.

**Options not taken.**

- Read the current declared value back as the question's context. That is not
  a proposed default: nothing is pre-filled by the plugin, and what is shown is
  the human's own prior authorship rather than the template's illustration.
- A block-scoped invocation — `/mast tune budgets` — so amendment costs one
  block rather than three.
- Diff-and-confirm before the write, as `/reservoir` does.

**Choice as written.** Tune is an authoring ritual, and by silence there is no
amendment ritual. Rewrite-in-place makes re-running *safe*, which is precisely
what makes re-running the amendment path.

**Consequences.** The cheapest way to change one number becomes opening the
file in an editor — the channel §2.3 concedes and §2.2 says the weather check
cannot see. The disclosure of that blind spot is right; this choice quietly
increases the traffic through it. The file Tune writes also carries less
guidance than the template it supersedes: §5 requires the clauses, the marker
and the stamps, and requires nothing of the template's warning that an inline
`#` comment silently becomes part of a value. The human most likely to
hand-edit is doing so in a file that no longer carries that warning.

**Pattern.** CRUD's missing **U**: a lifecycle specified for create and
replace, with update delegated to the filesystem. The interaction-design
sibling is wizard-versus-preferences — a wizard is right for first authorship
and famously poor for changing one field later.

## Story #2 — Consent per value, not per artefact

**Source:** spec §4, §5 · **Lens:** patterns, coherence · **Refs:** O7, #1

**Context.** §4 keeps the tool boundary — the agent holds no `Write`, the
command writes — and cites the `cost-estimator` precedent. But in tune mode no
agent appears at all: the command asks the questions and writes the file, "only
after the human has confirmed each value".

**Forces.** The promoted architecture is agent-emit + dispatcher-persist +
human-disposes. S3 keeps the tool boundary and drops the emit step: no artefact
is ever placed in front of the human to dispose over as a whole. Pulling the
other way, per-value confirmation is arguably *stronger* consent — the human
agrees to each number as they author it. The spec resolves toward per-value and
never names the unit-of-consent question it has answered.

**Options not taken.**

- Compose the block, present it, and take accept / edit / abort — the
  vocabulary `/cost-estimate` shipped.
- Let the `mast` agent author the block text and have the command persist it,
  making Tune an *instance* of the named architecture rather than a citation of
  its tool split.
- Keep per-value confirmation and add a read-back of the file as written.

**Choice as written.** Consent is per value. The citation names the boundary
Tune keeps — the agent does not write — and not the flow it inverts: in the
cited precedent the agent *authors* the content and the command only persists.

**Consequences.** The parts of the file the human did not author — the mandatory
clause, the reserved marker, `authored_at`, `authored_via` — are also the parts
that decide whether the block reads as `declared`, and they are never seen
before they land. There is no point at which the *whole* pact can be refused.
And the named architecture acquires an instance that honours its tool split
with no agent in it, which weakens the pattern's claim to describe a shape
rather than a permission.

**Pattern.** The agent-emit / dispatcher-persist / human-disposes
ARCH_DECISION, invoked in part. Structurally, the wizard again: consent as a
sequence of small local agreements rather than one review of the composite.

## Story #3 — A verified reader, an improvised writer

**Source:** spec §4, §5, §6, §7.2 · **Lens:** alternatives, consequences · **Refs:** O7, #2

**Context.** S1 built `pact-blocks.sh` as the single reader, with a long
preamble and ten scenarios. S3 ships "No hook. No library." The producer of the
file that library parses is a prose dialogue following six numbered rules.

**Forces.** A slice of one agent, one skill, one command is small and
reviewable. Against that: the format has literal-string requirements,
position-sensitive semantics, and a failure mode that is silent *by design* —
malformed collapses to observe-only. The one component that produces the file
is the one with no deterministic implementation. §5 names the stakes exactly
("Tune is what makes it wrong") and answers with rules and scenarios rather
than with a mechanism.

**Options not taken.**

- A write-side library, `pact-write.sh`, sourceable only by commands and hooks
  — a split `sentinel-design` already blesses.
- The repo's codified validation checkpoint: read the block back, assert
  `block_state` returns `declared`, fix in place. **`CLAUDE.md:174` requires
  this of every command producing structured output that downstream consumers
  parse.** `/reservoir tune` has one; `/mast tune` was specified without.
- Write by transforming `templates/pacts.md`, so the clauses and marker come
  from the source of truth rather than being re-typed from the spec.

**Choice as written.** Correctness established at CI time against named
scenarios, and at runtime by a model following six sentences.

**Consequences.** T1–T7 pin the shapes they name; anything the dialogue does
that they do not name is unconstrained at runtime, and the human's symptom of a
deviation is the one S1 worked hard to make quiet. The asymmetry is durable:
this epic now has a read path with a library, a preamble and ten tests, and a
write path with a numbered list. #501 and every later slice that touches the
file inherits the prose, not a writer.

**Pattern.** The missing half of a **Parser / Unparser** pair. The standard
remedy is a round-trip property, and T1–T7 are a partial one — a round trip
over the values the scenario author thought of, on a format whose worst input
is the one nobody imagined.

## Story #4 — Asking everything, anchoring nothing

**Source:** spec §5 rules 5–6, §7.3 · **Lens:** forces, defaults · **Refs:** #1

**Context.** Rule 5 forbids proposing anything as a default and demotes the
template's numbers to "illustrations"; rule 6 makes every block skippable. The
diaboli explicitly declined to object here, which routes the decision to this
record.

**Forces.** An imposed default is not a pact — correct, and the epic's founding
claim. Unweighed against it: a person asked cold for `max_switches_per_hour`
has no basis for an answer, and a number invented to move the dialogue along is
not obviously more *authored* than one recognised and adjusted. The ritual is
also long — three blocks, eleven-plus keys — and the only escape rule 6 supplies
is skipping a whole block.

**Options not taken.**

- Distinguish a **default** (written unless refused) from an **anchor** (shown,
  never written unless said). The template already carries illustrative values;
  only Tune is forbidden from mentioning them.
- Ask the one question that carries the epic — the stop hour — and offer the
  rest.
- Ask by intent rather than by field: "when do you stop?", and let Tune render
  the keys.

**Choice as written.** Every key asked cold, and the only cheap answer is to
skip the block.

**Consequences.** The ritual's most available exits are "skip" and "say a number
to move on"; skipping produces `absent`, which returns the human to
observe-only — the state the epic exists to move them out of. The design leans
hardest on new users, who have least basis for any of these numbers, and the
pact most likely to be authored is the shortest one. S2's story #5 named this
shape at the Coda; here it lands at the start of the relationship rather than
the end of a session.

**Pattern.** The **empty-form problem** in form design: a blank field maximises
freedom and minimises completion, and the standard remedy is the example rule 5
forbids. Naming it does not argue against the rule; it names the bill the rule
is paying.

## Story #5 — A gauge with one working needle

**Source:** spec §2.1, §7.1, §7.3 · **Lens:** forces, consequences · **Refs:** O6

**Context.** Of the four keys tabled, one is `observed`, two are `inferred`,
and one is *not observable*. The corrections O6 forced are right. What they
leave is a report whose majority content is disclosure of blindness.

**Forces.** Honesty against usefulness. The spec resolves wholly toward honesty
— the refusal to estimate spend is its strongest paragraph. What it does not
weigh is what the resulting artefact is *for*. "Consumption against a budget"
is the stated job and it can be computed for exactly one key.

**Options not taken.**

- Report the pact's own words first and the flags second, treating recital as
  the product and measurement as the annotation. §1's argument is that a pact
  nobody reads is not a pact, which makes *re-reading* the intervention.
- Report only what is observable, and say once that the rest is declared and
  unmeasurable.
- Carry the unmeasurable keys in the reference page rather than in every
  invocation.

**Choice as written.** A per-key table where every declared key appears and
three rows in four exist to state what the Mast cannot see.

**Consequences.** In the modal case the honest report reads as an inventory of
the plugin's limits rather than as a gauge, and a human who runs `/mast` twice
in a day learns that only the clock row moves. That is the price of the
position, not an argument against it — the alternative being refused is the
fabricated number, which is worse. The more durable effect is definitional:
this fixes what a budget *is* in this epic — a declaration to be recited, not a
quantity to be metered — and every later sentinel inherits that framing.

**Pattern.** — . The nearest frame is the honest-instrument discipline the repo
runs twice already. S3 is the first place where applying it faithfully leaves
the instrument with one working needle, which is worth recording as a known
shape rather than rediscovering as a disappointment.

## Story #6 — Sole writer of another slice's schema

**Source:** spec §5, §7.2 · **Lens:** patterns, coherence · **Refs:** O7, #3

**Context.** S1 owns the pact file's schema. S3 owns the only path that writes
it. §5's rules restate parts of that schema in a third place, and rule 4 stamps
`authored_at`/`authored_via` on *every block written* — keys S1's grammar
defines only inside `Budgets`.

**Forces.** A consumer never mutates the contract it consumes; harness
artefacts derive from the source of truth rather than pinning a copy. Tune is
neither consumer nor owner — it is a *writer*, a role the epic's vocabulary
does not have. Pulling the other way, restating is what makes §5 followable: a
rule saying "write whatever S1 §3.4 says" is not one an implementer can
execute.

**Options not taken.**

- Derive: take the clause text from `templates/pacts.md` or `_mandatory_clause`
  so a schema change reaches the writer without a spec edit.
- Name the third role in `sentinel-design` — schema owner, sole writer, readers
  — and state that a schema change obliges the writer's slice.
- Leave the stamps where S1 put them and say so.

**Choice as written.** The schema is restated where Tune needs it, extended for
two blocks, and nothing links the copies. §5 quotes the `Session WIP` clause in
full while `pact-blocks.sh` matches only its second sentence — they agree today
because one string contains the other, which is a coincidence of wording rather
than a derivation.

**Consequences.** S4 and S5 inherit a file whose only authoring path is
specified in a slice they do not own. When S4 wants `enforcement` declared, the
question "does Tune ask about it?" has no answer here, and the natural fix —
extend the ritual — is a change to S3's command made from a consumer slice. A
pact may also carry three `authored_at` stamps while the weather check reads
one, so "when was this pact authored" becomes a per-block fact with no rule for
combining them.

**Pattern.** The contract-owning-slice ARCH_DECISION meeting a role it does not
name. The derive-from-source-of-truth decision is the repo's own remedy and is
not applied.

## Story #7 — Inertness disclosed for one block only

**Source:** spec §2, §2.1, §2.3, §5 · **Lens:** coherence, consequences · **Refs:** #6

**Context.** Rule 2 requires Tune to say `Sync cadence` is reserved before
asking, "so nobody declares values believing something reads them". Tune also
walks `Session WIP`, whose consumer does not exist; of its four keys only
`stale_after_hours` is read today, by S1's registry lease. Read mode reports
against `Budgets` alone.

**Forces.** The disclosure principle is right and stated with unusual clarity.
Against it: the property that triggers it — a declaration nothing reads — is a
property of *keys at a point in time*, not of blocks. The spec applies it at
block granularity because that is the granularity at which S1 happened to
supply a reserved marker.

**Options not taken.**

- Say the same sentence about `Session WIP`'s three unconsumed keys until S4
  ships.
- Disclose at key level wherever the condition holds, including
  `notification_policy_after_stop` and `daily_cost_ceiling`.
- Have Tune write only the blocks with live consumers today.

**Choice as written.** Block-level disclosure for the one block S1 marked
reserved, and silence for every other declaration nothing currently reads.

**Consequences.** The human's first pact is authored under two regimes without
being told there are two. Read mode then reports on `Budgets` only, so the
ritual's reach exceeds anything this slice reflects back — tune three blocks,
read one. Recording the asymmetry is what stops it reading as an oversight when
S4 arrives and begins consuming values authored months earlier under no
disclosure at all.

**Pattern.** — . A disclosure rule scoped to the artefact that happened to
carry a marker rather than to the condition that triggers it.

## Story #8 — Nothing points at the only door

**Source:** spec §1, §2, §6, §7.1 · **Lens:** consequences, alternatives · **Refs:** O10, #1, #4

**Context.** The split's headline justification is that until Tune exists the
pact file does not exist and every other sentinel is permanently in
observe-only. Reaching Tune requires a human to type `/mast tune`. §6 adds no
hook and no statusline; read mode's absent-block path emits S1's fixed sentence,
which names no remedy because it belongs to S1's contract.

**Forces.** Nothing may nag and nothing may impose — constraint 6 and the
epic's ethic. Against that, the slice's entire stated value depends on humans
finding a command nothing mentions. §1 also still describes the Mast as what
"offers you the ritual for stopping"; that half is #501, and revision 2 neither
rewrote the sentence nor withdrew it.

**Options not taken.**

- Have read mode offer Tune when the block is absent — exactly what
  `/reservoir` read does. Saying it in the command's own prose needs no change
  to S1's fixed sentence and carves no contract.
- Make the O10 counter-argument and answer it. The diaboli said plainly that a
  Mast which never speaks at the boundary is a gauge nobody reads; revision 2
  asserts Tune's value and leaves the read half's value unargued.
- Claim the ramp explicitly: §8 already commits to a how-to, so the spec could
  state that documentation *is* the adoption path.

**Choice as written.** On-demand invocation only, adoption by documentation —
chosen by silence. The spec never says how a human comes to run `/mast tune`,
which is the same silence S1's story #2 recorded about how a human comes to
declare a block, one slice later and with the authoring path now built.

**Consequences.** The epic's unblocking event has no trigger inside the
product. In a project that adopts the plugin and never runs the command, S1–S3
are complete and behaviourally identical to not having shipped. Combined with
story #4's long unanchored dialogue, the two most likely outcomes for a new adopter
are "never invoked" and "invoked once and mostly skipped". And until #501 the
gauge-and-ritual half is the whole of the Mast, so `/mast` carries a name, an
epithet and an opening paragraph written for the version that speaks at the
line.

**Pattern.** — . An opt-in whose invitation lives outside the product — the
same shape S1's story #2 named, inherited by this slice rather than resolved
by it.
