---
spec: harness/assay/2026-08-25T23-46Z-assay.md#finding-1
date: 2026-08-25
mode: spec
diaboli_model: claude-opus-5[1m]
objections:
  - id: O1
    category: premise
    severity: critical
    claim: "The two prior assays pre-registered ADDITION as their corroborating condition; the observed event is a REMOVAL, and the loop's own validator encodes that asymmetry as deliberate — so the `harness-loop` classification rests on corroboration that fails on the pre-registrations' own terms."
    evidence: "Assay 2 finding-3: \"If a third assay observes a constraint **appearing** without a record, this is its corroborating observation.\" Assay 3 finding-4: \"A fourth assay that observes a **hand-added** constraint has two prior `no-change` observations to cite.\" Finding-1 concedes: \"It has now occurred, in the direction of removal rather than addition\" — and asserts one paragraph earlier \"This is precisely the condition the two prior assays pre-registered.\" `check-harness-decisions.py:914-918`: \"A retirement is exempt. The threshold exists to make rules hard to ADD; applying it to removal would mean a rule that turned out to be wrong needed two assays' evidence before anyone could withdraw it... the exact inversion of 'hard to add, easy to retire'.\""
    disposition: accepted
    disposition_rationale: "Accepted. The pre-registered condition in both cited assays names a rule appearing without a record; the observed event was a removal. That direction is not incidental: check-harness-decisions.py exempts retirements from the two-assay threshold on purpose, with the reason written into the code — the threshold exists to make rules hard to ADD, and applying it to removal would invert 'hard to add, easy to retire'. Read on the pre-registrations' own terms, finding-1 has one observation of the harm, not three, and would clear the gate on a filename count. Finding-1 therefore does not proceed at harness-loop. The heading-diff observation itself is sound and stands — an errata against the assay records the correction, and the underlying loop gap remains carried by #606."
  - id: O2
    category: premise
    severity: high
    claim: "\"The loop cannot express this change\" is established by counting occurrences of a phrase across eight files, and the proposed rule's own second paragraph states the loop can express it — so the diagnosed defect is non-use, not inexpressibility."
    evidence: "Finding: \"The loop cannot express this change. Counting occurrences of 'garbage collection', 'garbage-collection' or 'GC rule' across the eight artifacts that constitute the loop... returns **0 in every file**.\" Proposed rule: \"Until a classification routes to `## Garbage Collection`, use `harness-loop` with an explicit `target: HARNESS.md` and name the section in the record's prose.\" `harness/surfaces.yaml:23`: `harness-loop: HARNESS.md`, and `## Garbage Collection` is a section of `HARNESS.md` (`HARNESS.md:656`)."
    disposition: accepted
    disposition_rationale: "Accepted. 'The loop cannot express this change' is a capability claim resting on a phrase count across eight files, and the finding's own proposed rule supplies the workaround that disproves it: harness-loop routes to HARNESS.md (surfaces.yaml:23), and a record naming the GC rule in prose was available throughout the phase. The proxy cannot support the conclusion — the same substitution the phase under assay spent five spec revisions removing. The honest premise is materially weaker: the loop covers this awkwardly, with no section granularity, and nobody used the awkward path. That is a discipline gap, not a schema gap, and it weakens the case for legislating rather than simply using the loop. Errata records the correction."
  - id: O3
    category: implementation
    severity: high
    claim: "The rule instructs authors to set `target: HARNESS.md` on a `harness-loop` record, which the registrar refuses at the acceptance gate — and the finding's own metadata block does not carry the field its rule requires."
    evidence: "Proposed rule: \"use `harness-loop` with an explicit `target: HARNESS.md`\". `harness-registrar.py:775-781` (`apply_target_override`): `if routes.get(classification): die(f\"classification '{classification}' is routed to '{routes[classification]}' in harness/surfaces.yaml, so --target would be silently ignored. Change the route, or suppress it for this project, rather than naming a target the compiler will not use.\")`. `check-harness-decisions.py:960-961` (`_check_target`): `if classification in routes: return` — a target on a routed record is inert. Finding-1's own yaml block declares `classification`, `enforcement`, `surfaces`, `priority`, `evidence`, `overfitting_risk` and **no** `target`; finding-2's block does declare one."
    disposition: accepted
    disposition_rationale: "Accepted, and verified against source. harness-registrar.py:777-781 calls die() when --target is supplied for a routed classification, and surfaces.yaml:23 routes harness-loop to HARNESS.md — so the rule instructs exactly the combination that hard-fails at the acceptance gate. On the proposal path the field is copied through and then ignored by _check_target, so it sits inert until acceptance. The rule's compliance procedure was never executed, and finding-1's own metadata block omitting the target its rule mandates — while finding-2's block declares one — is the proof. An accepted harness-loop record compiles verbatim into HARNESS.md and mirrors to five surfaces, so this would have put a broken instruction into the governing document. Errata carries it so a later revival of the rule text does not inherit the defect."
  - id: O4
    category: implementation
    severity: high
    claim: "For the instance that motivated it, the loop's retirement primitive is unavailable — a retirement HDR must name `supersedes`, and a GC rule predating the loop has no record to withdraw — so the rule forces an additive HDR whose block is applied byte-for-byte into HARNESS.md, meaning every deletion adds governed text to the document."
    evidence: "`check-harness-decisions.py:605-613`: `is_retirement = (\"Withdrawn.\" in rule_section and not rule_blocks(rule_section))`; `if is_retirement and not fm.get(\"supersedes\"): errors.append(... \"a retirement must name the record it withdraws in 'supersedes'. Retiring nothing is not a decision.\")`. Finding-1 itself: \"a GC rule that predates the loop has no record to lapse.\" The proposed rule requires the additive form: \"that record's `## Rule` block names the GC rule and states which section of `HARNESS.md` the change lands in.\" `check-harness-decisions.py:871-874`: the `## Rule` block \"is the verbatim text applied to the target artifact, and Phase 2 checks the applied text against it byte for byte.\""
    disposition: accepted
    disposition_rationale: "Accepted, and on broader grounds than the objection argues. The objection is right that the retirement primitive is unavailable — a retirement HDR must name supersedes, and every GC rule in this repository predates the loop — so the rule forces an additive record that compiles byte-for-byte into HARNESS.md, growing the governing document with tombstones for things it no longer contains. But the deeper point is that no in-document record is needed at all: git history already holds it. `git log -S \"### Template currency\" -- HARNESS.md` returns both endpoints (f316d94 entering, 2fce5a4 leaving), the author, the date, the PR, the issue and the full reasoning in the commit body — more than a tombstone would carry, at no cost to the document. Finding-1's stated harm, that a reader 'finds the answer only by knowing which spec to open', is false as written. Managing tombstones to reproduce what git already records is the wrong trade."
  - id: O5
    category: specification quality
    severity: high
    claim: "\"Feature PR\" is the rule's binding term and is nowhere defined in HARNESS.md; CLAUDE.md's exemption table makes `chore` the documented label for exactly the class of work the cost estimate calls this — so one label escapes the rule entirely, which is cheaper than all three gaming routes the finding names."
    evidence: "Proposed rule: \"may not be added to, retired from, or have its **Tool** or **Enforcement** field changed in `HARNESS.md` by a **feature PR** alone.\" CLAUDE.md, Spec-First Exemptions: \"Feature and behaviour-change PRs require a spec\", and `chore` label / `chore/` prefix is for \"Maintenance, housekeeping, docs additions outside the plugin directory, formatting and metadata fixes\". Finding-1's cost estimate: \"It is a real tax on **housekeeping**: a GC rule whose script was renamed now needs a record.\" Assay: \"#607 carries no exempting label (`observed`, `gh pr list --json labels` returns `[]`)\" — the sole thing that made it a feature PR."
    disposition: moot
    disposition_rationale: "Moot. O1-O4 dispose of finding-1 at four levels: its corroboration fails on the pre-registrations' own terms (O1), its premise rests on a proxy its own rule disproves (O2), its instruction hard-fails at the acceptance gate (O3), and its stated harm is false because git history already answers the question it says only a spec can (O4). This objection argues about the shape of a rule that should not be built. It is recorded rather than dropped so a later reader can see it was read and why it was not answered on its merits."
  - id: O6
    category: risk
    severity: high
    claim: "All three named gaming routes require editing `HARNESS.md`; the cheapest route edits nothing there — change the script or workflow the GC rule's **Tool** field names, and the rule is retired in substance while the text, the heading count and `harness-registrar.py check` all report unchanged."
    evidence: "Proposed rule binds only changes \"in `HARNESS.md`\". GC rules name external tools: `### Secret scanner operational` declares `**Tool**: gitleaks --version && gitleaks detect --source . --no-banner --exit-code 1`; `### Documentation freshness` declares `**Tool**: harness-gc agent` (`HARNESS.md:661-678`). The finding supplies the proof that text and substance already diverge here, in mirror image: \"this repository already has one GC rule in that state, *Affordance review staleness*, running in `gc.yml` while parsing as inactive.\" The finding's own harm metric is a text metric: \"the decision index and `/harness-timeline` will show `Garbage collection active:` moving 19 → 18\"."
    disposition: moot
    disposition_rationale: "Moot. O1-O4 dispose of finding-1 at four levels: its corroboration fails on the pre-registrations' own terms (O1), its premise rests on a proxy its own rule disproves (O2), its instruction hard-fails at the acceptance gate (O3), and its stated harm is false because git history already answers the question it says only a spec can (O4). This objection argues about the shape of a rule that should not be built. It is recorded rather than dropped so a later reader can see it was read and why it was not answered on its merits."
  - id: O7
    category: risk
    severity: medium
    claim: "The two-assay threshold counts filenames, so a `no-change` finding that pre-registers a condition is a free corroboration token — and accepting this finding establishes that any assay can manufacture the threshold for a future rule by writing two cheap `no-change` findings first."
    evidence: "`check-harness-decisions.py:904-907`: \"Distinctness is by assay FILE, not by evidence entry - two anchors into one assay are one assay, and letting them count twice would make the threshold satisfiable by anyone willing to cite the same finding twice.\" Both cited findings are `classification: no-change`, `priority: P2` and `P3`, and both were written by the same agent role that now cashes them. The assay's own Unresolved questions: \"the validator counts filenames and cannot tell a pre-registration from an unrelated mention, so an approver who wants the threshold to mean 'two independent observations of the harm' should say so at the gate rather than let this pass on a count.\""
    disposition: moot
    disposition_rationale: "Moot. O1-O4 dispose of finding-1 at four levels: its corroboration fails on the pre-registrations' own terms (O1), its premise rests on a proxy its own rule disproves (O2), its instruction hard-fails at the acceptance gate (O3), and its stated harm is false because git history already answers the question it says only a spec can (O4). This objection argues about the shape of a rule that should not be built. It is recorded rather than dropped so a later reader can see it was read and why it was not answered on its merits. Noted for the future regardless: the two-assay threshold counting filenames rather than observations is a real weakness in check-harness-decisions.py, and it survives this disposition. It needs its own evidence, not this one."
  - id: O8
    category: scope
    severity: medium
    claim: "A GC rule carries five fields; the rule binds two of them and leaves **Frequency** and **Auto-fix** unbound — and **Auto-fix** is the field that grants an agent write authority over the repository."
    evidence: "`HARNESS.md:661-668`: a GC rule declares `**What it checks**`, `**Frequency**`, `**Enforcement**`, `**Tool**`, `**Auto-fix**`. Proposed rule binds only \"its **Tool** or **Enforcement** field\". The cost estimate names editing `**What it checks**` as gaming route (1) but names neither `**Frequency**` (settable to a cadence that never arrives) nor `**Auto-fix**` (`false` → `true` grants unattended edits). Assay 3 refers to \"the two auto-fix rules\", so `true` is a live value in this corpus."
    disposition: moot
    disposition_rationale: "Moot. O1-O4 dispose of finding-1 at four levels: its corroboration fails on the pre-registrations' own terms (O1), its premise rests on a proxy its own rule disproves (O2), its instruction hard-fails at the acceptance gate (O3), and its stated harm is false because git history already answers the question it says only a spec can (O4). This objection argues about the shape of a rule that should not be built. It is recorded rather than dropped so a later reader can see it was read and why it was not answered on its merits."
  - id: O9
    category: scope
    severity: medium
    claim: "The finding warns in its own prose that a rule written for one half of the shape will need writing again, and then writes exactly that half — the exit, for GC rules only — leaving `## Constraints` entries, the weightier class, on the same ungoverned channel."
    evidence: "Finding-1: \"I name it because it is the same shape from the other direction — no governed entry for a mechanical observation, no governed exit for a GC rule — and a rule written for only the exit half will need writing again.\" The proposed rule's subject is \"A garbage-collection rule\", and it binds only addition/retirement/field-change of GC rules. `HARNESS.md:73` opens `## Constraints`, which the assay's own parse counts at 36 active rules; nothing in the finding argues a constraint leaving `HARNESS.md` unrecorded would be less serious than a GC rule doing so. Assay's Unresolved questions repeat the point: \"If they are worked separately, each will answer half of 'what does the loop do with a rule change that is neither of those things'.\""
    disposition: moot
    disposition_rationale: "Moot. O1-O4 dispose of finding-1 at four levels: its corroboration fails on the pre-registrations' own terms (O1), its premise rests on a proxy its own rule disproves (O2), its instruction hard-fails at the acceptance gate (O3), and its stated harm is false because git history already answers the question it says only a spec can (O4). This objection argues about the shape of a rule that should not be built. It is recorded rather than dropped so a later reader can see it was read and why it was not answered on its merits."
  - id: O10
    category: alternatives
    severity: high
    claim: "The harm named is discoverability, and the cheaper unweighed alternative is to extend the existing deterministic, git-backed owner that already watches `HARNESS.md` for drift — instead of adding another advisory rule with no dispatch path, which is the exact condition finding-3 of the same assay exists to count."
    evidence: "Named harm: \"a reader asking when the project stopped checking template currency finds the answer only by knowing which spec to open.\" Existing owner, `HARNESS.md:596-623` *Harness governance is applied and undrifted*: \"every accepted record must be applied to the artifact its classification routes it to, and no accepted record may differ from its content at the commit that accepted it. ... The frozen-record check is git-backed\", `**Enforcement**: deterministic`, `**Tool**: python3 ai-literacy-superpowers/scripts/harness-registrar.py check (CI: .github/workflows/harness.yml)`. Finding-1 weighs only \"a deterministic version... would be a separate proposal with its own build cost\" — it does not weigh building it *instead of*, nor extending the check that already runs. Finding-3 of the same assay: \"**two** PR-scoped constraints name a tool with no dispatch path anywhere\"; this proposal declares `enforcement: advisory` and \"no validator enforces it today\"."
    disposition: moot
    disposition_rationale: "Moot. O1-O4 dispose of finding-1 at four levels: its corroboration fails on the pre-registrations' own terms (O1), its premise rests on a proxy its own rule disproves (O2), its instruction hard-fails at the acceptance gate (O3), and its stated harm is false because git history already answers the question it says only a spec can (O4). This objection argues about the shape of a rule that should not be built. It is recorded rather than dropped so a later reader can see it was read and why it was not answered on its merits. Noted for the future regardless: extending the existing deterministic, git-backed 'Harness governance is applied and undrifted' check is a better shape than a new advisory rule, and that observation outlives finding-1 — though O4's git-history point weakens the case for building anything here at all."
  - id: O11
    category: alternatives
    severity: medium
    claim: "No alternative classification is weighed at all, and the one chosen is the only one that triggers the two-assay threshold the finding then has to argue past — a choice the assay corpus elsewhere records reasoning for and this finding does not."
    evidence: "Finding-1's yaml declares `classification: harness-loop` with no accompanying reasoning; the body's only classification sentence is the transitional clause in the rule text. Contrast assay 3, which recorded its reasoning: \"`script-validator` would route to the same file and would clear the two-assay threshold, and I am not taking it: `harness-workflow-step-masking.md` O3 names that exact move.\" `check-harness-decisions.py:912`: `if status != \"accepted\" or classification != \"harness-loop\" or imported: return` — every other classification is exempt from the threshold. Finding-2 in the same assay chooses `agent-instruction` with an explicit `target` and an explicit alternative-home paragraph."
    disposition: moot
    disposition_rationale: "Moot. O1-O4 dispose of finding-1 at four levels: its corroboration fails on the pre-registrations' own terms (O1), its premise rests on a proxy its own rule disproves (O2), its instruction hard-fails at the acceptance gate (O3), and its stated harm is false because git history already answers the question it says only a spec can (O4). This objection argues about the shape of a rule that should not be built. It is recorded rather than dropped so a later reader can see it was read and why it was not answered on its merits."
  - id: O12
    category: specification quality
    severity: medium
    claim: "`overfitting_risk: medium` is asserted with no supporting sentence anywhere in the finding, and is inconsistent with finding-2's `high` on comparable evidence — one PR, one author, one phase, plus rule text carrying a clause tied to this repository's current schema."
    evidence: "Finding-1's yaml declares `overfitting_risk: medium`; no sentence in finding-1 mentions overfitting. Finding-2 argues its value explicitly: \"Overfitting risk is **high** — one spec, one author, one phase — and an approver would be within their rights to decline it on that basis alone and wait for a second instance.\" Finding-1's own evidence is one deletion, in one PR, in one phase, and the two cited assays record the condition as **not** occurring in their windows. The rule text embeds a transitional clause — \"Until a classification routes to `## Garbage Collection`\" — that is meaningful only against this repository's `surfaces.yaml` at this commit."
    disposition: moot
    disposition_rationale: "Moot. O1-O4 dispose of finding-1 at four levels: its corroboration fails on the pre-registrations' own terms (O1), its premise rests on a proxy its own rule disproves (O2), its instruction hard-fails at the acceptance gate (O3), and its stated harm is false because git history already answers the question it says only a spec can (O4). This objection argues about the shape of a rule that should not be built. It is recorded rather than dropped so a later reader can see it was read and why it was not answered on its merits."
---

## O1 — premise — critical

### Claim

The finding's authority to reach the loop layer rests on two prior assays. Both
pre-registered the **appearance** of a rule without a record as the condition
that would corroborate. What occurred is the **disappearance** of one. The loop's
own validator treats those two events as governed differently on purpose, so the
corroboration is not merely imperfect — it points at the half of the asymmetry
the loop deliberately left cheap.

### Evidence

Assay 2, finding-3:

> If a third assay observes a constraint **appearing** without a record, this is
> its corroborating observation.

Assay 3, finding-4:

> A fourth assay that observes a **hand-added** constraint has two prior
> `no-change` observations to cite; one that does not has the strongest
> available evidence that the restraint is real rather than incidental.

Finding-1 concedes the mismatch and then overrides it in adjacent sentences:

> This is precisely the condition the two prior assays pre-registered. [...]
> It has now occurred, in the direction of removal rather than addition.

And `check-harness-decisions.py:914-918` states the asymmetry as a design
decision, not an oversight:

> A retirement is exempt. The threshold exists to make rules hard to ADD;
> applying it to removal would mean a rule that turned out to be wrong needed
> two assays' evidence before anyone could withdraw it, and would stay in force
> meanwhile — the exact inversion of "hard to add, easy to retire".

A secondary mismatch sits under the same claim: assay 3's observation was a
diff of 55 headings scoped to `## Constraints` and `## Garbage Collection`;
finding-1's is a file-wide diff of 64 `### ` headings. Those are not the same
instrument, and the file-wide diff does not by itself place the deleted heading
in `## Garbage Collection` — the section the proposed rule is scoped to.

### Why this matters

`harness-loop` is the classification that carries the two-assay threshold, and
the threshold is the only thing standing between a single incident and a change
to the document that governs everything else. If the corroboration is read on
the pre-registrations' own terms, this finding has **one** observation of the
harm, not three. Accepting it means the threshold was cleared by a filename
count over two findings that recorded the opposite event not happening — which
is what the assay's own Unresolved question warns an approver against, and then
proceeds past. The honest reading is not that the pre-registration is worthless;
it is that a pre-registration naming addition cannot corroborate a removal, and
the loop wrote down why it should not.

## O2 — premise — high

### Claim

The load-bearing claim — that the governed loop has no way to express this
change — is established by counting occurrences of a phrase, and the proposed
rule's second paragraph contradicts it by explaining how to express the change
today. The defect actually observed is that nobody used the loop, not that the
loop was unusable.

### Evidence

The finding:

> The loop cannot express this change. Counting occurrences of "garbage
> collection", "garbage-collection" or "GC rule" across the eight artifacts that
> constitute the loop [...] returns **0 in every file**.

The proposed rule, forty lines later:

> Until a classification routes to `## Garbage Collection`, use `harness-loop`
> with an explicit `target: HARNESS.md` and name the section in the record's
> prose.

`harness/surfaces.yaml:23` routes `harness-loop: HARNESS.md`, and
`## Garbage Collection` is a section of `HARNESS.md` (`HARNESS.md:656`). A
`harness-loop` HDR naming the GC rule in prose was available throughout the
phase.

### Why this matters

Absence of a phrase from eight files is a proxy. The conclusion drawn from it —
inexpressibility — is a capability claim that the proxy cannot support, and the
finding's own remedy demonstrates the capability exists. This is the same
substitution the phase under assay spent five spec revisions removing, and which
the executive summary praises the phase for removing: "A mechanism that reported
a conclusion it never measured was traced to its evidence." The distinction is
not academic. If the loop can express the change, the gap is discipline, and
the case for elevating to `harness-loop` — for changing the governing document
rather than the practice — weakens considerably. If the loop genuinely cannot,
the remedy is a new route in `surfaces.yaml`, not a prose rule instructing a
workaround.

## O3 — implementation — high

### Claim

The rule text instructs future authors to do something the tooling refuses.
`harness-registrar.py` exits with an error when `--target` is supplied for a
routed classification, and `harness-loop` is routed. The finding's own
metadata block omits the field its rule mandates.

### Evidence

Proposed rule:

> use `harness-loop` with an explicit `target: HARNESS.md`

`harness-registrar.py:775-781`, in `apply_target_override`, on the acceptance
path:

```python
routes, _ = load_matrix(args.root)
classification = str(fm.get("classification") or "")
if routes.get(classification):
    die(f"classification '{classification}' is routed to "
        f"'{routes[classification]}' in harness/surfaces.yaml, so --target "
        "would be silently ignored. Change the route, or suppress it for this "
        "project, rather than naming a target the compiler will not use.")
```

On the proposal path the field is copied through (`harness-registrar.py:463-464`)
and then ignored: `check-harness-decisions.py`'s `_check_target` returns early
when `classification in routes`.

Finding-1's own yaml block declares `classification`, `enforcement`, `surfaces`,
`priority`, `evidence` and `overfitting_risk` — and no `target`. Finding-2's
block, in the same assay, does declare one.

### Why this matters

An accepted `harness-loop` record is compiled verbatim into `HARNESS.md` and
mirrored to five surfaces. This rule would put an instruction into the governing
document that is inert on one path and a hard `die()` on the other, and the
first author to follow it literally at the acceptance gate gets a refusal
telling them to change the route instead. That is not a typo; it is a rule whose
compliance procedure was not tried. The finding not following its own rule in
the record proposing it is the cheapest available check that this was never
exercised.

## O4 — implementation — high

### Claim

Applied to the instance that motivated it, the rule demands a record the schema
cannot produce in retirement form, and forces the additive form instead — so
recording a deletion **adds** governed text to `HARNESS.md`, and every future
GC-rule retirement leaves a tombstone rule inside the compiled region.

### Evidence

`check-harness-decisions.py:600-613`:

```python
is_retirement = ("Withdrawn." in rule_section
                 and not rule_blocks(rule_section))
fm["__retirement"] = is_retirement

if is_retirement and not fm.get("supersedes"):
    errors.append(
        f"FAIL: {where}: a retirement must name the record it withdraws in "
        "'supersedes'. Retiring nothing is not a decision."
    )
```

Finding-1 establishes that no such record exists: "a GC rule that predates the
loop has no record to lapse," and `harness/decisions/` holds six records, "none
concerns it."

The proposed rule therefore mandates the additive form — "that record's
`## Rule` block names the GC rule and states which section of `HARNESS.md` the
change lands in" — and `check-harness-decisions.py:871-874` states what happens
to that block: it "is the verbatim text applied to the target artifact, and
Phase 2 checks the applied text against it byte for byte."

### Why this matters

The rule's purpose is to make a removal visible. The mechanism it selects makes
the removal visible by appending a paragraph to the document the removal was
taken from, inside the generated region, where it is itself subject to
`expires`, `/harness-review` and the frozen-record check. `HARNESS.md` grows
monotonically with the record of things it no longer contains. Worse, the loop's
actual retirement primitive — the `Withdrawn.` form, with its threshold
exemption — is unreachable for exactly the population the rule cares about:
rules that predate the loop and therefore have nothing to supersede. That is the
whole population today. A rule whose compliance path is unavailable for every
current instance of its subject is not a rule anyone can follow.

## O5 — specification quality — high

### Claim

"Feature PR" carries the entire prohibition and is defined nowhere in
`HARNESS.md`. Under the definition the repository actually operates — CLAUDE.md's
spec-first exemption table — adding one `chore` label makes a PR not a feature
PR. That escape costs less than any of the three gaming routes the cost estimate
prices, and it is the label the repository's own convention recommends for this
class of work.

### Evidence

Proposed rule:

> A garbage-collection rule may not be added to, retired from, or have its
> **Tool** or **Enforcement** field changed in `HARNESS.md` by a **feature PR**
> alone.

CLAUDE.md, Spec-First Exemptions: "Feature and behaviour-change PRs require a
spec", with the `chore` label covering "Maintenance, housekeeping, docs
additions outside the plugin directory, formatting and metadata fixes."

The finding's own cost estimate names the affected class in the same vocabulary:

> It is a real tax on **housekeeping**: a GC rule whose script was renamed now
> needs a record.

And the assay records that the label field is what made #607 a feature PR at
all: "#607 carries no exempting label (`observed`, `gh pr list --json labels`
returns `[]`)."

### Why this matters

The brief for pricing a rule is to name the cheapest way around it. The three
routes named cost, respectively, a prose edit, an HTML-comment wrap, and a
fabricated citation — all of which require touching `HARNESS.md` and all of
which appear in a governance diff. The label route costs one click, requires no
edit to any governed file, and simultaneously exempts the PR from the spec-first
gate. It is not even adversarial: a maintainer doing GC housekeeping in good
faith would reach for `chore` because CLAUDE.md tells them to, and would fall
outside the rule without ever intending to. A rule whose binding term routes the
most likely compliant actor out of scope has an availability problem, not a
gaming problem, and the two need pricing separately.

## O6 — risk — high

### Claim

All three gaming routes the finding prices require editing `HARNESS.md`. The
cheapest route does not touch it: change the script or workflow the GC rule's
**Tool** field names, and the rule stops running while its text, the heading
count, `Garbage collection active: 19`, and `harness-registrar.py check` all
report unchanged. The finding cites the mirror image of this and does not draw
the inference.

### Evidence

GC rules delegate to external artefacts. `HARNESS.md:670-678`:

> `**Tool**: gitleaks --version && gitleaks detect --source . --no-banner --exit-code 1`

and `HARNESS.md:661-668`:

> `**Tool**: harness-gc agent`

The proposed rule binds only changes "in `HARNESS.md`". Editing `gc.yml`, or the
script a **Tool** field names, leaves every field verbatim.

The finding already holds the proof that text and substance diverge here — in
the opposite direction:

> this repository already has one GC rule in that state, *Affordance review
> staleness*, running in `gc.yml` while parsing as inactive.

And the harm the finding names is a text-level metric:

> the decision index and `/harness-timeline` will show
> `Garbage collection active:` moving 19 → 18 with no record explaining why

### Why this matters

Under the substance route the counter stays at 19 and no reader is prompted to
ask anything, which is strictly worse than the incident that motivated the rule:
there, at least, the count moved. The compiled governing rule in
`advocatus-diaboli/SKILL.md` names this failure shape directly —
"A reachable code path that reaches a passing value without reading the thing it
reports on is a defect, not a default" — and a GC-rule mechanism that measures
retirement by heading count has exactly that shape. The cost estimate's job was
to hand the approver the cheapest evasion. It handed them three that are all
more expensive and more visible than the one it did not name.

## O7 — risk — medium

### Claim

The two-assay threshold is satisfiable by citing findings that recorded the
condition **not** occurring, because the validator can only count filenames.
Accepting this finding establishes that any assay can prepay the threshold for a
future rule by writing two cheap `no-change` findings that pre-register a
condition.

### Evidence

`check-harness-decisions.py:904-907`:

> Distinctness is by assay FILE, not by evidence entry - two anchors into one
> assay are one assay, and letting them count twice would make the threshold
> satisfiable by anyone willing to cite the same finding twice.

Both cited findings are `classification: no-change` (assay 2 finding-3, assay 3
finding-4, `priority: P3`), which is to say neither carried a proposal, neither
cost anything to write, and both were authored by the same agent role that now
spends them. The assay names the exposure itself:

> the validator counts filenames and cannot tell a pre-registration from an
> unrelated mention, so an approver who wants the threshold to mean "two
> independent observations of the harm" should say so at the gate rather than
> let this pass on a count.

### Why this matters

The threshold exists so that "a single incident cannot reach the loop layer."
If a `no-change` finding that says "this did not happen, and if it ever does,
cite me" counts toward it, the cost of manufacturing loop-layer authority is two
paragraphs across two assays — cheaper than any gaming route the finding prices
for its own rule, and it games the gate rather than the rule. The steel-man is
real and worth stating: a pre-registered test is epistemically stronger than
post-hoc corroboration, and the finding argues this honestly. But the strength
of pre-registration comes from the registered condition being the one observed,
which O1 disputes — and once that link is broken, what remains is a filename
count. The precedent set by accepting is durable and applies to every future
proposal, not just this one.

## O8 — scope — medium

### Claim

A GC rule declares five fields. The rule binds two. Of the three left unbound,
**Auto-fix** is the field that authorises an agent to write to the repository
unattended, and **Frequency** is the field that can nullify a rule without
changing a word of what it checks.

### Evidence

`HARNESS.md:661-668` gives the GC-rule shape:

```markdown
### Documentation freshness

- **What it checks**: ...
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent
- **Auto-fix**: false
```

The proposed rule binds "its **Tool** or **Enforcement** field". The cost
estimate names `**What it checks**` as gaming route (1) but names neither
`**Frequency**` nor `**Auto-fix**`. Assay 3 refers to "the two auto-fix rules",
confirming `true` is a live value in this corpus.

### Why this matters

Two of the three unbound fields carry more consequence than one of the two
bound. `**Auto-fix**: false → true` converts a reporting rule into one that
edits the repository on a schedule, with no record and no approver — a strictly
larger governance event than renaming its **Tool**. `**Frequency**: weekly →
quarterly` retires a rule in effect while leaving every bound field intact. If
the principle is that a GC rule's governed properties should not change without
a record, the field list is underinclusive in the two directions that matter
most.

## O9 — scope — medium

### Claim

The finding argues, in its own words, that writing a rule for one half of the
shape guarantees writing it again — and then writes the exit half, for GC rules
only, leaving the entry half and the `## Constraints` population uncovered.

### Evidence

Finding-1:

> I name it because it is the same shape from the other direction — no governed
> entry for a mechanical observation, no governed exit for a GC rule — and a
> rule written for only the exit half will need writing again.

The proposed rule's subject is "A garbage-collection rule". `HARNESS.md:73`
opens `## Constraints`, which the same assay parses at 36 active rules —
26 deterministic, 6 unverified, 4 agent. Nothing in the finding argues that a
constraint leaving `HARNESS.md` unrecorded would be a smaller event than a GC
rule doing so.

The assay's Unresolved questions repeat the concern at the issue level:

> If they are worked separately, each will answer half of "what does the loop do
> with a rule change that is neither of those things", and the second will
> inherit the first's answer as precedent — which is the thing #606 opened to
> prevent.

### Why this matters

The steel-man for narrow scope is proportionality to evidence, and it is a good
argument — the observed instance was a GC rule and only a GC rule. But the
finding does not make that argument; it makes the opposite one and then does not
follow it. An approver reading the record cannot tell whether the narrow scope
is deliberate restraint or an oversight the finding itself flagged and did not
act on, and the difference determines whether the second half arrives as a
coherent extension or as the precedent-inheritance problem #606 exists to
prevent.

## O10 — alternatives — high

### Claim

The harm is discoverability, and there is an existing deterministic, git-backed,
CI-dispatched owner already watching `HARNESS.md` for exactly this class of
drift. Extending it was not weighed. The proposal instead adds another advisory
rule with no dispatch path — the condition finding-3 of the same assay exists to
correct the count of.

### Evidence

The named harm:

> a reader asking when the project stopped checking template currency finds the
> answer only by knowing which spec to open

The existing owner, `HARNESS.md:596-623`, *Harness governance is applied and
undrifted*:

> every accepted record must be applied to the artifact its classification
> routes it to, and no accepted record may differ from its content at the commit
> that accepted it. [...] The frozen-record check is git-backed because region
> drift alone cannot see a rule reworded in the accepted record and then
> recompiled

with `**Enforcement**: deterministic` and
`**Tool**: python3 ai-literacy-superpowers/scripts/harness-registrar.py check
(CI: .github/workflows/harness.yml)`.

Finding-1 weighs the deterministic option only as a successor:

> a deterministic version — diff the `### ` heading set under
> `## Garbage Collection` in a PR and require a new `harness/decisions/` file in
> the same PR — would be a separate proposal with its own build cost.

It does not weigh building that check *instead of* the advisory rule, nor
folding it into a check that already runs in CI, already reads `HARNESS.md`,
and already compares against git.

Finding-3, in the same assay: "**two** PR-scoped constraints name a tool with no
dispatch path anywhere."

### Why this matters

The refusal to declare `validated` without building it is correct and I do not
challenge it (see below). But "advisory now, deterministic later" is not the
only honest option; "deterministic now, as an extension of the thing already
doing this" is available and materially cheaper than the finding's estimate
implies, because the git-diff machinery, the CI job and the failure-reporting
path all exist. Choosing the advisory route instead spends a slot against the
three-per-cycle cap, adds a rule the enforcement report will list as unenforced,
and — on the finding's own numbers — grows a category the same assay is
simultaneously complaining about two findings later.

## O11 — alternatives — medium

### Claim

No alternative classification is weighed anywhere in the finding, and the one
chosen is the only classification in the vocabulary that triggers the two-assay
threshold the finding then spends a section of the assay arguing past.

### Evidence

Finding-1's yaml declares `classification: harness-loop` with no reasoning
paragraph; the only classification prose in the body is the transitional clause
inside the rule text itself.

`check-harness-decisions.py:912`:

```python
if status != "accepted" or classification != "harness-loop" or imported:
    return
```

Every other classification is exempt.

The corpus shows what recorded reasoning looks like. Assay 3:

> `script-validator` would route to the same file and would clear the two-assay
> threshold, and I am not taking it: `harness-workflow-step-masking.md` O3 names
> that exact move [...] and it would be worse for me to make it knowingly,
> having read the objection.

Finding-2, in this very assay, names its target, argues for it, and names the
defensible alternative home: "`skills/advocatus-diaboli/SKILL.md` is the
defensible alternative home [...] and the approver may move it there."

### Why this matters

The behaviour the rule governs — "a change of this kind carries a record" — is a
statement about how work proceeds, which is at least arguably
`agent-instruction` or `turn-instructions` territory. That is not obviously
right, and `harness-loop` may well be correct: the change lands in `HARNESS.md`
and the rule is about `HARNESS.md`'s contents. But the approver at the gate has
no record of the alternatives having been considered, on the one dimension that
determines whether the contested threshold applies at all. The corpus sets a
higher standard than this finding meets, twice over, including in the assay's
own next finding.

## O12 — specification quality — medium

### Claim

`overfitting_risk: medium` appears in the metadata block and is argued nowhere.
On the finding's own evidence it looks understated, and it is inconsistent with
finding-2's `high`, which is argued explicitly on a comparable base.

### Evidence

Finding-1's yaml: `overfitting_risk: medium`. No sentence in finding-1's body
mentions overfitting.

Finding-2, same assay, same author, same phase:

> Overfitting risk is **high** — one spec, one author, one phase — and an
> approver would be within their rights to decline it on that basis alone and
> wait for a second instance.

Finding-1's base: one deletion, one PR, one phase — and the two cited assays
record the condition as **not** occurring in their windows, which is evidence
about frequency pointing the other way. The rule text also embeds a clause
meaningful only against this repository's `surfaces.yaml` at this commit:
"Until a classification routes to `## Garbage Collection`".

### Why this matters

`overfitting_risk` is carried into the HDR by the registrar
(`harness-registrar.py:470`) and is one of the few fields an approver reads as a
direct signal at the acceptance gate. An unargued value is not a signal — it is a
number the approver has to re-derive. Here the re-derivation goes the other way
than the field claims: the observed frequency is one event in four assay
windows, the rule names this repository's section headings and field names, and
its second paragraph is an explicit workaround for the current schema. Rating it
below the rule that the same assay rates `high` on a strictly weaker basis is
the kind of inconsistency that makes the field stop meaning anything.

## Explicitly not objecting to

- **The heading-diff method and its result.** Extracting the `### ` heading set
  at `9a160d6` and `9995863` with HTML comments stripped is the right instrument
  for "did a rule leave the file", the result (64 → 63, one deletion, no
  additions) is stated with its method, and I have no reason to doubt it. My
  objection at O1 concerns whether the *prior* assays measured the same thing,
  not whether this measurement is sound.
- **`enforcement: advisory` and the refusal to declare `validated`.** The
  reasoning — "Declaring `validated` here without building it would reproduce
  the defect this phase spent five spec revisions removing" — is exactly right
  and is the finding at its strongest. O10 argues for building the deterministic
  version *instead*, not for declaring one that does not exist.
- **The disclaimer that the feature-PR channel was not wrong.** Separating "the
  channel was chosen deliberately and recorded" from "no record accompanied it"
  is a real distinction, honestly drawn, and it is what keeps the finding from
  overclaiming. I considered arguing it contradicts a rule that forbids the
  channel, and it does not: "alone" does the work.
- **Refusing to inflate #602 into a second finding.** "the heading diff shows
  nothing entered `HARNESS.md` that way, so nothing was exercised" is correct
  materiality discipline, and naming the shape inside finding-1 rather than
  claiming an instance is the right call.
- **The proposed rule block omitting `**Enforcement**`, `**Tool**` and
  `**Scope**`.** Every finding in the corpus writes the block this way and the
  registrar supplies those fields from frontmatter at compile time. This is
  convention, not a defect.
- **Raising the corroboration doubt in Unresolved questions.** Writing "an
  approver who wants the threshold to mean 'two independent observations of the
  harm' should say so at the gate rather than let this pass on a count" is
  exemplary and is what made O1 and O7 writable at all. My objection is to
  proceeding to `harness-loop` despite it, not to naming it.
- **`priority: P1`.** A rule leaving the governing document with every mechanism
  reporting `OK` is a serious class of event, and P1 is defensible on that alone
  regardless of whether this particular rule is the right response.
