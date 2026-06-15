---
name: auto-enforcer-action
description: Use when setting up automatic PR constraint enforcement via GitHub Actions — covers the advisory-vs-blocking split, workflow installation, configuration options, and reading the output
---

# Auto-Enforcer GitHub Action

## Overview

The harness enforces constraints across three loops:

- **Inner loop** (PreToolUse hooks) — advisory, runs while editing in
  Claude Code
- **Middle loop** (CI on PR) — runs automatically on every pull request
- **Outer loop** (scheduled audit) — investigative, runs on demand via
  `/harness-audit`

The standard `harness.yml` CI workflow handles the middle loop for
deterministic constraints only. Agent-based PR constraints — rules like
"All frontmatter has name and description" that require judgement —
are silently skipped at PR time unless someone remembers to run
`/harness-audit` manually.

The auto-enforcer closes this gap. It runs every PR-scoped constraint
in HARNESS.md automatically on each pull request:

- **Deterministic constraints** execute their tool command directly.
  Failures are blocking — they fail the CI job and prevent merge.
- **Agent constraints** send the constraint rule plus the PR diff to
  the Claude API. Findings are advisory — posted as a PR comment but
  never blocking. AI judgement should inform reviewers, not gate merges.

The workflow is data-driven: it reads constraint definitions from
HARNESS.md at runtime. Adding or modifying constraints in HARNESS.md
changes what the action checks with no workflow edits needed.

---

## Prerequisites

1. **HARNESS.md** exists at the project root with at least one
   PR-scoped constraint
2. **ANTHROPIC_API_KEY** stored as a GitHub Actions secret:
   Settings > Secrets and variables > Actions > New repository secret

---

## What Gets Checked

### Deterministic PR constraints

Each deterministic constraint with `scope: pr` has its tool command
executed against the checked-out code. The tool's exit code determines
pass or fail. Any stdout output is collected as findings.

Example: a constraint with `tool: gitleaks detect --source . --exit-code 1`
runs gitleaks directly in the CI runner.

### Agent PR constraints

Each agent constraint with `scope: pr` is evaluated by sending the
constraint's rule text and the PR diff (changed files) to the Claude
API. The model parses the diff against the rule and returns structured
findings.

Example: a constraint with `rule: All skill files have YAML frontmatter
with name and description` sends that rule plus the diff to Claude,
which reports any files that violate the rule.

---

## Installing the Workflow

1. Copy the template into your workflows directory:

   ```bash
   cp .claude/plugins/ai-literacy-superpowers/templates/ci-auto-enforcer.yml \
      .github/workflows/auto-enforcer.yml
   ```

2. Add the `ANTHROPIC_API_KEY` secret in your repository:
   Settings > Secrets and variables > Actions > New repository secret

3. Optionally configure include/exclude constraints or other options
   (see Configuration Options below)

4. Commit and push the workflow file

---

## Configuration Options

The workflow supports configuration through environment variables set
in the workflow file:

### `INCLUDE_CONSTRAINTS`

Comma-separated list of constraint names to run. When set, only these
constraints are checked. Default: all PR-scoped constraints.

```yaml
env:
  INCLUDE_CONSTRAINTS: "no-secrets,frontmatter-complete"
```

### `EXCLUDE_CONSTRAINTS`

Comma-separated list of constraint names to skip. Applied after
include filtering. Default: none.

```yaml
env:
  EXCLUDE_CONSTRAINTS: "slow-integration-check"
```

### `AGENT_MODEL`

The Claude model to use for agent constraint checks. Default:
`claude-opus-4-5`.

```yaml
env:
  AGENT_MODEL: "claude-sonnet-4-20250514"
```

### `COMMENT_MODE`

Controls when a PR comment is posted:

- `findings-only` (default) — post only when there is something to act
  on: any `FAIL`, `ADVISORY`, or `SKIP` result. An all-`PASS` run posts
  no comment.
- `always` — post a comment even when all constraints pass

```yaml
env:
  COMMENT_MODE: "always"
```

---

## Permissions

The workflow requires two permissions:

- **`contents: read`** — to check out the repository and read
  HARNESS.md and the PR diff
- **`pull-requests: write`** — to post the findings comment on the PR

No other permissions are needed. The workflow does not push code,
create branches, or access any other repository data.

---

## Reading the Output

### PR comment format

When agent findings exist (or `COMMENT_MODE` is `always`), the
auto-enforcer posts a comment on the PR with a summary table:

```markdown
## Auto-Enforcer Results

| Constraint | Type | Status | Findings |
|---|---|---|---|
| No secrets in source | deterministic | PASS | -- |
| All frontmatter complete | agent | ADVISORY | 2 files missing description |
| Consistent formatting | deterministic | FAIL | 3 files need formatting |
```

### Interpreting results

- **PASS** — the constraint check succeeded with no findings
- **FAIL** — a deterministic constraint failed; the CI job exits
  non-zero and blocks merge until fixed
- **ADVISORY** — an agent constraint found potential issues; review
  the findings but the job does not fail
- **SKIP** — the constraint was excluded by configuration, could not
  be parsed, or its agent API call did not complete after retries
  (transient `429`/`529` overloads are retried with backoff before a
  SKIP is recorded). A SKIP surfaces a PR comment even in
  `findings-only` mode so a silently-disabled gate stays visible.

### Distinguishing failures from advisories

The CI job exit code is determined only by deterministic constraints.
If all deterministic constraints pass, the job succeeds even if agent
constraints report findings. This means:

- A red CI check always indicates a deterministic failure
- Agent findings appear only in the PR comment, never in the CI status

---

## Interaction with Existing CI

The auto-enforcer supplements but does not replace the existing
`harness.yml` workflow. They run independently as separate CI jobs.

To avoid running the same deterministic constraint in both workflows
(which adds noise without value):

- Keep `harness.yml` for constraints that existed before adopting the
  auto-enforcer
- Use `EXCLUDE_CONSTRAINTS` in the auto-enforcer to skip constraints
  already covered by `harness.yml`
- Or migrate all PR constraints to the auto-enforcer and simplify
  `harness.yml`

---

## Limitations

- **Agent findings reflect the model's judgement on the diff, not a
  full repo scan.** The agent sees only changed files and their
  surrounding context, not the entire codebase. Some constraints may
  require full-repo context to evaluate accurately.

- **Large diffs may exceed context limits.** When the PR diff exceeds
  50 KB, the workflow falls back to sending only the list of changed
  files and a summary rather than the full patch text. Agent accuracy
  decreases in this mode.

- **The action does not run GC rules.** Garbage collection rules are
  periodic and investigative by design. They run on a schedule via
  `/harness-gc`, not on every PR.

- **Agent constraints are never blocking.** This is a deliberate
  design choice. AI judgement varies between runs and should not
  gate merges. If you need a constraint to be blocking, promote it
  to deterministic with a concrete tool command.

- **GitHub Actions only.** This iteration supports GitHub Actions.
  For other CI platforms, adapt the shell logic from the template
  to your platform's configuration format.
