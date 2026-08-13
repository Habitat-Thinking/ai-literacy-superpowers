# Spec: Cadence Sentinels S6 — Embedded Assumptions

**Status:** Draft (revision 1)
**Date:** 2026-08-13
**Issue:** #496
**Epic:** The Cadence Sentinels (S1–S7)
**Depends on:** nothing. Independent of S1–S5 — an extension to an existing
agent rather than a new one.
**Scope:** `skills/advocatus-diaboli/SKILL.md`, the objection-record schema,
`scripts/check-objection-taxonomy.py`, and the docs pages that name the six.

**Provenance:** *The Second Front — Arc Insertion Remit* (slide S6).

---

## 1. Problem Statement

Every implementation encodes assumptions its spec never stated.

That the user can see. That the network is there. That the list is short. That
the locale is the author's. None of these are decisions anyone made — they are
defaults that arrived with the code and were never noticed, because noticing
them requires asking a question nobody thought to ask.

The Diaboli's six categories cannot surface them, and not by oversight. **All
six interrogate what the spec says or fails to say.** An embedded assumption is
a property of the *artefact*, and it is invisible from the spec precisely
because the spec is silent on it — silence being the thing that makes it
embedded rather than decided.

## 2. The Seventh Category

### 2.1 `embedded assumptions`

> The implementation encodes an assumption the spec never states, which will be
> wrong for some real user, environment, or scale.

Four sub-kinds, which are prompts for attention rather than schema:

| Kind | The unstated assumption |
| --- | --- |
| **Usability and accessibility** | Everyone can see it, click it precisely, read it at that contrast, and is not using a screen reader |
| **Performance context** | The list is short, the machine is fast, the round trip is cheap |
| **Requirements enshrined in tests** | The fixture's shape *is* the requirement — a behaviour nobody specified is now locked in by the only thing that describes it |
| **Environmental** | One locale, one timezone, one scale, connectivity present |

*Example: "`registry_count` sorts and prints every live session. That is
correct for the 3–8 sessions a person holds, and the WIP Warden's own cap
makes larger values a breach rather than a case — but nothing says so, so the
next consumer inherits a linear scan as though it were a guarantee."*

### 2.2 Why a seventh rather than a fold-in

Folding these into `risk` or `implementation` was weighed and rejected.

Both could *hold* the finding — an environmental assumption is a failure mode,
and an encoded default is an implementation property. But a category's job is
not storage. **A category tells the agent what to go looking for**, and neither
`risk` nor `implementation` instructs anyone to hunt for what the artefact
assumes silently. Folded in, the lens would exist in the schema and go
unexercised in practice.

The Routing Rule's own test says the same thing from the other side: a finding
belongs to a category iff removing that category would leave a class of
findings unsurfaced. Remove `embedded assumptions` and the class goes with it.

### 2.3 It is primarily a code-mode lens

The existing per-mode weighting gains a line: **emphasise at code time,
deprioritise at spec time.**

An assumption is *embedded* by an artefact. Before the artefact exists there is
nothing to read it out of, so a spec-time embedded-assumption objection is
either a `premise` objection wearing a costume, or speculation — and the skill
already warns that ungrounded objections waste adjudication time.

It is not *forbidden* at spec time. A spec that names a concrete mechanism can
embed an assumption in the mechanism it names. But the evidence bar is the
existing one: quote the thing that encodes it.

## 3. The Remedy Field

### 3.1 `disposition` is untouched

Every objection, in every category, keeps `disposition: pending | accepted |
deferred | rejected`. Three consumers read that field — the orchestrator's
non-pending gate, the `PRs have adjudicated objections` constraint, and the
code-gate flow — and none of them changes.

### 3.2 `remedy` is new, optional, and additive

Embedded-assumption objections carry one further field:

```yaml
  - id: O3
    category: embedded assumptions
    severity: medium
    claim: "one sentence"
    evidence: "the line that encodes it"
    disposition: accepted
    remedy: add-test
    disposition_rationale: "..."
```

| `remedy` | Means |
| --- | --- |
| `accept-as-stated` | The assumption holds. Write it down so the next reader inherits a decision rather than a default. |
| `revise-spec` | The assumption is wrong, or right for a narrower case than the spec claims. The spec changes. |
| `add-test` | The assumption is a requirement nobody wrote down. A test makes it one. |
| `consciously-carry` | Known, wrong for someone, and shipped anyway — on the record, with the because. |

**`consciously-carry` is a complete answer**, and must not read as a lesser
one. An assumption carried knowingly is strictly better than the same
assumption carried invisibly, which is the entire point of surfacing it. The
`disposition_rationale` is what makes it a decision rather than a shrug.

### 3.3 Why a new field rather than a wider enum

The build spec's four values are answers to *"what do we do about it"*.
`disposition` answers *"does the human agree"*. Those are different questions,
and the four do not partition the three: `add-test` and `revise-spec` are both
`accepted`, and an assumption can be `rejected` outright (the reviewer disputes
that it is assumed at all) with no remedy owed.

Widening `disposition` would have made every existing consumer learn four
values it has no use for, to express something it was never asking. Additive
beats widening when the new information is genuinely orthogonal — the same
reasoning that gave S5 a separate check rather than a stricter one.

**Optional means optional.** `remedy` is absent on the other six categories and
absent on every record written before this ships. Nothing branches on its
absence: a consumer that does not know the field ignores it, and the checker
requires it only where the category demands it.

## 4. The Deterministic Checker

`scripts/check-objection-taxonomy.py` gains:

1. `"embedded assumptions"` in `CANONICAL_CATEGORIES`.
2. A `CANONICAL_REMEDIES` set, validated **only** where present.
3. A rule pairing the two: `remedy` on a non-embedded-assumptions objection is
   an error, and an embedded-assumptions objection with a non-`pending`
   disposition and no `remedy` is an error.

Rule 3 is what stops the field decaying into decoration. Without it, `remedy`
is a value nobody has to supply and nobody notices missing — which describes a
field that will be empty within two slices.

### 4.1 No cutover is needed, and the issue's note is wrong on this

Issue #496 says a dated cutover comparable to 2026-04-19 is required "so
pre-change records are not retroactively invalid".

**Adding a member to a validation set cannot invalidate anything.** The
checker asks whether a record's category is *in* `CANONICAL_CATEGORIES`; a
larger set answers yes strictly more often. All 45 existing records stay valid
by construction.

The 2026-04-19 cutover exists because that migration **retired** vocabulary —
`design|threat|failure|operational|cost` and `major|minor` — which is what
makes old records fail a new check. This slice retires nothing, so a cutover
would be a dated exemption from a rule nothing violates.

`MIGRATION_CUTOVER` stays exactly as it is. A second date constant, guarding
nothing, would be a live-looking mechanism with no behaviour behind it.

## 5. Files

| File | Purpose |
| --- | --- |
| `skills/advocatus-diaboli/SKILL.md` | the seventh category, the remedy vocabulary, per-mode weighting, the schema |
| `agents/advocatus-diaboli.agent.md` | the category list, if duplicated there |
| `scripts/check-objection-taxonomy.py` | the category, the remedies, the pairing rule |
| `docs/superpowers/objections/README.md` | **new** — what these records are, the taxonomy, the two dispositions |
| `docs/.../reference/objection-record-format.md` | the schema and `remedy` |
| `docs/.../explanation/*` and `reference/agents.md`, `skills.md` | "six categories" → seven |
| `orchestrator.agent.md`, `commands/diaboli.md` | wherever the six are enumerated |

## 6. Non-Goals

- **No change to `disposition`**, its enum, or any consumer of it.
- **No dated cutover.** §4.1.
- **No new agent, skill, or command.** Component counts are unchanged.
- **No retirement of any existing category.** Seven, not six-plus-a-rename.
- **No accessibility audit.** The category names accessibility as a place
  assumptions hide; it does not make the Diaboli a WCAG checker, any more than
  `risk` made it a CVE scanner.
- **No spec-mode requirement.** The category is available at both gates and
  emphasised at one.

## 7. Acceptance Scenarios (TDAD)

### 7.1 The checker — `tdad_tests/layer0_deterministic/test-objection-taxonomy.sh`

- **E1 — `embedded assumptions` is accepted** as a category.
- **E2 — the six existing categories still pass.** Regression against a real
  record.
- **E3 — retired vocabulary still fails.** `design`, `threat`, `major`.
- **E4 — every `remedy` value is accepted**; an unknown one fails.
- **E5 — `remedy` on a non-embedded-assumptions objection fails**, naming the
  category it appeared on.
- **E6 — an adjudicated embedded-assumptions objection with no `remedy`
  fails.** `pending` is exempt: the field is the human's to write.
- **E7 — the 45 committed records pass unchanged.** The proof that the change
  is additive, run against the real corpus rather than a fixture.

### 7.2 Agent-verified

- **A1** — an embedded-assumption objection quotes the artefact line that
  encodes the assumption, not a spec sentence about it.
- **A2** — at code time the category is emphasised; at spec time an objection
  in it is either grounded in a named mechanism or not raised.
- **A3** — `consciously-carry` is presented as a complete answer.
- **A4** — the four sub-kinds are prompts for attention, not a required field.

## 8. Rollout

Minor bump, 0.72.0 → 0.73.0 — a behavioural change to a skill and a
deterministic checker. **Component counts are unchanged**: 41 skills, 20
agents, 32 commands.

Five CI-checked version locations plus the README plugin-table cell. No count
badges, anchors, or headings change.

No breaking changes: `remedy` is optional and additive, `disposition` is
untouched, and the taxonomy grows rather than shifts.
