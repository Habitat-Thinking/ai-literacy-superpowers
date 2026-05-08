---
title: Getting Started
---
# Getting Started

This tutorial walks you through installing the ai-literacy-superpowers plugin,
running the harness initialiser on a project, and understanding what you get at
the end. It takes about fifteen minutes.

---

## Prerequisites

You need Claude Code installed and working. If you haven't done that yet,
follow [Anthropic's Claude Code installation guide](https://docs.anthropic.com/en/docs/claude-code)
and come back here once `claude` runs in your terminal.

You do not need any other tools installed in advance. The plugin will tell you
if anything is missing and what to do about it.

---

## Step 1: Install the Plugin

From any terminal:

```bash
claude plugin marketplace add Habitat-Thinking/ai-literacy-superpowers
claude plugin install ai-literacy-superpowers
```

Claude Code downloads the plugin from the marketplace and registers it. You
should see output similar to:

```text
Installing ai-literacy-superpowers from marketplace Habitat-Thinking...
Plugin installed: ai-literacy-superpowers
  24 skills
  10 agents
  15 commands
```

The plugin is now available in every Claude Code session. You don't need to
install it per-project.

---

## Step 2: Open a Project

Navigate to the project you want to set up. This can be an existing codebase
or a new empty directory — harness-init works either way.

```bash
cd my-project
claude
```

You're now in a Claude Code session with access to all plugin commands.

---

## Step 3: Run `/harness-init`

Type the following at the Claude Code prompt:

```text
/harness-init
```

The command dispatches the `harness-discoverer` agent to scan your project
before asking you anything. This takes a few seconds. You'll see something like:

```text
Scanning project structure...

Discovery complete. Here's what your project already has:

Stack
  Primary language: TypeScript
  Build system: npm / tsc
  Test framework: Jest
  CI: GitHub Actions (.github/workflows/ci.yml)

Existing enforcement
  Prettier configured (.prettierrc)
  ESLint configured (.eslintrc.json)
  No pre-commit hooks detected
  No secret scanner detected

Convention documentation
  README.md (found)
  No CLAUDE.md detected
```

The scan surfaces what already exists so the conversation can build on it
rather than starting from scratch.

### Choosing what to configure

After discovery, the command presents a feature selection menu:

```text
Which harness features would you like to configure?
All features are selected by default. Deselect any you want to skip
for now — you can always add them later by re-running /harness-init.

  [x] Context engineering     — stack declaration + conventions
  [x] Architectural constraints — enforcement rules + secret detection
  [x] Garbage collection      — periodic entropy checks
  [x] CI configuration        — GitHub Actions workflow + auto-enforcer
  [x] Observability           — README badge + status section
```

For your first time, accepting all defaults is a good choice. If you want
to start smaller — say, just context and constraints — deselect the others.
The command only asks questions about the features you selected.

{: .note }
> **Re-running is additive.** If you run `/harness-init` again later, it
> detects which features are already configured and defaults them to off.
> Unconfigured features default to on. Your existing configuration is
> preserved — you're only adding to it.

### What it asks you

For each selected feature, `/harness-init` works through a short interview.

**Context engineering** covers four convention topics, one at a time:

- **Naming conventions.** How the team names things — casing patterns,
  prefix/suffix rules. The agent offers concrete options based on what
  the discoverer found in your code.
- **File structure.** How files are organised. The agent looks at your
  directory layout and suggests a description. You confirm or refine it.
- **Error handling.** How errors are propagated — thrown exceptions,
  return types, or a Result pattern.
- **Documentation standards.** Which files require doc comments and what
  comments should explain.

Answer concretely. The more specific you are, the more useful the HARNESS.md
will be.

**Architectural constraints** asks whether each convention should be enforced.
For conventions where a tool exists (Prettier, ESLint, Jest), it offers to set
enforcement to `deterministic` and configure it for commit or PR scope. For
conventions without a tool, it offers agent-based enforcement or leaves the
constraint as `unverified` — declared but not yet automated.

Secret detection is handled as a special case. The agent checks whether
`gitleaks` is installed:

- If gitleaks is found, the "No secrets in source" constraint is set to
  `deterministic` and the tool command is configured automatically.
- If gitleaks is not found, the constraint is set to `unverified` and you
  are given the install command:

```text
gitleaks is not installed. The "No secrets in source" constraint
will be set to unverified for now.

To install:
  macOS:     brew install gitleaks
  Linux/Go:  go install github.com/gitleaks/gitleaks/v8@latest

After installing, run /harness-constrain to promote the constraint
to deterministic.
```

**Garbage collection** asks about periodic checks — weekly or monthly sweeps
that catch drift that neither commit-time hooks nor PR gates see. The defaults
are:

- Documentation freshness (weekly, agent)
- Dependency currency (weekly, agent)
- Secret scanner still operational (weekly, deterministic)

You can add, remove, or adjust frequency.

**CI configuration** generates a GitHub Actions workflow with deterministic
constraint steps. If your harness includes agent-based PR constraints, it
also offers the auto-enforcer action. This step is skipped if you didn't
select any constraints — there would be nothing to enforce.

**Observability** adds a badge to your README that links to HARNESS.md and
shows the enforcement ratio. This step is skipped if no harness content
was generated.

### What gets generated

After the interview, the agent generates files for the features you selected:

- `HARNESS.md` at the project root — the source of truth for your harness.
  Sections for features you didn't select are marked as unconfigured.
- `.github/workflows/harness.yml` — CI enforcement for deterministic
  constraints (if CI configuration was selected and GitHub Actions detected)
- A badge line in `README.md` — linking to HARNESS.md with an enforcement
  count (if observability was selected)

All generated files are staged and committed with the message:
`Initialize project harness with HARNESS.md`

---

## Step 4: Understand HARNESS.md

Open `HARNESS.md` in your editor. It has four sections.

### Context

The context section records what any agent — or new team member — needs to
know to work effectively in this codebase:

```markdown
## Context

### Stack

- **Primary languages**: TypeScript
- **Build system**: npm / tsc
- **Test framework**: Jest
- **Container strategy**: Docker, single-stage builds

### Conventions

- **Naming**: camelCase for variables and functions, PascalCase for
  interfaces and types, UPPER_SNAKE_CASE for constants
- **File structure**: One exported item per file, organised by feature
  in src/features/, shared utilities in src/lib/
- **Error handling**: Thrown exceptions for unexpected states, Result<T>
  return type for expected failure paths
- **Documentation**: Public functions require JSDoc with @param and
  @returns. Comments explain why, not what.
```

This section is read by agents at the start of every session. Keeping it
accurate and specific is the main maintenance task for a harness.

### Constraints

Each constraint is a rule with an enforcement level:

```markdown
## Constraints

### Consistent formatting

- **Rule**: All source files must pass Prettier without changes
- **Enforcement**: deterministic
- **Tool**: npx prettier --check .
- **Scope**: commit

### No secrets in source

- **Rule**: No API keys, tokens, passwords, or private keys may appear
  in committed source files
- **Enforcement**: deterministic
- **Tool**: gitleaks detect --source . --no-banner --exit-code 1
- **Scope**: commit

### Tests must pass

- **Rule**: The project's test suite must pass with zero failures before
  any code is merged
- **Enforcement**: deterministic
- **Tool**: npm test
- **Scope**: pr

### Architecture layer boundaries respected

- **Rule**: No imports from the api/ layer into the domain/ layer
- **Enforcement**: agent
- **Tool**: harness-enforcer agent
- **Scope**: pr
```

Enforcement has three levels:

- **deterministic** — a tool runs and exits non-zero if the rule is
  violated. No judgment involved.
- **agent** — an LLM agent reviews the change and reports violations.
  Useful for rules that cannot be expressed as a tool check.
- **unverified** — the constraint is declared but not yet backed by
  any enforcement. It serves as documentation and a reminder to automate later.

Scope controls when the check runs:

- **commit** — runs as a pre-commit hook (fast, local)
- **pr** — runs in CI before merge (strict gate)
- **commit + pr** — both

### Garbage Collection

GC rules catch the slow drift that real-time checks miss:

```markdown
## Garbage Collection

### Documentation freshness

- **What it checks**: Whether README.md, HARNESS.md, and inline doc
  comments reference files or functions that no longer exist
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent
- **Auto-fix**: false

### Dependency currency

- **What it checks**: Whether project dependencies have known
  vulnerabilities or are more than one major version behind latest
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent
- **Auto-fix**: false
```

Run `/harness-gc` to trigger GC checks on demand, or let the schedule
handle them.

### Status

The status section is updated automatically by `/harness-audit`. Do not
edit it manually:

```markdown
## Status

Last audit: 2026-04-06
Constraints enforced: 3/4
Garbage collection active: 2/2
Drift detected: none
```

This is what the badge in your README reflects.

---

## Step 5: Run Your First Constraint Check

With `HARNESS.md` in place, run:

```text
/harness-status
```

This reads the harness and prints a summary without dispatching any agents:

```text
## Harness Status

Last audit: 2026-04-06 (0 days ago)

### Constraints: 3/4 enforced
- Deterministic: 3 (tool-backed)
- Agent: 1 (LLM-reviewed)
- Unverified: 0 (declared only)

### Garbage Collection: 2/2 active
- Auto-fix enabled: 0 rules
- Report-only: 2 rules

### Drift: none detected

### Next Steps
- Run /harness-constrain to add or promote constraints
- Run /harness-sync to keep all surfaces in alignment, or /harness-audit for a read-only diagnostic
- Run /harness-gc to run garbage collection checks
```

The enforcement ratio (3/4 in this example) is the key number to watch.
A ratio below 1.0 means some constraints are declared but not yet automated.
Use `/harness-constrain` to promote them when you have the tooling in place.

---

## What You Have Now

After completing this tutorial you have:

- A `HARNESS.md` that records your conventions, constraints, and GC schedule
  (for the features you selected)
- CI enforcement for deterministic constraints (if you selected CI
  configuration and GitHub Actions is in use)
- A `README.md` badge that links to the harness and shows its enforcement
  ratio (if you selected observability)
- A working `/harness-status` command to check health at any time

If you selected all features, your harness is fully configured. If you started
with a subset, you can run `/harness-init` again at any time to add the
remaining features — your existing configuration is preserved.

The harness is a living document. It is expected to grow as you add constraints,
run reflections, and discover patterns worth encoding.

---

## Next Steps

- [A First-Time Tour of Every Capability](first-time-tour.md) — the full
  tour of every command in the order it is most useful, with the reason
  each step comes where it does
- [Creating Your First Skill](your-first-skill.md) — encode domain knowledge
  that agents will carry into every session
- [Harness for an Existing Codebase](harness-from-scratch.md) — strategies for
  retrofitting a harness into a project that already has conventions but no
  enforcement
- [How-to Guides](../index.md) — specific tasks: adding a constraint, setting
  up secret detection, running a harness audit
- [Reference: Commands](../reference/commands.md) — full specification for every
  slash command
