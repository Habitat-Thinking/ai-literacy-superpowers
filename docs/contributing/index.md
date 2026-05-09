---
title: Contributing
---

# Contributing

This page is the docs-site projection of the project's
[`ONBOARDING.md`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/ONBOARDING.md).
The source of truth lives in the repo and is regenerated from
`HARNESS.md`, `AGENTS.md`, and `REFLECTION_LOG.md` by the
[`/harness-onboarding`](../plugins/ai-literacy-superpowers/how-to/generate-onboarding.md)
command. When ONBOARDING.md is regenerated, this page should be
updated to mirror it.

If you are setting up your environment for the first time, start with
the [Getting Started tutorial](../plugins/ai-literacy-superpowers/tutorials/getting-started.md).
The page below picks up where that tutorial leaves off, covering the
day-to-day conventions and discipline a contributor needs to ship a
PR against this repo.

---

## Welcome

This is a Claude Code and GitHub Copilot CLI plugin marketplace that
ships the AI Literacy framework's complete development workflow —
harness engineering, agent orchestration, literate programming, CUPID
code review, compound learning, and the three enforcement loops. You
will be working with markdown skills, bash hook scripts, JSON
configuration, and YAML CI workflows. There is no compiled application
code; the plugin's "code" is content that agents and tools read and
execute. The flagship plugin is `ai-literacy-superpowers`;
`model-cards` is a sister plugin that ships from the same repo with
its own version line and tag convention. The whole project is also
self-referential — it defines the harness framework, and its own
`HARNESS.md` uses that framework, so changes to templates do not
automatically propagate to the project's own root.

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
- **Python (test-stage only)** — the TDAD test suite under
  [`tdad_tests/`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/tree/main/tdad_tests)
  uses Python plus pytest plus the Claude Agent SDK. Test-stage code
  stays out of the packaged plugin; consumers never need a Python
  runtime.
- **No build system** — this is a plugin, not a compiled application.
  There is nothing to build.

---

## How We Write Code

**Naming matters.** Skills live in `skills/<name>/SKILL.md` (the
directory is kebab-case, the file is always `SKILL.md`). Agents are
`<name>.agent.md`. Commands are `<name>.md`. Hook scripts are
`<name>.sh`. Everything is lowercase kebab-case except `SKILL.md`.

**One component per file.** Agents go in `agents/`, skills in
`skills/<name>/SKILL.md`, commands in `commands/`, hook scripts in
`hooks/scripts/`, templates in `templates/`, utility scripts in
`scripts/`. If you are adding something new, put it in the right
directory.

**New components ship with a TDAD scenario.** When you add a skill,
agent, or command, drop a markdown scenario alongside it under
`tdad_tests/scenarios/<type>/<name>/` so the structural and (where
relevant) behavioural layers can pick it up. The scenario is a small
human-readable markdown file with `Given / When / Then / Rubric`
sections — see the
[`tdad_tests/README.md`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/tdad_tests/README.md)
for the format.

**Hook scripts are advisory only.** They warn but never block. Output
uses JSON `systemMessage` format so Claude Code surfaces the message
without interrupting the session. When writing a hook script, start
with `set -euo pipefail` and exit silently (`exit 0`) when the hook
does not apply.

**Everything needs frontmatter.** Every `.agent.md`, `SKILL.md`, and
command `.md` file must have YAML frontmatter with `name` and
`description` fields. Skills also need an Overview section. Bash
scripts need a header comment block explaining purpose and behaviour.

---

## What's Enforced

### At commit time

These checks warn you while you are editing. They are advisory — they
will not stop you from committing, but they flag problems early.

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
they pass.

- **Frontmatter completeness** — every agent, skill, and command file
  must have `name` and `description` in its frontmatter.
- **Spec-first ordering** — for feature PRs, the first commit must
  contain only a spec file in `docs/superpowers/specs/`. Bug-fix and
  maintenance PRs (labelled `bug`, `fix`, `chore`, `maintenance` or
  branch-prefixed `fix/`, `chore/`) are exempt.
- **Spec scoping** — each feature PR traces to a single spec. Do not
  bundle unrelated changes.
- **Spec intent** — the spec must describe the problem, the chosen
  approach, and the expected outcome. The implementation should
  trace back to it.
- **Adjudicated objections** — every feature PR needs a spec-mode and
  a code-mode objection record at
  `docs/superpowers/objections/<spec-slug>.md` and
  `<spec-slug>-code.md`, with all dispositions resolved. Run
  [`/diaboli`](../plugins/ai-literacy-superpowers/how-to/review-a-spec-adversarially.md)
  after the spec is written and again after the implementation is
  complete.
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
  `ai-literacy-superpowers` uses bare `vX.Y.Z` tags; `model-cards`
  uses `model-cards-vX.Y.Z` tags.
- **Output validation** — commands that produce structured output must
  include a validation checkpoint that reads the output back and
  checks it against the format spec.
- **Docs site kept current** — when a PR adds, removes, or changes a
  skill, agent, or command, the corresponding pages on this docs
  site must be reviewed and updated in the same PR.
- **Docs propagation when shipping new commands** — when a new
  command consolidates or replaces existing functionality, every
  reference in the docs to the older commands must be updated to
  frame them as primitives or alternatives. A "See also" callout is
  not enough.
- **Tests must pass** — the
  [TDAD suite](#how-we-test) must pass on PRs. Layers 0–1 are free
  and fast; Layers 2–3 cost API spend and are gated by the
  `ANTHROPIC_API_KEY` environment variable, so they run nightly or
  behind a label rather than on every PR.

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
  outpacing human review. See
  [Enforce the human pace](../plugins/ai-literacy-superpowers/how-to/enforce-human-pace.md)
  for the rationale.
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

**Do not use worktrees for parallel subagents.** Worktree-isolated
subagents lose Bash permissions because `.claude/settings.local.json`
does not propagate to worktree paths. Use regular background agents
on separate branches instead, but plan for branch cross-contamination
and cherry-pick cleanup.

**Background subagents may lack write permissions.** For write-heavy
tasks, use foreground agents so the user can approve tool calls, or
have the parent agent extract content from subagent output and do the
writes itself.

**Check for existing CI workflows before proposing new ones.** This
project already has `version-check.yml`, `lint-markdown.yml`,
`harness.yml`, `gc.yml`, and `pages.yml` in `.github/workflows/`.
Proposing a duplicate wastes a branch cycle.

**Plugin files live in two locations.** Root-level `skills/`,
`hooks/`, `templates/` are the plugin's own development files. Files
under `ai-literacy-superpowers/` are the packaged plugin that gets
distributed. When a spec references a file path, check both
locations.

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
or alternatives in the same PR. The docs-propagation constraint
encodes this, but the discipline is yours.

**Match each file's existing emphasis style for markdown.** The
project's `.markdownlint.json` runs MD049 in `consistent` mode — it
enforces consistency *within each file*, not project-wide. Some
existing pages use asterisks for emphasis, others use underscores.
Match what the file already uses; do not assume a global convention.

**Prose-embedded counts and version strings drift silently.** Badges
in README.md are kept correct by the version-bump workflow, but
prose-embedded counts (the marketplace plugin table row, "Skills
(N)" headings, anything that looks like `N skills, M agents, K
commands`) are not. When you ship a command, skill, or agent, update
those prose surfaces in the same PR.

**`git mv` plus content edits plus narrowly-staged commit silently
drops the edits.** When a single logical change combines a `git mv`
with content edits to the moved files, a narrow `git add path1 path2
&& git commit` will commit the rename and leave the in-file edits
unstaged in the working tree. This bit twice in one session
(PR #286 → #287, PR #289 → #290), each time landing a broken `main`
that needed a recovery PR. Verify before committing: `git diff
--cached --stat` should list every file you intended to modify. If it
shows only renames where you expected modifications, the edits are
not staged.

**Specs about extracting logic for testing carry a hidden second
question.** When a design spec proposes extracting code into a helper
for test coverage, it almost always also implies a follow-on
question — *should the extracted helper ship as production code?* The
two questions have different stakes (test coverage vs plugin
distribution and language runtimes). PR #293 → #298 amended the
command-TDAD-testing spec because the original answered the first
question explicitly and the second only implicitly. The lesson:
when a spec recommendation crosses a major architectural boundary
(package contents, language runtimes, distribution shape), name the
crossing in its own row of the trade-off table. For this project
specifically: TDAD helpers stay test-stage in
`tdad_tests/spike_helpers/`; they do **not** ship inside
`ai-literacy-superpowers/scripts/`, because that would add a Python
runtime dependency to every consumer.

---

## Architecture Decisions

**Hook scripts never block.** This plugin is used across diverse
projects, so blocking hooks could break workflows the plugin authors
cannot predict. Advisory messages let users decide how to act. The
alternative of configurable blocking was rejected — the complexity
was not justified for advisory value.

**Health snapshots are committed directly to main.** They do not
affect behaviour, and gating them on PR review would add friction to
the observability cadence. This is an intentional exception to the
branch-and-PR workflow.

**Every structured-output command has a validation checkpoint.** The
pattern is: generate output, read it back, check against the format
spec, fix in place. This was added because agents consistently drift
from format specs under cognitive load — reference templates set
intent but do not guarantee compliance. The checkpoint is the
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

**Diaboli runs at two dispatch points (spec-time and code-time)
using a single agent.** One agent, two dispatches — not two agents.
Spec-time runs after spec-writer, before plan approval; code-time
runs once after the final code-reviewer PASS, before
integration-agent. A separate code-diaboli agent was rejected as
duplicating the charter; running diaboli inside the code-reviewer
loop per cycle was rejected as burning tokens on draft code.

**Cross-cutting methodology lives in
`skills/<skill-name>/references/<contract>.md`.** When the same
methodology is consumed by multiple agents, commands, and skills,
factor it into a reference file. Edits land in one place and
propagate. Inlining at each consumer site causes silent drift as one
copy is edited and the others are not — a failure mode caught
explicitly in code-mode diaboli on the choice-cartographer PR.

**Test-Driven Agentic Discipline (TDAD) uses a four-layer
architecture that mirrors the framework's promotion ladder.** Layer
0 is deterministic plumbing (bash scripts and helper libraries —
free, every PR). Layer 1 is structural (frontmatter, manifest
schema, cross-references — free, every PR). Layer 2 is trigger
(does a skill's description match the queries it should fire on —
~$0.03 per run, mostly deterministic). Layer 3 is behavioural (full
SDK invocation against fixtures with a rubric judge — $0.05–$0.20
per run, probabilistic). Layers 0–1 run on every PR; Layers 2–3 are
nightly or label-gated to keep the API budget bounded. This layout
was chosen because pure deterministic tests cannot verify whether a
skill description triggers correctly, but full SDK invocation is too
expensive to run on every PR. The four layers map directly to the
harness promotion ladder: Layer 0 is the deterministic tier;
Layers 1–3 together cover the agent-verified tier.

**TDAD helpers stay test-stage; they do not ship in the plugin.**
Helper code lives under `tdad_tests/spike_helpers/` and is invoked by
pytest, not by the plugin's commands at runtime. Shipping the
helpers in `ai-literacy-superpowers/scripts/` was rejected because it
would add a hard Python 3.11+ dependency to every consumer machine —
the plugin today ships shell scripts only and has no language runtime
requirements beyond bash. The trust-boundary rule is: code that helps
verify the plugin lives in `tdad_tests/`; code that the plugin
executes at runtime lives inside `ai-literacy-superpowers/`.

**The auto-fix-vs-manual rule for sync commands.** When a command
runs an audit and offers to remediate findings, classify each
remediation as `[auto]` only when (1) it derives from a single
canonical source, (2) the same input always produces the same output,
and (3) it requires no user judgement. Multi-source derivations,
judgement calls, and operations with user-visible side effects belong
in `[manual]` regardless of how trivial they look. ONBOARDING.md is
`[manual]` because it derives from three sources (HARNESS.md,
AGENTS.md, REFLECTION_LOG.md); convention-sync surfaces are `[auto]`
because they derive from HARNESS.md alone.

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

The project has no application code, but it does have a test suite —
[`tdad_tests/`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/tree/main/tdad_tests)
— that applies Test-Driven Agentic Discipline (TDAD, after Antony
Marcano 2026) to the plugin's own components. The suite lives outside
the packaged `ai-literacy-superpowers/` directory so it does not ship
with plugin installs.

**Four layers, mapped to cost and cadence:**

| Layer | What it tests | Cost | Cadence |
| --- | --- | --- | --- |
| **0. Deterministic plumbing** | Bash scripts and parser libraries the agents depend on | $0 | every PR |
| **1. Structural** | Frontmatter well-formed, required sections present, cross-references resolve | $0 | every PR |
| **2. Trigger** | Skill descriptions match the queries they should fire on (catches description drift) | ~$0.03 / run | nightly + label-gated |
| **3. Behavioural** | Run an agent or skill in a fixture, assert outputs against a rubric (TDAB proper) | $0.05–$0.20 / run | nightly + label-gated |

**Running locally:**

```bash
# from the tdad_tests/ directory
pip install -e .

# Layer 1 only (offline, free):
pytest tests/test_layer1_structural.py -v

# All layers (needs ANTHROPIC_API_KEY):
export ANTHROPIC_API_KEY=...
pytest -v
```

Layers 0–1 run offline and pass against the real plugin. Layers 2–3
require an Anthropic API key and skip with a clear message when the
key is absent.

**Plus the deterministic gates that have always been there:**

1. **markdownlint** — enforces consistent markdown formatting across
   every `.md` file
2. **ShellCheck** — catches shell script bugs and style issues
3. **bash -n** — verifies shell script syntax
4. **gitleaks** — detects accidentally committed secrets

All four run on every PR via the harness CI workflow. Run them
locally before pushing to avoid CI failures. See the
[`tdad_tests/README.md`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/tdad_tests/README.md)
for the full TDAD status table and scenario format.

---

## How the Harness Works

The project uses three enforcement loops that protect the codebase
at different timescales:

- **Advisory loop** — hooks run during editing and warn about
  potential issues, but never block your work. You will see system
  messages nudging you to run audits, capture reflections, or check
  for secrets.
- **Strict loop** — CI workflows run on every PR and block merges
  until all checks pass. This includes markdownlint, gitleaks, shell
  checks, version consistency, spec-first ordering, and the
  agent-driven `Enforce PR constraints` workflow. TDAD Layers 0–1
  run on every PR; Layers 2–3 run nightly or behind a label.
- **Investigative loop** — garbage collection rules run weekly (or
  monthly) to catch slow drift that neither hooks nor CI gates
  detect. Things like documentation staleness, marketplace listing
  drift, and unpromoted reflections.

For the conceptual background on each loop, see:

- [Three enforcement loops](../plugins/ai-literacy-superpowers/explanation/three-enforcement-loops.md)
- [The harness lifecycle](../plugins/ai-literacy-superpowers/explanation/the-harness-lifecycle.md)
- [Garbage collection](../plugins/ai-literacy-superpowers/explanation/garbage-collection.md)

The project runs on a monthly observability cadence:

- Harness health snapshots: monthly
- Harness audits: quarterly
- AI literacy assessments: quarterly
- Reflection review and promotion: monthly
- Cost captures: quarterly

---

## Your First PR Checklist

1. Create a branch — never commit directly to `main`.
2. Pick the right exemption label up front: `fix` for bug fixes,
   `chore` for docs and maintenance outside the plugin directory,
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
10. If you added a skill, agent, or command, drop a TDAD scenario
    alongside it under `tdad_tests/scenarios/<type>/<name>/` and run
    `pytest tests/test_layer1_structural.py -v` to confirm the new
    component picks up structural coverage.
11. If you changed files inside `ai-literacy-superpowers/`, bump the
    version in `plugin.json`, the README badge, and the CHANGELOG
    heading (all three must match).
12. Update `marketplace.json` `plugin_version` to match `plugin.json`.
13. Update `CHANGELOG.md` with a dated section describing your
    changes.
14. If the PR adds, removes, or substantially changes a skill,
    agent, or command, review every relevant page on this docs site
    and update references in the same PR. Update prose-embedded
    counts in README.md (marketplace table row, section headings)
    too — badges update automatically but prose does not.
15. If your change combines a `git mv` with content edits, run
    `git diff --cached --stat` before committing to confirm every
    edited file appears in the cached set, not just the renames.
16. After the implementation is complete, run `/diaboli` again in
    code mode and resolve every disposition before opening the PR.
17. Push and create the PR — wait for all CI checks to pass before
    requesting review.

---

## Where to Learn More

- [`HARNESS.md`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/HARNESS.md)
  — the full constraint and convention reference
- [`AGENTS.md`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/AGENTS.md)
  — accumulated team knowledge, gotchas, and architecture decisions
- [`REFLECTION_LOG.md`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/REFLECTION_LOG.md)
  — session-by-session learnings from agent pipeline runs
- [`CLAUDE.md`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/CLAUDE.md)
  — project conventions for Claude Code
- [`ONBOARDING.md`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/ONBOARDING.md)
  — the source of truth this page mirrors
- [`tdad_tests/README.md`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/tdad_tests/README.md)
  — the TDAD test suite, layer-by-layer status table, and scenario
  format
- [Command-TDAD-testing design spec](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/docs/superpowers/specs/2026-05-09-command-tdad-testing-design.md)
  — per-category strategy for testing commands, including the
  Option I amendment that keeps helpers test-stage
- [Generate an Onboarding Guide](../plugins/ai-literacy-superpowers/how-to/generate-onboarding.md)
  — how to regenerate `ONBOARDING.md` (the source of this page)
