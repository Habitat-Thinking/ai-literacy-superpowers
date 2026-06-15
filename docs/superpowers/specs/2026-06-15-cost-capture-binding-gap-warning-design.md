# Cost-Capture Binding-Gap Warning — Capability Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-15 |
| Status | Diaboli-complete — 10 objections raised, all accepted and absorbed; ready for plan/implementation |
| Author | claude-opus-4-8[1m] (interactive session with russmiles) |
| Capability | At capture time, `/cost-capture` tells the human whether the snapshot it just wrote will let the prospective `cost-estimator` ground a dollar figure — recorded as a structured, checkable line — closing the binding-gap feedback loop where a human can act |
| Fixes | #413 |
| Plugin version target | `ai-literacy-superpowers` v0.50.0 → v0.51.0 |
| Diaboli record | `docs/superpowers/objections/cost-capture-binding-gap-warning-design.md` (10 objections, all accepted) |

---

## 1. Problem

#412 (v0.50.0) made the cost-estimation binding resolve tiers by **model
family** and price an absent estimating-tier family by a disclosed
**cross-tier proxy**. Most real snapshots now ground cost. But whether a
freshly-captured snapshot will let the estimator ground cost is only
discovered **downstream**, estimate by estimate — never at the moment of
capture, when the human is in the loop and could act. This is the #411
silent-feedback latency one step removed.

## 2. The capability — a capture-time, informational advisory

`/cost-capture` gains a **binding-gap advisory**: after it writes and
structurally validates the snapshot, it reports whether prospective
estimates will ground, proxy, or omit cost against it, and records that
outcome as a **structured line in the snapshot's `## Observations`**.

Three design commitments fix the diaboli's load-bearing concerns:

1. **A thin family-PRESENCE check, not a pricing re-run (diaboli O2).** The
   advisory needs only to detect **which estimating-tier families are
   present** in the Model Breakdown: is there a key matching the
   `claude-opus-4` stem? a key matching `claude-sonnet-4`? — applying the
   binding table's **stem + delimiter rule by reference**
   (`skills/cost-estimation/references/estimate-record-format.md`). It does
   **not** re-implement family aggregation, rate derivation, or the
   dearest-present proxy selection — those stay estimator-only. The command
   shares two stems and one delimiter rule, **not** the pricing procedure,
   so the drift surface is minimal.
2. **Informational, never a gate (diaboli O5).** The advisory **emits no
   pass/fail token, never modifies the snapshot, and runs and prints
   regardless of the step-10 validation result**. It is not a sub-step of
   the mandatory structural checkpoint; a thin snapshot is a perfectly
   valid cost snapshot (it grounds spend trends regardless of
   estimating-tier coverage).
3. **A checkable artefact, not just spoken prose (diaboli O7).** The
   outcome is written as one line in the snapshot's `## Observations`:

   ```text
   Cost-estimate grounding: <grounds | proxied (<absent tiers>) | omitted (no estimating-tier family) | omitted (no per-model breakdown)>
   ```

   So the advisory is falsifiable (a validation/Layer-1 check can assert
   the line's presence and shape), a consumer can corroborate it, and the
   conversational advisory merely echoes the recorded line.

## 3. The four outcomes

After the snapshot is written, classify by **estimating-tier family
presence** in the Model Breakdown (totalling over all four grounding
states — diaboli O1):

| Outcome | Condition | `Observations` line + advisory |
| --- | --- | --- |
| **Grounds directly** | both `claude-opus-4` **and** `claude-sonnet-4` families present | `Cost-estimate grounding: grounds`. No warning. |
| **Grounds, but proxied** | ≥1 estimating-tier family present, but not both | `Cost-estimate grounding: proxied (<absent tier(s)>)`. INFO, **conditional** (diaboli O3): "estimates that **exercise** the absent tier(s) — `<Standard / Most capable>` (the `<claude-sonnet-4 / claude-opus-4>` family) — will be **proxied** (`cost_basis: snapshot-actuals-proxied`, a deliberate over-estimate); estimates exercising only the present family ground directly." Remedy names the **absent** family as the enrichment target (diaboli O6) — *only when there is spend to record* (see honesty note). |
| **Omitted — no estimating-tier family** | a Model Breakdown exists but neither `claude-opus-4` nor `claude-sonnet-4` family is present (e.g. a haiku-only snapshot) | `Cost-estimate grounding: omitted (no estimating-tier family)`. WARN, **unconditional** (every estimate exercises ≥1 estimating tier, so all omit): "prospective `/cost-estimate` will **omit cost** — no `claude-opus-4` or `claude-sonnet-4` family present (haiku and other families are valid breakdown rows but are **not** estimating tiers). If these are a newer model generation, the binding stem table needs updating for it." |
| **Omitted — no per-model breakdown** | no Model Breakdown was recorded (step 4 skipped — "if not available") or the snapshot is structurally without one (states 1–2) | `Cost-estimate grounding: omitted (no per-model breakdown)`. INFO: "no per-model breakdown recorded, so prospective `/cost-estimate` cannot ground cost (a **structural** gap, not a family mismatch). Record per-model rows **if your dashboard exposes them**." |

**Honesty note (diaboli O8).** The advisory distinguishes *thin because
per-model data was not recorded/available* (actionable: record it) from
*thin because the period's work genuinely used only some tiers* (**not** a
defect — the honest note is "no Standard-tier spend this period; nothing to
do"). It **never** nudges the human to add a model row for spend that did
not occur. The "proxied" outcome's remedy is offered as *"if that tier had
spend the dashboard can break out"*, not an imperative.

**No issue number in shipped text (diaboli O4).** The newer-generation
remedy describes the action ("the binding stem table needs updating") with
**no** GitHub issue number in the command's user-facing output. (The
tracking issue is #414; it lives in the spec/CHANGELOG, not the advisory.)

## 4. Where it lives

- A new **informational step after the step-10 validation checkpoint and
  before the step-11 commit** — explicitly named an advisory, with the §2.2
  non-gating constraints stated inline.
- It **writes** the `Cost-estimate grounding:` line into the snapshot's
  `## Observations` section (so the commit captures it) and **echoes** it
  conversationally; the existing **step-12 summary** gains a
  `Cost-estimate grounding:` line carrying the same outcome.
- The `cost-tracking` skill gains a **scoped pointer** (diaboli O10): a
  captured snapshot's estimating-tier coverage drives whether the
  prospective `cost-estimation` sibling can ground cost, **and** an
  annotation that a non-estimating-family row (e.g. haiku) is a valid
  breakdown entry but does not by itself ground cost — reconciling the
  existing example rather than implying it is deficient.

## 5. Out of scope

- **Changing the binding or the estimator** — #413 is a pure *consumer* of
  the v0.50.0 family-stem rule (presence detection only); no binding, proxy
  logic, rate maths, or format field.
- **Blocking or auto-fixing a thin snapshot** — informational only.
- **The stem-table maintenance itself** — that is #414; #413 describes the
  action when a generation rollover is the likely cause but does not
  implement the maintenance.
- **A new estimating tier** (Haiku/Inexpensive).

**Alternative weighed (diaboli O9).** The gap could instead be surfaced
**consumer-side** (in `/harness-health` or the estimator, where resolution
already runs), avoiding even the thin presence check in `/cost-capture`.
**Capture-time was chosen for timeliness** — the human is in the loop at
capture and can act immediately. The trade is accepted; and because the
outcome is now a structured `Observations` line (§2.3), consumer-side
surfaces can *also* read it later **without** re-resolving, so the
placement is not exclusive.

## 6. Spec-mode diaboli — outcomes

The spec-mode `/diaboli` gate raised **10 objections — 3 high, 5 medium, 2
low — all accepted**
(`docs/superpowers/objections/cost-capture-binding-gap-warning-design.md`).
The highs reshaped the design: O2 (thin presence check, not a pricing
re-run), O7 (a structured, falsifiable `Observations` line), O3
(conditional proxy wording). O1 added the no-per-model-data outcome; O4–O10
absorbed as above.

## 7. References

- Issue #413; sibling follow-on #414 (stem-table maintenance); #411 / #412.
- `ai-literacy-superpowers/commands/cost-capture.md`;
  `ai-literacy-superpowers/skills/cost-tracking/SKILL.md`.
- The family-stem binding table:
  `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`.
