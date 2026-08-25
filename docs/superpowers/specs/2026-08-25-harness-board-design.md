# The harness board — design

**Status:** proposed
**Date:** 2026-08-25
**Issue:** #590
**Provenance:** the 2026-08-25 session, in which the evolution loop completed its
first full cycle. The evidence in §1 was gathered by running the loop, not by
reasoning about it.
**Scope:** a read-only command that renders the loop's in-flight artefacts and
the next action for each.
**Out of scope:** proposing, accepting or disposing anything; an HTML view; any
stored artefact.

## 1. Problem statement

On 2026-08-25 the harness evolution loop ran end to end for the first time. By
the end of the day the corpus held six decision records, four assays, four
objection records and thirty-five dispositions.

Answering *"what is blocked, and on what"* took running `precheck` three times,
reading two objection records, and hand-computing a two-assay threshold.

Every one of those answers already existed in machine-readable form. Nothing
assembled them.

The specific failure is sharper than "no overview". It was possible to report
**that** three proposals were stalled, but not **why each one differed**, without
three separate commands. The three blockers turned out to be entirely different —
missing tier-2 sections, a threshold refusal, and two undecided rule-text
amendments — and that distinction is exactly what a human needs in order to act.

### What exists, and what it does not answer

| Command | Gives | Does not give |
| --- | --- | --- |
| `/harness-timeline` | JSON lines per **accepted** record | anything about proposed, rejected or queued work |
| `/harness-status` | enforcement ratio, drift, GC state | nothing about the loop's queues |
| `/harness-check` | pass/fail over the whole corpus | which item, or what to do about it |
| `precheck --hdr <one>` | **the exact blocker, per record** | one record at a time |

`precheck` is the important row. It already computes the answer and already words
it for a human. It simply has to be asked once per record, by someone who knows
the records exist.

## 2. Decision — `/harness-board`

A read-only command rendering two views over the existing corpus.

### 2.1 Queue view

Every artefact in flight, its state, and the single next action. Grouped by kind,
ordered by what is closest to a gate.

Each blocked item names a **concrete next action**, not a state. "Blocked" is not
an action; "two rule-text amendments undecided" is.

### 2.2 Timeline view

Interventions over time with direction and expiry horizon.
`harness-registrar.py timeline` already emits `direction`, `state`,
`provisional`, `expires`, `supersedes` and `superseded_by` per accepted record —
enough to render without new analysis.

Selected with `--timeline`; the queue view is the default because it is the half
that answers a question nobody can otherwise answer cheaply.

### 2.3 Three constraints that follow from the day's evidence

**Render on demand, write nothing.** `/harness-timeline` sets the precedent — it
is "deliberately not a stored artifact, and it writes nothing". A file that must
be regenerated becomes a file that is stale, and the 2026-08-25 assessment found
exactly that: two dashboards, 106 days old, read by nobody. A command that renders
current state cannot go stale. This also keeps the board clear of **INV-1**.

**Quote `precheck`, never reimplement it.** Two implementations of a refusal rule
will diverge, and the divergence will favour the board, because the board is what
someone reads. Where a blocker is computed by `precheck`, the board shells out and
quotes the result.

**Never omit what it cannot classify.** A record the board does not understand is
rendered as unclassified, with its path. A board that silently drops what it
cannot parse reports a smaller world than it checked — which is the subject of the
rule this repository currently has in force.

## 3. Data sources

All read-only, all existing:

| Source | Gives |
| --- | --- |
| `harness/decisions/HDR-*.md` | `status`, `classification`, `enforcement`, `provisional`, `expires` |
| `harness-registrar.py precheck --hdr` | the exact refusal, per proposed record |
| `harness-registrar.py timeline` | direction and state per accepted record |
| `harness/assay/*.md` | findings, their classification and `no-change` status |
| `docs/superpowers/objections/*.md` | disposition counts per record |

### 3.1 One known wrinkle

The disposition vocabulary is not consistent across the corpus. A sweep on
2026-08-25 returns `accepted` (309), `amend` (71), `rejected` (24) and `accept`
(24) — the singular forms appear in older records.

The board **normalises for counting and preserves the raw value where it
differs**. It does not rewrite records, and it does not treat the divergence as
an error: `check-objection-taxonomy.py` passes on all 51 records, so the schema
permits it. Whether the vocabulary should be unified is a separate question and
is out of scope here.

## 4. Acceptance criteria

1. One invocation answers "what is blocked and what unblocks it" for every
   artefact in the loop
2. Each blocked item names a concrete next action rather than a state
3. Writes no file; `git status` is unchanged after a run
4. Where a blocker is computed by `precheck`, the board quotes it rather than
   reimplementing it
5. Disposition vocabulary normalised for counting, raw value preserved where it
   differs
6. A record the board cannot classify is shown as unclassified with its path,
   never omitted
7. `--timeline` renders accepted records with direction, state and expiry
8. Exits non-zero only on its own failure, never on the corpus's state — the
   board reports, it does not gate

Criterion 6 is the one to test adversarially: seed a malformed record and assert
it appears in the output.

## 5. Rejected alternatives

**Extend `/harness-status`.** Rejected: that command answers "how is the harness
enforcing", which is a different question from "what is in flight". Merging them
produces a screen nobody reads twice.

**Write a stored `BOARD.md`, regenerated by CI.** Rejected on the strongest
available evidence — this repository already carries two stored dashboards that
are 106 days stale and read by nobody, and the 2026-08-25 assessment recommended
wiring them into a cadence or retiring them. A third would be the same mistake
with a fresher date.

**Have the board act — dispose, propose, accept.** Rejected. The loop's write path
is gated deliberately, and a board that could act would collapse the gates it
exists to make visible.

**Reimplement the refusal logic for speed.** Rejected: see §2.3.

## 6. Version

Minor bump — a new command. 0.87.0 → 0.88.0.
