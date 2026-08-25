# Template currency measures content — design

**Status:** proposed
**Date:** 2026-08-25
**Issue:** #601
**Provenance:** `docs/superpowers/specs/2026-04-15-harness-upgrade-design.md`,
which introduced the `template-version` marker and decided that a missing
marker means "treat as `0.0.0`". This spec retires the marker outright. The
issue as filed proposed making the marker optional; the approach here is
broader and is argued for in §3.
**Scope:** the SessionStart template-currency hook, `/harness-upgrade` step 1
and step 6, `/harness-init`'s marker write, the `Template currency` GC rule,
and the declined-item record that makes the new comparison quiet.
**Out of scope:** `/harness-upgrade`'s adoption mechanics (steps 2–5) beyond
the parsing fix in §4.4; the harness evolution loop; whether
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

The failure has two halves, and fixing only one leaves the mechanism broken.

**It cries wolf.** Five of the last six marker advances adopted nothing.
`58d3dda` (2026-07-22) and `89b46f9` (2026-08-13) each record "found nothing to
adopt", both naming the same item — the generic `Consistent formatting`
placeholder, declined because this repository has specialised it into a
deterministic markdownlint rule. The 2026-08-25 run reached the same conclusion
about the same item a third time.

**It may also be silent when it matters.** `d867c7c` added a commented-out
`## Stakeholders` section to the template on 2026-08-13 at 09:11. `89b46f9` ran
six hours later, reported "byte-identical … nothing to adopt", and stamped the
marker forward. The block was not adopted until twelve days later, by a human
who noticed it another way. This cannot be settled now — the `0.73.2` plugin
cache is no longer on the machine that ran it — but §4.4 addresses the parsing
asymmetry that makes the "genuinely missed it" reading plausible.

## 2. The property that should be measured

The nudge names one property: *the template contains something your harness
does not*. The marker measures a different one: *the plugin has been released
since you last stamped a number*. These come apart on every release that does
not touch the template, which is nearly all of them.

`/harness-upgrade` already computes the real property. Steps 2–3 parse both
files into named items and diff them. Step 1's version gate is a pre-filter in
front of a comparison that does not need it, and the pre-filter is the part
that is wrong.

## 3. Decision — compare headings, retire the marker

The hook and the command compare **heading sets** between the plugin's
`templates/HARNESS.md` and the project's `HARNESS.md`. There is no marker, no
`plugin.json` read, and no stored version state.

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

### 3.3 Why not delete the nudge entirely

Considered. `/harness-upgrade` survives as an on-demand command either way, and
the README already directs people to run it after a plugin upgrade. Rejected
because the `## Stakeholders` case suggests the failure mode that actually costs
something is *not being told*, and a nudge that measures the right property is
cheap enough to keep.

### 3.4 The declined-item record is load-bearing

Heading comparison alone reproduces the original defect in a new coat. This
repository's `HARNESS.md` has `Consistent markdown formatting`; the template has
`Consistent formatting`. A pure set difference flags it every session, forever —
an item declined three times on recorded reasoning.

So the disposition must live somewhere the mechanism can read. Today it lives in
commit messages and CHANGELOG entries, which is why the item keeps coming back.

`HARNESS.md` gains a declined block, in the position the marker occupied:

```html
<!-- template-declined
     Consistent formatting: specialised here as "Consistent markdown
       formatting" (deterministic, markdownlint, commit + pr). Adopting the
       template's unverified placeholder would be a downgrade.
-->
```

One line per declined heading, `Heading: reason`. The hook subtracts these from
the missing set. `/harness-upgrade` reads them and presents a declined item as
*previously declined, because …* rather than as new.

The reason text is never parsed. It exists so the next person reads why, and so
that declining is a considered act rather than a suppression.

## 4. Design

### 4.1 The hook

`hooks/scripts/template-currency-check.sh` becomes:

```text
tpl      = $CLAUDE_PLUGIN_ROOT/templates/HARNESS.md
proj     = $CLAUDE_PROJECT_DIR/HARNESS.md

exit 0 if either file is unreadable          (unchanged: advisory, never blocks)

tpl_headings   = headings of tpl             (## and ###, incl. commented)
proj_headings  = headings of proj
declined       = headings named in proj's template-declined block

missing = tpl_headings - proj_headings - declined

exit 0 if missing is empty
emit systemMessage naming the count and up to three headings
```

Matching is case-insensitive and whitespace-trimmed, identical to
`/harness-upgrade` step 2, so the hook and the command never disagree about
what is new.

### 4.2 The message states what it compared

> `Template has 2 item(s) your harness does not: "Stakeholders", "Spec conformance". Run /harness-upgrade to review.`

It names the items it found. A reader can falsify it against their own file
without running anything — which is the property §1 says was missing.

### 4.3 `/harness-upgrade`

- **Step 1** drops the version comparison. Prerequisites keep the HARNESS.md
  existence check and the `git fetch origin main` staleness guard.
- **Step 3** subtracts declined headings from the *new items* bucket and
  presents them in a separate **Previously declined** group, each with its
  recorded reason, so a standing decision is visible without being re-litigated.
- **Step 4** gains a **decline** disposition alongside accept/skip/customise.
  Declining prompts for a one-line reason and writes it to the declined block.
  **Skip** remains what it is today: not now, ask again next time.
- **Step 6** no longer writes a marker or a dismissal file. It removes a
  `template-version` marker if it finds one (§4.5) and writes any new declined
  entries.
- **Step 7** reports declined items alongside accepted and skipped.

### 4.4 Commented-out blocks parse uniformly

Step 2 currently scopes commented-out blocks to constraints and GC rules, and
describes sections as plain `## Heading` entries. The template's one commented
section, `<!-- ## Stakeholders`, matches neither clause.

Both the hook and the command extract headings from inside HTML comments at
every level. This is the parsing half of the `## Stakeholders` case in §1.

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

### 4.6 Surfaces that declare the marker

| File | Change |
| --- | --- |
| `templates/HARNESS.md:13` | Remove the stale `0.57.0` marker |
| `templates/HARNESS.md:337-342` | Remove the `Template currency` GC rule |
| `HARNESS.md:13` | Remove the marker |
| `HARNESS.md:760-769` | Remove the `Template currency` GC rule |
| `skills/harness-audit-engine/SKILL.md:33` | Remove the `Template currency` surface row |
| `skills/harness-observability/references/observatory-signals.md:127` | `Template version` is marked **required**; remove the row |
| `skills/ai-literacy-assessment/references/habitat-discovery.md:93,141` | Drop the marker from habitat discovery |

`HARNESS.md`'s Status block references the marker. It is owned by
`/harness-audit` and is corrected by running it, not by hand-editing this PR.

## 5. Acceptance criteria

1. Given a project whose `HARNESS.md` contains every heading in the template,
   the hook exits 0 and emits nothing — **regardless of plugin version**.
2. Given a template with a heading the project lacks, the hook emits a message
   naming that heading.
3. Given a project whose declined block names that heading, the hook exits 0 and
   emits nothing.
4. Given a template heading that appears only inside an HTML comment, it is
   compared like any other — criteria 1–3 hold for it unchanged.
5. Given a `HARNESS.md` with no `template-version` marker, no mechanism treats
   it as `0.0.0` and no mechanism nudges on that basis.
6. Given a `HARNESS.md` with a `template-version` marker, `/harness-upgrade`
   removes it and reports having done so.
7. Heading matching is case-insensitive and whitespace-trimmed in both the hook
   and the command; a heading differing only in case or surrounding whitespace
   is not reported as missing.
8. `/harness-upgrade` presents a previously-declined item under **Previously
   declined** with its recorded reason, never in the new-items bucket.
9. The hook never blocks and never exits non-zero.

Criteria 1–7 and 9 are Layer 0 deterministic tests at
`tdad_tests/layer0_deterministic/test-template-currency-check.sh`, using
fixture harnesses under `tdad_tests/layer0_deterministic/fixtures/`. No such
test exists today; the hook is currently untested.

The *New plugin components must ship with a TDAD scenario* constraint does not
gate this work — it adds no new `SKILL.md`, `agent.md`, or `command.md`. The
Layer 0 test is added because the hook is being rewritten, not because a
constraint demands it.

## 6. Rejected alternatives

**Compare the template's own content marker.** It is unmaintained — `d867c7c`
changed the template without moving it — and nothing reads it. This substitutes
one unreliable signal for another.

**Hash the template and store the hash.** Measures content correctly, but
reintroduces per-project state that drifts, which is the class of defect being
removed. Heading comparison needs no state.

**Full-text diff instead of heading sets.** Every wording change in the template
would nudge. The property worth surfacing is a *missing item*, not a reworded
one; §3 keeps the mechanism aligned with what the message claims.

**Record declines in a separate file.** A seventh durable governance artifact,
in a repository where two committed dashboards went 106 days unread. The
declined block sits in the file it describes and is read by the two mechanisms
that need it.

## 7. Version

Behavioural change to plugin files: **minor**, `0.89.0` → `0.90.0`, across the
five CI-checked locations plus the README plugin-table row.

## 8. Docs

Same PR, per the docs-site convention:
`how-to/update-the-plugin.md:16,97`; `how-to/upgrade-your-harness.md:23`;
`reference/commands.md:128`; `reference/hooks.md:282`;
`reference/harness-md-format.md:19,41`; `README.md:74,486`.
