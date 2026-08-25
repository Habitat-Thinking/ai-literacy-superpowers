# Assay a phase

An **assay** is a read-only postmortem at a phase boundary. It reads evidence
from completed work and proposes a bounded change set to the harness, then stops.

It is the evidence half of governance change. Everything downstream — the
two-assay promotion threshold, the three-per-cycle cap, the human-authored cost —
assumes a rule arrived because something was observed. Without an assay, those
mechanisms are ceremony around an unexamined preference.

## Before you start

The phase has to have ended. An assay of work still in flight is an assay of a
guess.

You need roughly twenty minutes, and almost all of it goes on step 2.

## 1. Run it

```bash
/harness-assay
```

**Do not tell it what you think went wrong.** An assay steered toward a
conclusion is a confirmation, and no honesty rule protects against a question
that already contains its answer.

The report lands at `harness/assay/<ISO8601>-assay.md`. Assays are append-only:
nothing ever overwrites one.

## 2. Read the report

This is the step that needs you. Everything after it is mechanical.

Six sections: executive summary, what worked, what created friction, findings,
rejected candidates, unresolved questions.

Three things to check, because a linter cannot:

- **Every claim that a check, test or integration passed cites observed output.**
  A planned command quoted from a build file is not evidence that it ran. This is
  the Assayer's honesty rule and the most likely place for it to have slipped.
- **Rejected candidates is not empty** — or the report says why. An assay that
  rejects nothing has stopped checking against `/harness-audit`,
  `/governance-audit` and `/reflect`, which read the same artifacts.
- **Absent sources are named as absent.** The Mast note store is per-machine; on
  a machine without it, "no boundary events" would be a fabrication dressed as a
  measurement.

### If every finding is `no-change`, you are done

An assay in which every finding resolves to `no-change` is a **successful**
assay. Recording that nothing needed to change is itself evidence, and the next
assay reads it. No further commands.

## 3. Optionally, attack the findings

Recommended for anything proposing a `harness-loop` change:

```bash
/diaboli harness/assay/<timestamp>-assay.md
```

This reviews the findings themselves — embedded assumptions, evidence strength,
overfitting to this project. A finding killed here stays in the report as a
rejected candidate, which is exactly where it belongs: the next assay can see
that it was considered and why it lost.

## 3b. Correcting an assay you have already written

Assays are append-only and are never edited — they record what an agent observed
at a moment, and editing one destroys the thing that makes it evidence. When a
finding turns out to be wrong, the correction goes in a **sibling errata record**:

```bash
python3 ai-literacy-superpowers/scripts/harness-registrar.py correct \
  --assay harness/assay/<timestamp>-assay.md \
  --finding finding-N \
  --correction-file <path>
```

That writes `harness/assay/<timestamp>-assay.errata.md`. One section per
corrected finding; a later correction to the same finding is appended, never
substituted. Neither file is edited.

Three consequences worth knowing before you need them:

1. **`/harness-propose` refuses on a corrected finding.** It quotes the
   correction and proceeds only with `--acknowledge-correction`. That is a
   refusal rather than a warning, because a warning from a command that just
   succeeded is a warning nobody reads, and the record it produces is frozen.
2. **A corrected finding stops counting toward the two-assay threshold.** The
   threshold exists so a single incident cannot reach the loop layer, and
   corroboration by an observation that was wrong is not corroboration.
3. **The exclusion is per finding, not per assay.** An assay may hold six
   findings and be wrong about one.

Point 2 is load-bearing and has already decided an outcome in this repository: a
`harness-loop` record could not clear the threshold because one of its two cited
assays carried an erratum on the finding it cited.

**There is deliberately no pointer inside the assay.** Adding one would require
editing the record, and a mechanism that pressures anyone to edit an append-only
document is worse than the gap it closes. Discovery is met by a sibling with a
predictable name and by refusals at the two points where a correction changes what
you should do.

## 4. Propose the ones you want

```bash
/harness-propose harness/assay/<timestamp>-assay.md finding-3
```

Not all of them. Three accepted records per cycle is the cap, and a proposal that
cannot win a slot twice running probably was not worth a rule.

Then [record the governance change](record-a-governance-change.md).

## Why the Assayer cannot write its own report

It is a `role: sentinel` agent, so `sentinel-integrity-check.sh` fails CI if it
is granted `Write` or `Edit`. It returns the report as a string and
`/harness-assay` persists it.

That is not bureaucracy. Frontmatter tools are all-or-nothing — there is no way
to grant write access to `harness/assay/` and nothing else — so an Assayer that
could write its own report is an Assayer that could rewrite `HARNESS.md`. The
whole design rests on the thing that diagnoses failures being unable to legislate
about them.

## What the Assayer is not

Not `/harness-audit`, `/governance-audit` or `/reflect`. Those audit **rules that
already exist**: whether `HARNESS.md` matches reality, whether constraints have
drifted from intent, what was learned.

The assay governs **the act of changing a rule**. The overlap is real, and it is
managed rather than denied — a finding one of those three already reports is
recorded as a rejected candidate with that owner named.

## See also

- [Record a governance change](record-a-governance-change.md)
- [Assay finding format](../reference/assay-finding-format.md)
- [Sentinels](../explanation/sentinels.md)
