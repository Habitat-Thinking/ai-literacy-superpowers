---
title: Enforce Human Pace
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 26
redirect_from:
  - /how-to/enforce-human-pace/
  - /how-to/enforce-human-pace.html
---

# Enforce Human Pace

Add the Human Pace constraint and cadence drift GC rule to keep
AI-assisted development at a pace humans can review, understand,
and learn from.

---

## What is Human Pace?

Human Pace is a set of signals ensuring that AI-generated output
stays scoped to what a human can meaningfully review. It prevents
the failure mode where AI produces large, bundled PRs faster than
the team can absorb — eroding understanding and compounding
technical debt.

Two mechanisms enforce it:

1. **Spec-scoped changes constraint** — each feature or behaviour-change
   PR traces to a single spec. One concern per PR.
2. **Change cadence drift GC rule** — weekly check that PR size
   distribution and spec-to-merge cycle time haven't drifted upward.

---

## 1. Add the spec-scoped changes constraint

Run `/harness-constrain` and add:

```markdown
### Spec-scoped changes

- **Rule**: Each feature or behaviour-change PR should trace to a single
  spec. Bug fixes, dependency updates, and other maintenance changes do
  not require a spec but should still be coherently scoped — one concern
  per PR. PRs that bundle unrelated changes must be decomposed.
- **Enforcement**: agent
- **Tool**: harness-enforcer (reviews against The Human Pace)
- **Scope**: pr
```

Or use the HARNESS.md template from `/superpowers-init`, which includes
this constraint by default as of v0.9.3.

---

## 2. Add the change cadence drift GC rule

Run `/harness-gc` to add a new rule, or add directly to the Garbage
Collection section of HARNESS.md:

```markdown
### Change cadence drift

- **What it checks**: Whether PR size distribution (median lines
  changed) or spec-to-merge cycle time has increased over the past
  month, indicating the human pace is being lost to AI-speed production
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: harness-gc agent (analyses recent merged PRs via git log)
- **Auto-fix**: false
```

---

## 3. Assessment signals

The `/assess` command now recognises Human Pace signals at multiple
literacy levels:

| Level | Signal |
| --- | --- |
| 2 (Verification) | Small, TDD-paced diffs visible in commit history |
| 3 (Habitat Engineering) | Spec-scoped changes constraint in HARNESS.md; change cadence drift GC rule active |
| 4 (Specification Architecture) | Spec-to-PR mapping — each spec produces one PR |
| 5 (Sovereign Engineering) | Change cadence metrics reviewed as team health signal |

These signals are checked automatically during assessment and contribute
to the level score.

---

## When to use this

- After running `/superpowers-init` or `/harness-init` on a new project
- When the team notices PRs growing in size or scope
- When assessment reveals missing Human Pace signals
- When onboarding a team that is new to AI-assisted development
