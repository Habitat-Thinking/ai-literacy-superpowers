---
name: harness-sync
description: Detect drift across all push-direction control surfaces, present the full picture, and apply the user's selected fixes via the existing primitives — single human-instigated entry point for keeping convention files in sync with HARNESS.md. ONBOARDING.md staleness is surfaced but not auto-fixed; users run /harness-onboarding deliberately when they want it regenerated.
---

# /harness-sync

Detect drift across every push-direction surface, present the full picture as
a structured table, and apply the selected fixes via the existing primitives
(`/convention-sync`). This command is a multiplexer —
it composes existing commands and does not introduce new propagation logic.

**What this command does NOT do:**

- It does _not_ write to `HARNESS.md`, `AGENTS.md`, or `REFLECTION_LOG.md` —
  those files are the harness source of truth; `/harness-sync` only writes to
  the generated surfaces derived from them.
- It does _not_ pull upstream template changes into `HARNESS.md` — that is
  `/harness-upgrade`.

## Invocation

- `/harness-sync` — full interactive mode: drift scan → selection → apply →
  verify → commit/PR.
- `/harness-sync --check` — drift scan only, no fix step. Exits after printing
  the status table. Useful for dry-run from CI or as the deep-scan step inside
  `/harness-health --deep`.

Read the `harness-audit-engine` skill from this plugin before
proceeding. The engine defines the shared drift-detection logic and
the drift-report shape. This command is the read-then-fix caller; it
runs the engine, builds a unified drift table including every audit
finding, and applies fixes via the existing primitives.

## Process

### 1. Branch Enforcement

Read the current branch:

```bash
git branch --show-current
```

**If the branch is `main`:** Refuse to apply changes directly to main.
Tell the user:

> You are on `main`. `/harness-sync` cannot apply changes directly to the
> default branch. Shall I create `chore/sync-surfaces-YYYY-MM-DD` for you?
> (Substitute today's date.) You can also supply a custom branch name.

Wait for the user's response:

- If the user accepts the default name or supplies a custom name, run:

  ```bash
  git checkout -b chore/sync-surfaces-YYYY-MM-DD
  ```

  (Substitute the confirmed branch name.) Record that a fresh `chore/` branch
  was created — this determines the commit/PR path in step 7.

- If the user declines to create a branch, exit cleanly with no changes.

**If the branch is anything other than `main`:** Proceed without creating a
new branch. Record that the user is on an existing feature branch — this
determines the lighter commit path in step 7.

### 2. Working-Tree-Clean Check

Run:

```bash
git status --porcelain
```

If the output is non-empty, refuse to proceed. List the dirty paths and tell
the user:

> Working tree is not clean. Resolve the following before running
> `/harness-sync`:
>
> `[list each dirty path on its own line]`
>
> Suggestion: stash with `git stash` or commit your work-in-progress first.

Exit without making any changes.

### 3. Phase 1 — Drift Scan via audit-engine

**If invoked with `--check`, the command stops after this phase — see exit semantics at the end of this section.**

Read `HARNESS.md` from the project root. If it does not exist, stop and tell
the user:

> No `HARNESS.md` found. Run `/harness-init` first, then re-run
> `/harness-sync`.

Invoke the `harness-audit-engine` skill to scan all surfaces. The engine
returns a list of findings in the structured shape documented in the
skill: each finding has `surface`, `status`, `details`, `action_command`,
and `auto_fixable`.

Surfaces the engine evaluates include (this list mirrors the table in the
audit-engine skill — when surfaces are added there, they appear here
automatically):

- `.cursor/rules/`, `.github/copilot-instructions.md`, `.windsurf/rules/`
- `ONBOARDING.md`
- Most recent snapshot in `observability/snapshots/`
- HARNESS.md Status section accuracy
- Template version drift
- Constraint regressions (deterministic constraints whose tool fails)
- Recurring reflection patterns (the `Reflection-driven regression detection` GC rule's findings)
- CI / CD (informational only)

#### Drift scan output table

Build and print this structured table from the findings. Each row's
`Action on apply` column carries `[auto]` or `[manual]` based on the
finding's `auto_fixable` field:

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
Constraint regression: ShellCheck unverified   drifted     /harness-constrain     [manual]
Reflection pattern: Output validation x3       candidate   /harness-constrain     [manual]
CI / CD (constraint scope)                     managed     handled at runtime
─────────────────────────────────────────────────────────────────────────────────────
N surfaces tracked · X drifted · Y missing · Z in sync · W managed · K candidates
```

State vocabulary:

- `drifted` — file or fact exists but does not match HARNESS.md / reality.
- `missing` — file is not present; would be created on apply.
- `in sync` — matches HARNESS.md / reality.
- `managed` — runtime-managed; surfaced for completeness, not actionable here.
- `candidate` — not strict drift but warrants review (recurring reflection patterns; deferred constraints).

If `--check` was passed, stop here and exit zero (or non-zero if any
finding is `drifted`, `missing`, or `candidate`). Do not proceed to
Phase 2.

### 4. Phase 2 — Selection

If all findings are `in sync` or `managed`, tell the user:

> All surfaces and audit checks are in sync. Nothing to apply.

Exit cleanly with no changes.

Otherwise, present a multi-select prompt. Use `AskUserQuestion` with
`multiSelect: true`. List each `drifted`, `missing`, or `candidate`
finding as a separate option, with the `[auto]` / `[manual]` tag from
the table. Default selection is _all_ actionable findings.

Group options visually so `[auto]` items appear before `[manual]`
items. The `managed` row never appears as a selectable option.

```json
{
  "type": "AskUserQuestion",
  "multiSelect": true,
  "question": "Select which findings to address. [auto] items run via existing primitives; [manual] items print the suggested command for you to run separately.",
  "options": [
    {
      "id": "cursor",
      "label": ".cursor/rules/  [auto: /convention-sync]",
      "selected": true
    },
    {
      "id": "windsurf",
      "label": ".windsurf/rules/  [auto: /convention-sync (create)]",
      "selected": true
    },
    {
      "id": "snapshot",
      "label": "Snapshot staleness  [auto: /harness-health]",
      "selected": true
    },
    {
      "id": "status",
      "label": "HARNESS.md Status accuracy  [auto: /harness-audit]",
      "selected": true
    },
    {
      "id": "onboarding",
      "label": "ONBOARDING.md  [manual: /harness-onboarding]",
      "selected": false
    },
    {
      "id": "template",
      "label": "Template drift  [manual: /harness-upgrade]",
      "selected": false
    },
    {
      "id": "regression",
      "label": "Constraint regression  [manual: /harness-constrain]",
      "selected": false
    },
    {
      "id": "none",
      "label": "Apply nothing — exit without changes",
      "selected": false
    }
  ]
}
```

Construct the actual options list from the Phase 1 findings. `[auto]`
items default to `selected: true`; `[manual]` items default to
`selected: false` (the user must opt in to running judgement-required
remediations, even via just printing the command).

If the user selects "Apply nothing — exit without changes" (or
deselects all surfaces), exit cleanly with no changes.

### 5. Phase 3 — Apply

For each selected finding, branch on its `auto_fixable` classification:

#### `[auto]` items — run the action command

For each `[auto]` selected finding, invoke its `action_command` _in
series_ (not in parallel — order matters for the verification scan):

1. **`.cursor/rules/`, `.github/copilot-instructions.md`, `.windsurf/rules/`** — invoke `/convention-sync`. This handles all three convention-file surfaces in a single run; if multiple are selected they share the same invocation.
2. **Snapshot staleness** — invoke `/harness-health`.
3. **HARNESS.md Status section accuracy** — invoke `/harness-audit`. (Audit updates Status as a side-effect of running.)

`ONBOARDING.md` is **not** auto-invoked. Sync surfaces its staleness as a `[manual]` finding so users see the drift, but `/harness-onboarding` is run separately by the user — onboarding regen is a heavier mutation than convention-file regen and benefits from the user's deliberate trigger.

If an underlying command errors out for one finding:

- Continue with the remaining selected `[auto]` findings.
- Mark the errored finding as `still drifted (error)` in the verification
  scan.
- The overall run will exit non-zero (see step 6 below).

#### `[manual]` items — print the suggested command

For each `[manual]` selected finding, do NOT invoke the action command.
Instead, print a "next step" line:

```text
Manual remediation suggested for: Template version drift
Run: /harness-upgrade
```

The user runs these separately. `/harness-sync` does not invoke them
to preserve the trust boundary — these commands require user judgement
(which template content to adopt, which constraint to add).

### 6. Verification Scan

After all selected `[auto]` items are applied, re-invoke the
`harness-audit-engine` skill and build the delta table:

```text
Apply complete — verification scan:

Surface / Finding                              Before      After
─────────────────────────────────────────────  ──────────  ─────────────
.cursor/rules/                                 drifted     in sync ✓
.windsurf/rules/                               missing     in sync ✓
ONBOARDING.md                                  drifted     drifted (manual — see suggestion above)
Snapshot staleness                             drifted     in sync ✓
HARNESS.md Status accuracy                     drifted     in sync ✓
Template drift                                 drifted     drifted (manual — see suggestion above)
```

If any selected `[auto]` finding is _not_ now `in sync`, mark it as
`still drifted (error)` in the After column. Do _not_ proceed to commit.
Report the failed findings and exit non-zero.

`[manual]` findings that the user selected are reported in the After
column with the `(manual — see suggestion above)` note, not flagged
as errors. They were not auto-applied.

If all selected `[auto]` findings are now `in sync` (and any `[manual]`
findings have their suggestions printed), proceed to the trust-boundary
guard.

### 7. Trust-Boundary Pre-Commit Guard

Before staging or committing, verify that no out-of-bounds file was touched.

Run:

```bash
git diff --name-only --cached
```

Verify every modified path matches the allow-list:

- `.cursor/rules/**`
- `.github/copilot-instructions.md`
- `.windsurf/rules/**`

If any path falls _outside_ the allow-list (including `HARNESS.md`,
`AGENTS.md`, `REFLECTION_LOG.md`, or `ONBOARDING.md` — which sync
surfaces as a `[manual]` finding but never writes to), refuse to
commit. Tell the user:

> Trust-boundary violation: the underlying primitive modified a file outside
> the allowed set. This is a bug in the underlying command, not a
> `/harness-sync` failure. Investigate before committing.
>
> Unexpected path(s): `[list each offending path]`

Do _not_ silently un-stage and continue. Exit non-zero.

If the guard passes, proceed to step 8 to commit and ship.

### 8. Commit and Ship

#### Path A — Fresh `chore/` branch (created in step 1)

Stage the surface files only:

```bash
git add .cursor/rules/ .github/copilot-instructions.md .windsurf/rules/
```

Git will only stage files with actual changes; paths that were not touched are
safe to include in the `git add` list.

Commit message: `"chore: sync convention files to HARNESS.md"`.

```bash
git commit -m "chore: sync convention files to HARNESS.md"
```

Push the branch:

```bash
git push -u origin <branch-name>
```

Open a PR with `--label chore`. The auto-generated body must include:

- **Why these changes:** latest HARNESS.md constraint changes (from `git log`).
- **Drift scan (before):** the Phase 1 table.
- **Verification scan (after):** the Phase 3 delta table.
- **Surfaces applied:** each surface and the command used.

```bash
gh pr create --label chore \
  --title "chore: sync surfaces to HARNESS.md" \
  --body "<auto-generated body as above>"
```

Report the PR URL and the verification delta.

#### Path B — Existing feature branch (step 1 skipped)

Stage and commit only — do _not_ push and do _not_ open a PR:

```bash
git add .cursor/rules/ .github/copilot-instructions.md .windsurf/rules/
git commit -m "chore: sync convention files to HARNESS.md"
```

Report the commit hash and tell the user:

> Changes committed to `<branch-name>`. Push when ready:
> `git push -u origin <branch-name>`

## Error and Refusal Cases

| Situation | Behaviour |
| --- | --- |
| Uncommitted changes on working tree | Refuse to run; print dirty paths; suggest stash or commit-first |
| Underlying command errors out for one surface | Continue with other surfaces; mark errored surface `still drifted (error)`; exit non-zero overall |
| Verification scan still shows drift after apply | Exit non-zero; report failed surfaces; do not commit |
| User declines all surfaces in Phase 2 | Exit cleanly with no changes |
| Pre-commit guard rejects HARNESS.md/AGENTS.md/REFLECTION_LOG.md path | Refuse to commit; treat as bug in underlying primitive |

## Idempotency

Running `/harness-sync` twice consecutively with no `HARNESS.md` changes
between runs MUST be a no-op on the second run. All surfaces will report
`in sync` in Phase 1, Phase 2 will offer nothing actionable, and the command
exits cleanly without committing anything.

## Output Format

On success with a fresh `chore/` branch:

```text
Harness Sync complete.

Verification:
  .cursor/rules/                  drifted → in sync ✓
  .github/copilot-instructions.md drifted → in sync ✓
  .windsurf/rules/                missing → in sync ✓ (created)
  ONBOARDING.md                   drifted → drifted (manual — run /harness-onboarding)

Branch:   chore/sync-surfaces-2026-05-07
Commit:   a1b2c3d  chore: sync convention files to HARNESS.md
Pushed:   origin/chore/sync-surfaces-2026-05-07
PR:       https://github.com/Habitat-Thinking/ai-literacy-superpowers/pull/N
```

On an existing feature branch (no auto-PR):

```text
Harness Sync complete.

Verification:
  .cursor/rules/                  drifted → in sync ✓
  ONBOARDING.md                   drifted → drifted (manual — run /harness-onboarding)

Commit:   a1b2c3d  chore: sync convention files to HARNESS.md
Push when ready: git push -u origin <branch-name>
```

## Validation Checkpoint

**This step is mandatory.** After generating the verification scan table in
step 6, read the table back and verify its structure matches this spec.

**Structural checks:**

1. Every selected surface appears in the After column.
2. Every After value is one of: `in sync ✓`, `in sync ✓ (created)`, or
   `still drifted (error)`.
3. No selected surface is missing from the table.
4. The Before value for each row matches the status recorded during Phase 1.

If any check fails, fix the table in place:

- Add missing surface rows using the Phase 1 status as the Before value.
- Correct any After value that does not match the vocabulary above.

Do not re-run the apply phase. Fix the output table directly, then proceed
to the trust-boundary guard.
