---
name: reservoir-warden
description: Spec for the depletable-collaborator agent — a read-only, advisory watch on the human verifier the harness cannot verify
date: 2026-06-13
status: draft
---

# Reservoir Warden — Watching the Verifier

## Problem

### 1. The harness verifies the output; nothing verifies the verifier

Every enforcement mechanism in the plugin — commit/PR constraints,
mutation tests, convention-drift GC, the advocatus diaboli — checks the
*output* of an agentic session. None of them checks the state of the
human who approves that output. A green checkmark at 09:00 and a green
checkmark at 21:00 are the same colour and carry the same authority in
the merge log, but they were not necessarily produced by the same
quality of verification. The faculty that says *yes, this belongs in our
system* runs on a finite human and is unobserved by the harness that
trusts it.

### 2. The instrument that would detect depletion is itself depleted

The intuitive control — "stop when you feel tired" — fails, because the
metacognition that would notice the fatigue draws on the same capacity
being spent. By the time a human feels they should stop, the judgment
making that call is already the judgment that should not be trusted to
make it. This conclusion does not depend on any contested "willpower
reservoir" model (see Intellectual Foundations); it follows from the
robust time-on-task vigilance decrement plus the well-documented
unreliability of self-assessment under fatigue. The corrective must
therefore be **external and count/time-based**, not judgment-based.

### 3. Parallel orchestration hides its own cost

The plugin actively encourages multi-agent orchestration. The literature
on attention residue and task-switching cost says that switching between
unfinished work streams leaves residual cognitive activation that
degrades the next decision — and that the cost scales with the
*switching*, not merely the agent count. An orchestrator running many
streams accumulates this cost invisibly while producing impressive
activity metrics. The harness currently celebrates the metrics and is
silent on the cost.

## Approach

A read-only **observability-and-advice loop on the human**, surfaced two
ways: a Stop-hook advisory that fires automatically at session end, and
an on-demand `reservoir-warden` agent that gives a fuller read via
`/reservoir`.

The mechanism counts only **observable proxies** — continuous session
span, approval-like event volume, distinct streams touched, wall-clock
hour — and never claims to measure cognitive state. Every statement it
emits carries a confidence flag (`observed` / `inferred` / `asked`,
reusing the framework's existing confidence vocabulary). Counts are
`observed`; risk is `inferred` and always defeasible; anything about the
human (chronotype, whether breaks were real rest) is `asked` and never
assumed.

It is **advisory only**. It has no Write/Edit tools by design, never
blocks a commit/merge/session, never persists a record about the human's
state, and never combines proxies into a single "fatigue score" — that
would manufacture precision the inputs cannot support. When a time/count
threshold is crossed it offers exactly one recommendation, grounded in
the one firm principle below, and then goes silent.

The mechanism is **opt-in per project** via a `Cognitive reservoir` block
in HARNESS.md, which also serves as the marker the Stop hook greps for.
It is deliberately **not** modelled as a Constraint: constraints are
gates with a scope that can fail CI, and wiring a human-state advisory
into a blocking gate would both defeat its purpose and overclaim a
measurement the proxies cannot support.

### The one firm principle

When a threshold is crossed, the warden surfaces the proxies and the
inferred risk with caveats, then offers the article's only
non-negotiable move:

> Decide your stop **before the next session begins**, while the judgment
> making the decision is still the kind you would trust. Do not negotiate
> the boundary with your tired self.

It then offers a concrete, time-boxed option (e.g. "re-review today's
last two approvals tomorrow morning on a full reservoir") and stops. No
lecture, no second nudge, no score.

## Intellectual Foundations

The source is the *Twentieth Watt* essay (softwareenchiridion.com) and
Epictetus: the governance of one's own cognitive state is the one thing
the framework cannot do for the engineer — the *prohairesis*, the
capacity for reasoned choice, remains theirs. The warden watches; it
never chooses for them.

The scientific grounding is deliberately conservative, and this honesty
is itself a hard requirement (FR-009), not editorial flavour. The
popular "decision fatigue" narrative rests on two contested pillars that
this spec **does not assert as fact**:

- **Ego depletion** — the strong "willpower is a finite resource that
  drains with use" model (Baumeister). The 2016 multi-lab Registered
  Replication Report (Hagger et al., 23 labs, N ≈ 2,141) found
  d = 0.04 with a 95% CI crossing zero. "The reservoir empties" is a
  useful metaphor, not a measured mechanism.
- **The hungry-judges study** (Danziger, Levav & Avnaim-Pesso, 2011).
  Its headline result depends on random case ordering, challenged by
  Weinshall-Margel & Shapard (2011) — unrepresented prisoners were
  typically heard last — and Glöckner (2016) showed the magnitude, if
  real, was overestimated. The "65% → near 0%" figure must not be quoted
  as established.

What the design stands on instead, all robust:

- **Task-switching cost / attention residue** (Leroy, 2009, on a deep
  task-switching literature) — the real basis for the context-switch
  proxy.
- **Circadian / time-of-day variation** — the daily performance curve
  (sleep inertia, late-morning peak, post-lunch dip, evening decline) is
  well established but **strongly chronotype-dependent**, which is why the
  late-hour band is unverified-by-default rather than assumed.
- **Vigilance decrement** — sustained time-on-task reliably degrades
  performance; the basis for the session-span proxy.
- **Ericsson's deliberate-practice ceiling** — expert sustained deep work
  converges around 4–5 hours/day; corroborating context for the span
  threshold default, cited as suggestive rather than prescriptive.

Every output of the mechanism is therefore framed as a **precaution
under uncertainty**, never a diagnosis.

## Acceptance Scenarios

### Scenario A — Long session crosses a threshold (hook)

**Given** a project whose HARNESS.md contains a `Cognitive reservoir`
block, and a git history showing a continuous activity span ≥ the
configured session-span threshold within the window,
**When** the Stop hook `reservoir-check.sh` runs at session end,
**Then** it emits a single `{"systemMessage": ...}` JSON advisory that
(a) states the crossed threshold(s) as `observed` counts, (b) frames the
risk as `inferred` and a precaution under uncertainty, (c) names the
robust basis (time-on-task / switching cost) and does **not** assert ego
depletion or the hungry-judges figure, and (d) restates the
decide-your-stop-first principle and that the choice to continue is the
human's.

### Scenario B — Quiet session stays silent (hook)

**Given** the same opt-in project but a session with activity below all
thresholds,
**When** the Stop hook runs,
**Then** it produces no output and exits 0 — no manufactured concern.

### Scenario C — Not opted in (hook)

**Given** a project whose HARNESS.md has no `Cognitive reservoir` block
(or no HARNESS.md, or no git repo),
**When** the Stop hook runs,
**Then** it exits 0 silently and changes nothing.

### Scenario D — On-demand read (agent)

**Given** a user invokes `/reservoir` mid-session,
**When** the `reservoir-warden` agent runs,
**Then** it reads the `cognitive-reservoir` skill first, reports each
proxy with an `observed`/`inferred`/`asked` flag, evaluates thresholds,
and — if any is crossed — gives the single recommendation; and its report
contains **no** combined fatigue score and **no** `inferred` claim that
lacks an `observed` proxy beneath it.

### Scenario E — Chronotype honesty (agent + hook)

**Given** no `chronotype` is declared in the HARNESS.md block,
**When** the current wall-clock hour falls in the naive late band,
**Then** the late-hour signal is marked `asked` / unverified rather than
asserted as depletion; **and** when a `chronotype` *is* declared, the
band is labelled (optimal / dip / suboptimal) accordingly.

### Scenario F — Read-only trust boundary (agent)

**Given** the `reservoir-warden` agent definition,
**When** its frontmatter `tools` list is inspected,
**Then** it contains no `Write` or `Edit` tool, and the agent writes no
file recording the human's state anywhere in its process.

## Functional Requirements

- **FR-001** A `cognitive-reservoir` skill SHALL define the observable
  proxies, the confidence-flag discipline, the default thresholds, the
  six-level scaling guidance, and the honesty rule; the agent and hook
  SHALL inherit grounding from it rather than re-deriving it.
- **FR-002** A `reservoir-warden` agent SHALL gather proxies via Bash
  (git/date) and Grep only, report each with `observed`/`inferred`/
  `asked`, and produce the report format in the skill.
- **FR-003** The agent's `tools` SHALL be exactly `Read, Glob, Grep,
  Bash` — no `Write`, no `Edit`.
- **FR-004** A Stop hook `reservoir-check.sh` SHALL compute span,
  decision volume, context switches, and wall-clock hour from the last
  `WINDOW_HOURS` (default 8) of git activity, and emit at most one
  advisory.
- **FR-005** The hook SHALL be advisory-only: it never exits non-zero on
  a triggered or untriggered path, never blocks, and outputs only the
  `{"systemMessage": "..."}` JSON contract when triggered.
- **FR-006** The hook SHALL self-gate: silent exit 0 unless HARNESS.md
  contains a case-insensitive `Cognitive reservoir` marker and the
  directory is a git repo.
- **FR-007** The hook SHALL use `set -euo pipefail`; best-effort proxy
  pipelines that legitimately match nothing (e.g. branch-switch reflog
  parsing on a single-branch session) SHALL degrade to 0 without
  aborting the script.
- **FR-008** Thresholds SHALL be disjunctive (any one crossing fires the
  advisory) and tunable in the HARNESS.md block; defaults: span 180 min,
  decision volume 8, context switches 4, window 8 h.
- **FR-009** No artefact SHALL assert ego depletion or the hungry-judges
  magnitude as established fact; the contested/robust distinction SHALL
  be visible in the skill, and the agent/hook copy SHALL frame triggers
  as precaution under uncertainty.
- **FR-010** The late-hour circadian band SHALL be applied only when a
  `chronotype` is declared in the HARNESS.md block; otherwise the band is
  reported as `asked`/unverified.
- **FR-011** The mechanism SHALL NOT be modelled as a Constraint and
  SHALL NOT be wired into any CI gate; it lives in its own HARNESS.md
  block. No artefact SHALL persist a record of the human's claimed state,
  breaks, or chronotype to disk (the human edits HARNESS.md themselves).
- **FR-012** A `/reservoir` command SHALL offer a Read mode (dispatch the
  agent) and a Tune mode (help the human edit the HARNESS.md block,
  including declaring a chronotype), proposing edits for the human to
  confirm.

## Expected Outcome

A project that opts in receives, at session end, an occasional honest
advisory that names what it can see and is candid about what it cannot —
and can ask for a fuller read any time via `/reservoir`. The quality bar
is not whether the warden fires often; it is whether, when it fires, it
tells the truth about its own confidence and leaves the choice with the
engineer. A cluster of advisories the human routinely ignores is a signal
to tune the HARNESS.md thresholds, not to weaken the honesty rule.

The deeper outcome is that the framework finally observes the one actor
it has always trusted blindly: the verifier. It does so without
pretending to a precision it lacks, which is itself the framework's
honest-confidence principle applied reflexively to the framework.

## Artefacts

1. `skills/cognitive-reservoir/SKILL.md` — proxies, confidence-flag
   discipline, default thresholds, honesty rule, six-level scaling,
   anti-patterns (FR-001, FR-009).
2. `agents/reservoir-warden.agent.md` — read-only agent (tools: Read,
   Glob, Grep, Bash), proxy-gathering process, report schema (FR-002,
   FR-003).
3. `commands/reservoir.md` — `/reservoir` Read + Tune modes (FR-012).
4. `.github/prompts/reservoir.prompt.md` — Copilot CLI equivalent.
5. `hooks/scripts/reservoir-check.sh` — Stop-hook advisory, `chmod +x`,
   `set -euo pipefail`, self-gating, JSON `systemMessage` contract
   (FR-004 – FR-008, FR-010).
6. `hooks/hooks.json` — register `reservoir-check.sh` in the `Stop`
   array (timeout 10).
7. `templates/HARNESS.md` — add an (optional, commented) `Cognitive
   reservoir` block for new projects, including the `chronotype` field
   and the not-a-constraint note (FR-011).
8. TDAD scenarios derived from the acceptance scenarios above:
   `tdad_tests/scenarios/agents/reservoir-warden/read-only-boundary.md`
   (Scenario F), `.../hooks/reservoir-check/fires-on-long-session.md`
   (A), `.../hooks/reservoir-check/silent-when-quiet.md` (B),
   `.../hooks/reservoir-check/silent-when-not-opted-in.md` (C) — per the
   "new components ship with a TDAD scenario" constraint.
9. `docs/plugins/ai-literacy-superpowers/` — a reference page and an
   explanation page (per the reference-page-entry and docs-propagation
   constraints).
10. `MODEL_ROUTING.md` — route `reservoir-warden` to an inexpensive tier
    (it counts and advises; no deep reasoning needed).
11. `README.md`, `plugin.json`, `marketplace.json`, `CHANGELOG.md` —
    version 0.48.0; counts Agents 15 → 16, Skills 34 → 35,
    Commands 27 → 28.
12. `AGENTS.md` — ARCH_DECISION: the verifier-watch is advisory-only and
    never a gate; record the rationale so a future contributor does not
    "promote" it into CI.

## Exemptions

None. The mechanism is opt-in by construction — a project that does not
add the `Cognitive reservoir` block to its HARNESS.md is unaffected, so
no pre-existing-work exemption is required. Naming is provisional:
`reservoir-warden` (a warden watches but does not control, mirroring the
read-only-on-the-human discipline); `twentieth-watt` and
`sustainable-pace` are register-faithful alternatives, a find-replace
across artefacts 1–7 if preferred.
