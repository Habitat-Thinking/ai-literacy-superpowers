# Spec: Cadence Sentinels S7 — Documentation, Marketplace, and Sync

**Status:** Draft (revision 1)
**Date:** 2026-08-13
**Issue:** #497 — and folds in #513 (docs-site gaps), whose scope is the same work
**Epic:** The Cadence Sentinels (S1–S7) — the closing slice
**Depends on:** S2–S6, all merged (0.68.0 – 0.73.0)
**Scope:** the docs site, `sentinel-design/SKILL.md`, and one smoke test

**Provenance:** *The Second Front — Arc Insertion Remit* (slide S7).

---

## 1. Problem Statement

Six slices shipped four sentinels, five hooks, three record contracts, a
deterministic constraint and a checker. The documentation did not keep pace, and
one page is now **factually wrong**.

That is not incidental to this epic. Every slice found its sharpest defect in
something *written* rather than something built — a docstring, an example line,
an enum value, a roster, a premise. S7 is where the writing gets the same
adversarial pass the code did.

## 2. What Is Actually Missing

Verified against shipped files, not inferred.

### 2.1 Four explanation pages that the convention demands

Five of the nine sentinels have a one-page explanation each:

| Page | Sentinel |
| --- | --- |
| `cadence-governance.md` | `carpaccio` |
| `adversarial-review.md` | `advocatus-diaboli` |
| `decision-archaeology.md` | `choice-cartographer` |
| `watching-the-verifier.md` | `reservoir-warden` |
| `prospective-cost-estimation.md` | `cost-estimator` |

**The four cadence sentinels have none.** Their how-to guides shipped with their
slices — `closing-a-session.md`, `keeping-a-pact.md`, `watching-your-wip.md`,
`convening-the-voices.md` — but a how-to answers *how do I use this*, and the
convention here is that each sentinel also gets a page answering *why is it
built this way*.

That quadrant is where this epic's genuinely conceptual results have no home:

- the **operational-state carve-out** — a third persistence category beside "by
  the person" and "about the person", permitted only when local, bounded,
  judging nothing, and declinable
- the **read/write library split** — a sentinel may source the read surface;
  mutation lives in a hooks-only library the frontmatter check cannot see
- **state-in-the-path records** — append-only made *true* by writing a new file
  per transition rather than editing a `status` key
- the **advisory rail's precedence rule** — a once-only advisory speaks and a
  repeating one defers, because ordering by position preserved the message that
  repeats and permanently spent the one designed to arrive once
- the **lease with heartbeat renewal** — because `Stop` fires per assistant
  turn, not per session

### 2.2 `reference/hooks.md` is wrong, and short by two

**Wrong:** PR #510 moved the constraint gate to `PostToolUse`. The page still
carries it under `## PreToolUse Hooks` with an explicit `- **Event**:
PreToolUse` line, and there is **no `## PostToolUse Hooks` section on the page
at all**. The description is also pre-write framing ("would violate") and omits
the verbatim-quote rule that fix introduced.

**Short:** `hooks.json` declares **18** hooks; the page documents **17**.
`wip-check.sh` (SessionStart, S4) is absent though both its siblings from this
epic are present, and `affordance-invocation-recorder.sh` (PostToolUse) has had
nowhere to live for want of the missing section.

### 2.3 `harness-md-format.md` never documents `## Stakeholders`

S5 shipped an optional `## Stakeholders` section — the declaration surface the
Convener reads to flag a voice `observed` rather than `inferred`. It is in
`templates/HARNESS.md` and explained in `convening-the-voices.md`, but not in
the **format reference**, which is where a reader goes to learn what sections a
`HARNESS.md` may contain.

S5's own rollout section named this file. **This is a missed commitment, not a
discovered gap** — which is worth saying plainly, because the epic's recurring
lesson is that a stated intention is not a shipped one.

### 2.4 `progressive-hardening.md` teaches a model the harness no longer follows

The page presents Unverified → Agent-verified → Deterministic as one ladder. S5
established, and a shipped constraint now demonstrates, that **the rung and the
reach are different axes**:

- **Rung** — how the check runs: `deterministic | agent | unverified`. The enum.
- **Reach** — what it demands: required on every PR, versus
  **complete-if-present**.

`PRs have disposed consultation voices` is `deterministic` **and** deliberately
held back in reach: a PR with no consultation record passes, because running
`/convene` is a choice. The one-axis model has no position for that constraint —
which is precisely how S5's first revision came to invent an `agent-verified`
rung that was never a value of the enum.

Note also that the page's own level names disagree with the enum it documents.

### 2.5 `sentinels.md` has a roster and no organising idea

The roster reached 9 in S5. What it lacks is the **two disciplines**:

- **Decision discipline** — `carpaccio`, `advocatus-diaboli`,
  `choice-cartographer`, `cost-estimator`: they guard *decisions* and their
  inputs.
- **Cadence discipline** — `coda`, `mast`, `wip-warden`, `convener`: they guard
  *the shape of the work around* those decisions. `carpaccio` is the forerunner,
  sitting in both.

`reservoir-warden` belongs to neither and guards *the decider*.

## 3. What Is Not Buildable Here

**The keynote sync (#497 item 4) is blocked, and the slice ships without it.**

It asks for verification that every link in the deck's S5 and slide-18 small
print resolves. That deck — *The Second Front — Arc Insertion Remit* — **is not
in either repository**:

| Searched | Found |
| --- | --- |
| `decks/` in this repo | `cognitive-debt-paydown.md` — ~9 slides, a different talk, no sentinel mentions, no slide 18 |
| `ai-literacy-for-software-engineers` | `talks/agile-tour-vienna-2026/keynote.md` — *"Does AI Deliver Waterfall?"*, 4 sections, no sentinel mentions, no external links |

Neither contains an S5 slide, a slide 18, or any link to check. **Verifying
links in a document that cannot be located is not something to approximate**,
and reporting it as done would be exactly the overclaim this epic keeps
catching.

The PR declares this openly and lists what would unblock it: the deck's path, or
the list of links it carries.

## 4. Decisions Taken at the Gate

### 4.1 `mast` keeps its name

Issue #497 flags the naming as open. **The repo has already answered**: `mast` shipped
in 0.69.0 and appears across 35 files, including a command users type, a pact
block name, and three hook libraries. Renaming is a breaking change to a live
command in exchange for a prose preference.

The Ulysses metaphor is also load-bearing rather than decorative — the skill's
entire argument is that a limit set *in clear weather* must survive the moment
it governs, and the mast is what makes that concrete.

The new explanation page nonetheless **leads with the plain-language framing**
so it reads to someone who has never heard of Ulysses.

### 4.2 No marketplace change

Issue #497 asks whether the cadence-discipline framing becomes a marketplace grouping
now or after the keynote. **The schema has nowhere to put one**: entries in
`.claude-plugin/marketplace.json` carry `name`, `source`, `description`,
`version` and nothing else.

Inventing a grouping field would be declaring a contract the platform does not
define. The framing lands in the docs, where it is readable and costs nothing to
revise once the keynote is final.

## 5. The Smoke Test

Issue #497's third acceptance item asks for a fresh-clone smoke run of `/coda`,
`/mast`, `/wip` and `/convene` against a toy repo.

**Half of that is honestly automatable and half is not.** The commands dispatch
model-mediated agents; a real run needs a live session and cannot be a CI test.
What *can* be exercised end-to-end is the **deterministic substrate S1–S5 built**
— and it has never been tested as a whole, only per-library.

`tdad_tests/layer0_deterministic/test-cadence-smoke.sh` builds a toy repo in a
temp directory and drives the real shipped scripts across it:

- **K1** — a pact file with all three blocks reads back through `pact-blocks.sh`
  with the right keys, including `hard_stop_hour: 18:30` (the first-delimiter
  rule).
- **K2** — `session-registry-start.sh` registers, `registry_count` counts, and
  `session-registry-sweep.sh` retires only what the lease expired.
- **K3** — `wip-check.sh` is silent under the limit and reports over it, naming
  count and limit.
- **K4** — `next-action-hint.sh` finds an anchor; a parking record written to
  the records directory is found open by `records_open` and, once resolved, is
  superseded by `records_latest`.
- **K5** — `check-consultation-dispositions.py` passes on a fully-disposed
  record and fails on a pending one, in the same toy repo.
- **K6** — every one of these exits 0 on a repo with **none** of these files,
  which is the state of every project that has not adopted the epic.

K6 is the one that matters most: the substrate must be silent by default.

## 6. Files

| File | Purpose |
| --- | --- |
| `explanation/the-closing-ritual.md` | **new** — the Coda |
| `explanation/ulysses-pacts.md` | **new** — the Mast |
| `explanation/concurrency-and-wip.md` | **new** — the WIP Warden |
| `explanation/consulting-the-affected.md` | **new** — the Convener |
| `explanation/sentinels.md` | the two disciplines (§2.5) |
| `explanation/progressive-hardening.md` | rung vs reach (§2.4) |
| `reference/hooks.md` | the PostToolUse section, the correction, the two missing hooks (§2.2) |
| `reference/harness-md-format.md` | the `## Stakeholders` section (§2.3) |
| `skills/sentinel-design/SKILL.md` | the two disciplines, mirroring the roster it already carries |
| `tdad_tests/layer0_deterministic/test-cadence-smoke.sh` | **new** — §5 |

## 7. Non-Goals

- **No rename of `mast`**, or of anything else. §4.1.
- **No marketplace schema change.** §4.2.
- **No keynote link verification.** §3 — blocked, declared, not approximated.
- **No new agent, skill, or command.** Component counts unchanged.
- **No behaviour change anywhere.** S7 is documentation plus one test over
  already-shipped code.
- **No new how-to pages.** All four already exist.

## 8. Acceptance Scenarios

- **D1** — every one of the nine sentinels has exactly one explanation page, and
  the count is derived from `role: sentinel` frontmatter rather than pinned.
- **D2** — `reference/hooks.md` documents every hook `hooks.json` declares, and
  each entry's stated event matches the event it is registered under.
- **D3** — no page describes the constraint gate as a `PreToolUse` hook.
- **D4** — `harness-md-format.md` documents `## Stakeholders`.
- **D5** — `progressive-hardening.md` distinguishes rung from reach and uses the
  enum's own vocabulary.
- **K1–K6** — §5.
- Docs build clean under `--strict`.

## 9. Rollout

`skills/sentinel-design/SKILL.md` is a plugin file, so a bump is required:
**0.73.0 → 0.74.0**. Five CI-checked version locations plus the README
plugin-table cell.

**Component counts unchanged**: 41 skills, 20 agents, 32 commands. No count
badges, anchors, or headings move.

Closes **#497** and **#513**.
