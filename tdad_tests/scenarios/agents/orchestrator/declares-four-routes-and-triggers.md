---
component: orchestrator
component_type: agent
tier: structural
---

# Scenario: the classification step declares all four routes and their triggers (AC-6 / FR-4)

## Given

The task-classification section of
`ai-literacy-superpowers/agents/orchestrator.agent.md`.

## When

The section is read.

## Then

The section declares **all four** routes and their triggers:

- **static** — ordinary coding → the existing static pipeline (the default
  branch, unchanged behaviour). Keep "static pipeline" **unwrapped**.
- **tournament** — design / naming / taste-based decisions → a **tournament
  with a rubric-bearing judge**. Keep "rubric-bearing judge" **unwrapped**
  (the content test asserts "tournament" with "rubric-bearing judge").
- **root-cause** — debugging / flaky-test / incident → **root-cause
  investigation** with **≥3 independent hypotheses from disjoint evidence**
  and a verifier/refuter panel. Keep "root-cause", "disjoint evidence", and
  "hypotheses" each **unwrapped**; the content test asserts "root-cause",
  "hypotheses" (with "3"/"≥3"), "disjoint" + "evidence", and "verif"/
  "refut" as co-occurring tokens.
- **triage** — large backlogs → **triage-at-scale under INV-2 quarantine**.
  Keep "triage" and "low-privilege" **unwrapped**; the content test asserts
  "triage" with "inv-2"/"quarantine".

The section also states any **non-static route adapts the relevant
`*.workflow.js` template by relative path** (ADAPT, not run verbatim).

## Rubric

Deterministic structural shadow of AC-2 / AC-3 (the live route selections,
which are agent-backed and declared in
`runtime-routes-taste-task-to-tournament.md` and
`runtime-routes-incident-to-root-cause.md`). What a file read verifies is
that the doc *declares* the four routes, their triggers, and the
adapt-by-relative-path rule — not that any live dispatch picks them.

The load-bearing specifics, each asserted as wrap-safe co-occurring tokens
so a reasonable line break cannot redden the gate:

- the four route names co-occur with their triggers;
- the root-cause route names the **≥3-disjoint-evidence-hypotheses** +
  **verifier/refuter-panel** shape (the discipline that defeats premature
  single-hypothesis fixation);
- the triage route names **INV-2 quarantine**;
- any non-static route **ADAPTs** an S2 template, never edits or runs it
  verbatim (the "consumer never mutates the contract it consumes" rule).

## Evaluation

Evaluated deterministically by
`tests/test_s5_orchestrator_routing_structural.py`
(`TestS5OrchestratorFourRoutes`). RED now: the classification section does
not exist, so none of the four route names / triggers appear.
