---
id: HDR-2026-08-25-command-cli-parity
title: The prose that drives the loop is never checked against the loop's code
status: proposed
classification: script-validator
enforcement: validated
surfaces: [ci]
provisional: true
expires: 2026-11-23
overfitting_risk: low
proposed_rule: |
  - **Rule**: Every long option and every subcommand that a script accepts must
    appear verbatim in at least one file under
    `ai-literacy-superpowers/commands/`, when that script is invoked by a
    command in that directory. A capability the code exposes and no command
    prompt names is a capability the agent driving that command cannot reach,
    and a validation checkpoint written against an older interface reports a
    correct artifact as a defect — which is worse than silence, because the
    command instructs the agent to report rather than patch. An option whose
    only caller is another script is exempt by carrying an `# undocumented:`
    comment on the line above its `add_argument` call, so the exemption is
    visible where the option is declared rather than in a list somewhere else.
    This does not reach reference or how-to pages; those are governed by
    *Docs site kept current*, whose trigger is a change to a command, skill or
    agent file.
  - **Enforcement**: deterministic
  - **Tool**: `python3 ai-literacy-superpowers/scripts/check-command-cli-parity.py`
    (CI: `.github/workflows/harness.yml`)
  - **Scope**: pr
evidence:
  - ai-literacy-superpowers/commands/harness-propose.md
  - ai-literacy-superpowers/commands/harness-accept.md
  - ai-literacy-superpowers/skills/harness-assay/SKILL.md
  - ai-literacy-superpowers/scripts/harness-registrar.py
  - docs/plugins/ai-literacy-superpowers/reference/harness-decision-records.md
  - HARNESS.md
  - harness/assay/2026-08-25T11-59Z-assay.md#finding-1
proposed_cost: |
  One-off: writing the parity check — an argparse walk over each script named in
  a command file, matched against that file's text — perhaps an hour, plus the
  Layer-0 suite. Then a backlog: the four capabilities already divergent must be
  written into `harness-propose.md` and `harness-accept.md` before the check can
  go green, which is thirty to sixty minutes of prose someone has to actually
  think about, because `--reject` changes what step 5's checkpoint should assert.

  Recurring: one line of prose per new option, paid by whoever adds the option,
  in the same PR. For a repository that added four in a day that is not nothing;
  for a repository that adds one a month it is invisible. The honest description
  is that it makes adding a flag slightly more expensive and makes an unusable
  flag impossible.

  Three ways it can be gamed, in descending order of likelihood. **Naming the
  flag and not explaining it** — a bare `--reject` mentioned in a code fence
  satisfies a literal-string check while the prompt still never tells the agent
  when to use it. This is the likely evasion and the check cannot see it; the
  mitigation is that the flag at least becomes discoverable, which is strictly
  better than today. **`# undocumented:` as a default** — the exemption is one
  comment away and an author in a hurry will reach for it; it is deliberately
  placed at the `add_argument` line so it shows up in the diff beside the option,
  where a reviewer is already looking. **Splitting the parser** — moving options
  into a wrapper script that no command file names. That would be conspicuous and
  costs more than writing the line.

  What the rule does **not** catch is the friction that motivated half its
  evidence: a reference page or a docstring asserting behaviour the code lacks,
  as in #567 and #568. I could not state a mechanical test for that class whose
  false-positive rate I could predict, and proposing an advisory rule I cannot
  falsify would be proposing to look comprehensive.

  ---
cost: ""
proposer:
  agent: harness-assayer
  model: claude-opus-5
  assay: harness/assay/2026-08-25T11-59Z-assay.md
supersedes: null
superseded_by: null
---

## Finding

`harness-registrar.py` accepts the long options `--acknowledge-correction`,
`--approver`, `--assay`, `--correction-file`, `--cost-file`, `--finding`,
`--hdr`, `--now`, `--reason-file`, `--reject`, `--root`, `--slug`, `--target`,
`--today`, and the subcommands `accept`, `check`, `compile`, `correct`,
`index`, `lint-assay`, `precheck`, `propose`, `review`.

`ai-literacy-superpowers/commands/harness-propose.md` names `--assay`,
`--finding`, `--slug`. `commands/harness-accept.md` names `--hdr`,
`--cost-file`, `--approver`, `--now`. A `grep -rln` across
`ai-literacy-superpowers/commands/`, `agents/` and `skills/` for
`--reject`, `--acknowledge-correction`, `--correction-file`,
`harness-registrar.py correct` and `accept … --target` returns **no files**.
Both command files were last modified on 2026-08-23; the four capabilities
landed on 2026-08-25 in #562, #566 and #568.

The divergence is not only omission. `harness-propose.md`'s step-5 validation
checkpoint requires, as **P1**, that the written record's frontmatter carries
`proposed_cost` and `cost`, and as **P5** that a tier-2 classification carries
all four extra sections. The rejection record shipped by #562 and written by
#563 carries neither key and none of those sections, by design. An agent
following the checkpoint as written against a correctly-formed rejection would
report a defect that is not there — and the command's own instruction for that
case is "Report the deviation as a defect … Report, do not patch."

The same divergence reaches the reference layer: the errata mechanism is
documented in `docs/.../reference/assay-finding-format.md` and in the
`harness-registrar.py` source, and nowhere in the agent-facing prose that
`/harness-assay` and `/harness-propose` actually load.

## Assayer's reasoning

_Written by the Assayer, carried verbatim. Not the approver's words, and not a substitute for the sections below._

**Why this layer, and why no existing owner absorbs it.** Three constraints sit
nearby and none of them fires here. *Docs site kept current* is triggered by a
PR that "adds, removes, or substantially changes a skill, agent, or command" —
and no file under `ai-literacy-superpowers/commands/`, `agents/` or `skills/`
changed in this entire phase (`observed`, `git diff --name-only`), so its
trigger condition is precisely what went missing. *Docs propagation when
shipping new commands* is scoped to a PR that adds a **new** command. The GC
rule *Command-prompt sync* compares `commands/` against `.github/prompts/` —
two prose surfaces against each other, never against the code. `/harness-audit`
would correctly report all three compliant, which is why this is a finding and
not a rejected candidate.

I am deliberately **not** proposing "update the command prompt". Four
capabilities diverged in a single day across three PRs, each written carefully
and each reviewed; the failure is not carelessness but the absence of anything
that reads a parser and a prompt in the same breath. That is a check, so the
classification is `script-validator`, which routes to `HARNESS.md`. I name no
`target` for that reason: the route wins in `target_of`, and since #568 a
routed classification refuses one.

`enforcement: validated` states the intent. No such check exists today, so the
first `/harness-compile` after acceptance should report an enforcement **gap**
on `ci` rather than `validated`. That is the enforcement report doing its job
and is not a reason to declare `advisory` instead.

**Overfitting risk: low.** The rule states a property of any command that
delegates to a script and encodes none of the four options that happen to have
diverged. It would have fired on all four independently.

**Validation plan.** Reconstruct the tree at `b1982b0^` for #562, #566 and #568
and assert the check fails on each. Assert it passes at `2e2d1fa`, where the
prompts and the parser agreed. Then assert it passes at `b1982b0` **only after**
the prompts are updated — if it passes on the current tree unchanged, the check
is not reading what it claims to read and should be refused.

## Rule

````markdown
- **Rule**: Every long option and every subcommand that a script accepts must
  appear verbatim in the command file that invokes that script. A capability the code exposes and no command
  prompt names is a capability the agent driving that command cannot reach,
  and a validation checkpoint written against an older interface reports a
  correct artifact as a defect — which is worse than silence, because the
  command instructs the agent to report rather than patch. An option whose
  only caller is another script is exempt by carrying an `# undocumented:`
  comment on the line above its `add_argument` call, so the exemption is
  visible where the option is declared rather than in a list somewhere else.
  This does not reach reference or how-to pages; those are governed by
  *Docs site kept current*, whose trigger is a change to a command, skill or
  agent file.
- **Enforcement**: deterministic
- **Tool**: `python3 ai-literacy-superpowers/scripts/check-command-cli-parity.py`
  (CI: `.github/workflows/harness.yml`)
- **Scope**: pr
````

## Cost

_Proposed by the Assayer. To be replaced at acceptance by the approver's own words:_

One-off: writing the parity check — an argparse walk over each script named in
a command file, matched against that file's text — perhaps an hour, plus the
Layer-0 suite. Then a backlog: the four capabilities already divergent must be
written into `harness-propose.md` and `harness-accept.md` before the check can
go green, which is thirty to sixty minutes of prose someone has to actually
think about, because `--reject` changes what step 5's checkpoint should assert.

Recurring: one line of prose per new option, paid by whoever adds the option,
in the same PR. For a repository that added four in a day that is not nothing;
for a repository that adds one a month it is invisible. The honest description
is that it makes adding a flag slightly more expensive and makes an unusable
flag impossible.

Three ways it can be gamed, in descending order of likelihood. **Naming the
flag and not explaining it** — a bare `--reject` mentioned in a code fence
satisfies a literal-string check while the prompt still never tells the agent
when to use it. This is the likely evasion and the check cannot see it; the
mitigation is that the flag at least becomes discoverable, which is strictly
better than today. **`# undocumented:` as a default** — the exemption is one
comment away and an author in a hurry will reach for it; it is deliberately
placed at the `add_argument` line so it shows up in the diff beside the option,
where a reviewer is already looking. **Splitting the parser** — moving options
into a wrapper script that no command file names. That would be conspicuous and
costs more than writing the line.

What the rule does **not** catch is the friction that motivated half its
evidence: a reference page or a docstring asserting behaviour the code lacks,
as in #567 and #568. I could not state a mechanical test for that class whose
false-positive rate I could predict, and proposing an advisory rule I cannot
falsify would be proposing to look comprehensive.

---

## Why this layer

The harm is real and a parity check is a reasonable thing to want. Output validation checkpoints owns the adjacent behaviour and had never been dispatched, but running the audit and writing the check are not alternatives to each other, so this does not collapse into that constraint. script-validator routes the rule text to HARNESS.md, which is where a rule about how work proceeds here belongs.

## Enforcement

Intended validated on ci. Achieved is none rather than a downgraded level: ci supports no advisory rung and no validator resolves until the check is written. The enforcement report should show that gap rather than a softened level, and the cost of closing it is the check itself.

## Validation

Nothing will tell us whether this rule helped. There is no measurement that would separate a repository where it worked from one where it was ignored, and the drafted plan named a criterion nobody can evaluate. Provisional on that basis, expiring 2026-11-23. The review at expiry is a judgement, not a reading.

## Rejected alternatives

Generation rather than checking - the repository owns an idempotent generator and generation dominates a string check on every axis the finding measures. Not rejected; carried into the redraft. Routing to /harness-audit alone - rejected: the audit finds instances, it does not stop the next one. No change - rejected, because the harm is real.
