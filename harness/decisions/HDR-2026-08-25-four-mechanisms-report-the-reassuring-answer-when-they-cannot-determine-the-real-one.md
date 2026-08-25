---
id: HDR-2026-08-25-four-mechanisms-report-the-reassuring-answer-when-they-cannot-determine-the-real-one
title: Four mechanisms report the reassuring answer when they cannot determine the real one
status: proposed
classification: harness-loop
enforcement: advisory
surfaces: [claude-code, codex, cursor, copilot, windsurf]
provisional: true
expires: 2026-11-23
overfitting_risk: low
evidence:
  - ai-literacy-superpowers/scripts/update-health-badge.sh
  - HARNESS.md
  - .github/workflows/gc.yml
  - harness/assay/2026-08-25T11-59Z-assay.md#finding-2
  - harness/assay/2026-08-25T14-31Z-assay.md#finding-1
proposed_cost: |
  Per PR that adds or changes a reporting mechanism: one question the author must
  answer in the spec or the PR body — what does this report when it cannot tell,
  and which code path reaches that value — plus, where the answer is "the passing
  one", the work to change it. Five minutes to answer, thirty to two hours to
  fix. Most PRs add no reporting mechanism and pay nothing.

  The heavy cost is honest and the approver should price it before the per-PR
  one. **This becomes the eleventh agent-enforced constraint in a tree where the
  2026-08-25 audit established that none of them can fire.** `grep -rn
  'harness-enforcer' .github/workflows/` returns nothing (`observed`, and
  recorded in the Status block). An agent-enforced constraint runs when a human
  types `/harness-audit`, which happened once in the twelve days before this
  window. So the realistic sequence after acceptance is: `HARNESS.md` gains a P1
  rule; it is not dispatched by anything; and it is next read at the following
  `/harness-audit`, which may be a quarter away. An approver who wants this to
  bite is buying the dispatch path, not the rule text, and the cost they write
  should say who builds it and when. An approver who does not want to buy that
  should decline this finding rather than accept a rule they know cannot fire —
  that is a legitimate outcome and I would rather it be chosen deliberately than
  arrived at.

  Three ways it can be gamed, in descending order of likelihood. **Declaring an
  `Unknown` state and never routing to it** — the branch exists, the reviewer
  sees it, nothing reaches it. This is the likely evasion; the rule's phrase
  "reachable code path" is the only defence and it depends on a reviewer asking
  what makes the branch reachable, which is exactly the kind of question that
  does not get asked at 17:00. **Renaming the passing value** — shipping
  `Healthy (unverified)` in green, which satisfies the letter and produces the
  same badge. **Arguing the mechanism does not report a status** — available for
  anything that only returns an exit code, and the second sentence about weaker
  properties is what closes it for checks, at the cost of being the vaguest
  clause in the rule. I could not tighten "weaker property" into something
  mechanical without narrowing it to release tags, which would overfit it to
  finding-2.

  ---
cost: ""
proposer:
  agent: harness-assayer
  model: claude-opus-5
  assay: harness/assay/2026-08-25T14-31Z-assay.md
supersedes: null
superseded_by: null
---

## Finding

Four separate mechanisms in this repository resolve an indeterminate state to
the passing value. Each was observed directly, and they share no
implementation.

**The health badge.** At `b1982b0`,
`ai-literacy-superpowers/scripts/update-health-badge.sh` set
`health_status="Healthy"` and `health_colour="2E8B57"` at line 22, then placed
its entire detection block behind `if [ -n "$SNAPSHOT_FILE" ] && [ -f
"$SNAPSHOT_FILE" ]`, where `SNAPSHOT_FILE="${2:-}"`. `/harness-health` step 8
documented the argument-less invocation. Every safety net — the explicit
`- Health:` line reader, the sub-70% override, the signal heuristic — lived
inside the branch an argument-less call skipped (`observed`, `git show
b1982b0:...`). #575 records the reproduction: a run against a snapshot whose
Meta section read `Health: **Degraded**` wrote a green badge.

**The Status block.** At `b1982b0`, `HARNESS.md` read `Last audit: 2026-08-13`,
`Constraints enforced: 33/34`, `Drift detected: no`, against a tree carrying 36
active constraints and, by the 2026-08-25 audit's own account, four failing
ones that predated the 2026-08-13 audit (`observed`, `git show
b1982b0:HARNESS.md` and the current block). The command that writes it had no
read-back step, so `no` was the value it produced when nothing checked.

**A GC step that did not run.** `gc.yml` carries one `if: always()`, on
`Summary`. On run `32712709028` steps 6–14 are `skipped`; on `32015897112`
steps 10–14 are `skipped` (`observed`, per-step conclusions). A `skipped`
conclusion is not a failure and is not a pass; the run reports one red step and
between five and nine unknowns, and a reader asking "did GC pass?" sees the
single failure.

**A check that passes on a weaker property than it names.** `gc.yml`'s
*Release tag completeness* runs `git tag -l "v$version" | grep -q "v$version"`
over `grep -oP '(?<=^## )\d+\.\d+\.\d+' CHANGELOG.md`. I ran that comparison:
117 version headings, 7 with no matching tag. Of the 110 that pass, I sampled
three — `## 0.27.0 — 2026-03-01` is satisfied by tag `v0.27.0` whose commit is
dated 2026-04-26 and titled "Add sync check on /harness-upgrade and PR workflow
on /reflect"; `## 0.28.0 — 2026-03-10` by a tag dated 2026-04-27 for
"/harness-affordance discover"; `## 0.29.0 — 2026-03-28` by a tag dated
2026-04-27 for the Choice Cartographer. The repository's first commit is
`26b55ae`, 2026-03-30, after all three CHANGELOG dates (`observed`). The check
verifies that a name exists, not that a release happened.

Three of the four were repaired in this window. The fourth is open as #578,
which names the pattern in its own words: "a mechanism reporting the reassuring
answer because it cannot determine the real one" (`reported`). The repaired
badge states the principle in a comment: "When this script cannot tell, it says
Degraded: absence of evidence is not evidence of health, and a badge that fails
toward the reassuring answer is worse than no badge" (`observed`). That comment
is the only place in the repository the principle is written. `HARNESS.md`'s 36
constraints and `AGENTS.md`'s six gotchas contain no equivalent (`observed`,
read in full).

## Assayer's reasoning

_Written by the Assayer, carried verbatim. Not the approver's words, and not a substitute for the sections below._

**Why `harness-loop`, and why the threshold is met honestly.** The behaviour is
a design property of this repository's own machinery — the same species as
*Output validation checkpoints*, which sits in `HARNESS.md` — so `HARNESS.md`
is the layer that owns it, and `harness-loop` routes there. I considered
`turn-instructions`, which routes to `AGENTS.md` and would need no CI and no
two-assay threshold. I rejected it because `harness/surfaces.yaml` gives
`AGENTS.md` as the target of `codex` alone, so the rule would reach one surface
and be silent on the one where the work happens. That is classifying at the
layer that is cheapest rather than the one that owns the behaviour.

The two-assay threshold is therefore live, and it is met: assay 2's finding-2
observed the masking instance directly and is uncorrected, so it counts; this
assay observes three further instances in three unrelated mechanisms. Assay 1's
finding-2 also observed masking, but it carries an erratum and I have
deliberately **not** cited it — a corrected finding does not corroborate. I
name no `target`: `harness-loop` is routed, and since #568 a routed
classification refuses one.

**Why no existing owner absorbs it.** *Output validation checkpoints* is the
nearest, and it is the reason `/harness-audit` gained a read-back step in #577.
It cannot absorb this: its subject is a command reading its own structured
output back and checking it against a **format spec**, which is a question
about shape. Three of the four instances here are correctly shaped and wrong
about the world — a green badge is a well-formed badge. The 2026-08-13 Status
block would have passed a structural check on all four fields. *Docs site kept
current* and the GC rule *Command-prompt sync* compare prose surfaces to each
other. `/harness-audit` **found** three of these four instances, which is why
they are not rejected candidates for it — but it has no rule to cite when the
next mechanism ships with the same default, and it found them because a human
typed the command, twelve days after the previous run.

**Overfitting risk: low.** Four instances across a bash script's variable
initialisation, an agent-authored prose block, GitHub Actions step ordering,
and a shell string comparison. The rule encodes none of their specifics and
would have fired on each independently.

**Validation plan.** Reconstruct the tree at `b1982b0` and assert the rule
flags `update-health-badge.sh`, the `## Status` block and `gc.yml`'s
release-tag step. Then assert it does **not** flag
`check-harness-decisions.py` or `harness-registrar.py check`, both of which
exit non-zero when they cannot read their input. If the rule cannot separate
those two sets without an author's cooperation, it is not falsifiable and
should be refused rather than softened.

## Rule

````markdown
- **Rule**: A mechanism that reports a status — a badge, a `## Status`
  block, a check result, a snapshot field, a summary line — must have a
  defined value for the case where it could not determine the answer, and
  that value may not be the passing one. Where an input is missing,
  unreadable or not supplied, the mechanism reports the degraded or unknown
  state and names the input it could not read. A reachable code path that
  reaches a passing value without reading the thing it reports on is a
  defect, not a default. Separately, a check may not report a pass on the
  strength of a property weaker than the one it names: if the check is
  called "release tag completeness" it verifies that the release has a tag,
  not that a string exists. Absence of evidence is not evidence of health,
  and a mechanism that fails toward the reassuring answer is worse than an
  absent one, because the next reader stops looking.
- **Enforcement**: agent
- **Tool**: advocatus-diaboli (spec-mode gate) and harness-enforcer
- **Scope**: pr
````

## Cost

_Proposed by the Assayer. To be replaced at acceptance by the approver's own words:_

Per PR that adds or changes a reporting mechanism: one question the author must
answer in the spec or the PR body — what does this report when it cannot tell,
and which code path reaches that value — plus, where the answer is "the passing
one", the work to change it. Five minutes to answer, thirty to two hours to
fix. Most PRs add no reporting mechanism and pay nothing.

The heavy cost is honest and the approver should price it before the per-PR
one. **This becomes the eleventh agent-enforced constraint in a tree where the
2026-08-25 audit established that none of them can fire.** `grep -rn
'harness-enforcer' .github/workflows/` returns nothing (`observed`, and
recorded in the Status block). An agent-enforced constraint runs when a human
types `/harness-audit`, which happened once in the twelve days before this
window. So the realistic sequence after acceptance is: `HARNESS.md` gains a P1
rule; it is not dispatched by anything; and it is next read at the following
`/harness-audit`, which may be a quarter away. An approver who wants this to
bite is buying the dispatch path, not the rule text, and the cost they write
should say who builds it and when. An approver who does not want to buy that
should decline this finding rather than accept a rule they know cannot fire —
that is a legitimate outcome and I would rather it be chosen deliberately than
arrived at.

Three ways it can be gamed, in descending order of likelihood. **Declaring an
`Unknown` state and never routing to it** — the branch exists, the reviewer
sees it, nothing reaches it. This is the likely evasion; the rule's phrase
"reachable code path" is the only defence and it depends on a reviewer asking
what makes the branch reachable, which is exactly the kind of question that
does not get asked at 17:00. **Renaming the passing value** — shipping
`Healthy (unverified)` in green, which satisfies the letter and produces the
same badge. **Arguing the mechanism does not report a status** — available for
anything that only returns an exit code, and the second sentence about weaker
properties is what closes it for checks, at the cost of being the vaguest
clause in the rule. I could not tighten "weaker property" into something
mechanical without narrowing it to release tags, which would overfit it to
finding-2.

---

## Why this layer

_TODO — why this change belongs at this layer and not one layer down._

## Enforcement

_TODO — how the rule binds on each listed surface, and where it is only advisory._

## Validation

_TODO — how anyone would know later whether this rule helped._

## Rejected alternatives

_TODO — including the 'no change' option, with the reason it was not taken._
