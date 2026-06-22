---
component: dynamic-workflows
component_type: skill
tier: structural
fixture: dynamic-workflows/workflows
---

# Scenario: each template opens with a literate preamble (AC-1, AC-4, AC-12)

## Given

Each of the four `*.workflow.js` templates under
`skills/dynamic-workflows/workflows/`.

## When

The top-of-file comment block (the literate preamble, per Knuth discipline)
of each template is read.

## Then

- Each preamble NAMES the **pattern** it composes (one or more of the six:
  classify-and-act, fan-out-and-synthesize, adversarial verification,
  generate-and-filter, tournament, loop-until-done).
- Each preamble declares an explicit **token budget** (a per-workflow cap).
- Each preamble declares a **default model tier per agent role**.
- Each preamble names the **INV-1 boundary** it respects (the durable
  artefacts it may only *propose* to, never write).
- Each preamble states the **Claude-Code-only runtime scope** — that the
  template is inert reference material on a tree without the workflow runtime.

## Rubric

This is the deterministic preamble check from AC-1 / AC-4 / AC-12 and FR-2 /
FR-3. The structural form is greppable markers inside the leading comment
block; the Layer-0 bash test `test-workflow-templates.sh` asserts each marker
is present. A template that ships code without the literate preamble — or that
omits the token budget, the per-role tier, the INV-1 boundary, or the runtime
scope — is RED. Naming a durable artefact in this preamble is *correct* and
must never trip the INV-1 firewall (that false-positive guard is AC-8, covered
by `test-inv1-firewall.sh`). RED until the templates exist.
