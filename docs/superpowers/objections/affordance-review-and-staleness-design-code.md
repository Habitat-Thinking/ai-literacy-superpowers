---
spec: docs/superpowers/specs/2026-06-16-affordance-review-and-staleness-design.md
date: 2026-06-16
mode: code
diaboli_model: claude-opus-4-8[1m]
objections:
  - id: O1
    category: risk
    severity: high
    claim: "The threshold-marker grep scans the whole HARNESS.md and takes head -1, not the ## Affordances section the adjudication (A2) designates — any earlier line carrying 'affordance-review-threshold-days: N' wins; safe in the shipped template only by the accident that the prose reference lacks a colon+number."
    evidence: "Marker grep runs against the full file, unscoped to the section."
    disposition: amend
    disposition_rationale: "Scope the marker resolution to the ## Affordances section (reuse the section extractor that already bounds entry parsing), so the marker is read from its designated home, not the whole file."
  - id: O2
    category: risk
    severity: medium
    claim: "BSD `date -u -j -f '%Y-%m-%d'` fills the missing time-of-day from localtime-now, not UTC midnight, so the A6 machine-independence guarantee does not hold on the maintainers' macOS path."
    evidence: "date -u -j -f '%Y-%m-%d' with no time fields; -u governs output, not parse-time field-fill on BSD."
    disposition: amend
    disposition_rationale: "Pin midnight UTC explicitly: parse 'YYYY-MM-DD 00:00:00' (BSD '%Y-%m-%d %H:%M:%S'; GNU '... 00:00:00 UTC'), so both today and Last reviewed are exact UTC-midnight epochs and the day-count is machine-independent."
  - id: O3
    category: implementation
    severity: medium
    claim: "A future Last reviewed date yields a negative age and passes the -gt staleness test, so a non-credible future date is reported as the freshest possible state."
    evidence: "age_days = today - reviewed; only age > MAX flagged; a 2099 date is negative and never flagged."
    disposition: amend
    disposition_rationale: "Flag a future date as a distinct finding (FUTURE: ...): a Last reviewed in the future cannot reflect a real past review and is at least as suspect as a stale one."
  - id: O4
    category: implementation
    severity: medium
    claim: "The shape regex passes calendar-impossible dates (2026-02-30) which BSD rejects (UNDATED) but GNU rolls over (valid wrong epoch) — platform-divergent classification."
    evidence: "Regex checks digit/dash shape only; GNU date rolls 2026-02-30 to 2026-03-02."
    disposition: amend
    disposition_rationale: "Round-trip validate: parse to epoch, reformat the epoch back to %Y-%m-%d UTC, and require it equals the input; a rolled-over (impossible) date fails the round-trip and is reported UNDATED on every platform."
  - id: O5
    category: risk
    severity: medium
    claim: "The gc.yml step writes unconditionally to $GITHUB_STEP_SUMMARY; when unset (local act / non-Actions), the redirect is unguarded and not covered by the scanner's || true."
    evidence: "Brace-group redirect to $GITHUB_STEP_SUMMARY with no guard."
    disposition: amend
    disposition_rationale: "Guard the step-summary write with [ -n \"${GITHUB_STEP_SUMMARY:-}\" ]; always echo the output to the step log so findings reach a reader regardless of environment."
  - id: O6
    category: implementation
    severity: medium
    claim: "The example-marker match is unanchored, so a Notes line quoting the literal <!-- affordance-example --> comment trips is_example and silently drops a real entry from staleness scanning (the same unanchored pattern as harness-affordance-check.sh)."
    evidence: "/<!--[^>]*affordance-example[^>]*-->/ fires on any line in the block; check.sh shares the pattern."
    disposition: amend
    disposition_rationale: "Anchor the example marker to a line that is ONLY the marker comment (^[[:space:]]*<!--[[:space:]]*affordance-example[[:space:]]*-->[[:space:]]*$) in BOTH the staleness scanner and harness-affordance-check.sh, so prose mentioning the marker cannot disable an entry."
  - id: O7
    category: risk
    severity: medium
    claim: "The Layer 0 suite covers happy-path classifications but not the three adjudicated robustness behaviours: competing-marker precedence (O1), UTC cross-timezone independence (A6/O2), and the malformed/future-date classes."
    evidence: "UTC test asserts only self-consistency for a fixed --today; no competing-marker or TZ-varied or future-date case."
    disposition: amend
    disposition_rationale: "Add Layer 0 cases: a competing earlier marker outside the section must not win; the same fixture under different TZ env yields the same verdict; a future date is FUTURE; an impossible date (2026-02-30) is UNDATED on any platform."
  - id: O8
    category: implementation
    severity: low
    claim: "The dual-form date parser accepts different input sets on BSD vs GNU, a portability win bought with a determinism loss for edge inputs."
    evidence: "BSD strict -f vs GNU permissive -d accept different residual inputs."
    disposition: amend
    disposition_rationale: "Resolved by O4: the round-trip validation makes both platforms reject any input that does not reformat back to the exact YYYY-MM-DD, collapsing the accepted-input sets to the same strict set."
  - id: O9
    category: risk
    severity: low
    claim: "review's idempotent gap-Notes (A3) and re-affirm-all-three (A4) are model-facing prose with no deterministic guard; a model could append a duplicate line or bump on a single-field confirm undetected."
    evidence: "review is model-mediated; the validation checkpoint only re-reads that Last reviewed is a date."
    disposition: acknowledge
    disposition_rationale: "Inherent to a model-mediated command (the spec accepts review is not unit-testable). The deterministic staleness scanner is the safety net — it keeps firing until a genuine review bumps the date, so a mis-gated bump self-corrects on the next cycle. Named as a residual-trust point, not hardened with a guard in this step."
---

# Objection record — affordance review + staleness (code mode)

Nine objections (1 high, 6 medium, 2 low); no critical. Adjudicated
2026-06-16: eight **amend** (hardening applied in this PR), one **acknowledge**
(O9, inherent model-mediation residual). The load-bearing fixes: scope the
threshold marker to the section (O1); pin UTC midnight so the date math is
genuinely machine-independent (O2); round-trip-validate dates so impossible
ones classify the same on every platform (O4/O8); flag future dates (O3);
anchor the example marker to its own line in both affordance scripts (O6);
guard the gc.yml summary write (O5); and add the missing edge-case tests (O7).

## Explicitly not challenged

- Hooks included in staleness scanning (A5/A9) — correctly marker-only.
- set -euo pipefail + LC_ALL=C sort output determinism.
- Exit-0-always report-only semantics.
- The --today hermeticity mechanism itself.
- The flag > marker > default precedence ordering (only the marker's scope, O1).
- review's transcription-only discipline as written (A7).
