# Retire the template-currency nudge — design

**Status:** proposed (revision 3)
**Date:** 2026-08-25
**Issue:** #601
**Provenance:** `docs/superpowers/specs/2026-04-15-harness-upgrade-design.md`
introduced the `template-version` marker, the `Template currency` GC rule and
the SessionStart nudge. This spec retires all three.
**Revision history:** Revision 1 replaced the version comparison with a heading
comparison. Revision 2 filtered the compared set. Both were reviewed
adversarially; the second review returned one critical and eight high
objections, and its premise objection (O1) observed that the design had grown a
script, a `PATH` shim, a grammar in the governing document, a fourth command
disposition, eighteen acceptance criteria and a twelve-file migration in
support of a mechanism with no recorded successes. Revision 3 takes the option
both prior revisions listed as live and neither took. §9 records what this
resolves and what it abandons.
**Scope:** deletion of the marker, the `Template currency` GC rule, the
SessionStart hook and the dismissal file, across the plugin, this repository,
and — by migration — consuming projects. `/harness-upgrade` survives as an
on-demand command with its version gate removed.
**Out of scope:** the declined-item record (§8); `/harness-upgrade`'s adoption
mechanics beyond step 1 and step 6; the harness evolution loop.

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

Five of the last six marker advances adopted nothing. `58d3dda` (2026-07-22)
and `89b46f9` (2026-08-13) each record "found nothing to adopt", both naming the
same item — the generic `Consistent formatting` placeholder, declined because
this repository specialised it into a deterministic markdownlint rule. The
2026-08-25 run reached the same conclusion about the same item a third time.

### 1.1 What the `## Stakeholders` case does not establish

`d867c7c` added a commented-out `## Stakeholders` section to the template on
2026-08-13 at 09:11. `89b46f9` ran six hours later, reported "byte-identical …
nothing to adopt", and stamped the marker forward. The block was not adopted
until twelve days later, by a human who noticed it another way.

Revisions 1 and 2 leaned on this as evidence that the expensive failure is *not
being told*. There are at least three candidate causes and this spec attributes
none: a genuine parsing miss; a cache that had not yet synced, so `89b46f9`
compared against a copy predating `d867c7c`; or the section being seen and
skipped. The `0.73.2` plugin cache is no longer on the machine that ran it, so
this cannot be settled.

**There is therefore no recorded instance of this nudge producing a useful
adoption.** Six runs are recorded; five adopted nothing and the sixth cannot be
attributed.

## 2. Decision — delete the nudge

The marker, the `Template currency` GC rule, the SessionStart hook and the
dismissal file are removed. Nothing replaces them.

`/harness-upgrade` survives, unchanged except for losing its version gate. It
already performs a real structural comparison in steps 2–3; that comparison was
never the broken part. `README.md:99` already directs people to run it after
upgrading the plugin, which becomes the whole of the discovery story.

### 2.1 Why deletion rather than a better comparison

Revisions 1 and 2 tried to keep a nudge and measure the right property. Each
attempt grew:

| | Revision 1 | Revision 2 | Revision 3 |
| --- | --- | --- | --- |
| New script + `PATH` shim | — | yes | — |
| New grammar in `HARNESS.md` | yes | yes (stricter) | — |
| New `/harness-upgrade` disposition | yes | yes | — |
| Acceptance criteria | 9 | 18 | 6 |
| Adversarial review | 1 critical, 5 high | 1 critical, 8 high | — |

The second review's critical objection was that revision 2's filter still fired
on a default install, because the template's two OPTIONAL blocks
(`templates/HARNESS.md:39`, `:630`) are shipped commented out and the rule
included commented headings by design. Its high objections included an exclusion
predicate that matched nothing — the `<!-- affordance-example -->` tag sits on
the line *below* each heading (`:519`/`:520`), verified by
`grep '^###.*affordance-example'` returning zero matches — and an acceptance
criterion incapable of detecting that, because it ran against this repository,
which already contains every heading the exclusions were meant to suppress.

The pattern is that each revision defended a mechanism the evidence does not
support, and paid for the defence in mechanism. §1.1 removed the last evidence
in its favour.

### 2.2 What is lost, stated plainly

A project that upgrades the plugin will no longer be told, unprompted, that the
template gained content. They learn it by running `/harness-upgrade`, which the
README already tells them to do after an upgrade.

This is a real reduction in discoverability, and it is accepted on the grounds
that the mechanism being removed has never demonstrably provided it. If a future
adopter reports missing template content they would have wanted to know about,
that is evidence this decision was wrong and is worth reopening on — §7 keeps
the alternative recorded rather than dismissed.

## 3. What is deleted

| Artefact | Location |
| --- | --- |
| SessionStart hook script | `hooks/scripts/template-currency-check.sh` |
| Hook registration | `hooks/hooks.json` SessionStart entry |
| Marker (plugin template) | `templates/HARNESS.md:13` |
| `Template currency` GC rule (plugin template) | `templates/HARNESS.md:335-342` |
| Marker (this repository) | `HARNESS.md:13` |
| `Template currency` GC rule (this repository) | `HARNESS.md:760-769` |
| Marker write | `commands/harness-init.md:184,211` |
| Version gate + marker/dismissal write | `commands/harness-upgrade.md:46-47,135-143,152` |
| Template-drift surface | `commands/harness-sync.md:118,206-207,271,294` |
| Drift surface row | `skills/harness-audit-engine/SKILL.md:33` |
| `Template version` signal row | `skills/harness-observability/references/observatory-signals.md:127` |
| Habitat-discovery signal | `skills/ai-literacy-assessment/references/habitat-discovery.md:93,141` |

`.claude/.harness-upgrade-dismissed` is no longer written or read. The
`.gitignore` entry stays — the file exists on machines that ran the old command,
and removing the ignore would surface it as untracked.

### 3.1 The observatory signal count

`observatory-signals.md:127` is a **required** signal, and
`commands/observatory-verify.md:42` reports **PARTIAL** when a required field is
absent — so the row must go, not merely be marked optional.

The total is hard-coded in three places and must move 82 → 81:

- `skills/harness-observability/references/observatory-signals.md:157`
- `commands/observatory-verify.md:3` (frontmatter description)
- `commands/observatory-verify.md:17`

`observatory-verify.md:89` carries `**82**` in a results-table template and moves
with them. Archived snapshots that carry the field are unaffected: verification
reads the reference against the latest output, not historical ones.

## 4. What survives

`/harness-upgrade` keeps its three-bucket comparison — **new**, **updated** and
**removed** items (`commands/harness-upgrade.md:74-88`). Revision 2 proposed
replacing that parse with a missing-set-only script and would have silently
dropped two buckets; this revision touches neither the parse nor the buckets.

Changes are confined to two steps:

- **Step 1** drops the version comparison and the "versions match → skip to step
  6" short-circuit. Prerequisites keep the HARNESS.md existence check and the
  `git fetch origin main` staleness guard.
- **Step 6** stops writing the marker and the dismissal file, and instead
  performs the migration in §5.

## 5. Migration for consuming projects

The plugin's template stops shipping the marker and the GC rule. That does not
reach a project whose `HARNESS.md` already has both — its file is its own.

Left alone, such a project keeps a GC rule declared **deterministic** whose tool
compares a marker that no longer exists. Under the semantics being deleted, an
absent marker reads as `0.0.0` (`hooks/scripts/template-currency-check.sh:32-34`),
so the rule reports drift on every run, permanently, with no way to clear it.
That would export the defect this spec removes to the entire install base.

So `/harness-upgrade` step 6 becomes a migration step. On any run, if the
project's `HARNESS.md` contains:

- a `<!-- template-version: … -->` marker, it is removed;
- a `### Template currency` GC rule whose **Tool** field references the
  template-version comment, it is removed;

and step 7 reports each removal by name. Both removals are idempotent and are
no-ops on a project that has neither.

A project that never runs `/harness-upgrade` again keeps an orphaned rule. That
is not fully solvable from here — the plugin cannot edit a file it is not
invited into — and it is the reason step 6 does the work on *every* run rather
than only when something is adopted.

## 6. Acceptance criteria

1. `hooks/scripts/template-currency-check.sh` does not exist, and `hooks.json`
   contains no SessionStart entry referencing it.
2. Neither `templates/HARNESS.md` nor this repository's `HARNESS.md` contains a
   `template-version` marker or a `Template currency` GC rule.
3. `/harness-upgrade` run against a project harness containing a
   `template-version` marker removes it and names it in the report.
4. `/harness-upgrade` run against a project harness containing a
   `Template currency` GC rule whose Tool references the template-version
   comment removes it and names it in the report.
5. Both removals are idempotent: a second run reports nothing further and
   changes nothing.
6. **Residue assertion.** A repository-wide search for `template-version`,
   `Template currency`, `template-currency` and `harness-upgrade-dismissed`
   returns matches only in: `CHANGELOG.md`, `REFLECTION_LOG.md`, `reflections/`,
   `assessments/`, `harness/assay/`, `docs/superpowers/{specs,plans,objections}/`,
   `observability/snapshots/`, and the `.gitignore` line.

Criteria 1, 2 and 6 are Layer 0 deterministic tests at
`tdad_tests/layer0_deterministic/test-template-currency-retired.sh`. Criteria
3–5 are behavioural — they are model-executed command behaviour and do not
belong in a Layer 0 file.

**Criterion 6 exists because hand enumeration failed twice.** Revision 1's
surfaces table listed seven files and was presented as complete; revision 2's
listed twelve and was presented as complete. A `grep` across the tree at the
time of writing returns **nineteen**. The assertion is cheaper than the table
and does not depend on the author having remembered everything.

The *New plugin components must ship with a TDAD scenario* constraint does not
gate this work: it names new `SKILL.md`, `agent.md` and `command.md` files, and
this change adds none.

## 7. Rejected alternatives

**Compare heading sets (revision 1).** Fires on a default install: the template
ships four `<!-- affordance-example -->` headings, a `### [Governance constraint
name]` placeholder, and two commented OPTIONAL sections that a default project
correctly lacks.

**Filter the compared set (revision 2).** Reduces but does not remove that,
because the OPTIONAL blocks are `##` sections and the unconfigured-section skip
cannot reach them; and it buys the reduction with a script, a shim, a grammar
and a new disposition.

**Fix the template's own content marker and read that.** The strongest surviving
alternative, raised as O7 against revision 2: add a CI assertion that any diff
touching `templates/HARNESS.md` also moves its `<!-- template-version -->`, and
have the hook compare that marker rather than `plugin.json`. It measures the
right property, costs one CI check, and needs no new mechanism.

Rejected on §1.1 rather than on cost: it is a cheap way to build a correct
version of a mechanism with no recorded successes, and the question this spec
answers is whether to have the mechanism at all. **If the answer to §2.2 turns
out to be wrong, this is the option to reopen on** — it is recorded here in
enough detail to be taken up without re-deriving it.

**Keep the marker but make its absence an opt-out (issue #601 as filed).**
Leaves the version-as-proxy flaw intact for every project that keeps its marker,
and silences the nudge for projects that never had one — the population most
likely to need it.

## 8. Out of scope: the declined-item record

Revisions 1 and 2 proposed recording declined template items in `HARNESS.md`, so
that `Consistent formatting` — declined three times on reasoning written only
into commit messages — would stop being re-presented.

That problem is real and survives this spec. It is out of scope because deleting
the nudge shrinks it from *every session* to *every deliberate `/harness-upgrade`
run*, which is a different order of nuisance, and because the record's grammar
was the source of two objections in the last review. It is worth revisiting on
its own terms rather than as a dependency of a mechanism being deleted.

## 9. Objections resolved and abandoned

Against the revision-2 review (record preserved at commit `6da8b77`):

| ID | Severity | Outcome |
| --- | --- | --- |
| O1 | high | **Resolved** — §2.1 takes the deletion option and prices the alternatives in like terms |
| O2 | critical | **Dissolved** — no comparison, no filter, no OPTIONAL-block false positive |
| O3 | high | **Dissolved** — no exclusion predicate |
| O4 | high | **Resolved differently** — §6 criterion 6 asserts residue by grep rather than validating an algorithm against one favourable input |
| O5 | high | **Resolved** — §4 leaves the three-bucket parse untouched |
| O6 | high | **Resolved** — §5 migrates consuming projects' orphaned GC rule |
| O7 | high | **Recorded, not taken** — §7 keeps it as the reopening path if §2.2 proves wrong |
| O8 | high | **Dissolved** — no SessionStart hook, so no re-fire on resume/clear/compact |
| O9 | high | **Resolved** — §6 criterion 6; §3's table is grep-derived, and the grep is the test |
| O10 | medium | **Dissolved** — no comparison, so no project-side comment rule to define |
| O11 | medium | **Dissolved** — no script, no `--` grammar |
| O12 | medium | **Dissolved** — no hook, so no silent-failure path to specify |

## 10. The Status block

Removing the `Template currency` GC rule changes the
`Garbage collection active:` count in `HARNESS.md`'s Status block, which is
owned by `/harness-audit` and must not be hand-edited.

**This PR runs `/harness-audit`** and commits its output, rather than merging a
governing document that misstates its own coverage. This repository's Status
block already records the cost of not doing that: "The 2026-08-13 audit recorded
`Drift detected: no` against a tree that already carried every failure listed
here" (`HARNESS.md:1177`).

## 11. Version

Behavioural change to plugin files: **minor**, `0.89.0` → `0.90.0`, across the
five CI-checked locations plus the README plugin-table row.

## 12. Docs

Same PR. Derived from the grep in §6, not by hand:

`README.md:74,77,486`; `docs/contributing/index.md:195`;
`docs/plugins/ai-literacy-superpowers/reference/hooks.md:277,282`;
`.../reference/commands.md:128,133`; `.../reference/harness-md-format.md:19,41`;
`.../how-to/update-the-plugin.md:16,97`; `.../how-to/upgrade-your-harness.md:23`;
`.../how-to/sync-harness.md` (three references, including the drift-table row and
the "Template drift" remediation section).
