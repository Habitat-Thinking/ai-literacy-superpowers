---
title: Set Up Auto-Enforcer
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 5
redirect_from:
  - /how-to/set-up-auto-enforcer/
  - /how-to/set-up-auto-enforcer.html
---

# Set Up Auto-Enforcer

Wire the auto-enforcer GitHub Action to check every PR against the constraints in
HARNESS.md — blocking on deterministic failures and posting advisory comments for
agent-based constraints.

---

## Prerequisites

- `HARNESS.md` exists at the project root with at least one PR-scoped constraint
- Repository is hosted on GitHub

---

## 1. Copy the workflow template

```bash
cp .claude/plugins/ai-literacy-superpowers/templates/ci-auto-enforcer.yml \
   .github/workflows/auto-enforcer.yml
```

---

## 2. Add the API key secret

The auto-enforcer uses the Claude API to evaluate agent-based constraints. Add the key
in your repository settings:

1. Go to **Settings > Secrets and variables > Actions**
2. Click **New repository secret**
3. Name: `ANTHROPIC_API_KEY`
4. Value: your Anthropic API key

Deterministic constraints run without the API key. If you have no agent constraints,
you can skip this step.

---

## 3. Commit and push the workflow

```bash
git add .github/workflows/auto-enforcer.yml
git commit -m "Add auto-enforcer workflow for PR constraint checking"
git push
```

On the next pull request, the workflow runs automatically.

---

## 4. Read the PR comment

When agent findings exist, the auto-enforcer posts a comment on the PR:

```markdown
## Auto-Enforcer Results

| Constraint | Type | Status | Findings |
|---|---|---|---|
| No secrets in source | deterministic | PASS | -- |
| All frontmatter complete | agent | ADVISORY | 2 files missing description |
| Consistent formatting | deterministic | FAIL | 3 files need formatting |
```

| Status | Meaning |
| ------ | ------- |
| `PASS` | Check succeeded with no findings |
| `FAIL` | Deterministic constraint failed — blocks merge |
| `ADVISORY` | Agent constraint found issues — informational only |
| `SKIP` | Constraint excluded by configuration |

A red CI check always means a deterministic failure. Agent findings never block merge.

---

## 5. Configure optional filtering

Edit the workflow file to include or exclude specific constraints:

```yaml
env:
  # Run only these constraints (comma-separated):
  INCLUDE_CONSTRAINTS: "no-secrets,frontmatter-complete"

  # Skip these constraints (comma-separated):
  EXCLUDE_CONSTRAINTS: "slow-integration-check"

  # Claude model for agent constraints:
  AGENT_MODEL: "claude-sonnet-4-20250514"

  # Post comment even when all constraints pass:
  COMMENT_MODE: "always"
```

---

## 6. Avoid duplicate checks

If your existing `harness.yml` already runs some deterministic constraints, avoid
running them twice:

```yaml
env:
  EXCLUDE_CONSTRAINTS: "no-secrets,test-suite"
```

Or migrate all PR constraints to the auto-enforcer and simplify `harness.yml` to
remove the duplicates. Both workflows run independently as separate CI jobs.

---

## Known limitations

- Agent constraints see only changed files and surrounding context, not the full
  codebase. Some rules may need full-repo context to evaluate accurately.
- Diffs larger than 50 KB fall back to a summary — agent accuracy decreases in
  this mode.
- GitHub Actions only. For other CI platforms, adapt the shell logic from the
  template to your platform's format.
