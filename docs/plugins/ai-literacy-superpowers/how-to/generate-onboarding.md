---
title: Generate an Onboarding Guide
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 36
redirect_from:
  - /how-to/generate-onboarding/
  - /how-to/generate-onboarding.html
---

# Generate an Onboarding Guide

`/harness-onboarding` is one of the underlying primitives that
[`/harness-sync`](sync-harness.md)
composes. **For multi-surface propagation in one interactive pass — across
`ONBOARDING.md` _and_ the Cursor / Copilot / Windsurf rule files — use
`/harness-sync`.** This page covers the focused single-surface command for when
you want to regenerate `ONBOARDING.md` alone (for example, when a new team
member joins and you want to refresh the onboarding document without touching
the rule files).

The command itself: produce a human-readable onboarding guide from your
project's harness state.

## Prerequisites

- HARNESS.md exists (created by `/harness-init`).
- AGENTS.md and REFLECTION_LOG.md are optional but recommended — they
  contribute the Common Pitfalls, Architecture Decisions, and How We
  Test sections. If missing, those sections are skipped.

---

## 1. Run the command

```text
/harness-onboarding
```

The command reads three files — HARNESS.md, AGENTS.md, and
REFLECTION_LOG.md — and synthesises them into `ONBOARDING.md` at the
project root.

---

## 2. Review the generated guide

The output covers 10 sections:

1. **Welcome** — what the project is and what to expect
2. **Tech Stack** — from HARNESS.md Context > Stack
3. **How We Write Code** — from HARNESS.md Context > Conventions
4. **What's Enforced** — constraints grouped by when they fire
   (commit time, PR time, scheduled)
5. **Common Pitfalls** — from AGENTS.md GOTCHAS and recent
   REFLECTION_LOG entries
6. **Architecture Decisions** — from AGENTS.md ARCH_DECISIONS
7. **How We Test** — from AGENTS.md TEST_STRATEGY
8. **How the Harness Works** — the three enforcement loops and
   observability cadence
9. **Your First PR Checklist** — a pre-flight list synthesised
   from constraints and conventions
10. **Where to Learn More** — links to HARNESS.md, AGENTS.md,
    REFLECTION_LOG.md, and other key files

The command validates the output automatically, checking that all
sections are present and no placeholder markers remain.

---

## 3. Keep it current

A garbage collection rule (`Onboarding document staleness`) checks
monthly whether ONBOARDING.md is older than its three sources. When
it flags staleness, re-run:

```text
/harness-onboarding
```

The guide is regenerated from scratch — it is a projection of current
harness state, not a document that accumulates edits over time.

---

## What you have now

A friendly, practical onboarding guide that new team members can read
to understand how the project works, what's enforced, and what to
check before their first PR. The guide stays current because it is
regenerated from the same files the harness already maintains.

---

## Next steps

- Share `ONBOARDING.md` with new contributors joining the project.
- Run `/harness-audit` to verify constraints referenced in the guide.
- Run `/harness-health` to generate a fresh health snapshot.
