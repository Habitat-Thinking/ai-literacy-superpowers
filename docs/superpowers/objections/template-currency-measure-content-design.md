---
spec: docs/superpowers/specs/2026-08-25-template-currency-measure-content-design.md
date: 2026-08-25
mode: spec
diaboli_model: claude-opus-5[1m]
objections:
  - id: O1
    category: premise
    severity: high
    claim: "The spec retains a nudge it admits has zero recorded successes, and compares the retained option against deletion using a cost figure ('two greps at session start') that omits the shared script, the bin shim, the new HARNESS.md grammar, the new command disposition, the eighteen acceptance criteria and the twelve-file migration the same spec specifies."
    evidence: "§3.3 'there is no recorded instance of this nudge producing a useful adoption. Six runs are recorded; five adopted nothing, and the sixth cannot be attributed'; §3.3 'a correctly filtered comparison costs two greps at session start'; §6 'Delete the nudge entirely … Still live, and strengthened by §1.1 removing the evidence that favoured keeping it.'"
    disposition: pending
    disposition_rationale: null
  - id: O2
    category: implementation
    severity: critical
    claim: "The filter does not exclude commented-out opt-in template blocks, and §5.1 criterion 4 mandates including them, so a default-initialised project is told on day one that it is missing 'Stakeholders' and 'Cognitive reservoir' — content the template itself labels OPTIONAL. This is the day-one false positive §3.4 exists to eliminate."
    evidence: "§4.1 'tpl_headings = ## and ### headings of tpl, including inside HTML comments' with exclusions only for affordance-example and ^\\[.*\\]$; §5.1 criterion 4 'A template heading that appears only inside an HTML comment is treated like any other'; templates/HARNESS.md:39 '<!-- ## Stakeholders' with ':41 OPTIONAL.'; templates/HARNESS.md:630 '<!-- ## Cognitive reservoir  (OPTIONAL — to opt in …)'; §3.4 'An unfiltered heading comparison fires on the default install, on day one.'"
    disposition: pending
    disposition_rationale: null
  - id: O3
    category: implementation
    severity: high
    claim: "The affordance-example exclusion, as specified, matches nothing: the tag sits on the line after each heading in the real template, not on the heading line."
    evidence: "§4.1 excludes 'a heading whose line carries <!-- affordance-example -->'; §3.4 cites 'four headings tagged <!-- affordance-example --> (templates/HARNESS.md:520,535,546,557)'. In the file, the headings are at :519 '### gh-cli', :534 '### honeycomb-mcp', :545 '### shell-write-to-tmp', :556 '### sync-to-global-cache-hook'; lines 520/535/546/557 are the standalone comment lines beneath them."
    disposition: pending
    disposition_rationale: null
  - id: O4
    category: scope
    severity: high
    claim: "No acceptance criterion runs the algorithm against a default-initialised project, and the one real-input criterion runs against a repository that is a superset of the template — an input on which every exclusion rule is unobservable, so O2 and O3 both ship green."
    evidence: "§5.2 criterion 14 'Run against this repository's committed HARNESS.md and templates/HARNESS.md, the missing set is empty'; §5.2 'This criterion exists because revision 1 never ran its own algorithm.' This repository's HARNESS.md already contains '### gh-cli' (:1014), '### honeycomb-mcp' (:1032), '### shell-write-to-tmp' (:1043), '### sync-to-global-cache-hook' (:1054) and '### [Governance constraint name]' (:639), so criteria 5 and 6 pass on this input whether or not the exclusions fire. Criteria 5–7 are fixture tests authored from the same rule text they are meant to check."
    disposition: pending
    disposition_rationale: null
  - id: O5
    category: scope
    severity: high
    claim: "Replacing /harness-upgrade step 2's parse with harness-template-diff silently deletes two of the command's three finding buckets: the script computes only the missing set, while the command today also produces 'Updated items' and 'Removed items'."
    evidence: "§4.4 'Step 2 invokes harness-template-diff --format=json rather than restating the matching rules'; §4.1's contract yields only 'missing'. commands/harness-upgrade.md:74 'Sort items into three buckets', :79 '**Updated items** — present in both files, but the template content differs', :86 '**Removed items** — present in the user's HARNESS.md but absent from the current template.' §4.4 lists changes to steps 1, 2, 3, 4, 6 and 7 and never mentions either bucket."
    disposition: pending
    disposition_rationale: null
  - id: O6
    category: risk
    severity: high
    claim: "Migration deletes the marker from every consuming project's HARNESS.md while leaving the `Template currency` GC rule that reads it in place, converting a noisy-but-explicable signal into a permanently failing one — and, per O5, removing the only path by which the command would have surfaced the orphan."
    evidence: "§4.5 'The marker becomes inert on the release that ships this. Nothing reads it, so a project that still has one is not broken' and '/harness-upgrade removes it when it next runs'; §4.5 scopes rule removal to 'This repository removes its own in this PR, along with the Template currency GC rule.' templates/HARNESS.md:335-342 shipped the rule to every project ('Tool: compare template-version comment in HARNESS.md against …'). Under the pre-existing semantics a missing marker is 0.0.0 (hooks/scripts/template-currency-check.sh:32-34), i.e. permanently drifted."
    disposition: pending
    disposition_rationale: null
  - id: O7
    category: alternatives
    severity: high
    claim: "The template's own content marker is rejected for being unmaintained and unread — both fixable properties, and this spec already demonstrates the fix it declines to apply. A Layer 0 assertion that a change to templates/HARNESS.md moves its marker, plus a hook that compares that marker instead of plugin.json, measures the stated property with one CI check and no new script, grammar, shim or declined-item mechanism."
    evidence: "§6 'Compare the template's own content marker. Unmaintained — d867c7c changed the template without moving it — and nothing reads it.' §4.2 adds exactly this class of guard for a different defect: 'A Layer 0 test asserts no heading line in templates/HARNESS.md carries a trailing parenthetical, so the class cannot return.' §6's other rejection, 'reintroduces per-project state that drifts', does not apply: the marker lives in the plugin's template, not per project."
    disposition: pending
    disposition_rationale: null
  - id: O8
    category: implementation
    severity: high
    claim: "The skip semantics reason about sessions, but SessionStart re-fires on resume, clear and compact; with the dismissal file removed and no startup guard specified, a project with one genuinely new template item gets the nudge re-injected repeatedly within a single working session."
    evidence: "§4.4 'Skip means not now, ask again next session … being reminded of those each session is the intended behaviour'; §4.5 '.claude/.harness-upgrade-dismissed is no longer written or read.' hooks/hooks.json:106 registers the hook under SessionStart with matcher '*'. The sibling hook on the same rail guards for this explicitly — hooks/scripts/wip-check.sh:28-29 'STARTUP ONLY. SessionStart re-fires on resume, clear and compact, and a breach report re-injected mid-session is the thrash this exists to name' and :47 '[ \"$source_field\" = \"startup\" ] || exit 0'. §4.1 and §4.4 specify no equivalent."
    disposition: pending
    disposition_rationale: null
  - id: O9
    category: scope
    severity: high
    claim: "The §4.7/§8 inventories are again presented as complete and are again incomplete, and the spec adds no acceptance criterion asserting that no live reference to the marker survives — so the only defence against a third recurrence is a third hand-made list."
    evidence: "§4.7 'Revision 1's table listed seven files and presented the inventory as complete; it found seven of ten.' Unlisted live references: skills/harness-observability/references/observatory-signals.md:157 '| **Total** | **82** |'; commands/observatory-verify.md:3 '82-signal checklist' and :17 '82 signals across 5 sources'; README.md:77 'the Template currency rule checks the same marker'; docs/plugins/ai-literacy-superpowers/reference/hooks.md:277 '### Template currency check'; docs/plugins/ai-literacy-superpowers/reference/commands.md:133 '.claude/.harness-upgrade-dismissed marker'; commands/harness-upgrade.md:152 'Template version updated from X.Y.Z to A.B.C'. §5 contains no criterion of the form 'grep finds no remaining reference outside CHANGELOG and archives'."
    disposition: pending
    disposition_rationale: null
  - id: O10
    category: specification quality
    severity: medium
    claim: "The comparison rule specifies HTML-comment handling for the template side and is silent for the project side, and this repository's own file makes the two readings give opposite results for criterion 14."
    evidence: "§4.1 'tpl_headings = ## and ### headings of tpl, including inside HTML comments' — the corresponding proj_headings term is used undefined in 'skip if normalise(h) is in normalise(proj_headings)'. This repository's HARNESS.md:55 carries '<!-- ## Stakeholders' inside a comment. Under a comment-excluding read of the project side, criterion 14's missing set is not empty; under a comment-including read it is."
    disposition: pending
    disposition_rationale: null
  - id: O11
    category: specification quality
    severity: medium
    claim: "Criterion 10 is filed under §5.1 as a Layer 0 test of harness-template-diff, but the script has no write path — the `--` rejection is a behaviour of the model-executed command, which is exactly the misfiling §5.3 says revision 1 committed."
    evidence: "§5.1 heading 'harness-template-diff — Layer 0 deterministic', criterion 10 'A declined reason containing -- is rejected on write.' §4.1's interface is 'harness-template-diff [--format=text|json]' with read-only inputs and four outcomes, none of which write. §4.4 assigns the behaviour elsewhere: 'Step 4 … Declining prompts for a reason and writes it per §3.5's grammar, rejecting a reason containing --.' §5.3 'Not Layer 0; these are model-executed … Revision 1 assigned them to the hook's test file in error.'"
    disposition: pending
    disposition_rationale: null
  - id: O12
    category: risk
    severity: medium
    claim: "§4.3 states an absolute contract — silence never means could-not-check — but only one input failure is covered. The hook's own failure modes (script absent from a partial or stale plugin install, non-zero exit under strict mode, the 10s timeout) all produce silence, which the spec has just defined as the reassuring answer."
    evidence: "§4.3 'Silence means checked-and-current. It never means could-not-check', citing the harness decision record 'a mechanism that could not determine the answer reports the degraded state and names the input it could not read.' §4.1 defines exactly two non-missing outcomes: 'proj absent -> exit 0, emit nothing' and 'tpl absent/unreadable -> exit 0, emit DEGRADED'. §4.7 specifies the hook only as 'Rewritten to call harness-template-diff'; hooks/hooks.json:107 sets 'timeout: 10', and the current hook runs under 'set -euo pipefail' (hooks/scripts/template-currency-check.sh:11)."
    disposition: pending
    disposition_rationale: null
---

# Objections — template currency measures content (revision 2)

## O1 — premise — high

### Claim

The spec retains the nudge on a judgement it states honestly, and then prices
that judgement wrongly. The comparison offered to the reviewer is "two greps at
session start" versus deleting the hook. The actual retained option is a new
shared script, a `bin/` shim, a new grammar embedded in the governing document,
a fourth disposition in `/harness-upgrade`, fifteen Layer 0 criteria, three
behavioural criteria, a twelve-file migration and eight documentation edits — in
service of a mechanism with no recorded instance of ever having worked.

### Evidence

> §3.3: "there is no recorded instance of this nudge producing a useful
> adoption. Six runs are recorded; five adopted nothing, and the sixth cannot
> be attributed."

> §3.3: "a correctly filtered comparison costs two greps at session start."

> §6: "**Delete the nudge entirely, keeping `/harness-upgrade` on demand.**
> Still live, and strengthened by §1.1 removing the evidence that favoured
> keeping it."

The spec is candid that this is a judgement and that a reviewer may reject it.
The objection is not to the candour; it is that the two options are not
presented in commensurable terms, so the reviewer is choosing between "two
greps" and "delete the hook" rather than between the real build and the real
saving. §6's own description of the deletion option — "deletes the hook, the
shared script, the declined block and §5.1 entirely" — states the true cost of
the retained option more accurately than §3.3 does.

### Why this matters

This is the highest-leverage decision in the spec and every other objection
here is downstream of it. If the nudge goes, O2 through O6, O8, O10 and O12
evaporate with it. A premise this thinly evidenced deserves the comparison
stated in like terms before the build proceeds.

## O2 — implementation — critical

### Claim

The filtered item set does not exclude the template's commented-out opt-in
blocks, and §5.1 criterion 4 explicitly requires including them. A
default-initialised project has neither `## Stakeholders` nor
`## Cognitive reservoir`, because both are shipped commented out and are
labelled OPTIONAL in the template. On day one, such a project is told its
harness is missing two items it was never meant to have. This is precisely the
failure mode §3.4 asserts the filter removes.

### Evidence

The template's two opt-in blocks:

> `templates/HARNESS.md:39` — `<!-- ## Stakeholders`
> `templates/HARNESS.md:41` — "OPTIONAL. Who this project affects…"

> `templates/HARNESS.md:630` — `<!-- ## Cognitive reservoir  (OPTIONAL — to opt in, remove this `<!--` line and the closing `-->` below)`

The rule includes them:

> §4.1: "tpl_headings = ## and ### headings of tpl, **including inside HTML
> comments**, EXCLUDING: a heading whose line carries `<!-- affordance-example -->`;
> a heading matching `^\[.*\]$`"

> §5.1 criterion 4: "A template heading that appears only inside an HTML comment
> is treated like any other; criteria 1–3 hold for it unchanged."

The unconfigured-section skip does not reach them: it fires when "h's owning
`##` section is unconfigured in proj", and these headings *are* the `##`
sections. A project that never adopted them has no section body to carry the
placeholder marker.

The spec came within one line of noticing. §3.4's own trial run reported
`Cognitive reservoir  (OPTIONAL — …)` as a false positive, and §4.2 diagnosed
that as a trailing-parenthetical matching failure. That diagnosis is correct for
*this* repository, which has an uncommented `## Cognitive reservoir`
(`HARNESS.md:1126`). It is the wrong diagnosis for a default project, which does
not have the heading at all and will be reported regardless of §4.2's fix. And
§4.3's exemplar message — `Template has 1 item your harness does not:
"Stakeholders"` — uses one of the two OPTIONAL blocks as the illustration of a
legitimately missing item.

### Why this matters

§3 states the case for revision 2 as "The filter is what makes the mechanism
quiet; the declined-item record handles only the residue." If the filter leaves
two OPTIONAL blocks in, the mechanism is not quiet on a default install, and the
only silencing route available to a new user is the one §3.4 already identified
as unacceptable: "silenceable only by running the command the nudge advertises."
The central claim of the revision does not hold as specified.

## O3 — implementation — high

### Claim

The `affordance-example` exclusion excludes nothing, because in the real
template the tag is on the line *following* each heading, not on the heading
line.

### Evidence

> §4.1: "EXCLUDING: — a heading whose line carries `<!-- affordance-example -->`"

> §3.4: "The template's `## Affordances` body carries four headings tagged
> `<!-- affordance-example -->` (`templates/HARNESS.md:520,535,546,557`)."

The cited lines are the tags, not the headings:

```text
519  ### gh-cli
520  <!-- affordance-example -->
...
534  ### honeycomb-mcp
535  <!-- affordance-example -->
...
545  ### shell-write-to-tmp
546  <!-- affordance-example -->
...
556  ### sync-to-global-cache-hook
557  <!-- affordance-example -->
```

An implementer following §4.1 literally writes a predicate over the heading
line and it never matches. An implementer who infers the intent writes a
lookahead — and the two implementations disagree on any future entry where a
blank line or a schema comment intervenes.

### Why this matters

This is the exclusion §3.4 identifies as the primary day-one false-positive
source for a project that opted out of Affordances, and it is one of the two
mechanisms §9 claims resolves the critical objection O1 from the previous
review. As written it is inert, and per O4 nothing in §5 would reveal that.

## O4 — scope — high

### Claim

The acceptance criteria never run the algorithm against a default-initialised
project, and the single real-input criterion runs against a repository that is a
near-superset of the template — an input on which no exclusion rule is
observable. Both O2 and O3 pass every criterion in §5.

### Evidence

> §5.2 criterion 14: "Run against this repository's committed `HARNESS.md` and
> `templates/HARNESS.md`, the missing set is **empty** …"
>
> "This criterion exists because revision 1 never ran its own algorithm; §3.4
> records what happened when it finally was."

This repository already contains every heading the exclusions are supposed to
suppress:

```text
HARNESS.md:1014  ### gh-cli
HARNESS.md:1032  ### honeycomb-mcp
HARNESS.md:1043  ### shell-write-to-tmp
HARNESS.md:1054  ### sync-to-global-cache-hook
HARNESS.md:639   ### [Governance constraint name]
HARNESS.md:1126  ## Cognitive reservoir
```

So criteria 5 and 6 are satisfied by the project side of the comparison, not by
the exclusion logic. Criterion 14 will read green with the exclusions removed
entirely. Criteria 5, 6 and 7 are fixture tests, and the fixtures will be
authored from the same rule text that carries the defect in O3.

What is absent is the case the design exists for: run the tool against the
output of a default `/harness-init` — Affordances off, Stakeholders and
Cognitive reservoir not adopted — and assert an empty missing set.

### Why this matters

§5.2 presents criterion 14 as the guard against shipping an unrun algorithm a
second time. On the input chosen it is a weak guard: it validates that this
repository is a superset, which was already known, and it is structurally
incapable of detecting a broken exclusion. The one population the filter was
designed for — new adopters — is the one population no criterion covers.

## O5 — scope — high

### Claim

Step 2 of `/harness-upgrade` currently parses both files into three buckets.
`harness-template-diff` computes one. Substituting the script for the parse
deletes the "Updated items" and "Removed items" buckets, and §4.4 does not
mention either.

### Evidence

> §4.4: "**Step 2** invokes `harness-template-diff --format=json` rather than
> restating the matching rules."

§4.1's contract emits `missing` and nothing else.

The command today:

> `commands/harness-upgrade.md:74`: "Sort items into three buckets:"
> `:79`: "**Updated items** — present in both files, but the template content
> differs. Only flag items the user has not customised…"
> `:86`: "**Removed items** — present in the user's HARNESS.md but absent from
> the current template. Advisory only."

§4.4 enumerates changes to steps 1, 2, 3, 4, 6 and 7. Step 3's new **Previously
declined** group is described; the two disappearing groups are not. §6 offers a
rationale for choosing heading sets over full-text diff — "The property worth
surfacing is a *missing item*, not a reworded one" — which is a defensible
answer for the *hook*, but "Updated items" is a `/harness-upgrade` feature about
content, and dropping it is a decision the spec does not record as one.

### Why this matters

A user who runs `/harness-upgrade` after this change will no longer be shown
that a constraint they never customised has been rewritten in the template, nor
that their harness carries items the template has dropped. Both are silent
regressions in a command whose stated job is bringing a harness in line with the
template. The second one has a direct consequence — see O6.

## O6 — risk — high

### Claim

Migration deletes the `template-version` marker from consuming projects while
leaving the `Template currency` GC rule that reads it. Under the pre-existing
"missing marker means 0.0.0" semantics, that rule then reports drift on every
run, forever, in every project that ever ran `/harness-init`. Nothing in the
spec removes it, and per O5 the one bucket that would have flagged it is being
removed in the same change.

### Evidence

> §4.5: "The marker becomes inert on the release that ships this. Nothing reads
> it, so a project that still has one is not broken."
> "`/harness-upgrade` removes it when it next runs, and says so in its report."
> "This repository removes its own in this PR, along with the `Template
> currency` GC rule."

The rule was shipped to every adopter by the template:

> `templates/HARNESS.md:335` `### Template currency`
> `:337` "**What it checks**: Whether the HARNESS.md template-version marker…"
> `:342` "**Tool**: compare template-version comment in HARNESS.md against…"

The failure semantics are already established in the code being replaced:

> `hooks/scripts/template-currency-check.sh:32-34`
> ```bash
> if [ -z "$harness_version" ]; then
>   harness_version="0.0.0"
> fi
> ```

§4.7's row for the rule is scoped to `templates/HARNESS.md:337-342` and
`HARNESS.md:760-769` — the plugin's copy and this repository's copy. A consuming
project's copy is its own file and is reached by no listed change.

### Why this matters

The spec's problem statement is a mechanism that "asserts `Plugin template has
been updated` on evidence that cannot establish it", and whose "false signal
reached the governing document" (§1). This migration reproduces that outcome
exactly, in every project except this one: a GC rule declared in the governing
document, comparing a value that no longer exists, reporting drift that cannot
be cleared. It is the defect being fixed, exported to the install base.

## O7 — alternatives — high

### Claim

The template's own content marker is rejected on two grounds — unmaintained, and
unread — that are both properties of the current state rather than of the
mechanism, and this spec already demonstrates the repair for the first one on
another defect three sections later. A hook that compares the template's content
marker against the project's, plus a Layer 0 assertion that any change to
`templates/HARNESS.md` moves that marker, measures the property §2 names and
needs no script, shim, grammar, declined-item record or new command disposition.

### Evidence

> §6: "**Compare the template's own content marker.** Unmaintained — `d867c7c`
> changed the template without moving it — and nothing reads it. Substitutes one
> unreliable signal for another."

The repair pattern is already in the spec:

> §4.2: "A Layer 0 test asserts no heading line in `templates/HARNESS.md`
> carries a trailing parenthetical, so the class cannot return."

The same sentence shape applies: *a Layer 0 test asserts that a diff touching
`templates/HARNESS.md` also moves `<!-- template-version -->`, so the class
cannot return.* "Nothing reads it" is answered by having the hook read it, which
is one line's change from the code in `template-currency-check.sh:29`.

§6's other stored-state objection does not transfer:

> "**Hash the template and store the hash.** … reintroduces per-project state
> that drifts, which is the class of defect being removed."

The template's marker is not per-project state. It ships in the plugin, is
authored by the maintainer, and is enforceable in this repository's CI — which
is where §4.2 is already putting an assertion.

### Why this matters

Spec time is when alternatives are still cheap. The rejected option is roughly
one CI check and one `sed` expression against a design that adds a script, a
`PATH` shim, an HTML-comment grammar in the governing document, a fourth
disposition in a command, eighteen acceptance criteria and a twelve-file
migration. The rejection is one sentence, and the sentence relies on a fact the
spec's own method dissolves.

## O8 — implementation — high

### Claim

`SessionStart` fires on startup, resume, clear and compact. §4.4 reasons about
skip semantics in units of "session", removes the only time-boxed silence, and
specifies no startup guard — so a project with one genuinely new template item
receives the nudge repeatedly inside one working session.

### Evidence

> §4.4: "Skip means *not now, ask again next session*. Revision 1 removed the
> dismissal file, which was the only time-boxed silence, without saying so. This
> revision states it: … being reminded of those each session is the intended
> behaviour."

> §4.5: "`.claude/.harness-upgrade-dismissed` is no longer written or read."

The hook's registration:

> `hooks/hooks.json:100-108` — `"SessionStart"`, `"matcher": "*"`,
> `bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/template-currency-check.sh`

The project has already learned this lesson on the same rail:

> `hooks/scripts/wip-check.sh:28-29`: "STARTUP ONLY. SessionStart re-fires on
> resume, clear and compact, and a breach report re-injected mid-session is the
> thrash this exists to name."
> `:47`: `[ "$source_field" = "startup" ] || exit 0`

`parked-resume-check.sh:13` carries the same note. Neither §4.1, §4.3 nor §4.4
specifies the equivalent gate, and no acceptance criterion covers it.

### Why this matters

The dismissal file was doing more work than §4.4 credits: it suppressed re-fires
within a version, not just across sessions. Removing it while keeping the nudge
on a `*` matcher turns a once-per-upgrade message into a per-compaction one on
exactly the population the nudge is meant to serve — a project that really is
missing template content and has not yet acted. Alarm fatigue on the only true
positives the mechanism has is the worst available distribution of noise.

## O9 — scope — high

### Claim

The §4.7 and §8 inventories are again presented as authoritative and are again
incomplete, and no acceptance criterion asserts that no live reference survives.
The correction mechanism for a defect that has now recurred twice is a third
hand-made list.

### Evidence

> §4.7: "Revision 1's table listed seven files and presented the inventory as
> complete; it found seven of ten (O4)."

Live references absent from both §4.7 and §8:

```text
skills/harness-observability/references/observatory-signals.md:157  | **Total** | **82** |
commands/observatory-verify.md:3    "…runs the 82-signal checklist against the latest output files"
commands/observatory-verify.md:17   "This is the authoritative list of all signals to verify — 82 signals"
README.md:77                        "the `Template currency` rule checks the same marker on…"
docs/plugins/…/reference/hooks.md:277               "### Template currency check"
docs/plugins/…/reference/commands.md:133            ".claude/.harness-upgrade-dismissed marker so the SessionStart hook"
commands/harness-upgrade.md:152                     "Template version updated from X.Y.Z to A.B.C"
```

The observatory count is the same enforcement surface §4.7 itself flags as
load-bearing: "**The observatory row is enforced.**" Removing row 127 without
moving 82 → 81 in three places leaves the reference internally inconsistent with
the command that reads it.

§5 contains no criterion of the form "a repository-wide search for
`template-version` returns only CHANGELOG entries, archived snapshots and
historical spec/objection records."

### Why this matters

The spec's method for this class is enumeration by hand, and enumeration by hand
is what produced seven-of-ten last time. The fix that would end the recurrence —
one grep assertion in the Layer 0 suite — costs less than the table and is the
same technique §4.2 and §5.2 already reach for elsewhere in this spec.

## O10 — specification quality — medium

### Claim

The comparison rule states HTML-comment handling for the template side and
leaves it undefined for the project side. This repository's own file makes the
two readings produce opposite outcomes for criterion 14.

### Evidence

> §4.1: "tpl_headings = ## and ### headings of tpl, **including inside HTML
> comments**, EXCLUDING: …"

`proj_headings` then appears undefined:

> "skip if normalise(h) is in normalise(proj_headings)"

> `HARNESS.md:55` — `<!-- ## Stakeholders`

Under a comment-excluding read of the project side, `Stakeholders` is missing
from this repository and criterion 14 fails. Under a comment-including read it
is present and criterion 14 passes. Since the template side is explicitly
specified and the project side is not, the asymmetry reads as deliberate to at
least one reasonable implementer.

### Why this matters

Criterion 14 is the spec's headline guard and its pass/fail depends on an
unstated rule. Worse, the two readings differ in meaning: "you have adopted this
in commented form" and "you have not adopted this" are different states, and the
spec has not decided which one counts as having the item.

## O11 — specification quality — medium

### Claim

Criterion 10 tests a write behaviour against a component that has no write path,
in the section §5.3 was added to stop exactly that misfiling.

### Evidence

> §5.1, "`harness-template-diff` — Layer 0 deterministic", criterion 10:
> "A declined reason containing `--` is rejected on write."

The script's contract (§4.1) is `harness-template-diff [--format=text|json]`
with two file inputs and four read-only outcomes. The behaviour belongs to the
command:

> §4.4: "**Step 4** … Declining prompts for a reason and writes it per §3.5's
> grammar, rejecting a reason containing `--`."

And the section immediately following states the principle being violated:

> §5.3: "Not Layer 0; these are model-executed and belong in a behavioural
> scenario, not in the hook's test file. Revision 1 assigned them to the hook's
> file in error."

### Why this matters

An implementer building the Layer 0 suite from §5.1 will either add a write path
to a read-only tool to satisfy criterion 10, or quietly drop the criterion. The
first widens the script's surface beyond §4.1's contract; the second loses the
only check on the `--` rule that §3.5 calls "semantically load-bearing".

## O12 — risk — medium

### Claim

§4.3 makes an absolute claim about what silence means, and the design honours it
for one input only. The hook's own failure modes all produce silence, which this
spec has just defined as the reassuring answer.

### Evidence

> §4.3: "Silence means checked-and-current. It never means could-not-check. This
> follows the harness decision record in force until 2026-11-23 … a mechanism
> that could not determine the answer reports the degraded state and names the
> input it could not read."

§4.1 defines exactly one degraded outcome — `tpl absent/unreadable`. It defines
none for the hook that wraps it. §4.7 specifies the wrapper only as
`hooks/scripts/template-currency-check.sh` "Rewritten to call
`harness-template-diff`". The surrounding conditions:

> `hooks/hooks.json:107` — `"timeout": 10`
> `hooks/scripts/template-currency-check.sh:11` — `set -euo pipefail`

A stale marketplace cache or partial install in which
`scripts/harness-template-diff.sh` is absent, a non-zero exit propagating under
strict mode, or a timeout, all yield no `systemMessage` — indistinguishable from
"checked and current".

### Why this matters

The decision record cited in §4.3 is enforced against this plugin and names this
exact shape: "A reachable code path that reaches a passing value without reading
the thing it reports on is a defect, not a default." The spec invokes the record
correctly for the template-unreadable case and then stops one layer short of the
component that actually decides whether the user sees anything.

## Explicitly not objecting to

- **The core premise that the marker measures the wrong property**: §1's
  evidence is independently checkable and holds — `templates/HARNESS.md` last
  changed at `d867c7c` (2026-08-13), the repository marker reads `0.79.0`
  (`HARNESS.md:13`) against `plugin.json` `0.89.0`, and `HARNESS.md:1185`
  records the resulting false claim in the governing document. Retiring
  version-as-proxy is right.
- **Heading sets over full-text diff**: §6's reasoning is correct — the property
  worth surfacing is a missing item, not a reworded one — and a full-text diff
  would fire on every prose edit.
- **Fixing the template rather than the parser in §4.2**: the right layer, and
  the justification checks out — `templates/HARNESS.md:463` and `:476` carry
  `(LOCAL — per-machine only)` parentheticals that appear identically on both
  sides and would be collapsed by a general normalisation.
- **Keeping the declined record in `HARNESS.md` rather than a new file**: the
  "two committed dashboards went 106 days unread" evidence is the strongest
  argument in §6, and it is applied correctly.
- **Running `/harness-audit` in this PR (§4.8)**: this is a genuine improvement
  over revision 1, and `HARNESS.md:1177`'s record of the 2026-08-13 audit
  reporting `Drift detected: no` against a failing tree is the right evidence
  for it.
- **§1.1's withdrawal of the Stakeholders attribution**: naming three candidate
  causes and attributing none, rather than keeping a convenient one, is
  intellectually honest and I have no basis to challenge it.
- **The declined-block grammar's strictness (§3.5)**: the `::` separator, the
  no-continuation rule, the `--` prohibition and "reported, never skipped" are
  well specified; my only objection touching it is where criterion 10 was filed,
  not what it says.
- **The version bump, docs list and Layer 0 platform conventions (§7, §8)**:
  these follow the repository's existing conventions and I found nothing wrong
  with them beyond the completeness point in O9.
- **The `New plugin components must ship with a TDAD scenario` reasoning in
  §5.3**: the constraint genuinely names skills, agents and commands, a script
  is none of those, and the spec adds the tests anyway.
- **Not objecting to the `/harness-upgrade`-routes-through-`/harness-propose`
  question**: explicitly out of scope per the header, and legitimately so.
