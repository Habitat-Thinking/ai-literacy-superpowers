# The challenge-refine protocol

The diagnostic-legibility agent's anti-hallucination value lives in its
challenge step. The agent does not just draft two model collections — it
re-reads its own drafts adversarially, pressure-tests each element
through five named questions, and retains evidence of what surfaced.
This page explains the protocol design and why the agent ships in the
shape it does at v0.3.0.

## What the agent does

The agent runs in two explicit phases per invocation:

1. **Phase A — Construction.** Read the schema template, inspect the
   scope, draft architectural elements (moving parts) and domain
   elements (concepts). Each element gets `name`, `description`,
   `evidence[]`, and a starting `confidence`. `challenge_notes[]`
   stays empty for now.

2. **Phase B — Challenge.** Re-frame as an adversarial reviewer.
   Re-read the evidence on each draft. Apply the five questions —
   *boundary, evidence, confounders, confidence, description
   integrity* — with dimension-flavoured weighting (Q1 heavy for
   architectural, Q5 heavy for domain). Where a question surfaces a
   change, revise the element and append a `Q<N>` entry to
   `challenge_notes[]`. Where all five run cleanly, append the
   sentinel `Challenge applied; no questions surfaced changes`.

The phase boundary is a load-bearing **prompt-segment boundary**, not
just a documentation convenience. The boundary is the mechanism that
gives the challenge step a fresh adversarial posture; collapse it and
the challenge degenerates into the same context that drafted the
elements arguing for them.

## The five questions

Each question targets a distinct named failure mode:

| # | Question | Catches |
| - | -------- | ------- |
| Q1 | **Boundary** — is the `name` actually a single thing, or did I smear two? | Smearing (architectural-heavy) |
| Q2 | **Evidence** — does the cited evidence actually support the description? | Ungrounded claim (fabrication-adjacent) |
| Q3 | **Confounders** — what nearby thing is *not* this element but could be mistaken for it? | Near-misses |
| Q4 | **Confidence** — am I overclaiming on the `confidence` field? | Calibration drift |
| Q5 | **Description integrity** — is the description specific to this codebase or generic textbook? | Textbook-definition drift (domain-heavy) |

The five together are *boundary, ground, identity-by-contrast,
calibration, specificity*. They are not claimed to be complete — they
are the **working hypothesis** for what an emitted `LegibilityElement`
draft most commonly gets wrong, with the agent's own
`challenge_notes[]` corpus as the falsification surface. If recurring
failure modes do not map to any of the five, the cover is missing a
question; if two questions consistently produce identical notes, the
cover has redundancy. Either signal can be observed across a real
invocation history without changing the schema.

## Why retained-challenge single-pass

Three candidate cycle architectures were considered:

(a) **Single-pass critique-revise** — one challenge, one revision,
    challenge artefact discarded.
(b) **Retained-challenge single-pass** (selected) — same as (a) but
    challenge notes are retained as `challenge_notes[]` on each
    element.
(c) **Iterative loop** — challenge–revise until stable or budget
    exhausted.

(b) is selected because:

- The schema already commits to `challenge_notes[]` as a required
  field on every `LegibilityElement`. (a) either leaves the field
  empty (defeating the schema decision) or reconstructs notes after
  the fact (weakening evidence quality). (b) makes the field
  load-bearing without changing the schema.
- The downstream cross-check (parent S3, [#332](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332))
  will want diagnostic context — knowing *what was challenged* and
  *what was revised* — to do its job. Retaining is cheap;
  reconstructing later is expensive and lossy.
- (c) adds variable token cost and a stopping-condition sub-decision
  in the absence of any signal that (b) under-refines. (c) remains
  available as an escalation — the schema accommodates iteration by
  appending to `challenge_notes[]` on each pass — but ships first as
  the simpler shape.

## Why one agent, two postures

The same architectural question — *how do we get the challenge step a
fresh adversarial posture without doubling the agent-file surface?* —
had three candidate resolutions:

1. **One-context self-challenge.** The agent challenges its own drafts
   in the same continuous reasoning context. Simplest. Named failure
   mode: **self-confirmation** — an LLM in one context that has just
   argued for a draft is statistically biased toward defending it.
2. **Two-agent dispatch.** A separate `diagnostic-legibility-challenger`
   agent file with its own charter and tool boundary. Maximal
   independence. Doubles the agent-file surface for a v0.3.0
   capability.
3. **Fresh-sub-context self-challenge** (selected). One agent file,
   two reasoning postures within it — *construct* and *challenge* —
   separated by an explicit prompt-segment boundary. The independence
   comes from the explicit re-framing, not from a separate context.

The middle option ships first because it addresses the
self-confirmation failure mode named in (1) without doubling the
agent-file surface named in (2). The mechanism is the agent file's
prompt itself: Phase B opens with an explicit re-framing instruction
("*You are now the challenger. Disagree where the evidence allows.*")
and treats the construction as someone else's work.

If a real-invocation corpus shows the middle option still degenerates
to self-confirmation — e.g. unusually high rates of sentinel-only
`challenge_notes[]` across diverse scopes — the architecture can
escalate to (2) without changing the schema or the spec's external
contract. The progression (1) → (3) → (2) is the natural escalation
path; v0.3.0 ships the cheapest move that takes the failure mode
seriously rather than deferring it.

**Honesty about the observability gap.** At v0.3.0 there is no
corpus, no persistence path for invocations, and no command to
aggregate sentinel-vs-`Q<N>` ratios. The escalation criterion above
is currently a **manual-review pattern**: a human reading a handful
of invocation outputs and noticing whether the sentinel dominates.
When parent S4 ([#333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333))
lands the `/diagnose` command, the natural extension is for
`/diagnose` to persist outputs to a known path and a follow-up rule
to aggregate ratios; until then, treat the escalation as a hand-flag
the dispatcher raises if the pattern is salient. The architectural
fix is shipped; the falsification surface is deferred.

## How `challenge_notes[]` connects schema to runtime

`challenge_notes[]` is the bridge:

- **At schema time** (v0.2.0): `challenge_notes` is a required list
  of strings on every `LegibilityElement`. The schema says nothing
  about what the strings *contain*.
- **At runtime** (v0.3.0 — this page): the agent fills the field
  with one of two things:
  - One or more `Q<N> (question name): ...` entries — when at least
    one of the five questions surfaced a change.
  - The single sentinel `Challenge applied; no questions surfaced
    changes` — when all five questions ran cleanly.

The `Q<N>` prefix is **machine-parseable**: the downstream cross-check
([#332](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332))
groups notes by prefix to identify recurring failure modes across an
element corpus. The sentinel is the **only** exception to the prefix
rule; its presence disambiguates "challenge ran cleanly" from
"challenge never ran" (the empty-list case).

This pattern — a typed field on the schema whose values follow an
in-string convention enforced by the agent rather than by the schema
— is a tagged-string idiom (also called a "lightweight in-string
schema"). It buys machine-readability without forcing the schema to
encode structure it doesn't need elsewhere.

## Two sentinels, one idiom

The plugin uses two reserved literal strings as sentinels:

- `Challenge applied; no questions surfaced changes` (in
  `challenge_notes[]`) — signals "challenge ran, found nothing".
- `(empty scope)` (in an element's `name`) — signals "scope yielded
  nothing".

Both solve the same shape of problem — an observable runtime state is
ambiguous without an explicit marker — and both resolve it with a
reserved literal string rather than with a new field or boolean. The
cost is two new agreed-upon literals in the contract surface;
downstream consumers (cross-check, future surfacing) must know them.
The benefit is no schema change — the disambiguation lives at the
agent layer, where it can evolve without touching the v0.2.0 schema.

## What this slice does not do

- **Cross-check the two models against each other.** Reserved for
  parent S3, [#332](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332).
- **Surface the models to a human.** A `/diagnose` command is the
  deliverable of parent S4, [#333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333).
- **Validate `LegibilityElement` instances at runtime.** The schema
  spec (v0.2.0) explicitly deferred this; the agent enforces the
  contract through its prompt, not through a separate validator.

## Further reading

- [How to invoke the agent](../how-to/invoke-the-agent.md) —
  task-oriented dispatch guide.
- [Cross-check protocol](cross-check-protocol.md) — Phase C, the
  v0.4.0 cross-collection extension that runs after this Phase B
  cycle. Reads naturally as a sibling page once you have understood
  Phase B.
- `diagnostic-legibility/templates/legibility-element.md` (in the
  repository) — the contract every emitted element follows.
- [Sub-S2b design spec](../../../superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md)
  — the full design record this protocol descends from.
