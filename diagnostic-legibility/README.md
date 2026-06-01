# diagnostic-legibility

Agents accountable for helping to maintain human understanding.

A sister plugin to [ai-literacy-superpowers](../ai-literacy-superpowers/)
and [model-cards](../model-cards/) in the same marketplace.

## Status

**v0.4.0 — working agent with cross-check.** The plugin ships the
`diagnostic-legibility` agent (parent S2 / S3). The agent accepts a
codebase scope, drafts an architectural model and a domain model
against the `LegibilityElement` schema, runs a retained-challenge
single-pass cycle (Phase B — five questions per element), then
cross-checks the two collections against each other (Phase C — five
cross-check questions per direction with direction-flavoured
weighting). Each element carries both `Q<N>` and `CC<N>` entries in
its `challenge_notes[]`; the wrapper carries a `cross_check_status`
field recording the model-level outcome.

The human-facing `/diagnose` surfacing command remains ahead:

- ✅ [#331](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/331) — S2: Two-model agent with per-model self-challenge (shipped v0.3.0)
- ✅ [#332](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332) — S3: Cross-check mechanism (shipped v0.4.0)
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

At v0.4.0 the `diagnostic-legibility` agent is dispatchable via
Claude Code's bare Task tool — see the
[how-to](../docs/plugins/diagnostic-legibility/how-to/invoke-the-agent.md)
for the invocation pattern. Two mode markers are recognised:
`mode: full` (default — Phase A construct + Phase B self-challenge +
Phase C cross-check) and `mode: cross-check-only` (Phase C against a
fenced YAML payload, for round-trip use). A wrapping `/diagnose`
slash-command remains deferred to parent S4
([#333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333)).

## Sister plugins in the same marketplace

- [`ai-literacy-superpowers`](../ai-literacy-superpowers/) — the flagship. Harness engineering, agent orchestration, the decision-discipline triad (carpaccio, advocatus-diaboli, choice-cartographer), CUPID code review, compound learning.
- [`model-cards`](../model-cards/) — Mitchell-extended model card research and authoring.
