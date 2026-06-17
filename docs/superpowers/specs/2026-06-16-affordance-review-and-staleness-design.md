# Spec: `/harness-affordance review` + staleness GC rule (sequencing step 6)

**Date**: 2026-06-16
**Author**: Russ Miles + assistant
**Parent design**: `docs/superpowers/specs/2026-04-26-harness-affordances-design.md`
(O11 disposition — the re-validation procedure)
**Builds on**: step 3 (`add`, the `Last reviewed` field) and steps 4+5 (the
deterministic check pattern)
**Driving issue**: #202
**Status**: design — spec-mode `/diaboli` reviewed, all 10 dispositions
adjudicated 2026-06-16 (see Adjudication); ready for implementation

## Problem

Every affordance carries a `Last reviewed: YYYY-MM-DD` date. Step 3 sets it
on `add` (a genuine first review). But nothing yet **bumps** it, and nothing
**flags** it when it goes stale. Per the parent spec's O11, the date is only
meaningful if a defined re-validation procedure controls it — otherwise it
degrades into a `git log` mtime check that says nothing about whether the
governance facts (Identity, Audit trail, Permission) still hold.

Step 6 closes the per-affordance staleness loop with two halves:

1. a **`review` command** that bumps the date only after three explicit
   re-validation checks pass; and
2. a deterministic **staleness GC rule** that flags affordances whose date
   has aged past a configurable threshold.

## Scope

1. **`commands/harness-affordance.md` — implement `review <name>`.** Replace
   the "not yet implemented" stub with the interactive three-check flow.
2. **`scripts/harness-affordance-staleness.sh`** — a deterministic scanner
   that flags affordances with a stale `Last reviewed` date.
3. **One GC rule** in `templates/HARNESS.md` `## Garbage Collection`
   (weekly, deterministic, report-only), with a configurable threshold.
4. **Docs** — update the how-to and the explanation/reference pages.
5. **Layer 0 tests** over the staleness scanner.
6. Minor version bump.

**Out of scope** (later steps): the runtime tuple recorder (step 7) and CI
discovery automation (step 8).

## `review <name>` behaviour

Interactive re-validation that bumps `Last reviewed` **only if all three
checks pass**. Given a name (matched by `### <name>` heading under
`## Affordances`):

1. **Identity check.** Show the entry's `Identity`; ask "still correct?
   yes / no / needs-edit". For `runtime-resolved`, prompt specifically that
   the resolution chain in Notes has not changed; for fixed identities, that
   the named credential still exists and belongs to the named principal.
2. **Audit trail check.** Show the `Audit trail`; ask the same. The endpoint
   exists, retention matches, access scope holds. For `none`, confirm no
   audit log has been added since last review.
3. **Permission check.** Show the `Permission`; confirm the pattern is still
   present in a settings allowlist (`.claude/settings.json`,
   `.claude/settings.local.json`, or `~/.claude/settings.json`).

Each check is **explicit** — no implicit "everything looks fine" passing; the
human answers each of the three.

- **All three `yes`** → bump `Last reviewed` to today.
- **Any `needs-edit`** → open that field for inline edit; the edit itself
  does **not** bump the date unless the human then re-affirms all three pass.
- **Any `no`** the human cannot fix in-session → leave `Last reviewed`
  **unchanged** and add a `Notes` line describing the gap (so the staleness
  rule keeps firing until it is resolved). Editing other fields (Notes,
  Constraint references) never bumps the date on its own.

Validation checkpoint: re-read the entry; confirm `Last reviewed` is a
`YYYY-MM-DD` date and was bumped iff all three checks passed.

## The staleness scanner

`scripts/harness-affordance-staleness.sh [--max-age-days=N] [--today=YYYY-MM-DD] [project-dir]`

1. Resolve `HARNESS.md` (root or `.claude/`). Absent → exit 0, nothing to
   check.
2. Extract the `## Affordances` section. Absent → exit 0.
3. For each **non-example** entry (skip `<!-- affordance-example -->`-marked
   entries; **include** hook entries — a hook's Identity/Audit trail can go
   stale too), read its `Last reviewed` date. An entry missing a parseable
   `YYYY-MM-DD` date is reported as `UNDATED: affordance '<name>' has no
   valid Last reviewed date` (a review is overdue by definition).
4. Compute age in days from `Last reviewed` to **today** (`--today` overrides
   the system date so tests are hermetic). Age `>` `--max-age-days`
   (default **180**) → `STALE: affordance '<name>' last reviewed <date>
   (<age> days ago; threshold <N>)`.
5. Print findings `LC_ALL=C`-sorted; print `OK: all affordances reviewed
   within <N> days` when none. **Exit 0 always** — this is a report-only GC
   rule, not a blocking gate.

Deterministic given `--today`. `set -euo pipefail`.

## Threshold is configurable, not hardcoded

The default is 180 days, but the threshold is set in `HARNESS.md` itself: the
GC rule's `Tool` line carries `--max-age-days=180`. A project edits that
number in its own `HARNESS.md` to tune the cadence — the knob lives in the
project's harness, not baked into the script (the script default applies only
when the flag is omitted). This satisfies "configurable via a HARNESS.md
setting, not hardcoded".

## GC rule (templates/HARNESS.md `## Garbage Collection`)

```text
### Affordance review staleness

- **What it checks**: Whether any affordance in the ## Affordances section has
  a `Last reviewed` date older than the configured threshold (default 180
  days / ~6 months), or no valid date at all
- **Frequency**: weekly
- **Enforcement**: deterministic
- **Tool**: bash ai-literacy-superpowers/scripts/harness-affordance-staleness.sh --max-age-days=180
- **Auto-fix**: false
```

Report-only (`Auto-fix: false`): the fix is a human running
`/harness-affordance review <name>`, which is a governance judgment, not a
mechanical edit.

## Acceptance scenarios

1. **All checks pass** → `review` bumps `Last reviewed` to today.
2. **A check fails** → date unchanged; a Notes line records the gap.
3. **Stale entry** → the scanner flags it by name with its age and the
   threshold; exit 0.
4. **Fresh entry** (within threshold) → not flagged.
5. **Undated entry** → reported as undated (review overdue).
6. **Example entries** → never flagged (skipped).
7. **Hook entry** → IS subject to staleness (included).
8. **Threshold override** → `--max-age-days=30` flags an entry the default
   180 would not.
9. **Hermetic** → `--today` fixes "now" so the same fixture yields the same
   verdict on any day.

## Functional requirements

- **FR1** `review <name>` runs the three explicit checks and bumps
  `Last reviewed` to today **iff** all pass; a failing check leaves the date
  and adds a Notes gap line.
- **FR2** `harness-affordance-staleness.sh` flags non-example affordances
  (including hooks) whose `Last reviewed` is older than `--max-age-days`
  (default 180) or undated; report-only (exit 0); `--today` makes it
  deterministic.
- **FR3** One weekly deterministic report-only GC rule in the template, with
  the threshold set via the `--max-age-days` flag in the `Tool` line.
- **FR4** Docs (how-to + reference/explanation) cover `review` and the
  staleness rule.
- **FR5** Layer 0 tests cover the staleness scenarios against hermetic
  fixtures (via `--today` and `project-dir`).

## Adjudication (post-diaboli, 2026-06-16)

Spec-mode `/diaboli` raised ten objections (3 high; record:
`docs/superpowers/objections/affordance-review-and-staleness-design.md`). All
adjudicated — every objection **amend**. The binding refinements below
supersede the original wording where they conflict and drive implementation.

- **A1/A8 (O1/O8) — wire the rule into the weekly cron.** `gc.yml` runs a
  hardcoded step list and never reads HARNESS.md `Tool` lines, so a template
  GC rule alone runs only via the on-demand `harness-gc` agent. This step
  **adds a report-only step to `.github/workflows/gc.yml`** that runs the
  staleness scanner, prints its output to the workflow step summary, and
  emits a `::warning::` when findings exist (it self-skips when there is no
  `## Affordances` section). The template GC rule stays for the agent path.
  Both consumers are named.
- **A2/A10 (O2/O10) — the scanner READS the threshold from HARNESS.md.**
  Precedence: `--max-age-days` flag > a human-owned HARNESS.md marker
  `<!-- affordance-review-threshold-days: N -->` > default **180**. The
  marker ships in the human-authored `## Affordances` section header (not the
  template-managed GC rule `Tool` line), so a tuned value is a genuine
  HARNESS.md setting the scanner resolves, and `/harness-upgrade` does not
  clobber it.
- **A3 (O3) — bounded, idempotent gap Notes.** A failing `review` check
  writes a **single** gap line per check, keyed by a stable prefix
  `[review-gap: <check>]`, updating it in place rather than appending; a
  passing review **removes** that check's gap line. Notes growth is bounded
  and resolved gaps are cleaned up.
- **A4 (O4) — a bump requires re-answering all three checks.** After any
  inline edit, the date bumps only if the human re-answers **all three**
  checks `yes` — no single-field shortcut. The date attests to a full
  re-validation or it is not bumped.
- **A5/A9 (O5/O9) — reuse only the section extractor.** The scanner reuses
  only the `## Affordances` section-extraction `awk` from
  `harness-affordance-check.sh`, **not** its entry classifier. It classifies
  entries solely by the `<!-- affordance-example -->` marker (skip
  example-marked; keep everything else, **including hooks**) and reads
  `Last reviewed`. It never inspects `Permission` for hook shape.
- **A6 (O6) — UTC-normalised age.** "Today" is derived via `date -u` and
  `Last reviewed` is interpreted as a UTC date, so the day-count is
  machine-independent regardless of the runner's timezone.
- **A7 (O7) — transcription-only edits.** `review`'s inline edits follow the
  same discipline as `add`: the human dictates the new value for any edited
  field; the command only transcribes. `Last reviewed` attests to a human
  re-validation, never a model edit.

### Added acceptance scenario

10. **Workflow surfaces findings** — the `gc.yml` staleness step prints stale
    / undated entries to the step summary and warns when any exist; it
    self-skips (no warning) when there is no `## Affordances` section.

## Risks and mitigations

- **Date math portability** (`date -d` vs BSD `date -j`). Mitigated by
  computing the age from `YYYY-MM-DD` epoch seconds with the same
  dual-form pattern the existing reflection-log helpers use
  (`date -j -f %Y-%m-%d` || `date -d`).
- **"Now"-dependence breaks hermetic tests.** Mitigated by `--today`.
- **`review` is model-mediated, not unit-testable.** Mitigated by the
  deterministic staleness scanner (which is the only mechanically-verifiable
  half) carrying the Layer 0 coverage; `review`'s bump-iff-all-pass logic is
  covered by the manual acceptance scenarios and its validation checkpoint.
