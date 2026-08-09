# Spec: Cadence Sentinels S2 — The Coda

**Status:** Approved (revision 1)
**Date:** 2026-08-09
**Issue:** #492
**Epic:** The Cadence Sentinels (S1–S7, issues #491–#497)
**Depends on:** S1 (#491, merged as 0.67.0) — the parking-record contract,
`records_open`, and the pact file
**Scope:** `ai-literacy-superpowers` plugin; one new agent, skill, command,
hook, and validator
**Explicitly out of scope:** the Mast (S3), the WIP Warden (S4), the Convener
(S5). S2 ships the ritual and the records it writes.

**Provenance:** *The Second Front — Arc Insertion Remit* (slide S5) and
*Compulsive Continuation — A Research Exploration*.

---

## 1. Problem Statement

An agentic session has no terminal cue. There is no compile, no deploy, no
colleague standing up to leave — the medium supplies nothing that says *this is
finished*. So sessions end by attrition rather than by decision: the human stops
when something external interrupts, and the work is left in whatever state the
interruption found it.

Two costs follow. The unfinished threads keep their pull, because nothing wrote
down where they were. And the next session opens cold, re-deriving from a diff
what the previous session knew.

The Coda is the good ending: a ritual that closes a session deliberately,
records what landed, and parks every live thread with a concrete resume step.

**Epithet:** *the good ending.* **Attacks:** compulsive continuation.

## 2. The Ritual

The same sequence every invocation, no reordering. The order is the design: a
survey before a summary so the summary is grounded; reflection before parking so
the parked records inherit what was just learned; parking before closing so
nothing is left holding.

| # | Step | Produces |
| --- | --- | --- |
| 1 | **Survey** | landed work and live threads, all `observed` |
| 2 | **Closure summary** | a "what landed" statement |
| 3 | **Reflection** | invokes the existing `/reflect` flow |
| 4 | **Park** | one parking record per live thread |
| 5 | **Close** | the session ends |

### 2.1 Survey

Enumerate, all flagged `observed` because all of it is read from disk:

- **Landed** — commits on the branch, merged PRs, resolved dispositions in
  objection and story records touched this session.
- **Live** — in-flight work: modified-but-uncommitted files, an open PR
  awaiting checks, objection or story records still carrying `pending`
  dispositions, and any `records_open` result already parked from a previous
  session.

Nothing here is inferred. If the Coda cannot see something, it does not guess
at it — it asks.

### 2.2 Closure summary

A short "what landed" statement, written into the session's reflection fragment
as a new optional field (§4). Closure needs an artifact; the medium supplies no
terminal cue, so the ritual has to leave one behind.

### 2.3 Reflection

The Coda **invokes the existing `/reflect` flow**. It does not reimplement
reflection, does not ask the three questions itself, and does not write the
fragment directly. `/reflect` already owns the fragment schema, the signal
classification, and the auto-constraint proposal; duplicating any of that would
create a second reflection path that drifts from the first.

### 2.4 Park

For every live thread, one parking record per the S1 contract
(`reference/parking-record-format.md`): frontmatter, a `## Context` paragraph,
and a `## Next action` section carrying **one concrete resume step**.

`next_action` is mandatory and validated — see §3, which is the substantive
part of this slice.

### 2.5 Close

The Coda **refuses to open new work in the closing breath.** Any work request
arriving after the ritual has started is parked, not executed.

"Almost done" is the state hardest to leave, and the closing breath is where
"while we're here" does its damage: the ritual that was about to end the session
becomes the preamble to another hour.

The refusal targets that drift, not the human's ability to change their mind.
If the human says plainly that they want to keep working, the Coda **abandons
the ritual cleanly** — no half-closed session, no partial parking — and says so.
A ritual that cannot be called off would be a gate on the person, which is the
anti-pattern `sentinel-design` names.

### 2.6 Resumption

At session start, if any parking record for this repo is still open, surface it:
id and next action, nothing more. This is the payoff that makes parking
trustworthy — a record nobody ever sees again is a diary, not a handoff.

Implemented as a `SessionStart` hook over `records_open`
(`hooks/scripts/lib/record-paths.sh`, shipped in S1). Advisory, silent when
there is nothing parked, exit 0 unconditionally.

## 3. The Next-Action Validator

The single mechanism in this slice that does real work.

### 3.1 Why it exists

A written plan for an unfinished task releases its pull — but **specificity is
the active ingredient**, not the writing. "Continue work" is a written plan and
does nothing. "Implement the retry branch of slice 7's error path, starting from
the failing test in `test_retry.py`" is a written plan that works.

<!-- evidence: Masicampo & Baumeister 2011 — a specific written plan, not
     completion, releases the unfinished-task pull. The specificity is what
     carries the effect, which is why this is validated rather than merely
     prompted for. -->

### 3.2 What it checks

`scripts/validate-next-action.sh <text>` — a deterministic heuristic, so it is
testable and the command and the agent share one answer.

A next action **fails** when either holds:

1. It matches a vague-stem pattern and carries nothing else: `continue`,
   `carry on`, `keep going`, `finish (this|it|up)`, `more work`, `pick up where
   …`, `resume`, `carry on with …` where the remainder is a bare noun phrase.
2. It contains **no concrete anchor** — no path-like token, no
   `identifier`-shaped token, no test or function name, no line or section
   reference, no quoted string.

It **passes** on any next action carrying at least one anchor and not consisting
solely of a vague stem.

### 3.3 The heuristic is disclosed, not hidden

A heuristic gets this wrong in both directions, and pretending otherwise would
be the overclaiming this epic exists to avoid. So:

- The failure message **names what was missing**, never merely "too vague": it
  asks for a file, a test, or a first step.
- The check is stated in the skill and the reference page, so a human can see
  why their wording failed rather than guessing at a hidden rule.

### 3.4 The override, on the record

**Reprompt once, then defer to the human.** A first failure gets one reprompt
naming what is missing. If the human gives the same answer again, the Coda
**parks it anyway** and the record carries `next_action_flag: asked-override`.

This is constraint 6 applied literally: no gate without an on-the-record human
override, and never a bypass. The default stays firm because the evidence
supports firmness; the human stays in charge because a sentinel that traps
someone at the end of a session has become the thing it was built to prevent.

The override is a *record* value, not a silence: a later reader can see that the
specificity check fired and that the human overrode it.

## 4. Contract Changes

Two contracts owned elsewhere change here. Both are carved out explicitly rather
than slipped in, per the promoted ARCH_DECISION that **a consumer never mutates
the contract it consumes**. S2 is a consumer of both.

This is the *second* worked instance of that decision (the first was
`format-revision-per-stage-cost`), which its Rule-of-Three watch item asks to be
recorded.

### 4.1 Parking record: `next_action_flag` becomes an enum

Owned by S1 (`reference/parking-record-format.md`).

| Before | After |
| --- | --- |
| `next_action_flag: asked` | `next_action_flag: asked \| asked-override` |

`asked` — the next action passed the specificity check.
`asked-override` — it did not, and the human confirmed it anyway.

Both values still mean the next action came from the human. Neither is an
inference, so constraint 3 is unaffected: this records *how the human answered*,
never a judgement about them.

### 4.2 Reflection fragment: a new optional `Closed` field

Owned by `/reflect` and `scripts/lib/reflection-log-helpers.sh`.

```text
- **Closed**: [what landed this session; what was parked, and how many]
```

Optional, and absent from every fragment `/reflect` writes on its own — only the
Coda's invocation supplies it. The change is additive: `extract_field` resolves
by name and `regenerate_log` concatenates fragments verbatim, so no existing
fragment, parser, or archive path is affected.

The alternative — a third record directory — was rejected at the design gate:
the reflection fragment already *is* the session-scoped record, `/reflect`
already runs inside the ritual, and a third schema would need its own
contract-ownership treatment for no gain.

## 5. Files

| File | Purpose |
| --- | --- |
| `agents/coda.agent.md` | `role: sentinel`, `tools: [Read, Glob, Grep, Bash]` — surveys and returns record content |
| `skills/coda/SKILL.md` | the ritual, the evidence, the anti-patterns |
| `commands/coda.md` | dispatches the agent, runs the validator, persists records after the human disposes |
| `scripts/validate-next-action.sh` | the specificity check |
| `hooks/scripts/parked-resume-check.sh` | `SessionStart` — surfaces open parking records |

**The agent holds no `Write`.** It returns parking-record content as a string;
`/coda` persists it. That is the `cost-estimator` precedent and what keeps the
Coda inside the sentinel category its own docs place it in.

## 6. Non-Goals

- **No reimplementation of reflection.** The Coda calls `/reflect`.
- **No changes to the Reservoir Warden.** The Coda may be *offered* when the
  Warden's threshold is crossed and the human accepts its decide-your-stop
  recommendation — never invoked automatically from it.
- **No automatic invocation at all in this slice.** S3 wires the hard-stop
  trigger. `/coda` is manual here.
- **No new gates on the pipeline.** The ritual gates a session's ending, which
  the human started, and always yields to the human.
- **No claim about why the human stopped.** Records say a session closed and
  what was parked. Never why.

## 7. Acceptance Scenarios (TDAD)

Prefixed **V** for the validator, **P** for parking records, **H** for the
resume hook, and **A** for agent-verified ritual behaviour.

### 7.1 Validator — `tdad_tests/layer0_deterministic/test-next-action.sh`

- **V1 — vague stems rejected.** `continue work`, `carry on`, `keep going`,
  `finish this`, `pick up where I left off`, `more work on the parser` each exit
  non-zero.
- **V2 — concrete actions accepted.** `implement the retry branch of slice 7's
  error path, starting from the failing test in test_retry.py`,
  `fix block_key's handling of a trailing comment in pact-blocks.sh:88`, and
  `add the B12 fixture for a malformed Sync cadence block` each exit 0.
- **V3 — the message names what is missing.** A rejection mentions a file, a
  test, or a first step — never only "too vague".
- **V4 — anchor without a stem passes.** `test_retry.py` alone passes: it is
  terse but concrete, and the check is for specificity, not prose.
- **V5 — stem with an anchor passes.** `continue the retry branch in
  test_retry.py` passes — a vague stem is only fatal when nothing else is there.
- **V6 — empty and whitespace-only rejected.**

### 7.2 Parking records — `test-record-contracts.sh` (extended)

- **P1 — the enum is documented.** `reference/parking-record-format.md` names
  both `asked` and `asked-override` and says what each means.
- **P2 — an override record is well-formed.** A fixture carrying
  `next_action_flag: asked-override` satisfies every other field of the S1
  contract.
- **P3 — an overridden record is still open.** `records_open` returns it: an
  override changes the flag, never the record's state.

### 7.3 Resume hook — `tdad_tests/layer0_deterministic/test-parked-resume.sh`

- **H1 — silent when nothing is parked.** Empty stdout, exit 0.
- **H2 — silent when the directory does not exist.** Exit 0.
- **H3 — surfaces an open record.** Output names the record and its next
  action.
- **H4 — a resumed record is not surfaced.** A record superseded by a
  `.resumed.md` transition does not appear.
- **H5 — exits 0 unconditionally**, including when the parked directory is
  unreadable.

### 7.4 Ritual — agent-verified, recorded in the skill

- **A1** — the ritual runs its five steps in order, no reordering.
- **A2** — a post-ritual work request is parked, not executed.
- **A3** — a human who says plainly they want to continue gets the ritual
  abandoned cleanly, not half-completed.
- **A4** — the Coda writes no file itself; every record is persisted by the
  command after the human confirms.

## 8. Migration & Rollout

Minor bump, 0.67.0 → 0.68.0 — a new agent, skill, command, and hook.

Version locations: the five CI-checked ones plus the README plugin-table cell,
and the README component counts (37 skills → 38, 16 agents → 17, 28 commands →
29).

Docs, same PR:

- `how-to/closing-a-session.md` — the ritual, when to use it, what it writes
- `reference/parking-record-format.md` — the `next_action_flag` enum (§4.1)
- `reference/hooks.md` — the resume hook
- `reference/agents.md`, `reference/commands.md`, `reference/skills.md` — entries
- `explanation/sentinels.md` — roster 5 → 6

No breaking changes. `next_action_flag` gains a value and loses none; the
reflection `Closed` field is optional and additive; the resume hook is silent
until a parking record exists.
