---
component: component-design-with-tdad
component_type: skill
tier: structural
---

# Scenario: component-design-with-tdad declares the five design questions

## Given

The skill at `ai-literacy-superpowers/skills/component-design-with-tdad/SKILL.md`
is the methodology guidance loaded by `spec-writer`, `tdd-agent`, or
human brainstorming when designing a new plugin component.

The skill's load-bearing claim (per the introducing PR #314 and
issue #313) is that it names *five* design questions implied by the
four-layer TDAD architecture, structured so a designer can work
through them in order before any agent dispatch.

## When

The skill is loaded into a session (via `Skill` tool invocation, an
agent's `description` match, or a human reading the file directly)
during the design pass for a new component.

## Then

The skill's `SKILL.md` must satisfy the following structural
assertions:

- **YAML frontmatter present** with both `name: component-design-with-tdad`
  and a non-empty `description` field — required by the
  `All frontmatter has name and description` HARNESS constraint.
- **Body contains five distinct design questions**, each surfaced as
  an `### N. ...` heading where `N` is the question number:
  1. What component type is this?
  2. Which TDAD layers does this component warrant?
  3. What does the scenario's `Then` clause look like?
  4. New file or modification of an existing component?
  5. Scenario or finding?
- **Each question section answers in plain prose** with at least one
  concrete heuristic, table, or list — a question section without an
  actionable answer fails the discipline the skill teaches.
- **Body declares the canonical output shape** — a `## Component design`
  template that the spec-writer carries into specs verbatim. Without
  the template, the skill is documentation; with it, the skill is a
  load-bearing contract on the spec format.
- **Body links to the existing surfaces** the design intelligence
  builds on: the TDAD docs page, `tdad_tests/README.md`, the
  introducing spec, `command-tdad-testing-design.md`, and the
  `plugin-dev` plugin's component-authoring skills.

## Rubric

This is a structural (Layer 1) scenario; the assertions above are
mechanically checkable by reading the SKILL.md file and matching
against the frontmatter, headings, and link targets. A future
Layer 3 (behavioural) scenario could verify that an LLM session
loaded with this skill, when asked to design a hypothetical
component, surfaces all five questions and emits the
`## Component design` section in the spec it produces — that
behavioural verification is deferred case-by-case per the
companion spec
[`docs/superpowers/specs/2026-05-09-command-tdad-testing-design.md`](../../../../docs/superpowers/specs/2026-05-09-command-tdad-testing-design.md)
Amendment 1 (Layer 3 for skills is case-by-case, opt-in per skill).

For Layer 1, the scenario passes if all five structural assertions
in the `Then` section can be verified by inspection of the SKILL.md.

## Notes

- This scenario is intentionally Layer 1 only. The skill's value is
  in *naming the questions* — the answers (which tier, which type,
  etc.) are answered by the designer, not by the skill. A Layer 3
  test asserting that the skill produces correct answers would test
  the LLM's design judgement, which is out of scope.
- The scenario was authored as part of the skill's own introducing
  PR (#314) — the first opportunity to apply the discipline to
  ourselves rather than exempt under the v0.36.0 forward-only
  stance. The recursive case the introducing spec anticipated is
  here demonstrated rather than waved away.
