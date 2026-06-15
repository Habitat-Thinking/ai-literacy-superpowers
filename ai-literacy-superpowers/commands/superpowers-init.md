---
name: superpowers-init
description: Set up the complete AI Literacy framework habitat for this project — discover the stack, define conventions, scaffold harness, agent team, compound learning, and CI templates
---

# /superpowers-init

Bootstrap the full AI Literacy habitat for this project. Run this once when
bringing a new project into the framework. It is safe to re-run — existing
files are not overwritten unless you confirm.

## What this command does

It walks through nine steps in sequence:

### 1. Discover

Analyse the repository to understand:

- Primary language(s) and build tooling
- Existing CI configuration (GitHub Actions, GitLab CI, etc.)
- Test framework(s) already in use
- Whether CLAUDE.md, AGENTS.md, MODEL_ROUTING.md already exist
- Whether a harness (hooks + scripts) is already configured

Use Read, Glob, and Grep for this. Do not run build commands.

### 2. Present

Show the user a discovery summary before making any changes:

- Detected stack and conventions
- Files that will be created
- Files that already exist (will be skipped unless overwrite is confirmed)

Ask the user to confirm before proceeding.

### 3. Conventions

Create or update CLAUDE.md from the template at
`${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md`.

Fill in the placeholders based on the detected stack:

- Language-specific linting and formatting commands
- Test runner command
- Build command
- Any project-specific constraints discovered in step 1

Apply the context-engineering skill to ensure CLAUDE.md is structured as a
high-signal harness document, not a dumping ground.

### 4. Constraints

If the project has existing conventions that differ from the template defaults,
capture them as explicit constraints in CLAUDE.md. Use the constraint-design
skill to evaluate whether each constraint is worth the cognitive cost it imposes.

### 5. Agent team

Create AGENTS.md from the template at `${CLAUDE_PLUGIN_ROOT}/templates/AGENTS.md`.

Scaffold MODEL_ROUTING.md from `${CLAUDE_PLUGIN_ROOT}/templates/MODEL_ROUTING.md`.

Copy the generic agent files from `${CLAUDE_PLUGIN_ROOT}/agents/` into the
project's `.claude/agents/` directory:

- orchestrator.md
- spec-writer.md
- tdd-agent.md
- code-reviewer.md
- integration-agent.md

Do not overwrite existing agent files without confirmation.

### 6. Garbage collection

Apply the garbage-collection skill to identify any stale, redundant, or
contradictory content in existing CLAUDE.md and AGENTS.md files before
continuing. Present findings to the user — do not auto-delete.

### 7. Scaffold

Copy CI templates from `${CLAUDE_PLUGIN_ROOT}/templates/`:

- `ci-github-actions.yml` → `.github/workflows/ai-literacy.yml`
  (only if the project uses GitHub Actions)
- `ci-generic.sh` → `scripts/ai-literacy-check.sh`
  (always — provides a language-agnostic verification script)
- `REFLECTION_LOG.md` (empty, generated header) to the project root if
  it does not exist, **and** create the `reflections/active/` directory
  (add a `.gitkeep`) that holds per-entry reflection fragments
- `gitattributes` → append/merge into the project root `.gitattributes`
  so the reflection surfaces use git's union merge driver (prevents
  silent loss of reflections under concurrent merges):

  ```gitattributes
  REFLECTION_LOG.md merge=union
  reflections/archive/*.md merge=union
  ```
- `HARNESS.md` → `.claude/HARNESS.md` if it does not exist

Use the harness-engineering skill to verify the scaffold is coherent before
presenting it to the user.

### 8. Validate Habitat Files

**This step is mandatory.** After all habitat files are generated,
read each one and verify its structure against the corresponding
template in `${CLAUDE_PLUGIN_ROOT}/templates/`.

**Structural checks per file:**

1. **CLAUDE.md**: has required sections `## Workflow`,
   `## Build and Test`, `## Learnings`
   (reference: `templates/CLAUDE.md`)
2. **AGENTS.md**: has required sections `## STYLE`, `## GOTCHAS`,
   `## ARCH_DECISIONS`, `## TEST_STRATEGY`, `## DESIGN_DECISIONS`
   (reference: `templates/AGENTS.md`)
3. **MODEL_ROUTING.md**: has required sections
   `## Agent Routing Table` (with markdown table),
   `## Token Budget Guidance` (with markdown table)
   (reference: `templates/MODEL_ROUTING.md`)
4. **REFLECTION_LOG.md**: exists and has the header comment
   containing the entry format template; `reflections/active/` exists;
   `.gitattributes` contains the `REFLECTION_LOG.md merge=union` rule

If any check fails, fix the file in place:

- Add missing sections from the corresponding template
- Do not overwrite existing content in sections that are already
  populated

Do not re-run the init conversation. Fix each file directly.

### 9. Commit and summary

Stage all new files and commit with a message in the form:

```text
Bootstrap AI Literacy habitat: conventions, agent team, harness, CI
```

Then present a summary to the user:

- Files created (list)
- Files skipped (already existed)
- Next steps: what to customise in CLAUDE.md, what to fill in AGENTS.md
- How to run `/superpowers-status` to check habitat health going forward

## What this command does NOT do

- It does not run builds, tests, or linters.
- It does not push to a remote or create a PR.
- It does not modify implementation code.
- It does not overwrite existing files without user confirmation.
