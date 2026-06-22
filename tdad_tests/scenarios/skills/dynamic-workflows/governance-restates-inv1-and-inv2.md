---
component: dynamic-workflows
component_type: skill
tier: structural
---

# Scenario: governance.md restates INV-1 and INV-2 in full (AC-4)

## Given

The file
`ai-literacy-superpowers/skills/dynamic-workflows/references/governance.md`.

## When

The file is read.

## Then

- **INV-1** is named and stated in full: ephemeral workflows propose, durable
  artefacts are human-curated. Workflows may **never** write the four durable
  artefacts directly — `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, and
  `MODEL_ROUTING.md` are each enumerated by name — and discoveries flow
  through the human-curation path `REFLECTION_LOG.md → human curates →
  AGENTS.md`.
- **INV-2** is named and stated in full: untrusted-content readers are
  quarantined — withheld high-privilege tools — so a subagent that reads
  untrusted input cannot also wield high-privilege capabilities.

## Rubric

This is the deterministic content check from AC-4 / FR-5. Each invariant must
be (a) named by its INV-1 / INV-2 label and (b) stated in full, not merely
referenced. For INV-1 the four durable artefacts must each be named and the
`REFLECTION_LOG.md → human → AGENTS.md` curation flow must be present — these
are the load-bearing specifics every later slice (S2–S7) references.

The scenario does not assert any CI grep firewall rule exists — that is the
S2 mechanisation of INV-1's *teeth* and is explicitly out of S1 scope. Here we
assert only that the invariants are restated for agents as readable knowledge.
