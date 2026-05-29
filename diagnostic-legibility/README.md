# diagnostic-legibility

Agents accountable for helping to maintain human understanding.

A sister plugin to [ai-literacy-superpowers](../ai-literacy-superpowers/)
and [model-cards](../model-cards/) in the same marketplace.

## Status

**v0.3.0 — working agent.** The plugin ships the
`diagnostic-legibility` agent (parent S2 / sub-S2b). The agent accepts
a codebase scope, drafts an architectural model and a domain model
against the `LegibilityElement` schema, and runs a retained-challenge
single-pass cycle that fills `challenge_notes[]` on every element
through five named questions (boundary, evidence, confounders,
confidence, description integrity).

Cross-checking the two models against each other and the human-facing
`/diagnose` surfacing command remain ahead:

- ✅ [#331](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/331) — S2: Two-model agent with per-model self-challenge (shipped v0.3.0)
- [#332](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332) — S3: Cross-check mechanism (mutual model correction)
- [#333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333) — S4: Surfacing interface (on-demand human legibility command)

## Available agents

- **`diagnostic-legibility`** (at `agents/diagnostic-legibility.agent.md`)
  — see the [how-to](../docs/plugins/diagnostic-legibility/how-to/invoke-the-agent.md)
  and the [challenge-refine concept page](../docs/plugins/diagnostic-legibility/explanation/challenge-refine-protocol.md).

The carpaccio slicing record at
[`docs/superpowers/slices/diagnostic-legibility-plugin.md`](../docs/superpowers/slices/diagnostic-legibility-plugin.md)
records the full decomposition from parent issue
[#327](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/327).

## Charter

The plugin's purpose is to host agents that are accountable for
maintaining human understanding of complex systems. The inaugural
agent builds two models of a codebase scope — one for architectural
moving parts, one for domain concepts — subjects each to a
challenge–refine cycle, then (in later slices) uses them to
cross-check and correct each other, producing mutually-corrected
models that can be surfaced on demand.

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

At v0.3.0 the `diagnostic-legibility` agent is dispatchable via
Claude Code's bare Task tool — see the
[how-to](../docs/plugins/diagnostic-legibility/how-to/invoke-the-agent.md)
for the invocation pattern. A wrapping `/diagnose` slash-command and
the cross-check between the two models are deferred to parent S4
([#333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333))
and parent S3
([#332](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332))
respectively.

## Sister plugins in the same marketplace

- [`ai-literacy-superpowers`](../ai-literacy-superpowers/) — the flagship. Harness engineering, agent orchestration, the decision-discipline triad (carpaccio, advocatus-diaboli, choice-cartographer), CUPID code review, compound learning.
- [`model-cards`](../model-cards/) — Mitchell-extended model card research and authoring.
