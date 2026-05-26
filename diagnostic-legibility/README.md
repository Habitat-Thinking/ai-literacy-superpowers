# diagnostic-legibility

Agents accountable for helping to maintain human understanding.

A sister plugin to [ai-literacy-superpowers](../ai-literacy-superpowers/)
and [model-cards](../model-cards/) in the same marketplace.

## Status

**v0.1.0 — scaffold only.** This plugin is structurally complete and
loadable but ships with no functional agents or commands. It is here
so the next three deliverables can land on a stable foundation:

- [#331](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/331) — S2: Two-model agent (architectural + domain models with per-model self-challenge)
- [#332](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332) — S3: Cross-check mechanism (mutual model correction)
- [#333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333) — S4: Surfacing interface (on-demand human legibility command)

The carpaccio slicing record at
[`docs/superpowers/slices/diagnostic-legibility-plugin.md`](../docs/superpowers/slices/diagnostic-legibility-plugin.md)
records the full decomposition from parent issue
[#327](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/327).

## Charter

The plugin's purpose is to host agents that are accountable for
maintaining human understanding of complex systems. The inaugural
agent (in development) builds two models of a codebase scope — one
for architectural moving parts, one for domain concepts — subjects
each to a challenge–refine cycle, then uses them to cross-check and
correct each other, producing mutually-corrected models that can be
surfaced on demand.

The framing is deliberately broad: codebase legibility is the first
instance, but the discipline (two-model + cross-check + on-demand
surfacing) generalises to other domains. Future agents may apply it
to governance artefacts, decision records, or other complex systems.

## Install

```bash
# In Claude Code
claude plugin install diagnostic-legibility@ai-literacy-superpowers

# In Copilot CLI
copilot plugin install diagnostic-legibility@ai-literacy-superpowers
```

The plugin will install successfully but offer no commands at v0.1.0.
Wait for S2 (#331) to land before expecting functional behaviour.

## Sister plugins in the same marketplace

- [`ai-literacy-superpowers`](../ai-literacy-superpowers/) — the flagship. Harness engineering, agent orchestration, the decision-discipline triad (carpaccio, advocatus-diaboli, choice-cartographer), CUPID code review, compound learning.
- [`model-cards`](../model-cards/) — Mitchell-extended model card research and authoring.
