---
title: ai-literacy-superpowers
---
# ai-literacy-superpowers

The flagship plugin in this marketplace — harness engineering, agent
orchestration, literate programming, CUPID code review, compound
learning, and the three enforcement loops.

The everyday lifecycle entry is `/harness-sync` — it detects drift
across every surface and applies the fixes you select. See
[The Harness Lifecycle](explanation/the-harness-lifecycle.md) for the
broader frame.

The plugin's source lives at [`ai-literacy-superpowers/`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/tree/main/ai-literacy-superpowers)
in the repository.

---

## Install

```bash
# Claude Code
claude plugin marketplace add Habitat-Thinking/ai-literacy-superpowers
claude plugin install ai-literacy-superpowers

# GitHub Copilot CLI
copilot plugin marketplace add Habitat-Thinking/ai-literacy-superpowers
copilot plugin install ai-literacy-superpowers@ai-literacy-superpowers
```

Then in any project:

```bash
/harness-init    # Set up a living harness
/harness-status  # Check enforcement health
```

`/harness-init` lets you select which features to configure — context
engineering, constraints, garbage collection, CI, and observability.
All are selected by default. Re-run at any time to add more; existing
configuration is preserved.

---

## Documentation

This documentation follows the
[Diataxis framework](https://diataxis.fr/). Use the section that
matches the kind of reading you're doing right now.

### Tutorials — learning-oriented

Start here if you're new to the plugin.

- [Getting Started](tutorials/getting-started.md)
- [First Time Tour](tutorials/first-time-tour.md)
- [Harness From Scratch](tutorials/harness-from-scratch.md)
- [Your First Skill](tutorials/your-first-skill.md)
- [Your First Assessment](tutorials/your-first-assessment.md)
- [Surfacing Tacit Knowledge](tutorials/surfacing-tacit-knowledge.md)
- [Governance for Your Harness](tutorials/governance-for-your-harness.md)
- [The Improvement Cycle](tutorials/the-improvement-cycle.md)
- [From Assessment to Dashboard](tutorials/from-assessment-to-dashboard.md)

### How-to guides — task-oriented

Practical guides for specific tasks.

#### Harness lifecycle

- [Add a Constraint](how-to/add-a-constraint.md)
- [Add Fitness Functions](how-to/add-fitness-functions.md)
- [Run a Harness Audit](how-to/run-a-harness-audit.md)
- [Run a Calibration Review](how-to/run-a-calibration-review.md)
- [Update the Plugin](how-to/update-the-plugin.md)
- [Upgrade Your Harness](how-to/upgrade-your-harness.md)
- [Understand Harness Engineering](explanation/understand-harness-engineering.md)

#### Assessment and portfolio

- [Run an Assessment](how-to/run-an-assessment.md)
- [Run Portfolio Assessment](how-to/run-portfolio-assessment.md)
- [Build Portfolio Dashboard](how-to/build-portfolio-dashboard.md)
- [Generate Improvement Plan](how-to/generate-improvement-plan.md)
- [Create Team API](how-to/create-team-api.md)

#### Governance

- [Write a Governance Constraint](how-to/write-a-governance-constraint.md)
- [Run a Governance Audit](how-to/run-a-governance-audit.md)
- [Check Governance Health](how-to/check-governance-health.md)
- [Build a Governance Dashboard](how-to/build-a-governance-dashboard.md)
- [Detect Semantic Drift](how-to/detect-semantic-drift.md)

#### Adversarial and decision-archaeology review

- [Review a Spec Adversarially](how-to/review-a-spec-adversarially.md)
- [Run Choice Cartograph](how-to/run-choice-cartograph.md)
- [Review Code with CUPID](how-to/review-code-with-cupid.md)

#### Setup and integration

- [Set Up Verification Slots](how-to/set-up-verification-slots.md)
- [Set Up Garbage Collection](how-to/set-up-garbage-collection.md)
- [Set Up Auto-Enforcer](how-to/set-up-auto-enforcer.md)
- [Set Up Context Engineering](how-to/set-up-context-engineering.md)
- [Set Up Secret Detection](how-to/set-up-secret-detection.md)
- [Set Up Model Routing](how-to/set-up-model-routing.md)
- [Configure Observability](how-to/configure-observability.md)
- [Verify Observatory Signals](how-to/verify-observatory-signals.md)
- [Sync Harness Surfaces](how-to/sync-harness.md)
- [Sync Conventions](how-to/sync-conventions.md)
- [Extract Conventions](how-to/extract-conventions.md)
- [Generate Onboarding](how-to/generate-onboarding.md)
- [Discover Affordances](how-to/discover-affordances.md)
- [Orchestrate Across Repos](how-to/orchestrate-across-repos.md)

#### Security and supply chain

- [Audit Dependencies](how-to/audit-dependencies.md)
- [Audit Docker Images](how-to/audit-docker-images.md)
- [Harden GitHub Actions](how-to/harden-github-actions.md)

#### Other

- [Track AI Costs](how-to/track-ai-costs.md)
- [Enforce Human Pace](how-to/enforce-human-pace.md)
- [Write Literate Code](how-to/write-literate-code.md)

### Reference — exact details

- [Commands](reference/commands.md)
- [Agents](reference/agents.md)
- [Skills](reference/skills.md)
- [Hooks](reference/hooks.md)
- [Templates](reference/templates.md)
- [HARNESS.md format](reference/harness-md-format.md)
- [Output validation](reference/output-validation.md)
- [Governance summary format](reference/governance-summary-format.md)

### Explanation — concepts

These pages introduce the core ideas behind the framework, building
from first principles to the complete system:

1. [The Environment Hypothesis](explanation/the-environment-hypothesis.md) — why AI output quality is an environment problem
2. [Context Engineering](explanation/context-engineering.md) — teaching your AI what your team already knows
3. [Constraints and Enforcement](explanation/constraints-and-enforcement.md) — from good intentions to automated enforcement
4. [Codebase Entropy](explanation/codebase-entropy.md) — why codebases rot and how to fight back
5. [Agent Orchestration](explanation/agent-orchestration.md) — specialised agents with trust boundaries
6. [Compound Learning](explanation/compound-learning.md) — how your AI gets smarter every session
7. [The Loops That Learn](explanation/the-loops-that-learn.md) — four operational loops that make AI environments compound

#### Deep dives

- [HARNESS.md, the Document](explanation/harness-md.md) — what `HARNESS.md` is, how it is operated, and how it compares to `AGENTS.md`, CI config, and hooks
- [The Self-Improving Harness](explanation/self-improving-harness.md) — the audit-and-amendment feedback loop that keeps the harness honest
- [Habitat Engineering](explanation/habitat-engineering.md) — the broader environment around the harness
- [Harness Engineering](explanation/harness-engineering.md) — what the harness is and isn't
- [Decision Archaeology](explanation/decision-archaeology.md) — the choice-cartographer's role; intent debt and cognitive debt
- [Adversarial Review](explanation/adversarial-review.md) — the advocatus-diaboli's role and the human-cognition gate
- [Progressive Hardening](explanation/progressive-hardening.md) — the promotion ladder from unverified to agent to deterministic
- [Determinacy Calibration](explanation/determinacy-calibration.md) — the bidirectional review practice that uses the ladder over time
- [The Three Enforcement Loops](explanation/three-enforcement-loops.md) — inner, middle, and outer loops operating at different timescales
- [Garbage Collection](explanation/garbage-collection.md) — fighting entropy with periodic checks and scheduled agents
- [Fitness Functions](explanation/fitness-functions.md) — testing architectural properties continuously
- [Regression Detection](explanation/regression-detection.md) — patterns that surface from the reflection log
- [The Harness Tuning Loop](explanation/the-harness-tuning-loop.md) — one surprise traced end to end through reflection, GC, HARNESS.md, AGENTS.md, hooks, and CI
- [The Harness Lifecycle](explanation/the-harness-lifecycle.md) — one harness traced through six stages over months and years; the temporal axis of harness operation
- [Governance as Meaning Alignment](explanation/governance-as-meaning-alignment.md) — the three-frame check
