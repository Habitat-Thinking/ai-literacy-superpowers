---
spec: docs/superpowers/specs/2026-06-15-cost-estimation-stem-table-maintenance-design.md
date: 2026-06-15
mode: spec
diaboli_model: claude-opus-4-8[1m]
adjudication: all 12 accepted; human disposed the design to PIVOT — drop the snapshot-content GC staleness rule, adopt O5's deterministic mention-consistency check + canonical source/maintenance note
objections:
  - id: O1
    category: implementation
    severity: high
    claim: "The GC rule's 'no estimating-tier family resolves' trigger equals a legitimate recurring state (a cheap-tier-only month), so it false-positives every such cycle."
    disposition: accepted
    disposition_rationale: "Resolved by DROPPING the snapshot-content GC rule entirely. The pivot replaces it with a deterministic mention-consistency check (O5) that has no operating-state false positive."
  - id: O2
    category: implementation
    severity: high
    claim: "The trigger gives a guaranteed false-negative for the actual feared case — a staggered rollover (opus→5 while sonnet-4 still present) leaves ≥1 stem resolving, so the rule stays silent while grounding degrades."
    disposition: accepted
    disposition_rationale: "Resolved by dropping the GC rule. The staggered-rollover external-staleness case is already covered by #412 (a partial rollover proxies the rolled tier at the present family's rate, a LOUD disclosed over-estimate) and #413 (capture-time advisory). The GC rule added no reliable coverage."
  - id: O3
    category: premise
    severity: high
    claim: "The single-canonical-source premise is contradicted: the stems appear in ~8 files (one being templates/MODEL_ROUTING.md), and 'reference, don't restate' is asserted, not enforced."
    disposition: accepted
    disposition_rationale: "This is the genuinely-unsolved problem #414 now targets. The pivot ships (a) the binding table as the declared canonical stem source (a parseable authoritative list) and (b) a deterministic check that consumer cost files do not reference an estimating-tier stem absent from that list. (Factual check: the templates/MODEL_ROUTING.md mention is an illustrative HTML-comment example, not a load-bearing routing entry — so the Option-2 rejection stands.)"
  - id: O4
    category: implementation
    severity: high
    claim: "'Agent-enforced, no agent code change, self-describing' is unsound — the harness-gc agent just 'scans for described entropy' and has no stem/delimiter logic."
    disposition: accepted
    disposition_rationale: "Resolved by dropping the agent GC rule. The replacement is a DETERMINISTIC Layer-1 structural test — no agent discretion, the resolution is in code."
  - id: O5
    category: alternatives
    severity: medium
    claim: "An unweighed, better alternative: a deterministic stem-mention drift check (do the files that name a stem agree with the canonical table?) — deterministic, no false positives, enforces single-source."
    disposition: accepted
    disposition_rationale: "Adopted as the CORE mechanism of the pivoted #414."
  - id: O6
    category: specification quality
    severity: high
    claim: "The promised test only asserts the rule text exists, not its behaviour — the central capability is unfalsifiable."
    disposition: accepted
    disposition_rationale: "Resolved by the pivot: the deterministic mention-consistency check IS the behavioural test — it fires on a drifted/absent stem and is silent on consistency, asserted directly over file contents (a real Layer-1 guard, not a text-presence assertion)."
  - id: O7
    category: scope
    severity: medium
    claim: "#414 duplicates #413's detection logic (re-resolving families) instead of consuming #413's recorded Observations line."
    disposition: accepted
    disposition_rationale: "Moot under the pivot — there is no snapshot-content re-resolution in #414 anymore. #413's capture-time grounding line stands as the external-staleness surface; #414 guards internal stem consistency, a disjoint concern."
  - id: O8
    category: premise
    severity: medium
    claim: "The external-staleness harm is overstated — #412 makes the miss a loud disclosed omission and #413 flags it at capture; the marginal value of a monthly sweep is small and unquantified."
    disposition: accepted
    disposition_rationale: "Accepted as the justification for dropping the GC rule: external staleness is adequately covered by #412 + #413, so #414 should not build a (mis-shaped) detector for it and instead targets the unsolved internal-drift problem."
  - id: O9
    category: implementation
    severity: medium
    claim: "'Latest snapshot' detection doesn't cover the primary gap (rolled-over-but-not-recaptured) — the last snapshot can't contain the new keys until re-captured, at which point #413 already caught it."
    disposition: accepted
    disposition_rationale: "Resolved by dropping the GC rule; confirms the snapshot-content surface could not cover its own motivating gap."
  - id: O10
    category: specification quality
    severity: medium
    claim: "The maintenance note's 'adds/replaces a stem' is ambiguous and load-bearing (add vs replace have opposite consequences for transition-quarter snapshots that span generations)."
    disposition: accepted
    disposition_rationale: "The maintenance note specifies ADD-and-retire, not replace-in-place: a new generation ADDS a stem (both coexist while transition snapshots may contain either — consistent with the binding table's cross-generation family aggregation); a stem is RETIRED only when no snapshot in the retention window still carries its family. Never silently replaced (which would regress transition snapshots)."
  - id: O11
    category: risk
    severity: medium
    claim: "Auto-fix:false routes every (mostly-benign, per O1) firing to a GitHub issue, training the curator to ignore the rule (alert fatigue)."
    disposition: accepted
    disposition_rationale: "Resolved by dropping the GC rule — the deterministic test fails CI only on real drift (a code change), producing no recurring benign issues."
  - id: O12
    category: scope
    severity: low
    claim: "Existing downstream harnessed projects don't auto-inherit a new template GC rule ('inherit' overclaims)."
    disposition: accepted
    disposition_rationale: "Moot under the pivot — no template GC rule is added. The deterministic check guards the PLUGIN repo's own cost files (where the stems live and could drift); downstream projects install but don't edit those files, so internal drift is a plugin-repo concern only."
---

## Summary

Spec-mode diaboli on the stem-table-maintenance spec (#414) raised **12
objections — 5 high, 6 medium, 1 low — all accepted.** The five highs
effectively **refuted the chosen design** (the snapshot-content GC staleness
rule): O1 (false-positive every cheap-tier month), O2 (false-negative on a
staggered rollover — the actual feared case), O4 (the agent has no stem
logic), O6 (only the rule's existence was testable), and O3 (the
single-source premise is contradicted by ~8 files).

The human disposed the fork to **pivot**:

- **Drop the snapshot-content GC staleness rule.** External staleness is
  already covered — #412 turns a rolled-over family into a *loud* disclosed
  omission/proxy, and #413 flags it at capture (O8); the GC rule added no
  reliable coverage and was mis-shaped (O1/O2/O9) and noisy (O11).
- **Adopt O5's deterministic mention-consistency check** as the core: the
  binding table declares the authoritative stem list (parseable), and a
  Layer-1 structural test asserts no consumer cost file references an
  estimating-tier stem absent from it — deterministic, no false positives,
  no agent discretion (O4), behaviourally falsifiable (O6), and it enforces
  the single-source discipline (O3).
- **Canonical source + maintenance note** (Option 1) with explicit
  **add-and-retire** semantics (O10), not replace-in-place.
- **Option 2 rejected** (confirmed: the MODEL_ROUTING stem mention is an
  illustrative HTML-comment example, not a load-bearing routing entry).

## What was NOT challenged (diaboli disclosure)

- Detection-never-auto-fix posture (correct for a pricing binding).
- The binding table as the canonical home (the right anchor — O3 challenges
  enforcement, not location).
- The Option-1 idea of a written maintenance note (O10 challenges its
  add/replace ambiguity, not its existence).
- No estimate-record format/field change (correctly scoped).
