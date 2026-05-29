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

## Status: v0.3.0 — working agent

The plugin ships the `diagnostic-legibility` agent. It accepts a
codebase scope, drafts an architectural model and a domain model
against the `LegibilityElement` schema, and runs a retained-challenge
single-pass cycle that fills `challenge_notes[]` on every element via
five named questions (boundary, evidence, confounders, confidence,
description integrity).

Cross-check and the `/diagnose` command remain ahead:

- ✅ [#331](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/331) — S2: Two-model agent (shipped v0.3.0)
- [#332](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332) — S3: Cross-check mechanism
- [#333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333) — S4: Surfacing interface (`/diagnose`)

The carpaccio slicing that produced this decomposition is recorded at
[`docs/superpowers/slices/diagnostic-legibility-plugin.md`](../../superpowers/slices/diagnostic-legibility-plugin.md)
and traces back to parent issue
[#327](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/327).

## Quadrant pages

- **How-to**: [Invoke the diagnostic-legibility agent](how-to/invoke-the-agent.md)
- **Concepts**: [The challenge-refine protocol](explanation/challenge-refine-protocol.md)

Tutorials and reference pages remain to be written; per the project
convention, each Diataxis quadrant folder is scaffolded when its first
page lands.
