---
title: Diagnostic Legibility
---
# Diagnostic Legibility

Agents accountable for helping to maintain human understanding.

A sister plugin to [ai-literacy-superpowers](../ai-literacy-superpowers/index.md)
and [model-cards](../model-cards/index.md) in the same marketplace.

## Charter

The plugin's purpose is to host agents that are accountable for
maintaining human understanding of complex systems. The inaugural
agent (in development) builds two models of a codebase scope — one
for architectural moving parts, one for domain concepts — subjects
each to a challenge–refine cycle, then uses them to cross-check and
correct each other, producing mutually-corrected models that can be
surfaced on demand to a human.

The framing is deliberately broad: codebase legibility is the first
instance, but the discipline (two-model + cross-check + on-demand
surfacing) generalises to other domains. Future agents may apply it
to governance artefacts, decision records, or other complex systems.

## Status: v0.1.0 — scaffold only

This plugin is structurally complete and loadable but ships with no
functional agents or commands yet. The next three deliverables are
filed as separate issues:

- [#331](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/331) — S2: Two-model agent
- [#332](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332) — S3: Cross-check mechanism
- [#333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333) — S4: Surfacing interface

The carpaccio slicing that produced this decomposition is recorded at
[`docs/superpowers/slices/diagnostic-legibility-plugin.md`](../../superpowers/slices/diagnostic-legibility-plugin.md)
and traces back to parent issue
[#327](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/327).

## Quadrant pages

No tutorials, how-to guides, reference, or concept pages exist yet.
Per the project convention, each Diataxis quadrant folder will be
scaffolded when its first page is written. Watch the three deferred
issues above to see what lands when.
