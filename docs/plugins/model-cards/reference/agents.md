---
title: Agent — model-card-researcher
---
<!-- redirect-sunset: 2027-05-08 -->

# Agent: model-card-researcher

A read-only research agent that produces a Mitchell-extended model card
from a model name and an optional provider hint. The agent emits the
card content as its final message; the `/model-card create` command
writes the file after a human review checkpoint.

---

## Charter

Given a model name (and optionally a provider hint), produce a
Mitchell-extended model card by researching the model through a tiered
source strategy. Cite every factual claim. Write "Not publicly
available" rather than fabricate. Refuse to produce a card when the
model's existence cannot be confirmed.

---

## Inputs

| Input | Required | Description |
| ----- | -------- | ----------- |
| Model name | yes | E.g. `claude-opus-4-7`, `meta-llama/llama-4`, `gpt-5-mini`. |
| Provider hint | no | E.g. `anthropic`, `openai`, `huggingface`, `meta`. If absent, the agent infers from the model name. |

---

## Output

A single markdown string containing the full card content — frontmatter
plus all 10 sections per the
[card template](card-template.md).

The agent does **not** write the file. The dispatching command
persists the output after a human-in-the-loop review checkpoint.

If the existence check fails, the agent returns a `REFUSED:` string
instead of a card body. The dispatcher detects this prefix and aborts
without writing anything.

---

## Tools

`WebFetch`, `WebSearch`, `Read`, `Glob`, `Grep`.

No `Write`. No `Edit`. No `Bash`.

The trust boundary is **research and emit content**; persistence is
the dispatcher's responsibility. This matches the read-only-emitter
pattern used by `advocatus-diaboli` and `choice-cartographer` in the
sister `ai-literacy-superpowers` plugin (see the project's `AGENTS.md`
ARCH_DECISIONS for the broader trust architecture).

The separation is **load-bearing**: the human review gate between
agent output and file write catches hallucinated claims, fabricated
citations, or refusal-conditions the agent should have surfaced. An
agent with `Write` access bypasses that gate.

---

## Tiered source strategy

| Tier | Source | Discovery |
| ---- | ------ | --------- |
| 1 | Provider docs | URL inferred from a provider→docs-root mapping. |
| 2 | HuggingFace | `https://huggingface.co/{owner}/{model}` if the model is hosted on HF. |
| 3 | arXiv release paper | `WebSearch` for `"{model-name}" arxiv`. |
| 4 | Web search | `WebSearch` with explicit queries; prefer recent results. |

### Provider → docs-root mapping (tier 1)

| Provider | Docs root |
| -------- | --------- |
| `anthropic` | `https://docs.anthropic.com` |
| `openai` | `https://platform.openai.com/docs/models` |
| `google` | `https://ai.google.dev/gemini-api/docs/models` |
| `meta` | `https://ai.meta.com/llama` and the model's GitHub repo |
| `mistral` | `https://docs.mistral.ai` |
| `xai` | `https://docs.x.ai` |
| `cohere` | `https://docs.cohere.com` |
| `alibaba` | `https://qwenlm.github.io` or the model's docs page |

For any other provider, the agent search-discovers via `WebSearch` for
`"{provider}" "{model-name}" docs`.

### Per-section primary source

| Section | Primary | Fallback |
| ------- | ------- | -------- |
| 1. Model Details | Tier 1 | Tier 2 → 4 |
| 2. Intended Use | Tier 1 | Tier 2 → 4 |
| 3. Factors | Tier 3 | Tier 1 → 2 |
| 4. Metrics | Tier 1 + Tier 3 | — |
| 5. Evaluation Data | Tier 3 | Tier 1 |
| 6. Training Data | Tier 3 | Tier 1 (often "Not publicly available") |
| 7. Quantitative Analyses | Tier 3 | Tier 1 |
| 8. Ethical Considerations | Tier 3 + Tier 1 | Tier 4 |
| 9. Caveats and Recommendations | Synthesised from above | — |
| 10. Operational Details | Tier 1 | Tier 4 |

The agent researches **section by section** using each section's primary
tier rather than fetching all sources upfront. This is more efficient
and produces a sharper provenance trail.

---

## Honesty rules

### Claim-level

- "Not publicly available" is the canonical answer when tier-1 is
  silent and lower tiers cannot confirm. **Never fabricate.**
- "Per the provider's published statements" framing is preferred over
  bare assertion — preserves the source-trust chain.
- If a tier-4 (web) claim conflicts with a tier-1 (provider docs)
  claim, **tier-1 wins**; the conflict is recorded in Section 9
  (Caveats).

### Card-level — model existence check

If tier-1 (provider docs) AND tier-2 (HuggingFace) are both silent on
the model's existence — neither has a page, doc, or model card matching
the input name — the agent **refuses to produce the card** and returns:

```text
REFUSED: Could not confirm existence of model "<name>" via tier-1
(provider docs) or tier-2 (HuggingFace). Searched: <list of URLs / queries>.
The model may not exist under this name, may have been retired, or may
be too recent for available sources. The dispatching command should
surface this to the user before any file is written.
```

The dispatcher detects the `REFUSED:` prefix and writes nothing. This
prevents authoritative-looking cards for hallucinated or non-existent
models.

---

## Citation format

Every factual claim ends with `[T<n>.<m>]` where:

- `n` is the source tier (1-4)
- `m` is the source index within that tier (1, 2, 3, ...)

URLs resolve via the frontmatter `sources` block of the card the agent
produces. The agent aggregates sources at the top of the card.

---

## Anti-patterns

- **Fabricating a citation.** If the agent didn't fetch a URL, it must
  not cite it.
- **Producing a card after the model-existence check fails.** Return
  the `REFUSED:` string instead.
- **Trying to write files.** The agent has no `Write` tool. Content is
  returned as the final message; the dispatcher writes the file after
  the human review checkpoint.
- **Dropping a section because it came up sparse.** Every section
  appears in every card; sparse sections are filled with "Not publicly
  available" — never omitted.

---

## Related

- [`/model-card` command](commands.md) —
  the dispatcher that uses this agent.
- [`model-cards` skill](skills.md) —
  authoring reference for the 10-section card structure.
- [Card template](card-template.md) —
  the canonical structure the agent populates.
- [Mitchell-extended model cards](../explanation/mitchell-extended-cards.md) —
  why the agent works the way it does.
