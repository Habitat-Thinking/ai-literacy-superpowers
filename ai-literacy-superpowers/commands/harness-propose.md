---
name: harness-propose
description: Draft a Harness Decision Record from an assay finding — copies the proposed rule text and evidence verbatim into harness/decisions/HDR-<date>-<slug>.md at status proposed, leaving the cost for the approver to write at the acceptance gate; never authors a rule
---

# /harness-propose \<assay-path\> \<finding-id\>

Draft an HDR from one finding in an assay. The record lands at
`status: proposed` with `cost` deliberately empty — the approver writes that at
the `/harness-accept` gate, in their own words.

## When to use

- After reading an assay, on a finding you actually want to act on
- Never on every finding an assay produced. Three accepted HDRs per cycle is the
  cap, and a proposal that cannot win a slot twice running probably was not
  worth a rule

## The copy is deterministic, and you must not do it yourself

The rule text and the evidence list are extracted from the assay **by the
script**, byte for byte.

This is not a convenience. A model asked to copy text usually copies it and
occasionally improves it — fixes a typo, tidies an inconsistent bullet, rewraps
a line — and every one of those is a silent edit to a rule a human is about to
approve believing it to be the Assayer's words.

**Never write rule text or evidence references into the HDR by hand.**

## Process

### 1. Validate input

Confirm the assay exists at the given path. If not, abort with:

```text
Error: assay not found at <path>. Pass a valid path under harness/assay/.
```

### 2. Show the findings

Read the assay and list its findings so the human can confirm the choice:

```text
Findings in 2026-08-21T16-02Z-assay.md:

  finding-3   P1  agent-instruction  validated  Unevidenced completion claims
  finding-5   P3  no-change          advisory   Context files capture narration
  finding-7   P0  harness-loop       validated  Completion claims across surfaces
```

If the human named a finding id already, confirm it exists and move on.

### 3. Run the script

```bash
python3 ai-literacy-superpowers/scripts/harness-registrar.py propose \
  --assay <assay-path> --finding <finding-id>
```

Add `--slug <slug>` only when the derived slug collides with an existing HDR.
The script never overwrites, and a collision means two findings resolved to the
same name.

### 4. Report what was written

State the path, the classification, and the enforcement level. Then, if the
classification is `harness-loop`, `script-validator` or `new-agent`, say this
plainly:

```text
This is a tier-2 classification. Four sections are placeholders:

  ## Why this layer
  ## Enforcement
  ## Validation
  ## Rejected alternatives

A human writes these. Acceptance is refused until they are filled, and
neither the Assayer nor the Registrar is entitled to write the argument
for why a rule belongs at the loop layer.
```

### 5. Validation checkpoint

Read the written file back and check:

- **P1** — frontmatter carries `id`, `title`, `status: proposed`,
  `classification`, `enforcement`, `surfaces`, `provisional`, `evidence`,
  `proposed_cost`, `cost`, `proposer`, `supersedes`, `superseded_by`
- **P2** — `cost` is empty. A pre-filled cost is the anti-theatre gate defeated
  before it opens. If it is not empty, that is a bug in the script; report it
  rather than editing the file
- **P3** — the `## Rule` section holds exactly one four-backtick block, and its
  contents match the assay finding's proposed-rule block **character for
  character**. Diff them; do not eyeball them
- **P4** — `evidence` is the finding's evidence plus the assay anchor
  `<assay-path>#<finding-id>`
- **P5** — for a tier-2 classification, all four extra sections are present

If P3 or P4 deviates, **do not fix it in place** — that would be you doing the
copy the script exists to prevent. Report the deviation as a defect.

For P1, P2 and P5, a deviation is also a script defect. Report, do not patch.

### 6. Suggest next steps

```text
Next: /harness-accept harness/decisions/<id>.md

That gate is where you write the cost — what this rule will demand of
whoever works here next, and how it might be gamed. Every refusal that
does not need a cost runs first, so you will not be asked to compose one
for a rule that is about to be refused.
```

## Refusals

The script refuses, and writes nothing, on: a missing assay; an unknown finding
id; a finding missing its metadata block, its observation prose, its proposed
rule, or its cost estimate; and a target filename that already exists.

Report the refusal. Do not construct the HDR by hand to work around it.
