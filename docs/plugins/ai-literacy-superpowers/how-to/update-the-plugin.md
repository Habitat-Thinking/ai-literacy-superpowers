---
title: Update the Plugin
---
# Update the Plugin

Keep the plugin current when new versions are released, and adopt new
template content into your HARNESS.md after each update.

---

## How you find out an update is available

You don't need to check manually. Three signals surface new versions:

**SessionStart hook.** When you start a Claude Code session in a
project that has a HARNESS.md, the hook compares the `template-version`
marker in your file against the installed plugin version. If they differ
it emits:

```text
Plugin template has been updated (your harness: vX.Y.Z, plugin: vA.B.C).
Run /harness-upgrade to see what's new.
```

This fires once per plugin upgrade and goes silent after you run
`/harness-upgrade`.

**Weekly GC rule.** The `Template currency` GC rule checks the same
marker on its weekly schedule and reports the mismatch in the
`/harness-health` snapshot, giving it visibility in the observability
loop even if you dismissed the SessionStart nudge.

**Manual check.** Compare your installed version against the latest
release at any time:

```bash
claude plugin list
```

Look for `ai-literacy-superpowers` in the output and compare the version
shown against the [releases page](https://github.com/Habitat-Thinking/ai-literacy-superpowers/releases)
or the [CHANGELOG](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/CHANGELOG.md).

---

## 1. Update the installed plugin

Pull the latest version into your local environment:

```bash
# Claude Code
claude plugin update ai-literacy-superpowers@ai-literacy-superpowers
```

```bash
# Copilot CLI
/plugin update ai-literacy-superpowers
```

This fetches the newest plugin code — skills, agents, hooks, commands,
and templates. Your project files (CLAUDE.md, HARNESS.md, etc.) are
not overwritten; only the plugin itself is updated.

---

## 2. Review what changed

Check the changelog for anything that affects your workflow:

```bash
# Read the installed changelog directly
cat ~/.claude/plugins/cache/ai-literacy-superpowers/ai-literacy-superpowers/<version>/CHANGELOG.md
```

Or browse the [CHANGELOG](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/CHANGELOG.md) on GitHub. Pay attention
to:

- **New skills or agents** you may want to use
- **Changed hooks** that may alter advisory behaviour
- **New template content** (new constraints, GC rules, or optional
  blocks) — these are adopted via `/harness-upgrade` in the next step
- **Minor version bumps** — in pre-1.0, minor bumps may include
  behavioural changes

---

## 3. Upgrade your HARNESS.md

Updating the plugin does not automatically update your HARNESS.md. New
template content — constraints, GC rules, optional blocks — must be
adopted explicitly:

```text
/harness-upgrade
```

The command compares the `<!-- template-version: X.Y.Z -->` marker in
your HARNESS.md against the installed plugin version. It presents each
new or changed item with a summary of what it does and lets you accept
or skip each one individually.

After you finish, the marker is updated to the current plugin version
and the SessionStart nudge goes silent until the next release.

See [Upgrade Your Harness](upgrade-your-harness.md) for the full
step-by-step guide to the upgrade menu.

---

## 4. Update the marketplace listing (maintainers only)

If you maintain a marketplace that includes this plugin, refresh the
index so the new version is discoverable:

```bash
claude plugin marketplace update Habitat-Thinking/ai-literacy-superpowers
```

This pulls the latest `plugin.json` metadata — version, description,
keywords — into the marketplace index. It does not update installations
for users who already have the plugin; they must run
`claude plugin update` themselves.

---

## 5. Verify the update

Confirm the new version is active:

```bash
claude plugin list
```

Then run a quick health check to make sure everything loads:

```text
/superpowers-status
```

If the status command reports missing components, try removing and
reinstalling the plugin:

```bash
claude plugin uninstall ai-literacy-superpowers
claude plugin install ai-literacy-superpowers
```

---

## What you have now

Your plugin is at the latest version and your HARNESS.md has been
reviewed for new template content. All skills, agents, hooks, and
commands reflect the newest release.

---

## Next steps

- [Run a harness audit](run-a-harness-audit.md) after major version
  updates to verify nothing has drifted
- [Review the CHANGELOG](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/CHANGELOG.md) for migration notes
- [Run an assessment](run-an-assessment.md) to see if new skills
  unlock higher literacy levels
