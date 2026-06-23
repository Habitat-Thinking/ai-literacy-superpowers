---
component: reflect
component_type: command
tier: structural
---

# Scenario: reflect declares an opt-in --mine mode and leaves the default capture path unchanged (AC-3 / FR-1)

## Given

The file
`ai-literacy-superpowers/commands/reflect.md`.

## When

The command doc is read.

## Then

- A **mining-mode section** is present — a level-2/3/4 heading containing
  "Mining mode" or "--mine". The content test slices from that heading;
  everything below is the `--mine` contract.
- The section declares `--mine` is **optional / opt-in** — it is an additive
  mode, not the default behaviour. The token `--mine` is a single
  unwrappable token; "optional"/"opt-in" are asserted as co-occurring with it.
- The section states the **default** `/reflect` **capture** behaviour is
  **unchanged** — bare `/reflect` (no `--mine`) still writes a fragment under
  `reflections/active/` and regenerates `REFLECTION_LOG.md`. Keep the words
  "default", "capture", and "unchanged" each **unwrapped**; the content test
  asserts them as co-occurring tokens on the lowercased section (NOT as a
  joined substring). The tokens `reflections/active` and `REFLECTION_LOG.md`
  are single unwrappable tokens.

## Rubric

Deterministic structural shadow of AC-3 / FR-1. What a static file read can
verify is that the doc *declares* `--mine` as an opt-in, additive mode and
that it *states* the default capture path is untouched — not that a live
bare `/reflect` run actually behaves identically (that is a behavioural
property, not asserted here).

The load-bearing specifics:

- `--mine` is **opt-in** — the section must not read as if mining is the
  new default; the default `## Process` capture path is the unchanged
  behaviour, and `--mine` is strictly additive;
- the default capture path is named (`reflections/active/` fragment +
  `REFLECTION_LOG.md` regeneration) so the "unchanged" guarantee is concrete,
  not a bare assertion.

The scenario must **not** be read as asserting any live capture or mining
run occurs — only that the contract is declared in checkable language.

## Evaluation

Evaluated deterministically by
`tests/test_s6_reflection_mining_structural.py`
(`TestS6ReflectMineModeOptIn`). RED now because `reflect.md` contains no
"Mining mode" / "--mine" section (`grep -in "mining mode\|--mine"
ai-literacy-superpowers/commands/reflect.md` returns nothing), so none of the
opt-in / default-unchanged phrases exist yet.
