# AI Literacy Assessment — ai-literacy-superpowers

**Date:** 2026-08-25
**Assessed by:** assessor agent (via `/assess`), single-context scan
**Placement mode:** evidence-first (ALCI Part D axes placed from scan, two
resolved by clarifying question)
**Previous assessment:** 2026-05-11 (106 days prior)

## Observable Evidence

### Habitat document discovery

All three habitat documents present at conventional root paths. No
alternative-path candidates exist, so no ambiguity to resolve.

| Document | Lines | Markers confirmed |
| --- | --- | --- |
| `HARNESS.md` | 1189 | Context, Constraints, Garbage Collection, Status (4/4) |
| `AGENTS.md` | 544 | STYLE, GOTCHAS, ARCH_DECISIONS (3/3) |
| `CLAUDE.md` | 314 | branch rule, PR workflow, commit messages (3/3) |

### Repository Signals

**Found:**

- **19 CI workflows**, 11 of them blocking PR gates implementing HARNESS.md
  constraints: `harness.yml` (8 deterministic constraints), `tdad-tests-fast.yml`
  (Layers 0+1 with a macOS leg for BSD-coreutils parity), `spec-first-check.yml`,
  `version-check.yml` (5 version locations), `convention-parity-check.yml`
  (heading *and* enumeration-body parity), `objection-taxonomy-check.yml`,
  `consultation-disposition-check.yml`, `dynamic-workflows-firewall.yml`
  (INV-1/INV-2 on agent topology), `docs-reference-parity-check.yml`,
  `marketplace-docs-coverage-check.yml`, `spec-redaction-marker-check.yml`.
  Action SHAs pinned to full commit hashes with version comments.
- **132 TDAD scenarios** — 81 structural, 40 behavioural, 10 trigger, 1 finding
  — across 20 pytest modules and ~50 Layer-0 bash scripts. 150 tests green,
  zero failures, verified during the same-day `/harness-audit`.
- **Secret and shell scanning**: gitleaks 8.30.1 on two paths (PR gate + weekly),
  clean across 611 commits; ShellCheck 0.11.0, `bash -n`, strict-mode sweeps.
- **42 skills, 22 agents, 39 commands**, and **18 hook scripts** across four
  events — including a `type: prompt` hook that LLM-judges commit-scope
  constraints and must quote both the HARNESS heading and the offending line.
- **Orchestrator safety gates**: `MAX_REVIEW_CYCLES = 3` with explicit
  STOP-and-escalate, four hard gates (Slice, Objection, Plan, Integration) and
  two soft gates.
- **97 specs, 24 plans, 51 objection records, 14 choice-story records**,
  465 objections by severity (19 critical / 176 high / 203 medium / 58 low).
- **Governed evolution loop**: `harness/decisions/` (6 records, 1 rule in force),
  `harness/assay/` (3 assays + errata), `enforcement-report.md`, `surfaces.yaml`.
- **11 health snapshots**, 2026-04-06 → 2026-08-25, at a declared 30-day cadence.
- **Three mirrored tool surfaces** (`.cursor/`, `.windsurf/`,
  `.github/copilot-instructions.md`) generated from HARNESS.md and gated at
  36/36 constraints plus 3 enums / 45 member checks.

**Not found:**

- Coverage enforcement — no `--cov`, no threshold, no gate in any workflow.
- Mutation testing — declared N/A in the current snapshot (no application code).
- Dependabot, `govulncheck`, Docker Scout in this repo's own CI. Skills for
  dependency and container auditing exist as capabilities shipped to consumers
  but are not self-applied.
- Deployed telemetry. All 14 OTel hits are documentation; the snapshot's own
  words are "telemetry still unwired".
- Layer 2/3 CI execution — deliberately excluded for API cost.

### Evidence Summary

The apparatus is unusually complete and, in several places, ahead of what the
practice currently exercises. The defining characteristic of this repository is
not the volume of governance machinery but the quality of its self-observation:
the same-day audit indicted the command performing it, and the current snapshot
retro-diagnoses its own predecessor for reporting "GC effectiveness: quiet" the
day after the job had begun failing.

## Clarifying Responses

Four questions were asked. Answers are recorded with the confidence flag this
repository's sentinel agents already use.

| Question | Answer | Flag |
| --- | --- | --- |
| Are TDAD Layers 2/3 run on any cadence? | Weekly, manually | `asked` |
| What is read between snapshots? | The monthly snapshot is the only thing anyone reads | `asked` |
| Who operates this habitat? | Mostly one person; this repo is the whole practice | `asked`, corroborated by 696/700 commits |
| Is the objection/story gap selective or slippage? | Historical slippage, not worthy of historical redress | `asked` |

The fourth answer is recorded deliberately. 37 in-scope specs have no objection
record and 52 have no choice-story record; without this statement a later
assessor reads that as neglect. It is a closed historical gap, not a live
practice failure, and the recommendation below reflects that.

## Level Assessment

### Primary Level: 4 — Governed Collaboration

The habitat is governed by design and the governance is largely mechanical. All
three disciplines sit at L4, and the ceiling is set not by weakness but by
scope: L5 markers are organisational, and this is a single-operator practice.

### Discipline Maturity

| Discipline | Level | Evidence |
| --- | --- | --- |
| Context engineering | 4 | 1189-line HARNESS.md with Context, Constraints, GC and Status; AGENTS.md compound learning with 56 active reflection fragments; three generated tool mirrors under parity CI at 36/36 plus enumeration-body parity |
| Architectural constraints | 4 | 36 active constraints, 25 deterministic, 11 blocking PR gates; documented unverified → agent → deterministic promotion ladder, used; intended-vs-achieved enforcement reporting per rule × surface |
| Guardrail design | 4 | Orchestrator with four hard gates and `MAX_REVIEW_CYCLES = 3`; INV-1/INV-2 firewall on agent topology enforced by the same matcher its Layer-0 test exercises; 18 hooks across four events; read-only sentinel agent tier |

### The Weakest Discipline

None of the three is materially weaker than the others, which is itself the
finding. The binding constraint is **dispatch, not design**: ten agent-enforced
constraints have no automated path, so a third of the declared constraint set
cannot fail a build. That deficit is spread evenly across all three disciplines
rather than concentrated in one, which is why the level does not drop.

L5 is unreachable on scope rather than quality. Its markers — conventions that
hold when someone else writes the code, governance binding an author who did not
design it, drift caught by someone other than its author — cannot be evidenced
by a single-operator practice at any level of rigour.

## Operational Axes (ALCI Part D)

| Axis | Level | Evidence |
| --- | --- | --- |
| Composition | 4 | 22 agents including a read-only critic tier; orchestrator composes a bounded ensemble with four hard gates and a cycle guardrail; topology constrained mechanically by `dynamic-workflows-firewall.yml`; routing declared in `MODEL_ROUTING.md`. Not L5 by deliberate design — the gates exist to keep a human in the composition loop |
| Testing | 4 | `tdad-scenario-check.yml` enforces scenario-before-merge and rejects `tier: finding` as non-falsifiable; 132 scenarios; 150 tests green; cross-OS Layer-0 matrix. Layers 2 and 3 (50 scenarios) run weekly by hand — flagged `asked`, since no artifact evidences the cadence. Issue #583 would convert it to `observed` |
| Observability | 3 | Snapshots at a declared 30-day cadence, read and acted on; the current snapshot performs genuine perception-reality calibration against its predecessor. Held at 3 rather than 4 because the instrumentation does not exist: snapshots are agent-authored from repository greps, both dashboards are 106 days stale and unread, `events.jsonl` holds 2 entries from April, and cost tracking is a single 73-day-old sample with no budget or trend |
| Governance | 4 | 11 blocking policy-as-code gates; 25 of 36 constraints deterministic; promotion ladder documented and used; governed evolution loop with per-surface enforcement reporting, 90-day expiries and provisional flags. Not L5: "every change carries evidence of compliance" is falsified on this repo's own record — 10 constraints undispatched, three currently failing, six of six recent non-exempt PRs shipped without objection or choice-story records |

**Governance Dimension** — placed at **4**, matching the Governance axis, with
the divergence recorded rather than hidden. Harness governance is genuinely L4.
Governance *as a named discipline* is one constraint: `grep 'Governance
requirement' HARNESS.md` returns two hits, one of which is a template
placeholder. The single real one is *Release traceability* (line 216), which the
2026-06-13 audit scored at 0% falsifiability, drift stage 3/5, frame alignment
0%, health **At Risk** — and which is currently failing with six untagged
releases. The number is 4; the caveat is that the governance-tagged subset is
one drifted, failing constraint and is the specific gap to close.

## Habitat Build Gap

```text
Level placement          4.00
Operational axes mean    3.75   (4 + 4 + 3 + 4) / 4
Habitat Build Gap       +0.25
Regime                   |gap| < 0.5  →  Coherent
```

**Interpretation — Coherent.** Ambition and enablement are in line. The habitat
is neither over-claimed (ambition outpacing enablement) nor inherited (tooling
arriving ahead of the practice that would use it). The single axis below the
level placement is Observability, and the gap it opens is a quarter of a level —
within the coherent band.

This is the honest good news of the assessment, and it is earned: the operational
capability was built by the same practice that claims it.

## Strengths

1. **Self-observation that hunts its own false greens.** The 2026-08-25 audit
   reported the command performing it as one of four failing constraints. The
   current snapshot retro-diagnoses its predecessor for reporting a healthy GC
   job the day after it began failing, and names the format defect that made a
   silent job and a green job indistinguishable. It also refuses to fudge a
   count to preserve comparability, stating that a 26 → 22 delta is a change of
   counting basis and that the format reference is what needs correcting.
2. **Governance that refuses the convenient outcome.** In the same window, a
   proposal was reclassified to the layer that owns its behaviour despite that
   classification costing it acceptance at the two-assay threshold; six missing
   release tags were left uncreated on the grounds that creating them would make
   the rule green and the history more wrong; and an objection was deferred
   rather than rejected because the approver was not sure of the answer.
3. **Constraints that are mechanically falsifiable.** 25 of 36 deterministic,
   11 blocking gates, convention parity extended to enumeration bodies after a
   six-value enum was found mirrored as five. The promotion ladder is documented
   and demonstrably used rather than aspirational.

## Gaps

1. **Undispatched verification, in three places.** Ten agent-enforced
   constraints have no CI path (`grep -rn 'harness-enforcer' .github/workflows/`
   returns nothing). Fifty TDAD scenarios have no CI path. The GC job's
   step-masking skipped steps 6–14 for six consecutive weeks. All three are the
   same defect: declared verification with nothing to dispatch it.
2. **The garbage-collection loop is dead.** Six consecutive failing scheduled
   runs since 2026-07-20. Two `Auto-fix: true` rules have been masked behind an
   earlier failure the whole time, leaving six untagged releases and fifteen
   archivable reflection fragments unarchived.
3. **Observability instrumentation does not exist.** Two dashboards, 106 days
   stale and read by nobody; `events.jsonl` dead since April; a single cost
   sample with no budget, no monthly average and no trend. By this repository's
   own newly-in-force rule, an unread dashboard is an artefact that looks like
   assurance and provides none.
4. **The README overstates the level.** It carries `AI Literacy — Level 5`
   pointing at a 106-day-old assessment, beside a `Harness Health — Degraded`
   badge. This is the one place the project's own honesty standard is not met.
5. **Governance as a named discipline is one failing constraint.** Falsifiability
   ratio 0%, drift stage 3/5, health At Risk at the last audit — which is itself
   73 days old.
6. **Single point of failure is a person.** The practice, its cadences and its
   undocumented weekly TDAD run all depend on one operator. Nothing notices if a
   cadence lapses; the GC job demonstrated exactly that failure mode.

## Recommendations

1. **Dispatch what is already declared.** Wire `harness-enforcer` into CI, or
   redeclare the ten agent-enforced constraints as advisory and drop the
   enforcement figure from 35/36 to 25/36. Both are honest; the current state is
   not. This is the highest-value change available and it moves Governance and
   Testing together.
2. **Fix the GC step-masking** (assay 2 finding-2, proposed and currently refused
   at the threshold) or resolve #578, either of which unblocks the release-tag
   and reflection-archival auto-fixes that have been masked for six weeks.
3. **Automate the weekly TDAD Layer 2/3 run** (#583). At $9.89–$35.69 per month
   it converts an `asked` fact into an `observed` one and removes the operator
   from the critical path.
4. **Decide the dashboards.** Wire them into the snapshot cadence or retire them.
   A third option — leaving them stale and unread — is the one the in-force rule
   now argues against.
5. **Correct the README badge to Level 4** and point it at this assessment.
   Applied as an immediate adjustment below.
6. **Run `/governance-audit`** (73 days, approaching the 90-day target) and use
   `/governance-constrain` to move the governance-tagged subset off a single
   drifted constraint.

**Not recommended: backfilling the 37 missing objection records and 52 missing
choice stories.** The approver has recorded this as historical slippage not
worthy of redress. Generating them retrospectively would produce ~89 adjudications
of decisions already shipped — expensive ceremony with no decision attached. The
live practice is what matters, and it is now covered by the constraints that
already exist.

## Immediate Adjustments Applied

Recorded in the commit accompanying this assessment.

- README AI Literacy badge: Level 5 → Level 4, pointed at this assessment
- `HARNESS.md` Status: *Output validation checkpoints* removed from the failing
  list; it was repaired in #577 after the Status block was written

## Next Assessment

Due 2026-11-23 (90-day cadence), which coincides with the expiry of the one rule
currently in force. Both are judgements rather than measurements, and the
retirement test for that rule — whether it fired and protected something,
evidenced in objection dispositions — is the first thing to read.
