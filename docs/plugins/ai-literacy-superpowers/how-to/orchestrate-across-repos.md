---
title: Orchestrate Changes Across Repos
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 22
redirect_from:
  - /how-to/orchestrate-across-repos/
  - /how-to/orchestrate-across-repos.html
---

# Orchestrate Changes Across Repos

Coordinate changes — skills, templates, hooks, and harness policies —
across multiple repositories using the pattern appropriate to your scale.

---

## 1. Choose the right pattern

| Situation | Pattern |
| --- | --- |
| Syncing skills or hooks from an upstream repo to 2–5 downstream repos | Git-mediated (Level 4) |
| Propagating harness policy changes to downstream consumers | Git-mediated (Level 4) |
| Managing shared standards across 10+ repos | Specification-mediated (Level 5) |
| Aggregating health snapshots across an organisation | Specification-mediated (Level 5) |

Start with git-mediated. Graduate to specification-mediated when the
portfolio grows beyond what a single agent or team can manage manually.

---

## 2. Git-mediated coordination (Level 4)

This pattern uses the standard git workflow: identify what changed
upstream, then apply those changes to each downstream repo via a branch
and PR.

### Declare what the upstream repo exports

Document the exported artefacts in the upstream README or a manifest
section. At minimum, state:

- Which directories contain reusable artefacts
- What the downstream repos are
- What triggers a sync (for example, "after any PR that modifies `skills/`")

### What to sync — and what not to

| Sync | Do not sync |
| --- | --- |
| Skills (tool-agnostic knowledge) | HARNESS.md (project-specific constraints) |
| Agent definitions | AGENTS.md (project-specific learnings) |
| Hook scripts and `hooks.json` | REFLECTION_LOG.md (project-specific reflections) |
| CI workflow templates | Project source code |
| Templates (starting points) | Specs and plans |

### Apply changes to each downstream repo

For each downstream repo:

```bash
cd /path/to/downstream-repo
git checkout main && git pull
git checkout -b sync/upstream-skills-YYYY-MM-DD

# Copy the changed artefacts from upstream
cp -r /path/to/upstream/skills/ ./skills/
# or use rsync for selective updates
rsync -av --include='*.md' --exclude='*' /path/to/upstream/skills/ ./skills/

# Run lint and verify
npx markdownlint-cli2 "skills/**/*.md"

git add skills/
git commit -m "sync: update skills from upstream (YYYY-MM-DD)"
git push -u origin sync/upstream-skills-YYYY-MM-DD
gh pr create --title "Sync skills from upstream" --body "..."
```

Watch CI checks and merge when green.

---

## 3. Specification-mediated orchestration (Level 5)

At organisational scale, each repo declares its dependencies through a
manifest file, and a platform orchestrator resolves and propagates changes
automatically.

### Create a repo manifest

Add `.repo-manifest.yml` to the upstream repo:

```yaml
name: my-platform-repo
version: 0.1.0

exports:
  skills:
    - harness-engineering
    - verification-slots
  hooks:
    - constraint-gate
    - drift-check

imports: []
```

Downstream repos declare what they consume:

```yaml
name: my-service-repo
version: 0.1.0

imports:
  - source: my-platform-repo
    version: ">=0.1.0"
    artefacts:
      - skills/*
      - hooks/*
```

### Let the platform orchestrator propagate changes

When the platform repo changes a harness policy, the orchestrator:

1. Reads all downstream manifests
2. Identifies which repos consume the changed artefact
3. Opens sync PRs in each affected repo
4. Reports sync status to the portfolio dashboard

---

## 4. Avoid common anti-patterns

| Anti-pattern | Problem | Fix |
| --- | --- | --- |
| Sync without contracts | Nobody knows what should flow where | Declare exports in README or manifest |
| Bidirectional sync | Changes flow both ways, causing conflicts | One direction only — upstream is authoritative |
| Sync everything | Downstream repos lose their identity | Only sync declared exports |
| Manual ad-hoc copies | Drift accumulates silently | Use a documented sync command or workflow |
| Sync without CI | Broken changes propagate downstream | Every sync goes through a PR with CI checks |

---

## 5. Monitor portfolio health

For specification-mediated orchestration, aggregate health snapshots give
a portfolio-wide view:

```text
Portfolio Health — 2026-04-08

Repos: 12
At L3+: 9 (75%)
Below threshold: 3 (api-gateway, legacy-auth, billing-service)
Enforcement average: 84%
Mutation score average: 76%
Repos with stale snapshots: 1 (legacy-auth, 45 days)
```

Run `/portfolio-assess` to generate the current portfolio view.

---

## Summary

After completing these steps you have:

- A documented contract between upstream and downstream repos
- A repeatable sync workflow that goes through PRs and CI
- Clear boundaries around what flows downstream and what stays local
- A monitoring approach scaled to the size of your portfolio
