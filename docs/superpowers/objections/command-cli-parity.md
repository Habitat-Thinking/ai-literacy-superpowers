---
spec: harness/assay/2026-08-25T11-59Z-assay.md#finding-1
date: 2026-08-25
mode: spec
diaboli_model: claude-opus-5
objections:
  - id: O1
    category: premise
    severity: critical
    claim: "The harm the finding leads with is a prompt asserting output structure the code no longer produces; the proposed check compares option strings and cannot detect it, so the check goes green on one added string while the false-defect report still fires."
    evidence: "Finding: 'An agent following the checkpoint as written against a correctly-formed rejection would report a defect that is not there.' Rule: options 'must appear verbatim in at least one file under ai-literacy-superpowers/commands/'. Cost estimate concedes: 'a bare --reject mentioned in a code fence satisfies a literal-string check while the prompt still never tells the agent when to use it.' harness-propose.md P1 and P5 are unchanged by adding that string."
    disposition: rejected
    disposition_rationale: null
  - id: O2
    category: premise
    severity: high
    claim: "The rule's stated harm — a capability the driving agent cannot reach — is falsified inside the assay's own What worked section: --reject was exercised in the same phase it landed, with no command prompt naming it."
    evidence: "Proposed rule: 'A capability the code exposes and no command prompt names is a capability the agent driving that command cannot reach.' Assay, What worked: 'A declined finding is now a record ... It carries no cost key and no tier-2 sections, which is the shape #562 specified.' harness/decisions/HDR-2026-08-25-an-epic-s-authority-cited-to-a-document-nobody-else-can-open.md exists in exactly the shape --reject produces."
    disposition: rejected
    disposition_rationale: null
  - id: O3
    category: implementation
    severity: high
    claim: "The rule binds subcommands but its exemption is anchored to add_argument and its detection is a verbatim string match; the two subcommands genuinely absent from every command file are ordinary English words that already appear there, so the check passes on precisely the capabilities that are unreachable."
    evidence: "harness-registrar.py:1902 `sub.add_parser(\"correct\", ...)`, :1909 `sub.add_parser(\"index\", ...)`. harness-accept.md:60 'or correct the target'; harness-accept.md:118 'harness/decisions/index.md lists the HDR'. Rule's exemption: 'carrying an `# undocumented:` comment on the line above its add_argument call' — a subparser has no add_argument call."
    disposition: rejected
    disposition_rationale: null
  - id: O4
    category: implementation
    severity: high
    claim: "The rule says 'a script' but the proposed tool is an argparse walk; five of the six scripts named in command files are bash, one of them already violates the rule, and the exemption is inexpressible for any of them."
    evidence: "Cost estimate: 'an argparse walk over each script named in a command file'. Command files name next-action-hint.sh, ai-literacy-check.sh, regenerate-reflection-log.sh, sentinel-integrity-check.sh and harness-affordance-staleness.sh alongside harness-registrar.py. harness-affordance-staleness.sh accepts --max-age-days and --today; commands/harness-affordance.md names neither."
    disposition: accepted
    disposition_rationale: null
  - id: O5
    category: scope
    severity: high
    claim: "The remediation backlog is priced at four capabilities when the finding's own enumeration contains six undocumented options plus two undocumented subcommands, and two of them are hermeticity injections that no prompt should ever name."
    evidence: "Finding enumerates '--root ... --today' among accepted options. harness-registrar.py:1863 `parser.add_argument(\"--root\", default=\".\")`, :1870/:1920/:1929 `--today`, help='YYYY-MM-DD; injected so nothing races the clock'. Neither string appears in any file under commands/. Cost estimate: 'the four capabilities already divergent must be written into harness-propose.md and harness-accept.md'."
    disposition: accepted
    disposition_rationale: null
  - id: O6
    category: specification quality
    severity: medium
    claim: "The trigger 'when that script is invoked by a command in that directory' has no mechanical definition, and the two available readings produce different violation sets on files already in the repository."
    evidence: "Rule: 'when that script is invoked by a command in that directory'. commands/harness-affordance.md:189 mentions scripts/harness-affordance-staleness.sh in a parenthetical attributing it to a GC rule, not in a fenced invocation. commands/harness-timeline.md:32, harness-check.md:53 and others use fenced `python3 ... harness-registrar.py <subcommand>` invocations."
    disposition: accepted
    disposition_rationale: null
  - id: O7
    category: specification quality
    severity: medium
    claim: "The quantifier is per-repository rather than per-command, so an option can satisfy the rule from a command file that could never pass it — which is the exact shape of the observed defect the rule is written against."
    evidence: "Rule: 'must appear verbatim in at least one file under ai-literacy-superpowers/commands/'. --target is only ever passed by `harness-registrar.py accept`, which only commands/harness-accept.md invokes (line 91); naming --target in any other command file satisfies the rule while /harness-accept stays silent."
    disposition: accepted
    disposition_rationale: null
  - id: O8
    category: alternatives
    severity: high
    claim: "The repository already owns an idempotent generator that writes marked regions into prose artefacts; generating the option inventory is strictly stronger than checking for a string, and the finding weighs neither generation nor no-change."
    evidence: "harness-registrar.py apply_region / render_region and the `compile` subcommand exist and are driven by commands/harness-compile.md:40. Assay, What worked: 'the transcription fix travelled and the rule did not need to' — the precedent in which the previous assay's finding-1 was declined and the defect fixed anyway."
    disposition: accepted
    disposition_rationale: null
  - id: O9
    category: alternatives
    severity: critical
    claim: "An existing constraint already owns this behaviour and was never run: Output validation checkpoints requires a checkpoint to check structure against the format spec reference, the reference is current, and it is harness-propose.md's checkpoint that diverges from it."
    evidence: "HARNESS.md:255 'must include a validation checkpoint step that reads the output, checks structure against the format spec reference'. docs/plugins/ai-literacy-superpowers/reference/harness-decision-records.md:76-94 documents `/harness-propose --reject --reason-file` and the '## Finding and a non-empty ## Rejection, and nothing else' shape; :188 documents `/harness-accept <hdr> --target`. Assay, Rejected candidates: 'harness.yml runs eight deterministic constraints and none of the agent-enforced ones'."
    disposition: accepted
    disposition_rationale: null
  - id: O10
    category: implementation
    severity: high
    claim: "The enforcement outcome is understated: with ci supporting no advisory rung and no validator resolvable, the rule achieves `none` rather than a downgraded level on its only declared surface, and nothing in the loop schedules the script that would change that."
    evidence: "harness/surfaces.yaml:62-64 `ci: supports: [validated, blocked]`. harness-registrar.py achieved_for:1321-1324 — when the candidate is at or above validated and not validated, 'advisory' in supports else return 'none'. validator_state:1291 requires `record.id in fh.read()`. Finding: 'the first /harness-compile after acceptance should report an enforcement gap on ci rather than validated'."
    disposition: accepted
    disposition_rationale: null
  - id: O11
    category: scope
    severity: medium
    claim: "Three of the rule's five cited evidence paths lie outside anything the rule can bind, including the errata blindness the finding presents as its sharpest observation."
    evidence: "evidence list names skills/harness-assay/SKILL.md and docs/.../reference/harness-decision-records.md. Rule: 'This does not reach reference or how-to pages'. Assay: 'The Assayer's own evidence pool does not know that corrections exist ... contains no occurrence of \"errata\" or \"correction\".'"
    disposition: deferred
    disposition_rationale: null
  - id: O12
    category: specification quality
    severity: medium
    claim: "The exemption's stated criterion — an option whose only caller is another script — does not cover the population that most obviously needs exempting, which is options injected by tests for hermeticity."
    evidence: "Rule: 'An option whose only caller is another script is exempt'. harness-registrar.py:1870 --today help='injected so nothing races the clock'; :1863 --root default='.'. docs/superpowers/specs/2026-06-17-affordance-runtime-recorder-design.md:130 'Hermetic — --today fixes \"now\"; the analyzer is deterministic.' Neither is called by another script; both are called by tests."
    disposition: deferred
    disposition_rationale: null
---

## O1 — premise — critical

### Claim

The finding leads with a concrete, verified harm: `/harness-propose`'s step-5
checkpoint asserts frontmatter keys and tier-2 sections that a correctly-formed
rejection record does not carry, so an agent following it would report a defect
that is not there. That harm is a divergence between a prompt's *assertions about
output structure* and the code's *behaviour*. The proposed rule checks for the
presence of *option strings*. Adding the seven characters `--reject` to
`harness-propose.md` turns the check green and leaves P1 and P5 exactly as wrong
as they are today.

### Evidence

The harm, from the finding:

> The rejection record shipped by #562 and written by #563 carries neither key
> and none of those sections, by design. An agent following the checkpoint as
> written against a correctly-formed rejection would report a defect that is not
> there.

Verified. `harness-propose.md` step 5:

> **P1** — frontmatter carries `id`, `title`, `status: proposed`, …
> `proposed_cost`, `cost`, `proposer`, `supersedes`, `superseded_by`
> **P5** — for a tier-2 classification, all four extra sections are present

And `HDR-2026-08-25-an-epic-s-authority-cited-to-a-document-nobody-else-can-open.md`
carries `status: rejected`, no `proposed_cost`, no `cost`, and a `## Rejection`
section in place of the four tier-2 sections.

The remedy, from the proposed rule:

> Every long option and every subcommand that a script accepts must appear
> verbatim in at least one file under `ai-literacy-superpowers/commands/`

And the finding's own concession, in its gaming analysis:

> **Naming the flag and not explaining it** — a bare `--reject` mentioned in a
> code fence satisfies a literal-string check while the prompt still never tells
> the agent when to use it. This is the likely evasion and the check cannot see
> it.

### Why this matters

The finding treats that concession as a residual weakness. It is not residual;
it is the whole of the observed harm. The check binds the inventory and the
harm lives in the assertions. The cost estimate acknowledges this in passing —
"thirty to sixty minutes of prose someone has to actually think about, because
`--reject` changes what step 5's checkpoint should assert" — and then relies on
that thinking happening voluntarily, because nothing in the rule requires it.

So the state after acceptance and remediation is: a rule in `HARNESS.md`, a new
CI check, a green build, and a step-5 checkpoint that still reports a correct
rejection record as a defect. The repository would then hold a deterministic
check whose passing is evidence for something it does not test — which is a
worse configuration than today's, where the divergence is at least not
certified.

There is a version of this finding that survives the objection: state the harm
as *discoverability* rather than as *correctness of the driving prose*, and
price the rule accordingly. That is a smaller claim and would probably not carry
a `P1`.

## O2 — premise — high

### Claim

The rule's justifying sentence asserts unreachability. The assay's own *What
worked* section records the capability being reached, in the phase in which it
landed, with no command prompt naming it.

### Evidence

The rule:

> A capability the code exposes and no command prompt names is a capability the
> agent driving that command cannot reach

The assay, three sections earlier:

> **A declined finding is now a record, and the approver's words are verbatim.**
> `HDR-2026-08-25-an-epic-s-authority-cited-to-a-document-nobody-else-can-open`
> carries `status: rejected` and a `## Rejection` reading, in full: "My feeling
> was that the rule was pointed at the wrong problem." … It carries no `cost`
> key and no tier-2 sections, which is the shape #562 specified.

That record exists on disk in exactly the shape `--reject --reason-file`
produces, and `commands/harness-propose.md` was last modified two days before it
was written and names neither option.

### Why this matters

An unreachable capability and an undiscoverable one are different failures with
different remedies and different prices. Unreachable justifies a P1 deterministic
gate. Undiscoverable justifies a note, or a generated inventory, or nothing at
all if the surrounding practice supplies the reach — which here it demonstrably
did, twice in one day.

I am not claiming the weaker harm is unreal. I am claiming that the finding
argues the strong version and evidences the weak one, and that the approver at
`/harness-accept` will be asked to write a cost against the strong version. The
precedent is directly on point: the previous assay's finding-1 was declined with
"the rule was pointed at the wrong problem", and the mechanism by which that
went wrong was the same — a real observation carrying a harm claim one size too
large.

## O3 — implementation — high

### Claim

The rule binds subcommands as well as options. Its detection mechanism is a
verbatim string match and its exemption mechanism is a comment above an
`add_argument` call. Neither works for a subcommand. The two subcommands that are
genuinely absent from every command file are ordinary English words that already
appear in command files, so the check passes on them; and had it not, there
would be no way to exempt them.

### Evidence

`harness-registrar.py`:

```python
p = sub.add_parser("correct", help="record a correction to an assay finding")
...
p = sub.add_parser("index", help="regenerate harness/decisions/index.md")
```

Neither `harness-registrar.py correct` nor `harness-registrar.py index` appears
in any file under `commands/` — the finding says so itself, and there is no
`/harness-correct` command in the directory at all. But the bare tokens do
appear:

- `commands/harness-accept.md:60` — "Create the artifact, or **correct** the
  target."
- `commands/harness-accept.md:118` — "**A5** — `harness/decisions/index.md`
  lists the HDR with its new status"

Seventeen such occurrences across twelve command files.

The exemption:

> An option whose only caller is another script is exempt by carrying an
> `# undocumented:` comment on the line above its `add_argument` call

`sub.add_parser("index", ...)` is not an `add_argument` call.

### Why this matters

The finding's own detection method concedes the problem: it greps for
`harness-registrar.py correct`, a two-token phrase, precisely because the bare
token is ambiguous. The rule it proposes says "appear verbatim", which for a
subcommand is the bare token. So the check as specified would report compliance
on the two capabilities the finding demonstrated are undocumented, while
failing on options that are merely test plumbing (O5).

That inversion is not fixable by tightening the string match without the rule
specifying what a subcommand mention looks like — and once it does, `index` and
`correct` become unexemptable, because the escape hatch is defined only for
`add_argument`. The rule then forces either the invention of a `/harness-correct`
command or a paragraph about `index` in a command file that does not call it,
three PRs after #565 deliberately made index regeneration automatic so that no
one would have to.

## O4 — implementation — high

### Claim

The rule's subject is "a script". The tool that would enforce it is described as
an argparse walk. Five of the six scripts named in command files are bash, one
of them is already in violation, and the `# undocumented:` exemption cannot be
written in a language that has no `add_argument`.

### Evidence

The rule: "Every long option and every subcommand that **a script** accepts".

The cost estimate: "writing the parity check — **an argparse walk** over each
script named in a command file, matched against that file's text".

Scripts named in files under `commands/`:

| Script | Named by |
| --- | --- |
| `harness-registrar.py` | six command files |
| `next-action-hint.sh` | `coda.md:58,61` |
| `ai-literacy-check.sh` | `superpowers-init.md:88`, `superpowers-status.md:123` |
| `regenerate-reflection-log.sh` | `reflect.md:231` |
| `sentinel-integrity-check.sh` | `superpowers-status.md:88` |
| `harness-affordance-staleness.sh` | `harness-affordance.md:189` |

`harness-affordance-staleness.sh` accepts `--max-age-days` and `--today`.
`commands/harness-affordance.md` names neither.

### Why this matters

Three outcomes, all of which the finding should have priced and did not. The
check reads only Python, in which case the rule text over-claims by a factor of
five and the enforcement report will record a `validated` rule that validates
one sixth of its stated domain. Or the check reads bash too, in which case
`harness-affordance-staleness.sh` is an immediate second violation in a
different command's territory, and its author cannot exempt `--today` because
there is no `add_argument` line to attach the comment to. Or the rule is
narrowed to Python at acceptance, which is a change to the rule text, and the
Registrar copies rule text byte for byte and does not paraphrase.

The finding's remediation estimate — "thirty to sixty minutes … into
`harness-propose.md` and `harness-accept.md`" — assumes the first outcome
without saying so.

## O5 — scope — high

### Claim

The backlog that must be cleared before the check can go green is larger than
the four capabilities the cost estimate names, and the extra members are the
worst possible things to write into a prompt: options that exist so tests can
pin the clock and the filesystem root.

### Evidence

The finding's own enumeration includes them:

> `harness-registrar.py` accepts the long options `--acknowledge-correction`,
> `--approver`, `--assay`, `--correction-file`, `--cost-file`, `--finding`,
> `--hdr`, `--now`, `--reason-file`, `--reject`, `--root`, `--slug`, `--target`,
> `--today`

From the parser:

```python
parser.add_argument("--root", default=".", help="repository root")
...
p.add_argument("--today", help="YYYY-MM-DD; injected so nothing races the clock")
```

`--root` and `--today` appear in no file under `commands/`. `--today` is
declared three times, on `propose`, `check` and `review`. Adding the two
undocumented subcommands from O3, the green-able set at acceptance is six
options and two subcommands on `harness-registrar.py`, plus two options on
`harness-affordance-staleness.sh` from O4.

Against the cost estimate:

> Then a backlog: **the four capabilities already divergent** must be written
> into `harness-propose.md` and `harness-accept.md` before the check can go
> green, which is thirty to sixty minutes of prose

### Why this matters

The four named capabilities are things a human wants an agent to know about.
`--root` and `--today` are the opposite: `/harness-propose`'s prompt telling an
agent that a `--today` flag exists is an invitation to pass one, and the whole
reason the option exists is that the value must be injected by a harness rather
than chosen. The rule would push misleading prose into the exact files whose
accuracy it exists to protect.

The finding's own framing — "it makes adding a flag slightly more expensive and
makes an unusable flag impossible" — is the honest description of the four. It
is not the description of `--root`, and the exemption criterion does not reach
it (O12).

## O6 — specification quality — medium

### Claim

The trigger clause has no mechanical definition, and the two plausible readings
disagree about files already in the repository.

### Evidence

The rule:

> when that script is invoked by a command in that directory

`commands/harness-affordance.md:189` reads:

> (Staleness is surfaced separately by the `Affordance review staleness` GC
> rule — `scripts/harness-affordance-staleness.sh` — which flags entries whose
> `Last reviewed` is older than the configured threshold.)

That is a citation, not an invocation. `commands/harness-check.md:53` reads
`python3 ai-literacy-superpowers/scripts/harness-registrar.py check` inside a
fenced block. Under a "fenced invocation" reading the staleness script is out of
scope; under a "path mentioned anywhere" reading it is in, and in violation.

### Why this matters

The implementer picks one, and the two produce different failing sets on the
first run. That is exactly the divergent-implementation shape this category
exists for, and it is compounded by the Registrar's byte-for-byte guarantee:
once accepted, the ambiguity is frozen into `HARNESS.md` and can only be
resolved by superseding the record, not by clarifying it.

A secondary case rides along: `agents/harness-registrar.agent.md:40` names
`harness-registrar.py propose`. Agents are outside the rule's stated scope, but
they drive the same script, and the finding's evidence list includes
`skills/harness-assay/SKILL.md`. The rule does not say why the boundary sits
where it does.

## O7 — specification quality — medium

### Claim

The quantifier is "at least one file under `commands/`" — repository-wide, not
per-command. An option can therefore be documented in a command that could never
pass it, and the rule is silent about the case that produced the finding.

### Evidence

The rule: "must appear verbatim in **at least one file** under
`ai-literacy-superpowers/commands/`".

`--target` is accepted only by the `accept` subparser
(`harness-registrar.py:1896`), which only `commands/harness-accept.md:91`
invokes. Naming `--target` in `harness-timeline.md`, or in a footnote to
`harness-check.md`, satisfies the rule while `/harness-accept` remains silent —
and `/harness-accept` was the command the reference page described as supporting
a target-at-acceptance workflow that the code could not perform, which is one
half of the assay's *What created friction* section.

### Why this matters

The observed defect is per-command: the prompt that drives `accept` did not know
about `--target`. The rule as written cannot express that, because its
quantifier ranges over the directory. A per-command quantifier is not obviously
correct either — options shared across subcommands would need a home — but the
rule does not acknowledge the choice, so the implementer makes it silently and
the human approving the cost is not told which they are buying.

## O8 — alternatives — high

### Claim

The repository already owns an idempotent generator that writes marked regions
into prose artefacts and repairs them on demand. Generating the option and
subcommand inventory into each command file is strictly stronger than checking
that a string is present, removes the recurring cost entirely, and closes the
inventory half of the "name it without explaining it" evasion. The finding
weighs neither generation nor `no-change`.

### Evidence

The mechanism exists and is in use: `harness-registrar.py`'s `apply_region` and
`render_region`, driven by `commands/harness-compile.md:40`
(`harness-registrar.py compile`), described in the source as "idempotent repair
of every generated region".

The `no-change` precedent is in the same assay, in *What worked*:

> **The defect behind assay-1 finding-1 was fixed even though the rule was
> declined.** … The behaviour the declined rule was aimed at did not recur in the
> phase that followed the decline. … what is observed is that the transcription
> fix travelled and the rule did not need to.

And finding-3 of this assay uses `no-change` as a first-class outcome.

### Why this matters

Under generation, the recurring cost the finding prices — "one line of prose per
new option, paid by whoever adds the option" — becomes zero, and the two
evasions ranked most likely both disappear: a generated table cannot be omitted,
and `# undocumented:` becomes a rendering decision rather than a hurdle. What
generation does not buy is the *explanation*, which is the thing that actually
matters (O1) — but neither does the check, so generation dominates it on every
axis the finding measures.

The `no-change` option deserves separate weighing precisely because the assay
just recorded the pattern working: a defect fixed without a rule, and no
recurrence in the following phase. That is one observation, not a law. But it is
one more observation than the proposed rule has of a divergence surviving
remediation, and the finding does not put it on the scale.

## O9 — alternatives — critical

### Claim

An existing constraint already owns this behaviour, and the finding's ownership
survey does not name it. *Output validation checkpoints* requires every command
producing structured output to carry a checkpoint that checks structure against
the format spec reference. The format spec reference is current. It is
`harness-propose.md`'s checkpoint that has diverged from it. The constraint is
agent-enforced, and by the assay's own account nothing ran it.

### Evidence

`HARNESS.md:255`:

> **Rule**: Every command that produces structured output parsed by downstream
> consumers … must include a validation checkpoint step that reads the output,
> **checks structure against the format spec reference**, and fixes deviations
> in place
> **Enforcement**: agent
> **Tool**: harness-enforcer agent

The format spec reference,
`docs/plugins/ai-literacy-superpowers/reference/harness-decision-records.md`, is
not stale:

> Written by `/harness-propose --reject --reason-file <path>`. It carries
> `## Finding` and a non-empty `## Rejection`, and **nothing else**: no
> `## Rule` … (line 78)

> `/harness-accept <hdr> --target .claude/agents/tdd-agent.agent.md` … Three
> refusals bound it. A **routed** classification refuses `--target` … (lines
> 188, 196)

So the reference layer knows about `--reject`, the rejection record's shape,
`--target`, and the routed-classification refusal. The checkpoint in
`harness-propose.md` does not. That is a checkpoint out of step with its format
spec reference — the literal subject of the constraint.

And from the assay's *Rejected candidates*:

> `.github/workflows/harness.yml` runs eight deterministic constraints and none
> of the agent-enforced ones, so CI going green on these PRs never spoke to
> this. This is the second consecutive assay to route this to `/harness-audit`.

### Why this matters

The finding's "why no existing owner absorbs it" section surveys three
constraints — *Docs site kept current*, *Docs propagation when shipping new
commands*, and the GC rule *Command-prompt sync* — and correctly shows none
fires. It does not survey the one whose subject matter is an exact match. The
conclusion "`/harness-audit` would correctly report all three compliant, which
is why this is a finding and not a rejected candidate" does not survive a fourth
constraint that `/harness-audit` would report **non**-compliant, if anyone ran
it.

This matters more than a missed citation because it changes the diagnosis. If
the harm is owned by an existing agent-enforced constraint that has not been
dispatched for two consecutive assay windows, then the remedy is dispatching it,
and adding a deterministic string check writes a second rule over a first one
nobody runs. That is the precise failure the previous assay's finding-1 was
declined for, and this assay's own recurring observation — "the recurrence is the
fact, and the remedy is running the audit, not writing a new rule" — is the
argument against itself, applied one section earlier and not here.

If this objection is accepted, finding-1 becomes a rejected candidate routed to
`/harness-audit`, with the four prompt updates done as repair.

## O10 — implementation — high

### Claim

The enforcement consequence of acceptance is stated too gently. With
`surfaces: [ci]`, `enforcement: validated`, and a tool that does not exist, the
enforcement report will record the rule achieving **`none`** — not a downgraded
level — on its only declared surface. Nothing in the loop schedules the script
that would change that, and even once written it counts as unvalidated unless it
names the record id.

### Evidence

`harness/surfaces.yaml`:

```yaml
  ci:
    targets: [.github/workflows/]
    supports: [validated, blocked]
```

`harness-registrar.py`, `achieved_for`:

```python
    if LADDER[candidate] >= LADDER["validated"] and not validated:
        if "advisory" in supports:
            return "advisory", why
        return "none", why
```

`ci` does not support `advisory`, so the second branch is taken. And
`validator_state` resolves only if the declared tool file contains the record's
own id:

```python
                if record.id in fh.read():
                    return True, ""
```

The finding says:

> `enforcement: validated` states the intent. No such check exists today, so the
> first `/harness-compile` after acceptance should report an enforcement **gap**
> on `ci` rather than `validated`.

### Why this matters

I accept the finding's principle — a declared gap is the report working, not a
reason to lie about the level. The objection is that the gap is total, not
partial, and that the loop has no way to close it. `/harness-propose` and
`/harness-accept` write records; neither opens an issue, and the assay's own
*What created friction* section shows what happens to work that nothing tracks.

The realistic sequence after acceptance is: `HARNESS.md` gains a P1 rule that is
in force nowhere; some later PR writes `check-command-cli-parity.py`; the check
fails on the current tree for six options, two subcommands and a second script
(O3, O4, O5); and the cheapest way to green is the exemption comment the finding
already identifies as the second most likely evasion. The moment of maximum
temptation is not distributed across future flags — it is concentrated in the
single PR that first turns the check on, against a backlog the cost estimate
under-counts by half.

The finding is right that this is not a reason to declare `advisory`. It is a
reason for the cost the approver writes to name who writes the script and when.

## O11 — scope — medium

### Claim

Three of the five artefact paths in the finding's evidence list lie outside
anything the rule can bind, including the observation the finding presents as its
sharpest — that the Assayer's own skill does not know corrections exist.

### Evidence

The metadata:

```yaml
evidence:
  - ai-literacy-superpowers/commands/harness-propose.md
  - ai-literacy-superpowers/commands/harness-accept.md
  - ai-literacy-superpowers/skills/harness-assay/SKILL.md
  - ai-literacy-superpowers/scripts/harness-registrar.py
  - docs/plugins/ai-literacy-superpowers/reference/harness-decision-records.md
  - HARNESS.md
```

The rule's boundary:

> This does not reach reference or how-to pages; those are governed by *Docs
> site kept current*

And the observation, from *What created friction*:

> **The Assayer's own evidence pool does not know that corrections exist.**
> `skills/harness-assay/SKILL.md` lists "Prior assays in `harness/assay/`" and
> contains no occurrence of "errata" or "correction" … This assay read the
> errata because the task message named it.

### Why this matters

Under the rule, naming `correct` and `--correction-file` in some command file
discharges the obligation, and `SKILL.md` still does not tell the Assayer to
read errata — so the assay that follows this one still reads corrections only if
its task message says so. That is the failure the finding names most vividly and
the one its remedy is furthest from touching.

The boundary itself is defensible; O11 is not an argument for widening it. The
objection is that the evidence list should be the set of artefacts the rule can
act on. As written, an approver reading the HDR sees `SKILL.md` cited as
evidence for a rule that cannot reach `SKILL.md`, and a reader in six months
will reasonably infer the rule covers skills.

## O12 — specification quality — medium

### Claim

The exemption's criterion does not describe the population that needs exempting.
The options with the strongest claim to be undocumented are the ones injected by
tests for hermeticity, and no script calls them.

### Evidence

The exemption:

> An option whose **only caller is another script** is exempt by carrying an
> `# undocumented:` comment on the line above its `add_argument` call

The two options at issue:

```python
parser.add_argument("--root", default=".", help="repository root")
p.add_argument("--today", help="YYYY-MM-DD; injected so nothing races the clock")
```

The repository's own account of what this class of option is for, from
`docs/superpowers/specs/2026-06-17-affordance-runtime-recorder-design.md:130`:

> **Hermetic** — `--today` fixes "now"; the analyzer is deterministic.

Neither is called by another script. Both are called by a test suite and by
nothing else.

### Why this matters

Read literally, an author cannot exempt `--today`, so it must be written into a
command prompt where its presence is actively harmful (O5). Read charitably —
"another script" stretched to cover a test harness — the exemption swallows most
of the rule, because almost any option can be described as having a
non-interactive caller.

The fix is small: name the exempt classes rather than the caller
("test-injection, hermeticity and root-override options"). The reason it belongs
in the objection record rather than in a copy-edit is the Registrar's
byte-for-byte guarantee — the wording that lands is the wording in the assay,
and a criterion that does not match its own population becomes an argument at
every future flag.

## Explicitly not objecting to

- **The `script-validator` classification and the refusal to name a `target`.**
  `harness/surfaces.yaml:28` pins `script-validator: HARNESS.md`, and the
  finding's statement that a routed classification refuses a `target` matches
  the reference at line 196. The reasoning is correct and the restraint about
  not choosing a layer to clear a threshold is the right instinct.
- **The decision not to propose "update the command prompt" as the rule.** The
  argument — four capabilities diverged across three carefully written PRs, so
  the failure is structural rather than careless — is sound. My objections are
  to the check that was chosen instead, not to the refusal of the obvious
  non-remedy.
- **The naming of what the rule does not catch.** "I could not state a
  mechanical test for that class whose false-positive rate I could predict, and
  proposing an advisory rule I cannot falsify would be proposing to look
  comprehensive" is better discipline than most rule proposals show, and it is
  the sentence that makes O1 arguable rather than something I had to excavate.
- **`overfitting_risk: low`.** The rule genuinely encodes none of the four
  option names and would have fired on all four independently. Every objection
  above is about what the rule *does* encode, not about it being fitted to the
  incident.
- **`priority: P1`.** Nothing in the evidence lets me argue P2 with more
  authority than the Assayer had, and the finding is a required-key value rather
  than an argument.
- **The exclusion of how-to and reference pages, as a boundary.** Rejecting
  `record-a-governance-change.md` and `assay-a-phase.md` on the grounds that
  extending the check to prose pages is a burden the finding cannot cost is
  correct reasoning. O11 objects that the evidence list crosses the boundary the
  rule draws, not that the boundary is in the wrong place.
- **The factual accuracy of the P1/P5 divergence.** I verified it against
  `harness-propose.md` step 5 and the rejection record on disk, and it holds
  exactly as stated. The finding's central observation is true; O1 is about what
  the proposed remedy does with it.
- **The three gaming modes being ranked at all, and the concession on the first
  one.** Naming the likely evasion, admitting the check cannot see it, and
  arguing the residual value anyway is the honest shape. O1 disputes that the
  residual is residual; it does not dispute the disclosure.
