---
title: Decide Whether to Use a Dynamic Workflow
---
# Decide Whether to Use a Dynamic Workflow

Orientation guide to the `dynamic-workflows` skill — the conceptual model
for self-authored, ephemeral multi-agent harnesses. This guide helps you
decide *whether* a task warrants a workflow and *which* pattern fits.

> **Scope note.** This first release ships **reading material**, not a
> runnable workflow you can invoke. The opinionated, adaptable workflow
> *templates* arrive in a follow-up slice (S2). Until then, use this guide
> and the skill to reason about workflows; there is no end-to-end runbook
> to walk through yet.
>
> **Runtime scope — Claude Code only.** Dynamic workflows are a Claude Code
> runtime capability and are **not transferable** to GitHub Copilot CLI or
> other coding agents. On a tree without the workflow runtime this skill is
> guidance only — readable knowledge, but no workflow can be spawned.

---

## Prerequisites

- The `ai-literacy-superpowers` plugin installed.
- Familiarity with the static pipeline (`spec-writer → GATE → tdd-agent →
  implementer → code-reviewer → GUARDRAIL → integration-agent`), which
  remains the default for ordinary coding tasks.

---

## 1. Read the skill

The `dynamic-workflows` skill is knowledge you read, not a script you run.
It names the six composable patterns, the election rubric, and the two
governance invariants. Its references are:

- `references/patterns.md` — the six patterns with worked micro-examples.
- `references/when-not-to-use.md` — the four-question election rubric.
- `references/governance.md` — INV-1 and INV-2 in full.

---

## 2. Run the election rubric

Before reaching for a workflow, ask whether the task is any of:

1. **Long-running** — would one context drift or run out of room?
2. **Massively parallel** — does it split into many independent units?
3. **Highly structured** — does it have clear, isolable pipeline stages?
4. **Adversarial** — does it benefit from a separate agent refuting the
   result?

**If none apply, use the static pipeline.** A routine single-file change
does not warrant a panel of subagents — electing one anyway is
over-orchestration.

---

## 3. Pick the matching pattern

If the task is a workflow candidate, choose from `references/patterns.md`:
classify-and-act, fan-out-and-synthesize, adversarial verification,
generate-and-filter, tournament, or loop-until-done. Real workflows
compose several.

---

## 4. Respect the invariants

Two non-negotiable rules bind every workflow:

- **INV-1 — Ephemeral proposes, durable curates.** A workflow may
  **propose** changes to `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, and
  `MODEL_ROUTING.md`, but never write them directly. Discoveries flow
  through `REFLECTION_LOG.md → human curates → AGENTS.md`.
- **INV-2 — Quarantine.** An agent that reads untrusted content (web
  pages, external issues, third-party PRs) is withheld high-privilege
  tools; a separate trusted agent acts on what it found.

---

## 5. Set a budget

Elected workflows declare an explicit per-workflow token cap and model
tiering up front — see the *workflow election* section of your project's
`MODEL_ROUTING.md`.

---

## Related

- Reference: [Skills](../reference/skills.md) → `dynamic-workflows`
- Skill: `ai-literacy-superpowers/skills/dynamic-workflows/SKILL.md`
