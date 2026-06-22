---
component: code-reviewer
component_type: agent
tier: structural
---

# Scenario: the workflow-mode section declares per-property dedicated verifiers, synthesised-not-collapsed, adapting the template (AC-3 / FR-3)

## Given

The workflow-mode section of
`ai-literacy-superpowers/agents/code-reviewer.agent.md`.

## When

The section is read.

## Then

- It declares that **each CUPID property** (Composable, Unix-philosophy,
  Predictable, Idiomatic, Domain-based) and **each literate-programming
  property** is checked by a **dedicated verifier** — the terms "CUPID",
  "literate", and "dedicated verifier" all appear. Keep "dedicated
  verifier" **on one line**.
- It states that findings are **synthesised, not collapsed** into a single
  thumbs-up — both "synthesis" and "collapse" appear so the contrast is
  explicit (asserting "synthesis" alone would not capture the guarantee).
- It states it **adapts `adversarial-review.workflow.js` by relative
  path** — the filename `adversarial-review.workflow.js` and the word
  "adapt" both appear (ADAPT, not run verbatim; per-role model tiers and
  token budget tuned per run).
- It states the **`MAX_REVIEW_CYCLES=3`** GUARDRAIL still holds in workflow
  mode — workflow mode does not multiply review cycles. Keep
  `MAX_REVIEW_CYCLES` **unwrapped**.

## Rubric

Deterministic structural shadow of AC-1's fan-out (umbrella D5). The
load-bearing guarantee is the *per-property fan-out plus the
synthesise-not-collapse barrier* — a single thumbs-up that hides which
property failed is exactly the self-preferential collapse this defeats. The
test asserts the synthesise/collapse contrast as two tokens, the template
filename verbatim (filenames are wrap-safe), and `MAX_REVIEW_CYCLES` as one
token. AC-4 (the guardrail actually holding) is unverified/declared — the
guardrail lives in the orchestrator/pipeline; the structural shadow is the
section *stating* it holds.

## Evaluation

Evaluated deterministically by
`tests/test_s4_adversarial_deepresearch_structural.py`
(`TestS4CodeReviewerWorkflowMode`). RED now: no workflow-mode section
exists, so the per-property-verifier, synthesise-not-collapse,
template-adapt, and MAX_REVIEW_CYCLES declarations are all absent.
