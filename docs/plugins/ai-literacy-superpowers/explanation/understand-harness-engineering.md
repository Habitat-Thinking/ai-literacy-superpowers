---
title: Understand Harness Engineering
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 24
redirect_from:
  - /how-to/understand-harness-engineering/
  - /how-to/understand-harness-engineering.html
---

# Understand Harness Engineering

Apply the harness engineering framework to your project — understand the
three components, set up the living harness document, and harden
constraints over time.

---

## 1. Understand the three components

A harness is the combined set of deterministic tooling and LLM-based
agents that keeps AI-generated code trustworthy and maintainable. Three
components form a complete harness:

**Context engineering** — the knowledge an LLM needs to work effectively
in your codebase. This includes explicit documentation (conventions,
constraints, stack declarations) and implicit context (the code design
itself). In this plugin, context engineering lives in HARNESS.md's
Context section.

**Architectural constraints** — rules that must be enforced, not
suggestions. Each constraint is backed by a verification slot that can be
filled by a deterministic tool (linter, formatter, structural test) or an
agent-based review. Constraints live in HARNESS.md's Constraints section
and are enforced at three timescales.

**Garbage collection** — periodic checks that fight entropy. Documentation
goes stale, conventions erode, dead code accumulates. GC agents run on a
schedule to find and fix these issues. GC rules live in HARNESS.md's
Garbage Collection section.

---

## 2. Initialise the harness

If your project does not yet have a `HARNESS.md`, run:

```bash
/harness-init
```

This creates a `HARNESS.md` with starter sections for Context,
Constraints, and Garbage Collection. It also installs the pre-commit hook
and sets up the CI workflow step if you confirm those options.

---

## 3. Add context to HARNESS.md

Open `HARNESS.md` and fill in the Context section. Useful entries:

- Stack declaration (language, framework, key libraries)
- Conventions that AI tools should follow
- Constraints that govern code structure
- Any project-specific knowledge that shapes how code should be written

The more precise the context, the more accurate AI-generated code will be.

---

## 4. Understand the constraint promotion ladder

Constraints follow a three-stage promotion ladder:

| Stage | Meaning |
| --- | --- |
| `unverified` | Declared intent — no automation yet |
| `agent` | LLM-based review against the constraint's prose rule |
| `deterministic` | Tool-backed enforcement (linter, formatter, test) |

Start by declaring what should be true. Automate when you are ready. The
harness improves over time without restructuring.

To add a new constraint through the guided flow:

```bash
/harness-constrain
```

---

## 5. Understand the three enforcement loops

Constraints are checked at three timescales — inner, middle, and outer:

| Loop | Trigger | Strictness | Purpose |
| --- | --- | --- | --- |
| Inner | PreToolUse hook | Advisory | Catch issues while context is fresh |
| Middle | CI on PR | Strict | Prevent violations reaching main |
| Outer | Scheduled GC + audit | Investigative | Fight slow entropy |

The inner loop gives fast feedback without blocking. The middle loop
blocks merges on violations. The outer loop catches slow drift that neither
hook nor PR gate sees.

---

## 6. Check harness health

Run the health command to see the current state of every constraint:

```bash
/harness-status
```

This shows each constraint's enforcement type, last verification result,
and whether it is active in the hook and CI layers.

For a deeper audit — including running every deterministic tool and
reporting which constraints are drifting from their declared state:

```bash
/harness-audit
```

---

## 7. Run garbage collection

GC checks run on a schedule to catch entropy that accumulates between
PRs. To run them manually:

```bash
/harness-gc
```

The GC agent reads every rule in HARNESS.md's Garbage Collection section
and reports findings. Common GC rules include stale documentation checks,
dead code detection, and dependency freshness checks.

---

## 8. Understand the living harness principle

HARNESS.md is a living document — it declares what should be true and
the plugin's agents check whether it is true. The Status section reflects
the gap between declared and actual enforcement.

When the Status section shows drift, the team knows where to invest next.
This self-referential loop is the central design principle: the harness
is harnessed by its own document.

---

## Summary

After completing these steps you have:

- A `HARNESS.md` with Context, Constraints, and GC sections
- An understanding of the three-component harness model
- Constraints on the promotion ladder, hardening over time
- Three enforcement loops active at commit, PR, and schedule timescales
- Harness health visible via `/harness-status` and `/harness-audit`
