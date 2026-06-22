---
component: assessor
component_type: agent
tier: structural
---

# Scenario: the workflow-mode section preserves the timestamped-artefact output and states the precise INV-1 boundary (AC-9, AC-11 / FR-9, FR-11)

## Given

The file
`ai-literacy-superpowers/agents/assessor.agent.md` — its workflow-mode
section and its frontmatter `tools`.

## When

The agent doc is read.

## Then

- The workflow-mode section states the output **remains a timestamped
  artefact in the existing location/format** — the word "timestamped"
  appears, and the existing location `assessments/` (i.e.
  `assessments/YYYY-MM-DD-assessment.md`) is named. Workflow mode changes
  *how* the report is produced (fan-out + verify), not *what* it is or
  *where* it lands.
- The section states the **`*.workflow.js` workflow itself proposes
  findings only** and **never writes a durable curated artefact** — the
  word "durable" co-occurs with a propose-only statement and with **at
  least two** of the four named artefacts `HARNESS.md`, `AGENTS.md`,
  `CLAUDE.md`, `MODEL_ROUTING.md`. The prohibition is on **those four**.
- The frontmatter `tools` **retains** `Write` and `Edit` — the assessor
  **legitimately writes its own assessment report** (which is **not** one
  of the four durable curated artefacts). Workflow mode must **not** be
  read as forbidding the assessor from writing its assessment. This stays
  GREEN.

## Rubric

Deterministic structural assertion of AC-9 (output invariant) and AC-11
(the precise INV-1 boundary). The honest hazard the spec flags (§9) is
**over-restricting** the assessor: INV-1 forbids only the four durable
curated artefacts, **not** the assessment doc. So this scenario asserts two
things in tension — (a) the workflow proposes findings only and never writes
the four curated artefacts, and (b) the assessor **keeps** its `Write`/`Edit`
tools for its own report. A scenario that forbade the assessor from writing
its assessment would be wrong; this one does not.

The durable-curated prohibition is asserted as the word "durable" plus a
propose-only term plus ≥2 of the four named artefacts co-occurring, so a
reasonable line-wrap of the four-artefact list still passes while keeping the
assertion load-bearing (not a single trivially-satisfiable keyword).

## Evaluation

Evaluated deterministically by
`tests/test_s4_adversarial_deepresearch_structural.py`
(`TestS4AssessorWorkflowMode`). The output-invariant and durable-curated
declarations are RED now (no workflow-mode section); the Write/Edit-retained
tool assertion is GREEN now and stays green.
