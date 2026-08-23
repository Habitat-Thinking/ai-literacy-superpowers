# Spec: Harness Evolution S3 — the Harness Assayer

**Status:** Approved
**Date:** 2026-08-23
**Issue:** #537
**Epic:** Harness Evolution — the Harness Assayer and the Harness Registrar (#533)
**Depends on:** S1 (0.75.0) — the assay-finding contract this agent writes to.
**Scope:** `ai-literacy-superpowers` plugin — one sentinel, one skill, one
command, one deterministic assay linter, one seeded fixture.
**Explicitly out of scope:** proposing, accepting, compiling, review, demotion,
and the Observatory export. The Assayer stops at the report.

**Provenance:** the Harness Assayer / Harness Registrar build spec, supplied in
conversation 2026-08-23. Epic-level decisions recorded on #533.

---

## 1. Problem Statement

S0 built the refusals, S1 the records, S2 the application. Every one of them
waits on an input that does not exist: an assay.

Harness rules currently enter because somebody was annoyed once. The Assayer is
the other end — the thing that reads what actually happened and proposes a
bounded change set from evidence, then stops.

## 2. The role collision, and how it resolves

The build spec declares the Assayer a **sentinel** and, four paragraphs later,
instructs it to "write the assay report to `harness/assay/<ISO8601>-assay.md`".

Those cannot both hold here. Criterion S1 of the sentinel signature is a
read-only trust boundary, and `sentinel-integrity-check.sh` fails CI on any
`role: sentinel` agent whose `tools:` list contains `Write` or `Edit`.
Frontmatter tools are all-or-nothing — there is no way to grant write access to
`harness/assay/` and nothing else — so a writing Assayer is an Assayer that can
also rewrite `HARNESS.md`, which is precisely the concentration of authority the
two-role separation exists to prevent.

**Resolution: the agent returns the report content as a string, and
`/harness-assay` persists it.** This is the `cost-estimator` and `coda`
precedent, already established twice in this repository, and it keeps the
Assayer inside the category rather than beside it.

The build spec's §4 permission table survives intact — `harness/assay/` is still
the only path that gains a file — but the write happens on the command's
authority, not the agent's.

## 3. The sentinel signature

**S1 — read-only trust boundary.** `tools: [Read, Glob, Grep, Bash]`. `Bash` for
reading only: `git log`, `ls`, `cat`, `date`.

**S2 — advisory output for a human.** The assay is a report a person reads and
disposes. Nothing downstream acts on it automatically; `/harness-propose` is
invoked by a human who chose a finding.

**S3 — explicit epistemic honesty rule.** Every sentinel carries its own. The
Assayer's is the sharpest in the roster because its subject matter invites the
failure directly:

> **Never claim a check, test, or integration passed unless the result was
> observed in the evidence. Never convert a planned command from a build file
> into passing evidence.**

An assay reads build logs full of commands that were *going* to run. Treating a
planned command as a passing one is a single, easy inference, and it produces a
report that says the harness is working when nobody looked. Every finding
therefore carries an `observed` / `reported` / `inferred` flag, and where
evidence conflicts the finding is marked **unresolved** rather than resolved in
favour of the neater reading.

## 4. Anti-proliferation, aimed at itself

The build spec's hard constraints say: prefer tightening an existing rule or
agent over proposing a new one, and state explicitly why the existing owner
cannot absorb the behaviour.

That constraint points at the Assayer. This repository already has
`/harness-audit` (does HARNESS.md match reality), `/governance-audit` (have
constraints drifted from intent) and `/reflect` (what did we learn). A new agent
that reads the same artifacts and produces a prioritised list of improvements is
one plausible reading away from being a fourth of those.

**The distinction that makes it a separate agent:** those three audit *rules
that already exist*. The Assayer governs *the act of changing one* — it produces
the evidence-bearing proposal that a Harness Decision Record is built from, and
nothing else in the plugin produces that.

**The distinction is enforced, not asserted.** A finding that `/harness-audit`,
`/governance-audit` or `/reflect` already reports is not a finding; it is a
**rejected candidate**, recorded with the existing owner named. The report has a
mandatory section for exactly this, and an assay that never rejects anything on
those grounds is an assay that has stopped checking.

## 5. The evidence pool

Per the epic's resolution of §14 Q1: durable artifacts **plus** cadence sentinel
findings.

| Source | What it carries | Typical flag |
| --- | --- | --- |
| `HARNESS.md`, `AGENTS.md`, agent files | The intended workflow | `observed` |
| `harness/decisions/`, `harness/enforcement-report.md` | Rules in force, and which are merely written down | `observed` |
| Prior assays in `harness/assay/` | What was already found, and what was rejected | `observed` |
| `REFLECTION_LOG.md`, `reflections/` | What people noticed at the time | `reported` |
| `docs/superpowers/objections|consultations|stories|slices` | Dispositions at the decision gates | `observed` |
| `docs/superpowers/parked/` — Coda parking records | Threads that stopped and why | `observed` |
| Mast boundary notes, WIP and reservoir observations | What fired, and when | `observed` when the store exists |
| `git log` | What actually landed, and in what order | `observed` |

**Absent sources are absent, not empty.** The Mast note store is per-machine and
gitignored; on another machine it does not exist. The Assayer says so rather
than reporting zero boundary events, because "nothing fired" and "nothing was
recorded here" are different facts and only one of them is evidence.

No new telemetry is collected. Everything above already exists.

## 6. Procedure

1. **Read-only discovery.** The live repository is the source of truth. Do not
   import assumptions from other projects, and do not carry findings forward
   from a prior assay without re-observing them.
2. **Reconstruct the intended workflow**, then **reconstruct what actually
   happened**, keeping the two separate and written down separately. The gap
   between them is where findings live; collapsing them early is how an assay
   ends up describing the process rather than the work.
3. **Apply the materiality test.** A finding is material only if omitting it
   could change scope, cause repeated discovery, affect an interface or
   ownership boundary, change acceptance criteria or required verification,
   affect security, privacy, reliability, observability or recovery, or hide a
   blocker, assumption or accepted limitation.
4. **Classify each material finding** by ownership, using the S0 taxonomy, and
   state whether the proposed remedy would be advisory or mechanically enforced.
5. **Return the report** and stop. No HDRs, no governance edits, no
   forward-testing, no commits.

## 7. The report

Written to `harness/assay/<ISO8601>-assay.md` by the command. Frontmatter and
the `## Findings` section conform to the **S1 assay-finding contract**, which
this slice consumes rather than redefines.

Sections, in order:

1. **Executive summary** — effectiveness, and the single most important
   opportunity
2. **What worked** — evidence-backed practices worth preserving
3. **What created friction** — problem, impact, evidence
4. **Findings** — the contract: id, observation, metadata block, proposed rule,
   cost estimate. Plus, per finding, the overfitting risk and the validation
   plan
5. **Rejected candidates** — with the existing owner that should absorb the
   behaviour instead
6. **Unresolved questions** — what needs a human, including every finding where
   evidence conflicted

### 7.1 `no-change` is a live option, structurally

A `no-change` finding is a first-class outcome, and an assay where every finding
resolves to `no-change` is a **successful** assay.

The report template makes this structural rather than encouraged: the Findings
section is not permitted to be empty, and `no-change` is a valid classification
in the contract. An assay with nothing to say records that it had nothing to
say, and that record is evidence the next assay reads.

### 7.2 Every proposal declares its burden

`#### Cost estimate` is required by the contract, and it is not decoration: it
becomes the HDR's `proposed_cost`, which is the exact text the S0 validator
compares the approver's own words against and refuses when they match.

An Assayer that writes a vague cost estimate weakens that check. Say what the
rule will demand of whoever works here next.

## 8. `lint-assay` — the deterministic half

`harness-registrar.py lint-assay --assay <path>` parses **every** finding in an
assay and reports every contract violation.

This is the counterpart to S1's lazy parse. `/harness-propose` parses one
finding at a time so that a single malformed block costs one finding rather than
the whole report; `lint-assay` is eager, because at write time the question is
whether the *document* is well-formed.

Without it, a malformed finding surfaces days later as a confusing
`/harness-propose` failure against an append-only record nobody may edit. The
`/harness-assay` validation checkpoint becomes mechanical instead of instructed.

**Deliberately not a CI gate.** An assay is an append-only record of what an
agent observed at a moment; failing the build retroactively over one malformed
block would pressure someone to edit a record, which is the one thing the
append-only rule forbids. Evidence-reference resolution belongs to S4's
`/harness-check`, where a superseding record is the remedy.

## 9. Acceptance criteria

| ID | Criterion |
| --- | --- |
| A1 | `harness-assayer.agent.md` carries `role: sentinel` and no `Write`/`Edit`, and passes `sentinel-integrity-check.sh` |
| A2 | The agent appears in all three sentinel rosters, derived rather than pinned |
| A3 | An explanation page declares `sentinels: harness-assayer`, satisfying docs coverage |
| A4 | The usage path resolves: command documented, how-to guide exists, `agents.md` entry names the command |
| A5 | `lint-assay` accepts a conforming assay |
| A6 | `lint-assay` reports **every** malformed finding in one pass, not just the first |
| A7 | `lint-assay` names the specific defect: missing observation, missing metadata key, missing or duplicated rule block, empty cost estimate |
| A8 | A seeded fixture assay round-trips: `lint-assay` passes it, and `/harness-propose` produces a valid HDR from each finding |
| A9 | The agent and command both state the honesty rule and the anti-proliferation rule |
| A10 | Forward-tested in fresh contexts against a seeded repository — see §10 |

## 10. Forward-testing, and why structural validation is not enough

The build spec is explicit: *"Forward-test Phase 3 in fresh, independent
contexts with realistic artifacts, without revealing the seeded defect, and
check both positive and negative triggering. Structural validation alone does
not constitute evidence that the Harness Assayer works."*

That is right, and it is the honest position for this slice. Everything S0–S2
shipped could be proven by a deterministic test. This cannot: the Assayer's
output is a judgement, and a test suite that asserts the agent's file contains
the right paragraphs proves only that the paragraphs are there.

**This slice therefore ships the fixture and the protocol, and the forward test
is run explicitly.**

`tdad_tests/fixtures/assay_seed/` is a small repository with a realistic
workflow history and a **seeded defect** — a build log recording an integration
suite that was planned twice and never run, alongside a phase completion claim.
The protocol:

- **Positive triggering** — a fresh context, given only the fixture and
  `/harness-assay`, identifies the unevidenced completion claim, classifies it
  correctly, proposes a bounded rule, and writes nothing outside
  `harness/assay/`.
- **Negative triggering** — a second fixture variant with the defect removed
  must **not** produce that finding. An agent that reports the seeded defect
  whether or not it is present has learned the report, not the repository.
- **The defect is never named in the prompt.**

The negative case is the one worth insisting on. A forward test that only checks
the agent finds the planted thing rewards a confident guesser, and confident
guessing is exactly the failure the honesty rule exists to prevent.

## 11. Rejected alternatives

**Granting the Assayer `Write` scoped to `harness/assay/`.** Not possible —
frontmatter tools are all-or-nothing — and not desirable: the same grant would
let it rewrite `HARNESS.md`.

**Dropping `role: sentinel` so it can write.** Rejected. The read-only boundary
is the only mechanical guarantee that a diagnosing agent cannot legislate, and
it is enforced by CI. Trading it for a convenience the command already provides
would be trading the enforceable half of the design for the unenforceable half.

**Folding the Assayer into `/harness-audit`.** Rejected per §4, but not
casually: the auditor checks whether declared enforcement matches reality, and
its output is a status, not a proposal with evidence and a classification. The
overlap is real and is managed by the rejected-candidates rule rather than
denied.

**Making `lint-assay` a CI gate.** Rejected per §8 — it would pressure someone
to edit an append-only record.

**Structural tests alone.** Rejected per §10. They would let this slice claim
completion on evidence that cannot support it, which is the failure the
Assayer's own honesty rule is about.
