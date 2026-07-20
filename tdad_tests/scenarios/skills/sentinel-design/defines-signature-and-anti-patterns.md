---
component: sentinel-design
component_type: skill
tier: structural
---

# Scenario: sentinel-design defines the signature, the near-miss gallery, and the anti-patterns

## Given

The `sentinel-design` skill (spec
`docs/superpowers/specs/2026-07-20-sentinel-agent-category-design.md`, §5.3) is
the authoring guidance for the sentinel agent category — the reference a human
or agent consults before designing a new agent that guards the human's
understanding and judgement. It documents the category so the next sentinel is
built deliberately rather than rediscovered.

## When

The skill file at
`ai-literacy-superpowers/skills/sentinel-design/SKILL.md` is read directly from
the filesystem.

## Then

**Frontmatter**:

- YAML frontmatter present with `name: sentinel-design` and a non-empty
  `description`.

**Content — the definition and the three-part signature** (§2, §3):

- States the **definition** of a sentinel: an agent whose primary purpose is to
  protect and support the understanding and judgement of the human.
- Defines all three signature criteria: **S1** (read-only trust boundary —
  denies Write/Edit, Bash permitted for read-only inspection), **S2** (advisory
  output a human disposes, no automated action), and **S3** (explicit epistemic
  honesty rule declaring the status of its claims).

**Content — the near-miss gallery** (§4):

- Names **code-reviewer** and **harness-auditor** as near-misses and explains
  that read-only-plus-advisory is *not sufficient* — the category turns on the
  object of care (the human's understanding) not the trust boundary.

**Content — design discipline and anti-patterns** (§5.3):

- States the **honesty-rule-before-detection-logic** discipline, cross-
  referencing the `cognitive-reservoir` skill's contested-vs-robust discipline.
- Lists the three **anti-patterns**: a sentinel that **scores the human**, that
  **persists a record of the human's state**, or that **gates automatically**
  has left the category.

## Rubric

Layer 1 structural scenario: every assertion is mechanically checkable by
reading the skill and matching against its section headings and key phrases.
The scenario passes only when the definition, the three signature criteria
(S1/S2/S3), the two near-miss agents, the honesty-rule-first discipline, and
the three anti-patterns are all present.
