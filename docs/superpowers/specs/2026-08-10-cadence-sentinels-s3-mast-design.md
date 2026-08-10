# Spec: Cadence Sentinels S3 — The Mast

**Status:** Approved (revision 1)
**Date:** 2026-08-10
**Issue:** #493
**Epic:** The Cadence Sentinels (S1–S7, issues #491–#497)
**Depends on:** S1 (#491, 0.67.0) — the pact file and `pact-blocks.sh`;
S2 (#492, 0.68.0) — the Coda, which the reached notice recommends and which
carries the Mast's override to the record
**Scope:** `ai-literacy-superpowers` plugin; one agent, skill, command, hook,
and a session-scoped note store
**Explicitly out of scope:** the WIP Warden (S4) and the Convener (S5).

**Provenance:** *The Second Front — Arc Insertion Remit* (slide S5) and
*Compulsive Continuation — A Research Exploration*.

---

## 1. Problem Statement

A limit you set for yourself in advance holds. A limit you set in the moment
you are about to breach it does not — you will simply move it, because the
thing you want at 18:00 is to keep working.

That is why the pact file exists, and why S1 refused to scaffold one: an
imposed default is not a pact. But a pact nobody reads is also not a pact. The
Mast is what reads it, tells you where you are against it, and — once, at the
line — offers you the ritual for stopping.

**Epithet:** *the pact-keeper.* **Attacks:** outsourced governance — the drift
where the decision about when to stop migrates from a person who decided it in
advance to a person who is tired and mid-thought.

It feeds the Coda. It never stops anything itself.

## 2. Two Modes, Mirroring `/reservoir`

| Mode | Does |
| --- | --- |
| `/mast` (default `read`) | reports consumption against the declared `Budgets` block |
| `/mast tune` | the **only** sanctioned authoring path for the pact file |

### 2.1 Read mode, and what is honestly observable

Most of a budget is not observable, and saying so is the whole job.

| Key | Flag | Why |
| --- | --- | --- |
| `hard_stop_hour` | `observed` | wall clock |
| `focus_blocks` | `observed` | wall clock |
| `sessions_per_day` | `inferred` | the registry holds *live* sessions, not a day's history — see below |
| `daily_cost_ceiling` | **`asked`**, or *not observable* | nothing in this plugin can see spend |

`sessions_per_day` deserves its own sentence. S1's registry is a lease over
*currently live* sessions; it is not a log and has no day's history in it.
Counting today's sessions from it is possible only for those still within their
lease, so the Mast reports it `inferred` and says what it could not see. It
does **not** reconstruct a day's count and present it as fact.

`daily_cost_ceiling` is the sharper case. Nothing in this plugin observes
spend. The pact template already blesses the literal `not observable` as a
valid value, and the Mast honours that: it will report what the human declared
and what it cannot check, and it will **refuse to estimate**. A fabricated
spend figure against a real ceiling is the worst possible output — it would
make a person stop, or not stop, on a number nobody measured.

### 2.2 The weather check

Tune stamps `authored_at`. Read mode notes when a budget was authored **on the
day it is being enforced**:

> This budget was authored today. A limit set in the weather it governs is not
> the pact the clear-weather rule relies on — worth knowing, not a reason to
> stop.
> *(observed: `authored_at` is today)*

**This is the clear-weather rule's actual mechanism**, and it replaces the one
the build spec specified.

The build spec called for "a critic check that flags `Budgets` diffs lacking a
same-change `authored_via: tune` update". That is impossible here:
`~/.claude/pacts.md` lives outside every work tree and is never committed, so
there is no diff and no CI can see the file. **Flagged for the PR** — it is a
direct consequence of S1's user-scoped pact decision.

The replacement is better aimed. The failure mode the rule exists to catch is
not hand-editing in general — a calm Tuesday-morning tweak is exactly the
deliberate authorship the rule wants. It is *editing the limit in the weather
it governs*: raising `hard_stop_hour` at 18:00 because you want to keep going.
An `authored_at` of today, read at enforcement time, catches that and nothing
else.

It is a **note, never a gate**. The Mast reports it and continues. A sentinel
that refused to honour a pact because it was authored recently would be
second-guessing the person it serves.

### 2.3 Tune mode: one authoring ritual for all three blocks

Tune walks `Budgets`, `Session WIP`, and the reserved `Sync cadence`, and
**creates `~/.claude/pacts.md`** if it does not exist — S1 assigned that here
and nothing else in the epic writes the file.

Three rules govern the dialogue:

1. **It proposes nothing as a default.** It asks. Authorship is the active
   ingredient; a value the human accepted because it was pre-filled is not one
   they authored. The template's numbers are illustrations, not suggestions.
2. **Every block is skippable.** A human who wants only a stop hour gets only a
   `Budgets` block. An undeclared block is not an incomplete pact.
3. **It stamps `authored_at` (today) and `authored_via: tune`**, and says it is
   doing so and why.

For `Sync cadence` it says plainly that the block is reserved and inert before
asking, so nobody declares values believing something reads them.

Tune is the only path that writes the file. That is a convention, not an
enforced boundary — the file is the human's and they may edit it with any
editor they like. §2.2 is what notices when the timing of that edit matters.

## 3. Boundary Notices

Two, each firing **at most once per session**.

| Notice | When | Says |
| --- | --- | --- |
| **approaching** | at 80% of the way from session start to the line | where you are, and what the line is |
| **reached** | at the line | one recommendation: invoke the Coda |

**One recommendation, once.** No repeats, no escalation, no second notice ten
minutes later. Ambient reminders are ignored and then resented; a single
boundary-moment reality check is the thing with evidence behind it.

<!-- evidence: boundary-moment reality checks improve adherence where ambient
     reminders do not. The mechanism is a prompt at the decision point, not
     accumulated pressure — which is why repeating it would not make it work
     better, it would make it work worse. -->

Notices ride the `Stop` hook, so they arrive between turns rather than
interrupting one. Both are `{"systemMessage": ...}` advisories: they never
block, never exit non-zero, and never require a disposition.

### 3.1 The hard stop

When `hard_stop_hour` passes during a live session, the Mast raises the reached
notice and offers `/coda`.

**It does not kill the session.** It cannot, and it should not be able to. The
disposition is the human's.

If they continue, that is recorded — see §4 — as a fact about the session:

```text
observed: continued past the 20:00 stop by choice
```

Never a judgement, never an explanation, never a count of how often. That a
session ran past a declared line is a fact about the session; *why* is not the
Mast's business and is not recorded.

### 3.2 `notification_policy_after_stop` is declared intent

It ships at the **Unverified** rung and is documented as such. Push and digest
behaviour is platform-side and outside this plugin's reach; the block records
the pact so a platform hook can honour it where one exists. The Mast reads it,
reports it, and enforces nothing.

## 4. Session Notes: Where the Override Lives

Constraint 6 requires an on-the-record override. The override happens at 18:31,
mid-session — and `/reflect`, the path to the record, runs a full
branch-PR-merge cycle (S2 §2). Triggering a PR round-trip to record "I chose to
keep working" would be absurd.

**So the Mast writes a session-scoped note, and the Coda carries it to the
record at close** — the moment `/reflect` runs anyway.

```text
~/.claude/mast/<sanitised-session-id>.notes
```

One line per event, append-only within the session:

```text
2026-08-10T20:00:00Z reached hard_stop_hour=20:00
2026-08-10T20:00:00Z continued past the 20:00 stop by choice
```

The Coda's survey reads these and includes them in the `Closed` field. The note
file is **removed once consumed**, which is what bounds it.

### 4.1 This is a third operational-state artefact, and it is evaluated as one

`sentinel-design`'s carve-out permits hook-authored operational state only when
all four conditions hold. S2's choice story #7 established that a consumer must
not park a new file class in another slice's directory and inherit its location
guarantees without its retention contract — so this store is the Mast's own,
and the conditions are checked here rather than assumed:

| Condition | How it holds |
| --- | --- |
| **Local, never committed** | `~/.claude/mast/`, outside every work tree |
| **Bounded** | removed when the Coda consumes it; lease-pruned otherwise, on the same `Stop` rail |
| **Nothing in it judges** | facts about the session — a notice fired, a line was passed. No assessment, no counts across sessions |
| **Disclosed and declinable** | `reference/hooks.md` states what it holds, how long, and how to switch the hook off |

The notes file also carries the once-per-session notice state, so one mechanism
serves both and no second store is invented.

## 5. Files

| File | Purpose |
| --- | --- |
| `agents/mast.agent.md` | `role: sentinel`, read-only — reads the pact, reports consumption with flags |
| `skills/mast/SKILL.md` | the two modes, the clear-weather rule, the notice discipline, the anti-patterns |
| `commands/mast.md` | Read dispatches the agent; Tune walks the authoring dialogue and writes the pact file |
| `hooks/scripts/mast-boundary-check.sh` | `Stop` — fires the two notices, writes session notes, prunes |
| `hooks/scripts/lib/mast-notes.sh` | the note store: append, read, consume, prune |

**The agent holds no `Write`.** Tune's file write is done by the command, after
the human has confirmed each value — the `cost-estimator` precedent, and the
same split S2 used.

## 6. Non-Goals

- **No changes to the Reservoir Warden.** Constraint 5. The Warden recommends
  deciding a stop; whether the human then runs `/coda` is their own move,
  mediated by no artefact — the disposition S2 recorded, unchanged.
- **No blocking.** Nothing here can end a session, and nothing requires a
  disposition.
- **No spend estimation, ever.** If cost is not observable, the Mast says so.
- **No repeats.** One approaching notice and one reached notice per session.
- **No count of overrides across sessions.** A note is consumed at close and
  gone. Aggregating them would be a record of how often someone works late,
  which is the second persistence category, not the third.
- **No enforcement of `notification_policy_after_stop`.**
- **No statusline work.** If a statusline surface exists, contributing to it is
  future work; Read mode is the gauge.

## 7. Acceptance Scenarios (TDAD)

Prefixed **W** for the weather check, **B** for boundary notices, **T** for the
note store, and **A** for agent-verified behaviour.

### 7.1 Weather check and read honesty — `test-mast-read.sh`

- **W1 — a budget authored today is noted.** Given `authored_at` equal to
  today, the read output carries the weather note flagged `observed`.
- **W2 — a budget authored earlier is not noted.** Given `authored_at`
  yesterday or before, no weather note appears.
- **W3 — the note is not a gate.** The weather note never changes an exit code
  and never suppresses the rest of the report.
- **W4 — spend is never estimated.** Given `daily_cost_ceiling` declared and no
  observable spend, the output says it cannot be checked and contains no
  number presented as spend.
- **W5 — `sessions_per_day` is flagged `inferred`**, with a statement of what
  could not be seen.
- **W6 — an absent `Budgets` block degrades to observe-only**, using the S1
  fixed sentence, exit 0.
- **W7 — a malformed `Budgets` block also degrades**, never gates.

### 7.2 Boundary notices — `test-mast-boundary.sh`

- **B1 — approaching fires once.** At 80%, the notice appears; a second run in
  the same session is silent.
- **B2 — reached fires once**, and recommends `/coda` exactly once.
- **B3 — reached does not repeat after an override.** Once the human has
  continued, no further notice fires for that line this session.
- **B4 — before the fraction, silence.**
- **B5 — no `Budgets` block, silence.** Not a note, not an observe-only line —
  a hook with nothing to say says nothing.
- **B6 — exits 0 unconditionally**, including with an unwritable note store and
  `HOME` unset.
- **B7 — the hard stop never blocks.** The hook's output is a `systemMessage`
  advisory and its exit status is 0 in every path.

### 7.3 Note store — `test-mast-notes.sh`

- **T1 — append and read round-trip.**
- **T2 — consume removes the file.**
- **T3 — a stale note file is pruned** past its lease.
- **T4 — notes never leave the store directory.** A hostile session id
  sanitises to `unknown`, as S1 established for the same field.
- **T5 — the store holds no cross-session aggregate.** Reading notes for one
  session returns only that session's lines.

### 7.4 Agent-verified

- **A1** — Read mode reports every key with its flag and never presents an
  unobservable value as observed.
- **A2** — Tune proposes no defaults; every value is asked for.
- **A3** — Tune stamps `authored_at` and `authored_via: tune` and says so.
- **A4** — Tune states that `Sync cadence` is reserved before asking about it.
- **A5** — every block is skippable.
- **A6** — the agent writes no file; Tune's write is the command's.

## 8. Migration & Rollout

Minor bump, 0.68.0 → 0.69.0.

Version locations: the five CI-checked ones, the README plugin-table cell, and
the README count badges, anchors, and section headings — 38 skills → 39,
17 agents → 18, 29 commands → 30. A Layer 1 test asserts the badge matches the
real directory count.

New components need a TDAD scenario each under `tdad_tests/scenarios/`.

Docs, same PR: a how-to for keeping a pact, reference entries on all three
component pages, the hook and the note store in `reference/hooks.md`, the
weather check in `reference/pacts-format.md`, and the sentinels roster 6 → 7.

No breaking changes. The pact file's schema is unchanged; the Mast reads what
S1 defined and writes it only through Tune.
