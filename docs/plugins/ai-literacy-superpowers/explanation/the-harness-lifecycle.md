---
title: The Harness Lifecycle
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 19
redirect_from:
  - /explanation/the-harness-lifecycle/
  - /explanation/the-harness-lifecycle.html
---

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
