---
title: Card Template
layout: default
parent: Reference
grand_parent: model-cards
nav_order: 2
redirect_from:
  - /plugins/model-cards/card-template/
  - /plugins/model-cards/card-template.html
---

<!-- redirect-sunset: 2027-05-08 -->

# Card Template

Every model card produced by the plugin conforms to a single template:
`model-cards/templates/MODEL_CARD.md`. This page reproduces the
template structure for reference — it is what the validation
checkpoint in `/model-card create` checks against, and what
hand-authored cards should match.

---

## Frontmatter

```yaml
---
model_name: <provider>/<model-name>
provider: <Anthropic | OpenAI | Google | Meta | Mistral | xAI | Cohere | Alibaba | other>
model_version: <as-stated-by-provider>
last_researched: YYYY-MM-DD
card_version: 0.1.0
researcher: model-card-researcher (claude-opus-4-7[1m])
sources:
  - tier: 1
    url: <provider docs URL>
    fetched: YYYY-MM-DD
  - tier: 2
    url: <huggingface URL or "n/a">
    fetched: YYYY-MM-DD
  - tier: 3
    url: <arxiv URL or "n/a">
    fetched: YYYY-MM-DD
  - tier: 4
    url: <web URL or "n/a">
    fetched: YYYY-MM-DD
---
```

### Required keys

| Key | Description |
| --- | ----------- |
| `model_name` | The model's canonical identifier as published by the provider. |
| `provider` | The provider company name. |
| `model_version` | Version as stated by the provider. If the provider does not disclose a separate version, use the input model name. |
| `last_researched` | Date the agent (or hand-author) last fetched sources, in `YYYY-MM-DD`. |
| `card_version` | The card schema version. Always `0.1.0` for this plugin's v0.1.0. |
| `researcher` | Identifier for who or what produced the card. Agent uses `model-card-researcher (claude-opus-4-7[1m])`. |
| `sources` | One entry per tier consulted. Tiers not consulted use `url: "n/a"`. The validation checkpoint requires at least the tiers actually cited in the body. |

---

## Body — the ten sections

The body must contain **all ten sections** in canonical order, with
the exact heading text shown below. Sparse sections are filled with
"Not publicly available" rather than omitted — the validation
checkpoint enforces presence, not depth.

```markdown
# Model Card: {provider}/{model-name}

## 1. Model Details

What this model is, who released it, when, what kind of model it is. Cite
provider-stated identity, release date, model family, parameter count if
disclosed.

## 2. Intended Use

Primary uses, primary users, out-of-scope uses (per the provider's published
statements).

## 3. Factors

Relevant subgroups, environmental factors, instrumentation factors. Often
sparse for proprietary API-served models — fill with "Not publicly available"
where the provider has not disclosed.

## 4. Metrics

Performance measures the provider reports. Cite each metric with its source
tier; prefer tier-1 (provider docs) and tier-3 (release paper).

## 5. Evaluation Data

Datasets used to evaluate (per the provider's published statements). Often
"Not publicly available" for proprietary models — say so explicitly.

## 6. Training Data

Datasets used to train (per the provider's published statements). Frequently
"Not publicly available" for proprietary models — say so explicitly.

## 7. Quantitative Analyses

Disaggregated performance, where provider has published this. Cite metrics
table from release paper or provider docs; record the date of the analysis.

## 8. Ethical Considerations

Risks, mitigations, known failure modes — preferring the release paper as
primary source (tier 3); supplemented by provider statements (tier 1) and
independent evaluations (tier 4) where relevant.

## 9. Caveats and Recommendations

What this card cannot tell you (sections marked "Not publicly available" and
why). Recommendations for use given the model's documented strengths and
limitations. Conflicts between tier-1 and tier-4 sources are recorded here.

## 10. Operational Details

Best-effort structured fields; missing values are written as "Not publicly
available" rather than omitted:

- **Pricing** — input/output cost per million tokens; pricing tier; as-of
  date. Cite the pricing page (tier 1).
- **Context window** — maximum input + output tokens.
- **Knowledge cutoff** — provider-stated training cutoff date.
- **Supported APIs/SDKs** — provider's API name(s); language SDKs; OpenAI
  Chat Completions compatibility if applicable.
- **Latency tier** — provider's stated latency tier or category, if any.
- **Tool / structured-output support** — function calling, JSON mode, tool
  use, parallel tool calls.
- **Function calling** — supported, parallel-supported, schema format.
- **Fine-tuning availability** — yes/no/limited; cite the fine-tuning docs
  page if available.
- **Rate-limit notes** — provider-published rate limit tiers or quotas.
```

---

## Section 10 — field-level "Not publicly available"

Section 10 (Operational Details) is special: every field listed in the
template appears in every card, even if the value is unknown.
Field-level "Not publicly available" entries replace silent omission.

```markdown
- **Pricing** — Not publicly available [T1.4]
- **Context window** — 1M tokens [T1.2]
- **Knowledge cutoff** — January 2026 [T1.1]
- **Fine-tuning availability** — Not publicly available
```

This makes downstream comparison reliable — the future
`/model-card compare` (issue #234) can diff cards field-by-field
without having to special-case missing fields.

---

## Validation checkpoint

The validation step in `/model-card create` checks four things before
writing:

1. YAML frontmatter parses; required keys are present.
2. All 10 numbered section headings are present in canonical order
   (`## 1. Model Details` through `## 10. Operational Details`).
3. Every per-claim citation matches `\[T[1-4]\.\d+\]` and resolves
   via the frontmatter `sources` block.
4. Section 10 fields use field-level "Not publicly available" rather
   than silent omission.

Deviations are fixed in place — the agent is not re-dispatched.
Citation gaps (e.g. a `[T2.1]` reference with no source 2.1 in
frontmatter) are surfaced to the user before write.

---

## Related

- [Skill: model-cards]({% link plugins/model-cards/reference/skills.md %}) —
  authoring guidance for each section.
- [Agent: model-card-researcher]({% link plugins/model-cards/reference/agents.md %}) —
  how the agent populates the template.
- [Commands: /model-card]({% link plugins/model-cards/reference/commands.md %}) —
  including the validation checkpoint flow.
