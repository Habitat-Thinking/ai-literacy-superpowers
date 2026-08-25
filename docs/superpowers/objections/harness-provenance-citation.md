---
spec: harness/assay/2026-08-25T08-08Z-assay.md#finding-1
date: 2026-08-25
mode: spec
diaboli_model: claude-opus-5
objections:
  - id: O1
    category: premise
    severity: critical
    claim: "The finding diagnoses a scope defect in an existing rule where its own evidence shows a dispatch defect in that rule's enforcement path; broadening the text of a gate that was never run cannot prevent the recurrence."
    evidence: "Assay, Rejected candidates: 'No objection record, choice-story record or consultation record exists for any of the six specs' and '.github/workflows/harness.yml runs eight deterministic constraints and none of the agent-enforced ones'. Meanwhile docs/superpowers/objections/cadence-sentinels-s7-docs-design.md O1 shows the diaboli DID detect this exact class in occurrence 1, and the human accepted it."
    disposition: pending
    disposition_rationale: null
  - id: O2
    category: premise
    severity: critical
    claim: "The finding's headline factual claim is false for a third of its own fixture: S4 and S5 carry no Provenance line at all, yet two of the four cited deviations come from those two specs."
    evidence: "Finding: 'Six specs — 2026-08-23-harness-evolution-s0 through -s5 — carry the line **Provenance:** the Harness Assayer / Harness Registrar build spec, supplied in conversation 2026-08-23.' Only s0 (line 14), s1 (16), s2 (14) and s3 (13) carry it. 2026-08-23-harness-evolution-s4-review-demotion-design.md and -s5-observatory-design.md have no Provenance line in their headers."
    disposition: pending
    disposition_rationale: null
  - id: O3
    category: implementation
    severity: critical
    claim: "The rule names advocatus-diaboli as its enforcement tool, but nothing routes advocatus-diaboli to HARNESS.md; the rule would ship inert on the day it lands, exactly as its sibling constraint already has."
    evidence: "ai-literacy-superpowers/agents/advocatus-diaboli.agent.md, ai-literacy-superpowers/skills/advocatus-diaboli/SKILL.md and ai-literacy-superpowers/commands/diaboli.md contain zero references to HARNESS.md. orchestrator.agent.md line 394: 'Dispatch the advocatus-diaboli agent with the spec file path and mode: spec' — no harness context is passed."
    disposition: pending
    disposition_rationale: null
  - id: O4
    category: implementation
    severity: critical
    claim: "The claim that the proposed text 'is written to sit inside' the existing constraint is contradicted by the mechanism that will apply it: the compiler can only emit a new `### HDR-...` heading into a generated region appended to the end of HARNESS.md."
    evidence: "harness-registrar.py render_region (line 992): `out += [\"\", f\"### {record.id} — {record.fm.get('title')}\", ...]`; apply_region (line 887-889) appends the region at end-of-file when no markers exist. HARNESS.md has no harness-registrar markers and ends at `## Status` (line 1168)."
    disposition: pending
    disposition_rationale: null
  - id: O5
    category: scope
    severity: high
    claim: "The rule's trigger condition — a spec that names a source document as its authority — does not reach S4 and S5, which make build-spec claims while naming no authority; the evasion the cost section dismisses as too expensive has already occurred, free, inside the negative fixture."
    evidence: "Cost estimate: 'Dropping the provenance line entirely — a spec that names no authority is not covered, so the cheapest evasion is to stop attributing, which would cost more than the rule saves.' s4 line 132 'The build spec requires provisional: true...' and s5 line 35 'The build spec's example line does not say...' both appear in specs with no Provenance line."
    disposition: pending
    disposition_rationale: null
  - id: O6
    category: implementation
    severity: high
    claim: "Transcription cannot deliver the benefit the rule is sold on: there is no artefact of the source conversation, so a transcript is an unverifiable assertion by the same author in the same session, and a reader still cannot check the deviations."
    evidence: "Proposed rule: 'Where the source was supplied in conversation, transcribe it into docs/superpowers/ ... and cite that file by path.' docs/superpowers/cadence-sentinels-charter.md line 26: 'This file is the transcription. The constraints below are quoted verbatim from that build spec' — an assertion with nothing to diff against."
    disposition: pending
    disposition_rationale: null
  - id: O7
    category: alternatives
    severity: high
    claim: "A deterministic PR-time check is materially cheaper, would have fired in both occurrences including the one where no agent ran, and sits at the layer the assay's own ownership test selects — the finding does not weigh it."
    evidence: "Finding-2 in the same assay applies exactly this reasoning: 'This is a defect in a validator, and the remedy is a change to that validator, so script-validator is where it sits.' Finding-1 applies the opposite reasoning to a remedy that is also a change to a check. HDR reference, refusals table: the two-assay promotion threshold binds only `harness-loop`."
    disposition: pending
    disposition_rationale: null
  - id: O8
    category: scope
    severity: high
    claim: "The grandfather clause exempts the defect that motivates the rule, and no remediation is proposed, so the four uncheckable deviations sitting in the repository today remain uncheckable after acceptance."
    evidence: "Proposed rule: 'Specs with filename date before 2026-08-25 are exempt.' All six harness-evolution specs are dated 2026-08-23. The finding proposes no equivalent of the transcription that 1133b9c performed for the previous epic."
    disposition: pending
    disposition_rationale: null
  - id: O9
    category: implementation
    severity: high
    claim: "The finding's three load-bearing arguments sit after its YAML metadata block, where /harness-propose discards them; the approver will read an HDR whose 'Why this layer', 'Validation' and 'Rejected alternatives' sections are TODO placeholders."
    evidence: "harness-registrar.py _parse_finding line 297: `observation = preamble.split(\"```\", 1)[0].strip()`. The 'Why this is a tightening', 'Overfitting risk: low' and 'Validation plan' paragraphs are at assay lines 202-221, after the metadata fence at 189-200. TIER2_PLACEHOLDERS (line 77) then emits '_TODO —' for all four required harness-loop sections."
    disposition: pending
    disposition_rationale: null
  - id: O10
    category: implementation
    severity: high
    claim: "The instruction to transcribe the source 'as the first commit of the epic' collides head-on with the Spec-First Check, which fails any first commit containing a non-spec file."
    evidence: "Proposed rule: 'transcribe it into docs/superpowers/ as the first commit of the epic'. .github/workflows/spec-first-check.yml lines 95-126: files not matching `docs/superpowers/specs/*.md` produce '::error::Non-spec file in first commit' and 'First commit must contain ONLY spec files'."
    disposition: pending
    disposition_rationale: null
  - id: O11
    category: premise
    severity: high
    claim: "The two-occurrence evidence base is weaker than the prose asserts and weaker still by the time it reaches the approver: independence is claimed without evidence, and the second occurrence cannot be represented in the HDR evidence list at all."
    evidence: "Finding: 'Two independent occurrences, two different epics, two different authors' sessions'. Commit 1133b9c appears only in prose; the metadata `evidence:` list holds two of the six specs, the charter and HARNESS.md. HARNESS.md line 614: 'an evidence reference naming a repository path that no longer exists fails' — the corpus takes paths, not SHAs. docs/superpowers/objections/cadence-sentinels-s7-docs-design.md, where the defect was first adjudicated by a human, is absent."
    disposition: pending
    disposition_rationale: null
  - id: O12
    category: specification quality
    severity: medium
    claim: "The validation plan cannot falsify the half of the rule its own cost section calls load-bearing, and its positive fixture is a retrofit rather than a spec that ever passed the gate."
    evidence: "Validation plan: 'If the gate cannot separate those two without reading either spec's content, the rule is not falsifiable and should be refused.' Cost estimate: 'the \"name the clause you depart from\" half is load-bearing rather than decorative' — a check that is irreducibly content-reading. The positive fixture's charter citation was added by 1133b9c on 2026-08-13, five days after the spec was written."
    disposition: pending
    disposition_rationale: null
---

## O1 — premise — critical

### Claim

The finding diagnoses the 2026-08-23 recurrence as a *scope* defect in the rule
promoted on 2026-08-13 — the narrow half was generalised, the wide half was not.
The assay's own evidence supports a different diagnosis: the promoted rule's only
enforcement mechanism was never run on the epic that reproduced the defect.
Widening the text of a gate nobody dispatched cannot prevent a third occurrence.

### Evidence

From the assay's own Rejected candidates section:

> **PRs #540–#545 merged with no objection record, no choice-story record and no
> exempting label.** … Worth noting for whoever runs it:
> `.github/workflows/harness.yml` runs eight deterministic constraints and none
> of the agent-enforced ones, so CI going green on these PRs never spoke to this.

And from the first occurrence, which the finding presents as the un-carried-forward
lesson — `docs/superpowers/objections/cadence-sentinels-s7-docs-design.md`, O1:

> "S7 establishes that the epic's cited source document cannot be found in either
> repository, then quarantines that finding to a single acceptance item instead of
> drawing the conclusion it forces — that every S1-S6 provenance line cites a
> document nobody can produce."

That objection was raised by this agent, adjudicated `accepted` by the human, and
is what produced `1133b9c`. So in occurrence 1 the mechanism worked — six slices
late, but it worked. In occurrence 2 the mechanism did not run at all.

### Why this matters

The finding's remedy is a broader rule enforced by the same agent through the same
dispatch path. If the causal story is "the rule was too narrow", the remedy fits.
If the causal story is "the gate is per-spec, dispatched by hand, and skipped for
an entire six-PR epic without anything noticing", the remedy is unrelated to the
cause and the next epic reproduces the defect a third time with a wider rule on
the books. The assay contains the evidence for the second story and routes it to
`/harness-audit` on ownership grounds, which is defensible for the *adjudication
records* candidate but leaves finding-1's causal claim resting on the first story
without ever testing it against the second.

There is a sharper version still. Occurrence 1 was caught at S7 — the last slice
of a seven-slice epic — because nothing in a per-spec review makes an epic-scale
citation pattern visible until six specs have accumulated. That is a property of
the gate's granularity, not of the rule's wording, and no wording change fixes it.

## O2 — premise — critical

### Claim

The finding's headline observation is factually wrong about a third of its own
fixture. Two of the six specs carry no `**Provenance:**` line, and those two are
the source of two of the four deviations the finding presents as the harm.

### Evidence

The finding states:

> Six specs — `2026-08-23-harness-evolution-s0` through `-s5` — carry the line
> `**Provenance:** the Harness Assayer / Harness Registrar build spec, supplied
> in conversation 2026-08-23`.

Grepping `Provenance` across `docs/superpowers/specs/` returns four
harness-evolution hits, not six: `s0` line 14, `s1` line 16, `s2` line 14, `s3`
line 13. The headers of `2026-08-23-harness-evolution-s4-review-demotion-design.md`
and `2026-08-23-harness-evolution-s5-observatory-design.md` run Status / Date /
Issue / Epic / Depends on / Scope / Explicitly out of scope and then go straight
to `## 1. Problem Statement`. Neither names an authority.

Two of the four deviations the finding cites come from precisely those two specs:

> S4 §132 "The build spec requires `provisional: true` with a mandatory `expires`
> date", S5 §35 "The build spec's example line does not say whether 'expired'
> appears in the feed".

The secondary count is also off. The finding says "`grep` returns thirteen `build
spec` references across the six specs"; a case-sensitive grep for `build spec`
across the six returns nineteen lines (s0: 2, s1: 4, s2: 4, s3: 5, s4: 1, s5: 3).

### Why this matters

This is the evidentiary foundation of a rule proposed for `HARNESS.md`, and it is
wrong in a way that is one grep away — which is the failure mode the sibling
constraint *Specs cite the source of a claimed convention* was written against,
reproduced in the finding that proposes to extend that constraint. The sibling's
own rule text names the shape: "A table built from the examples that fit is not a
citation." Six is the count that fits the story; four is the count.

The consequence is not merely embarrassment. The miscount conceals O5: the two
specs that fall outside the claim are exactly the two the proposed rule's trigger
condition does not reach.

## O3 — implementation — critical

### Claim

The rule declares `Enforcement: agent` with `Tool: advocatus-diaboli (spec-mode
gate)`. Nothing in the advocatus-diaboli agent definition, its skill, the
`/diaboli` command, or the orchestrator's dispatch instructions directs that agent
to read `HARNESS.md`. A rule compiled into `HARNESS.md` and enforced by an agent
that never opens `HARNESS.md` is inert on the day it lands.

### Evidence

- `ai-literacy-superpowers/agents/advocatus-diaboli.agent.md` — no occurrence of
  `HARNESS`.
- `ai-literacy-superpowers/skills/advocatus-diaboli/SKILL.md` — no occurrence of
  `HARNESS`.
- `ai-literacy-superpowers/commands/diaboli.md` — no occurrence of `harness` in
  any case.
- `ai-literacy-superpowers/agents/orchestrator.agent.md` line 394: "Dispatch the
  advocatus-diaboli agent with the spec file path and `mode: spec`."

Contrast `convener.agent.md` line 96 — "Read `HARNESS.md`'s `## Stakeholders`
section, if present" — and `choice-cartographer.agent.md` line 49 — "`HARNESS.md`
for constraints the spec is operating against." Those two agents are told. This
one is not.

The existing constraint at `HARNESS.md:320` already names this agent as its Tool
and already has this problem. Its rule text concedes half of it — "The obligation
is the spec author's; the diaboli verifying it afterwards is the backstop, not the
mechanism" — but the proposed extension drops that qualifier and supplies no
author-side mechanism, leaving the backstop as the whole of it.

### Why this matters

You asked what it is worth that the rule appoints its reviewer as its enforcer.
Here is the honest answer, and it is not a conflict-of-interest answer.

I did read `HARNESS.md` during this review. I read it because your dispatch
message told me to, in a sentence beginning "Read that constraint in
`HARNESS.md`". Nothing in my charter would have taken me there. A future
spec-mode dispatch, arriving through `/diaboli` or the orchestrator with a file
path and a mode, would not take me there either. So the rule as written proposes
to bind an agent by writing text into a document that agent has no instruction to
open, and the party best placed to notice that is the party being appointed —
which is the one genuine argument *for* having me review it, and it cuts against
the proposal rather than for it.

The self-appointment has a second cost the finding does not price. An
agent-enforced constraint has no corpus-level verifier: the enforcement report
will record `advisory` intended and `advisory` achieved on every declared surface,
and report **no gap**, because `advisory` is what those surfaces support. A rule
that nothing runs will be reported as fully achieved. That is worse than an
unenforced rule that is visibly unenforced.

## O4 — implementation — critical

### Claim

The finding's structural claim — "The rule below extends that constraint's scope
rather than adding a second heading, and the proposed text is written to sit
inside it" — is not achievable through the mechanism that will apply it. The
compiler emits a new `### HDR-…` heading into a generated region appended to the
end of `HARNESS.md`. A second heading is the only outcome available.

### Evidence

`ai-literacy-superpowers/scripts/harness-registrar.py`, `render_region`:

```python
out += ["", f"### {record.id} — {record.fm.get('title')}", "",
        enforcement_summary(record, surfaces, root), ""]
out += body.rstrip("\n").split("\n")
```

and `apply_region`, when the target carries no markers:

```python
if span is None:
    body = "\n".join(lines).rstrip("\n")
    return body + "\n\n" + region.rstrip("\n") + "\n"
```

`HARNESS.md` contains no `<!-- BEGIN GENERATED: harness-registrar -->` marker
(the only occurrence, at line 604, is prose inside the *Harness governance is
applied and undrifted* constraint describing the markers). The file ends with the
`## Status` section at line 1168. So the region is appended after `## Status`.

The reference confirms there is no alternative: "the text applied to a governance
artifact must be byte-identical to what is inside those four backticks. This is
what keeps 'the Registrar never paraphrases to make text fit' a guarantee rather
than an instruction."

### Why this matters

Two consequences, and the second is worse than the first.

**First**, the finding's entire acceptance argument rests on this being a
tightening rather than a new rule. If the mechanism can only produce a new
heading, that argument is unavailable and the proposal must be re-argued on the
evidentiary bar for a new `harness-loop` rule — which is the bar it is already
known to fail on one assay. The framing that makes it palatable is the framing the
compiler cannot honour.

**Second**, a heading appended after `## Status` is outside the `## Constraints`
section, and *Convention parity* (`HARNESS.md:535`) reads only that section:

> Every active constraint heading in HARNESS.md's `## Constraints` section must
> appear verbatim in all three generated convention files.

The finding declares `surfaces: [claude-code, codex, cursor, copilot, windsurf]`.
Four of those five are reached only through `/convention-sync`'s mirrors of the
`## Constraints` section. So four of the five declared surfaces would never
receive the rule, *Convention parity* would not detect the omission because the
heading is out of its scope, and the enforcement report would nonetheless record
`advisory` achieved on all five. Three separate mechanisms would agree the rule
had landed everywhere it claimed, and it would be present on one surface.

## O5 — scope — high

### Claim

The rule triggers on a spec that *names* a source document as its authority. The
two specs that make build-spec claims without naming one are therefore outside it.
The finding's cost section identifies this evasion and dismisses it as too
expensive to be worth guarding against; the evasion is already present, at zero
cost, inside the fixture the finding proposes to test the rule against.

### Evidence

The rule's trigger:

> A spec that names a source document as its authority — a provenance line, a
> "build spec", a charter, a deck, a briefing, a conversation — must cite
> something a second reader can open

The dismissal, from the cost estimate:

> **Dropping the provenance line entirely** — a spec that names no authority is
> not covered, so the cheapest evasion is to stop attributing, which would cost
> more than the rule saves.

And the fixture, per O2: `s4` and `s5` carry no provenance line, and each makes
claims about what the unretrievable build spec says — including one of the four
recorded deviations apiece.

The trigger's parenthetical is ambiguous in a way that matters here. `"a build
spec"` appears in the list of things that count as *naming an authority*, so a
reader might argue that s4's "The build spec requires `provisional: true`" is
itself a naming. If so, the rule reaches s4 and s5 — and then it reaches every
spec in the repository that mentions any source in passing, and the "zero for
specs with no external authority, which is most of them" line in the cost estimate
is wrong. The rule cannot have both the narrow trigger that keeps its cost low and
the wide trigger that covers its own fixture.

### Why this matters

The validation plan requires the six specs to fail the gate as a negative fixture.
Under the narrow reading, two of the six pass, and the plan's own falsification
criterion is not met. Under the wide reading, the cost estimate is understated by
an unknown factor. Either way the finding has not established that the rule
separates its fixtures, which is the test it set for itself.

More corrosively: the rule teaches spec authors that citing a source is what
attracts scrutiny. The two specs in this epic that attract no scrutiny are the two
that cited nothing. That is a gradient pointing away from attribution, installed by
a rule whose purpose is attribution.

## O6 — implementation — high

### Claim

The rule's benefit is stated as making the deviations checkable by a second
reader. Transcription cannot deliver that. There is no durable artefact of the
source conversation, so the transcript is an assertion by the same author in the
same session, and a second reader gains a document rather than verifiability.

### Evidence

The rule:

> Where the source was supplied in conversation, transcribe it into
> `docs/superpowers/` as the first commit of the epic and cite that file by path.

The precedent it is modelled on, `docs/superpowers/cadence-sentinels-charter.md`
line 26:

> **This file is the transcription.** The constraints below are quoted verbatim
> from that build spec.

Nothing can check "verbatim". The document that would falsify it is the thing
whose absence started this.

The finding names this and misclassifies it as an evasion:

> **A transcript that is not the source** — committing a paraphrase, or the parts
> that support the design, and citing that; the path resolves and the check is
> satisfied while the deviations remain uncheckable, which is the failure this
> rule is aimed at, surviving intact.

It is not an evasion. It is the default condition. An author acting in complete
good faith produces an artefact with exactly the same epistemic status as one
acting in bad faith, because neither can be checked. The rule's remedy for this —
"a spec that departs from its cited authority must name the clause it departs
from" — is already satisfied by the current specs: s2 §2 names the compilation
model, s4 §132 names the `provisional`/`expires` requirement, s5 §35 names the
example line. The half described as load-bearing is the half already in force.

### Why this matters

If the rule is accepted on the stated benefit and the benefit is not delivered,
the repository acquires a governance rule, a per-epic cost of fifteen to forty
minutes, and a transcript corpus that reads as verification while providing none.
That is worse than the status quo, in which the uncheckability is at least visible
as a bare "supplied in conversation".

There is an honest version of this rule that the finding does not consider: require
the spec to *declare* that its authority is unretrievable, rather than to
manufacture a retrievable stand-in. That preserves the signal the reader actually
needs — "the deviations below cannot be checked" — at near-zero cost, and does not
claim a verification it cannot perform.

## O7 — alternatives — high

### Claim

A deterministic PR-time check is materially cheaper, would have fired in both
observed occurrences including the one where no agent was dispatched, and sits at
the layer the assay's own ownership test selects. The finding does not weigh it,
and rejects the classification change that would follow on grounds it applies
inconsistently between its own two findings.

### Evidence

The shape is greppable without judgement: a file under `docs/superpowers/specs/`
containing `**Provenance:**` or `supplied in conversation`, where the same line
carries no path resolving under the repository root and no URI scheme. That is a
regex and an `os.path.isfile`. It runs in `.github/workflows/harness.yml` on every
pull request, which is the one thing that did not depend on anyone remembering to
dispatch an agent — the failure O1 identifies.

The assay applies exactly this reasoning one finding later:

> This is a defect in a validator, and the remedy is a change to that validator, so
> `script-validator` is where it sits. It is deliberately not `harness-loop`.

And rejects it here:

> I have not reclassified it to something acceptable, because that would be
> choosing the layer that gets the rule through rather than the layer that owns
> the behaviour.

Those two positions can both be right only if the behaviour here is genuinely
owned by the loop. Given O3, it is not: the artefact that would have to change for
the rule to bind is `skills/advocatus-diaboli/SKILL.md`, which makes this
`agent-instruction` with a `target` — a classification the HDR reference requires a
target for, and which the two-assay threshold does not gate.

### Why this matters

This is not a request to launder the classification past the threshold. It is the
observation that the finding's stated ownership test, honestly applied, does not
select `harness-loop` — because `HARNESS.md` is the one artefact in the chain that
nothing reads for this purpose. The finding's refusal to reclassify is framed as
integrity, and on its own premises it is; but the premise it rests on (that the
loop owns the behaviour) is the thing O3 falsifies.

The `no-change` option is also unweighed. `no-change` is a first-class outcome in
this corpus, and the assay uses it for finding-3. The case for it here is real:
transcribe the harness-evolution build spec now, as `1133b9c` did for the previous
epic, record that the recurrence was observed, and let a second assay decide
whether a rule is warranted. The finding does not consider it.

## O8 — scope — high

### Claim

The rule exempts the specs that motivate it and proposes no remediation, so the
four uncheckable deviations sitting in the repository today are still uncheckable
after acceptance. The rule buys future compliance and does nothing about the
observed harm.

### Evidence

From the rule:

> Specs with filename date before 2026-08-25 are exempt.

Every harness-evolution spec is dated `2026-08-23`. The harm the finding
describes —

> A reader cannot check any of them.

— is therefore untouched by the remedy the finding proposes for it.

The asymmetry with the precedent is worth stating plainly. `1133b9c` fixed the
artefacts and wrote no rule; the finding treats that as the defect that let the
recurrence through. This proposal writes a rule and fixes no artefacts. Neither
does both, and the finding names the first failure while committing the second.

### Why this matters

The grandfather clause is defensible in itself — retroactive rules are a known
governance anti-pattern, and the S0 spec's `imported: true` reasoning makes the
same argument about expiry cliffs. What is not defensible is exempting without a
companion remediation, because the cost of that remediation is the one number the
finding has actually measured: fifteen to forty minutes, once, by whoever writes
the transcript. The finding prices the work and then does not schedule it.

A reader of `HARNESS.md` in six months finds a rule requiring retrievable
provenance, and six specs in the repository citing a document nobody can open,
exempt by date. That configuration teaches the opposite of the rule.

## O9 — implementation — high

### Claim

Three of the finding's load-bearing arguments are positioned after its YAML
metadata block, where `/harness-propose` discards them. The approver at the
acceptance gate will read an HDR whose "Why this layer", "Validation" and
"Rejected alternatives" sections are TODO placeholders, with the finding's actual
reasoning nowhere in the record.

### Evidence

`harness-registrar.py`, `_parse_finding`:

```python
observation = preamble.split("```", 1)[0].strip()
```

`observation` becomes the HDR's `## Finding` section and is everything from the
finding heading up to the first fence. In finding-1 the metadata fence opens at
assay line 189. The paragraphs at lines 202-221 — **"Why this is a tightening, not
a new rule"**, **"Overfitting risk: low"**, and the entire **"Validation plan"** —
all sit after it. They are not in `observation`, and they are not `#### `
subsections, so `subsections` does not hold them either. `render_hdr` writes
`## Finding`, `## Rule`, `## Cost` and then:

```python
if classification in S0.TIER2_CLASSIFICATIONS:
    for heading, prompt in TIER2_PLACEHOLDERS:
        lines.append(f"## {heading}")
        lines.append(f"{PLACEHOLDER_PREFIX} {prompt}._")
```

with `TIER2_PLACEHOLDERS` covering "Why this layer", "Enforcement", "Validation",
"Rejected alternatives" and `PLACEHOLDER_PREFIX = "_TODO —"`.

`overfitting_risk: low` is a further casualty: it is not in
`FINDING_REQUIRED_KEYS` and is not read by `render_hdr`, so it is dropped from the
metadata as well as from the prose.

### Why this matters

The acceptance gate is the point of the whole mechanism — the moment a human
writes the cost in their own words and decides. The finding's best arguments are
the ones that gate needs, and they are placed where the pipeline cannot carry
them. The human either re-derives them from scratch into four TODO sections or,
more likely, writes something thinner than what the Assayer already wrote and
which is sitting one file away.

This is not a formatting nit. It means the record that survives — the artefact a
reader consults in a year to understand why this rule exists — will contain the
observation and the rule and none of the reasoning that justified the layer, the
scope, or the falsifiability. The corpus is designed so that "a rule enters on
recorded evidence"; here the evidence enters and the argument does not.

Finding-2 has the same structure, so this is a property of how the assay was
authored rather than of finding-1 alone. Within finding-1's scope, the remedy is
positional: the argument belongs before the metadata fence.

## O10 — implementation — high

### Claim

The instruction to commit the transcript "as the first commit of the epic"
collides with the `Spec-First Check`, which fails any first commit containing a
file outside `docs/superpowers/specs/`. Following the rule as written makes an
epic's first pull request red.

### Evidence

The rule:

> transcribe it into `docs/superpowers/` as the first commit of the epic and cite
> that file by path

`.github/workflows/spec-first-check.yml`, lines 94-126:

```bash
if [[ "$file" == docs/superpowers/specs/*.md ]]; then
  SPEC_COUNT=$((SPEC_COUNT + 1))
else
  NON_SPEC_COUNT=$((NON_SPEC_COUNT + 1))
  echo "::error::Non-spec file in first commit: $file"
fi
```

followed by an explicit failure when `NON_SPEC_COUNT > 0`: "First commit must
contain ONLY spec files."

`docs/superpowers/cadence-sentinels-charter.md` is not under `specs/`. A charter
committed first fails; a charter committed alongside the spec fails; a charter
committed second satisfies CI but not the rule's literal text.

### Why this matters

Three outcomes, all bad. The author follows the rule and CI goes red on the first
PR of every epic. The author satisfies CI and technically breaches the new rule,
which — since the enforcer is an agent with judgement — will be waved through,
teaching that this rule's text is approximate. Or the author reaches for a `chore`
label to escape `Spec-First Check`, which drags one governance gate down to satisfy
another.

The fix is a one-word change ("as the first commit of the epic" → "before the
first spec that cites it", or placing charters under `docs/superpowers/specs/`),
which is cheap. The reason it belongs here rather than in a copy-edit is that it
demonstrates the rule was written without checking it against the deterministic
gates already in force — which is a variant of the failure the rule is about.

## O11 — premise — high

### Claim

The two-occurrence evidence base is weaker than the prose asserts, and weaker
again by the time it reaches the approver. Independence between the occurrences
is claimed without evidence and is contradicted by the observable record; and the
second occurrence cannot be represented in the HDR evidence list at all.

### Evidence

The claim:

> **Overfitting risk: low.** Two independent occurrences, two different epics, two
> different authors' sessions, thirteen and fifteen citation instances
> respectively.

The observable record: one repository, one model tier (`REFLECTION_LOG.md`
2026-08-13, "Model tiers used: capable (100%) — Opus 5 throughout, including all
advocatus-diaboli dispatches"; assay frontmatter `model: claude-opus-5`), one
reflection author. "Two different authors' sessions" is not sourced anywhere in
the assay. And the second occurrence happened *with the first's fix already in the
tree* — which is the finding's own strongest point, and which makes the two
occurrences dependent rather than independent. Two draws that share an author, a
model, a repository and ten days are not two samples.

The representability problem is separate and concrete. The metadata evidence list
holds four entries — two of the six specs, the charter, and `HARNESS.md`. It does
not hold `1133b9c`, which is the entire basis of the recurrence argument, and
`harness-registrar.py` copies the list verbatim into the HDR:

```python
evidence = [str(item) for item in (meta.get("evidence") or [])]
anchor = f"{assay_path}#{finding.id}"
```

`HARNESS.md:614` establishes what the corpus accepts: "an evidence reference
naming a repository path that no longer exists fails, while a reference carrying a
URI scheme is named as skipped rather than passed in silence." A commit SHA is
neither a path nor a URI scheme. Also absent:
`docs/superpowers/objections/cadence-sentinels-s7-docs-design.md`, the artefact in
which a human first adjudicated this exact defect and accepted it — the strongest
single piece of evidence the finding has, and the one that most directly supports
the recurrence claim.

### Why this matters

The approver at `/harness-accept` will read an HDR citing one assay and four
paths, none of which shows a recurrence, while the argument that there *was* a
recurrence has been dropped per O9. They will then be asked to decide the
question the assay poses in its Unresolved questions section — whether 2026-08-13
counts as a second independent observation — with the record in front of them
showing neither the second observation nor the argument for counting it.

The assay is candid that the threshold will refuse this, and right that the
threshold refusing it is the threshold working. My objection is narrower and
sharper: the finding argues for an exception to the threshold on the strength of
independence, and independence is the property the evidence least supports.

## O12 — specification quality — medium

### Claim

The validation plan sets a falsifiability criterion that cannot test the half of
the rule the cost section calls load-bearing, and its positive fixture is a
retrofit rather than a spec that ever passed the gate — so passing the plan would
not establish what the plan claims to establish.

### Evidence

The plan:

> If the gate cannot separate those two without reading either spec's content, the
> rule is not falsifiable and should be refused.

The cost section, on the rule's second clause:

> it is why the "name the clause you depart from" half is load-bearing rather than
> decorative: a paraphrase transcript makes that half impossible to write honestly.

Whether a spec names the clause it departs from is irreducibly a question about
the spec's content. A test that forbids reading content can only exercise the
first clause. The clause identified as the defence against the most likely gaming
mode is the clause the validation plan structurally cannot reach.

On the fixture:

> Take `cadence-sentinels-s1` post-`1133b9c` as the positive fixture: it cites
> `cadence-sentinels-charter.md` by path and must pass.

`2026-08-08-cadence-sentinels-s1-infrastructure-design.md` line 17-18 does read
"transcribed to `docs/superpowers/cadence-sentinels-charter.md`" — but that text
was added on 2026-08-13, five days after the spec was written and after the epic
had shipped. It demonstrates that a repaired spec matches the pattern. It does not
demonstrate that any author has ever satisfied the rule at spec-gate time, which is
the only moment the gate fires.

### Why this matters

A validation plan that a rule passes without establishing the rule works is worse
than no validation plan, because passing it will be read as evidence. The
finding's own standard — "If the gate cannot separate those two … the rule is not
falsifiable and should be refused" — is the right standard, and applied honestly it
refuses the rule's second clause today.

A second, smaller ambiguity rides along and would produce divergent enforcement.
The rule requires "a path inside this repository, or a URL". The S0 spec's own
provenance line ends: "Epic-level design decisions (§14 open questions) were
resolved before implementation and are recorded on #533." An issue number is
neither a path nor a URL, and reasonable reviewers will split on whether it
satisfies. The cost section separately concedes the rule "cannot tell an open link
from a private workspace", so even the unambiguous URL case is unverified by the
mechanism the rule depends on.

## Explicitly not objecting to

- **The classification staying `harness-loop` despite knowing it will be
  refused.** The assay's reasoning — that reclassifying to clear a threshold is
  choosing the layer that passes rather than the layer that owns — is correct as a
  principle, and I have attacked its application in O7 rather than the principle.
  A finding that walks knowingly into its own gate is behaving well.
- **The decision to record finding-3 as `no-change`.** Recording that nothing
  needed to change, with the evidence for it, is exactly what a first assay should
  do, and the reasoning distinguishing hand-edits made *while* the mechanism was
  being built from hand-edits made after is sound.
- **The honesty about absent sources.** "Absent, not empty", the Mast entry's
  "'Nothing fired' and 'nothing was recorded here' are different facts and I
  observed only the second", and the flag that `REFLECTION_LOG.md` is silent for
  the window are all better practice than most reports manage. They also weaken
  finding-1 — the "what people noticed at the time" evidence pool is empty — and
  the assay says so itself rather than making me find it.
- **The confidentiality exposure created by mandatory transcription.** The rule
  requires copying conversation-supplied material into a public repository with no
  carve-out, and forbids the honest alternative of declaring the source private.
  I considered raising it and did not: the skill deprioritises risk objections at
  spec time, and the mechanism by which it would bite — authors producing
  sanitised transcripts — is already named in the finding's own gaming analysis as
  the failure to watch. It belongs at code time if this rule is ever implemented.
- **The fifteen-to-forty-minute cost figure.** It is plausible, it is bounded, and
  it names who pays. My objections are to whether the thing bought is delivered
  (O6) and whether it is bought for the specs that need it (O8), not to the price.
- **The three gaming modes being listed at all.** Most rule proposals in this
  repository do not carry an adversarial section, and this one ranks its evasions
  by likelihood and names which is load-bearing. O5 and O6 argue that two of the
  three are misjudged; that is a better position to argue from than silence.
- **The rule's target repository scope and the `surfaces` list membership.**
  Whether `codex` or `windsurf` should be listed is downstream of O4, which says
  none of them will receive the rule anyway. There is nothing to adjudicate about
  the list until the compile path is settled.
- **`priority: P2`.** It is a required metadata key, it is present, and nothing in
  the evidence lets me argue P1 or P3 with more authority than the assayer had.
