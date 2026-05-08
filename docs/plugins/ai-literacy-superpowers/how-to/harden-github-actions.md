---
title: Harden GitHub Actions
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 15
redirect_from:
  - /how-to/harden-github-actions/
  - /how-to/harden-github-actions.html
---

# Harden GitHub Actions

This guide walks you through reviewing and hardening your GitHub Actions workflows against supply chain attacks — covering SHA pinning, permissions scoping, and automated update configuration.

**Never rely on your knowledge of whether an action version is safe. Run the checklist.**

---

## 1. List your workflow files

```bash
ls .github/workflows/
```

Work through every file in the directory. A finding in one workflow is often present in others.

---

## 2. Check every `uses:` reference for SHA pinning

A mutable tag (`@v4`) can be silently repointed to a different commit by anyone with push access to that repository. The `tj-actions/changed-files` incident (March 2025) demonstrated this at scale — a compromised action exfiltrated secrets from thousands of repositories.

Every `uses:` reference must be pinned to a full 40-character commit SHA.

**Find unpinned references:**

```bash
grep -r "uses:" .github/workflows/ | grep -v "@[0-9a-f]\{40\}"
```

Any output is a finding.

---

## 3. Resolve the SHA for each action

```bash
# Get the SHA for a tag — replace owner, repo, and tag as needed
gh api repos/actions/checkout/git/ref/refs/tags/v4 --jq '.object.sha'

# If the tag points to a tag object rather than a commit, dereference it:
gh api repos/actions/checkout/git/tags/<sha-from-above> --jq '.object.sha'
```

---

## 4. Pin every reference and add a comment

```yaml
# Before (mutable tag):
uses: actions/checkout@v4

# After (pinned SHA with tag as comment):
uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
```

Always leave the tag as a comment. A bare SHA is unreadable to humans.

Apply the same treatment to third-party actions — any namespace outside `actions/` and `github/` is high risk:

| Action namespace | Risk level |
| --- | --- |
| `actions/*` | Medium — GitHub-owned; employee accounts can be compromised |
| `github/*` | Medium — same as above |
| Any other owner | High — no privileged relationship; pin and verify provenance |

---

## 5. Add a `permissions:` block to every workflow

Without an explicit `permissions:` block, a workflow inherits the repository's default token permissions, which may include write access to contents, pull requests, or packages.

**Most CI workflows (read-only):**

```yaml
permissions:
  contents: read
```

**Workflows that post PR comments:**

```yaml
permissions:
  contents: read
  pull-requests: write
```

**Workflows that upload release artifacts:**

```yaml
permissions:
  contents: write
```

Apply the block at the job level when different jobs need different scopes. Apply at the workflow level when all jobs share the same scope.

---

## 6. Check for `pull_request_target` misuse

`pull_request_target` runs with write permissions and access to secrets. If used with `actions/checkout` of the PR head, it allows a fork to run arbitrary code with those permissions.

```bash
grep -r "pull_request_target" .github/workflows/
```

Any match warrants careful review. If the trigger is needed, ensure the checkout step checks out the base branch, not the PR head.

---

## 7. Check for script injection

User-controlled input flowing into `run:` shell commands is a script injection risk:

```bash
grep -r "\${{ github.event" .github/workflows/
```

Review every match. Values like `github.event.pull_request.title` or `github.event.issue.body` are attacker-controlled and must not be interpolated directly into shell commands. Use an environment variable intermediary instead:

```yaml
- name: Safe interpolation
  env:
    PR_TITLE: ${{ github.event.pull_request.title }}
  run: echo "$PR_TITLE"
```

---

## 8. Configure Dependabot to keep pinned SHAs current

A pinned SHA that never updates is worse than a mutable tag once a CVE lands in the pinned version. Add a `dependabot.yml` entry for GitHub Actions:

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
    groups:
      actions:
        patterns:
          - "*"
```

---

## 9. Produce a findings table

```markdown
## Supply Chain Assessment — .github/workflows/

| File | Finding | Severity | Fix |
| --- | --- | --- | --- |
| lint.yml | Third-party action not SHA-pinned | High | Pin to commit SHA |
| build.yml | No permissions block | Medium | Add permissions: contents: read |
| All files | No dependabot.yml for actions | Medium | Add .github/dependabot.yml |
```

Severity guide: **High** — third-party action not SHA-pinned; `pull_request_target` misuse; script injection. **Medium** — first-party action not SHA-pinned; no `permissions:` block; no Dependabot. **Low** — minor hygiene.

---

## Summary

After completing these steps you have:

- Every `uses:` reference pinned to a full commit SHA with a human-readable comment
- Third-party actions identified and risk-rated
- Minimal `permissions:` blocks on every workflow
- No `pull_request_target` misuse or unguarded script injection
- Dependabot configured to keep pinned SHAs current automatically
