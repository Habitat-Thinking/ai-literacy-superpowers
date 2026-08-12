# Spec: Cadence Sentinels S5 — The Convener

**Status:** Approved (revision 1)
**Date:** 2026-08-12
**Issue:** #495
**Epic:** The Cadence Sentinels (S1–S7)
**Depends on:** S1 (0.67.0) — the consultation-record contract, already shipped
and unchanged by this slice
**Scope:** `ai-literacy-superpowers` plugin; one agent, skill, command, and one
`HARNESS.md` constraint
**Explicitly out of scope:** contacting anyone, ever.

**Provenance:** *The Second Front — Arc Insertion Remit* (slide S5).

---

## 1. Problem Statement

A spec can be internally excellent and still be wrong, because the person who
wrote it never asked the one question that would have changed it.

That failure is invisible from inside. The Diaboli attacks the spec's premises;
the Cartographer surfaces the decisions it made without noticing. Neither can
see the decision that was never made *because nobody outside the room was
asked* — the support engineer who knows this error message is the one people
call about, the person who owns the docs page this silently invalidates, the PO
who would have said the behaviour change is fine but not this quarter.

**Epithet:** *the counsel-bringer.* **Attacks:** isolation drift.

## 2. What It Does, and the Line It Does Not Cross

The Convener does exactly two things:

1. **Maps the voices** a spec affects.
2. **Drafts the actual question worth asking each one.**

Then it stops.

### 2.1 It never contacts anyone

Not by email, not by issue, not by mention, not by opening a PR against another
repository, not by drafting a message for the human to send unedited.

This is a scope guard rather than a technical limit, and it exists because the
failure mode is severe and one-directional. An agent that contacts a colleague
on someone's behalf has spent that person's social capital without their
knowledge, in their name, and there is no undo. The human carries the
conversation, or the conversation does not happen.

### 2.2 An agent is never a voice

A voice is a **role or a group of people**. Never an agent, never a sentinel,
never "the reviewer" meaning a model.

Listing an agent as a consultable voice would let the record show a
conversation that never involved a person, which is precisely the isolation the
Convener exists to attack — dressed up as its remedy.

### 2.3 A question, not a ping

Every voice gets **one concrete question worth asking**.

Not "sync with support". Not "check with the PO". A question a person could
answer without a meeting:

> *Support:* when this returns the new error code instead of timing out, does
> that change what you tell people who call about it?

A vague question is worse than none: it converts a real gap into a scheduled
meeting, and the meeting is what makes people stop doing this.

**And unlike the Coda's next action, nothing validates it** — because the
question is the *Convener's* output, not the human's. The Coda checks a human's
words because the human wrote them; here, writing a good question is the
agent's job, and there is nobody to gate.

## 3. Where It Runs

At **plan approval**, after the Diaboli's spec-gate dispositions are resolved
and alongside the Choice Cartographer — mirroring that agent's shape exactly,
because the two answer adjacent questions about the same spec at the same
moment.

```text
spec → diaboli spec-gate → convener + cartographer → plan approval → implement
```

**Soft at plan approval.** Unresolved voices are *listed*, not blocking. The
human may approve a plan with every voice still `pending`; the record simply
says so.

## 4. The Merge-Time Check

A `HARNESS.md` constraint, **agent-verified**, scoped to `pr`:

> A PR whose spec has a consultation record must have **no voice left
> `pending`**. Every voice is either `consulted` with a one-line outcome, or
> `deliberately-not-consulted` with the because.

### 4.1 Complete-if-present, not required

A PR with **no** consultation record passes. Running `/convene` remains a
choice.

This is deliberately weaker than the Cartographer's sibling constraint, which
*requires* a story record on every non-exempt PR with a spec. Two reasons.

**Progressive hardening.** A new sentinel earns a required step by proving
useful, not by declaring itself mandatory on the day it ships. The ladder in
this repo runs Unverified → Agent-verified → deterministic, and skipping rungs
because the idea feels important is how a harness accumulates constraints
nobody believes in.

**The failure worth catching first is the abandoned conversation.** Someone ran
`/convene`, saw a voice they knew mattered, and shipped without saying either
way. That is a decision made by omission, and it is exactly the shape the
record exists to make visible. A project that never convened at all has not
made that mistake — it has made a different one, and a merge gate is not how
you fix it.

**Promotion is future work, on the record.** If teams run this and the
undispositioned-voice failure stops occurring, requiring a record is the next
rung.

### 4.2 `deliberately-not-consulted` is a complete answer

It is not a lesser disposition, and it must not read as one.

Deciding *not* to ask someone, for a stated reason, is a real decision made
deliberately — which is the entire point. The Convener's value is that the
choice becomes visible, not that everyone gets consulted.

The `because` is what carries it: "the docs page is generated from this file,
so the docs owner has nothing to decide" is a complete disposition. "No time"
is also a complete disposition, and an honest one.

## 5. Where Voices Come From

### 5.1 A declared `Stakeholders` section

Optional, in `HARNESS.md`:

```markdown
## Stakeholders

- Support — fields questions about the CLI
- Docs — owns the published reference
- PO — disposes behaviour changes
```

`HARNESS.md` because **who a project affects is a property of the project**.
That is the same reasoning that sent pacts *out* of it in S3, applied in
reverse: a stop hour belongs to a person, a stakeholder map belongs to a repo.

### 5.2 When it is absent

The Convener derives candidates from the change itself and **flags every one
`inferred`**:

| Signal | Candidate voice |
| --- | --- |
| A user-facing surface changes | whoever uses that surface |
| `CODEOWNERS` names an adjacent module | its owners |
| Behaviour changes rather than internals | the PO or product owner |
| A published doc page describes the old behaviour | its owner |

An absent section is not an error and produces no warning. It produces a
shorter, less certain list, honestly labelled.

### 5.3 Propose and prune

The Convener proposes voices; the human removes the ones that do not apply.

Same shape as the Mast's tune dialogue and the Coda's thread grouping, for the
same reason: at the moment this runs the human knows their organisation and the
agent does not, and the cheaper direction is deleting a wrong row rather than
composing a list from nothing.

There is **no cap** on voices proposed, and one is stated as a non-goal rather
than left implicit — a cap would silently drop the voice a change most needed,
and the human can delete faster than they can recall.

## 6. The Record

**S5 changes no contract.** S1's `reference/consultation-record-format.md`
already defines everything this writes: `spec`, `date`, `state`,
`supersedes`, and per voice `voice`, `source_flag`, `question`, `disposition`,
`outcome`.

That is worth noting rather than passing over. Every slice since S2 has had to
carve a contract change out of a neighbour; this one does not, because S1 wrote
the schema before the consumer existed and got it right. A substrate slice
paying off looks like a later slice with nothing to say.

The agent holds no `Write`: it returns record content and `/convene` persists
it after the human disposes — the `cost-estimator` precedent, and the same
split every sentinel in this epic uses.

State lives in the filename, per S1: disposing voices writes a `.resolved.md`
naming its predecessor in `supersedes`, and no record is ever edited in place.

## 7. Files

| File | Purpose |
| --- | --- |
| `agents/convener.agent.md` | `role: sentinel`, read-only — maps voices, drafts questions |
| `skills/convener/SKILL.md` | the scope guard, what a good question is, the anti-patterns |
| `commands/convene.md` | dispatches, prunes with the human, persists |
| `HARNESS.md` | the merge-time constraint (§4) |
| `templates/HARNESS.md` | the optional `Stakeholders` section, commented out |
| `docs/.../explanation/sentinels.md`, `skills/sentinel-design/SKILL.md`, `README.md` | roster 8 → 9 |
| `reference/agents.md`, `commands.md`, `skills.md`, `harness-md-format.md` | entries |

## 8. Non-Goals

- **No contacting anyone**, in any form, including drafting a message to send.
- **No agent as a voice.**
- **No cap on voices.** A cap drops the one that mattered.
- **No validation of the human's dispositions.** `deliberately-not-consulted`
  with a thin because is still a disposition; the record makes it visible, and
  visibility is the mechanism.
- **No contract change.** S1's schema is used as shipped.
- **No requirement to convene.** §4.1.
- **No deterministic enforcement.** Agent-verified is the rung this ships at.

## 9. Acceptance Scenarios (TDAD)

Prefixed **V** for the merge-time check and **A** for agent-verified behaviour.

### 9.1 The constraint — `tdad_tests/layer0_deterministic/test-convene-check.sh`

The check is a matcher over records, so it is deterministic even though its
enforcement is agent-mediated.

- **V1 — no record passes.** A spec with no consultation record is not a
  breach.
- **V2 — a fully-dispositioned record passes**, whether voices were
  `consulted` or `deliberately-not-consulted`.
- **V3 — a `pending` voice fails**, naming the spec and the voice.
- **V4 — `deliberately-not-consulted` with no `outcome` fails.** The because is
  what makes it a disposition rather than a shrug.
- **V5 — a superseded record is not checked**; its successor is.
- **V6 — a malformed record fails loudly** rather than passing by default. A
  matcher that cannot parse a record must not report it clean.

### 9.2 Agent-verified

- **A1** — every voice is a role or group; no agent appears as a voice.
- **A2** — every voice carries a concrete question, not "sync with X".
- **A3** — voices are proposed for the human to prune, not decided alone.
- **A4** — a derived voice is flagged `inferred`; a declared one `observed`.
- **A5** — the agent writes no file.
- **A6** — nothing is contacted, and no message is drafted for sending.

## 10. Rollout

Minor bump, 0.71.0 → 0.72.0. Five CI-checked version locations, the README
plugin-table cell, and the README count badges, anchors and headings — 40
skills → 41, 19 agents → 20, 31 commands → 32.

A TDAD scenario per new component. Docs: a how-to, reference entries on all
three component pages, the `Stakeholders` section in `harness-md-format.md`,
and the sentinels roster 8 → 9.

No breaking changes. The constraint is new and complete-if-present, so no
existing PR shape starts failing.
