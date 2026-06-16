---
spec: docs/superpowers/specs/2026-06-16-affordance-review-and-staleness-design.md
date: 2026-06-16
mode: spec
diaboli_model: claude-opus-4-8[1m]
objections:
  - id: O1
    category: implementation
    severity: high
    claim: "A weekly+deterministic GC rule has no scheduled consumer — gc.yml runs a hardcoded step list and never reads HARNESS.md Tool lines, so staleness surfaces only on a manual /harness-gc run."
    evidence: "Spec declares weekly/deterministic; gc.yml enumerates fixed named steps; the harness-gc agent is the only consumer that reads the section and runs arbitrary Tool commands."
    disposition: amend
    disposition_rationale: "Add a report-only step to gc.yml that runs the staleness scanner, so the rule genuinely runs on the weekly cron (for projects that vendor the plugin and have an ## Affordances section; self-skips otherwise). The template GC rule stays for the on-demand harness-gc agent path. Both consumers named in the spec."
  - id: O2
    category: specification quality
    severity: high
    claim: "'Configurable via a HARNESS.md setting' is met only by a flag in a template-managed Tool line, not a value the scanner reads from HARNESS.md; /harness-upgrade may overwrite it and a direct scanner run ignores it."
    evidence: "Scanner reads the threshold only from the CLI flag; it never parses HARNESS.md."
    disposition: amend
    disposition_rationale: "The scanner READS the threshold from a human-owned HARNESS.md marker comment (<!-- affordance-review-threshold-days: N -->), with precedence: --max-age-days flag > HARNESS.md marker > default 180. The marker lives in the human-authored ## Affordances section header (not the template-managed GC rule line), so /harness-upgrade does not clobber a tuned value (resolves O10)."
  - id: O3
    category: specification quality
    severity: high
    claim: "Repeated failing reviews pile up duplicate Notes gap lines with no de-duplication or update-in-place rule; a resolved gap leaves stale Notes behind."
    evidence: "Spec adds 'a Notes line describing the gap' on every failing review with no idempotency rule."
    disposition: amend
    disposition_rationale: "review writes a SINGLE gap line per failing check, keyed by a stable prefix `[review-gap: <check>]`, updating it in place rather than appending; a passing review removes that check's gap line. Notes growth is bounded and resolved gaps are cleaned up."
  - id: O4
    category: specification quality
    severity: medium
    claim: "The 'needs-edit then re-affirm' path is ambiguous about whether the date bumps after re-walking all three checks or just confirming the edited field."
    evidence: "Spec: 'the edit does not bump the date unless the human then re-affirms all three pass' — re-affirmation gesture unspecified."
    disposition: amend
    disposition_rationale: "State explicitly: a bump after ANY edit requires re-answering ALL THREE checks (no single-field shortcut). The date attests to a full re-validation or it is not bumped."
  - id: O5
    category: implementation
    severity: medium
    claim: "'Mirrors harness-affordance-check.sh's parsing idiom' over-claims reuse — that script drops hooks and extracts Permission patterns; the staleness scanner must include hooks and read Last reviewed."
    evidence: "check.sh flush() returns for hook entries and extracts patterns, not dates."
    disposition: amend
    disposition_rationale: "Clarify the scanner reuses ONLY the section-extraction awk, not the entry classifier. It classifies entries solely by the example marker (skip example-marked, keep everything else including hooks) and reads Last reviewed; it never inspects Permission for hook shape (resolves O9)."
  - id: O6
    category: risk
    severity: medium
    claim: "Age computation crosses an unpinned timezone/DST boundary; a bare YYYY-MM-DD interpreted at local midnight can yield off-by-one verdicts across machines near the threshold."
    evidence: "Dual-form date helper does no TZ pinning; determinism claimed only via --today."
    disposition: amend
    disposition_rationale: "Normalise the age computation to UTC: derive 'today' via date -u and interpret Last reviewed as a UTC date, so the day-count is machine-independent. State UTC explicitly."
  - id: O7
    category: risk
    severity: medium
    claim: "review writes HARNESS.md (model-mediated) but restates the human-dictates/command-transcribes discipline only for the bump, not for the inline field edits, leaving room for the model to author governance content."
    evidence: "review 'opens that field for inline edit'; add explicitly transcribes only."
    disposition: amend
    disposition_rationale: "Restate the transcription-only discipline for review's inline edits: the human dictates the new value for any edited field; the command only transcribes. The date attests to a human re-validation, never a model edit."
  - id: O8
    category: specification quality
    severity: medium
    claim: "Undated/stale findings exit 0 with no scheduled consumer (per O1), so the 'review overdue by definition' condition can be silently lost."
    evidence: "Exit 0 always; gc.yml reports only its own hardcoded steps."
    disposition: amend
    disposition_rationale: "Resolved by O1: the new gc.yml step prints the scanner output into the workflow step summary and emits a ::warning:: when findings exist, so stale/undated entries reach a reader on the cron. An acceptance scenario asserts the workflow surfaces findings."
  - id: O9
    category: implementation
    severity: low
    claim: "If the scanner reuses check.sh's hooks.-pattern detection it could mis-skip a hook entry it was told to include."
    evidence: "check.sh drops hooks.-pattern entries; staleness must include them."
    disposition: amend
    disposition_rationale: "Resolved by O5: classify entries only by the example marker; never inspect Permission for hook shape."
  - id: O10
    category: scope
    severity: low
    claim: "A locally-tuned --max-age-days in the template-managed Tool line may be clobbered by /harness-upgrade."
    evidence: "Knob sited in the template GC rule line; projects adopt template rules via upgrade."
    disposition: amend
    disposition_rationale: "Resolved by O2: the tunable threshold lives in a human-owned HARNESS.md marker, not the template-managed GC rule line, so upgrade does not regress it."
---

# Objection record — affordance review + staleness (spec mode)

Ten objections (3 high, 5 medium, 2 low); no critical, no premise. All
adjudicated 2026-06-16 — every objection **amend**. The two load-bearing
resolutions: (O1/O8) a real gc.yml step so the "weekly" rule actually runs on
the cron and its findings reach a reader; and (O2/O10) the scanner reads the
threshold from a human-owned HARNESS.md marker (flag > marker > default), so
"configurable via a HARNESS.md setting" is literally true and survives
/harness-upgrade. The amended design is in the spec's Adjudication section.

## Explicitly not challenged

- The bump-iff-all-three-pass core rule (faithful to the parent O11 procedure).
- The example-marker skip anchoring (consistent with the steps-4+5 adjudication).
- `--today` for hermetic fixtures.
- `set -euo pipefail` + LC_ALL=C sort determinism.
- The premise of step 6 (Last reviewed is meaningless without a bump-and-flag loop).
- review's Permission check reading the user settings layer (interactive path,
  consistent with add; not the deterministic CI check's project-only scope).
