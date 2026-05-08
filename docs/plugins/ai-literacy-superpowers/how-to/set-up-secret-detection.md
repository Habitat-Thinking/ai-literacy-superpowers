---
title: Set Up Secret Detection
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 1
redirect_from:
  - /how-to/set-up-secret-detection/
  - /how-to/set-up-secret-detection.html
---

# Set Up Secret Detection

This guide walks you through adding gitleaks-based secret detection to your project and wiring it into the harness so it runs automatically at commit time and in CI.

---

## 1. Install gitleaks

**macOS (Homebrew):**

```bash
brew install gitleaks
```

**Go (any platform):**

```bash
go install github.com/gitleaks/gitleaks/v8@latest
```

**Verify the install:**

```bash
gitleaks version
```

You should see a version string such as `gitleaks v8.x.x`.

---

## 2. Run an initial scan

Before writing any configuration, scan the repository as it currently stands:

```bash
gitleaks detect --source . --no-banner
```

This writes no output on a clean result and exits `0`. If it finds potential secrets it prints a findings table and exits non-zero.

Work through every finding before continuing. Common outcomes:

- **Real secret committed** — rotate the credential, then scrub the commit history with `git filter-repo` or BFG.
- **False positive** — note the rule ID and file path; you will allowlist it in the next step.
- **Test fixture or example value** — move it to a dedicated allowlist rather than deleting it.

Do not proceed past this step with unresolved real secrets.

---

## 3. Create a `.gitleaks.toml` for allowlists

If the initial scan produced false positives, create a `.gitleaks.toml` at the repository root. A minimal file looks like this:

```toml
title = "gitleaks config"

[allowlist]
  description = "project-specific allowlist"
  regexTarget = "match"
  regexes = [
    # Example: ignore a known test fixture value
    # "AKIAIOSFODNN7EXAMPLE",
  ]

  paths = [
    # Example: ignore generated credential fixtures in test data
    # "tests/fixtures/credentials.json",
  ]

  commits = [
    # Example: ignore a specific historical commit that has been remediated
    # "abc1234def5678",
  ]
```

Remove the comment characters for any entries you need. Keep the file minimal — an overly broad allowlist defeats the purpose of secret detection.

To target a specific rule rather than writing a regex against the secret value, use the `stopwords` or rule-level `allowlist` block instead. See the [gitleaks documentation](https://github.com/gitleaks/gitleaks) for the full schema.

Re-run the scan after adding each allowlist entry to confirm it resolves the false positive:

```bash
gitleaks detect --source . --no-banner --config .gitleaks.toml
```

---

## 4. Promote the HARNESS.md constraint to deterministic

Open `HARNESS.md` in your project root. Find the constraint that covers secret detection — it may already exist as a probabilistic item in advisory state. If it does not exist, add it:

```markdown
| No secrets in repository | DETERMINISTIC | gitleaks pre-commit hook | gitleaks detect --source . |
```

If a constraint for secret detection exists but is marked `ADVISORY` or `PROBABILISTIC`, promote it:

```markdown
<!-- Before -->
| No secrets in repository | ADVISORY | manual review | none |

<!-- After -->
| No secrets in repository | DETERMINISTIC | gitleaks pre-commit hook | gitleaks detect --source . |
```

The enforcement column should reference the pre-commit hook you will add in a moment. The verification column should be the exact command a developer can run manually to confirm the constraint is satisfied.

If your `HARNESS.md` does not yet have a secret-detection row, run `/harness-constrain` to add one through the guided flow, then edit the enforcement details by hand.

---

## 5. Add the pre-commit hook

Create or update `.git/hooks/pre-commit` to run gitleaks before each commit:

```bash
#!/usr/bin/env bash
set -e

echo "Running gitleaks secret detection..."
gitleaks protect --staged --no-banner --config .gitleaks.toml 2>/dev/null || \
  gitleaks protect --staged --no-banner 2>/dev/null

if [ $? -ne 0 ]; then
  echo "gitleaks found potential secrets. Commit blocked."
  echo "Run 'gitleaks detect --source . --no-banner' to review findings."
  exit 1
fi
```

The `protect --staged` subcommand scans only the files in the staging area, which is faster and more appropriate for a pre-commit hook than a full repository scan.

Make the hook executable:

```bash
chmod +x .git/hooks/pre-commit
```

If your project uses a hook manager such as `pre-commit` (the Python tool), add this stanza to `.pre-commit-config.yaml` instead:

```yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.21.2  # pin to the latest stable release
    hooks:
      - id: gitleaks
```

Then run:

```bash
pre-commit install
```

---

## 6. Verify it works with `/harness-status`

Run the harness status command:

```bash
/harness-status
```

The output should show the secret-detection constraint in the `DETERMINISTIC` tier with its enforcement hook listed as active. If it still shows as `ADVISORY`, the constraint row in `HARNESS.md` needs updating (see step 4).

You can also trigger a manual enforcement check by staging a file that contains a well-known test pattern:

```bash
echo "AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" > /tmp/test-secret.txt
git add /tmp/test-secret.txt
git commit -m "test" 2>&1
git reset HEAD /tmp/test-secret.txt
rm /tmp/test-secret.txt
```

The commit should be blocked by the pre-commit hook. The `git reset` and `rm` lines clean up afterward regardless of outcome.

---

## 7. Add to CI

Add a gitleaks step to your GitHub Actions workflow. Insert it early in the job, before any build or test steps:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # gitleaks needs full history for the git log scan

      - name: Run gitleaks secret detection
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          # Optional: point at your allowlist
          GITLEAKS_CONFIG: .gitleaks.toml
```

The `fetch-depth: 0` is important. Without it, the shallow clone that Actions uses by default means gitleaks cannot walk the full commit history.

If you prefer running the binary directly rather than using the action:

```yaml
      - name: Install gitleaks
        run: |
          curl -sSfL https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_$(uname -s | tr '[:upper:]' '[:lower:]')_x86_64.tar.gz \
            | tar -xz -C /usr/local/bin gitleaks

      - name: Run gitleaks
        run: gitleaks detect --source . --no-banner --config .gitleaks.toml
```

Both approaches produce a CI failure on findings, which satisfies the DETERMINISTIC enforcement requirement in your harness.

---

## Summary

After completing these steps you have:

- A clean repository baseline with no known exposed secrets
- An allowlist for any legitimate false positives
- A HARNESS.md constraint promoted to DETERMINISTIC
- A pre-commit hook that blocks secrets from being committed
- A CI step that catches anything that gets past the local hook
- Confirmation via `/harness-status` that the constraint is enforced

The constraint is now deterministic: it is checked mechanically at every commit and every pull request, not by convention or code review habit.
