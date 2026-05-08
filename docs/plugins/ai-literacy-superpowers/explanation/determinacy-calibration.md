---
title: Determinacy Calibration
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 14
redirect_from:
  - /explanation/determinacy-calibration/
  - /explanation/determinacy-calibration.html
---

# Determinacy Calibration

Progressive hardening describes the promotion ladder for constraints —
unverified to agent to deterministic, with movement always upward. That
framing is right as far as it goes, and the plugin's documentation
treats it as the canonical path. But the real engineering practice is
not unidirectional. Capabilities migrate up *and* down the determinacy
spectrum. A script that started life as the right answer becomes the
wrong answer when the team's understanding of the underlying problem
sharpens. An agent-based check that catches a class of issue reliably
becomes ready for promotion to a deterministic tool. A skill that has
quietly accumulated flags and special cases is no longer a skill — it
is an undeclared programming language nobody owns.

**Determinacy calibration** is the periodic practice of looking at
where each capability currently sits on the determinacy spectrum,
gathering evidence about whether that placement is still correct, and
moving capabilities deliberately — including not moving them at all.
It is reflective, not reflexive. It runs on project cadence, not per
execution. And the most important thing it does is make the invisible
*choice not to move* a first-class output, on equal footing with
promotion and demotion.

This page sets out why bidirectional movement matters, what calibration
is for, and how it relates to the audit, garbage-collection, and
reflection mechanisms the plugin already provides.

---

## Two failure modes of drift

Drift is asymmetric in attention. Teams notice when their AI agents
behave inconsistently and reach for more scripting. Teams rarely
notice when their scripting has metastasised, because metastasis
*looks* like rigour.

### Over-scripting drift

Scripts accumulate flags, special cases, and accidental
configuration languages. A bash script that started as ten lines
becomes a hundred-line wrapper around three other scripts, two of
which only the author understands. The team relocates indeterminacy
from the agent to the script — but indeterminacy doesn't disappear,
it just gets harder to see.

This failure mode flatters itself. It looks responsible. It survives
review because it produces visible artefacts. But it forces folklore
and apprenticeship to maintain, and the team blames *agent
unreliability* when the calibration that has actually drifted is the
script's.

### Under-scripting drift

Capabilities remain looser than the team's understanding of them
warrants. The same kind of failure recurs because the rule has not
been promoted. Agents and humans both perform intelligence in places
where structure could help. Output stays inconsistent — silently —
even though the system continues to work.

Under-scripting drift produces visible inconsistency only when the
inconsistency is large enough to break something. Smaller drift
accumulates without surfacing until the team tries to reason about
the system as a whole and discovers that no two recent runs of the
same nominal task look alike.

---

## Why movement is bidirectional

Progressive hardening's "movement is always toward deterministic"
framing is correct *for healthy promotions*. It is wrong as a
description of legitimate calibration outputs. There are five honest
moves at any given calibration cycle:

1. **Promotion.** A capability has been agent-enforced reliably enough
   that the underlying pattern is now expressible as a deterministic
   tool. Move it up the ladder.

2. **Demotion.** A deterministic tool has accumulated edge cases that
   make its rule fragile, or the team's understanding of the problem
   has shifted enough that the tool now misclassifies real cases.
   Move it back to agent enforcement, where judgment can be applied,
   while a better tool is designed (or accept that some constraints
   live well at the agent layer).

3. **Splitting.** A single capability is doing two jobs that have
   different determinacy needs. Split it: one half stays at the
   level where it was; the other half moves up or down to where it
   belongs.

4. **Seam repair.** A capability is in the right *layer* but the
   surrounding seams have rotted — orphaned references, dead
   pathways, scripts no skill invokes any more. Fix the seam without
   moving the level.

5. **Leaving unchanged.** The capability is at the right level for
   the evidence the team currently has. The honest output is no
   movement. This is the most under-recorded calibration outcome and
   the most important one to surface — see "Recording refusals"
   below.

The article that motivated this page puts it sharply: *a calibrator
that always proposes a move is optimising for visibility, not harness
health*. Calibration's job is to interpret signal, not to manufacture
activity.

---

## The four signal classes

Calibration is not done by introspection alone. It is grounded in
specific signal that the plugin's existing mechanisms already
produce. Four classes of signal carry the most weight.

- **Change records.** Variance in duration, token usage, and
  artefact trails across nominally identical tasks. If running
  `/harness-audit` takes 30 seconds one week and 5 minutes the next
  with no change in scope, the variance is itself signal — something
  about the audit's enforcement layer is shifting under the surface.
  `/superpowers-status` and the harness-health snapshots are the
  primary surfaces for this signal class.

- **Temporal patterns.** The growth trajectory of scripts and the
  invocation ratio of skills. A hooks directory that has grown 40%
  this quarter is either responding to real demand or is in
  over-scripting drift; the trajectory alone doesn't tell you which
  — but it surfaces the question.

- **Reflection-log patterns.** Where agents (or humans) noted
  improvising around provided tooling. `REFLECTION_LOG.md` entries
  with `Surprise:` text describing "I had to work around X" are
  direct evidence that X is at the wrong level on the determinacy
  spectrum. Recurring improvisation around the same capability
  across multiple reflections is a strong promotion signal *or* a
  splitting signal.

- **Seam integrity.** Dead pathways, orphaned references, scripts no
  skill invokes any more, constraints listed as `deterministic`
  whose tool no longer runs, or skills that quote functions that
  have been deleted. The plugin's GC rules and the harness-auditor
  agent surface most of these directly. Seam rot is what makes a
  capability look healthy from above while being effectively absent
  underneath.

These four classes are not exhaustive — calibration's whole point is
that some signals will only become visible in the context of a
specific project's evolution. But they are the load-bearing classes
to gather every cycle.

---

## Calibration as a review activity

Calibration runs on project rhythm, not on every execution. The
plugin's enforcement mechanisms (hooks, CI gates, harness-enforcer)
operate per-event — they fire when something happens. Calibration is
the opposite shape: it is a deliberate review, scheduled, evidence-
based, and slow.

Cadences worth considering:

- **End-of-iteration** (every sprint, fortnight, or release cycle)
  for active projects. The volume of change is high enough that
  drift can accumulate quickly; reviewing each iteration keeps the
  determinacy distribution in calibration with the team's current
  understanding.

- **Monthly** for steady-state projects where the rate of change is
  slower. The four signal classes accumulate over a month into a
  meaningful sample.

- **Quarterly** for portfolio-scale concerns — calibration patterns
  visible only across multiple repositories, surfaced via
  `/portfolio-assess`.

The cadence choice itself is calibration: a team running calibration
every iteration on a slow-moving project will produce mostly
"leave-unchanged" outputs and learn to skip it; a team running it
quarterly on a fast-moving project will accumulate drift faster than
the cycle catches.

---

## Recording refusals

Calibration's most under-recorded output is the decision *not* to
move a capability. Refusals carry information:

- A capability repeatedly proposed for promotion but always refused
  is signal that the team has an unspoken constraint preventing
  promotion — perhaps the deterministic version would impose a
  workflow change the team isn't willing to make, or the cost of
  the script is judged higher than the cost of the agent-time.
  Surfacing the unspoken constraint is more valuable than promoting.

- A capability repeatedly considered for demotion but kept at its
  current level reveals genuine equilibrium. The team has tried to
  destabilise the placement and failed — that is positive signal
  about the placement, not absence of signal.

- A capability that nobody proposes to move at all is a candidate
  for *removal*. If no one is even debating its placement, it may
  no longer be load-bearing.

A good calibration record reads more like a meeting minutes than a
patch series. It captures what was considered, what was moved, and
what was deliberately left in place — with the rationale for each.
The refusals make the record honest. A record showing only movements
is a record optimised for visibility, not for the harness's health.

---

## How calibration relates to existing mechanisms

Calibration sits *above* the per-event enforcement mechanisms and
*alongside* the audit, GC, and reflection pathways. It consumes their
output rather than replacing them.

| Mechanism | Question it answers | Output |
| --- | --- | --- |
| `/harness-audit` | Does declared state match runtime reality? | Drift report; auto-updates Status block |
| `/harness-gc` | Has entropy accumulated since the last sweep? | Findings against rule-bound checks |
| `/reflect` | What surprised me or failed in this session? | Reflection entry, possibly auto-constraint proposal |
| `/superpowers-status` | What's the current health of the habitat? | Dashboard with current metrics |
| **Determinacy calibration** | Is the determinacy distribution across capabilities still right? | Promote / demote / split / repair / leave decisions, with rationale |

Audit, GC, and reflection produce *raw* signal. Calibration
*interprets* the signal across all four classes and decides, for each
capability, whether the current placement is still correct.

The relationship to progressive hardening is similar: progressive
hardening describes the *shape* of the determinacy ladder; calibration
is the practice that uses that shape over time. Promotions still
follow the ladder; demotions follow the same ladder in reverse;
splittings produce new ladder positions for the parts; refusals
preserve the existing position. Progressive hardening is the
geography. Calibration is the surveying.

---

## The harness-as-habitat framing

The unifying metaphor is the one already present in the framework's
[Habitat Engineering](habitat-engineering.md)
explanation: a habitat has paths and wildness, and the right balance
is contextual rather than absolute. Determinacy is the harness's
paths-versus-wildness dial. Too many paths and the habitat
suffocates: agents and humans alike must follow scripts that no
longer reflect the territory, and improvisation gets blamed on
unreliability rather than recognised as an honest response to over-
constraint. Too few paths and the habitat becomes wilderness:
output is inconsistent, the same problem gets re-solved every time
it recurs, and structure that would help is missing.

The calibration practice is what tunes the dial. Not toward more
paths in general; not toward more wildness in general. Toward the
right balance for the territory the team is currently working in,
recalibrated as the territory itself shifts.

---

## See also

- [Progressive Hardening](progressive-hardening.md) —
  the determinacy ladder calibration applies to; this page extends
  that one with the bidirectional movement framing
- [Self-Improving Harness](self-improving-harness.md) —
  the audit-and-amendment feedback loop that surfaces calibration
  signal
- [Compound Learning](compound-learning.md) —
  the broader frame for converting session-level signal into shared
  infrastructure
- [HARNESS.md, the Document](harness-md.md) —
  where calibration outputs land when they involve constraint
  amendments
- [Habitat Engineering](habitat-engineering.md) —
  the paths-versus-wildness framing from which calibration borrows
  its underlying metaphor
- [How to: Run a determinacy calibration review](../how-to/run-a-calibration-review.md) —
  the practical procedure

External: the article that motivated this page is Russ Miles'
[The Djinn's Determinacy Drift](https://www.softwareenchiridion.com/p/the-djinns-determinacy-drift),
which sets out the argument for calibration as a maintenance
discipline and gives the harness-as-habitat framing its sharpest
form.
