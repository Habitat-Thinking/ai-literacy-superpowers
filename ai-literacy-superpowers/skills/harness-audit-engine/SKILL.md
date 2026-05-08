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
| Onboarding | `ONBOARDING.md` matches HARNESS.md + AGENTS.md + REFLECTION_LOG.md | manual — `/harness-onboarding` |
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
