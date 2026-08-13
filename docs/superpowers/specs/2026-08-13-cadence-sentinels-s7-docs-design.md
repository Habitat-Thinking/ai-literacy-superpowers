# Spec: Cadence Sentinels S7 — Documentation, Marketplace, and Sync

**Status:** Approved (revision 2, post-diaboli)
**Date:** 2026-08-13
**Issue:** #497 — and folds in #513 (docs-site gaps), whose scope is the same work
**Epic:** The Cadence Sentinels (S1–S7) — the closing slice
**Depends on:** S2–S6, all merged (0.68.0 – 0.73.0)
**Objections:** `docs/superpowers/objections/cadence-sentinels-s7-docs-design.md`
— 12 objections, all accepted
**Scope:** the docs site, `hooks.json`'s description, `README.md`, and one
integration test

**Provenance:** *The Second Front — Arc Insertion Remit* (slide S7) — **a
document that is in neither repository.** See §3 and #514; the citation is
recorded as unresolvable rather than repeated as though it were retrievable.

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

### 2.1 One cadence-discipline page, mirroring the one that exists

Revision 1 claimed a one-page-per-sentinel convention and produced a five-row
table proving it. **The table was built by omitting the counterexamples** (O3):

| Page | Covers |
| --- | --- |
| `cadence-governance.md` | `carpaccio` |
| `adversarial-review.md` | `advocatus-diaboli` |
| `decision-archaeology.md` | `choice-cartographer` |
| `watching-the-verifier.md` | `reservoir-warden` |
| `prospective-cost-estimation.md` | `cost-estimator` |
| **`decision-discipline-triad.md`** | **`carpaccio` + `advocatus-diaboli` + `choice-cartographer`** |
| **`the-cost-estimation-loop.md`** | **`cost-estimator`, a second time** |

The real pattern is **mixed**: per-agent pages *and* per-discipline pages, both
linked from the landing page. So the convention that justified four new pages
does not exist — and the per-discipline shape this slice was going to introduce
as a framing is already sitting in the directory.

This is the S6 finding one slice later: a premise asserted from the cases that
fit. It is worth naming rather than quietly correcting, because it is now the
second time in two slices.

**S7 therefore ships ONE page — `cadence-discipline.md` — mirroring
`decision-discipline-triad.md` exactly**, with a `###` section per sentinel.
The four how-to guides already answer *how do I use this*; this answers *why is
it built this way*, once, for the four together, which is also the only place
their shared results can be stated.

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

**Short:** `hooks.json` declares **18**; the page documents **16** — revision 1
said 17 under a heading reading "short by two", and both could not hold (O6).
`wip-check.sh` (SessionStart, S4) is absent though both its siblings from this
epic are present, and `affordance-invocation-recorder.sh` (PostToolUse) has had
nowhere to live for want of the missing section.

The discrepancy hides a third thing: `### The advisory rail` sits among the Stop
hooks but documents `lib/advisory-rail.sh`, **a sourced library that is never
registered**. It moves to a `## Libraries` section outside the event groups, so
a count over event-section headings is exact rather than off by one forever.

**And the error is in the shipped artefact, not only its documentation** (O5).
`hooks.json`'s own description field says the constraint gate is `PreToolUse`
while the same file registers it under `PostToolUse` eight lines later. `README.md`
carries it twice more — once in prose at :323, once in the architecture diagram
at :428. A grep for `PreToolUse` returns three files; revision 1 named one.

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

The page's own level names also disagree with the enum it documents: three
rungs are named, then a **four**-value enum appears
(`unverified | agent | deterministic | deterministic + agent`), whose fourth
value has no rung at all.

**And the one-axis model is in eight pages, not one** (O8) — including
`how-to/add-a-constraint.md`, which states the ladder at the exact moment
someone is choosing an `Enforcement` value. That is where the missing reach axis
has consequences, so fixing only `progressive-hardening.md` would have corrected
the page a reader consults *after* they have the question and left the page that
forms it. All eight are corrected.

### 2.5 `sentinels.md` has a roster and no organising idea

The roster reached 9 in S5. **The framing it needs is already shipped** — in
`sentinel-design/SKILL.md:139-143` and repeated in `sentinels.md`:

> the decision-discipline triad guards *decisions*; the reservoir-warden guards
> *the decider*; the cost-estimator guards *the decision's inputs*. The four
> cadence sentinels guard the shape of the work around those decisions.

Revision 1 proposed a *different* framing that moved `cost-estimator` inside the
decision discipline. That is a **reclassification contradicting three shipped
surfaces**, and it would have misnamed `decision-discipline-triad.md` — a page
whose title says three and whose body argues "why three, not one" — on the day
S7 merged (O7). A slice built to remove pages teaching superseded models would
have created one.

**The shipped framing stands.** What S7 adds is the name *cadence discipline*
for the group that already has the description, and the page that explains it.

`sentinels.md` also needs two repairs revision 1 did not see: a blank line at
:115 **orphans the `convener` row into a second one-row table** — live on the
docs site since S5, introduced by the edit that added the row — and :198 still
reads "The five roster agents behave exactly as before" beneath a roster of
nine.

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

### 3.1 The finding is bigger than one acceptance item

**All seven** Cadence Sentinels specs cite this deck in their provenance line.
If it cannot be located, the answer to *"why these nine sentinels, in this
order, with this remit?"* has no external referent — and S7, the slice whose job
is to give the epic's results a durable home, is the last place anyone looks
(O1).

Revision 1 filed this as a blocked checklist item. It is the epic's own
recurring defect at epic scale: a confident sentence describing something that
is not there. **#514** records it, and this spec's own provenance line says so.

### 3.2 So this PR does not close #497

Declaring item 4 undone and closing the issue that tracks it are the same
overclaim through two channels (O2). `Closes #497` is a machine instruction, and
merging it would shut an issue whose fourth acceptance item was never met, with
the only record living in a merged PR body — not a surface anyone returns to.

**The PR closes #513 only.** A comment on #497 records what shipped, what did
not, and what would unblock it: the deck's path, or the list of links it
carries.

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

## 5. The Integration Test

Issue #497's third acceptance item asks for a fresh-clone smoke run of `/coda`,
`/mast`, `/wip` and `/convene` against a toy repo.

**Half of that is honestly automatable and half is not.** The commands dispatch
model-mediated agents; a real run needs a live session and cannot be a CI test.

### 5.1 What it must test, and what it must not re-test

Revision 1 proposed K1–K5 re-running per-library coverage that already ships —
`test-pact-blocks.sh`, `test-session-registry.sh`, `test-wip-check.sh`,
`test-next-action.sh`, `test-record-contracts.sh`, `test-convene-check.sh`. Five
independent assertions sharing an `mktemp` is not integration coverage; it is
the same coverage with a shared temp directory (O11).

The property per-library tests **structurally cannot** show is agreement:

> **Three libraries read the pact file independently.** `pact-blocks.sh` reads
> the limit, `session-registry-read.sh` applies the lease, and `wip-check.sh`
> compares one against the other. Nothing today asserts that the value one
> library reads is the value the next one acts on.

That is the whole test: **one pact file, one registry, three readers, one
answer.**

### 5.2 It must not touch the developer's machine

The pact file and the session registry live **outside every work tree by
design** — `$HOME/.claude/pacts.md` and `$HOME/.claude/sessions/`. A toy repo
does not isolate them (O9).

Revision 1 named a temp directory and none of the four test-only overrides. A
run would have written into the **real** registry, inflating the live-session
count the WIP Warden reports against a line the person drew — which
`test-wip-check.sh` already names as the worst output this substrate can
produce — and `session-registry-sweep.sh` could have retired a merely-idle
colleague session (O10).

All four are set: `$CLAUDE_PACTS_FILE`, `$CLAUDE_SESSIONS_DIR`,
`$CLAUDE_MAST_DIR`, `$CLAUDE_PARKED_DIR`.

### 5.3 Scenarios — `tdad_tests/layer0_deterministic/test-cadence-integration.sh`

- **K1 — one pact, three readers, one answer.** A pact declaring
  `max_concurrent_sessions: 2` is read by `pact-blocks.sh`, and `wip-check.sh`
  reports a breach at exactly the third live registry entry — not the second,
  not the fourth.
- **K2 — the lease governs what the count sees.** An entry aged past
  `_lease_hours` stops being counted, so the breach clears without the pact
  changing. The limit and the lease are read by different libraries and must
  agree on the same registry.
- **K3 — a record written by one contract is found by the other.** A parking
  record is open to `records_open`; its `.resolved.md` successor is what
  `records_latest` returns, and `check-consultation-dispositions.py` reads
  through the latter.
- **K4 — silence on an unadopted machine.** No pact file, empty registry: every
  hook emits **nothing** and exits 0. This constructs *machine*-state absence,
  which is the state that actually matters, and it is the scenario revision 1
  got wrong.
- **K5 — no shipped script writes outside its store.** After a full run, the
  toy repo contains no `.claude/` directory and no session or pact file.

K4 and K5 are the ones that matter: the substrate must be silent by default and
must not leak into a work tree.

## 6. Files

Revision 1 listed ten and missed nine (O5, O12). This is the fourth slice in
this epic whose Files table was found short, which is itself the argument for
deriving rather than listing.

### 6.1 New

| File | Purpose |
| --- | --- |
| `explanation/cadence-discipline.md` | the one page (§2.1), mirroring `decision-discipline-triad.md` |
| `tdad_tests/layer0_deterministic/test-cadence-integration.sh` | §5 |

### 6.2 The `PreToolUse` correction — three surfaces

| File | Why |
| --- | --- |
| `ai-literacy-superpowers/hooks/hooks.json` | its **description field** says `PreToolUse` while the same file registers `PostToolUse`. The shipped artefact, not its docs |
| `README.md` (:323 prose, :428 diagram) | the first surface anyone reads, wrong twice |
| `reference/hooks.md` | the `## PostToolUse Hooks` section, the two missing hooks, `## Libraries` for the advisory rail, and the `## Configuration` section that still describes only `PreToolUse` and `Stop` arrays |

### 6.3 The rung/reach correction — eight pages

`explanation/progressive-hardening.md` (the full treatment, plus its
three-rungs-four-values mismatch), then a corrected sentence in
`explanation/constraints-and-enforcement.md`,
`explanation/understand-harness-engineering.md`,
`explanation/harness-engineering.md`, `explanation/fitness-functions.md`,
`how-to/add-a-constraint.md`, `tutorials/harness-from-scratch.md`,
`tutorials/getting-started.md`, and `docs/plugins/.../index.md`.

### 6.4 Everything else

| File | Purpose |
| --- | --- |
| `explanation/sentinels.md` | the cadence-discipline name, the **broken table at :115**, and "five roster agents" at :198 |
| `reference/harness-md-format.md` | the `## Stakeholders` section (§2.3) |
| `docs/plugins/ai-literacy-superpowers/index.md` | its **hand-maintained** Concepts list, already short by three before this slice adds one |
| the four how-to guides | backlinks to the new page, per the `watching-the-verifier` ↔ `watch-your-cognitive-reservoir` pattern |
| every explanation page covering a sentinel | a `sentinels:` frontmatter key (§8) |

### 6.5 Version surfaces

`plugin.json`, the README badge, the README plugin-table cell, the CHANGELOG
heading, `marketplace.json` `plugin_version`, `marketplace.json`
`plugins[].version`. Hard CI gates, absent from revision 1's table.

## 7. Non-Goals

- **No rename of `mast`**, or of anything else. §4.1.
- **No marketplace schema change.** §4.2.
- **No keynote link verification.** §3 — blocked, declared, not approximated.
- **No new agent, skill, or command.** Component counts unchanged.
- **No behaviour change anywhere.** S7 is documentation plus one test over
  already-shipped code.
- **No new how-to pages.** All four already exist.
- **No reclassification of `cost-estimator`.** The shipped framing stands
  (§2.5).
- **No four per-sentinel pages.** One discipline page (§2.1).
- **Does not close #497.** §3.2.

## 8. Acceptance Scenarios

### 8.1 The derivation surface D1 needed and did not have

Revision 1 asserted the page count would be "derived from `role: sentinel`
frontmatter rather than pinned". **Half that derivation had no source** (O4):
nine agents carry the tag, but nothing on disk links a sentinel to the page
explaining it — pages are named for concepts (`cadence-governance.md`,
`watching-the-verifier.md`), not agents.

`AGENTS.md:480-501` is explicit that where no on-disk source exists, a pin must
carry a comment saying what makes it change. The cheaper and better option is to
**create the missing relation**: every explanation page covering a sentinel
gains a frontmatter key naming which.

```yaml
---
title: The decision-discipline triad
sentinels: [carpaccio, advocatus-diaboli, choice-cartographer]
---
```

Coverage is then derivable from both ends, and `test-sentinel-docs-coverage.sh`
checks it.

- **D1** — every agent with `role: sentinel` is named by at least one page's
  `sentinels:` key, and every name in a `sentinels:` key is a real sentinel.
  Both sides derived; no literal count anywhere.
- **D2** — `reference/hooks.md`'s event sections document exactly the hooks
  `hooks.json` registers, each under its registered event. Derived by parsing
  both. The advisory rail is outside the event sections and outside the count.
- **D3** — **no file in the repo** describes the constraint gate as a
  `PreToolUse` hook — not `hooks.json`, not `README.md`, not any page. Revision
  1 scoped this to "no page", which the planned fix satisfied by construction.
- **D4** — `harness-md-format.md` documents `## Stakeholders`.
- **D5** — every page teaching the enforcement ladder distinguishes rung from
  reach, and none names a rung outside the enum.
- **K1–K5** — §5.3.
- Docs build clean under `--strict`, and the new page is reachable from
  `index.md`.

## 9. Rollout

**Patch bump, 0.73.0 → 0.73.1.** Revision 1 said 0.74.0 while §7 said "no
behaviour change anywhere", and both could not hold (O12). With the
`cost-estimator` reclassification dropped (§2.5), nothing behaves differently —
the only plugin file touched is `hooks.json`'s description, a documentation
correction. `CLAUDE.md` makes that a patch.

Five CI-checked version locations plus the README plugin-table cell.

**Component counts unchanged**: 41 skills, 20 agents, 32 commands.

Closes **#513**. **#497 stays open** (§3.2), with a comment recording what
shipped. **#514** carries the provenance gap.
