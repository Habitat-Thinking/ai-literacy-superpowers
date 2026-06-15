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
agent builds two models of a codebase scope — one for architectural
moving parts, one for domain concepts — subjects each to a
challenge–refine cycle, then uses them to cross-check and correct each
other, producing mutually-corrected models that can be surfaced on
demand to a human.

The framing is deliberately broad: codebase legibility is the first
instance, but the discipline (two-model + cross-check + on-demand
surfacing) generalises to other domains. Future agents may apply it
to governance artefacts, decision records, or other complex systems.

## Status: v0.11.0 — task-scoped pipeline maps with change-site prediction

The plugin ships the `diagnostic-legibility` agent and two human-facing
commands. The agent builds an architectural model and a domain model
against the `LegibilityElement` schema, runs a retained-challenge cycle
(Phase B — five questions per element), then cross-checks the collections
against each other (Phase C). `/diagnose <scope>` drives that pipeline for
a code area you hand it and renders the corrected models as a readable
report.

Since then the **task-scoped pipeline map** (`ConceptualPipelineMap`) has
been added: instead of handing in a scope, you state a **work task** and
the agent *derives* the bounded slice it touches (`mode: scope-resolution`,
v0.7.0), traces the control flow within it (`mode: pipeline`, v0.8.0),
cross-checks the flow against the architectural and domain models
(three-way, v0.9.0), and predicts which nodes the task will edit
(`mode: change-prediction`, v0.11.0). The **`/pipeline-map "<task>"`**
command (v0.10.0) renders all of this as a self-contained HTML flow map,
and **`/pipeline-map "<task>" --predict-change`** adds the change-site
prediction. New here? Start with
[Explore the scope and impact of a change](tutorials/explore-scope-and-impact.md).

The full carpaccio decomposition is now shipped:

- ✅ [#331](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/331) — S2: Two-model agent (shipped v0.3.0)
- ✅ [#332](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332) — S3: Cross-check mechanism (shipped v0.4.0)
- ✅ [#333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333) — S4: Surfacing interface — the `/diagnose` command (shipped v0.5.0)

The carpaccio slicing that produced this decomposition is recorded at
[`docs/superpowers/slices/diagnostic-legibility-plugin.md`](../../superpowers/slices/diagnostic-legibility-plugin.md)
and traces back to parent issue
[#327](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/327).

## Quadrant pages

- **Getting Started**:
  - [Explore the scope and impact of a change](tutorials/explore-scope-and-impact.md) — the end-to-end key workflow, step by step (`/pipeline-map` + `--predict-change`)
- **How-to**:
  - [Run the `/pipeline-map` command](how-to/run-the-pipeline-map-command.md) — render a task-scoped flow map; `--predict-change` predicts the edit sites (v0.10.0–v0.11.0)
  - [Resolve a task's scope](how-to/resolve-task-scope.md) — the "what does my task touch?" surface (v0.7.0)
  - [Run the `/diagnose` command](how-to/run-the-diagnose-command.md) — the area-scoped human-facing surface (v0.5.0)
  - [Invoke the diagnostic-legibility agent](how-to/invoke-the-agent.md) — the bare-Task-tool dispatch
- **Reference**:
  - [The `/pipeline-map` command](reference/pipeline-map-command.md) — signature, render contract, Mermaid vendoring, change-site prediction (v0.10.0–v0.11.0)
  - [The `/diagnose` command](reference/diagnose-command.md) — signature, dispatch contract, report structure (v0.5.0)
- **Concepts**:
  - [The challenge-refine protocol](explanation/challenge-refine-protocol.md) — Phase B self-challenge
  - [The cross-check protocol](explanation/cross-check-protocol.md) — Phase C mutual correction (v0.4.0)
