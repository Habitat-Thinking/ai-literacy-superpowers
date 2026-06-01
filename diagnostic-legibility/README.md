# diagnostic-legibility

Agents accountable for helping to maintain human understanding.

A sister plugin to [ai-literacy-superpowers](../ai-literacy-superpowers/)
and [model-cards](../model-cards/) in the same marketplace.

## Status

**v0.5.0 — on-demand `/diagnose` command.** The plugin ships the
`diagnostic-legibility` agent (parent S2 / S3) and the human-facing
`/diagnose` command (parent S4) that surfaces its output. The agent
accepts a codebase scope, drafts an architectural model and a domain
model against the `LegibilityElement` schema, runs a retained-challenge
single-pass cycle (Phase B — five questions per element), then
cross-checks the two collections against each other (Phase C — five
cross-check questions per direction with direction-flavoured
weighting). Each element carries both `Q<N>` and `CC<N>` entries in
its `challenge_notes[]`; the wrapper carries a `cross_check_status`
field recording the model-level outcome. `/diagnose <scope>` drives the
full pipeline and renders the corrected models as a readable report.

The full carpaccio decomposition is now shipped:

- ✅ [#331](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/331) — S2: Two-model agent with per-model self-challenge (shipped v0.3.0)
- ✅ [#332](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332) — S3: Cross-check mechanism (shipped v0.4.0)
- ✅ [#333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333) — S4: Surfacing interface — the `/diagnose` command (shipped v0.5.0)

## Available agents

- **`diagnostic-legibility`** (at `agents/diagnostic-legibility.agent.md`)
  — see the [how-to](../docs/plugins/diagnostic-legibility/how-to/invoke-the-agent.md)
  and the [challenge-refine concept page](../docs/plugins/diagnostic-legibility/explanation/challenge-refine-protocol.md).

## Available commands

- **`/diagnose <scope> [--out <dir>]`** (at `commands/diagnose.md`) —
  surfaces the mutually-corrected models for a scope as a readable
  report. See the
  [how-to](../docs/plugins/diagnostic-legibility/how-to/run-the-diagnose-command.md)
  and the
  [reference](../docs/plugins/diagnostic-legibility/reference/diagnose-command.md).

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

At v0.5.0 the plugin is driven through the `/diagnose <scope>` command,
which dispatches the `diagnostic-legibility` agent in `mode: full` and
renders the corrected models as a report — see the
[how-to](../docs/plugins/diagnostic-legibility/how-to/run-the-diagnose-command.md).
The agent also remains dispatchable directly via Claude Code's bare
Task tool — see the
[agent how-to](../docs/plugins/diagnostic-legibility/how-to/invoke-the-agent.md)
for the invocation pattern. Two mode markers are recognised:
`mode: full` (default — Phase A construct + Phase B self-challenge +
Phase C cross-check) and `mode: cross-check-only` (Phase C against a
fenced YAML payload, for round-trip use; not exposed through
`/diagnose`).

## Sister plugins in the same marketplace

- [`ai-literacy-superpowers`](../ai-literacy-superpowers/) — the flagship. Harness engineering, agent orchestration, the decision-discipline triad (carpaccio, advocatus-diaboli, choice-cartographer), CUPID code review, compound learning.
- [`model-cards`](../model-cards/) — Mitchell-extended model card research and authoring.
