# Implementation Plan — S4 — Orchestrator cost fold-in at T1 and T2

Companion to `docs/superpowers/specs/2026-06-12-orchestrator-cost-fold-in-design.md`.
Tracking issue #371. Plugin version 0.44.0 → 0.45.0 (behavioural change to the
orchestrator agent — minor bump).

## Approach

S4 is a pure consumer of S1 (format), S2 (agent), and S3 (persistence +
checkpoint). The only behavioural change is to
`ai-literacy-superpowers/agents/orchestrator.agent.md`: two informational
fold-ins into **existing** gates, never a new gate. Everything else is the
standard version/CHANGELOG/docs ceremony.

## Steps

1. **Spec + plan** (this PR's first commit) — done.
2. **Orchestrator T1 fold-in.** In §"After carpaccio completes", insert
   **Step 2a — Estimate per-slice cost** between the validate step and the
   surface step: dispatch the `cost-estimator` once per slice in parallel with
   explicit `target_kind: slice`; on each non-`REFUSED:` return, write to
   `cost-estimates/<date>-<task-slug>-<slice-id>-estimate.md` and run the S3
   Output Validation Checkpoint (referenced, not re-inlined). Extend Step 3 to
   append the compact per-slice cost line. Note re-run on `revised`.
3. **Orchestrator T2 fold-in.** In §"After spec-writer completes", insert
   **Step 6a — Estimate progressed-slice cost** between the choice-story soft
   gate and Plan Approval: dispatch the agent once against the progressed slice's
   spec with explicit `target_kind: spec`; persist + checkpoint. Extend Step 7 to
   add the cost-estimate block alongside `cartograph_pending_count`. Note re-run
   on request-changes.
4. **Context object.** Add `t1_estimate_slugs`, `t1_estimate_refused_count`,
   `t2_estimate_slug`, `t2_estimate_grounded` to the Context object section.
5. **Failure-mode prose.** State the never-degrades guarantee inline at both
   fold-ins (REFUSED / dispatch error / checkpoint abort → "unavailable", gate
   proceeds; no block, no keypress).
6. **Exemption comment.** Update the orchestrator's in-file TDAD exemption comment
   to reference this spec as the latest modification.
7. **Version ceremony.** plugin.json 0.44.0 → 0.45.0; README badge; marketplace
   `plugin_version`; CHANGELOG 0.45.0 section.
8. **Docs.** Make the concept page's "future orchestrator fold-in" present-tense
   and add a fold-in section; note the fold-in in the agent-orchestration
   explanation page.
9. **PR ceremony.** feature — full `/diaboli` (spec + code) and
   `/choice-cartograph`; CHANGELOG before PR; wait for CI green before merge.

## Risks / watch-items

- **Friction risk.** Keep T1 to one line per slice; the verbose surface is T2,
  which fires once per iteration.
- **Fan-out cost.** T1 is N parallel read-only dispatches; acceptable and the
  named highest-value moment. Re-runs only on `revised`.
- **Never-degrades.** Every estimator failure path must reduce to "unavailable",
  never a block — this is the load-bearing reliability guarantee and the thing a
  code-mode diaboli should probe hardest.
