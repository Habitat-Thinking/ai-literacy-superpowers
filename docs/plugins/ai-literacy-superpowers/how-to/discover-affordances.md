---
title: Discover Affordances
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 39
redirect_from:
  - /how-to/discover-affordances/
  - /how-to/discover-affordances.html
---

# Discover Affordances

Run the affordance discovery scanner against your project's existing
config to produce a draft inventory of every tool the agent can
invoke.

## When to use this

- **First time setting up the affordances section.** Existing harness
  adopters can backfill the `## Affordances` section in `HARNESS.md`
  by running `discover` once and then promoting the entries.
- **After changing project permissions.** Add a new permission entry,
  hook, or MCP server? Re-run `discover` to see the diff against the
  previous draft and find what is new.
- **As part of a governance review.** A reviewer can run `discover`
  to confirm that the declared affordances in `HARNESS.md` still
  match what the project's config actually grants.

## Prerequisites

- **`jq`** must be installed. The scanner uses it to parse JSON
  config files robustly.
  - macOS: `brew install jq`
  - Debian/Ubuntu: `apt install jq`
  - Fedora/RHEL: `dnf install jq`
- The plugin must be installed and at version `0.28.0` or later.
- At least one of the following must exist in your project root:
  `.claude/settings.json`, `.claude/settings.local.json`,
  `.mcp.json`. If none exist there is nothing to discover.

## Run it

From a Claude Code session:

```text
/harness-affordance discover
```

Or from a terminal directly (assumes the plugin is installed via
the `ai-literacy-superpowers` marketplace):

```bash
bash ~/.claude/plugins/cache/ai-literacy-superpowers/ai-literacy-superpowers/<version>/scripts/harness-affordance-discover.sh
```

The script reads from the current working directory by default. Pass
an explicit project directory as the first argument if you want to
scan a different project.

## Read the output

The scanner writes to `<project>/.claude/affordance-discovery-<YYYY-MM-DD>.md`.
The file is gitignored — drafts never accidentally land in version
control.

The output starts with a header summarising what was scanned:

```text
# Affordance Discovery — 2026-04-27

Source files scanned:
- `.claude/settings.local.json` (72 permission entries)
- `.mcp.json` (3 MCP servers)

Counts by mode: cli=72, local-mcp=2, central-mcp=1, hook=2
```

Followed by one entry per discovered affordance. The scanner fills
in the **machine-derivable fields** (`Mode`, `Trigger` for hooks,
`Permission`); the **human-owned governance fields** (`Identity`,
`Audit trail`, optional `Notes`) start as `TODO`:

```markdown
### gh-cli

- **Mode**: cli
- **Identity**: TODO
- **Audit trail**: TODO
- **Permission**: `Bash(gh *)` (declared in .claude/settings.local.json)
- **Last reviewed**: TODO (run `/harness-affordance review` once
  Identity and Audit trail are filled in)
```

If the scanner finds an MCP server declared in `.mcp.json` but no
matching `mcp__<server>__*` permission entry, it emits a draft
affordance entry for that server with a `WARN:` note in the `Notes`
field explaining the missing permission. The header summary also
reports the count of orphan MCP servers. This is the
*affordance-without-permission* case from the harness-affordances
design — the entry surfaces in the inventory itself rather than as a
separate warning paragraph, so it is impossible to miss when scanning
the entries.

## Promote entries to HARNESS.md

For each draft entry you want to keep:

1. **Fill in `Identity`** — whose credentials does this tool run
   under? Use one of: `user-sso`, `service-account`, `current-user`,
   `runtime-resolved`, `none`. See the
   [affordances design spec](../../superpowers/specs/2026-04-26-harness-affordances-design.md)
   for the full definitions.
2. **Fill in `Audit trail`** — where would you find a record of what
   the agent did? `none` is encouraged when there genuinely is no
   audit trail; the visibility is the point.
3. **Set `Last reviewed`** to today's date.
4. **Copy the entry** into `HARNESS.md` under `## Affordances`.

In a future release `/harness-affordance add <name>` will guide
this annotation interactively. For now it is hand-edited.

## Disambiguation

If two permission patterns derive to the same name (e.g. eight
different `Bash(awk ...)` patterns all derive to `awk-cli`), the
scanner appends a numeric suffix: `awk-cli`, `awk-cli-2`,
`awk-cli-3`, etc. This is deterministic and **independent of the
order patterns appear in your `permissions.allow` array** — the
scanner sorts patterns lex-ascending before assigning suffixes, so
re-ordering the array (e.g. alphabetising it) does not silently
re-name entries you have already promoted to `HARNESS.md`.

## Idempotency

Running the scanner twice on identical input produces output that
differs only in the date in the heading. Entry order is alphabetical
by derived name (basename, not full path); no timestamps appear
inside entries. Sort and listing are pinned to the `C` locale so
output is byte-identical across machines with different default
locales. This makes it safe to `diff` successive runs to find what
changed.

## What the scanner does NOT do

- It never writes to `HARNESS.md`. Promotion is always a human
  action.
- It does not read `~/.claude/settings.json` (user-level settings
  are out of scope for project-level governance).
- It does not infer `Identity`, `Audit trail`, or `Last reviewed` —
  these are governance judgments that humans must make.
- It does not ship `add` or `review` subcommands — those land in
  later sequencing steps of the affordances design.

## Related

- [Harness Affordances — Design Spec](../../superpowers/specs/2026-04-26-harness-affordances-design.md)
- [`/harness-affordance discover` — Implementation Spec](../../superpowers/specs/2026-04-27-harness-affordance-discover.md)
