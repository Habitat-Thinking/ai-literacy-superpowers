# Convening the voices

Map the roles and groups a spec affects, and draft the one question worth
asking each of them.

`/convene` never contacts anyone. It produces a list and a set of questions;
you carry the conversations.

## When to run it

At plan approval, beside `/choice-cartograph`, on any spec that changes
something outside the room:

- a user-facing surface — a CLI flag, an API response, an error message
- a published document, runbook, or dashboard that describes the old behaviour
- a default that changes for existing users on upgrade
- behaviour rather than internals

Run it *before* implementation. A question asked at plan approval can still
change the spec; the same question asked at merge time can only change a plan
you have already paid for.

## Declaring who your project affects

Optional, in `HARNESS.md`:

```markdown
## Stakeholders

- Support — fields questions about the CLI
- Docs — owns the published reference
- PO — disposes behaviour changes
```

It lives in `HARNESS.md` because **who a project affects is a property of the
project**. That is the same reasoning that keeps personal pacts out of it: a
stop hour belongs to a person, a stakeholder map belongs to a repo.

Roles or groups only. Never named individuals — roles outlive the people
holding them, and a record naming a person ages into a record naming the wrong
person.

**Leaving it out is not an error.** The Convener derives candidates from the
change itself and flags every one `inferred`, producing a shorter and less
certain list, honestly labelled. You get no warning and no nag.

## Running it

```bash
/convene docs/superpowers/specs/2026-08-12-retry-semantics-design.md
```

You get a proposed list, then a two-part question:

```text
Voices proposed for retry-semantics-design:

  1. Support   [inferred]  when this returns the new error code instead of
                           timing out, does that change what you tell people
                           who call about it?
  2. Docs      [observed]  the published reference describes the 30-second
                           timeout as guaranteed — is that page generated, or
                           maintained by hand?
  3. PO        [inferred]  this changes behaviour for existing integrations on
                           upgrade rather than behind a flag. Fine this
                           quarter, or does it wait?

Which of these do not apply? (numbers, or "none")
Who did it miss? (a role or group, or "nobody")
```

**Answer the second question properly.** It is where the value usually is. The
agent cannot see your org chart, the argument that has been running since
March, or the team that got burned by this last time — so the highest-leverage
voice in a session is typically the one it could not derive. A voice you name
is flagged `asked`.

The flags mean:

| Flag | Meaning |
| --- | --- |
| `observed` | Your `## Stakeholders` section named it. |
| `inferred` | The agent derived it from the change. |
| `asked` | You named it. |

## What makes a question worth asking

Not "sync with support". A question someone could answer in one line, in a
chat thread, without preparing:

> **Support:** when this returns the new error code instead of timing out, does
> that change what you tell people who call about it?

A vague question is **worse than none**: it converts a real gap into a
scheduled meeting, and the meeting is what makes people stop doing this.

## The line the agent does not cross

A question is one sentence a person could answer. A message has a salutation, a
context paragraph, or a sign-off.

| A question | A message |
| --- | --- |
| when this returns the new error code instead of timing out, does that change what you tell people who call about it? | Hi Support — we're changing the timeout behaviour next sprint. When this returns the new error code instead of timing out, does that change what you tell people who call about it? Thanks! |

Same sentence. The wrapper is the entire difference, and the wrapper is what
would make it sendable in your name by something that is not you. An agent that
contacts a colleague on your behalf has spent your social capital without your
knowledge — and there is no undo.

## Recording what happened

Two dispositions, both complete answers:

```yaml
  - voice: Support
    source_flag: inferred
    question: does the new error code change what you tell callers?
    disposition: consulted
    outcome: they want the code in the message body, not just the header

  - voice: Docs
    source_flag: observed
    question: is the published reference generated or hand-maintained?
    disposition: deliberately-not-consulted
    outcome: the page is generated from this file, so there is nothing to decide
```

**`deliberately-not-consulted` is not a lesser answer.** Deciding *not* to ask
someone, for a stated reason, is a real decision made deliberately — which is
the whole point. The value is that the choice becomes visible, not that
everyone gets consulted.

"No time" is a complete disposition, and an honest one.

### One rule: each outcome must be distinct

No two voices in one record may carry the same `outcome`. Each must name
something specific to that voice.

This is not the plugin judging your reasons. *"No time; shipping Thursday and
the docs owner is on leave"* passes. What it refuses is **one string standing
for eight decisions**.

The reason is worth knowing. `pending` is a *detectable* failure — the check
catches it. Eight voices bulk-filled with one line is an *undetectable* one,
and it is strictly worse: an all-`pending` record is at least truthful about
disengagement, while an all-declined one launders it into eight deliberate
decisions nobody made. Records are append-only, so that stays true forever, and
the next reader will believe it.

### Records are append-only

Never edit dispositions into an existing record. Write the transition:

```text
docs/superpowers/consultations/retry-semantics-design.md            # open
docs/superpowers/consultations/retry-semantics-design.resolved.md   # disposed
```

The `.resolved.md` names its predecessor in `supersedes:` and carries the full
voice list with dispositions filled in. State lives in the filename.

## The gates

**At plan approval — soft.** A `convene_pending_count` is surfaced and you may
approve a plan with every voice still `pending`. The record simply says so.

**At merge — deterministic, and complete-if-present.** The constraint **PRs
have disposed consultation voices** runs
`scripts/check-consultation-dispositions.py` over the current state of each
record chain. Every voice must be disposed with its own distinct outcome.

**A PR with no consultation record passes.** Running `/convene` is a choice.
What the check catches is the *abandoned* conversation — you ran it, saw a
voice you knew mattered, and shipped without saying either way. A project that
never convened at all has made a different mistake, and a merge gate is not how
you fix that one.

## See also

- [Sentinels](../explanation/sentinels.md) — the category and its signature
- [Consultation record format](../reference/consultation-record-format.md)
- [`/convene` reference](../reference/commands.md)
