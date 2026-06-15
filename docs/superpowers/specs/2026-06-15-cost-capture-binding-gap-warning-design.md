# Cost-Capture Binding-Gap Warning — Capability Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-15 |
| Status | Drafted — ready for spec-mode diaboli, then plan/implementation |
| Author | claude-opus-4-8[1m] (interactive session with russmiles) |
| Capability | At capture time, `/cost-capture` warns when the snapshot it just wrote will not let the prospective `cost-estimator` ground a dollar figure — closing the binding-gap feedback loop where a human can act |
| Fixes | #413 |
| Plugin version target | `ai-literacy-superpowers` v0.50.0 → v0.51.0 |

---

## 1. Problem

#412 (v0.50.0) made the cost-estimation binding resolve tiers by **model
family** and price an absent estimating-tier family by a disclosed
**cross-tier proxy**. Most real snapshots now ground cost. But two
grounding outcomes are only discovered **downstream**, estimate by
estimate, never at the moment the snapshot is captured:

- **No estimating-tier family resolves** (e.g. a haiku-only snapshot) →
  the estimator omits cost entirely (grounding state 3).
- **Only some estimating-tier families resolve** (e.g. the opus-only
  2026-06-13 snapshot has no Sonnet family) → the estimator *proxies* the
  absent tier (`cost_basis: snapshot-actuals-proxied`), an honest but
  deliberately over-stated figure.

Both are correct estimator behaviour. The gap is **feedback latency**: the
person best placed to fix it — the human capturing the snapshot, who can
add a missing model's row or note a renaming — never learns the snapshot
is thin until estimates start coming back omitted or proxied. This is the
#411 silent-feedback failure one step removed.

## 2. The capability — a capture-time advisory

`/cost-capture` gains a **binding-gap check**: after it writes the snapshot
(and validates its structure), it resolves the snapshot's Model Breakdown
keys against the **estimating-tier family stems** and tells the human what
prospective estimates will do with this snapshot.

It is **advisory only**:

- It **never blocks** the capture and **never fails** validation — a thin
  snapshot is still a perfectly valid cost snapshot (it grounds spend
  trends regardless of estimating-tier coverage). The check informs; it
  does not gate.
- It is **distinct from** the existing step-10 structural validation
  checkpoint (which checks the snapshot has the fields `/harness-health`
  parses). The binding-gap check asks a different question: "will the
  *prospective estimator* ground cost against this?"

## 3. Behaviour

After the snapshot is written and structurally validated, resolve each
Model Breakdown model key against the **estimating-tier family stems**
defined in the binding table
(`skills/cost-estimation/references/estimate-record-format.md` — the
`claude-opus-4` / `claude-sonnet-4` stems, the delimiter rule). The command
**references** that table; it does **not** restate the stem list (one
source of truth — the same table the estimator uses).

Three outcomes, surfaced to the human and echoed in the §12 summary:

| Outcome | Condition | Advisory |
| --- | --- | --- |
| **Grounds directly** | every estimating-tier family (`claude-opus-4` **and** `claude-sonnet-4`) resolves | none — estimates will carry `cost_basis: snapshot-actuals`. |
| **Grounds, but proxied** | ≥1 estimating-tier family resolves, but not all | INFO: "estimates will **proxy** the absent tier(s) — `<tier(s)>` — at the dearest present family's rate (`cost_basis: snapshot-actuals-proxied`, a deliberate over-estimate). Add a `<family>` model row for direct grounding." |
| **Will not ground** | **no** estimating-tier family resolves (e.g. haiku-only) | WARN: "prospective `/cost-estimate` will **omit cost** against this snapshot (no `claude-opus-4` or `claude-sonnet-4` family present). Add an opus-4 or sonnet-4 family row, or — if the models are a newer generation the binding stem table doesn't yet know — update the stem table (#414)." |

The wording points the human at the **two** real remedies: capture a
richer snapshot, or (for a generation rollover) the stem-table maintenance
follow-on (#414). Haiku and other non-estimating families are named as
"present but not an estimating tier", so the human is not left guessing why
a populated breakdown still won't ground.

## 4. Where it lives

A new advisory step **after** the step-10 validation checkpoint and
**before** the step-11 commit — call it **step 10b: estimating-tier
binding check (advisory)** — plus a **"Cost-estimate grounding:"** line in
the step-12 summary stating which of the three outcomes applies. The
existing steps are otherwise unchanged.

The `cost-tracking` skill gains a short pointer noting that a captured
snapshot's estimating-tier coverage determines whether the prospective
`cost-estimation` sibling can ground cost — reinforcing the existing
sibling-relationship framing, not duplicating the check logic.

## 5. Out of scope

- **Changing the binding or the estimator** — #413 is a pure *consumer* of
  the v0.50.0 family-stem rule at capture time; it adds no binding, no
  proxy logic, no format field.
- **Blocking or auto-fixing a thin snapshot** — advisory only; the human
  decides whether to enrich the snapshot.
- **The stem-table maintenance itself** — that is #414; #413 only *points
  at* it when a generation rollover is the likely cause.
- **A new estimating tier** (Haiku/Inexpensive) — the estimating tiers stay
  Most capable / Standard / the split.

## 6. Spec-mode diaboli

This spec goes through the spec-mode `/diaboli` gate; objections recorded
at `docs/superpowers/objections/cost-capture-binding-gap-warning-design.md`
and absorbed.

## 7. References

- Issue #413; sibling follow-on #414 (stem-table maintenance); #411 / #412.
- `ai-literacy-superpowers/commands/cost-capture.md`;
  `ai-literacy-superpowers/skills/cost-tracking/SKILL.md`.
- The family-stem binding table:
  `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`.
