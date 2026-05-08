---
title: Home
layout: default
nav_order: 1
---

# ai-literacy-superpowers

A plugin marketplace for [Claude Code](https://claude.ai/claude-code)
and [GitHub Copilot CLI](https://github.com/features/copilot) shipping
opinionated tools for the AI Literacy framework — **harness
engineering**, **agent orchestration**, **decision archaeology**,
**governance**, and **model evaluation**.

{: .fs-6 .fw-300 }

[Get Started](plugins/ai-literacy-superpowers/tutorials/getting-started.md){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 }
[Browse Plugins](plugins/index.md){: .btn .fs-5 .mb-4 .mb-md-0 .mr-2 }
[Quick Install](#add-the-marketplace){: .btn .fs-5 .mb-4 .mb-md-0 }

---

## Plugins in this marketplace

| Plugin | What it does | Get started |
| ------ | ------------ | ----------- |
| **[ai-literacy-superpowers](plugins/ai-literacy-superpowers/index.md)** | The flagship. Harness engineering, agent orchestration, literate programming, CUPID code review, compound learning, and the three enforcement loops. 30 skills, 13 agents, 24 commands. | [Tutorial](plugins/ai-literacy-superpowers/tutorials/getting-started.md) |
| **[model-cards](plugins/model-cards/index.md)** | Researches and authors Mitchell-extended model cards from a model name. Tiered source strategy with refusal-on-unconfirmed-existence honesty rule. | [Tutorial](plugins/model-cards/how-to/seed-your-library.md) |

The marketplace is on track to ship more sister plugins as the
framework grows. New plugins land under
[`/plugins/`](plugins/index.md) with their own tutorials,
how-to guides, reference, and explanation pages.

---

## Add the marketplace

The marketplace ships multiple plugins. Add the marketplace once, then
install whichever plugins you need.

**Claude Code:**

```bash
claude plugin marketplace add Habitat-Thinking/ai-literacy-superpowers
```

**GitHub Copilot CLI:**

```bash
copilot plugin marketplace add Habitat-Thinking/ai-literacy-superpowers
```

## Install a plugin

After adding the marketplace, install one or both plugins:

```bash
# Claude Code
claude plugin install ai-literacy-superpowers     # the flagship
claude plugin install model-cards                  # the sister

# Copilot CLI
copilot plugin install ai-literacy-superpowers@ai-literacy-superpowers
copilot plugin install model-cards@ai-literacy-superpowers
```

Each plugin's commands, agents, and skills become available immediately
in any project session.

---

## What each plugin ships

### ai-literacy-superpowers — the flagship

The flagship plugin implements **harness engineering**: surrounding AI
code generation with deterministic tooling, agent-based review, and
periodic entropy checks so AI-assisted development stays trustworthy
at scale.

It gives you:

- **30 skills** — domain knowledge for security auditing, constraint
  design, context engineering, fitness functions, model sovereignty,
  decision archaeology, and more
- **13 agents** — autonomous workers for orchestration, enforcement,
  garbage collection, code review, governance auditing, adversarial
  spec/code review, decision archaeology, and TDD
- **24 commands** — slash commands for harness lifecycle, assessment,
  portfolio assessment, reflection, governance, onboarding, affordance
  inventory, decision-archaeology mapping, and convention management
- **3 enforcement loops** — advisory at edit time, strict at merge
  time, investigative on schedule

In a fresh project, run `/superpowers-init` for the full habitat or
`/harness-init` for just the constraint machinery.

[Browse the ai-literacy-superpowers docs →](plugins/ai-literacy-superpowers/index.md)

### model-cards — Mitchell-extended model card research

Aimed at evaluators researching new models. Produces 10-section cards
(Mitchell et al.'s 9 canonical sections plus an "Operational Details"
section for consumer-evaluator audiences), with per-claim citations
and tiered source provenance.

It gives you:

- **`/model-card create <name>`** — researches a single model with a
  human-in-the-loop review checkpoint before the file is written
- **`/model-card seed`** — bulk-populates the library with cards for
  14 frontier LLMs from major providers
- A **read-only research agent** with no `Write` access — the trust
  boundary that prevents hallucinated claims from landing on disk
  unreviewed
- An **existence-check refusal rule** — the agent refuses to produce a
  card when it cannot confirm the model exists via tier-1 (provider
  docs) or tier-2 (HuggingFace), preventing authoritative-looking
  cards for hallucinated models

[Browse the model-cards docs →](plugins/model-cards/index.md)

---

## Documentation structure

Each plugin in the marketplace has its own landing page with tutorials,
how-to guides, reference material, and explanation pages organised
using the [Diataxis framework](https://diataxis.fr/).

| Plugin | Documentation |
| ------ | ------------- |
| ai-literacy-superpowers | [Landing](plugins/ai-literacy-superpowers/index.md) · [Tutorials](plugins/ai-literacy-superpowers/index.md#tutorials--learning-oriented) · [How-to](plugins/ai-literacy-superpowers/index.md#how-to-guides--task-oriented) · [Reference](plugins/ai-literacy-superpowers/index.md#reference--exact-details) · [Explanation](plugins/ai-literacy-superpowers/index.md#explanation--concepts) |
| model-cards | [Landing](plugins/model-cards/index.md) · [Tutorial](plugins/model-cards/how-to/seed-your-library.md) · [How-to](plugins/model-cards/how-to/research-a-model-card.md) · [Reference](plugins/model-cards/reference/commands.md) · [Explanation](plugins/model-cards/explanation/mitchell-extended-cards.md) |

See the [Plugins index](plugins/index.md) for the canonical
list.

### Old URLs

The previous flat layout (`/tutorials/`, `/how-to/`, `/reference/`,
`/explanation/`) was reorganised on 2026-04-29 to support multiple
plugins in the same marketplace. Old URLs redirect to the new
plugin-scoped paths automatically via `jekyll-redirect-from`.

---

## Why a marketplace, not a monolith

Every plugin in this marketplace addresses a distinct discipline that
benefits from AI Literacy practice — harness engineering, model
evaluation, future plugins covering further domains. Shipping each as
its own plugin lets teams adopt incrementally:

- A team focused on AI-assisted code quality can install
  `ai-literacy-superpowers` and skip `model-cards` until they need to
  catalogue models.
- A team building an evaluation pipeline can install `model-cards`
  without needing the full harness machinery.
- Future plugins for adjacent disciplines (cost governance, prompt
  evaluation, agent observability) can land in the same marketplace
  without inflating the flagship plugin.

Shared infrastructure — the marketplace listing, the docs site, the
CI conventions, the trust-boundary patterns — lives at the repository
level. The plugins themselves stay focused.
