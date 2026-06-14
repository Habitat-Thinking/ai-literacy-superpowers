---
name: cognitive-reservoir
description: Use when watching the human verifier rather than the output — defines the observable proxies, the observed/inferred/asked confidence discipline, the default thresholds, the one firm principle, six-level scaling, and the honesty rule that the reservoir-warden agent and the reservoir-check Stop hook both inherit
---

# Cognitive Reservoir

You are watching the one actor the harness has always trusted blindly:
the human who says *yes, this belongs in our system*. Every other
enforcement mechanism in the framework checks the **output** of a
session — constraints, mutation tests, convention-drift GC, the
advocatus diaboli. None checks the **state of the verifier** who
approves that output. A green checkmark at 09:00 and a green checkmark
at 21:00 are the same colour in the merge log and carry the same
authority, but they were not necessarily produced by the same quality
of verification.

This skill is the shared grounding for two surfaces:

- the **`reservoir-check.sh` Stop hook** — fires automatically at
  session end and emits at most one advisory;
- the **`reservoir-warden` agent** — gives a fuller on-demand read via
  `/reservoir`.

Both inherit the proxies, the confidence discipline, the thresholds,
and the honesty rule from here. Neither re-derives them.

> The warden watches; it never chooses. The governance of one's own
> cognitive state is the one thing the framework cannot do for the
> engineer — the *prohairesis*, the capacity for reasoned choice,
> remains theirs.

## The instrument problem

The intuitive control — "stop when you feel tired" — fails, because the
metacognition that would notice the fatigue draws on the same capacity
being spent. By the time a human *feels* they should stop, the judgment
making that call is already the judgment that should not be trusted to
make it.

That is why this mechanism is **external and count/time-based**, not
judgment-based. It does not ask the human how they feel; it counts what
it can see and offers a precaution. The conclusion does not rest on any
contested "willpower reservoir" model — it follows from the robust
time-on-task vigilance decrement plus the well-documented unreliability
of self-assessment under fatigue.

## Honesty rule (the hard requirement)

The scientific grounding is deliberately conservative, and this honesty
is a hard requirement (FR-009), **not editorial flavour**. Two contested
pillars of the popular "decision fatigue" narrative MUST NOT be asserted
as established fact by any artefact in this mechanism:

- **Ego depletion** — the strong "willpower is a finite resource that
  drains with use" model (Baumeister). The 2016 multi-lab Registered
  Replication Report (Hagger et al., 23 labs, N ≈ 2,141) found d = 0.04
  with a 95% CI crossing zero. *"The reservoir empties"* is a useful
  **metaphor**, not a measured mechanism. The name of this skill is that
  metaphor; the skill does not claim the mechanism.
- **The hungry-judges study** (Danziger, Levav & Avnaim-Pesso, 2011).
  The headline result depends on random case ordering, challenged by
  Weinshall-Margel & Shapard (2011) — unrepresented prisoners were
  typically heard last — and Glöckner (2016) showed the magnitude, if
  real, was overestimated. The "65% → near 0%" figure MUST NOT be quoted
  as established.

What the design stands on instead — **all robust**:

| Basis | What it is | What it grounds |
| --- | --- | --- |
| **Task-switching cost / attention residue** (Leroy, 2009) | Switching between unfinished streams leaves residual activation that degrades the next decision; cost scales with *switching*, not agent count | the context-switch proxy |
| **Vigilance decrement** | Sustained time-on-task reliably degrades performance | the session-span proxy |
| **Circadian / time-of-day variation** | The daily performance curve (sleep inertia, late-morning peak, post-lunch dip, evening decline) is well established but **strongly chronotype-dependent** | the late-hour band — unverified-by-default |
| **Ericsson's deliberate-practice ceiling** | Expert sustained deep work converges around 4–5 h/day | corroborating context for the span default — *suggestive, not prescriptive* |

Every output of this mechanism is framed as a **precaution under
uncertainty**, never a diagnosis.

## Confidence-flag discipline

Reusing the framework's existing confidence vocabulary, every statement
the mechanism emits carries exactly one flag:

- **`observed`** — counted directly from git/clock. The proxies are
  `observed`. These are facts about activity, not about the human.
- **`inferred`** — risk read off the proxies. Always defeasible. An
  `inferred` claim MUST have an `observed` proxy beneath it; a bare
  `inferred` risk with no count under it is a defect, not a reading.
- **`asked`** — anything about the *human*: chronotype, whether breaks
  were real rest, whether a long span was deep work or idle-with-editor-
  open. Never assumed. If it has not been declared in HARNESS.md, it is
  `asked` / unverified, not asserted.

The mechanism **never combines proxies into a single "fatigue score."**
That would manufacture precision the inputs cannot support. Report each
proxy on its own line with its own flag.

## Observable proxies

Only four, all `observed`, all counted from git and the clock over the
last `WINDOW_HOURS`:

1. **Continuous session span** (minutes) — wall-clock from the first to
   the last commit in the window, where gaps below the idle cut are
   treated as continuous. Grounds in the **vigilance decrement**.
2. **Decision volume** — count of approval-like events in the window
   (commits + merges as the observable proxy for "times the human said
   yes"). Grounds in sustained decision load.
3. **Context switches** — distinct work streams touched: branch
   switches in the reflog, distinct top-level directories touched, or
   distinct branches committed to. Grounds in **task-switching cost /
   attention residue** — the cost scales with the switching.
4. **Wall-clock hour** — the current local hour, mapped to a circadian
   band **only when a `chronotype` is declared**; otherwise reported as
   `asked` / unverified (FR-010).

A proxy that legitimately matches nothing (e.g. reflog branch-switch
parsing on a single-branch session) degrades to **0** — it is not an
error and must not abort the read.

## Default thresholds

Disjunctive — **any one** crossing fires the advisory (FR-008). All
tunable in the HARNESS.md `Cognitive reservoir` block:

| Proxy | Default threshold | HARNESS key |
| --- | --- | --- |
| Continuous session span | **180 min** | `span_minutes` |
| Decision volume | **8** | `decision_volume` |
| Context switches | **4** | `context_switches` |
| Window | **8 h** | `window_hours` |

The span default is corroborated by Ericsson's 4–5 h/day ceiling, cited
as suggestive. Thresholds are a starting point, not a measurement: a
cluster of advisories the human routinely ignores is a signal to **tune
the thresholds**, not to weaken the honesty rule.

## The one firm principle

When a threshold is crossed, surface the proxies and the inferred risk
with caveats, then offer the article's only non-negotiable move:

> Decide your stop **before the next session begins**, while the
> judgment making the decision is still the kind you would trust. Do not
> negotiate the boundary with your tired self.

Then offer exactly **one** concrete, time-boxed option — for example,
*"re-review today's last two approvals tomorrow morning on a full
reservoir"* — and stop. No lecture, no second nudge, no score. The
choice to continue is the human's; say so.

## Report format (agent)

The `reservoir-warden` agent produces this shape. The hook emits a
compressed single-line version of the same content.

```text
## Reservoir read — <local date/time>

Window: last <window_hours> h

| Proxy | Value | Threshold | Flag | Crossed? |
| --- | --- | --- | --- | --- |
| Continuous span | <n> min | 180 min | observed | yes/no |
| Decision volume | <n> | 8 | observed | yes/no |
| Context switches | <n> | 4 | observed | yes/no |
| Wall-clock hour | <hh> (<band or "unverified — no chronotype declared">) | — | asked | — |

Inferred risk (defeasible): <one or two sentences, each tied to a
crossed proxy above and named to its robust basis — time-on-task or
switching cost; never ego depletion, never the hungry-judges figure>.

[If any threshold crossed:]
Recommendation: <the one firm principle, then one concrete time-boxed option>.

The choice to continue is yours.
```

If **no** threshold is crossed, the agent says so plainly and adds no
manufactured concern.

## Six-level scaling

How heavily a team leans on the warden tracks AI-literacy maturity. The
mechanism is the same at every level; what changes is how it is used.

| Level | Posture toward the warden |
| --- | --- |
| **0 — Awareness** | Not yet relevant — no agentic verification load to watch. |
| **1 — Prompting** | Optional. Single-stream work rarely crosses thresholds; the hook stays quiet. |
| **2 — Verification** | The natural entry point. The verifier is now the bottleneck the framework trusts; opt in and let the hook surface long spans. |
| **3 — Habitat Engineering** | Tune thresholds into the HARNESS.md block; declare a chronotype to turn on the circadian band honestly. |
| **4 — Specification Architecture** | Multi-agent orchestration makes the *context-switch* proxy the load-bearing one — switching cost scales with parallel streams. This is the "Depletable Collaborator" signal: spec decomposition accounts for human energy, not just modularity. |
| **5 — Sovereign Engineering** | The warden is one observability surface among many; the team reads its advisories as data and tunes rather than obeys. |

## Anti-patterns

- **A combined fatigue score.** Forbidden. The inputs cannot support it.
- **Asserting ego depletion or the hungry-judges figure as fact.**
  Forbidden (FR-009). Frame as precaution under uncertainty.
- **A bare `inferred` claim** with no `observed` proxy beneath it.
- **Assuming the late-hour band** when no chronotype is declared — it is
  `asked`, not depletion (FR-010).
- **Blocking, persisting, or gating.** The mechanism is advisory-only,
  is not a Constraint, writes no record of the human's state to disk,
  and never fails CI (FR-011). The human edits HARNESS.md themselves.
- **A second nudge.** One advisory, then silence.
- **Manufactured concern on a quiet session.** Below all thresholds →
  say nothing.
