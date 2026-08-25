# Retire the template-currency nudge — design

**Status:** proposed (revision 4)
**Date:** 2026-08-25
**Issue:** #601
**Provenance:** `docs/superpowers/specs/2026-04-15-harness-upgrade-design.md`
introduced the `template-version` marker, the `Template currency` GC rule and
the SessionStart nudge. This spec retires all three.
**Revision history:** Revision 1 replaced the version comparison with a heading
comparison; revision 2 filtered the compared set; revision 3 deleted the
mechanism instead. Each was reviewed adversarially. Revision 4 implements the
dispositions written against revision 3's objection record
(`docs/superpowers/objections/template-currency-measure-content-design.md`, all
twelve disposed: 7 accepted, 4 rejected, 1 amend). §9 maps each.
**Scope:** deletion of the marker, the `Template currency` GC rule, the
SessionStart hook and the dismissal file, across the plugin, this repository,
and — by prompted migration — consuming projects. `/harness-upgrade` survives as
an on-demand command with its version gate removed.
**Out of scope:** the declined-item record (§8); `/harness-upgrade`'s adoption
mechanics beyond step 1 and step 6; the harness evolution loop; the
`reference/hooks.md:287` documentation defect (§3.3).

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

So the SessionStart hook asserts `Plugin template has been updated` on evidence
that cannot establish it, and the false signal reached the governing document:
`HARNESS.md`'s Status block records "eight minors of unreviewed template
content" against a template that had not changed.

### 1.1 What the run history does and does not show

The hook fires whenever the marker differs from the plugin version
(`hooks/scripts/template-currency-check.sh:42-45`). Across six recorded marker
advances it fired six times; five found nothing to adopt (`58d3dda`, `89b46f9`,
and CHANGELOG entries at `0.35.1`, `0.38.0`, `0.40.0`). Those five were false
alarms, not correct silence — in each, the template had not changed and the
hook said it had.

The sixth is `a81c552`, which adopted the commented-out `## Stakeholders`
section. `d867c7c` added that section to the template on 2026-08-13 at 09:11;
`89b46f9` ran six hours later, reported "byte-identical … nothing to adopt", and
stamped the marker forward. The block was not adopted until twelve days later,
by a human who noticed it another way. There are at least three candidate causes
— a parsing miss, a cache that had not yet synced, or the section being seen and
skipped — and the `0.73.2` plugin cache is no longer on the machine that ran it,
so this cannot be settled.

**What this history establishes, and what it does not.** It establishes that
*this* notifier was wrong five times out of six. It does not establish that
notification is worthless, because a correct notifier has never existed here: in
the five windows where the template was unchanged, a correct mechanism would
have been silent and produced no evidence either way. §2 therefore does not rest
on "it never worked".

## 2. Decision — delete the nudge

The marker, the `Template currency` GC rule, the SessionStart hook and the
dismissal file are removed. Nothing replaces them.

`/harness-upgrade` survives, unchanged except for losing its version gate. It
already performs a real structural comparison in steps 2–3; that comparison was
never the broken part. `README.md:99` already directs people to run it after
upgrading the plugin.

### 2.1 Why deletion rather than a better comparison

The case is cost and escalating complexity, not absence of value.

| | Revision 1 | Revision 2 | Revision 3+ |
| --- | --- | --- | --- |
| New script + `PATH` shim | — | yes | — |
| New grammar in `HARNESS.md` | yes | yes (stricter) | — |
| New `/harness-upgrade` disposition | yes | yes | — |
| Acceptance criteria | 9 | 18 | 8 |
| Adversarial review | 1 critical, 5 high | 1 critical, 8 high | 2 critical, 8 high |

Revision 2's critical objection was that its filter still fired on a default
install, because the template's two OPTIONAL blocks (`templates/HARNESS.md:39`,
`:630`) ship commented out and the rule included commented headings by design.
Its high objections included an exclusion predicate that matched nothing — the
`<!-- affordance-example -->` tag sits on the line *below* each heading
(`:519`/`:520`), verified by `grep '^###.*affordance-example'` returning zero
matches — and an acceptance criterion structurally incapable of detecting that,
because it ran against this repository, which already contains every heading the
exclusions were meant to suppress.

Two revisions spent increasing mechanism defending a notifier, and each returned
a critical. That is the argument. A correct notifier remains buildable and
§7 records how.

### 2.2 What is lost, stated plainly

Four capabilities go, not one:

1. **The unprompted notification.** A project that upgrades the plugin will no
   longer be told, at session start, that the template gained content. They
   learn it by running `/harness-upgrade`.
2. **The `/harness-sync` monthly drift row.** `commands/harness-sync.md:118,
   207, 271, 294` surfaces template drift as a `[manual]` item in the monthly
   sync ritual. That is a pull the user initiated, not an unprompted claim — but
   it computes from the same broken proxy, so a `drifted` row there is still a
   false statement. It goes with the rest.
3. **The `/harness-audit` drift-engine row.** `skills/harness-audit-engine/SKILL.md:33`.
4. **The required observatory signal.** `observatory-signals.md:127`, with the
   count arithmetic in §3.2.

**One consumer is deliberately retained.**
`skills/ai-literacy-assessment/references/habitat-discovery.md:93,141` reads the
marker as one signal that a project has a harness at all. It is a *reader*, not
a writer; it is harmless; and per §5 most consuming projects will keep carrying
the marker for a long time. Deleting the reader before the data is gone would be
backwards. It stays, and is removed in a later release once the marker is rare.

**A transitional cost, accepted rather than mitigated.** A project whose marker
has been removed, opened on a machine with an *older* plugin, gets the old hook
firing every session: an absent marker reads as `0.0.0`
(`template-currency-check.sh:32-34`), so versions always differ. Previously
`/harness-upgrade` could silence it by writing the dismissal file; this version
stops writing it. Mixed versions across machines and teammates are normal, and
this is accepted as a cost of the transition rather than carried by keeping a
file nothing in the new plugin reads. Users on stale plugins have other reasons
to upgrade.

## 3. What is deleted

| Artefact | Location |
| --- | --- |
| SessionStart hook script | `hooks/scripts/template-currency-check.sh` |
| Hook registration | `hooks/hooks.json` SessionStart entry |
| Marker (plugin template) | `templates/HARNESS.md` |
| `Template currency` GC rule (plugin template) | `templates/HARNESS.md` |
| Marker (this repository) | `HARNESS.md` |
| `Template currency` GC rule (this repository) | `HARNESS.md` |
| Marker write | `commands/harness-init.md` |
| Version gate, marker + dismissal write | `commands/harness-upgrade.md` |
| Template-drift surface | `commands/harness-sync.md` |
| Drift-engine row | `skills/harness-audit-engine/SKILL.md` |
| `Template version` signal row | `skills/harness-observability/references/observatory-signals.md` |

Line numbers are deliberately omitted: several cited in revisions 1–3 had already
drifted by one or two lines, and the residue assertion in §6 is what guarantees
completeness, not the table.

`.claude/.harness-upgrade-dismissed` is no longer written or read. The
`.gitignore` entry stays — the file exists on machines that ran the old command,
and removing the ignore would surface it as untracked.

### 3.1 Prose that describes the mechanism without naming it

A term search does not find these, which is why §6 needs a second assertion.
`docs/plugins/ai-literacy-superpowers/tutorials/first-time-tour.md:564` tells a
new user "SessionStart hook will prompt you the first time a new version is…",
and `.../explanation/the-harness-lifecycle.md:88` says "When the plugin has
shipped new template content, `/harness-upgrade`…". Neither matches
`template-version`, `template currency` or `template drift`. Both describe
behaviour that will not exist.

### 3.2 Counts that must move

**Observatory signals: 82 → 81.** `observatory-signals.md:127` is a **required**
signal and `commands/observatory-verify.md:42` reports **PARTIAL** when a
required field is absent, so the row must go rather than be marked optional. The
total is hard-coded at `observatory-signals.md:157`, `observatory-verify.md:3`
(frontmatter description), `observatory-verify.md:17`, and in the results-table
template at `observatory-verify.md:89`.

**Hooks: 18 → 17, SessionStart 4 → 3.** Verified by parsing `hooks/hooks.json`:
PreToolUse 1, PostToolUse 2, Stop 11, SessionStart 4. `hooks.json`'s own
description field also names the template currency check.
`tdad_tests/layer0_deterministic/test-hooks-doc-parity.sh:19` records what
happened the last time this count went stale ("hooks.json declares 18; the page
documented 16"), so the parity test will fail if `reference/hooks.md` is not
updated with it.

### 3.3 A documentation defect that is not this spec's to fix

`docs/plugins/ai-literacy-superpowers/reference/hooks.md:287` states the hook
"Exits silently if `HARNESS.md` does not exist **or the marker is absent**." The
second clause is false today: `template-currency-check.sh:32-34` treats an absent
marker as `0.0.0` and nudges. This predates the spec and is noted so it is not
silently absorbed into a change that deletes the page section anyway. It should
be tracked as its own defect.

## 4. What survives

`/harness-upgrade` keeps its three-bucket comparison — **new**, **updated** and
**removed** items (`commands/harness-upgrade.md:74-88`). Revision 2 would have
replaced that parse with a missing-set-only script and silently dropped two
buckets; this revision touches neither the parse nor the buckets.

Changes are confined to two steps:

- **Step 1** drops the version comparison and the "versions match → skip to step
  6" short-circuit. Prerequisites keep the HARNESS.md existence check and the
  `git fetch origin main` staleness guard.
- **Step 6** stops writing the marker and the dismissal file, and instead offers
  the migration in §5.

## 5. Migration for consuming projects

The plugin's template stops shipping the marker and the GC rule. That does not
reach a project whose `HARNESS.md` already has both — its file is its own.

Left alone, such a project keeps a GC rule declared **deterministic** whose tool
compares a marker that no longer exists. An absent marker reads as `0.0.0`
(`template-currency-check.sh:32-34`), so the rule reports drift on every run,
permanently, with no way to clear it.

So `/harness-upgrade` step 6 offers a migration. On any run it looks for:

- a `<!-- template-version: … -->` marker;
- a `### Template currency` GC rule whose **Tool** field references the
  template-version comment.

**Each finding is presented for the user to accept or skip**, in the same
per-item form step 4 uses for every other change (`commands/harness-upgrade.md:104`,
"Ask the user to choose for each item"). Nothing is removed from a project's
`HARNESS.md` without a recorded decision. A project may have specialised that
rule — which is exactly what this repository did with `Consistent formatting` —
and silently deleting someone's work during a command they ran for an unrelated
reason is not a thing this command does.

### 5.1 Near misses are reported, never guessed

If a `### Template currency` heading is present but its **Tool** field does not
reference the template-version comment, it is **reported and left alone**. The
same applies to a marker in an unexpected form.

Step 7 distinguishes three outcomes explicitly:

- *removed* — the user accepted a finding
- *found, not removed* — the user skipped it, or it was a near miss
- *not found* — the file was read and contained neither

"Nothing reported" must never be able to mean "the file could not be parsed".
This follows the decision record in force until 2026-11-23: a mechanism that
could not determine the answer reports that, and does not return the reassuring
value.

### 5.2 Reach, and the projects this does not touch

The migration only fires when a project runs `/harness-upgrade`. A project that
never runs it again keeps an orphaned rule.

This is the maximum reach available: the plugin cannot edit files in projects it
is not invited into, and performing the check on *every* run rather than only on
adoption is what makes the reach as wide as it can be.

Migrated projects' Status blocks will report one more active GC rule than they
have. That is `/harness-audit`'s tracked drift surface
(`skills/harness-audit-engine/SKILL.md:32`) and its normal cadence will catch it;
this command does not take on keeping every consuming project's Status block
current.

### 5.3 This migration is one-way

Stated rather than left implied:

- Reverting the plugin does not restore what step 6 removed from files the
  plugin does not own.
- There is no rollback path from the plugin side.
- Reopening on §7's alternative would cost a **second** migration — reintroducing
  the marker to the template and re-populating it across projects, through the
  same partially-reaching channel — not merely re-reading a recorded design.

## 6. Acceptance criteria

1. `hooks/scripts/template-currency-check.sh` does not exist, and `hooks.json`
   contains no SessionStart entry referencing it.
2. Neither `templates/HARNESS.md` nor this repository's `HARNESS.md` contains a
   `template-version` marker or a `Template currency` GC rule.
3. `/harness-upgrade` run against a project harness containing a
   `template-version` marker **presents it for accept/skip** and removes it only
   on accept.
4. Same for a `### Template currency` GC rule whose Tool field references the
   template-version comment.
5. A near miss — a `### Template currency` heading whose Tool field does not
   match — is reported and not removed, on accept or skip.
6. Step 7's report distinguishes *removed*, *found but not removed*, and *not
   found*.
7. Both removals are idempotent: a second run finds nothing further.
8. **Residue assertion**, in two parts:

   **8a — terms.** A **case-insensitive** repository-wide search for
   `template-version`, `template currency`, `template-currency`,
   `template drift`, `template version drift` and `harness-upgrade-dismissed`
   returns matches only in the allow-list below.

   **8b — description.** No file outside the allow-list describes the SessionStart
   template-currency behaviour in prose. Seeded from a search for `harness-upgrade`
   co-occurring with `SessionStart` or "new template content", because §3.1
   demonstrates that prose describing the mechanism need not contain any of 8a's
   terms.

   **Allow-list:** `CHANGELOG.md`, `REFLECTION_LOG.md`, `reflections/`,
   `assessments/`, `harness/assay/`, `docs/superpowers/{specs,plans,objections}/`,
   `observability/snapshots/`, `harness/decisions/`, the `.gitignore` line, and —
   **exempted by construction, with the reason stated** — `commands/harness-upgrade.md`
   (which must name the marker and the rule in order to offer their removal) and
   the test file itself (whose filename and search patterns necessarily contain
   the terms). `habitat-discovery.md` is exempt per §2.2 until the marker is rare.

   The two exemptions are named individually and deliberately. An implementer
   must not widen the allow-list further to make the test pass; if a new file
   legitimately needs an exemption, that is a spec change.

Criteria 1, 2 and 8 are Layer 0 deterministic tests at
`tdad_tests/layer0_deterministic/test-template-currency-retired.sh`. Criteria
3–7 are behavioural — model-executed command behaviour, which does not belong in
a Layer 0 file.

**Criterion 8 exists because hand enumeration failed three times.** Revision 1's
table listed seven files; revision 2's twelve; revision 3's nineteen. The
broadened case-insensitive search returns **twenty-two**, and §3.1 shows two more
that no term search reaches. The assertion is what guarantees completeness; the
§3 table is a reader's aid.

The *New plugin components must ship with a TDAD scenario* constraint does not
gate this work: it names new `SKILL.md`, `agent.md` and `command.md` files, and
this change adds none.

## 7. Rejected alternatives

**Compare heading sets (revision 1).** Fires on a default install: the template
ships four `<!-- affordance-example -->` headings, a `### [Governance constraint
name]` placeholder, and two commented OPTIONAL sections a default project
correctly lacks.

**Filter the compared set (revision 2).** Reduces but does not remove that — the
OPTIONAL blocks are `##` sections, which the unconfigured-section skip cannot
reach — and buys the reduction with a script, a shim, a grammar and a new
disposition.

**Fix the template's own content marker and read that.** The strongest surviving
alternative: add a CI assertion that any diff touching `templates/HARNESS.md`
also moves its `<!-- template-version -->`, and have the hook compare that marker
rather than `plugin.json`. It measures the right property and costs one CI check.

Rejected on §2.1's cost argument rather than on §1.1: it is a cheap way to build
a correct version of a mechanism whose value is unevidenced in either direction.
**If §2.2's losses prove to matter, this is the option to reopen on** — though
per §5.3, doing so costs a second migration, not merely re-reading this section.

**Delete only the SessionStart hook, keeping the pull-direction surfaces.**
Considered: the demonstrated harm is specific to the hook, and `/harness-sync`'s
row is a pull the user initiated at a monthly cadence. Rejected because a
`drifted` row computed from a broken proxy is still a false statement wherever it
appears, and leaving one surface reading a marker the rest of the system no
longer maintains recreates the orphan problem §5 exists to solve.

**Keep the marker but make its absence an opt-out (issue #601 as filed).**
Leaves the version-as-proxy flaw intact for projects that keep their marker, and
silences the nudge for projects that never had one.

## 8. Out of scope: the declined-item record

Revisions 1 and 2 proposed recording declined template items in `HARNESS.md`, so
that `Consistent formatting` — declined three times on reasoning written only
into commit messages — would stop being re-presented.

That problem is real and survives this spec. It is out of scope because deleting
the nudge shrinks it from *every session* to *every deliberate `/harness-upgrade`
run*, and because the record's grammar generated two objections in the last
review. It is worth revisiting on its own terms.

## 9. Dispositions implemented

Against `docs/superpowers/objections/template-currency-measure-content-design.md`:

| ID | Disposition | Where |
| --- | --- | --- |
| O1 | accepted | §1.1 rewritten — the five were false alarms, not true negatives, and §2.1 now rests the case on cost rather than "never worked" |
| O2 | accepted | §6 criterion 8a — terms broadened, search made case-insensitive |
| O3 | accepted | §6 — `harness-upgrade.md` and the test file exempted by name, with the reason and a prohibition on widening further |
| O4 | accepted | §5 — every finding presented for accept/skip; nothing removed without a recorded decision |
| O5 | rejected | §5.2 — Status-block accuracy stays `/harness-audit`'s surface and cadence |
| O6 | rejected | §5.2 — every-run checking is the maximum reach available |
| O7 | amend | §2.2 — all four losses stated; `habitat-discovery.md` retained as a reader |
| O8 | rejected | §7 — recorded as considered and rejected, with the reason |
| O9 | accepted | §5.3 — the one-way property and the true cost of reopening |
| O10 | rejected | §2.2 — mixed-version cost stated and accepted; §3.3 tracks the docs defect separately |
| O11 | accepted | §5.1 — near misses reported, three outcomes distinguished |
| O12 | accepted | §3 regenerated from the broadened grep with line numbers dropped; §3.1 adds the prose surfaces; §3.2 adds the hook arithmetic |

## 10. The Status block

Removing the `Template currency` GC rule changes the
`Garbage collection active:` count in `HARNESS.md`'s Status block, which is
owned by `/harness-audit` and must not be hand-edited.

**This PR runs `/harness-audit`** and commits its output. This repository's
Status block already records the cost of not doing that: "The 2026-08-13 audit
recorded `Drift detected: no` against a tree that already carried every failure
listed here" (`HARNESS.md:1177`).

## 11. Version

Behavioural change to plugin files: **minor**, `0.89.0` → `0.90.0`, across the
five CI-checked locations plus the README plugin-table row.

## 12. Docs

Same PR. Derived from criterion 8's two searches, not by hand:

**Term matches:** `README.md`, `docs/contributing/index.md`, `CLAUDE.md`,
`ai-literacy-superpowers/templates/CLAUDE.md`,
`docs/plugins/ai-literacy-superpowers/reference/{hooks,commands,harness-md-format,skills}.md`,
`.../how-to/{update-the-plugin,upgrade-your-harness,sync-harness}.md`.

**Prose matches (§3.1):** `.../tutorials/first-time-tour.md`,
`.../explanation/the-harness-lifecycle.md`, `.../explanation/harness-md.md`,
`.../explanation/self-improving-harness.md`, `commands/observatory-verify.md`.

`reference/hooks.md` additionally needs the hook-count update from §3.2, which
`test-hooks-doc-parity.sh` enforces.
