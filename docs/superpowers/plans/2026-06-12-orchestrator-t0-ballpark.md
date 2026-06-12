# Implementation Plan — S5 — Orchestrator T0 pre-carpaccio ballpark

Companion to `docs/superpowers/specs/2026-06-12-orchestrator-t0-ballpark-design.md`.
Tracking issue #372. Plugin version 0.45.0 → 0.46.0 (behavioural change to the
orchestrator agent — minor bump).

## Approach

S5 is a pure consumer of S1 (format) and S2 (agent). The only behavioural change
is to `ai-literacy-superpowers/agents/orchestrator.agent.md`: a single
non-blocking T0 pre-step before carpaccio, inline-only and ephemeral. Everything
else is the standard version/CHANGELOG/docs ceremony.

## Steps

1. **Spec + plan** (this PR; spec is the spec-only first commit) — done.
2. **Orchestrator T0 pre-step.** In §"Before dispatching carpaccio", add Step 3:
   dispatch the `cost-estimator` once against the issue body as an inline
   `task-text` target (explicit `target_kind: task-text`); surface a loud
   low-confidence ballpark; write no file; run no checkpoint; do not add to the
   context object; proceed to carpaccio regardless. Add the never-degrades
   handling (REFUSED / error → "unavailable", proceed).
3. **Pipeline overview.** Add a `T0. BONUS (before step 0)` line to the Pipeline
   list.
4. **Exemption comment.** Add S5 to the orchestrator's in-file TDAD exemption
   note.
5. **Version ceremony.** plugin.json; README badge **and** table cell; marketplace
   `plugin_version` **and** `plugins[]` entry; CHANGELOG 0.46.0 section. (All six
   spots — the version-check reads the shields.io badge and the per-plugin entry,
   not just the obvious fields.)
6. **Docs.** Add the T0 section to the prospective-cost-estimation concept page
   (with the inline-only-vs-persisted asymmetry); add a sentence to the
   agent-orchestration page.
7. **PR ceremony.** feature — full `/diaboli` (spec + code) and
   `/choice-cartograph`; CHANGELOG before PR; first commit spec-only; wait for CI
   green before merge.

## Risks / watch-items

- **Anchoring is the whole point of the design choices.** The inline-only,
  not-threaded-downstream, loud-low-confidence framing all exist to stop a
  raw-text number reading as fact. A code-mode diaboli should probe whether any
  path persists or threads T0.
- **Non-blocking.** T0 must never introduce a pause or keypress; it surfaces and
  the orchestrator proceeds.
- **Spec-first CI** requires the first commit to contain only files under
  `docs/superpowers/specs/` — the plan file ships in commit 2.
