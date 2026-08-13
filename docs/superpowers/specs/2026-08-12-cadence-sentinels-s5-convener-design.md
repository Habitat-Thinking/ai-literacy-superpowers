# Spec: Cadence Sentinels S5 — The Convener

**Status:** Approved (revision 2, post-diaboli)
**Date:** 2026-08-12
**Issue:** #495
**Epic:** The Cadence Sentinels (S1–S7)
**Objections:** `docs/superpowers/objections/cadence-sentinels-s5-convener-design.md`
— 12 objections, all accepted
**Depends on:** S1 (0.67.0) — the consultation-record contract, extended here
in a carved commit (§6)
**Scope:** `ai-literacy-superpowers` plugin; one agent, skill, command, and one
`HARNESS.md` constraint
**Explicitly out of scope:** contacting anyone, ever.

**Provenance:** the Cadence Sentinels build spec, supplied in conversation
2026-08-08 — transcribed to `docs/superpowers/cadence-sentinels-charter.md`.
Slice scope: issue #495.

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

**Where the line is.** A question is one sentence a person could answer. A
message has a salutation, a context paragraph, or a sign-off — and the moment
any of those appears, the agent has crossed.

That boundary needs stating because the read-only trust boundary already
forecloses every *mechanical* path, so what remains is drift: an agent
producing progressively more sendable questions until one of them is a message.
Drift needs a line, not a lock (O11).

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

A9.2's A2 is therefore a **rubric a human reviewer applies to the agent's
output**, not a check applied to anyone's words. Revision 1 wrote it as though
it were a check, which would have had an implementer rebuild exactly the defect
S2 diagnosed: a lexical matcher for "sync with X", on a property — question
quality — that lexical form does not measure (O10).

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

### 3.1 The pipeline is wired, not implied

`orchestrator.agent.md` gains a numbered step beside the Cartographer's `1b`, a
named **SOFT GATE**, and a structured `convene_pending_count` field alongside
`cartograph_pending_count`. None of that transfers by implication (O3).

It has to be wired, because §1's argument is that this failure is *invisible
from inside*: the people who most need the Convener are precisely the people who
will not think to run it, and a manual-only command does not address the thing
the slice exists for.

What the "no requirement to convene" non-goal actually meant is narrower than it
read — **the pipeline surfaces it; the human may approve a plan with every voice
still pending**, and the merge check stays complete-if-present.

## 4. The Merge-Time Check

A `HARNESS.md` constraint, **`Enforcement: deterministic`**, scoped to `pr`,
matched by `scripts/check-consultation-dispositions.py`:

> A PR whose spec has a consultation record must have **no voice left
> `pending`**. Every voice is either `consulted` with a one-line outcome, or
> `deliberately-not-consulted` with the because.

### 4.1 Complete-if-present, not required

A PR with **no** consultation record passes. Running `/convene` remains a
choice.

This is deliberately weaker than the Cartographer's sibling constraint, which
*requires* a story record on every non-exempt PR with a spec. Two reasons.

**Two axes, not one.** Revision 1 called this "agent-verified" and argued it
was a low rung of progressive hardening. That was wrong twice: `agent-verified`
is not a value of the enum — `harness-md-format.md` gives `deterministic`,
`agent`, `unverified` — and a matcher over record frontmatter is plainly the
first of those. Calling an LLM applying a rule "deterministic" because the rule
*could* be matched deterministically is the overclaim this epic keeps catching
(O2).

So the **rung** is deterministic and the **reach** is complete-if-present, and
those are different things. What is held back is not the rigour of the check
but the scope of what it demands. A new sentinel earns a required step by
proving useful, not by declaring itself mandatory on the day it ships.

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

### 4.3 Each outcome must be distinct

**No two voices in one record may carry the same `outcome`.** Each must name
something specific to that voice.

Without this, the gate converts a detectable failure into an undetectable one.
`pending` fails the check — but eight voices bulk-filled
`deliberately-not-consulted / "no time"` pass it, and revision 1 explicitly
blessed that string as complete while forbidding any validation of dispositions
(O4).

An all-`pending` record is at least truthful about disengagement. An
all-declined one **launders** it: the file now asserts eight deliberate
decisions that were never made, it is append-only, and the next reader will
trust it. The lie is permanent.

This is not the plugin judging anyone's reasons. *"No time; shipping Thursday
and the docs owner is on leave"* passes, and is honest — it is specific to that
voice. What the rule refuses is **one string standing for eight decisions**, so
that a bulk-fill costs more than thinking does.

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

### 5.4 Prune **and add**

The dialogue offers both directions. A voice the human names is written into the
record and flagged **`asked`**.

Revision 1 was prune-only, and that made S1's third honesty flag unreachable —
`asked` means "the human named it" and there was nowhere to name one. Worse, it
reproduced the Convener's own founding failure one level up: §5.3's rationale
argues for a two-way exchange because the human knows the organisation, and then
the mechanism delivered a one-way filter. **The highest-value voice in any
session is the one the agent failed to derive** (O7).

### 5.5 At most eight, and three to five is the good number

The Convener proposes **at most 8 voices, biasing toward 3–5**.

Revision 1 declared "no cap" a non-goal. That overturned a settled position on
both sibling components without noticing: the Diaboli caps at 12 with a stated
justification, and the Cartographer caps at 15 while biasing toward 5–8 with an
explicit *do not pad*.

Their caps are **an honesty device aimed at the agent, not an ergonomic
concession to the human**. An uncapped generative agent pads, and from the
inside padding is indistinguishable from thoroughness. Under the merge check the
asymmetry bites: a proposed voice the human does not actively delete becomes a
mandatory disposition, so deleting is cheap and immediate while failing to
delete is expensive and deferred (O5).

## 6. The Record

**S5 changes no *schema*.** S1's `reference/consultation-record-format.md`
already defines every field this writes: `spec`, `date`, `state`, `supersedes`,
and per voice `voice`, `source_flag`, `question`, `disposition`, `outcome` —
including that `outcome` is required when the disposition is
`deliberately-not-consulted`, which is V4 verbatim.

Revision 1 claimed more than that: "S5 changes no contract". A contract has a
**query surface** and a **naming rule** as well as a schema, and this slice
needed both (O1, O6). Two things are therefore added to S1, **carved as their
own commit** with their own scenarios, exactly as the `registry_list` repair was
in S4:

**`records_latest <dir>`** in `hooks/scripts/lib/record-paths.sh` — the current
state of every record chain, one path per line, transitions included. S1 built
`records_open` to answer *what is still outstanding*, and it excludes
`*.resolved.md` by name. But a disposed voice only ever exists inside a
`.resolved.md`, so the check as specified in revision 1 would have read an empty
set for every disposed record and passed it vacuously. Re-deriving the walk
inside the check would have made it the second place in the repo that knows what
`.resolved.md` means — the duplication S1's library exists to prevent.

**The naming rule**: a consultation record lives at
`docs/superpowers/consultations/<spec-slug>.md`, matching the objection and
story records exactly. S1's grammar gave `<YYYY-MM-DD>-<slug>.md` with the
record's own date and an undefined slug, so nothing connected a spec to its
record.

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
| `scripts/check-consultation-dispositions.py` | the matcher (§4), over `records_latest` |
| `agents/orchestrator.agent.md` | the step, the soft gate, `convene_pending_count` (§3.1) |
| `hooks/scripts/lib/record-paths.sh` | `records_latest` — carved commit (§6) |
| `reference/consultation-record-format.md` | the `<spec-slug>.md` naming rule — carved commit (§6) |
| `HARNESS.md` + 3 convention files | the merge-time constraint (§4); parity is enforced |
| `templates/HARNESS.md` | the `Stakeholders` section **and** the constraint |
| `skills/advocatus-diaboli/SKILL.md`, `skills/choice-cartographer/SKILL.md` | Routing Rule 2-way → 3-way (§11) |
| `README.md`, `skills/sentinel-design/SKILL.md`, `docs/.../explanation/sentinels.md` | roster 5 → 9 |
| `reference/agents.md`, `commands.md`, `skills.md`, `harness-md-format.md` | entries |

## 8. Non-Goals

- **No contacting anyone**, in any form, including drafting a message to send.
- **No agent as a voice.**
- **No judging anyone's reasons.** "No time; shipping Thursday and the docs
  owner is on leave" passes, and is honest. What the check refuses is one string
  standing for eight decisions (§4.3).
- **No schema change.** S1's fields are used as shipped; the query surface and
  the naming rule are extended (§6).
- **No requirement to *have* convened.** A PR with no record passes (§4.1).
- **No changes to the Reservoir Warden**, and none to the Cartographer's lenses
  — the fold-in was weighed and rejected (§11).

## 9. Acceptance Scenarios (TDAD)

Prefixed **V** for the matcher and **A** for the review rubric.

### 9.1 The matcher — `tdad_tests/layer0_deterministic/test-convene-check.sh`

- **V1 — no record passes.** A spec with no consultation record is not a
  breach.
- **V2 — a fully-dispositioned record passes**, whether voices were
  `consulted` or `deliberately-not-consulted`.
- **V3 — a `pending` voice fails**, naming the spec and the voice.
- **V4 — `deliberately-not-consulted` with no `outcome` fails.** The because is
  what makes it a disposition rather than a shrug.
- **V5 — a superseded record is not checked**; its successor is, read through
  `records_latest` rather than `records_open` (§6).
- **V6 — a malformed record fails loudly** rather than passing by default. A
  matcher that cannot parse a record must not report it clean.
- **V7 — identical outcomes across voices fail** (§4.3). One string cannot stand
  for several decisions.
- **V8 — a record is found by `<spec-slug>.md`** (§6), and a spec with no
  matching filename is V1, not an error.

### 9.2 The review rubric

Applied by a human reviewer to the **agent's** output. These are not checks over
anyone's words — §2.3 (O10).

- **A1** — every voice is a role or group; no agent appears as a voice.
- **A2** — every voice carries a question a person could answer without a
  meeting, not "sync with X".
- **A3** — voices are proposed for the human to prune **and add to**, not
  decided alone (§5.4).
- **A4** — a declared voice is flagged `observed`, a derived one `inferred`, a
  human-named one `asked`.
- **A5** — the agent writes no file.
- **A6** — nothing is contacted, and nothing crosses §2.1's line: no salutation,
  no context paragraph, no sign-off.
- **A7** — at most 8 voices (§5.5).

### 9.3 The carved contract extension

- **C1–C4** in `test-record-paths.sh`: `records_latest` returns the newest file
  in each supersession chain, skips `README.md`, is empty on a missing
  directory, and returns a bare record with no successor.

## 10. Rollout

Minor bump, 0.71.0 → 0.72.0. Five CI-checked version locations, the README
plugin-table cell, and the README count badges, anchors and headings — 40
skills → 41, 19 agents → 20, 31 commands → 32.

A TDAD scenario per new component. Docs: a how-to, reference entries on all
three component pages, the `Stakeholders` section in `harness-md-format.md`.

**Three rosters, all reconciled to 9 here** — `README.md`'s
`#### Sentinels (5)` and its five rows, `sentinel-design`'s five-row roster
*and its narrative sentence*, and the explanation page. The drift is S2's,
S3's and S4's: each updated the explanation page and missed the other two,
three slices running (O9). Follow-up filed as **#507** — a roster is a pinned
copy of a derived fact (which agents carry `role: sentinel`), and the promoted
`ARCH_DECISION` at `AGENTS.md:481` has already caught the README count badges
twice in this epic.

No breaking changes. The constraint is new and complete-if-present, so no
existing PR shape starts failing.

## 11. The Routing Rule Becomes Three-Way

`advocatus-diaboli/SKILL.md` states that the Diaboli and the Cartographer
"together form a complete partition of findings worth surfacing about a spec".
A third record arriving without touching that sentence leaves findings landing
in two places or neither (O12).

A finding like *"the docs owner should have been asked, and the published page
will describe behaviour that no longer exists"* is simultaneously a class of
undetected failures and a voice. **Tie-break: it is the Convener's, because the
remedy is a conversation rather than a spec change.**

### 11.1 Why not a seventh Cartographer lens

Weighed and rejected on **object of care**. A choice story records a *decision
the spec made*; a voice is a *person the spec affects*. Every Cartographer lens
interrogates the artefact, and none of them looks outward — a seventh would have
been the first lens whose subject was not the spec.
