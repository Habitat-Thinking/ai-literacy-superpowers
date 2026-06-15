---
name: reflect
description: Capture a reflection after completing work — what was surprising, what should future agents know, what could improve
---

# /reflect

Capture a post-task reflection as a per-entry fragment under
`reflections/active/`, then regenerate the aggregate `REFLECTION_LOG.md`.

Reflections use a **one-file-per-entry** storage model (see
`docs/superpowers/specs/2026-06-15-reflection-fragments-migration-design.md`):
each reflection is its own file, so two reflections authored concurrently
never touch the same path and can never be silently dropped at merge time.
`REFLECTION_LOG.md` is a generated, committed aggregate of the fragments —
never edit it by hand.

## Process

1. Ask the user (or review the current session context) for:
   - What was just worked on (one sentence)
   - What was surprising or unexpected
   - What should future agents know about this area of the codebase

1. Format the entry:

   ```text
   ---

   - **Date**: [today's date in YYYY-MM-DD]
   - **Agent**: [you / the agent that did the work]
   - **Task**: [what was done]
   - **Surprise**: [what was unexpected]
   - **Proposal**: [what to add to AGENTS.md, or "none"]
   - **Improvement**: [what would make the process better]
   - **Signal**: [context | instruction | workflow | failure | none]
   - **Constraint**: [proposed constraint, or "none"]
   - **Session metadata**:
     - Duration: [estimated session duration, e.g. "45 min" or "unknown"]
     - Model tiers used: [e.g. "capable (30%), standard (70%)" or "unknown"]
     - Pipeline stages completed: [e.g. "5/5" or "spec-writer, tdd-agent, code-reviewer" or "unknown"]
     - Agent delegation: [full pipeline | partial | manual | unknown]
   ```

   **Session metadata rules:**

   - All session metadata fields are best-effort. Fill in what you
     know from the session you just completed. If a value is not
     determinable, use `"unknown"` — never omit the field.
   - **Duration**: Estimate from the session's start and end. If you
     do not track time, use `"unknown"`.
   - **Model tiers used**: If MODEL_ROUTING.md is configured and the
     session used multiple tiers, report the approximate distribution.
     Otherwise `"unknown"`.
   - **Pipeline stages completed**: If the orchestrator ran, list
     which agents were invoked. If the session was a single-agent
     interaction, note that.
   - **Agent delegation**: `"full pipeline"` if the orchestrator ran
     the full spec→TDD→implement→review→integrate pipeline;
     `"partial"` if some stages were skipped; `"manual"` if the
     developer worked without the pipeline; `"unknown"` if you cannot
     determine.

1. **Signal classification** — review the Surprise and Improvement
   fields and classify the signal type:

   | Signal | When to use | Routes to |
   | --- | --- | --- |
   | `context` | Gap in priming — missing convention, outdated stack info, incomplete domain knowledge | HARNESS.md Context section |
   | `instruction` | A prompt or command produced notably better or worse results | Skills or shared commands |
   | `workflow` | A sequence or process pattern reliably succeeded or failed | AGENTS.md (STYLE, ARCH_DECISIONS) |
   | `failure` | A preventable error — missing check, wrong tool config, boundary condition | Constraints via `/harness-constrain` |
   | `none` | No classifiable signal — routine work, nothing novel | No routing needed |

   - Propose the signal type to the user with a one-sentence rationale
   - The user confirms or overrides the classification
   - If the signal is `failure`, this feeds directly into the
     auto-constraint step that follows

1. **Auto-constraint proposal** — review the Surprise and Improvement
   fields of the entry you just formatted:

   - If either field describes a preventable failure (e.g. a lint error
     that slipped through, a wrong branch, a missing check, a tool that
     should have caught something), offer to draft a constraint.
   - Propose the constraint to the user with:
     - **Rule**: one-sentence description of what the constraint enforces
     - **Enforcement**: `deterministic` or `agent`
     - **Tool**: the command or tool that checks it (if known)
     - **Scope**: when it runs (e.g. `commit`, `pr`, `session-end`)
   - If the user **accepts**, invoke `/harness-constrain` with the
     proposed rule, enforcement type, tool, and scope. Record the
     constraint in the reflection entry:
     `- **Constraint**: [short description] ([enforcement type])`
   - If the user **declines**, record:
     `- **Constraint**: none`
   - If neither field describes a preventable failure, skip this step
     and record:
     `- **Constraint**: none`

1. Write the entry as a **fragment file**. Derive a short kebab-case
   slug from the Task (lowercase, hyphen-separated, ≤6 words) and write
   the entry **body only** (no leading `---` separator) to:

   ```text
   reflections/active/<YYYY-MM-DD>-<slug>.md
   ```

   If a file with that name already exists (another reflection the same
   day), append a numeric suffix: `<date>-<slug>-2.md`, `-3.md`, etc.

   Then regenerate the aggregate so readers see the new entry:

   ```bash
   bash ai-literacy-superpowers/scripts/regenerate-reflection-log.sh
   ```

   If that script is not present in the project, regenerate by hand:
   write `REFLECTION_LOG.md` as its existing header followed by each
   `reflections/active/*.md` fragment (Date order) separated by `---`.

1. **Validate the reflection entry.** Read the fragment you just wrote
   and verify its structure against the entry template in step 2 above.

   **Structural checks:**

   1. Fragment body starts directly with the `- **Date**:` line (no
      leading `---` separator — that belongs only to the aggregate)
   2. All 8 mandatory fields present: Date, Agent, Task, Surprise,
      Proposal, Improvement, Signal, Constraint
   3. Session metadata block present with all 4 subfields: Duration,
      Model tiers used, Pipeline stages completed, Agent delegation
   4. Signal field value is one of: `context`, `instruction`,
      `workflow`, `failure`, `none`

   If any check fails, fix the entry in place:

   - Add missing fields with `"unknown"` values
   - Add missing session metadata subfields with `"unknown"`
   - If Signal value is not in the enum, set it to `none`

   Do not ask the user to re-enter the reflection. Fix the output
   directly.

1. Do NOT modify `AGENTS.md` — only humans edit that file. If the
   reflection contains a proposal, note it and let the human decide.

1. Commit the new fragment and the regenerated aggregate.

   Check whether the project declares a "Reflections via PR workflow"
   constraint (or equivalent) in `HARNESS.md`. If yes, use a branch and
   a labelled PR; if not, commit directly to the current branch.

   **PR workflow (when the constraint is declared):**

   ```bash
   slug="<short-slug-derived-from-task>"
   git checkout -b "add-reflection-${slug}"
   git add reflections/active/ REFLECTION_LOG.md
   git commit -m "Add reflection: <one-line summary of the task>"
   git push -u origin "add-reflection-${slug}"
   gh pr create --label chore \
     --title "Add reflection: <one-line summary of the task>" \
     --body "<short body summarising the surprise + signal classification>"
   ```

   Pass `--label chore` directly on `gh pr create` (per the "Label PRs
   at creation time" constraint, where present) so the PR is exempt
   from spec-first-commit-ordering and adjudicated-objections gates
   that would otherwise block a docs-only reflection PR. Wait for CI
   to pass, then merge with
   `gh pr merge <n> --squash --delete-branch` and `git pull` on main.

   **Direct commit (when the constraint is not declared):**

   ```bash
   git add reflections/active/ REFLECTION_LOG.md
   git commit -m "Add reflection: <one-line summary of the task>"
   ```

## Promoting an entry (curator action, post-reflection)

When you later promote this reflection's content to `AGENTS.md` or
`HARNESS.md`, add a `Promoted` line to this entry's **fragment file**
(`reflections/active/<date>-<slug>.md`) **in the same commit** as the
AGENTS.md/HARNESS.md edit, then regenerate the aggregate with
`scripts/regenerate-reflection-log.sh`. The line follows the grammar in
`docs/superpowers/specs/2026-04-30-reflection-log-archival-design.md`
(Schema change → Formal grammar). Examples:

```text
- **Promoted**: 2026-05-15 → AGENTS.md STYLE: "Multi-repo scheduled agents"
- **Promoted**: 2026-05-15 → CLAUDE.md "Treat ports as the domain boundary"
- **Promoted**: 2026-05-15 → src/renderer/CLAUDE.md "Wrap at column 80"
- **Promoted**: 2026-05-15 → HARNESS.md: Reflections via PR workflow
- **Promoted**: 2026-05-15 → .claude/HARNESS.md: Reflections via PR workflow
- **Promoted**: 2026-05-15 → aged-out, no promotion warranted
```

The Path 1 weekly GC rule auto-archives fragments with verified Promoted
lines — moving them to `reflections/archive/<YYYY>.md` and regenerating
the aggregate; you do not need to move the entry yourself.
