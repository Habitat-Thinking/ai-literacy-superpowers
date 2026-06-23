---
component: reflect
component_type: command
tier: structural
---

# Scenario: the --mine section declares the staging candidate shape and the gitignored / regenerated-each-run lifecycle (AC-6 / FR-4, FR-7)

## Given

The mining-mode section of
`ai-literacy-superpowers/commands/reflect.md`, and the repo-root `.gitignore`.

## When

The `--mine` section and `.gitignore` are read.

## Then

- The section declares the **`REFLECTION_STAGING.md` candidate shape**: each
  shortlist candidate carries the **proposed rule** / insight, its **source**
  reflection fragment(s) it clusters, and the adversarial-filter
  **verdict** / **evidence** ("would this have prevented a real mistake?" +
  the supporting evidence). Keep "proposed rule", "source", "verdict", and
  "evidence" each **unwrapped**; the content test asserts "rule", "source",
  "verdict"/"evidence" each as independent tokens on the lowercased section.
- The section states `REFLECTION_STAGING.md` is a **staging** / working area
  for human review — **not** the permanent record and **not** a durable
  curated artefact in the INV-1 sense. Keep "staging" and "permanent" each
  **unwrapped**; the content test asserts "staging" co-occurring with
  "not the permanent" (via "permanent") and "review".
- The section states the staging file is **gitignored** and **regenerated**
  (overwritten) each `--mine` run — the lifecycle decision (§6 decision 1,
  L1). Keep "gitignored" and "regenerated"/"regenerate" each **unwrapped**;
  the content test asserts "gitignore" co-occurring with
  "regenerate"/"regenerated"/"overwrite".
- The repo-root **`.gitignore`** contains a **`REFLECTION_STAGING.md`** entry
  (the lifecycle decision made concrete). Both `.gitignore` and
  `REFLECTION_STAGING.md` are single unwrappable tokens; the content test
  reads `.gitignore` and asserts the staging filename appears.

## Rubric

Deterministic structural shadow of AC-6 / FR-4 (candidate shape +
staging-not-permanent status) and the FR-7 lifecycle decision. The staging
file is the mining-loop analogue of the `reflections/active/` working set
(transient) versus `REFLECTION_LOG.md` (the committed aggregate) — except
staging is a proposal scratchpad, not a record at all. The contract fixes
*what each candidate must carry* (proposed rule + source fragment(s) +
adversarial verdict/evidence) and the *lifecycle* (repo-root, gitignored,
regenerated-each-run), not a frozen markdown schema.

The load-bearing specifics:

- each candidate is **traceable** — the source fragment(s) let the human
  trace a proposal back to the evidence, and only skeptic-affirmed candidates
  reach the shortlist;
- the staging file is a **scratchpad, then cleared** — gitignored and
  regenerated-each-run keeps ephemeral proposal churn out of the durable
  history INV-1 protects, mirroring the plugin's other gitignored
  working-draft artefacts (affordance-discovery, cost-estimates, diagnose
  output). The promotion (the `Promoted:` line on the source fragment) is the
  durable record, not the staging file.

## Evaluation

Evaluated deterministically by
`tests/test_s6_reflection_mining_structural.py`
(`TestS6ReflectStagingShapeAndLifecycle` and
`TestS6GitignoreHasStagingEntry`). RED now because the mining-mode section
does not exist (candidate-shape and lifecycle phrases absent) and the
repo-root `.gitignore` has no `REFLECTION_STAGING.md` entry (`grep -n
REFLECTION_STAGING .gitignore` returns nothing).
