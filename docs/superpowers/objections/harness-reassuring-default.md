---
spec: harness/assay/2026-08-25T14-31Z-assay.md#finding-1
date: 2026-08-25
mode: spec
diaboli_model: claude-opus-5
objections:
  - id: O1
    category: premise
    severity: critical
    claim: "The rule's two sentences cover three of the four instances between them and the fourth not at all — and the uncovered instance is the only one that appears in a second assay, so the four-instance pattern and the two-assay corroboration rest on disjoint evidence."
    evidence: "Rule sentence 1 binds a mechanism that 'must have a defined value for the case where it could not determine the answer, and that value may not be the passing one' — this covers the badge and the Status block. Sentence 2 is introduced as 'Separately' and covers the release-tag check. Instance 3 is covered by neither: the finding itself says 'A `skipped` conclusion is not a failure and is not a pass; the run reports one red step and between five and nine unknowns, and a reader asking \"did GC pass?\" sees the single failure.' A defined non-passing value that a reader misreads is not indeterminacy resolved to the passing value. Instance 3 is the only one carried by `harness/assay/2026-08-25T11-59Z-assay.md#finding-2`."
    disposition: accepted
    disposition_rationale: "Accepted: the four-instance pattern and the two-assay corroboration rest on disjoint evidence. The rule as drafted does not hold up here. Amended in place as proposed, rather than rejected and re-derived from a corrected finding."
  - id: O2
    category: risk
    severity: critical
    claim: "The two-assay threshold is satisfied by re-observing one unrepaired artifact in a second window, which is a single incident counted twice by a check that can only count filenames — and accepting it establishes that any open defect becomes threshold-eligible by surviving one assay cycle."
    evidence: "`_check_promotion_threshold` docstring: 'A single incident cannot reach the loop layer... Distinctness is by assay FILE, not by evidence entry - two anchors into one assay are one assay, and letting them count twice would make the threshold satisfiable by anyone willing to cite the same finding twice.' The same assay states: 'The masking defect that both assays observed is unrepaired: `harness.yml` and `gc.yml` each still carry exactly one `if: always()`, on `Summary` (`observed`, counted).' Nothing changed the artifact between the two observations."
    disposition: deferred
    disposition_rationale: "Deferred rather than rejected. The second sighting is a verification observation, not the same one counted twice, and the precedent this objection warns about - an unrepaired defect becoming the cheapest route into HARNESS.md - is right but acceptable. What is unsettled is the question accepting O1 raises: whether corroboration drawn from the one instance the rule text does not cover should count toward the threshold at all. I'm not sure it does. Deferred until that is answered."
  - id: O3
    category: implementation
    severity: critical
    claim: "The reason given for choosing `harness-loop` over `turn-instructions` — that AGENTS.md reaches one surface and is silent where the work happens — applies with equal force to HARNESS.md, which reaches three of the five surfaces the record declares and neither `claude-code` nor `codex` by any mechanism."
    evidence: "Record: 'I rejected it because `harness/surfaces.yaml` gives `AGENTS.md` as the target of `codex` alone, so the rule would reach one surface and be silent on the one where the work happens.' `harness/surfaces.yaml`: `claude-code: targets: [CLAUDE.md, .claude/agents/, .claude/hooks/, .claude/settings.json]`; `codex: targets: [AGENTS.md]`. HARNESS.md appears in no surface's `targets`. *Convention parity* generates 'all three generated convention files (`.cursor/rules/constraints.mdc`, `.github/copilot-instructions.md`, `.windsurf/rules/constraints.md`)'. `commands/harness-sync.md:15`: 'It does _not_ write to `AGENTS.md`... `AGENTS.md` and `REFLECTION_LOG.md` are curated by humans.' The record declares `surfaces: [claude-code, codex, cursor, copilot, windsurf]`."
    disposition: accepted
    disposition_rationale: "Accepted: the reach argument given against turn-instructions applies equally against HARNESS.md. The rule as drafted does not hold up here. Amended in place as proposed, rather than rejected and re-derived from a corrected finding."
  - id: O4
    category: specification quality
    severity: critical
    claim: "The repaired script the finding holds up as the principle's only written statement still reaches the passing value when it cannot read the input it names, so either the rule flags its own exemplar at HEAD or 'a reachable code path that reaches a passing value' has no determinable meaning — and the validation plan's fixtures are chosen so neither horn can surface."
    evidence: "Rule: 'Where an input is missing, unreadable or not supplied, the mechanism reports the degraded or unknown state and names the input it could not read. A reachable code path that reaches a passing value without reading the thing it reports on is a defect, not a default.' `update-health-badge.sh:54-88`: when `grep -iE '^- Health:'` matches nothing, the `*)` branch counts keyword signals and, at zero signals, sets `health_status=\"Healthy\"` — commented 'the one path to Healthy that does not come from an explicit Health line'. Validation plan: 'Reconstruct the tree at `b1982b0` and assert the rule flags `update-health-badge.sh`' — the pre-repair tree only. Cost estimate names the same shape as the likely evasion: 'Declaring an `Unknown` state and never routing to it.'"
    disposition: accepted
    disposition_rationale: "Accepted for the point beneath it, not the claim as written. The claim does not hold: under set -euo pipefail the grep assignment fails before the fallback branch is reached, so the script exits 1 with the badge untouched and that path is unreachable. What is accepted is the underlying point - a reporting mechanism should not carry a fallback that reaches the passing value without reading the thing it reports on, reachable or not."
  - id: O5
    category: implementation
    severity: critical
    claim: "Both halves of the declared Tool are unreachable for the evidence class: `harness-enforcer` is dispatched by no workflow, and the advocatus-diaboli spec-mode gate is exempt on exactly the labels all five PRs in the window carried — so the rule would have fired on none of its own four instances."
    evidence: "Cost estimate: '`grep -rn 'harness-enforcer' .github/workflows/` returns nothing.' HARNESS.md *PRs have adjudicated objections*: 'Bug fixes, dependency updates, and maintenance PRs (labelled `bug`, `fix`, `chore`, `maintenance` or branch-prefixed `fix/`, `chore/`) are exempt.' Same assay: 'Every PR in the window merged under a spec-first exemption. #571 and #572 carry `chore`; #574 `chore`; #576 and #577 `fix`... No spec was written.' #576 is the PR that changed the badge's indeterminate value. `skills/advocatus-diaboli/SKILL.md`: 'Deprioritise at spec time: `risk` objections that require examining concrete code or runtime behaviour to ground — including every embedded assumption... before the artefact exists there is nothing to read it out of.'"
    disposition: accepted
    disposition_rationale: "Accepted: neither half of the declared Tool can reach the class of change the finding is drawn from. The rule as drafted does not hold up here. Amended in place as proposed, rather than rejected and re-derived from a corrected finding."
  - id: O6
    category: scope
    severity: high
    claim: "The instance supplying the second assay is already the subject of an accepted decision whose approver wrote its cost and whose retirement withdrew only where it was pointed, and of an unproposed finding-2 that is a live competing proposal — none of which the 'why no existing owner absorbs it' section discloses."
    evidence: "`HDR-2026-08-25-the-periodic-check-suite-stops-at-its-first-failure-and-reports-the-rest-as-nothing`, status `accepted`, cost in the approver's words: 'We will implement the fourteen absent checks rather than demote them.' Its retirement: 'Withdrawing where the rule was pointed, not the rule itself', and 'Re-propose immediately with `HARNESS.md` as the target. Deferred, not rejected.' The record's 'Why no existing owner absorbs it' names only *Output validation checkpoints*, *Docs site kept current*, *Command-prompt sync* and `/harness-audit`; it names no HDR."
    disposition: accepted
    disposition_rationale: "Accepted: an accepted record already governs the corroborating instance, and the record discloses none of it. A rule should exist here, but not this one."
  - id: O7
    category: premise
    severity: high
    claim: "The headline claim that motivates elevation — the principle is written down exactly once, in a code comment — is false: it is stated in an accepted HDR's rule text with an approver's cost against it, and in the governance validator's own documentation."
    evidence: "Finding: 'That comment is the only place in the repository the principle is written.' Executive summary: 'the principle that says they must not was written down exactly once, in a code comment.' Counter-evidence: the accepted (now superseded) masking HDR's rule text — 'A rule that did not run is reported as not run — never omitted, and never counted as passing' — and `check-harness-decisions.py`'s `sections()` docstring — 'An empty section is a missing section that looks present, and that is worse than an absent one: it reads as done.' The narrower claim the finding also makes, that HARNESS.md's 36 constraints and AGENTS.md's six gotchas contain no equivalent, is not disputed."
    disposition: accepted
    disposition_rationale: "Accepted: the principle is written in more than the one place the finding claims. The rule as drafted does not hold up here. Amended in place as proposed, rather than rejected and re-derived from a corrected finding."
  - id: O8
    category: alternatives
    severity: high
    claim: "Exactly one alternative classification was weighed, and it is not the one the record's own Tool field points at: `agent-instruction` targeting the advocatus-diaboli skill would reach the surface where the work happens, need no two-assay threshold, and be dispatched by something that actually runs."
    evidence: "Record: 'I considered `turn-instructions`... I rejected it because...' — no other classification is named. Rule: '**Tool**: advocatus-diaboli (spec-mode gate) and harness-enforcer.' `check-harness-decisions.py`: `_check_promotion_threshold` returns early unless `classification == \"harness-loop\"`; `agent-instruction` has no default route and names its own `target`, which `_check_target` requires only at acceptance. `skills/advocatus-diaboli/SKILL.md` is loaded on every `/diaboli` run; `.github/prompts/diaboli.prompt.md` exists as a second dispatch path."
    disposition: accepted
    disposition_rationale: "Accepted: one alternative classification was weighed and it was not the one the record's own Tool field points at. A rule should exist here, but not this one."
  - id: O9
    category: scope
    severity: high
    claim: "The 'weaker property' sentence legislates the same claim as finding-2's proposed rule from the same assay, so accepting both writes one normative claim into HARNESS.md twice with no supersession relationship, and spends two of the three cycle slots on it."
    evidence: "finding-1: 'Separately, a check may not report a pass on the strength of a property weaker than the one it names: if the check is called \"release tag completeness\" it verifies that the release has a tag, not that a string exists.' finding-2: 'A check named for a property verifies that property; passing on a weaker one is worse than failing, because 110 green rows are read as coverage.' Neither rule mentions the other. `check_cycle_cap`: 'At most three accepted HDRs may share one assay.' The finding's own cost estimate concedes the clause is unmechanical: 'I could not tighten \"weaker property\" into something mechanical without narrowing it to release tags, which would overfit it to finding-2.'"
    disposition: accepted
    disposition_rationale: "Accepted: the weaker-property clause legislates the same claim as finding-2 from the same assay. A rule should exist here, but not this one."
  - id: O10
    category: specification quality
    severity: high
    claim: "The validation plan presupposes something that runs, and the record declares `enforcement: advisory` with an agent tool — so the refusal criterion the record sets for itself can never be evaluated by anyone, and the rule ships carrying a falsification test that cannot be performed."
    evidence: "Validation plan: 'Reconstruct the tree at `b1982b0` and assert the rule flags `update-health-badge.sh`, the `## Status` block and `gc.yml`'s release-tag step. Then assert it does not flag `check-harness-decisions.py` or `harness-registrar.py check`... If the rule cannot separate those two sets without an author's cooperation, it is not falsifiable and should be refused rather than softened.' Frontmatter: `enforcement: advisory`; rule block: '**Enforcement**: agent'; cost estimate: 'An agent-enforced constraint runs when a human types `/harness-audit`, which happened once in the twelve days before this window.'"
    disposition: accepted
    disposition_rationale: "Accepted: the validation plan names a refusal criterion nobody can evaluate. The rule as drafted does not hold up here. Amended in place as proposed, rather than rejected and re-derived from a corrected finding."
  - id: O11
    category: risk
    severity: high
    claim: "The proposed record's four tier-2 sections are placeholders, and the corpus validator passes them — it checks non-emptiness everywhere and placeholder text only in `## Rejection` — so a harness-loop rule can be accepted with no layer argument, no enforcement statement, no validation and no rejected alternatives."
    evidence: "`HDR-2026-08-25-four-mechanisms-...md` body: '## Why this layer\\n\\n_TODO — why this change belongs at this layer and not one layer down._' and the same for Enforcement, Validation and Rejected alternatives. `check-harness-decisions.py` `_check_body`: `elif not found[heading].strip():` — a `_TODO` line is non-empty. The `startswith(\"_TODO\")` guard exists only in `_check_rejection`, for `## Rejection`. The record's own rule: 'A reachable code path that reaches a passing value without reading the thing it reports on is a defect, not a default.'"
    disposition: accepted
    disposition_rationale: "Accepted for the point beneath it, not the claim as written. The claim does not hold: /harness-accept runs precheck, which refuses _TODO sections by name, so a harness-loop rule cannot be accepted carrying them. What is accepted is the underlying point - the corpus validator does pass placeholder text, so /harness-check reports OK on an unfinished proposal, and a gate that checks shape is not checking substance."
  - id: O12
    category: alternatives
    severity: high
    claim: "The existing machinery found and repaired three of the four instances inside four hours with no new rule, and 'run the audit on a cadence' is not weighed as an alternative anywhere in the record — the same disposal O9 of the previous review argued for and which the assay records as having been borne out."
    evidence: "Finding: '`/harness-audit` **found** three of these four instances, which is why they are not rejected candidates for it.' Executive summary: 'three separate mechanisms were repaired within four hours (`observed`, `gh pr list` merge times 14:05–14:30Z).' 'What worked': 'One of them, `command-cli-parity.md` O9, argues finding-1 should be routed to `/harness-audit` instead of becoming a rule... The gate's prediction and events agree.' The record's counter — 'it has no rule to cite when the next mechanism ships with the same default, and it found them because a human typed the command, twelve days after the previous run' — argues for a cadence, which the proposal does not contain."
    disposition: accepted
    disposition_rationale: "Accepted: the existing machinery found and repaired three of the four instances in four hours with no new rule, and no-change went unweighed. A rule should exist here, but not this one."
---

# Objections — assay 3 finding-1, mechanisms that report the reassuring answer

Adversarial review of `harness/assay/2026-08-25T14-31Z-assay.md#finding-1`
only. The rest of the assay, the proposed record
`harness/decisions/HDR-2026-08-25-four-mechanisms-report-the-reassuring-answer-when-they-cannot-determine-the-real-one.md`,
the two prior assays and their errata, the three existing decision records,
`harness/surfaces.yaml`, `check-harness-decisions.py` and the two prior
objection records were read for context and are not themselves under
objection. Mode: `spec`. The thing under review is the finding as an argument:
its rule text, its four cited instances, its "why this layer" reasoning, its
overfitting claim, its validation plan and its cost estimate.

Five objections are `critical`, which is more than either prior review. That
density reflects the layer, not a judgement that the observation is wrong. The
underlying observation — that this repository has a recurring habit of
resolving indeterminate state to the passing value — is well made and I do not
dispute it anywhere below. What I dispute is that the four instances are four
instances of it, that the corroboration is two incidents, that HARNESS.md is
the layer, and that the rule as drafted would have caught any of it.

## O1 — premise — critical

### Claim

The rule's two sentences cover three of the four instances between them and
the fourth not at all — and the uncovered instance is the only one that appears
in a second assay. The four-instance pattern claim and the two-assay
corroboration claim therefore rest on disjoint evidence: the pattern lives
entirely inside this assay, and the corroboration lives entirely in the one
instance the pattern does not describe.

### Evidence

Sort the four instances against the rule text.

Sentence 1 — "must have a defined value for the case where it could not
determine the answer, and that value may not be the passing one" — covers the
health badge (`health_status="Healthy"` above a skipped detection block) and
the Status block (`Drift detected: no` produced when nothing checked). Both
are indeterminacy resolved to the passing value. Both fit.

Sentence 2 is introduced by the word **"Separately"** and covers the
release-tag check. That check is not indeterminate about its own question at
all: it determines, correctly, that a string exists. It is answering a weaker
question than its name. The finding's own cost estimate concedes this clause
is a bolt-on that resists definition:

> I could not tighten "weaker property" into something mechanical without
> narrowing it to release tags, which would overfit it to finding-2.

The third instance is covered by neither sentence, and the finding says so in
its own words:

> A `skipped` conclusion is not a failure and is not a pass; the run reports
> one red step and between five and nine unknowns, and a reader asking "did GC
> pass?" sees the single failure.

`skipped` is a defined value, it is not the passing value, and the mechanism
names what did not run. What goes wrong is that a *reader* aggregates one red
step and nine unknowns into "one problem". That is a presentation defect in a
run summary, and it is what the previously accepted record legislated against
in different words — "a rule that did not run is reported as not run — never
omitted, and never counted as passing." Cancellation-masking and
defaulting-to-pass are different failures with different fixes: the first is
fixed by `if: always()`, the second by an initial value. Nothing in the
proposed rule would produce `if: always()`.

Now cross-reference the corroboration. The evidence list carries exactly one
prior-assay anchor, `harness/assay/2026-08-25T11-59Z-assay.md#finding-2`, and
that finding is *only* about the masking instance — the third one.

### Why this matters

The record's two strongest claims are "four instances, no shared
implementation" and "two distinct assays". They are true of different sets. If
the masking instance is struck, the pattern is three instances observed in one
window by one assay, and the threshold fails outright. If it is kept, the rule
must be read as covering it — and then the rule is either wrong about what it
covers, or "reports a status" has been stretched to mean "any signal a reader
could misread", which is not a boundary an implementer or a later reviewer can
apply. A harness-loop rule whose own author's four exemplars do not sort
cleanly under its own text is not ready to govern the loop.

## O2 — risk — critical

### Claim

The two-assay threshold is satisfied here by observing one unrepaired artifact
in two consecutive windows. That is a single incident counted twice, which is
the thing the threshold exists to refuse; the check cannot see it because it
counts filenames. Accepting on this basis establishes the precedent that any
open defect becomes threshold-eligible simply by surviving one assay cycle.

### Evidence

The validator's own reasoning:

> A single incident cannot reach the loop layer. HARNESS.md governs the loop,
> so a change to it must survive the loop below: evidence from at least two
> distinct assays. Distinctness is by assay FILE, not by evidence entry - two
> anchors into one assay are one assay, and letting them count twice would
> make the threshold satisfiable by anyone willing to cite the same finding
> twice.

The two assays are twelve hours apart on the same day. What each observed
about the masking instance is the same file in the same state, and this assay
says so:

> The masking defect that both assays observed is unrepaired: `harness.yml`
> and `gc.yml` each still carry exactly one `if: always()`, on `Summary`
> (`observed`, counted).

The mechanical check will pass — `harness/assay/2026-08-25T11-59Z-assay.errata.md`
does not exist, so `_corrected_findings` excludes nothing, and two distinct
filenames are present. The check has no way to ask whether the second sighting
was a second event.

I am not asserting the assayer intended this. The record's restraint elsewhere
argues otherwise. The risk is structural: nothing in the loop distinguishes
"two assays saw this happen twice" from "two assays saw the same open ticket".

### Why this matters

This is the first record to reach the threshold, so whatever is accepted here
is the worked example every later assay reads. The cheapest way to promote any
future finding to HARNESS.md becomes: observe a defect, do not fix it, observe
it again next cycle, cite both. The threshold's stated purpose inverts — it
starts rewarding unrepaired defects over repaired ones, because a repaired
defect cannot be re-observed. Three of this finding's four instances were
repaired within four hours and are therefore, under this reading,
threshold-ineligible; the one nobody fixed is the one that carries the record.
If the approver accepts, the disposition should say in the approver's own words
what distinguishes a second observation from a second incident, because nothing
in the corpus does.

## O3 — implementation — critical

### Claim

The stated reason for choosing `harness-loop` over `turn-instructions` — that
AGENTS.md serves one surface and is silent where the work happens — applies
with at least equal force to HARNESS.md. HARNESS.md is the declared target of
no surface in the matrix, reaches three of the five surfaces the record
declares by generation, and reaches `claude-code` and `codex` by no mechanism
at all.

### Evidence

The argument under objection:

> I rejected it because `harness/surfaces.yaml` gives `AGENTS.md` as the target
> of `codex` alone, so the rule would reach one surface and be silent on the
> one where the work happens. That is classifying at the layer that is cheapest
> rather than the one that owns the behaviour.

The matrix it cites:

```yaml
claude-code:
  targets: [CLAUDE.md, .claude/agents/, .claude/hooks/, .claude/settings.json]
codex:
  targets: [AGENTS.md]
```

HARNESS.md appears in no `targets` list. The generation path is *Convention
parity*, which binds "all three generated convention files
(`.cursor/rules/constraints.mdc`, `.github/copilot-instructions.md`,
`.windsurf/rules/constraints.md`)". `commands/harness-sync.md:15` is explicit
about the rest: "It does _not_ write to `AGENTS.md`, `REFLECTION_LOG.md`, or
`ONBOARDING.md`. `AGENTS.md` and `REFLECTION_LOG.md` are curated by humans."

The record nonetheless declares `surfaces: [claude-code, codex, cursor,
copilot, windsurf]`. Two of those five are asserted reach with no generator
behind them — including `codex`, whose only target is the file the record just
rejected as too narrow, and `claude-code`, the surface the argument calls "the
one where the work happens".

The repository has already adjudicated this exact question, in the accepted
masking record's `## Enforcement` section:

> The rule is invisible to the five advisory surfaces — `claude-code`,
> `codex`, `cursor`, `copilot`, `windsurf` — and is not listed on them. This is
> correct rather than a gap... Listing those surfaces would have produced five
> rows in the enforcement report reading `advisory` intended and `advisory`
> achieved, which would look like reach and mean nothing.

The steel-man: an agent told to read HARNESS.md reads it, and CLAUDE.md points
at the loop. That is true and it is not what the matrix says, and the record
cannot both use the `targets` table as its reason for refusing one
classification and ignore it when declaring its own reach.

### Why this matters

"Why this layer" is the section a tier-2 record exists to force, and it is
currently a `_TODO` (see O11) with only the assayer's paragraph standing in for
it. That paragraph's single load-bearing fact does not hold. If reach is the
criterion, the honest ranking is that HARNESS.md reaches three advisory
surfaces plus whoever is told to read it, AGENTS.md reaches one, and neither
reaches `claude-code` by generation — which is an argument for weighing the
agent-file classifications (O8), not for the layer that carries the threshold.
And an enforcement report that renders five advisory rows for a rule with three
generated destinations is itself a mechanism reporting a reassuring answer it
cannot determine, which is the subject of the finding.

## O4 — specification quality — critical

### Claim

The repaired script that the finding presents as the principle's only written
statement still reaches the passing value when it cannot read the input it
names. Either the rule flags its own exemplar at HEAD — in which case "three of
the four were repaired" is wrong and the cost is understated — or "a reachable
code path that reaches a passing value" has no determinable meaning. The
validation plan's fixtures are chosen so that neither horn can surface.

### Evidence

The rule:

> Where an input is missing, unreadable or not supplied, the mechanism reports
> the degraded or unknown state and names the input it could not read. A
> reachable code path that reaches a passing value without reading the thing it
> reports on is a defect, not a default.

`ai-literacy-superpowers/scripts/update-health-badge.sh` at `0048ae5`, lines
54–88. The script names its input explicitly — "That line is the source of
truth — mirror it, do not re-derive it" — and then, when `grep -iE '^- Health:'`
matches nothing:

```sh
    *)
      # No explicit Health line (older or malformed snapshot) — fall back to
      # the signal heuristic.
      ...
      else
        # A snapshot was read and shows no attention signals. This is the one
        # path to Healthy that does not come from an explicit Health line...
        health_status="Healthy"
```

A snapshot with no `- Health:` line and no keyword hits yields a green badge.
The input the mechanism reports on was not read; the passing value was reached;
the input it could not read is not named. The comment above it argues the path
is legitimate because *some* file was opened. That is precisely the distinction
the rule refuses to draw for anybody else.

The validation plan tests only `b1982b0` — the pre-repair tree — and two
validators chosen because they exit non-zero. It never asks the question that
matters: does the rule flag the repository's own reference implementation
today?

The record already names this shape as its likeliest evasion: "**Declaring an
`Unknown` state and never routing to it** — the branch exists, the reviewer
sees it, nothing reaches it... the rule's phrase 'reachable code path' is the
only defence."

### Why this matters

A rule whose canonical example violates it on the day it is written cannot
teach anyone the boundary, and the four-part remedy framing does not help
because there is no reading under which the exemplar is compliant *and* the
Status block at `b1982b0` is not. The approver is being asked to accept an
unpriced open violation in the plugin's own script, and a validation plan
constructed such that the first person to run it reports success.

## O5 — implementation — critical

### Claim

Both halves of the declared Tool are unreachable for the class of change the
finding is derived from. `harness-enforcer` is dispatched by no workflow — the
record says so — and the advocatus-diaboli spec-mode gate is exempt on exactly
the labels every PR in the window carried. The rule would have fired on none of
its own four instances.

### Evidence

The rule names `**Tool**: advocatus-diaboli (spec-mode gate) and
harness-enforcer`. The cost estimate concedes half:

> `grep -rn 'harness-enforcer' .github/workflows/` returns nothing.

The other half is not addressed anywhere. HARNESS.md's *PRs have adjudicated
objections*, which is what makes a spec-mode diaboli review obligatory:

> Bug fixes, dependency updates, and maintenance PRs (labelled `bug`, `fix`,
> `chore`, `maintenance` or branch-prefixed `fix/`, `chore/`) are exempt on the
> same terms as spec-first-commit-ordering.

And the same assay, three sections earlier:

> Every PR in the window merged under a spec-first exemption. #571 and #572
> carry `chore`; #574 `chore`; #576 and #577 `fix`... No spec was written.

#576 is the PR that changed a reporting mechanism's indeterminate value. It
carried `fix`. Under the proposed rule it would have been exempt from the gate
the rule names as its tool.

There is a third problem with the same fact. The diaboli's spec mode is, by its
own charter, the wrong mode for this defect class:

> **Deprioritise at spec time:** `risk` objections that require examining
> concrete code or runtime behaviour to ground — including every embedded
> assumption (below), since an assumption is embedded *by an artefact* and
> before the artefact exists there is nothing to read it out of.

A variable initialised to `Healthy` is an embedded assumption in a bash script.
That is code mode. The rule names spec mode.

### Why this matters

The cost estimate offers the approver a clean choice — buy the dispatch path or
decline — and that choice is drawn too narrowly. Buying `harness-enforcer`
dispatch would still leave the rule silent on every `fix`- and `chore`-labelled
PR, which in the window under assay is all of them, and the diaboli half would
still be pointed at the wrong mode. The realistic cost of making this rule
bite is: a CI dispatch path for the enforcer, a narrowing of the exemption
list so reporting-mechanism changes cannot ride a `fix` label, and a code-mode
rather than spec-mode gate. None of that is in the estimate, and it is the
difference between a rule and a sentence.

## O6 — scope — high

### Claim

The instance that supplies the second assay is already the subject of an
accepted decision with an approver-written cost, whose retirement withdrew only
where the rule was pointed and explicitly deferred re-proposal at that layer —
and of an unproposed finding-2 that is a live competing proposal over the same
artifact. The "why no existing owner absorbs it" section discloses none of it.

### Evidence

`HDR-2026-08-25-the-periodic-check-suite-stops-at-its-first-failure-and-reports-the-rest-as-nothing`
is `status: accepted`, `enforcement: validated`, with a cost in the approver's
own words: "We will implement the fourteen absent checks rather than demote
them. ... I can't think of a circumstance when we might retire this rule yet."

Its retirement is unambiguous about what was withdrawn: `cost: Withdrawing
where the rule was pointed, not the rule itself`, and

> **Re-propose immediately with `HARNESS.md` as the target.** Deferred, not
> rejected.

That deferred re-proposal is assay 2's finding-2, which has an objection record
of eleven objections, all `pending`. It is cited here as *evidence*.

The record's "Why no existing owner absorbs it" section names *Output
validation checkpoints*, *Docs site kept current*, the GC rule *Command-prompt
sync*, and `/harness-audit`. It names no HDR and no pending proposal.

There is a further wrinkle the approver should see. The accepted record's "Why
this layer" already adjudicated the classification question for this instance,
in the opposite direction:

> It is deliberately not `harness-loop`: the declared rules are correct as
> written, and routing this to `HARNESS.md` would be classifying at the layer
> that feels most decisive rather than the one that owns the behaviour.

### Why this matters

An approver reading the evidence list sees four artifacts and a prior finding.
They do not see that one of the four is under a live proposal at a stronger
enforcement level, or that its layer was already decided against `harness-loop`
by an approver who wrote a cost against it. If both are accepted, the same
behaviour is governed twice at two enforcement levels with no supersession
chain, and `superseded_ids` will show neither as retired. The disclosure
belongs in the record, whatever the approver decides.

## O7 — premise — high

### Claim

The claim that motivates elevation to HARNESS.md — that the principle has been
discovered four times and written once, in a code comment — is false as stated.
It is written in an accepted HDR's rule text, with an approver's cost against
it, and in the governance validator's own documentation.

### Evidence

The finding:

> That comment is the only place in the repository the principle is written.

The executive summary:

> the principle that says they must not was written down exactly once, in a
> code comment.

Two counter-instances, both in the repository at `0048ae5`. The accepted (now
superseded) masking record's rule text:

> A rule that did not run is reported as not run — never omitted, and never
> counted as passing. The point of a weekly job is the weeks nobody reads it,
> so a run that silently stops partway is a run that reports a smaller world
> than it checked.

And `check-harness-decisions.py`'s `sections()` docstring:

> A heading with nothing under it maps to the empty string — which the caller
> then rejects. An empty section is a missing section that looks present, and
> that is worse than an absent one: it reads as done.

The narrower claim the finding also makes — that HARNESS.md's 36 constraints
and AGENTS.md's six gotchas contain no equivalent — I checked and do not
dispute.

### Why this matters

"Discovered four times, written once" is the rhetorical engine of the whole
proposal: it is what turns a set of repaired defects into an argument for a
constraint. The accurate statement is weaker and points somewhere different —
the principle has been written twice in the governance corpus and once in a
script, and none of those three places is a document an author of the *next*
mechanism is required to read. That is an argument about placement and
readership, which may still support a rule, but it is not the argument the
record makes and the approver should be weighing the true one.

## O8 — alternatives — high

### Claim

Exactly one alternative classification was weighed, and it is not the one the
record's own Tool field points at. `agent-instruction` targeting the
advocatus-diaboli skill file would reach the surface where the work happens,
require no two-assay threshold, and be dispatched by something that actually
runs.

### Evidence

The record's full consideration of alternatives is one classification:

> I considered `turn-instructions`... I rejected it because...

`agent-instruction`, `agent-reference`, `regression-test` and `new-agent` are
in `VALID_CLASSIFICATION` and are not mentioned. Meanwhile the rule names an
agent as half its enforcement: `**Tool**: advocatus-diaboli (spec-mode gate)
and harness-enforcer`.

The mechanical facts: `_check_promotion_threshold` returns early unless
`classification == "harness-loop"`, so `agent-instruction` carries no
threshold; `_check_target` requires the record to name its own target at
acceptance, which for this rule would be
`ai-literacy-superpowers/skills/advocatus-diaboli/SKILL.md` or an agent file;
and unlike `harness-enforcer`, that skill is loaded on every `/diaboli` run and
has a second dispatch path at `.github/prompts/diaboli.prompt.md`.

I am not proposing that design — that is the spec-writer's job, not mine. I am
objecting that the record's own Tool field points at an agent, and the
classification section never asks whether the rule therefore belongs in that
agent's instructions.

### Why this matters

`harness-workflow-step-masking.md` O3 objected to reaching for a classification
that *clears* a threshold. The honest mirror is not "always take the most
expensive classification"; it is "take the one that owns the behaviour". A rule
whose enforcement is a question an agent asks at a review gate has a strong
claim to live in that agent's instructions, where it is loaded on every run,
rather than in a document reached by a human typing `/harness-audit` once a
quarter. The record cannot demonstrate that it took the owning layer while
leaving the layer its own Tool names unexamined.

## O9 — scope — high

### Claim

The "weaker property" sentence legislates the same claim as finding-2's
proposed rule from the same assay. If both are accepted, one normative claim
enters HARNESS.md twice, in two constraints, with no supersession relationship
and two of the three cycle slots spent on it.

### Evidence

finding-1's rule:

> Separately, a check may not report a pass on the strength of a property
> weaker than the one it names: if the check is called "release tag
> completeness" it verifies that the release has a tag, not that a string
> exists.

finding-2's rule, same assay:

> A check named for a property verifies that property; passing on a weaker one
> is worse than failing, because 110 green rows are read as coverage.

Neither record mentions the other's clause. Both cite `.github/workflows/gc.yml`
and `HARNESS.md` as evidence. `check_cycle_cap`: "At most three accepted HDRs
may share one assay."

The record concedes the clause cannot be tightened without collapsing into the
other finding: "I could not tighten 'weaker property' into something mechanical
without narrowing it to release tags, which would overfit it to finding-2."
That is an admission that the clause's only concrete referent is finding-2's
subject.

### Why this matters

*Convention parity* copies every constraint heading into three generated
mirrors. Two constraints stating the same claim in different words, one
advisory and one deterministic, propagate to all three and give a later reader
two places to satisfy and two to argue from. The cheap remedy is available and
unpriced: drop the sentence from finding-1 and let finding-2 carry it — which
also removes the only instance sentence 2 covers, and forces the four-instance
claim (O1) to be restated honestly as three.

## O10 — specification quality — high

### Claim

The validation plan presupposes something executable. The record declares
`enforcement: advisory` with an agent tool and concedes nothing dispatches it,
so the refusal criterion the record sets for itself can never be evaluated by
anyone — the rule ships carrying a falsification test that cannot be performed.

### Evidence

The plan:

> Reconstruct the tree at `b1982b0` and assert the rule flags
> `update-health-badge.sh`, the `## Status` block and `gc.yml`'s release-tag
> step. Then assert it does **not** flag `check-harness-decisions.py` or
> `harness-registrar.py check`... If the rule cannot separate those two sets
> without an author's cooperation, it is not falsifiable and should be refused
> rather than softened.

"Assert the rule flags X" has a subject only if something runs the rule.
`enforcement: advisory`; `**Enforcement**: agent`; and the cost estimate:
"An agent-enforced constraint runs when a human types `/harness-audit`, which
happened once in the twelve days before this window."

So the operation is: a human reconstructs a historical tree, dispatches an
agent over it, and reads whether the agent's prose mentions three files. The
outcome depends on the agent, the model and the prompt, and is not stable
across runs. Contrast the same assay's finding-2, whose validation plan asserts
against `git tag` and an exit status.

Compare, too, the accepted masking record, which named its falsification
criterion and made it mechanical: "Assertion 3 is the one that matters, and it
is the falsification criterion... If the implementation reaches green by
collecting results and not failing on them, this rule has been defeated."

### Why this matters

The record proposes its own refusal condition and then makes it unreachable.
At the ninety-day review — `expires: 2026-11-23` — the question "did this
help?" will have no evidence to answer it, because nothing will have run, and
the default outcome of an unfalsifiable provisional rule is renewal by
inattention. If the approver accepts, the disposition should replace this plan
with one that can be executed by a person in an afternoon.

## O11 — risk — high

### Claim

The proposed record's four tier-2 sections are placeholders, and the corpus
validator passes them: it checks non-emptiness everywhere and placeholder text
only in `## Rejection`. A harness-loop rule can therefore be accepted with no
layer argument, no enforcement statement, no validation and no rejected
alternatives, and `/harness-check` will report OK.

### Evidence

The record's body ends:

```markdown
## Why this layer

_TODO — why this change belongs at this layer and not one layer down._

## Enforcement

_TODO — how the rule binds on each listed surface, and where it is only advisory._

## Validation

_TODO — how anyone would know later whether this rule helped._

## Rejected alternatives

_TODO — including the 'no change' option, with the reason it was not taken._
```

`check-harness-decisions.py` `_check_body` requires `TIER2_SECTIONS` for
`harness-loop` and tests only `if heading not in found` / `elif not
found[heading].strip()`. A `_TODO` line is non-empty. The `startswith("_TODO")`
guard exists in exactly one place, `_check_rejection`, and applies to
`## Rejection` alone — added, by its own comment, because "a rejection with no
reason records that someone said no and nothing about why."

The four sections are the entire justification for the tier-2 burden:
"Process burden should be proportional to blast radius, so only these three pay
for the four extra body sections."

### Why this matters

This is a fifth instance of the finding's own pattern, in the mechanism that
will promote the finding: a gate that reports the passing answer because it
checked shape rather than substance. It is also the most consequential one,
because the sections it waves through are where an approver would have to
answer O3 (why this layer), O5 (how it binds on each surface), O10 (how anyone
would know later) and O8/O12 (what was rejected, including no change). The
record cannot argue that the repository needs a rule about mechanisms that
pass on a weaker property while riding one to acceptance. Note that the
`_TODO` text also names the exact question O3 shows the assayer's paragraph
gets wrong — "why this change belongs at this layer and not one layer down."

## O12 — alternatives — high

### Claim

The existing machinery found and repaired three of the four instances inside
four hours with no new rule, and "run the audit on a cadence" — the alternative
the previous review's O9 argued for, and which this assay records as borne out
— is not weighed anywhere in the record.

### Evidence

The finding's own account of the window:

> `/harness-audit` **found** three of these four instances, which is why they
> are not rejected candidates for it — but it has no rule to cite when the next
> mechanism ships with the same default, and it found them because a human
> typed the command, twelve days after the previous run.

And the executive summary:

> three separate mechanisms were repaired within four hours (`observed`,
> `gh pr list` merge times 14:05–14:30Z).

And "What worked":

> One of them, `command-cli-parity.md` O9, argues finding-1 should be routed to
> `/harness-audit` instead of becoming a rule. `/harness-audit` was then run in
> this window and found the constraint O9 named — *Output validation
> checkpoints* — failing, and it was repaired. The gate's prediction and events
> agree.

The counter the record offers is a cadence argument: the audit ran because a
human typed the command, twelve days late. But the proposal contains no
cadence change. `CLAUDE.md`'s *Quarterly Operations* sets the audit cadence at
90 days and *Monthly Operations* at 30; neither is touched. The rule's own
dispatch, as the cost estimate says, is "when a human types `/harness-audit`" —
the same trigger, with a sentence added to what the audit reads.

`no-change` is likewise unweighed. This assay uses that classification twice,
for findings 3 and 4, with reasoning about corroboration conditions; finding-1
does not consider it.

### Why this matters

The strongest evidence in the record is that the existing machinery works: it
found three of four defects and they were repaired the same afternoon, one of
them deliberately deferred to its own PR with its own reproduction and tests.
That is the observation an approver most needs weighed against the proposal,
and the record does not weigh it. If the honest diagnosis is a cadence problem
— twelve days between audits, quarterly by declaration — then the remedy is a
cadence change or a dispatch path, both of which are cheaper than a constraint
and neither of which requires the two-assay threshold. The proposal as it
stands asks for a rule and leaves the cadence exactly where it was.

## Explicitly not objecting to

- **The underlying observation.** That this repository has repeatedly resolved
  indeterminate state to the passing value is well evidenced, and the badge and
  Status-block instances are exactly what the finding says they are. Every
  objection above is about the pattern's boundaries, its layer, its
  corroboration and its enforcement — not about whether the behaviour happened.
- **The decision not to cite assay 1's finding-2.** It is correct: that finding
  carries an erratum, and `_corrected_findings` would exclude the anchor at
  acceptance in any case. Worth noting only that the record presents as
  restraint a move the validator would have made anyway.
- **Naming no `target`.** Correct since #568 — a routed classification refuses
  one, and `_check_target` returns early when `classification in routes`. The
  record's handling of this is exactly right.
- **`overfitting_risk: low` as a property of the rule text.** The text genuinely
  encodes none of the four instances' specifics. My objection is to which
  instances it was generalised from, not to the generality of the wording.
- **The candour of the cost estimate.** Volunteering that the rule becomes the
  eleventh unenforceable constraint, and that declining is a legitimate outcome,
  is the disclosure the loop is built to elicit. O5 disputes the completeness of
  the accounting, not the willingness to give it.
- **`provisional: true` with `expires: 2026-11-23`.** A ninety-day trial on a
  P1 rule is the right shape; O10 objects that nothing will be able to evaluate
  the trial, not that the trial exists.
- **The 23 pending dispositions.** Real, and the assay is right that four hours
  is not a reasonable window in which to demand them. It is a fact about the
  approver's queue, not a defect in this finding's argument, and I decline to
  use it as one.
- **`priority: P1`.** If the finding is valid at all, P1 is defensible. Nothing
  turns on it.
- **The rejected-candidates discipline.** Routing the exemption question to
  `/governance-audit` for the second consecutive assay, and the reflection gap
  to `/reflect` for the third, rather than converting recurrence into rule text,
  is the restraint this agent exists to reward rather than challenge.
