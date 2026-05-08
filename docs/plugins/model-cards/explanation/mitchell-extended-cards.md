---
title: Mitchell-Extended Model Cards
layout: default
parent: Concepts
grand_parent: model-cards
nav_order: 1
redirect_from:
  - /plugins/model-cards/mitchell-extended-cards/
  - /plugins/model-cards/mitchell-extended-cards.html
---

<!-- redirect-sunset: 2027-05-08 -->

# Mitchell-Extended Model Cards

The cards produced by this plugin extend the Mitchell et al. (2019)
"Model Cards for Model Reporting" specification. This page explains
why — what the original specification covers, why an extension was
needed for the consumer-evaluator audience, and why the citation-tier
discipline and existence-check refusal rule are load-bearing.

---

## What Mitchell et al. proposed

Mitchell et al.'s 2019 paper, *Model Cards for Model Reporting*,
proposed a 9-section structured document that accompanies every
released ML model. The sections — Model Details, Intended Use, Factors,
Metrics, Evaluation Data, Training Data, Quantitative Analyses, Ethical
Considerations, Caveats and Recommendations — answer the question
*what should be disclosed when releasing a model*.

The paper's argument was that under-specified model releases produce
predictable harms: misuse outside intended scope, surprise failure on
underrepresented subgroups, and a general inability for downstream
users to make informed adoption decisions. A standardised disclosure
document would shift the cost of evaluation from the consumer back to
the producer.

The proposal landed. Major model providers now publish documents they
call "model cards", though the structural conformance varies. Some
follow the original 9-section structure closely; others publish ad-hoc
documents that carry the name without the discipline.

---

## Why a 10th section

The original 9 sections answer *what was released*. They do not answer
*how to use the model operationally* — pricing, context window,
knowledge cutoff, supported APIs, function-calling support,
fine-tuning availability, rate limits.

For the **consumer-evaluator audience** (engineers picking which model
to integrate, evaluators comparing options, platform teams making
procurement decisions), the operational profile matters more than the
training-data lineage. A card that documents Section 6 (Training Data)
in detail but says nothing about pricing or context window is not
useful for the choice these audiences are actually making.

Section 10 — **Operational Details** — fills this gap. It is best-
effort structured: every field listed in the template appears in every
card, even if the value is unknown ("Not publicly available"). This
guarantees that downstream tooling (e.g. the future
`/model-card compare`) can diff cards field-by-field without
special-casing missing fields.

The choice to add a 10th section rather than fork the spec entirely
preserves Mitchell et al.'s structural commitment. A consumer who
already knows the 9-section layout can read these cards without
relearning anything; the 10th section is additive.

---

## Why per-claim citations

The original Mitchell paper does not mandate citation discipline.
Many published model cards rely on the producer's authority — claims
appear without sources, and the reader is implicitly trusting the
producing organisation.

This plugin produces cards from research, not from authoritative
disclosure. A card the agent generates is a synthesis of public
sources of varying tier. **Without per-claim citations, the card
becomes indistinguishable from the producer's own card** — and that
indistinguishability is dangerous, because the agent's claims have a
different epistemic status than the producer's.

The `[T<n>.<m>]` citation format makes the source tier explicit at
the point of claim:

- `T1.x` — provider docs (most authoritative for what the producer
  claims about their own model).
- `T2.x` — HuggingFace (authoritative for open-source / fine-tuned
  models; secondary for proprietary models).
- `T3.x` — arXiv release paper (authoritative for training and
  evaluation data; often more candid about limitations than provider
  marketing).
- `T4.x` — web search (independent evaluations, third-party
  benchmarks; valuable for reality-check but lowest tier).

A reader can then judge each claim by its tier without needing to
re-research it. A claim citing `T1.3` (provider pricing page) is
trustworthy in a different way than a claim citing `T4.7` (independent
benchmark blog post).

The citation discipline also catches **fabrication**. If a citation
appears in the body but the corresponding source is missing from the
frontmatter `sources` block, the validation checkpoint flags it
before the card is written. The agent cannot cite a URL it didn't
fetch.

---

## Card-level honesty

The most consequential rule in the plugin is the **existence-check
refusal**: if tier-1 (provider docs) AND tier-2 (HuggingFace) are
both silent on the model's existence — the agent cannot confirm the
model exists at all — the agent **refuses to produce the card**.

This rule prevents a specific failure mode that would otherwise be
catastrophic: an authoritative-looking model card for a hallucinated
model.

LLMs hallucinate model names. If you ask an LLM about
`gpt-7-ultra-pro`, it will often produce plausible-sounding details:
"GPT-7 Ultra Pro is OpenAI's most advanced reasoning model, released
in early 2027, with a 5M token context window..." — none of which is
true. The model doesn't exist.

If the plugin produced a card for `gpt-7-ultra-pro` containing such
content, the card would inherit the structural authority of every
other card in the library. A reader skimming a populated library
would have no signal that this particular card was fabricated. The
fabricated card would be cited by downstream tooling, included in
comparisons, and treated as data.

The existence check breaks this loop. The agent must find the model
in tier-1 OR tier-2 — both authoritative producer-side sources —
before writing anything. If it can't, it returns `REFUSED:` with the
URLs it searched, the dispatcher surfaces the refusal verbatim, and
no file is written.

This means a populated library has a guaranteed property: every card
in it corresponds to a model that at least one authoritative source
confirms exists. That guarantee is the foundation everything else
rests on.

---

## The trust boundary

The agent has only `WebFetch`, `WebSearch`, `Read`, `Glob`, and `Grep`.
No `Write`. No `Edit`. No `Bash`.

This is the **read-only-emitter** pattern. The agent's job is to
research and emit content. Persistence — writing the file — is the
dispatching command's job, after a human review checkpoint.

The separation is load-bearing. The human review gate sits between
agent output and file write, and catches:

- Hallucinated claims that survived the existence check.
- Fabricated citations (a `[T2.1]` reference with no actual source 2.1).
- Refusal conditions the agent should have surfaced.
- Sections that came up too thin to be useful.

An agent with `Write` access bypasses that gate. Once the file is on
disk, downstream tooling treats it as data; the human review window
has closed. The pattern matches the trust architecture used by
`advocatus-diaboli` and `choice-cartographer` in the sister
`ai-literacy-superpowers` plugin (see
[the adversarial-review explanation]({% link plugins/ai-literacy-superpowers/adversarial-review.md %})
for the broader argument).

---

## Tiered sources, not majority votes

A naive aggregator might treat sources as votes — "three out of four
sources agree, so the claim is true". This plugin doesn't.

Sources are **tiered**, not weighted. A claim from tier 1 (provider
docs) **wins** over a claim from tier 4 (web), even if tier 4 has
more sources. The conflict is recorded in Section 9 (Caveats), not
resolved by majority.

Why: tier 4 sources are often downstream of tier 1. A blog post
discussing pricing usually reflects what the pricing page said at the
time the post was written. If three blog posts cite an old pricing
page and the current pricing page disagrees, the blog posts are
**evidence of a past state**, not contradictory current evidence.
Treating them as votes against the current provider docs would
systematically privilege stale information.

The tiered approach also makes the trust chain auditable. A reader
can see *why* a claim won — not because it had the most sources, but
because its source was the most authoritative for that claim type.

---

## Related

- [Skill: model-cards]({% link plugins/model-cards/reference/skills.md %}) —
  the operational reference for each section.
- [Agent: model-card-researcher]({% link plugins/model-cards/reference/agents.md %}) —
  how the rules are enforced in code.
- [Card template]({% link plugins/model-cards/reference/card-template.md %}) —
  the canonical structure.
- [Adversarial review]({% link plugins/ai-literacy-superpowers/adversarial-review.md %}) —
  the broader read-only-emitter pattern this plugin's agent follows.
