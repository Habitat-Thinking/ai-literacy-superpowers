# Spec: Harness Evolution S0 — HDR schema, surfaces schema, and validator

**Status:** Approved
**Date:** 2026-08-23
**Issue:** #534
**Epic:** Harness Evolution — the Harness Assayer and the Harness Registrar (#533)
**Depends on:** nothing. This is the substrate phase.
**Scope:** `ai-literacy-superpowers` plugin — one validator script, one schema
reference, one Layer-0 test suite, one new record corpus at `harness/`.
**Explicitly out of scope:** agents, commands, compilation, application of rule
text to any governance artifact. Phase 0 builds the thing that says *no*; every
later phase calls it.

**Provenance:** the Harness Assayer / Harness Registrar build spec, supplied in
conversation 2026-08-23. Epic-level design decisions (§14 open questions) were
resolved before implementation and are recorded on #533.

---

## 1. Problem Statement

The plugin governs the loop (`HARNESS.md`) and the turn (`AGENTS.md`). Nothing
governs how those two documents themselves change.

`/harness-audit` checks whether the harness matches reality. `/governance-audit`
checks whether constraints have drifted from their intent. Both look at rules
that already exist. Neither governs the *act of changing* a rule — what evidence
justified it, who approved it, what it costs the next person, and when it
stops being true.

So harness rules accrete. A rule enters because someone was annoyed once, and
it never leaves, because leaving requires somebody to remember it exists.

The Harness Decision Record (HDR) is the unit that fixes this. This phase
defines what an HDR *is* and builds the thing that refuses a bad one.

## 2. Why the validator comes first, and why it holds every refusal

The epic resolved §14 Q2 in favour of the Harness Registrar being a **plugin
agent** with `Write`/`Edit` rather than scripts alone. That is a deliberate
choice — rule text has to land in a specific place in a specific document, and
that is judgement — but it puts a model in the governance write path, which is
precisely the risk the two-role separation exists to remove.

The resolution is not to trust the agent's instructions. It is to move **every
refusal into deterministic code that CI also runs**:

> A rule that only exists in an agent's prompt is a rule the agent can
> rationalise around. A rule that exists in `check-harness-decisions.py` is a
> rule that turns the build red.

So the promotion thresholds, the cost rule, the tier rules, the enum checks and
the identifier grammar all live here, in Phase 0, before any agent exists.
`/harness-accept` in Phase 1 becomes a thin caller: it prompts, it writes, and
it invokes this validator. If the validator says no, nothing is written.

This inverts the usual build order — normally the tool comes after the thing it
checks. Here the checker *is* the specification, and everything downstream is
an interface to it.

## 3. Layout

```text
harness/
  surfaces.yaml                     # capability matrix per control surface
  assay/                            # (S3) Assayer output, append-only
  decisions/
    HDR-<YYYY-MM-DD>-<slug>.md      # one per governance change
    index.md                        # (S1) GENERATED
  enforcement-report.md             # (S2) GENERATED
```

`harness/` is a new top-level corpus, deliberately outside `docs/superpowers/`.
The `docs/superpowers/` corpora are records of the *spec pipeline* — one project's
decisions about its own features. `harness/` is a record of the *harness*, and
a project adopting this plugin gets a `harness/` directory without inheriting
this repository's spec conventions.

### 3.1 It is an append-only corpus

`harness/decisions/**` and `harness/assay/**` join `docs/superpowers/**` and
`reflections/**` in the markdownlint exclusion list, for the same reason those
are excluded: records quote markdown as evidence and carry human dispositions,
so style rules fight them by construction, and reformatting one would edit
something the append-only rule protects.

### 3.2 The one place an HDR is mutable

A `status: proposed` HDR is a **draft**, not a record. It may be edited freely.

Acceptance is the moment it becomes a record. From `status: accepted` onward an
HDR is frozen: it is never edited, only **superseded** by a later HDR that names
it in `supersedes:`.

This is why this corpus does not use the state-in-path substrate in
`hooks/scripts/lib/record-paths.sh`, which the cadence-sentinel records use. That
substrate exists because a `parked → resumed` transition is a state change with
no new content, and flipping a `status:` key in place would violate append-only.
Acceptance is not that shape: the human authors the `cost` at the gate, so
acceptance genuinely *adds* content rather than flipping a flag. One file, one
decision, mutable until it is decided and immutable after.

Freezing is enforced against git history rather than by hope — see §9.

## 4. The HDR

### 4.1 Identifier

`HDR-<YYYY-MM-DD>-<slug>`, matching the filename stem exactly.

Sequential numbering collides as soon as two people propose on parallel
branches. Date-plus-slug is merge-safe and readable in a file listing.

- Filename: `HDR-YYYY-MM-DD-<slug>.md`
- Slug grammar: `[a-z0-9]+(-[a-z0-9]+)*`
- The date must be a real calendar date
- Frontmatter `id` must equal the filename stem

### 4.2 Frontmatter

```yaml
---
id: HDR-2026-08-19-observed-evidence
title: Require observed evidence for phase completion claims
status: accepted           # proposed | accepted | rejected | superseded | expired
classification: harness-loop
enforcement: validated     # advisory | validated | blocked
surfaces: [claude-code, codex]
provisional: true
expires: 2026-11-19        # required when provisional, unless review_trigger is set
review_trigger: "Two consecutive assays with zero findings in this class"
imported: false
evidence:
  - harness/assay/2026-08-04T09-12Z-assay.md#finding-1
  - harness/assay/2026-08-12T14-03Z-assay.md#finding-3
proposed_cost: |
  One extra check per phase boundary.
cost: |
  Human-authored. One extra check per phase boundary; roughly two minutes.
  Risk: reviewers may start pasting command output to satisfy the rule.
proposer:
  agent: harness-assayer
  model: <model-id>
  assay: harness/assay/2026-08-12T14-03Z-assay.md
approver: <human identity>
approved_at: 2026-08-19T10:41Z
supersedes: null
superseded_by: null
cohort: b                  # optional
---
```

### 4.3 Required fields

| Field | Present | Non-empty |
| --- | --- | --- |
| `id`, `title`, `status`, `classification`, `enforcement`, `surfaces`, `provisional`, `evidence`, `proposer`, `supersedes`, `superseded_by` | always | always (`surfaces` may be empty for `no-change`; `supersedes`/`superseded_by` may be `null`) |
| `cost` | always | **only when `status: accepted`** |
| `approver`, `approved_at` | `status: accepted` | `status: accepted` |
| `expires` **or** `review_trigger` | `provisional: true` | `provisional: true` |
| `cohort`, `proposed_cost`, `imported` | optional | — |

**Why `cost` is present-but-empty at `proposed`.** The human authors the cost at
the acceptance gate, which is the whole point of §5.1 — so a proposed HDR with an
empty `cost` is the *correct* state, not a malformed one. Requiring it non-empty
from the start would force `/harness-propose` to fabricate a cost, which is
precisely the laundering the rule exists to prevent. The key must exist so the
shape is stable and the gap is visible; the value arrives at the gate.

### 4.4 Enums

- `status` — `proposed` · `accepted` · `rejected` · `superseded` · `expired`
- `classification` — `harness-loop` · `turn-instructions` · `agent-instruction`
  · `agent-reference` · `script-validator` · `regression-test` · `new-agent` ·
  `no-change`
- `enforcement` — `advisory` · `validated` · `blocked`

An unknown value in any of these fails loudly. A typo must never be a silent
exemption — the precedent is `sentinel-integrity-check.sh`, which fails on
`role: sentinal` rather than skipping the file.

### 4.5 Body tiers, scaled to blast radius

Process burden should be proportional to reach. The validator enforces the tier
implied by `classification`; reclassifying upward requires the additional
sections before acceptance.

**Every HDR** — `## Finding`, `## Rule`, `## Cost`.

**Additionally for `harness-loop`, `script-validator`, `new-agent`** — the
classifications whose reach extends beyond a single agent — `## Why this layer`,
`## Enforcement`, `## Validation`, `## Rejected alternatives`.

Every required section must be non-empty. A heading with nothing under it is a
missing section that looks present, which is worse than an absent one.

### 4.6 The Rule block

The `## Rule` section must contain **exactly one fenced block delimited by four
backticks**, holding the rule text verbatim as it will appear in the target
artifact.

Four backticks, not three, because rule text is markdown and routinely contains
a three-backtick fence of its own. A three-backtick delimiter would terminate on
the first nested fence and silently truncate the rule.

This block is the extraction target for Phase 2's byte-identity check: the text
applied to a governance artifact must be byte-identical to what is inside these
four backticks. That is what keeps "the Registrar never paraphrases to make text
fit" a guarantee rather than an instruction.

### 4.7 `no-change` is a first-class outcome

An assay in which every finding resolves to `no-change` is a successful assay.
Recording that nothing needed to change is evidence.

A `classification: no-change` HDR is relaxed accordingly:

- `enforcement` must be `advisory` — nothing is being enforced
- `surfaces` may be empty — nothing reaches a surface
- `provisional` must be `false`, and expiry rules do not apply — nothing is in
  force, so nothing can lapse
- the `## Rule` section carries the literal text `No change.` and no fenced block

## 5. The refusals

These are the phase. Each is a validator rule with a specific message.

### 5.1 The cost rule

At `status: accepted`, `cost` must be non-empty after stripping whitespace.

Where `proposed_cost` is present, `cost` must differ from it after stripping
leading and trailing whitespace.

At `status: proposed` an empty `cost` passes — see §4.3.

**This is the fix for an unimplementable clause in the build spec.** That spec
requires refusing a `cost` "byte-identical to the Harness Assayer's proposal",
but never says where the Assayer's proposal is stored — so there is nothing to
compare against. `/harness-propose` (S1) writes the Assayer's words into
`proposed_cost` and leaves `cost` empty. The human's words go in `cost`. The
comparison is now mechanical.

Without this, the single most important anti-theatre requirement in the whole
design degrades to a polite request, and the failure is invisible: a
copy-pasted cost reads exactly like a considered one.

### 5.2 The promotion threshold

A `classification: harness-loop` HDR at `status: accepted` must cite **at least
two distinct assay files** in `evidence`. A single incident cannot reach the
loop layer.

Distinctness is by assay file path, not by evidence entry — two anchors into the
same assay are one assay.

### 5.3 The cycle cap

At most **three** HDRs at `status: accepted` may share the same
`proposer.assay`. Excess proposals stay `proposed` and carry forward.

Both §5.2 and §5.3 are corpus-level rules: they cannot be checked by looking at
one file. That is the second reason they live in the validator rather than in
the accepting command — CI re-checks the whole corpus on every PR, so a
threshold cannot be evaded by a merge that combines two individually-valid
branches.

### 5.4 The expiry rule

`provisional: true` requires `expires` (a real calendar date) or a non-empty
`review_trigger`. Permanence is earned at review, not at creation.

### 5.5 Grandfathering

`imported: true` marks a rule that predates this mechanism — a constraint lifted
from an existing `HARNESS.md` during migration.

An imported HDR:

- must have `provisional: false` and no `expires`
- must have `proposer.agent: imported`
- is exempt from §5.2's two-assay threshold
- must still cite at least one `evidence` entry — the source artifact

`imported: true` with `provisional: true` is a contradiction and fails.

This resolves §14 Q5. The alternative — importing every legacy rule as
provisional with a 90-day clock — manufactures a large expiry cliff on roughly
day 90 of adoption, with `/harness-check` going red on rules nobody proposed.
The predictable result is that people learn to ignore a red check, which costs
more than the un-evidenced legacy rules ever did.

## 6. `surfaces.yaml`

```yaml
surfaces:
  claude-code:
    targets: [CLAUDE.md, .claude/agents/, .claude/hooks/]
    supports: [advisory, validated, blocked]
  copilot-cli:
    targets: [.github/copilot-instructions.md]
    supports: [advisory]
  codex:
    targets: [AGENTS.md, .codex/skills/]
    supports: [advisory, validated]
  ci:
    targets: [.github/workflows/harness-check.yml]
    supports: [validated, blocked]
```

Validated as: a top-level `surfaces` mapping, non-empty; each key matching
`[a-z0-9]+(-[a-z0-9]+)*`; each entry carrying a non-empty `targets` list of
strings and a non-empty, duplicate-free `supports` list drawn from the
enforcement enum.

### 6.1 The cross-check, and the one thing it must not do

Every entry in an HDR's `surfaces` list must be a key declared in
`surfaces.yaml`. An HDR naming a surface that does not exist is a typo, and
fails.

**A surface that does not support the HDR's `enforcement` level is not an
error.** That is an *enforcement gap*, and reporting it is the primary output of
Phase 2, not a validation failure. A rule that intends `blocked` on a surface
that can only advise is a true and useful fact about the world; failing the
build over it would push authors to downgrade their intent to whatever the
weakest surface can manage, which destroys exactly the information the gap
report exists to carry.

## 7. Implementation

`ai-literacy-superpowers/scripts/check-harness-decisions.py`

- Python 3, **no third-party dependencies** — CI-friendly, matching
  `check-consultation-dispositions.py` and `check-convention-parity.py`.
- Includes a minimal YAML-subset reader sufficient for frontmatter and
  `surfaces.yaml`: scalars, block scalars (`|`), flow and block sequences, and
  one level of nested mapping (`proposer`). It is not a YAML implementation and
  does not pretend to be; it rejects what it cannot read rather than guessing.
- Exit `0` on a clean corpus, non-zero on any failure, one `FAIL:` line per
  violation naming the file and the rule.
- A repository with no `harness/` directory passes. Adopting this mechanism
  stays a choice.

## 8. Acceptance criteria

| ID | Criterion |
| --- | --- |
| V1 | A repository with no `harness/` directory passes |
| V2 | A well-formed minimal HDR passes |
| V3 | Filename/`id` mismatch fails, naming both |
| V4 | A bad slug or an impossible date fails |
| V5 | Each missing always-required field fails with that field named |
| V6 | Unknown `status`, `classification`, or `enforcement` values fail loudly |
| V7 | A tier-2 classification missing any of the four extra sections fails, naming the section |
| V8 | An empty required section fails |
| V9 | A `## Rule` section with no four-backtick block, or more than one, fails |
| V10 | An accepted HDR with empty `cost` fails; an accepted `cost` equal to `proposed_cost` fails; a **proposed** HDR with empty `cost` passes |
| V11 | `provisional: true` with neither `expires` nor `review_trigger` fails |
| V12 | An accepted `harness-loop` HDR citing one assay fails; citing two distinct assays passes; citing two anchors into the same assay fails |
| V13 | A fourth accepted HDR sharing one `proposer.assay` fails |
| V14 | `imported: true` passes without expiry; with `provisional: true` it fails |
| V15 | `status: accepted` without `approver`/`approved_at` fails |
| V16 | An HDR naming an undeclared surface fails |
| V17 | An HDR whose `enforcement` exceeds a surface's `supports` **passes** (gap, not error) |
| V18 | A malformed `surfaces.yaml` fails for each of: missing top-level key, empty `targets`, empty `supports`, unknown `supports` value, duplicate `supports` value, bad surface key |
| V19 | A `no-change` HDR passes with empty surfaces, `advisory`, no fenced rule block |

Tests live at `tdad_tests/layer0_deterministic/test-harness-decisions.sh`,
following the red/green fixture pattern of `test-convene-check.sh`.

## 9. Forward references

Deliberately **not** built in this phase, recorded so the next phase does not
have to rediscover them:

- **Frozen-after-acceptance enforcement (S2).** `/harness-check` compares each
  accepted HDR against its state at the commit that accepted it, using git
  history. §3.2 states the rule; without this check it is only a convention, and
  an agent with `Write` could edit an accepted rule and its target artifact
  together so that the byte-identity check still passes.
- **Byte-identity check (S2).** Applied text must equal the four-backtick Rule
  block exactly.
- **Expiry detection (S4).** An `expires` date in the past on a
  `status: accepted` HDR fails `/harness-check`. The field is validated for
  *shape* here and for *lapse* there.
- **Evidence resolution (S4).** `/harness-check` fails when an HDR's evidence
  references no longer resolve. Not checked here, because S0 has no assay corpus
  to resolve against.

## 10. Rejected alternatives

**State-in-path records via `record-paths.sh`.** Rejected per §3.2: acceptance
adds the human-authored cost, so it is a content change, not a bare state
transition. Using the transition-file substrate would split one decision across
two files for no gain, and would make the frozen-after-acceptance rule harder to
express, not easier.

**Refusals in the Registrar's prompt.** Rejected per §2. Corpus-level rules
(§5.2, §5.3) cannot be checked from one file at write time anyway, and a rule
that lives only in a prompt is one a model can talk itself past.

**Depending on PyYAML.** Rejected. Every existing validator in this repository
is dependency-free, and adding a runtime dependency to a governance gate makes
the gate fail for reasons unrelated to governance.

**Failing on an enforcement gap.** Rejected per §6.1 — it would train authors to
declare the weakest enforcement any surface supports, which discards the
information the gap report exists to carry.
