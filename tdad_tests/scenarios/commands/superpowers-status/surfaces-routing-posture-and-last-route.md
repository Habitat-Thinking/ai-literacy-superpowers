---
component: superpowers-status
component_type: command
tier: structural
---

# Scenario: superpowers-status surfaces routing posture and the last route taken (AC-10 / FR-9)

## Given

The file
`ai-literacy-superpowers/commands/superpowers-status.md`.

## When

The command doc is read.

## Then

- The dashboard documents a **workflow-routing** surface (a section or check)
  that reports the routing **posture** — read from the `orchestrator-routing`
  `HARNESS.md` field: **`opt-in, off by default`** when absent/off, vs
  **`enabled`** when set. Keep "opt-in" and "off by default" each
  **unwrapped**; the content test asserts "routing" co-occurring with
  "opt-in" and ("off by default" via "off" + "default") and "enabled".
- The surface also reports the **most-recent route taken** when a durable
  trace exists (static / tournament / root-cause / triage), degrading to
  **`unavailable`** when no durable trace exists. Keep "last route" and
  "unavailable" each **unwrapped**; the content test asserts "route"
  co-occurring with "unavailable" (the honest degrade) and the four route
  names.

## Rubric

Deterministic structural assertion (AC-10, §6 decision 3 / option S1). The
dashboard is a **read-only health snapshot** of files on disk — it has no
live event stream of orchestrator dispatches — so the surface must be honest
about what it can read. It reports **posture** from the decision-1
`orchestrator-routing` `HARNESS.md` field (reusing that field rather than
inventing a persisted counter) **plus** the most-recent route when a durable
trace exists, degrading to `unavailable` otherwise. The surface stays
**descriptive — no threshold, no `WARNING` state** (the AGENTS.md "no
threshold before data" decision). This is a file-read declaration check, not
a live-dispatch property.

## Evaluation

Evaluated deterministically by
`tests/test_s5_orchestrator_routing_structural.py`
(`TestS5SuperpowersStatusRouteSurface`). RED now: `superpowers-status.md`
does not yet document any workflow-routing posture / last-route surface
(`grep -n "orchestrator-routing\|workflow routing"` returns nothing).
