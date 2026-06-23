---
component: reflect
component_type: command
tier: structural
---

# Scenario: the --mine section declares the cluster → adversarial filter → shortlist shape and adapts the template by relative path (AC-4 / FR-2)

## Given

The mining-mode section of
`ai-literacy-superpowers/commands/reflect.md`.

## When

The `--mine` section is read.

## Then

- The section declares the **three-phase shape**: **cluster** the reflection
  entries → an **adversarial** pre-filter ("would this rule have prevented a
  real past mistake?") → a vetted **shortlist** of promotion candidates. Keep
  the words "cluster", "adversarial", and "shortlist" each **unwrapped**; the
  content test asserts each as an independent token on the lowercased
  section, plus the co-occurring "would this" + "prevented" pre-filter
  question (each kept unwrapped, asserted as co-occurring tokens — NOT a
  joined substring).
- The section declares mining **adapts** `reflection-mining.workflow.js` by
  **relative path** — ADAPT, not run verbatim. The token
  `reflection-mining.workflow.js` is single and unwrappable. Keep the phrase
  "relative path" **unwrapped**; the content test asserts "adapt" co-occurring
  with "relative path" and with the `.workflow.js` token.

## Rubric

Deterministic structural shadow of AC-4 / FR-2. The generate-and-filter +
adversarial-verification shape is the reverse of the rule-adherence pattern:
over-generate candidate rules, then prune hard. What a static file read
verifies is that the doc *declares* this cluster → adversarially-filter →
shortlist shape and that it ADAPTs the S2 template by relative path (per the
AGENTS.md "a consumer never mutates the contract it consumes" decision) — not
that a live mining run actually clusters a real corpus (that is the
agent-backed AC-1, declared in
`mining-emits-vetted-shortlist-to-staging.md`, not wired here).

The load-bearing specifics:

- the **adversarial** filter is the "would this rule have prevented a real
  past mistake?" skeptic gate, not a generic relevance filter — only
  candidates the skeptic affirms reach the shortlist;
- mining **ADAPTs** (not edits, not runs verbatim) the S2 template by relative
  path — S6 ships no edit to any `*.workflow.js`.

## Evaluation

Evaluated deterministically by
`tests/test_s6_reflection_mining_structural.py`
(`TestS6ReflectMineShape`). RED now because the mining-mode section does not
exist, so the cluster/adversarial/shortlist and adapt-by-relative-path
phrases are absent.
