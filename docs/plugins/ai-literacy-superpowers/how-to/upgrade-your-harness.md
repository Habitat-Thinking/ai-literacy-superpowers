---
title: Upgrade Your Harness
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

The command compares your HARNESS.md against the plugin's template directly and displays a summary of what differs. If nothing differs, it says so.

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

## 4. Skip for later

If you're not ready to adopt an item, skip it. Nothing is written, and the item is offered again the next time you run `/harness-upgrade`.

Nothing prompts you between runs — `/harness-upgrade` is on-demand.

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
