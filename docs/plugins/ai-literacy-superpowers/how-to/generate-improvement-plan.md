---
title: Generate an Improvement Plan
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 21
redirect_from:
  - /how-to/generate-improvement-plan/
  - /how-to/generate-improvement-plan.html
---

# Generate an Improvement Plan

Generate a prioritised improvement plan from assessment gaps and work
through it item by item, accepting, skipping, or deferring each action.

---

## 1. Run an assessment first (if you haven't already)

The improvement plan works best when it has an existing assessment to draw
gaps from. If you haven't assessed the repository yet:

```bash
/assess
```

The assessment identifies your current level (L0–L5) and lists specific
gaps. The improvement skill uses these gaps to filter the plan to only
what is actually missing.

If you already know your level, you can skip the assessment and invoke
the improvement skill directly.

---

## 2. Start the improvement plan

The improvement skill is invoked automatically at the end of `/assess`.
To run it standalone:

```bash
/literacy-improvements
```

If invoked standalone, the skill asks for your current level:

```text
What is your current AI literacy level?

1. Level 0 — Awareness
2. Level 1 — Prompting
3. Level 2 — Verification
4. Level 3 — Habitat Engineering
5. Level 4 — Specification Architecture
```

---

## 3. Choose a target level

The skill presents the levels above your current one:

```text
You're currently at Level 2 (Verification).

How far would you like to improve?

1. Level 3 — Habitat Engineering (recommended next step)
2. Level 4 — Specification Architecture
3. Level 5 — Platform Engineering
```

The default recommendation is always the next level. Choosing a higher
target includes all intermediate levels — the plan works through each
level transition in order.

---

## 4. Work through the plan item by item

For each gap, the skill presents one item at a time with its priority and
recommended action:

```text
Improvement 1/6 (Level 2 → Level 3):
  Gap: No HARNESS.md
  Action: Run /harness-init
  Priority: High — foundational; nothing else at L3 works without it

  Accept / Skip / Defer?
```

Respond to each item:

- **Accept** — the command or skill runs immediately. Wait for it to
  complete before the next item appears.
- **Skip** — removes the item from the plan for this session.
- **Defer** — keeps the item in the plan but does not execute it now. The
  next assessment picks it up.

If an accepted command opens its own interactive flow (for example,
`/harness-init` asks which features to enable), let it run naturally. The
improvement plan resumes after the command completes.

---

## 5. Understand priority levels

| Priority | Criteria | Examples |
| --- | --- | --- |
| High | Foundational — other items depend on it | HARNESS.md for L3, CI pipeline for L2 |
| Medium | Closes a real gap independently | Secret scanning, GC rules |
| Low | Conditional on project context | Docker scanning when no Docker is used |

Work through High items first. Medium and Low items can be deferred if
resources are constrained.

---

## 6. Find the output document

After working through all items, the skill appends an Improvement Plan
section to today's assessment document if one exists:

```text
assessments/YYYY-MM-DD-assessment.md
```

If no assessment exists for today, it writes a standalone file:

```text
assessments/YYYY-MM-DD-improvements.md
```

The document records which improvements were accepted, skipped, or
deferred, and what commands ran.

---

## 7. Re-run after completing deferred items

Deferred items are not lost — they appear again at the next assessment.
When you have capacity to address them, re-run `/assess` or invoke
`/literacy-improvements` directly to resume the plan.

---

## Summary

After completing these steps you have:

- A prioritised list of improvements mapped to your specific gaps
- Commands executed for accepted improvements
- A record of accepted, skipped, and deferred items in the assessment
  document
- A clear target level and a path to reach it
