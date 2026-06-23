---
component: orchestrator
component_type: agent
tier: structural
---

# Scenario: the orchestrator declares a classification step, the opt-in flag, and static-is-default (AC-5 / FR-1, FR-2, FR-3)

## Given

The file
`ai-literacy-superpowers/agents/orchestrator.agent.md`.

## When

The agent doc is read.

## Then

- A **task-classification section** is present — a level-2/3/4 heading
  containing "Task classification" or "Workflow routing". The content test
  slices from that heading; everything below is the routing contract.
- The section declares the classification runs **before the pipeline
  dispatches / as the first action** — it is a pre-pipeline step that
  *selects which pipeline runs*, not a new agent in the chain. Keep "first
  action" **unwrapped** on one line (the content test asserts "before" with
  "pipeline", and "first action" as a single phrase).
- The section names the **explicit opt-in flag mechanism**: routing is
  enabled only via the optional **`orchestrator-routing`** field in
  **`HARNESS.md`**, and **default off / absent → off** (static-only). The
  tokens `orchestrator-routing` and `harness.md` are single unwrappable
  tokens; "default off" / "absent" are asserted as co-occurring with the
  flag. This name is **distinct** from the S3/S4 `fan-out-threshold` /
  deep-research fields — no collision.
- The section states the **static pipeline is the sole default**, stated
  three ways — the **flag-off** case, **ordinary coding**, and **ambiguous**
  classification **all select static**, with **no workflow and no extra
  compute**. Keep "static pipeline", "no extra compute", and "ambiguous"
  each **unwrapped**; the content test asserts "static" + "default",
  "flag-off"/"flag off", "ambiguous", and "no extra compute" as co-occurring
  tokens on the lowercased section.

## Rubric

Deterministic structural shadow of umbrella D4 / AC-1. What a static file
read can verify is that the orchestrator doc *declares* the classification
step, the `orchestrator-routing` opt-in flag (default off), and the
static-default supremacy rule — not that a live dispatch actually classifies
a routine task to static (that is the agent-backed AC-1, declared in
`runtime-routes-routine-task-to-static.md`, not wired here).

The load-bearing specifics:

- the flag is **named** (`orchestrator-routing` in `HARNESS.md`), matching
  the S3/S4 epic precedent of an optional `HARNESS.md` field, and the
  missing/absent case is **off** — the conservative direction;
- the static-default supremacy rule covers **all three** fall-through cases
  (flag-off, ordinary coding, ambiguous) so no routine task can drift into a
  non-static route by accident — this is the over-orchestration guard made
  load-bearing.

The scenario must **not** be read as asserting any live classification
occurs — only that the contract is declared in checkable language.

## Evaluation

Evaluated deterministically by
`tests/test_s5_orchestrator_routing_structural.py`
(`TestS5OrchestratorClassificationStep`). RED now because the agent doc
contains no "Task classification" / "Workflow routing" section (`grep -n
"Task classification\|Workflow routing"` returns nothing), so none of the
flag / static-default phrases exist yet.
