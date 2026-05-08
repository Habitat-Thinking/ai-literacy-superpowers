# ai-literacy-superpowers — Conventions

## Always Work on a Branch

Never commit directly to `main`. Create a branch for every change:

```bash
git checkout -b <short-descriptive-name>
```

## PR Workflow

1. Create a GitHub issue describing the task
2. Create a branch
3. Make changes, lint, commit
4. Push and create a PR
5. Wait for CI checks to pass
6. Merge only when green

## Commit Messages

Write concise commit messages describing what changed and why.
No postamble, trailer, or attribution lines.

## CHANGELOG

Before every PR, update `CHANGELOG.md`:

- **Every top-level `## ...` heading MUST begin with a semver version
  followed by a dash and date — `## X.Y.Z — YYYY-MM-DD`.** CI
  (`Check version consistency`) reads the first whitespace-delimited
  token after `##` and matches it against `plugin.json`. A date-only
  heading like `## 2026-04-18` silently parses as `2026` and fails the
  check with a cryptic version-mismatch error.
- **For docs-only or other changes that do not bump the plugin
  version**, append entries under the most recent version's heading.
  Do not create a new top-level heading without a version.
- **For plugin changes that warrant a version bump** (see "Semantic
  Versioning" below), update the top heading to the new version and
  today's date, then add your entries underneath.
- Group entries under a short theme heading (`### ...`).
- One bullet per change: what changed and why it matters.

## Semantic Versioning

The plugin follows [semver](https://semver.org/) while pre-1.0:

- **0.MINOR.0** — new skills, agents, commands, or behavioural changes
- **0.x.PATCH** — bug fixes, doc-only changes, count corrections

Version bumps are only required when files inside `ai-literacy-superpowers/`
change. Changes outside the plugin directory (articles, docs, observability,
root config) do not require a version bump.

When a PR touches `ai-literacy-superpowers/` files, check whether the
change warrants a bump:

1. Read the current version from `ai-literacy-superpowers/.claude-plugin/plugin.json`
2. If the change adds or removes a skill, agent, or command, or changes
   plugin behaviour, bump the minor version (e.g. 0.4.0 → 0.5.0)
3. If the change is a fix or doc update to plugin files only, bump the
   patch version (e.g. 0.4.0 → 0.4.1)
4. If the change is trivial (typo, whitespace, formatting-only fixes
   like adding code fence languages), no bump needed — add the
   `no-bump` label to the PR to skip the CI check
5. When bumping, update all three locations:
   - `ai-literacy-superpowers/.claude-plugin/plugin.json` (`"version"` field)
   - `README.md` (Plugin version badge)
   - `CHANGELOG.md` (version header on the current date section)

## Marketplace Versioning

The marketplace listing (`.claude-plugin/marketplace.json`) is versioned
independently from the plugin. It has two version fields:

- `version` — the listing version (the contract with the platform)
- `plugin_version` — pointer to the currently approved plugin release

**When to update `plugin_version`:**

After every plugin version bump, update `plugin_version` in
`.claude-plugin/marketplace.json` to match the new `plugin.json`
version. This is the common case — plugin code changes, listing
contract stays the same.

**When to bump `version` (listing version):**

Bump when the listing contract itself changes:

- Description, keywords, or owner metadata change
- Permissions or consent scope change
- A plugin entry is added or removed from the `plugins` array
- The `source` path changes

The listing version follows the same semver rules as the plugin while
pre-1.0. A listing-only change does not require a plugin version bump.

## Spec-First Exemptions

Feature and behaviour-change PRs require a spec committed as the first
commit on the branch under
`docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`. The
`Spec-First Check` CI workflow at `.github/workflows/spec-first-check.yml`
enforces this. PRs that do not need a spec are exempt via labels or
branch prefixes — pick the one that matches the kind of change you are
making:

| Exemption | Use for | Branch prefix alternative |
| --- | --- | --- |
| `bug` label | An identified bug that does not need a fresh design | _(none — use the `fix` form)_ |
| `fix` label or `fix/` branch prefix | A targeted bug fix or correction where no design work is needed | `fix/<short-name>` |
| `chore` label or `chore/` branch prefix | Maintenance, housekeeping, docs additions outside the plugin directory, formatting and metadata fixes | `chore/<short-name>` |
| `maintenance` label | Refactors, dependency bumps, infrastructure tweaks that do not change behaviour | _(none — use the `chore` form)_ |
| `cross-repo` label or `cross-repo/` branch prefix | The spec lives in another repository (typically `ai-literacy-for-software-engineers`) | `cross-repo/<short-name>` |

Apply the label at PR creation time, per the _Label PRs at creation
time_ constraint in `HARNESS.md`. Adding the label at creation avoids
the friction of having to re-trigger the check after the fact and
keeps the PR's check history clean.

For cross-repo work, two further options apply on top of the
`cross-repo` exemption:

1. **Copy the spec** into `docs/superpowers/specs/` as the first commit
   on the branch. This satisfies the spec-first gate and keeps a local
   record of what drove the change. Preferred for large feature work.

2. **Use the `cross-repo` exemption alone** — name the branch
   `cross-repo/...` or add the `cross-repo` label to the PR. Use this
   for sync-driven changes where the spec already exists upstream and
   copying it would be redundant.

In the PR description for cross-repo work, always link to the upstream
spec regardless of which option you choose.

## Output Validation Checkpoints

Every command that produces structured output parsed by downstream
consumers must include a validation checkpoint step. The pattern:

1. Generate the output (agent dispatch or command logic)
2. Read the output back
3. Check structure against the format spec reference
4. Fix deviations in place (do not re-dispatch the agent)

Commands with checkpoints: `/harness-health`, `/assess`, `/reflect`,
`/cost-capture`, `/harness-constrain`, `/harness-init`,
`/superpowers-init`, `/governance-audit`, `/harness-onboarding`.

When adding a new command that writes structured markdown, add a
validation step following this pattern. Reference the format spec
rather than inlining field definitions.

## Docs Site Review

The `docs/` directory is the project's documentation site, organised
**per plugin** under `docs/plugins/<plugin-name>/`. When presenting a
plan or opening a PR, always check whether any docs pages need to be
created or updated.

For each plugin, content is organised into Diataxis quadrant folders:

- `tutorials/` — nav label "Getting Started" — end-to-end walkthroughs
- `how-to/` — nav label "How-to Guides" — task-oriented (one guide per
  command or workflow)
- `reference/` — nav label "Reference" — API/schema reference material
- `explanation/` — nav label "Concepts" — conceptual background

Pages live at `docs/plugins/<plugin-name>/<quadrant>/<slug>.md`. The
plugin's root `index.md` is a landing page that links to each quadrant;
each quadrant has its own `index.md` so MkDocs Material renders the
section as a navigable group. The site uses the `mkdocs-awesome-pages`
plugin to derive nav from the filesystem — folder structure is the
source of truth, no manual `nav:` listing required. The `_template.md`
file stays at the plugin root with header guidance for each quadrant.
A quadrant folder is created only when the plugin has at least one
page in that quadrant — empty quadrants are not scaffolded.

For the `ai-literacy-superpowers` plugin, pages live at
`docs/plugins/ai-literacy-superpowers/<quadrant>/<slug>.md`. For sister
plugins, under `docs/plugins/<plugin-name>/<quadrant>/<slug>.md`.

**When a feature adds a new command, skill, or agent**: check for an existing
how-to guide and create one if missing.

**When a feature changes behaviour**: check whether explanation pages reference
the old behaviour and update them.

**When a feature changes a format or schema**: check whether reference pages
are current.

Include docs changes in the same PR as the implementation, not as a follow-up.

## Quarterly Operations

Aligned cadence (every 90 days, anchored to `/governance-audit`):

1. `/governance-audit` — full governance review
2. `/cost-capture` — capture spend snapshot from provider dashboards
3. `/assess` — AI literacy re-assessment

Run as a single sitting; one quarterly working block, not three scattered
tasks.

## Monthly Operations

Light-touch health check (every 30 days, between quarterly anchor weeks):

1. `/governance-health` — governance constraint health snapshot
2. Reflection review — scan `REFLECTION_LOG.md` for new entries worth
   promoting to `AGENTS.md`
3. `/harness-sync` — bring every push-direction surface into alignment
   with HARNESS.md (convention files, snapshot, Status section).
   Surfaces ONBOARDING.md staleness, template drift, and recurring
   reflection patterns as `[manual]` items for follow-up; sync prints
   the suggested command but does not invoke them.

## Sync from Source

This plugin's reusable components originate from the
`ai-literacy-for-software-engineers` repo. When syncing changes,
use the `/sync-repos` command in that repo to identify what
needs updating, then apply changes via the PR workflow above.

## Marketplace Cache Auto-Sync

Claude Code keeps a git clone of this repo at
`~/.claude/plugins/marketplaces/ai-literacy-superpowers/`. When a PR
that changes `.claude-plugin/marketplace.json` is merged, the clone is
stale until someone pulls it.

Two scripts handle cache freshness:

- `ai-literacy-superpowers/scripts/sync-to-global-cache.sh` — rsyncs
  plugin content into the versioned plugin cache (runs on every `Stop`)
- `ai-literacy-superpowers/scripts/sync-marketplace-cache.sh` — fast-
  forwards the marketplace clone whenever `marketplace.json` on
  `origin/main` differs from the cached copy (runs on `PostToolUse`
  matching `Bash(gh pr merge*)`; catches listing version,
  `plugin_version`, and per-plugin version bumps alike)

The hooks that invoke these scripts live in `.claude/settings.local.json`
(gitignored, per-machine). Collaborators who want the same behaviour
should copy those entries into their own local settings.
