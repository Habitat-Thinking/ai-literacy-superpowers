# Harness Decision Record format

A **Harness Decision Record** (HDR) is one governance change: the evidence that
justified it, the exact rule text, the enforcement level it intends, the
surfaces it reaches, who approved it, what it costs the next person, and when it
stops being true.

`HARNESS.md` governs the loop and `AGENTS.md` governs the turn. The HDR corpus
governs how those two documents change.

Records live in `harness/decisions/`. They are written by the
`harness-registrar` agent, which holds write authority over governance artifacts
but no authority to author them — proposals come from the `harness-assayer`, a
`role: sentinel` agent that is read-only by construction.

## Layout

```text
harness/
  surfaces.yaml                     # control-surface capability matrix
  assay/<ISO8601>-assay.md          # Assayer output, append-only
  decisions/
    HDR-<YYYY-MM-DD>-<slug>.md      # one per governance change
    index.md                        # generated
  enforcement-report.md             # generated
```

## Filename and identifier

```text
harness/decisions/HDR-<YYYY-MM-DD>-<slug>.md
```

The frontmatter `id` must equal the filename stem exactly. The slug is
lowercase and hyphen-separated; the date must be a real calendar date.

**Why date-plus-slug rather than a sequence number.** Sequential numbering
collides the moment two people propose on parallel branches. Date-plus-slug is
merge-safe and readable in a file listing.

## Lifecycle

A `proposed` HDR is a **draft** and may be edited freely.

**Acceptance is the moment it becomes a record.** The human authors the `cost`
at that gate, so acceptance adds content rather than flipping a flag. From
`accepted` onward an HDR is frozen: never edited, only superseded by a later HDR
naming it in `supersedes:`.

Demotion therefore produces a **superseding HDR** rather than a deletion. The
record shows the rule existed, what it cost, and why it was retired.

### Superseded and expired are derived, never stored

Only `proposed`, `accepted` and `rejected` may be **written**. `superseded` and
`expired` are computed at read time:

| Derived state | Condition |
| --- | --- |
| `superseded` | Some other record names this one in `supersedes:` |
| `expired` | Accepted, provisional, `expires` in the past, not superseded |
| `in force` | Accepted, not superseded, not expired |

`superseded_by` must be `null`. The field stays in the schema because a reader
expects it, and the validator refuses any value.

**This is forced by the frozen-record rule, and it is the better design anyway.**
Writing `superseded_by` onto the record being superseded would be an edit to a
frozen record, so supersession and the frozen check would contradict each other
on the first demotion anyone performed. Deriving the field removes the need for
an exception in the one check that guarantees accepted rules are not quietly
reworded — and it removes a second place for the same fact to be wrong.

### A retirement says `Withdrawn.`

A record that withdraws a rule carries the literal `Withdrawn.` in its `## Rule`
section, with no fenced block, and must name a non-null `supersedes`. Retiring
nothing is not a decision.

Retirements compile nothing and are absent from the enforcement report.

**A `harness-loop` retirement is exempt from the two-assay threshold.** That
threshold exists to make rules hard to *add*. Applying it to removal would mean a
rule that turned out to be wrong needed two assays' evidence before anyone could
withdraw it, and would stay in force meanwhile — the exact inversion of "hard to
add, easy to retire".

### The cycle cap counts live records

Three accepted records per assay, counting records **in force**. Superseding one
frees its slot: the cap limits how much governance an assay *adds*, and a retired
rule adds nothing.

This is why the corpus does not use the state-in-path substrate in
`hooks/scripts/lib/record-paths.sh` that the cadence-sentinel records use. That
substrate exists because a `parked → resumed` transition is a state change with
no new content. Acceptance is not that shape.

## Frontmatter

```yaml
---
id: HDR-2026-08-19-observed-evidence
title: Require observed evidence for phase completion claims
status: accepted           # proposed | accepted | rejected | superseded | expired
classification: harness-loop
enforcement: validated     # advisory | validated | blocked
surfaces: [claude-code, codex]
provisional: true
expires: 2026-11-19        # required when provisional, unless review_trigger is set
review_trigger: "Two consecutive assays with zero findings in this class"
imported: false
target: .claude/agents/tdd-agent.agent.md
validator: ai-literacy-superpowers/scripts/check-observed-evidence.py
evidence:
  - harness/assay/2026-08-04T09-12Z-assay.md#finding-1
  - harness/assay/2026-08-12T14-03Z-assay.md#finding-3
proposed_cost: |
  One extra check per phase boundary.
cost: |
  Two minutes per boundary. Risk: reviewers may start pasting command
  output to satisfy the rule rather than reading it.
proposer:
  agent: harness-assayer
  model: claude-opus-5
  assay: harness/assay/2026-08-12T14-03Z-assay.md
approver: russ@russmiles.com
approved_at: 2026-08-19T10:41Z
supersedes: null
superseded_by: null
cohort: b                  # optional
---
```

### Fields

| Field | Present | Non-empty |
| --- | --- | --- |
| `id`, `title`, `status`, `classification`, `enforcement`, `surfaces`, `provisional`, `evidence`, `proposer`, `supersedes`, `superseded_by` | always | always (`surfaces` may be empty for `no-change`; `supersedes`/`superseded_by` may be `null`) |
| `cost` | always | only when `status: accepted` |
| `approver`, `approved_at` | `status: accepted` | `status: accepted` |
| `expires` **or** `review_trigger` | `provisional: true` | `provisional: true` |
| `target` | when the classification has no route | `status: accepted` |
| `validator` | optional | — |
| `cohort`, `proposed_cost`, `imported` | optional | — |
| `overfitting_risk` | optional | — |

**`target`** names the artifact the rule text is written into, and is required at
**acceptance** for `agent-instruction`, `agent-reference`, `regression-test` and
`new-agent`. `harness-loop`, `turn-instructions` and `script-validator` have
fixed routes in `surfaces.yaml` and need no target of their own.

**A target must be a markdown artifact (`.md`).** Rule text is markdown and is
applied verbatim, so the artifact that *hosts* a rule has to be one that can hold
markdown. The artifact a rule is *about* belongs in the rule's `**Tool**` field —
those are different things, and conflating them is what put a generated markdown
region into a YAML workflow and left it unparseable (#551).

This is an allowlist rather than a list of known-bad types, because a denylist
answers "is this one of the types we thought of?" — which is exactly the question
nobody had asked about `.yml`.

It binds at acceptance rather than at proposal because the Assayer frequently
identifies a behaviour without knowing which of four agent files should own it.
That is the human's decision, made at the gate beside the cost.

**`validator`** is a path, or list of paths, to whatever actually enforces the
rule. Its absence is never an error — an unenforced rule is not a malformed one —
but it is what the [enforcement report](enforcement-report-format.md) uses to
tell *enforced* from *written down*.

**Why `cost` is present but empty while proposed.** The human authors the cost
at the acceptance gate. Requiring it earlier would force `/harness-propose` to
fabricate one, which is precisely the laundering the rule exists to prevent. The
key must exist so the gap is visible; the value arrives at the gate.

### Vocabularies

- `status` — `proposed`, `accepted`, `rejected`, `superseded`, `expired`
- `enforcement` — `advisory`, `validated`, `blocked`
- `classification` — `harness-loop`, `turn-instructions`, `agent-instruction`,
  `agent-reference`, `script-validator`, `regression-test`, `new-agent`,
  `no-change`

An unknown value in any of these fails loudly. A typo must never be a silent
exemption.

## Body

Process burden is proportional to blast radius, so there are two tiers.

**Every HDR** carries `## Finding`, `## Rule`, `## Cost`.

**Additionally, for `harness-loop`, `script-validator` and `new-agent`** — the
classifications whose reach extends beyond a single agent — `## Why this layer`,
`## Enforcement`, `## Validation`, `## Rejected alternatives`.

Every required section must be non-empty. A heading with nothing under it is a
missing section that looks present, which is worse than an absent one.

### `## Assayer's reasoning` — optional, and never the approver's

Emitted by `/harness-propose` when the finding carries prose between its metadata
block and its first `####` subsection — conventionally the Assayer's "why this
layer", overfitting assessment and validation plan. Carried **verbatim** and
labelled, so a reader cannot mistake it for the approver's words.

It is **not** a substitute for the tier-2 sections and does not satisfy them.
Those stay `_TODO` placeholders and acceptance is still refused until a human
writes them.

The split mirrors `proposed_cost` and `cost`, and exists for the same reason:
pre-filled reasoning reads exactly like considered reasoning, and nothing
downstream could tell them apart. Before it existed, extraction stopped at the
first fence and this prose was discarded, so a human wrote the four sections from
scratch beside a file that already held a better version (#554).

The section is **omitted entirely** when a finding carries no such prose, rather
than emitted empty — an empty heading invites someone to fill it, and this one is
not theirs to fill.

### The Rule block

The `## Rule` section holds **exactly one fenced block delimited by four
backticks**, containing the rule text verbatim as it will appear in the target
artifact.

Four backticks, not three, because rule text is markdown and routinely contains
a three-backtick fence of its own — a three-backtick delimiter would terminate
on the first nested fence and silently truncate the rule.

That block is the extraction target for the byte-identity check: the text
applied to a governance artifact must be byte-identical to what is inside those
four backticks. This is what keeps "the Registrar never paraphrases to make text
fit" a guarantee rather than an instruction.

### `no-change` is a first-class outcome

An assay in which every finding resolves to `no-change` is a **successful**
assay. Recording that nothing needed to change is itself evidence.

A `no-change` HDR is relaxed accordingly: `enforcement` must be `advisory`,
`surfaces` may be empty, `provisional` must be `false`, and the `## Rule`
section says `No change.` with no fenced block.

## The refusals

Every refusal lives in `ai-literacy-superpowers/scripts/check-harness-decisions.py`,
which CI runs on every pull request. The Registrar is an agent with write
authority; a rule that lived only in its prompt would be a rule it could talk
itself past.

| Rule | What it refuses |
| --- | --- |
| **Cost** | An accepted HDR with an empty `cost`, or a `cost` identical to `proposed_cost`. The approver writes it in their own words. |
| **Promotion threshold** | An accepted `harness-loop` HDR citing fewer than **two distinct assay files**. Distinctness is by file — two anchors into one assay are one assay. |
| **Cycle cap** | More than **three** accepted HDRs sharing one `proposer.assay`. Excess proposals stay `proposed` and carry forward. |
| **Expiry** | `provisional: true` without an `expires` date or a non-empty `review_trigger`. |
| **Grandfathering** | `imported: true` combined with `provisional: true`, or carrying an `expires`, or naming any proposer other than `imported`. |
| **Attribution** | An accepted HDR without `approver` and `approved_at`. |
| **Surfaces** | An HDR naming a surface not declared in `surfaces.yaml`. |
| **Target** | An accepted HDR whose classification has no route and which names no `target`. |
| **Target type** | A `target` that is not a markdown artifact. Checked before routing, so a routed classification cannot silently discard a target its author named. |
| **Derived state** | A record storing `status: superseded` or `expired`, or a non-null `superseded_by`. |
| **Broken chain** | `supersedes` naming a record that does not exist, itself, or one already superseded by a different record. |
| **Contradiction** | `provisional: false` alongside an `expires` date — a rule not on trial has no trial date. |

The promotion threshold and the cycle cap are **corpus-level**: they compare
HDRs against each other, so they cannot be checked from one file at write time.
CI re-checks the whole corpus, which means a threshold cannot be evaded by a
merge that combines two individually-valid branches.

### Grandfathering

`imported: true` marks a rule that predates this mechanism — a constraint lifted
from an existing `HARNESS.md` during migration. It is accepted with
`provisional: false`, no expiry, `proposer.agent: imported`, and exemption from
the two-assay threshold. It must still cite the source artifact as evidence.

Importing every legacy rule as provisional would manufacture a large expiry
cliff on roughly day 90 of adoption, with CI going red on rules nobody proposed.
People then learn to ignore a red check, which costs far more than the
un-evidenced legacy rules ever did.

## `surfaces.yaml`

A `routes:` block **replaces** the defaults rather than merging with them, so
every route a project relies on must be listed in its own file:

```yaml
routes:
  harness-loop: HARNESS.md
  turn-instructions: AGENTS.md
  script-validator: HARNESS.md
```

```yaml
surfaces:
  claude-code:
    targets: [CLAUDE.md, .claude/agents/, .claude/hooks/]
    supports: [advisory, validated, blocked]
  copilot:
    targets: [.github/copilot-instructions.md]
    supports: [advisory]
  ci:
    targets: [.github/workflows/]
    supports: [validated, blocked]
```

Each surface key is lowercase and hyphen-separated, with a non-empty `targets`
list and a non-empty, duplicate-free `supports` list drawn from the enforcement
vocabulary.

The matrix is validated whenever it exists, not only when HDRs exist — day one
of adoption is when it is being authored and most likely to be wrong.

### An enforcement gap is not an error

A rule intending `blocked` on a surface supporting only `advisory` **passes**
validation. That is an *enforcement gap*, and reporting it is the primary output
of `harness/enforcement-report.md`, not a diagnostic.

Failing the build over it would push authors to declare the weakest enforcement
any surface supports, which destroys exactly the information the gap report
exists to carry: knowing which rules are genuinely enforced, and which are
merely written down.

## Adoption is a choice

A repository with no `harness/` directory passes. Nothing here is imposed on a
project that has not opted in.

## See also

- Spec: `docs/superpowers/specs/2026-08-23-harness-evolution-s0-schema-validator-design.md`
- Tests: `tdad_tests/layer0_deterministic/test-harness-decisions.sh`
- [Enforcement report format](enforcement-report-format.md)
- Constraint: **Harness decision records are well-formed** in `HARNESS.md`
- Constraint: **Harness governance is applied and undrifted** in `HARNESS.md`
