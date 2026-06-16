---
spec: docs/superpowers/specs/2026-06-16-affordance-chained-constraints-design.md
date: 2026-06-16
mode: code
diaboli_model: claude-opus-4-8[1m]
objections:
  - id: O1
    category: risk
    severity: high
    claim: "Example-skip keys on the bare substring 'affordance-example' anywhere in an entry, so a real affordance whose Notes mention it is silently skipped — a false-negative disabling the safety check for that entry."
    evidence: "harness-affordance-check.sh: '/affordance-example/ { is_example=1 }' is unanchored."
    disposition: amend
    disposition_rationale: "Anchor the skip to the HTML comment marker form (<!-- ... affordance-example ... -->), not a bare substring, so prose mentioning the string cannot disable a real entry."
  - id: O2
    category: implementation
    severity: high
    claim: "DIAGNOSTIC entries are dropped from the advisory 'declared' set, so a governed permission in a multi-pattern/flagged affordance is falsely reported as an ungoverned ADVISORY."
    evidence: "declared=$(... $1==\"OK\"{print $3} ...) excludes DIAG rows."
    disposition: amend
    disposition_rationale: "Emit a DECL row for every permission-shaped token in any non-example, non-hook entry (including multi-pattern ones); the advisory 'declared' set is built from DECL rows, so a flagged-but-governed permission is not reported ungoverned."
  - id: O3
    category: implementation
    severity: high
    claim: "The comma heuristic for multi-pattern detection false-positives on a single pattern containing a comma and false-negates on space-joined patterns (only the first is extracted)."
    evidence: "comma-before-first-' (' heuristic; match(/`[^`]+`/) extracts only the first token."
    disposition: amend
    disposition_rationale: "Replace the comma heuristic with counting permission-SHAPED backticked tokens (Word(...), mcp__..., hooks....): exactly 1 => OK with that pattern; >1 => DIAGNOSTIC (multiple patterns); 0 => DIAGNOSTIC (no pattern). Annotation paths like `.claude/settings.local.json` are not permission-shaped and are ignored."
  - id: O4
    category: risk
    severity: high
    claim: "The real-affordance gate uses GNU grep alternation '\\|', literal under BSD/macOS grep (the dev platform), so a populated project self-skips to unverified — silently disabling the safety check on the enforcement machine while CI stays green."
    evidence: "grep -q '^OK\\|^DIAG'; confirmed masked locally only by the harness ugrep wrapper."
    disposition: amend
    disposition_rationale: "Replace all '\\|' alternation with POSIX 'grep -qE' / separate greps. Verified the bare BSD grep treats '\\|' as literal."
  - id: O5
    category: risk
    severity: medium
    claim: "A malformed settings JSON file is silently swallowed (jq 2>/dev/null), so a corrupt file that grants a pattern yields a false blocking FAIL with no hint of the real cause."
    evidence: "jq -r '.permissions.allow[]?' over multiple files, stderr discarded."
    disposition: amend
    disposition_rationale: "Validate each settings file with 'jq empty' before union; if any is invalid JSON, go unverified with a message naming the file (a parse failure must not masquerade as a governance gap)."
  - id: O6
    category: implementation
    severity: medium
    claim: "Blocking FAIL/DIAGNOSTIC lines are emitted in document order, not C-sorted, contradicting the spec's 'sorted LC_ALL=C before reporting' determinism claim (advisory IS sorted)."
    evidence: "blocking loop iterates PARSED in document order; only advisory is sorted."
    disposition: amend
    disposition_rationale: "Sort the blocking DIAGNOSTIC and FAIL lines LC_ALL=C before printing, so both directions share the same determinism guarantee."
  - id: O7
    category: risk
    severity: medium
    claim: "A hook entry with a missing/malformed Mode line is treated as non-hook and FAILs against its hooks.<Trigger> Permission — re-opening the O1 false-fire-on-hooks failure mode."
    evidence: "mode captured only from a '- **Mode**:' line; flush skips only mode=='hook'."
    disposition: amend
    disposition_rationale: "Belt-and-suspenders: also skip any entry whose extracted pattern is a 'hooks.*' registration, regardless of the Mode field, so a hook with an absent/garbled Mode is still not matched against the allowlist."
  - id: O8
    category: implementation
    severity: medium
    claim: "The section extractor stops at the first line beginning '## ', so an entry whose Notes contain a column-0 '## ' line truncates the section, silently dropping later entries."
    evidence: "awk '/^## / { if (inside) exit }' with no fenced-code awareness."
    disposition: acknowledge
    disposition_rationale: "Low blast radius: affordance fields are single bullet lines per the schema, and a column-0 '## ' inside an entry is malformed markdown. Documented as a constraint on entry authoring rather than hardened now; a fenced-code-aware parser is disproportionate for this step."
  - id: O9
    category: risk
    severity: low
    claim: "The Layer 0 test covers happy paths only; the adjudicated robustness behaviours (example-in-Notes, DIAGNOSTIC-in-advisory, malformed JSON, hook-without-Mode, multi-pattern) are asserted, not verified."
    evidence: "test covers scenarios 1-7 + one hook-skip + one union; no edge fixtures."
    disposition: amend
    disposition_rationale: "Add Layer 0 cases for: example-marker mentioned in a real entry's Notes (must NOT skip), DIAGNOSTIC entry's permission not flagged ungoverned in advisory, malformed settings JSON => unverified, hook entry with no Mode line => skipped, space-joined multi-pattern => DIAGNOSTIC."
  - id: O10
    category: scope
    severity: low
    claim: "Both constraints ship commented-out, so the live harness never exercises them and the commented text can drift from the script's --direction contract."
    evidence: "templates/HARNESS.md wraps both entries in one opt-in comment."
    disposition: acknowledge
    disposition_rationale: "Deliberate, consistent with the template's opt-in idiom for non-default features (Affordances is opt-in). The check self-gates, so the script-level Layer 0 tests are the enforcement-behaviour guarantee. Drift risk noted; a future step may activate them once affordances are in wide use."
---

# Objection record — affordance chained constraints (code mode)

Ten objections: 0 critical, 4 high, 4 medium, 2 low. The implementation
realised the adjudicated design structurally; these objections concern
parser/gate robustness against imperfect input. Adjudicated 2026-06-16:
eight **amend** (hardening applied in the same PR), two **acknowledge**
(O8 low-blast-radius markdown edge; O10 deliberate commented opt-in). The
highest-leverage fix is O4 (POSIX grep) — the gate was silently masked
locally by the harness `ugrep` wrapper and would self-skip the safety check
on a clean BSD-grep machine.

## Explicitly not challenged

- String-equality matching (parent O5), faithfully implemented via grep -qxF.
- jq-missing => exit-0-unverified for tooling absence.
- project-dir hermeticism (A11) and project-settings-only reads (A5).
- The advisory always-exit-0 contract (only the DIAGNOSTIC leakage, O2).
