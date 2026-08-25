---
spec: docs/superpowers/specs/2026-08-25-template-currency-measure-content-design.md
date: 2026-08-25
mode: spec
diaboli_model: claude-opus-5[1m]
objections:
  - id: O1
    category: premise
    severity: high
    claim: "The load-bearing claim that the mechanism has no recorded successes is a survivorship artefact — in five of six recorded runs the template had not changed, so 'adopted nothing' is a true negative rather than a failure."
    evidence: "§1: 'The plugin moved ten minor versions across that window. The template moved zero bytes.' §1.1: 'There is therefore no recorded instance of this nudge producing a useful adoption.' §2.2 rests acceptance of the loss on 'the mechanism being removed has never demonstrably provided it.'"
    disposition: accepted
    disposition_rationale: "The survivorship point is taken and the decision stands. The justification is rewritten: deletion rests on cost and complexity — three revisions of escalating mechanism, two criticals — not on 'it never worked'. Note the reviewer's 'true negative' framing is itself wrong: the hook fires whenever versions differ, so it nudged all six times and was wrong five. But the surviving point holds — that history damns the broken notifier and cannot tell us whether a correct one would earn its keep."
  - id: O2
    category: implementation
    severity: critical
    claim: "Criterion 6's four search terms cannot match the phrasing that actually carries this mechanism across the tree, so the residue assertion returns the passing answer over a tree that still advertises the deleted hook in at least eleven places."
    evidence: "§6 criterion 6 searches for `template-version`, `Template currency`, `template-currency`, `harness-upgrade-dismissed`. None of these match `hooks/hooks.json:2` ('template currency check ... (SessionStart) nudge on plugin upgrade'), `README.md:371` ('SessionStart template currency check'), `commands/harness-sync.md:118,138,207,271,294` ('Template version drift' / 'Template drift'), `skills/harness-audit-engine/SKILL.md:3`, `CLAUDE.md:284`, `templates/CLAUDE.md:220`, `docs/plugins/ai-literacy-superpowers/reference/skills.md:46`, `.../tutorials/first-time-tour.md:558`, `.../explanation/the-harness-lifecycle.md:161`, `.../explanation/the-loops-that-learn.md:36`, `.../reference/output-validation.md:33`."
    disposition: accepted
    disposition_rationale: "Broaden the residue assertion: add 'template drift' and 'template version drift', and make the search case-insensitive. The assertion was sold as the reason a complete table was no longer needed; blind to the phrasings in use, it would have certified the incomplete table instead."
  - id: O3
    category: specification quality
    severity: high
    claim: "Criterion 6's allow-list omits the two files that must contain the forbidden strings by construction — the migration command and the test that implements the criterion — so the Layer 0 test fails on its own implementation."
    evidence: "§6 criterion 6 permits matches 'only in: CHANGELOG.md, REFLECTION_LOG.md, reflections/, assessments/, harness/assay/, docs/superpowers/{specs,plans,objections}/, observability/snapshots/, and the .gitignore line.' §5 requires `/harness-upgrade` step 6 to detect 'a `<!-- template-version: … -->` marker' and 'a `### Template currency` GC rule', and §6 places the test at `tdad_tests/layer0_deterministic/test-template-currency-retired.sh` — a filename containing `template-currency`."
    disposition: accepted
    disposition_rationale: "Exempt commands/harness-upgrade.md and the test file by name, with the reason stated, so the exemption is deliberate and narrow rather than a widening someone applied to get CI green."
  - id: O4
    category: implementation
    severity: critical
    claim: "Step 6's migration deletes content from a project's governing document unconditionally and without asking, inside a command whose entire design is per-item consent."
    evidence: "§5: 'On any run, if the project's HARNESS.md contains: a `<!-- template-version: … -->` marker, it is removed; a `### Template currency` GC rule … it is removed'. `commands/harness-upgrade.md:104` — 'Ask the user to choose for each item' — and step 4 offers 'accept, skip, or customise' for every other change the command makes. CLAUDE.md: 'hand edits are how a governing document becomes the least governed thing in the repository.'"
    disposition: accepted
    disposition_rationale: "Step 6 prompts per item, matching the command's existing consent design. Nothing in a project's HARNESS.md is deleted without a recorded decision — a project may have specialised that rule, which is exactly what this repository did with Consistent formatting."
  - id: O5
    category: scope
    severity: high
    claim: "The spec applies its own Status-block standard to this repository and not to the projects it migrates, so every migrated project is left with a governing document that overstates its GC coverage."
    evidence: "§10: 'Removing the `Template currency` GC rule changes the `Garbage collection active:` count in HARNESS.md's Status block … This PR runs `/harness-audit` … rather than merging a governing document that misstates its own coverage.' §5 performs the identical edit in consuming projects with no equivalent step. `skills/harness-audit-engine/SKILL.md:32` makes Status-block accuracy a tracked drift surface."
    disposition: rejected
    disposition_rationale: "Out of scope. Status-block accuracy is /harness-audit's tracked drift surface and its normal cadence will catch it. This command's job is not to keep every consuming project's Status block current."
  - id: O6
    category: scope
    severity: high
    claim: "The migration reaches only projects that run `/harness-upgrade` — by the spec's own argument the population least in need of it — yet §9 records the corresponding prior objection as fully resolved."
    evidence: "§5: 'A project that never runs `/harness-upgrade` again keeps an orphaned rule.' §7 argues against the opt-out alternative because it 'silences the nudge for projects that never had one — the population most likely to need it.' §9: 'O6 | high | **Resolved** — §5 migrates consuming projects' orphaned GC rule'."
    disposition: rejected
    disposition_rationale: "Resolved as written. The plugin cannot edit files in projects it is not invited into; performing the migration on every /harness-upgrade run is the maximum available reach, and that is what resolved means here."
  - id: O7
    category: scope
    severity: high
    claim: "§2.2 prices only the loss of the unprompted notification, but §3 also deletes three other consumers — the `/harness-sync` monthly drift surface, the `/harness-audit` engine row, and the assessment's harness-detection marker — including a reader for data that stays in the wild."
    evidence: "§2.2: 'A project that upgrades the plugin will no longer be told, unprompted, that the template gained content.' §3 additionally deletes `commands/harness-sync.md:118,206-207,271,294`, `skills/harness-audit-engine/SKILL.md:33`, `skills/harness-observability/references/observatory-signals.md:127`, and `skills/ai-literacy-assessment/references/habitat-discovery.md:93,141` — the last being a marker used to recognise that a project has a harness at all, which unmigrated projects will keep carrying."
    disposition: amend
    disposition_rationale: "Keep habitat-discovery.md reading the marker — it is a reader, it is harmless, and unmigrated projects keep carrying the marker it recognises. Rewrite section 2.2 to name every capability removed rather than only the unprompted notification."
  - id: O8
    category: alternatives
    severity: high
    claim: "All four alternatives in §7 keep or repair the nudge; the spec never weighs deleting less — removing the SessionStart hook (the every-session false signal) while retaining the pull-direction surfaces."
    evidence: "§7 lists 'Compare heading sets', 'Filter the compared set', 'Fix the template's own content marker and read that', and 'Keep the marker but make its absence an opt-out'. §1's evidence of harm is specific to the hook's assertion ('the SessionStart hook asserts `Plugin template has been updated` on evidence that cannot establish it'), not to the `/harness-sync` row, which surfaces drift as a `[manual]` item at a monthly cadence the user chose."
    disposition: rejected
    disposition_rationale: "Delete all of it. A drifted row computed from a broken proxy is still a false statement wherever it appears, including in a monthly table the user asked for. Coherence beats preserving a surface that reports the same bad signal at a slower cadence."
  - id: O9
    category: risk
    severity: medium
    claim: "The spec names the condition under which the decision is wrong and the option to reopen on, but the migration strips from the install base the marker that option depends on, making the recorded reopening path more expensive than §7 implies."
    evidence: "§2.2: 'If a future adopter reports missing template content they would have wanted to know about, that is evidence this decision was wrong and is worth reopening on.' §7: 'have the hook compare that marker rather than `plugin.json` … recorded here in enough detail to be taken up without re-deriving it.' §5 removes the project-side marker on every `/harness-upgrade` run."
    disposition: accepted
    disposition_rationale: "State plainly that the migration is one-way: it is not reversible from the plugin side, reverting the plugin does not restore project files, and reopening on section 7's alternative costs a second migration through the same partially-reaching channel."
  - id: O10
    category: risk
    severity: high
    claim: "Stripping the marker while older plugin copies remain installed produces a permanent every-session false nudge that the new command can no longer silence, because it stops writing the dismissal file."
    evidence: "`hooks/scripts/template-currency-check.sh:32-34` — absent marker is treated as `0.0.0` — with `:43-45` and `:48-53`, so an absent marker nudges unless a dismissal file matching the plugin version exists. §3: '`.claude/.harness-upgrade-dismissed` is no longer written or read.' CLAUDE.md documents per-version plugin caches and a separately-synced marketplace clone, so mixed versions across machines and teammates are the normal case."
    disposition: rejected
    disposition_rationale: "Stated and accepted as a transitional cost. Name the mixed-version consequence in section 2.2 rather than carrying a dismissal file nothing in the new plugin reads. Users on stale plugins have other reasons to upgrade. The reference/hooks.md:287 docs bug is real but predates this spec and is tracked separately."
  - id: O11
    category: specification quality
    severity: medium
    claim: "The GC-rule removal predicate is stated in prose and never checked against the text it must match, and no behaviour is defined for a near-miss, a customised rule, or an unreadable file."
    evidence: "§5: 'a `### Template currency` GC rule whose **Tool** field references the template-version comment, it is removed'. §2.1 records that revision 2 shipped 'an exclusion predicate that matched nothing … verified by `grep '^###.*affordance-example'` returning zero matches'. §5's step 7 defines only the success report: 'step 7 reports each removal by name.'"
    disposition: accepted
    disposition_rationale: "Report near misses and never guess. A '### Template currency' heading whose Tool field does not match is reported and left alone, and step 7 distinguishes 'found nothing' from 'removed nothing' so silence never stands in for could-not-determine."
  - id: O12
    category: scope
    severity: high
    claim: "The §3 and §12 enumerations miss named surfaces despite claiming grep derivation, and no counterpart to §3.1's signal arithmetic exists for the hook count that a Layer 0 test enforces."
    evidence: "§12: 'Derived from the grep in §6, not by hand' — yet `how-to/sync-harness.md` matches none of the four terms, and the list omits `README.md:371`, `hooks/hooks.json:2`, `templates/CLAUDE.md:220`, `reference/skills.md:46`, `tutorials/first-time-tour.md:558`, `explanation/the-harness-lifecycle.md:161`, `explanation/the-loops-that-learn.md:36`, `reference/output-validation.md:33`. `hooks.json` declares 18 hooks (4 SessionStart); `tdad_tests/layer0_deterministic/test-hooks-doc-parity.sh:19` records the last time that count went stale. §3.1 does exactly this arithmetic for the observatory total (82 → 81) and nothing equivalent for hooks."
    disposition: accepted
    disposition_rationale: "Regenerate the section 3 and section 12 tables from O2's broadened case-insensitive search rather than by hand, and add the hooks.json count arithmetic (18 hooks, 4 SessionStart) alongside the observatory arithmetic in section 3.1."
---

## O1 — premise — high

### Claim

The spec's decisive claim — that the mechanism has never demonstrably worked — is
read off a sample in which success was structurally impossible for five of six
trials. In those five windows the template had not changed, so "found nothing to
adopt" is the mechanism correctly reporting a true negative, not the mechanism
failing. The one window in which the template *did* change is precisely the one
§1.1 says cannot be attributed. The informative sample size is therefore one, and
the spec treats it as six.

### Evidence

> The plugin moved ten minor versions across that window. The template moved zero
> bytes.

and

> **There is therefore no recorded instance of this nudge producing a useful
> adoption.** Six runs are recorded; five adopted nothing and the sixth cannot be
> attributed.

and §2.2:

> This is a real reduction in discoverability, and it is accepted on the grounds
> that the mechanism being removed has never demonstrably provided it.

### Why this matters

§1's evidence is strong and, I think, correct about a different proposition: that
plugin version is a broken proxy for template content. That proposition supports
fixing or removing the *proxy*. The spec then uses a second proposition — that
notification itself is worthless — to justify removing the *capability*, and
grounds it in a run history that mostly records the template not moving. If the
template rarely changes, the correct inference is that a correct marker would fire
rarely, which is an argument for the cheap version in §7's third alternative, not
against having one. The deletion may still be right on cost grounds; the spec
should not rest it on a statistic that a period of template stability generated.

## O2 — implementation — critical

### Claim

Criterion 6 is the spec's central safety mechanism, introduced explicitly because
hand enumeration failed twice. Its four search terms do not match the phrasing in
which this mechanism is most widely described. A tree that still advertises the
SessionStart nudge in at least eleven places — including `hooks.json`'s own
description and the README's mechanism map — passes criterion 6 clean.

### Evidence

> **Residue assertion.** A repository-wide search for `template-version`,
> `Template currency`, `template-currency` and `harness-upgrade-dismissed`
> returns matches only in: …

Surviving references that match none of those four terms, verified in the tree
today:

- `ai-literacy-superpowers/hooks/hooks.json:2` — "template currency check and
  session-registry start (SessionStart) nudge on plugin upgrade" (lower-case
  "template currency", space-separated)
- `README.md:371` — "**SessionStart template currency check** — detects when the
  HARNESS.md template version is behind the installed plugin version"
- `ai-literacy-superpowers/commands/harness-sync.md:118, 138, 207, 271, 294` —
  "Template version drift", "Template drift  [manual: /harness-upgrade]"
  (note that §3 lists 118, 206-207, 271, 294 and misses 138)
- `ai-literacy-superpowers/skills/harness-audit-engine/SKILL.md:3` — the skill
  description advertising "template drift" coverage
- `CLAUDE.md:284` and `ai-literacy-superpowers/templates/CLAUDE.md:220` — "Surfaces
  ONBOARDING.md staleness, template drift, and recurring reflection patterns"
- `docs/plugins/ai-literacy-superpowers/reference/skills.md:46`,
  `.../reference/output-validation.md:33`, `.../tutorials/first-time-tour.md:558`,
  `.../explanation/the-harness-lifecycle.md:161`,
  `.../explanation/the-loops-that-learn.md:36`

The criterion also does not state whether the search is case-sensitive. Listing
both `Template currency` and `template-currency` implies it is, which is the
reading under which the misses above are worst.

### Why this matters

The repository's own harness carries
`HDR-2026-08-25-four-mechanisms-report-the-reassuring-answer-when-they-cannot-determine-the-real-one`:
a mechanism that reaches a passing value without reading the thing it reports on
is a defect, not a default. Criterion 6 is exactly that. Worse, the spec presents
it as the reason the author no longer needs a complete table — "The assertion is
cheaper than the table and does not depend on the author having remembered
everything." If the assertion is blind to the phrasing the mechanism is described
in, the spec has traded an incomplete table for a check that certifies the
incomplete table. That is a third repetition of the failure §6 was written to end,
this time with a green test on top of it.

## O3 — specification quality — high

### Claim

The allow-list in criterion 6 omits the two files that must contain the forbidden
strings for the spec to be implementable at all: `commands/harness-upgrade.md`,
which has to name the marker and the rule in order to remove them, and the test
file itself, whose filename and search patterns contain them. As written, the
criterion fails against its own implementation.

### Evidence

Criterion 6 permits matches "only in: `CHANGELOG.md`, `REFLECTION_LOG.md`,
`reflections/`, `assessments/`, `harness/assay/`,
`docs/superpowers/{specs,plans,objections}/`, `observability/snapshots/`, and the
`.gitignore` line." Neither `ai-literacy-superpowers/commands/` nor `tdad_tests/`
appears.

§5 requires the command to detect "a `<!-- template-version: … -->` marker" and "a
`### Template currency` GC rule whose **Tool** field references the template-version
comment". §6 names the test `test-template-currency-retired.sh`.

### Why this matters

An implementer hitting this has three moves, and two of them are bad: widen the
allow-list until the test passes (which is how allow-lists become meaningless),
or write the migration predicate obliquely to dodge the grep (which makes the
command harder to read and no safer). Only the third — writing the criterion so
that it exempts the implementation while still constraining everything else — is
the one the spec wanted, and the spec does not say it. Since criterion 6 is
Layer 0 and will be committed as a passing test, whichever compromise gets made
becomes the durable definition of "no residue" with no record that it was a
compromise.

## O4 — implementation — critical

### Claim

Step 6's migration performs an unannounced, unconditional deletion of two blocks
from a file the plugin does not own, in the one command in the suite whose design
premise is that the user adjudicates every change to their harness individually.

### Evidence

> §5: On any run, if the project's `HARNESS.md` contains: a
> `<!-- template-version: … -->` marker, it is removed; a `### Template currency`
> GC rule whose **Tool** field references the template-version comment, it is
> removed;

Against the existing command:

> `commands/harness-upgrade.md:104` — "Ask the user to choose for each item."
> `:96-102` — every new item is presented with "Options: **accept**, **skip**, or
> **customise**." `:131` — "Preserve all existing content that was not part of the
> upgrade."

And against this repository's stated posture toward governing documents:

> CLAUDE.md: "Once a harness exists, changing it goes through the governed loop
> rather than a hand edit to `HARNESS.md` … After that, hand edits are how a
> governing document becomes the least governed thing in the repository."

### Why this matters

The spec's justification for unconditional removal is sound as far as it goes: a
rule whose tool compares a marker that no longer exists reports drift forever.
But the remedy it chose is the plugin silently editing someone's source of truth
during a command they ran for an unrelated reason, with no prompt, no diff shown
before the fact, no opt-out, and no undo. A user who had specialised that GC rule
— which is exactly what §1 says this repository did with `Consistent formatting` —
loses their work without being asked. A prompt costs one `AskUserQuestion` and
converts a silent mutation into a recorded decision; the spec does not weigh
whether to have one. The migration is also the only part of this change that
touches files outside the repository, which makes it the part that most needs the
consent posture the rest of the command already has.

## O5 — scope — high

### Claim

The spec identifies that removing the GC rule invalidates the Status block, refuses
to merge a governing document that misstates its own coverage, and then performs the
same edit in every consuming project it reaches without any equivalent repair.

### Evidence

> §10: Removing the `Template currency` GC rule changes the
> `Garbage collection active:` count in `HARNESS.md`'s Status block, which is owned
> by `/harness-audit` and must not be hand-edited. **This PR runs `/harness-audit`**
> and commits its output, rather than merging a governing document that misstates
> its own coverage.

§5 contains no counterpart. `skills/harness-audit-engine/SKILL.md:32` makes
"`HARNESS.md` Status block matches actual constraint enforcement counts" a tracked
drift surface, auto-fixable via `/harness-audit`.

### Why this matters

After migration, every consuming project's Status block claims one more active GC
rule than it has, and their next `/harness-audit` or `/harness-sync` reports drift
that the plugin introduced. This is the same class of defect §1 opens with — a
governing document carrying a false statement about itself — and §10 shows the
author already holds the standard. Step 6 either needs to say "then tell the user
to run `/harness-audit`", or step 7's report needs to name the consequence.
Neither is expensive; neither is present.

## O6 — scope — high

### Claim

The migration only fires when a project runs `/harness-upgrade`, which by the
spec's own reasoning is the population that least needs help. §9 nonetheless
records the prior objection about orphaned rules as "Resolved".

### Evidence

§5 concedes:

> A project that never runs `/harness-upgrade` again keeps an orphaned rule. That
> is not fully solvable from here …

§7 rejects the opt-out alternative on precisely this asymmetry:

> silences the nudge for projects that never had one — the population most likely
> to need it.

§9:

> O6 | high | **Resolved** — §5 migrates consuming projects' orphaned GC rule

### Why this matters

The disposition table is the artefact a future reader will trust when deciding
whether this ground was covered. "Resolved" overstates what §5 delivers: a partial
migration that reaches the engaged population, with the unengaged population left
with a permanently-drifting deterministic GC rule and no notification path — the
notification path having just been deleted. That combination is worse for those
projects than the status quo, and it deserves to be recorded as a carried cost
rather than a resolved objection. The honest entry is "partially resolved for
projects that re-run the command; unresolved for the rest", which is also what
§2.2's plain-statement style would produce if applied here.

## O7 — scope — high

### Claim

"What is lost, stated plainly" states one loss. §3 deletes four consumers. One of
them is a *reader* for data that will remain in the wild indefinitely.

### Evidence

> §2.2: A project that upgrades the plugin will no longer be told, unprompted,
> that the template gained content. They learn it by running `/harness-upgrade`,
> which the README already tells them to do after an upgrade.

§3 also removes:

- `commands/harness-sync.md:118,206-207,271,294` — the template-drift row in the
  monthly `/harness-sync` ritual, which is a pull-direction path the user chose,
  not an unprompted nudge (CLAUDE.md, Monthly Operations)
- `skills/harness-audit-engine/SKILL.md:33` — the same finding for `/harness-audit`
- `skills/harness-observability/references/observatory-signals.md:127` — a required
  observatory signal
- `skills/ai-literacy-assessment/references/habitat-discovery.md:93,141` — "The
  string `template-version:` in an HTML comment near the top", one of the markers
  `/assess` uses to recognise that a project has a harness at all

### Why this matters

Two distinct problems. First, §2.2 says the discovery story reduces to the README
line, but it currently also includes a monthly command that prints
`Manual remediation suggested for: Template version drift`. Deleting that is a
second, separate reduction, and the section that exists to state losses plainly
does not state it. Second, `habitat-discovery` is a reader, not a writer: removing
it stops `/assess` recognising markers that, per O6, will remain in most projects
for a long time. Deleting the reader before the data is gone is backwards, and it
is invisible in a table whose column heading is "What is deleted".

## O8 — alternatives — high

### Claim

Every alternative in §7 preserves or repairs the nudge. The option of deleting
less — removing the SessionStart hook, which is where the demonstrated harm lives,
while keeping the pull-direction surfaces — is never weighed.

### Evidence

§7's four entries are "Compare heading sets (revision 1)", "Filter the compared set
(revision 2)", "Fix the template's own content marker and read that", and "Keep the
marker but make its absence an opt-out". The harm §1 documents is specific to the
hook:

> So the SessionStart hook asserts `Plugin template has been updated` on evidence
> that cannot establish it, and the false signal reached the governing document

Whereas the `/harness-sync` surface presents the same fact as a `[manual]` row in a
table the user asked for, at a monthly cadence, alongside eight other surfaces
(`commands/harness-sync.md:130-144`).

### Why this matters

Spec time is the only moment this question is cheap. The spec's own §2.1 argument
is that each revision paid in mechanism to defend a nudge; deleting the hook and
nothing else pays *nothing* in mechanism, removes the every-session false
assertion, and leaves the monthly surface, the observatory signal, and the
habitat-discovery marker in place. It may be the wrong answer — a `drifted` row
computed from a broken proxy is still a false statement, and there is a real case
for coherence — but it is the alternative closest to the problem statement, and
the reader cannot see whether it was considered and rejected or simply not
considered.

## O9 — risk — medium

### Claim

The spec records a reopening condition and a reopening option, and then removes
from the install base the artefact that option needs, without noting that
reopening now costs a second migration.

### Evidence

> §2.2: If a future adopter reports missing template content they would have wanted
> to know about, that is evidence this decision was wrong and is worth reopening
> on

> §7: **If the answer to §2.2 turns out to be wrong, this is the option to reopen
> on** — it is recorded here in enough detail to be taken up without re-deriving it.

§5 removes the project-side `<!-- template-version: … -->` marker on every run,
and §3 removes it from the template so new projects never get one.

### Why this matters

The reopening option compares a marker in the project's harness against the
template's own content marker. Taking it up later means re-introducing the marker
to the template *and* re-populating it across projects — a second migration through
the same partially-reaching channel as the first. "Without re-deriving it" is true
of the design and false of the cost. There is also no rollback story anywhere in
the spec: reverting the plugin does not restore what step 6 removed from files the
plugin does not own. A deletion spec that names its own falsification condition
should say what undoing looks like, even if the answer is "we accept it is
one-way".

## O10 — risk — high

### Claim

Stripping the marker while the old hook still exists on other machines and in older
plugin caches converts a per-upgrade nudge into a permanent every-session one, and
the new command removes the only mechanism that could silence it.

### Evidence

`hooks/scripts/template-currency-check.sh`:

> `:32-34` — `# If no marker exists, treat as needing upgrade` … `harness_version="0.0.0"`
> `:43-45` — exits only when versions match
> `:48-53` — silenced only by `.claude/.harness-upgrade-dismissed` containing the current plugin version

§5 relies on exactly this semantics for its own argument — "Under the semantics
being deleted, an absent marker reads as `0.0.0` … so the rule reports drift on
every run, permanently, with no way to clear it" — and applies it to the GC rule
but not to the hook. §3 then states: "`.claude/.harness-upgrade-dismissed` is no
longer written or read."

### Why this matters

The reasoning in §5 is correct and incomplete. The same "absent reads as 0.0.0"
property makes the old hook fire on every session for any project whose marker has
been migrated away but which is opened with an older plugin version — a teammate
who has not upgraded, a second machine with a stale versioned cache, or a
deliberate downgrade. Previously that user could silence it by running
`/harness-upgrade`; after this change the command no longer writes the dismissal
file, so the only escape is to upgrade the plugin or hand-edit a gitignored file
they have never heard of. §3 keeps the `.gitignore` line specifically because "the
file exists on machines that ran the old command" — the spec is already reasoning
about heterogeneous installs at that point and stops one step short. Note also that
`docs/plugins/ai-literacy-superpowers/reference/hooks.md:287` documents the
opposite behaviour ("Exits silently if `HARNESS.md` does not exist or the marker is
absent"), so anyone checking this against the docs rather than the script will
conclude there is no problem.

## O11 — specification quality — medium

### Claim

The GC-rule removal predicate is prose that was never checked against the text it
must match, and the spec defines no behaviour for the cases where it half-matches
or cannot run.

### Evidence

> §5: a `### Template currency` GC rule whose **Tool** field references the
> template-version comment, it is removed;

The shipped template's rule (`templates/HARNESS.md:335-344`) has
`**Tool**: compare template-version comment in HARNESS.md against plugin.json
version`, spanning two lines. This repository's copy (`HARNESS.md:760-769`) matches.
Nothing in the spec records that check, and §2.1 records what happened last time:

> an exclusion predicate that matched nothing — the `<!-- affordance-example -->`
> tag sits on the line *below* each heading … verified by
> `grep '^###.*affordance-example'` returning zero matches

§5's only defined output is "step 7 reports each removal by name."

### Why this matters

Three unhandled cases, all plausible: a project that renamed the heading (the rule
is removed from neither the marker nor the report — it just silently persists); a
project that reworded the Tool field, perhaps to point at a script, which was
revision 2's own proposal; and a project that specialised the rule into something
it still wants. The first two leave the orphan the migration exists to remove while
reporting success; the third deletes wanted content. Because the report only names
removals, "nothing was reported" is indistinguishable from "nothing was found" and
from "the file could not be parsed" — the reassuring answer again, which the
repository's harness names a defect rather than a default. A one-line "if a
`### Template currency` heading is present but the Tool field does not match,
report it and leave it alone" closes all three.

## O12 — scope — high

### Claim

The surface enumerations in §3 and §12 are presented as grep-derived and are not
complete, and no counterpart to §3.1's careful signal arithmetic exists for the
hook count that a committed Layer 0 test enforces.

### Evidence

> §12: Same PR. Derived from the grep in §6, not by hand:

`how-to/sync-harness.md` is in that list but matches none of §6's four terms, so
the list is partly hand-made. Missing from §3/§12 entirely: `README.md:371`,
`hooks/hooks.json:2` (the description field), `templates/CLAUDE.md:220`,
`docs/plugins/ai-literacy-superpowers/reference/skills.md:46`,
`.../reference/output-validation.md:33`, `.../tutorials/first-time-tour.md:558`
(a tutorial section that walks a new user through the hook),
`.../explanation/the-harness-lifecycle.md:161`,
`.../explanation/the-loops-that-learn.md:36`, and
`commands/harness-sync.md:138`. §12 also describes sync-harness.md as carrying
"three references"; it carries four (`:36`, `:65`, `:86`, `:134`).

On counts, `hooks.json` declares 18 hooks, four of them SessionStart.
`tdad_tests/layer0_deterministic/test-hooks-doc-parity.sh:19` records what happened
when that count last went stale: "hooks.json declares 18; the page documented 16".
§3.1 does this arithmetic explicitly for the observatory total (82 → 81, in four
places) and the spec contains nothing equivalent for hooks.

### Why this matters

CLAUDE.md's docs convention is explicit that behaviour changes require checking
whether explanation pages describe the old behaviour. A tutorial that tells a new
user "compares the template version marker in your…" and a concepts page that says
"SessionStart hook nudges you when the template version has moved" will be
published describing a mechanism that does not exist — which is the same failure
mode §1 opens with, relocated from `HARNESS.md` to the docs site. The hook count is
narrower but sharper: it is enforced by a test, the spec shows it knows this class
of arithmetic exists, and the omission means CI is the thing that discovers it.

## Explicitly not objecting to

- **The decision to delete rather than repair.** The cost argument in §2.1 —
  three revisions, each paying more mechanism to defend the same premise — is
  strong on its own terms, and O1 challenges the evidence it is stated on, not
  the conclusion.
- **§4's decision to leave the three-bucket parse alone.** This is the clearest
  improvement over revision 2 and directly answers a prior objection; touching
  neither the parse nor the buckets is the right call and is well justified.
- **§3.1's observatory arithmetic.** It is the one place the spec chases a
  hard-coded count to every location and reasons about archived snapshots; I
  verified the signal row at `observatory-signals.md:127` and the required flag,
  and the reasoning is sound. My objection is that this care was not extended to
  hooks, not that it was misapplied here.
- **Keeping the `.gitignore` line.** The reasoning — the file exists on machines
  that ran the old command, and removing the ignore would surface it as untracked
  — is correct and is the kind of residue thinking the rest of §6 needs more of.
- **§8's out-of-scoping of the declined-item record.** Deferring it is defensible,
  and the reason given (the record's grammar generated two prior objections) is
  honest about why.
- **§11's version bump.** Minor for a behavioural plugin change across the five
  CI-checked locations is exactly what CLAUDE.md prescribes; there is nothing to
  challenge.
- **"Who in the install base relies on this nudge."** Someone should ask adopters
  before removing a capability from their projects, but the remedy is a
  conversation rather than a change to the spec, so under the Routing Rule that
  finding belongs to the Convener's consultation record, not here.
- **Grammar, line-number drift, and table formatting.** Several cited line numbers
  are already one or two off (`harness-init.md:184,211` against `:182,210,222`);
  that is normal spec decay and not worth an objection, except where it indicates
  a missed surface, which O12 covers.
