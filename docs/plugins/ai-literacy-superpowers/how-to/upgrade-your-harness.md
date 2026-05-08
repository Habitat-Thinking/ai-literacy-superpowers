---
title: Upgrade Your Harness
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 34
redirect_from:
  - /how-to/upgrade-your-harness/
  - /how-to/upgrade-your-harness.html
---

# Upgrade Your Harness

Run `/harness-upgrade` to adopt new template content after updating the plugin.

## Prerequisites

- The plugin is installed and active in your Claude Code session.
- Your HARNESS.md exists in the `.claude/` directory (created by `/harness-init`).

---

## 1. Check for available upgrades

Run the command:

```bash
/harness-upgrade
```

The command compares the `<!-- template-version: X.Y.Z -->` marker in your HARNESS.md against the installed plugin version. If versions match, no upgrade is needed. If they differ, the command displays a summary of changes.

---

## 2. Review new items

The command categorises changes into three groups:

- **New** — items in the latest template that aren't in your current HARNESS.md.
- **Updated** — items that exist in both but have changed.
- **Removed** — items in your HARNESS.md that are no longer in the template.

Read through each category to understand what will change.

---

## 3. Accept or dismiss items

For each new or updated item, you'll be prompted to accept or skip:

- **Accept** — the item is written to your HARNESS.md.
- **Skip** — the item is not added; you keep your current version.

After you accept or skip all items, the template version marker in your HARNESS.md is updated to match the current plugin version.

---

## 4. Dismiss for later

If you're not ready to upgrade, dismiss the prompt. A `.claude/.harness-upgrade-dismissed` marker is created. The SessionStart hook won't ask again until the next plugin update.

To force the upgrade later, delete the marker file and run `/harness-upgrade` again.

---

## 5. Verify the result

After the upgrade completes, run:

```bash
/harness-status
```

This confirms your HARNESS.md is up to date with the latest template content and shows the current version marker.

---

## What you have now

Your HARNESS.md is in sync with the plugin's template. All new features and fixes in the latest template are now available in your harness.

---

## Next steps

- Run `/harness-audit` to verify constraint enforcement.
- Run `/harness-health` to generate a snapshot of your harness state.
