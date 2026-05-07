<!-- Generated from HARNESS.md, AGENTS.md, and REFLECTION_LOG.md.
     Do not edit directly — regenerate with /harness-onboarding. -->

# Welcome to ai-literacy-superpowers

This is a Claude Code and GitHub Copilot CLI plugin that provides the
AI Literacy framework's complete development workflow — harness
engineering, agent orchestration, literate programming, CUPID code
review, compound learning, and the three enforcement loops. You'll be
working with markdown skills, bash hook scripts, JSON configuration,
and YAML CI workflows. There is no compiled application code here; the
plugin's "code" is content that agents and tools read and execute. The
project is also a marketplace — `model-cards` is a sister plugin that
ships from the same repo with its own version line and tag convention.

---

## Tech Stack

- **Markdown** — the primary language. Skills, agents, commands,
  templates, and documentation are all markdown files with YAML
  frontmatter. Markdownlint enforces consistent formatting across
  every `.md` file.
- **Bash** — hook scripts and utility scripts. Every `.sh` file uses
  strict mode (`set -euo pipefail`) and passes ShellCheck.
- **JSON** — plugin configuration (`plugin.json`, `marketplace.json`)
  and hook registration (`hooks/hooks.json`).
- **YAML** — GitHub Actions CI workflows that enforce constraints on
  PRs and run weekly garbage collection.
- **No build system** — this is a plugin, not a compiled application.
  There is nothing to build or compile.
- **No test framework** — quality is enforced by linters and
  deterministic tools (markdownlint, gitleaks, ShellCheck, bash
  syntax checks), not by a test suite.

---

## How We Write Code

**Naming matters.** Skills live in `skills/<name>/SKILL.md` (the
directory is kebab-case, the file is always `SKILL.md`). Agents are
`<name>.agent.md`. Commands are `<name>.md`. Hook scripts are
`<name>.sh`. Everything is lowercase kebab-case except `SKILL.md`.

**One component per file.** Agents go in `agents/`, skills in
`skills/<name>/SKILL.md`, commands in `commands/`, hook scripts in
`hooks/scripts/`, templates in `templates/`, utility scripts in
`scripts/`. If you're adding something new, put it in the right
directory.

**Hook scripts are advisory only.** They warn but never block. Output
uses JSON `systemMessage` format so Claude Code surfaces the message
without interrupting the session. When writing a hook script, start
with `set -euo pipefail` and exit silently (`exit 0`) when the hook
doesn't apply.

**Everything needs frontmatter.** Every `.agent.md`, `SKILL.md`, and
command `.md` file must have YAML frontmatter with `name` and
`description` fields. Skills also need an Overview section. Bash
scripts need a header comment block explaining purpose and behaviour.

---

## What's Enforced

### At commit time

These checks warn you while you're editing. They're advisory — they
won't stop you from committing, but they'll flag problems early.

- **Markdown formatting** — all `.md` files must pass markdownlint.
  Run `npx markdownlint-cli2 "**/*.md"` locally to check.
- **No secrets** — no API keys, tokens, passwords, or private keys in
  source files. Gitleaks scans for these automatically.
- **Shell syntax** — all `.sh` files must pass `bash -n` syntax
  checking.
- **Strict mode** — every `.sh` file must contain `set -euo pipefail`
  within the first 15 lines.
- **ShellCheck** — all `.sh` files must pass ShellCheck with no
  errors.

### At PR time

These are CI gates that block merges. Your PR will not go green until
these pass.

- **Frontmatter completeness** — every agent, skill, and command file
  must have `name` and `description` in its frontmatter.
- **Spec-first ordering** — for feature PRs, the first commit must
  contain only a spec file in `docs/superpowers/specs/`. Bug-fix and
  maintenance PRs (labelled `bug`, `fix`, `chore`, `maintenance` or
  branch-prefixed `fix/`, `chore/`) are exempt.
- **Spec scoping** — each feature PR traces to a single spec. Don't
  bundle unrelated changes.
- **Spec intent** — the spec must describe the problem, approach, and
  expected outcome. The implementation should trace back to it.
- **Adjudicated objections** — every feature PR needs a spec-mode and
  a code-mode objection record at
  `docs/superpowers/objections/<spec-slug>.md` and
  `<spec-slug>-code.md`, with all dispositions resolved (no `pending`
  values). Run `/diaboli` after the spec is written and again after
  the implementation is complete. Bug-fix and maintenance PRs are
  exempt on the same terms as spec-first ordering.
- **Adjudicated choice stories** — every non-exempt feature PR needs
  a choice-story record at `docs/superpowers/stories/<spec-slug>.md`
  with every story dispositioned. Run `/choice-cartograph` after the
  spec-mode `/diaboli` dispositions are resolved. The exempt-label
  list is the same as objections plus `cross-repo`.
- **Version consistency** — `plugin.json` version, README badge, and
  CHANGELOG heading must all match. Changes inside
  `ai-literacy-superpowers/` require a version bump.
- **Marketplace sync** — `marketplace.json` `plugin_version` must
  match `plugin.json` `version`.
- **Release traceability** — every version needs a matching CHANGELOG
  heading and a git tag. The tag is created automatically on merge.
  `ai-literacy-superpowers` uses bare `vX.Y.Z` tags;
  `model-cards` uses `model-cards-vX.Y.Z` tags.
- **Output validation** — commands that produce structured output must
  include a validation checkpoint that reads the output back and
  checks it against the format spec.
- **Docs site kept current** — when a PR adds, removes, or changes a
  skill, agent, or command, the corresponding pages under `docs/`
  must be reviewed and updated in the same PR.
- **Docs propagation when shipping new commands** — when a new
  command consolidates or replaces existing functionality, every
  reference in `docs/plugins/<plugin>/` to the older commands must
  be updated to frame them as primitives or alternatives. A "See
  also" callout is not enough.
- **Tests must pass** — the test suite (such as it is) must pass with
  zero failures. Currently unverified because there is no application
  test suite.

### On schedule

Periodic checks run weekly or monthly to catch slow drift.

- **Documentation freshness** — checks whether README.md, HARNESS.md,
  and CLAUDE.md reference things that no longer exist.
- **Secret scanner operational** — confirms gitleaks is still
  installed and running.
- **Snapshot staleness** — flags if the harness health snapshot is
  older than 30 days.
- **Command-prompt sync** — detects when commands and their
  corresponding `.github/prompts/` files have diverged.
- **Change cadence drift** — watches whether PR sizes or cycle times
  are increasing, which can signal that AI-speed production is
  outpacing human review.
- **Plugin manifest currency** — checks whether `plugin.json` counts
  still match actual skills, agents, and commands.
- **Marketplace listing drift** — checks whether `marketplace.json`
  has drifted from `plugin.json`.
- **Release tag completeness** — confirms every CHANGELOG version has
  a git tag.
- **Onboarding staleness** — flags if ONBOARDING.md is older than
  HARNESS.md, AGENTS.md, or REFLECTION_LOG.md.
- **Template currency** — detects when the HARNESS.md template
  version is behind the installed plugin version.
- **Dependency currency** — checks for known vulnerabilities in
  dependencies.
- **Convention file sync** — checks whether Cursor, Copilot, and
  Windsurf convention files reflect current HARNESS.md conventions.
- **Reflection regression detection** — looks for recurring failure
  patterns in REFLECTION_LOG.md that should become constraints.
- **Reflection log archival** — promoted reflection entries are
  auto-moved to `reflections/archive/<YYYY>.md` once verified.
- **Reflection log aged-out review** — entries older than 180 days
  without a `Promoted` line surface as evidence for the curator
  (no auto-classification).
- **Objection record freshness** — flags spec files modified more
  recently than their objection record (a spec edited without
  re-running `/diaboli`).
- **Reflections via PR workflow** — every change to
  `REFLECTION_LOG.md` must come via a PR with CI passing. Direct
  commits to `main` that modify the log are forbidden.
- **Observability archive** — moves snapshots older than 6 months to
  the archive directory.

---

## Common Pitfalls

**Run deterministic tools before promoting constraints.** When adding
a new linter or check (like ShellCheck), run it against the entire
codebase first — including files created earlier in the same session.
ShellCheck found 4 issues in scripts that had already passed LLM
review. Deterministic tools catch what review misses.

**Don't use worktrees for parallel subagents.** Worktree-isolated
subagents lose Bash permissions because `.claude/settings.local.json`
doesn't propagate to worktree paths. Use regular background agents on
separate branches instead, but plan for branch cross-contamination and
cherry-pick cleanup.

**Background subagents may lack write permissions.** For write-heavy
tasks, use foreground agents so the user can approve tool calls, or
have the parent agent extract content from subagent output and do the
writes itself.

**Check for existing CI workflows before proposing new ones.** This
project already has `version-check.yml`, `lint-markdown.yml`,
`harness.yml`, `gc.yml`, and `pages.yml` in `.github/workflows/`.
Proposing a duplicate wastes a branch cycle.

**The plugin is self-referential.** This plugin defines the harness
framework, and its own HARNESS.md uses that framework. Changes to
template files (`templates/HARNESS.md`) do not automatically propagate
to the project's root `HARNESS.md`. The command-prompt sync and
plugin manifest currency GC rules catch this drift.

**Plugin files live in two locations.** Root-level `skills/`, `hooks/`,
`templates/` are the plugin's own development files. Files under
`ai-literacy-superpowers/` are the packaged plugin that gets
distributed. When a spec references a file path, check both locations.

**Apply spec-first exemption labels at PR creation, not after.** When
a PR needs a `chore`, `fix`, or `cross-repo` label to bypass a CI
gate, pass `--label <label>` directly in `gh pr create`. Labels added
after the initial push are invisible to already-queued CI runs and
need an empty-commit retrigger to re-evaluate. The `chore` label is
the right exemption for docs-only changes outside the plugin
directory; CLAUDE.md's "Spec-First Exemptions" table lists which
label to use for which kind of change.

**Audit after shipping a new command — not just the immediate docs.**
When a new command consolidates or replaces existing functionality,
the new how-to page is not enough. Grep `docs/plugins/<plugin>/` for
every reference to the older commands and reframe them as primitives
or alternatives in the same PR. The new docs-propagation constraint
encodes this, but the discipline is yours: a PR that ships
`/harness-sync` without updating `convention-sync.md` and
`harness-onboarding.md` to acknowledge the new entry point is
incomplete.

**Match each file's existing emphasis style for markdown.** The
project's `.markdownlint.json` runs MD049 in `consistent` mode — it
enforces consistency *within each file*, not project-wide. Some
existing pages use asterisks for emphasis, others use underscores.
Match what the file already uses; do not assume a global convention.

**Prose-embedded counts and version strings drift silently.** Badges
in README.md are kept correct by the version-bump workflow, but
prose-embedded counts (the marketplace plugin table row, "Skills
(N)" headings, anything that looks like `N skills, M agents, K
commands`) are not. When you ship a command/skill/agent, update
those prose surfaces in the same PR.

---

## Architecture Decisions

**Hook scripts never block.** This plugin is used across diverse
projects, so blocking hooks could break workflows the plugin authors
cannot predict. Advisory messages let users decide how to act. The
alternative of configurable blocking was rejected — the complexity
wasn't justified.

**Health snapshots are committed directly to main.** They don't
affect behaviour, and gating them on PR review would add friction to
the observability cadence. This is an intentional exception to the
branch-and-PR workflow.

**Every structured-output command has a validation checkpoint.** The
pattern is: generate output, read it back, check against the format
spec, fix in place. This was added because agents consistently drift
from format specs under cognitive load — reference templates set
intent but don't guarantee compliance. The checkpoint is the
verification layer, analogous to type checking in compiled code.

**Content-emitting agents follow agent-emit + dispatcher-persist +
human-disposes.** The agent's tool boundary is research-and-author
only (no Edit, no Bash); it returns content as a string; the
dispatching command writes the file after a structured human review
(accept / edit / re-run / abort). This pattern is in production
across `advocatus-diaboli`, `choice-cartographer`, and
`model-card-researcher`. Future research-and-author agents should
default to this shape unless an explicit reason argues otherwise.

**The advocatus-diaboli is hard-wired into the spec-first pipeline,
not optional.** It runs as an agent-enforced constraint at PR time
and as a gate inside the orchestrator pipeline. Manual-only
invocation was rejected — discipline that depends on remembering
collapses under pressure. Schema-only checks were also rejected —
"resolved" is a judgment call about rationale quality, not a value
in a field.

**Cross-cutting methodology lives in
`skills/<skill-name>/references/<contract>.md`.** When the same
methodology is consumed by multiple agents, commands, and skills,
factor it into a reference file. Edits land in one place and
propagate. Inlining at each consumer site causes silent drift as one
copy is edited and the others are not — a failure mode caught
explicitly in code-mode diaboli on the choice-cartographer PR.

**Reflection-driven amendments may use `chore`-labelled PRs.** When
a reflection has been captured, the work is scoped in a tracked
issue, the implementation is additive or conservatively bounded,
and the version bump is honest about the change, a `chore` PR is
acceptable even for behavioural changes. Reserve full feature-flow
ceremony (spec → diaboli → adjudicate → implement → diaboli code-
mode → adjudicate) for net-new capability. Use chore for refining
existing capability driven by captured signal. The distinction is
calibrated rather than codified — judgement, not a rule.

---

## How We Test

This project has no application code or test suite. Quality is
assured by four deterministic tools that run in CI:

1. **markdownlint** — enforces consistent markdown formatting
2. **ShellCheck** — catches shell script bugs and style issues
3. **bash -n** — verifies shell script syntax
4. **gitleaks** — detects accidentally committed secrets

All four run on every PR via the harness CI workflow. Run them
locally before pushing to avoid CI failures.

---

## How the Harness Works

The project uses three enforcement loops that protect the codebase
at different timescales:

- **Advisory loop** — hooks run during editing and warn about
  potential issues, but never block your work. You'll see system
  messages nudging you to run audits, capture reflections, or check
  for secrets.
- **Strict loop** — CI workflows run on every PR and block merges
  until all checks pass. This includes markdownlint, gitleaks, shell
  checks, version consistency, spec-first ordering, and the
  agent-driven `Enforce PR constraints` workflow.
- **Investigative loop** — garbage collection rules run weekly (or
  monthly) to catch slow drift that neither hooks nor CI gates
  detect. Things like documentation staleness, marketplace listing
  drift, and unpromoted reflections.

The project runs on a monthly observability cadence:

- Harness health snapshots: monthly
- Harness audits: quarterly
- AI literacy assessments: quarterly
- Reflection review and promotion: monthly
- Cost captures: quarterly

---

## Your First PR Checklist

1. Create a branch — never commit directly to `main`
2. Pick the right exemption label up front: `fix` for bug fixes,
   `chore` for docs/maintenance outside the plugin directory,
   `cross-repo` for syncs from another repo. Pass `--label <label>`
   in `gh pr create` — adding labels after the push leaves CI gates
   in their failed state until you push another commit.
3. For feature work, commit the spec first (in
   `docs/superpowers/specs/`) before any implementation.
4. After the spec is written, run `/diaboli` and resolve every
   disposition before plan approval; then run `/choice-cartograph`
   and resolve every story.
5. Run `npx markdownlint-cli2 "**/*.md"` and fix any warnings —
   match each file's existing emphasis style (MD049 enforces
   per-file consistency, not a global default).
6. Run `shellcheck` on any `.sh` files you changed or created.
7. Confirm every `.sh` file has `set -euo pipefail` in the first
   15 lines.
8. Ensure all `.agent.md`, `SKILL.md`, and command `.md` files have
   `name` and `description` in their YAML frontmatter.
9. Run `gitleaks detect --source . --no-banner` to check for secrets.
10. If you changed files inside `ai-literacy-superpowers/`, bump
    the version in `plugin.json`, the README badge, and the
    CHANGELOG heading (all three must match).
11. Update `marketplace.json` `plugin_version` to match
    `plugin.json`.
12. Update `CHANGELOG.md` with a dated section describing your
    changes.
13. If the PR adds, removes, or substantially changes a skill,
    agent, or command: review every relevant page under
    `docs/plugins/<plugin>/` and update references in the same PR.
    Update prose-embedded counts in README.md (marketplace table
    row, section headings) too — badges update automatically but
    prose does not.
14. After the implementation is complete, run `/diaboli` again in
    code mode and resolve every disposition before opening the PR.
15. Push and create the PR — wait for all CI checks to pass before
    requesting review.

---

## Where to Learn More

- [HARNESS.md](HARNESS.md) — the full constraint and convention
  reference
- [AGENTS.md](AGENTS.md) — accumulated team knowledge, gotchas, and
  architecture decisions
- [REFLECTION_LOG.md](REFLECTION_LOG.md) — session-by-session
  learnings from agent pipeline runs
- [CLAUDE.md](CLAUDE.md) — project conventions for Claude Code
  sessions
- [README.md](README.md) — full plugin documentation with component
  listings
- [docs/](docs/) — the project's full documentation site (per-plugin
  how-tos, explanation pages, reference material)
