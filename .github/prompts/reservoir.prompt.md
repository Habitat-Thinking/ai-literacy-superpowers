---
name: reservoir
description: Watch the human verifier the harness cannot verify — Read mode dispatches the reservoir-warden agent for a fuller cognitive-reservoir read; Tune mode helps you edit the HARNESS.md Cognitive reservoir block (thresholds and chronotype), proposing edits for you to confirm
---

# Reservoir

An on-demand, read-only advisory on **you**, the verifier — not on the
code. It counts observable proxies over the recent git window and, if a
threshold is crossed, offers the single decide-your-stop-first
recommendation. Advisory only: never blocks, never scores, never
persists a record of your state.

## Usage

```text
/reservoir [read | tune]
```

Mode defaults to `read`.

## Read mode

1. Confirm HARNESS.md contains a `Cognitive reservoir` block. If not (or
   no HARNESS.md, or no git repo), say the project has not opted in and
   offer Tune mode. Do not manufacture a read.
2. Read `ai-literacy-superpowers/skills/cognitive-reservoir/SKILL.md` for
   the four proxies, the `observed`/`inferred`/`asked` confidence
   discipline, the default thresholds, the one firm principle, the
   honesty rule, and the report format.
3. Gather proxies with `git`/`date` only (read-only): continuous session
   span, decision volume, context switches, wall-clock hour. A proxy that
   matches nothing degrades to 0.
4. Read tuned thresholds from the HARNESS.md block (defaults: window 8 h,
   span 180 min, decision volume 8, context switches 4). Evaluate
   disjunctively — any one crossing fires the recommendation.
5. Produce the report: a proxy table (each line flagged), one or two
   sentences of defeasible inferred risk tied to a robust basis
   (vigilance decrement / switching cost), and — if crossed — the one
   firm principle plus one concrete time-boxed option. No fatigue score.
   No second nudge.
6. Honesty gate: never assert ego depletion; never quote the
   hungry-judges figure; frame every trigger as a precaution under
   uncertainty. The late-hour band is `asked`/unverified unless a
   `chronotype` is declared.

## Tune mode

1. Read the current `Cognitive reservoir` block (or propose adding one).
2. Walk the tunable fields: `window_hours`, `span_minutes`,
   `decision_volume`, `context_switches`, and the optional `chronotype`.
3. Present the proposed block as a diff; confirm before writing. The user
   owns this block — it records configuration only, never a claim about
   their state.
4. After writing, verify the `## Cognitive reservoir` marker is intact,
   keys are recognised, numeric values are positive integers, and the
   not-a-constraint note is present.

## Not a gate

Advisory-only and not a Constraint. Never fails CI, never blocks, writes
no record of cognitive state.
