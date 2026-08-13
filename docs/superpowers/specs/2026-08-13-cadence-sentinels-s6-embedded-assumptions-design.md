# Spec: Cadence Sentinels S6 — Embedded Assumptions

**Status:** Approved (revision 2, post-diaboli)
**Date:** 2026-08-13
**Issue:** #496
**Epic:** The Cadence Sentinels (S1–S7)
**Objections:** `docs/superpowers/objections/cadence-sentinels-s6-embedded-assumptions-design.md`
— 12 objections, all dispositioned
**Depends on:** nothing. Independent of S1–S5 — an extension to an existing
agent rather than a new one.
**Scope:** `skills/advocatus-diaboli/SKILL.md` and one new reference page.

**Provenance:** *The Second Front — Arc Insertion Remit* (slide S6).

---

## 1. Problem Statement

Every implementation encodes assumptions its spec never stated.

That the user can see. That the network is there. That the list is short. That
the locale is the author's. None of these are decisions anyone made — they are
defaults that arrived with the code and were never noticed, because noticing
them requires asking a question nobody thought to ask.

**The Diaboli can hold these findings today. Nothing tells it to look.**

Revision 1 claimed more: that all six categories interrogate what the spec says
and therefore *cannot* reach an artefact's silent assumptions. That is false,
and the gate falsified it against the file this slice edits — the code-time
weighting already directs `risk` at "specific evidence from the implementation
— API surface exposures, error path gaps, resource-management failures, and
operational blind spots" (O1).

So the gap is attention, not capability. This slice closes the attention gap
and nothing else.

## 2. The Approach: a Hunt-List, Not a Category

### 2.1 What ships

Four items appended to the **code-time `risk` weighting** in
`skills/advocatus-diaboli/SKILL.md`, in the same shape as the four already
there:

| Sub-kind | The unstated assumption |
| --- | --- |
| **Usability and accessibility** | Everyone can see it, click it precisely, read it at that contrast, and is not using a screen reader |
| **Performance context** | The list is short, the machine is fast, the round trip is cheap |
| **Requirements enshrined in tests** | The fixture's shape *is* the requirement — a behaviour nobody specified is now locked in by the only thing that describes it |
| **Environmental** | One locale, one timezone, one scale, connectivity present |

Plus worked examples, the routing rule for them (§4), and the four remedy
framings as prose (§3).

### 2.2 Why not a seventh category

Revision 1 proposed `embedded assumptions` as a seventh category and rejected
fold-in on the grounds that "neither `risk` nor `implementation` instructs
anyone to hunt for what the artefact assumes silently."

**That mechanism is exactly what the code-time weighting is** (O2). The
rejection argued against a *silent* fold-in that nobody proposed, and the
option actually available — appending to the existing hunt-list — delivers the
same attention-direction at a fraction of the cost:

| | Seventh category | Hunt-list |
| --- | --- | --- |
| Files touched | ~16 | 2 |
| `check-objection-taxonomy.py` | new category, new remedy set, new pairing rule | unchanged |
| `HARNESS.md` constraint **body** | enumerates the six verbatim — must change | unchanged |
| Three convention-file mirrors | must change, and `check-convention-parity.py` compares **headings only**, so the drift would be invisible to every gate (O4) | unchanged |
| Reversibility | its own slice | one paragraph |

The remaining honest argument for a category — that a first-class name carries
attention weight a sub-bullet cannot — is real but unevidenced, and it is not
worth a deterministic checker change to test. **If the hunt-list proves
insufficient in practice, promoting it to a category is a later slice with
evidence behind it.** That is the direction this repo's progressive-hardening
convention runs.

### 2.3 What this does not claim

The Routing Rule argument in revision 1 is withdrawn. It restated a test that
partitions *findings between three agents* as one that partitions *lenses
between categories*, and in that form it is satisfied by any category one cares
to name — including "assumptions about Tuesdays" (O7). It did no work.

## 3. The Four Remedy Framings — Prose, Not Schema

The build spec asks for a per-assumption disposition line: `accept-as-stated` /
`revise-spec` / `add-test` / `consciously-carry`.

These ship as **a prose section the skill requires at the end of an
assumption objection's body**, offering the four framings to the human who is
about to write a disposition. They do **not** become a schema field.

| Framing | Means |
| --- | --- |
| `accept-as-stated` | The assumption holds. Write it down so the next reader inherits a decision rather than a default. |
| `revise-spec` | The assumption is wrong, or right for a narrower case than the spec claims. The spec changes. |
| `add-test` | The assumption is a requirement nobody wrote down. A test makes it one. |
| `consciously-carry` | Known, wrong for someone, and shipped anyway — on the record, with the because. |

**`consciously-carry` is a complete answer** and must not read as a lesser one.
An assumption carried knowingly is strictly better than the same assumption
carried invisibly, which is the entire point of surfacing it.

### 3.1 Why not a `remedy` field

Revision 1 added an optional `remedy` field with a checker rule pairing it to
the category: a `remedy` on any other category is an error, and an adjudicated
assumption objection without one is an error.

**That rule cannot exist without the category.** With no `embedded assumptions`
value in the schema, nothing deterministic can tell an assumption objection
from any other, so a `remedy` field would ship with no enforcement and the spec
would be claiming one — which is the failure this epic keeps catching, and the
one O2 just caught (S5's O2: an `agent-verified` rung that was never a value of
the enum; #509: a hook instructed to warn from a position that can only block).

The honest options were an unenforceable field or no field. Prose that shapes
the human's choice at the moment they make it is worth more than a field
nothing checks, and it claims nothing.

`disposition` is untouched: `pending | accepted | deferred | rejected`, read by
the orchestrator's non-pending gate, the `PRs have adjudicated objections`
constraint, the code-gate flow, and `snapshot-format.md`'s
disposition-distribution metric — four consumers, one more than revision 1
counted, and none of them changes.

## 4. Routing: Some Assumptions Are the Convener's

An assumption whose remedy is **a conversation** belongs to the Convener, not
here — the tie-break shipped in S5 one day before this slice (O8).

That is not a corner case. Two of the four sub-kinds are paradigm cases:

> *"Nobody established whether screen-reader users can complete this flow."*
> *"Nobody asked which locales this ships to."*

Both name a failure class **and** name a person to ask, and the shipped rule is
explicit that the Convener wins those.

**The test:** can the assumption be settled by reading the artefact, or only by
asking someone? Reading it out of a fixture, a sort, or a hard-coded timeout is
the Diaboli's. Needing a person's answer is the Convener's.

The skill states this with a worked pair, because the three-way partition is
shared contract and a seventh entry into it should not be left to inference.

### 4.1 And some are the Cartographer's — once #209 lands

The Choice Cartographer's `defaults` lens already describes this class almost
verbatim: *"an inherited default is a decision the team did not make but now
owns"* (O9). It is spec-mode-only, pending #209.

When code mode ships, `defaults` becomes the natural home for the
*decision-recording* half of an embedded assumption, and this hunt-list keeps
the *failure-detecting* half — which is the existing partition applied
unchanged, rather than a new question. Noted here so #209's slice inherits the
observation rather than rediscovering it.

## 5. Files

| File | Purpose |
| --- | --- |
| `skills/advocatus-diaboli/SKILL.md` | the four sub-kinds on the code-time weighting, worked examples, the remedy framings, the Convener routing pair |
| `docs/.../reference/objection-record-format.md` | **new** — the reader-facing record contract, missing beside its two siblings |

Two files. Revision 1's table listed seven and missed four more (O4, O5, O11).

### 5.1 The reference page, not a README in the records directory

Issue #496 asks for `docs/superpowers/objections/README.md`. **That would be
counted as an objection record** by two shipped consumers — the taxonomy
checker globs `objections/*.md`, and `snapshot-format.md` counts the same glob
"excluding `.gitkeep`" and classifies anything without a `-code` suffix as
spec-mode. A `README` would land in four published metrics as a record with
zero objections (O5).

Rather than teach both consumers a second exclusion, the page goes where its
two siblings already live — `consultation-record-format.md` and
`parking-record-format.md` are both under `reference/`, and
`objection-record-format.md` is simply missing (O11).

**Divergence from #496, declared:** the README becomes a reference page, in a
different directory, for this reason.

To avoid a third copy of one schema, the reference page is the **reader-facing
contract** and states plainly that `skills/advocatus-diaboli/SKILL.md` owns the
agent's emission rules. It does not restate them.

## 6. Non-Goals

- **No new category.** §2.2. Six stays six.
- **No checker change.** `check-objection-taxonomy.py` is untouched, so the
  cutover question does not arise at all.
- **No schema change.** No `remedy` field, no change to `disposition`.
- **No `README.md` inside the records directory.** §5.1.
- **No new agent, skill, or command.** Component counts unchanged.
- **No accessibility audit.** The hunt-list names accessibility as a place
  assumptions hide; it does not make the Diaboli a WCAG checker, any more than
  `risk` made it a CVE scanner.
- **No claim of enforcement.** Nothing here is deterministically checked, and
  the spec says so rather than implying otherwise.

## 7. Acceptance Scenarios (TDAD)

The slice ships no executable code, so there are no Layer 0 scenarios. One
structural TDAD scenario covers the skill.

### 7.1 `tdad_tests/scenarios/skills/advocatus-diaboli/embedded-assumptions.md`

- **A1** — the code-time `risk` weighting names all four sub-kinds.
- **A2** — each carries a worked example that quotes an **artefact** line, not
  a spec sentence about one.
- **A3** — the four remedy framings appear with `consciously-carry` presented
  as a complete answer.
- **A4** — the Convener routing pair appears with the read-it/ask-someone test.
- **A5** — the six categories are unchanged, and no seventh is introduced.
- **A6** — the spec-time weighting still deprioritises artefact-grounded
  findings, so the hunt-list does not leak into spec mode.

### 7.2 Regression

`check-objection-taxonomy.py` passes over the **whole committed corpus**,
derived from the glob rather than a pinned count. Revision 1 wrote "the 45
committed records", which the gate's own record made stale before the slice
could merge — the fourth instance of the pinned-literal pattern in this epic
(O6, `AGENTS.md:481`, #507).

## 8. Rollout

Minor bump, 0.72.1 → 0.73.0 — a behavioural change to a skill. **Component
counts unchanged**: 41 skills, 20 agents, 32 commands.

Five CI-checked version locations plus the README plugin-table cell. No count
badges, anchors, or headings change.

No breaking changes: the taxonomy, the schema, the checker, and every
constraint body are untouched.
