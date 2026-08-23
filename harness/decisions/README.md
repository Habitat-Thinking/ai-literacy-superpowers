# Harness Decision Records

One file per governance change: the evidence that justified it, the exact rule
text, the enforcement level it intends, the surfaces it reaches, who approved
it, what it costs the next person, and when it stops being true.

`HARNESS.md` governs the loop and `AGENTS.md` governs the turn. This directory
governs how those two documents change — which, until now, nothing did.

## Why a rule has to declare its cost, and its expiry

Harness rules accrete. One enters because someone was annoyed once, and it
never leaves, because leaving requires somebody to remember it exists.

Two mechanisms push back:

- **The cost is written by the approver, in their own words** — what the rule
  will demand of whoever works here next, and how it might be gamed. The
  validator refuses a cost copied from the proposal, because a copy-pasted cost
  reads exactly like a considered one.
- **Provisional by default.** Permanence is earned at review, not at creation.
  An expired rule still in force fails CI, so demotion never depends on anyone
  remembering to reflect.

## Lifecycle

A `proposed` HDR is a draft and may be edited freely. **Acceptance is the
moment it becomes a record** — the human authors the cost at that gate, so
acceptance adds content rather than flipping a flag. From `accepted` onward an
HDR is frozen: never edited, only superseded by a later HDR naming it in
`supersedes:`.

Demotion therefore produces a superseding HDR rather than a deletion. The
record shows the rule existed, what it cost, and why it was retired.

## Format

See `docs/plugins/ai-literacy-superpowers/reference/harness-decision-records.md`.
Validated by `ai-literacy-superpowers/scripts/check-harness-decisions.py`, which
holds every refusal — the Registrar is an agent with write authority, and a rule
that lived only in its prompt would be a rule it could talk itself past.
