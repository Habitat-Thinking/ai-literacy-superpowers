# Record a declined finding — design

**Status:** proposed
**Date:** 2026-08-25
**Issue:** #555
**Provenance:** observed during the first end-to-end loop run (#548, PR #550).
finding-1 of `harness/assay/2026-08-25T08-08Z-assay.md` was read, adversarially
reviewed (`docs/superpowers/objections/harness-provenance-citation.md`,
12 objections), investigated against a newly transcribed source, and declined on
evidence. Nothing in the corpus records that.
**Scope:** a `rejected` decision record, and what the validator requires of one.
**Out of scope:** #556, #557, #558, #559.

## 1. Problem statement

The corpus records what **entered**. It has no way to record what a human weighed
and refused.

- `harness/decisions/` holds records that were proposed. finding-1 never was.
- The assay records what was *found*, and is append-only, so no disposition can be
  added to it.
- `index.md` and `/harness-timeline` are built from HDRs, so a finding that never
  became one is invisible to both.

The mechanism's own argument leans on refusal being visible. The assay format
requires a **Rejected candidates** section, and `/harness-assay` treats an empty
one as evidence the Assayer has stopped checking. `no-change` is a first-class
classification for the same reason.

That principle is enforced for the **Assayer** and absent for the **human**. The
one actor whose judgement the gate exists to capture is the one whose refusals
leave nothing behind.

### The practical cost

A later assay reads prior assays and will re-find the same class of problem.
Nothing tells it a human already considered and declined it, so it cannot
distinguish a genuinely recurring problem from one already adjudicated — which is
the distinction the two-assay promotion threshold turns on. Corroboration by a
finding that was already refused is not corroboration.

## 2. What already exists and is unreachable

```python
VALID_STATUS    = {"proposed", "accepted", "rejected", "superseded", "expired"}
STORABLE_STATUS = {"proposed", "accepted", "rejected"}
```

`rejected` is a **storable** status. Nothing in the plugin produces one — not
`/harness-propose`, not `/harness-accept`, not `/harness-review`. The schema
anticipated this outcome and no command reaches it.

Three mechanisms already behave correctly for a rejected record and need no
change:

- `compile_plan` skips anything not `accepted`, so a rejection reaches no artifact.
- `cmd_timeline` skips anything not `accepted`, so it stays out of the feed.
- `render_index` lists **every** record and falls through to `record.status`, so a
  rejection already renders with state `rejected`.

## 3. Decision — declining costs one section

`_check_body` is not gated on status. A rejected `harness-loop` record would today
need `## Rule`, a non-empty `## Cost`, and all four tier-2 sections — so declining
would cost more than accepting.

That is backwards, and it is fatal to the purpose: friction on the path we want
people to take means the path is not taken and the hole stays open.

For `status: rejected`:

| Section | Required | Why |
| --- | --- | --- |
| `## Finding` | yes | carried from the assay; what was observed |
| `## Rejection` | yes, non-empty | the human's reason. This is the artifact |
| `## Rule` | no | nothing enters force |
| `## Cost` | no | nothing is demanded of anyone |
| tier-2 sections | no | no layer is being argued for |

The cost rule does not apply — `_check_acceptance` already fires only on
`accepted`, and a cost for a rule that will never bind is ceremony.

**`## Rejection` must be non-empty and must not be a placeholder.** A rejection
with no reason records that someone said no and nothing about why, which is the
half a later reader actually needs.

## 4. Decision — the feed is for interventions

A rejected record does **not** appear in `/harness-timeline`.

The `no-change` precedent argues the other way: 0.79.0 kept `no-change` records in
the feed as `direction: none`, because they record that governance was examined at
a known moment and deliberately not changed. The distinction is that a `no-change`
record is **accepted** and carries `approved_at`; a rejection was never in force
and has no such date.

The feed's contract is when a rule entered force, in which direction, and when it
stopped. A rejection is not an intervention of size zero — it is not an
intervention. It belongs in the index, which is the corpus's record of what exists
rather than of what was in force.

## 5. Decision — how a rejection is produced

`/harness-propose --reject <assay> <finding>` writes the record at
`status: rejected` with `## Rejection` as a placeholder for the human to fill,
mirroring how tier-2 sections are left for a human today.

It is on `propose` rather than `accept` because nothing is being accepted, and
routing a refusal through the acceptance gate would make the gate mean two
opposite things.

**It does not consume a cycle slot.** The three-per-cycle cap limits how much
governance an assay *adds*; a rejection adds none. `_check_cycle_cap` counts
records in force, and a rejection is never in force, so this needs no change —
asserted rather than assumed.

## 6. Acceptance criteria

- **A1** — `/harness-propose --reject` writes a record at `status: rejected`.
- **A2** — the record carries `## Finding` and a `## Rejection` placeholder.
- **A3** — validation fails while `## Rejection` is a placeholder or empty.
- **A4** — validation passes with `## Finding` and `## Rejection` alone: no
  `## Rule`, no `## Cost`, no tier-2 sections, whatever the classification.
- **A5** — a rejected record reaches no artifact: `compile_plan` ignores it and
  `/harness-compile` writes nothing for it.
- **A6** — it is absent from `/harness-timeline`.
- **A7** — it appears in `harness/decisions/index.md` with state `rejected`.
- **A8** — it does not consume a cycle slot: three accepted records plus any
  number of rejections still pass.
- **A9** — an **accepted** record is unaffected: still requires `## Rule`,
  `## Cost` and its tier-2 sections. The relaxation must not leak.
- **A10** — the existing corpus is unaffected; `/harness-check` passes.

## 7. Version

Behaviour change to plugin files: minor bump, `0.82.0` → `0.83.0`, across the
five CI-checked locations named in `CLAUDE.md`.
