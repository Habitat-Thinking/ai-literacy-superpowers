---
title: Seed Your Library
layout: default
parent: How-to Guides
grand_parent: model-cards
nav_order: 2
redirect_from:
  - /plugins/model-cards/seed-your-library/
  - /plugins/model-cards/seed-your-library.html
---

<!-- redirect-sunset: 2027-05-08 -->

# Seed Your Model Card Library

Populate your model card library with cards for a shipped list of 14
frontier models in a single command.

This is the fastest way to get a working library you can browse,
compare, and reference. After this tutorial you will have one card per
frontier model on disk, ready for downstream tooling.

---

## Prerequisites

- The `model-cards` plugin installed — see the
  [model-cards landing]({% link plugins/model-cards/index.md %}#install).
- A working internet connection. The agent fetches provider docs,
  HuggingFace pages, arXiv papers, and web sources during research.

---

## 1. Run the seed command

```text
/model-card seed
```

The command reads the shipped seed list at
`${CLAUDE_PLUGIN_ROOT}/seed/frontier-models.json`, prints the list and
total count, and asks for one confirmation:

```text
Research 14 cards into ~/.claude/model-cards? [y/N]
```

Type `y` to proceed. Anything else aborts.

---

## 2. Watch the per-model log

The command processes models sequentially. For each one you will see
a one-line status:

```text
[1/14] anthropic/claude-opus-4-7      created
[2/14] anthropic/claude-sonnet-4-6    created
[3/14] anthropic/claude-haiku-4-5     created
[4/14] openai/gpt-5                    skipped (refused: not confirmed)
...
```

Three outcomes are possible per model:

| Status | Meaning |
| ------ | ------- |
| `created` | Card written to the library. |
| `skipped (existed)` | A card already exists at the target path; left untouched. Use `--force` to overwrite. |
| `skipped (refused: <reason>)` | The agent could not confirm the model exists via tier-1 (provider docs) or tier-2 (HuggingFace). No file is written. The refusal reason is logged. |

Refusals are normal for models that are recent, retired, or whose
provider has not published documentation under the exact model name in
the seed list.

---

## 3. Review the summary

When the run completes, the command prints a four-line summary:

```text
Created: 11
Skipped (existed): 0
Skipped (refused): 3
Failed (other): 0
```

The library now lives at `~/.claude/model-cards/` (or whatever
`MODEL_CARDS_DIR` was set to). Cards are organised by provider:

```text
~/.claude/model-cards/
├── anthropic/
│   ├── claude-opus-4-7.md
│   ├── claude-sonnet-4-6.md
│   └── claude-haiku-4-5.md
├── google/
│   ├── gemini-2.5-pro.md
│   └── gemini-2.5-flash.md
└── ...
```

---

## 4. Inspect a card

Open any of the generated cards. Every card has the same 10-section
structure (see the [card template]({% link plugins/model-cards/reference/card-template.md %})
reference) and a frontmatter `sources` block listing every URL the
agent fetched, grouped by tier.

A typical card opens like this:

```yaml
---
model_name: claude-opus-4-7
provider: Anthropic
model_version: claude-opus-4-7
last_researched: 2026-04-29
card_version: 0.1.0
researcher: model-card-researcher (claude-opus-4-7[1m])
sources:
  - tier: 1
    url: https://docs.anthropic.com/...
    fetched: 2026-04-29
  ...
---

# Model Card: Anthropic/claude-opus-4-7

## 1. Model Details

Claude Opus 4.7 is Anthropic's most capable model in the Claude 4
family [T1.1] ...
```

Every factual claim ends with a `[T<n>.<m>]` citation marker. `n` is
the source tier (1 = provider docs, 2 = HuggingFace, 3 = arXiv,
4 = web). `m` is the index within that tier. Resolve the URL by looking
it up in the frontmatter `sources` block.

---

## 5. Re-research a card

If a card came up thin (lots of "Not publicly available" sections) or
the source material has changed, re-research a single card with:

```text
/model-card create <model-name> --provider <provider>
```

This is the same flow as the [research a model card]({% link plugins/model-cards/how-to/research-a-model-card.md %})
how-to. When prompted about the existing card, choose `overwrite` or
`load-existing-as-base`.

---

## What you have now

A populated model card library on disk, with one card per confirmed
frontier model. Each card carries per-claim citations and tiered source
provenance. Refusals are logged but no fabricated cards exist in the
library — the existence-check rule guarantees this.

## Next steps

- [Research a model card]({% link plugins/model-cards/how-to/research-a-model-card.md %}) —
  add a card for a model that wasn't in the seed list.
- [Mitchell-extended model cards]({% link plugins/model-cards/explanation/mitchell-extended-cards.md %}) —
  understand why the cards are structured the way they are.
- [Card template reference]({% link plugins/model-cards/reference/card-template.md %}) —
  the template every generated card conforms to.
