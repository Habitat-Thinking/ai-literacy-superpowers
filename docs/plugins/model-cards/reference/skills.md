---
title: Skill — model-cards
---
<!-- redirect-sunset: 2027-05-08 -->

# Skill: model-cards

Authoring and interpretation reference for Mitchell-extended model
cards. Used by the `model-card-researcher` agent and the `/model-card`
command. Useful directly when authoring a card by hand or designing
extensions to the card schema.

---

## When to use this skill

- Authoring a card by hand (without the agent).
- Interpreting a card — knowing which sections to trust most.
- Designing extensions to the card schema (e.g. adding fields to
  Section 10).
- Building tooling that consumes cards (e.g. the future
  `/model-card compare`).

---

## The ten sections

The plugin produces 10-section cards: Mitchell et al.'s 9 canonical
sections plus an "Operational Details" 10th section for the consumer-
evaluator audience. Each section's purpose, primary source tier, and
honesty norm are summarised below.

### 1. Model Details

What the model **is** — name, provider, family, release date, parameter
count where disclosed. Tier 1 (provider docs) is primary; tier 2
(HuggingFace) is secondary for open-source / fine-tuned models.

### 2. Intended Use

What the model is **for** — primary uses, intended users, explicitly
out-of-scope uses. The provider's documentation usually makes this
explicit; quote it faithfully and cite.

### 3. Factors

Subgroups, environmental factors, instrumentation. Often sparse for
proprietary API-served models. Write "Not publicly available" rather
than fabricate.

### 4. Metrics

Performance measures the provider reports. Distinguish provider-
reported benchmarks from independent evaluations (tier 1 vs tier 4).

### 5. Evaluation Data

Datasets used to evaluate. Frequently "Not publicly available" for
proprietary models. Tier 3 (release paper) is the most likely source.

### 6. Training Data

Datasets used to train. Almost always "Not publicly available" for
proprietary models — say so. Tier 3 is the only source likely to
disclose.

### 7. Quantitative Analyses

Disaggregated performance — by demographic, by task category, by
language. Tier 3 (release paper) is primary.

### 8. Ethical Considerations

Risks, mitigations, known failure modes. Tier 3 is the most honest
source (release papers are usually more frank than marketing pages);
tier 1 is secondary; tier 4 (independent evaluations) is tertiary but
valuable for reality-check.

### 9. Caveats and Recommendations

The "what this card cannot tell you" section. Lists which sections
came up "Not publicly available" and why. Records conflicts between
tiers. Recommendations for use given the model's documented profile.

### 10. Operational Details

This plugin's extension. Best-effort structured fields:

- Pricing (input / output per million tokens)
- Context window
- Knowledge cutoff
- Supported APIs / SDKs
- Latency tier
- Tool / structured-output support
- Function calling
- Fine-tuning availability
- Rate-limit notes

Each field gets "Not publicly available" if absent; the field is never
omitted. This makes downstream comparison (`/model-card compare`)
reliable — every card has the same field surface.

---

## Citation discipline

Every factual claim ends with `[T<n>.<m>]` where:

- `n` is the source tier: 1 = provider docs, 2 = HuggingFace, 3 = arXiv,
  4 = web search.
- `m` is the source index within that tier (1, 2, 3, ...).

Example:

```text
Knowledge cutoff: January 2026 [T1.1]. Context window: 1M tokens [T1.2].
Pricing: $5/$25 per million tokens (input/output) at standard tier [T1.3].
```

URLs for each citation resolve via the per-card frontmatter `sources`
block.

---

## Honesty rules

### Claim-level

- "Not publicly available" is the canonical answer when tier-1 is
  silent and lower tiers cannot confirm. **Never fabricate.**
- "Per the provider's published statements" framing is preferred over
  assertion — preserves the source-trust chain.
- If a tier-4 web claim conflicts with a tier-1 provider claim,
  tier-1 wins; the conflict is flagged in Section 9 (Caveats).

### Card-level

If tier-1 (provider docs) AND tier-2 (HuggingFace) are both silent on
the model's existence — the card author cannot confirm the model
exists at all — the card is **not produced**. This rule prevents
authoritative-looking cards for hallucinated models. The agent enforces
this automatically by returning a `REFUSED:` string; a hand-author
should follow the same rule.

---

## Tiered source strategy

| Tier | Source | Used for |
| ---- | ------ | -------- |
| 1 | Provider docs | Model Details, Intended Use, Operational Details |
| 2 | HuggingFace | Open-source / fine-tuned models; fallback for tier-1 gaps |
| 3 | arXiv release paper | Factors, Metrics, Evaluation Data, Training Data, Quantitative Analyses, Ethical Considerations |
| 4 | Web search | Anything tiers 1-3 don't cover; independent evaluations |

The agent researches **section by section** using each section's
primary tier (see the [agent reference](agents.md)
for the full table). This is more efficient than fetching all sources
upfront and produces a sharper provenance trail.

---

## Related

- [Card template](card-template.md) —
  the structural template every card conforms to.
- [Agent reference](agents.md) — how
  the agent applies this skill end-to-end.
- [Mitchell-extended model cards](../explanation/mitchell-extended-cards.md) —
  conceptual background on why the cards are structured this way.
