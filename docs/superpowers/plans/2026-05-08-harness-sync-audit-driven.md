# Audit-driven `/harness-sync` and Lifecycle Docs Simplification — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewire `/harness-sync` to run `/harness-audit`'s detection logic internally via a shared audit-engine skill, presenting a unified drift table that includes audit findings beyond the current four push-direction surfaces. Simplify the lifecycle docs to converge on one canonical narrative ("detect drift → heal it; pull upstream when needed") with `/harness-sync` as the everyday entry point.

**Architecture:** Extract a new internal `harness-audit-engine` skill that documents the shared drift-detection logic and report shape. Both `/harness-audit` (read-only inspection) and `/harness-sync` (read-then-fix) reference it. The `/harness-sync` command's process is restructured around this engine, with each drift row tagged `[auto]` or `[manual]` to distinguish mechanical fixes from judgement-required ones.

**Tech Stack:** Markdown (skills, commands, docs), Bash (no new scripts in this PR — existing `/harness-sync` is purely conversational), MkDocs Material (for docs build verification), markdownlint (CI gate).

---

## File Structure

**Create:**

| Path | Responsibility |
| --- | --- |
| `ai-literacy-superpowers/skills/harness-audit-engine/SKILL.md` | The shared audit-engine contract: what to detect, the drift-report shape, the `[auto]`/`[manual]` classification rule, the per-finding action mapping. |

**Modify:**

| Path | Why |
| --- | --- |
| `ai-literacy-superpowers/commands/harness-audit.md` | Add reference to the new audit-engine skill at the top of the Process section. User-facing UX unchanged. |
| `ai-literacy-superpowers/commands/harness-sync.md` | Rewrite the Process section to invoke audit-engine in Phase 2 (replacing the per-surface drift detection), expand the drift table in Phase 3 to include all audit findings with `[auto]`/`[manual]` tags, branch the apply step in Phase 5 between auto-fix and print-the-command. |
| `docs/plugins/ai-literacy-superpowers/explanation/the-harness-lifecycle.md` | Substantive rewrite as the canonical lifecycle narrative. |
| `docs/plugins/ai-literacy-superpowers/explanation/the-harness-tuning-loop.md` | Trim to focus on the signal-capture → constraint-promotion sub-flow. |
| `docs/plugins/ai-literacy-superpowers/explanation/self-improving-harness.md` | Trim to the conceptual core; remove walkthroughs that duplicate how-tos. |
| `docs/plugins/ai-literacy-superpowers/how-to/sync-harness.md` | Rewrite for the audit-driven flow. |
| `docs/plugins/ai-literacy-superpowers/how-to/run-a-harness-audit.md` | Clarify diagnostic role; route everyday users to `/harness-sync`. |
| `docs/plugins/ai-literacy-superpowers/tutorials/getting-started.md` | Touch-up: position `/harness-sync` as everyday command. |
| `docs/plugins/ai-literacy-superpowers/tutorials/first-time-tour.md` | Same touch-up. |
| `docs/plugins/ai-literacy-superpowers/index.md` (plugin landing) | Touch-up: reflect simpler everyday flow. |
| `CLAUDE.md` (root) | Quarterly/Monthly Operations sections: replace ad-hoc lists with `/harness-sync`. |
| `ai-literacy-superpowers/templates/CLAUDE.md` | Same Operations update (shipped template). |
| `README.md` | Plugin description; command tables. |
| `ai-literacy-superpowers/.claude-plugin/plugin.json` | Version `0.34.1` → `0.35.0`. |
| `.claude-plugin/marketplace.json` | `plugin_version` and `plugins[0].version` → `0.35.0`. |
| `CHANGELOG.md` | New top heading `## 0.35.0 — 2026-05-08` with theme + bullets. |

---

## Task 1: Create the `harness-audit-engine` skill

**Files:**
- Create: `ai-literacy-superpowers/skills/harness-audit-engine/SKILL.md`

The audit-engine is a new internal skill that both `/harness-audit` and `/harness-sync` reference. It defines the shared drift-detection logic so the two commands stay in sync as audit's surface coverage evolves.

- [ ] **Step 1: Create the directory and SKILL.md**

```bash
mkdir -p ai-literacy-superpowers/skills/harness-audit-engine
```

Write `ai-literacy-superpowers/skills/harness-audit-engine/SKILL.md`:

````markdown
---
name: harness-audit-engine
description: Use when running the shared drift-detection logic that backs /harness-audit and /harness-sync — produces a structured drift report covering convention files, ONBOARDING.md, snapshot staleness, template drift, constraint regressions, recurring reflection patterns, and HARNESS.md Status section accuracy.
---

# Harness Audit Engine

## Overview

The harness audit-engine is the shared drift-detection layer that both
`/harness-audit` and `/harness-sync` invoke. Audit is read-only; sync
uses the same engine to drive its multi-select prompt. This skill
defines the contract — what surfaces are scanned, the drift-report
shape, and the per-finding `[auto]` / `[manual]` classification rule.

`/harness-audit` and `/harness-sync` are the two callers. Their UX
differs (audit prints, sync prompts), but the underlying findings are
the same.

## What the engine scans

The engine evaluates every surface or fact that could be out of sync
with `HARNESS.md`. The current scan covers:

| Category | Finding | Auto-fixable? |
| --- | --- | --- |
| Convention files | `.cursor/rules/` matches HARNESS.md | yes — `/convention-sync` |
| Convention files | `.github/copilot-instructions.md` matches HARNESS.md | yes — `/convention-sync` |
| Convention files | `.windsurf/rules/` matches HARNESS.md | yes — `/convention-sync` |
| Onboarding | `ONBOARDING.md` matches HARNESS.md + AGENTS.md + REFLECTION_LOG.md | yes — `/harness-onboarding` |
| Observability | Most recent snapshot in `observability/snapshots/` is < 30 days old | yes — `/harness-health` |
| Status section | `HARNESS.md` Status block matches actual constraint enforcement counts | yes — `/harness-audit` (audit updates Status as a side-effect) |
| Template currency | `<!-- template-version: X -->` in HARNESS.md matches installed plugin version | manual — `/harness-upgrade` |
| Constraint regression | Any constraint marked `deterministic` whose tool no longer succeeds | manual — `/harness-constrain` |
| Reflection pattern | Recurring failure pattern in REFLECTION_LOG.md (2+ similar entries, not yet a constraint) | manual — `/harness-constrain` |
| CI / CD | Constraint scope handled at runtime by harness-enforcer | informational — handled at runtime |

New surfaces added to the engine appear in both commands automatically.

## Drift-report shape

The engine returns a list of findings. Each finding has:

- `surface` — short label (e.g. `.cursor/rules/`, `Snapshot staleness`)
- `status` — one of `drifted`, `missing`, `in sync`, `managed`, `candidate`
- `details` — short string with the specific evidence (e.g. `last: 2026-04-15`, `HARNESS: 0.31, plugin: 0.34`)
- `action_command` — the slash command that remediates this finding (e.g. `/convention-sync`, `/harness-upgrade`)
- `auto_fixable` — `true` if the action runs without further user judgement; `false` if the action requires user input

## State vocabulary

- `drifted` — file or fact exists but does not match HARNESS.md / reality.
- `missing` — file expected but not present.
- `in sync` — matches HARNESS.md / reality.
- `managed` — handled at runtime by other layers (CI/CD); informational only.
- `candidate` — finding that is not strict drift but warrants review (recurring reflection patterns; deferred constraints).

## Auto-fixable classification rule

A finding is `auto_fixable: true` only when:

1. There is a deterministic remediation (a specific command that, given the same HARNESS.md state, would always produce the same fix).
2. The remediation writes to allow-listed paths (the four push-direction surfaces) OR mutates HARNESS.md only in defined ways (Status section regen via `/harness-audit`, snapshot creation via `/harness-health`).
3. No user judgement is required between detection and remediation.

Findings that need user input — choosing which constraint to add, deciding whether enforcement should be promoted, deciding when to take an upstream template upgrade — are `auto_fixable: false`. Sync surfaces them as `[manual]` rows; selecting them prints the suggested command without writing.

## Caller contract

Each caller is responsible for its own UX:

- `/harness-audit` prints the findings in its existing format and updates `HARNESS.md` Status section.
- `/harness-sync` builds its drift table from the findings, prompts for selection, and dispatches the action commands.

The engine itself does not print or prompt. It returns the findings and exits.

## Adding a new surface to the engine

When a new check is added to the engine:

1. Document the surface in the Categories table above.
2. Decide its `auto_fixable` classification using the rule.
3. Define the `action_command` it maps to.
4. Both `/harness-audit` and `/harness-sync` pick up the new finding without further code changes.

This is the value of factoring the engine: surface coverage evolves in one place.
````

- [ ] **Step 2: Run markdownlint**

Run: `npx markdownlint-cli2 ai-literacy-superpowers/skills/harness-audit-engine/SKILL.md`

Expected: no warnings.

- [ ] **Step 3: Commit**

```bash
git add ai-literacy-superpowers/skills/harness-audit-engine/SKILL.md
git commit -m "feat(skill): add harness-audit-engine shared skill

Documents the shared drift-detection contract for /harness-audit and
/harness-sync. Defines the surfaces scanned, the drift-report shape,
the [auto]/[manual] classification rule, and the per-finding action
mapping.

The engine itself does not print or prompt — each caller handles its
own UX. /harness-audit prints findings and updates HARNESS.md Status;
/harness-sync builds its drift table and dispatches actions."
```

---

## Task 2: Refactor `/harness-audit` to reference the audit-engine skill

**Files:**
- Modify: `ai-literacy-superpowers/commands/harness-audit.md` (top of Process section)

`/harness-audit`'s user-facing behaviour does not change. The only edit is a new line at the top of the Process section that references the audit-engine skill, ensuring agents executing the command load it.

- [ ] **Step 1: Read the current command**

Run: `cat ai-literacy-superpowers/commands/harness-audit.md` to confirm the structure.

- [ ] **Step 2: Insert the engine reference**

Find the line near the top of the file that reads `## Process` (it will be roughly line 10).

Immediately above the `## Process` heading, insert:

```markdown
Read the `harness-audit-engine` skill from this plugin before
proceeding. The engine defines the shared drift-detection logic and
the drift-report shape. This command is the read-only inspection
caller; `/harness-sync` is the read-then-fix caller.

```

(Two newlines after the last sentence, then the existing `## Process` line.)

- [ ] **Step 3: Run markdownlint**

Run: `npx markdownlint-cli2 ai-literacy-superpowers/commands/harness-audit.md`

Expected: no warnings.

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/commands/harness-audit.md
git commit -m "refactor(commands): point /harness-audit at audit-engine skill

Adds a one-paragraph reference to the new harness-audit-engine skill
at the top of the Process section. /harness-audit's user-facing UX is
unchanged — it remains the read-only inspection caller. The engine
reference ensures agents executing the command load the shared
drift-detection contract."
```

---

## Task 3: Rewrite `/harness-sync` to be audit-driven

**Files:**
- Modify: `ai-literacy-superpowers/commands/harness-sync.md` (Process section, drift table example)

This is the load-bearing behavioural change. The current Process section has 8 numbered steps focused on the four push-direction surfaces. The new Process section keeps the 8-step shape but replaces the per-surface drift detection in step 3 with an audit-engine invocation, expands the drift table to include every audit finding tagged `[auto]` or `[manual]`, and branches the apply step between auto-fix and print-the-command.

- [ ] **Step 1: Read the current command**

Run: `cat ai-literacy-superpowers/commands/harness-sync.md` to confirm the current structure (8 numbered subsections under `## Process`, plus `## Error and Refusal Cases`, `## Idempotency`, `## Output Format`, `## Validation Checkpoint` sections).

- [ ] **Step 2: Insert the engine reference**

Find the line that reads `## Process` (currently line 29).

Immediately above the `## Process` heading, insert:

```markdown
Read the `harness-audit-engine` skill from this plugin before
proceeding. The engine defines the shared drift-detection logic and
the drift-report shape. This command is the read-then-fix caller; it
runs the engine, builds a unified drift table including every audit
finding, and applies fixes via the existing primitives.

```

- [ ] **Step 3: Replace section "### 3. Phase 1 — Drift Scan"**

Find the section heading `### 3. Phase 1 — Drift Scan` (currently line 83) and the next section heading `### 4. Phase 2 — Selection`.

Replace EVERYTHING between them with:

````markdown
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
ONBOARDING.md                                  drifted     /harness-onboarding    [auto]
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
````

- [ ] **Step 4: Replace section "### 4. Phase 2 — Selection"**

Find `### 4. Phase 2 — Selection` (currently line 148) and the next section `### 5. Phase 3 — Apply`.

Replace EVERYTHING between them with:

````markdown
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
      "id": "onboarding",
      "label": "ONBOARDING.md  [auto: /harness-onboarding]",
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
````

- [ ] **Step 5: Replace section "### 5. Phase 3 — Apply"**

Find `### 5. Phase 3 — Apply` (currently line 201) and the next section `### 6. Verification Scan`.

Replace EVERYTHING between them with:

````markdown
### 5. Phase 3 — Apply

For each selected finding, branch on its `auto_fixable` classification:

#### `[auto]` items — run the action command

For each `[auto]` selected finding, invoke its `action_command` _in
series_ (not in parallel — order matters for the verification scan):

1. **`.cursor/rules/`, `.github/copilot-instructions.md`, `.windsurf/rules/`** — invoke `/convention-sync`. This handles all three convention-file surfaces in a single run; if multiple are selected they share the same invocation.
2. **`ONBOARDING.md`** — invoke `/harness-onboarding`.
3. **Snapshot staleness** — invoke `/harness-health`.
4. **HARNESS.md Status section accuracy** — invoke `/harness-audit`. (Audit updates Status as a side-effect of running.)

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
````

- [ ] **Step 6: Replace section "### 6. Verification Scan"**

Find `### 6. Verification Scan` (currently line 218) and the next section `### 7. Trust-Boundary Pre-Commit Guard`.

Replace EVERYTHING between them with:

````markdown
### 6. Verification Scan

After all selected `[auto]` items are applied, re-invoke the
`harness-audit-engine` skill and build the delta table:

```text
Apply complete — verification scan:

Surface / Finding                              Before      After
─────────────────────────────────────────────  ──────────  ─────────────
.cursor/rules/                                 drifted     in sync ✓
.windsurf/rules/                               missing     in sync ✓
ONBOARDING.md                                  drifted     in sync ✓
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
````

- [ ] **Step 7: Run markdownlint**

Run: `npx markdownlint-cli2 ai-literacy-superpowers/commands/harness-sync.md`

Expected: no warnings.

- [ ] **Step 8: Commit**

```bash
git add ai-literacy-superpowers/commands/harness-sync.md
git commit -m "refactor(commands): /harness-sync is now audit-driven

Replaces the per-surface drift detection in Phase 1 with an invocation
of the new harness-audit-engine skill. The drift table now includes
every audit finding tagged [auto] or [manual] based on whether the
remediation runs without user judgement.

Phase 3 (Apply) branches: [auto] findings run via existing primitives
(/convention-sync, /harness-onboarding, /harness-health, /harness-audit);
[manual] findings print 'Run: <command>' suggestions without writing,
preserving the trust boundary.

The trust-boundary pre-commit guard's allow-list is unchanged — the
unified drift table includes additional rows but those rows either
fix non-allow-listed paths via existing primitives (which have their
own trust boundaries) or print suggestions without writing."
```

---

## Task 4: Rewrite `the-harness-lifecycle.md` as canonical narrative

**Files:**
- Modify: `docs/plugins/ai-literacy-superpowers/explanation/the-harness-lifecycle.md` (full body rewrite)

The current page (290 lines) traces a six-stage tuning loop end-to-end. The new page is the canonical lifecycle narrative built around the simpler "detect drift → heal it; pull upstream when needed" frame, with `/harness-sync` as the everyday entry point.

- [ ] **Step 1: Read the current file**

Run: `cat docs/plugins/ai-literacy-superpowers/explanation/the-harness-lifecycle.md` to see the existing structure.

- [ ] **Step 2: Replace the body (everything below the frontmatter)**

Preserve the existing frontmatter (the first `---` block at the top of the file). Replace the body — everything from the first `# H1` heading down — with this content:

````markdown
# The Harness Lifecycle

> The harness has a simple lifecycle: **detect drift, heal it, pull
> upstream when needed**. Three commands cover it. Everything else is
> a deeper or specialised version of one of those three.

## The three states a harness is ever in

A harness is always in one of three states:

1. **In sync.** HARNESS.md matches reality. Convention files reflect
   the current rules. Reflections are captured. The Status section
   accurately describes enforcement.
2. **Drifted.** Something has fallen out of alignment. A convention
   file is stale, a snapshot has aged out, a constraint regressed,
   or a recurring reflection pattern hasn't been promoted yet.
3. **Behind upstream.** The plugin has shipped new template content
   the project hasn't reviewed yet — new constraint defaults, new GC
   rules, new conventions.

Every command in the plugin moves the harness between these states.
Most are specialisations; a few are the everyday entry points.

## The everyday entry points

Three commands cover most lifecycle activity:

### `/harness-sync` — the everyday command

Detects drift across every surface and lets you fix it in one pass.
Internally runs `/harness-audit`'s detection logic, presents a unified
drift table, and applies the fixes you select. Mechanical fixes
(convention files, ONBOARDING.md, snapshots, HARNESS.md Status
accuracy) run automatically. Judgement-required fixes (which
constraint to add, whether to take a template upgrade) print the
suggested command for you to run separately.

When in doubt, run `/harness-sync`. It tells you everything that's out
of alignment and either fixes it or tells you what to run.

### `/harness-upgrade` — pull upstream changes

When the plugin has shipped new template content, `/harness-upgrade`
diffs your `HARNESS.md` against the current template and presents new
items for review. You accept, skip, or customise each one.

`/harness-sync` will tell you when this is needed (the "Template
version drift" row in its drift table). `/harness-upgrade` is the
remediation; it doesn't auto-run because choosing what to adopt is a
judgement call.

### `/harness-constrain` — capture or promote a constraint

When you want to add a new constraint to HARNESS.md, or promote an
existing one from `unverified` to `agent` or `deterministic`,
`/harness-constrain` walks you through the authoring with the
constraint-design skill loaded.

`/harness-sync` will surface "Recurring reflection pattern" findings
when REFLECTION_LOG.md shows the same surprise twice. That's the
signal that a constraint should exist for that pattern. `/harness-
constrain` is the authoring path.

## The specialised commands

Behind the everyday three, there are deeper or focused tools:

- **`/harness-audit`** is the inspection-only deep-dive. Same engine
  as `/harness-sync` but read-only — no prompts, just a report.
  Useful when you want to inspect without committing to action, or
  when scripting / scheduling. The cadence in `HARNESS.md`
  Observability ("Harness audit: quarterly") refers to this command.
- **`/harness-status`** is a quick-look summary — enforcement ratio,
  drift indicator, GC state. Faster than `/harness-audit` for "is
  everything roughly OK?"
- **`/harness-health`** generates a full snapshot to
  `observability/snapshots/`. The longitudinal record of the harness
  over time, with trends.
- **`/harness-gc`** manages the periodic garbage-collection rules
  that fight slow drift between PR-level enforcement events.
- **`/convention-sync`** and **`/harness-onboarding`** are the
  primitives `/harness-sync` calls. You can invoke them directly when
  you only want one surface refreshed.

## When each lifecycle state happens

- **You write a constraint** → run `/harness-constrain`. Then later,
  next time you run `/harness-sync`, the new constraint propagates to
  the convention files automatically (it shows up as a drifted
  surface that auto-fixes).
- **You merge a PR** → run `/harness-sync` if the PR changed
  HARNESS.md content. Convention files and ONBOARDING.md regenerate.
- **You see a build break** related to harness state → run
  `/harness-audit` for the read-only diagnostic, or `/harness-sync`
  to also fix.
- **You install a new plugin version** → run `/harness-upgrade`. The
  SessionStart hook nudges you when the template version has moved.
- **You notice a pattern of failures** in REFLECTION_LOG.md → run
  `/harness-constrain` to encode the lesson.

## Why this lifecycle works

The lifecycle is built around two truths.

**Truth one: HARNESS.md is the single source of truth.** Everything
else is derived. Convention files are derived from the Conventions
and Constraints sections. ONBOARDING.md is derived from HARNESS.md +
AGENTS.md + REFLECTION_LOG.md. The snapshot is derived from the
current state. The Status section is derived from actual enforcement.
When anything diverges, regeneration brings it back into alignment.

**Truth two: not every drift is mechanical.** Some drift signals a
real choice — should we take the upstream template? Should this
recurring reflection become a constraint? Mechanical regeneration
works for derived surfaces; choices need a human. The
`[auto]` / `[manual]` distinction in `/harness-sync`'s drift table
makes this explicit, and keeps the trust boundary clear: the command
applies mechanical fixes; choices stay with you.

## Related reading

- [The Harness Tuning Loop](the-harness-tuning-loop.md) — the focused
  sub-flow for promoting reflection patterns into constraints.
- [The Self-Improving Harness](self-improving-harness.md) — why a
  harness needs to evolve and how compound learning fits in.
- [How to: sync the harness](../how-to/sync-harness.md) — the
  step-by-step for `/harness-sync`.
- [How to: run a harness audit](../how-to/run-a-harness-audit.md) —
  the diagnostic workflow.
````

- [ ] **Step 3: Run markdownlint**

Run: `npx markdownlint-cli2 docs/plugins/ai-literacy-superpowers/explanation/the-harness-lifecycle.md`

Expected: no warnings.

- [ ] **Step 4: Commit**

```bash
git add docs/plugins/ai-literacy-superpowers/explanation/the-harness-lifecycle.md
git commit -m "docs(explanation): rewrite the-harness-lifecycle as canonical narrative

The page is now the single canonical lifecycle narrative for the
plugin. Frame: 'detect drift → heal it; pull upstream when needed'.
Three states (in sync, drifted, behind upstream) cover everything;
three everyday commands (/harness-sync, /harness-upgrade,
/harness-constrain) cover the transitions; everything else is a
specialised tool.

Drops the previous six-stage tuning-loop walkthrough — that content
moves to the-harness-tuning-loop, which now focuses specifically on
the signal-capture → constraint-promotion sub-flow."
```

---

## Task 5: Trim `the-harness-tuning-loop.md` to its sub-flow

**Files:**
- Modify: `docs/plugins/ai-literacy-superpowers/explanation/the-harness-tuning-loop.md` (full body rewrite)

The current page covers the broad lifecycle. With the lifecycle narrative now in `the-harness-lifecycle.md`, this page refocuses on the specific signal-capture → constraint-promotion sub-flow.

- [ ] **Step 1: Read the current file**

Run: `cat docs/plugins/ai-literacy-superpowers/explanation/the-harness-tuning-loop.md` to see the existing structure.

- [ ] **Step 2: Replace the body (everything below the frontmatter)**

Preserve the existing frontmatter. Replace the body with:

````markdown
# The Harness Tuning Loop

> A harness improves over time through a specific sub-flow: surprises
> get captured as reflections, recurring patterns become candidate
> constraints, candidate constraints get promoted via
> `/harness-constrain`. This page is about that sub-flow.

For the broader picture, see [The Harness Lifecycle](the-harness-lifecycle.md).
This page goes deeper on the part of the lifecycle that turns
*lessons* into *enforcement*.

## The four stages

### 1. Capture — write the reflection

When a session ends with something surprising — a wrong assumption,
an unexpected gotcha, a workflow hole — the integration agent (or you,
running `/reflect`) appends an entry to `REFLECTION_LOG.md`. Each
entry has:

- A one-sentence task summary
- The surprise — what went wrong or wasn't expected
- A proposal — what could prevent this next time
- A signal — `failure`, `workflow`, `context`, or `none`
- An optional proposed constraint

`failure` and `workflow` signals are the ones that feed this loop.

### 2. Detect — let the GC rule find recurring patterns

The `Reflection-driven regression detection` GC rule runs weekly. It
scans `REFLECTION_LOG.md` for recurring failure patterns — the same
type of surprise across two or more entries. When it finds one, it
flags the pattern as a candidate constraint.

`/harness-sync`'s drift table includes these candidates as
`[manual]` rows. The action command suggested is `/harness-constrain`.

### 3. Promote — author the constraint

`/harness-constrain` is the authoring path. It loads the
`constraint-design` skill, which walks through:

- The rule itself (must be falsifiable)
- The enforcement level (`unverified`, `agent`, `deterministic`)
- The tool, if deterministic
- The scope (`commit`, `pr`, `weekly`, `manual`)

The constraint gets added to `HARNESS.md`. From that point forward
it appears in `/harness-sync`'s convention-file drift detection
(if it changes the conventions text) and in `/harness-audit`'s
enforcement-ratio reporting.

### 4. Verify — let the constraint catch real violations

The newly authored constraint enters the active enforcement set. Its
behaviour over the next few PRs is the test of whether the promotion
was correct:

- If it catches real instances of the original surprise, promotion
  was right.
- If it never fires, the underlying assumption may have been wrong —
  the surprise was a one-off, or the constraint's rule isn't falsifiable
  enough to detect the real pattern. Either way, future reflections
  will say so.
- If it fires on innocent code, the constraint is too strict; the
  next reflection should propose softening it.

## Why the loop is structured this way

The loop deliberately separates *capture* from *promotion*. Reflections
should be cheap — write them down without judgement. The judgement
happens later, with the benefit of recurrence. A single failure isn't
enough evidence to add a constraint; two related failures often is.

This is also why the GC rule fires weekly rather than on every
reflection. Reflection-time pattern matching would over-promote
(every surprise becomes a constraint). Aggregated weekly review
catches genuine recurrence.

## Where this fits in the lifecycle

This loop is one of the contributors to the "drifted → in sync"
transition described in [The Harness Lifecycle](the-harness-lifecycle.md).
A recurring pattern is a kind of drift between *what should be
constrained* and *what is constrained*. `/harness-constrain` is the
remediation; the GC rule and `/harness-sync` are the detection.

## Related reading

- [The Harness Lifecycle](the-harness-lifecycle.md) — the broader
  detect-heal-pull frame.
- [The Self-Improving Harness](self-improving-harness.md) — why
  iteration matters and how compound learning fits in.
- [How to: write a governance constraint](../how-to/write-a-governance-constraint.md)
  — the deeper case for governance-flavoured constraints.
- [How to: add a constraint](../how-to/add-a-constraint.md) — the
  step-by-step for `/harness-constrain`.
````

- [ ] **Step 3: Run markdownlint**

Run: `npx markdownlint-cli2 docs/plugins/ai-literacy-superpowers/explanation/the-harness-tuning-loop.md`

Expected: no warnings.

- [ ] **Step 4: Commit**

```bash
git add docs/plugins/ai-literacy-superpowers/explanation/the-harness-tuning-loop.md
git commit -m "docs(explanation): refocus the-harness-tuning-loop on its sub-flow

The page no longer tries to cover the broader lifecycle (that lives
in the-harness-lifecycle now). It focuses on the specific
signal-capture → constraint-promotion sub-flow:

  1. Capture — write the reflection
  2. Detect — let the GC rule find recurring patterns
  3. Promote — author the constraint via /harness-constrain
  4. Verify — let the constraint catch real violations

The 'Why the loop is structured this way' section explains the
deliberate separation between cheap reflection capture and aggregated
weekly promotion."
```

---

## Task 6: Trim `self-improving-harness.md` to conceptual core

**Files:**
- Modify: `docs/plugins/ai-literacy-superpowers/explanation/self-improving-harness.md` (full body rewrite)

The current page (262 lines) mixes conceptual content about *why* a harness must self-improve with command-level walkthroughs that duplicate how-to pages. The trim removes the duplicated walkthroughs and focuses the page on the conceptual core.

- [ ] **Step 1: Read the current file**

Run: `cat docs/plugins/ai-literacy-superpowers/explanation/self-improving-harness.md` to see the existing structure.

- [ ] **Step 2: Replace the body (everything below the frontmatter)**

Preserve the existing frontmatter. Replace the body with:

````markdown
# The Self-Improving Harness

> A harness that doesn't evolve becomes a museum exhibit. The
> conventions that worked last quarter may not work this quarter.
> The constraints that mattered when the team was small may be
> ceremony when the team is large. The harness has to keep up — and
> the cheapest way to do that is to make every session a contribution.

## Why iteration matters

The conventions captured in HARNESS.md were correct *when they were
written*. The codebase changes; the team changes; tooling changes;
expectations change. Without a path for the harness to evolve in
response, three failure modes appear:

- **Drift** — what's enforced no longer matches what should be enforced.
  Either too strict (ceremony) or too lax (escape hatches). Either
  way, trust in the harness erodes.
- **Calcification** — the team stops pushing back on bad rules
  because the rules are "what we do." Conventions become identity
  rather than judgement.
- **Stagnation** — patterns the team has actually learned in the
  trenches never make it into the harness, because no one writes
  them down. Knowledge stays in heads.

The cure is to make every session a chance for the harness to
update.

## How sessions become contributions

The plugin shapes sessions so that lessons accumulate without
requiring a separate "process":

- **`/reflect`** captures one session's surprise, classified by
  signal (`failure`, `workflow`, `context`, `none`). Cheap to write,
  cheap to merge via PR.
- **`REFLECTION_LOG.md`** is the running journal. Most entries stay
  there forever as historical record.
- **The `Reflection-driven regression detection` GC rule** fires
  weekly to find recurring patterns — the signal that a one-off
  surprise has become a class of surprise.
- **`/harness-sync`** surfaces those recurring patterns in its drift
  table as `[manual]` candidate-constraint rows.
- **`/harness-constrain`** authors the new constraint when the
  pattern warrants it.
- **`AGENTS.md`** is the curated subset — the lessons the team has
  decided are part of the project's identity, not just the log.

Every session contributes raw material. The aggregating mechanisms
(GC rule, sync, constrain) turn that into structured, enforced
knowledge over time.

## The compound-learning principle

Two ideas underlie this:

**Lessons compound.** A team that captures lessons consistently is
strictly better off than a team that doesn't, regardless of which
specific lessons. The activation cost of `/reflect` (write three
lines) is low enough that it's worth doing for every session — the
compound effect over a year of sessions is large.

**Curation is human.** The plugin captures aggressively (every
reflection is appended) but promotes conservatively (only patterns
recurring twice or more become constraints, only after the GC rule
finds them, only after a human runs `/harness-constrain`). This
asymmetry is deliberate. False captures cost nothing; false promotions
add ceremony. The harness errs on the side of capturing too much and
promoting too little.

## What "self-improving" actually means

It does not mean the harness rewrites itself autonomously. Every
mutation is human-initiated:

- A reflection is written by a human (or by an agent the human
  reviews).
- A constraint is promoted by a human running `/harness-constrain`.
- A template upgrade is accepted by a human running `/harness-upgrade`.

It means the harness has the *machinery* for evolution wired in: the
journal, the recurrence detector, the promotion path, the curation
target. Without that machinery, evolution requires a separate
discipline that can be skipped under pressure. With it, evolution is
a side effect of normal work.

## Where this fits in the lifecycle

The self-improving aspect is the long-arc view of the
"drifted → in sync" transition described in
[The Harness Lifecycle](the-harness-lifecycle.md). What looks like
drift in one session is signal for the next session's improvement.

## Related reading

- [The Harness Lifecycle](the-harness-lifecycle.md) — the everyday
  three-state model.
- [The Harness Tuning Loop](the-harness-tuning-loop.md) — the focused
  signal-capture → constraint-promotion sub-flow.
- [Compound Learning](compound-learning.md) — the deeper conceptual
  background on why lessons compound.
````

- [ ] **Step 3: Run markdownlint**

Run: `npx markdownlint-cli2 docs/plugins/ai-literacy-superpowers/explanation/self-improving-harness.md`

Expected: no warnings.

- [ ] **Step 4: Commit**

```bash
git add docs/plugins/ai-literacy-superpowers/explanation/self-improving-harness.md
git commit -m "docs(explanation): trim self-improving-harness to conceptual core

Removes command-level walkthroughs that duplicated content in the
how-to pages. Keeps the conceptual content: why iteration matters
(drift, calcification, stagnation), how sessions become contributions
via the capture-aggregate-promote chain, the compound-learning
principle (capture aggressively, promote conservatively), and what
'self-improving' actually means (machinery for evolution, not
autonomous mutation)."
```

---

## Task 7: Rewrite `how-to/sync-harness.md` for new flow

**Files:**
- Modify: `docs/plugins/ai-literacy-superpowers/how-to/sync-harness.md` (full body rewrite)

- [ ] **Step 1: Read the current file**

Run: `cat docs/plugins/ai-literacy-superpowers/how-to/sync-harness.md` to see the existing structure.

- [ ] **Step 2: Replace the body (everything below the frontmatter)**

Preserve the existing frontmatter. Replace the body with:

````markdown
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
ONBOARDING.md                                  drifted     /harness-onboarding    [auto]
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
invokes the underlying primitive (`/convention-sync`,
`/harness-onboarding`, `/harness-health`, `/harness-audit`). For each
`[manual]` selection, it prints a "next step" line:

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
ONBOARDING.md                                  drifted     in sync ✓
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
offers to create `chore/sync-surfaces-YYYY-MM-DD` for you. The
trust-boundary pre-commit guard restricts what gets staged: only
`.cursor/rules/**`, `.github/copilot-instructions.md`,
`.windsurf/rules/**`, and `ONBOARDING.md` may be committed.
`HARNESS.md`, `AGENTS.md`, and `REFLECTION_LOG.md` are off-limits to
this command.

If a `[auto]` action mutates HARNESS.md (the Status section update
from `/harness-audit`, for example), that mutation lands as part of
the action's own flow and is committed separately by the action's
own logic. `/harness-sync`'s commit covers only the four push-direction
surfaces.

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
````

- [ ] **Step 3: Run markdownlint**

Run: `npx markdownlint-cli2 docs/plugins/ai-literacy-superpowers/how-to/sync-harness.md`

Expected: no warnings.

- [ ] **Step 4: Commit**

```bash
git add docs/plugins/ai-literacy-superpowers/how-to/sync-harness.md
git commit -m "docs(how-to): rewrite sync-harness for the audit-driven flow

Documents the new /harness-sync behaviour: unified drift table from
the shared audit-engine, [auto] vs [manual] action column, multi-select
prompt with [auto] items pre-selected and [manual] items opt-in,
verification scan, --check dry-run mode, trust-boundary preservation,
and pointers to /harness-upgrade and /harness-constrain when sync
can't auto-fix."
```

---

## Task 8: Update `how-to/run-a-harness-audit.md` for diagnostic role

**Files:**
- Modify: `docs/plugins/ai-literacy-superpowers/how-to/run-a-harness-audit.md`

The page already documents `/harness-audit`. The update positions it as the read-only diagnostic alternative to `/harness-sync` and routes everyday users to sync.

- [ ] **Step 1: Read the current file**

Run: `cat docs/plugins/ai-literacy-superpowers/how-to/run-a-harness-audit.md` to see the existing structure.

- [ ] **Step 2: Add a "When to use audit vs sync" section near the top**

Find the first H2 heading after the page's introductory paragraph (likely `## When to run it` or similar). Immediately above that H2, insert:

```markdown
## Audit vs `/harness-sync`

`/harness-audit` and `/harness-sync` use the same drift-detection
engine. The difference is action:

- **`/harness-audit`** is read-only. It prints findings and updates
  the `HARNESS.md` Status section. It never prompts you to fix
  anything. Useful when you want a clean diagnostic without
  committing to action — for example from CI, or when scripting,
  or when you suspect drift but aren't ready to deal with it yet.
- **`/harness-sync`** runs the same engine but prompts you to apply
  fixes. Mechanical fixes (convention files, ONBOARDING.md, snapshot,
  Status section) auto-apply when selected. Judgement-required fixes
  (template upgrade, constraint authoring) print suggested commands.

**For everyday lifecycle hygiene, run `/harness-sync`.** Run
`/harness-audit` when you specifically want the diagnostic without
the action prompt.

```

- [ ] **Step 3: Update the page's opening paragraph if it overstates audit's role**

If the page's intro says something like "audit is the everyday command for harness hygiene" or treats audit as the primary lifecycle entry, soften it. The intro should now position audit as a diagnostic tool that shares its engine with `/harness-sync`.

A suggested opening (replace the first paragraph after the H1 heading if one exists):

```markdown
> `/harness-audit` is the read-only diagnostic. It runs the shared
> drift-detection engine across every surface and prints findings,
> without prompting you to fix anything. Use it when you want
> visibility without action. For everyday hygiene, prefer
> [`/harness-sync`](sync-harness.md), which uses the same engine and
> applies fixes.

```

- [ ] **Step 4: Run markdownlint**

Run: `npx markdownlint-cli2 docs/plugins/ai-literacy-superpowers/how-to/run-a-harness-audit.md`

Expected: no warnings.

- [ ] **Step 5: Commit**

```bash
git add docs/plugins/ai-literacy-superpowers/how-to/run-a-harness-audit.md
git commit -m "docs(how-to): clarify /harness-audit as diagnostic role

Adds an 'Audit vs /harness-sync' section that explains the two
commands share an engine. /harness-audit is read-only inspection;
/harness-sync uses the same engine and applies fixes.

Routes everyday users to /harness-sync for lifecycle hygiene; keeps
/harness-audit positioned for diagnostic use cases (CI, scripting,
inspection-without-commitment)."
```

---

## Task 9: Touch-up tutorials (`getting-started.md` and `first-time-tour.md`)

**Files:**
- Modify: `docs/plugins/ai-literacy-superpowers/tutorials/getting-started.md`
- Modify: `docs/plugins/ai-literacy-superpowers/tutorials/first-time-tour.md`

Both tutorials currently mention various harness commands. The touch-up positions `/harness-sync` as the everyday command in any lifecycle-related section.

- [ ] **Step 1: Search both files for current command references**

Run: `grep -n "harness-audit\|harness-sync\|convention-sync\|harness-onboarding" docs/plugins/ai-literacy-superpowers/tutorials/getting-started.md docs/plugins/ai-literacy-superpowers/tutorials/first-time-tour.md`

Look at the surrounding context for each match.

- [ ] **Step 2: For each occurrence where the tutorial walks through "what to run periodically" or "after editing HARNESS.md", prefer `/harness-sync`**

Replacement patterns:

- "Run `/convention-sync` to push HARNESS.md to the AI tool rule files" → "Run `/harness-sync` to bring every surface into alignment with HARNESS.md (`/convention-sync` is one of the primitives it composes)"
- "Run `/harness-audit` to see if anything has drifted" → "Run `/harness-sync` to see drift across every surface and apply the fixes you select; or `/harness-audit` for the read-only diagnostic"
- Bare lists of "/convention-sync; /harness-onboarding; /harness-audit" as periodic actions → replace with "/harness-sync (everyday); /harness-audit (diagnostic only)"

Apply these edits where they fit naturally; don't force the substitution if the surrounding tutorial text is doing something specific.

- [ ] **Step 3: Run markdownlint**

Run: `npx markdownlint-cli2 docs/plugins/ai-literacy-superpowers/tutorials/getting-started.md docs/plugins/ai-literacy-superpowers/tutorials/first-time-tour.md`

Expected: no warnings.

- [ ] **Step 4: Commit**

```bash
git add docs/plugins/ai-literacy-superpowers/tutorials/getting-started.md docs/plugins/ai-literacy-superpowers/tutorials/first-time-tour.md
git commit -m "docs(tutorials): position /harness-sync as the everyday command

Updates getting-started.md and first-time-tour.md to mention
/harness-sync where the tutorials previously listed individual
primitives (/convention-sync, /harness-onboarding) or treated
/harness-audit as the everyday entry. /harness-audit is mentioned
as the diagnostic alternative."
```

---

## Task 10: Touch-up plugin landing page

**Files:**
- Modify: `docs/plugins/ai-literacy-superpowers/index.md`

The plugin landing currently has a "Where to start" section with quadrant links. The touch-up adds a one-line mention that `/harness-sync` is the everyday lifecycle command, in the appropriate section of the landing.

- [ ] **Step 1: Read the current file**

Run: `cat docs/plugins/ai-literacy-superpowers/index.md`

- [ ] **Step 2: Locate the "Where to start" or equivalent section**

There should be a table or section listing the quadrants. If there's a paragraph that introduces the everyday workflow, add a sentence near the bottom of that paragraph (or just below the quadrant table):

```markdown
The everyday lifecycle entry is `/harness-sync` — it detects drift
across every surface and applies the fixes you select. See
[The Harness Lifecycle](explanation/the-harness-lifecycle.md) for the
broader frame.
```

If there isn't a natural spot, add the sentence just above the
"Where to start" table.

- [ ] **Step 3: Run markdownlint**

Run: `npx markdownlint-cli2 docs/plugins/ai-literacy-superpowers/index.md`

Expected: no warnings.

- [ ] **Step 4: Commit**

```bash
git add docs/plugins/ai-literacy-superpowers/index.md
git commit -m "docs(landing): mention /harness-sync as everyday lifecycle entry

Adds a one-line pointer to /harness-sync and a link to the lifecycle
explanation page on the plugin's landing page."
```

---

## Task 11: Update CLAUDE.md (root + template) Operations sections

**Files:**
- Modify: `CLAUDE.md` (root)
- Modify: `ai-literacy-superpowers/templates/CLAUDE.md`

Both CLAUDE.md files have "Quarterly Operations" and "Monthly Operations" sections that list specific commands to run. Where these list ad-hoc combinations of `/convention-sync` + `/harness-onboarding` (or similar push-surface commands), replace with `/harness-sync`. Keep the cadence anchors (`/governance-audit`, `/cost-capture`, `/assess`, `/harness-audit`).

- [ ] **Step 1: Search for the Operations sections**

Run: `grep -n "Operations\|/harness-sync\|/convention-sync\|/harness-onboarding\|/harness-audit" CLAUDE.md ai-literacy-superpowers/templates/CLAUDE.md | head -30`

- [ ] **Step 2: Update the Quarterly Operations section in both files**

Find the section that currently reads roughly:

```markdown
## Quarterly Operations

Aligned cadence (every 90 days, anchored to `/governance-audit`):

1. `/governance-audit` — full governance review
2. `/cost-capture` — capture spend snapshot from provider dashboards
3. `/assess` — AI literacy re-assessment

Run as a single sitting; one quarterly working block, not three scattered
tasks.
```

Replace with the same content (it's already correct — the quarterly anchors don't include the surface-sync commands). If the file has additional bullets that mention `/convention-sync` or `/harness-onboarding`, swap those for `/harness-sync`.

- [ ] **Step 3: Update the Monthly Operations section in both files**

Find the section that reads roughly:

```markdown
## Monthly Operations

Light-touch health check (every 30 days, between quarterly anchor weeks):

1. `/governance-health` — governance constraint health snapshot
2. Reflection review — scan `REFLECTION_LOG.md` for new entries worth
   promoting to `AGENTS.md`
```

Add a third bullet for the everyday lifecycle entry:

```markdown
3. `/harness-sync` — bring every push-direction surface into alignment
   with HARNESS.md (convention files, ONBOARDING.md, snapshot, Status
   section). Surfaces template drift and recurring reflection patterns
   as `[manual]` items for follow-up.
```

If the existing Monthly Operations section already has surface-related items, integrate `/harness-sync` and remove individual `/convention-sync` / `/harness-onboarding` mentions in favour of the unified entry.

- [ ] **Step 4: Run markdownlint**

Run: `npx markdownlint-cli2 CLAUDE.md ai-literacy-superpowers/templates/CLAUDE.md`

Expected: no warnings.

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md ai-literacy-superpowers/templates/CLAUDE.md
git commit -m "docs(claude.md): /harness-sync is the everyday lifecycle entry

Updates Monthly Operations sections in both CLAUDE.md (root) and
templates/CLAUDE.md to list /harness-sync as the everyday
lifecycle hygiene step. Quarterly Operations cadence anchors are
unchanged.

Lands in both root and shipped template so projects running
/superpowers-init pick up the corrected guidance."
```

---

## Task 12: Update README

**Files:**
- Modify: `README.md`

The README has a Commands table that describes each lifecycle command. Update `/harness-sync`'s description to reflect the audit-driven flow; update `/harness-audit`'s description to clarify its diagnostic role.

- [ ] **Step 1: Search for the Commands table**

Run: `grep -nE "^\| ./harness-(sync|audit)" README.md`

This should locate the rows for `/harness-sync` and `/harness-audit` in the Commands table.

- [ ] **Step 2: Update the `/harness-sync` row**

Find the row currently reading approximately:

```markdown
| `/harness-sync` | Multi-surface entry point — detects drift across convention files and ONBOARDING.md, applies fixes via the underlying primitives in one interactive pass |
```

Replace with:

```markdown
| `/harness-sync` | Everyday lifecycle entry. Runs the shared audit-engine to detect drift across every surface (convention files, ONBOARDING.md, snapshot, Status section, template, constraint regressions, recurring reflection patterns), presents a unified drift table tagged `[auto]`/`[manual]`, and applies the fixes you select. Mechanical fixes auto-apply via existing primitives; judgement-required fixes print suggested commands. |
```

- [ ] **Step 3: Update the `/harness-audit` row**

Find the row currently reading approximately:

```markdown
| `/harness-audit` | Full meta-verification of the harness |
```

Replace with:

```markdown
| `/harness-audit` | Read-only diagnostic. Same engine as `/harness-sync` but prints findings without prompting to fix. Use for inspection-without-commitment, CI scripts, or the quarterly cadence anchor. |
```

- [ ] **Step 4: Run markdownlint**

Run: `npx markdownlint-cli2 README.md`

Expected: no warnings.

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "docs(readme): update /harness-sync and /harness-audit descriptions

The Commands table now reflects the audit-driven /harness-sync and
the read-only diagnostic role of /harness-audit. Both descriptions
emphasise that they share an engine."
```

---

## Task 13: Bump plugin version 0.34.1 → 0.35.0

**Files:**
- Modify: `ai-literacy-superpowers/.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `README.md`
- Modify: `CHANGELOG.md`

Minor bump because `/harness-sync`'s behaviour materially changes.

- [ ] **Step 1: Bump `plugin.json`**

In `ai-literacy-superpowers/.claude-plugin/plugin.json`, change the `"version"` field from `"0.34.1"` to `"0.35.0"`.

- [ ] **Step 2: Bump `marketplace.json`**

In `.claude-plugin/marketplace.json`, change BOTH the top-level `"plugin_version"` and the entry inside the `plugins` array (the one with `"name": "ai-literacy-superpowers"`) from `"0.34.1"` to `"0.35.0"`.

- [ ] **Step 3: Update README badge and marketplace plugin row**

In `README.md`, update the `ai-literacy-superpowers` badge URL from `v0.34.1` to `v0.35.0`.

Also update the marketplace plugin table row's version cell (the `| ai-literacy-superpowers | v0.34.1 |` row) from `v0.34.1` to `v0.35.0`.

- [ ] **Step 4: Add the new CHANGELOG section**

In `CHANGELOG.md`, insert a new top heading immediately above the existing top heading. Today's date is `2026-05-08`.

```markdown
## 0.35.0 — 2026-05-08

### Feature — Audit-driven `/harness-sync`

Restructures `/harness-sync` so it runs `/harness-audit`'s detection
logic internally via a new shared `harness-audit-engine` skill. The
unified drift table now includes every audit finding tagged `[auto]`
or `[manual]`. Mechanical fixes (convention files, ONBOARDING.md,
snapshot regen via `/harness-health`, HARNESS.md Status section regen
via `/harness-audit`) auto-apply when selected. Judgement-required
fixes (`/harness-upgrade`, `/harness-constrain`) print the suggested
command without writing — preserving the trust boundary.

`/harness-audit` keeps its standalone diagnostic role unchanged. Both
commands now share the same engine; surface coverage evolves in one
place.

### Docs — Lifecycle simplification

Three explanation pages are rewritten to converge on a single
canonical narrative:

- `the-harness-lifecycle` is now the everyday three-state model
  (in sync, drifted, behind upstream) with `/harness-sync`,
  `/harness-upgrade`, and `/harness-constrain` as the everyday entry
  points.
- `the-harness-tuning-loop` refocuses on the signal-capture →
  constraint-promotion sub-flow specifically.
- `self-improving-harness` trims to the conceptual core (why
  iteration matters, the compound-learning principle).

How-to pages for sync-harness and run-a-harness-audit are updated
to reflect the audit-driven flow and the diagnostic-vs-everyday split.
Touch-ups across tutorials, plugin landing, CLAUDE.md (root +
template), and README align command descriptions.

### Internal

- New skill: `harness-audit-engine` documents the shared
  drift-detection contract.
```

The existing `## 0.34.1 — 2026-05-08` heading stays unchanged below.

- [ ] **Step 5: Verify the version locations agree**

Run:

```bash
echo "plugin.json: $(jq -r .version ai-literacy-superpowers/.claude-plugin/plugin.json)"
echo "marketplace.json plugin_version: $(jq -r .plugin_version .claude-plugin/marketplace.json)"
echo "marketplace.json plugins[0].version: $(jq -r '.plugins[0].version' .claude-plugin/marketplace.json)"
echo "README badge: $(grep -oE 'ai--literacy--superpowers-v[0-9]+\.[0-9]+\.[0-9]+' README.md | head -1)"
echo "README marketplace row: $(grep -E '\| \*\*\`ai-literacy-superpowers\`\*\* \| v' README.md | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
echo "CHANGELOG top: $(grep -m1 '^## ' CHANGELOG.md)"
```

Expected:

```text
plugin.json: 0.35.0
marketplace.json plugin_version: 0.35.0
marketplace.json plugins[0].version: 0.35.0
README badge: ai--literacy--superpowers-v0.35.0
README marketplace row: v0.35.0
CHANGELOG top: ## 0.35.0 — 2026-05-08
```

- [ ] **Step 6: Run markdownlint**

Run: `npx markdownlint-cli2 README.md CHANGELOG.md`

Expected: no warnings.

- [ ] **Step 7: Commit**

```bash
git add ai-literacy-superpowers/.claude-plugin/plugin.json .claude-plugin/marketplace.json README.md CHANGELOG.md
git commit -m "chore: bump ai-literacy-superpowers to v0.35.0

Minor bump driven by the audit-driven /harness-sync rewrite. The
shared audit-engine skill is new (inside the plugin directory);
/harness-sync's command file changes meaningfully; templates/CLAUDE.md
documentation updates land for new projects.

Marketplace plugin_version, marketplace plugin entry version, README
badge, and README marketplace plugin row all bumped together. New
CHANGELOG section explains the feature and docs simplification."
```

---

## Task 14: Local mkdocs build verification

**Files:**
- No file changes — this is verification only

- [ ] **Step 1: Build the site locally**

Run:

```bash
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
rm -rf site _site
mkdocs build --strict
```

Expected: `Documentation built in N.NN seconds` with no `WARNING` lines (INFO lines about pre-existing anchor mismatches are acceptable).

- [ ] **Step 2: Spot-check the rewritten pages render**

Open or curl-grep `site/plugins/ai-literacy-superpowers/explanation/the-harness-lifecycle/index.html` and confirm:

```bash
grep -oE '<h[12][^>]*>[^<]+' site/plugins/ai-literacy-superpowers/explanation/the-harness-lifecycle/index.html | head -8
```

Expected: H1 "The Harness Lifecycle" plus the new H2 headings ("The three states a harness is ever in", "The everyday entry points", etc.).

Repeat the check for the other rewritten pages:

- `site/plugins/ai-literacy-superpowers/explanation/the-harness-tuning-loop/index.html`
- `site/plugins/ai-literacy-superpowers/explanation/self-improving-harness/index.html`
- `site/plugins/ai-literacy-superpowers/how-to/sync-harness/index.html`
- `site/plugins/ai-literacy-superpowers/how-to/run-a-harness-audit/index.html`

- [ ] **Step 3: No commit (verification only)**

This task produces no file changes.

---

## Task 15: Open the chore PR and watch CI

- [ ] **Step 1: Confirm the working tree is clean and pushed**

Run:

```bash
git status
git log --oneline origin/main..HEAD
```

Expected: clean working tree; the commit list shows the 13 commits from Tasks 1–13 (Task 14 produced no commits).

- [ ] **Step 2: Push the branch**

Run:

```bash
git push -u origin chore/harness-sync-audit-driven
```

- [ ] **Step 3: Open the PR with the chore label**

Run:

```bash
gh pr create --label chore \
  --title "chore: audit-driven /harness-sync and lifecycle docs simplification" \
  --body "$(cat <<'EOF'
## Summary

Rewires \`/harness-sync\` so it runs \`/harness-audit\`'s detection logic
internally via a new shared \`harness-audit-engine\` skill. The drift
table now covers every audit finding tagged \`[auto]\` or \`[manual]\`.
\`/harness-audit\` stays as a callable read-only diagnostic with
unchanged user-facing behaviour.

Includes a docs simplification pass: rewrites the-harness-lifecycle,
the-harness-tuning-loop, and self-improving-harness as the canonical
narrative; updates how-to pages for sync-harness and run-a-harness-audit;
touch-ups across tutorials, plugin landing, CLAUDE.md (root +
template), and README.

[Spec](docs/superpowers/specs/2026-05-08-harness-sync-audit-driven-design.md) ·
[Plan](docs/superpowers/plans/2026-05-08-harness-sync-audit-driven.md)

## What's in this PR

- New skill \`ai-literacy-superpowers/skills/harness-audit-engine/SKILL.md\`
  documents the shared drift-detection contract.
- \`/harness-sync\` and \`/harness-audit\` command files reference the
  new skill. \`/harness-sync\`'s Process section is rewritten to call the
  engine in Phase 1, build a unified drift table in Phase 1 with
  \`[auto]\`/\`[manual]\` tags, and branch the apply step in Phase 3.
- Three explanation page rewrites: \`the-harness-lifecycle\` becomes
  the canonical narrative, \`the-harness-tuning-loop\` trims to the
  signal-capture sub-flow, \`self-improving-harness\` trims to the
  conceptual core.
- How-to rewrites: \`sync-harness.md\` documents the new flow;
  \`run-a-harness-audit.md\` clarifies the diagnostic role.
- Touch-ups: tutorials (\`getting-started\`, \`first-time-tour\`),
  plugin \`index.md\`, CLAUDE.md (root + template) Operations
  sections, README Commands table.
- Plugin version bump 0.34.1 → 0.35.0 with marketplace.json,
  README badge + marketplace row, and CHANGELOG entry.

## Why chore label

Per AGENTS.md STYLE on reflection-driven amendments: implementation
is conservatively bounded (single PR, 13 logical commits), version
bump is honest (minor — \`/harness-sync\` behaviour change), and the
work was brainstormed and specified in the linked spec.
\`/diaboli\` and \`/choice-cartograph\` adjudications skipped on the
same terms as the previous chore-labelled lifecycle PRs (#263, #265,
#266).

## Test plan

- [x] markdownlint clean across all touched files.
- [x] \`mkdocs build --strict\` succeeds locally with the rewritten docs.
- [ ] CI green (markdownlint x2, spec-first ordering, version
  consistency, Enforce PR constraints).
- [ ] Pages deploy succeeds on merge.
- [ ] Post-merge: run \`/harness-sync\` on the project itself; confirm
  the unified drift table renders and \`[auto]\`/\`[manual]\` tags
  appear correctly.
EOF
)"
```

- [ ] **Step 4: Watch CI**

Run: `gh pr checks $(gh pr view --json number -q .number) --watch`

Expected: all 5 checks (markdownlint x2, spec-first ordering, version consistency, Enforce PR constraints) pass.

- [ ] **Step 5: Hand off to the user for merge**

Once CI is green, report the PR URL. The user merges; this plan does not auto-merge. After merge:

1. Pages workflow rebuilds the docs site with the rewritten lifecycle pages.
2. Run `/harness-sync` on the project itself — first real-world exercise of the new flow.

---

## Self-Review

Verifying coverage against the spec sections:

- **Spec § 1 Summary**: Tasks 1–3 implement the audit-engine + /harness-sync rewrite + /harness-audit refactor. ✓
- **Spec § 2 Why**: Captured in the explanation page rewrites (Tasks 4–6). ✓
- **Spec § 3 Architecture**: Audit-engine skill (Task 1); both commands reference it (Tasks 2, 3). ✓
- **Spec § 4 Unified drift table**: Specified in Task 3 (the rewritten Phase 1 section). ✓
- **Spec § 5 Interactive flow**: Specified in Task 3 (Phases 1, 2, 3). ✓
- **Spec § 6 /harness-audit standalone**: Task 2 (engine reference only, no UX change). ✓
- **Spec § 7 Docs simplification**: Tasks 4–12 cover every page listed in the spec's docs table. ✓
- **Spec § 8 Out of scope**: Honoured — no command-count reduction, no convention-sync/harness-onboarding standalone changes, no GC rule additions, no trust-boundary changes, no marketplace listing changes. ✓
- **Spec § 9 Plan summary**: Tasks 1–15 mirror this with sufficient granularity. ✓
- **Spec § 10 Verification**: Tasks 14–15 cover the build verification, CI, and post-merge testing. ✓

Placeholder scan: clean. No "TBD", "TODO", "implement later", or vague requirements. Every step that mentions code shows the code.

Type/path consistency: every file path is referenced consistently. The new skill is `ai-literacy-superpowers/skills/harness-audit-engine/SKILL.md` everywhere; the audit-engine is referenced by both commands; the version bump targets all four locations together.

No issues found. Plan is ready.
