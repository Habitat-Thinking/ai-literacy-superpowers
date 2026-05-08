---
title: The Harness Tuning Loop
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 18
redirect_from:
  - /explanation/the-harness-tuning-loop/
  - /explanation/the-harness-tuning-loop.html
---

# The Harness Tuning Loop

A harness that cannot be tuned is a harness that calcifies. The loop on this page is what keeps it alive: a single recurring path that takes one operational surprise and converts it -- through six stages -- into a tightened policy and the enforcement surfaces that carry that policy. The simple version is that `REFLECTION_LOG.md` is the input, the GC agent is the watcher, `HARNESS.md` is the policy, and `AGENTS.md` / hooks / CI are the downstream surfaces that get re-tuned when the policy changes.

Every other Explanation page in this section cuts the harness on a different axis: [The Loops That Learn](the-loops-that-learn.md) cuts it as **four cadences**, [Three Enforcement Loops](three-enforcement-loops.md) cuts it as **three timescales**, [The Self-Improving Harness](self-improving-harness.md) cuts it as **the reflection mechanism**, [Garbage Collection](garbage-collection.md) cuts it as **entropy detection**. This page is the integrative cut: one surprise, walked end to end through every surface it touches, with the concrete plumbing -- commands, skills, agents, hooks, workflows -- named at each stage.

---

## A worked example, to make this concrete

A developer is mid-session. The AI suggests adding a dependency the project already uses elsewhere, and the developer accepts it. A CVE check on the next CI run flags the version as having a known high-severity vulnerability. The merge is blocked, the dependency is downgraded, work continues.

That is the **surprise**. The page traces it through all six stages: from the moment the developer captures it as a reflection, to the moment a constraint that prevents the same surprise from recurring is wired into the commit hook, the PR pipeline, and the convention files that every AI assistant reads at session start. By the end, the surprise stops being a surprise.

---

## The shape of one full turn

A complete turn of the loop has six stages. The first five form the per-surprise path; the sixth is the wider tuning frame that catches what the per-surprise path misses.

| Stage | What happens | Where |
| --- | --- | --- |
| 1. Capture | Surprise is recorded against a structured template | `REFLECTION_LOG.md` |
| 2. Detect | Recurring patterns are found and reported as proposals | GitHub issues |
| 3. Promote | A human accepts a proposal and writes the constraint | `HARNESS.md` |
| 4. Verify | The audit confirms the constraint is honest | `HARNESS.md` Status |
| 5. Propagate | The new policy reaches the surfaces that enforce it | AGENTS.md / hooks / CI |
| 6. Tune | Quarterly re-assessment surfaces gaps the loop did not catch | Assessment, governance |

Two design choices govern the whole sequence:

- **The trust boundary is between detection and writing.** Every read-write agent in the loop is allowed to **report** changes to `HARNESS.md` (as issues, as audit findings, as proposals). None is allowed to **write** them. The promotion step is a human-cognition gate, by design.
- **Reports nudge; constraints stop.** Only one of the surfaces in this loop has the authority to block work, and it is not the one that detects drift. The asymmetry is what makes the whole thing safe to leave running.

The rest of the page walks through each stage with the worked example threaded in italic.

---

## Stage 1 — Capture the surprise

The only entry point to the steady-state loop is the `/reflect` command. There are no agents, no skills loaded, no scans of the codebase. Three questions, one appended entry, a signal-type classification, and -- sometimes -- an immediate constraint proposal there and then.

The questions are deliberately blunt: *what were you working on, what was surprising, what should future agents know?* The answers land in `REFLECTION_LOG.md` as a structured entry with seven fields (date, agent, task, surprise, proposal, improvement, signal, constraint). The append-only structure matters: entries are never modified, never deleted. The file becomes the operational record of every surprise the team has registered.

The signal classification (`context | instruction | workflow | failure | none`) is the routing hint: failures route to constraints, context signals route to `HARNESS.md`, workflow signals route to `AGENTS.md`, instruction signals route to skills or commands. See [The Self-Improving Harness](self-improving-harness.md#the-reflection-mechanism) for the full taxonomy.

Sometimes the surprise is clearly a preventable failure -- a check that should have run, a tool that should have caught it -- and `/reflect` proposes a constraint immediately, offering it to the user for acceptance. Often the surprise looks one-off and just gets logged. Both outcomes are correct. A reflection that does not propose a constraint is not a wasted reflection; it is a data point that may matter only when a second one joins it.

> *Worked example.* The developer runs `/reflect`. The surprise field reads: "agent imported lodash@4.17.20 which has a known CVE; CI caught it but not before merge was attempted." `/reflect` classifies this as a `failure` signal. It drafts a constraint proposal: "Block merges that introduce dependencies with known CVEs." The developer hesitates -- they think this is a one-off -- and declines the immediate promotion. The reflection is logged with `Constraint: none`.

---

## Stage 2 — Detect recurring patterns

The garbage collector watches reflections accumulate. The specific GC rule that closes this loop is **reflection-driven regression detection**: it reads `REFLECTION_LOG.md`, looks for the same kind of surprise appearing across two or more entries without a corresponding constraint in `HARNESS.md`, and when it spots one it files a GitHub issue with evidence (reflection dates and quotes), a suggested enforcement type, and a suggested scope.

The rule runs weekly under `/harness-gc`, executed either on schedule (the `gc.yml` workflow) or on demand. The agent that runs it is `harness-gc`, supported by the [garbage-collection](garbage-collection.md) skill. The agent is also reflection-aware in general: by design it reads recent `REFLECTION_LOG` entries before running any of its other rules, so reflections shape what it looks for beyond the declared rules. See [Garbage Collection](garbage-collection.md#the-gc-agent) for the full mechanics.

Crucially, the GC agent **cannot write to `HARNESS.md`**. That is the trust boundary. It produces reports -- GitHub issues, summary outputs -- and nothing more. Humans decide what gets promoted.

Adjacent GC rules touch the loop's other surfaces during the same agent run: `documentation freshness`, `command-prompt sync`, `convention file sync`, `secret scanner operational`, `snapshot staleness`, `dependency currency`. Together they catch drift across all the surfaces the per-surprise loop will eventually touch.

> *Worked example.* Two weeks later, a different developer trips over the same problem: a different dependency this time, but the same shape of surprise. They `/reflect`, the entry lands. The next Monday's `/harness-gc` run reads the log, spots two `failure` reflections about CVE-bearing dependencies with no matching constraint in `HARNESS.md`, and files a GitHub issue. The issue cites both reflection dates, quotes the surprise text, and proposes: "deterministic constraint, scope=pr, tool=osv-scanner."

---

## Stage 3 — Promote a proposal into HARNESS.md

This is the only stage that writes new constraints into `HARNESS.md`, and it is deliberately interactive. No agent can bypass the human here. The command is `/harness-constrain`, supported by the [constraint-design](constraints-and-enforcement.md) and [verification-slots](../how-to/set-up-verification-slots.md) skills. No agents are dispatched.

The interaction has two responsibilities. The first is to write the constraint into `HARNESS.md` in the canonical five-field format (rule, frequency, enforcement, tool, auto-fix). The second, when deterministic enforcement is selected, is to **configure the verification slot** -- the integration point that wires the named tool to the harness's enforcement engine. A constraint without a wired slot is a claim, not a check.

The human-cognition gate is load-bearing. The GC agent's proposal might be wrong about scope. It might propose deterministic enforcement when the rule actually needs agent judgement. It might be a real pattern but not yet worth the cost of enforcement. The human is the filter that converts a proposal into a policy.

> *Worked example.* The team triages the issue at their next planning session. They agree the surprise is real and recurring. A developer runs `/harness-constrain`, accepts the suggested rule, picks `enforcement: deterministic`, names `osv-scanner` as the tool, and sets `scope: pr`. The verification slot is configured to invoke `osv-scanner --recursive .` on every PR. The constraint lands in `HARNESS.md` under the appropriate section.

---

## Stage 4 — Verify HARNESS.md is still honest

A new constraint is a claim about reality. The audit step is what tests the claim. The commands are `/harness-audit` (full meta-verification) with the lighter alternatives `/harness-status` (no agents, fast) and `/harness-health --deep`. The agents are `harness-discoverer` (read-only scanner that finds enforcement in the wild) and `harness-auditor` (read-write meta-agent that compares declared against actual).

The audit detects drift in **both directions**: declared-but-not-enforced (a constraint exists in `HARNESS.md` but the tool is missing from CI) and enforcement-present-but-not-declared (a linter is running in CI but is not listed as a constraint). Both directions represent a gap between what the team believes is true and what is actually true.

The auditor is the **only** agent permitted to update the Status section of `HARNESS.md`. Nothing else writes there. The Status section is the audit's product, and keeping its authorship narrow is what prevents it from becoming a free-form scratchpad.

> *Worked example.* The developer runs `/harness-audit`. The auditor confirms `osv-scanner` is installed in CI, the verification slot is wired, the PR workflow invokes it, and the constraint's status flips from `proposed` to `verified-deterministic`. The Status section is updated. The new constraint is now part of the harness's verified surface area.

---

## Stage 5 — Propagate the change to the enforcement surfaces

`HARNESS.md` is the source of truth, but the surfaces that actually enforce behaviour live elsewhere. A constraint that exists only in `HARNESS.md` does not yet shape what agents see at session start, what hooks fire at edit time, or what CI gates a pull request. Stage 5 is the propagation step that pushes the new policy out to those three surfaces and, just as importantly, the GC rules that keep those surfaces in step with `HARNESS.md` over time.

### 5a — AGENTS.md / CLAUDE.md (turn-time context)

This is what the AI sees at session start. The relevant commands are `/extract-conventions` (when a new tacit convention surfaces through the cycle, supported by the convention-extraction skill), `/convention-sync` (which generates Cursor / Copilot / Windsurf rule files from `HARNESS.md`), and `/harness-onboarding` (which regenerates `ONBOARDING.md` from `HARNESS.md` + `AGENTS.md` + `REFLECTION_LOG.md`). The unified entry point that runs `/convention-sync` and `/harness-onboarding` together in one interactive pass — detecting drift across all push-direction surfaces, presenting the full picture, applying the user's selected fixes — is `/harness-sync`. See [Sync Harness Surfaces](../how-to/sync-harness.md). The single-surface commands remain available for focused work.

The GC rules that catch lag on this surface are `convention file sync` (weekly, agent-enforced), `command-prompt sync` (weekly, agent-enforced), and the monthly `ONBOARDING.md` staleness check. Together they ensure that when `HARNESS.md` changes, the convention files every AI assistant reads do not silently fall behind.

### 5b — Hooks (edit-time and session-end)

There is no dedicated slash command for hooks. They are configured at install time via the [harness-engineering](harness-engineering.md) skill and inventoried by `/harness-affordance discover`. The steady-state moving part is the **rotating Stop hook**: each session it picks one deterministic GC rule by day-of-year and runs it as a sub-five-second advisory check. Over a working week, every deterministic rule is checked at least once, even if scheduled CI does not run.

The `SessionStart` hook is what surfaces `/harness-upgrade` prompts when template versions move, which is how new template-shipped GC rules and constraints reach existing harnesses without anyone having to remember to look.

### 5c — CI/CD (PR-time and scheduled)

There is no per-change command for CI propagation either. The constraint format itself declares scope (`commit | pr | scheduled`) and the CI workflow templates pick that up. The agent is `harness-enforcer` (read-only), the unified verification engine that CI dispatches -- the same agent runs both deterministic tools and agent-based reviews, so the CI surface treats all constraint outcomes uniformly.

The `gc.yml` workflow runs deterministic GC rules weekly (Monday 09:00 UTC, plus `workflow_dispatch`). PR-scoped constraints fire on every pull request. Scheduled constraints fire on their declared cadence.

The combination of all three surfaces -- session-start context, edit-time hooks, PR-time CI -- is what gives a single new constraint multiple chances to catch a future surprise before it lands.

> *Worked example.* The next time `/convention-sync` runs, Cursor's rule file gains a new line about CVE-bearing dependencies; Copilot's instructions file gains the same; Windsurf's rules pick it up. The next CI run on a feature branch invokes `osv-scanner` and blocks a PR that includes a vulnerable transitive dependency. The rotating Stop hook may run `secret scanner operational` or `documentation freshness` on any given session, but `dependency currency` is now in its rotation too. Three surfaces, one constraint, multiple chances to catch the next CVE before it merges.

---

## Stage 6 — The wider tuning frame

Two commands sit one level out from the per-surprise loop and tune at quarterly cadence. They catch what the per-surprise path misses: gaps that no individual surprise has surfaced yet, or governance constraints that have drifted in meaning rather than in enforcement.

`/assess` (supported by the [ai-literacy-assessment](../how-to/run-an-assessment.md) skill, dispatching the `assessor` agent) reassesses the literacy level, surfaces gaps, and produces an improvement plan that may itself add constraints, hooks, or CI workflows. It is the loop's check on its own progress: are we catching surprises faster, are recurring patterns getting promoted, are constraints getting tighter over time.

`/governance-audit` (supported by the [governance-audit-practice](../how-to/run-a-governance-audit.md) and [governance-observability](../how-to/build-a-governance-dashboard.md) skills, dispatching the `governance-auditor` agent) does the same job for governance constraints specifically, with semantic-drift detection. Its trust boundary mirrors `harness-gc`: it writes audit reports, never modifies `HARNESS.md` directly.

These commands sit outside the per-surprise loop because they answer different questions. The per-surprise loop asks "did anything surprising happen?" The quarterly frame asks "are we still working on the right things?"

> *Worked example.* At the next quarterly `/assess`, the assessor finds the new CVE constraint, sees it has fired three times in the past 90 days (caught three real vulnerabilities, blocked three PRs), and notes that the gap that produced it is now closed. The assessment record updates accordingly. The improvement plan moves on to the next gap.

---

## The asymmetry that makes the loop work

It is worth keeping in plain sight the asymmetry that makes the whole thing safe to operate continuously: **GC produces reports, not blocks**.

Every other part of the harness prevents bad changes. Constraints block merges. Hooks block commits. CI gates block PRs. Each of those surfaces has the authority to stop work, and each is appropriate to that authority because it is evaluating a specific change made by a specific person, where the fix is usually within that person's control.

GC is different. The drift it detects -- stale documentation, lagging convention files, a `gitleaks` binary that has quietly disappeared from CI, the same surprise appearing in three reflections -- was not caused by any single person or any single change. Blocking on a finding that accumulated over weeks or months would penalise whoever happens to trigger the check, not the people who contributed to the drift. That creates exactly the wrong incentive: teams learn to avoid running GC rather than fixing what it finds.

So GC describes drift. Humans decide. Constraints stop. Reports nudge. Continuous tuning needs both, in the right places.

This is also the reason the trust boundaries in stages 2 and 6 matter. The agents that detect patterns and audit governance can write everywhere except `HARNESS.md` itself, because writing constraints is the one place in the loop where blocking authority is created. Keeping that authority in human hands is what keeps the loop honest.

---

## What the loop earns over time

A team that runs the loop for six months has a `HARNESS.md` that is no longer a record of what they thought was important when the project started. It is a record of what their operational experience has taught them is worth enforcing -- evidence-backed, audited, and propagated through every surface that shapes what their AI does next.

A team that does not run the loop has the same `HARNESS.md` they had on day one. The reflections they did not capture do not exist. The patterns they did not detect do not get proposed. The constraints they did not promote do not block the surprises that recur. The harness still appears to operate, but it has stopped tuning.

The infrastructure is not the product. The loop is the product. Every component on this page exists to make one full turn of the loop possible without imposing a cost the team cannot pay -- two minutes for `/reflect`, weekly automated GC, an interactive `/harness-constrain` when a real pattern emerges, and the propagation surfaces that pick up the change without anyone having to remember to update them by hand.

---

## Further reading

- [The Self-Improving Harness](self-improving-harness.md) -- the deeper read on the reflection mechanism, including agent reading windows and the auto-constraint pipeline
- [Garbage Collection](garbage-collection.md) -- the mechanics of GC rules, the GC agent's trust boundary, and the rules that propagate to surfaces 5a/5b/5c
- [The Loops That Learn](the-loops-that-learn.md) -- the four-cadence cut: reflect, health, assess, cost
- [Three Enforcement Loops](three-enforcement-loops.md) -- the timescale cut: inner (edit time, advisory), middle (PR time, blocking), outer (scheduled, investigative)
- [Compound Learning](compound-learning.md) -- the introductory framing of why captured learnings compound, and why uncaptured ones do not
- [Constraints and Enforcement](constraints-and-enforcement.md) -- the anatomy of a constraint and the enforcement types referenced in stage 3
- [Regression Detection](regression-detection.md) -- the related-but-distinct sense of regression: broken practices rather than recurring surprises
