# Spec: Harness Evolution S4 — review and demotion

**Status:** Approved
**Date:** 2026-08-23
**Issue:** #538
**Epic:** Harness Evolution — the Harness Assayer and the Harness Registrar (#533)
**Depends on:** S0 (schema), S1 (records), S2 (apply/compile/check).
**Scope:** `ai-literacy-superpowers` plugin — one command, one script subcommand,
four schema rules, three new `check` failures.
**Explicitly out of scope:** the Observatory export. S5.

---

## 1. Problem Statement

A rule can be added, applied, compiled and checked. Nothing can retire one.

That is the half of governance almost nobody does, and it is the half the whole
design was arranged around: rules should be **hard to add and easy to retire**.
Every mechanism so far has made adding harder. This makes retiring possible, and
makes *not* retiring fail the build.

## 2. The conflict S2 created, and how it dissolves

Supersession conventionally writes two things: `supersedes` on the new record,
and `superseded_by` plus `status: superseded` on the old one.

S2 made that impossible. An accepted record is **frozen**, and `/harness-check`
compares it against its content at the commit that accepted it. Writing
`superseded_by` onto the old record is an edit to a frozen record, so the two
mechanisms would contradict each other on the first demotion anyone performed.

The fix is not an exception to the frozen check. It is to stop storing the
derivable thing:

> **A record's stored status never changes after acceptance. Supersession is
> derived from the successor's `supersedes:` field.**

This is the same discipline `records_open` already uses in
`hooks/scripts/lib/record-paths.sh`, arrived at for the same reason: state that
can be derived should not be written, because writing it creates a second place
to be wrong.

Three consequences follow, and each is enforced:

1. **`superseded_by` must be `null`.** The field stays in the schema because a
   reader expects it, and the validator refuses any value — with the reason.
2. **Only `proposed`, `accepted` and `rejected` may be *stored*.** `superseded`
   and `expired` remain in the vocabulary as **derived** states, computed at read
   time and shown in the index. A record that stored one would be a record
   claiming a fact about itself that only the corpus can know.
3. **Nothing edits a frozen record, ever.** The frozen check needs no exception,
   which is the test of whether this dissolution is real.

## 3. Derived states

| Derived state | Condition |
| --- | --- |
| `superseded` | Some other record names this one in `supersedes:` |
| `expired` | `status: accepted`, `provisional: true`, `expires` in the past, not superseded |
| `in force` | `status: accepted`, not superseded, not expired |

Superseded records **compile nothing** and are absent from the enforcement
report. They remain in the corpus and in the index, because the record that the
rule once existed, what it cost, and why it was retired is the output of this
whole mechanism.

## 4. The three review outcomes

`/harness-review` lists every lapsed rule. Each has three options, and all three
produce a **new record** that supersedes the old one. None edits anything.

| Outcome | The new record | Direction |
| --- | --- | --- |
| **Re-evidence** | Cites fresh evidence; may set `provisional: false` — permanence earned at review, as designed | same |
| **Weaken** | Lower `enforcement`, or narrower `surfaces` | loosen |
| **Demote** | Retires the rule entirely | loosen |

### 4.1 A retirement says `Withdrawn.`

A demotion's `## Rule` section contains the literal `Withdrawn.` and no fenced
block — mirroring how `no-change` says `No change.`

No new frontmatter field. The precedent already exists, a reader meets the fact
where the rule text would be, and the index derives the rest.

A record whose Rule is `Withdrawn.` must name a non-null `supersedes`. Retiring
nothing is not a decision.

### 4.2 Retirements are exempt from the promotion threshold

A `harness-loop` change requires evidence from two distinct assays. A
`harness-loop` **retirement** does not.

The threshold exists to make rules hard to add. Applying it to removal would make
them hard to remove as well, which is the exact inversion of the design: a rule
that turned out to be wrong would need two assays' worth of evidence before
anyone could withdraw it, and would stay in force meanwhile.

### 4.3 The cycle cap counts live records

Three accepted records per assay, counting records **in force** — not superseded
ones. Superseding a rule frees its slot, because the cap limits how much
governance an assay adds, and a retired rule adds nothing.

## 5. What `/harness-check` gains

| Check | Fails when |
| --- | --- |
| **Lapsed rule** | An `expires` date is in the past on a record still in force |
| **Unresolvable evidence** | An evidence entry names a repo path that no longer exists |
| **Stored derived status** | A record stores `superseded` or `expired` |
| **Non-null `superseded_by`** | A record stores what should be derived |
| **Broken supersession** | `supersedes` names a record that does not exist, itself, or one already superseded by a different record |

An expired rule still in force is a **build failure**. That is anti-theatre
requirement 5: expiry is enforced by CI, not by a calendar, so demotion is never
contingent on anyone remembering to reflect.

### 5.1 Evidence resolution, and what it will not claim

An evidence entry that looks like a repository path — no URI scheme — must
resolve to a file that exists. An entry carrying a scheme (`trace://run/8821`) is
**skipped with a note**, not passed silently and not failed.

Failing it would demand the check resolve things it has no access to. Passing it
silently would let any unresolvable evidence be laundered by prefixing a scheme.
Saying which entries were not checked is the only honest option.

## 6. A gap in the source design, stated rather than closed

The build spec requires `provisional: true` with "a mandatory `expires` date
(default 90 days) **or** a `review_trigger`", and separately requires that expiry
be enforced by CI rather than by a calendar.

Those two do not compose. A `review_trigger` is free text — *"Two consecutive
assays with zero findings in this class"* — and **nothing can evaluate it
mechanically**. So a rule with a trigger and no expiry never lapses, never fails
`/harness-check`, and is permanent by construction. Choosing a trigger over a
date is therefore an available route to exactly the permanence the design says
must be earned.

This slice does **not** invent a policy to close it, because the remedy is a
judgement the author of the design should make, not one a builder should slip in.
What it does instead:

- `/harness-review` lists trigger-only records in their own section, headed
  *"Triggers nothing can evaluate"*, with the age of each
- The section states plainly that these will never lapse on their own

Recommended fix, for the author: require `expires` **always**, and treat
`review_trigger` as an additional, earlier prompt rather than a substitute. One
field changes and the loophole closes.

## 7. Acceptance criteria

| ID | Criterion |
| --- | --- |
| D1 | An expired provisional record still in force fails `check` |
| D2 | A grandfathered import (`provisional: false`, no expiry) never lapses |
| D3 | A record with `provisional: false` never lapses |
| D4 | Superseding an expired record clears the failure |
| D5 | A superseded record compiles nothing and leaves the region |
| D6 | A superseded record stays in the corpus and in the index, marked superseded |
| D7 | Storing `status: superseded` or `expired` fails validation, naming the reason |
| D8 | A non-null `superseded_by` fails validation |
| D9 | `supersedes` naming a missing record, itself, or an already-superseded record fails |
| D10 | A retirement (`Withdrawn.`) compiles nothing and requires `supersedes` |
| D11 | A `harness-loop` retirement is exempt from the two-assay threshold |
| D12 | The cycle cap counts live records: superseding one frees its slot |
| D13 | Evidence naming a path that no longer exists fails `check` |
| D14 | Evidence carrying a URI scheme is skipped with a note, not failed |
| D15 | `review` lists expired records, and lists trigger-only records separately |
| D16 | `review` is read-only — the corpus is byte-identical afterwards |

Tests: `tdad_tests/layer0_deterministic/test-harness-review.sh`.

## 8. Rejected alternatives

**Teaching the frozen check to permit a `superseded_by` edit.** Rejected per §2.
An exception carved into the one check that guarantees accepted rules are not
quietly reworded is an exception that will be widened. Deriving the field removes
the need for the exception entirely.

**A `retires: true` frontmatter flag.** Rejected per §4.1 — `no-change` already
established that a decision with no rule text says so where the rule text would
be, and a second convention for the same shape is a second thing to remember.

**Inventing a backstop expiry for trigger-only records.** Rejected per §6. It
would be policy the author never asked for, arriving inside an implementation
slice, and applied retroactively to records already accepted.

**Deleting a retired record.** Rejected. The record that a rule existed, what it
cost, and why it was withdrawn is the output of this mechanism, not its residue.
