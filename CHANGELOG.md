# Changelog

## 0.87.0 — 2026-08-25

### The first rule enters force through the governed loop

`HDR-2026-08-25-four-mechanisms-report-the-reassuring-answer-when-they-cannot-determine-the-real-one`
is `accepted` and applied. Three assays, two adversarial reviews, thirty-five
dispositions and one reclassification after it was first observed, the loop has
produced a rule that is in force — and the corpus is no longer three records of
governance being examined with nothing surviving the examination.

- **Rule text amended before the gate**, on the accepted objections: the Tool
  retargeted to the skill that actually dispatches it (O5), and the duplicated
  "weaker property" clause dropped so it no longer legislates what assay 3's
  finding-2 already covers (O9). Each record now carries `proposed_rule` beside
  its amended text — the fourth application of the `proposed_cost` / `cost`
  pattern, added here because rule text had no provenance pair and an amendment
  would otherwise have read as the Assayer's words.
- **Applied to `skills/advocatus-diaboli/SKILL.md`**, where it is loaded on every
  `/diaboli` run. Enforcement report: intended advisory, achieved advisory,
  **0 gaps of 1 rule-surface pair**. At the classification the assay proposed it
  would have compiled to achieved `none`.
- **The cost is the approver's, in their own words**: the team does the work; the
  recurring cost is probably tighter than the Assayer estimated; retirement at
  2026-11-23 unless it has fired and protected something.
- **Validation was rewritten twice.** It first said nothing could measure the
  rule. The approver's own retirement test then supplied the measurement: the
  rule fires as an objection, objections carry dispositions, and that is the
  evidence trail. A criterion that only exists because of the reclassification.

### Fixed — the compiler emitted markdown that failed the project's own lint

`enforcement_summary` rendered its one-line account as an underscore-emphasised
line, which trips MD036 (emphasis used instead of a heading) and MD049
(emphasis style). So the first rule this loop put in force wrote a generated
region into `skills/advocatus-diaboli/SKILL.md` that failed *Consistent
markdown formatting* — and the region carries "do not edit by hand", so it
could not be fixed where it landed.

Now rendered as a blockquote. A generated region that cannot satisfy the
constraints of the project it is generated into is a defect in the generator,
and it took putting a rule in force to find it.

### Not accepted

`workflow-step-masking` is reclassified to `harness-loop` on its own accepted
objection and is now **refused by the threshold** — one countable assay against
two, because assay 1's finding-2 carries an erratum. Choosing the classification
that owns the behaviour cost it acceptance.

`command-cli-parity` is gate-ready with two amendments still open: whether the
rule binds bash as well as Python, and what the invocation trigger means
mechanically.

### AI literacy assessment — Level 4, and the badge corrected down from 5

`/assess` run in full. **Level 4 — Governed Collaboration.** Operational axes
mean 3.75 (Composition 4, Testing 4, Observability 3, Governance 4), Habitat
Build Gap **+0.25 — Coherent**: ambition and enablement are in line.

The level **fell from the previously claimed 5**, and not because anything
regressed. L5's markers are organisational — conventions that hold when someone
else writes the code, governance binding an author who did not design it, drift
caught by someone other than its author — and this is a single-operator practice
at 696 of 700 commits. The Level 5 claim was unreachable rather than merely
stale, and it had been sitting in the README for 106 days beside a
`Harness Health — Degraded` badge.

**Three of the four clarifying answers described real disciplines that leave no
trace**, and each changed a placement the scan could not have made:

- TDAD Layers 2 and 3 — 50 scenarios — run **weekly, by hand**, with no artifact.
  Testing is placed L4 flagged `asked` rather than L3; #583 would convert it to
  `observed`.
- The monthly snapshot is the only observability artefact anyone reads. Both
  dashboards are 106 days stale and unread, which by the rule this repository
  put in force today is an artefact that looks like assurance and provides none.
- The 37 missing objection records and 52 missing choice stories are **closed
  history, not live neglect** — recorded explicitly so a later assessor does not
  read the gap as decay, and backfilling is recommended against.

**Immediate adjustments applied:** the README AI Literacy badge corrected to
Level 4 and pointed at this assessment; the `HARNESS.md` Status block corrected
from "Four constraints failing" to three, since *Output validation checkpoints*
was repaired in #577 after the block was written.

The assessment's central finding is that one defect class — declared
verification with no dispatch path — explains most of the operational shortfall,
and appears three times: ten agent-enforced constraints with no CI path, fifty
scenarios with no CI path, and six weeks of GC step-masking.

### First on-demand garbage-collection run, and what six weeks of masking actually cost

`/harness-gc` Mode 2. The scheduled `gc.yml` workflow has failed six consecutive
runs since 2026-07-20, and because only its `Summary` step carries
`if: always()`, every step after the failure recorded `skipped`. Running the
rules on demand does not have that property — the rules execute independently.

**Reflection log archival (Path 1) — applied.** 15 fragments moved to
`reflections/archive/2026.md`; `reflections/active/` falls 57 → 42;
`REFLECTION_LOG.md` regenerated from the remainder. Two fragments are held back
because their `Promoted` lines fail `verify_rhs`, unchanged since 2026-08-13 —
the script reports and keeps them rather than editing or silently archiving,
which is the behaviour worth having. This backlog existed only because the rule
is step 13 of a job that never reached step 13. Running it by hand took four
seconds.

**Release tag completeness — applied, at the approver's direction.** The six
imported versions `v0.28.1`–`v0.28.5` and `v0.29.1` now carry annotated tags at
`2517102e`, the commit that brought their CHANGELOG entries into this
repository. The declared auto-fix could not have created them: its
`git log --grep` searches commit messages for a version string that appears only
in the diff, so it has always hit its error branch. Each annotation records that
the release was made upstream, that this repository's first commit postdates it,
and that #578 remains open. The rule now passes 118/118 — 110 by coincidence of
numbering, 6 by explicit annotation, 0 by verified correspondence. See #578,
updated rather than closed.

**Observability archive — nothing to do, correctly.** The cutoff is 2026-02-23
and the oldest snapshot is 2026-04-06. All eleven stay. The rule will first have
work around 2026-10-06.

### A correction to yesterday's account of the masking cost

The 2026-08-25 snapshot and issue #573 both state that two `Auto-fix: true`
rules were masked with work waiting. That overstates it. Of the three auto-fix
rules behind the failures, **one** had work: reflection archival, 15 fragments.
*Release tag completeness* had six tags its own search could never have found,
and *Observability archive* had nothing and will have nothing until October.

The masking defect is real and its cost is narrower than the count of blocked
rules implied. Recorded here rather than left standing, because the more
dramatic version is the one already written down.

### The health field had a reason to move, and was held

The 2026-08-25 snapshot is revised in place with the end-of-day state. Two of the
four grounds for `Degraded` closed during the day — the snapshot cadence lapse and
the outer-loop overdue on `/assess` — and cadence compliance reached 5/5. On the
format reference's own rule that arithmetic points at **Attention**.

It is held at **Degraded**, on evidence gathered after the arithmetic:

- **The investigative layer was not one degraded layer; it was largely unbuilt.**
  5 of 19 declared rules have any automation, 14 ran for the first time on
  2026-08-25, and 9 of those 14 produced findings. Three of the ten deterministic
  rules cannot report a failure as declared (#587).
- **A manual run is not a cadence.** It happened because someone typed a command
  once, and the scheduled job will fail again at *Release tag completeness*.
- **An open CVE surfaced from a rule that had never run** (#586). A habitat that
  finds that on its first sweep should not improve its health the same day.

Recording a refused upgrade is the point: this is the first time the health field
has had a reason to move and been held.

### Two morning claims falsified by the evening, corrected in place

Both corrections show the original and the correction rather than overwriting:

- *"No rule after step 5 has produced a result in 36 days"* — false, and
  generalised from the 2026-08-24 run alone. Per-step conclusions show 07-20
  failing at step 8 and 08-17 at step 9, both with steps 5–7 `success`. Five of
  six blocked at *Release tag completeness*. Falsified by assay 3 finding-3.
- *"Two auto-fix rules had work waiting"* — one did. Reflection archival had
  fifteen fragments; *Release tag completeness* had six tags its own search could
  never have created; *Observability archive* had nothing until October.

### Security — pymdown-extensions CVEs closed by relaxing the mkdocs-material pin

`pymdown-extensions` 10.21.3 carried two known advisories, and the fixed version
was unreachable at the old pin. See #586.

- **PYSEC-2026-3609** — path traversal in `pymdownx/b64.py::repl_path`. A `src`
  containing `../` or an absolute path escaped `base_path` with no containment
  check, base64-inlining any readable file with an image extension into rendered
  output.
- **PYSEC-2026-3654** — exponential-backtracking ReDoS (CWE-1333, proposed CVSS
  3.1 7.5 High) in four inline processors — `caret`, `tilde`, `betterem`,
  `magiclink` — all reachable in **default** configuration. Both `pages.yml` and
  `docs-build-check.yml` render this repository's Markdown through them, so on
  the PR gate the input was any Markdown file in a contributor's branch.

`pymdown-extensions` is transitive and unpinned; `mkdocs-material==9.5.42`
constrained it to `~=10.2`, so no update to the transitive package alone could
have reached the fix.

```diff
-mkdocs-material==9.5.42
+mkdocs-material==9.7.7
-mkdocs-redirects==1.2.2
+mkdocs-redirects==1.2.3
```

**Verified rather than assumed**, in a clean venv:

| Check | Before | After |
| --- | --- | --- |
| `pip-audit -r requirements.txt` | 2 vulnerabilities in 1 package | **No known vulnerabilities found** |
| resolved `pymdown-extensions` | 10.21.3 | **11.0.2** |
| `mkdocs build --strict` | exit 0, 312 pages | exit 0, 312 pages |

The two-minor jump in mkdocs-material changes the rendered output not at all —
identical page count, identical strict-build result. It does introduce one
non-fatal MkDocs 2 deprecation notice, which `--strict` does not treat as an
error and which is suppressible with `DISABLE_MKDOCS_2_WARNING=true` if it
becomes noise.

**How this was found is the part worth keeping.** *Dependency currency* is an
agent-enforced GC rule with no workflow step, declared since April and never
run. There is no `dependabot.yml` and no scheduled dependency scan. Both
advisories were published against a package this repository has been rendering
untrusted Markdown through on every pull request, and the first thing that ever
looked was a garbage-collection sweep someone ran by hand on 2026-08-25.

### Fixed — three garbage-collection tools that could not report a failure

`/harness-gc`'s first on-demand run found that three of the ten deterministic GC
rules were structurally incapable of failing. Not stale, not misconfigured —
counted among the active nineteen since April, running clean, examining nothing.
See #587.

**Release tag completeness** used `grep -oP`, a GNU extension. Under
`/usr/bin/grep` on macOS it prints usage, extracts nothing, and **exits 0** — the
loop body never runs and the rule reports a clean bill. Replaced with a POSIX
`sed -n` extraction. Verified under `PATH=/usr/bin:/bin`: the old form extracts
**0** version headings, the new one extracts **118**, and against a fixture
carrying an untagged version the new form reports `MISSING: v9.9.9` where the old
form reports nothing.

This was the third recurrence of the BSD/GNU pattern, landing outside the fence
built for it — *Layer 0 bash tests run on macOS and Linux* scopes to Layer 0 bash
scripts, not to rule tools declared inline in `HARNESS.md`.

**Objection record freshness** referenced an unbound `$f` with no enclosing loop.
Run verbatim, `$f` expanded empty, the `-newer` operand became
`docs/superpowers/objections/.md`, `find` errored into suppressed stderr, and
`grep .` matched nothing — `rc=1`, always, regardless of state. Replaced with a
loop that binds its variable and compares **git commit dates** rather than
filesystem mtimes, which are identical on a fresh clone and would have made the
comparison meaningless in CI. It now reports 12 records.

**Docs-site strict-build sweep** declared `mkdocs build --strict`, and `mkdocs` is
not on the ambient PATH — a bare `/harness-gc` got a shell "command not found"
rather than a result. The tool now checks for the binary first and fails with a
named reason and a remedy. Absence of the tool reads as failure, not as silence.

### Repair, not a rule change

**What it checks**, **Enforcement**, **Frequency** and **Auto-fix** are byte-identical
for all three. Only the Tool implementation moved, and in every case because the
declared implementation could not execute. This is treated as repair rather than
a governed change on the grounds that the harness evolution loop exists to
restrain rules *entering force*, not to gate a portability bug in an existing
rule's implementation.

### Known limitation, deliberately not fixed here

*Objection record freshness* now reports 12 stale records, and most are
metadata-only post-merge edits rather than design changes — seven are
cadence-sentinels specs all last touched by `1133b9c` (#518), a provenance fix.
The rule as declared compares timestamps and has no discriminator for "design
content changed". Adding one would change what the rule checks, which is a
governed decision rather than a repair, so the over-firing is recorded and left.
Four objection records also have no date-prefixed spec and the rule is silent on
them by construction.

### Fixed — step masking, in both workflows; and the rule about it declined

The defect assay 2 finding-2 named is repaired. Every enforcing step now produces
an outcome instead of being discarded behind an earlier failure, and each job
derives its conclusion from the collected results.

- **`gc.yml`** — eleven GC steps under `if: ${{ !cancelled() }}`, not `always()`.
  That distinction is objection **O6**, accepted: the job holds `contents: write`
  and five steps that commit and push, and `always()` runs on cancellation.
- **`harness.yml`** — eight constraint steps under `if: always()`. The job is
  read-only, so cancellation is not a hazard. These are the steps that mattered
  most: on runs `32836457544` (#552) and `32839441437` (#561) a ShellCheck failure
  skipped the two governance validators on the very PRs rewriting them.
- **Three-state aggregation in both.** The summary fails the job when any step
  failed, and *separately* when any step did not run. Objection **O5**, accepted,
  said `if: always()` yields two values where the rule demanded three — and the
  first draft of this fix proved it, printing a skipped step in its list and then
  reporting "all constraints reported a result". A check that did not run is now
  reported as not run and fails the job.

Verified by substituting outcomes into the aggregation and running it: all-success
exits 0, one failure exits 1 naming the constraint, one skipped exits 1 with "a
check that did not run is not a check that passed".

### And the rule declined, deliberately

`HDR-2026-08-25-workflow-step-masking-declined` — `rejected`.

Repairing the defect closed the rule's only route to acceptance. It is
`harness-loop`, holds one countable assay against a threshold of two, and the
second could only have come from a fourth assay observing the masking **still
present**.

The alternative was to leave a known defect standing so an assay could corroborate
a rule about it. That is the incentive objection **O2** of
`harness-reassuring-default.md` named this morning — "the cheapest way to promote
any future finding becomes observe a defect, do not fix it, observe it again next
cycle" — arriving live on a different record four hours later.

Precedent: assay 1 finding-1, declined on evidence while its defect was fixed
anyway. That assay's own words: "the transcription fix travelled and the rule did
not need to."

**The cost is stated in the record and is not zero:** there is no regression
guard. Nothing prevents a future workflow adding an unguarded enforcing step, and
nothing notices if someone removes the aggregation. The repair rests on two files
and on whoever edits them next reading why the comments are there.

### The enforcement figure is now honest: 35/36 → 30/36

Ten constraints were declared `Enforcement: agent` with `Tool: harness-enforcer`,
and `grep -rn 'harness-enforcer' .github/workflows/` returns nothing. They have
been unable to fire since April, while the Status block counted them as enforced.

The ten did not decompose into one decision:

- **Two were never part of the problem.** *Specs cite the source of a claimed
  convention* names `advocatus-diaboli`, a different dispatch path. *Label PRs at
  creation time* is `scope: manual` and was never a PR gate.
- **One was mechanical all along.** *All frontmatter has name and description*
  parses YAML and looks for two keys. **Promoted to `deterministic`** with
  `scripts/check-component-frontmatter.py`, wired into `harness.yml` behind
  `if: always()` and reporting into the new aggregation. 103 files checked, 0
  failures; verified against a fixture that it reports and exits 1.
- **Five genuinely need judgement** — *Spec-scoped changes*, *Spec captures
  intent*, *Output validation checkpoints*, *Docs site kept current*, *Docs
  propagation when shipping new commands*. **Demoted to `unverified`**, with the
  Tool field recording why: declared `agent` from April to 2026-08-25 while no
  workflow dispatched the agent.

Wiring an enforcer for those five would cost **$1.30–$47.00/month** depending on
PR volume — the same band as the TDAD Layer 2/3 run declined earlier the same day
on cost grounds, and more volatile because it scales with pull requests rather
than being a fixed weekly job.

```text
before   25 deterministic + 10 agent + 1 unverified   enforced 35/36
after    26 deterministic +  4 agent + 6 unverified   enforced 30/36
```

**The number fell by five and became true.** Every one of the 30 can now fire.

### The mirrors were stale in a way the parity gate cannot see

`/convention-sync`'s parity check verifies that every constraint heading appears
in all three generated mirrors, and that enumerated values are covered. It does
**not** compare the `Enforcement` value. So all three mirrors carried
`Enforcement: agent` for constraints that had just been demoted, and both parity
checks passed.

Regenerated by hand in this PR. The Copilot mirror uses an inline prose form —
`Enforcement: agent (harness-enforcer). Scope: pr.` — rather than the bullet form
the other two use, which is why the first pass silently updated two of three
files and reported success. Worth its own look: a sync gate that cannot see a
changed value is the third instance today of a check answering an easier question
than its name.

### Deferred, deliberately

*PRs have adjudicated objections* and *PRs have adjudicated choice stories* stay
`agent`. Their schema half is mechanical — a record exists, and no disposition is
`pending` — and a check for it was written and verified during this work. It was
**not shipped**, because it fails immediately:
`docs/superpowers/objections/harness-provenance-citation.md` carries 12 of 12
dispositions pending, and two merged specs cite it as their evidence base.

That is the constraint working, and merging a knowingly-red gate is how a red
check becomes normal. The adjudication comes first; the promotion follows it.

## 0.86.2 — 2026-08-25

### Added — /harness-audit now validates the Status block it writes

`/harness-audit` writes `HARNESS.md`'s `## Status` section — structured output
with three downstream parsers (`/harness-status`, `harness-auditor` on its next
run, `harness-gc`) — and had no read-back step. It was the one command missing
from CLAUDE.md's checkpoint list, and its own constraint *Output validation
checkpoints* was failing because of it.

The cost was measurable rather than theoretical: the block sat reading
`Last audit: 2026-08-13`, `Constraints enforced: 33/34`, `Drift detected: no`
for twelve days, against a tree with 36 active constraints and four failing.
An audit that records "no drift" while drift exists is worse than one that
never ran, because the next reader stops looking.

- **Step 5 is a mandatory validation checkpoint.** Five assertions: the four
  fields present and ordered, `Last audit` is today, `Constraints enforced`
  counted from the tree rather than carried forward, `Drift detected: yes`
  whenever the enforcer reported a failure, and the enforcement figure
  qualified wherever agent-enforced constraints have no dispatch path.
- **The enforcer results win any disagreement.** They were observed; the Status
  block is a summary of them.
- **Fix in place, do not re-dispatch.** A second opinion on a number you can
  count yourself is slower and no more reliable.
- `/harness-audit` added to CLAUDE.md's checkpoint list, where its absence is
  why the omission went unnoticed rather than being a regression.

### The third assay, and the first rule proposed at the loop layer

`/harness-assay` over the audit-and-health wave (#574, #572, #571, #576, #577).
Four findings — two proposing rules, two `no-change` — seven rejected
candidates, five unresolved questions. `lint-assay` passes; S1–S6 checked by
hand.

- **`harness/assay/2026-08-25T14-31Z-assay.md`** — its headline finding is that
  four separate mechanisms in this repository report the reassuring answer when
  they cannot determine the real one, and the principle forbidding it is
  written down exactly once, in a code comment added yesterday. The four: the
  health badge's `Healthy` default (#575), the `## Status` block's
  `Drift detected: no` against four failing constraints, a GC step that did not
  run being recorded `skipped`, and *Release tag completeness* passing 110 of
  117 versions because a same-named tag happens to exist.
- **`HDR-2026-08-25-four-mechanisms-report-the-reassuring-answer-when-they-cannot-determine-the-real-one`**
  — proposed, `harness-loop`, advisory across all five surfaces. The first
  record to reach the loop layer, and the first to satisfy the two-assay
  promotion threshold: its evidence cites assay 2's finding-2 and assay 3's
  finding-1, two distinct assay files. Assay 1's finding-2 observed the same
  masking instance and is **deliberately not cited**, because it carries an
  erratum and a corrected finding does not corroborate.
- **Four tier-2 sections and the cost are placeholders.** They are the
  approver's to write, at the gate, and `precheck` refuses acceptance until
  they are.

### Corrected — a claim in the 2026-08-25 snapshot, and in #573

The snapshot states the GC job "failed on every run since 2026-07-20 … so no
rule after step 5 has produced a result in 36 days". Assay 3 finding-3 falsifies
it against per-step conclusions this repository could have read at the time: on
run `29739302793` steps 6 and 7 are `success` with the failure at step 8, and on
`32015897112` steps 6–8 are `success` with the failure at step 9. Only the
2026-08-24 run failed at step 5.

The consequence is not cosmetic. Five of the six runs blocked at *Release tag
completeness*, so refreshing the snapshot returns the next scheduled run to that
step rather than clearing the path. *Reflection log archival (Path 1)* stays
masked, the fifteen archivable fragments stay unarchived, and #573's closing
claim that "the two auto-fix rules can run again on the next scheduled sweep" is
wrong. The generalisation was made from a single run's conclusions without
reading the other five — the same shape as the finding proposed above.

### Adversarial review of the first loop-layer proposal

`/diaboli` on `harness/assay/2026-08-25T14-31Z-assay.md#finding-1`, the
reassuring-default finding proposed as
`HDR-2026-08-25-four-mechanisms-report-the-reassuring-answer-when-they-cannot-determine-the-real-one`.

**Twelve objections, five critical** — more criticals than either prior review,
evenly spread across all six categories. The reviewer explicitly does not
dispute that the behaviour happened; it disputes that the four instances are
four instances of one pattern, that the corroboration is two incidents, that
`HARNESS.md` is the layer, and that the rule as drafted would have caught any
of it.

The two objections most likely to decide the disposition:

- **O2** — the two-assay threshold is satisfied by re-observing one *unrepaired*
  artifact twelve hours later. The validator counts filenames and cannot ask
  whether the second sighting was a second event. If accepted on this basis, the
  cheapest route to `HARNESS.md` becomes: observe a defect, do not fix it,
  observe it again next cycle. Three of the finding's four instances were
  repaired within four hours and are therefore threshold-ineligible; the one
  nobody fixed is the one carrying the record.
- **O1** — the rule's two sentences cover three instances and the fourth not at
  all, and the uncovered one is the only instance appearing in a second assay.
  The four-instance pattern and the two-assay corroboration rest on disjoint
  evidence.

### Two critical objections checked and found wrong

Dispositions belong to the approver and the record is written verbatim, but two
of the five criticals were verified mechanically and do not hold:

- **O4** claims the repaired `update-health-badge.sh` still reaches `Healthy`
  when it cannot read a snapshot's `- Health:` line. It does not. Under
  `set -euo pipefail` the assignment `health_line=$(… | grep …)` fails when grep
  matches nothing, so the script exits 1 before the `*)` fallback. Verified: on a
  snapshot with no `Health:` line the badge is left untouched and the exit code
  is 1. The `*)` branch is unreachable dead code. A real adjacent defect does
  exist — a silent non-zero exit leaving a stale badge — but it is not the
  defect O4 describes.
- **O11** claims a `harness-loop` rule "can be accepted" with `_TODO` tier-2
  sections. `/harness-accept` runs `precheck`, which refuses them by name.
  What O11 gets right is narrower and still worth knowing: the *corpus*
  validator passes placeholder text, so `/harness-check` reports OK on a corpus
  containing an unfinished proposal.

Both are recorded as raised rather than silently corrected. The disposition
mechanism exists for exactly this, and an agent editing an adversarial reviewer's
objections would defeat the gate.

### The approver's calls on all thirty-five objections

Dispositions recorded across the three objection records. No objection remains
`pending`.

| Record | accepted | rejected | deferred |
| --- | --- | --- | --- |
| `command-cli-parity` | 7 | 3 | 2 |
| `harness-workflow-step-masking` | 4 | 3 | 4 |
| `harness-reassuring-default` | 11 | 1 | 0 |

**Every `disposition_rationale` is still `null`.** The calls are recorded; the
reasons are not. That distinction matters more here than the schema suggests —
*PRs have adjudicated objections* states in its own text that "'Resolved' is a
judgment call on rationale quality, not a schema check", so the only mechanical
proxy for adjudication is the count of non-`pending` values, and that count is
now zero on all three records. A record can therefore read as fully adjudicated
while carrying no reasoning at all.

The rationale field was left `null` rather than filled with a placeholder for
exactly that reason: a `TODO` string is content, and content in a field nothing
checks is the shape objection O11 of the reassuring-default record objects to.

### The two outstanding assay-2 findings are now proposed records

`/harness-propose` on `harness/assay/2026-08-25T11-59Z-assay.md` findings 1 and 2,
which had objection records but had never been drafted into the corpus.

- **`HDR-2026-08-25-command-cli-parity`** — `script-validator`, routed to
  `HARNESS.md`, naming no target.
- **`HDR-2026-08-25-workflow-step-masking`** — `script-validator`, same routing.
  This is the re-proposal the retirement record deferred: "Re-propose immediately
  with `HARNESS.md` as the target. Deferred, not rejected." The route now carries
  the target, so the deadlock that retired the original does not recur.

The corpus holds six records — three historical, three `proposed` — and
`/harness-check` reports OK.

All three proposals fail `precheck` on exactly one thing, and it is the same
thing for each: the four tier-2 sections are placeholders. Nothing else stands
in the way — routing resolves, the two-assay threshold is satisfied where it
applies, and the cycle cap is not reached.

Those sections, the 35 objection dispositions across the three records, and the
cost at the gate are the approver's work and no agent's. They are listed rather
than drafted.

### Rationales written for all thirty-five objections

Every disposition now carries the approver's reasoning in their own words,
transcribed rather than drafted. Three dispositions changed during the pass as
the reasoning was worked through, which is the gate doing its job rather than a
correction to it.

| Record | accepted | rejected | deferred |
| --- | --- | --- | --- |
| `command-cli-parity` | 7 | 3 | 2 |
| `harness-workflow-step-masking` | 11 | 0 | 0 |
| `harness-reassuring-default` | 11 | 0 | 1 |

**What moved.** `reassuring-default` O2 went from rejected to deferred: the
approver holds that the second sighting is a verification observation and that
the precedent the objection warns about is "right but acceptable", but is not
sure that corroboration drawn from the one instance the rule text does not
cover should count at all. That record does not go to the gate until the
question is answered. On `workflow-step-masking`, O1 and O4 went from rejected
to accepted — "I stand corrected" on the first — and O8 through O11 from
deferred to accepted.

**Two consequences worth stating plainly.**

`workflow-step-masking` now concedes all eleven objections, including that it
re-proposes a scope already rejected in writing. Its O3 rationale commits the
redraft to reclassifying from `script-validator` to `harness-loop`, which takes
the two-assay threshold with it. That reclassification makes the record
**unacceptable as it stands**: its evidence cites two assays, but assay 1's
finding-2 carries an erratum and a corrected finding does not corroborate, so
one countable assay remains against a threshold of two. Choosing the honest
classification costs the record its acceptance until another assay observes the
behaviour.

`command-cli-parity` survives. O9 is accepted — an existing constraint owns the
behaviour and was never dispatched — while the objection's own reading, that
accepting it turns the finding into a rejected candidate, is explicitly not
taken: running the audit and writing the check are not alternatives.

### Tier-2 sections written; two records reach the gate, one is refused by it

All twelve tier-2 sections written across the three proposals, in minimal form.
Eight were assembled from dispositions the approver had already made; four were
open and are now answered.

**Validation, on all three, says the same thing and says it plainly:** nothing
will tell us whether the rule helped. There is no measurement separating a
repository where it worked from one where it was ignored, and each drafted plan
named a criterion nobody could evaluate. All three stay `provisional`, expiring
2026-11-23, and the review at expiry is a judgement rather than a reading.

**`reassuring-default` is reclassified `harness-loop` → `agent-instruction`,**
targeting `ai-literacy-superpowers/skills/advocatus-diaboli/SKILL.md`. The
assay's reason for the loop layer was reach, and objection O3 established that
reason does not hold — `HARNESS.md` is the declared target of no surface in the
matrix. The rule's enforcement is a question an agent asks at a review gate, so
it belongs in that agent's instructions, where it is loaded on every `/diaboli`
run rather than read when someone types `/harness-audit` once a quarter. The
two-assay threshold does not apply at this classification, so the corroboration
question deferred at O2 no longer gates the record; it stays genuinely unsettled
and is recorded there rather than resolved by the move.

**`workflow-step-masking` is reclassified `script-validator` → `harness-loop`,
and the gate now refuses it.** That is the intended outcome of accepting O3,
not an accident:

```text
FAIL: a harness-loop change requires evidence from at least two distinct
      assays, found 1. Either wait for a second assay to corroborate, or
      reclassify to the layer that owns the behaviour.
```

Its evidence cites two assays, but assay 1's finding-2 carries an erratum and a
corrected finding does not corroborate. Choosing the classification that owns
the behaviour cost the record its acceptance, which is the threshold working
rather than obstructing.

**Gate status:** `command-cli-parity` and `reassuring-default` pass `precheck`
with no refusal standing. `workflow-step-masking` is refused until another assay
observes the masking behaviour independently. What remains for the two that pass
is the cost, written by the approver at the gate.

## 0.86.1 — 2026-08-25

### Fixed — the health badge defaulted to green when it could not tell

`update-health-badge.sh` reads the snapshot path from `$2`, and its entire
detection block sits behind a check that the argument was supplied. Line 22
initialised `health_status="Healthy"`. Called with no argument it skipped every
line that reads a snapshot and wrote that hardcoded green straight to the
badge. See #575.

`/harness-health` **step 8 documented exactly that call**, so the documented way
to run the command always produced a green badge. Observed on 2026-08-25: an
argument-less run wrote `Healthy` over a snapshot whose Meta section reads
`Health: **Degraded**`, and repointed the link from the snapshot to the
directory.

Every safety net in the script — the sub-70% enforcement override, the signal
heuristic, the explicit `Health:` line reader — lived inside the branch that
never ran.

- **The argument-less path now discovers the latest snapshot**, using the same
  `sort -r | head -1` idiom `gc.yml` uses for its own staleness check. The
  documented invocation becomes correct rather than merely tolerated.
- **The default is Degraded.** Healthy is now reachable only from a snapshot
  that was actually read — either an explicit `Health:` line or a snapshot with
  no attention signals. When the script cannot tell, it says so.
- **The link target is normalised** to a repo-relative path. Discovery runs
  `find "$PROJECT_DIR"`, so `.` yielded `./observability/…` and an absolute
  project dir yielded an absolute path; neither belongs in a README link.
- **Layer 0 coverage for the path that had none.** `test-update-health-badge.sh`
  exercised the detection logic thoroughly and every case passed a snapshot
  file — the documented invocation was untested. Four new assertions: an
  argument-less run over a Degraded snapshot reports Degraded (this fails on
  the old code), the discovered link is repo-relative, discovery picks the
  newest snapshot, and no snapshots at all is Degraded rather than Healthy.
- **Step 8 now passes the snapshot path explicitly** and says why: you know
  which file you just wrote, discovery only infers it.

### Why a default matters more than it looks

This is the same shape as the GC masking defect recorded in 0.86.0's snapshot
refresh: when the mechanism cannot determine an answer, it reported the one
that looks best. A green badge meaning "nobody passed an argument" is worse
than no badge, because it is read as a measurement. The fix is not the
discovery — it is that absence of evidence now resolves to Degraded.

## 0.86.0 — 2026-08-25

### Fixed — the target can now be set where the reference always said it was

`harness-decision-records.md` has always described `target` as binding at
acceptance, "because the Assayer frequently identifies a behaviour without
knowing which of four agent files should own it. That is the human's decision,
made at the gate beside the cost."

The code fixed it at proposal, copied verbatim from an append-only assay, and
`/harness-accept` had no way to set one. **The documented workflow was therefore
impossible**: a finding naming no target proposed cleanly and could never be
accepted, with no exit but a new assay finding or supersession. See #557.

- **`/harness-accept --target <path>`** supplies the artifact that will host the
  rule.
- **Three refusals keep it narrow.** A routed classification refuses `--target`,
  because `target_of` prefers the route and the value would be silently ignored —
  and silently discarding what someone typed is what #551 was about. The target
  must be able to hold the rule (the `.md` check from 0.80.0, reused), and it
  must exist.
- **Provenance is recorded.** Where the assay named a target and the approver
  overrides it, the Assayer's value is preserved as `proposed_target`. Third
  application of the `proposed_cost` / `cost` pattern: two people contributed to
  one record and a reader should be able to tell which part came from whom.
- **Layer 0 suite** `test-target-at-the-gate.sh` (T1–T9), hashing the corpus
  across every refusal.

### The objection, recorded rather than dismissed

Letting the approver retarget at the gate lets a rule be moved to wherever it
applies cleanly, which is a cousin of reclassifying to clear a threshold. It is a
weaker cousin: reclassification changes the evidentiary bar a rule must clear,
which is what the two-assay threshold turns on, while retargeting only changes
which prose document hosts the text — and since 0.80.0 that must be markdown, so
every option is a governance artifact. `proposed_target` makes the move visible.

### Note on the ticket's preferred option

The ticket leaned toward `--target` on `/harness-propose`. Rejected after testing the
documented flow: if the Assayer cannot know which of four agent files owns a
behaviour, neither can whoever drafts the record thirty seconds later. The person
who can decide is the one reading the rule beside its cost, which is what the
reference said all along.

### The second assay, and the first adversarial review of an assay's own findings

The harness-evolution fix wave closed at `b1982b0`, and the loop's next step ran:
`/harness-assay` over the window, then `/diaboli` on each substantive finding.

- **`harness/assay/2026-08-25T11-59Z-assay.md`** — three findings, two at P1, seven
  rejected candidates, five unresolved questions. Its headline: the code moved eight
  times across the wave and the prose that tells an agent how to drive it moved zero
  times.
- **Two objection records**, one per substantive finding — `command-cli-parity.md`
  (12 objections, 2 critical) and `harness-workflow-step-masking.md` (11 objections,
  3 critical). Both follow the per-finding shape set by `harness-provenance-citation.md`
  rather than one record per assay.
- **Every disposition is `pending`.** That is the gate working, not an omission: the
  human-cognition gate is the point of the record, and 5 of the 23 objections argue
  their finding should not be proposed at all.

Two objections are worth a reader's attention before the gate. `harness-workflow-step-masking`
O1 shows the finding re-proposes the narrow scope the approver rejected in writing eight
hours earlier, in the record it cites as its own precedent. O3 shows the two-assay
promotion threshold is keyed on `harness-loop` alone, so a `script-validator` routed to
`HARNESS.md` since #552 reaches that document on one assay's evidence — the threshold
now guards a classification name rather than the document it was written to protect.
O3 stands whatever is decided about the finding that surfaced it.

### /harness-audit run — the Status block now says what is true

The Status block read `Last audit: 2026-08-13`, `Constraints enforced: 33/34`,
`Drift detected: no`. The tree carries 36 active constraints and four failing.

- **Four constraints fail.** *Release traceability* — `v0.28.1`–`v0.28.5` and
  `v0.29.1` carry CHANGELOG headings and no git tag, absent locally and on the
  remote while `v0.28.0` and `v0.29.0` exist. *Output validation checkpoints* —
  `/harness-audit` writes the Status block, which has three downstream parsers,
  with no read-back step. *PRs have adjudicated objections* and *PRs have
  adjudicated choice stories* — 6 of 6 non-exempt PRs in the window, twelve and
  six missing records respectively.
- **The enforcement figure is qualified rather than quietly redefined.** It moves
  33/34 → 35/36 on its existing definition, so it stays comparable, and the block
  now states plainly why the number overstates what is in force:
  `grep -rn 'harness-enforcer' .github/workflows/` returns nothing, so all ten
  agent-enforced constraints have no automated path and cannot fail a build. A
  green Status line has meant "nobody looked".
- **One masking defect with a measured cost.** GC run `32712709028` failed at step
  5 (*Snapshot staleness*) and recorded steps 6–14 `skipped`, including *Release
  tag completeness* and *Reflection log archival (Path 1)* — the two auto-fix
  rules that would have closed the tag gap and the archival backlog. Six
  consecutive scheduled runs have failed the same way since 2026-07-20. The six
  untagged releases and the fifteen unarchived fragments are the same defect's
  bill.
- **Enforcement-surface drift, both directions.** Two active `Scope: pr`
  constraints name `harness-affordance-check.sh` and no workflow invokes it;
  inversely, GC rule *Affordance review staleness* runs at `gc.yml:258` while its
  declaring block sits inside an HTML comment. `dynamic-workflows-firewall.yml`
  runs on every PR under no declared constraint at all.
- **Two stale claims in HARNESS.md are now recorded.** `### Stack` says "Test
  framework: None" against a 150-test pytest suite gated by three constraints, and
  the markdownlint rule's "same set locally and in CI" claim is false — 511
  files/91 issues locally against CI's 502/0, all in gitignored paths absent from
  `.markdownlint-cli2.jsonc`. Committed markdown is genuinely clean; the
  equivalence claim is not.

The audit changed the Status block and the README badge and nothing else. The
remediation it argues for is separate work, deliberately not bundled here.

### Observability snapshot refreshed — and the badge script's green default

The snapshot was 35 days stale against a 30-day cadence. It is also step 5 of
the GC job, so its failure had been skipping every rule after it for six
consecutive weeks — including the two `Auto-fix: true` rules that would have
closed the release-tag gap and the reflection archival backlog.

- **`observability/snapshots/2026-08-25-snapshot.md`** — full quick-mode
  snapshot, all 16 sections, generated straight after the `/harness-audit`
  run so the enforcement figures are observed rather than re-derived. Health:
  **Degraded**, on four grounds — the investigative loop has not completed a
  run in 36 days, the snapshot cadence had lapsed, four constraints fail, and
  `/assess` is 106 days overdue against a 90-day target.
- **Two GC findings recorded**, both discovered by the audit rather than by
  the GC job: six untagged releases and fifteen archivable reflection
  fragments.
- **The health badge now reads Degraded** and links to the new snapshot.

### Fixed — `update-health-badge` defaulted to a green badge

`update-health-badge.sh` reads the snapshot path from `$2`. Called with no
argument it skips the entire detection block and falls through to
`health_status="Healthy"`, hardcoded, and points the link at the snapshots
directory rather than a snapshot.

`/harness-health` step 8 documents exactly that argument-less invocation, so
**the documented way to run it always wrote a green badge** regardless of what
the snapshot said. Observed directly: the argument-less call wrote `Healthy`
over a snapshot whose Meta section reads `Health: **Degraded**`.

The script is not changed here — the defect is recorded and the badge written
correctly by passing the snapshot path. A default that fails toward the most
reassuring value is the same shape as the masking defect this snapshot
documents, and the fix belongs with its own evidence rather than bundled into
a snapshot refresh.

### Also recorded

The `Compound Learning` count basis is now stated in the snapshot. The format
reference says to count `GOTCHA:` and `ARCH_DECISION:` lines; neither string
exists in `AGENTS.md`, which uses `##` headings with top-level bullets. The
26 -> 22 delta against the previous snapshot is a change of counting basis,
not a removal of entries, and the reference is what needs correcting.

## 0.85.0 — 2026-08-25

### Fixed — a project's routing table merges with the defaults instead of replacing them

`effective_routes`' docstring said "defaults included" and the function returned
only the project's routes, so declaring one custom route silently dropped every
default — `harness-loop: HARNESS.md` included. The failure surfaced late, at
acceptance, on a record someone had already read, argued and costed, and the
cause was a line in `surfaces.yaml` that reads as additive. See #559.

It also meant a route shipped in a new plugin release could never reach a project
that had customised the file it lives in — the same shape as the template-currency
problem in #547. Adding `script-validator` to the defaults in 0.80.0 had no effect
on this repository until the route was written into `harness/surfaces.yaml` by
hand.

- **`routes:` now merges**: the plugin's defaults, overlaid with the project's.
  The docstring is true, and future defaults propagate.
- **A default is suppressed by mapping it to an empty value**, and a suppressed
  classification behaves as unrouted — the record names its own `target`, as it
  already must for classifications with no default.
- **The `surfaces.yaml` validator accepts an empty route value** as suppression
  rather than rejecting it as malformed.
- **Layer 0 suite** `test-routes-merge.sh` (M1–M7).

### Why suppression is not decoration

`target_of` prefers a route over any `target` a record names. So merging a
default back for a project that lacks its target artifact — `AGENTS.md`, say —
would leave records of that classification refused at compile **and impossible to
redirect**, because the route wins. Today such a project omits the route and names
targets explicitly; a merge without an escape hatch would take that away and offer
nothing in its place. M6 covers the case.

### Adopter impact

A project declaring a partial `routes:` block will find the omitted defaults back
in force. This is a fix rather than a change of mind — the documented contract was
always "defaults included", so those projects were getting behaviour that
contradicted the documentation. One blank line per route restores the old effect,
and the refusal that would otherwise appear names the classification.

This repository's routes resolve identically and its enforcement report is
byte-identical.

### Also corrected

The `surfaces.yaml` comment and the reference page added in 0.80.0 both stated
that a `routes:` block replaces the defaults. Both now describe merging. A comment
that contradicts behaviour is the defect this release exists to fix, one level up.

## 0.84.0 — 2026-08-25

### Added — assays can be corrected without being edited

Assays are append-only and never edited, correctly: they record what an agent
observed at a moment. But nothing carried a **correction**, so an error was
permanent, uncited, and propagated. See #556.

The first assay contains two confirmed errors, both load-bearing: finding-1 said
six specs carry a provenance line (four do), and finding-2 said `gc.yml` runs
nineteen declared GC rules (it carries eleven steps covering five). Both are now
corrected in `harness/assay/2026-08-25T08-08Z-assay.errata.md`, with the assay
byte-identical.

- **`correct --assay --finding --correction-file`** writes a sibling errata
  record. One section per corrected finding; a later correction appends rather
  than substitutes. Nothing edits either file.
- **`/harness-propose` refuses** on a corrected finding, quotes the correction,
  and proceeds only with `--acknowledge-correction`. Not a warning — a warning
  from a command that just succeeded is a warning nobody reads, and the record it
  produces is frozen. The record notes the acknowledgement.
- **The two-assay promotion threshold stops counting a corrected finding.** It
  exists so a single incident cannot reach the loop layer, and without this a
  falsified observation could be the second assay that lets a rule through.
  Corroboration by a finding that was wrong is not corroboration.
- **The exclusion is per finding, not per assay.** An assay may hold six findings
  and be wrong about one.
- **Layer 0 suite** `test-assay-corrections.sh` (E1–E7), fixtured on the two real
  errors. E3 hashes the assay before and after: "the record was not touched" is a
  measurable claim, and asserting it by reading the code is not.

### Deliberately not done

There is **no pointer inside the assay**. It cannot be added without editing the
record, and a mechanism that pressures anyone to edit an append-only document is
worse than the gap it closes. Discovery is met by a sibling with a predictable
name and by refusals at the two points where a correction changes what someone
should do. The trade is stated rather than the requirement quietly redefined.

## 0.83.1 — 2026-08-25

### Fixed — a propose no longer leaves the corpus failing its own check

`/harness-propose` wrote a record and returned. `harness/decisions/index.md` is
part of the compile plan and `render_index` lists every record, `proposed`
included, so the index went stale and `/harness-check` reported a build failure
until someone ran `/harness-compile`. `/harness-accept` was unaffected because it
runs the compile step inside its transaction. See #564.

That window is not brief. The gates are deliberately separate, and a proposal is
*supposed* to sit at `proposed` and carry forward when it does not win a slot —
the cycle cap assumes exactly that. So the CI entry point was red for the whole
normal mid-cycle state of a corpus, which is how people learn to ignore a red
check. This repository spent six weeks demonstrating that with the GC workflow.

The failure also misdirected: "Run `/harness-compile` to repair, or supersede the
decision if the change was intended" describes a hand-edited generated region.
Nothing had been hand-edited and there was nothing to supersede.

- **`propose` now regenerates the index** after a successful write, with and
  without `--reject`. There is no decision in regenerating an index — the same
  reason applying and compiling are not gates.
- **Only the index.** A proposed record reaches no artifact and is absent from the
  enforcement report, so nothing else moves. Asserted rather than assumed.
- **D10** in `test-declined-findings.sh` covers it, including that a plain propose
  and a `--reject` both leave `/harness-check` passing.

## 0.83.0 — 2026-08-25

### Added — a finding a human declines is now recorded

The corpus recorded what **entered** and had no way to record what a human
weighed and refused. During the first loop run, finding-1 of
`2026-08-25T08-08Z-assay.md` was read, adversarially reviewed and declined on
evidence, and nothing in the corpus shows it. See #555.

`rejected` was already a **storable** status that nothing produced — the schema
anticipated this outcome and no command reached it.

- **`/harness-propose --reject --reason-file <path>`** writes a record at
  `status: rejected`, carrying `## Finding` and a non-empty `## Rejection`.
- **Declining costs one section.** No `## Rule` (nothing enters force), no `cost`
  key (nothing is demanded, and an empty cost would imply an obligation that will
  never be met), no tier-2 sections (no layer is being argued for). Friction on
  the path we want people to take means the path is not taken.
- **The reason is supplied up front, never a placeholder.** A rejection has no
  later gate — it is written at `rejected` and never accepted — so a placeholder
  would either block the write, since `propose` validates before writing, or sit
  in the corpus permanently recording that someone said no and nothing about why.
  `--reason-file` is a file rather than an argument for the same reason
  `--cost-file` is.
- **It reaches no artifact, consumes no cycle slot, and stays out of
  `/harness-timeline`.** The `no-change` precedent argues the other way, but a
  `no-change` record is *accepted* and carries `approved_at`; a rejection was
  never in force. It is not an intervention of size zero — it is not an
  intervention. It appears in `harness/decisions/index.md` with state `rejected`.
- **The relaxation is keyed on status and does not leak.** An accepted record
  still requires `## Rule`, `## Cost` and its tier-2 sections; asserted directly,
  because a leak would let a rule enter force with no rule text and no cost.
- **Layer 0 suite** `test-declined-findings.sh` (D1–D9).

### The first declined finding is on the record

`HDR-2026-08-25-an-epic-s-authority-cited-to-a-document-nobody-else-can-open`
records the disposition of finding-1 from the first assay: proposed by the
Assayer as a `harness-loop` rule, adversarially reviewed, investigated against
the transcribed build spec, and declined by the approver.

The reason is the approver's, written in their own words and copied verbatim:

> My feeling was that the rule was pointed at the wrong problem.

Worth noting what the record contains, because it is the first artifact to
exercise two changes made today: the finding as observed, the Assayer's own
argument for the layer (carried by 0.81.0, which would previously have discarded
it), and the human's disposition. Read together they are the whole decision —
what was seen, what was argued, and what a person concluded.

The corpus now holds one rejection, one retirement and one superseded rule, and
nothing in force. That is an honest state rather than an embarrassing one: three
records of governance being examined, and no rule that survived the examination.

### Why it matters beyond tidiness

A later assay reads prior assays and will re-find the same class of problem.
Nothing told it a human had already considered and declined one, so it could not
distinguish a recurring problem from one already adjudicated — the distinction the
two-assay promotion threshold turns on. Corroboration by a finding that was
already refused is not corroboration.

## 0.82.0 — 2026-08-25

### Fixed — a validator must be shown to enforce the rule that claims it

`has_validator` tested that a named file exists, and nothing else. Existence is
the entire link between a written rule and the code enforcing it — `render_region`
only ever emits prose, so governance never edits code — and `achieved_for` gates
the top of the enforcement ladder on that one boolean. See #553.

Observed against this repository before the change: `validator: README.md`,
`CHANGELOG.md` and `.gitignore` all reported a rule as `validated`, and
`["docs/index.md", "nope/missing.py"]` passed because `any` accepted the doc while
the real checker was missing.

- **Every listed path must resolve.** `all`, not `any`.
- **Each must look runnable** — the executable bit, or a `.py`, `.sh`, `.bash`,
  `.js` or `.rb` suffix. A shape test to exclude documents, not a guarantee of
  executability.
- **At least one must name the record it enforces** — the HDR `id` in the file's
  text. A comment is enough. This is the condition that makes the claim
  falsifiable: a runnable, invoked script that checks something else is still not
  enforcement of *this* rule.
- **The report names the specific failure** instead of one collapsed string:
  `no validator declared`, `validator not found: <path>`,
  `validator is not runnable: <path>`, or `validator does not name <hdr-id>`.
  "Nobody declared one" and "one was declared and it is missing" are different
  failures with different remedies, and collapsing them was the same class of
  defect being fixed.
- **Existence is checked across every path before runnability**, so a missing
  validator is reported ahead of a present-but-unrunnable one.

**Invocation is deliberately not checked.** The obvious test — a reference from a
workflow — passes `README.md`, which two of this repository's workflows grep,
while wrongly downgrading a validator invoked from inside another script. A test
that passes the worst case and fails good ones is not worth having.

### Adopter impact

A record declaring a validator that does not name it drops from `validated` to
`advisory` on the next compile. That is a downgrade toward honesty — the report
stops claiming enforcement it cannot demonstrate — and the reason string says
exactly which condition failed. This repository's corpus declares no validators,
so its enforcement report is byte-identical.

- **Layer 0 suite** `test-validator-binding.sh` (V1–V7), fixtured directly on the
  #553 evidence table. V4 asserts a bound validator still reaches `validated`,
  because a check strict enough to reject everything would replace an
  over-claiming report with a useless one.
- `test-harness-compile.sh` C12b now asserts the absent path is *named* rather
  than matching the old collapsed message, and C13's fixture gained the one-line
  binding comment — which is what the new convention costs an adopter.

## 0.81.0 — 2026-08-25

### Fixed — the Assayer's reasoning reaches the record

`/harness-propose` took the observation as everything before the first fence
(`_parse_finding`), so the Assayer's "why this layer", overfitting assessment and
validation plan — which conventionally sit *after* the YAML metadata block — were
discarded. The record then arrived with four `_TODO` placeholders while a better
argument sat one directory away. Reconstructing those sections by hand is how an
error ("no enforcement gap", where the generated report said `gap`) got into a
record that is now accepted and frozen. See #554.

- **New optional `## Assayer's reasoning` section**, carrying that prose verbatim
  and labelled as the Assayer's. Extraction is positional — the text between the
  metadata block and the first `####` subsection — so it takes whatever was
  written there and makes no judgement about which paragraph matters.
- **It does not satisfy the tier-2 sections.** `## Why this layer`,
  `## Enforcement`, `## Validation` and `## Rejected alternatives` stay `_TODO`
  placeholders, and acceptance is still refused until a human writes them. The
  split mirrors `proposed_cost` and `cost` and exists for the same reason:
  pre-filled reasoning reads exactly like considered reasoning, and nothing
  downstream could tell them apart. Pre-filling those sections was considered and
  rejected as the cost-rule failure one section over.
- **Omitted entirely when a finding carries no such prose**, rather than emitted
  empty. An empty heading invites someone to fill it, and this one is not theirs.
- **`overfitting_risk` now reaches the HDR frontmatter** when the finding declares
  it. Not added to `FINDING_REQUIRED_KEYS` — making it mandatory changes the assay
  contract and deserves its own evidence.
- **`## Finding` and `## Rule` are unchanged.** The rule block is still
  byte-identical to the assay's four-backtick block, nested fences intact; that
  guarantee is asserted directly rather than assumed, because this change touches
  the same parser.
- **Layer 0 suite** `test-assayer-reasoning.sh` (R1–R9), fixtured on finding-2 of
  `2026-08-25T08-08Z-assay.md` — the finding the defect was found on.

## 0.80.0 — 2026-08-25

### Fixed — the harness evolution write path

Found by running the loop end to end for the first time (#548, PR #550), where
accepting a record whose `target` was `.github/workflows/gc.yml` appended a
markdown region to a YAML file and left the workflow unparseable. `/harness-check`
then reported `OK`. See #551 and
`docs/superpowers/specs/2026-08-25-harness-write-path-integrity-design.md`.

- **A target must be a markdown artifact.** Rule text is markdown and is applied
  verbatim, so the artifact that *hosts* a rule must be able to hold markdown. The
  artifact a rule is *about* goes in its `**Tool**` field. `/harness-accept`,
  `/harness-compile` and `/harness-check` all refuse a target that cannot hold the
  text, and the refusal names the target and directs the author to `**Tool**`.
- **Checked before routing.** A routed classification would otherwise silently
  ignore a target its author named, and quietly discarding what someone wrote is
  the failure shape this mechanism exists to refuse.
- **An allowlist, not a denylist.** A denylist answers "is this one of the types we
  thought of?", which is the question nobody had asked about `.yml`.
- **`script-validator` gains a fixed route to `HARNESS.md`.** A rule about a
  validator is still a rule about how work proceeds here, and its text is prose.
  The classification was previously unusable: its targets are code files by
  definition, and the compiler emits only markdown.
- **Superseded and retirement records stay exempt**, so an existing corpus that
  already resolved this by supersession — as this one did — still passes.
- **Layer 0 suite** `test-harness-write-path.sh` (W1–W8), covering the refusal at
  accept, compile and check, the routed case, the superseded exemption, and four
  file types beyond the one that failed. This is the coverage the original Phase 2
  acceptance criteria never had: both fixed routes were markdown, so no test ever
  pointed a record at another file type.

### Known limitation

A `routes:` block in `surfaces.yaml` **replaces** the defaults rather than merging
with them, despite `effective_routes`' docstring claiming otherwise. A project that
declares any custom route silently loses every default, including
`harness-loop: HARNESS.md`. Documented in the reference and left for its own
change rather than widened into this one.

## 0.79.0 — 2026-08-23

### Added

- **`/harness-timeline`** — emits the Observatory intervention feed to stdout,
  one JSON line per accepted decision record: when a rule entered, in which
  direction, at what enforcement level, on which cohort, and when it stopped.
  This is the timeline the difference-in-differences design otherwise has to
  infer. Completes the harness evolution epic (#533, #539).
- **Reference page** `intervention-feed-format.md`.
- **Layer-0 suite** `test-harness-timeline.sh` (T1–T13), mutation-tested against
  12 deliberately broken implementations.

### Changed from the source spec

Two additions to the example line, each because the example as given cannot
support the analysis the feed exists for.

- **No field depends on the current date.** Whether a rule is expired *right now*
  is a fact about the clock, not the corpus. A feed carrying it produces
  different output on different days from a repository nobody touched — a run in
  November would disagree with the same run in September about the same data. So
  `expires` is emitted as data for the consumer to interpret, `state` is limited
  to `in force` and `superseded`, and the command reads no clock at all.
- **Every intervention carries an end** — `superseded_by` and `ends`, giving the
  interval `[date, ends)`. The example records only when a rule started; without
  an end, every rule ever retired is still counted as in force, and the step
  function never steps back.

Also: `direction` is **derived** from the enforcement ladder and the surface
sets, never declared. A self-reported direction is a self-report, and this is the
one field the analysis turns on. And `no-change` records stay in the feed as
`direction: none` — an intervention of size zero. They record that governance was
examined at a known moment and deliberately not changed, which is a control
observation rather than an absence; dropping them would convert "we looked and
decided no" into "nobody looked".

### Documentation — harness evolution becomes the preferred path

- **New tutorial** `your-first-governance-change.md` — the Diataxis entry point
  for changing a harness rule the governed way.
- **The plugin landing page leads with the loop.** Seven pages added across
  S0–S5 were reachable through the filesystem-derived nav but linked from none
  of the curated index lists — they are now, and `harness-evolution.md` is
  promoted into the numbered first-principles sequence rather than buried in
  Deep dives. A new **Evolving the harness** how-to section sits above the
  lifecycle one.
- **Pages describing the older path now say where it fits.**
  `the-harness-tuning-loop.md` documented reflection → candidate →
  `/harness-constrain`, which is the unevidenced path; it now says so, keeps its
  capture and pattern-recognition stages, and points at the governed path for
  promotion. `self-improving-harness.md`, `the-harness-lifecycle.md`,
  `harness-engineering.md` and `how-to/add-a-constraint.md` carry the same
  pointer.
- **`/harness-constrain` is repositioned, not deprecated.** It authors the first
  draft of a harness that does not exist yet; the governed loop changes one that
  does, and grandfathering (`imported: true`) is the bridge between them.
- **README and CLAUDE.md** carry the loop and the four properties that make it
  hard to game.
- Fixed a stale count: `your-first-sentinels.md` said there were nine sentinels.
  The roster-parity check derives membership from `role: sentinel` frontmatter
  but does not read prose counts.

### Harness upgrade to the 0.79.0 template

- **Adopted the optional `## Stakeholders` block** into `HARNESS.md`, commented
  out as the template ships it. The Convener treats an absent section as
  not-an-error and flags every derived voice `inferred`; the block is now
  present as a prompt to fill in, and filling it in is what makes those voices
  `observed`.
- **Template-version marker bumped `0.73.2` → `0.79.0`**, clearing the
  `Template currency` GC rule.
- Worth recording for whoever runs the next upgrade: the shipped
  `templates/HARNESS.md` still carries its own `0.57.0` marker, so a version gap
  against the plugin does not imply new template content. Everything the harness
  evolution epic added arrived as commands, agents and skills. This repo's own
  harness leads the template by roughly forty items — including the three
  harness-evolution constraints (`Sentinel integrity`, `Harness decision records
  are well-formed`, `Harness governance is applied and undrifted`), which a
  project adopting 0.79.0 does not get from the template.

### The harness evolution loop, run for the first time

The loop was exercised end to end against this repository on 2026-08-25. What it
produced is committed here as the record, including the parts that went wrong.

- **First assay** — `harness/assay/2026-08-25T08-08Z-assay.md`. Three findings,
  five rejected candidates, four unresolved questions. Two of its factual claims
  are wrong and are corrected elsewhere in this commit rather than in the record,
  because assays are append-only.
- **Adversarial pass** — `docs/superpowers/objections/harness-provenance-citation.md`.
  Twelve objections on finding-1, four critical. Three were verified by hand
  before being acted on. Dispositions remain `pending`; finding-1 was resolved by
  evidence rather than by the gate.
- **The build spec is now in the repository** —
  `docs/superpowers/harness-evolution-build-spec.md`, with every claim the S0–S5
  specs make about it checked against it in
  `harness-evolution-build-spec-claims.md`. All four recorded deviations hold.
  The specs departed from their source honestly; what was missing was any way for
  a reader to confirm that.
- **One rule accepted and retired the same day.** `HDR-2026-08-25-the-periodic-
  check-suite-...` was accepted with a human-authored cost, applied to
  `.github/workflows/gc.yml`, and left the file invalid YAML — the compiler
  appends a markdown region to whatever artifact a record targets.
  `HDR-2026-08-25-retire-periodic-check-suite-runner` supersedes it. The
  Observatory feed records the pair as an intervention of zero duration.

### Defects this surfaced, none yet fixed

Recorded here so they are not rediscovered:

- `/harness-check` validates the corpus, not the artifacts it writes. It reported
  `OK` against a workflow file the acceptance had made unloadable.
- `script-validator` targets code files while the compiler emits only markdown,
  so the classification corrupts its target on acceptance. The fixed routes
  (`harness-loop`, `turn-instructions`) are both markdown, and nothing in the
  Phase 2 acceptance criteria exercises a non-markdown target.
- The cost rule refuses a cost identical to the **Assayer's** proposal and is
  blind to one supplied by an assistant in the same conversation.
- `target` is copied verbatim from an append-only assay and `/harness-accept` has
  no override, so a mis-targeted finding cannot be corrected through the loop.
- Assays have no supersession or errata path, and no CI validation.
- A finding a human declines leaves no trace in the corpus.
- `/harness-propose` drops the finding's reasoning: the Assayer's "why this
  layer", overfitting note and validation plan sit after the metadata fence and
  are not carried into the record.

### Note on the cohort tag

`cohort` remains on the decision record, per the epic's resolution of the source
spec's §14 Q4. Worth naming: a cohort tag on a governance artifact is visible to
whoever writes the next rule, which is a route by which a study can influence the
thing it studies. If that matters, the field can be dropped from the record and
joined externally at analysis time with no change to this command — it emits
`null` and the join happens downstream.

## 0.78.0 — 2026-08-23

### Added

- **`/harness-review`** — lists every lapsed rule and the three things a human
  can do about each: re-evidence, weaken, demote. Read-only; every outcome
  produces a **new superseding record** through `/harness-accept`, because every
  outcome is a decision with a cost that a human writes (#533, #538).
- **Expiry enforcement in `/harness-check`.** A rule past its `expires` date and
  still in force is a build failure, so retiring a rule is never contingent on
  anyone remembering to reflect.
- **Evidence resolution.** An evidence reference naming a repository path that no
  longer exists fails. A reference carrying a URI scheme is **named as skipped**,
  never passed in silence — failing it would demand the check resolve things it
  has no access to, and passing it quietly would let any unresolvable evidence be
  laundered by prefixing a scheme.
- **Supersession chain validation** — `supersedes` naming a missing record,
  itself, or one already superseded by a different record.
- **Retirements.** A record withdrawing a rule says `Withdrawn.` where the rule
  text would be, mirroring `no-change`, and must name a non-null `supersedes`.

### Changed

- **`superseded` and `expired` are derived, never stored.** Only `proposed`,
  `accepted` and `rejected` may be written, and `superseded_by` must be `null`.
  S2 froze accepted records and checks them against git, so writing
  `superseded_by` onto the record being superseded would be an edit to a frozen
  record — the two mechanisms would have contradicted each other on the first
  demotion anyone performed. Rather than carve an exception into the one check
  that guarantees accepted rules are not quietly reworded, the derivable fact is
  not stored. Same discipline `record-paths.sh` already uses.
- **A `harness-loop` retirement is exempt from the two-assay threshold.** That
  threshold exists to make rules hard to *add*; applying it to removal would mean
  a rule that turned out to be wrong needed two assays' evidence before anyone
  could withdraw it, and would stay in force meanwhile.
- **The cycle cap counts live records.** Superseding one frees its slot: the cap
  limits how much governance an assay adds, and a retired rule adds nothing.
- `provisional: false` alongside an `expires` date is now refused as a
  contradiction — a rule not on trial has no trial date.

### Fixed

- **Compilation left a retired rule sitting in its target artifact.** When the
  last live record routed to a file was superseded, that target dropped out of
  the compilation plan entirely and its region was never regenerated. Any
  artifact the corpus has ever written to, which still carries a region, is now
  regenerated — with an empty region when nothing routes there any more.
  Withdrawing the last rule from a file has to actually remove it.
- The S2 test fixture cited assay files it never created, which the new evidence
  check correctly refused. The fixture was completed rather than the check
  weakened.

### Known limitation

A `review_trigger` is free text and nothing can evaluate it mechanically, so a
rule carrying a trigger and no `expires` never lapses, never fails
`/harness-check`, and is permanent by construction — which is the opposite of
permanence being earned at review. `/harness-review` lists such records in their
own section, **Triggers nothing can evaluate**, with their age, and says plainly
that they will not lapse on their own. Closing the gap properly means requiring
`expires` always and treating `review_trigger` as an additional, earlier prompt
rather than a substitute; that is a change to the design's intent and is left to
its author rather than slipped in by an implementation slice.

## 0.77.0 — 2026-08-23

### Added

- **`harness-assayer` agent** — the read-only postmortem a governance change is
  built from. `role: sentinel`, so `sentinel-integrity-check.sh` mechanically
  enforces its read-only trust boundary. Reads evidence at a phase boundary,
  reconstructs the intended workflow and what actually happened, classifies
  material findings by ownership, and returns a bounded proposal for a human to
  dispose (#533, #537).
- **`/harness-assay`** — runs the Assayer and persists the report to
  `harness/assay/<ISO8601>-assay.md`. Invoked explicitly; the agent never
  self-triggers and never runs mid-phase.
- **`harness-assay` skill** — the materiality test, the evidence pool and its
  honesty flags, the report's six sections, and the anti-patterns.
- **`harness-registrar.py lint-assay`** — checks every finding in an assay
  against the S1 contract and reports **all** malformed findings in one pass.
  Deliberately not a CI gate: an assay is an append-only record of what an agent
  observed at a moment, and failing the build retroactively over one malformed
  block would pressure someone to edit a record.
- **Forward-test fixture** at
  `tdad_tests/layer0_deterministic/fixtures/assay_seed/` — two variants of a
  small repository, one carrying a seeded defect (an integration suite planned
  twice and never run, with both phases reported complete) and one with the
  defect removed. The negative variant is the half that matters: a forward test
  that only checks the agent finds the planted thing rewards a confident guesser.
- **Explanation page** `harness-evolution.md`, **how-to** `assay-a-phase.md`, and
  reference entries for the agent, command and skill.
- **Layer-0 suite** `test-harness-assay.sh` (A5–A8), mutation-tested against 9
  deliberately broken implementations.

### Changed

- **The Assayer returns its report as a string; the command persists it.** The
  source spec declares the Assayer a sentinel and then instructs it to write its
  own report. Those cannot both hold: criterion S1 is a read-only trust boundary,
  `sentinel-integrity-check.sh` fails CI on a sentinel granted `Write`, and
  frontmatter tools are all-or-nothing — so an Assayer that could write to
  `harness/assay/` could rewrite `HARNESS.md`. This follows the `cost-estimator`
  and `coda` precedent already established twice in this plugin.
- **The anti-proliferation rule is turned on the Assayer itself.** The plugin
  already has `/harness-audit`, `/governance-audit` and `/reflect`, which read the
  same artifacts. The distinction — those audit rules that already exist, while
  the Assayer governs the act of changing one — is enforced rather than asserted:
  a finding one of those three already reports is recorded as a **rejected
  candidate** with the owner named, and an assay that never rejects anything on
  those grounds has stopped checking.
- Finding parsing now raises rather than exits, so `lint-assay` can report every
  defect while `/harness-propose` still stops at the first. The two consumers
  want opposite behaviour: propose is acting on one finding, the linter is asking
  whether the document is well-formed.

## 0.76.0 — 2026-08-23

### Added

- **`/harness-compile`** — idempotent repair. Regenerates the generated region of
  every target artifact, the decision index, and the enforcement report. Writes
  only between markers, and refuses rather than guessing when a marker pair is
  ambiguous (#533, #536).
- **`/harness-check`** — read-only drift detection and the CI entry point. Fails
  on an invalid corpus, malformed markers, an accepted record never applied,
  region drift, report drift, or a frozen-record violation. Wired into
  `.github/workflows/harness.yml`; a failure is a build failure, not a warning.
- **`harness/enforcement-report.md`** — for every accepted rule on every surface
  it names, the enforcement level intended and the level achieved. Documented at
  `docs/plugins/ai-literacy-superpowers/reference/enforcement-report-format.md`.
- **The validator gate.** `achieved` also asks whether a declared `validator`
  resolves to a file that exists. Without it, a rule declaring
  `enforcement: blocked` on the `ci` surface reports as blocked while nothing
  anywhere refuses anything — a confident, legible, wrong answer from the
  mechanism whose purpose is telling enforced from written down. A
  declared-but-absent validator counts as none.
- **The frozen-record check.** Each accepted record is compared against its
  content at the commit that accepted it. Region drift catches a hand-edit to a
  compiled rule; it cannot catch a rule reworded in the *accepted record* and
  then recompiled, because the region would match the corpus and every
  byte-identity check would pass.
- **`target` and `validator`** on the decision record; **`routes`** in
  `harness/surfaces.yaml`.
- **Constraint: Harness governance is applied and undrifted** — deterministic,
  mirrored into all three convention files.
- **Layer-0 suite** `test-harness-compile.sh` (C1–C19), mutation-tested against
  19 deliberately broken implementations.

### Changed

- `/harness-accept` now accepts, applies, and recompiles in **one transaction**.
  Applying and compiling are deliberately not separate approval gates: once a
  record is accepted there is no decision left in either step, and a gate with no
  decision behind it is the shape of approval theatre. The compilation plan is
  computed before anything is written, so a missing target or an ambiguous marker
  pair refuses the whole acceptance rather than leaving a record accepted and
  unapplied.
- **Compilation routes by classification, and reports by surface.** The source
  spec asks compilation to regenerate the marked regions of every control
  surface. Taken literally that puts two generators on one file —
  `/convention-sync` already owns `.github/copilot-instructions.md`,
  `.cursor/rules/constraints.mdc` and `.windsurf/rules/constraints.md` — and is
  ambiguous wherever a surface lists a directory among its targets. So
  classification decides where a rule's text goes, and the enforcement report is
  what the surfaces are told.

### Fixed

- Four weaknesses in the S2 tests, all found by mutation testing. A
  truncate-before-read bug in a fixture (`open(p,"w").write(open(p).read()…)`)
  silently emptied the file under test. Region ordering was untestable because no
  target held two rules. The frozen-record baseline was indistinguishable from
  "first revision" because no fixture was committed while still proposed. And an
  assertion for the absent-validator case passed against a mutated checker
  because it grepped the whole report and matched an identical message emitted
  for a *different* record — the same false-pass shape found twice in S1.

## 0.75.0 — 2026-08-23

### Added

- **`harness-registrar` agent** — keeps the record of how governance itself
  changes. Applies human-approved decisions and never authors them.
  Deliberately **not** tagged `role: sentinel`: it holds `Write` and `Edit`, so
  claiming a read-only trust boundary would be a lie
  `sentinel-integrity-check.sh` would catch, and the exact category error the
  two-role separation exists to prevent (#533, #535).
- **`/harness-propose <assay> <finding>`** — drafts a Harness Decision Record
  from an assay finding at `status: proposed`, with `cost` left empty for the
  approver.
- **`/harness-accept <hdr>`** — the single write transaction. Runs every
  cost-independent refusal *before* prompting for the cost, then accepts and
  regenerates the index.
- **`scripts/harness-registrar.py`** — the deterministic write path behind both
  commands: `propose`, `precheck`, `accept`, `index`.
- **The assay-finding contract** — owned by this slice and consumed by the
  Assayer in a later one, because `/harness-propose` has no input without it.
  Documented at
  `docs/plugins/ai-literacy-superpowers/reference/assay-finding-format.md`.
- **`harness/decisions/index.md`** — generated, sorted by id, byte-identical on
  re-run so a later drift check can treat any difference as drift.
- **How-to guide** at
  `docs/plugins/ai-literacy-superpowers/how-to/record-a-governance-change.md`.
- **Layer-0 suite** `test-harness-registrar.sh` (R1–R16), mutation-tested
  against 22 deliberately broken implementations.

### Changed

- The rule-text copy is performed by a **script**, not by the agent. The build
  spec asks `/harness-propose` to copy proposed rule text verbatim, and a model
  asked to copy text usually copies it and occasionally improves it — a typo
  fixed, a bullet tidied, a line rewrapped. Each of those is a silent edit to a
  rule a human is about to approve believing it to be the Assayer's words.
  Verbatim by construction, not verbatim by instruction.
- Acceptance validates a **staged copy of the whole corpus** and writes only on
  success. Two S0 refusals are corpus-level — the three-per-cycle cap and the
  two-assay promotion threshold compare records against each other — so neither
  can be evaluated from the candidate alone. "Nothing is written and the HDR
  stays proposed" is now a property of the mechanism rather than a promise.
- The cost is passed as `--cost-file`, never as a command-line argument: it is
  multi-line prose, and an argument would put the approver's own words into
  shell history one copy-paste from the next HDR.
- Assay findings are parsed **lazily**. One malformed finding costs one finding,
  not the whole report — an assay is written by an agent under a materiality
  test, not by a compiler.

### Fixed

- Three weaknesses in the S1 tests, all found by mutation testing rather than by
  review. The rule-text fixture was too clean to catch a copier that strips
  trailing whitespace, so its first line now ends in two spaces — a markdown
  hard line break, meaningful syntax that a well-meaning `rstrip()` destroys
  silently. The `## Cost` section replacement was untested because the
  assertion grepped the whole file and the frontmatter satisfied it alone. And
  an assertion for "a finding with no observation is refused" passed against a
  validator with that check removed, because the refused **filename** —
  `HDR-…-no-observation-at-all.md` — contained the word being grepped for.

## 0.74.0 — 2026-08-23

### Added

- **Harness Decision Records** — a new append-only corpus at
  `harness/decisions/`, governing how `HARNESS.md` and `AGENTS.md`
  themselves change. Until now the plugin governed the loop and the turn
  but nothing governed the act of changing a rule: what evidence
  justified it, who approved it, what it costs the next person, and when
  it stops being true. First slice of the harness evolution epic (#533,
  #534).
- **`check-harness-decisions.py`** — the deterministic validator that
  holds every governance refusal: identifier grammar, required fields,
  the classification and enforcement vocabularies, the two body tiers,
  the four-backtick Rule block, the human-authored `cost`, the two-assay
  promotion threshold for `harness-loop` changes, the three-per-cycle
  acceptance cap, and grandfathering for imported constraints. Refusals
  live here rather than in an agent's prompt because the Harness
  Registrar is an agent with write authority over governance artifacts —
  a rule that lives only in a prompt is one a model can talk itself past.
- **`harness/surfaces.yaml`** — the control-surface capability matrix,
  declaring what each surface (Claude Code, Codex, Cursor, Copilot,
  Windsurf, CI) can actually enforce. A rule intending `blocked` on a
  surface that can only advise is reported as an *enforcement gap*, never
  silently downgraded: knowing which rules are genuinely enforced and
  which are merely written down is the point.
- **Constraint: Harness decision records are well-formed** — deterministic,
  wired into `.github/workflows/harness.yml` and mirrored into all three
  convention files.
- **Reference page** at
  `docs/plugins/ai-literacy-superpowers/reference/harness-decision-records.md`.
- **Layer-0 test suite** `test-harness-decisions.sh` (V1–V19), mutation-tested
  against 30 deliberately broken validators. Two rounds of mutation exposed
  gaps in the tests themselves: one assertion was passing on a Python
  traceback that happened to contain the word it grepped for, so
  `expect_fail` now refuses to accept a crash as a refusal.

### Changed

- `check-harness-decisions.py` validates `surfaces.yaml` whenever it exists,
  not only when decision records exist — day one of adoption is when the
  matrix is being authored and most likely to be wrong.
- Markdownlint now excludes `harness/decisions/HDR-*.md` and `harness/assay/**`
  for the same reason `docs/superpowers/**` is excluded: an HDR quotes the
  verbatim rule text it is about to write into `HARNESS.md`, so style rules
  fight it by construction. The corpus `README.md` and the generated
  `index.md` remain linted — those are documents, not records.

## 0.73.3 — 2026-08-14

### Fixed

- **`test-mast-boundary` no longer races the clock** (#527). MB3 built its
  fixture with `date -v+300M +%H:%M`, which formats `HH:MM` and discards the
  date — so a run after 19:00 produced a stop hour on the *following* day, which
  the hook could only read as many hours behind. It emitted the reached notice
  and the test failed, for roughly five hours in every twenty-four. CI never hit
  it because pushes landed earlier in the day.
- **The hook was correct throughout.** Its own comment says so: *"there is no
  day-rollover puzzle because there is no interval."* A stop hour already past
  today *should* produce the reached notice. The fixture was impossible, not the
  behaviour — worth stating, because the obvious fix would have been to change
  the hook.
- **MB1 and MB2 carried smaller versions of the same defect** — 21-minute and
  1-minute failure windows. Pinning the clock removes all three rather than
  narrowing them.
- **New `$CLAUDE_MAST_NOW` test-only override**, the fifth here beside
  `$CLAUDE_PACTS_FILE`, `$CLAUDE_SESSIONS_DIR`, `$CLAUDE_MAST_DIR` and
  `$CLAUDE_PARKED_DIR`. Malformed values fall through to the real clock: a
  boundary notice must never break a `Stop` hook. `minutes_from_now` now refuses
  to wrap rather than emitting a fixture the hook cannot satisfy.
- Verified across eight timezones, including the two that reproduced the failure.
  Three mutations killed.

## 0.73.2 — 2026-08-13

### Fixed

- **The sentinel docs now have a usage path** (#519). They were written for
  people who *build* sentinels rather than people who *use* them:
  `explanation/sentinels.md` carried exactly one how-to link and it pointed at
  `design-a-sentinel.md`, its roster's third column was "signature evidence"
  (proof an agent qualifies), and two of its eight sections were for authors.
  A reader who had just learned what the nine are had almost no path onward.
- **New `Using them` section** on the sentinels page: one row per sentinel with
  *reach for it when*, the command, and the guide — answering "which one",
  "how", and "what is available" in one table. Plus what to try first, and the
  distinction between the four that run in the pipeline and the five you call.
- **Every sentinel's `reference/agents.md` entry now names its command.** Four
  did; `coda` and `mast` passed only incidentally, with the command appearing in
  prose. All nine now carry a structural `Run` field.
- **New tutorial `your-first-sentinels.md`** — the Diataxis learning quadrant was
  empty for this category. All nine tutorials mentioned no sentinel, and
  `first-time-tour.md` presented `/diaboli` as freestanding rather than one of
  nine. It now says so, and links onward.
- **New Layer 0 test** `test-sentinel-usage-path.sh` (U1-U4). Three relations,
  each derived from both ends: sentinels from `role: sentinel`, commands from
  `reference/commands.md`'s own **Agents dispatched** field — a mapping that
  already existed and nothing consumed — and guides from the new table. Six
  mutations, all killed.

- **A constraint's enum values are now checked across the convention mirrors**
  (#511). `check-convention-parity.py` matches constraint **headings**, so a
  change to a rule's **body** passed untouched while `.cursor`, `.github` and
  `.windsurf` kept the old wording. The S6 gate found that one step from
  shipping: adding a seventh objection category would have left four files
  declaring a six-value enum the deterministic checker no longer enforced,
  with every gate green.
- **New check** `scripts/check-constraint-enum-parity.py`, wired into the
  existing Convention Parity workflow. Where a rule enumerates a closed set of
  valid values, every member must appear in all three mirrors.
- **Deliberately narrow.** The mirrors legitimately *abridge* — they drop
  explanatory clauses that belong in `HARNESS.md` and would be noise in an
  assistant's context, and 38 of 450 code literals in the rules differ today,
  most of them correctly. A whole-body equality check would fail everywhere and
  be switched off within a week. **Mirrors may abridge explanation; they may
  not abridge a vocabulary** — a mirror listing five of six valid values does
  not omit prose, it misleads about what is allowed.
- Mutation-tested against both directions: a mirror dropping an enum member,
  and `HARNESS.md` gaining a value the mirrors do not offer.

- **The sentinel roster is now checked against its source** (#507). Which agents
  are sentinels is a derived fact — exactly the `agents/*.agent.md` files
  carrying `role: sentinel` — and three documents pinned a copy of it.
  `README.md` and `sentinel-design/SKILL.md` were both still at 5 after S2, S3
  and S4 had each shipped one; each of those slices updated
  `explanation/sentinels.md` and missed the other two. Nobody was careless;
  there were three places and one habit.
- **New Layer 0 test** `test-sentinel-roster-parity.sh` — every `role: sentinel`
  agent appears in all three rosters, no roster claims an agent that is not one,
  and the README's `#### Sentinels (N)` count is compared against the derived
  set rather than a literal. **Membership only**: the rosters carry per-agent
  "Guards" columns and narrative prose that no generator would write well, so a
  check treating them as one list would be right about membership and wrong
  about everything else.
- Mutation-tested against all six drift shapes, including the one that will
  actually happen — a new sentinel shipping with no roster updated.

## 0.73.1 — 2026-08-13

### Documentation (Cadence Sentinels S7)

- **The hook manifest no longer contradicts itself.** `hooks.json`'s description
  said the constraint gate was `PreToolUse` while the same file registered it
  under `PostToolUse` eight lines below — the shipped artefact, not its
  documentation. `README.md` carried the error twice more, in prose and in the
  architecture diagram.
- **`reference/hooks.md` gains a `PostToolUse` section** (it had none), the two
  hooks it was missing (`wip-check`, `affordance-invocation-recorder`), and a
  `Libraries` section for the advisory rail — a sourced library that sat among
  the Stop hooks and made every heading count off by one. 18 declared, 18
  documented.
- **New page: The cadence discipline** — `coda`, `mast`, `wip-warden` and
  `convener`, mirroring `decision-discipline-triad.md`. It is the home for the
  epic's conceptual results: the operational-state carve-out, the read/write
  library split, state-in-the-path records, the advisory rail's precedence rule,
  and the lease that renews because `Stop` fires per turn.
- **`harness-md-format.md` documents `## Stakeholders`** — the Convener's
  declaration surface, promised by S5's rollout and not delivered.
- **Rung and reach are now distinguished** across all eight pages that taught
  the enforcement ladder as one axis. The rung is *how* a check runs
  (`unverified | agent | deterministic | deterministic + agent`); the reach is
  *what it demands* (required, or complete-if-present). Collapsing them is how
  S5's first revision came to invent an `agent-verified` rung that was never a
  value of the enum.
- **`sentinels.md` repaired**: a blank line was orphaning the `convener` row
  into a second one-row table — live on the docs site since S5, introduced by
  the edit that added the row — and the page still said "the five roster agents"
  beneath a roster of nine.
- **`index.md`'s hand-maintained Concepts list** gains six pages it was missing.

### Tests

- **`test-sentinel-docs-coverage.sh`** — every `role: sentinel` agent is named
  by an explanation page's new `sentinels:` frontmatter key, and no page claims
  an agent that is not one. **Both sides derived**; no count pinned anywhere.
  The key exists because nothing on disk previously linked a sentinel to the
  page explaining it — pages are named for concepts, not agents.
- **`test-hooks-doc-parity.sh`** — the page's event sections match what
  `hooks.json` registers, by count *and* by script name, and nothing in the repo
  calls the constraint gate a `PreToolUse` hook.
- **`test-cadence-integration.sh`** — the property per-library tests
  structurally cannot show: one pact file, one registry, **three readers, one
  answer**. Plus silence on an unadopted machine, and no state leaking into a
  work tree. Sets all four test-only overrides, because the pact file and
  registry live outside every work tree and a toy repo does not isolate them.

### Known gaps

- **#497 stays open.** Its fourth acceptance item — verifying links in the
  epic's source deck — cannot be done: that deck is in neither repository.
- **#514** records the wider finding: all seven Cadence Sentinels specs cite it.

## 0.73.0 — 2026-08-13

### Embedded assumptions (Cadence Sentinels S6)

- **The advocatus-diaboli now hunts for assumptions an artefact encodes without
  stating them** — that the user can see, that the list is short, that the
  locale is the author's. Four sub-kinds appended to the **code-time `risk`
  weighting**: usability and accessibility, performance context, requirements
  enshrined in tests, and environmental.
- **Not a seventh category.** The spec gate falsified the premise the first
  revision rested on: the shipped code-time weighting already directs `risk` at
  "specific evidence from the implementation", so the gap was **attention, not
  capability**. Four items on an existing hunt-list, against a taxonomy change
  touching sixteen surfaces including a deterministic checker, a HARNESS
  constraint body and three convention-file mirrors.
- **Quote the artefact, not a sentence about it.** An objection that quotes the
  spec is a `premise` or `specification quality` objection instead — an
  assumption the spec *states* is not embedded.
- **The Convener routing is stated**, with the test: can the assumption be
  settled by *reading the artefact*, or only by *asking someone*? Two of the
  four sub-kinds are paradigm cases where the remedy is a conversation, and the
  S5 tie-break already assigns those to the Convener.
- **Four remedy framings as prose, not schema** — `accept-as-stated`,
  `revise-spec`, `add-test`, `consciously-carry` — offered at the end of an
  assumption objection so the human has them in view when writing the
  disposition. `consciously-carry` is a complete answer: an assumption carried
  knowingly is strictly better than the same one carried invisibly.
- **New reference page** `objection-record-format.md`, which was simply missing
  beside its two siblings. Issue #496 asked for a README inside
  `docs/superpowers/objections/`; that directory is globbed by two consumers as
  the complete record set, so the page went where it belongs instead.

### Unchanged, deliberately

- **Six categories, one schema, one checker.** No `remedy` field: with no
  distinguishing category, nothing deterministic can tell an assumption
  objection from any other, so the field would have shipped claiming an
  enforcement that does not exist. `disposition` keeps `accepted | deferred |
  rejected` and its four consumers.
- **No dated cutover**, because nothing about the taxonomy changed.

## 0.72.1 — 2026-08-13

### Fixed

- **The auto-enforcer constraint hook no longer blocks writes** (#509). It was
  a `type: prompt` hook on `PreToolUse` whose prompt ended *"Do not block —
  only warn."* A `PreToolUse` prompt hook has exactly two channels — return
  nothing (allow) or return text (deny) — so the instruction was addressed to a
  model with no mechanism to comply: the text it returns **is** the block. Moved
  to `PostToolUse`, where the write has landed, the file is still uncommitted,
  and returned text is genuinely advisory. Two legitimate writes were denied
  during the Cadence Sentinels epic.
- **And no longer invents constraints.** Both denials named a constraint absent
  from `HARNESS.md`; the second paraphrased an objection out of the payload it
  was inspecting and reframed it as a violation — pattern-matching on the
  content rather than reading the file. The prompt now requires the constraint
  heading be quoted **verbatim** from `HARNESS.md` alongside the offending line,
  and to return nothing when it cannot do both. Returning nothing is named as
  the correct and common outcome.
- **New Layer 0 test** `test-hooks-advisory-placement.sh` (H1–H4): no advisory
  prompt hook may sit on `PreToolUse`, the constraint check must still exist and
  live on `PostToolUse`, its prompt must demand a verbatim quote, and every hook
  must declare a valid type and timeout. Structural rather than behavioural —
  the same hook allowed three agent-file writes and denied the fourth, so a test
  that ran the prompt would be flaky in exactly the way the bug is.

## 0.72.0 — 2026-08-12

### The Convener (Cadence Sentinels S5)

- **New sentinel `convener`** — runs at plan approval beside the
  `choice-cartographer`. Maps the roles and groups a spec affects, drafts the
  one concrete question worth asking each, and returns a consultation record.
  Attacks **isolation drift**: a spec can be internally excellent and still be
  wrong because the person who wrote it never asked the one question that would
  have changed it, and that failure is invisible from inside.
- **It never contacts anyone**, in any medium. The read-only trust boundary
  forecloses every mechanical path; the charter draws a line against drift —
  *a question is one sentence a person could answer; a message has a
  salutation, a context paragraph, or a sign-off*.
- **New `/convene` command** — dispatches the agent, runs a prune-**and-add**
  dialogue, and persists the record append-only (`.superseded.md` on re-run,
  never an in-place edit). Carries an F1–F8 validation checkpoint.
- **New `convener` skill** — the charter, the question/message line as a worked
  pair, the derivation table for `inferred` voices, the cap, and the
  anti-pattern gallery.
- **New constraint `PRs have disposed consultation voices`** —
  `Enforcement: deterministic`, matched by
  `scripts/check-consultation-dispositions.py`. Every voice disposed with its
  own distinct `outcome`. **Complete-if-present**: a PR whose spec has no
  consultation record passes, because running `/convene` is a choice.
- **Optional `## Stakeholders` section** in `HARNESS.md` (and the template,
  commented out) declares who a project affects. Absent is not an error — the
  agent derives candidates and flags every one `inferred`.
- **Orchestrator wired**, not implied: a numbered step beside `1b`, a named
  soft gate, and a structured `convene_pending_count`.
- **The Routing Rule is now three-way** across the diaboli, cartographer and
  convener skills, with the tie-break stated: a finding about a person who
  should be asked is the Convener's even when it also names a failure class,
  because the remedy is a conversation rather than a spec change.

### Why outcomes must be distinct

- `pending` is a **detectable** failure. N voices bulk-filled
  `deliberately-not-consulted / "no time"` is an **undetectable** one, and
  strictly worse: an all-pending record is truthful about disengagement, while
  an all-declined one launders it into decisions nobody made — permanently,
  because records are append-only and the next reader will trust the file.
- The check never judges a reason. *"No time; shipping Thursday and the docs
  owner is on leave"* passes. It refuses one string standing for several
  decisions.

### Substrate and honesty corrections

- **`records_latest` added to `hooks/scripts/lib/record-paths.sh`** (carved
  commit) — the current state of every record chain. `records_open` excludes
  `*.resolved.md` by name, and a disposition only ever exists inside one, so
  the only query S1 shipped could not see the only file that matters.
- **Consultation records are named `<spec-slug>.md`**, matching the objection
  and story records, so one spec resolves to one record across all three.
- **The gate is no longer described as "agent-verified"** — never a value of
  the enum (`deterministic | agent | unverified`). The **rung** is
  deterministic and the **reach** is complete-if-present; those are different
  axes.
- **All three sentinel rosters reconciled 5 → 9**, narrative sentences
  included — `README.md`, `sentinel-design/SKILL.md`, and the explanation page.
  The drift is S2's, S3's and S4's: each updated the explanation page and
  missed the other two. #507 tracks deriving the roster rather than pinning it.

### Docs

- New how-to: **Convening the voices**.
- Reference entries on `agents.md`, `skills.md`, `commands.md`, and the
  corrected `consultation-record-format.md`.

## 0.71.0 — 2026-08-12

### Cadence Sentinels S3b — boundary notices and the hard stop

The seam three slices deferred into: S3's notices and override, S4's override,
and a contract change to the Coda that shipped before either existed.

- **Two notices against `hard_stop_hour`** — approaching (default 30 minutes,
  tunable via `approaching_lead_minutes`) and reached — each once per session.
  At the line, exactly one recommendation: `/coda`.
- **A lead time, not a fraction.** The first design measured 80% of the way
  from session start, which is not computable: `started_at` is UTC,
  `hard_stop_hour` is local, and `started_at` is deliberately never reset across
  resume — so the notice would have fired every morning with nothing approached.
- **The advisory rail** arbitrates by **precedence**, not registration order. A
  once-only advisory speaks; a repeating one defers to the turn it is going to
  get anyway. `reservoir-check.sh` has no once-per-session guard and cannot
  have one, so ordering it first would have preserved the message that repeats
  and permanently spent the one designed to arrive once.
- **The store records only what fired.** An earlier design carried
  `continued past the 20:00 stop by choice`, timestamped identically to the
  notice — written before the human had done anything. Nothing observes a
  choice; continuing is the absence of stopping. What the human decided is
  asked for at close, in their own words, or not recorded at all.
- **Keyed by repo, not session**, because its writers include `/coda` and
  `/wip` — commands, which have no channel to learn a session id.
- **Consumption marks rather than deletes**, so the once-per-session notice
  state survives a close that does not end the session.
- **The prune runs unconditionally**, before the opt-in check: gating the
  janitor behind the feature meant deleting your pact stranded every file
  forever.
- **Read/write library split**, so a sentinel can reach the notes without
  reaching a mutator.
- **One coordination line in `reservoir-check.sh`** — a coordination change,
  not a behavioural one, recorded as a judgement in the spec.

Closes #501.

## 0.70.1 — 2026-08-11

### Fix: `block_state` answers well-formedness, not completeness

S1 defined `malformed` as "mandatory clause **or required key** missing" and
only the clause half was ever implemented. S4 exposed the gap; the resolution
is that the **definition** was the defect, not the code.

- **No pact key is required.** `/mast tune` deliberately offers a two-line
  pact, so a `Session WIP` block carrying only `stale_after_hours` is exactly
  what somebody meant to write. Calling that `malformed` would say it was
  broken. It is not broken — it is partial, on purpose — and no key was ever
  truly required, since a person may declare that block solely to tune the
  registry lease.
- **`block_has_key`** answers the completeness question separately, per key, so
  a consumer can say *what* is absent instead of inventing a value. An empty
  value is not a declaration: `- max_concurrent_sessions:` with nothing after
  it is someone who started typing and stopped.
- The WIP Warden now asks rather than inferring a missing limit from an empty
  string.
- S1's spec and the pacts reference page are amended, and the reference now
  tells adopters plainly that a short pact is a complete one.

Closes #503.

## 0.70.0 — 2026-08-11

### Cadence Sentinels S4 — the WIP Warden

Closes the loop S1 and S3 left open: the registry knew how many sessions were
live and the pact declared the limit, and nothing read either.

- **`/wip`** and a `SessionStart` breach report — how many sessions are live,
  which they are, how long since each last took a turn, and how that compares
  against the line you drew.
- **It counts sessions and never watches the human.** That split is what
  protects the `reservoir-warden`, which is trustworthy precisely because it has
  no teeth; a sibling inferring tiredness from session counts would break its
  contract retroactively for anyone who had declared a chronotype.
- **The boundary is not machine-enforced, and says so.** A word-ban was written
  and rejected: it passes every sentence that actually violates the boundary
  while failing on `focus_blocks`, a live pact key — and a green grep would have
  been read as proof the boundary was checked.
- **`enforcement: strict` gets an honest definition.** S1 defined it as
  requiring a disposition before the session proceeds; no hook can hold a
  session. It is now a stronger *ask* that says plainly it cannot compel. The
  shipped template and reference page, which still promised an on-the-record
  override, are corrected.
- **It never invents a limit.** A `Session WIP` block with its clause and no
  `max_concurrent_sessions` is a normal file — `/mast tune` offers a two-line
  pact on purpose — so the Warden says no limit is declared and compares
  nothing. Reporting a breach of a line nobody drew would be the worst output
  available.
- **Ages are measured from each session's last turn**, not from when it
  started, which would have pointed you at the session you are working in as the
  obvious one to park.
- **An inexact count says "at least".** No consumer may treat the registry count
  as an exact number of open windows, and this is the first consumer.

### Fix

- **`registry_list` never filtered by lease, and its docstring said it did.**
  Shipped that way since 0.67.0. A consumer taking a count from `registry_count`
  and a list from `registry_list` would have said "1 live session" and then
  listed four. Repaired in its own commit, with `heartbeat` now carried so an
  honest age is computable, and two scenarios pinning it.

## 0.69.0 — 2026-08-10

### Cadence Sentinels S3 — the Mast

The pact-keeper: the gauge that reads the limits you set for yourself, and the
ritual that brings them into existence.

- **`/mast tune`** is the only sanctioned path that creates or amends
  `~/.claude/pacts.md`. **This unblocks the epic** — S1 shipped a template no
  path authored, so until now the pact file did not exist and every sentinel was
  permanently in observe-only.
- **It is an editor, not only an author.** It reads your current values back as
  each question's context — not as defaults — and `/mast tune budgets` scopes an
  edit to one block. Without that, changing one number meant re-running the
  whole ritual, and the cheapest path to a small edit was the file itself.
- **It asks the stop hour first**, then offers to stop there: a useful pact in
  one question. It proposes nothing as a default, and every block is skippable.
- **It says what nothing reads yet before asking** — `Sync cadence` entirely,
  three of `Session WIP`'s keys, `notification_policy_after_stop`,
  `daily_cost_ceiling`. Disclosing for one block and not the others would have
  had people authoring a first pact under two regimes without being told.
- **`/mast` recites before it measures.** A pact nobody reads is not a pact, so
  the report leads with your own declared words and annotates after.
- **It refuses to estimate.** `hard_stop_hour` is `observed`; `focus_blocks` and
  `sessions_per_day` are `inferred`; `daily_cost_ceiling` is **not observable**.
  A fabricated spend figure against a real ceiling would make someone stop, or
  not stop, on a number nobody measured.
- **The weather check discloses its own blind spot.** It notes a budget tuned
  today; a pact hand-edited outside Tune never moves the stamp and is invisible
  to it. The build spec called for a CI check on `Budgets` diffs, which is
  impossible now that pacts are never committed — flagged, and replaced with a
  note that says what it misses rather than one that overclaims.
- **`lib/pact-write.sh`** — the write surface, sourceable by commands and hooks
  only, matching S1's read/write split. It derives the mandatory clauses from
  the template rather than restating them, replaces a block instead of appending
  a second (a duplicate heading is silently unread), stamps `Budgets` only, and
  preserves the preamble.
- **A validation checkpoint** after every write, per the repo convention for
  commands producing structured output that downstream consumers parse. Its
  absence would otherwise surface later and silently, as sentinels dropping to
  observe-only.
- **Boundary notices and the hard stop are #501**, split out at the spec gate.
- **9 new Layer-0 scenarios**; sentinels 6 → 7.

## 0.68.0 — 2026-08-09

### Cadence Sentinels S2 — the Coda

The closing ritual. A session that ends by decision rather than by attrition,
with every open thread written down and a concrete step to resume from.

- **`/coda`** — survey what landed and what is still live, park each open
  thread, write the closure summary through `/reflect`, and close. Stoppable at
  any point by saying so.
- **`/coda resume <record>`** closes a parked thread by writing a `.resumed.md`
  transition. Nothing is ever edited or deleted.
- **The `coda` agent is `role: sentinel` and read-only.** It returns
  parking-record content; the command persists it after the human confirms.
- **Parking happens before reflection, and records are committed there.**
  `/reflect` stages only the reflection paths and, where a *Reflections via PR
  workflow* constraint is declared, relocates the tree to `main` — so a ritual
  that reflected first would have published a summary describing records it
  left behind uncommitted, on a branch it had just left.
- **Nothing is refused.** `scripts/next-action-hint.sh` asks one more question
  when it finds no anchor; whatever the human answers is parked, including the
  same words again. It renders no verdict, so there is no gate.
- **The anchor grammar carries a decision row** — a question word, a named
  person, `ask` / `decide` / `choose between` — because the other five kinds
  are all artefacts of code-shaped work, and much of what gets parked is a
  spec, a piece of prose, or a decision.
- **The override lives in the record's prose, in the human's own voice**, not
  in a frontmatter flag. A flag recording that someone's answer failed a check
  would be an agent-authored verdict about them, permanent and countable across
  records. `next_action_flag` stays `asked`, so S2 consumes S1's contract
  without mutating it.
- **Thread grouping is proposed and default-accepted.** Deciding that nine
  modified files are two threads is the judgement that shapes the whole
  handoff, so it is the human's — but the proposal stands unless they change
  it, because this step lands after they have decided they are finished.
- **Parked records surface once, on startup only.** `SessionStart` re-fires on
  resume, clear and compact; handing a thread back mid-session is the surface
  this epic exists to reduce. The guard reads the hook's own `source` field and
  writes no marker file.
- **`sentinel-design`** gains the Coda to its roster; sentinels 5 → 6.
- **19 new Layer-0 scenarios** across `test-next-action.sh`,
  `test-parked-resume.sh`, and the extended `test-record-contracts.sh`.

## 0.67.0 — 2026-08-08

### Cadence Sentinels S1 — the shared substrate

The plumbing the four cadence sentinels (Coda, Mast, WIP Warden, Convener)
will consume, shipped once so none of them re-derives it. Nothing in this
slice gates anything.

- **The pact file (`~/.claude/pacts.md`).** A new, user-scoped declaration
  surface carrying three optional blocks — `Session WIP`, `Budgets`, and a
  reserved `Sync cadence`. Pacts belong to a person, not a repository: a stop
  hour and a concurrency limit are properties of the human, so they live
  outside every work tree and are never committed. `HARNESS.md` remains the
  repo's declaration surface and is untouched.
- **`Budgets` carries its governing clause.** *Unspent budget is not a debt.*
  A block whose clause has been deleted reads as `malformed` and every
  consumer drops back to observe-only, rather than holding its keeper to a
  pact whose governing sentence is gone.
- **A block reader that does not mangle its own vocabulary.**
  `lib/pact-blocks.sh` splits on the first delimiter and trims at the ends
  only. The inherited `read_key` is greedy on `:` and strips interior spaces,
  which turns `hard_stop_hour: 18:30` into `30` — three of seven `Budgets`
  keys would have parsed to garbage.
- **The session registry is a lease, not a log.** `SessionStart` writes,
  `Stop` renews, and only lease expiry retires an entry. `Stop` fires per
  assistant turn rather than per session, so a delete-on-`Stop` registry would
  have emptied itself after each session's first response — and the WIP Warden
  would have reported one live session while four ran.
- **The honesty flag belongs to the count, not the reader.** `registry_count`
  is a pure read; pruning happens on the hook rail. A count following a
  retirement stays `inferred` for every subsequent reader, not just the first.
- **The registry library is split along the sentinel trust boundary.**
  Sentinels may source the read surface; the mutation surface is reachable
  only from hook scripts. The frontmatter check permits `Bash` and names this
  as its own known limit, so the boundary is preserved by what an agent can
  reach rather than by what it is trusted not to call.
- **Records are append-only, and now actually are.** Parking and consultation
  records carry their state in the filename; a transition writes a new file
  rather than editing a `status` key in place. `records_open` answers "what is
  still open" from the names.
- **Record schemas ship as published reference pages.**
  `reference/parking-record-format.md` and
  `reference/consultation-record-format.md`, plus `reference/pacts-format.md`.
  A schema homed in `docs/superpowers/` would be excluded from the site by
  `mkdocs.yml` — the one format contract an adopter could not read.
- **25 Layer-0 scenarios** across `test-pact-blocks.sh`,
  `test-session-registry.sh`, and `test-record-contracts.sh`.

## 0.66.2 — 2026-07-22

### Fix: health badge mirrors the authoritative Health line

- `update-health-badge.sh` re-derived the harness health status by
  keyword-sniffing the snapshot's Meta section, so the standard line
  `Trend alerts: none` false-positived on the substring "alert" and
  flagged **Attention** on a genuinely Healthy snapshot; a `head -20`
  window could also miss the Health line in a longer Meta section. The
  script now reads the explicit `- Health: **X**` line the
  `/harness-health` skill already computes (Healthy / Attention /
  Degraded) as the source of truth, keeping the `<70%` enforcement ratio
  as a Degraded safety-net override and a word-boundaried keyword
  heuristic only as a fallback for snapshots with no Health line.
- Added a Layer-0 regression test (`test-update-health-badge.sh`)
  covering the `Trend alerts: none` case, all three Health statuses, the
  enforcement override, a Health line past 20 lines of Meta, and the
  badge link target.

## 0.66.1 — 2026-07-20

### Docs: ground the sentinel category in Storey's triple-debt model

- Grounded the sentinel category in Margaret-Anne Storey's *From
  Technical Debt to Cognitive and Intent Debt* (2026, arXiv:2603.22106):
  where the pipeline and harness agents fight **technical** debt in the
  code, sentinels service the human side of the ledger, holding back the
  **cognitive** debt (erosion of shared understanding) and **intent**
  debt (absence of externalised rationale, goals, and constraints) that
  accrue when AI generates code faster than a team can absorb it.
- Framed sentinels as the agent pattern that establishes and protects the
  human's **understanding, judgement, and discernment** — three edges of
  one commitment, each mapped to a debt and to the sentinels that hold it
  back. Discernment (telling a sound AI output from a plausible-but-wrong
  one) is named as the sharpest edge and the one AI erodes most quietly.
- Added the grounding to `explanation/sentinels.md`, the `sentinel-design`
  skill, the `design-a-sentinel` how-to, the README Sentinels intro, and
  the reference entry; kept the crisp one-line definition and layered the
  triple-debt framing on top. Patch bump — plugin doc-only change.

## 0.66.0 — 2026-07-20

### Feature: the sentinel agent category

Names the sub-family of agents whose object of care is the human's
understanding and judgement rather than an artefact, the pipeline, or
the harness. Categorisation, documentation, and one new enforceable
constraint — no agent renames, no behavioural changes, no new gates.

- **`role: sentinel` frontmatter tag** — added to the five roster agents
  (`reservoir-warden`, `advocatus-diaboli`, `choice-cartographer`,
  `carpaccio`, `cost-estimator`). An enum with a single permitted value;
  absence means "pipeline/harness agent" and changes nothing.
- **Sentinel integrity constraint** — `sentinel-integrity-check.sh`
  fails CI if a `role: sentinel` agent is granted Write/Edit (criterion
  S1), or if any `role:` value falls outside the enum. Runs at PR time
  (`harness.yml`) and weekly (`gc.yml`), and as a Layer-0 test with
  red/green fixtures. This makes the category load-bearing, not
  decorative — mislabel an agent and the build goes red.
- **`sentinel-design` skill** — documents the three-part signature (S1
  read-only, S2 advisory-to-human, S3 explicit honesty rule), the
  near-miss gallery (why code-reviewer and harness-auditor don't
  qualify), the honesty-rule-before-detection-logic discipline, and the
  three anti-patterns.
- **README Sentinels section** — the *Agents (16)* table splits into
  Sentinels (5) and Pipeline & harness agents (11).
- **Docs** — new `explanation/sentinels.md` page; `/superpowers-status`
  now reports sentinel coverage and integrity-constraint state.

### Docs: how to design a sentinel

- Added the [Design a Sentinel Agent](docs/plugins/ai-literacy-superpowers/how-to/design-a-sentinel.md)
  how-to guide — the task-oriented walkthrough for authoring a new
  sentinel (confirm the object of care, write the honesty rule first,
  author the agent, run the integrity check, ship the TDAD scenario and
  reference entry), completing the Diataxis coverage alongside the
  existing concept and reference pages. Cross-linked from the Sentinels
  concept page and the `sentinel-design` reference entry. Docs-only, no
  plugin version bump.

## 0.65.1 — 2026-07-16

### Fix: harness-auditor bounded read-side filtering (#478)

The harness-auditor's "Read-side filtering policy" told the agent to
`bash …/scripts/lib/reflection-log-helpers.sh` and then call
`bounded_entries` — broken two ways: the vendored path does not exist in
a marketplace-cache install (the #475 class of failure), and
`reflection-log-helpers.sh` is a *sourced* function library, so running
it with `bash` in a subshell never defines the function for the caller.

Fixing the invocation surfaced a third, latent defect: `bounded_entries`
itself returned empty entry bodies. It wrote each multi-line entry into a
tmpfile with real newlines, so the line-based `sort`/`awk` that follow
shattered every record — only the first physical line kept its tab, and
the rest read back blank. The existing tests missed it because they
counted `---ENTRY---` markers only, never the bodies.

- **`scripts/lib/reflection-log-helpers.sh`** — `bounded_entries` now
  encodes each entry body as a single physical line (newlines → literal
  `\n`) before the sort, which the downstream `awk` already decodes.
  Entry bodies are preserved.
- **New `bin/reflection-log-bounded` shim** — sources the helper library
  (resolved from its own location) and calls `bounded_entries` with the
  caller's arguments, so it works vendored or cache-installed and via
  PATH as a bare command.
- **`agents/harness-auditor.agent.md`** — the read-side-filtering
  instruction now runs `reflection-log-bounded REFLECTION_LOG.md 50 90`.
- **Test** — added `test_bounded_entries_preserves_entry_bodies`
  (asserts bodies == markers); it fails against the pre-fix function.

## 0.65.0 — 2026-07-04

### Fix: plugin-script references resolve in cache installs via bin/ shims (#475)

Commands, agents, and GC-rule `Tool:` fields referenced plugin scripts by
path — either `ai-literacy-superpowers/scripts/<name>.sh` (only valid when
the plugin is vendored in-repo) or `${CLAUDE_PLUGIN_ROOT}/scripts/<name>.sh`.
In the default (non-vendored) install the plugin runs from the versioned
marketplace cache, and **`${CLAUDE_PLUGIN_ROOT}` is defined only for hooks**
— it is UNSET in slash-command, main-agent, and subagent Bash contexts
(verified empirically on Claude Code 2.1.200, in both `--plugin-dir` and
real marketplace-cache installs). So every such reference silently failed
to resolve outside a vendored checkout — most importantly the **active,
deterministic** "Reflection log archival of promoted entries" GC rule,
which ships enabled with no caveat.

The one thing that IS on PATH in every context, including the harness-gc
subagent, is the plugin's `bin/` directory.

- **New `ai-literacy-superpowers/bin/` shims** — `archive-promoted-reflections`,
  `harness-affordance-check`, `harness-affordance-staleness`,
  `harness-affordance-invocations`, `harness-affordance-discover`,
  `update-badge`, `update-health-badge`, and `regenerate-reflection-log`.
  Each resolves the plugin root from its own location and `exec`s the
  corresponding `scripts/<name>.sh`, preserving the caller's working
  directory.
- **`templates/HARNESS.md`** — the reflection-archival and affordance
  `Tool:` fields are now **bare commands** (e.g. `archive-promoted-reflections`)
  that resolve via `bin/` on PATH regardless of vendored-vs-cache install
  and survive plugin upgrades. Added a Garbage Collection section note
  explaining the mechanism, and reworded the affordance caveat (no more
  "adjust to your install location"). The `sync-to-global-cache` hook
  example now shows `${CLAUDE_PLUGIN_ROOT}` (hooks resolve it; GC-rule
  Tool fields do not).
- **Commands / agents / skills** — badge, discovery, and reflection-log
  regeneration instructions now invoke the bare `bin/` commands instead of
  `${CLAUDE_PLUGIN_ROOT}` or vendored paths: `commands/harness-health.md`,
  `commands/harness-init.md`, `commands/harness-affordance.md`,
  `commands/reflect.md`, `agents/harness-gc.agent.md`,
  `agents/harness-auditor.agent.md`, `agents/integration-agent.agent.md`,
  and `skills/ai-literacy-assessment/SKILL.md`.

Known remaining edge (not addressed here): the read-side-filtering
instruction in `agents/harness-auditor.agent.md` sources the
`reflection-log-helpers.sh` function library rather than executing a
top-level script, so a `bin/` shim does not map to it cleanly — it needs
its own treatment.

## 0.64.1 — 2026-07-03

### Fix: gc-rotate strict-mode check false positives (#362)

- **`hooks/scripts/gc-rotate.sh` rule 3 (shell strict mode)** now scans
  the whole file for any start-of-line `set` that enables
  errexit/nounset/pipefail, instead of matching the exact literal
  `set -euo pipefail` in the first 15 lines only. The old check produced
  false positives on two legitimate patterns: strict-mode lines that sit
  below a documented header comment block (past line 15), and deliberate
  fail-open subsets such as `set -uo pipefail` (hooks that must not abort
  mid-run) and `set -u` (telemetry/CI scripts). The `[euo]` anchor still
  rejects `set -- "$@"` and still flags scripts with no strict mode at
  all. (Defect 1 from the issue — whole-tree `*.sh` scan — was already
  fixed by the `git ls-files` scoping in `list_owned_shell_scripts`.)

## 0.64.0 — 2026-06-23

### Docs: curated agentic-engineering video library (#456)

- **New explanation page** `docs/plugins/ai-literacy-superpowers/explanation/agentic-engineering-videos.md`
  — a "watch this to understand X" companion that maps authoritative
  talks (Böckeler, Anthropic, Osmani, North, Adzic, Knuth, Fairbanks,
  Meadows, Boyd/OODA) onto the plugin's own capabilities and lineage.
  Grouped by repo theme, each entry cites the capability or foundation
  it illuminates, carries a start-here → deeper sequence hint, and was
  link-verified live on 2026-06-24. Includes a suggested viewing path
  and an honest list of foundations with no verified primary-source
  video. Linked from the plugin docs index. Docs-only, no version bump.

### dynamic-workflows: docs, Copilot contract, epic finale (S7, #444)

The final slice of the Dynamic Workflows Alignment epic (D1–D9 now all
delivered across S1–S7).

- **README gains a "Dynamic Workflows" section** — the new ephemeral substrate,
  the six patterns, the opt-in election discipline, INV-1/INV-2, and the
  Claude-Code-only/guidance-everywhere boundary. The `Skills-36` badge is
  deliberately unchanged (the count was reconciled in S1).
- **Copilot CLI degradation contract resolved (open question 4 → Option A):** the
  `dynamic-workflows` skill **ships to both** the Claude Code and Copilot CLI
  trees and is **never omitted**. Where the workflow runtime is absent it is
  guidance-only — readable knowledge with each workflow-mode degrading to its
  static fallback, never erroring. Documented in the README and the skill's
  `governance.md`. This is documentation of already-shipped behaviour — no agent
  behaviour changes.
- **`CLAUDE.md` (root) and `templates/CLAUDE.md`** gain a pointer: when a task
  looks long-running, massively parallel, highly structured, or adversarial,
  consult the `dynamic-workflows` skill before reaching for a workflow.
- The optional advisory `Stop` hook from D9 was **deliberately deferred** (a Stop
  hook cannot reliably know a task's shape; the election discipline already lives
  in the skill and the orchestrator's classifier).
- All four §7 open questions are now resolved: Q1 fan-out threshold = 8 (S3); Q2
  routing opt-in (S5); Q3 staging = `REFLECTION_STAGING.md` (S6); Q4 Copilot =
  Option A (here). Deterministic structural checks
  (`test_s7_docs_hook_copilot_structural.py`) gate the declared contract.

## 0.63.0 — 2026-06-23

### dynamic-workflows: reflection-mining curation workflow (S6, #443)

Raises the *proposal* quality of the compound-learning loop without touching the
human-curates principle.

- **`/reflect` gains an optional `--mine` mode**: it adapts
  `reflection-mining.workflow.js` to cluster the reflection corpus, adversarially
  pre-filter each candidate rule ("would this rule have prevented a real past
  mistake?"), and emit a vetted **shortlist** of promotion candidates. The
  default `/reflect` capture behaviour is unchanged.
- **New `REFLECTION_STAGING.md`** (gitignored, regenerated each run) is the sole
  write target — each candidate carries the proposed rule, its source reflection
  fragment(s), and the adversarial verdict/evidence. Mining writes **only** there
  and **never** to `AGENTS.md` (byte-for-byte unchanged); a **human still
  promotes** from staging via the existing `Promoted:` flow (INV-1: agents
  propose, humans curate).
- **`integration-agent`** notes that mining **augments, never replaces** human
  curation — the `Promoted:`-line gate stays the only path into AGENTS.md/HARNESS.md.
- `--mine` requires the Claude Code runtime; without it it degrades to
  guidance-only and never errors. Deterministic structural checks
  (`test_s6_reflection_mining_structural.py`) gate the declared contract.

## 0.62.0 — 2026-06-23

### dynamic-workflows: orchestrator classify-and-act routing (S5, #442)

The largest behavioural slice — deliberately conservative. A classifier front
runs before the pipeline and routes by task type, but only when explicitly
opted in.

- **`orchestrator` gains a "Task classification" step** before the pipeline.
  Non-static routing is **opt-in** via an optional `orchestrator-routing` field
  in HARNESS.md (**default off**); when off — and for ordinary coding tasks and
  any ambiguous classification — the existing **static pipeline runs unchanged
  with no extra compute**. Treat drift toward "everything is a workflow" as a
  regression.
- **Four routes** when enabled: static (ordinary coding), tournament
  (design/naming/taste, rubric-bearing judge), root-cause (debugging/incident,
  ≥3 hypotheses from disjoint evidence + verifier/refuter panel), and triage
  (large backlogs under INV-2 quarantine — untrusted content read by
  low-privilege agents, trusted agents act). Each adapts the relevant
  `*.workflow.js` template.
- **The Plan Approval GATE and `MAX_REVIEW_CYCLES=3` GUARDRAIL hold on every
  route** — routing changes which pipeline runs, never the human-cognition gates.
  Claude-Code-only with a non-erroring static fallback; every route is
  propose-only (INV-1).
- **`/superpowers-status`** surfaces routing posture (opt-in/off-by-default vs
  enabled) and the last route taken when traceable, else `unavailable`.
- Deterministic structural checks (`test_s5_orchestrator_routing_structural.py`)
  gate the declared contract.

## 0.61.0 — 2026-06-22

### dynamic-workflows: adversarial review + deep-research workflows (S4, #441)

Reuses the proven S3 pattern across the four agents most exposed to
self-preferential bias and agentic laziness.

- **`code-reviewer` gains separate-context adversarial review** (D5): for
  non-trivial diffs (default `> 2 files`, configurable via the HARNESS.md
  `fan-out-threshold` field) it adapts `adversarial-review.workflow.js` so the
  reviewer works in a context window distinct from the implementer's, each
  CUPID + literate property checked by a dedicated verifier and findings
  synthesised, not collapsed. `MAX_REVIEW_CYCLES=3` still holds.
  **`advocatus-diaboli`** declares its role as the rubric-bearing adversary,
  read-only trust boundary unchanged.
- **`assessor` and `harness-auditor` gain deep-research mode** (D7): above a
  repo file-count threshold (`> 300`, configurable via the HARNESS.md field)
  they adapt `deep-assessment.workflow.js` to fan out by area, verify each
  finding in a separate agent, and synthesise a cited report. The auditor adds
  a **self-preference guard** — at least one verifier is adversarial to the
  framework's own assumptions, so it cannot grade its own homework. Output stays
  a timestamped artefact in the existing location/format.
- All four are Claude-Code-only with a non-erroring single-context fallback;
  INV-1 precision preserved (the ephemeral workflow proposes; the assessor/
  auditor still write their own report artefacts, which are not the four durable
  curated files). `commands/assess.md` and `commands/harness-audit.md` document
  the large-repo workflow path. Deterministic structural checks
  (`test_s4_adversarial_deepresearch_structural.py`) gate the declared contract.

## 0.60.0 — 2026-06-22

### dynamic-workflows: harness-enforcer fan-out mode (S3, #440)

The highest-leverage slice of the epic — defeats the enforcer's "35 of 50
constraints checked" lazy stop.

- **`harness-enforcer` gains a "Workflow mode" section**: when the enforceable-
  constraint count exceeds a threshold (**default 8, configurable per project
  via an optional `fan-out-threshold` field in HARNESS.md**; strict `>`
  trigger), the enforcer adapts `enforcer-fanout.workflow.js` to spawn **one
  verifier subagent per rule** plus a **skeptic** persona, reconciled at a
  **synthesis barrier** that waits for all N. At or below the threshold the
  single-context path runs unchanged — no workflow, no extra compute.
- **Count-equality guarantee (no silent drop)**: when it reports "all
  constraints checked", verifier results equal the enforceable count (`unverified`
  excluded). The first run records the skeptic's false-positive-reduction
  observation in REFLECTION_LOG.md for human curation — an observation, never a
  CI-verified metric.
- **`verification-slots` SKILL.md** documents the **fan-out slot** as a
  first-class agent-backed slot (one verifier per rule + skeptic + synthesis
  barrier) producing the same pass/fail + `{file, line, message}` contract.
- Workflow mode requires the Claude Code runtime; where it is absent the
  enforcer falls back to single-context behaviour and never errors. Read-only /
  propose-only — never writes a durable artefact (INV-1).
- Deterministic structural checks (`test_s3_enforcer_fanout_structural.py`) gate
  the declared workflow-mode contract in CI.

## 0.59.0 — 2026-06-22

### dynamic-workflows: template library + INV-1/INV-2 firewall (S2, #439)

The runnable substrate for the epic, plus the deterministic teeth that keep it
governed.

- **Four workflow templates** under `skills/dynamic-workflows/workflows/` —
  `enforcer-fanout`, `adversarial-review`, `reflection-mining`, and
  `deep-assessment`. Each is a template to **adapt, never run verbatim**, with a
  literate preamble naming its pattern, token budget, per-role model tiers, the
  INV-1 boundary it respects, and the Claude-Code-only runtime scope. A
  `workflows/package.json` (`type: module`) lets the `export const meta` +
  top-level-await DSL parse as the runtime expects.
- **INV-1/INV-2 firewall** (`scripts/inv-firewall.sh`) — one POSIX-portable
  matcher, invoked two ways: a PR-time gate
  (`.github/workflows/dynamic-workflows-firewall.yml`) and a Layer-0
  deterministic test with red/green fixtures. INV-1 strips comments then fails on
  any durable filename (`HARNESS.md` / `AGENTS.md` / `CLAUDE.md` /
  `MODEL_ROUTING.md`) appearing in executable code — so a literate preamble that
  merely *names* one passes, but a write fails. INV-2 fails if a declared
  `@untrusted-reader` agent's `@tools` names a high-privilege tool (write, edit,
  bash, commit, push). A consequence templates respect: durable artefacts are
  reached only through harness indirection, never spelled in code.
- **`SKILL.md`** flips the template library from "forthcoming (S2)" to shipped,
  referencing all four templates by resolving relative path; the how-to guide
  names them. The S1 markdownlint scenario that forbade template links is
  reconciled to assert the links now resolve.

## 0.58.1 — 2026-06-22

### dynamic-workflows: state the Claude-Code-only runtime scope in the skill

- **`skills/dynamic-workflows/SKILL.md`** gains a "Runtime scope — Claude Code
  only" section: dynamic workflows are a Claude Code runtime capability, **not
  transferable** to GitHub Copilot CLI or other coding agents. The skill is
  knowledge everywhere, runtime only on Claude Code; on a tree without the
  workflow runtime it is guidance only — readable, but no workflow can be
  spawned, and an agent there falls back to its static behaviour rather than
  erroring. Brought forward from S7 so the boundary is clear in the artefact
  agents actually read; the precise Copilot degradation *contract* (guidance-only
  vs omit) remains S7's open question.
- The `dynamic-workflows` how-to guide carries the same runtime-scope note.

## 0.58.0 — 2026-06-22

### dynamic-workflows: foundational skill + election discipline (S1, #438)

First slice of the Dynamic Workflows Alignment epic — the conceptual model the
rest of the epic references.

- **New `dynamic-workflows` skill** (`ai-literacy-superpowers/skills/dynamic-workflows/`):
  `SKILL.md` plus `references/{patterns,when-not-to-use,governance}.md`. Knowledge
  agents read, not a script they run — sibling to `harness-engineering` and
  `context-engineering`. Names the six composable patterns (classify-and-act,
  fan-out-and-synthesize, adversarial verification, generate-and-filter,
  tournament, loop-until-done), each with a worked micro-example.
- **Compute-discipline election rubric** (`references/when-not-to-use.md`): the
  four-question test — long-running, massively parallel, highly structured, or
  adversarial — with the default "if none apply, use the static pipeline", so
  workflows are elected, not reflexive. Advisory guidance, not a CI gate.
- **Governance invariants** (`references/governance.md`): INV-1 (ephemeral
  proposes, durable curates — workflows never write `HARNESS.md` / `AGENTS.md` /
  `CLAUDE.md` / `MODEL_ROUTING.md` directly) and INV-2 (quarantine
  untrusted-content readers from high-privilege tools), restated for agents.
- **`templates/MODEL_ROUTING.md`** gains a *workflow election* section: a
  per-workflow token-budget convention and a model-routing-classifier idea
  (Haiku/Sonnet/Opus tiering).
- **Docs**: new how-to guide and `### dynamic-workflows` reference entry; skill
  count reconciled to 36 (badge, plugin table, tree). Workflow *templates* and
  the INV-1 CI firewall are deferred to S2 (#439); SKILL.md only forward-references
  them.

## 0.57.0 — 2026-06-17

### planning: dynamic-workflows-alignment epic spec + carpaccio slicing (#438–#444)

Saved the Dynamic Workflows Alignment design (D1–D9) as the umbrella spec
(`docs/superpowers/specs/2026-06-22-dynamic-workflows-alignment-design.md`) and
sliced it into seven independently-shippable pieces via carpaccio rather than
landing it as one big change. Recorded human dispositions (all accepted) and
resolved three of four open questions (D3 threshold = 8; D4 routes opt-in for
v1; D6 staging = new `REFLECTION_STAGING.md`); Copilot degradation deferred to
the S7 build. Filed issues #438–#444, one per slice, in §6 dependency order.
Docs/planning only — no plugin change.

### harness: declare a cross-OS Layer 0 constraint (reflection follow-up)

Reflection from the affordances epic surfaced a recurring BSD-vs-GNU shell
portability trap in deterministic check scripts (`grep '\|'` is BSD-literal and
masked locally by the harness's `grep`→`ugrep` alias; `date -u -j -f` does not
pin UTC midnight on BSD). Declared a new `unverified` HARNESS.md constraint —
**Layer 0 bash tests run on macOS and Linux** — whose promotion to
`deterministic` is adding a `macos-latest` leg to the TDAD fast-suite matrix.
(Repo HARNESS.md only — no plugin change.)

### affordances: runtime invocation recorder + dead-inventory analyzer (#203)

Sequencing step 7 — the affordance section's runtime backbone.

- **`hooks/scripts/affordance-invocation-recorder.sh`** — a PostToolUse hook
  (registered in `hooks.json`) appending one minimal NDJSON tuple per `Bash` /
  `mcp__*` call to the gitignored `observability/affordance-invocations.json`.
  Built-in file tools are not recorded. **Privacy is enforced, not just
  declared**: the Bash `program` field strips env-var prefixes (`GH_TOKEN=…
  gh` → `gh`), `basename`s paths (`/a/b/deploy.sh` → `deploy.sh`), and accepts
  only a clean `^[A-Za-z0-9._-]+$` shape — no arguments, paths, secrets, or
  user identity. Uses grep/sed (no jq), never blocks, self-trims to 5000 lines.
- **`scripts/harness-affordance-invocations.sh`** — a report-only analyzer:
  `--check=freshness` (is the recorder operating?) and `--check=dead-inventory`
  (each declared, non-example, **non-hook** affordance observed within N days?).
  Bash matching is program-coarse and **conservative** (an observed program
  marks every Bash affordance sharing it as observed — a false-alive, never a
  false-dead); MCP/named matching is exact. Hermetic via `--today`; tolerates
  any malformed NDJSON line.
- **Local, per-machine.** The data file is gitignored (the user-confirmed
  answer to cross-machine merge), so the two GC rules and the checks are
  **local observability via `/harness-gc`, not CI governance** — stated
  honestly. A reference page documents the stable tuple format.
- Spec-mode `/diaboli` raised 12 objections (6 high), all adjudicated before
  implementation: keep the `.json` filename (the existing reference), sanitise
  the Bash program token so the no-secrets guarantee is real, recorder uses
  grep/sed (no jq silent-no-op trap), exclude hooks from dead-inventory, and
  frame the gitignored consequence honestly.

## 0.56.0 — 2026-06-16

### affordances: review subcommand + staleness GC rule (#202)

Sequencing step 6 of the harness-affordances epic — the per-affordance
staleness loop.

- **`/harness-affordance review <name>`** — interactive re-validation that
  bumps `Last reviewed` to today **only if all three checks pass** (Identity,
  Audit trail, Permission), each with an explicit `yes / no / needs-edit`
  prompt. A bump after any edit requires re-answering all three; a failing
  check leaves the date and records a single idempotent `[review-gap: <check>]`
  Notes line. Inline edits follow the same human-dictates/command-transcribes
  discipline as `add`.
- **`scripts/harness-affordance-staleness.sh`** — a deterministic, report-only
  scanner that flags non-example affordances (hooks **included**) whose
  `Last reviewed` is older than the threshold, or undated. UTC-normalised age
  (`--today` makes it hermetic). Threshold precedence: `--max-age-days` flag >
  a human-owned `<!-- affordance-review-threshold-days: N -->` marker the
  scanner reads from HARNESS.md > default 180.
- **Weekly GC**: a `gc.yml` step runs the scanner, prints findings to the step
  summary, and emits a `::warning::` when any exist (self-skips with no
  `## Affordances` section) — so the rule genuinely runs on the cron, not only
  via `/harness-gc`. A matching template GC rule (commented opt-in) covers the
  on-demand agent path.
- **Layer 0 tests** over the scanner (stale/fresh/undated, hook inclusion,
  example skip, threshold override, marker read, UTC determinism).
- Spec-mode `/diaboli` raised 10 objections (3 high), all adjudicated before
  implementation — the load-bearing fix wired the rule into `gc.yml` (a
  template GC rule alone is never run by the hardcoded cron) and made the
  scanner read the threshold from HARNESS.md rather than only a CLI flag.

## 0.55.0 — 2026-06-16

### affordances: chained constraints — declaration-vs-enforcement loop (#201)

Sequencing steps 4+5 of the harness-affordances epic: the asymmetric
constraint pair that checks the `## Affordances` section against the
permissions allowlist.

- **`scripts/harness-affordance-check.sh`** — one deterministic `shell + jq`
  script, two directions: `--direction=blocking` (affordance-without-
  permission, exits 1 on a gap) and `--direction=advisory` (permission-
  without-affordance, warns, always exits 0). Matching is **string equality**
  on the permission pattern.
- **Two-condition gate.** The check is `unverified` (exit 0, no-op) unless
  the section has a real (non-example) affordance **and** a project
  permissions allowlist is readable — so it never fires on un-migrated
  adopters or in CI without a committed allowlist. Example entries (marked
  `<!-- affordance-example -->`) and hook-mode affordances are skipped.
- **Two constraint entries** in the HARNESS.md template's `## Constraints`
  (commented opt-in, `Scope: pr`); adopters pick them up via
  `/harness-upgrade`. The step-3 example entries gain the per-entry marker.
- **Layer 0 tests** exercise all acceptance scenarios against hermetic
  fixture directories (the check takes a project-dir argument).
- Spec-mode `/diaboli` raised 12 objections (1 critical, 4 high); all
  adjudicated before implementation — the critical caught that hook
  affordances would false-fire the blocking check (now skipped), and the
  enforcement model (pr scope, honest self-gating) was user-confirmed.

## 0.54.0 — 2026-06-16

### affordances: HARNESS.md section + guided `/harness-affordance add` (#200)

Sequencing step 3 of the harness-affordances epic makes the discovery
scanner's inventory a first-class part of the harness.

- **`templates/HARNESS.md` `## Affordances` section** — a top-level section
  (after Garbage Collection, before Status) carrying the field schema in
  comments, a reference to `observability/affordance-invocations.json`, and
  four worked example entries (cli, central-mcp, current-user cli, hook).
- **`/harness-affordance add <name>`** — replaces the stub with a guided
  flow: seed from the newest discovery draft (matched by permission pattern),
  prompt for the governance fields (Identity with five-value framing, Audit
  trail with "none is fine" guidance), auto-date `Last reviewed`, validate
  (required fields, Mode/Trigger pairing, permission existence across project
  **and** user settings — warn, not block), and write idempotently. Re-runs
  edit in place keyed on the **permission pattern**, not the heading name, so
  a rename never duplicates an entry.
- **`/harness-init`** gains Affordances as a sixth, opt-in (default off)
  feature; **`/harness-status`** counts declared affordances.
- **Docs** — new explanation (the contractor scenario, identity as the
  load-bearing field, the source-of-truth split) and reference (field-by-
  field schema) pages; the discover how-to updated for `add`.
- **Tests** — a Layer 0 test validates the template's example entries against
  the schema (required fields, Mode/Trigger pairing, date format).
- Spec-mode `/diaboli` raised 12 objections (3 high); all adjudicated before
  implementation (idempotency keys on permission pattern; `add` reads user
  settings; concrete init integration; direct-write confirmed).

## 0.53.3 — 2026-06-16

### docs: exploration findings for microsoft/AI-Engineering-Coach (#340)

Investigation-only findings doc at
`docs/superpowers/explorations/2026-06-16-ai-engineering-coach-findings.md`
mapping the MS project's concepts to our surfaces. Key framing: MS coaches
from *behavioural* session-log evidence, we assess from *habitat* artifacts —
so most features have a mature analog here and the additive ideas are the
behavioural ones. Recommends five follow-ups (R1 behavioural lens, privacy-
gated; R2 mine their rule taxonomy; R3 agentic-readiness checklist; R4
skill-finder angle; R5 decline gamification) and flags MIT attribution rules.

### compound learning: promote three dispositioned findings (#339, #347, #348)

Curation pass landing three choice-cartographer findings that the human had
already dispositioned `promoted`, turning recurring lessons into standing
guardrails (no plugin version bump — convention files only).

- **#339** → `CLAUDE.md` Marketplace Versioning: a cross-PR coordination rule
  for `marketplace.json`'s `plugin_version` (owned by `ai-literacy-superpowers`
  PRs; non-owning PRs take main's value verbatim). Specs can now reference the
  convention instead of restating the merge-time rule per spec.
- **#347** → `AGENTS.md` ARCH_DECISIONS: "schema evolution routes by fact
  granularity" — per-element facts use a per-element field with a string
  prefix; model-level facts earn an additive wrapper field; audit entries keep
  a single writer.
- **#348** → `AGENTS.md` ARCH_DECISIONS: "dispatcher-first error contracts for
  agent output" — structured output for programmatic consumers must spec a
  single-line, pattern-matchable refusal shape emitted instead of the success
  block, with no silent fallback (third-occurrence promotion).

### auto-enforcer: record deterministic results without source interpolation (#424)

The `Run deterministic constraints` step in `templates/ci-auto-enforcer.yml`
built a `python3 -c "…"` body by shell-interpolating each tool's stdout into
a triple-quoted Python literal. Any tool that printed `'''` (or other quote
characters) terminated the literal early and raised a `SyntaxError`, failing
the whole step — so a tool that **passed** could still break the run, and the
interpolation was a latent injection vector.

- The step now uses the same safe heredoc-argv pattern as the agent and
  comment steps: a single-quoted heredoc (no shell expansion) with the
  results file, name, status, and tool output passed via `sys.argv` *after*
  the source is parsed, so no character in tool output can corrupt the script.
- Layer 0 coverage added: tool stdout containing `'''`, `"`, `"""`, and
  shell-like `$(…)` text is recorded verbatim; a PASS result records `--`.
  Verified to SyntaxError against the pre-fix interpolation form (RED→GREEN).

## 0.53.2 — 2026-06-15

### auto-enforcer: four PR-enforcement bug fixes (#322, #323, #324, #325)

Four defects in `templates/ci-auto-enforcer.yml` quietly degraded PR-time
constraint enforcement for every adopter of the GitHub Action.

- **#325 — duplicate constraint rows.** The constraint parser appended
  the final block at section exit **and** again at the EOF flush, so any
  `HARNESS.md` with a `##` section after `## Constraints` ran (and listed)
  its last constraint twice. The section-exit path now resets state and the
  trailing flush is gated on still being inside the section.
- **#324 — truncated multi-line rules.** `parse_field` returned only the
  first physical line of a `Rule:`, so multi-paragraph agent constraints
  reached the model half-stated (the agent even reported the rule as
  "incomplete"). It now folds continuation lines until the next list item.
- **#323 — COMMENT_MODE never applied.** `comment_mode = "${COMMENT_MODE}"`
  inside a single-quoted heredoc was a literal string, so `findings-only`
  never suppressed all-PASS comments. The value is now passed as a
  positional argv. `SKIP` also counts as a finding so a silently-disabled
  gate still surfaces a comment.
- **#322 — no retry on transient overload.** A single `urlopen` with a
  broad `except` turned an Anthropic `429`/`529` into a `SKIP`pped
  enforcement gate. Agent calls now retry transient overloads with backoff
  (2s, 4s), retry one network error, and fail fast on non-transient HTTP
  errors; a half-second pace between agent calls flattens the burst.
- **Tests.** New Layer 0 suite (`test-auto-enforcer.sh`) extracts the real
  embedded Python from the template and exercises all four fixes — nine
  cases, verified to fail against the pre-fix template (RED→GREEN).

## 0.53.1 — 2026-06-15

### reflections: verify_rhs recognises CLAUDE.md + .claude/HARNESS.md promotions (#319, #320)

`verify_rhs` (the Path 1 archival pre-check) rejected valid, documented
promotion forms, so `archive-promoted-reflections.sh` kept those entries
in the active set forever.

- **#320 — HARNESS path resolution.** The check hard-coded `HARNESS.md`
  at the repo root, but the plugin's own `/superpowers-init` scaffolds to
  `.claude/HARNESS.md`. A canonical `Promoted: → HARNESS.md: <constraint>`
  line therefore never verified in projects that follow the recommended
  layout. A new `resolve_file` helper now resolves the constraint heading
  against the repo root **or** the `.claude/` scaffold; `propose_for_entry`
  uses the same resolution.
- **#319 — CLAUDE.md and explicit .claude paths.** Promotions to
  `CLAUDE.md` (root or per-component `<subdir>/CLAUDE.md`) and the explicit
  `.claude/HARNESS.md: <constraint>` form fell through to a rejection.
  `verify_rhs` now models a `CLAUDE_FORM` (verifies the quoted excerpt in
  the named CLAUDE.md) and accepts the `.claude/HARNESS.md:` alias. The
  formal grammar in the archival spec and the RHS-form lists in `/reflect`
  and the integration-agent are updated to match.
- Layer 0 coverage added: eight `verify_rhs` unit cases plus an end-to-end
  archival case proving a `.claude/HARNESS.md`-only project archives.

## 0.53.0 — 2026-06-15

### reflections: one-file-per-entry storage + union-merge default (#398)

`REFLECTION_LOG.md` was a single, shared, append-only file. Every
reflection PR appended at the same EOF location, so any two PRs cut from
the same base conflicted at the same spot — and when that conflict was
resolved against an already-merged block, a committed reflection was
**silently dropped** (the PR merged green and the entry simply wasn't on
`main`). This was an emergent property of the storage design, observed
downstream, not a one-off mistake.

- **Source of truth is now per-entry fragments.** `/reflect`, the
  integration-agent, and the assessment skill write each reflection as
  its own file under `reflections/active/<YYYY-MM-DD>-<slug>.md` (body
  only, no leading `---`). Two reflections authored concurrently never
  touch the same path, so the append-contention — and the silent-drop
  failure — disappears at the source.
- **`REFLECTION_LOG.md` becomes a generated aggregate.** It stays
  committed (like a lockfile) and is deterministically regenerated from
  the fragments in Date order by the new
  `scripts/regenerate-reflection-log.sh`, so all existing readers
  (agents, GC rules, health/status commands, observability) keep working
  unchanged. A messy interim union merge self-heals on the next
  regeneration because the fragments are canonical.
- **Union-merge default shipped.** A root `.gitattributes` (and a
  `templates/gitattributes` scaffolded by `/superpowers-init`) applies
  git's built-in `merge=union` driver to `REFLECTION_LOG.md` and
  `reflections/archive/*.md`, so even an un-migrated monolith or two
  concurrent GC runs can never drop content.
- **Archival preserved on fragments.** `archive-promoted-reflections.sh`
  now moves promoted fragments to `reflections/archive/<YYYY>.md`,
  deletes them, and regenerates the aggregate; the Promoted-line grammar
  and archive format are unchanged. The weekly GC workflow counts and
  commits fragments instead of monolith entries.
- **One-time migration.** New `scripts/split-reflection-log.sh`
  (idempotent) splits an existing monolith into fragments and
  regenerates the aggregate, preserving Promoted lines and the existing
  archive. This repo's own 49-entry log was migrated as part of this
  change (verified lossless: all 591 content lines preserved).

## 0.52.1 — 2026-06-15

### gc-rotate: scope shell-script GC rules to project-owned files (#361)

The rotating GC check's shell-syntax (rule 2) and strict-mode (rule 3)
rules scanned **every** `*.sh` under the project, excluding only
`*/.git/*`. In non-trivial projects this pulled in vendored, generated,
and untracked scripts and flooded the session-end banner with
false positives — `bash -n` choking on `zsh` snapshots written under
`CLAUDE_CONFIG_DIR`, `node_modules` scripts, and nested worktrees that
were never meant to follow this plugin's conventions.

- **Scope to tracked files.** Both rules now enumerate scripts via a new
  `list_owned_shell_scripts` helper that uses `git ls-files -z -- '*.sh'`,
  which skips `node_modules`, nested worktrees, `CLAUDE_CONFIG_DIR`
  snapshots, and build output for free. Paths are re-anchored to
  `PROJECT_DIR` and the loops read NUL-delimited entries so paths with
  spaces survive.
- **Graceful fallback.** Outside a git repo the helper falls back to the
  previous `find` walk, so non-git projects are unaffected.

## 0.52.0 — 2026-06-15

### cost-estimation: single-source the family stem table + deterministic drift guard (#414)

Keeps the v0.50.0 tier→model family stems (`claude-opus-4`,
`claude-sonnet-4`) **singly-sourced and internally consistent** as model
generations roll over.

- **Declared canonical source.** The binding table in
  `skills/cost-estimation/references/estimate-record-format.md` now carries
  an authoritative, parseable `canonical-estimating-tier-family-stems`
  block — the single source the other cost files reference.
- **Add-and-retire maintenance note** (not replace-in-place): a new
  generation **adds** a stem (both coexist while transition snapshots may
  carry either — consistent with cross-generation family aggregation); a
  stem is **retired** only when no snapshot in the retention window carries
  its family; never silently replaced (which would regress a
  transition-quarter snapshot to omission).
- **Deterministic drift guard.** A CI-gated Layer-1 structural test
  (`tdad_tests/tests/test_layer1_structural.py`,
  `TestCostEstimationStemConsistency`) asserts that no consumer cost file
  references an estimating-tier family stem absent from the canonical set
  (every `claude-opus-*`/`claude-sonnet-*` family token must resolve, by
  the delimiter-bounded stem rule, to a declared stem; documented
  delimiter counter-examples like `claude-opus-40` are exempt). A future
  stem bump that desyncs the files fails CI loudly.

**Design pivot (spec-mode diaboli).** The slice originally proposed a
periodic GC staleness rule reading the latest snapshot; the diaboli refuted
it (false-positive every cheap-tier-only month; false-negative on a
*staggered* rollover; the agent has no stem logic; only the rule's
existence was testable) and noted external staleness is already covered by
the loud disclosed omission/proxy of #412 and #413's capture-time
advisory. The human disposed the design to **drop the GC rule** and ship
the deterministic
mention-consistency check + canonical source instead. Option 2 (derive
stems from `MODEL_ROUTING.md`) was rejected — its only family names are
illustrative HTML-comment examples; routing uses abstract tiers.

**Decision discipline** — spec at
`docs/superpowers/specs/2026-06-15-cost-estimation-stem-table-maintenance-design.md`;
spec-mode diaboli at
`docs/superpowers/objections/cost-estimation-stem-table-maintenance-design.md`
(12 objections — 5 high — all accepted). Closes #414.

## 0.51.0 — 2026-06-15

### cost-capture: capture-time binding-gap advisory (#413)

`/cost-capture` now tells the human, **at capture time**, whether the
prospective `cost-estimation` sibling will be able to ground a dollar
figure against the snapshot just written — closing the binding-gap
feedback loop one step earlier than the per-estimate discovery #411
suffered.

- **Informational, never a gate.** A new advisory step (after structural
  validation, before commit) emits no pass/fail token, never alters the
  snapshot's cost data, and runs regardless of the validation result. A
  thin snapshot remains a perfectly valid cost snapshot.
- **A thin family-presence check, not a pricing re-run.** It applies the
  `cost-estimation` binding table's family-stem + delimiter rule **by
  reference** to detect which estimating-tier families (`claude-opus-4` /
  `claude-sonnet-4`) are present — it does **not** re-implement
  aggregation, rate derivation, or proxy selection (those stay
  estimator-only, so there is no second copy of the pricing logic).
- **A structured, checkable artefact.** The outcome is recorded as a
  `Cost-estimate grounding:` line in the snapshot's `## Observations`
  (and echoed in the capture summary): `grounds` / `proxied (<absent
  tiers>)` / `omitted (no estimating-tier family)` / `omitted (no
  per-model breakdown)` — so the advisory is falsifiable and a consumer
  can corroborate it.
- **Conditional, honest wording.** Proxy advisories are conditioned on a
  future target *exercising* the absent tier; the no-estimating-family
  case is the unconditional "will omit". The advisory distinguishes
  *thin because data wasn't recorded* (actionable) from *thin because the
  period genuinely used only some tiers* (not a defect) and **never**
  nudges fabricating a model row for spend that did not occur.

Touches `commands/cost-capture.md` and `skills/cost-tracking/SKILL.md`
(the snapshot format gains the `Cost-estimate grounding:` Observations
line and an estimating-tier-coverage pointer). Pure consumer of the
v0.50.0 family-stem rule — no binding, proxy, or format-field change.

**Decision discipline** — spec at
`docs/superpowers/specs/2026-06-15-cost-capture-binding-gap-warning-design.md`;
spec-mode diaboli at
`docs/superpowers/objections/cost-capture-binding-gap-warning-design.md`
(10 objections — 3 high — all accepted; the highs reshaped it to a thin
presence check writing a structured, falsifiable line). Closes #413; the
stem-table-maintenance sibling is #414.

## 0.50.0 — 2026-06-15

### cost-estimation: tier→model family matching + disclosed cross-tier proxy (#411)

Fixes the silent cost-omission #411 surfaced: the cost-estimation binding
matched representative model keys **literally** (`claude-opus-4`,
`claude-sonnet-4`), but real snapshots key their Model Breakdown by the
**actual** model ids (`claude-opus-4-8`, …), so every estimate omitted
cost even when a snapshot existed to ground it.

- **Family matching (the core fix).** A snapshot key now resolves to a
  tier's representative **by family stem** — it matches iff it starts with
  the stem (`claude-opus-4` / `claude-sonnet-4`) **and** the next character
  is `-` or end-of-string (so `claude-opus-4-8` → Most capable;
  `claude-opus-40` does **not** match). Multiple rows in one family
  aggregate into one blended rate, disclosed when >1. Only
  `claude-opus-4` / `claude-sonnet-4` are estimating-tier families; haiku
  and others bind to no tier. The stems are a maintained table (bumped per
  model generation); a renamed family is a *signalled* miss (omission),
  never a silent wrong rate.
- **Disclosed cross-tier proxy (Option B′).** When an exercised tier's
  family is **absent** but ≥1 estimating-tier family resolves, the missing
  tier is **priced by a proxy** at the dearest present family's rate rather
  than omitted — but as a **distinctly-typed, disclosed** figure: a new
  additive `cost_basis` value **`snapshot-actuals-proxied`** (machine-
  distinguishable from direct `snapshot-actuals`), with
  `failure_direction: likely-overrun` and `confidence.cost: low` forced and
  every proxied tier named. The proxy uses only observed snapshot rates —
  never a vendor list price (the no-list-price-fallback rule is intact).
- **Validator changes.** The `cost_basis` enum gains
  `snapshot-actuals-proxied`; the "Split-tier spread" check exempts a
  proxied (`snapshot-actuals-proxied`) split-tier band from the strict
  `low < high` requirement (a cross-tier proxy legitimately collapses it);
  the cost-pairing check requires a proxied record to carry the forced
  overrun/low-confidence/disclosure trio. The three grounding states /
  closed omission set are restated under family resolution.

Touches the format reference (`skills/cost-estimation/references/estimate-record-format.md`),
the skill (`skills/cost-estimation/SKILL.md`), and the `cost-estimator`
agent in lockstep.

**Decision discipline** — spec at
`docs/superpowers/specs/2026-06-15-cost-estimation-family-matching-design.md`;
spec-mode diaboli at
`docs/superpowers/objections/cost-estimation-family-matching-design.md`
(12 objections — 2 critical, 4 high — all accepted; the two criticals
broke the naïve proxy and drove the engineered Option B′). Closes #411.

## 0.49.0 — 2026-06-14

### cost-estimator: populate per-stage cost_usd bands on cost-present records

- **Per-stage `cost_usd` bands (#380).** Now that the repo has a usable cost
  snapshot (`observability/costs/2026-06-13-costs.md`), the cost-estimator
  emitter honours the #377 §4.3.1 SHOULD obligation: on a **cost-present**
  record it populates a `tokens_by_stage[].cost_usd` `{ low, high }` band on
  every exercised stage (stage `tokens` × tier `$/token`), with split-tier
  stages priced cheaper-at-low / dearer-at-high so the spread is strictly
  positive (`low < high`). Cost-omitted records are unchanged (no per-stage
  band; the one-directional coupling forbids a band without the whole-record
  `cost_usd`). The pricing convention is referenced from the format spec, not
  redefined; no format change and no new validation-rejection rule. Behaviour
  change to a shipped agent — minor bump. Spec:
  `docs/superpowers/specs/2026-06-14-per-stage-cost-bands-emitter-design.md`.

## 0.48.1 — 2026-06-14

### cost-estimator: normalise the split-tier model_tier literal

- **Consistent `Standard/Capable` literal (#381).** The cost-estimator agent
  charter referred to the split tier as `Standard / Capable` (spaced) in its
  Split-tier widening note while the format reference binding table records the
  literal as `Standard/Capable` (unspaced). Normalised the charter to the
  unspaced form so an exact-string consumer of `model_tier` sees one emitted
  shape. The whitespace-insensitive comparison note (which deliberately shows
  both forms are equivalent) is unchanged. Doc-only; patch bump.

## 0.48.0 — 2026-06-14

### Reservoir warden — watching the verifier the harness cannot verify

The framework's first observability surface aimed at the **human verifier**
rather than the session output. Every other enforcement mechanism checks what
an agentic session produced; none checked the state of the human who approves
it. This adds a read-only, advisory watch — opt-in per project, never a gate.
New skill + agent + command + hook — minor bump.

- **`cognitive-reservoir` skill (new).** The shared grounding: four observable
  proxies (session span, decision volume, context switches, wall-clock hour),
  the `observed`/`inferred`/`asked` confidence discipline, disjunctive default
  thresholds (span 180 min, decision volume 8, context switches 4, window 8 h),
  the one firm principle, six-level scaling, and the honesty rule that keeps
  contested science (ego depletion, the hungry-judges study) out of the
  mechanism's assertions while standing on the robust basis (vigilance
  decrement, task-switching cost).
- **`reservoir-warden` agent (new).** Read-only on the human (tools: Read,
  Glob, Grep, Bash — no Write, no Edit). Counts the proxies via `git`/`date`,
  reports each with a confidence flag, and offers the single
  decide-your-stop-first recommendation when a threshold is crossed. Persists no
  record of the human's state; produces no combined fatigue score. Routed to an
  inexpensive tier in `MODEL_ROUTING.md`.
- **`/reservoir` command (new) + Copilot prompt.** Read mode dispatches the
  agent for a fuller read; Tune mode helps you edit the HARNESS.md block
  (thresholds and an optional `chronotype`), proposing edits to confirm.
- **`reservoir-check.sh` Stop hook (new).** Self-gates on an active
  `## Cognitive reservoir` heading and a git repo, computes the proxies over the
  recent window, and emits at most one `{"systemMessage": ...}` advisory.
  Advisory-only: never blocks, never exits non-zero, never asserts ego depletion
  or the hungry-judges figure.
- **HARNESS template (updated).** Ships an optional, commented `Cognitive
  reservoir` block (inert until uncommented) with the `chronotype` field and a
  not-a-constraint note.
- **AGENTS.md ARCH_DECISION (new).** Records that the verifier-watch is
  advisory-only and must never be promoted into a CI gate or a single fatigue
  score, so a future contributor does not "improve" it into one.
- **Docs + TDAD.** New explanation and how-to pages, reference entries for the
  new skill/agent/command/hook, and four TDAD scenarios (read-only boundary,
  fires-on-long-session, silent-when-quiet, silent-when-not-opted-in); the test
  runner gains hook-component discovery.

## 0.47.0 — 2026-06-12

### Calibration loop — per-PR actuals capture (S6 of the cost-estimator pipeline)

Closes the calibration seam S1 deliberately left open: the estimator now learns
from **this repo's own history** instead of only the generic `MODEL_ROUTING.md`
budgets. The final slice of the cost-estimator pipeline. New integration-agent
responsibility + new actuals format + calibration ingestion — minor bump.

- **Per-PR actuals format (new).** A single-task, structural sibling of the
  quarterly provider snapshot, owned by the `cost-tracking` skill
  (`references/per-pr-actuals-format.md`) and stored under
  `observability/costs/per-pr/`. Captures which stages ran, review cycles, files
  and languages touched, plus token/cost figures **when a human supplies them**.
- **Integration-agent capture (new Step 1a).** At integration time — after the
  CHANGELOG, before the commit, so the record **ships in the PR** and never
  commits to `main` — the integration-agent auto-captures the structural facts and
  records human-supplied `/cost` figures, marking them `unavailable` otherwise.
  **Non-blocking and never fabricates a figure**: a subagent can't read per-PR
  tokens programmatically, and the repo's no-fabrication rule forbids inventing
  them, so `unavailable` is explicit and is never `0`.
- **Calibration ingestion — token ranges only.** The `cost-estimation` methodology
  and the `cost-estimator` agent now read accumulated per-PR records as a
  `kind: calibration` grounding source to **narrow the per-stage token ranges**
  (and may raise the `tokens` confidence) against repo history, disclosed in
  `Confidence rationale`. The `$/token` ground stays the snapshot
  (`cost_basis: snapshot-actuals`) — calibration refines tokens only.
- **No estimate-record format change.** True to the S1 seam, calibration ships as
  the already-permitted `kind: calibration` `grounding_sources[]` entry plus a
  disclosure — no field added, removed, or retyped. Zero history degrades cleanly
  to the pre-S6 generic-budget behaviour.
- **Docs** — the prospective-cost-estimation concept page gains a calibration-loop
  section; the cost-tracking skill documents its two actuals records (quarterly
  snapshot + per-PR).

## 0.46.0 — 2026-06-12

### Orchestrator T0 pre-carpaccio ballpark (S5 of the cost-estimator pipeline)

Adds the earliest, weakest insertion point: a coarse whole-task cost **ballpark**
from raw task text only, surfaced **before carpaccio** as a non-blocking go/no-go
sniff-test. Completes the T0/T1/T2 insertion picture (T1/T2 shipped in 0.45.0).
Behavioural change to the orchestrator agent — minor bump.

- **T0 (new Step 3 of "Before dispatching carpaccio").** After branch and issue
  creation and immediately before carpaccio, the orchestrator dispatches the
  `cost-estimator` **once** against the issue body as an inline `task-text` target
  (the `low` confidence ceiling) and surfaces a **loud low-confidence** ballpark
  framed as a "sniff-test, not an estimate to plan against".
- **Inline-only and ephemeral — a deliberate asymmetry with T1/T2.** T0 writes
  **no file** and runs **no checkpoint**, and is **not** threaded into the context
  object. The gate-folded T1/T2 estimates persist (decision-support with audit
  value); the earliest, least-accurate sniff-test stays ephemeral so a
  low-confidence raw-text number never reads as an authoritative artefact — the
  structural answer to the anchoring risk the slice flags.
- **Non-blocking, no gate, no verdict.** T0 adds no pause, no keypress, and no
  go/no-go prompt; the orchestrator proceeds to carpaccio regardless. A `REFUSED:`
  string or a dispatch error surfaces "T0 ballpark unavailable" and the run
  continues exactly as today.
- **Pure consumer of S1/S2.** No change to the estimate-record format, the
  `cost-estimator` agent, or the `/cost-estimate` command.
- **Docs** — the prospective-cost-estimation concept page now describes the full
  T0/T1/T2 picture with the inline-only-vs-persisted asymmetry; the
  agent-orchestration page notes the pre-pipeline ballpark.

## 0.45.0 — 2026-06-12

### Orchestrator cost fold-in at T1 and T2 (S4 of the cost-estimator pipeline)

Wires the read-only `cost-estimator` agent into the orchestrator's **existing**
human-disposition gates as **informational fields, never a new gate**. The
highest-value insertion the carpaccio slicing record names — cost surfaces at the
moment it most changes a choice. Behavioural change to the orchestrator agent —
minor bump.

- **T1 — Slice Adjudication gate (new Step 2a).** After carpaccio's record is
  validated and before it is surfaced, the orchestrator dispatches the
  `cost-estimator` **once per slice in parallel** (explicit `target_kind: slice`),
  persists each returned record under `cost-estimates/<date>-<task-slug>-<slice-id>-estimate.md`,
  runs the S3 Output Validation Checkpoint on each, and appends a **compact
  one-line-per-slice** cost summary (tokens, cost-or-"not grounded", confidence,
  failure direction) to that slice's block — so the human sees cost while choosing
  which slice to progress.
- **T2 — Plan Approval gate (new Step 6a).** After the choice-story soft gate and
  before the Plan Approval prompt, the orchestrator dispatches the estimator
  **once** against the progressed slice's spec (explicit `target_kind: spec`, the
  pipeline's highest confidence ceiling), persists + validates it, and surfaces a
  fuller cost block (tokens, agent-compute time, cost, **verbatim `human_gate_time`
  caveat**, excluded pointer) alongside `cartograph_pending_count`.
- **Informational, never a decision point.** Both fold-ins mirror the existing
  `cartograph_pending_count` treatment: no block, no extra keypress, no agent
  writes dispositions. The estimate carries no recommendation or verdict; the
  human reads the ranges and disclosures and makes the **existing** slice /
  plan-approval choice.
- **The gate never degrades.** A `REFUSED:` string, a dispatch error, or a
  checkpoint abort reduces the affected target's estimate to "unavailable" and the
  existing gate proceeds exactly as today — the estimate is purely additive.
- **Pure consumer of S1/S2/S3.** No change to the estimate-record format, the
  `cost-estimator` agent, or the `/cost-estimate` command. The orchestrator owns
  the write (the agent stays read-only) and reuses the S3 persistence + checkpoint
  discipline by reference. New context-object fields (`t1_estimate_slugs`,
  `t1_estimate_refused_count`, `t2_estimate_slug`, `t2_estimate_grounded`) make the
  estimate state readable by observability tooling.
- **Docs** — the prospective-cost-estimation concept page's "future orchestrator
  fold-in" forward-reference is now present-tense; the agent-orchestration
  explanation page notes the fold-in at both gates.

## 0.44.0 — 2026-06-12

### New command — `/cost-estimate` (S3 of the cost-estimator pipeline)

Ships the standalone manual dispatcher for the read-only `cost-estimator` agent —
the **prospective** sibling of the retrospective `/cost-capture`. New command —
minor bump.

- **`/cost-estimate <target> [--kind <target-kind>] [--out <dir>]`** — point it at
  a slice, a spec, a slicing record, or pasted task text and it estimates the
  target's tokens, agent-compute time, and (only when a cost snapshot grounds it)
  cost, then writes the estimate record to disk. One target per invocation
  (matching the agent's one-target-per-dispatch contract); path vs inline text
  resolved by filesystem lookup; `--kind` forwards an explicit `target_kind` to the
  agent; the `--near` sketch is dropped. The command is a **pure consumer** of the
  S2 agent and the S1 format reference — it redefines neither.
- **Dispose-then-write ordering** — the command owns the single `Write`; the agent
  stays read-only. The human disposition (`accept` / `edit` / `re-run` / `abort` —
  the full vocabulary) **precedes** the write. On `REFUSED:` the refusal is
  surfaced verbatim with no checkpoint and no file.
- **Output Validation Checkpoint** — reads the returned record back and checks it
  against every line of `estimate-record-format.md`'s validation checklist
  (including the #377 per-stage cost coupling and split-tier strict-spread checks),
  **fixing only structural-only deviations in place** (routinely just deleting a
  stray verdict field) and **aborting — never authoring — on any derived-value
  defect**. The review summary surfaces a change-list of exactly what was altered,
  flags a human-asserted `--kind` as asserted-not-inferred, and honours the
  grounding-path trailing-slash sentinel in its own summary consumption. The `edit`
  path is validate-and-report, never silently reverting a human edit.
- **Output home** — default `cost-estimates/<YYYY-MM-DD>-<target-slug>-estimate.md`,
  a new top-level directory **outside** `observability/` (predictions are not
  telemetry); `--out` overrides the directory; same-day collisions are
  disambiguated under both, never silently overwritten. `cost-estimates/` is added
  to `.gitignore` as a derived, regenerable artefact.
- **Docs and discipline** — `/cost-estimate` joins the CLAUDE.md Output Validation
  Checkpoints list; a how-to guide and a reference-page entry ship in the same PR.
- **Code-mode adversarial hardening** — eight `advocatus-diaboli` code-mode
  objections closed executor-latitude seams in the command prose: the
  `<target-slug>` is sanitised to a single `[a-z0-9-]` path segment
  (write-target-injection closed); `REFUSED:` detection is anchored to the
  untrimmed first line; a pre-classification test routes a *stray verdict field*
  to FIX and a *prose verdict* to ABORT (so the checkpoint never edits the agent's
  judgment); the change-list is a diff of the retained original, not a narration;
  the checkpoint takes an explicit `fix-in-place | validate-and-report` mode; and
  the same-day collision is re-checked at write time (TOCTOU gap closed).

## 0.43.0 — 2026-06-11

### Format revision — per-stage `cost_usd`, `generated_by` grammar, grounding-path sentinel

Ships the format-revision slice (#377): a backward-compatible revision of the
`cost-estimation` skill's estimate-record format reference, resolving three
deferred residues from the S1/S2 reviews. Format/schema change to a plugin
reference file — minor bump. No new skill, agent, or command.

- **Per-stage `cost_usd` sub-field** — `references/estimate-record-format.md`
  gains an optional `tokens_by_stage[].cost_usd` `{ low, high }` range,
  **one-directionally coupled** to top-level `cost_usd` (sub-field present ⟹
  top-level present is enforced; top-level present ⟹ bands SHOULD be populated
  is an emitter obligation, not a rejection rule — **not** an `iff`, so S1-era
  cost-present records without bands stay valid). Makes a split-tier band's
  non-collapsed (strictly-spread) shape record-internally checkable.
- **Two new validation-checklist lines** — *Per-stage cost coupling* (forbids
  the incoherent inverse: a per-stage band with no whole-record cost) and
  *Split-tier spread* (a present split-tier band, identified by the closed
  `model_tier` contains-`/` rule, must have a strict `low < high`). A §4.4.1
  CAN/CANNOT note states the honest floor: the validator can assert
  presence/coupling, `low ≤ high`, and strict spread, but cannot assert the
  band spans two tiers or equals the absolute snapshot rates — that
  absolute-rate check defers to S3.
- **Example 2 re-derived** from two fixed per-tier rates (sonnet `4.0e-6`, opus
  `2.0e-5` $/token): spec-writer `{1.00, 2.00}`, tdd-agent `{0.20, 0.60}`,
  implementer `{0.40, 5.00}`, summing to the whole-record `{1.60, 7.60}`.
  Example 1 (cost-omitted) carries no per-stage band.
- **`generated_by` grammar widened** — the field description admits a
  `tier:<tier>` routing-tier label alongside a concrete model id, with `tier:`
  defined as a reserved provenance prefix (a concrete model id never begins with
  `tier:`) so consumers can distinguish the two forms with no rejecting check.
  Makes the merged S2 agent's `tier:Standard` output documentation-conformant.
- **Grounding-path sentinel documented** — the trailing-slash directory
  `observability/costs/` is the defined cost-omitted sentinel; the reference
  names that this entrenches an overloaded `path` meaning (file = grounded;
  directory = looked-and-found-nothing) and carries the consumer special-case
  (an aggregator must not count a trailing-slash path as a grounding), noted as
  advisory/unenforced.

## 0.42.0 — 2026-06-11

### New agent — `cost-estimator` (read-only prospective-cost emitter)

Ships S2 of the cost-estimator capability: the read-only agent that *produces*
an estimate record. S1 (0.41.0) shipped the methodology and the format
contract; this slice ships the emitter that consumes them. No command or
orchestrator wiring ships here (S3/S4, out of scope).

- **`agents/cost-estimator.agent.md`** — a `Read, Glob, Grep`-only emitter
  (`model: inherit`). Given a target (raw task text, slicing record, slice, or
  spec), it reads `MODEL_ROUTING.md` and the latest `observability/costs/`
  snapshot, applies the `cost-estimation` skill, and **returns the
  estimate-record content as a string** for a dispatcher to persist after a
  human disposes — the next instance of the AGENTS.md agent-emit +
  dispatcher-persist + human-disposes pattern and its dispose-then-write
  ordering invariant. It never writes, validates, or decides go/no-go.
- **Target classification** drives the S1 confidence ceiling; any inferred
  `target_kind` discloses its inference basis (`classified as <kind> by
  <signal>`) so a confident mis-read is human-catchable, and ambiguous targets
  resolve to the lower-grounding candidate with disclosure.
- **Mechanical cost-omission**: omits `cost_usd` (with disclosure) whenever any
  exercised stage tier is unmapped by the binding table — after the S1 join-key
  normalisation — or a named model key is missing, with no salience judgment.
- **Refusal discipline**: a machine-greppable `REFUSED:` string on an
  unreadable/unclassifiable target or an absent/tableless `MODEL_ROUTING.md`;
  an empty `observability/costs/` is a cost-omitted record, **not** a refusal.
- **Provenance**: `generated_by` carries the dispatcher's resolved model id when
  supplied, else the honest routing-tier label `tier:Standard` — never a guessed
  model string.
- `MODEL_ROUTING.md` gains an Agent Routing row for `cost-estimator` at the
  **Standard** tier (read-and-author, like `tdd-agent`).
- Docs: a reference entry in
  `docs/plugins/ai-literacy-superpowers/reference/agents.md` and an emitter
  section added to the `prospective-cost-estimation.md` explanation page.

## 0.41.1 — 2026-06-11

### Fix — reconcile advocatus-diaboli objection taxonomy

- Completed the abandoned 2026-04-19 taxonomy migration: the SKILL.md and
  the `/diaboli` command were migrated to the canonical six-category set
  (`premise`/`scope`/`implementation`/`risk`/`alternatives`/`specification
  quality` + `critical`/`high`/`medium`/`low`), but `advocatus-diaboli.agent.md`
  and the orchestrator's spec-mode validation kept the retired
  `design`/`threat`/`failure`/`operational`/`cost` + `major`/`minor` set.
  Reconciled both to the canonical set (one set for both modes; only per-mode
  weighting differs). Surfaced by REFLECTION_LOG 2026-06-11.
- Remapped the objection records that had drifted to the retired taxonomy
  (`cost-estimation-skill-design.md`; one stray `operational` in
  `dl-s2b-challenge-protocol-design-code.md`) back to canonical.
- Added a deterministic guard — `scripts/check-objection-taxonomy.py` +
  `objection-taxonomy-check.yml` workflow + the HARNESS constraint
  "Objection records use the canonical taxonomy" — so the retired vocabulary
  cannot reappear. Records dated on or before the 2026-04-19 migration are
  grandfathered.

## 0.41.0 — 2026-06-11

### New skill — `cost-estimation` (prospective cost/token/time estimation)

Ships S1 of the cost-estimator capability: the methodology and the format
contract every later slice (the S2 agent, the S3 command, the S4
orchestrator fold-in) consumes. No agent, command, or orchestrator wiring
ships here.

- **`skills/cost-estimation/SKILL.md`** — the prospective sibling of
  `cost-tracking`. Describes how MODEL_ROUTING.md grounds token and
  agent-compute-time ranges today, how an `observability/costs/` snapshot
  adds a dollar figure only when it supplies a usable $/token rate (three
  grounding states, no list-price fallback), the split-tier widening for
  the implementer stage, the two-layer no-verdict guarantee, the
  agent-compute / human-gate time split, and the calibration seam left
  open for S6.
- **`skills/cost-estimation/references/estimate-record-format.md`** — the
  stable estimate-record field set (with `cost_usd`/`cost_basis`
  conditional and `confidence` per-axis), the tier→model→$/token binding
  table, the four-part disclosure body, the validation checklist
  (including the positive-content no-verdict scan), and two worked
  examples (cost-omitted and cost-present). This is the artefact a
  downstream command's Output Validation Checkpoint parses.

## 0.40.0 — 2026-06-01

### `/assess` — ALCI Part D operational axes + Habitat Build Gap

Brings `/assess` into line with the framework's latest ALCI, which was
extended upstream with **Part D — four operational axes** and the
**Habitat Build Gap** diagnostic (driving change:
`ai-literacy-for-software-engineers` commits `f13d388`/#327 and
`542f325`/#330). Parts A–C (the cognitive level placement) are
unchanged; Part D is additive.

- **Four operational axes** — Composition, Testing, Observability,
  Governance — each placed L1–L5, measuring what the team's *habitat
  actually delivers* alongside the cognitive level.
- **Habitat Build Gap** — `cognitive level − operational axes mean`,
  with three interpretation regimes (Coherent / Ambition outpaces
  enablement / Inherited habitat). The signal is coherence, not the
  size of the level.
- **Hybrid administration** — evidence-first placement by default
  (from the repo scan), with an opt-in 40-statement ALCI Part D survey
  for teams wanting the rigorous per-axis score.
- **Self-contained** — all axis definitions, the full L1–L5 marker
  statements, the evidence map, the gap formula, and the regimes are
  embedded in the plugin (new reference
  `skills/ai-literacy-assessment/references/operational-axes.md`).
  `/assess` reads no external repository at runtime; upstream refs are
  provenance/re-sync pointers only.
- **Governance** — the existing standalone Governance Dimension
  deep-dive is retained; the new Governance operational axis is its
  one-line operational summary. The two are cross-referenced and must
  report a consistent level (enforced by the document validation
  checkpoint).
- Updated: the `ai-literacy-assessment` SKILL, the `assessor` agent,
  the assessment template, the `/assess` command (document step +
  validation checkpoint), the two evidence references, and the
  `run-an-assessment` how-to. Structural tests added.

Spec: `docs/superpowers/specs/2026-06-01-assess-operational-axes-design.md`.

### Maintenance

- `/harness-upgrade`: advanced the root `HARNESS.md` template-version
  marker from 0.39.1 to 0.40.0 after confirming the dogfood harness
  already contains all current template content (no new constraints,
  GC rules, or sections to adopt).

## 0.39.1 — 2026-05-28

### Fix — /superpowers-status disposition counting

`/superpowers-status` could over-report pending dispositions when an
objection or choice-story record contained the literal string
`disposition: pending` inside an `evidence:` or `claim:` field — a
common pattern when an objection itself critiques disposition handling.
A naive `grep -c "disposition: pending"` matched those prose occurrences
and reported them as unresolved entries. In 2026-05 this showed
`choice-cartographer.md` as having 3 pending dispositions when every
entry was in fact resolved.

- `commands/superpowers-status.md` now defines a shared "Disposition
  counting" algorithm before Section 7. The rule: count only lines
  matching `^    disposition: pending(\s|$)` within the first
  `---`…`---` frontmatter block. Provides an awk recipe agents and
  humans can paste, and notes that a YAML-aware parser (`yq`,
  `python -c "import yaml"`) is preferred when available.
- Sections 7 (Diaboli) and 8 (Cartographer) reference the shared
  algorithm so the same fix protects both panels.

### Chore — Bump Node.js 20 GitHub Actions before 2026-06-02 cutoff

- `spec-first-check.yml`: bumped `actions/github-script` from v7.0.1 (Node 20) to v9.0.0 (Node 24) ahead of GitHub's 2026-06-02 hard cutoff.

## 0.39.0 — 2026-05-26

### Carpaccio agent — cadence governor for AI-generated decision streams

Adds the `carpaccio` agent — the third member of the decision-discipline
triad alongside `advocatus-diaboli` (objections) and
`choice-cartographer` (decision visibility). Carpaccio is the cadence
governor: it sits at orchestrator step 0, before spec-writer, and
slices the raw task description into end-to-end-complete pieces so the
human engages with one decision at a time rather than the whole
proposal at once.

- New skill at `skills/carpaccio/SKILL.md` defining the charter, the
  routing rule (carpaccio vs spec-writer), the selectivity protocol,
  and the reasoning protocol.
- New references at `skills/carpaccio/references/slicing-lenses.md`
  (the five-lens vocabulary with priority order) and
  `skills/carpaccio/references/validation-checks.md` (the validation
  contract — frontmatter checks F1–F8, prose-body checks P1–P5).
- New agent at `agents/carpaccio.agent.md` with read-only trust
  boundary (Read/Glob/Grep). The orchestrator writes the slicing
  record; humans fill dispositions; the orchestrator drives
  `gh issue create` for accepted-but-not-progressed slices.
- New command at `commands/carpaccio.md` for manual invocation
  outside the orchestrator.
- New TDAD scenarios at `tdad_tests/scenarios/agents/carpaccio/` —
  six scenarios covering multi-decision slicing, atomic-task
  inseparability, mixed-independence sequencing, vague-task
  fallback to acceptance-criterion, revise-redispatch behaviour,
  and selectivity-cap respect.
- Orchestrator gains a new **Step 0** before spec-writer:
  dispatches carpaccio, validates the slicing record, hard-gates
  on `disposition` and `file_as_issue`, drives issue creation for
  accepted-not-progressed slices, dispatches spec-writer against
  the progressed slice's scope.
- New directory `docs/superpowers/slices/` holds slicing records,
  sibling to `objections/` and `stories/`.

Tracks issue #326.

## 0.38.0 — 2026-05-11

### Snapshot template gains two new sections

Two new sections added to the health snapshot template defined in
`ai-literacy-superpowers/skills/harness-observability/references/snapshot-format.md`
and the writer/validator in
`ai-literacy-superpowers/commands/harness-health.md`:

- **Sustainable Pace** — longitudinal self-report capturing the
  depletable-collaborator signal (this month's pace: sustainable /
  at-edge / over-the-edge / unknown; optional note; trend vs previous
  snapshot). Closes the depletion-management gap raised in successive
  literacy assessments — pace becomes a tracked field instead of a
  by-feel judgement.
- **Portfolio Adoption** — adoption telemetry capturing the L5 →
  sovereign-across-an-organisation progression (plugin installs,
  /assess invocations from other projects, upstream PRs into
  `ai-literacy-for-software-engineers`, `agent-harness-enabled`
  tagged-repo count, trend). Most fields read `not tracked` until
  install telemetry is available, but capturing what *is* available
  starts the longitudinal record.

Section count moves from 14 to 16. Next `/harness-health` invocation
populates the new sections.

### Quarterly literacy assessment — Level 5 continuation

`assessments/2026-05-11-assessment.md` records the quarterly
re-assessment. Level 5 confirmed for the third consecutive sitting,
with deepening evidence: 81 commits, 6 minor releases, the TDAD
pillar shipped end-to-end and operationally adopted, governance
subsystem operating quarterly, monthly curation practised, ONBOARDING
regenerated immediately after TDAD landed.

Five workflow recommendations walked interactively and all five
accepted:

- R1 — run `/cost-capture` in this quarterly sitting (closes
  three-assessment-old gap)
- R2 — add a SessionStart hook surfacing AGENTS.md promoted patterns
  (filed as follow-up PR with its own spec)
- R3 — run `/harness-audit` in this sitting to refresh HARNESS.md
  Status counts via the proper mechanism
- R4 — sustainable-pace snapshot field (shipped in this PR)
- R5 — portfolio-adoption snapshot field (shipped in this PR)

### Habitat hygiene

- New `decks/` directory with `cognitive-debt-paydown.md` — a
  slide-deck source mapping the four-debt cycle onto the framework's
  three human-cognition gates (Choice Cartographer, Advocatus
  Diaboli, alternative-options agent architecture). Markdown-source
  format intended for Claude Design or any deck tool that consumes
  per-slide headings.
- HARNESS.md template-version marker bumped from `0.35.1` to `0.38.0`
  after `/harness-upgrade` confirmed the project's harness already
  contains every active and commented-out item present in the current
  template (24 constraints + 18 GC rules vs the template's 5 + 14).
- README Skills badge: 31 → 32 (catches the
  `component-design-with-tdad` skill added in v0.37.0)
- README marketplace table and Skills heading anchor: same
- README AI Literacy badge: link updated to point to the new
  2026-05-11 assessment
- README mechanism map: Skills count updated; STRICT loop CI workflow
  list now includes `docs-build-check.yml`,
  `spec-redaction-marker-check.yml`, `tdad-tests-fast.yml`, and
  `tdad-scenario-check.yml`

### Reflection

`REFLECTION_LOG.md` gains a new entry for the 2026-05-11 assessment.
Notable observations: drift on entry was immediate and mechanical
signal (README/HARNESS Status counts visibly stale within seconds —
the L5 epistemic gain at work); the TDAD pillar followed the same
six-step shipping arc as the governance subsystem six weeks ago,
making the arc a tacit pattern worth promoting to AGENTS.md
ARCH_DECISIONS; cost capture has been flagged in three consecutive
assessments and the gap is *operational habit*, not tool friction.

## 0.37.0 — 2026-05-10

### New skill — `component-design-with-tdad`

Methodology guidance for designing a new plugin component (skill,
agent, command, or backing script) with TDAD discipline integrated
from the start. The skill names the five design questions implied
by the four-layer TDAD architecture:

1. What component type is this?
2. Which TDAD layers does this component warrant?
3. What does the scenario's `Then` clause look like?
4. New file or modification of an existing component?
5. Scenario or finding?

Loadable by `spec-writer`, `tdd-agent`, or human brainstorming. Not
a gate — the forcing functions are the deterministic CI workflows
shipped in v0.36.0 (`tdad-tests-fast.yml`,
`tdad-scenario-check.yml`). This skill packages the design
intelligence those gates assume.

The choice of skill rather than a new agent is deliberate: cartograph
story #3 of the v0.36.0 introducing spec explicitly chose
single-`tdd-agent` + branch over a separate `tdad-agent`, citing the
architectural failure mode of "two agents that share a charter." A
new component-designer agent would have reversed that decision shape
on the same charter axis. A skill carries the design intelligence
reusably (loadable by either agent or human) without the dispatch
overhead.

Skill count: 30 → 31. No agent or command count change.

Issue #313 carries the in-scope / out-of-scope and the chore-PR
rationale per AGENTS.md STYLE on reflection-driven amendments.
REFLECTION_LOG.md captures the design-intelligence-gap signal that
drove the addition.

## 0.36.0 — 2026-05-10

### Feature — TDAD discipline for agent artefacts in the orchestrator pipeline

When the orchestrator detects that a feature spec touches a new file
under `ai-literacy-superpowers/skills/`, `agents/`, or `commands/`, it
now passes agent-artefact scope context to `tdd-agent`. The tdd-agent's
new agent-artefact branch authors a TDAD scenario file at
`tdad_tests/scenarios/<type>/<name>/<aspect>.md` (with `Given/When/Then/Rubric`
sections and `tier` declared as one of `structural`, `trigger`, or
`behavioural`) as the RED-phase deliverable, instead of a generic
test file. Detection is path-based; modification of an existing
component is acknowledged as a known limitation (the orchestrator
surfaces the question but does not enforce an answer).

### Constraint — `New plugin components must ship with a TDAD scenario`

New deterministic HARNESS constraint enforced at PR time via
`.github/workflows/tdad-scenario-check.yml`. The check verifies that
any added file matching the canonical component paths has a
corresponding scenario file with a non-`finding` tier. Files with
`tier: finding` (the documentary-finding category, e.g.
`FINDING-command-tdab-gap.md` in the corpus) coexist with scenarios
but do not satisfy the constraint. Modifications are out of scope —
only additions are gated.

The HARNESS Status `Constraints enforced` count moves from 20/21 to
21/22; the README badge follows.

### Discipline shipped forward-only

Per the spec at
`docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md`
(Amendment 2 §A2.6), this PR's modifications to `orchestrator.agent.md`
and `tdd-agent.agent.md` themselves do not author scenarios. The
discipline applies forward — to PRs that *add* a component after this
one merges. Both modified agent files carry an in-place forward-pointer
comment explaining the exemption (per the diaboli adjudication of O7).

### Spec ceremony

Three spec-mode `/diaboli` passes (12 → 8 → 8 objections, converging
on implementation polish), one `/choice-cartograph` pass (9 stories),
and one Amendment 2 pivot from self-demonstration to forward-only.
Both records have all dispositions resolved — no `pending`. Spec
preserves original prose with visible `> **SUPERSEDED**: …`
blockquote redaction markers (the cartograph promoted this convention
to AGENTS.md STYLE at the next curation pass).

## 0.35.5 — 2026-05-09

### Fix — `/harness-sync` consistently references `harness-audit-engine`

Three places in `harness-sync.md` referenced the skill informally as
`audit-engine` when its actual name is `harness-audit-engine`. The
prose was understandable to a human reader but failed strict
component-name resolution.

Surfaced by **TDAD Phase 1** (the new command-wiring test in
`tdad_tests/tests/test_command_wiring.py`), which parses every
command's body for `Dispatch the X agent` and `Read the X skill`
patterns and asserts each referenced component exists. This is
exactly the rename-without-callsite-update failure class Phase 1 was
designed to catch — and it did, on its first run, against three
commands (the other two — `assess` and `harness-init` — were false
positives in the regex's handling of `gh repo edit --add-topic
agent-harness-enabled`, fixed by adding a `(?!-)` negative lookahead
on the trailing keyword).

No functional behaviour change — the loader uses the `harness-audit-engine`
skill correctly today. Patch bump for the prose-consistency edit
that the new test required.

## 0.35.4 — 2026-05-09

### Fix — agent frontmatter now strict-YAML compliant (resolves #283)

Six agent files carried multi-line `description:` values with embedded
`<example>` blocks whose internal `Context:`, `user:`, `assistant:`
lines tripped strict YAML parsers. The Claude Code loader accepts
this convention; PyYAML and any other strict YAML library does not.
Surfaced by the TDAD Layer 1 frontmatter-strictness check (PR #282 /
issue #281).

Conversion to YAML literal block scalars (`description: |` followed
by a 2-space-indented multi-line body) for the six affected files:

- `assessor.agent.md`
- `governance-auditor.agent.md`
- `harness-auditor.agent.md`
- `harness-discoverer.agent.md`
- `harness-enforcer.agent.md`
- `harness-gc.agent.md`

Round-trip parsing verified each conversion preserves the description
text including all `<example>` blocks. The Layer 1 frontmatter
strictness test now PASSES (was a non-blocking SKIP listing all six
broken files); TDAD suite count moves from 22 passed / 8 skipped to
23 passed / 7 skipped.

Decision rationale (Option A from issue #283): the plugin is
documented at the framework level and likely to be consumed by
independent tooling over time; assuming the test runner is the only
non-Claude-Code consumer that will ever read these files was a
fragile assumption. Block scalars are well-supported by every YAML
library and remove the ambiguity at the source.

The resolved finding scenario (`tdad_tests/scenarios/agents/assessor/FINDING-frontmatter-yaml-strictness.md`)
has been removed; the architectural record lives in PR #282 and
issue #283 in git history.

## 0.35.3 — 2026-05-09

### Internal reorganisation — bash test scripts moved to tdad_tests/

The three internal bash test scripts and their 11 fixtures have been
relocated from `ai-literacy-superpowers/tests/` (inside the packaged
plugin) to `tdad_tests/layer0_deterministic/` (a sibling test
directory outside the packaged plugin). No functional change for
plugin consumers — the scripts under test
(`archive-promoted-reflections.sh`, `migrate-reflection-log.sh`,
`lib/reflection-log-helpers.sh`) remain in the packaged plugin and
ship unchanged.

This is purely an internal reorganisation, hence the patch bump:

- The TDAD suite now mirrors the framework's harness promotion ladder
  (Theme #10) explicitly: Layer 0 (deterministic plumbing, NEW), Layer
  1 (structural), Layer 2 (trigger), Layer 3 (behavioural).
- A pytest dispatcher (`tests/test_layer0_deterministic.py`) runs the
  three bash scripts as subprocesses and surfaces their FAIL output on
  failure. Bash kept as bash; Python only for the dispatcher.
- Markdown lint config migrated to `.markdownlint-cli2.jsonc` with an
  `ignores:` entry for the deliberately-malformed Layer 0 fixtures
  (one is named `reflection-log-promoted-trailing-space.md` because
  it tests the parser's trailing-whitespace handling).

Tracked at PR #289.

## 0.35.2 — 2026-05-08

### Fix — `/harness-sync` trust-boundary contradiction with HARNESS.md Status auto-fix

Resolves an internal inconsistency in the `/harness-sync` command spec.
Phase 3 step 3 declared HARNESS.md Status section accuracy auto-fixable
via `/harness-audit`, but step 7's trust-boundary guard listed HARNESS.md
in the rejected set. A live sync run hit this contradiction and had to
resolve it pragmatically inline; this PR codifies that resolution.

Changes:

- Step 7 trust-boundary allow-list now permits HARNESS.md changes
  scoped to the four-line Status block under the
  `<!-- Auto-updated by /harness-audit — do not edit manually -->`
  marker, with an additional scoped-diff check that rejects any hunk
  outside that region. Adds `observability/snapshots/**` to the
  allow-list (covers `/harness-health` snapshot creation, the other
  HARNESS.md-adjacent auto-fix the audit-engine declares).
- Phase 3 step 3 no longer says "invoke `/harness-audit`". Sync now
  inlines the Status block update directly. The full audit (which
  also writes the README badge and runs heavy constraint regression
  scans) remains a separate user-triggered action.
- The opening "What this command does NOT do" paragraph distinguishes
  curated-by-humans files (`AGENTS.md`, `REFLECTION_LOG.md`,
  `ONBOARDING.md`) from the narrowly-scoped HARNESS.md Status mutation
  that sync is allowed to make.
- Path A and Path B `git add` lines now stage every allow-listed
  surface (including HARNESS.md and snapshot directories); commit
  message guidance reflects the actual mix of surfaces synced.
- Error/Refusal table updated to match the new allow-list.
- The `sync-harness` how-to doc's "Branch and trust-boundary" section
  is rewritten to match the corrected spec — including the explicit
  note that everything above the Status block (Context, Constraints,
  Garbage Collection, Observability, Read-side filtering) is
  off-limits to sync.

No change to the `harness-audit-engine` skill — its `auto_fixable`
classification rule already permitted HARNESS.md Status section
mutation as a defined exception. Only the sync command spec lagged.

## 0.35.1 — 2026-05-08

### Chore — Bump HARNESS.md template-version marker to 0.35.1

Brings the project's HARNESS.md `template-version` comment in line with
the current plugin release. `/harness-upgrade` confirmed no new template
constraints, GC rules, or sections to surface — every active and
commented item from the cached template (baseline `0.29.0`) is already
present in this project's HARNESS.md, often customised with project-
specific content. The bump records that the upgrade was reviewed for
0.34.x and 0.35.x; no semantic change to the harness itself.

### Refinement — `/harness-sync` no longer auto-invokes `/harness-onboarding`

Removes the auto-invocation of `/harness-onboarding` from
`/harness-sync`'s Phase 3 apply step. ONBOARDING.md staleness still
appears in the unified drift table (audit-engine continues to detect
it), but it now appears as a `[manual]` row instead of `[auto]` —
sync prints "Run: /harness-onboarding" and exits without writing.

Rationale: ONBOARDING.md regen is a heavier mutation than
convention-file regen and benefits from the user's deliberate trigger.
Convention-file sync is a tight derive-from-HARNESS.md operation;
onboarding regen also pulls in AGENTS.md and REFLECTION_LOG.md and
produces a substantial human-facing document. Same-shape change as
template-drift and constraint-regression: surface the staleness, let
the user act.

The trust-boundary pre-commit guard's allow-list drops `ONBOARDING.md`
accordingly — sync never writes to it now.

Updates `/harness-sync`'s command file, the audit-engine skill's
classification table, the sync-harness how-to, the run-a-harness-audit
how-to, the-harness-lifecycle explanation, CLAUDE.md (root + template)
Monthly Operations, and the README Commands table.

## 0.35.0 — 2026-05-08

### Feature — Audit-driven `/harness-sync`

Restructures `/harness-sync` so it runs `/harness-audit`'s detection
logic internally via a new shared `harness-audit-engine` skill. The
unified drift table now includes every audit finding tagged `[auto]`
or `[manual]`. Mechanical fixes (convention files, ONBOARDING.md,
snapshot regen via `/harness-health`, HARNESS.md Status section regen
via `/harness-audit`) auto-apply when selected. Judgement-required
fixes (`/harness-upgrade`, `/harness-constrain`) print the suggested
command without writing — preserving the trust boundary.

`/harness-audit` keeps its standalone diagnostic role unchanged. Both
commands now share the same engine; surface coverage evolves in one
place.

### Docs — Lifecycle simplification

Three explanation pages are rewritten to converge on a single
canonical narrative:

- `the-harness-lifecycle` is now the everyday three-state model
  (in sync, drifted, behind upstream) with `/harness-sync`,
  `/harness-upgrade`, and `/harness-constrain` as the everyday entry
  points.
- `the-harness-tuning-loop` refocuses on the signal-capture →
  constraint-promotion sub-flow specifically.
- `self-improving-harness` trims to the conceptual core (why
  iteration matters, the compound-learning principle).

How-to pages for sync-harness and run-a-harness-audit are updated
to reflect the audit-driven flow and the diagnostic-vs-everyday split.
Touch-ups across tutorials, plugin landing, CLAUDE.md (root +
template), and README align command descriptions.

### Internal

- New skill: `harness-audit-engine` documents the shared
  drift-detection contract.

## 0.34.1 — 2026-05-08

### Docs — Migrate site infrastructure from Jekyll/just-the-docs to MkDocs Material

Replaces the Jekyll + just-the-docs docs site infrastructure with
MkDocs Material. The change is plugin-internal only because it
modifies `templates/CLAUDE.md` (the shipped convention text projects
get from `/superpowers-init` now reflects the new theme conventions).

The bulk of the migration touches the `docs/` tree (outside the plugin
directory): a new `mkdocs.yml` and `requirements.txt` at repo root,
the `pages.yml` workflow swapped from `bundle exec jekyll` to
`pip install + mkdocs build`, all 377 Liquid `{% link %}` tags
rewritten to relative markdown paths, all 89 `redirect_from`
frontmatter entries migrated to the `mkdocs-redirects` plugin's
`redirect_maps`, and the Jekyll artifacts (`Gemfile`, `Gemfile.lock`,
`docs/_config.yml`) removed.

The `templates/CLAUDE.md` "Docs Site Review" section is updated to
describe the new theme conventions (MkDocs Material, the
`mkdocs-awesome-pages` plugin for filesystem-derived nav, no more
`has_children: true` or `nav_label` frontmatter required). New
projects running `/superpowers-init` get the corrected guidance.

A one-shot migration script
(`scripts/migrations/jekyll-to-mkdocs.py`) is committed for
reproducibility.

## 0.34.0 — 2026-05-08

### Feature — Diataxis docs reorg (Phase 1: model-cards)

Establishes the project-wide Diataxis folder convention for the docs
site and applies it to the `model-cards` plugin as the reference
implementation. Plugin docs now live at
`docs/plugins/<plugin-name>/<quadrant>/<slug>.md` where `<quadrant>`
is one of `tutorials/`, `how-to/`, `reference/`, or `explanation/`.
URLs are Diataxis-pure; sidebar nav uses friendly labels via
just-the-docs `nav_label` frontmatter.

Ships the convention machinery: a new **Redirect sunset** GC rule
(monthly, deterministic, scans for expired `<!-- redirect-sunset:
YYYY-MM-DD -->` markers), the `scripts/check-redirect-sunsets.sh`
tool that backs it, and the `scripts/migrations/rewrite-docs-links.sh`
one-shot link rewriter. Updates `CLAUDE.md` and
`templates/CLAUDE.md` to document the new layout convention.

The `model-cards` plugin's 7 movable docs pages were moved into
how-to/, reference/, and explanation/ quadrants (no tutorials/ —
no end-to-end walkthrough page exists yet). Every moved page
carries `redirect_from` covering both old URL forms (`/slug/` and
`/slug.html`) plus a 12-month sunset marker (2027-05-08).

`ai-literacy-superpowers` plugin docs migration arrives in Phase 2
as a separate PR (no version bump — outside the plugin directory).

## 0.33.0 — 2026-05-07

### Feature — `/choice-cartograph` command and `choice-cartographer` agent

Adds the second member of the decision-discipline triad: the
`choice-cartographer` agent and its companion `/choice-cartograph`
command.

The choice cartographer's job is decision-record keeping. When the
orchestrator (or a human) invokes `/choice-cartograph`, the
cartographer agent produces a structured YAML+prose choice story at
`docs/superpowers/stories/`. The story captures the decision context,
the options that were on the table, the chosen option, the rationale,
and — crucially — the `disposition:` of each alternative, so the
"road not taken" is preserved alongside the road taken.

- New agent at `agents/choice-cartographer.agent.md`
- New skill at `skills/choice-cartographer/SKILL.md` (the
  cartographer's protocol — phases 1–4, story format, validation
  contract, disposition lifecycle)
- New command at `commands/choice-cartograph.md`
- New `/superpowers-status` Section 8 panel for choice-story health
  (mirrors the Diaboli panel at Section 7)
- Story format reference and schema example at
  `skills/choice-cartographer/references/story-format.md` and
  `skills/choice-cartographer/references/story-schema-example.md`
- Orchestrator updated to dispatch the cartographer after spec
  approval, before the tdd-agent
- TDAD scenarios in `tdad_tests/scenarios/agents/choice-cartographer/`
  covering the four canonical trigger paths and one format-validation
  scenario
- Docs: explanation, how-to, reference pages; README and HARNESS.md
  counts updated

Tracks issue #297.

## 0.32.0 — 2026-04-27

### Feature — `/advocatus-diaboli` command and `advocatus-diaboli` agent

Adds the first member of the decision-discipline triad: the
`advocatus-diaboli` agent and its companion `/advocatus-diaboli`
command (alias `/diaboli`).

The diaboli agent's job is structured adversarial critique of a spec
before implementation starts. When the orchestrator (or a human)
invokes `/advocatus-diaboli <spec-file>`, the agent produces a
structured YAML+prose objection record at `docs/superpowers/objections/`.
Each record captures between 5 and 12 objections; the human author
resolves or defers each one before the orchestrator continues.

- New agent at `agents/advocatus-diaboli.agent.md`
- New skill at `skills/advocatus-diaboli/SKILL.md` (the diaboli
  protocol — phases 1–5, objection format, validation contract,
  disposition lifecycle)
- New command at `commands/advocatus-diaboli.md`
- New `/superpowers-status` Section 7 panel for objection health
  (surfaces pending dispositions per spec, warns when a spec is
  implementation-complete but objections remain open)
- Objection format reference and schema example at
  `skills/advocatus-diaboli/references/objection-format.md` and
  `skills/advocatus-diaboli/references/objection-schema-example.md`
- Orchestrator updated to dispatch the diaboli agent after
  spec-writer, before the tdd-agent
- TDAD scenarios in `tdad_tests/scenarios/agents/advocatus-diaboli/`
  covering the four canonical trigger paths and one format-validation
  scenario
- Docs: tutorial, explanation, how-to, reference pages; README and
  HARNESS.md counts updated

Tracks issue #264.

## 0.31.0 — 2026-04-20

### Feature — TDAD observability and fast-feedback workflows

Adds two GitHub Actions workflows that provide deterministic TDAD
feedback on every PR without requiring any Python environment:

- **`tdad-tests-fast.yml`** — runs the Phase 0 YAML lint and Phase 1
  wiring checks (pure Python stdlib, `<10 s`). Blocks merges if these
  fail.
- **`tdad-scenario-check.yml`** — checks that every new plugin
  component (skill, agent, command) added in a PR has a corresponding
  TDAD scenario file. Blocks merges if the component ships without a
  scenario.

Both are in the STRICT loop; HARNESS.md constraint count moves from
19/20 to 21/22. README mechanism map updated.

### Docs

- New how-to: `run-tdad-tests.md` — step-by-step for the four TDAD
  layers.
- Updated `docs/plugins/ai-literacy-superpowers/explanation/tdad-testing-explained.md`
  to describe the full four-layer picture with the new workflow
  context.

## 0.30.0 — 2026-04-19

### Feature — TDAD testing infrastructure (Layers 0–3)

Ships the four-layer TDAD testing framework for this plugin:

- **Layer 0** (deterministic, bash): three existing scripts
  (`archive-promoted-reflections.sh`, `migrate-reflection-log.sh`,
  `lib/reflection-log-helpers.sh`) and their 11 fixtures.
- **Layer 1** (structural, Python): `test_frontmatter.py` validates
  agent/skill/command YAML frontmatter, `test_command_wiring.py`
  asserts that every `Dispatch the X agent` / `Read the X skill`
  reference in a command body resolves to a real component.
- **Layer 2** (trigger, Python): `test_orchestrator_routing.py` and
  `test_command_dispatch.py` verify that the orchestrator routes to
  the right agent and that each command's declared trigger string
  appears in the right place.
- **Layer 3** (behavioural, YAML scenarios): 20 scenario files across
  `tdad_tests/scenarios/{agents,skills,commands}/` covering the
  canonical trigger paths and format-validation cases for the six
  agents, four skills, and four commands in the plugin.

`pytest.ini` and `conftest.py` wired; CI runs via `tdad-tests-fast.yml`
(Phase 0+1) added in the next PR.

## 0.29.1 — 2026-04-06

### Internal — rebase-only

This version bump marks the resolution of a rebase conflict on the
`orchestrator-tdad-integration` branch. No functional changes from
0.29.0; the rebase brought in the `docs/plugins/` tree from the main
branch (0.28.x series) and the `tdad_tests/scenarios/` directory
landed in 0.29.0 is now on top.

## 0.29.0 — 2026-03-28

### Feature — Governance subsystem

Full governance subsystem: monthly AI usage audit, quarterly literacy
assessment, REFLECTION_LOG.md archiving, and cross-plugin insight
harvesting.

- New agent `governance-auditor` with monthly and quarterly sub-agents
- New command `/governance-audit`
- `/assess` updated to produce structured assessment records with
  gap-tracking sections
- `/harness-health` snapshot format adds a Governance section
- REFLECTION_LOG.md archiving workflow via `archive-promoted-reflections.sh`

Tracks issue #198.

## 0.28.5 — 2026-03-15

### Fix — harness-discoverer trust boundary on harness-init invocation

The harness-discoverer agent's trust-boundary validation logic
incorrectly blocked `harness-init` invocations where the repository
had no existing `HARNESS.md`. The agent now distinguishes first-run
(`harness-init`, no existing file) from update-run (`harness-upgrade`,
existing file present) before applying the trust boundary. Tracked
at issue #187.

## 0.28.4 — 2026-03-14

### Fix — /harness-audit silent-pass on empty constraint list

When a project's HARNESS.md had zero constraints in the Constraints
section (e.g. a brand-new harness from `/harness-init`), the audit
engine reported "0 constraints, 0 passing, 0 failing" — a valid
empty result — as a green pass, which hid the onboarding gap. Now the
audit hard-fails when the constraint count is zero, with a clear
message directing the user to `/harness-constrain`. Tracked at
issue #182.

## 0.28.3 — 2026-03-13

### Fix — /harness-constrain constraint uniqueness check

When adding a new constraint, `/harness-constrain` now checks whether
an equivalent constraint (same `check_type` + `target_pattern`) already
exists before writing. Previously, repeated invocations could append
duplicate constraints without warning. The uniqueness check uses
normalised YAML keys so minor whitespace differences do not create
false negatives. Tracked at issue #178.

## 0.28.2 — 2026-03-12

### Fix — /harness-health snapshot date-stamping

The snapshot filename and frontmatter `date:` field now use the
localtime date of the machine running the command rather than UTC.
This was causing off-by-one-day errors for users in UTC+N timezones
when they ran a health check after 4 PM local. Tracked at issue #173.

## 0.28.1 — 2026-03-11

### Fix — harness-enforcer false positive on multi-line constraint bodies

The constraint-runner regex used by `harness-enforcer` matched only
the first line of a multi-line `check_body:` field, silently passing
constraints whose full body would have failed. Multi-line bodies are
now joined before matching. Tracked at issue #168.

## 0.28.0 — 2026-03-10

### Feature — Harness enforcement CI workflow

Adds `.github/workflows/harness-enforcement.yml`: a GitHub Actions
workflow that runs `harness-enforcer` on every PR and push to main.
The workflow installs no extra dependencies — it uses only the shell
scripts and YAML files already present in the plugin. Status badge
added to README.

Tracks issue #161.

## 0.27.0 — 2026-03-01

### Feature — `/harness-health` command and `harness-observability` skill

Adds longitudinal health snapshots for the harness:

- New command `/harness-health` — generates a dated snapshot file at
  `observability/snapshots/YYYY-MM-DD.md` capturing constraint
  counts, GC rule status, recent audit results, and a pace-of-change
  note.
- New skill `harness-observability` — the detection and generation
  protocol shared by `/harness-health` and the audit engine.
- HARNESS.md gains an `Observability` section (template updated).

Snapshot count moves from 0 to 1 on first invocation; README badge
and HARNESS.md Status section updated.

Tracks issue #149.

## 0.26.0 — 2026-02-14

### Feature — `/harness-upgrade` command

Adds `/harness-upgrade`: compares the project's `HARNESS.md` against
the latest plugin-shipped template, reports semantic drift (new
constraint categories, new GC rules, updated section text), and
offers to apply upstream changes with a conflict-resolution protocol.

- New command at `commands/harness-upgrade.md`
- Template stored at `templates/HARNESS.md`; upgrade logic in the
  `harness-discoverer` skill (Phase 3 branch)

Tracks issue #134.

## 0.25.0 — 2026-02-01

### Feature — Garbage-collection subsystem

Adds the GC subsystem to the harness: structured rules for pruning
stale artefacts, cleaning up obsolete snapshots, and retiring
old constraints that have been superseded.

- HARNESS.md template gains a `Garbage Collection` section with
  5 default GC rules
- New skill `harness-gc` handles rule evaluation and output
- `/harness-audit` now includes a GC pass and surfaces stale-artefact
  findings in the audit report

Tracks issue #121.

## 0.24.0 — 2026-01-25

### Feature — `/harness-constrain` command

Adds the constraint-authoring command: guides the user through
specifying a new harness constraint (type, target, check body,
enforcement mode), validates uniqueness, and appends it to HARNESS.md.

- New command at `commands/harness-constrain.md`
- Constraint schema documented in `skills/harness-audit/references/`

Tracks issue #111.

## 0.23.0 — 2026-01-18

### Feature — `/harness-audit` command

Adds the audit command: runs all harness constraints against the
current repository state, produces a pass/fail report per constraint,
and surfaces actionable fix commands for failures.

- New command at `commands/harness-audit.md`
- New agent `harness-auditor` (runs constraints, formats report)
- New skill `harness-audit-protocol` (the evaluation protocol)

Tracks issue #102.

## 0.22.0 — 2026-01-10

### Feature — `/harness-sync` command (v1)

Adds the first version of the sync command: detects drift between the
project's convention files (CLAUDE.md, AGENTS.md) and the values in
HARNESS.md, and offers to regenerate the convention files from the
harness.

- New command at `commands/harness-sync.md`
- Sync logic in the `harness-discoverer` skill (Phase 2 branch)

Tracks issue #93.

## 0.21.0 — 2026-01-03

### Feature — `/harness-init` command

Adds the harness initialisation command: scaffolds a `HARNESS.md` in
the target repository based on a discovery interview, detects existing
convention files, and seeds the Constraints section with any
constraints the agent detects from the existing CLAUDE.md.

- New command at `commands/harness-init.md`
- New agents `harness-discoverer`, `harness-enforcer`
- New skill `harness-init-protocol`

Tracks issue #81.

## 0.20.0 — 2025-12-21

### Feature — AI Literacy assessment system

Adds the assessment system: a structured progression from L1 to L5,
assessment criteria per level, and the `/assess` command.

- New command `/assess`
- New agent `assessor`
- Assessment rubric at `skills/assessment/references/rubric.md`
- Level progression guide at `skills/assessment/references/levels.md`

Tracks issue #68.

## 0.19.0 — 2025-12-07

### Feature — SessionStart hook and `harness-onboarding` command

Adds automatic context injection at the start of every Claude Code
session:

- New `harness-onboarding` command generates `ONBOARDING.md` from
  `HARNESS.md` + `AGENTS.md` + `REFLECTION_LOG.md`
- `CLAUDE.md` template updated with a `SessionStart:` hook that loads
  `ONBOARDING.md` automatically
- New skill `harness-onboarding-protocol`

Tracks issue #57.

## 0.18.0 — 2025-11-22

### Feature — REFLECTION_LOG.md and reflection workflow

Adds the reflection subsystem:

- `REFLECTION_LOG.md` template with `promoted:`, `archived:`, and
  `raw:` sections
- New command `/capture-reflection` — writes a dated entry to the
  `raw:` section
- New command `/promote-reflection` — moves entries from `raw:` to
  `promoted:` with the human's editorial review
- `migrate-reflection-log.sh` one-shot migration script for projects
  already tracking reflections in plain markdown

Tracks issue #44.

## 0.17.0 — 2025-11-08

### Feature — Plugin marketplace listing

Publishes the plugin to the Claude Code plugin marketplace.

- `CLAUDE.md` metadata block updated with `marketplace: true` and
  `categories: ["AI Literacy", "Agent Harness"]`
- README updated with installation instructions and marketplace badge
- `docs/plugins/ai-literacy-superpowers/` landing page added

## 0.16.0 — 2025-10-25

### Feature — Superpowers status dashboard

Adds `/superpowers-status`: a one-command dashboard that surfaces the
current state of the AI Literacy Superpowers plugin — spec coverage,
constraint health, objection dispositions, choice-story completeness,
and snapshot currency.

- New command at `commands/superpowers-status.md`
- Sections 1–6 cover: plugin version, spec coverage, constraint
  health, GC rule status, snapshot currency, and reflection log
  currency

Tracks issue #31.

## 0.15.0 — 2025-10-11

### Feature — Spec-first CI workflow

Adds `.github/workflows/spec-first-check.yml`: enforces that the
first commit on any feature branch is a spec file in
`docs/superpowers/specs/`. Bug-fix, maintenance, and cross-repo PRs
are exempt via branch prefix or label.

- New workflow file
- HARNESS.md constraint "Spec-first commit ordering" added
- README mechanism map updated

Tracks issue #22.

## 0.14.0 — 2025-09-27

### Feature — `spec-writer` agent

Adds the `spec-writer` agent: given a feature request, produces a
structured spec file at `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
with Problem, Goals, Non-goals, Design, and Open Questions sections.

- New agent at `agents/spec-writer.agent.md`
- New skill at `skills/spec-writer/SKILL.md`
- Orchestrator updated to dispatch spec-writer before tdd-agent

Tracks issue #17.

## 0.13.0 — 2025-09-13

### Feature — `tdd-agent`

Adds the `tdd-agent`: given a spec file, produces a RED-phase test
file that fails deterministically, then implements to GREEN.

- New agent at `agents/tdd-agent.agent.md`
- New skill at `skills/tdd/SKILL.md`
- Orchestrator routes feature specs to tdd-agent

Tracks issue #12.

## 0.12.0 — 2025-08-30

### Feature — Orchestrator agent

Adds the `orchestrator` agent: the entry point that routes user
requests to the appropriate specialist agent.

- New agent at `agents/orchestrator.agent.md`
- Routing table covers spec-writer, tdd-agent, harness agents, and
  assessment

Tracks issue #7.

## 0.11.0 — 2025-08-16

### Feature — CLAUDE.md and AGENTS.md templates

Adds the convention-file templates that `/superpowers-init` deposits
into new projects:

- `templates/CLAUDE.md` — project convention file template
- `templates/AGENTS.md` — agent manifest template

Tracks issue #4.

## 0.10.0 — 2025-08-02

### Feature — `/superpowers-init` command

Adds the plugin initialisation command: bootstraps a new project with
`HARNESS.md`, `CLAUDE.md`, `AGENTS.md`, and `REFLECTION_LOG.md` via
an interview-driven setup flow.

- New command at `commands/superpowers-init.md`
- New agent `harness-discoverer` (Phase 1 — initial discovery)

Tracks issue #1.

## 0.9.0 — 2025-07-19

### Initial plugin structure

Establishes the top-level directory layout:

- `ai-literacy-superpowers/` — plugin root
- `agents/`, `skills/`, `commands/` — plugin component directories
- `docs/superpowers/` — plugin documentation tree
- `tdad_tests/` — TDAD test suite root
- `.github/workflows/` — CI workflow directory

## 0.8.0 — 2025-07-05

### Docs — AI Literacy for Software Engineers integration

Adds cross-references from this plugin's documentation to the
`ai-literacy-for-software-engineers` course material. The plugin
docs now link to the relevant course sections for each AI Literacy
level.

## 0.7.0 — 2025-06-21

### Feature — Cost capture workflow

Adds `/cost-capture`: records the token cost and wall-clock time of
the current session to `observability/costs/YYYY-MM.md`. Provides
the longitudinal cost record the governance subsystem later consumes.

- New command at `commands/cost-capture.md`

## 0.6.0 — 2025-06-07

### Feature — Monthly curation workflow

Adds `/monthly-curation`: the monthly operations command that walks
the GC rules, surfaces stale artefacts, and prompts the human to
dispose of or retain each one.

- New command at `commands/monthly-curation.md`

## 0.5.0 — 2025-05-24

### Feature — Harness lifecycle explanation

Adds `docs/plugins/ai-literacy-superpowers/explanation/the-harness-lifecycle.md`:
the canonical explanation of the three-state harness model (in sync,
drifted, behind upstream) and the three everyday entry points
(`/harness-sync`, `/harness-upgrade`, `/harness-constrain`).

## 0.4.0 — 2025-05-10

### Feature — Harness self-improvement explanation

Adds `docs/plugins/ai-literacy-superpowers/explanation/self-improving-harness.md`:
the canonical explanation of how the harness improves over time via
the signal-capture → constraint-promotion loop.

## 0.3.0 — 2025-04-26

### Initial documentation scaffold

Adds the docs site scaffold:

- `mkdocs.yml` and `requirements.txt` at repo root
- `docs/` tree with `index.md`, `plugins/` landing pages
- `.github/workflows/pages.yml` for MkDocs build + GitHub Pages deploy

## 0.2.0 — 2025-04-12

### Rename and restructure

- Rename repo from `superpowers-harness` to `ai-literacy-superpowers`
- Move plugin into `ai-literacy-superpowers/` subdirectory for
  marketplace install compatibility
