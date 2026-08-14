<!-- Generated from HARNESS.md, AGENTS.md, and REFLECTION_LOG.md.
     Do not edit directly — regenerate with /harness-onboarding. -->

# Welcome to ai-literacy-superpowers

This is a Claude Code plugin marketplace. It ships three plugins, the largest
of which — `ai-literacy-superpowers` — is a complete development workflow:
harness engineering, an agent pipeline, CUPID code review, and a compound
learning loop.

The thing to understand first is that **this project is self-referential**. The
plugin defines the harness framework, and the repository runs on that same
framework. When you edit `HARNESS.md` you are editing the project's own rules;
when you edit `ai-literacy-superpowers/templates/HARNESS.md` you are editing
what *other* projects get. They are different files and changes do not
propagate between them.

Expect a lot of process for a repository with no application code. That is the
point: the process *is* the product, and it is tested on itself before it ships
to anyone else.

## Tech Stack

- **Primary languages** — Markdown for skills, agents, commands and templates;
  Bash for hook scripts; Python for deterministic checks.
- **Build system** — none. Nothing compiles. Plugin content is loaded by Claude
  Code from the directory structure.
- **Tests** — Python (`pytest`) driving a TDAD suite; Bash for the deterministic
  Layer 0 checks. See *How We Test*.
- **Containers** — none.

## How We Write Code

- **Naming** — skills live as `SKILL.md` inside a directory named for the
  skill. Agents are `<name>.agent.md`, commands are `<name>.md`.
- **File structure** — one component per file, organised by type. Plugin
  content lives under `ai-literacy-superpowers/`; the repo root holds the
  project's own harness and docs.
- **Error handling** — every hook script uses `set -euo pipefail`, and every
  hook exits 0 on every path. A hook that broke a session would be worse than
  a hook that stayed quiet.
- **Documentation** — every skill, agent and command file carries frontmatter
  with `name` and `description`. This is enforced.

## What's Enforced

34 constraints, of which 23 are checked by a tool, 10 by an agent reading the
rule, and 1 is declared but unverified. You do not need to memorise them — CI
tells you. These are the ones that catch people first.

### At commit time

- **No secrets in source** — gitleaks scans the working tree.
- **Shell scripts pass syntax check** and **use strict mode** — `bash -n`, plus
  a check for `set -euo pipefail`.
- **Consistent markdown formatting** — markdownlint against
  `.markdownlint.json`. Also runs at PR time.
- **ShellCheck compliance** — likewise.

### At PR time

Twenty-six constraints run here. The ones most likely to stop you:

- **Spec-first commit ordering** — a feature or behaviour-change PR needs a
  spec committed as the *first* commit on the branch. Exempt via a `chore`,
  `fix`, `bug`, `maintenance` or `cross-repo` label, or a `fix/` or `chore/`
  branch prefix.
- **Label PRs at creation time** — pass `--label` on `gh pr create`, not
  afterwards. A label added later does not apply to the CI run already queued.
- **Version consistency** and **Marketplace plugin version sync** — a version
  bump must land in five places at once. `CLAUDE.md` enumerates them.
- **PRs have adjudicated objections** / **adjudicated choice stories** — if a
  spec has an objection or choice-story record, every entry needs a human
  disposition before merge. No agent can write one.
- **New plugin components must ship with a TDAD scenario** and **with a
  reference-page entry** — adding a skill, agent or command means adding both
  in the same PR.
- **Docs site builds in strict mode** — `mkdocs build --strict`. A broken link
  fails the build.
- **Sentinel integrity** — any agent tagged `role: sentinel` must hold no
  `Write` or `Edit` tool.
- **Convention parity** — every constraint heading must appear in all three
  assistant convention files, and any enumerated set of values in a rule must
  appear in each of them too.
- **Specs cite the source of a claimed convention** — if your spec asserts "the
  pattern here is X", cite the file that *defines* X. A table built from the
  examples that fit is not a citation.

### On schedule

Nineteen garbage-collection rules — 15 weekly, 4 monthly — sweep for the decay
that PR gates cannot see: stale docs, missing release tags, drifted convention
files, ageing reflections. A monthly observability snapshot lands in
`observability/snapshots/`.

## Common Pitfalls

These are recorded gotchas. Every one cost somebody real time.

- **The two-directory split.** Root-level `skills/`, `hooks/` and `templates/`
  are the project's own development files. The same-named directories under
  `ai-literacy-superpowers/` are what ships to users. Editing the wrong one
  produces a change that appears to work and reaches nobody.
- **Worktree-isolated subagents lose Bash permissions**, and background
  subagents may lack `Write`/`Edit` even when the parent has them. Use
  foreground agents for write-heavy work, or have the parent do the final
  writes.
- **Before proposing a new CI workflow, grep `.github/workflows/`.** The check
  you are about to add usually exists.
- **Run a new deterministic constraint against the whole codebase before
  promoting it** — including files created earlier in the same session.
  ShellCheck found four pre-existing issues the first time.
- **Long uninterrupted sessions degrade judgement** in ways that are invisible
  from inside the session. `/reservoir` reports the observable proxies and
  offers exactly one recommendation: decide your stop before the next session
  begins.
- **A confident sentence is the most dangerous artefact here.** The recurring
  review finding across this repo is a claim about an existing convention
  written from the cases that fit, without opening the file that defines it.
  Three such premises were falsified in a single day. Check first.

## Architecture Decisions

Sixteen decisions are recorded in `AGENTS.md`. The four that shape most work:

- **Read-only trust boundaries are the mechanism, not a precaution.**
  Content-emitting agents hold `Read`/`Glob`/`Grep` and no write tool. Their
  output is returned as text and persisted by a command *after* a human
  disposes it. The disposition field cannot be filled by any agent — that
  constraint is what makes engagement structural rather than requested.
- **Harness artefacts derive from the source of truth; they do not pin a copy
  of it.** A check that counts nine sentinels should read `role: sentinel`, not
  hold the number nine. Where no on-disk source exists and a literal is
  genuinely unavoidable, the guard must say what makes it change and why it was
  not derived.
- **A consumer never mutates the contract it consumes.** If your slice needs a
  contract change, that change gets its own owning slice and its own
  adversarial pass.
- **Hook scripts never block, only warn.** This is a plugin running inside
  someone else's session; a hook that halted their work would be a worse
  failure than the one it was preventing.

## How We Test

There is no application code, but there is a substantial test suite under
`tdad_tests/`, run by `pytest`, across four layers.

- **Layer 0 — deterministic.** Bash scripts under
  `tdad_tests/layer0_deterministic/`, each registered by stem in
  `tdad_tests/tests/test_layer0_deterministic.py`. These exercise the shipped
  hook scripts and checkers against temp fixtures. Adding a Layer 0 test means
  adding the file *and* the roster entry.
- **Layer 1 — structural.** Scenario files under `tdad_tests/scenarios/`,
  one directory per component, asserting that agent and command files carry the
  charter clauses they are required to.
- **Layer 2 — skill triggers.** Does a skill's description still fire on the
  queries it should? Model-mediated, one inference per query, and skipped when
  no API key is present — which accounts for most of the suite's skips.
- **Layer 3 — behavioural.** Opt-in, case by case.

Two habits are worth copying. **Write the test first and watch it fail for the
right reason** — a test that passes the moment it is written proves nothing.
And **mutation-test anything that guards a property**: break the thing
deliberately and confirm the test catches it. Several checks in this repo were
found to be passing for the wrong reason that way.

Run the fast suite with `python3 -m pytest tdad_tests/tests/ -q`.

## How the Harness Works

Three loops at different timescales.

- **The inner loop** is the agent pipeline: a spec, an adversarial review of
  that spec, a mapping of the decisions it made silently, then TDD,
  implementation, code review, and a second adversarial pass before
  integration. Human gates sit between the stages, and agents cannot write
  through them.
- **The middle loop** is CI: the 34 constraints, checked on every PR.
- **The outer loop** is garbage collection and compound learning: 19 scheduled
  rules sweeping for decay, plus a reflection captured after substantial work.
  Reflections accumulate as one file per entry under `reflections/active/`;
  `REFLECTION_LOG.md` is a generated aggregate and is never edited by hand.

Learning flows one way: reflections propose, humans curate. Nothing writes to
`AGENTS.md` except a person.

## Your First PR Checklist

1. **Branch first.** Never commit to `main` — `git checkout -b <short-name>`.
2. **Decide whether you need a spec.** Feature or behaviour change: yes, and it
   must be the first commit on the branch. Fix, chore or docs: use a `fix/` or
   `chore/` branch prefix, or the matching label.
3. **Update `CHANGELOG.md`.** Every top-level heading must begin with a semver
   version and a date — `## X.Y.Z — YYYY-MM-DD`. A date-only heading parses as
   the year and fails CI with a confusing version-mismatch error.
4. **Bump the version if you touched `ai-literacy-superpowers/`** — all five
   CI-checked locations. Nothing under that directory changed? No bump.
5. **New skill, agent or command?** Add a TDAD scenario and a reference-page
   entry in the same PR.
6. **Label at creation**: `gh pr create --label chore ...`.
7. **Run the suite locally** before pushing.
8. **Wait for green.** Every check, not most of them. If one fails, read the
   log rather than guessing from the check name.

## Where to Learn More

- **`HARNESS.md`** — the constraints, GC rules and observability cadence, in
  full. This document is a projection of it.
- **`AGENTS.md`** — gotchas and architecture decisions. Human-curated; agents
  propose changes through reflections and never write here.
- **`CLAUDE.md`** — the conventions an agent must follow in this repo,
  including the version-bump locations and the docs-site structure.
- **`REFLECTION_LOG.md`** — what surprised people, and what changed as a
  result. Generated from `reflections/active/`.
- **The docs site** —
  <https://habitat-thinking.github.io/ai-literacy-superpowers/> — tutorials,
  how-to guides, reference and explanation, per plugin.
- **`docs/superpowers/specs/`** — every design decision, with its adversarial
  objection record alongside in `docs/superpowers/objections/`. Reading a spec
  and its objections together is the fastest way to understand why something is
  shaped the way it is.
