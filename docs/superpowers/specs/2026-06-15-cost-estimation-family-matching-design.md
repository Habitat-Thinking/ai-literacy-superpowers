# Cost-Estimation Tier→Model Family Matching — Capability Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-15 |
| Status | Diaboli-complete — 12 objections raised, all accepted; §3 fork disposed to **Option B′** (engineered proxy); ready for plan/implementation |
| Author | claude-opus-4-8[1m] (interactive session with russmiles) |
| Capability | Make the cost-estimation tier→model binding resolve by **model family** (not an exact key string), and price a tier whose family is absent from the snapshot via a **distinctly-typed, disclosed proxy** — so a real captured snapshot grounds a dollar figure instead of silently omitting cost |
| Fixes | #411 |
| Plugin version target | `ai-literacy-superpowers` v0.49.0 → v0.50.0 (behaviour change to the cost-estimation methodology) |
| Diaboli record | `docs/superpowers/objections/cost-estimation-family-matching-design.md` (12 objections, all accepted) |

---

## 1. Problem

The cost-estimation methodology grounds a dollar figure by binding each
MODEL_ROUTING tier to a **representative model key** and reading that
model's blended rate from the latest `observability/costs/<date>-costs.md`
snapshot's Model Breakdown. The binding table names those keys
**literally**: Most capable → `claude-opus-4`, Standard →
`claude-sonnet-4`. The `cost-estimator` agent omits cost when a named key
is **absent**.

The repo's only snapshot, `observability/costs/2026-06-13-costs.md`, keys
its Model Breakdown as **`claude-opus-4-8`** and **`claude-haiku-4-5`** —
the *actual* model ids. Neither literal binding key is present, so **every**
estimate omits cost — even though that snapshot was captured precisely so
the estimator could ground cost. Observed across six consecutive estimates
(#363–#368); the omission is **silent** (a cost-omitted record is
valid-and-complete). (#411.)

This spec has **two parts**, kept separable (diaboli O10):

- **§2 — family matching** (the firm core; the literal #411 fix).
- **§3 — the engineered proxy** (Option B′; pricing a tier whose family is
  absent, disposed by the human after the diaboli broke the naïve proxy).

## 2. Family matching (firm core)

The binding resolves a tier's representative by **model-family stem**, not
an exact string. A snapshot Model Breakdown key `K` resolves to a tier `T`
**iff `K`, lowercased, starts with `T`'s family stem _and_ the character
after the stem is `-` or end-of-string** (the delimiter rule, diaboli O8):

| Tier | Family stem | Matches | Does **not** match |
| --- | --- | --- | --- |
| Most capable | `claude-opus-4` | `claude-opus-4`, `claude-opus-4-8`, `claude-opus-4-1` | `claude-opus-40`, `claude-opus-4o`, `claude-opus-5` |
| Standard | `claude-sonnet-4` | `claude-sonnet-4`, `claude-sonnet-4-5` | `claude-sonnet-45`, `claude-sonnet-5` |
| Standard / Capable (split) | low `claude-sonnet-4` … high `claude-opus-4` | as above, per end | — |

- **Delimiter-bounded prefix**, case-insensitive — closes the
  false-positive match (`claude-opus-40`) the bare prefix would admit (O8).
- **Multiple matches in one family are aggregated** into one blended family
  rate: `$/token = Σ estimated_cost ÷ Σ (input + output) tokens` over the
  matching rows. **When >1 row is aggregated, the agent discloses it** in
  `Confidence rationale` (mirroring the blended-rate-skew disclosure) —
  cross-generation blends are named, not silent (O7).
- `claude-haiku-4-5` and any non-opus-4 / non-sonnet-4 key resolve to **no**
  estimating tier (the table has only Most capable / Standard / the split).
  They are never a binding *or* a proxy source — neither grounds nor blocks
  a tier (O9).
- **Stem-table maintenance (O8 false-negative side):** a future renamed
  family (e.g. `claude-opus-5`) deliberately does **not** match — it is a
  *signalled* miss (it drives state-3-with-no-family → state 2 omission,
  which is loud), and the stem table is a per-model-generation maintenance
  point, noted in §6. This is the opposite of #411's *silent* miss.

With §2 alone the 2026-06-13 snapshot grounds the **Most capable** tier
(`claude-opus-4-8` → Most-capable rate). It does not, alone, ground the
**Standard** tier from that snapshot (no `claude-sonnet-4*` row) — which §3
handles.

## 3. The engineered proxy (Option B′)

When an exercised tier's estimating family is **absent** from the snapshot
but **≥1 estimating-tier family resolves** (a usable rate exists), the
missing tier is priced by a **proxy** rather than omitted — but as a
**distinctly-typed, disclosed, direction-forced** figure, not a figure
masquerading as direct grounding. (The naïve "reuse `snapshot-actuals`,
disclose in prose" proxy was broken by diaboli O1/O2/O3/O5 and is **not**
what ships.)

The engineered proxy:

1. **Distinct basis (O2/O11/O5).** A record with **any** proxied tier
   carries the new, additive `cost_basis` value
   **`snapshot-actuals-proxied`** (not `snapshot-actuals`). This is
   machine-distinguishable: a consumer keys on `cost_basis`, not on prose
   or the (routinely-`low`) cost confidence. Fully-direct records keep
   `snapshot-actuals`. Backward-compatible — old records and unaware
   consumers are unaffected.
2. **Dearest-present source, over-stating and saying so (O3/O4).** The
   missing tier binds to the **dearest present estimating family's** rate.
   A proxied record **forces `failure_direction: likely-overrun`** and the
   prose states the figure is a **deliberate over-estimate, unsuitable for
   trend aggregation** — the directional bias is named, not implied. The
   proxy is **not** defended as "still observed actuals"; it is a distinct,
   opted-into third basis. The no-list-price-fallback rule is untouched:
   vendor price cards are still never used; the proxy is anchored only in
   this repo's observed snapshot rates.
3. **Forced low cost confidence.** `confidence.cost: low` whenever any
   proxy is used (secondary to the `cost_basis` marker, not the sole
   signal).
4. **Per-tier disclosure.** `Included`/`Confidence rationale` names every
   proxied tier and its source ("Standard priced via a cross-tier proxy at
   the Most-capable rate — the snapshot carries no Sonnet family").
5. **Split-tier collapse is allowed when proxied (O1).** A split-tier stage
   whose one end is proxied legitimately collapses to a single rate
   (`low == high`); such a band is **exempt** from the "Split-tier spread"
   strict-`low < high` check (§4 amends the checklist line). The exemption
   keys on the proxied basis, so a *directly-bound* split tier is still
   required to spread.

Consequence: the 2026-06-13 opus-only snapshot now **grounds cost** —
Most-capable directly, Standard and the split's low end via the
`snapshot-actuals-proxied` Opus rate — relieving #411 with the data we
have, honestly and machine-distinguishably.

## 4. Grounding states, the closed omission set, and the validator

### 4.1 The closed omission set (restated in full — O12)

The agent's omission decision is a closed set; family matching merges the
old "unmapped tier" + "missing model key" triggers into one
family-resolution trigger:

1. **No snapshot** → omit.
2. **Snapshot present, no usable Model Breakdown** → omit ("no usable
   per-model breakdown").
3. **Model Breakdown present but NO estimating-tier family resolves**
   (neither `claude-opus-4*` nor `claude-sonnet-4*`, after §2) → omit,
   naming the cause. (A haiku-only snapshot lands here — O9.)
4. **≥1 estimating-tier family resolves** → `cost_usd` **present**. Tiers
   whose family resolves bind directly (`cost_basis: snapshot-actuals`);
   tiers whose family is absent are **proxied** per §3 (`cost_basis:
   snapshot-actuals-proxied` for the whole record).

### 4.2 Format-reference changes

- **`cost_basis` enum** gains `snapshot-actuals-proxied` alongside
  `snapshot-actuals` (additive; backward-compatible).
- **Binding table** documents the family stems + delimiter rule + family
  aggregation (§2).
- **Three grounding states** reworded to family resolution (§4.1); state 2
  "missing model key" language replaced.
- **"Split-tier spread" checklist line** amended: applies to a present
  split-tier `cost_usd` band **only when that record's `cost_basis` is
  `snapshot-actuals`** (both ends directly bound); a
  `snapshot-actuals-proxied` split-tier band is **exempt** and may collapse
  (O1).
- **Cost-pairing checklist line**: `cost_usd` is present with `cost_basis`
  ∈ {`snapshot-actuals`, `snapshot-actuals-proxied`}.

## 5. Surfaces changed (tagged firm-core vs proxy — O10)

1. `skills/cost-estimation/references/estimate-record-format.md` —
   **[core]** binding table (family stems, delimiter, aggregation
   disclosure), grounding states / closed omission set; **[proxy]** the new
   `cost_basis` enum value, the proxy rule + disclosure, the split-tier
   exemption + cost-pairing checklist edits.
2. `skills/cost-estimation/SKILL.md` — **[core]** mirror the binding-table
   family resolution; **[proxy]** the proxy methodology + its disclosure
   and `likely-overrun` forcing.
3. `agents/cost-estimator.agent.md` — **[core]** the mechanical check
   restated as the §4.1 closed set with family resolution (the
   `claude-opus-4-8`-worked-example caveat updated to "resolves to Most
   capable"); **[proxy]** the proxy step, the forced overrun + low cost
   confidence, the per-tier disclosure.
4. Tests (**O6 — surfaces clarified**) — **Layer-1 / structural** asserts
   the *static contract data*: the family-stem + delimiter rule and the new
   `snapshot-actuals-proxied` enum value documented in the format reference,
   and the amended split-tier-spread exemption text. The *behavioural*
   claim (the agent resolving `claude-opus-4-8` → Most capable and
   proxying Standard on a fixture snapshot) is **Layer-2/3 acceptance
   documentation**, gated on an API key — **not** a Layer-1 assertion of
   agent-internal reasoning.
5. Version triplet + CHANGELOG — the five `ai-literacy-superpowers`
   CI-checked locations; minor bump 0.49.0 → 0.50.0.

## 6. Out of scope

- **Capture-time validation** (a `/cost-capture` warning when a snapshot's
  keys won't bind) — a complementary #411 idea, deferred to its own slice;
  family matching makes most snapshots bind anyway.
- **Stem-table auto-discovery** — the family stems (`claude-opus-4`,
  `claude-sonnet-4`) are a **maintained** table, bumped per model
  generation (O8); auto-deriving them from MODEL_ROUTING is not in scope.
- **Per-direction (input/output) rates** — the blended-rate skew stays.
- **Calibration / per-PR actuals** — untouched.
- **Adding an Inexpensive/Haiku estimating tier** — the table keeps Most
  capable / Standard / split.

## 7. Spec-mode diaboli — outcomes

The spec-mode `/diaboli` gate raised **12 objections** — **2 critical, 4
high, 5 medium, 1 low** — **all accepted**
(`docs/superpowers/objections/cost-estimation-family-matching-design.md`).
The criticals (O1 split-tier-spread collapse; O2 `cost_basis` lie) and
O3/O5/O11 all struck the naïve proxy; the human disposed the §3 fork to
**Option B′ — engineer the proxy properly**, whose load-bearing
resolutions are the additive `snapshot-actuals-proxied` basis (O2/O11), the
split-tier-spread exemption (O1), the forced `likely-overrun` +
over-estimate disclosure (O3/O4), the delimiter rule + aggregation
disclosure (O7/O8), the haiku→state-2 clarification (O9), the restated
closed omission set (O12), and the clarified test surfaces (O6).

## 8. References

- Issue #411; the 2026-06-15 reflection (`REFLECTION_LOG.md`).
- `skills/cost-estimation/references/estimate-record-format.md`;
  `skills/cost-estimation/SKILL.md`; `agents/cost-estimator.agent.md`.
- `observability/costs/2026-06-13-costs.md` (the opus-only snapshot).
