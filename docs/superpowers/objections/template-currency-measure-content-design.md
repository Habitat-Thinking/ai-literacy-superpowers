---
spec: docs/superpowers/specs/2026-08-25-template-currency-measure-content-design.md
date: 2026-08-25
mode: spec
diaboli_model: claude-opus-5[1m]
objections:
  - id: O1
    category: implementation
    severity: critical
    claim: "A default /harness-init run produces a HARNESS.md that is missing template headings by design, so the new hook nudges on the very next session — reproducing the cry-wolf defect the spec exists to remove."
    evidence: "§4.1 'missing = tpl_headings - proj_headings - declined'; commands/harness-init.md step 3 'Affordances ... opt-in (default off)' and step 7 'For each unselected feature, replace the section body with the placeholder marker'; templates/HARNESS.md:519-557 declares '### gh-cli', '### honeycomb-mcp', '### shell-write-to-tmp', '### sync-to-global-cache-hook', each tagged '<!-- affordance-example -->'."
    disposition: pending
    disposition_rationale: null
  - id: O2
    category: implementation
    severity: high
    claim: "Case-insensitive, whitespace-trimmed matching does not match the template's commented section headings, which carry instructional parentheticals on the heading line; the design produces a permanent false positive on the repository used to verify it."
    evidence: "§4.1 'Matching is case-insensitive and whitespace-trimmed'; templates/HARNESS.md:630 '<!-- ## Cognitive reservoir  (OPTIONAL — to opt in, remove this `<!--` line and the closing `-->` below)' versus HARNESS.md:1126 '## Cognitive reservoir'."
    disposition: pending
    disposition_rationale: null
  - id: O3
    category: specification quality
    severity: high
    claim: "The declined block is called load-bearing but has no grammar: the stated one-line-per-entry rule is contradicted by the spec's own example, and nothing defines continuation lines, duplicate entries, headings containing a colon, or reason text containing the comment terminator."
    evidence: "§3.4 'One line per declined heading, `Heading: reason`' immediately below an example whose single entry wraps across three indented lines; §4.3 step 4 'Declining prompts for a one-line reason and writes it to the declined block'; §3.4 'The reason text is never parsed.'"
    disposition: pending
    disposition_rationale: null
  - id: O4
    category: scope
    severity: high
    claim: "The surfaces table is incomplete: /harness-sync computes and reports 'Template version drift' in three places and is not listed, so a mechanism that reports drift will survive the input it reads being deleted."
    evidence: "§4.6 lists seven files, none of them commands/harness-sync.md, which carries 'Template version drift' (line 118), the drift-table row 'Template version (HARNESS: 0.31, plugin: 0.34) drifted /harness-upgrade [manual]' (line 138), and the JSON item '\"id\": \"template\", \"label\": \"Template drift  [manual: /harness-upgrade]\"' (lines 206-208). docs/contributing/index.md:195 and docs/plugins/ai-literacy-superpowers/how-to/sync-harness.md (six references) are also absent from §4.6 and §8."
    disposition: pending
    disposition_rationale: null
  - id: O5
    category: premise
    severity: medium
    claim: "The only affirmative evidence for keeping a nudge at all is a case the spec admits cannot be settled, while the spec's hard evidence records no instance of the nudge ever producing a useful adoption."
    evidence: "§1 'Five of the last six marker advances adopted nothing'; §1 'This cannot be settled now — the 0.73.2 plugin cache is no longer on the machine that ran it'; §3.3 'Rejected because the ## Stakeholders case suggests the failure mode that actually costs something is not being told.'"
    disposition: pending
    disposition_rationale: null
  - id: O6
    category: implementation
    severity: high
    claim: "The spec asserts the hook and the command can never disagree, but they are two independent implementations of one parser — a bash script and a prose instruction executed by a model — and the repository already carries a GC rule because that exact drift happens here."
    evidence: "§4.1 'identical to /harness-upgrade step 2, so the hook and the command never disagree about what is new'; §4.4 'Both the hook and the command extract headings from inside HTML comments at every level'; HARNESS.md:690 '### Command-prompt sync'."
    disposition: pending
    disposition_rationale: null
  - id: O7
    category: risk
    severity: high
    claim: "The hook reaches the passing, silent outcome on a path where it never read the thing it reports on, which the in-force harness decision record names as a defect rather than a default."
    evidence: "§4.1 'exit 0 if either file is unreadable (unchanged: advisory, never blocks)'; §5 criterion 9 'The hook never blocks and never exits non-zero'; HDR-2026-08-25 (compiled into skills/advocatus-diaboli/SKILL.md): 'A reachable code path that reaches a passing value without reading the thing it reports on is a defect, not a default.'"
    disposition: pending
    disposition_rationale: null
  - id: O8
    category: scope
    severity: medium
    claim: "The design removes the only way to silence the nudge without acting on it, so any item the user skips re-fires every session forever, and the spec never states this consequence."
    evidence: "§4.5 '.claude/.harness-upgrade-dismissed is no longer written or read'; §4.3 step 4 'Skip remains what it is today: not now, ask again next time'; §4.1 subtracts only 'declined' from the missing set."
    disposition: pending
    disposition_rationale: null
  - id: O9
    category: specification quality
    severity: medium
    claim: "The test plan assigns command behaviour to a hook test file and leaves the write path of the load-bearing declined block with no acceptance criterion at all."
    evidence: "§5 'Criteria 1-7 and 9 are Layer 0 deterministic tests at tdad_tests/layer0_deterministic/test-template-currency-check.sh' where criterion 6 is '/harness-upgrade removes it and reports having done so' and criterion 7 covers 'both the hook and the command'; no criterion covers §4.3 step 4/6 writing a declined entry."
    disposition: pending
    disposition_rationale: null
  - id: O10
    category: alternatives
    severity: medium
    claim: "The rejected-alternatives section weighs four ways to compare but never weighs narrowing what is compared, which would remove most false positives without inventing per-project declined state at all."
    evidence: "§6 rejects the template's own marker, hashing, full-text diff, and a separate file — all four vary the comparison method, none varies the item set; §4.1 compares '## and ###, incl. commented' with no exclusion for placeholders, examples, or opt-in blocks."
    disposition: pending
    disposition_rationale: null
  - id: O11
    category: implementation
    severity: medium
    claim: "The spec never states which copy of the template is authoritative, and in this repository the copy it names is rsynced from the working tree on every Stop, so editing the template nudges the editor about their own unfinished edit."
    evidence: "§4.1 'tpl = $CLAUDE_PLUGIN_ROOT/templates/HARNESS.md'; CLAUDE.md 'sync-to-global-cache.sh — rsyncs plugin content into the versioned plugin cache (runs on every Stop)'; §1's ## Stakeholders timeline turns on which copy 89b46f9 compared against and the spec does not say."
    disposition: pending
    disposition_rationale: null
  - id: O12
    category: risk
    severity: medium
    claim: "The PR knowingly merges a governing document whose Status block overstates its own coverage, and removes a signal the observatory reference marks required."
    evidence: "§4.6 'HARNESS.md's Status block references the marker. It is owned by /harness-audit and is corrected by running it, not by hand-editing this PR'; HARNESS.md:760-769 declares 'Template currency' with 'Enforcement: deterministic'; HARNESS.md:1174 'Garbage collection active: 19/19'; §4.6 'observatory-signals.md:127 | Template version is marked required; remove the row'."
    disposition: pending
    disposition_rationale: null
---

## O1 — implementation — critical

### Claim

A default `/harness-init` run produces a `HARNESS.md` that is missing template
headings by design. Under the proposed set difference, that project is nudged on
its very next session — naming, among other things, example affordances it was
never meant to adopt. The replacement signal cries wolf on day one, for the
default user, which is the defect the spec exists to remove.

### Evidence

The algorithm is a plain set difference over headings:

> `missing = tpl_headings - proj_headings - declined` (§4.1)

`/harness-init` is documented to produce a project file that is *not* a superset
of the template:

> **Affordances** is opt-in: if **unselected** (the default), replace the
> `## Affordances` section body with the placeholder marker like any other
> unselected feature. (`commands/harness-init.md`, step 7)

and, generally:

> For each unselected feature, replace the section body with the placeholder
> marker. (`commands/harness-init.md`, step 7)

The template's `## Affordances` body contains four headings, each explicitly
tagged as an example:

```text
templates/HARNESS.md:519  ### gh-cli                    <!-- affordance-example -->
templates/HARNESS.md:534  ### honeycomb-mcp             <!-- affordance-example -->
templates/HARNESS.md:545  ### shell-write-to-tmp        <!-- affordance-example -->
templates/HARNESS.md:556  ### sync-to-global-cache-hook <!-- affordance-example -->
```

The template also carries a literal placeholder heading no project should ever
have: `templates/HARNESS.md:194  ### [Governance constraint name]`.

A user who deselects Garbage collection loses roughly twenty-five `###` headings
in one step. The spec verified its algorithm against one repository — this one —
whose `HARNESS.md` happens to be a near-superset of the template, including the
`[Governance constraint name]` placeholder at line 639 and all four affordance
examples. That is the single least representative sample available.

### Why this matters

§1's charge against the marker is that it "asserts `Plugin template has been
updated` on evidence that cannot establish it". The replacement asserts
`Template has 4 item(s) your harness does not: "gh-cli", "honeycomb-mcp", ...`
on evidence that is technically true and semantically false — those are examples,
not items. The message §4.2 is proud of ("A reader can falsify it against their
own file") is worse here, not better: the reader falsifies it, finds it correct,
and concludes the mechanism is stupid rather than wrong.

§3.4 anticipates the *class* of this problem and answers it with the declined
block. But that answer has a cost the spec does not budget: the only way to
populate the declined block is to run `/harness-upgrade` and decline each item.
The nudge whose purpose is to sell `/harness-upgrade` can only be silenced by
running `/harness-upgrade` — on a fresh project, before the user has any reason
to trust it, for four items that were never content. Either the template must
mark non-adoptable headings so the comparison can exclude them, or `/harness-init`
must seed the declined block from what it chose not to write.

## O2 — implementation — high

### Claim

The specified normalisation — case-insensitive and whitespace-trimmed — does not
match the template's commented section headings, because those headings carry
instructional parentheticals on the heading line itself. The result is a
permanent false positive on the very repository the spec used to verify the
design.

### Evidence

> Matching is case-insensitive and whitespace-trimmed, identical to
> `/harness-upgrade` step 2, so the hook and the command never disagree about
> what is new. (§4.1)

The template's opt-in section heading:

```text
templates/HARNESS.md:630
<!-- ## Cognitive reservoir  (OPTIONAL — to opt in, remove this `<!--` line and the closing `-->` below)
```

This repository's adopted version:

```text
HARNESS.md:1126
## Cognitive reservoir
```

Extracted per §4.4 ("extract headings from inside HTML comments at every level"),
the template heading is `Cognitive reservoir  (OPTIONAL — to opt in, remove this
` + backtick-quoted markup + `line and the closing ... below)`. Trimming and
case-folding do not reduce that to `Cognitive reservoir`. The heading is reported
missing, every session, on a repository that adopted it months ago.

Acceptance criterion 4 covers commented headings and criterion 7 covers case and
whitespace. Neither covers a parenthetical suffix, so a conforming implementation
passes the whole suite and still fires this every session.

### Why this matters

The spec's §1 does its verification work well — `diff`, exit codes, commit
hashes, dates. §5 does not extend that discipline to the new algorithm. Nothing
in the spec records the output of running the proposed comparison against this
repository's real `HARNESS.md` and the real template. Had that been run, this
would have surfaced before review, along with whatever else it turns up. The
missing artefact is one paragraph: *here is the missing set the new rule produces
today, and here is why each entry is correct.*

## O3 — specification quality — high

### Claim

§3.4 calls the declined-item record load-bearing and then gives it no grammar.
The stated format contradicts the spec's own example, and nothing defines
continuation lines, duplicates, headings containing a colon, or the one input
that can corrupt the file it lives in.

### Evidence

The rule:

> One line per declined heading, `Heading: reason`. (§3.4)

The example, directly above it:

```html
<!-- template-declined
     Consistent formatting: specialised here as "Consistent markdown
       formatting" (deterministic, markdownlint, commit + pr). Adopting the
       template's unverified placeholder would be a downgrade.
-->
```

That is one declined heading occupying three lines with two distinct indentation
levels. A parser written to the rule reads three entries: `Consistent formatting`,
`formatting" (deterministic, markdownlint, commit + pr). Adopting the` (no
colon — dropped or malformed), and one more. A parser written to the example
needs a continuation convention the spec never states.

The reason text is user-supplied and machine-written:

> Declining prompts for a one-line reason and writes it to the declined block.
> (§4.3, step 4)

> The reason text is never parsed. (§3.4)

Never parsed is not the same as harmless. The block is an HTML comment. A reason
containing `-->` terminates it early, uncommenting whatever follows — in a file
whose commented blocks are semantically load-bearing, since §4.1 and the
`## Cognitive reservoir` opt-in both turn on comment state.

### Why this matters

This block is the only thing standing between the new comparison and the old
defect — §3.4 says so plainly: "Heading comparison alone reproduces the original
defect in a new coat." It is read by a bash script and written by a model
following prose. A silent parse failure does not fail loudly; it re-admits the
declined item to the missing set, and the mechanism resumes crying wolf about
the exact item three humans already declined on the record. That failure is
indistinguishable, from the user's seat, from the bug being fixed.

Specify the grammar as strictly as the `## Cognitive reservoir` value lines are
specified — that block already carries a written warning about exactly this class
of parser fragility (`HARNESS.md:1145-1148`), which is the precedent to follow.

## O4 — scope — high

### Claim

The §4.6 surfaces table is incomplete. `/harness-sync` reads and reports
`Template version drift` in three separate places and does not appear in the
table, so after this ships a drift-reporting mechanism will be reporting on an
input that no longer exists.

### Evidence

§4.6 lists seven files. `commands/harness-sync.md` is not among them, and it
carries:

```text
line 118  - Template version drift                            (surface list)
line 138  Template version (HARNESS: 0.31, plugin: 0.34) drifted  /harness-upgrade  [manual]
line 207  "label": "Template drift  [manual: /harness-upgrade]"    (checkbox JSON, id: "template")
line 271  Manual remediation suggested for: Template version drift
```

Also absent from §4.6 and from §8's docs list:

- `docs/contributing/index.md:195` — "**Template currency** — detects when the
  HARNESS.md template version is behind the installed plugin version."
- `docs/plugins/ai-literacy-superpowers/how-to/sync-harness.md` — six references,
  including a worked drift-table row and a "Template drift" remediation section.

§4.6 does list `skills/harness-audit-engine/SKILL.md:33`, which is the drift
surface table row — correctly. The point is not that the spec was careless; it is
that the enumeration method found seven of ten and the spec presents it as
complete.

### Why this matters

`/harness-sync` is one of the two monthly operations in `CLAUDE.md`. After this
merges, its drift scan has a row whose input has been deleted. It will either
error, or report `drifted` forever, or — most likely, and worst — report
`in sync`, because "no marker found" collapses to "nothing to compare". That is
the failure HDR-2026-08-25 names: a status mechanism reaching the reassuring
answer without reading the thing it reports on. The spec removes the marker on
the strength of an inventory that missed the mechanism most likely to fail that
way.

## O5 — premise — medium

### Claim

The spec's own evidence records no instance of this nudge ever producing a useful
adoption, and the single case offered in its favour is one the spec states cannot
be settled. On that basis the design keeps the nudge and adds new per-project
governance state to it.

### Evidence

Against:

> Five of the last six marker advances adopted nothing. (§1)

> The 2026-08-25 run reached the same conclusion about the same item a third
> time. (§1)

In favour, in full:

> `d867c7c` added a commented-out `## Stakeholders` section ... `89b46f9` ran six
> hours later, reported "byte-identical … nothing to adopt" ... This cannot be
> settled now — the `0.73.2` plugin cache is no longer on the machine that ran
> it. (§1)

And the decision that rests on it:

> Rejected because the `## Stakeholders` case *suggests* the failure mode that
> actually costs something is *not being told*. (§3.3, emphasis added)

### Why this matters

§3.3 is the right question asked once and answered from the weaker of the two
available bodies of evidence. Six recorded runs adopting nothing is data; one
unattributable miss is an anecdote whose cause §4.4 guesses at (see O11 for a
third candidate cause). The cost of being wrong here is not the hook — it is
§3.4's declined block, a new durable governance artefact in every project that
adopts the plugin, kept alive to serve a signal with no recorded success.

I am not asserting the nudge is worthless; §3.3 may well be right that *not being
told* is the expensive failure. I am objecting that the spec does not know, says
so, and proceeds as though the question were closed. The honest form of §3.3 is
either evidence that someone was ever usefully told, or an explicit statement
that the nudge is being retained on judgement rather than data.

## O6 — implementation — high

### Claim

The spec asserts an invariant its architecture cannot supply. The hook and the
command are two independent implementations of one parser — one bash, one prose
executed by a model — and this repository already runs a GC rule because that
exact drift is a known local failure class.

### Evidence

> Matching is case-insensitive and whitespace-trimmed, identical to
> `/harness-upgrade` step 2, so the hook and the command never disagree about
> what is new. (§4.1)

> Both the hook and the command extract headings from inside HTML comments at
> every level. (§4.4)

`hooks/scripts/template-currency-check.sh` is bash. `commands/harness-upgrade.md`
is a markdown prompt: "Match items by heading name (case-insensitive, trimmed)"
(step 2). The second is an instruction to a model, not an implementation.

The repository's own position on this class:

```text
HARNESS.md:690  ### Command-prompt sync
```

### Why this matters

"Never disagree" is doing load-bearing work in this design. §4.3 has the command
subtract declined headings and present a *Previously declined* group; §4.1 has
the hook subtract the same set. If they diverge, the user is nudged about an item
the command will not show them, or shown an item the hook never mentions —
either of which reads as the mechanism being broken, because it is.

The single-implementation alternative is available and unweighed: have step 2
invoke `template-currency-check.sh` (or a shared extraction script) and consume
its output, rather than restating its rules in prose. That would make the
invariant structural instead of asserted, and would collapse §4.4's "both the
hook and the command" into one change instead of two that must agree.

## O7 — risk — high

### Claim

The hook reaches its silent, passing outcome on a code path where it has not read
the thing it reports on. The harness decision record in force names that a defect
rather than a default, and the spec carries the behaviour forward marked
"unchanged".

### Evidence

> `exit 0 if either file is unreadable          (unchanged: advisory, never blocks)`
> (§4.1)

> 9. The hook never blocks and never exits non-zero. (§5)

Against HDR-2026-08-25, compiled into
`ai-literacy-superpowers/skills/advocatus-diaboli/SKILL.md` and in force until
2026-11-23:

> A mechanism that reports a status ... must have a defined value for the case
> where it could not determine the answer, and that value may not be the passing
> one. Where an input is missing, unreadable or not supplied, the mechanism
> reports the degraded or unknown state and names the input it could not read.

The unreadable case is not hypothetical for this hook: `$CLAUDE_PLUGIN_ROOT` is
unset outside a plugin context, and the current script already exits 0 in three
such places (lines 19-26, 38-40).

### Why this matters

There is no tension between the HDR and "never blocks" — a `systemMessage` naming
the unreadable input satisfies both, and §4.2 already establishes the message
channel. What the spec has done is carry an old behaviour forward under the word
"unchanged", which is precisely how a mechanism that fails toward the reassuring
answer survives a rewrite that was otherwise willing to delete everything.

The consequence is specific: a project whose plugin root is misconfigured gets
silence, reads silence as "my harness is current", and stops looking. That is the
same failure §1 describes, arrived at from the other direction — §1's mechanism
lied loudly, this path lies quietly.

## O8 — scope — medium

### Claim

The design removes the only mechanism for silencing the nudge without acting on
it, leaving *skip* as a disposition that guarantees the item re-fires every
session forever. The spec does not state this consequence.

### Evidence

> `.claude/.harness-upgrade-dismissed` is no longer written or read. (§4.5)

> **Skip** remains what it is today: not now, ask again next time. (§4.3, step 4)

> `missing = tpl_headings - proj_headings - declined` (§4.1)

Skipped items are not in `declined`, so they remain in `missing`. Under the old
design, the dismissal file silenced the hook until the next plugin version — a
skip bought the user weeks. Under the new one, "ask again next time" means the
next session, and the one after that.

### Why this matters

The spec's central charge is alert fatigue: an item declined three times on
recorded reasoning kept coming back. §3.4 solves that for *decline* and leaves
*skip* with strictly worse ergonomics than it has today. A user who wants to
consider an item next month has exactly two options: adopt it, or record a formal
decline they do not mean. The predictable outcome is that people decline things
to make the nudge stop, which converts §3.4's "declining is a considered act
rather than a suppression" into its opposite.

Either skip needs a time-boxed silence, or the spec should say plainly that skip
now means "nudge me every session until you decide" and accept that as the design.

## O9 — specification quality — medium

### Claim

The test plan assigns command behaviour to a hook test file, and leaves the write
path of the declined block — the mechanism §3.4 calls load-bearing — with no
acceptance criterion at all.

### Evidence

> Criteria 1-7 and 9 are Layer 0 deterministic tests at
> `tdad_tests/layer0_deterministic/test-template-currency-check.sh` (§5)

Criterion 6 is:

> Given a `HARNESS.md` with a `template-version` marker, `/harness-upgrade`
> removes it and reports having done so.

That is a model-executed command, not the hook script named as its test location.
Criterion 7 spans "both the hook and the command", so at most half of it can live
there. Criterion 8, correctly, is excluded from the deterministic list — which
shows the boundary was noticed for one criterion and not the neighbouring two.

Every declined-block criterion is a *read* criterion. Criterion 3 assumes a
correctly formed block already exists; criterion 8 assumes the command can read
one. Nothing tests that §4.3 step 4 and step 6 *write* a block that criterion 3
can read.

### Why this matters

Given O3, the write path is where this design is most likely to fail, and it is
the one path with neither a specified format nor a test. The round trip is the
thing worth pinning: decline an item via the command, then run the hook and
observe silence. Written as a Layer 0 fixture pair, that single test would catch
every grammar ambiguity in O3 without the spec having to resolve them in prose
first.

## O10 — alternatives — medium

### Claim

§6 weighs four alternative ways to *compare*, and never weighs narrowing *what*
is compared. Excluding placeholders, examples, and opt-in blocks from the item
set removes most of the false-positive load without inventing per-project
declined state at all.

### Evidence

All four rejected alternatives vary the comparison method:

> **Compare the template's own content marker** ... **Hash the template and store
> the hash** ... **Full-text diff instead of heading sets** ... **Record declines
> in a separate file.** (§6)

The item set is fixed by one parenthetical and never revisited:

> `tpl_headings   = headings of tpl             (## and ###, incl. commented)` (§4.1)

The template already distinguishes the categories that would be excluded, in
machine-readable form: `<!-- affordance-example -->` (lines 520, 535, 546, 557),
`<!-- Uncomment if ... -->` wrappers (lines 147, 181, 192, 372, 406, 446), and a
bracketed placeholder heading (`### [Governance constraint name]`, line 194).
`/harness-upgrade` step 2 already keys on the `<!-- Uncomment if...` pattern
today.

### Why this matters

§3.4's declined block exists because "heading comparison alone reproduces the
original defect in a new coat". That is true of an *unfiltered* heading
comparison. A filtered one — active constraints and GC rules, excluding examples
and placeholders — reduces the standing false-positive set from O1's dozens to
approximately the one case §3.4 actually cites (`Consistent formatting` versus
`Consistent markdown formatting`), which is a genuine specialisation and the only
case where a recorded human decision is really needed.

That is a materially cheaper design: it drops a new durable per-project artefact,
its grammar (O3), its write path (O9), and the new `decline` disposition, in
exchange for a filter over a set the template already tags. §6 should say why it
is worse, or take it.

## O11 — implementation — medium

### Claim

The spec never states which copy of the template is authoritative. The path it
names is, in this repository, rsynced from the working tree on every `Stop` —
which both creates a self-referential false positive during template development
and supplies a third, simpler explanation for §1's `## Stakeholders` case than
the parsing asymmetry §4.4 fixes.

### Evidence

> `tpl      = $CLAUDE_PLUGIN_ROOT/templates/HARNESS.md` (§4.1)

`CLAUDE.md`, Marketplace Cache Auto-Sync:

> `ai-literacy-superpowers/scripts/sync-to-global-cache.sh` — rsyncs plugin
> content into the versioned plugin cache (runs on every `Stop`)

So in this repository the hook compares the project's `HARNESS.md` against a
template copy that tracks the working tree within one session. And §1's timeline:

> `d867c7c` added a commented-out `## Stakeholders` section to the template on
> 2026-08-13 at 09:11. `89b46f9` ran six hours later, reported "byte-identical …
> nothing to adopt". (§1)

Whether that report was wrong depends entirely on which copy `89b46f9` read — and
the spec does not say, while §4.4 proceeds as though parsing were the cause:

> This is the parsing half of the `## Stakeholders` case in §1. (§4.4)

### Why this matters

Two distinct consequences. First, operationally: a maintainer who adds a heading
to `templates/HARNESS.md` gets nudged, in their next session, that their own
harness is missing the thing they just wrote. That is a new failure the current
version-based hook does not have.

Second, epistemically: if `89b46f9` compared against a cache copy that predated
`d867c7c`, then the comparison was *correct*, §4.4 fixes a bug that was not the
cause, and the one piece of evidence sustaining §3.3's decision to keep the nudge
(O5) evaporates. §4.4 is worth doing regardless — commented headings should parse
uniformly — but it should not be presented as the explanation of a case the spec
has not attributed. Naming the authoritative copy, and what happens when it is
the working tree, closes both.

## O12 — risk — medium

### Claim

The PR knowingly merges a governing document whose Status block overstates its own
coverage, and removes a row the observatory reference marks required, without
saying what either consequence is.

### Evidence

> `HARNESS.md`'s Status block references the marker. It is owned by
> `/harness-audit` and is corrected by running it, not by hand-editing this PR.
> (§4.6)

The rule being removed is deterministic and counted:

```text
HARNESS.md:760-769   ### Template currency ... **Enforcement**: deterministic
HARNESS.md:1174      Garbage collection active: 19/19
```

After the removal, 19/19 describes eighteen rules. And:

> `skills/harness-observability/references/observatory-signals.md:127` |
> `Template version` is marked **required**; remove the row (§4.6)

### Why this matters

§4.6's reasoning is right about ownership — `/harness-audit` owns the Status
block, and hand-editing it is worse than leaving it. But the choice presented is
false: the third option is to run `/harness-audit` as part of this change, which
the repository's own convention supports, and which turns "the governing document
is wrong until someone notices" into "the governing document is correct at merge".
Leaving it stale is the same fail-toward-reassuring pattern as O7, in the document
that is supposed to be the source of truth for all the others — and this
repository's Status block already carries a written record of exactly this
happening before ("The 2026-08-13 audit recorded `Drift detected: no` against a
tree that already carried every failure listed here", `HARNESS.md:1177`).

On the observatory signal: the spec says to remove a row marked **required**
without stating whether `required` is enforced, what reads it, or what happens to
archived snapshots that carry the field. If nothing enforces it, say so; if
something does, this is a schema change and belongs in §4.6 with its consumers
named.

## Explicitly not objecting to

- **§1's evidence quality**: the problem statement is the strongest part of this
  spec — byte-level `diff` results, commit hashes, dates, and a stated
  verification date. It establishes the marker is a bad proxy beyond argument,
  and I am not challenging that conclusion anywhere in this record.
- **Retiring the marker rather than making it optional (§3.1)**: the reasoning is
  correct and well argued — opting out of a broken signal is not fixing it, and
  the projects most in need of a nudge are exactly the ones that would go quiet.
- **Rejecting the `none` sentinel (§3.2)**: "Retiring the signal is cheaper than
  governing it" is the right call, and the spec correctly identifies that it is
  trading against a local declare-don't-infer preference rather than a rule.
- **Keeping the declined record in `HARNESS.md` rather than a new file (§6)**:
  the "two committed dashboards went 106 days unread" argument is concrete,
  local, and decisive. My objections to the declined block (O3, O9) are about its
  grammar and its tests, never its location.
- **The minor version bump and the five CI-checked locations (§7)**: correct per
  `CLAUDE.md`, correctly scoped as behavioural, and nothing here warrants a
  challenge.
- **Rejecting full-text diff (§6)**: "The property worth surfacing is a *missing
  item*, not a reworded one" is exactly right, and it is the sentence that keeps
  the message in §4.2 honest about what it compared.
- **The TDAD constraint analysis (§5)**: the spec correctly reasons that the
  *New plugin components must ship with a TDAD scenario* constraint does not gate
  this work, and adds the Layer 0 test anyway with a stated reason. That is the
  right relationship to a constraint and I am not going to punish it.
- **Leaving the `.gitignore` entry in place (§4.5)**: the reasoning — the file
  exists on machines that ran the old command, and removing the ignore surfaces
  it as untracked — is a small, correct piece of migration thinking that many
  specs would have missed.
- **The out-of-scope boundary**: excluding adoption mechanics, the evolution
  loop, and the `/harness-propose` routing question is a defensible line. My
  scope objections (O4, O8) are about surfaces inside the declared scope that the
  spec missed, not about where the line was drawn.
