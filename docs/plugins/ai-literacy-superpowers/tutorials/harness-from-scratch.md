---
title: Harness for an Existing Codebase
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 3
redirect_from:
  - /tutorials/harness-from-scratch/
  - /tutorials/harness-from-scratch.html
---

# Harness for an Existing Codebase

Most projects already have conventions — they just aren't written down
or enforced consistently. This tutorial covers how to retrofit a harness
into a codebase that has an established style, existing CI, and opinions
that may not match the plugin's defaults: how to surface what already
exists, encode it faithfully in HARNESS.md, avoid duplicating rules
already handled by linters or workflows, and promote unverified
constraints to deterministic enforcement incrementally rather than
all at once.

It takes about thirty minutes the first time through. You will end with a
HARNESS.md that describes your project accurately, constraints that build
on what you already have, and a clear path to promote each one when you
are ready.

---

## Prerequisites

Before starting, make sure you have:

- Claude Code installed with the ai-literacy-superpowers plugin (see
  [Getting Started](getting-started) if you haven't done this yet)
- An existing project with at least some CI in place
- A few minutes to talk through your conventions — the extraction
  conversation is the most valuable part

You do not need to clean up your codebase first. The commands work on
real, in-progress projects.

---

## Step 1: Surface Tacit Knowledge with `/extract-conventions`

Before touching HARNESS.md, run the convention extraction session. This
is what separates retrofitting from guessing — it ensures the harness
reflects what your team actually does, not what a template assumes.

```text
/extract-conventions
```

The command checks that CLAUDE.md and HARNESS.md exist. If either is
missing, it will tell you what to run first. If this is a net-new setup,
run `/harness-init` first to create the skeleton, then come back here.

Once the session starts, you will see:

```text
## Convention Extraction

I'll ask five questions to surface your team's tacit conventions.
For each answer, I'll categorise it as:

- **Constraint** (must-follow) → goes in HARNESS.md
- **Convention** (should-follow) → goes in CLAUDE.md
- **Style preference** (nice-to-have) → goes in CLAUDE.md
- **Not encodable yet** → needs decomposition before encoding

Take your time — the conversation matters as much as the output.
```

The five questions are:

1. **Architecture** — What decisions should never be left to individual
   judgment? Dependency direction, module boundaries, API rules.
2. **AI corrections** — Which conventions do you keep fixing in
   AI-generated code? These are your highest-value items.
3. **Security instincts** — What security checks do senior engineers
   apply automatically?
4. **Review rejections** — What triggers an immediate rejection in code
   review?
5. **Refactoring philosophy** — Where is the line between helpful
   abstraction and unnecessary complexity?

Answer concretely. After each answer the agent restates it, asks one
follow-up to sharpen the wording, and proposes a category. You confirm
before it writes anything.

{: .note }
> **"It depends" is a signal, not a failure.** If an answer keeps landing
> on "it depends on context," that convention needs decomposition into
> specific, observable cases before it can be encoded. The agent will
> flag these as "not encodable yet" — that is useful information, not
> a problem to solve today.

At the end, the agent compiles everything and presents a summary before
writing:

```text
## Proposed Additions

### HARNESS.md Constraints (must-follow)

1. No imports from api/ into domain/ — dependency direction rule
2. All returned errors must be wrapped with context

### CLAUDE.md Conventions (should-follow)

1. Variables must be 3+ characters except i, j, k, err
2. Functions must not exceed 40 lines

### Not Encodable Yet (needs decomposition)

1. "Write clean code" — needs decomposition into observable properties
```

Confirm, and the agent appends the conventions to CLAUDE.md and adds the
constraints to HARNESS.md as `unverified` — declared but not yet
automated. You will promote them in later steps.

---

## Step 2: Run `/harness-init` with Selective Features

Now run the initialiser. Because you already have CI and linters, you
will be selective about what to configure:

```text
/harness-init
```

The `harness-discoverer` agent scans the project first. You will see
output like:

```text
Discovery complete. Here's what your project already has:

Stack
  Primary language: Go
  Build system: make / go build
  Test framework: go test
  CI: GitHub Actions (.github/workflows/ci.yml)

Existing enforcement
  golangci-lint configured (.golangci.yml)
  go vet in CI
  No pre-commit hooks detected
  No secret scanner detected

Convention documentation
  README.md (found)
  CLAUDE.md (found — 47 lines)
  HARNESS.md (found — constraints: 2 unverified)
```

The discovery report surfaces what is already enforced. This matters for
the next step.

After discovery, you will see the feature selection menu:

```text
Which harness features would you like to configure?

  [x] Context engineering     — stack declaration + conventions
  [x] Architectural constraints — enforcement rules + secret detection
  [x] Garbage collection      — periodic entropy checks
  [ ] CI configuration        — GitHub Actions workflow + auto-enforcer
  [x] Observability           — README badge + status section
```

Notice that CI configuration is deselected here. If your project already
has a working CI pipeline, you will wire harness constraints into it
manually rather than generating a new workflow. Check the box only if you
want the plugin to generate a separate harness workflow file alongside
your existing one.

Deselect any features you already have covered. You can always re-run
`/harness-init` later to add what you skipped.

---

## Step 3: Review What Was Generated

Open `HARNESS.md`. Pay attention to the Constraints section — this is
where the work of avoiding duplication happens.

You will see entries like:

```markdown
## Constraints

### Consistent formatting

- **Rule**: All source files must pass gofmt without changes
- **Enforcement**: deterministic
- **Tool**: gofmt -l .
- **Scope**: commit

### No secrets in source

- **Rule**: No API keys, tokens, passwords, or private keys in source
- **Enforcement**: unverified
- **Tool**: none yet
- **Scope**: commit

### No imports from api/ into domain/

- **Rule**: The domain layer must not import from the api layer
- **Enforcement**: unverified
- **Tool**: none yet
- **Scope**: pr
```

Now compare this against what your CI already enforces. Look at
`.github/workflows/ci.yml` (or whichever CI file you have). For each
constraint in HARNESS.md, ask: is this already checked?

---

## Step 4: Avoid Duplication — Map Existing Enforcement

The key discipline when retrofitting is not re-declaring what tools
already enforce. Duplication creates two sources of truth for the same
rule, which drift and contradict each other.

For each HARNESS.md constraint, decide which bucket it falls into:

**Already enforced deterministically**: your linter, formatter, or CI
job catches this mechanically. For example, if `golangci-lint` already
enforces function length, do not add a harness constraint for function
length. Set the existing constraint to `deterministic` and record the
tool that runs it — the harness is documenting reality, not creating
new enforcement.

**Enforced, but not by a deterministic tool**: architectural rules, doc
comment quality, naming conventions. A linter might catch some of these,
but the rule requires judgment. These are candidates for `agent`
enforcement.

**Declared but not enforced**: conventions your team follows but no tool
checks. These start as `unverified` and get promoted over time.

Update each constraint's enforcement field to reflect reality:

```markdown
### Consistent formatting

- **Rule**: All source files must pass gofmt without changes
- **Enforcement**: deterministic
- **Tool**: gofmt -l .
- **Scope**: commit
```

```markdown
### No imports from api/ into domain/

- **Rule**: The domain layer must not import from the api layer
- **Enforcement**: agent
- **Tool**: harness-enforcer agent
- **Scope**: pr
```

```markdown
### No secrets in source

- **Rule**: No API keys, tokens, passwords, or private keys in source
- **Enforcement**: unverified
- **Tool**: none yet
- **Scope**: commit
```

{: .note }
> **The harness does not need to own every constraint.** If golangci-lint
> already enforces naming conventions, you can omit that constraint from
> HARNESS.md entirely, or note it in a comment. The harness tracks what
> matters for orientation and gap-filling — not what is already handled.

---

## Step 5: Promote Incrementally

With your constraints categorised, start promoting them. The promotion
ladder has three rungs:

1. **Unverified** — declared intent, no automation
2. **Agent** — LLM review against the prose rule
3. **Deterministic** — tool-backed, exits non-zero on failure

Use `/harness-constrain` to promote a constraint when you are ready:

```text
/harness-constrain
```

The command walks through each unverified constraint and asks what you
want to do with it. For a constraint like "no secrets in source":

```text
Constraint: No secrets in source
Current enforcement: unverified

Options:
  1. Promote to deterministic — gitleaks is not installed.
     Install: brew install gitleaks
     Then re-run to set enforcement to deterministic.

  2. Promote to agent — the harness-enforcer agent will review
     changes for hardcoded credentials.

  3. Leave as unverified for now.
```

Start with the constraints where tooling already exists. Add `gitleaks`
for secret detection. Use `go-cleanarch` or similar for import boundary
rules if your language ecosystem has one. Leave complex judgment calls as
`agent` — the harness-enforcer handles them well.

Do not try to promote everything at once. An unverified constraint is
not a failure — it is a documented intention. The goal is steady
improvement over time, not a complete harness on day one.

---

## Step 6: Verify with `/harness-status`

Once you have reviewed and updated HARNESS.md, run:

```text
/harness-status
```

This reads the harness and prints a summary without dispatching any
agents:

```text
## Harness Status

Last audit: 2026-04-08 (0 days ago)

### Constraints: 2/4 enforced
- Deterministic: 1 (tool-backed)
- Agent: 1 (LLM-reviewed)
- Unverified: 2 (declared only)

### Garbage Collection: 2/2 active
- Auto-fix enabled: 0 rules
- Report-only: 2 rules

### Drift: none detected

### Next Steps
- Run /harness-constrain to promote unverified constraints
- Run /harness-audit for a full verification
```

The enforcement ratio (2/4 in this example) is the key number to watch.
A ratio below 1.0 means some constraints are declared but not yet
automated. That is expected when retrofitting — use this number as a
target to improve over time rather than a pass/fail score.

{: .note }
> **Re-run `/harness-init` to add features later.** If you skipped CI
> configuration this time, you can run `/harness-init` again to add it.
> The command detects which sections are already configured and only
> touches the sections you select.

---

## What You Have Now

After completing this tutorial you have:

- A `HARNESS.md` that describes your project accurately — conventions
  extracted from your team's tacit knowledge, constraints that build on
  your existing enforcement rather than duplicating it
- A clear categorisation of every constraint: what is already enforced
  deterministically, what needs agent review, and what is declared but
  not yet automated
- A promotion path — unverified constraints with a clear record of what
  they need to become deterministic
- A `CLAUDE.md` with conventions that any AI agent (or new team member)
  can read to understand how your project works

The harness is now a living document. Run `/harness-audit` periodically
to check for drift between what HARNESS.md declares and what is actually
enforced. Run `/extract-conventions` again after significant team
changes or after a production incident reveals tacit knowledge that was
not encoded.

---

## Next Steps

- [How-to: Set Up Secret Detection](../how-to/set-up-secret-detection.md) —
  promote the "no secrets in source" constraint from unverified to
  deterministic using gitleaks
- [Creating Your First Skill](your-first-skill) — encode domain knowledge
  that agents carry into every session
- [Reference: HARNESS.md Format](../reference/harness-md-format.md) — full
  specification of every field in HARNESS.md
- [Reference: Commands](../reference/commands.md) — full specification for
  `/harness-constrain`, `/harness-audit`, and `/harness-gc`
