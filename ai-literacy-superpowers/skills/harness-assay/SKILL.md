---
name: harness-assay
description: Use when running or reviewing a harness assay — the read-only postmortem that produces evidence-bearing proposals for governance change. Carries the materiality test, the evidence pool and its honesty flags, the report template, the anti-proliferation rule that keeps the Assayer from duplicating the harness auditor, and the anti-patterns that turn an assay into a productivity display.
---

# Harness Assay

An **assay** is a read-only postmortem at a phase boundary. It reads evidence
from completed work, classifies what it finds by ownership, proposes a bounded
change set, and stops.

It is the input to the harness evolution loop: `/harness-propose` builds a
Harness Decision Record from one of its findings, and `/harness-accept` puts that
record in force after a human writes what it costs.

## What an assay is for

Harness rules accrete. One enters because somebody was annoyed once, and it never
leaves, because leaving requires somebody to remember it exists.

The assay is the half that supplies evidence. Everything downstream — the
two-assay promotion threshold, the three-per-cycle cap, the human-authored cost —
assumes a rule arrived because something was observed. Without an assay, those
mechanisms are ceremony around an unexamined preference.

## The evidence pool

Durable artifacts, plus what the cadence sentinels already recorded. **No new
telemetry.** Everything here exists already.

| Source | What it carries | Typical flag |
| --- | --- | --- |
| `HARNESS.md`, `AGENTS.md`, agent files | The intended workflow | `observed` |
| `harness/decisions/`, `harness/enforcement-report.md` | Rules in force, and which are merely written down | `observed` |
| Prior assays in `harness/assay/` | What was already found, and what was rejected | `observed` |
| `REFLECTION_LOG.md`, `reflections/` | What people noticed at the time | `reported` |
| `docs/superpowers/objections`, `consultations`, `stories`, `slices` | Dispositions at the decision gates | `observed` |
| `docs/superpowers/parked/` | Threads that stopped, and the next action recorded for each | `observed` |
| Mast boundary notes, WIP and reservoir observations | What fired, and when | `observed` where the store exists |
| `git log` | What actually landed, and in what order | `observed` |

### An absent source is absent, not empty

The Mast note store is per-machine and gitignored. On a machine without it, a
report of "no boundary events" would be a fabrication dressed as a measurement.

Say which sources you could read and which were not present. "Nothing fired" and
"nothing was recorded here" are different facts, and only one of them is
evidence.

## The honesty flags

| Claim | Flag |
| --- | --- |
| Text read in a file, a commit, a log | `observed` |
| Something a person or a record says happened | `reported` |
| A conclusion drawn from those | `inferred` |

Every `inferred` claim must sit on an `observed` one.

### The rule this exists for

> **Never claim a check, test, or integration passed unless the result was
> observed in the evidence. Never convert a planned command from a build file
> into passing evidence.**

A build log records commands that were *going* to run. Treating a planned command
as a passing one is one easy inference, and it produces a report that says the
harness is working when nobody looked. It is the exact failure a harness exists
to prevent, committed by the thing auditing the harness.

Where evidence conflicts, present both observations and mark the finding
**unresolved**. Do not resolve it in favour of the neater reading.

## The materiality test

A finding is material only if omitting it could:

- change scope
- cause repeated discovery
- affect an interface or an ownership boundary
- change acceptance criteria or required verification
- affect security, privacy, reliability, observability, or recovery
- hide a blocker, an assumption, or an accepted limitation

Everything else is an observation, not a finding. "The build log has no
consistent format" is immaterial unless something shows a person misread it.

## Classification

Use the Harness Decision Record taxonomy, because the finding becomes one:

`harness-loop` · `turn-instructions` · `agent-instruction` · `agent-reference` ·
`script-validator` · `regression-test` · `new-agent` · `no-change`

Classification carries a real cost downstream. `harness-loop`,
`script-validator` and `new-agent` require four extra sections in the record, and
`harness-loop` additionally requires evidence from **two distinct assays** — a
single incident cannot reach the loop layer. Classify at the layer that owns the
behaviour, not at the layer that would feel most decisive.

## The anti-proliferation rule

Prefer tightening an existing rule or agent over proposing a new one, and state
explicitly why the existing owner cannot absorb the behaviour.

**This rule points at the assay itself.** The plugin already has:

| Owner | Its question |
| --- | --- |
| `/harness-audit` | Does `HARNESS.md` match reality? |
| `/governance-audit` | Have constraints drifted from their intent? |
| `/reflect` | What did we learn? |

An assay reads the same artifacts. The distinction is that those three audit
**rules that already exist**; the assay governs **the act of changing one**.

So: a finding one of them already reports is **not a finding**. It is a rejected
candidate, recorded with the owner named. An assay that never rejects anything on
those grounds has stopped checking.

## The report

Six sections, in order.

1. **Executive summary** — effectiveness, and the single most important
   opportunity. One opportunity, not a ranked list of five.
2. **What worked** — evidence-backed practices worth preserving. Not
   encouragement; a named behaviour with the evidence that it happened.
3. **What created friction** — problem, impact, evidence.
4. **Findings** — the [assay finding contract](../../../docs/plugins/ai-literacy-superpowers/reference/assay-finding-format.md):
   heading, observation prose, metadata block, proposed rule, cost estimate. Plus
   overfitting risk and a validation plan.
5. **Rejected candidates** — with the existing owner that should absorb the
   behaviour instead.
6. **Unresolved questions** — what needs a human, including every finding where
   evidence conflicted.

### The cost estimate is load-bearing

It becomes the record's `proposed_cost`, which is the exact text the validator
compares the approver's own words against — and refuses when they match.

A vague cost estimate weakens that check. Say what the rule will demand of
whoever works here next, and how it might be gamed.

### `no-change` is a first-class outcome

An assay in which every finding resolves to `no-change` is a **successful**
assay. Recording that nothing needed to change is evidence, and the next assay
reads it.

The Findings section may not be empty — that records nothing at all — but a
single `no-change` finding is a complete and honest report.

## Anti-patterns

**Proposing to look comprehensive.** Six findings with evidence for two is two
findings and four inferences. Every proposal declares its burden; a proposal
whose burden you cannot state is one you have not thought about.

**Collapsing intended and actual.** Reconstructing them together produces a
description of the process. The gap between them is where findings live.

**Carrying findings forward.** A finding from a prior assay is evidence that it
was found, not evidence that it is still true. Re-observe it or cite the prior
assay as a second, independent observation — which is exactly what the two-assay
promotion threshold is asking for.

**Resolving a conflict.** Two sources disagreeing is a finding for a human, not a
puzzle for the agent.

**Writing.** The assay is returned as a string. The command persists it.

## The failure mode

Not laziness. Productivity.

A well-written postmortem with a prioritised backlog is easy to rubber-stamp, and
at the governance layer that is the worst place for cognitive surrender. The
report that costs the most is the one that is fluent, comprehensive, and built on
one unexamined inference.
