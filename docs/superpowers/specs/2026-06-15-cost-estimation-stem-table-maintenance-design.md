# Cost-Estimation Family Stem-Table Maintenance — Capability Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-15 |
| Status | Diaboli-complete — 12 objections raised, all accepted; design pivoted (drop the GC staleness rule → deterministic mention-consistency check); ready for plan/implementation |
| Author | claude-opus-4-8[1m] (interactive session with russmiles) |
| Capability | Keep the cost-estimation tier→model **family stem table** singly-sourced and internally consistent — a declared canonical list, an add-and-retire maintenance discipline, and a deterministic check that the cost files do not drift from it |
| Fixes | #414 |
| Plugin version target | `ai-literacy-superpowers` v0.51.0 → v0.52.0 |
| Diaboli record | `docs/superpowers/objections/cost-estimation-stem-table-maintenance-design.md` (12 objections, all accepted) |

---

## 1. Problem (re-framed after the diaboli)

Slice #412 (v0.50.0) made the cost-estimation binding resolve tiers by
**model family stem** (`claude-opus-4`, `claude-sonnet-4`). Issue #414
(diaboli O8 of #411) asked how those stems stay current as model
generations roll over. The spec-mode diaboli separated two problems the
original framing conflated:

- **External staleness** — a new model generation outran the stems. This is
  **already adequately covered**: #412 turns an unresolved family into a
  *loud, disclosed* omission or cross-tier proxy (never a silent wrong
  rate), and #413 flags it at **capture time**. A periodic snapshot-content
  detector for this was specced first but the diaboli refuted it — it
  false-positives on every legitimate cheap-tier-only month (O1),
  false-negatives on a *staggered* rollover where one stem still resolves
  (O2, the actual feared case), and cannot even cover the
  rolled-over-but-not-recaptured gap it was motivated by (O9). It is
  **dropped**.
- **Internal drift** — the stems appear in **~8 files** with no single
  enforced source (O3). After the *next* stem bump, those mentions can
  silently disagree. This is the genuinely-unsolved problem #414 now
  targets, with a **deterministic** check (O5).

## 2. Options weighed

- **Option 1 — canonical source + maintenance ritual.** Kept (the backing).
- **Option 2 — derive stems from `MODEL_ROUTING.md`.** **Rejected, and
  confirmed by inspection:** the only model-family names in
  `MODEL_ROUTING.md` / its template are **illustrative examples inside an
  HTML comment**; the routing tables themselves name **abstract tiers**
  (the abstraction the binding table exists to map). Deriving stems from it
  would require restructuring routing to authoritatively name families it
  deliberately omits.
- **Option 3 — snapshot-content GC staleness rule.** **Dropped** (the
  diaboli refuted it; external staleness is already covered — §1).
- **Option 5 (diaboli) — deterministic mention-consistency check.**
  **Adopted as the core mechanism.** Deterministic (no agent discretion,
  O4), no operating-state false positive (O1), behaviourally falsifiable
  (O6), and it directly enforces the single-source discipline (O3).

## 3. The capability

### 3.1 A declared canonical stem source + maintenance note

The binding table in
`skills/cost-estimation/references/estimate-record-format.md` is the
**single canonical source** of the estimating-tier family stems. It gains:

- an **authoritative, parseable stem declaration** — the estimating-tier
  family stems listed in a form a test can extract (a clearly-delimited
  list), so "the canonical set" is machine-defined, not prose-implied;
- a **Stem-table maintenance note** with **add-and-retire** semantics (O10),
  *not* replace-in-place:
  - a new model generation **adds** a stem (e.g. `claude-opus-5` alongside
    `claude-opus-4`); both coexist while transition-period snapshots may
    carry either — consistent with the binding table's cross-generation
    family aggregation;
  - a stem is **retired** only when no snapshot in the retention window
    still carries its family;
  - a stem is **never silently replaced** (which would regress a
    transition-quarter snapshot still keyed by the old family).

The other cost files (`cost-estimation/SKILL.md`, `cost-tracking/SKILL.md`,
the `cost-estimator` agent, the `cost-capture` command) **reference** this
table as the authority; the §3.2 check enforces that they do not drift from
it.

### 3.2 A deterministic mention-consistency check (the core — O5)

A **deterministic Layer-1 structural test** over the plugin's own cost
files:

- **Extract** the canonical estimating-tier stem set from the binding
  table's authoritative declaration (§3.1).
- **Assert** that no consumer cost file references an estimating-tier
  family stem **absent** from the canonical set — i.e. every
  `claude-opus-*` / `claude-sonnet-*` *binding-stem* token used in a
  consumer cost file is one the canonical table declares.
- It runs in the **CI-gated** structural layer (`test_layer1_structural.py`
  family), so a stem bump that updates one file but not the canonical
  declaration — or a consumer that introduces an undeclared stem — **fails
  CI loudly**.

This is the falsifiable behaviour O6 demanded: it **fires** on a drifted or
undeclared stem and is **silent** on consistency, asserted directly over
file contents — no agent, no snapshot, no operating-state ambiguity.

**Scope of the check.** It guards the **plugin repo's own cost files**
(where the stems live and could drift after a bump). Downstream harnessed
projects install the plugin but do not edit these files, so internal drift
is a plugin-repo concern only — there is **no** template GC rule to
propagate (resolving O12).

### 3.3 Relationship to #412 / #413

- **#412** keeps external staleness loud (omission/proxy with disclosure).
- **#413** flags external staleness at capture time (the
  `Cost-estimate grounding:` Observations line).
- **#414** (this slice) keeps the stem table **internally consistent and
  singly-sourced** so a future bump cannot silently desync the ~8 files.

Three disjoint surfaces over one binding rule; none re-implements the
estimator's pricing, and #414 does **not** re-resolve snapshots (O7).

## 4. Surfaces changed

1. `skills/cost-estimation/references/estimate-record-format.md` — the
   authoritative parseable stem declaration + the add-and-retire
   maintenance note (§3.1).
2. `tdad_tests/tests/test_layer1_structural.py` — the deterministic
   mention-consistency test (§3.2), CI-gated.
3. Version triplet + CHANGELOG (the five CI-checked locations; minor bump).

(No HARNESS.md / template GC rule, no MODEL_ROUTING change, no
estimate-record format/field change.)

## 5. Out of scope

- **A periodic external-staleness detector** — refuted by the diaboli;
  external staleness is covered by #412 + #413 (§1).
- **Auto-bumping or auto-fixing stems** — a pricing-binding change is
  human-reviewed; the maintenance note is the human ritual, the §3.2 test is
  the drift guard.
- **Deriving stems from `MODEL_ROUTING.md`** (Option 2, rejected).
- **Changing the binding, the proxy, or the estimate-record format** — the
  stem *values* and resolution rule are unchanged.

## 6. Spec-mode diaboli — outcomes

The spec-mode `/diaboli` gate raised **12 objections — 5 high — all
accepted**
(`docs/superpowers/objections/cost-estimation-stem-table-maintenance-design.md`).
The five highs refuted the original snapshot-content GC rule (O1
false-positive, O2 false-negative, O4 no agent stem logic, O6 untestable,
O3 single-source contradicted); the human disposed the design to **drop
that rule** (external staleness covered by #412/#413 — O8) and **adopt the
deterministic mention-consistency check** (O5) plus the canonical source +
add-and-retire note (O10). Option 2 rejection confirmed by inspection.

## 7. References

- Issue #414; diaboli O8 of #411; the siblings #412 (family matching) and
  #413 (capture-time advisory).
- `skills/cost-estimation/references/estimate-record-format.md` (canonical
  stems / binding table).
- `tdad_tests/tests/test_layer1_structural.py` (the deterministic check).
