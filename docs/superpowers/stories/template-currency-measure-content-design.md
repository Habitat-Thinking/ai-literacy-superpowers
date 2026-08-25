---
spec: docs/superpowers/specs/2026-08-25-template-currency-measure-content-design.md
date: 2026-08-25
mode: spec
cartographer_model: claude-opus-5[1m]
stories:
  - id: 1
    lens: [defaults, patterns]
    title: Retiring a GC rule outside the governed loop
    disposition: pending
    disposition_rationale: null
  - id: 2
    lens: [alternatives, patterns]
    title: A bespoke predicate beside a general bucket
    disposition: pending
    disposition_rationale: null
  - id: 3
    lens: [patterns, consequences]
    title: Deletion as the honest-status rule's converse
    disposition: pending
    disposition_rationale: null
  - id: 4
    lens: [coherence, forces]
    title: A spec against proxies, argued by proxy
    disposition: pending
    disposition_rationale: null
  - id: 5
    lens: [consequences, forces]
    title: A trigger only the deleted sensor could pull
    disposition: pending
    disposition_rationale: null
  - id: 6
    lens: [consequences, alternatives]
    title: Three residues, none of them on a clock
    disposition: pending
    disposition_rationale: null
  - id: 7
    lens: [alternatives, consequences]
    title: The test becomes the inventory
    disposition: pending
    disposition_rationale: null
  - id: 8
    lens: [coherence, defaults]
    title: Two counts, two standards of proof
    disposition: pending
    disposition_rationale: null
---

# Choice stories — Retire the template-currency nudge

Eight stories against revision 4 of a spec that has already been through three
adversarial passes. The twelve objections on
`docs/superpowers/objections/template-currency-measure-content-design.md` are all
disposed, and none of them is restated here: the survivorship argument (O1), the
blind residue search (O2), the missing allow-list exemptions (O3), the
unconsented migration (O4), Status-block accuracy in consuming projects (O5),
the migration's reach (O6), the unpriced losses (O7), the delete-less
alternative (O8), one-way-ness (O9), the mixed-version nudge (O10), the
unchecked predicate (O11) and the incomplete enumerations (O12) are all
adjudicated and out of scope for this record.

These eight sit where that coverage stops. Four of them turn on one fact the
objection record never had to look at: revision 4 is the first change in this
repository to **retire** a piece of harness machinery, and the repository's
governance apparatus — the evolution loop, the decision records, the sunset
markers, the count guards — is built almost entirely for **adding** things.

**Read-mode note.** `REFLECTION_LOG.md` was read bounded (header, opening
entries, plus a targeted search for prior surprises about retirement, deletion
and orphaned state — none found). `AGENTS.md`, `HARNESS.md`, the objection
record, `commands/harness-upgrade.md` and
`harness/decisions/HDR-2026-08-25-four-mechanisms-report-the-reassuring-answer-when-they-cannot-determine-the-real-one.md`
were read in full or in the sections cited.

## Story #1 — Retiring a GC rule outside the governed loop

**Source:** spec §3 (the "Marker (this repository)" and "`Template currency` GC rule (this repository)" rows), §10
**Lens:** defaults, patterns
**Refs:** O4

**Context.** The spec deletes the `Template currency` GC rule from this
repository's own `HARNESS.md` (`HARNESS.md:760-769`) as one row of a deletion
table, inside a feature PR. `CLAUDE.md`'s *Changing a Harness Rule* section says
that once a harness exists, changing it goes through
`/harness-assay → /harness-propose → /harness-accept → /harness-check`, with
`/harness-review` when a rule lapses, and closes with: "hand edits are how a
governing document becomes the least governed thing in the repository." The spec
mentions the loop nowhere. §10 addresses only the arithmetic consequence — the
`Garbage collection active:` count, which `/harness-audit` owns.

**Forces.** The spec is retiring a rule that has *lapsed* in precisely the sense
`/harness-review` names: its **Tool** field promises to compare template content
and compares plugin versions instead. That is the loop's canonical trigger. Set
against it: the loop's vocabulary is constraints, not GC rules.
`commands/harness-propose.md` and `commands/harness-review.md` contain no
mention of garbage collection; the HDR classifications route to `HARNESS.md`'s
constraint section, `AGENTS.md`, or an agent skill file. And this rule predates
the loop — it entered with the 2026-04-15 harness-upgrade spec, so there is no
decision record to expire. Every governed retirement path the repository has
assumes the rule entered through a governed door.

**Options not taken.**

- Run `/harness-review` on the lapsed rule and let `/harness-propose` draft a
  retirement record, accepting that the loop would need extending to GC rules —
  which is itself the finding.
- Write the retirement as an HDR with a cost the approver states in their own
  words, matching what every rule accepted since the loop shipped has paid.
- Say in the spec that GC rules are outside the loop's scope and that the
  feature-PR channel is therefore deliberate, so the next person retiring one
  inherits a decision rather than a precedent.

**Choice as written.** The spec chose the feature-PR channel by silence. It is
the path of least resistance and it is almost certainly correct — but nothing in
the document records that a channel was chosen, or that a different one exists
and was considered.

**Consequences.** The reasoning for retiring a governance rule lands in
`docs/superpowers/specs/` rather than `harness/decisions/`, so
`harness/decisions/index.md` and `/harness-timeline`, which reads it
(`commands/harness-timeline.md:92`), will show the GC count moving 19 → 18 with
no entry explaining why. A future reader asking "when did we stop checking
template currency, and who agreed?" finds the answer only by knowing which spec
to open. This is also the repository's first GC-rule retirement, so whatever
happens here becomes the pattern: the loop's gap gets filled by precedent rather
than by amendment.

Note the diaboli quoted this exact `CLAUDE.md` line at O4 and aimed it at
*consuming projects'* `HARNESS.md` files. The disposition — per-item consent —
is right and is implemented in §5. The same sentence pointed at this
repository's own governing document was never fired.

**Pattern.** Chesterton's Fence read from the removal side. The spec does the
archaeology the fence-remover is supposed to do — §1's verification is unusually
good — and then removes the fence through a gate that keeps no register of
fence-removals. The register exists (`harness/decisions/`); it is not addressed
to this species of fence.

## Story #2 — A bespoke predicate beside a general bucket

**Source:** spec §4, §5, §5.1
**Lens:** alternatives, patterns
**Refs:** O4, O11

**Context.** §4 keeps `/harness-upgrade`'s three-bucket comparison — **new**,
**updated** and **removed** — untouched, and rightly treats that restraint as a
virtue. §5 then adds a hand-written predicate in step 6 that looks for a
`<!-- template-version: … -->` marker and a `### Template currency` GC rule
whose **Tool** field references the template-version comment. But once the
template stops shipping that rule, the existing parse already sees it: step 2
matches `###` blocks under `## Garbage Collection` by heading name
(case-insensitive, trimmed), and step 3 puts anything present in the user's file
and absent from the template into the **removed** bucket.

**Forces.** Specificity against generality. The marker genuinely needs a bespoke
predicate — it is an HTML comment, not a `###` item, so nothing in the existing
parse can see it. The GC rule does not: it is exactly the shape the parser
already handles. The spec added one predicate covering both, which is the
simpler thing to write and the harder thing to reconcile with the machinery
beside it.

**Options not taken.**

- Bespoke predicate for the marker only; promote the **removed** bucket from
  advisory to actionable for the rule, so one mechanism handles one class of
  object.
- Make the **removed** bucket offer removal generally, with the `Template
  currency` rule as its first customer — the migration then costs no new
  predicate at all and every future template retirement inherits it.
- State that the bespoke predicate is deliberately narrow and one-shot, deleted
  in the release that removes the habitat-discovery reader (see #6).

**Choice as written.** Two mechanisms now see the same object under two
vocabularies, in the same run. Step 4 lists it as a *removed item* — "Advisory
only… No action required" — and step 6 asks the user to accept or skip its
removal. §5.1's *near miss* is a third vocabulary for the case where the
heading matches and the Tool field does not; under the generic parse that same
file is an ordinary removed item, reported without ceremony. The predicates also
disagree in strictness: the command matches by heading name, the migration
requires heading *and* Tool field.

**Consequences.** The user of a project that has customised the rule can be told
about it twice in one command run, once as advisory and once as a decision to
make, with no cross-reference between them. Step 3's short-circuit inherits an
awkward line too: "Your harness already contains all current template content.
Then skip to step 6" now routes directly into a step that removes content. None
of this breaks; all of it costs a reader. And the general improvement — an
actionable removed bucket — that this change had the best occasion in the
project's history to make, goes unmade and unmentioned.

**Pattern.** Special case beside a general mechanism, the classic prelude to
divergence: the two will be maintained by different people at different times
and will drift on the matching rule first. The counter-pattern the spec is one
step away from is Open/Closed — extend the bucket, don't branch beside it.

## Story #3 — Deletion as the honest-status rule's converse

**Source:** spec §1, §2, §5.1
**Lens:** patterns, consequences
**Refs:** O1

**Context.** §5.1 cites "the decision record in force until 2026-11-23" for the
migration report's three outcomes. That record is
`HDR-2026-08-25-four-mechanisms-report-the-reassuring-answer-when-they-cannot-determine-the-real-one`,
accepted the same day as this spec. Its rule: a mechanism that reports a status
must have a defined value for the case where it could not determine the answer,
and that value may not be the passing one — "a mechanism that fails toward the
reassuring answer is worse than an absent one, because the next reader stops
looking." The hook this spec deletes fails in the mirror direction: it reports
the *alarming* value on evidence that cannot establish it.

**Forces.** The HDR's remedy vocabulary is *report unknown and name the input
you could not read*. The spec's remedy is *remove the reporter*. Both satisfy
the rule; only one of them is in the rule's text. The unspoken force is that a
false alarm and a false all-clear are not symmetric harms — the HDR grounds
itself on "the next reader stops looking", and §1 documents the opposite harm,
where a false alarm was believed and written into `HARNESS.md`'s Status block as
"eight minors of unreviewed template content", then copied forward into the next
block without being re-checked (`HARNESS.md:1185`). The spec demonstrates that
the alarming direction is also load-bearing and does not say so.

**Options not taken.**

- Have the hook report what it can actually establish — "the plugin version
  moved; whether the template changed is unknown from here" — which is the
  HDR's prescribed shape and a true statement.
- §7's third alternative, which makes the input readable rather than the report
  honest about being unreadable.
- Cite the HDR for the deletion as well as for the report, and record that
  deletion is a legitimate compliance move under it.

**Choice as written.** The spec chose removal, and cited the record for the
small decision (§5.1's three outcomes) while leaving the large one uncited. That
is the correct call on the merits and an unrecorded one on the reasoning.

**Consequences.** This is the first worked instance in the repository of "delete
it" as an answer to the reassuring-answer rule, and deletion is the cheapest
compliance move available for anything that rule ever catches — vacuously
satisfying, requires no unknown-state design, and needs no approver's cost
statement. It is right here; it will be reached for again on weaker facts.
Second, and more concretely: the HDR's own validation criterion is to read the
objection records written before 2026-11-23 and look for objections the rule
produced and dispositions that acted on them, with no such objections meaning
retirement. A defect removed before a diaboli pass can object to it produces no
entry in that trail. This change quietly makes the HDR marginally harder to
validate at expiry.

**Pattern.** Alarm rationalisation from safety engineering (EEMUA 191 and its
lineage): a nuisance annunciator is addressed by removal, re-ranging or
suppression, and removal is legitimate specifically when the alarm has **no
defined operator action**. That test is met here — the nudge's only response was
running a command `README.md:99` already recommends after every plugin upgrade —
and naming it gives the decision a defence stronger than the cost argument in
§2.1. The same literature carries the caution worth recording alongside it: an
annunciator removed for nuisance is rarely reinstated once the underlying signal
becomes measurable, which is #5's subject.

## Story #4 — A spec against proxies, argued by proxy

**Source:** spec §1, §2.1, §9 (O1 row)
**Lens:** coherence, forces
**Refs:** O1, O8

**Context.** §1's case is that `plugin.json`'s version is a broken proxy for
template content: it moves for reasons unrelated to the thing it claims to
measure. §2.1's case — which §9 records as the disposition to O1, and which is
now the load-bearing justification for the whole decision — is a table of
revisions scored on **acceptance criteria count** (9, 18, 8) and **adversarial
review outcomes** (1 critical / 5 high, 1 critical / 8 high, 2 critical / 8
high). Those are measurements of specs and of review sessions, not of the
mechanism.

**Forces.** Cost arguments need a number, and the only numbers this project
generates about design work are pipeline artefacts: criteria counts, objection
counts, severity mixes. The alternative measurement — what a correct notifier
would cost to build and run — is stated in §7 and is small: one CI assertion.
The spec resolves toward the numbers it has rather than the number that bears on
the question, and never remarks on the substitution.

**Options not taken.**

- Price the surviving alternative directly against the deletion: one CI check
  and a marker discipline, versus a permanent capability loss and a one-way
  migration. §7 supplies both halves; nothing multiplies them out.
- Attribute the review cost to its actual cause. Revisions 1 and 2 were
  *heading-comparison* designs; §7's third alternative shares none of their
  mechanism, so their objection counts are not evidence about it.
- Keep both legs and say so — cost *and* the survivorship-limited history —
  rather than transplanting the entire weight onto one.

**Choice as written.** The spec chose to measure the mechanism's worth by the
expense of specifying it. The symmetry with §1 is exact and unremarked: version
count stood in for template content; objection count now stands in for design
cost. A document whose opening move is *this number does not measure what it
claims* closes on a number that does not measure what it claims.

**Consequences.** The argument form generalises further than the spec wants:
"three revisions and two criticals" is available against anything the pipeline
finds hard to specify, which is not the same set as things not worth building.
Revision 4 adds a fourth round to the tally it cites, so the metric grows with
each attempt to answer the objections raised against it. Note also what changed
in the argument's *role*: the diaboli's "explicitly not objecting to" section
called §2.1 "strong on its own terms" while it was one leg of two. It was never
reviewed carrying the whole weight, and the disposition that gave it that weight
is the last word written on it.

**Pattern.** Goodhart's law inside a review pipeline — a measure of the review
process adopted as a measure of the thing reviewed. The adjacent human pattern
is the sunk-cost-to-abandonment flip: effort spent on X reframed as evidence
against X.

## Story #5 — A trigger only the deleted sensor could pull

**Source:** spec §2.2, §5.3, §7
**Lens:** consequences, forces
**Refs:** O1, O9, #3, #4

**Context.** §7 keeps the reopening path warm: "**If §2.2's losses prove to
matter, this is the option to reopen on**", and §5.3 (the O9 disposition) prices
reopening honestly as a second migration. What neither section names is how
anyone would learn that the losses matter. The four things that could have
surfaced unadopted template content — the SessionStart hook, the `/harness-sync`
monthly drift row, the `/harness-audit` drift-engine row and the required
observatory signal — are the four things §2.2 deletes.

**Forces.** Reversibility against evidence. The spec did the harder half: it
faced up to reversibility (§5.3) after O9 pushed. The easier half went
unexamined — a decision recorded as conditional needs an observer for its
condition, and the deletion removes every observer. §1.1 states this class of
problem with real care about the past: "in the five windows where the template
was unchanged, a correct mechanism would have been silent and produced no
evidence either way." The same reasoning applied forward gives the answer, and
the spec does not apply it forward.

**Options not taken.**

- Name a review date rather than a trigger — reread this decision at the next
  quarterly `/governance-audit`, whatever the evidence — matching the
  `expires:` discipline every HDR carries.
- Ask adopters directly. The objection record routes exactly this to the
  Convener's consultation record ("Someone should ask adopters before removing a
  capability from their projects"); a consultation is the only remaining channel
  through which the evidence could arrive.
- Build §7's third alternative *as the instrument rather than the notifier* —
  silent when correct, recording adoptions where anyone could count them —
  which is the version of it that generates the evidence the reopening decision
  needs.

**Choice as written.** The spec chose, by silence, that the reopening condition
is met when a user independently notices something nobody told them about. The
only user positioned to notice is one who runs `/harness-upgrade` regularly —
which is precisely the user who lost nothing when the nudge went away.

**Consequences.** The decision joins the class §1.1 describes with such
precision: a proposition about a mechanism's value about which the tree will
generate no evidence in either direction. §7's design stays legible and
re-buildable; the hand that would reach for it does not exist. The honest
reading is that this is a permanent decision written in provisional language,
and the record should say so rather than leaving a future reader to conclude
that nobody complained. Routing note: no failure class goes undetected by this
— the mechanism being removed detected nothing real. What goes undetected is
whether the removal was right.

**Pattern.** A revisit clause with no observer — the ADR failure mode Nygard's
format invites and does not prevent, since "Status: accepted" carries no
expiry. The contrast inside this repository is sharp and worth citing: the HDR
of #3 names an expiry date, a validation criterion, and the artefact that
carries the evidence trail. This spec names a condition and none of the three.

## Story #6 — Three residues, none of them on a clock

**Source:** spec §2.2 ("One consumer is deliberately retained"), §3 (`.gitignore` paragraph), §5.2
**Lens:** consequences, alternatives
**Refs:** O7, O10

**Context.** The change leaves three pieces of transitional state behind, each
deliberately and each with a different implied lifetime.
`skills/ai-literacy-assessment/references/habitat-discovery.md:93,141` keeps
reading the marker and "is removed in a later release once the marker is rare".
The `.gitignore` entry for `.claude/.harness-upgrade-dismissed` stays for a file
nothing writes or reads. And the marker itself persists in every consuming
project that never runs `/harness-upgrade` again (§5.2). Not one of the three
has a date, an owner, or a measurable condition — "rare" is undefined and, after
this change, unmeasurable, since the surfaces that could have counted markers in
the wild are the ones being deleted.

**Forces.** Deleting a reader before its data is gone is backwards, which O7
established and §2.2 correctly implements. Against that: unclocked transitional
state is the exact failure this spec exists to correct — a marker that outlived
what it measured, kept because removing it was nobody's job.

**Options not taken.**

- A `<!-- redirect-sunset: YYYY-MM-DD -->`-style marker on the retained reader.
  The repository already runs `scripts/check-redirect-sunsets.sh` monthly under
  the `Redirect sunset` GC rule for precisely this class of expiring
  transitional state.
- An issue filed for the reader's removal, as §3.3 does for the
  `reference/hooks.md:287` docs defect and §8 does for the declined-item record.
  The spec has a deferral vocabulary; it does not use it here.
- Define "rare" as something a person can check — say, review at the next
  quarterly `/governance-audit`, which `CLAUDE.md` already schedules.

**Choice as written.** The spec chose deliberate, indefinite residue. The
retention decisions are all sound; the absence of a clock on any of them is
unremarked, and it is a decision, because the repository has two established
idioms for putting one on — the sunset marker and the HDR `expires:` field,
about which the harness-evolution page is explicit: "An expired rule still in
force fails CI, so retiring a rule never depends on anyone remembering."

**Consequences.** After this PR the tree carries three artefacts whose only
removal trigger is memory, and it removes a GC rule while creating state that a
GC rule is this repository's normal answer for. The follow-up work is also now
harder to scope than it is today: whoever removes the habitat-discovery reader
in "a later release" has to re-derive what it read and why it was kept, from a
spec that will by then be one of many in `docs/superpowers/specs/`.

**Pattern.** Tombstone / vestigial field. The lifecycle shape is Strangler Fig
(Fowler) with the cut-over left unstated — the old path is kept alive
deliberately, and the condition for killing it is qualitative.

## Story #7 — The test becomes the inventory

**Source:** spec §3 (line-number paragraph), §6 criterion 8, §12
**Lens:** alternatives, consequences
**Refs:** O2, O12

**Context.** §3 drops line numbers on purpose and says outright that "the
residue assertion in §6 is what guarantees completeness, not the table"; §6
adds that "Criterion 8 exists because hand enumeration failed three times" and
supplies the count that damns the tables (7, then 12, then 19, against a real
22 plus two prose surfaces no term search reaches). Authority over *what this
change touched* moves from a curated inventory in the spec to an executable
assertion in `tdad_tests/layer0_deterministic/test-template-currency-retired.sh`.

**Forces.** Inventories rot silently and had been wrong three times running.
Assertions run on every commit — but only answer the question someone encoded.
"Is there residue now?" and "what did this change touch?" are different
questions, and only the first is executable. The spec resolves toward the
executable one and demotes the other to "a reader's aid" in the same breath.

**Options not taken.**

- Generate the §3 table from the search at implementation time, so the
  inventory *is* the test's output and cannot disagree with it.
- Keep the inventory authoritative and accept line-number drift as the cheap
  cost it is — the objection record already dismisses drift as "normal spec
  decay".
- Put the allow-list in one place that both the spec and the test read, rather
  than in prose in §6 and again in shell in the test.

**Choice as written.** The spec chose test-as-source-of-truth and said so
plainly, which is more than most specs manage. It also chose, by silence, that
the allow-list lives in two disagreeing-capable copies: §6 states the list and
forbids widening it ("An implementer must not widen the allow-list further to
make the test pass; if a new file legitimately needs an exemption, that is a
spec change"), while the runtime list is the shell array in the test file. That
prohibition is written where the test cannot read it and the reviewer of a
one-line array edit is unlikely to look.

**Consequences.** The durable record of this change's scope becomes a Layer 0
shell script, and §3 and §12 are explicitly non-authoritative from the day they
are committed. Someone in six months asking why `reference/hooks.md` lost a
section reads a table the spec itself disclaims. The allow-list can be widened
by an edit that turns CI green with no mechanism comparing it back to §6 — the
governance equivalent of what `CLAUDE.md` says about hand edits, one layer down.
None of this is a failure of the change as specified; it is where the knowledge
will live afterwards, which is a choice worth having made on purpose.

**Pattern.** Executable specification (Fowler; Adzic's *Specification by
Example*), with its known cost: the test encodes what someone thought to assert,
and the prose that explains *why* those terms and not others degrades to
commentary. The allow-list half is a policy expressed as prose against an
artefact whose violation is a one-line diff — the same shape as an unenforced
lint rule.

## Story #8 — Two counts, two standards of proof

**Source:** spec §3.2
**Lens:** coherence, defaults
**Refs:** O12, #7

**Context.** §3.2 does two arithmetics, both correctly, and treats them
identically. Hooks 18 → 17 and SessionStart 4 → 3 is guarded:
`tdad_tests/layer0_deterministic/test-hooks-doc-parity.sh` fails if
`reference/hooks.md` is not updated, and the spec cites both the test and the
history of the count going stale ("hooks.json declares 18; the page documented
16"). Observatory signals 82 → 81 is not guarded: the total is hard-coded at
`observatory-signals.md:157`, `observatory-verify.md:3` (frontmatter), `:17`,
and the results-table template at `:89`, and nothing pins it —
`tdad_tests/tests/test_phase2_observatory_verify.py:67` asserts only that there
are at least ten snapshot signals.

**Forces.** Completeness against scope. The spec had every reason to stop at
"move the counts": O12 asked only for the arithmetic and the disposition
delivered it. Against that, §6's whole argument is that hand enumeration in this
tree has a track record and needs a machine behind it. The spec applies that
standard to *terms* and not to *counts*, in the same document, without noticing
that it noticed the difference — it cites the hooks parity test as the reason
one count must move, which means it read the guard and did not ask why the other
count has none.

**Options not taken.**

- Extend criterion 8's Layer 0 test with an assertion that the four hard-coded
  observatory totals agree with the number of signal rows. It is a `grep -c`
  and a comparison, in a test file this spec is already creating.
- Derive the total rather than hard-code it in four places, retiring the
  arithmetic instead of performing it.
- Say explicitly that guarding the total is out of scope, as §3.3 does for the
  `hooks.md:287` defect — a sentence, and the next reader inherits a decision
  rather than an oversight.

**Choice as written.** The spec chose to pay the four-place arithmetic by hand
and leave the guard unbuilt, and treated the presence of a test for one count
and its absence for the other as a fact about which files to edit rather than as
a question about which counts can be trusted.

**Consequences.** The next change to the observatory signal set pays the same
four-place tax, with the same reliance on someone remembering all four
locations, and `observatory-verify.md`'s frontmatter description — the least
likely of the four to be re-read — is where it will go stale. Routing note: this
change moves all four correctly, so no failure is left undetected here; what is
left unrecorded is why the residue assertion's own logic ("hands missed this
three times, so assert it") stopped at the section boundary. Story #7's
observation applies with the sign reversed — there, authority moved to the test
and the prose was demoted; here, the count stayed in prose and the test that
could have held it was not extended.

**Pattern.** Magic number duplicated across artefacts, with a single-point-of-
truth fix available and unexercised. The coherence reading is Alexander's:
inside one section, two decisions about the same kind of object made on
different principles, where the principle governing the first is written in
§6 and simply not carried across.
