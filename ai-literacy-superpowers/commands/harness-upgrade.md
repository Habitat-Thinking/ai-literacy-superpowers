---
name: harness-upgrade
description: Discover and adopt new template content after a plugin upgrade — diffs your HARNESS.md against the current template and presents new items for review
---

# /harness-upgrade

Discover new constraints, GC rules, sections, and optional blocks that
have been added to the plugin's HARNESS.md template since your harness
was last generated or upgraded. Present each new item for review and
selectively adopt what you want.

## Process

### 1. Check Prerequisites

Verify HARNESS.md exists at the project root. If not, tell the user:
"No HARNESS.md found. Run /harness-init to create one."

**Verify local main is in sync with origin.** The marketplace cache
auto-syncs from `origin/main` on every PR merge, so this command
compares the user's local HARNESS.md against a near-real-time view of
main. If the local clone is stale, the upgrade will suggest content
that has already merged, and the resulting PR will conflict at push
time. Run:

```bash
git fetch origin main 2>/dev/null && \
  git rev-list HEAD..origin/main --count 2>/dev/null
```

If the count is non-zero, warn the user: "Your local clone is N
commits behind origin/main. The upgrade comparison may suggest content
that has already merged. Recommend `git pull` (if on main) or rebasing
your branch before continuing."

Offer to abort so the user can sync, or continue if the divergence is
known to be safe. Default: prompt the user. If `git fetch` or
`git rev-list` fails (no remote `main`, detached HEAD), skip this
check and continue silently — the staleness guard is best-effort, not
a hard block.

There is no version comparison. The plugin version says nothing about
whether the template changed — it moves on every release, and the
template does not. The comparison in steps 2–3 is the check.

### 2. Read and Parse Both Files

Read the user's `HARNESS.md` and the plugin's template at
`${CLAUDE_PLUGIN_ROOT}/templates/HARNESS.md`.

Parse each file into named items:

- **Constraints**: each `### Heading` block under `## Constraints`.
  Include commented-out blocks — identify them by
  `<!-- Uncomment if...` patterns. Extract the heading name from
  inside the comment.
- **GC rules**: each `### Heading` block under
  `## Garbage Collection`. Include commented-out blocks using the
  same pattern.
- **Sections**: top-level `## Heading` entries. Compare which
  sections exist in each file.

Match items by heading name (case-insensitive, trimmed).

### 3. Categorise Findings

Sort items into three buckets:

**New items** — present in the template, absent from the user's
HARNESS.md. These are the primary upgrade targets.

**Updated items** — present in both files, but the template content
differs. Only flag items the user has not customised: if the user's
version still matches a previously generated template version (i.e.
the text is identical to what the template shipped when they last
ran init or upgrade), flag it. If the user has edited the item, skip
it — the user's version takes precedence.

**Removed items** — present in the user's HARNESS.md but absent from
the current template. Advisory only.

If no findings in any bucket, tell the user: "Your harness already
contains all current template content." Then skip to step 6.

### 4. Present Menu

Show the user each finding, grouped by bucket.

**For new items**, present each one with:

- What it is: constraint, GC rule, or section
- Whether it's active or commented-out (optional content)
- A one-line summary of what it does (from the Rule or What it checks
  field)
- Options: **accept**, **skip**, or **customise**

Ask the user to choose for each item. If there are many items, present
them in a numbered list and allow batch responses (e.g. "accept all"
or "accept 1, 3, 5, skip 2, 4").

**For updated items**, show the diff between the user's version and
the template version. Options: **accept update**, **keep mine**.

**For removed items**, list them as advisory: "These items exist in
your harness but have been removed from the template. You may want
to review whether they're still relevant." No action required.

### 5. Apply Changes

For each accepted item:

- **New constraints**: append to the `## Constraints` section, before
  the `---` separator that closes the section.
- **New GC rules**: append to the `## Garbage Collection` section,
  before the `---` separator that closes the section.
- **New sections**: insert at the position matching the template's
  section order (e.g. `## Observability` goes between
  `## Garbage Collection` and `## Status`).
- **Commented-out blocks**: insert as commented, preserving the
  `<!-- Uncomment if... -->` wrapper.
- **Updated items**: replace the user's version with the template
  version.

Preserve all existing content that was not part of the upgrade.

### 6. Retire template-currency leftovers

No marker is written, and `.claude/.harness-upgrade-dismissed` is neither
written nor read.

Instead, on **every** run, look in the user's `HARNESS.md` for two
leftovers from the retired template-currency mechanism:

1. A `<!-- template-version: X.Y.Z -->` marker.
2. A `### Template currency` GC rule whose **Tool** field references the
   template-version comment.

The second matters because the rule is declared `deterministic` and its
tool compares a marker that no longer exists. An absent marker used to
read as `0.0.0`, so the rule reports drift on every run, permanently,
with no way to clear it.

**Present each as a finding for the user to accept or skip**, in the same
per-item form step 4 uses. Never remove either without a recorded
decision — a project may have specialised that rule, and deleting
someone's work during a command they ran for another reason is not
something this command does.

**Near misses are reported, never guessed.** If a `### Template currency`
heading is present but its **Tool** field does not reference the
template-version comment, report it and leave it alone. The same applies
to a marker in an unexpected form.

Both removals are idempotent: a second run finds nothing further.

### 7. Report

Summarise what happened:

- Items accepted (with names)
- Items skipped
- Removed items flagged for review (if any)

For the step 6 leftovers, report all three outcomes distinctly:

- **removed** — the user accepted a finding
- **found, not removed** — the user skipped it, or it was a near miss
- **not found** — the file was read and contained neither

"Nothing reported" must never be able to mean "the file could not be
parsed". Silence is not the reassuring answer.

Suggest next steps:

- "Run /harness-audit to verify the new constraints"
- "Run /harness-init to configure any new sections"
- If constraints were added: "New constraints start as the template
  declares them. Use /harness-constrain to adjust enforcement level
  or scope."
