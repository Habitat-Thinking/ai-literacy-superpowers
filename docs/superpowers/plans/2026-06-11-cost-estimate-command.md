# Cost Estimation — S3 — `/cost-estimate` command — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship S3 of the cost-estimator capability — the human-facing
**`/cost-estimate` command** at `ai-literacy-superpowers/commands/cost-estimate.md`.
It is the manual dispatcher for the S2 `cost-estimator` agent: it parses a single
target, dispatches the agent, handles a `REFUSED:` output (write nothing), runs an
**Output Validation Checkpoint** against the S1 format reference's checklist
(including the #377 per-stage coupling + split-tier strict-spread lines) under a
**transparency-at-the-disposition-seat discipline** — it fixes only
**structural-only** deviations in place, **records every change** it makes,
**aborts (never authors)** on any derived-value defect, and on the `edit` path
**validates-and-reports** rather than reverting the human's edit — shows a review
summary of the **validated** record (with the change-list and, on a human-asserted
`--kind`, an asserted-not-inferred ceiling flag), asks the human for a disposition
(accept / edit / re-run / abort), and on `accept` performs its **single Write** to
a top-level **`cost-estimates/`** directory (outside `observability/`) —
**downstream of the human disposition** (the dispose-then-write ordering
invariant). Plugin version bumps `0.43.0 → 0.44.0`.

**Revised 2026-06-12** after the spec-mode advocatus-diaboli raised 9 objections,
all accepted (record:
`docs/superpowers/objections/cost-estimate-command-design.md`). The revisions:
checkpoint transparency + structural-fix boundary (O1, O2); edit-path
validate-and-report (O3); `--kind` asserted-ceiling flag (O4); output home moved
outside `observability/` to top-level `cost-estimates/` (O5); absolute-rate check
re-filed with a blocking acceptance criterion (O6); unguarded-sentinel residual
recorded (O7); `re-run` re-reads the snapshot (O8); `--out` collision
disambiguation (O9).

**Round-2 diaboli (2026-06-12):** O1 (collapse checklist row 7 to a clean ABORT),
O3 (gitignore `cost-estimates/` by default + add the `.gitignore` line this slice),
and O4 (bind the absolute-rate check to a concrete slice — S6/#373, extended to own
first-snapshot capture — so the trigger is reachable) are fixed; O5/O6 are
one-line flags (live-checklist-surface note; runnable-today vs synthetic-fixture
split); O2 needs no change.

**This is slice 3 of a six-slice capability.** Upstream (merged on main): S1 (the
skill + `estimate-record-format.md`, incl. the #377 per-stage `cost_usd`
additions) and S2 (#369, the read-only agent). Downstream issues, **none ship
here**: S4 #371 (orchestrator T1/T2 fold-in), S5 #372 (T0 ballpark), S6 #373
(calibration loop). S3 is a **standalone manual surface** — it does **not** wire
into the orchestrator.

**Architecture:** A new command file — the **fifth production instance** of the
AGENTS.md **agent-emit + dispatcher-persist + human-disposes** pattern (after
`advocatus-diaboli`, `choice-cartographer`, `model-card-researcher`, `/diagnose`),
and the first cost-record instance. It mirrors the `model-card create`
dispose-then-write flow (dispatch → handle REFUSED → validate → review summary →
disposition → single Write) and the `/cost-capture` sibling's structure/discipline
(directory creation, mandatory validation step). The command is a **pure
consumer** of the S2 agent and the S1 format reference: it dispatches the agent
as-merged and validates against the format checklist as-merged, mutating neither.

**Tech Stack:** Markdown. No new dependencies, no code.

**Spec reference:** `docs/superpowers/specs/2026-06-11-cost-estimate-command-design.md`

---

## Modules / files touched

```
ai-literacy-superpowers/
├── .claude-plugin/plugin.json                          # MODIFIED: 0.43.0 → 0.44.0
└── commands/
    └── cost-estimate.md                                # NEW — manual dispatcher command
#   NOTE: agents/cost-estimator.agent.md is NOT touched (S2, consumed as-merged).
#   NOTE: skills/cost-estimation/references/estimate-record-format.md is NOT
#         touched — S3 is a pure consumer of the format checklist (incl. #377).

CLAUDE.md                                                # MODIFIED: add /cost-estimate to the Output Validation Checkpoints command list
CHANGELOG.md                                             # MODIFIED: new 0.44.0 entry (repo root, not under the plugin dir)
.gitignore                                               # MODIFIED: add cost-estimates/ (derived, regenerable; matches the /diagnose entry's rationale) (O3, FR-10a)

tdad_tests/scenarios/commands/cost-estimate/
├── command-structure.md                                # NEW — structural (frontmatter; flow order; checkpoint-by-path; structural-fix boundary; disposition vocab; cost-estimates/ default home)
├── writes-record-on-accept.md                          # NEW — behavioural (accept → single Write at cost-estimates/ resolved path; cost-omitted today)
├── dispose-precedes-write.md                            # NEW — behavioural (abort → no file; accept → exactly one Write after disposition)
├── refused-not-persisted.md                             # NEW — behavioural (REFUSED → surfaced verbatim, no checkpoint, no file)
├── checkpoint-fix-boundary.md                           # NEW — behavioural (O1/O2: structural-only fix + change-list; derived-value defect ABORTS, never authors)
├── edit-validate-and-report.md                          # NEW — behavioural (O3: edit path validates-and-reports, never silently reverts the human)
├── checkpoint-377-checks.md                             # NEW — behavioural (#377 coupling + split-tier strict-spread on pinned cost-present/cost-omitted fixtures)
├── empty-snapshot-cost-omitted.md                       # NEW — behavioural (empty costs/ → written cost-omitted record, not refusal; trailing-slash summary; unguarded-sentinel residual)
├── kind-assertion-flag.md                               # NEW — behavioural (O4: --kind asserted → asserted-not-inferred summary flag; no --kind → inference-basis line)
├── rerun-rereads-snapshot.md                            # NEW — behavioural (O8: re-run re-dispatches and re-reads now-populated observability/costs/)
└── signature-targets.md                                 # NEW — behavioural (path vs inline; --kind forwarded; --out overrides dir + collision disambiguation, O9)

docs/plugins/ai-literacy-superpowers/
├── how-to/estimate-cost-of-a-task.md                   # NEW — how-to guide (runnable command)
└── reference/cost-estimate-command.md                   # NEW — command reference (signature, targets, cost-estimates/ output path, checkpoint)

.claude-plugin/marketplace.json                          # MODIFIED: entry version + plugin_version 0.43.0 → 0.44.0
README.md                                                # MODIFIED: plugin badge 0.43.0 → 0.44.0
```

Top-level marketplace `version` stays at `0.4.0`. No agent, skill, format
reference, or orchestrator file touched.

**Plus a re-filed tracking issue (not a file in this PR):** the #377-deferred
**absolute-rate check** is re-filed as a standalone GitHub issue
("estimate-record absolute-rate validation — snapshot-grounded per-stage cost
falsification") per the AGENTS.md natural-home-hand-off decision, **bound to a
concrete slice number: a BLOCKING required deliverable of S6/#373**. S6 is extended
to also own **first-snapshot capture** so the trigger is reachable — S6 both
captures the first `observability/costs/` snapshot and consumes it in the
calibration loop, making it the slice under which the first falsifiable cost-present
record exists (the earlier "first slice that produces a cost-present record" wording
was unreachable because no scheduled slice produced that event — O4) (spec §7.2,
O6, O4).

---

## Algorithm / key decisions (not pseudocode)

- **Dispatcher-persist + dispose-then-write ordering (load-bearing).** The
  command owns the **single Write**; the human disposition **precedes** it. The
  flow order is fixed: parse → dispatch agent → handle REFUSED (no write) →
  Output Validation Checkpoint → review summary → ask disposition
  (accept/edit/re-run/abort) → **on accept, write once**. Nothing is persisted
  until `accept`. This is the AGENTS.md ordering invariant honoured as **ordering**,
  not merely the agent/command tool split (spec §5, FR-8/FR-9).
- **Full disposition vocabulary (accept/edit/re-run/abort).** Ship the full named
  vocabulary, not the narrowed accept/abort `/diagnose` used — the AGENTS.md watch
  item flags that narrowing as a divergence to avoid recurring (spec §5 step 6,
  FR-8).
- **Checkpoint runs BEFORE the disposition.** Resolves the model-card "validate
  between accept and write" ambiguity: the human disposes over a **validated**
  record, then the Write follows `accept`. The checkpoint references the S1 format
  reference **by path** and implements **every** checklist line incl. the #377
  per-stage coupling and split-tier strict-spread checks; never re-dispatches
  (spec §5 step 4, §7.1, FR-6/FR-7).
- **Checkpoint transparency + structural-fix boundary (O1, O2 — load-bearing).**
  The checkpoint fixes only **STRUCTURAL-ONLY** deviations in place (routinely
  only the removal of a stray `recommendation`/`verdict`/`proceed` field — a pure
  removal that authors nothing) and **records every change** it makes, surfacing it
  in the review summary's change-list so the human disposes over a transparent
  agent-content-vs-command-content composite. It **ABORTS, never authors**, on any
  deviation that would create or alter a **derived value** — a missing `cost_basis`
  on a cost-present record (inventing provenance), a `low > high` range, a missing
  disclosure section, a per-stage-coupling violation, a collapsed split-tier band,
  an over-ceiling confidence axis, an imperative-recommendation prose hit. The
  earlier "insert a missing `cost_basis`" example is **removed** — it inverted the
  rule. The per-checklist-line fix-vs-abort table is in spec §7.1a (spec §5 step 4,
  §7.1a, FR-6/FR-6a).
- **Edit path is validate-and-report, never silent-revert (O3).** Step-4
  fix-in-place applies to the **agent's fresh output**. On the `edit` disposition
  the content is the **human's**: the post-edit checkpoint **validates and
  reports** remaining deviations but does not apply fix-in-place — a human edit is
  never reverted without the human seeing and re-confirming it. The human is the
  final author on the edit path (spec §5 step 6, §7.1b, FR-6b).
- **`--kind` asserted-ceiling flag in the review summary (O4).** An explicit
  `--kind` suppresses the agent's inference-basis line *and* raises the
  `tokens`/`time` confidence ceiling. The command (which owns the summary, not the
  classification) carries the disclosure the suppressed line would have: when
  `target_kind` was human-asserted via `--kind`, the summary flags it
  **asserted-not-inferred** with a raised ceiling and no agent inference basis, so
  the human re-confirms the ceiling raised; when agent-inferred, the summary carries
  the agent's inference-basis line as emitted (spec §4.1, §5, FR-8a).
- **`re-run` re-reads the snapshot (O8).** `re-run` is a **full fresh dispatch**
  that re-reads the grounding sources, including the now-populated
  `observability/costs/`, so add-a-snapshot-then-re-run works as described (spec
  §5 step 6, FR-8b).
- **Pure consumer of S2 + S1 — mutates neither.** The command dispatches the S2
  agent as-merged (does not re-implement methodology or re-classify `target_kind`)
  and validates against the format checklist as-merged (inlines no field/checklist
  definition, adds no checklist line). A genuine contract need would be a separate
  owning slice, never folded into this consumer (spec §2.3, FR-4/FR-7).
- **Signature: one target, `--kind`, `--out`.** `/cost-estimate <target>
  [--kind <target-kind>] [--out <dir>]`. `--near` is **dropped** (the S2 agent
  accepts exactly one target per dispatch — no second "nearby" target); `--kind`
  is the disambiguation affordance, forwarded to the agent as the explicit
  dispatch-stated kind (the agent's rule-1 path). The command distinguishes path
  vs inline text by filesystem resolution; it does **not** itself classify the
  `target_kind` (spec §4, FR-2/FR-3/FR-4).
- **REFUSED handling.** A `REFUSED:`-prefixed agent output is surfaced verbatim;
  no checkpoint runs and no file is written; the flow aborts. The dispatcher half
  of the S2 refusal convention (spec §5.1, FR-5).
- **Empty cost snapshot is NOT a refusal.** Per the S1 three grounding states, an
  empty `observability/costs/` yields a valid **cost-omitted** record, which the
  command validates, summarises, and (on accept) writes. The command never treats
  a cost-omitted record as a failure (spec §5.2, FR-13).
- **Output path: top-level `cost-estimates/`, OUTSIDE `observability/` (O5).**
  Default `cost-estimates/<YYYY-MM-DD>-<target-slug>-estimate.md` — a new top-level
  directory deliberately **outside** the `observability/` telemetry/actuals tree,
  so a forward-looking prediction is never co-located with captured actuals where
  a future scan could read it as fact. **What was checked:** every current
  `observability/` consumer — `harness-health.md` (reads `observability/costs/*-costs.md`
  + `observability/snapshots/*-snapshot.md`), `cost-capture.md`
  (`observability/costs/*-costs.md`), `observatory-verify.md` + the observatory
  signal checklist (named subdirs, specific filename patterns, no `estimates/`
  signal source), and the hook scripts — reads **named subdirectories by specific
  filename patterns, not the tree wholesale**, so none would aggregate an
  estimates sibling today; moving the home outside `observability/` removes the
  conflation at the source rather than relying on a marker a future tree-wide scan
  could miss. `--out` overrides the **directory** only (derived filename preserved,
  mirroring `model-card create`); `mkdir -p` on write; same-day slug collision
  disambiguated and noted in the summary **under both** the default and `--out`
  (O9) (spec §6, FR-10/FR-11/FR-11a/FR-12).
- **`cost-estimates/` gitignored by default (O3).** Estimate records are
  **derived, regenerable** predictions referencing moving targets (an unmerged
  spec, a since-renamed slice) — the same artefact-kind the repo already gitignores
  for the `/diagnose` output (`diagnostic-legibility/output/`). This slice adds a
  `cost-estimates/` line to `.gitignore` with a comment matching that entry's
  "derived, regenerable artefacts … Never committed" rationale. The staleness
  concern is moot — a regenerable artefact, not a committed corpus (spec §6.1,
  FR-10a).
- **Grounding-path trailing-slash special-case — honoured in the command's OWN
  summary, NOT as a new checklist line.** The command tests the trailing slash
  when it reports "grounded in a snapshot?" in the review summary, reporting a
  `cost-snapshot` entry whose `path` ends in `/` as "no snapshot — cost omitted",
  not a grounding. It adds **no** checklist line keying on
  `grounding_sources[].path` shape (that would be a consumer mutating the
  contract). S3 is itself a downstream consumer, so it must not be the consumer
  that miscounts. **Residual recorded (O7):** S3 ships the first persisted estimate
  records and every cost-omitted one carries the **unguarded** trailing-slash
  sentinel (no checklist line keys on it), so any other consumer (S4/aggregators)
  that does not apply the same trailing-slash test will silently miscount — a known
  failure named in the spec, not left to cartographer archaeology (spec §7.3,
  FR-14/FR-14a).
- **#377-deferred absolute-rate check — DEFER FURTHER, recorded + re-filed with a
  COMMITTED home (O6).** S3 does **not** build the snapshot-grounded absolute-rate
  falsification check: it is dead against today's cost-omitted-only records,
  materially different (re-reads the snapshot, recomputes per-model $/token, needs
  its own adversarial pass on tolerance/re-derivation), and YAGNI against a
  closed-world record set. Recorded reason in the spec; **re-filed as a standalone
  tracking issue bound to a concrete slice number — a BLOCKING required deliverable
  of S6/#373**. The earlier "first slice that produces a cost-present record"
  trigger was unreachable: no scheduled slice produced that event (O4). Fixed by
  **extending S6 to also own first-snapshot capture** — S6 both captures the first
  `observability/costs/` snapshot and consumes it in the calibration loop, so it is
  the slice under which the first falsifiable cost-present record exists. This makes
  the hand-off a committed home bound to a named slice, not a precondition the
  roadmap never causes (spec §7.2, FR-15; O6, O4).
- **Joins the Output Validation Checkpoints discipline.** `/cost-estimate` is added
  to the CLAUDE.md Output Validation Checkpoints command list (spec §7.4, FR-16).
- **Behavioural grading by deterministic oracles.** The behavioural scenarios ride
  a non-deterministic `model: inherit` agent dispatch, so they grade **on-disk
  outcome properties**: file-exists-at-`cost-estimates/`-resolved-path on accept /
  no-file on abort-or-REFUSED; frontmatter conformance parse; the #377 coupling +
  split-tier-spread checks on pinned fixtures; the trailing-slash summary
  reporting; the **structural-fix-boundary** oracle (stray-verdict-field → removed
  + change-listed; missing-`cost_basis` → ABORT, no `cost_basis` authored, no
  file); the **edit-validate-and-report** oracle (human edit preserved, not
  silently reverted); the **`--kind` assertion-flag** oracle (asserted →
  asserted-not-inferred summary flag; inferred → inference-basis line). Never exact
  numbers or prose wording. A scenario no oracle can grade is descoped (spec §9,
  FR-17).

---

## FR mapping table

| FR | Requirement (abbrev) | Covering test case(s) |
| --- | --- | --- |
| FR-1 | Command file present; well-formed frontmatter | `command-structure.md` (structural) |
| FR-2 | Signature `<target> [--kind] [--out]`; `--near` absent; `--kind` enum | `command-structure.md` + `signature-targets.md` |
| FR-3 | One target per invocation; path vs inline by FS resolution | `signature-targets.md` |
| FR-4 | Dispatches S2 agent; forwards `--kind`; no re-classify/re-implement | `command-structure.md` + `signature-targets.md` |
| FR-5 | REFUSED → surfaced verbatim, no checkpoint, no file, abort | `refused-not-persisted.md` |
| FR-6 | Checkpoint runs full checklist incl. #377 coupling + split-tier spread; structural-only fix; abort-never-author on derived defects | `checkpoint-fix-boundary.md` + `checkpoint-377-checks.md` |
| FR-6a | Checkpoint surfaces a change-list of exactly what it altered (O1) | `checkpoint-fix-boundary.md` |
| FR-6b | Edit path validate-and-report, never silent-revert (O3) | `edit-validate-and-report.md` |
| FR-7 | Checkpoint references format reference by path; no inline/mutation | `command-structure.md` + `checkpoint-377-checks.md` |
| FR-8 | Review summary + disposition (accept/edit/re-run/abort) BEFORE write | `command-structure.md` + `dispose-precedes-write.md` |
| FR-8a | `--kind` asserted → asserted-not-inferred ceiling flag in summary (O4) | `kind-assertion-flag.md` |
| FR-8b | `re-run` re-dispatches + re-reads now-populated `observability/costs/` (O8) | `rerun-rereads-snapshot.md` |
| FR-9 | Single Write, on accept, downstream of disposition | `dispose-precedes-write.md` + `writes-record-on-accept.md` |
| FR-10 | Default path `cost-estimates/<date>-<slug>-estimate.md` (outside observability/); mkdir -p | `writes-record-on-accept.md` |
| FR-10a | `cost-estimates/` gitignored by default (derived, regenerable) — add the `.gitignore` line in this slice (O3) | local check (Task 5a) |
| FR-11 | `--out` overrides directory; derived filename preserved | `signature-targets.md` |
| FR-11a | Same-day collision disambiguation under default AND `--out`; never silent overwrite (O9) | `signature-targets.md` |
| FR-12 | Resolved path shown in summary (confirm content + destination) | `dispose-precedes-write.md` |
| FR-13 | Empty costs/ → written cost-omitted record, not failure | `empty-snapshot-cost-omitted.md` + `writes-record-on-accept.md` |
| FR-14 | Trailing-slash special-case honoured in command's own summary; no new checklist line | `empty-snapshot-cost-omitted.md` |
| FR-14a | Unguarded-sentinel residual recorded for S4/aggregators (O7) | (no S3 test — recorded residual; spec §7.3) |
| FR-15 | Absolute-rate check deferred further; recorded + re-filed **bound to S6/#373** (a concrete slice number) which is extended to own first-snapshot capture so the trigger is reachable (O6, O4) | (no S3 test — re-filed issue; spec §7.2) |
| FR-16 | `/cost-estimate` added to CLAUDE.md checkpoint list | local check (Task 4) |
| FR-17 | TDAD structural + behavioural scenarios present, deterministic oracles | all scenario files exist |
| FR-18 | Version bump 0.44.0 across four locations | local version-consistency check (Task 6) |
| FR-19 | How-to guide + reference entry ship | docs check (Task 5) |

---

## Test case list

(In the same form as the existing TDAD command/agent scenario corpus —
`Given/When/Then` markdown scenarios under
`tdad_tests/scenarios/commands/cost-estimate/`. The structural scenario is Layer 1
($0, every PR); the behavioural scenarios are Layer 3 (nightly + label-gated),
graded by the deterministic oracle strategy of spec §9 so they fail honestly
against a non-deterministic dispatch. One structural + ten behavioural = eleven
scenarios (the revision added `checkpoint-fix-boundary.md`,
`edit-validate-and-report.md`, `kind-assertion-flag.md`, and
`rerun-rereads-snapshot.md`, and split the old `checkpoint-validates-record.md`
into the fix-boundary scenario plus `checkpoint-377-checks.md`). **No S2 agent or
S1 format scenario is modified** — S3 is a pure consumer.)

- `command-structure.md` (tier: structural) — frontmatter well-formed
  (`name: cost-estimate`, description); the process documents the order dispatch →
  REFUSED-handling → checkpoint → review-summary → disposition → write with the
  disposition **before** the write; the checkpoint section references
  `estimate-record-format.md` by path and enumerates the checklist lines incl. the
  #377 per-stage coupling + split-tier strict-spread, and documents the
  **structural-fix boundary** (fix structural-only + record; abort-never-author on
  derived defects); the disposition vocabulary is accept / edit / re-run / abort;
  the signature is `<target> [--kind <target-kind>] [--out <dir>]` with no `--near`;
  the default home is top-level `cost-estimates/` (outside `observability/`).
- `writes-record-on-accept.md` (tier: behavioural) — dispatched against a real
  spec target with `MODEL_ROUTING.md` readable and `observability/costs/` empty;
  on `accept`, exactly one file is written to
  `cost-estimates/<date>-<slug>-estimate.md`; the written record parses
  to the S1 field set; cost omitted with the `Excluded` disclosure; the full path
  is confirmed. Graded by file-existence + conformance oracles.
- `dispose-precedes-write.md` (tier: behavioural) — at the disposition step no
  file exists yet and the resolved output path is shown in the summary; `abort` →
  no file written; `accept` → exactly one Write, to the resolved path, **after**
  the disposition. Graded by file-existence oracle (no-file-before-accept;
  no-file-on-abort; one-file-on-accept).
- `refused-not-persisted.md` (tier: behavioural) — an ungroundable fixture
  (unreadable target / absent or tableless `MODEL_ROUTING.md`) yields a `REFUSED:`
  agent output; the command surfaces it verbatim, runs no checkpoint, writes no
  file, and aborts. Graded by REFUSED-prefix + no-file oracles.
- `checkpoint-fix-boundary.md` (tier: behavioural, O1/O2) — a fixture with a
  **stray `verdict` field** (structural-only) is fixed in place by deletion AND the
  review summary's change-list names the deletion; a fixture where the checkpoint
  changes nothing yields a "no checkpoint changes" summary; a **cost-present
  fixture missing `cost_basis`** (derived-value defect) **ABORTS without writing**
  and **no `cost_basis` is authored**; a `low > high` range fixture likewise
  aborts. Graded by the structural-fix-boundary oracle (field-removed +
  change-listed; no-file + no-authored-field on derived defects).
- `edit-validate-and-report.md` (tier: behavioural, O3) — on the `edit` path the
  human edit is preserved (not silently reverted) and any remaining deviation is
  **reported** in the re-prompt; the post-edit checkpoint does not apply
  fix-in-place to human-edited content. Graded by the edit-validate-and-report
  oracle (edited value preserved; deviation surfaced, not auto-fixed).
- `checkpoint-377-checks.md` (tier: behavioural) — a cost-present fixture with a
  split-tier (`model_tier` contains `/`) per-stage band with `low == high`
  **fails** the split-tier strict-spread check; a non-collapsed band
  (`low < high`) **passes**; a per-stage band on a cost-omitted record **fails**
  the coupling check; a record with no per-stage bands passes both vacuously.
  Graded by the #377-check oracle on pinned fixtures.
- `empty-snapshot-cost-omitted.md` (tier: behavioural) — empty
  `observability/costs/` yields a written **cost-omitted** record (NOT a refusal)
  at `cost-estimates/<date>-<slug>-estimate.md`; the `cost-snapshot` grounding
  entry's path is the directory `observability/costs/` (trailing slash); the review
  summary reports it as "no snapshot — cost omitted (directory inspected, no
  snapshot found)", not a snapshot grounding; the written record carries the
  **unguarded trailing-slash sentinel** (no checklist line keys on it — the
  recorded O7 residual); cost_usd / cost_basis omitted with the `Excluded`
  disclosure; tokens / agent_compute_time ranges present; human_gate_time the
  qualitative caveat string. Graded by conformance + trailing-slash-summary
  oracles.
- `kind-assertion-flag.md` (tier: behavioural, O4) — `--kind spec` on a
  slice-fragment target yields a review summary flagging `target_kind` as
  **human-asserted (not agent-inferred)** with the raised ceiling and no inference
  basis; with no `--kind`, the summary carries the agent's inference-basis line.
  Graded by the `--kind` assertion-flag oracle.
- `rerun-rereads-snapshot.md` (tier: behavioural, O8) — after a cost-omitted first
  dispatch (empty `observability/costs/`), adding a usable snapshot and responding
  `re-run` re-dispatches the agent, which re-reads the now-populated
  `observability/costs/`; the re-summarised record can carry `cost_usd` grounded in
  the added snapshot. Graded by the re-dispatch-re-reads oracle (cost-present after
  snapshot-add-then-re-run).
- `signature-targets.md` (tier: behavioural) — a positional target that resolves
  to a readable file is passed as a path; one that does not resolve is passed as
  inline task text; `--kind spec` is forwarded to the agent as the explicit
  dispatch-stated kind; `--out <dir>` writes the derived
  `<date>-<slug>-estimate.md` filename beneath `<dir>`, exactly one file, full path
  confirmed; a same-day same-slug collision under `--out` is disambiguated, never
  silently overwritten (O9). Graded by path-vs-inline routing + file-at-overridden-
  dir + collision-disambiguation oracles.

---

## Phase 1 — The command

### Task 1: Write the `/cost-estimate` command

- [ ] Create `ai-literacy-superpowers/commands/cost-estimate.md`.
- [ ] Frontmatter: `name: cost-estimate`; a `description` (prospective sibling of
  `/cost-capture`; estimate a target's tokens/time/cost before it runs; dispatches
  the read-only `cost-estimator` agent, validates, and persists after a human
  disposes).
- [ ] Body sections (mirroring `/cost-capture` discipline + `model-card create`
  dispose-then-write flow):
  - **Usage / signature** — `/cost-estimate <target> [--kind <target-kind>]
    [--out <dir>]`; one target per invocation; the four target types; path vs
    inline resolution; `--kind` as the agent's explicit-kind hint **and the
    review-summary asserted-ceiling consequence (O4)**; `--out` as the directory
    override with collision disambiguation (spec §4, §6.2; FR-2/FR-3/FR-11/FR-11a).
  - **1. Parse args & resolve target** — distinguish path vs inline text; capture
    `--kind`, `--out` (FR-3).
  - **2. Dispatch the cost-estimator agent** — one target, explicit `--kind` if
    supplied, resolved model id if known (agent `generated_by` branch a). Agent
    returns a record string **or** a `REFUSED:` string (FR-4).
  - **3. Handle REFUSED** — surface verbatim; no checkpoint; no file; abort (spec
    §5.1, FR-5).
  - **4. Output Validation Checkpoint** — read the record back; check against the
    `estimate-record-format.md` validation checklist **referenced by path**,
    enumerating every line incl. the #377 per-stage coupling + split-tier
    strict-spread. **Fix only STRUCTURAL-ONLY deviations in place and record each
    change** (routinely only deleting a stray verdict field); **ABORT, never
    author**, on any derived-value defect (missing `cost_basis`, `low > high`,
    missing disclosure section, coupling violation, collapsed split-tier band,
    over-ceiling confidence, imperative prose) — per the §7.1a per-line table;
    never re-dispatch (spec §7.1, §7.1a, §7.3; FR-6/FR-6a/FR-7/FR-14). Honour the
    trailing-slash special-case **in the summary's grounding report**, add no
    checklist line.
  - **5. Review summary** — target + classified `target_kind` **with an
    asserted-not-inferred flag when the kind was human-asserted via `--kind` (O4)**;
    token range + per-axis confidence; agent-compute-time range + `human_gate_time`
    caveat; cost present/omitted (+ disclosed cause, with the trailing-slash "no
    snapshot" reporting); `failure_direction` + driver; **the resolved output
    path**; and **the change-list of exactly what the checkpoint altered (O1)** (or
    "no checkpoint changes" when none) (spec §5 step 5, §6.3; FR-8/FR-8a/FR-6a/FR-12).
  - **6. Ask for disposition** — accept / edit / re-run / abort (full vocabulary)
    **before** any write. `edit` runs the post-edit checkpoint in
    **validate-and-report** mode (never silent-revert, O3); `re-run` is a **full
    fresh dispatch that re-reads `observability/costs/`** (O8) (spec §5 step 6,
    §7.1b; FR-8/FR-6b/FR-8b).
  - **7. On accept: write once** — `mkdir -p` the output dir; single Write to the
    resolved path under `cost-estimates/`; confirm full path. This is the only
    persistence, downstream of the disposition (spec §5 step 7, §6; FR-9/FR-10).
  - **Specification picks** — `--near` dropped (one-target contract); `--kind`
    enum; `--out` directory-override semantics + collision disambiguation; default
    path **top-level `cost-estimates/<date>-<slug>-estimate.md` (outside
    `observability/`, O5)**; absolute-rate check deferred + re-filed with a blocking
    acceptance criterion (spec §4.1, §6.1, §7.2; FR-10/FR-15).

---

## Phase 2 — Convention list + TDAD scenarios

### Task 2: Add `/cost-estimate` to the CLAUDE.md checkpoint list

- [ ] Add `/cost-estimate` to the CLAUDE.md "Output Validation Checkpoints"
  convention's list of commands with checkpoints (spec §7.4, FR-16).

### Task 3: Author the structural + behavioural scenarios

- [ ] Create the eleven scenario files under
  `tdad_tests/scenarios/commands/cost-estimate/` per the test case list and the
  corpus format in `tdad_tests/README.md` (one structural, ten behavioural). Do
  **not** modify any `cost-estimator` agent or `cost-estimation` skill scenario —
  S3 is a pure consumer.
- [ ] Each behavioural scenario pins its grounding fixtures (a target, a fixture
  `MODEL_ROUTING.md`, an empty or populated `observability/costs/`) and is graded
  by the deterministic oracles (spec §9): file-existence at the `cost-estimates/`
  resolved path, frontmatter conformance parse, the #377 coupling +
  split-tier-spread checks, the REFUSED-prefix + no-file outcome, the trailing-slash
  summary reporting, the **structural-fix-boundary** oracle (fix + change-list vs
  abort-never-author), the **edit-validate-and-report** oracle, and the **`--kind`
  assertion-flag** oracle — never exact numbers or prose wording.

---

## Phase 3 — Docs

### Task 4: How-to guide + reference entry

- [ ] Add a how-to guide at
  `docs/plugins/ai-literacy-superpowers/how-to/estimate-cost-of-a-task.md` —
  task-oriented walkthrough of running `/cost-estimate` on a slice / spec / task
  text, the disposition flow, and where the record lands (FR-19).
- [ ] Add a reference entry at
  `docs/plugins/ai-literacy-superpowers/reference/cost-estimate-command.md` —
  the signature, accepted target types, the **top-level `cost-estimates/`
  output-path convention (outside `observability/`, with a note on why predictions
  are not filed under the telemetry root, and that `cost-estimates/` is gitignored
  by default as a derived, regenerable artefact)**,
  the `--out` override + collision disambiguation, the **`--kind` asserted-ceiling
  consequence**, and the Output Validation Checkpoint **with its structural-fix
  boundary + change-list transparency** (FR-19). Cross-link the `/cost-capture`
  sibling and the S1 format reference.

---

## Phase 4 — Version bumps + gitignore

### Task 5a: Gitignore `cost-estimates/` (O3, FR-10a)

- [ ] Add a `cost-estimates/` line to the repo-root `.gitignore`, with a comment
  matching the existing `/diagnose` entry's rationale (e.g. "Cost estimate records
  — derived, regenerable artefacts written by the /cost-estimate command. Never
  committed."). Place it near the `diagnostic-legibility/output/` entry so the two
  derived-output exclusions sit together (spec §6.1, O3).

### Task 5: Bump plugin.json, CHANGELOG, marketplace.json, README

- [ ] `ai-literacy-superpowers/.claude-plugin/plugin.json`: `version` `0.43.0` →
  `0.44.0`.
- [ ] `CHANGELOG.md` (repo root): new `## 0.44.0 — 2026-06-12` heading with
  entries for the new command (manual dispatcher; dispose-then-write ordering;
  Output Validation Checkpoint incl. #377 lines **with the structural-fix boundary
  + change-list transparency** — fix structural-only, abort-never-author on derived
  defects; the `edit` validate-and-report path; the `--kind` asserted-ceiling flag;
  REFUSED handling; default output home **top-level `cost-estimates/` outside
  `observability/`** (and **gitignored by default** as a derived, regenerable
  artefact) + `--out` with collision disambiguation; `re-run` re-reads the
  snapshot; trailing-slash summary special-case + recorded unguarded-sentinel
  residual; absolute-rate check deferred + re-filed **bound to S6/#373 as a
  blocking required deliverable**), the CLAUDE.md checkpoint-list addition, the
  `.gitignore` entry, and the docs.
- [ ] `.claude-plugin/marketplace.json`: bump the `ai-literacy-superpowers`
  `plugins[]` entry `version` and the top-level `plugin_version` to `0.44.0`;
  leave top-level `version` at `0.4.0`.
- [ ] `README.md`: bump the `ai-literacy-superpowers` badge `v0.43.0` → `v0.44.0`.
- [ ] Verify version consistency:

```bash
python3 -c "
import json
pj = json.load(open('ai-literacy-superpowers/.claude-plugin/plugin.json'))
m = json.load(open('.claude-plugin/marketplace.json'))
entry = next(p for p in m['plugins'] if p['name']=='ai-literacy-superpowers')
assert pj['version']=='0.44.0', pj['version']
assert entry['version']=='0.44.0', entry['version']
assert m['plugin_version']=='0.44.0', m['plugin_version']
assert m['version']=='0.4.0', m['version']
print('version consistency OK')
"
```

---

## Phase 5 — Verify and ship

### Task 6: Local CI gate checks

- [ ] Spec-first ordering — first commit on branch is the spec:

```bash
git log main..HEAD --reverse --oneline | head -1
```

- [ ] TDAD scenario presence — the new command ships with scenarios:

```bash
ls tdad_tests/scenarios/commands/cost-estimate/*.md
```

- [ ] Markdown lint, docs build, and the deterministic TDAD fast suite
  (Layers 0+1) pass.

### Task 7: Re-file the deferred absolute-rate check

- [ ] Open a standalone GitHub issue ("estimate-record absolute-rate validation —
  snapshot-grounded per-stage cost falsification"). The issue body MUST bind the
  check to a **concrete slice number, not an unscheduled precondition** (O4): it is
  a **BLOCKING required deliverable of S6/#373**. State plainly that **S6/#373 is
  extended to also own first-snapshot capture** — capturing the first usable
  `observability/costs/` snapshot — so the first falsifiable cost-present record
  actually comes into existence under S6 (S6 both captures the snapshot and
  consumes it in the calibration loop); the absolute-rate check is then a required
  deliverable of that same slice. Do **not** key the trigger on "the first slice
  that produces a cost-present record" (no scheduled slice produced that event —
  the unreachable-trigger defect O4 names). **Reference the issue as a required,
  blocking deliverable from S6/#373.** This is a committed home bound to a named
  slice (spec §7.2, FR-15; O6, O4). Reference it in the PR body.

### Task 8: Push, PR, CI, merge

- [ ] Push the `cost-estimate-command` branch, open a PR against #370 (feature
  ceremony — `/diaboli` spec runs on this spec next; code-mode runs after the
  code-reviewer PASS; `/choice-cartograph` as applicable).
- [ ] PR body states what ships (command + eleven scenarios + CLAUDE.md
  checkpoint-list entry + docs + version bump) and what does NOT (S4–S6, issues
  #371–#373; no orchestrator wiring; no S2/S1 change; no absolute-rate check —
  re-filed with a blocking acceptance criterion). Link the re-filed absolute-rate
  issue.
- [ ] Watch CI green; merge `--squash --delete-branch`; sync the marketplace
  cache.

---

## Out of scope (deferred to S4–S6)

- **Orchestrator fold-in at T1 (Slice Adjudication) and T2 (Plan Approval)** (S4,
  #371). `/cost-estimate` is standalone; no orchestrator change, no gate added or
  re-weighted, no estimate fields surfaced inside the existing gates. The
  orchestrator dispatching the same S2 agent at T1/T2 is a separate dispatcher
  with its own spec.
- **The T0 pre-carpaccio ballpark** (S5, #372). The command accepts a task-text
  target, but the firing position and bonus-step wiring are S5's.
- **The calibration loop** — per-PR actuals capture + integration-agent change
  (S6, #373). The agent reads a `kind: calibration` source if one exists (S1
  seam); the command neither produces nor requires one.
- **The snapshot-grounded absolute-rate check** (#377-deferred). Re-filed as a
  standalone issue **bound to a concrete slice number — a BLOCKING required
  deliverable of S6/#373**, which is extended to also own first-snapshot capture so
  the trigger is reachable (spec §7.2, O6, O4); not built here.
- **Any change to the S2 agent or the S1 format reference.** S3 consumes both
  as-merged. A genuine contract need would be its own owning slice, never folded
  into this consumer.
```
