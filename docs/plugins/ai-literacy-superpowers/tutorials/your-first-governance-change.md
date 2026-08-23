---
title: Your First Governance Change
---
# Your First Governance Change

In this tutorial you will change a harness rule the governed way: from
evidence, through a recorded decision, with a cost you wrote yourself and an
expiry date that CI will enforce.

Plan for about thirty minutes. Most of it is reading.

## Why not just edit HARNESS.md

You can. Nothing stops you, and for the *first* draft of a harness that is the
right thing to do — see [Add a Constraint](../how-to/add-a-constraint.md).

The problem is what happens next. Harness rules accrete. One enters because
somebody was annoyed once, and it never leaves, because leaving requires
somebody to remember it exists. A year later the document that governs the work
is the least governed thing in the repository: a dozen rules, none carrying the
evidence that justified it, none saying who owns it, none saying what it costs,
and none with an expiry.

That is a failure with no incident behind it, which is why it is rarely fixed.
Nothing ever goes wrong on a Tuesday because of it.

This loop is the answer. **Once a harness exists, this is how it changes.**

## What you will need

A repository with a `HARNESS.md`, and a phase of work that has just finished.
Not one still in flight — an assay of unfinished work is an assay of a guess.

If you have never set up a harness, run `/harness-init` first and come back
after your next phase.

## 1. Set up the corpus, once

```bash
mkdir -p harness/decisions
```

Then write `harness/surfaces.yaml`, declaring what each of your tools can
actually enforce:

```yaml
routes:
  harness-loop: HARNESS.md
  turn-instructions: AGENTS.md

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

`routes` says where a rule's *text* goes. `surfaces` says who is *told* about
it, and how strongly it can bind there.

Be honest in `supports`. A surface that reads prose and refuses nothing
supports `advisory`, however much you would like it to block. That honesty is
what makes the enforcement report worth reading later.

Finally, add the check to CI:

```yaml
- name: "Harness governance is applied and undrifted"
  run: python3 ai-literacy-superpowers/scripts/harness-registrar.py check
```

## 2. Run the assay

```bash
/harness-assay
```

The Harness Assayer reads your `HARNESS.md`, `AGENTS.md`, agent files, build
log, reflection log, decision records, and whatever the cadence sentinels
recorded. It reconstructs what the workflow was *meant* to be, then what
actually happened, and reports the gap.

**Do not tell it what you think went wrong.** An assay steered toward a
conclusion is a confirmation.

The report lands at `harness/assay/<timestamp>-assay.md`.

## 3. Read it — this is the step that matters

Everything after this is mechanical. Six sections: executive summary, what
worked, what created friction, findings, rejected candidates, unresolved
questions.

Three things to check, because no linter can:

- **Every claim that a check passed cites observed output.** A planned command
  quoted from a build file is not evidence that it ran. This is the Assayer's
  honesty rule and the most likely place for it to have slipped.
- **Rejected candidates is not empty** — or the report says why. An assay that
  rejects nothing has stopped checking itself against `/harness-audit`,
  `/governance-audit` and `/reflect`, which read the same artifacts.
- **Absent sources are named as absent.** "No boundary events" from a machine
  with no boundary-note store is a fabrication dressed as a measurement.

### If every finding is `no-change`, you are finished

That is a **successful** assay. Recording that nothing needed to change is
itself evidence, and the next assay will read it. Stop here.

## 4. Propose one finding

```bash
/harness-propose harness/assay/<timestamp>-assay.md finding-3
```

Not all of them. Three accepted records per cycle is the cap, and a proposal
that cannot win a slot twice running probably was not worth a rule.

This writes `harness/decisions/HDR-<date>-<slug>.md` at `status: proposed`. The
rule text and evidence are copied **by a script**, byte for byte — a model asked
to copy text usually copies it and occasionally improves it, and every
improvement is a silent edit to a rule you are about to approve believing it to
be the Assayer's words.

`cost` is deliberately empty. That is yours.

## 5. Accept it — and expect to be refused

```bash
/harness-accept harness/decisions/HDR-<date>-<slug>.md
```

Every refusal that does not need a cost runs **first**, so you are never asked
to compose a considered cost for a rule that is about to be rejected.

A first-timer usually meets one of these:

| Refusal | What it means |
| --- | --- |
| `harness-loop` citing one assay | A single incident cannot reach the loop layer. Wait for a second assay, or reclassify to the layer that owns the behaviour |
| Tier-2 sections are placeholders | A change reaching beyond one agent must argue why it belongs at that layer. Neither the Assayer nor the Registrar may write that argument |
| No route and no `target` | `agent-instruction` says the behaviour belongs to an agent, not *which* agent. That is your call |

**A refusal is the mechanism working.** Rules should be hard to add. A proposal
that carries forward to the next cycle is not a blocked task.

Once it passes, you get one question:

```text
Cost of this rule, in your own words. What will it demand of whoever
works here next, and how might it be gamed?
```

Answer it yourself. The validator refuses a cost identical to the Assayer's
proposal — not as procedure, but because a copy-pasted cost reads exactly like a
considered one, so nothing downstream can tell them apart. If you ask the agent
to write it, it will decline and offer to discuss the rule instead.

Acceptance then does three things in one transaction: accepts the record, writes
the rule into the artifact that owns it, and recompiles the index and the
enforcement report.

## 6. Read the enforcement report

```bash
cat harness/enforcement-report.md
```

```markdown
| Surface | Intended | Achieved | Gap | Why |
| --- | --- | --- | --- | --- |
| claude-code | blocked | advisory | gap | no validator declared or resolvable |
| copilot | blocked | advisory | gap | surface supports at most advisory |
```

**A gap is not a failure.** It is a true fact, and the report exists to state it.
What you must not do is lower the rule's `enforcement` to make the gaps
disappear — that discards the information you just gained.

The second row is a ceiling: Copilot reads prose and refuses nothing. The first
is more interesting. It says the rule *could* be enforced here and nothing
enforces it. Point `validator:` at the script or workflow that does the
refusing, and the gap closes. A validator that does not exist counts as no
validator.

## 7. Review the diff and commit

Nothing has been committed for you. Three gates exist — drafting, accepting,
committing — and none is implied by another.

## 8. Ninety days later

Your rule was accepted `provisional: true` with an expiry. Permanence is earned
at review, not at creation.

When it lapses, CI goes red and `/harness-review` gives you three options:
**re-evidence** it, **weaken** it, or **demote** it. All three write a *new*
record that supersedes the old one — nothing edits an accepted record, and
nothing is ever deleted. The record that the rule existed, what it cost, and why
it went is the output of this whole mechanism.

That is the half of governance almost nobody does, and it is the half this loop
exists for.

## What you have now

- A rule that entered on evidence, not irritation
- A cost written by a person, in their own words
- A truthful account of how strongly it binds on each tool
- An expiry that CI enforces, so retiring it never depends on anyone remembering

## Where to go next

- [Assay a phase](../how-to/assay-a-phase.md)
- [Record a governance change](../how-to/record-a-governance-change.md)
- [Harness evolution](../explanation/harness-evolution.md) — why the two roles are separate
- [Harness Decision Record format](../reference/harness-decision-records.md)
