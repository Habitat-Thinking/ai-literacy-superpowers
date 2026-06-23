---
component: dynamic-workflows
component_type: skill
tier: structural
---

# Scenario: README ships a Dynamic Workflows section (AC-1–AC-5 / FR-1–FR-5)

## Given

The repo-root `README.md` (read via `_repo_root(plugin_path) / "README.md"`
— `README.md` is at the **repo root**, not a plugin component; this scenario
is filed against the `dynamic-workflows` skill only so the corpus can resolve
a target, mirroring how S6's `.gitignore` check lives under
`commands/reflect` but asserts a repo-root file).

## When

`README.md` is read and the Dynamic Workflows section is isolated (from a
heading whose text contains `dynamic workflows`, case-insensitive, to the
next same-or-higher-level heading).

## Then

- A **heading containing `dynamic workflows`** exists (case-insensitive).
  `dynamic workflows` is two words — the content test isolates the section by
  matching a heading that contains both, but assertions on the section body
  use co-occurring single tokens. Keep the heading phrase **unwrapped**.
- The section references the **six patterns**: the content test asserts a few
  load-bearing tokens co-occur — `fan-out` (single token, keep unwrapped) and
  `adversarial` and `tournament` — and/or the phrase concept "six patterns".
  Keep `fan-out`, `classify-and-act`, `loop-until-done` **unwrapped** (each is
  a single hyphenated token).
- The section references the **election discipline** — that workflows are
  elected (opt-in), not reflexive: the test asserts one of `elect` /
  `opt-in` / `when not to use`. Keep `opt-in` and `when not to use`
  **unwrapped**.
- The section names **INV-1** AND **INV-2** — both are single wrap-safe
  tokens, asserted directly.
- The section states the **Claude Code-only** scope: `claude code` is **two
  words** — keep it **unwrapped**; the test asserts `claude` and `code` as two
  independent co-occurring tokens (NOT a joined substring).
- The section states the **Option A Copilot guidance contract**: `copilot`
  co-occurs with `guidance` — i.e. the README states the skill ships to
  Copilot CLI as **guidance only** (the guidance-only fallback), not omitted.
  Keep `guidance only` / `guidance-only` **unwrapped**; the test asserts
  `copilot` and `guidance` as co-occurring tokens.
- The README **Skills badge still reads 36** — the test asserts `Skills-36`
  is present and `Skills-37` is **absent** (a guard against an accidental
  re-bump; S1 already reconciled the count). `Skills-36` and `Skills-37` are
  single wrap-safe tokens. **This is a guard that must STAY green now, not a
  RED-now assertion.**

## Rubric

Deterministic structural shadow of AC-1 through AC-5. The README must gain a
prose Dynamic Workflows section documenting the ephemeral, self-authored,
per-task multi-agent substrate beneath the static pipeline: the six patterns
at a glance, the election discipline (elected via the when-not-to-use rubric,
not reflexive — the static pipeline stays the default), the two governance
invariants INV-1 (ephemeral proposes, durable curates) and INV-2 (quarantine
untrusted-content readers), and the Claude-Code-only runtime scope with the
resolved **Option A** Copilot degradation contract (guidance-only fallback,
never omitted). S7 adds prose only: it does **not** re-bump the `Skills-36`
badge (reconciled in S1).

## Evaluation

Evaluated deterministically by
`tests/test_s7_docs_hook_copilot_structural.py`
(`TestS7ReadmeDynamicWorkflowsSection`). RED now because `README.md` has no
Dynamic Workflows section — only a one-line skill-table row — so the section,
the patterns/election/INV/scope/Copilot phrases are absent. The
`Skills-36`-present / `Skills-37`-absent guard is GREEN now and must stay so.
