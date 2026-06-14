---
component: reservoir
component_type: command
tier: structural
---

# Scenario: /reservoir offers Read and Tune modes and is never a gate

## Given

The `/reservoir` command (spec
`docs/superpowers/specs/2026-06-14-reservoir-warden-design.md`, FR-012) is the
on-demand entry point to the verifier-watch. It dispatches the read-only
`reservoir-warden` agent (Read mode) or helps the human edit the HARNESS.md
`Cognitive reservoir` block (Tune mode).

## When

The command file at `ai-literacy-superpowers/commands/reservoir.md` is read
directly from the filesystem.

## Then

**Frontmatter**:

- YAML frontmatter present with `name: reservoir` and a non-empty
  `description`.

**Modes** (FR-012):

- A **Read mode** section: checks the project has opted in (an active
  `## Cognitive reservoir` block), dispatches the `reservoir-warden` agent, and
  presents its report verbatim — no fatigue score, no second nudge added.
- A **Tune mode** section: walks the tunable fields (`window_hours`,
  `span_minutes`, `decision_volume`, `context_switches`, and the optional
  `chronotype`), and **proposes edits for the human to confirm** before writing
  — the human owns the block.

**Validation checkpoint**:

- A validation step that, after a Tune-mode write, reads the block back and
  verifies the `## Cognitive reservoir` marker is intact, the keys are
  recognised, numeric values are positive integers, and the not-a-constraint
  note is present (per the Output Validation Checkpoints convention).

**Not a gate**:

- The command states the mechanism is **advisory-only and not a Constraint** —
  it never blocks, never scores, and records no claim about the human's state.

## Rubric

Layer 1 structural scenario: every assertion is mechanically checkable by
reading the command file and matching its section headings. The scenario passes
only when both modes, the propose-then-confirm Tune flow, the validation
checkpoint, and the not-a-gate statement are present.
