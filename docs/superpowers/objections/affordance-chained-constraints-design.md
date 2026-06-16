---
spec: docs/superpowers/specs/2026-06-16-affordance-chained-constraints-design.md
date: 2026-06-16
mode: spec
diaboli_model: claude-opus-4-8[1m]
objections:
  - id: O1
    category: implementation
    severity: critical
    claim: "The 'backticked token' Permission parse extracts `hooks.Stop` for hook-mode affordances, which is never an allowlist pattern, so the blocking direction false-fires on every hook affordance."
    evidence: "Template hook entry: '- **Permission**: `hooks.Stop` entry in `.claude/settings.local.json` invoking ...'; allowlist holds Bash(...)/mcp__ patterns, never hooks.Stop."
    disposition: amend
    disposition_rationale: "The blocking direction SKIPS Mode: hook affordances entirely — hook registrations are not permission-allowlist-gated, so they have no allowlist counterpart to match. Document that hooks are out of the affordance-without-permission relation."
  - id: O2
    category: implementation
    severity: high
    claim: "A 'deterministic, blocking' constraint at Scope: commit contradicts the harness model where commit scope is the advisory inner loop and strict/blocking enforcement lives at pr (CI)."
    evidence: "constraint-design/SKILL.md: commit = PreToolUse hook (advisory), pr = CI (strict)."
    disposition: amend
    disposition_rationale: "Change the blocking constraint to Scope: pr (the idiomatic strict/blocking loop). See the enforcement-model decision recorded with O6/O9 (user-confirmed)."
  - id: O3
    category: risk
    severity: high
    claim: "Keying a SAFETY constraint's enforcement on deleting one sentinel line makes a silently-disabled blocking check trivial — the dangerous false-negative direction, with no meta-check that the gate never opened."
    evidence: "Spec: 'Deleting the sentinel is the human's explicit signal'."
    disposition: amend
    disposition_rationale: "Replace the section-level sentinel with a PER-ENTRY example marker. The check enforces on every non-example entry automatically; there is no ceremony to forget, so the gate cannot be silently left closed. An entry being real (unmarked) is the signal, not a separate deletion."
  - id: O4
    category: risk
    severity: high
    claim: "Deleting the sentinel while leaving example entries enforces the blocking check against fabricated example permissions."
    evidence: "Gate condition 1 keys only on sentinel-absence, not example removal; template ships four example entries."
    disposition: amend
    disposition_rationale: "Resolved by the per-entry marker (O3): example-marked entries are skipped by both directions, so leftover examples never enforce. The human deletes examples and adds real entries; the check ignores whatever examples remain."
  - id: O5
    category: specification quality
    severity: high
    claim: "Reading per-machine ~/.claude/settings.json breaks the 'byte-identical output' determinism claim and diverges from the discovery scanner's project-only source set."
    evidence: "Spec reads user layer while claiming determinism; scanner reads project config only."
    disposition: amend
    disposition_rationale: "The CHECK reads PROJECT settings only (.claude/settings.json, .claude/settings.local.json) — matching the discovery scanner's source set and restoring per-repo determinism. (Step 3's interactive `add` keeps reading the user layer; the deterministic CI check does not.)"
  - id: O6
    category: risk
    severity: medium
    claim: "Advisory always-exit-0 plus blocking self-gating on every common CI/adopter config means the pair can ship enforcing nothing strict."
    evidence: "Advisory never fails; blocking unverified when no readable allowlist; Scope commit (no CI run)."
    disposition: amend
    disposition_rationale: "Enforcement model (user-confirmed): blocking ships Scope: pr and enforces strictly in CI for projects that commit their permissions allowlist (.claude/settings.json). For projects that only use gitignored .claude/settings.local.json, the check honestly self-gates to unverified in CI and still runs locally. Document the enforcement points explicitly rather than implying universal CI blocking."
  - id: O7
    category: premise
    severity: medium
    claim: "The gate keys on an examples sentinel the merged step-3 template does not contain; the spec must retro-add it, and the gate is undefined for projects that adopted step 3 already."
    evidence: "Merged template has prose 'Delete the example entries' but no machine-readable sentinel."
    disposition: amend
    disposition_rationale: "This PR adds the per-entry example markers to the step-3 template examples (shipped via /harness-upgrade). Projects on the pre-marker template have unmarked examples; the check will flag their fake example permissions — which is correct feedback to delete the examples — and re-running /harness-upgrade installs the markers. Note this transition window in the spec."
  - id: O8
    category: specification quality
    severity: medium
    claim: "The 'Not yet configured placeholder' unverified branch references a marker string the template does not define."
    evidence: "No such placeholder string in the template Affordances block."
    disposition: amend
    disposition_rationale: "Drop the placeholder branch. The gate is: section absent OR no non-example entries => nothing to enforce (vacuous pass); otherwise enforce on the non-example entries. No placeholder-string matching needed."
  - id: O9
    category: alternatives
    severity: medium
    claim: "pr scope is the idiomatic home for a deterministic blocking check and dissolves O2 and most of O6."
    evidence: "constraint-design/SKILL.md: 'Start with pr scope for most constraints'; existing safety constraints use pr."
    disposition: amend
    disposition_rationale: "Adopted — blocking constraint ships Scope: pr (see O2/O6)."
  - id: O10
    category: implementation
    severity: medium
    claim: "Treating a malformed multi-pattern Permission as a 'non-match' makes a parse limitation indistinguishable from a real safety gap, both producing a blocking exit-1."
    evidence: "Spec Risks treats malformed field as a blocking finding."
    disposition: amend
    disposition_rationale: "A Permission field that does not parse to a single allowlist-shaped pattern (multi-pattern, or non-pattern text) is reported as a distinct DIAGNOSTIC line, not a blocking FAIL. The blocking exit-1 is reserved for a well-formed pattern with no matching allowlist entry — a genuine gap."
  - id: O11
    category: scope
    severity: medium
    claim: "FR6 requires Layer 0 to cover scenarios depending on per-machine settings files with no fixture-injection mechanism specified."
    evidence: "Scenarios depend on allowlist readability; FR3 read the user layer; no path override given."
    disposition: amend
    disposition_rationale: "The check takes a project-dir argument and (per O5) reads only project settings under it, so Layer 0 tests point it at hermetic fixture directories with synthetic .claude/settings.json + HARNESS.md. No user-layer read => fully reproducible tests."
  - id: O12
    category: specification quality
    severity: low
    claim: "Allowlist set construction across settings layers lacks a stated precedence/union rule."
    evidence: "Spec names de-duplication but not the merge rule."
    disposition: amend
    disposition_rationale: "State the rule: the allowlist is the UNION of .permissions.allow[] across the readable PROJECT settings files (.claude/settings.json and .claude/settings.local.json), de-duplicated. A pattern present in either satisfies an affordance."
---

# Objection record — affordance chained constraints (spec mode)

Twelve objections: 1 critical, 4 high, 6 medium, 1 low. The critical (O1)
and two highs (O3, O4) re-opened the O8 universal-fire / silent-disable
failure modes the gate was meant to close; O2/O5/O6/O9 concern where and
whether the pair actually enforces. All adjudicated 2026-06-16 — every
objection **amend**. Two resolutions are load-bearing and user-confirmed:
(a) the blocking direction skips hook-mode affordances and reads project
settings only; (b) gating moves from a section sentinel to per-entry example
markers, and the blocking constraint ships `Scope: pr`. The amended design
is captured in the spec's Adjudication section.

## Explicitly not challenged

- String-equality matching (settled in the parent spec's O5).
- The asymmetric blocking/advisory split (parent O9).
- One check script with a `--direction` flag.
- jq-missing => exit-0-unverified for tooling absence.
- The minor version bump and the steps 6-8 deferrals.
