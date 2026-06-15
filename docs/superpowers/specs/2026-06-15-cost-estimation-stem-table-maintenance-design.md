# Cost-Estimation Family Stem-Table Maintenance — Capability Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-15 |
| Status | Drafted — ready for spec-mode diaboli, then plan/implementation |
| Author | claude-opus-4-8[1m] (interactive session with russmiles) |
| Capability | Keep the cost-estimation tier→model **family stem table** current as model generations roll over — a single canonical source plus a periodic GC staleness check — so a renamed family does not silently degrade cost grounding |
| Fixes | #414 |
| Plugin version target | `ai-literacy-superpowers` v0.51.0 → v0.52.0 |

---

## 1. Problem

#412 (v0.50.0) made the cost-estimation binding resolve tiers by **model
family stem** (`claude-opus-4` → Most capable, `claude-sonnet-4` →
Standard), matched with a delimiter rule. Diaboli O8 named the residual:
the stems are a **hand-maintained** table, so a **renamed family a
generation later** (`claude-opus-5`, `claude-sonnet-5`) will not match the
`*-4` stems. The miss is *signalled* (it falls through to a loud
omission, not a silent wrong rate — unlike #411), and #413 already flags
it at capture time ("if these are a newer model generation, the binding
stem table needs updating"). But two gaps remain:

1. **No periodic detection.** #413 only fires when a human runs
   `/cost-capture`. A repo that has rolled onto a new model generation but
   not re-captured will quietly stop grounding cost until someone notices.
2. **No single source / maintenance ritual.** The stem values appear in
   several cost files; there is no one declared canonical list, and no
   stated discipline for bumping them per model generation.

## 2. Options weighed (#414 named three)

- **Option 1 — documented maintenance ritual / single source.** Declare one
  canonical stem list and a per-generation bump discipline.
- **Option 2 — derive the stems from `MODEL_ROUTING.md`.** **Rejected.**
  `MODEL_ROUTING.md` deliberately names **abstract tiers** ("Most capable",
  "Standard") and **no concrete model families** — that abstraction is the
  very reason the binding table exists (to map abstract tiers to
  representative families). Deriving stems from MODEL_ROUTING would require
  restructuring it to name model families, coupling routing to model ids it
  intentionally omits. Not worth the coupling.
- **Option 3 — a GC fitness-function staleness check.** A periodic check
  that flags when the latest cost snapshot's models no longer resolve to
  any stem — detection, not auto-change.

**Chosen: Option 3 (the active mechanism) + Option 1 (the backing).** A GC
staleness rule is exactly the idiom HARNESS.md already uses (Snapshot
staleness, Documentation freshness, …), and detection-without-auto-change
is correct for a **pricing-relevant** binding (it must never silently
re-point itself at a different family). Option 1 gives the rule a single
canonical target to point at.

## 3. The capability

### 3.1 A canonical stem source + maintenance note (Option 1)

The binding table in
`skills/cost-estimation/references/estimate-record-format.md` is declared
the **single canonical source** of the family stems. It gains a short
**Stem-table maintenance** note: the stems (`claude-opus-4`,
`claude-sonnet-4`) are a deliberately-maintained table, bumped **per model
generation** (a new generation adds/replaces a stem), and the
maintenance is driven by the GC rule (§3.2). The other cost files
(`cost-estimation/SKILL.md`, `cost-tracking/SKILL.md`, the `cost-estimator`
agent, the `cost-capture` command) **reference** that table as the
authority for the stem values rather than asserting an independent list —
the canonical-source discipline, not a rip-and-replace of every contextual
mention.

### 3.2 A GC staleness rule (Option 3)

A new garbage-collection rule, in the GC idiom:

```text
### Cost-estimation binding-stem staleness

- **What it checks**: Whether the latest observability/costs/ snapshot's
  Model Breakdown keys still resolve to ≥1 estimating-tier family stem in
  the cost-estimation binding table (claude-opus-4 / claude-sonnet-4, by
  the stem + delimiter rule). If NONE resolve, the stem table is likely
  stale for a new model generation.
- **Frequency**: monthly (aligned with the cost cadence)
- **Enforcement**: agent
- **Tool**: harness-gc agent
- **Auto-fix**: false
```

It is added to **this project's `HARNESS.md`** (so it runs here) and to the
**plugin template** `ai-literacy-superpowers/templates/HARNESS.md` (so
harnessed projects inherit it), and catalogued in the
`garbage-collection` skill's rule catalogue alongside the other staleness
rules.

- **Detection, never auto-fix** (`Auto-fix: false`): re-pointing a pricing
  binding is a human, reviewed change. The rule *flags*; a human bumps the
  stem in the canonical source.
- **Agent-enforced, self-describing**: the harness-gc agent already runs
  agent rules declared in HARNESS.md; this rule needs **no** agent code
  change — its "What it checks" is the whole instruction (read the latest
  snapshot, apply the binding table's stem+delimiter presence check).
- **Honest framing**: a "no estimating-tier family resolves" result can
  mean *stale stems* (a new generation) **or** *a genuinely cheap-tier-only
  snapshot* (e.g. haiku-only). The rule's finding states both possibilities
  — it points at the stem table as the **likely** cause for a new
  generation, not the certain one — mirroring #413's no-fabrication
  honesty.

### 3.3 Relationship to #413

#413 catches the binding gap **at capture time** (per-`/cost-capture`);
#414 catches it **periodically** (per GC cadence), even with no new
capture, and frames it specifically as **stem-table staleness**. They
share the same family-presence check (the binding table's stem+delimiter
rule) — one source of truth — and neither re-implements the estimator's
pricing.

## 4. Surfaces changed

1. `skills/cost-estimation/references/estimate-record-format.md` — the
   canonical-source declaration + Stem-table maintenance note (§3.1).
2. `HARNESS.md` (this project) — the new GC rule.
3. `ai-literacy-superpowers/templates/HARNESS.md` — the new GC rule (so
   harnessed projects inherit it).
4. `skills/garbage-collection/` (the GC rule catalogue) — catalogue the new
   rule alongside the other staleness rules.
5. A TDAD scenario / Layer-1 assertion that the rule is declared in the
   template and the maintenance note in the canonical source.
6. Version triplet + CHANGELOG (the five CI-checked locations; minor bump).

## 5. Out of scope

- **Auto-bumping the stems** — detection only; a pricing binding change is
  human-reviewed.
- **Deriving stems from `MODEL_ROUTING.md`** (Option 2 — rejected, §2).
- **Changing the binding, the proxy, or the estimate-record format** — the
  stem *values* and the resolution rule are unchanged; this slice is about
  keeping them current and singly-sourced.
- **A deterministic script** for the check — the agent-enforced GC rule is
  sufficient; a deterministic snapshot-parsing tool can come later if the
  rule proves high-volume.

## 6. Spec-mode diaboli

This spec goes through the spec-mode `/diaboli` gate; objections recorded
at `docs/superpowers/objections/cost-estimation-stem-table-maintenance-design.md`
and absorbed.

## 7. References

- Issue #414; diaboli O8 of #411
  (`docs/superpowers/objections/cost-estimation-family-matching-design.md`);
  the capture-time sibling #413.
- `skills/cost-estimation/references/estimate-record-format.md` (the binding
  table / canonical stems).
- `HARNESS.md` and `ai-literacy-superpowers/templates/HARNESS.md` (GC rules);
  `skills/garbage-collection/` (the catalogue).
