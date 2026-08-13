# Spec: Cadence Sentinels S3 — The Mast

**Status:** Approved (revision 3, post-cartographer)
**Date:** 2026-08-10
**Issue:** #493
**Epic:** The Cadence Sentinels (S1–S7, issues #491–#497)
**Objections:** `docs/superpowers/objections/cadence-sentinels-s3-mast-design.md`
— 11 objections, 4 accepted, 7 deferred to #501
**Choice stories:** `docs/superpowers/stories/cadence-sentinels-s3-mast-design.md`
— 8 stories, all accepted
**Depends on:** S1 (#491, 0.67.0) — the pact file and `pact-blocks.sh`. **Not
S2.** This slice touches no Coda file and needs none.
**Scope:** `ai-literacy-superpowers` plugin; one agent, one skill, one command,
and a write-side library. No hook, no session state, no new store.
**Explicitly out of scope:** boundary notices and the hard stop, which are
**#501** (see §3); the WIP Warden (S4); the Convener (S5).

**Provenance:** the Cadence Sentinels build spec, supplied in conversation
2026-08-08 — transcribed to `docs/superpowers/cadence-sentinels-charter.md`.
Slice scope: issue #493.

---

## 1. Problem Statement

A limit you set for yourself in advance holds. A limit you set in the moment
you are about to breach it does not — you will simply move it, because the
thing you want at 18:00 is to keep working.

That is why the pact file exists, and why S1 refused to scaffold one: an
imposed default is not a pact. But a pact nobody reads is also not a pact, and
a pact nobody has authored is not one either.

The Mast is what brings a pact into existence, and what reads it back to you.

**Epithet:** *the pact-keeper.* **Attacks:** outsourced governance — the drift
where the decision about when to stop migrates from a person who decided it in
advance to a person who is tired and mid-thought.

It never stops anything itself.

**What this slice is, after the split.** S3 ships the **gauge and the authoring
ritual** — `/mast` reads your pact and tells you where you stand against it;
`/mast tune` is how the pact comes to exist at all. Everything that *speaks at
the boundary* — the approaching and reached notices, the hard-stop trigger, and
the override record — is **#501**.

The split was made at the spec gate because six of eleven objections, including
both criticals, were consequences of one decision: that the Mast writes session
state another slice must consume. Removing that half dissolved them rather than
mitigating them. It also ships the higher-value half first — S1 shipped a
template that no path authors, so **until Tune exists the pact file does not
exist and every other sentinel in this epic is permanently in observe-only.**

## 2. Two Modes, Mirroring `/reservoir`

| Mode | Does |
| --- | --- |
| `/mast` (default `read`) | reports consumption against the declared `Budgets` block |
| `/mast tune` | the **only** sanctioned authoring path for the pact file |

### 2.1 Read mode, and what is honestly observable

Most of a budget is not observable, and saying so is the whole job.

| Key | Flag | Why |
| --- | --- | --- |
| `hard_stop_hour` | `observed` | the wall clock is either past it or not |
| `focus_blocks` | `inferred` | the clock being inside a block is observed; that you *spent* it working is not |
| `sessions_per_day` | `inferred` | the registry holds *live* sessions, not a day's history |
| `daily_cost_ceiling` | **not observable** | nothing in this plugin can see spend |

Two of these were wrong in the first revision and are corrected here (O6).

`focus_blocks` was flagged `observed` on the reasoning that a focus block is a
clock range. But "consumption against a focus block" is not *is the clock
inside it* — it is *did you spend it working*, which needs exactly the day's
history the next row says the registry lacks. The same sentence disqualifies
both; it had been applied to only one.

`daily_cost_ceiling` was flagged `asked`, which describes an act that does not
happen. Reporting a declared ceiling back is reading a pact, not asking a
question — `asked` means the human was asked and answered, as S1 and S2 both
use it. An unearned flag would have left an implementer to invent the question,
and the plausible invention is asking what someone spent today, which nothing
authorises.

`sessions_per_day` deserves its own sentence. S1's registry is a lease over
*currently live* sessions; it is not a log and has no day's history in it.
Counting today's sessions from it is possible only for those still within their
lease, so the Mast reports it `inferred` and says what it could not see. It
does **not** reconstruct a day's count and present it as fact.

On cost specifically: nothing in this plugin observes spend. The pact template
already blesses the literal `not observable` as a valid value, and the Mast
honours it — reporting what the human declared and what it cannot check, and
**refusing to estimate**. A fabricated spend figure against a real ceiling is
the worst possible output: it would make a person stop, or not stop, on a
number nobody measured.

### 2.2 The weather check, and exactly what it sees

Tune stamps `authored_at`. Read mode notes when the budget it is reading was
**tuned today**:

> This budget was tuned today, so it has not been lived with yet. Worth knowing
> when it asks something of you tonight.
> *(observed: `authored_at` is today)*
> *(A pact edited outside `/mast tune` is not visible to this check.)*

**What it detects, stated honestly.** It detects a budget *tuned* today. That
is a true and useful thing to say — a pact authored hours ago has not yet
survived contact with a day, and knowing that is worth a line when it asks
something of you.

**What it does not detect: weather-editing.** Revision 1 claimed this check
caught "raising `hard_stop_hour` at 18:00 because you want to keep going… and
nothing else". That was exactly backwards (O5). `authored_at` moves only when
Tune writes it, so:

| The human does | `authored_at` | Note fires |
| --- | --- | --- |
| Hand-edits the stop hour at 18:00 | unchanged | **no** |
| Runs `/mast tune` on a calm Tuesday morning | today | **yes**, that evening |

It fires on the honest path and stays silent on the dishonest one. A check that
claims coverage it does not have is worse than one that claims none, because
the human learns to read its silence as an all-clear.

So the note says what it sees, and the reference page and the skill both carry
the blind spot in the same words. A hand-edit is invisible to this check and
always will be — the pact file is the human's, outside every work tree, and
nothing watches it.

**Why not something stronger.** The build spec called for "a critic check that
flags `Budgets` diffs lacking a same-change `authored_via: tune` update". That
is impossible here: `~/.claude/pacts.md` is never committed, so there is no
diff and no CI can see the file. **Flagged for the PR** — a direct consequence
of S1's user-scoped pact decision. Checksumming the block would detect
hand-edits, but it would flag the calm Tuesday tweak too, which §2.2's own
reasoning says is the authorship the rule *wants*.

The honest position is a note with a disclosed blind spot, at the **Unverified**
rung, rather than a check that overclaims. That is the same call §2.1 makes
about spend, for the same reason.

It is a **note, never a gate**. A sentinel that refused to honour a pact because
it was authored recently would be second-guessing the person it serves.

### 2.3 Tune mode: one authoring ritual for all three blocks

Tune walks `Budgets`, `Session WIP`, and the reserved `Sync cadence`, and
**creates `~/.claude/pacts.md`** if it does not exist — S1 assigned that here
and nothing else in the epic writes the file.

The dialogue's rules and the exact shape of what it writes are §5 — that
section exists because revision 1 specified the ritual and never said what it
produced, which is the highest-consequence gap the gate found (O7).

Tune is the only path that writes the file. That is a **convention, not an
enforced boundary** — the file is the human's and they may edit it with any
editor they like, and nothing in this plugin will know. §2.2 says plainly what
that costs the weather check.

## 3. Boundary Notices Are Not In This Slice

The approaching notice, the reached notice, the hard-stop trigger, and the
override record are **#501**.

They were specified here in revision 1 and moved out at the spec gate. The
reason is worth recording, because it is the same shape three times: each of
those mechanisms required the Mast to *write session state that another slice
must consume*, and every one of the slice's structural problems followed from
it.

- The override needed the Coda's survey and its `Closed` field — a contract S2
  owns and shipped, which knows nothing of notes.
- The note store bundled `append, read, consume, prune` in one library a
  `role: sentinel` agent had to reach, re-opening the channel S1 split two
  libraries to close.
- The once-per-session guarantee lived in the file that consumption deletes.
- Two stop advisories could land on the same turn, since a declared `lark`
  enters the Reservoir Warden's suboptimal band at hour ≥ 20.

None of that is wrong to build. It is wrong to build *here*, alongside a file
reader, in a slice whose adversarial pass then has to be about two unrelated
things at once.

**What remains true and is carried to #501:** the notice discipline itself. One
recommendation, once, at the boundary — no repeats, no escalation.

<!-- evidence: boundary-moment reality checks improve adherence where ambient
     reminders do not. The mechanism is a prompt at the decision point, not
     accumulated pressure — which is why repeating it would not make it work
     better, it would make it work worse. Recorded here because it is the
     reason #501 exists at all. -->

`notification_policy_after_stop` likewise stays declared intent at the
**Unverified** rung. The Mast reads it and reports it; nothing enforces it, and
nothing in this plugin can.

## 4. Files

| File | Purpose |
| --- | --- |
| `agents/mast.agent.md` | `role: sentinel`, read-only — reads the pact, reports consumption with flags |
| `skills/mast/SKILL.md` | the two modes, the clear-weather rule and its honest limits, the anti-patterns |
| `commands/mast.md` | Read dispatches the agent; Tune walks the dialogue and calls the writer |
| `hooks/scripts/lib/pact-write.sh` | the write surface — composes and replaces a block |

No hook. No session state. Nothing outside `~/.claude/pacts.md` is written.

**Why a library and not prose.** The first revision of this slice shipped no
shell at all, and the write path was six numbered rules for a model to follow.
That did not survive contact with §7: T1–T7 are Layer-0 deterministic
scenarios, and there is nothing deterministic to test when the writer is prose
in a command file. Either the round-trip tests were not real or the writer was.

`lib/pact-write.sh` is **sourceable by commands and hooks only**, matching the
split S1 made for the registry and the rule `sentinel-design` promoted from it:
a read surface a sentinel may source, a write surface it may not. The `mast`
agent never sources it and never writes.

**The agent holds no `Write`.** Tune's write is the command's — the
`cost-estimator` precedent, and the same split S2 used.

## 5. Tune: the Ritual and the Writer

Tune is the only sanctioned authoring path, and revision 1 never said what it
produces (O7). That gap mattered: **Tune is the one component in this epic that
*produces* the pact file, and its output is the input to every other sentinel.**
Everything else degrades safely when the file is wrong; Tune is what makes it
wrong.

### 5.1 It is an editor, not only an author

`/mast tune` reads the current pact first and asks each question **with the
human's existing value as context** — "your line is 18:30; what should it be?"

That is not a proposed default. Nothing is pre-filled by the plugin, and what
is shown is the human's own prior authorship rather than the template's
illustration. The distinction matters because the alternative is worse: without
it, the only sanctioned way to move one number is to re-run the whole ritual,
and the cheapest path to a small edit becomes opening the file in an editor —
the channel §2.2 says the weather check cannot see. A pact is meant to be
revised in clear weather, so the honest revision path must be cheaper than the
dishonest one.

`/mast tune budgets` scopes the ritual to one block. `/reservoir tune`, the
mirror §2 names, already works this way.

### 5.2 The stop hour first

The dialogue asks `hard_stop_hour` **first**, and then offers to stop there.

A complete, useful two-line pact is reachable in one question. The remaining
keys are offered rather than marched through — a person asked cold for
`max_switches_per_hour` has no basis for an answer, and a number invented to
move the dialogue along is not more authored than one they declined to give.

This does not weaken rule 5 below. It pays down its cost: a blank field
maximises freedom and minimises completion, and the only cheap exit the first
revision offered was skipping a whole block — which produces `absent`, which
returns the human to observe-only, which is the state this epic exists to move
them out of.

### 5.3 It says what nothing reads yet

Before asking about any key no consumer reads today, Tune says so:

- `Sync cadence` — reserved entirely.
- `Session WIP` — only `stale_after_hours` is read today (by S1's registry
  lease). `max_concurrent_sessions`, `max_switches_per_hour` and `enforcement`
  wait for S4.
- `notification_policy_after_stop` — declared intent at the Unverified rung;
  nothing in this plugin enforces it.
- `daily_cost_ceiling` — declared, never checkable (§2.1).

Revision 1 disclosed this for `Sync cadence` alone, because that is the block
S1 happened to give a reserved marker. But the property that triggers
disclosure — a declaration nothing reads — belongs to *keys at a point in
time*, not to blocks. A human authoring their first pact would otherwise have
been working under two regimes without being told there were two.

### 5.4 It composes, shows, and then writes

Tune builds the block from the answers, **shows it**, and takes accept / edit /
abort before anything is written.

Per-value confirmation is not enough on its own. The parts of the file the human
did not author — the mandatory clause, the reserved marker, `authored_at`,
`authored_via` — are exactly the parts that decide whether the block reads as
`declared`, and without a composed preview they land unseen. This is also what
makes Tune an instance of the agent-emit / dispatcher-persist / human-disposes
architecture rather than a citation of its tool split: there is now a point at
which the whole pact can be refused.

### 5.5 What the writer guarantees

`lib/pact-write.sh` exposes `pact_write_block <heading> <body-file>`:

1. **Derives the mandatory clause and the reserved marker from
   `templates/pacts.md`**, never from a copy. A restated clause agrees with
   `pact-blocks.sh` only by coincidence of wording; the promoted decision is
   that harness artefacts derive from the source of truth rather than pinning a
   copy of it.
2. **Replaces a block in place; never appends.** `_block_span` exits at the
   next known heading, so a second `## Budgets` is silently unread and the
   newly tuned values are invisible.
3. **Stamps `authored_at` and `authored_via: tune` on `Budgets` only**, where
   S1's grammar defines them. Revision 1 stamped every block written, extending
   two blocks S3 does not own — and leaving "when was this pact authored" a
   per-block fact with no rule for combining them.
4. **Preserves everything outside the block it is replacing**, including the
   template's editing guidance.

### 5.6 The validation checkpoint

After writing, Tune reads the block back, asserts `block_state` returns
`declared`, and fixes in place.

This is not optional politeness. `CLAUDE.md` requires a validation checkpoint of
**every command that produces structured output parsed by downstream
consumers**, and `/mast tune` produces the file `pact-blocks.sh` parses.
`/reservoir tune` carries one. Its absence from revision 1 was a convention
violation, and it is the one guard that catches a malformed write at the moment
it happens rather than the next time a sentinel silently degrades.

## 6. Non-Goals

- **No notices, no hard stop, no override record.** #501.
- **No hook.** This slice adds nothing to the `Stop` rail.
- **No session state and no new store.** Nothing is created under
  `~/.claude/` except the pact file the human asked for.
- **No changes to the Reservoir Warden.** Constraint 5. And with no notices,
  nothing in this slice can collide with its advisory.
- **No changes to the Coda.** This slice touches no S2 file.
- **No blocking.** Read mode reports; the weather note is a note.
- **No spend estimation, ever.** If cost is not observable, the Mast says so.
- **No statusline work.** Read mode is the gauge.

## 7. Acceptance Scenarios (TDAD)

Prefixed **W** for the weather check and read honesty, **T** for Tune's output,
and **A** for agent-verified behaviour.

### 7.1 Read honesty — agent-verified, pinned by the TDAD scenario

Read mode is a dispatched agent, so its honesty is verified structurally
(the flags it must carry, the things it must refuse) rather than by a Layer-0
script. The W scenarios below are assertions about the skill and agent files.

- **W1 — a budget tuned today is noted**, flagged `observed`, with the note
  saying the pact has not been lived with yet.
- **W2 — a budget tuned earlier raises no note.**
- **W3 — the note is not a gate.** It never changes an exit code and never
  suppresses the rest of the report.
- **W4 — the note discloses its own blind spot.** The output states that an
  edit made outside `/mast tune` is invisible to the check.
- **W5 — spend is never estimated.** Given a declared `daily_cost_ceiling`, the
  output says it cannot be checked and contains no number presented as spend.
- **W6 — `focus_blocks` and `sessions_per_day` are flagged `inferred`**, each
  with a statement of what could not be seen.
- **W7 — an absent `Budgets` block degrades to observe-only** using S1's fixed
  sentence, exit 0.
- **W8 — a malformed `Budgets` block also degrades**, and names the missing
  clause rather than only reporting malformed.

### 7.2 The writer — `tdad_tests/layer0_deterministic/test-pact-write.sh`

The scenarios revision 1 lacked, and the most valuable in the slice. They are
deterministic because §4 ships a writer; against a prose-only Tune none of them
could exist.

- **T1 — the writer's output reads as `declared`.** A block written by
  `pact_write_block`, run through `block_state`, returns `declared`. This is
  the round trip that makes the reader and the writer one contract.
- **T2 — the mandatory clauses are present** in every block written.
- **T3 — the reserved marker is present** when `Sync cadence` is written.
- **T4 — a skipped block is absent, not empty.** `block_state` returns
  `absent`, and the file contains no heading for it.
- **T5 — a second run rewrites in place.** After tuning `Budgets` twice, the
  file contains exactly one `## Budgets` heading and `block_key` returns the
  second run's value.
- **T6 — the stamps land on `Budgets` only**, where S1's grammar defines them,
  and on no other block.
- **T8 — content outside the replaced block survives**, including the
  template's editing guidance and any other declared block.
- **T9 — the clause is derived, not restated.** Changing the clause in
  `templates/pacts.md` changes what the writer emits, with no edit to the
  writer.
- **T7 — values with colons and spaces survive the round trip.**
  `hard_stop_hour: 18:30` and `focus_blocks: 09:00-12:00, 14:00-17:00` read
  back whole through `block_key` — the S1 regression, now reachable from the
  writer's side.

### 7.3 Agent-verified

- **A1** — Read mode reports every key with its flag and never presents an
  unobservable value as observed.
- **A2** — Tune proposes no defaults; every value is asked for.
- **A3** — Tune states that `Sync cadence` is reserved before asking about it.
- **A4** — every block is skippable, and skipping is offered.
- **A5** — the agent writes no file; Tune's write is the command's.
- **A6** — Read mode says plainly what it cannot see, rather than omitting it.

## 8. Migration & Rollout

Minor bump, 0.68.0 → 0.69.0.

Version locations: the five CI-checked ones, the README plugin-table cell, and
the README count badges, anchors, and section headings — 38 skills → 39,
17 agents → 18, 29 commands → 30. A Layer 1 test asserts the badge matches the
real directory count.

A TDAD scenario per new component under `tdad_tests/scenarios/`.

Docs, same PR: a how-to for keeping a pact, reference entries on all three
component pages, the weather check and its blind spot in
`reference/pacts-format.md`, and the sentinels roster 6 → 7.

No breaking changes. The pact file's schema is unchanged; the Mast reads what
S1 defined and writes it only through Tune. No hook is added, so the `Stop`
rail is untouched.
