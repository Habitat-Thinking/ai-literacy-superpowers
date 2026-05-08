---
title: Sync Conventions
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 6
redirect_from:
  - /how-to/sync-conventions/
  - /how-to/sync-conventions.html
---

# Sync Conventions

`/convention-sync` is one of the underlying primitives that
[`/harness-sync`](sync-harness.md)
composes. **For multi-surface propagation in one interactive pass — across
convention files _and_ `ONBOARDING.md` — use `/harness-sync`.** This page covers
the focused single-surface command for when you want to propagate the convention
files alone (for example, as part of a tighter loop immediately after
`/harness-constrain` adds a new constraint and you do not yet need to regenerate
the onboarding document).

The command itself: propagate HARNESS.md conventions to Cursor, Copilot, and
Windsurf so all AI coding tools work from the same rules.

---

## 1. Run the sync command

```text
/convention-sync
```

The agent reads the Context and Constraints sections of `HARNESS.md`, generates the
target files for each tool, and reports what changed in a summary table.

HARNESS.md is the single source of truth. Sync is one-way: HARNESS.md drives the other
files. Do not edit the generated files directly — changes will be overwritten on the
next sync.

---

## 2. Review the generated files

The sync creates or updates these files:

| Tool | File | Contents |
| ---- | ---- | -------- |
| Cursor | `.cursor/rules/conventions.mdc` | Context section (stack, conventions) |
| Cursor | `.cursor/rules/constraints.mdc` | One rule block per constraint |
| Copilot | `.github/copilot-instructions.md` | Context and constraints combined |
| Windsurf | `.windsurf/rules/conventions.md` | Context section (no frontmatter) |
| Windsurf | `.windsurf/rules/constraints.md` | One rule block per constraint |

Open each file and confirm that every constraint from HARNESS.md appears. If a
constraint is missing, the generation has a bug — report it rather than adding the
entry by hand.

---

## 3. Handle conflicts

When a target file already exists, the agent diffs the generated content against
the existing file:

- **Identical**: reports "unchanged" and moves on
- **Different**: shows the diff and asks before overwriting
- **Declined**: reports "skipped" for that file

If you have tool-specific rules that should not be in HARNESS.md, add them in a
separate file that the sync does not manage. For example, a Cursor-only rule about
a third-party IDE extension belongs in `.cursor/rules/ide-specific.mdc`, not in
`.cursor/rules/conventions.mdc`.

---

## 4. Commit the generated files

```bash
git add .cursor/rules/ .github/copilot-instructions.md .windsurf/rules/
git commit -m "Sync conventions from HARNESS.md to Cursor, Copilot, Windsurf"
```

---

## 5. Re-sync after HARNESS.md changes

Run `/convention-sync` whenever you add or promote a constraint in HARNESS.md. The
sync is fast — it reads HARNESS.md and regenerates only files that have changed.

A good practice is to add convention sync to your PR checklist:

```markdown
- [ ] Run `/convention-sync` if HARNESS.md was modified
```

---

## What gets synced

| HARNESS.md section | What it becomes |
| ------------------- | --------------- |
| Context > Stack | Tool description block in each file |
| Context > Conventions | Convention rules in each file |
| Each constraint entry | One rule block per constraint |
| Constraint `Scope` field | Cursor glob pattern (defaults to `**/*`) |

The Garbage Collection and Status sections are not synced — they are harness-internal
and have no equivalent in other tools.
