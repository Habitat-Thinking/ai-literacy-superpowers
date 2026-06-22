---
component: harness-enforcer
component_type: agent
tier: structural
---

# Scenario: the fan-out + skeptic + synthesis-barrier + template adaptation are declared (AC-6 / FR-4, FR-7, FR-8)

## Given

The file
`ai-literacy-superpowers/agents/harness-enforcer.agent.md`.

## When

The workflow-mode section is read.

## Then

The section declares **all** of the following (this is the structural
shadow of the runtime AC-1 fan-out behaviour):

- **Fan-out, one verifier per rule** — one verifier subagent **per
  HARNESS.md rule**, each in its own clean context window (the phrase
  "one verifier per rule" / "per rule" / "per HARNESS.md rule" appears).
- **Skeptic persona** — a skeptic persona that **adversarially reviews
  each candidate violation** to suppress false positives (the word
  "skeptic" appears).
- **Synthesis barrier waiting for all N** — a synthesis barrier that waits
  for **all N** verifier results before any report can form, with no
  "good enough" early stop (the phrase "synthesis barrier" and "all N" /
  "all-N" appear).
- **Template adaptation by relative path** — the section references
  `enforcer-fanout.workflow.js` **by relative path** and states the
  enforcer **ADAPTs** it per run (prompts, per-role model tiers, token
  budget) rather than running it verbatim (the words "adapt"/"ADAPT" and
  the relative path containing `enforcer-fanout.workflow.js` both appear,
  with the path being a relative reference under the
  `dynamic-workflows` skill, not a bare filename).
- **First-run REFLECTION_LOG obligation** — the skeptic
  false-positive-reduction observation is recorded once in
  `REFLECTION_LOG.md` on first run (the phrase "REFLECTION_LOG" and
  "first run" / "first time" appear together with the skeptic claim).

## Rubric

Deterministic structural assertion (AC-6) — the honest deterministic
shadow of the runtime fan-out (AC-1) and the skeptic effect (AC-2). What a
file read can verify is that the agent doc *declares* the fan-out shape,
the skeptic pass, the all-N synthesis barrier, the ADAPT-by-relative-path
relationship to the S2 template, and the first-run REFLECTION_LOG
obligation. It cannot verify a live run spawns exactly N verifiers — that
is AC-1, agent-backed.

Two boundary conditions the check must honour:

- The template reference must be a **relative path** (ADAPT, not edit) —
  consistent with the AGENTS.md "a consumer never mutates the contract it
  consumes" decision; S3 points at but never edits the S2 template.
- The first-run REFLECTION_LOG obligation must be stated as the route the
  *observation* takes — it must **not** be phrased as a deterministic
  guarantee that a false-positive reduction is CI-checkable (§6 decision
  3). The reduction itself stays agent-backed/observational.

## Evaluation

Evaluated deterministically by
`tests/test_s3_enforcer_fanout_structural.py`. RED now: the agent doc has
no workflow-mode section and never mentions "skeptic", "synthesis
barrier", "enforcer-fanout.workflow.js", or the first-run REFLECTION_LOG
obligation.
