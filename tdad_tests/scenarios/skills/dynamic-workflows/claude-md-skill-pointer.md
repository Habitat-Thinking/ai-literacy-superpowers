---
component: dynamic-workflows
component_type: skill
tier: structural
---

# Scenario: both CLAUDE.md surfaces point to the dynamic-workflows skill (AC-7p / FR-7)

## Given

`CLAUDE.md` (repo root, read via `_repo_root(plugin_path) / "CLAUDE.md"`)
**and** `ai-literacy-superpowers/templates/CLAUDE.md` (read via
`plugin_path / "templates" / "CLAUDE.md"`). The repo-root `CLAUDE.md` is not
a plugin component; this scenario is filed against the `dynamic-workflows`
skill so the corpus can resolve a target.

## When

Each `CLAUDE.md` surface is read.

## Then

- **Each** file references `dynamic-workflows` (the skill name — a single
  wrap-safe token, asserted directly) **AND** a **trigger cue** so the pointer
  is meaningful, not a bare mention: one of `long-running` /
  `massively parallel` / `adversarial` / `workflow`. Keep `dynamic-workflows`,
  `long-running`, `massively parallel`, `highly structured` **unwrapped**; the
  test asserts the trigger cue as co-occurring tokens within each file.

## Rubric

Deterministic structural shadow of AC-7p / FR-7. Both CLAUDE.md surfaces — the
repo-root project conventions and the plugin's `templates/CLAUDE.md` (the
behavioural agent pointer that justifies the minor bump) — must carry a single
line directing agents to consult the `dynamic-workflows` skill when a task
looks long-running / massively parallel / highly structured / adversarial,
before reaching for a workflow. A bare mention of the skill name without a
trigger cue is insufficient: the pointer must tell an agent *when* to consult
the skill.

## Evaluation

Evaluated deterministically by
`tests/test_s7_docs_hook_copilot_structural.py`
(`TestS7ClaudeMdSkillPointer`). RED now because neither `CLAUDE.md` (repo
root) nor `ai-literacy-superpowers/templates/CLAUDE.md` references
`dynamic-workflows` — the skill pointer is absent from both.
