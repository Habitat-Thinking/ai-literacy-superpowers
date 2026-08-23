---
name: harness-assay
description: Run the Harness Assayer at a phase boundary — reads evidence from completed work, returns a bounded assay report, and persists it to harness/assay/<ISO8601>-assay.md after the human has read it; the agent is read-only and never self-triggers, so this is always run deliberately
---

# /harness-assay

Run the read-only postmortem that governance changes are built from.

This is invoked **explicitly**, at a phase boundary or on demand. It never
self-triggers, and it never runs in the middle of implementation work — an assay
of a phase that has not finished is an assay of a guess.

## When to use

- At a phase boundary, once, deliberately
- Roughly twenty minutes of a human's attention, most of it spent reading the
  report rather than running commands
- Never mid-phase, and never on a schedule that removes the decision to run it

## What it is not

It is not `/harness-audit`, `/governance-audit` or `/reflect`. Those three audit
**rules that already exist** — whether `HARNESS.md` matches reality, whether
constraints have drifted from intent, what was learned. This governs **the act of
changing a rule**.

The overlap is real and is managed rather than denied: a finding one of those
three already reports is recorded as a **rejected candidate** with that owner
named, not as a finding.

## Process

### 1. Confirm the phase has ended

If work is still in flight, say so and stop. The assay reconstructs what
happened; there is nothing to reconstruct yet.

### 2. Dispatch the harness-assayer agent

Pass the repository. The agent reads `HARNESS.md`, `AGENTS.md`, agent files,
`harness/decisions/`, `harness/enforcement-report.md`, prior assays,
`REFLECTION_LOG.md`, the `docs/superpowers/` records, Coda parking records, the
Mast and WIP stores where they exist, and `git log`.

**Do not pass it a hypothesis.** Do not tell it what you think went wrong. An
assay steered toward a conclusion is a confirmation, and the agent's honesty rule
cannot protect against a question that already contains the answer.

The agent returns the report content as a **string**. It holds no `Write` — that
is criterion S1 of the sentinel signature, enforced by
`sentinel-integrity-check.sh` — so persisting it is this command's job.

### 3. Derive the path

```text
harness/assay/<ISO8601>-assay.md
```

Use a filesystem-safe timestamp: `2026-08-21T16-02Z`, colons replaced by hyphens.

**Assays are append-only.** If a file already exists at that path, do not
overwrite it. Derive a new timestamp, or stop and ask.

### 4. Write the report

Write the agent's returned content verbatim to that path.

**Do not edit it into shape.** If the report is wrong, that is a finding about
the agent, not a document for you to correct — and correcting it would put your
judgement into a record that claims to be the Assayer's observations.

### 5. Validation checkpoint

Lint the written file:

```bash
python3 ai-literacy-superpowers/scripts/harness-registrar.py lint-assay \
  --assay harness/assay/<timestamp>-assay.md
```

That checks the mechanical half of the contract — every finding has an
observation, a metadata block with all five keys, exactly one four-backtick rule
block, and a non-empty cost estimate. It reports **every** malformed finding in
one pass.

Then check what a linter cannot:

- **S1** — the six sections are present and in order: Executive summary, What
  worked, What created friction, Findings, Rejected candidates, Unresolved
  questions
- **S2** — every claim about a check, test or integration passing cites observed
  output. A planned command quoted from a build file is **not** evidence that it
  ran. This is the honesty rule, and it is the one worth reading the report for
- **S3** — sources that were not present are named as absent, not reported as
  empty
- **S4** — **Rejected candidates** is non-empty, or the report says explicitly
  why nothing was rejected. An assay that rejects nothing on
  harness-auditor/governance-auditor/reflect grounds has stopped checking
- **S5** — every finding where evidence conflicted appears under Unresolved
  questions rather than being resolved
- **S6** — no finding proposes a new agent, skill or command without stating why
  an existing owner cannot absorb the behaviour

A `lint-assay` failure is fixed by **re-running the agent**, not by editing the
record. S1–S6 deviations are reported to the human as defects in the assay.

### 6. Present it

```text
Assay written to harness/assay/<timestamp>-assay.md

  <n> findings — <k> at P1 or above
  <r> rejected candidates
  <u> unresolved questions

Read the report. This is the step that needs your attention; everything
after it is mechanical.

An assay in which every finding resolves to `no-change` is a successful
assay. If nothing needs to change, you are done — the report is the
record of that.
```

### 7. Suggest next steps

- **Optional, recommended for anything proposing a `harness-loop` change:** hand
  the assay to `/diaboli` for adversarial review of the findings themselves —
  embedded assumptions, evidence strength, overfitting to this project
- Then `/harness-propose <assay-path> <finding-id>` on the findings you actually
  want to act on. Not all of them: three accepted records per cycle is the cap,
  and a proposal that cannot win a slot twice running probably was not worth a
  rule

## What this command never does

- Draft a decision record, or modify any governance artifact
- Overwrite an existing assay
- Edit the agent's report
- Commit or push
