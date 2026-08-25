# Template currency measures content — design

**Status:** proposed (revision 2)
**Date:** 2026-08-25
**Issue:** #601
**Provenance:** `docs/superpowers/specs/2026-04-15-harness-upgrade-design.md`,
which introduced the `template-version` marker and decided that a missing
marker means "treat as `0.0.0`". This spec retires the marker outright. The
issue as filed proposed making the marker optional; the approach here is
broader and is argued for in §3.1.
**Revision 2** rewrites §3 and §4 against
`docs/superpowers/objections/template-currency-measure-content-design.md`.
The comparison is now over a *filtered* item set (O10), which removes the
false-positive load that O1 and O2 identified and shrinks the declined-item
mechanism to the one case that needs it. §11 maps every objection to what
changed.
**Scope:** the SessionStart template-currency hook, `/harness-upgrade` step 1
and step 6, `/harness-init`'s marker write, the `Template currency` GC rule,
the `/harness-sync` template-drift surface, and the declined-item record.
**Out of scope:** `/harness-upgrade`'s adoption mechanics (steps 2–5) beyond
the parsing changes in §4; the harness evolution loop; whether
`/harness-upgrade` should route adopted items through `/harness-propose`.

## 1. Problem statement

The `template-version` marker claims to track template content. It tracks the
plugin version, which moves for reasons unrelated to the template.

Verified on 2026-08-25:

- The template shipped at plugin `0.79.0` and the template shipped at `0.89.0`
  are byte-identical (`diff`, exit 0). The `0.89.0` cache copy is byte-identical
  to `ai-literacy-superpowers/templates/HARNESS.md`.
- The last change to `templates/HARNESS.md` is `d867c7c`, 2026-08-13 — twelve
  days *before* `a81c552` stamped this repository's marker to `0.79.0`.
- The plugin moved ten minor versions across that window. The template moved
  zero bytes.
- The template carries its own content marker, `<!-- template-version: 0.57.0 -->`,
  last moved 2026-06-17 (`52e114a`). `d867c7c` changed the template's content
  without moving it. No mechanism reads it.

The consequence is a SessionStart hook that asserts `Plugin template has been
updated` on evidence that cannot establish it. The false signal reached the
governing document: `HARNESS.md`'s Status block records "eight minors of
unreviewed template content" against a template that had not changed.

Five of the last six marker advances adopted nothing. `58d3dda` (2026-07-22)
and `89b46f9` (2026-08-13) each record "found nothing to adopt", both naming
the same item — the generic `Consistent formatting` placeholder, declined
because this repository has specialised it into a deterministic markdownlint
rule. The 2026-08-25 run reached the same conclusion about the same item a
third time.

### 1.1 The `## Stakeholders` case, and what it does not establish

`d867c7c` added a commented-out `## Stakeholders` section to the template on
2026-08-13 at 09:11. `89b46f9` ran six hours later, reported "byte-identical …
nothing to adopt", and stamped the marker forward. The block was not adopted
until twelve days later, by a human who noticed it another way.

Revision 1 presented this as evidence that the nudge's valuable failure mode is
*not being told*, and presented §4's parsing fix as its explanation. Both
overstated it. There are at least three candidate causes and this spec
attributes none of them:

1. The run genuinely missed a commented-out section (a parsing gap).
2. The cache had not yet synced, so `89b46f9` compared against a copy predating
   `d867c7c` — plausible, because in this repository the cache is rsynced from
   the working tree on `Stop` (§4.6).
3. The section was seen and skipped.

The `0.73.2` plugin cache is no longer on the machine that ran it, so this
cannot be settled. §3.3 no longer rests on it.

## 2. The property that should be measured

The nudge names one property: *the template contains something your harness
does not*. The marker measures a different one: *the plugin has been released
since you last stamped a number*. These come apart on every release that does
not touch the template, which is nearly all of them.

`/harness-upgrade` already computes something close to the real property. Steps
2–3 parse both files into named items and diff them. Step 1's version gate is a
pre-filter in front of a comparison that does not need it, and the pre-filter is
the part that is wrong.

## 3. Decision — compare a filtered item set, retire the marker

The hook and the command compare **heading sets** between the plugin's
`templates/HARNESS.md` and the project's `HARNESS.md`. There is no marker, no
`plugin.json` read, and no stored version state.

The comparison is over a filtered set. Revision 1 compared every `##` and `###`
heading in the template, which produces false positives by construction — see
§3.4. The filter is what makes the mechanism quiet; the declined-item record
(§3.5) handles only the residue.

### 3.1 Why not the narrower change in #601

The issue proposed keeping the marker as an optional feature and treating its
absence as opt-out. That silences the false alarm for projects that remove the
marker and leaves it intact for everyone who keeps it — the version-as-proxy
flaw survives, and the projects most likely to need a nudge (those that never
had a marker) go permanently quiet. Opting out of a broken signal is not the
same as fixing it.

### 3.2 Why not an explicit `none` sentinel

Considered and rejected. A declared opt-out fits this repository's
declare-don't-infer culture, but it is additional mechanism in service of a
signal §1 shows is unreliable in both directions. Retiring the signal is
cheaper than governing it.

### 3.3 Why keep a nudge at all — on judgement, not on data

Stated plainly, because §1.1 removed the evidence revision 1 leaned on: **there
is no recorded instance of this nudge producing a useful adoption.** Six runs
are recorded; five adopted nothing, and the sixth cannot be attributed.

The nudge is retained on the judgement that a project which never learns its
template gained content has no other path to finding out, and that a correctly
filtered comparison costs two greps at session start. That is a judgement, and
a reviewer is entitled to reject it — §6 records deleting the nudge entirely as
a live alternative rather than a dismissed one.

What changed between revisions is the cost of being wrong. Revision 1 sustained
the nudge with a new durable per-project artefact in every adopting project.
This revision sustains it with a filter over headings the template already tags,
plus a declined block that is empty in a default project.

### 3.4 Why the item set must be filtered

An unfiltered heading comparison fires on the default install, on day one.

- `/harness-init` documents Affordances as "opt-in (default off)"
  (`commands/harness-init.md:57`) and replaces an unselected feature's section
  body with `<!-- Not yet configured. Run /harness-init and select this feature
  to set up. -->` (`:147`, `:154`).
- The template's `## Affordances` body carries four headings tagged
  `<!-- affordance-example -->` (`templates/HARNESS.md:520,535,546,557`).
- The template carries a literal placeholder heading, `### [Governance
  constraint name]` (`:194`).

So a default-initialised project is missing template headings *by design*, and
under an unfiltered rule is nudged about example affordances it was never meant
to adopt — silenceable only by running the command the nudge advertises.

Running revision 1's rule against this repository — a near-superset of the
template, the most favourable input available — produced two items:

```text
Consistent formatting
Cognitive reservoir  (OPTIONAL — to opt in, remove this `<!--` line and the closing `-->` below)
```

The second is pure false positive: `templates/HARNESS.md:630` carries
instructional text on the heading line, which no amount of trimming or
case-folding reconciles with this repository's `## Cognitive reservoir`
(`HARNESS.md:1126`). §4.2 fixes it in the template rather than working around
it in the parser.

### 3.5 The declined-item record, reduced to its residue

Filtering does not catch a genuine specialisation. This repository has
`Consistent markdown formatting`; the template has `Consistent formatting`.
Same intent, different name, and no filter can know that.

That case needs a recorded human decision, and it needs one because the decision
has already been made three times and written only into commit messages — which
is why the item keeps returning.

`HARNESS.md` gains a declined block. In a default project it is absent or empty;
in this repository it holds one entry.

```html
<!-- template-declined
Consistent formatting :: specialised here as "Consistent markdown formatting" (deterministic, markdownlint, commit + pr); the template's placeholder is unverified
-->
```

Grammar, stated strictly because revision 1 left it undefined (O3):

- One entry per line. **No continuation lines** — an indented line is not a
  continuation, it is a malformed entry. `MD013` is disabled in
  `.markdownlint.json`, so a long line is permitted.
- Separator is ` :: ` (space-colon-colon-space). A colon may appear in either
  field; the first ` :: ` splits.
- Left field is the template heading, matched by the same normalisation as §4.1.
- Right field is free prose, never parsed.
- The reason may not contain `--`. `/harness-upgrade` rejects such a reason and
  re-prompts rather than writing it. This is not stylistic: the block is an HTML
  comment, `-->` terminates it early, and comment state is semantically
  load-bearing in this file.
- Duplicate left fields are malformed, not last-wins.
- **A line that does not parse is reported, never skipped.** The tooling names
  the file and line and treats the entry as absent. A silent skip re-admits a
  declined item to the missing set, which is indistinguishable from the bug
  this spec fixes.

## 4. Design

### 4.1 The comparison, in one place

Revision 1 specified the rule twice — once as bash for the hook, once as prose
for the command — and asserted they could not disagree. They are two
implementations, one of them executed by a model, and this repository already
runs a `Command-prompt sync` GC rule (`HARNESS.md:690`) because that class of
drift happens here.

The rule is implemented **once**, as `ai-literacy-superpowers/scripts/harness-template-diff.sh`,
exposed on `PATH` as `harness-template-diff` via the `bin/` shim convention. The
hook invokes it. `/harness-upgrade` step 2 invokes it and consumes its output
instead of restating its rules.

```text
harness-template-diff [--format=text|json]

  tpl   = $CLAUDE_PLUGIN_ROOT/templates/HARNESS.md
  proj  = $CLAUDE_PROJECT_DIR/HARNESS.md

  proj absent            -> exit 0, emit nothing        (not a harness project)
  tpl absent/unreadable  -> exit 0, emit DEGRADED naming the unreadable path

  tpl_headings = ## and ### headings of tpl, including inside HTML comments,
                 EXCLUDING:
                   - a heading whose line carries <!-- affordance-example -->
                   - a heading matching ^\[.*\]$          (literal placeholder)

  For each remaining template heading h:
    skip if h's owning ## section is unconfigured in proj
           (section body is the "Not yet configured" placeholder marker)
    skip if normalise(h) is in normalise(proj_headings)
    skip if normalise(h) is in normalise(declined left-fields)
    otherwise -> missing

  normalise(h) = trim, collapse internal whitespace, casefold
```

The unconfigured-section skip is what makes a default `/harness-init` quiet: a
project that opted out of Garbage Collection has the `## Garbage Collection`
heading with a placeholder body, so its twenty-odd `###` children are not
reported as missing.

### 4.2 The template stops putting instructions on heading lines

`templates/HARNESS.md:630` reads:

```text
<!-- ## Cognitive reservoir  (OPTIONAL — to opt in, remove this `<!--` line and the closing `-->` below)
```

The instruction moves to the line below the heading. The heading line becomes
`<!-- ## Cognitive reservoir`.

This is a template fix, not a parser fix, and it is the right layer: the
template is ours, the comparison runs template→project, and a normalisation
that strips trailing parentheticals would also collapse `### Affordance recorder
freshness (LOCAL — per-machine only)` (`:463`) and `### Affordance dead
inventory (LOCAL — per-machine only)` (`:476`), whose parentheticals are part of
the heading and appear identically on both sides.

A Layer 0 test asserts no heading line in `templates/HARNESS.md` carries a
trailing parenthetical, so the class cannot return.

### 4.3 The message states what it compared

> `Template has 1 item your harness does not: "Stakeholders". Run /harness-upgrade to review.`

It names the items it found. A reader can falsify it against their own file
without running anything.

On the degraded path (§4.1):

> `Could not read the plugin template at <path> — template currency not checked.`

Silence means checked-and-current. It never means could-not-check. This follows
the harness decision record in force until 2026-11-23, compiled into
`skills/advocatus-diaboli/SKILL.md`: a mechanism that could not determine the
answer reports the degraded state and names the input it could not read. The
hook still never blocks and never exits non-zero — a `systemMessage` satisfies
both.

`proj absent` is silent by design and is not a degraded case: a project with no
`HARNESS.md` has nothing to be current with.

### 4.4 `/harness-upgrade`

- **Step 1** drops the version comparison. Prerequisites keep the HARNESS.md
  existence check and the `git fetch origin main` staleness guard.
- **Step 2** invokes `harness-template-diff --format=json` rather than
  restating the matching rules.
- **Step 3** presents declined items in a separate **Previously declined**
  group with their recorded reasons, so a standing decision is visible without
  being re-litigated.
- **Step 4** gains a **decline** disposition alongside accept/skip/customise.
  Declining prompts for a reason and writes it per §3.5's grammar, rejecting a
  reason containing `--`.
- **Step 6** no longer writes a marker or a dismissal file. It removes a
  `template-version` marker if it finds one (§4.5) and writes any new declined
  entries.
- **Step 7** reports declined items alongside accepted and skipped.

**Skip semantics, stated rather than assumed.** Skip means *not now, ask again
next session*. Revision 1 removed the dismissal file, which was the only
time-boxed silence, without saying so. This revision states it: after filtering,
the only items that recur are genuinely new template content the project has not
acted on, and being reminded of those each session is the intended behaviour.
A user who wants a standing silence declines instead, which costs one sentence
and leaves a reason for the next reader. No time-boxed skip is added.

### 4.5 Migration

The marker becomes inert on the release that ships this. Nothing reads it, so a
project that still has one is not broken.

- `/harness-init` stops writing it.
- `/harness-upgrade` removes it when it next runs, and says so in its report.
- This repository removes its own in this PR, along with the `Template currency`
  GC rule.
- `.claude/.harness-upgrade-dismissed` is no longer written or read. The
  `.gitignore` entry stays — the file exists on machines that have run the old
  command, and removing the ignore would surface it as untracked.

### 4.6 Which copy of the template is authoritative

`$CLAUDE_PLUGIN_ROOT/templates/HARNESS.md` — the installed plugin's copy. For a
consuming project that is the versioned marketplace cache, which advances when
they upgrade the plugin.

**In this repository the two are coupled.** `sync-to-global-cache.sh` rsyncs
plugin content into the versioned cache on every `Stop` (`CLAUDE.md`,
Marketplace Cache Auto-Sync). A maintainer who adds a heading to
`templates/HARNESS.md` will, in a later session, be told their harness is
missing the thing they just wrote.

That is correct behaviour reported at a useless moment. It is accepted rather
than solved: the alternative is teaching the hook to detect that the project
*is* the plugin source, which is the special-casing §3 exists to avoid. It is
recorded here so the next person meeting it knows it is known. This coupling is
also candidate cause 2 in §1.1.

### 4.7 Surfaces that declare or read the marker

Revision 1's table listed seven files and presented the inventory as complete;
it found seven of ten (O4).

| File | Change |
| --- | --- |
| `templates/HARNESS.md:13` | Remove the stale `0.57.0` marker |
| `templates/HARNESS.md:337-342` | Remove the `Template currency` GC rule |
| `templates/HARNESS.md:630` | Move the instruction off the heading line (§4.2) |
| `HARNESS.md:13` | Remove the marker |
| `HARNESS.md:760-769` | Remove the `Template currency` GC rule |
| `commands/harness-sync.md:118,206-207,271,294` | **Was missing.** Surface list, checkbox JSON (`"id": "template"`), remediation line, drift-table row |
| `commands/harness-init.md:184,211` | Stop writing the marker |
| `commands/harness-upgrade.md:46-47,135-143` | §4.4 |
| `hooks/scripts/template-currency-check.sh` | Rewritten to call `harness-template-diff` |
| `skills/harness-audit-engine/SKILL.md:33` | Remove the `Template currency` surface row |
| `skills/harness-observability/references/observatory-signals.md:127` | Remove the `Template version` row — see below |
| `skills/ai-literacy-assessment/references/habitat-discovery.md:93,141` | Drop the marker from habitat discovery |

**The observatory row is enforced.** `commands/observatory-verify.md:16` reads
the signals reference, and `:42` reports **PARTIAL** when a required field is
absent. So removing the marker without removing the row degrades every project's
verification. Removing the row is required, not cosmetic. Archived snapshots
that carry the field are unaffected — verification reads the reference against
the *latest* output, not historical ones.

### 4.8 The Status block is corrected in this PR

`HARNESS.md`'s Status block references the marker, and its
`Garbage collection active:` count changes when the `Template currency` rule is
removed.

Revision 1 deferred this to "whenever `/harness-audit` next runs", which merges
a governing document that misstates its own coverage. `/harness-audit` owns the
block and hand-editing it is worse — so **this PR runs `/harness-audit`** and
commits its output. That is the third option revision 1 did not consider, and
this repository's Status block already records the cost of not taking it: "The
2026-08-13 audit recorded `Drift detected: no` against a tree that already
carried every failure listed here" (`HARNESS.md:1177`).

## 5. Acceptance criteria

### 5.1 `harness-template-diff` — Layer 0 deterministic

Tests at `tdad_tests/layer0_deterministic/test-harness-template-diff.sh`, with
fixtures under `tdad_tests/layer0_deterministic/fixtures/`.

1. A project harness containing every non-excluded template heading yields an
   empty missing set — **regardless of plugin version**.
2. A template heading absent from the project appears in the missing set.
3. A heading named in the project's declined block does not appear.
4. A template heading that appears only inside an HTML comment is treated like
   any other; criteria 1–3 hold for it unchanged.
5. A heading tagged `<!-- affordance-example -->` never appears, even when the
   project lacks it.
6. A heading matching `^\[.*\]$` never appears.
7. `###` headings under a project section carrying the "Not yet configured"
   placeholder never appear.
8. Matching is trim, whitespace-collapse and casefold on both sides; headings
   differing only in those respects are not reported.
9. A malformed declined line is reported with file and line, and its entry is
   treated as absent — not silently skipped.
10. A declined reason containing `--` is rejected on write.
11. Template unreadable → DEGRADED naming the path; exit 0.
12. Project harness absent → silent; exit 0.
13. Exit status is 0 on every path.

### 5.2 The real-input assertion

14. Run against this repository's committed `HARNESS.md` and
    `templates/HARNESS.md`, the missing set is **empty** once §4.2's template fix
    and the `Consistent formatting` declined entry are in place.

This criterion exists because revision 1 never ran its own algorithm; §3.4
records what happened when it finally was. It is a Layer 0 test against the real
files, not fixtures, so template edits that reintroduce a false positive fail CI.

15. No heading line in `templates/HARNESS.md` carries a trailing parenthetical
    (§4.2).

### 5.3 `/harness-upgrade` — behavioural

Not Layer 0; these are model-executed and belong in a behavioural scenario, not
in the hook's test file. Revision 1 assigned them to the hook's file in error.

16. Given a `HARNESS.md` with a `template-version` marker, the command removes it
    and reports having done so.
17. A previously-declined item is presented under **Previously declined** with
    its recorded reason, never in the new-items bucket.
18. **Round trip:** declining an item through the command produces a block that
    `harness-template-diff` reads back as declined, and the hook then emits
    nothing. This is the write path revision 1 left untested, and given §3.5 it
    is where the design is most likely to fail.

The *New plugin components must ship with a TDAD scenario* constraint does gate
`harness-template-diff.sh` only if it ships as a new skill, agent or command; a
script is none of those, so the constraint does not apply. The tests are added
because the behaviour is new, not because a constraint demands them.

## 6. Rejected alternatives

**Compare the template's own content marker.** Unmaintained — `d867c7c` changed
the template without moving it — and nothing reads it. Substitutes one unreliable
signal for another.

**Hash the template and store the hash.** Measures content correctly, but
reintroduces per-project state that drifts, which is the class of defect being
removed.

**Full-text diff instead of heading sets.** Every wording change would nudge.
The property worth surfacing is a *missing item*, not a reworded one.

**Record declines in a separate file.** A new durable governance artefact in a
repository where two committed dashboards went 106 days unread. The declined
block sits in the file it describes.

**Normalise trailing parentheticals in the parser** rather than fixing the
template (§4.2). Rejected: it would also collapse the two `(LOCAL — per-machine
only)` headings, whose parentheticals are meaningful, and it hides a template
defect inside a matcher.

**Delete the nudge entirely, keeping `/harness-upgrade` on demand.** Still live,
and strengthened by §1.1 removing the evidence that favoured keeping it. §3.3
retains it on judgement and says so; a reviewer who weighs the absence of any
recorded successful nudge more heavily should take this option, which deletes
the hook, the shared script, the declined block and §5.1 entirely.

## 7. Version

Behavioural change to plugin files: **minor**, `0.89.0` → `0.90.0`, across the
five CI-checked locations plus the README plugin-table row.

## 8. Docs

Same PR, per the docs-site convention. Revision 1 missed the last two:

`README.md:74,486`; `how-to/update-the-plugin.md:16,97`;
`how-to/upgrade-your-harness.md:23`; `reference/commands.md:128`;
`reference/hooks.md:282`; `reference/harness-md-format.md:19,41`;
`docs/contributing/index.md:195`;
`docs/plugins/ai-literacy-superpowers/how-to/sync-harness.md` (six references,
including a drift-table row and a "Template drift" remediation section).

## 9. Objections addressed

| ID | Severity | Where |
| --- | --- | --- |
| O1 | critical | §3.4, §4.1 — affordance-example and placeholder exclusions; unconfigured-section skip |
| O2 | high | §4.2 template fix; §5.2 criterion 14 asserts the real missing set is empty |
| O3 | high | §3.5 — strict grammar, `::` separator, no continuations, `--` rejected, malformed reported not skipped |
| O4 | high | §4.7 — `harness-sync.md` added; §8 — `contributing/index.md`, `sync-harness.md` added |
| O5 | medium | §1.1 withdraws the claim; §3.3 states the nudge is kept on judgement; §6 keeps deletion live |
| O6 | high | §4.1 — one implementation, `harness-template-diff`, invoked by both |
| O7 | high | §4.1, §4.3 — degraded path names the unreadable input; §5.1 criteria 11–13 |
| O8 | medium | §4.4 — skip semantics stated; no time-box added, with reasons |
| O9 | medium | §5.1/§5.3 split; §5.3 criterion 18 tests the write path round trip |
| O10 | medium | §3 restructured around the filtered item set |
| O11 | medium | §4.6 names the authoritative copy and the local coupling; §1.1 stops attributing the Stakeholders case |
| O12 | medium | §4.8 runs `/harness-audit` in this PR; §4.7 confirms the observatory row is enforced |
