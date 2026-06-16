# Exploration: microsoft/AI-Engineering-Coach

**Date**: 2026-06-16
**Driving issue**: #340 (investigation only)
**Subject**: [microsoft/AI-Engineering-Coach](https://github.com/microsoft/AI-Engineering-Coach)
(MIT-licensed VS Code extension; "any harness, one dashboard")
**Status**: findings — recommends follow-up issues, ships no behaviour change

## What this is

A short findings doc, per #340: map the MS project's concepts onto our
existing surfaces, separate genuinely-additive ideas from things we already
do, flag MIT-attribution requirements, and recommend concrete follow-ups.

Out of scope (per the issue): porting their VS Code / TypeScript UI, and
adopting their session-log telemetry model wholesale (that would need its own
privacy/consent spec — see Recommendation R1).

## What the MS project is

A VS Code extension that reads **local AI coding-assistant session logs**
read-only, on-device (no phone-home; optional AI features call the in-editor
Copilot API only on explicit invocation). It organises into four pillars —
**Observe → Measure → Improve → Level Up** — surfacing usage patterns,
anti-patterns, and skill progression. Headline features: 45 editable
markdown anti-pattern rules across 5 practice-score categories (Prompt
Quality, Session Hygiene, Code Review, Tool Mastery, Context Management) with
a rule DSL + playground; practice scores with week-over-week trends; a 7×24
activity heatmap; Context Health (score + agentic-readiness checklist +
AI-powered instruction-file review); Skill Finder (repeated-prompt →
reusable-skill detection); and a Learning Center / Achievements layer
(quizzes from real usage, XP Bronze→Silver→Gold→Diamond).

> Verification note: the public README confirms the four pillars, the
> "45 editable markdown rules", the rule-playground (field browser / function
> catalog / metric list), and the MIT license. It does **not** document the
> rule-file schema, the named DSL fields/functions/metrics, the session-log
> schema, or the exact 5 category names — those come from the #340 issue body
> and the feature pages. Any port that copies rule assets must re-read the
> actual files (see R-attribution).

## The load-bearing difference: behaviour vs habitat

Everything below turns on one distinction.

- **MS coaches from _behavioural evidence_** — what the engineer actually did
  inside AI sessions (prompts written, tools invoked, session timing, review
  cadence). Its substrate is the **session log**.
- **We assess from _habitat evidence_** — what the repository contains
  (HARNESS.md, AGENTS.md, CI, tests, reflections, specs, hooks). Our substrate
  is the **committed artifact**.

So most MS features have a mature analog here, but pointed at a different data
source. The genuinely additive ideas are precisely the ones that exploit
behavioural data we don't currently collect — which is also why the biggest
one is privacy-gated and deferred.

## Concept map

| MS concept | Closest existing surface | Verdict |
| --- | --- | --- |
| Practice scores; Bronze→Diamond level-up | `/assess` 5-level cognitive model + 3 discipline scores + 4 operational axes + **Habitat Build Gap** | **Already do (richer)** — ours diagnoses *coherence*, not just a tier. |
| 45 markdown anti-pattern rules + rule DSL | `garbage-collection` GC catalogue (~15 rules incl. fitness + learning-driven) + `governance-constraint-design` anti-pattern gallery + `constraint-design` 4-field anatomy | **Already do**, over artifacts not sessions. Their *taxonomy* is additive input (see R2). |
| Rule Playground (live rule testing) | `harness-enforcer` test runs; verification-slot interface | **Already do** for our substrate. |
| Practice-score trends; 7×24 activity heatmap | `harness-observability` (82 signals, snapshot-to-snapshot trends) | **Partly** — we trend *harness health*; we have **no session-activity heatmap** (needs behavioural data → R1). |
| Context Health score + agentic-readiness checklist | `harness-audit-engine` drift detection; `context-engineering` enforceability test | **Mostly do** — but we emit a *drift report*, not a **readiness checklist / scalar score** → **additive (R3)**. |
| AI-powered instruction-file review | `harness-audit-engine` (HARNESS/AGENTS/CLAUDE drift); `convention-extraction` | **Already do** as drift; a *quality* review angle is a modest extension of R3. |
| Skill Finder (repeated-prompt → skill) | `/reflect` → reflection-driven regression-detection GC (theme recurrence → constraint) | **Partly** — ours is *failure*-oriented and proposes *constraints*; **repeated-prompt → reusable-skill** detection is additive → **R4**. |
| 5 behavioural practice categories | our axes are artifact-based (discipline scores, operational axes) | **Additive taxonomy** — orthogonal behavioural lens, only meaningful with session data → parked behind R1. |
| Learning Center / Achievements / XP | literacy levels (no gamification) | **Additive but off-thesis** → **R5 (consider-and-likely-decline)**. |
| On-device, read-only, no phone-home | hooks never block/phone-home; reflections local; telemetry export opt-in | **Already aligned** — same privacy posture, good precedent to cite if R1 proceeds. |

## Genuinely additive ideas (ranked)

1. **Behavioural evidence lens.** The whole Observe/Measure substrate.
   Triangulating *declared habitat* (what we assess today) against *observed
   behaviour* (what sessions show) would let `/assess` detect a new kind of
   gap — a **"behaviour-vs-habitat gap"**, sibling to the existing Habitat
   Build Gap (which already compares cognitive level to operational mean). A
   team can have an L4 habitat and L1 session behaviour; only behavioural data
   reveals it. This is the highest-value and highest-cost idea, and is
   privacy-gated.
2. **Agentic-readiness checklist.** A binary, fast "is this workspace set up
   for agentic work?" checklist (instruction files present + non-stub,
   MODEL_ROUTING present, constraints enforced, reflections active…) emitting a
   small readiness score. Portable with zero behavioural data; complements our
   drift report with a *forward-looking* readiness view.
3. **Skill Finder angle.** A reuse-oriented (not failure-oriented) detector
   that surfaces repeated prompt/work shapes worth promoting to a skill,
   feeding the skill-authoring pipeline rather than `/harness-constrain`.
4. **Their rule taxonomy as evidence input.** The 5 categories and 45
   anti-pattern names are a ready-made checklist to mine for *new* falsifiable
   GC rules / assessment signals we may be missing — used as inspiration, not
   copied.

## Already covered (do not rebuild)

Practice scoring, anti-pattern rule catalogues, rule testing, observability
trends, instruction-file drift detection, multi-tool convention sync, and the
privacy posture are all mature here — in several cases (the literacy framework,
the falsifiability machinery, the reflection→constraint learning loop) more
developed than the MS analog. The contribution of the MS project to those
areas is a *cross-check taxonomy*, not a capability gap.

## MIT-attribution requirements

The repo is **MIT-licensed** (community effort by Microsoft employees;
explicitly *not* an official Microsoft product; Microsoft trademark guidelines
apply to any mark usage).

- **Ideas and concepts are not copyrightable** — adopting the *approach*
  (behavioural lens, readiness checklist, skill-finder) needs no attribution,
  though a courtesy credit in the relevant spec is good practice.
- **Copying any asset verbatim or near-verbatim** (e.g. their rule markdown
  files, category definitions, quiz text) **does** require MIT attribution:
  reproduce the MIT copyright + permission notice, e.g. in a repo-root
  `NOTICE`/`THIRD_PARTY_NOTICES` file, and do **not** imply Microsoft
  endorsement or use Microsoft marks.
- **Recommendation:** prefer *re-deriving* any rule/checklist in our own
  falsifiable-constraint idiom over copying, which sidesteps attribution
  entirely and keeps everything in our house style. If a verbatim port is ever
  chosen, add the NOTICE in the same PR.

## Recommended follow-ups

| Ref | Proposal | Type | Priority |
| --- | --- | --- | --- |
| **R1** | Discovery spec: *behaviour-vs-habitat gap* — a behavioural-evidence lens for `/assess`, **gated on a privacy/consent design**. Park until appetite exists; large. | spec-first | Low (deferred) |
| **R2** | Mine the MS 5-category / 45-rule taxonomy for falsifiable GC rules or assessment signals we lack; adopt any in our own idiom. | enhancement | Medium |
| **R3** | Add an **agentic-readiness checklist** to `/harness-audit` or `/superpowers-status` — forward-looking readiness score over instruction-file presence/quality. Small, no behavioural data. | enhancement (small) | Medium |
| **R4** | **Skill Finder** angle for the reflection pipeline — detect repeated prompt/work shapes worth promoting to a skill (reuse-oriented, distinct from the failure-oriented constraint loop). | enhancement | Medium |
| **R5** | Gamified progression (XP / achievements / quizzes): record as **considered**; likely **decline** — engagement mechanics sit off our literacy-depth thesis. Revisit only as an opt-in surface if requested. | decision | Low |

**Suggested first build if any:** R3 (agentic-readiness checklist) — smallest,
fully additive, needs no behavioural data, and slots into an existing command.
R1 is the strategic prize but should not start without a privacy/consent spec.
