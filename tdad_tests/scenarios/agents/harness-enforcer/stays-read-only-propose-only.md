---
component: harness-enforcer
component_type: agent
tier: structural
---

# Scenario: workflow mode is propose-only; the enforcer stays read-only (AC-9 / FR-10, INV-1)

## Given

The file
`ai-literacy-superpowers/agents/harness-enforcer.agent.md` — both its
frontmatter and its workflow-mode section.

## When

The frontmatter `tools` list and the workflow-mode section are read.

## Then

- The frontmatter `tools` list is **unchanged**: it contains exactly
  `Read`, `Glob`, `Grep`, `Bash` — and **no `Write`** and **no `Edit`**.
  (The literal `tools: ["Read", "Glob", "Grep", "Bash"]` is the current
  state; adding workflow mode must not widen it.)
- The workflow-mode section states workflow mode is **read-and-report
  only** / **propose-only**: the enforcer reads and reports, and any
  keep-worthy discovery flows through the human-curation gate
  `REFLECTION_LOG.md → human curates` (INV-1).
- The section states the workflow **never writes a durable artefact**
  (the phrase "never writes" / "does not write" tied to "durable
  artefact" appears) — the §D3 false-positive-reduction observation is
  recorded via the curation gate, not written by the workflow.

## Rubric

Deterministic structural assertion of the cross-cutting INV-1 boundary
(AC-9). Two surfaces are checked:

- **Frontmatter `tools`** — a hard, exact check: the set must remain
  `{Read, Glob, Grep, Bash}` with no write capability. This is the
  load-bearing INV-1 enforcement at the agent level: a read-only tool set
  makes a durable write impossible regardless of prose.
- **Prose** — the section must *declare* the propose-only boundary and the
  human-curation flow, so the contract is legible, not merely implied by
  the absent `Write` tool.

The firewall scope note (§9): the enforcer *reading* `HARNESS.md` (for
its threshold field) is an agent behaviour, not a `*.workflow.js` template
spelling a durable filename in executable code — so it is outside the
INV-1 firewall's scope and does not contradict the read-only boundary.

## Evaluation

Evaluated deterministically by
`tests/test_s3_enforcer_fanout_structural.py`. The `tools` exact-set
check passes today (the list is already correct) — but the prose
propose-only / "never writes a durable artefact" declaration is **absent**
(no workflow-mode section), so the scenario as a whole is RED until the
section is authored. This is RED for the right reason: the missing
declaration, not a malformed tools list.
