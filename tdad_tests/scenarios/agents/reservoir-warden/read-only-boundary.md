---
component: reservoir-warden
component_type: agent
tier: structural
---

# Scenario: reservoir-warden is read-only on the human — tool boundary and charter

## Given

The `reservoir-warden` agent (spec
`docs/superpowers/specs/2026-06-14-reservoir-warden-design.md`) watches the
one actor the harness cannot verify: the human verifier. It counts observable
proxies and, if a threshold is crossed, returns a single advisory. It is
**advisory-only** and **read-only on the human**: the discipline is that it
never persists a record of the human's state.

This scenario fixes the structural contract the agent file must satisfy
(Scenario F; FR-002, FR-003, FR-011).

## When

The agent file at
`ai-literacy-superpowers/agents/reservoir-warden.agent.md` is read directly
from the filesystem.

## Then

**Frontmatter** (FR-003):

- YAML frontmatter present with `name: reservoir-warden` and a non-empty
  `description`.
- The `tools` declaration is **exactly** `Read, Glob, Grep, Bash` — and
  contains **no** `Write` and **no** `Edit`. This is the load-bearing
  trust-boundary decision: the agent cannot persist a record of the human's
  state, so the read-only-on-the-human discipline is enforced by the tool
  list, not by good intentions.

**Charter / body** (FR-002, FR-011):

- The body instructs the agent to read the `cognitive-reservoir` skill
  (`ai-literacy-superpowers/skills/cognitive-reservoir/SKILL.md`) **first** and
  to inherit its grounding rather than re-derive it.
- The body states the agent gathers proxies via `git`/`date` (Bash) and Grep
  only, and reports each proxy with an `observed` / `inferred` / `asked` flag.
- The body states the agent **never persists a record of the human's state,
  breaks, or chronotype to disk**, and that tuning suggestions are returned as
  text for the human to apply themselves.
- The body states the report contains **no combined fatigue score** and that
  every `inferred` claim sits on an `observed` proxy.
- The honesty gate is present: the agent does **not** assert ego depletion and
  does **not** quote the hungry-judges figure; triggers are framed as a
  precaution under uncertainty.

## Rubric

Layer 1 structural scenario: every assertion is mechanically checkable by
reading the agent file and matching against its frontmatter `tools` list and
its body headings. The scenario passes only when the tool boundary is exactly
`Read, Glob, Grep, Bash` (no Write, no Edit), the agent reads the
`cognitive-reservoir` skill first, the no-persistence and no-fatigue-score
disciplines are stated, and the honesty gate is present.

## Notes

Scope is the agent's structural shape only. Behavioural assertions about the
proxy values it computes are covered by the hook scenarios (the hook and agent
share the skill's proxy definitions).
