# Cost-Estimation Tier→Model Family Matching — Capability Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-15 |
| Status | Drafted — ready for spec-mode diaboli, then plan/implementation |
| Author | claude-opus-4-8[1m] (interactive session with russmiles) |
| Capability | Make the cost-estimation tier→model binding resolve by **model family** (not an exact key string), so a real captured snapshot grounds a dollar figure instead of silently omitting cost |
| Fixes | #411 |
| Plugin version target | `ai-literacy-superpowers` v0.49.0 → v0.50.0 (behaviour change to the cost-estimation methodology) |

---

## 1. Problem

The cost-estimation methodology grounds a dollar figure by binding each
MODEL_ROUTING tier to a **representative model key** and reading that
model's blended rate from the latest `observability/costs/<date>-costs.md`
snapshot's Model Breakdown. The binding table
(`skills/cost-estimation/references/estimate-record-format.md`) names those
keys **literally**: Most capable → `claude-opus-4`, Standard →
`claude-sonnet-4`. The `cost-estimator` agent's mechanical check
(`agents/cost-estimator.agent.md`, "Missing model key") omits cost when a
named key is **absent** from the snapshot.

The repo's only snapshot, `observability/costs/2026-06-13-costs.md`, keys
its Model Breakdown as **`claude-opus-4-8`** and **`claude-haiku-4-5`** —
the *actual* model ids. Neither literal binding key (`claude-opus-4`,
`claude-sonnet-4`) is present, so **every** estimate omits cost — even
though that snapshot was captured precisely so the estimator could ground
cost (its prose flags the ~$0.83/1M Opus blended rate for exactly this).
Observed across six consecutive estimates (#363–#368). The omission is
**silent** (a cost-omitted record is valid-and-complete), so nothing
surfaces the mismatch. (#411.)

## 2. The fix — family matching (firm)

The binding resolves a tier's representative by **model-family stem**, not
an exact string. A snapshot Model Breakdown key `K` resolves to a tier `T`
**iff `K`, lowercased, starts with `T`'s family stem**:

| Tier | Family stem | Matches (examples) |
| --- | --- | --- |
| Most capable | `claude-opus-4` | `claude-opus-4`, `claude-opus-4-8`, `claude-opus-4-1`, … |
| Standard | `claude-sonnet-4` | `claude-sonnet-4`, `claude-sonnet-4-5`, … |
| Standard / Capable (split) | low `claude-sonnet-4` … high `claude-opus-4` | as above, per end |

Rules:

- **Prefix-on-family-stem**, case-insensitive. The stems are the
  family roots `claude-opus-4` / `claude-sonnet-4` (a major family the
  routing tiers actually map to), not full ids.
- **Multiple matches in one family are aggregated** into a single blended
  family rate: sum the matching rows' `estimated_cost` and their
  `(input + output)` tokens, then `$/token = Σcost ÷ Σtokens`. This uses
  all of a family's observed data and stays deterministic.
- `claude-haiku-4-5` and other non-opus-4/non-sonnet-4 keys resolve to
  **no** estimating tier (the binding table has only Most capable /
  Standard / the split). They are simply not used for binding — their
  presence neither grounds nor blocks a tier.
- The match is documented and deterministic — **not** agent discretion.
  The agent still holds no write tool and applies the table mechanically.

This is necessary and unambiguous, and it directly answers #411. With it,
the 2026-06-13 snapshot grounds the **Most capable** tier
(`claude-opus-4-8` → Most-capable rate). It does **not**, on its own,
ground the **Standard** tier from that snapshot, because the snapshot
contains no `claude-sonnet-4*` row — which §3 addresses.

## 3. The partial-snapshot decision (the genuine fork)

Family matching alone leaves a real gap: the only snapshot we have is
**opus-only** (the single-machine session it captured ran ~100% on Opus).
A typical multi-stage task exercises Standard-tier stages (tdd-agent,
integration-agent) whose family (`claude-sonnet-4*`) is **absent**. So
after §2, those tasks would *still* omit cost. Two honest options:

### Option A — precise omission (conservative)

`cost_usd` is present **iff every exercised tier's family resolves** in
the snapshot; otherwise omit, but with a **precise** `Excluded`
disclosure naming the **specific missing tier family** (e.g. "Standard
tier — no `claude-sonnet-4*` row in the snapshot"), rather than today's
generic "keys absent". No approximation is introduced.

- *Pro:* maximally honest; no new approximation class; smallest change.
- *Con:* does **not** relieve #411's symptom for the current opus-only
  snapshot — multi-tier tasks still omit (truthfully) until a snapshot
  containing Sonnet data is captured. Family matching only fixes
  Most-capable-only tasks and the disclosure quality.

### Option B — disclosed cross-tier proxy (recommended)

When an exercised tier's family is **absent** but the snapshot has a
usable rate for **another** family, bind the missing tier to the
**dearest present family's** rate, **disclosed** as a cross-tier proxy and
with `confidence.cost` forced to **`low`**:

- The proxy uses an **observed snapshot rate** (this repo's actual spend),
  never a vendor list price — the no-list-price-fallback rule is intact.
- **Dearest-present** is deliberately conservative: proxying Standard to
  the Opus rate **over**-states (never under-states) the Standard cost, so
  a "can I afford this?" read is not lulled by an optimistic figure.
- The `Included`/`Confidence rationale` prose **names** every proxied
  tier ("Standard priced via a cross-tier proxy at the Most-capable rate —
  the snapshot carries no Sonnet data"), and `confidence.cost: low` is
  forced whenever any proxy is used.
- Only applies when **≥1** family is present (a usable rate exists). With
  **no** usable Model Breakdown at all, the existing state-2 omission is
  unchanged.

- *Pro:* the 2026-06-13 snapshot now **grounds cost** (Most capable
  directly; Standard/split-low via the disclosed Opus proxy), matching the
  snapshot author's stated intent and relieving #411 with the data we
  have.
- *Con:* introduces a new, disclosed approximation class; the proxied
  figure is a deliberate over-estimate.

**Recommendation: Option B**, because #411's intent is "real snapshots
should ground cost", the proxy is grounded in observed actuals (not list
price), it is conservative, loudly disclosed, and confidence-capped — and
it is the behaviour the captured snapshot's own prose anticipates. Option
A is the fallback if the diaboli/human judges the proxy too strong; family
matching (§2) ships either way and is itself a real improvement.

**This is the load-bearing decision for the spec-mode diaboli and the
human to dispose.**

## 4. Grounding-state changes

The three grounding states (`estimate-record-format.md`) are refined:

- **State 1 (no snapshot):** unchanged — omit.
- **State 2 (snapshot, no usable Model Breakdown / no family resolves at
  all):** unchanged — omit, with the "no usable per-model breakdown"
  cause. The "missing model key" trigger is **reworded** to "no tier
  family resolves" (a tier family resolves by §2, not an exact key).
- **State 3 (≥1 tier family resolves):** `cost_usd` **present**. Under
  Option B, tiers whose family is absent are **proxied** (dearest present
  family) with the disclosure + `confidence.cost: low`; under Option A,
  cost is present **only** if *all* exercised families resolve, else state
  2.

No estimate-record **format** field changes — `cost_usd`, `cost_basis:
snapshot-actuals`, `confidence.cost` are as today. (A proxy is disclosed
in prose, not a new field — consistent with how the methodology discloses
other caveats.) The blended-rate-skew simplification is unchanged.

## 5. Surfaces changed

1. `skills/cost-estimation/references/estimate-record-format.md` — the
   binding table (family stems + aggregation), the "deriving a per-model
   rate" step (resolve by family), the three grounding states (§4), and
   (Option B) the proxy rule + its disclosure obligation.
2. `skills/cost-estimation/SKILL.md` — the grounding-methodology section
   mirrors the binding table; updated in lockstep.
3. `agents/cost-estimator.agent.md` — the mechanical binding check
   (currently "Missing model key" → omit) becomes family resolution +
   (Option B) the proxy step; the worked-example caveat about
   `claude-opus-4-8` is updated to reflect that it now **resolves** to
   Most capable.
4. Tests — a TDAD scenario / Layer-1 assertion that family matching
   resolves `claude-opus-4-8` → Most capable and (Option B) that an
   opus-only snapshot grounds cost with the proxy disclosure.
5. Version triplet + CHANGELOG (the five `ai-literacy-superpowers`
   CI-checked locations; minor bump).

## 6. Out of scope

- **Capture-time validation** (warning in `/cost-capture` when a
  snapshot's keys won't bind) — a complementary idea from #411, deferrable
  to its own slice; family matching makes most snapshots bind anyway.
- **Per-direction (input/output) rates** — the blended-rate skew stays.
- **Calibration / per-PR actuals** — untouched.
- **Adding new tiers** (e.g. an `Inexpensive`/Haiku estimating tier) — the
  binding table keeps Most capable / Standard / split.

## 7. Spec-mode diaboli

This spec goes through the spec-mode `/diaboli` gate before
implementation — the §3 proxy decision especially. Objections recorded at
`docs/superpowers/objections/2026-06-15-cost-estimation-family-matching-design.md`
and absorbed here.

## 8. References

- Issue #411; the 2026-06-15 reflection (`REFLECTION_LOG.md`).
- `skills/cost-estimation/references/estimate-record-format.md` (binding table, grounding states).
- `skills/cost-estimation/SKILL.md`; `agents/cost-estimator.agent.md`.
- `observability/costs/2026-06-13-costs.md` (the opus-only snapshot).
