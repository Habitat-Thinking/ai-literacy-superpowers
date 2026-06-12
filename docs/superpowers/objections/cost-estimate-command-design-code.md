---
spec: docs/superpowers/specs/2026-06-11-cost-estimate-command-design.md
date: 2026-06-12
mode: code
diaboli_model: claude-opus-4-8[1m]
objections:
  - id: O1
    category: specification quality
    severity: high
    claim: "The command never specifies how <target-slug> is derived from inline task text or sanitised, so a crafted task string or a path with traversal/separators can produce an estimate written outside cost-estimates/ or to a surprising filename."
    evidence: "cost-estimate.md:291-293 — '<target-slug> — for a path target, the source filename with its date prefix and .md extension stripped; for inline task text, a short kebab-case slug of the first few words.' No sanitisation, no length bound, no statement that the slug is confined to a single path segment."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Pin <target-slug> to a single sanitised path segment
      (lowercase [a-z0-9-], separators and '..' stripped, length-capped); the
      slug is never a path. Closes the write-target-injection surface.
  - id: O2
    category: implementation
    severity: high
    claim: "REFUSED detection is specified only as 'begins with the stable REFUSED: prefix', with no anchoring discipline — the agent's REFUSED string interpolates attacker-influenceable free text, and the command never states the test runs against the untrimmed first line, so a literal executor could substring-match anywhere or miss a real refusal emitted with leading whitespace."
    evidence: "cost-estimate.md:92 'If the agent's output begins with the stable REFUSED: prefix'; cost-estimator.agent.md:249-251 'REFUSED: <one-line reason>. Target: <target description>.' — target description is free text. The command never specifies first-line-only anchoring or leading-whitespace handling."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Anchor REFUSED detection to an exact prefix on the
      UNTRIMMED FIRST LINE of the agent's final message, tested before any
      reformatting — not substring-anywhere, not post-trim. State the anchor
      precisely so neither failure direction (drop a record / persist a refusal)
      is reachable by executor latitude.
  - id: O3
    category: implementation
    severity: high
    claim: "The checkpoint's only FIX action is 'delete a stray recommendation/verdict/proceed field' (line 8); a verdict in failure_direction PROSE (line 9) must ABORT — but the two share the word 'verdict' and sit one table-row apart, so an executing LLM can misread a prose verdict as a 'stray verdict' and try to fix it by editing the agent's text, which is authoring."
    evidence: "cost-estimate.md:144-148 lists line 8 (field-absence FIX) above line 9 (positive-content ABORT); the fix-boundary prose (158-166) names 'delete a stray recommendation/verdict/proceed field' as the routine fix. The field-vs-prose distinction is a conclusion, not a test the executor applies before choosing FIX vs ABORT. estimate-record-format.md:373-375's line-9 example is exactly a verdict in Failure-direction prose."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Add an explicit pre-classification test BEFORE FIX-vs-ABORT:
      the stray-field FIX applies only when the offender is a top-level YAML key
      whose name is literally in {recommendation, verdict, proceed}; any verdict
      phrased inside prose (failure_direction etc.) ABORTS. The checkpoint never
      edits the agent's prose — make that test executable, not a conclusion.
  - id: O4
    category: implementation
    severity: medium
    claim: "The change-list is permitted to be 'an explicit itemised list (or diff)' and the command never requires the executor to compute an actual before/after comparison, so a literal executor can narrate 'I deleted the verdict field' without surfacing the altered content — the human disposes over a claimed change, not an observed one."
    evidence: "cost-estimate.md:227-231 — 'show an explicit itemised list (or diff) of exactly what the command altered vs the agent's emitted record'. 'or itemised list' lets the executor choose the weaker form; nothing binds the list to the retained pre-edit content."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Require the executor to retain the agent's original emitted
      output and present the change-list as a DIFF of original-vs-altered; drop
      the 'or itemised list' weaker form. The seam the human ratifies must be an
      observed change, not a narrated one.
  - id: O5
    category: implementation
    severity: medium
    claim: "On the edit path the post-edit checkpoint is 'validate-and-report', but that mode lives only in the disposition prose while step 4 documents a single default (fix-in-place); the switch is carried by executor memory of authorship context, not a structural flag — a foreseeable failure where re-validation silently applies fix-in-place to human-edited content."
    evidence: "cost-estimate.md:250-258 (edit → 'validate-and-report mode') vs 259-263 (re-run → 're-validates (step 4)'); step 4 (106-199) documents only fix-in-place. The validate-and-report variant is remote prose, not a parameter the checkpoint takes."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Make the checkpoint mode an explicit input on every
      invocation (fix-in-place on fresh agent output | validate-and-report on
      human-edited content), so the 'a human edit is never reverted unseen'
      invariant is structural, not carried by executor memory of authorship.
  - id: O6
    category: risk
    severity: medium
    claim: "Same-day collision disambiguation is bound to the step-5 summary, but the single Write is step 7 after disposition, with no re-check at write time — a file appearing between summary and accept (a concurrent invocation, a manual drop) is clobbered because the disambiguator was computed against a now-stale listing; a time-of-check/time-of-use gap."
    evidence: "cost-estimate.md:299-303 — collision check + disambiguator at 'the confirm-before-write summary (step 5)'; '...never silently overwrites'. The Write is step 7 (270-274) with no restated existence check. The guarantee is only as strong as the step-5 snapshot."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Re-evaluate the collision at WRITE time (step 7) and
      re-disambiguate if the target now exists; never overwrite even if a file
      appeared after the step-5 summary. Closes the time-of-check/time-of-use gap
      that widens with deliberation time.
  - id: O7
    category: scope
    severity: medium
    claim: "The commands reference page still asserts 'All 24 slash commands registered in commands/' while the directory now holds 27 command files including cost-estimate.md — the reference ships factually wrong on the day this command lands, the reference-staleness the spec's scope section commits to preventing."
    evidence: "docs/.../reference/commands.md:6 'All 24 slash commands registered in commands/'; Glob of commands/*.md returns 27 files. The implementer added the ### /cost-estimate entry (commands.md:281) but left the count sentence stale."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix. Correct the reference page's 'All 24 slash commands' to the
      actual count this PR ships (27). The number was stale before, but this PR
      adds the command that makes it wrong by one and touches the file, so it is
      this PR's to correct.
  - id: O8
    category: implementation
    severity: low
    claim: "The command tells the executor to pass 'the resolved model id for the agent's generated_by branch (a)' only 'if the command knows it', but never says how a slash-command executor would know it; in practice it has no resolved model id, so branch (a) is dead and every record takes branch (b) — harmless, but the spec presents (a) as a live path."
    evidence: "cost-estimate.md:83-84 '— if the command knows it — the resolved model id for the agent's generated_by branch (a)'. No mechanism for the command to obtain the model id; the agent's branch (b) default (cost-estimator.agent.md:218-226) is what fires."
    disposition: accepted
    disposition_rationale: >
      Accepted — note (no behavioural change). Add a one-line note that a
      slash-command executor has no resolved model id, so branch (b) is the live
      path; (a) is reserved for an orchestrator dispatcher that supplies one.
      Retires the dead-conditional ambiguity without changing output.
---

## O1 — specification quality — high

### Claim

The command derives the on-disk filename from a `<target-slug>` but never
specifies how that slug is sanitised. For inline task text it is "a short
kebab-case slug of the first few words"; for a path target it is the filename
with date prefix and `.md` stripped. Neither rule constrains the result to a
single safe path segment, bounds its length, or strips path separators and
`..`. An executing agent given a quoted task string containing `/` or `..`, or
a path target whose basename is adversarial, can produce a write target that
escapes `cost-estimates/` or lands at a surprising location.

### Evidence

> `cost-estimate.md:291-293` — "**`<target-slug>`** — for a **path** target,
> the source filename with its date prefix and `.md` extension stripped …; for
> **inline task text**, a short kebab-case slug of the first few words."

"kebab-case slug" implies normalisation, but the command never states the slug
is confined to `[a-z0-9-]` or to a single path component. The collision logic
(`299-303`) reasons about "the derived filename" as if it is always a leaf name,
but nothing enforces that.

### Why this matters

A slash command that writes files derived from arbitrary human-supplied text is
a write-target-injection surface. If the executor takes "first few words"
literally on a target like `"../../etc/notes spike"`, the slug can carry
separators. Because the single `Write` + `mkdir -p` trust the derived path, an
unsanitised slug turns the confirm-before-write gate into the only defence — and
the human confirms a path the executor chose. The fix is one sentence pinning
the slug to a single sanitised segment (`[a-z0-9-]`, length-capped); its absence
is a real footgun in an instruction artefact whose failure mode is executor
latitude.

## O2 — implementation — high

### Claim

REFUSED detection is the load-bearing branch that prevents persisting a
non-record, yet its match is specified only as "begins with the stable
`REFUSED:` prefix" with no anchoring discipline. The agent's REFUSED string
interpolates an attacker-influenceable `<target description>`, and the command
does not state the prefix test runs against the untrimmed first line of the
agent's final message (vs. anywhere in the output). A literal executor that
substring-matches `REFUSED:` could misclassify a conforming record whose prose
mentions the token; one that trims/reformats before testing could miss a real
refusal emitted with a leading newline.

### Evidence

> `cost-estimate.md:92` — "If the agent's output **begins with** the stable
> `REFUSED:` prefix".

> `cost-estimator.agent.md:249-251` — "`REFUSED: <one-line reason>. Target:
> <target description>. …`" — reason and target are free text.

The command never specifies first-line-only anchoring, leading-whitespace
handling, or that the test precedes any reformatting of the agent's output.

### Why this matters

This seam keeps a malformed/partial output off disk. If the match is ambiguous,
two opposite failures are reachable: a record mis-read as a refusal is silently
dropped, and a refusal mis-read as conforming gets written. For a branch whose
whole job is "never persist a non-record", "begins with" deserves an explicit
anchor (untrimmed, first line, exact prefix) rather than relying on the
executor's judgement.

## O3 — implementation — high

### Claim

The checkpoint's only FIX action is "delete a stray
`recommendation`/`verdict`/`proceed` **field**" (line 8); every prose-verdict
case (line 9) must ABORT because the checkpoint "cannot rewrite the agent's
prose". But the two cases are adjacent and the operative distinction — a
*frontmatter field literally named* `verdict` versus *a verdict phrased inside*
`failure_direction` prose — is stated as a conclusion, not a test the executor
applies before choosing FIX vs ABORT. An LLM executor that meets "failure
direction: likely-overrun, so do not proceed" can read "verdict" and reach for
FIX, editing the agent's prose — the authoring the boundary forbids.

### Evidence

> `cost-estimate.md:144-148` lists line 8 ("field-absence layer — no
> `recommendation`, `verdict`, or `proceed` field") immediately above line 9
> ("positive-content layer — … no imperative recommendation or go/no-go
> language").

> `cost-estimate.md:158-166` names "delete a stray
> `recommendation`/`verdict`/`proceed` field" as "the only routinely-fixed
> line". `estimate-record-format.md:373-375`'s line-9 example is precisely a
> verdict in the Failure-direction prose — the case most likely to be confused
> with a "stray verdict".

### Why this matters

The dispose-then-write architecture depends on the checkpoint *never silently
authoring the agent's judgment*. The single permitted mutation (field deletion)
and the single most dangerous forbidden mutation (prose-verdict rewrite) share
the word "verdict" and sit one table-row apart. An executor that conflates them
edits the agent's disclosure text and presents it as "validated", collapsing the
provenance the change-list exists to keep transparent. The command needs an
explicit pre-classification test ("is this a top-level YAML key whose name is in
{recommendation, verdict, proceed}? → FIX by deletion; otherwise → ABORT") so a
prose verdict cannot route into FIX.

## O4 — implementation — medium

### Claim

The change-list is the mechanism that makes the one mutating fix transparent,
but the command permits it to be "an explicit itemised list (**or diff**)" and
never requires an actual before/after comparison. A literal executor can satisfy
the prose by narrating "deleted a stray `verdict` field" without surfacing the
altered content, so the human disposes over a claimed change, not an observed
one.

### Evidence

> `cost-estimate.md:227-231` — "show an **explicit itemised list (or diff) of
> exactly what the command altered vs the agent's emitted record**".

The disjunction "list (or diff)" lets the executor choose the weaker form, and
nothing binds the list to the actual pre-fix bytes — the executor that *made*
the change also *reports* it, with no independent capture of the agent's
original output to diff against.

### Why this matters

The change-list exists so `accept` ratifies a composite "the human can see the
seams of". If the executor can self-report the change without showing it, the
seam is opaque again. Lower severity than O3 (the only fixable case is a
deletion) but it undercuts the same transparency guarantee and is cheap to close
(retain the original agent output; make the change-list a diff of it).

## O5 — implementation — medium

### Claim

The post-edit checkpoint is "validate-and-report", but that mode lives only in
the `edit` disposition prose, while step 4 documents a single default:
fix-in-place. The mode switch is carried by executor memory of authorship
context, not a structural flag passed into the checkpoint. An executor that
re-enters "the checkpoint" after an edit can apply the step-4 fix-in-place
default to human-authored content, silently reverting a human edit — the precise
failure validate-and-report was added to prevent.

### Evidence

> `cost-estimate.md:250-258` (edit → "validate-and-report mode") vs `259-263`
> (re-run → "re-validates (step 4)"). Step 4 (`106-199`) describes only
> fix-in-place; the validate-and-report variant is not represented in the
> checkpoint section.

### Why this matters

"A human edit is never reverted without the human seeing and re-confirming it"
is an explicit O3-resolution invariant. Encoding the exception as remote prose
rather than a parameter the checkpoint takes (`mode: fix | report`) means the
invariant holds only if the executor correctly attributes authorship every time
it re-enters validation — brittle in an artefact whose failure mode is executor
drift. Stating the checkpoint's mode as an explicit input on every invocation
makes the seam structural rather than mnemonic.

## O6 — risk — medium

### Claim

The "never silently overwrites" guarantee is anchored to the collision check at
step 5 (summary time), but the actual `Write` is at step 7 after the human
disposes. Nothing requires the existence check to re-run at write time. A file
appearing between summary and `accept` — a concurrent `/cost-estimate` for the
same target/day, or a manual drop — is clobbered, because the disambiguator was
computed against a listing that is stale by the time the Write fires.

### Evidence

> `cost-estimate.md:299-303` — collision check + disambiguator at "the
> confirm-before-write summary (step 5) … never silently overwrites".

> `cost-estimate.md:270-274` (step 7) — the single Write, with no restated
> existence check.

### Why this matters

The guarantee is the whole point of the O9 resolution (silent estimate loss is
real data loss). Binding the check to step 5 makes it a time-of-check/time-of-use
gap that widens with deliberation time. The fix is one clause — "re-evaluate the
collision at write time and re-disambiguate if the target now exists". Medium
because the window is small and the targets are gitignored regenerable artefacts.

## O7 — scope — medium

### Claim

The commands reference page still opens with "All 24 slash commands registered
in `commands/`", but `commands/` now contains 27 command files including the new
`cost-estimate.md`. The page ships factually wrong on the day the command lands —
the reference-staleness the spec's own scope section commits to avoiding.

### Evidence

> `docs/plugins/ai-literacy-superpowers/reference/commands.md:6` — "All **24**
> slash commands registered in `commands/`."

A Glob of `commands/*.md` returns 27 files. The implementer correctly added the
`### /cost-estimate` entry (`commands.md:281`) but left the count at line 6
unchanged.

### Why this matters

The CLAUDE.md "Docs Site Review" convention requires reference pages to be
current when a feature changes the surface they describe; the spec puts the
reference entry in scope. The number was likely stale before this PR, but this PR
adds the command that makes it wrong by one more and touches this very file, so
it is this PR's to correct.

## O8 — implementation — low

### Claim

The command tells the executor to pass "the resolved model id for the agent's
`generated_by` branch (a)" but only "if the command knows it", and never says how
a slash-command executor would know it. In practice it has no resolved model id,
so branch (a) never fires and every record takes branch (b)'s routing-tier
default. The instruction presents (a) as a live path when it is effectively dead.

### Evidence

> `cost-estimate.md:83-84` — "and — **if the command knows it** — the resolved
> model id for the agent's `generated_by` branch (a)".

> `cost-estimator.agent.md:218-226` — branch (b) (read the tier from
> `MODEL_ROUTING.md`) is the default when no id is supplied.

### Why this matters

Harmless to output (branch (b) produces honest `tier:` provenance), so `low`. But
it is dead conditional prose: a future maintainer may build logic for a path that
can never be exercised, or be misled that records can carry concrete model ids
under this command. A one-line note ("the slash-command executor has no resolved
model id, so branch (b) is the live path; (a) is reserved for an orchestrator
dispatcher that does") retires the ambiguity.

## Explicitly not objecting to

- **The dispose-then-write ordering itself**: steps 5→6→7 place the single
  `Write` unambiguously downstream of `accept`, and the REFUSED/abort/edit/re-run
  branches each correctly write nothing — the core ordering invariant is sound;
  O5/O6 are about mode and collision-timing seams, not the ordering.
- **The `cost-estimates/` output home (outside `observability/`, gitignored)**:
  the placement reasoning, the `.gitignore` entry matching the `/diagnose`
  rationale, and the "predictions are not telemetry" decision are coherent and
  correctly implemented across command, docs, and gitignore.
- **Empty-snapshot-is-not-a-refusal**: command (`102-104`) and agent agree an
  empty `observability/costs/` yields a valid cost-omitted record, and the
  trailing-slash sentinel is honoured in the summary without mutating the format
  contract.
- **The #377 deferred absolute-rate check being out of scope**: the re-filing-to-S6
  reasoning is an adjudicated spec-time decision; re-raising it would re-litigate
  a resolved disposition.
- **The checklist transcription**: the command's lines 1-9 faithfully transcribe
  the format reference's validation checklist incl. the #377 additions; the
  transcription is correct.
