# Spec: Cadence Sentinels S3b — Boundary Notices and the Hard Stop

**Status:** Approved (revision 1)
**Date:** 2026-08-12
**Issue:** #501
**Epic:** The Cadence Sentinels (S1–S7)
**Depends on:** S1 (the pact file, the registry), S2 (the Coda, whose contract
this changes), S3 (the Mast), S4 (the WIP Warden, whose override this carries)
**Scope:** one hook, two libraries, a contract change to S2, and one
coordination line in an existing hook

---

## 1. Problem Statement

Three slices have now deferred work here, and they deferred the same thing
twice over: **something has to speak at the boundary, and something has to
carry what the human says back to the record.**

- **S3** deferred the Mast's approaching and reached notices, and its hard-stop
  override, because building a note store another slice must consume made six
  of its eleven objections.
- **S4** deferred the WIP Warden's `strict` override for the same reason — an
  override worth recording is worth recording once.
- **S2** shipped the Coda without knowing any of this existed.

So this slice is the missing half of two sentinels and a contract change to a
third. That is unusual and worth stating plainly: it is not a feature slice, it
is the seam.

## 2. What Speaks, and Once

| Notice | Fires | Says |
| --- | --- | --- |
| **approaching** | at 80% of the way from session start to `hard_stop_hour` | where you are, and what the line is |
| **reached** | at `hard_stop_hour` | one recommendation: `/coda` |

**One recommendation, once.** No repeats, no escalation, no second notice ten
minutes later.

<!-- evidence: boundary-moment reality checks improve adherence where ambient
     reminders do not. The mechanism is a prompt at the decision point, not
     accumulated pressure — which is why repeating it would not make it work
     better, it would make it work worse. That is also why §3 exists: two
     advisories arriving together IS accumulated pressure, even when each was
     designed as a single prompt. -->

Both ride the `Stop` hook, so they arrive between turns rather than
interrupting one. Both are `{"systemMessage": ...}` advisories: they never
block, never exit non-zero, and never require a disposition.

**Only `hard_stop_hour` produces notices.** `focus_blocks` has two endpoints
and no defined fraction; `sessions_per_day` is a count the registry cannot
reconstruct; `daily_cost_ceiling` is not observable at all. S3 §2.1 settled
what each key can honestly support, and only one supports a line in time.

## 3. The Advisory Rail

Two sentinels now counsel stopping on the same rail, and they can fire on the
same turn: `reservoir-check.sh` puts a declared `lark` into its suboptimal band
at hour ≥ 20, so a `hard_stop_hour: 20:00` produces two independent stop
advisories saying essentially the same thing.

That is not a cosmetic clash. The evidence this slice is built on says a single
boundary-moment prompt works and accumulated pressure does not — and two
messages about stopping, arriving together, **is** accumulated pressure. The
Mast would be degrading the Reservoir Warden's effectiveness without editing
one of its files.

### 3.1 One claim per turn

`hooks/scripts/lib/advisory-rail.sh` exposes:

```text
advisory_claim <kind>   # true for the first claim of this kind this turn
```

The first hook to claim `stop` in a given turn emits; every later one stays
silent about stopping. Nothing re-derives anyone else's logic — which is the
point.

**The alternative was worse.** Having the Mast stay quiet by re-deriving the
Warden's chronotype band would pin a copy of logic another slice owns, which is
the anti-pattern `AGENTS.md` has already caught twice in this epic (the README
counts, and `registry_list`'s docstring). A shared rail costs one line in each
participant and copies nothing.

### 3.2 The one line in `reservoir-check.sh`

`reservoir-check.sh` gains a single `advisory_claim stop` guard before it
emits.

This is a change to the Reservoir Warden's hook, and constraint 5 says that
agent is untouched. The judgement, recorded here: **this is a coordination
change, not a behavioural one.** The Warden's proxies, thresholds, honesty
flags, recommendation text, and advisory-forever standing are all unchanged. It
still fires whenever it would have fired — it simply claims the turn first, and
by ordering it always wins the claim.

The Warden going first is deliberate. It is the older sentinel, it is
advisory-forever by charter, and its advice is the more general — *decide your
stop* subsumes *you have reached the stop you decided*.

### 3.3 What the Mast does when it loses the claim

It stays silent **and still logs the note** (§4). The human's boundary was
still reached; the only thing suppressed is a second message saying so.

A later reader of the session's record sees that the line was passed. They just
were not told twice at the time.

## 4. The Note Store

`~/.claude/mast/<sanitised-session-id>.notes` — append-only within a session,
one line per event.

```text
2026-08-12T20:00:00Z reached hard_stop_hour=20:00
2026-08-12T20:00:00Z continued past the 20:00 stop by choice
2026-08-12T21:14:00Z wip-override 3 live against a limit of 2
2026-08-12T23:10:00Z consumed-by-coda
```

### 4.1 Marked consumed, never deleted

The Coda **marks** the file consumed rather than removing it.

S3's O3 found the reason: the once-per-session notice state lives in this file,
and `/coda`'s final step is a statement rather than a process termination — the
session is still alive and the `Stop` rail keeps firing. A file deleted at close
would take the notice state with it, and the reached notice would fire again on
the next turn, on exactly the sessions where the human had already overridden
once.

Marking also makes a second `/coda` in the same session idempotent, which the
first design would not have been.

**Boundedness is unchanged**: the file is lease-pruned on the same `Stop` rail,
exactly as the registry is. That is what satisfies the operational-state
carve-out's second condition, and it never depended on deletion-at-close.

### 4.2 Two libraries, split on the trust boundary

| File | Exposes | Who may source it |
| --- | --- | --- |
| `lib/mast-notes-read.sh` | `notes_read`, `notes_has` | hooks, commands, **and sentinels** |
| `lib/mast-notes-write.sh` | `notes_append`, `notes_mark_consumed`, `notes_prune` | hooks and commands **only** |

S3's O2 called the single-library design a critical, and correctly: a
`role: sentinel` agent must reach the read side, and a library exposing
`notes_prune` to it would breach the boundary through the exact channel
`sentinel-integrity-check.sh` names as its own known limit. S1 shipped this
split for the registry; this follows it.

### 4.3 Self-gated, and disclosed

**Nothing is created for a human who declared no `Budgets` block.** S3's O11:
a directory appearing under `~/.claude/` for someone who opted into nothing is
operational state with no operational purpose, and documenting a store that
should not exist is an explanation rather than a disclosure.

The hook checks `block_state` first and exits 0 before touching the filesystem,
exactly as `reservoir-check.sh` does.

`reference/hooks.md` states what the store holds, how long, and how to switch
the hook off.

### 4.4 The carve-out's four conditions

| Condition | How it holds |
| --- | --- |
| **Local, never committed** | `~/.claude/mast/`, outside every work tree |
| **Bounded** | lease-pruned on the `Stop` rail; consumption marks rather than removes, and does not affect the bound |
| **Nothing in it judges** | facts about the session — a notice fired, a line was passed, an override was spoken. No score, no assessment, no count across sessions |
| **Disclosed and declinable** | `reference/hooks.md`, with the opt-out |

## 5. The Contract Change to S2

The Coda's survey gains a fourth row, and its `Closed` field gains what that
row produces. **S3b owns this change explicitly**, per the promoted decision
that a consumer never mutates the contract it consumes — this is the third
worked instance.

### 5.1 The survey

| Item | Flag |
| --- | --- |
| Commits, working-tree state, dispositions | `observed` |
| Merged PRs, open-PR check state | `observed` / `inferred` |
| Which files constitute one thread | `asked` |
| **Boundary events this session** | **`observed`** |

`observed` is honest here: the note file records what actually fired and what
the human actually said. The Coda is reading a log, not inferring.

### 5.2 The `Closed` field

```text
- **Closed**: [what landed; the filename of each record parked; any boundary
  events and what was decided]
```

### 5.3 Who marks it consumed

The `/coda` **command**, not the agent. The Coda agent holds no `Write` and
must never source `mast-notes-write.sh`.

### 5.4 What the override looks like once it lands

S3's O9 asked the sharp question: the note file is bounded and local, but
`REFLECTION_LOG.md` is committed, aggregated, and permanently archived. One
`grep` would return every night the human worked past their line.

**So the Coda writes the human's own sentence, not the machine's.** At close it
asks what to record — offering the note's plain content as a starting point —
and what reaches the reflection fragment is a line the person authored and would
recognise as theirs.

That is the same resolution S2 reached for the next-action override: the record
carries the human's words, not a machine verdict, and it is what keeps a
permanent committed artefact on the *by the person* side of the boundary.

If they would rather record nothing, nothing is recorded. The override was
never a gate, so there is nothing that must be accounted for.

## 6. Files

| File | Purpose |
| --- | --- |
| `hooks/scripts/mast-boundary-check.sh` | `Stop` — the two notices, the notes, the prune |
| `hooks/scripts/lib/advisory-rail.sh` | one stop-advisory per turn |
| `hooks/scripts/lib/mast-notes-read.sh` | the read surface |
| `hooks/scripts/lib/mast-notes-write.sh` | the write surface |
| `hooks/scripts/reservoir-check.sh` | **one line**: claim the rail first |
| `agents/coda.agent.md`, `commands/coda.md` | the survey row and the `Closed` field |
| `agents/wip-warden.agent.md`, `commands/wip.md` | the override is now recorded |
| `skills/mast/SKILL.md`, `skills/wip-warden/SKILL.md` | the notices, the rail |

## 7. Non-Goals

- **No blocking.** Nothing here can end or hold a session.
- **No notices for keys that cannot support one.** Only `hard_stop_hour`.
- **No cross-session aggregation.** A note is per-session and pruned. Counting
  overrides across sessions would be a record of how often someone works late.
- **No changes to the Reservoir Warden's behaviour** — one coordination line,
  §3.2, and nothing else.
- **No machine-authored sentence in a committed file.** §5.4.

## 8. Acceptance Scenarios (TDAD)

### 8.1 The rail — `test-advisory-rail.sh`

- **AR1** — the first claim of a kind in a turn succeeds; the second fails.
- **AR2** — a different kind claims independently.
- **AR3** — a new turn resets the claim.
- **AR4** — claiming writes nothing outside the store, and exits 0 when it
  cannot write.

### 8.2 The notices — `test-mast-boundary.sh`

- **MB1** — approaching fires once at 80%; a second run in the same session is
  silent.
- **MB2** — reached fires once and recommends `/coda`.
- **MB3** — silent before the fraction.
- **MB4** — silent with no `Budgets` block, **and no store is created**.
- **MB5** — a malformed block degrades to silence, never a gate.
- **MB6** — losing the rail claim suppresses the message **but still logs the
  note**.
- **MB7** — the notice state survives `consumed-by-coda`: after consumption,
  reached does not fire again.
- **MB8** — exits 0 on every path, including an unwritable store and `HOME`
  unset.
- **MB9** — a hostile session id sanitises to `unknown`.

### 8.3 The libraries — `test-mast-notes.sh`

- **MN1** — append and read round-trip.
- **MN2** — `notes_mark_consumed` marks and does **not** remove.
- **MN3** — a stale file is pruned past its lease.
- **MN4** — the read library defines no mutator, and its transitive source
  closure contains none.
- **MN5** — reading one session's notes returns only that session's lines.

### 8.4 Agent-verified

- **A1** — the Coda's survey reports boundary events, flagged `observed`.
- **A2** — the Coda asks what to record and writes the human's sentence.
- **A3** — recording nothing is a valid answer.
- **A4** — neither the Coda nor the WIP Warden agent sources a write surface.

## 9. Rollout

Minor bump, 0.70.1 → 0.71.0 — new hook and libraries, and a changed contract.

No new agent, skill, or command, so the component counts are unchanged.

Docs: the hook and the store in `reference/hooks.md`; the notices in the Mast's
and WIP Warden's how-tos; the override in `reference/parking-record-format.md`'s
neighbour, `closing-a-session.md`.
