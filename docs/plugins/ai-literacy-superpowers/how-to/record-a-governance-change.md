# Record a governance change

`HARNESS.md` governs the loop. `AGENTS.md` governs the turn. This guide covers
the thing that governs *those* — how a harness rule comes into existence, what
it has to prove, and what it costs.

You will use two commands: `/harness-propose` and `/harness-accept`.

## Before you start

You need an assay — a read-only postmortem at `harness/assay/<ISO8601>-assay.md`
written at a phase boundary. If you do not have one, there is nothing to
propose from, and that is the design: rules enter on evidence, not on
irritation.

You also need `harness/surfaces.yaml`, declaring what each of your control
surfaces can actually enforce.

## 1. Read the assay

This is the only step that needs your full attention. Everything after it is
mechanical.

An assay in which every finding resolves to `no-change` is a **successful**
assay. If nothing needs to change, stop here — the report is the record of that,
and you are done.

## 2. Propose

```bash
/harness-propose harness/assay/2026-08-21T16-02Z-assay.md finding-3
```

This writes `harness/decisions/HDR-2026-08-21-<slug>.md` at `status: proposed`,
copying the rule text and evidence **byte for byte** from the finding.

`cost` is deliberately empty. You write it at the next gate.

**If the classification is `harness-loop`, `script-validator` or `new-agent`,**
four sections arrive as placeholders:

```text
## Why this layer
## Enforcement
## Validation
## Rejected alternatives
```

Fill them yourself. Acceptance is refused until you do, and that refusal is not
bureaucracy: a change that reaches beyond a single agent has to argue why it
belongs at that layer, and neither the Assayer nor the Registrar is entitled to
make that argument for you.

## 3. Accept

```bash
/harness-accept harness/decisions/HDR-2026-08-21-unevidenced-completion.md
```

Every refusal that does not depend on the cost runs **first**. You will not be
asked to compose a considered cost for a rule that is about to be refused.

If it passes, you are asked one question:

```text
Cost of this rule, in your own words. What will it demand of whoever
works here next, and how might it be gamed?
```

Answer it yourself. The validator refuses a cost identical to the Assayer's
proposal, and the reason is not procedural — a copy-pasted cost reads exactly
like a considered one, so nothing downstream can tell them apart. If you ask the
agent to write it, it will decline and offer to discuss the rule instead.

Acceptance is all-or-nothing: on any refusal, nothing is written and the record
stays `proposed`.

**If the classification is not `harness-loop` or `turn-instructions`,** you will
also be asked for a `target` — the artifact the rule text is written into.
`agent-instruction` says the behaviour belongs to an agent, not which agent, and
nothing in the schema can infer it.

Acceptance then does three things in one transaction: accepts the record, writes
the rule into its target's generated region, and recompiles the index and the
enforcement report.

## 4. Read the enforcement report

`harness/enforcement-report.md` tells you what actually happened, per surface:

```markdown
| Surface | Intended | Achieved | Gap | Why |
| --- | --- | --- | --- | --- |
| claude-code | blocked | advisory | gap | no validator declared or resolvable |
| copilot | blocked | advisory | gap | surface supports at most advisory |
```

**A gap is not a failure.** It is a true fact about the world, and the report
exists to state it. What you should not do is downgrade the rule's `enforcement`
to make the gaps disappear — that discards the very information you just gained.

The second row is the surface's ceiling: Copilot reads prose and refuses nothing.
The first is more interesting. It says the rule *could* be enforced here but
nothing enforces it. Declare a `validator:` pointing at the script, workflow or
hook that does the refusing, and the gap closes. A validator that does not exist
counts as no validator — believing the declaration would defeat the check at the
one point it bites.

## 5. Review the diff and commit

Nothing has been committed on your behalf. Three gates exist — drafting,
accepting, committing — and none is implied by another.

Applying and compiling are deliberately *not* extra gates. Once a record is
accepted there is no decision left in either step, and a gate with no decision
behind it is the shape of approval theatre.

## When CI goes red

`/harness-check` runs on every pull request and a failure is a build failure.

| It says | What to do |
| --- | --- |
| **drift** | `/harness-compile`, if the generated region was what changed. If the *corpus* changed, the question is whether that change was approved — and that is not answered by a command |
| **never applied** | `/harness-compile` |
| **malformed markers** | Repair them yourself. Never guess which BEGIN pairs with which END |
| **frozen record** | Serious. An accepted decision was edited after the fact. Do not recompile to make it agree — read the diff against its accepted revision and either restore it or supersede it with a new decision |

## The refusals you will actually meet

| Refusal | What it means | Your options |
| --- | --- | --- |
| Tier-2 sections are placeholders | The argument for this layer is unwritten | Write them, or let the HDR wait |
| `harness-loop` cites one assay | A single incident cannot reach the loop layer | Wait for a second assay to corroborate, or reclassify to the layer that owns the behaviour |
| Fourth acceptance from one assay | The three-per-cycle cap | Leave it `proposed`; it carries forward and competes with the next assay's findings |
| Cost identical to `proposed_cost` | You pasted the Assayer's words | Write your own |
| Undeclared surface | A typo, or a surface missing from the matrix | Fix the name, or declare the surface |
| No route and no target | The rule has nowhere to go | Name the artifact that owns it |
| Target does not exist | The record points at a missing file | Create it yourself — the Registrar writes records, not governance documents |

**A refusal is the mechanism working.** The design assumes rules should be hard
to add and easy to retire. A proposal that carries forward is not a blocked
task.

Do not resolve a refusal by editing the record until it passes. Reclassifying a
rule after the promotion threshold refused it is a real decision about where the
behaviour belongs — make it deliberately, or leave the proposal alone.

## What "provisional" means

Every accepted HDR starts `provisional: true` with a 90-day expiry or a review
trigger. Permanence is earned at review, not at creation.

An expired rule still in force fails CI, so retiring a rule never depends on
anyone remembering to reflect. That is the half of governance most projects
never do.

The exception is grandfathering: constraints lifted from an existing
`HARNESS.md` during migration are imported with `provisional: false` and no
expiry. Importing them on a 90-day clock would manufacture an expiry cliff on
roughly day 90 of adoption, and people would learn to ignore a red check — which
costs far more than the un-evidenced legacy rules ever did.

## See also

- [Harness Decision Record format](../reference/harness-decision-records.md)
- [Assay finding format](../reference/assay-finding-format.md)
- [Enforcement report format](../reference/enforcement-report-format.md)
