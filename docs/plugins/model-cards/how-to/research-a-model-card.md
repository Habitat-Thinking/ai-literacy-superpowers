---
title: Research a Model Card
layout: default
parent: How-to Guides
grand_parent: model-cards
nav_order: 1
redirect_from:
  - /plugins/model-cards/research-a-model-card/
  - /plugins/model-cards/research-a-model-card.html
---

<!-- redirect-sunset: 2027-05-08 -->

# Research a Model Card

Produce a Mitchell-extended model card for a single model with a
human-in-the-loop review checkpoint before the file is written.

Use this when you want fine-grained control over a single card —
inspecting source coverage, re-running a thin section, or editing the
draft before it lands on disk. To bulk-populate a library, use the
[seed your library](seed-your-library.md)
tutorial instead.

---

## Prerequisites

- The `model-cards` plugin installed.
- The model name you want to research. A provider hint is optional —
  the agent will infer it if not supplied.

---

## 1. Start the research

```text
/model-card create <model-name> [--provider <provider>] [--out <path>]
```

Examples:

```text
/model-card create claude-opus-4-7
/model-card create gpt-5-mini --provider openai
/model-card create meta-llama/llama-4 --out ./team-models
```

| Flag | Effect |
| ---- | ------ |
| `--provider X` | Provider hint; if omitted, the agent infers from the model name. |
| `--out PATH` | Library directory override. Cards still land beneath it as `<provider>/<model-name>.md`. Highest-priority path resolver. |

The default library root is `~/.claude/model-cards/`. The
`MODEL_CARDS_DIR` environment variable also overrides the default;
`--out` wins over both.

---

## 2. Handle the existing-card prompt (if any)

If a card already exists at the resolved target path, the command
asks:

```text
Card exists at <path>. [overwrite / skip / load-existing-as-base]
```

| Choice | Effect |
| ------ | ------ |
| `overwrite` | Continue research; replace the existing card on accept. |
| `skip` | Abort with no file change. |
| `load-existing-as-base` | Pass the existing card to the agent as starting context. Useful for refreshing a stale card. |

---

## 3. Wait for research to complete

The agent dispatches with the model name and provider hint, then
researches section-by-section using each section's primary source tier
(see the [agent reference](../reference/agents.md)
for the per-section tier table).

Research can take 1-3 minutes depending on how much source material is
available. The agent uses `WebFetch` and `WebSearch` only — it has no
write access. The trust boundary is "research and emit content";
persistence is the command's job after your review.

---

## 4. Review the research summary

When the agent returns, the command prints a structured summary:

```text
Sources used per section:
  Section 1 (Model Details):     T1×3
  Section 2 (Intended Use):      T1×2
  Section 3 (Factors):           T3×1, T1×1
  Section 4 (Metrics):           T1×4, T3×2
  ...

Sections that came up thin:
  Section 5 (Evaluation Data) — "Not publicly available"
  Section 6 (Training Data)   — "Not publicly available"

Top 3 most-cited claims:
  1. Pricing: $5/$25 per million tokens (T1.3)
     https://docs.anthropic.com/...
  2. Knowledge cutoff: January 2026 (T1.1)
     https://docs.anthropic.com/...
  3. Context window: 1M tokens (T1.2)
     https://docs.anthropic.com/...

Estimated research cost: ~14k tokens
```

Read this carefully. It is the only structured view you get of where
the card's evidence comes from before you commit to writing it.

---

## 5. Choose a disposition

```text
Disposition: [accept / edit / re-run-section <N> / abort]
```

| Choice | Effect |
| ------ | ------ |
| `accept` | Validate the draft, then write to the target path. |
| `edit` | Open the draft in `$EDITOR` (or `vi` if unset). The edited content replaces the draft, then you are re-prompted. |
| `re-run-section <N>` | Re-dispatch the agent with a section-specific prompt focused on template section `N` (1-10). Replaces just that section in the draft, then re-prompts. |
| `abort` | Discard the draft. No file is written. |

Use `re-run-section` when the summary shows a section is thin and you
suspect the agent missed a relevant source. Use `edit` to make narrow
factual corrections you can verify yourself.

---

## 6. Validation checkpoint runs automatically

On `accept`, the command validates the draft before writing:

1. YAML frontmatter parseable; required keys present.
2. All 10 numbered section headings present in canonical order.
3. Every `[T<n>.<m>]` citation resolves to a source in the frontmatter
   `sources` block.
4. Section 10 fields use field-level "Not publicly available" rather
   than silent omission.

Deviations are fixed in place — the agent is not re-dispatched.
Citation gaps (e.g. a `[T2.1]` reference with no source 2.1 in
frontmatter) are surfaced to you before write.

This validation is the same pattern enforced by the project-wide
"Output Validation Checkpoints" convention — see
[the harness conventions](../../ai-literacy-superpowers/how-to/run-a-harness-audit.md)
for the broader context.

---

## 7. Confirm the write

```text
Card written: ~/.claude/model-cards/anthropic/claude-opus-4-7.md
```

The card is now on disk at the resolved path. Open it in your editor
to inspect the full content; every claim resolves to a citation, and
every citation resolves to a URL in the frontmatter `sources` block.

---

## What happens on REFUSED

If the agent cannot confirm the model exists via tier-1 or tier-2
sources, it returns a `REFUSED:` string instead of a draft. The
command surfaces the refusal verbatim and aborts:

```text
REFUSED: Could not confirm existence of model "<name>" via tier-1
(provider docs) or tier-2 (HuggingFace). Searched: <list of URLs>.
The model may not exist under this name, may have been retired, or may
be too recent for available sources.
```

No file is written. This is by design — the existence-check rule
prevents authoritative-looking cards for hallucinated or non-existent
models. See [the explanation page](../explanation/mitchell-extended-cards.md#card-level-honesty)
for why this matters.

If the refusal looks wrong (e.g. you know the model exists), pass an
explicit `--provider` hint to disambiguate, or use a different
spelling of the model name.

---

## What you have now

A single Mitchell-extended model card on disk at the resolved target
path, with per-claim citations and tiered source provenance. Validation
guarantees the card is structurally correct and every citation
resolves.

## Next steps

- [Seed your library](seed-your-library.md) —
  bulk-populate from the shipped frontier-models seed list.
- [Card template reference](../reference/card-template.md) —
  the canonical structure each card is validated against.
- [Agent: model-card-researcher](../reference/agents.md) —
  inside the research loop and refusal logic.
