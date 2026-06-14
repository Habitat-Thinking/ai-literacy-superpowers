---
title: Watch Your Cognitive Reservoir
---
# Watch Your Cognitive Reservoir

Opt in to an advisory watch on **you**, the verifier the harness cannot
verify. Once opted in, a Stop-hook advisory fires automatically at
session end when a threshold is crossed, and you can ask for a fuller
read any time with `/reservoir`. It is advisory-only: it never blocks,
never scores, and records no claim about your cognitive state.

For the concepts and the honest-confidence grounding behind this, see
[Watching the Verifier](../explanation/watching-the-verifier.md).

---

## 1. Opt in

The mechanism is off until your project's `HARNESS.md` contains an
**active** `## Cognitive reservoir` heading. New projects scaffolded
from the template ship the block commented out (the `<!--` sits on the
heading line), so you are not opted in by default.

To opt in, open `HARNESS.md`, find the commented `Cognitive reservoir`
block near the Status section, and remove the surrounding `<!--` / `-->`
markers so the heading becomes a real section:

```markdown
## Cognitive reservoir

- window_hours: 8       # how far back the proxies look
- span_minutes: 180     # continuous session span (min) before the span proxy fires
- decision_volume: 8    # approval-like events (commits/merges) in the window
- context_switches: 4   # distinct work streams touched in the window
- chronotype:           # optional: early | late | intermediate
```

The block is **not** a Constraint — do not move it into the Constraints
section and do not wire it into CI. That would defeat its purpose and
overclaim a precision the proxies cannot support.

## 2. Let the Stop hook advise you

With the block active, `reservoir-check.sh` runs at session end. It
counts the four proxies over the last `window_hours` of git activity and
— only if a disjunctive threshold is crossed — emits a single advisory:
the crossed counts (`observed`), the inferred risk framed as a precaution
under uncertainty, and the one firm principle:

> Decide your stop before the next session begins, while the judgment
> making the call is still one you would trust.

A quiet session produces no output. The hook never blocks and never
fails CI.

## 3. Ask for a fuller read on demand

Run `/reservoir` (Read mode) mid-session to dispatch the
`reservoir-warden` agent for a fuller read: a proxy table with each line
flagged `observed` / `inferred` / `asked`, the defeasible inferred risk,
and — if a threshold is crossed — the single recommendation. The report
contains no combined fatigue score, and the choice to continue is always
yours.

## 4. Tune the thresholds

If the hook fires too often or too rarely, **tune the thresholds — do
not distrust the honesty rule.** Run:

```text
/reservoir tune
```

The command walks you through `window_hours`, `span_minutes`,
`decision_volume`, `context_switches`, and the optional `chronotype`,
and proposes the edited block as a diff for you to confirm. Declaring a
`chronotype` (`early`, `late`, or `intermediate`) is what turns the
late-hour circadian band from `asked` / unverified into a labelled
band — without it, the mechanism will not assert anything about the
hour.

You own this block. It is the one place the mechanism records anything,
and it records only configuration — never a claim about your state.

## 5. Read the advisories as data

A cluster of advisories you routinely ignore is a signal to raise a
threshold, not a failure of discipline. The quality bar is not how often
the warden fires; it is whether, when it fires, it tells the truth about
its own confidence and leaves the choice with you.
