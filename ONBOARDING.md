<!-- Generated from HARNESS.md, AGENTS.md, and REFLECTION_LOG.md.
     Do not edit directly — regenerate with /harness-onboarding. -->

# Welcome to ai-literacy-superpowers

This is a Claude Code and GitHub Copilot CLI plugin marketplace that
ships the AI Literacy framework's complete development workflow —
harness engineering, agent orchestration, literate programming, CUPID
code review, compound learning, dynamic workflows, and the three
enforcement loops. You will be working with markdown skills, bash hook
scripts, JSON configuration, and YAML CI workflows. There is no compiled
application code; the plugin's "code" is content that agents and tools
read and execute. The flagship plugin is `ai-literacy-superpowers`
(36 skills, 16 agents, 28 commands); `model-cards` and
`diagnostic-legibility` are sister plugins that ship from the same repo,
each with its own version line and tag convention. The whole project is
also self-referential — it defines the harness framework, and its own
`HARNESS.md` uses that framework, so changes to templates do not
automatically propagate to the project's own root.

---

## Tech Stack

- **Markdown** — the primary language. Skills, agents, commands,
  templates, and documentation are all markdown files with YAML
  frontmatter. Markdownlint enforces consistent formatting across
  every `.md` file.
- **Bash** — hook scripts and utility scripts. Every `.sh` file uses
  strict mode (`set -euo pipefail`) and passes both `bash -n` and
  ShellCheck. Deterministic check scripts are written POSIX-only so
  they behave the same under BSD (macOS) and GNU (Linux) coreutils.
- **JSON** — plugin configuration (`plugin.json`, `marketplace.json`)
  and hook registration.
- **YAML** — GitHub Actions CI workflows that enforce constraints on
  PRs and run scheduled garbage collection.
- **Python (test-stage only)** — the TDAD test suite under
  `tdad_tests/` uses Python plus pytest plus the Claude Agent SDK.
  Test-stage code stays out of the packaged plugin; consumers never
  need a Python runtime.
- **No build system** — this is a plugin, not a compiled application.
  There is nothing to build. Quality comes entirely from linters,
  scanners, and review.

---

## How We Write Code

**Naming matters.** Skills live in `skills/<name>/SKILL.md` (the
directory is kebab-case, the file is always `SKILL.md`). Agents are
`<name>.agent.md`. Commands are `<name>.md`. Hook scripts are
`<name>.sh`. Everything is lowercase kebab-case except `SKILL.md`.

**One component per file.** Agents go in `agents/`, skills in
`skills/<name>/SKILL.md`, commands in `commands/`, hook scripts in
`hooks/scripts/`, templates in `templates/`, and utility scripts in
`scripts/`. Find a file by its type and you find it fast.

**Frontmatter is mandatory.** Every skill, agent, and command file
carries YAML frontmatter with at least `name` and `description`.
Skills also include an Overview section. This isn't bureaucracy — the
plugin loader and the assessment tooling read those fields, so a
missing one breaks discovery.

**Error handling in shell is uniform.** Every hook script opens with
`set -euo pipefail` — and it must sit within the first 15 lines (a CI
check greps `head -15`, so a long literate header goes *below* strict
mode, never above it). Hooks are advisory only: they warn but never
block, and they emit JSON `systemMessage` output so Claude Code
surfaces the note without interrupting your flow. Guard clauses exit
silently (`exit 0`) when a hook doesn't apply.

**Document for the next human.** Bash scripts carry a header comment
explaining purpose and behaviour. The README documents the full
plugin. When in doubt, write the sentence you'd have wanted to read
before you started.

---

## What's Enforced

The harness declares 28 constraints. Here's what fires, grouped by
when you'll meet it.

### At commit time

These are fast, local checks — run them before you push and you'll
sail through CI:

- **No secrets in source** — gitleaks scans for API keys, tokens,
  passwords, and private keys. A hit blocks the commit.
- **Consistent markdown formatting** — every `.md` file must pass
  markdownlint with the project's config, no warnings.
- **Shell scripts pass syntax check** — every `.sh` file must pass
  `bash -n`.
- **Shell scripts use strict mode** — every `.sh` file must contain
  `set -euo pipefail` within its first 15 lines.
- **ShellCheck compliance** — every `.sh` file must pass ShellCheck
  with no errors.

### At PR time

These are the CI gates that block a merge:

- **All frontmatter has name and description** — every skill, agent,
  and command file must have both.
- **Spec-first commit ordering** — for feature or behaviour-change
  PRs, the first commit on the branch contains only a spec file in
  `docs/superpowers/specs/`. Bug-fix, dependency, and maintenance PRs
  (labelled `bug`, `fix`, `chore`, `maintenance`, or branch-prefixed
  `fix/`, `chore/`) are exempt.
- **Spec-scoped changes / Spec captures intent** — one concern per
  PR, traceable to a spec that states the problem, approach, and
  outcome.
- **PRs have adjudicated objections** — feature PRs carry a spec-mode
  and a code-mode objection record (`/diaboli`) with every disposition
  resolved.
- **Objection records use the canonical taxonomy** — every objection
  record uses the canonical advocatus-diaboli categories (`premise`,
  `scope`, `implementation`, `risk`, `alternatives`, `specification
  quality`) and severities (`critical`, `high`, `medium`, `low`), in
  both spec and code mode.
- **PRs have adjudicated choice stories** — non-exempt PRs carry a
  choice-story record (`/choice-cartograph`) with every story
  dispositioned, or claim an exempt label.
- **Version consistency / Marketplace plugin version sync / Release
  traceability** — `plugin.json`, the README badge, the CHANGELOG
  heading, and `marketplace.json`'s `plugin_version` and
  `plugins[].version` must all agree, and every shipped version needs a
  matching git tag.
- **Docs site builds in strict mode** — PRs touching `docs/**`,
  `mkdocs.yml`, or `requirements.txt` must pass `mkdocs build
  --strict` (catches broken internal links before they reach main).
- **Docs site kept current / Docs propagation when shipping new
  commands** — when you add, remove, or substantially change a skill,
  agent, or command, the matching docs pages are updated in the same
  PR.
- **New plugin components must ship with a TDAD scenario** — a new
  skill/agent/command file ships with at least one scenario under
  `tdad_tests/scenarios/`.
- **New plugin components must ship with a reference-page entry** — a
  new component adds an `### <name>` heading to its Diataxis reference
  page.
- **Every marketplace plugin appears in the docs index pages** — every
  plugin in `marketplace.json` is linked from both `docs/index.md` and
  `docs/plugins/index.md`.
- **TDAD fast-suite passes (Layers 0 + 1)** — the offline plumbing and
  structural tests run green on any PR touching plugin code.
- **Layer 0 bash tests run on macOS and Linux** — the deterministic
  bash tests must pass under both BSD and GNU coreutils. Currently
  *unverified*: declared as a guard but awaiting a `macos-latest` leg
  on the CI runner matrix.
- **Output validation checkpoints** — every command that writes
  structured output reads it back and checks it against the format
  spec.
- **Spec redaction markers must be visible** — superseded spec prose
  is marked with a visible blockquote, never an HTML comment.
- **Tests must pass** — declared but currently *unverified*: there is
  no application test runner to wire it to yet.

### On schedule

These periodic garbage-collection checks fight the slow drift that PR
gates miss (19 GC rules in total, run weekly or monthly):

- **Documentation freshness** — flags README/HARNESS/CLAUDE references
  to things that no longer exist.
- **Secret scanner operational / Snapshot staleness / Template
  currency / Release tag completeness** — deterministic health checks
  on the harness itself.
- **Plugin manifest currency / Marketplace listing drift** — keep
  `plugin.json` and `marketplace.json` honest about what the plugin
  actually contains.
- **Change cadence drift** — watches PR size and spec-to-merge time so
  AI-speed production doesn't outrun the human pace.
- **Convention file sync** — keeps `.cursor/`, `.github/copilot-
  instructions.md`, and `.windsurf/` in step with HARNESS.md.
- **Reflection log archival / aged-out review / regression detection**
  — curate `REFLECTION_LOG.md` and surface recurring failure patterns.
- **Reflections via PR workflow** — additions to `REFLECTION_LOG.md`
  go through a PR, never a direct commit to main.
- **Onboarding document staleness / Redirect sunset / Observability
  archive / Objection record freshness / Docs-site strict-build
  sweep** — the rest of the entropy patrol.

---

## Common Pitfalls

Lessons the team learned the hard way, so you don't have to.

- **Run the deterministic tools before you trust a review.** ShellCheck
  once found 4 issues in scripts that had already passed both an
  implementer and a spec-compliance review — unused variables and
  sed-vs-parameter-expansion idioms are invisible to LLM review but
  obvious to a linter. Run markdownlint, ShellCheck, and `bash -n`
  locally; deterministic tools catch what reading misses.

- **The harness is self-referential — mind which HARNESS.md you're
  editing.** The plugin ships `templates/HARNESS.md`, and the project's
  own root `HARNESS.md` is a *separate* file generated from it. Editing
  the template does not change the project's harness, and vice versa.
  Drift between the two is exactly what the manifest-currency and
  command-prompt-sync GC rules exist to catch.

- **Grep `.github/workflows/` before proposing a new CI check.** The
  project already has a dozen-plus workflows (`harness.yml`,
  `version-check.yml`, `spec-first-check.yml`, `tdad-tests-fast.yml`,
  `docs-build-check.yml`, `objection-taxonomy-check.yml`, `gc.yml`, and
  more). Proposing a duplicate wastes a branch cycle.

- **Watch for BSD-vs-GNU shell traps in deterministic check scripts.**
  Scripts that pass on a macOS dev machine can fail (or worse, silently
  self-skip a safety check) on the Linux CI runner. `grep '\|'` is a
  *literal* under BSD grep — and the Claude Code harness aliases `grep`
  to `ugrep`, so the bug passes locally; verify with `/usr/bin/grep`.
  `date -u -j -f '%Y-%m-%d'` does not pin UTC midnight on BSD; `stat
  -f%z` (BSD) vs `-c%s` (GNU) differ; pin `sort` with `LC_ALL=C`. Write
  check scripts POSIX-only.

- **When a structural test asserts a doc *declares* a phrase, mind the
  line wrap.** Layer-1 tests grep for a phrase to confirm a guarantee
  is present; if you wrap a bolded multi-word phrase across two lines
  (`**falls\nback**`), the substring check fails even though the
  content is correct. When authoring, keep the asserted phrase on one
  line (line length is unlinted here — MD013 is off). When writing the
  test, assert the words as co-occurring tokens, not one joined
  substring.

- **MkDocs resolves links from the source file's directory, not from
  `docs/`.** A link like `plugins/foo.md` written in
  `docs/contributing/index.md` resolves to
  `docs/contributing/plugins/foo.md`. Markdownlint won't catch it; the
  strict build will. Run `mkdocs build --strict` before opening a docs
  PR. For repo-internal paths *outside* `docs/`, use a plain code span
  (`` `path/to/file.md` ``) rather than a markdown link.

- **Incremental plugin work leaves marketplace-level surfaces stale.**
  When a plugin ships across several slices, each PR tends to update
  that plugin's own docs but never the marketplace-level surfaces
  (homepage table, plugins index, install block) that belong to no
  single slice. The diagnostic-legibility plugin shipped across five
  PRs without ever landing on the homepage. The final slice of a plugin
  chain should update those cross-cutting surfaces — and there's now a
  deterministic check that enforces it.

- **Long sessions quietly degrade judgment.** Output keeps flowing, but
  pattern-matching narrows and surprise-detection drops — and it's
  invisible from inside the session. Take time-based breaks (a
  90-minute self-check, an end-of-day stop), not task-based ones. If
  the next decision is about *whether* to do something rather than
  *how*, and you've been going for 90+ minutes, defer it to a fresh
  session.

---

## Architecture Decisions

The team has already settled these — here's the reasoning, so you can
build on them rather than relitigate them.

- **Content-emitting agents follow agent-emit + dispatcher-persist +
  human-disposes.** A research-and-author agent's tool boundary is
  read-only (no Edit, no Bash); it returns content as a string; the
  dispatching command writes the file *after* a structured human
  review (accept / edit / re-run / abort). The load-bearing invariant
  is the *ordering*: the human disposition must precede the write. A
  spec can honour the tool split and still break the invariant by
  writing first and summarising after — so check the ordering, not
  just the tool boundary. In production across `advocatus-diaboli`,
  `choice-cartographer`, `model-card-researcher`, `/diagnose`, and
  `/cost-estimate`.

- **An agent that derives a judgment a human used to supply carries a
  disclosure obligation.** When an agent emits a value formerly
  ground-truth supplied by a human (a derived *prediction*, not an
  inspected fact), the artefact must disclose four parts: what it
  included, what it consciously excluded, its confidence, and the
  failure direction when confidence is below high — never a silent
  boundary or a single number as fact. The Rule of Three has fired;
  this is now a confirmed cross-cutting design discipline (the
  cost-estimation skill's estimate-record is the worked instance).

- **A change to a shared/merged contract gets its own owning slice with
  its own adversarial pass — a consumer never mutates the contract it
  consumes.** When a slice needs to change a reference, schema, or
  format that other slices depend on, carve the change into a dedicated
  slice that *owns* that artefact and runs its own diaboli pass, rather
  than mutating it in-place from a consumer slice (which inherits only
  the consumer's adversarial budget, not the contract's
  backward-compatibility scrutiny).

- **Human-cognition gates require propose-with-rationale-and-wait, not
  silent adjudication — even in auto-mode.** The diaboli and
  cartographer gates exist to force human engagement with substantive
  decisions. When an agent writes the dispositions itself, the gate
  becomes documentation-only. The working pattern: surface the record,
  propose dispositions-with-rationale via `AskUserQuestion`, and write
  only after an explicit human choice.

- **Agents producing structured output for programmatic consumers use
  dispatcher-first error contracts.** No silent fallback on
  unrecognised input. Such an agent specs *both* a success shape and a
  single-line, pattern-matchable refusal shape (prefixed with the agent
  name and the literal `refusal:`), emitted *instead of* the success
  block — never alongside it. A forgiving fallback silently corrupts
  dispatcher intent; a structured refusal fails loud and
  machine-legibly.

- **Schema evolution routes by fact granularity.** Where a new fact
  lives on a schema surface is decided by whether it varies per element
  (reuse the per-element field with a string-prefix convention — no
  schema touch) or applies to the whole record (add an additive
  optional wrapper field — a schema touch is justified). Every
  audit-trail entry has exactly one author and one source.

- **The cognitive-reservoir verifier-watch is advisory-only and is NOT
  a Constraint.** The `cognitive-reservoir` skill, `reservoir-warden`
  agent, `/reservoir` command, and `reservoir-check` Stop hook watch
  the *human verifier* — the one actor every other enforcement surface
  trusts blindly. They count observable proxies (session span, decision
  volume, context switches, wall-clock hour) and infer risk, but the
  inputs cannot support a precise measurement of cognitive state. So it
  lives in its own opt-in HARNESS.md block, never blocks a
  commit/merge/session, never exits non-zero, and persists no record of
  the human's state to disk. Promoting it into a CI gate breaks the
  design.

- **Hook scripts never block, only warn.** This plugin runs across
  diverse projects; a blocking hook could break workflows the authors
  can't predict. Advisory messages let users decide. Configurable
  blocking was considered and rejected as unjustified complexity.

- **Health snapshots are generated artifacts committed straight to
  main.** They don't affect behaviour, and gating them on PR review
  would add friction to the observability cadence.

- **Every structured-output command includes a validation checkpoint.**
  Generate, read back, check against the format spec, fix in place.
  Agents drift from format specs under cognitive load; the checkpoint
  is the verification layer, analogous to type checking. Relying on
  agent instructions alone was tried across 8 commands and proved
  unreliable.

- **`advocatus-diaboli` is hard-wired into the spec-first pipeline, and
  runs at two dispatch points** — spec-time (after spec-writer, before
  plan approval) and code-time (after the final code-reviewer PASS).
  It's one agent with mode-based weighting, not two agents. Manual
  invocation and advisory-only gates were rejected because they create
  ceremony, not discipline.

- **Cross-cutting methodology lives in `skills/<name>/references/`
  files**, consumed by reference rather than inlined at each consumer.
  Edits land in one place and propagate; inlining silently drifts.

- **A "natural home" hand-off in one slice does not bind the next.**
  When a slice defers a concern by pointing at a later slice, that's a
  suggestion, not a commitment the later slice inherits. Repeatedly
  handing the same concern forward accrues *deferred-concern-accretion
  debt*. When a slice declines an inherited hand-off, either absorb the
  concern or re-file it as a standalone issue bound to a *scheduled
  deliverable* — never leave it implicit in a closed slice's "out of
  scope" section.

---

## How We Test

This project has no application code and no application test suite.
Quality is assured entirely by deterministic content validation and a
layered behavioural test suite:

- **Content validation (always on, in CI via `harness.yml`)** —
  markdownlint for markdown, ShellCheck plus `bash -n` for shell, and
  gitleaks for secrets. All deterministic, all fast.

- **TDAD test suite (`tdad_tests/`, pytest + Claude Agent SDK)** —
  organised in layers. **Layer 0** is deterministic bash plumbing;
  **Layer 1** is structural (frontmatter well-formedness, component
  existence, scenario-target resolution). Both run offline with no API
  key, finish in under ten seconds, and gate every PR via
  `tdad-tests-fast.yml`. **Layers 2 (trigger)** and **3
  (behavioural)** need an `ANTHROPIC_API_KEY` and per-run cost, so they
  are not part of the PR gate.

When you write a structural test that asserts a doc *declares* a
guarantee, assert the words as co-occurring tokens rather than one
joined substring — markdown reflows across lines and a wrapped phrase
will break a naïve substring check even when the content is correct.
And when you add a new deterministic security gate (like the INV-1
firewall), have it adversarially probed — green unit tests prove only
the cases you imagined.

To run the fast suite locally: from `tdad_tests/`, set up the Python
virtualenv and run `pytest` against the Layer 0 and Layer 1
directories. To run the content checks, run markdownlint, ShellCheck,
and gitleaks against the tree — the same commands the harness declares.

---

## How the Harness Works

Three enforcement loops protect the codebase, each catching what the
others can't:

- **Advisory loop** — hooks that warn while you edit. They never block;
  they surface a `systemMessage` and let you decide.
- **Strict loop** — CI gates that block merges. This is where the
  PR-time constraints above live.
- **Investigative loop** — scheduled garbage-collection rules that
  catch the slow drift neither hooks nor PR gates see (stale docs,
  manifest drift, cadence creep).

The harness also declares an **Affordances** inventory — the tools the
agent is allowed to invoke, the identity each runs under, and the audit
trail each leaves. Right now the project declares one real affordance
(`gh-cli`, running under the human's GitHub OAuth identity) alongside
example entries. Identity is the load-bearing governance question:
whose credentials authorise the action.

The project runs on an observability cadence. Health snapshots are
generated **monthly**. The `/harness-audit`, `/assess`, and
`/cost-capture` activities run **quarterly** (every 90 days), and
reflection review and promotion runs **monthly**. The quarterly
activities are meant to run as a single sitting — one working block,
anchored to the governance audit, not three scattered tasks.

When a task looks long-running, massively parallel, highly structured,
or adversarial, the `dynamic-workflows` skill carries the patterns for
spinning up a self-authored ephemeral multi-agent harness. Workflows
are opt-in (the static pipeline stays the default), Claude-Code-only,
and governed by two invariants: an ephemeral workflow never writes a
durable curated artefact directly (INV-1), and untrusted output is
quarantined (INV-2).

---

## Your First PR Checklist

Work through this before you push:

1. **Branch first.** Never commit to `main` — `git checkout -b
   <short-descriptive-name>`. Use a `fix/` or `chore/` prefix if the
   change is a bug fix or maintenance (it claims the spec-first
   exemption).
2. **Spec first, if it's a feature.** For a feature or behaviour
   change, make the first commit a spec-only commit under
   `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`. Only files in
   `docs/superpowers/specs/` may appear in that commit — a plan file
   under `docs/superpowers/plans/` will trip the gate.
3. **Run the local checks.** markdownlint on your `.md` files,
   ShellCheck plus `bash -n` on any `.sh` files, and gitleaks across
   the tree. If you touched `docs/**`, also run `mkdocs build
   --strict`.
4. **Update the CHANGELOG.** Add an entry under the current version
   heading (`## X.Y.Z — YYYY-MM-DD`). If your change touches files
   inside `ai-literacy-superpowers/`, bump the version in the five
   CI-checked locations together — `plugin.json`, the README badge, the
   CHANGELOG heading, and `marketplace.json`'s `plugin_version` and the
   plugin's `plugins[].version` entry.
5. **Update the docs.** If you added or changed a skill, agent, or
   command, update its how-to / reference / explanation pages and add a
   TDAD scenario and a reference-page entry in the same PR.
6. **Keep commit messages clean.** Describe what changed and why. No
   postamble, trailer, or attribution lines.
7. **Label at creation time.** If the PR needs a `chore`, `fix`, or
   `cross-repo` label to bypass a gate, pass `--label <label>` in the
   `gh pr create` command itself — labels added later are invisible to
   already-queued CI.
8. **Wait for green, then merge.** Let CI pass before merging; merge
   only when every check is green.

---

## Where to Learn More

- [HARNESS.md](HARNESS.md) — the full constraint, GC, affordance, and
  convention reference
- [AGENTS.md](AGENTS.md) — accumulated team knowledge, gotchas, and
  architecture decisions
- [REFLECTION_LOG.md](REFLECTION_LOG.md) — session-by-session learnings
- [CLAUDE.md](CLAUDE.md) — the working conventions (branching, PRs,
  versioning, docs)
- [README.md](README.md) — the full plugin documentation
- [Docs site](https://habitat-thinking.github.io/ai-literacy-superpowers/)
  — the rendered guides, references, and concept pages
