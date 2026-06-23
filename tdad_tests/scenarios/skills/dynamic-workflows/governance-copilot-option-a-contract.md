---
component: dynamic-workflows
component_type: skill
tier: structural
---

# Scenario: the skill/governance reference states the Option A Copilot contract (AC-6c / FR-6)

## Given

`ai-literacy-superpowers/skills/dynamic-workflows/references/governance.md`
(read via `plugin_path / "skills" / "dynamic-workflows" / "references" /
"governance.md"`).

## When

`governance.md` is read.

## Then

- The reference states the resolved **Copilot CLI degradation contract**:
  `copilot` co-occurs with `guidance` — the skill is **guidance only** on a
  tree without the workflow runtime. Keep `guidance only` / `guidance-only`
  **unwrapped**; the test asserts `copilot` and `guidance` as co-occurring
  tokens (NOT a joined substring).
- The reference carries a **never-omit / never-error assurance** — one of
  `never omit` / `not omitted` / `ship to both` / `both trees` — stating the
  skill is guidance-only where the runtime is absent and is **not omitted**
  (Option A, not Option B). Keep `both trees` / `ship to both` / `never omit`
  **unwrapped**; the test asserts the assurance as a small set of
  co-occurring tokens.

## Rubric

Deterministic structural shadow of AC-6c / FR-6. The skill/governance
reference is the agent-facing authoritative home for the resolved
open-question-4 contract: **Option A — guidance-only fallback**. The skill
ships to **both** the Claude Code and Copilot CLI trees; without the workflow
runtime it is **readable knowledge only** — no workflow is spawned, nothing
errors, and the skill is **never omitted**. This is the consistent resolution
with shipped S1–S6 behaviour and requires no code change beyond words. Option
B (omit on Copilot) is recommended against and is NOT the contract stated
here.

## Evaluation

Evaluated deterministically by
`tests/test_s7_docs_hook_copilot_structural.py`
(`TestS7GovernanceCopilotContract`). RED now because `governance.md` carries
the INV-1/INV-2 invariants but no Copilot Option-A degradation statement, so
the `copilot` + `guidance` co-occurrence and the never-omit/both-trees
assurance are absent.
