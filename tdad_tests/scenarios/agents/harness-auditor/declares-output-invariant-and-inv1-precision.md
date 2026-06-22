---
component: harness-auditor
component_type: agent
tier: structural
---

# Scenario: the workflow-mode section preserves the existing HARNESS.md-Status + README-badge output and states the precise INV-1 boundary (AC-9, AC-11 / FR-9, FR-11)

## Given

The file
`ai-literacy-superpowers/agents/harness-auditor.agent.md` — its
workflow-mode section and its frontmatter `tools`.

## When

The agent doc is read.

## Then

- The workflow-mode section states the output **remains a timestamped
  artefact in the existing location/format** — the word "timestamped"
  appears — and that the auditor's existing write targets are the
  **HARNESS.md Status section** and the **README badge** ("status" and
  "badge" both appear). Workflow mode keeps those exact write targets and
  formats.
- The section states the **`*.workflow.js` workflow itself proposes
  findings only** and **never writes a durable curated artefact** — the
  word "durable" co-occurs with a propose-only statement and with **at
  least two** of the four named artefacts `HARNESS.md`, `AGENTS.md`,
  `CLAUDE.md`, `MODEL_ROUTING.md`.
- The frontmatter `tools` **retains** `Write` and `Edit` — the auditor's
  existing, narrowly-scoped writes (the HARNESS.md Status section + the
  README badge line) are legitimate and unchanged. Workflow mode must
  **not** be read as forbidding them. This stays GREEN.

## Rubric

Deterministic structural assertion of AC-9 (output invariant) and AC-11
(the precise INV-1 boundary), for the auditor. The same over-restriction
hazard the spec flags (§9) applies: the auditor already (and only) writes
the HARNESS.md Status section and the README badge line — these are its
existing narrowly-scoped writes, **not** a full durable-artefact rewrite.
The *workflow* proposes findings only; the *agent* performs those two scoped
writes as today.

The durable-curated prohibition is asserted as the word "durable" plus a
propose-only term plus ≥2 of the four named artefacts co-occurring (wrap-safe
yet load-bearing). The Write/Edit-retained tool assertion guards against an
over-zealous workflow-mode edit stripping the auditor's legitimate writes.

## Evaluation

Evaluated deterministically by
`tests/test_s4_adversarial_deepresearch_structural.py`
(`TestS4HarnessAuditorWorkflowMode`). The output-invariant and
durable-curated declarations are RED now (no workflow-mode section); the
Write/Edit-retained tool assertion is GREEN now and stays green.
