---
name: harness-check
description: Read-only drift detection across the governance corpus and every generated region, including the git-backed frozen-record check that byte-identity alone cannot perform; exits non-zero on any divergence and is the CI entry point rather than something anyone types
---

# /harness-check

Verify that what is written down and what is in force are the same thing.

This is a **CI entry point**. You will normally meet it as a red build rather
than as something you ran.

## What it checks

| Check | Fails when |
| --- | --- |
| Corpus valid | `check-harness-decisions.py` refuses any record |
| Malformed markers | A target artifact has an unmatched or duplicated marker pair |
| Never applied | An accepted record routes to a file with no generated region |
| Region drift | A generated region differs from what the corpus produces |
| Report drift | `enforcement-report.md` or `index.md` differ from a fresh compile |
| Frozen record | An accepted HDR differs from its content at the commit that accepted it |

**A failure is a build failure, not a warning.** A governance check that can be
ignored is a governance check that will be.

## Why the frozen-record check exists

Region drift catches a hand-edit to a compiled rule, because the region no longer
matches what the corpus would produce.

It cannot catch the failure this whole design is arranged against. An agent with
write authority could reword the rule **in the accepted record** and recompile:
the region would then match the corpus exactly, every byte-identity check would
pass, and the rule in force would quietly differ from the one a human approved.

So each accepted record is compared against its content at the commit that
accepted it. An accepted record is frozen — a later decision supersedes a rule;
nothing edits one.

### The known limit, stated rather than hidden

A record that has never been committed cannot be checked this way, and is skipped
with a note. That window is closed by human review of the diff, which is the
third gate and the one this mechanism never tries to replace.

If you are ever tempted to present that note as a pass, do not. Say plainly which
records were skipped and why.

## Process

```bash
python3 ai-literacy-superpowers/scripts/harness-registrar.py check
```

Report every problem, in the order printed, with what would resolve it:

- **Drift** — `/harness-compile` repairs it, *if* the generated region was the
  thing that was wrong. If the corpus was the thing that changed, the question is
  whether that change was approved, and the answer is not a command
- **Never applied** — `/harness-compile`
- **Malformed markers** — a human repairs them; never guess
- **Frozen record** — this one is serious. An accepted decision has been edited
  after the fact. Do not "fix" it by recompiling. Show the human the diff between
  the record and its accepted revision, and let them decide whether to restore it
  or supersede it with a new decision

## What it never does

- Write anything. It is read-only, and that is what makes it safe to run anywhere
- Repair drift. `/harness-compile` does that, deliberately as a separate step
- Pass because a problem looked cosmetic
