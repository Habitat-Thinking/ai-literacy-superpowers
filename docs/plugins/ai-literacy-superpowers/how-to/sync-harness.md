---
title: Sync Harness Surfaces
---
# Sync the harness

> Run `/harness-sync` to bring every surface into alignment with
> `HARNESS.md`. Same engine as `/harness-audit` (the read-only
> diagnostic), but with a multi-select prompt that lets you apply
> the fixes.

## When to run it

- After modifying `HARNESS.md` (new constraint, edited convention,
  promoted enforcement level).
- After merging a PR that touched `HARNESS.md` or any of the derived
  surfaces.
- When you suspect drift but want to see the full picture before
  acting.
- As a periodic check — once a sprint or whenever the SessionStart
  hook nudges you.

## What you'll see

`/harness-sync` runs in three phases. Phase 1 is the drift scan via
the shared audit-engine; it prints a unified drift table:

```text
Surface / Finding                              Status      Action on apply
─────────────────────────────────────────────  ──────────  ────────────────────────
.cursor/rules/                                 drifted     /convention-sync       [auto]
.github/copilot-instructions.md                in sync     —
.windsurf/rules/                               missing     /convention-sync       [auto]
ONBOARDING.md                                  drifted     /harness-onboarding    [manual]
Snapshot staleness (last: 2026-04-15)          drifted     /harness-health        [auto]
HARNESS.md Status section accuracy             drifted     /harness-audit         [auto]
Template version (HARNESS: 0.31, plugin: 0.34) drifted     /harness-upgrade       [manual]
Reflection pattern: Output validation x3       candidate   /harness-constrain     [manual]
CI / CD (constraint scope)                     managed     handled at runtime
```

The `Action on apply` column has two flavours:

- **`[auto]`** — the fix is mechanical. `/harness-sync` will run it
  for you when you select the row.
- **`[manual]`** — the fix needs a judgement call (which constraint
  to add, whether to take a template upgrade). `/harness-sync` will
  print the suggested command but won't run it.

## What you'll do

After Phase 1 prints the drift table, Phase 2 prompts you with a
multi-select. Every drifted, missing, or candidate finding appears
as a checkbox. `[auto]` items default to checked; `[manual]` items
default to unchecked.

Pick which to address. Hit "Apply nothing — exit without changes" if
you just wanted the diagnostic.

Phase 3 applies the fixes. For each `[auto]` selection, `/harness-sync`
invokes the underlying primitive (`/convention-sync`, `/harness-health`,
`/harness-audit`). For each `[manual]` selection — including
`ONBOARDING.md` staleness — it prints a "next step" line:

```text
Manual remediation suggested for: Template version drift
Run: /harness-upgrade
```

You run those separately.

## Verification

`/harness-sync` re-runs the audit-engine after applying and prints a
delta table:

```text
Apply complete — verification scan:

Surface / Finding                              Before      After
─────────────────────────────────────────────  ──────────  ─────────────
.cursor/rules/                                 drifted     in sync ✓
.windsurf/rules/                               missing     in sync ✓
ONBOARDING.md                                  drifted     drifted (manual — run /harness-onboarding)
Snapshot staleness                             drifted     in sync ✓
HARNESS.md Status accuracy                     drifted     in sync ✓
Template drift                                 drifted     drifted (manual — see suggestion above)
```

If any selected `[auto]` finding didn't reach `in sync`, the run exits
non-zero and prints what failed. `[manual]` findings keep their
"drifted" status with the suggestion note — they were never going to
be auto-applied.

## Branch and trust-boundary

`/harness-sync` refuses to run on `main`. If you're on `main` it
offers to create `chore/sync-surfaces-YYYY-MM-DD` for you.

The trust-boundary pre-commit guard restricts what may be committed
from a sync run:

- `.cursor/rules/**`, `.github/copilot-instructions.md`,
  `.windsurf/rules/**` — convention files derived from HARNESS.md
- `observability/snapshots/**` — only when `/harness-health` ran as
  a selected `[auto]` action
- `HARNESS.md` — only the four-line Status block under the
  `<!-- Auto-updated by /harness-audit — do not edit manually -->`
  marker. Sync regenerates these lines as the audit-engine's
  narrowly-scoped Status auto-fix and runs a scoped-diff check before
  committing — any HARNESS.md change outside the Status block is
  treated as a trust-boundary violation.

`AGENTS.md`, `REFLECTION_LOG.md`, and `ONBOARDING.md` are never on
the allow-list. `ONBOARDING.md` shows in the drift table as a
`[manual]` finding so you can see when it's stale, but
`/harness-onboarding` runs separately under your deliberate trigger.

The Context, Constraints, Garbage Collection, Observability, and
Read-side filtering sections of HARNESS.md are off-limits to sync —
those are the harness source of truth, edited by humans (or by
`/harness-upgrade` when adopting upstream template content).

## `--check` mode

`/harness-sync --check` runs Phase 1 only. Prints the drift table and
exits. Useful from CI or scripts when you just want to know if drift
exists. Exits non-zero if any finding is drifted, missing, or candidate;
zero otherwise.

## When `/harness-sync` isn't enough

Some drift can't be `[auto]`-fixed:

- **Template drift** — run `/harness-upgrade` and adjudicate the new
  items.
- **Constraint regression** — run `/harness-constrain` to either fix
  the constraint or downgrade its enforcement level.
- **Recurring reflection pattern** — run `/harness-constrain` to
  promote the pattern into a constraint.

`/harness-sync` will tell you which to run. You decide when.

## Related

- [How to: run a harness audit](run-a-harness-audit.md) — the
  read-only diagnostic, same engine as sync.
- [The Harness Lifecycle](../explanation/the-harness-lifecycle.md) —
  the broader detect-heal-pull frame.
- [How to: add a constraint](add-a-constraint.md) — the
  `/harness-constrain` workflow.
- [How to: upgrade your harness](upgrade-your-harness.md) — the
  `/harness-upgrade` workflow.
