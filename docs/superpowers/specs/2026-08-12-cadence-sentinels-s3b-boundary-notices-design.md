# Spec: Cadence Sentinels S3b — Boundary Notices and the Hard Stop

**Status:** Approved (revision 2, post-diaboli)
**Date:** 2026-08-12
**Issue:** #501
**Epic:** The Cadence Sentinels (S1–S7)
**Depends on:** S1 (the pact file, the registry), S2 (the Coda, whose contract
this changes), S3 (the Mast), S4 (the WIP Warden, whose override this carries)
**Objections:** `docs/superpowers/objections/cadence-sentinels-s3b-boundary-notices-design.md`
— 12 objections, all accepted; three criticals reshaped the slice
**Scope:** one hook, three libraries, a contract change to S2, and one
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
| **approaching** | `approaching_lead_minutes` before `hard_stop_hour` (default 30) | where you are, and what the line is |
| **reached** | at `hard_stop_hour` | one recommendation: `/coda` |

**A lead time, not a fraction.** Revision 1 said "80% of the way from session
start to `hard_stop_hour`", which is not computable (O5). `started_at` is UTC
and `hard_stop_hour` is local, so the naive arithmetic is silently wrong by the
machine's offset. Worse, `registry_touch` deliberately never resets
`started_at` across resume, clear and compact — so a session resumed the next
morning reports yesterday's start, and the fraction is already past 80% at
breakfast. The notice would fire on resume, every morning, with nothing
approached.

A fraction needs two endpoints and only one of them is honest: the line the
human drew. A lead time needs one, sits in the same frame as the value it
measures against, and has no behaviour to define for midnight or for a session
that begins after the line.

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

Two sentinels counsel stopping on the same rail and can fire on the same turn:
`reservoir-check.sh` puts a declared `lark` into its suboptimal band at hour
≥ 20, so a `hard_stop_hour: 20:00` produces two independent stop advisories.

Two messages about stopping, arriving together, **is** accumulated pressure —
which the evidence in §2 says makes the mechanism work worse.

### 3.1 Precedence, not registration order

Revision 1 said the first hook to claim wins, and ordered the Warden first. That
inverted the rail's purpose (O1).

`reservoir-check.sh` has **no once-per-session guard and cannot have one** — it
persists nothing by charter, recomputes an eight-hour git window every `Stop`,
and emits whenever a threshold is still crossed. Thresholds stay crossed for
hours. So the Warden speaks on **every turn**, while the Mast's `reached` fires
once, ever.

First-claim-wins with the Warden first therefore preserved the message that
repeats and permanently spent the one designed to arrive once — and because the
note is still logged on the suppressed turn, the human would never have received
the boundary message at all.

So the rail arbitrates by **precedence**:

| Class | Example | On a collision |
| --- | --- | --- |
| **once-only** | the Mast's `approaching` and `reached` | speaks |
| **repeating** | the Warden's band advisory | defers to the next turn |

The Warden loses nothing by deferring: it fires again next turn, on the same
conditions. The Mast's notice has no next turn.

Revision 1 also justified the old order by claiming *decide your stop* subsumes
*you have reached the stop you decided*. The shipped sentence does not say that
— it asks the human to decide a **future** stop before the **next** session
(`reservoir-check.sh:133`), which is advice for someone who has not drawn a
line. The person who declared `hard_stop_hour: 20:00` has already done it, and
the suppressed message was the one naming their own line. The argument is
withdrawn rather than repaired (O2).

### 3.2 What a "turn" is, stated operationally

A `Stop` hook receives no turn identifier, and every hook in one firing sees the
same `session_id`. So a turn is defined by the only thing available (O3):

**Hooks in one `Stop` firing run back-to-back**, so a claim is scoped by a
short wall-clock window — **10 seconds**, recorded in the claim file.

Its two failure modes are disclosed rather than hidden, in the skill and the
reference page:

- Two turns completing inside 10 seconds collapse into one, so a turn's
  repeating advisory is suppressed. Costs one skipped Warden message.
- A rail slow enough to straddle 10 seconds lets both emit. Costs one duplicate.

Both are bounded and neither is silent to a reader of the docs. Claiming uses
`mkdir`, which is atomic on every POSIX filesystem — a rail whose guarantee is a
race would flicker, and a sentinel that flickers teaches the human to discount
it.

### 3.3 The one line in `reservoir-check.sh`

It gains a single `advisory_defer_if_claimed` guard before it emits.

This is a change to the Reservoir Warden's hook, and constraint 5 says that
agent is untouched. The judgement, recorded: **this is a coordination change,
not a behavioural one.** Its proxies, thresholds, honesty flags, recommendation
text and advisory-forever standing are all unchanged, and it still fires
whenever it would have fired — except on the at most one turn per session when
a once-only advisory has claimed.

**The Mast's hook is registered before it** in `hooks.json`, so precedence and
order agree rather than the guarantee resting on precedence alone.

### 3.4 What the Mast does when it defers

It never defers — it is the once-only class. When it speaks, it logs the note
either way.

## 4. The Note Store

`~/.claude/mast/<sanitised-repo-slug>.notes` — append-only, one line per event.

```text
2026-08-12T20:00:00Z reached hard_stop_hour=20:00
2026-08-12T21:14:00Z wip-breach 3 live against a limit of 2
2026-08-12T23:10:00Z consumed-by-coda
```

### 4.0 It records what fired, never what it meant

Revision 1's example carried a second line beside the first —
`continued past the 20:00 stop by choice` — timestamped **identically** to the
notice. Whatever wrote it wrote it before the human had done anything at all
(O6).

That is a hook attributing intent to a person. Nothing observes a choice:
**continuing is the absence of stopping**, and reading intent into silence is
exactly what the boundary between counting and watching forbids. It also
falsified two of this spec's own claims — §4.4's judges-nothing condition, and
§5.1's `observed` flag, which is true of `reached` and was false of the line
beside it.

So the store holds **only what fired**. There is no override line, because
there is nothing to observe. What the human decided is asked for at close (§5.4)
and their answer is the only account that exists — which also means there is no
machine sentence left to accept by default, dissolving O10 entirely.

### 4.1 Keyed by repo, because its writers are commands

Revision 1 keyed the store by session id. Its two writers are `/coda` and
`/wip` — **commands**, which have no channel to learn one. Every shipped reader
takes `session_id` from hook stdin, and no command in this plugin reads it (O9).

The obvious workaround — take the newest file — fails in exactly the world this
epic exists for: `/coda` in one session would consume another's notes, silently,
because the file it read contained plausible lines.

So the key is the repo. A command knows its working directory, so everything
that touches the store can name it. Per-session isolation is not lost so much as
never achievable — and the scope fits: boundary events concern a pact that is
machine-global and a person who is singular, and the Coda closes a session *in a
repo*.

### 4.1a Marked consumed, never deleted

The Coda **marks** the file consumed rather than removing it.

S3's O3 found the reason: the once-per-session notice state lives here, and
`/coda`'s final step is a statement rather than a process termination — the
session is alive and the `Stop` rail keeps firing. A file deleted at close would
take the notice state with it, and `reached` would fire again on the next turn,
on exactly the sessions where the human had already been told once.

Marking also makes a second `/coda` idempotent, which deletion would not have
been.

### 4.1b Bounded by a heartbeat, not by an event

The notes file is **touched on every `Stop` while its repo has a live session**,
exactly as a registry entry is — the same shape, for the same reason.

Revision 1 said "lease-pruned, exactly as the registry is", which was not true
of the mechanism it described: a notes file has no heartbeat and is appended to
only on a boundary event, so under the default 12-hour lease a session reaching
its stop at 20:00 and still alive at 08:00 would have its own hook prune its
notice state — and `reached` would fire again (O8). That is S3's O3 arriving
through the pruner instead of through consumption.

Touching on every `Stop` makes one lease serve both jobs without compromise: a
live repo's notes never age out, a dormant one's do.

### 4.1c The prune runs unconditionally

**Before the self-gate, for every user, exactly as `registry_prune` does.**

Revision 1 put the prune behind the `block_state` check, which meant a human who
used the feature for a month and then deleted their `Budgets` block left every
note file behind forever (O7). The one path where someone has withdrawn consent
is the one path where leftover state matters most, and gating the cleanup behind
the feature is precisely backwards.

The janitor is separable from the opt-in, and must be.

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
says what fired — "your 20:00 stop passed at 20:00" — and asks whether they want
to record anything about it. What reaches the reflection fragment is a line the
person authored and would recognise as theirs.

**Nothing is offered as a default.** Revision 1 proposed the note's own content
as a starting point, which after §4.0 no longer exists — and would have been a
machine-authored observation about conduct, accepted at the tiredest moment of
the day, landing in a permanently archived file (O10). The question is open,
and a blank answer records nothing.

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
| `hooks/hooks.json` | registers the new hook **before** `reservoir-check.sh` |
| `skills/coda/SKILL.md` | the survey table §5.1 amends, and the ritual's length |
| `templates/pacts.md` | `approaching_lead_minutes`, and the override now *is* recorded |
| `reference/pacts-format.md` | the same two corrections |

The last three are the third file-table omission in four slices (S3's O1, S4's
O11, and this). §6 now lists every file the change cannot land without — the
ordering guarantee lives in `hooks.json` and nowhere else, and the two pact
surfaces currently tell the human their answers are *not* written down, which
this slice makes false.

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
