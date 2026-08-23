---
component: harness-assayer
component_type: agent
tier: structural
---

# Scenario: the Assayer never launders a planned command into evidence

## Given

Criterion S3 of the sentinel signature is an explicit epistemic honesty rule, and
each sentinel's is shaped by the failure its subject matter invites.

The Assayer's subject matter is build logs, which are full of commands that were
*going* to run. Treating a planned command as a passing one is a single, easy
inference — and it produces a report saying the harness is working when nobody
looked. That is the exact failure a harness exists to prevent, committed by the
thing auditing the harness.

The build spec also declares the Assayer a sentinel and then tells it to write
its own report. Those cannot both hold: `sentinel-integrity-check.sh` fails CI on
a `role: sentinel` agent granted `Write`, frontmatter tools are all-or-nothing,
and an Assayer that could write to `harness/assay/` could rewrite `HARNESS.md`.

## When

`ai-literacy-superpowers/agents/harness-assayer.agent.md` is read from the
filesystem.

## Then

**Frontmatter:** `name: harness-assayer`, `role: sentinel`, `tools` containing
`Read`, `Glob`, `Grep`, `Bash` and **neither `Write` nor `Edit`**.

**Body:**

- States the honesty rule verbatim: never claim a check, test or integration
  passed unless the result was observed; never convert a planned command from a
  build file into passing evidence.
- Carries the `observed` / `reported` / `inferred` flag table, and requires every
  `inferred` claim to sit on an `observed` one.
- States that conflicting evidence is marked **unresolved** rather than resolved
  in favour of the neater reading.
- States that an **absent source is absent, not empty** — naming the per-machine
  Mast store, and the difference between "nothing fired" and "nothing was
  recorded here".
- Explains the trust boundary as a design property, not an oversight: it returns
  report content as a string for `/harness-assay` to persist, on the
  `cost-estimator` and `coda` precedent, and says why scoped write access is not
  available.
- Carries the anti-proliferation rule **pointed at itself**, naming
  `/harness-audit`, `/governance-audit` and `/reflect`, and makes it enforceable:
  a finding one of those already reports is a rejected candidate with the owner
  named, and an assay that never rejects on those grounds has stopped checking.
- States that an assay in which every finding resolves to `no-change` is a
  **successful** assay.
- Names the failure mode as **productivity, not laziness** — a fluent,
  comprehensive report built on one unexamined inference — and instructs: six
  findings with evidence for two means two.

**Forbidden:** writing any file, drafting a decision record, modifying any
governance artifact, proposing a commit, or forward-testing its own proposals.
