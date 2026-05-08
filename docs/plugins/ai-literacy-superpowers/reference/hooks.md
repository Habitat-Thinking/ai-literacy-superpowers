---
title: Hooks
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 4
redirect_from:
  - /reference/hooks/
  - /reference/hooks.html
---

# Hooks

All hooks are registered in `hooks/hooks.json` and active in every
session. Hooks are advisory only — they warn but never block.

---

## PreToolUse Hooks

These hooks fire when Claude invokes the `Write` or `Edit` tool.

### Constraint gate (prompt)

- **Event**: PreToolUse
- **Matcher**: `Write|Edit`
- **Type**: prompt
- **Timeout**: 30s

Reads the Constraints section of `HARNESS.md`, identifies any
constraints scoped to `commit`, and evaluates whether the file being
written or edited would violate them. Returns a warning describing
each violation. Uses LLM judgement to interpret constraints.

### Markdownlint check (command)

- **Event**: PreToolUse
- **Matcher**: `Write|Edit`
- **Type**: command
- **Script**: `hooks/scripts/markdownlint-check.sh`
- **Timeout**: 15s

Extracts the file path from the tool input JSON. If the file is a
`.md` file and `markdownlint-cli2` is available via `npx`, runs the
linter and returns any violations as a warning. Exits silently for
non-markdown files, files that do not yet exist on disk (new files
via Write), or when the tool is not installed.

Complements the prompt-based constraint gate with deterministic
checking — the prompt hook catches constraint intent, while this
hook catches formatting that machines are better at detecting.

---

## Stop Hooks

These hooks fire when a Claude session ends. All produce JSON
`systemMessage` output so that Claude surfaces the message without
interrupting session flow.

### Drift check

- **Script**: `hooks/scripts/drift-check.sh`
- **Timeout**: 10s

Examines the most recent commit for changes to CI workflows, linter
configs, hook configs, or dependency manifests. If any of these
changed, `HARNESS.md` may need updating. Outputs a nudge to run
`/harness-audit`.

**Signals detected**: `.github/workflows/`, `.gitlab-ci.yml`,
`Jenkinsfile`, `.eslintrc`, `.prettierrc`, `.golangci`,
`.editorconfig`, `.pylintrc`, `.husky/`, `.pre-commit-config`,
`hooks.json`, `go.mod`, `package.json`, `pom.xml`,
`requirements.txt`, `*.csproj`.

### Snapshot staleness check

- **Script**: `hooks/scripts/snapshot-staleness-check.sh`
- **Timeout**: 10s

Finds the most recent health snapshot in `observability/snapshots/`
by filename date. If the snapshot is older than 30 days, suggests
running `/harness-health`. Works with both GNU and macOS date
implementations.

### Reflection prompt

- **Script**: `hooks/scripts/reflection-prompt.sh`
- **Timeout**: 10s

Counts commits made in the last four hours (approximate session
length). If commits were made, nudges you to run `/reflect` to
capture learnings before they evaporate. Only fires when
`REFLECTION_LOG.md` exists.

### Framework change prompt

- **Script**: `hooks/scripts/framework-change-prompt.sh`
- **Timeout**: 10s

Checks whether `framework/framework.md` was modified in recent
commits. If so, nudges three actions: run `/reflect`, run
`/sync-repos` to propagate changes to downstream repos, and check
whether downstream READMEs need updating.

### Secrets check

- **Script**: `hooks/scripts/secrets-check.sh`
- **Timeout**: 15s

If gitleaks is installed and `HARNESS.md` has a deterministic "No
secrets in source" constraint, scans the working directory for
committed secrets. Exits silently if gitleaks is not installed or
the constraint is not active.

### Rotating GC check

- **Script**: `hooks/scripts/gc-rotate.sh`
- **Timeout**: 10s

Picks one deterministic GC rule per session, rotating by
day-of-year modulo 4:

| Day mod | Rule checked |
| --- | --- |
| 0 | Secret scanner operational |
| 1 | Snapshot staleness |
| 2 | Shell scripts syntax |
| 3 | Shell scripts strict mode |

This ensures entropy is caught between weekly scheduled CI runs.
Agent-scoped rules (documentation freshness, command-prompt sync,
plugin manifest currency) are not included — they require LLM
judgement and are triggered via `/harness-gc` or
`/harness-health --deep`.

### Curation nudge

- **Script**: `hooks/scripts/curation-nudge.sh`
- **Timeout**: 10s

Compares the number of reflection entries in `REFLECTION_LOG.md`
against the curated entries in `AGENTS.md`. If reflections
significantly outnumber promoted entries (by more than 2), nudges
you to review and curate learnings. This closes the gap in the
compound learning lifecycle where reflections are captured but never
promoted to team memory.

### Governance drift check (command)

- **Event**: Stop
- **Matcher**: `*`
- **Type**: command
- **Script**: `hooks/scripts/governance-drift-check.sh`
- **Timeout**: 10s

Checks whether governance-related files were modified during the
session and whether the last governance audit is stale (> 90 days).
Detects three signals: HARNESS.md changes involving governance
language, compliance or policy document modifications, and audit
staleness. Also flags when governance constraints exist in
HARNESS.md but no audit has ever been run. Nudges
`/governance-audit` or `/governance-health`.

---

## SessionStart Hooks

These hooks fire once when a new Claude Code session begins.

### Template currency check

- **Script**: `hooks/scripts/template-currency-check.sh`
- **Timeout**: 10s

Compares the `<!-- template-version: X.Y.Z -->` marker in
`HARNESS.md` against the installed plugin version from
`plugin.json`. If the template version is behind the plugin
version, nudges you to run `/harness-upgrade` to adopt new
template content. Exits silently if `HARNESS.md` does not exist
or the marker is absent.

---

## Configuration

Hooks are configured in `hooks/hooks.json`. The file contains:

- A `description` field summarising the hook set
- A `PreToolUse` array with matcher patterns and hook definitions
- A `Stop` array with wildcard matcher and hook definitions

Each hook entry specifies:

- **type**: `"prompt"` (LLM-evaluated) or `"command"` (shell script)
- **command** or **prompt**: the script path or prompt text
- **timeout**: maximum execution time in seconds

Hook scripts use `${CLAUDE_PLUGIN_ROOT}` for path resolution and
`${CLAUDE_PROJECT_DIR}` for the project working directory.

---

## Design Principles

**Advisory, not blocking.** All hooks warn but never prevent the
action. This is deliberate — blocking hooks during creative work
interrupts flow and trains developers to work around the system.
The middle loop (CI gates) provides blocking enforcement.

**JSON systemMessage output.** Stop hooks output
`{"systemMessage": "..."}` so that Claude surfaces the nudge in
the conversation. Plain text output would be ignored.

**Silent on non-applicable.** Every hook checks prerequisites
(file existence, tool availability) and exits silently with
`exit 0` when the check does not apply. This prevents noise in
projects that do not use all features.

**Strict mode.** All hook scripts use `set -euo pipefail` within
the first 15 lines, as required by the harness constraint.
