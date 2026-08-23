---
title: ai-literacy-superpowers
---
# ai-literacy-superpowers

The flagship plugin in this marketplace — harness engineering, agent
orchestration, literate programming, CUPID code review, compound
learning, and the three enforcement loops.

## Changing a harness rule

**Once a harness exists, this is how it changes.** Rules enter on recorded
evidence, carry a cost the approver wrote, and expire unless someone renews
them:

```text
/harness-assay      read what actually happened; propose, then stop
/harness-propose    draft a decision record, rule text copied verbatim
/harness-accept     you write the cost; the rule is applied and compiled
/harness-check      CI verifies what is written down is what is in force
/harness-review     when a rule lapses: re-evidence, weaken, or demote
```

Start with **[Your First Governance Change](tutorials/your-first-governance-change.md)**,
or read [Harness evolution](explanation/harness-evolution.md) for why the role
that diagnoses failures is forbidden from writing the rules.

Editing `HARNESS.md` by hand still has one job — the first draft of a harness
that does not exist yet. After that, hand edits are how a governing document
becomes the least governed thing in the repository.

The everyday drift-and-heal entry is `/harness-sync` — it detects drift across
every surface and applies the fixes you select. See
[The Harness Lifecycle](explanation/the-harness-lifecycle.md) for the broader
frame.

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

- [Your First Governance Change](tutorials/your-first-governance-change.md) — change a harness rule the governed way: from evidence, through a recorded decision, with a cost you wrote and an expiry CI enforces
- [Your First Sentinels](tutorials/your-first-sentinels.md) — meet three of the ten in one session; the category that guards your understanding rather than your code
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

#### Evolving the harness

How a rule changes once the harness exists. This is the governed path, and the
one to reach for by default.

- [Assay a Phase](how-to/assay-a-phase.md) — the read-only postmortem a governance change is built from
- [Record a Governance Change](how-to/record-a-governance-change.md) — propose, accept, and read the enforcement report

#### Harness lifecycle

- [Add a Constraint](how-to/add-a-constraint.md) — authoring the *first* draft by hand; for changes to an existing harness, use the governed path above
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
- [Watch Your Cognitive Reservoir](how-to/watch-your-cognitive-reservoir.md)
- [Write Literate Code](how-to/write-literate-code.md)

### Reference — exact details

- [Commands](reference/commands.md)
- [Agents](reference/agents.md)
- [Skills](reference/skills.md)
- [Hooks](reference/hooks.md)
- [Templates](reference/templates.md)
- [HARNESS.md format](reference/harness-md-format.md)
- [Harness Decision Record format](reference/harness-decision-records.md) — the unit a governance change is recorded in
- [Assay finding format](reference/assay-finding-format.md) — the contract between the Assayer and the Registrar
- [Enforcement report format](reference/enforcement-report-format.md) — intended versus achieved, per rule, per surface
- [Intervention feed format](reference/intervention-feed-format.md) — the Observatory timeline `/harness-timeline` emits
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
8. [Harness Evolution](explanation/harness-evolution.md) — **how the rules themselves change**: the two roles, the human gate between them, and why rules should be hard to add and easy to retire

#### Deep dives

- [HARNESS.md, the Document](explanation/harness-md.md) — what `HARNESS.md` is, how it is operated, and how it compares to `AGENTS.md`, CI config, and hooks
- [The Self-Improving Harness](explanation/self-improving-harness.md) — the audit-and-amendment feedback loop that keeps the harness honest
- [The Harness Tuning Loop](explanation/the-harness-tuning-loop.md) — the older reflection-to-constraint path, and where it still applies
- [Habitat Engineering](explanation/habitat-engineering.md) — the broader environment around the harness
- [Harness Engineering](explanation/harness-engineering.md) — what the harness is and isn't
- [Cadence Governance](explanation/cadence-governance.md) — the carpaccio agent's role; slicing the task before any spec exists
- [The Decision-Discipline Triad](explanation/decision-discipline-triad.md) — how carpaccio, advocatus-diaboli, and choice-cartographer relate
- [Sentinels](explanation/sentinels.md) — the category that guards the human's understanding and judgement, its three-part signature, and the roster
- [The Cadence Discipline](explanation/cadence-discipline.md) — coda, mast, wip-warden and convener; the shape of the work around decisions
- [Decision Archaeology](explanation/decision-archaeology.md) — the choice-cartographer's role; intent debt and cognitive debt
- [Adversarial Review](explanation/adversarial-review.md) — the advocatus-diaboli's role and the human-cognition gate
- [Watching the Verifier](explanation/watching-the-verifier.md) — the reservoir-warden's advisory watch on the human the harness cannot verify
- [Prospective Cost Estimation](explanation/prospective-cost-estimation.md) — the cost-estimator's range-not-point contract and its refusal to fabricate
- [The Cost Estimation Loop](explanation/the-cost-estimation-loop.md) — how the cost capability works as a whole
- [Harness Affordances](explanation/harness-affordances.md) — what the harness can reach, declared and checked
- [Progressive Hardening](explanation/progressive-hardening.md) — the promotion ladder, and why rung and reach are different axes
- [Determinacy Calibration](explanation/determinacy-calibration.md) — the bidirectional review practice that uses the ladder over time
- [The Three Enforcement Loops](explanation/three-enforcement-loops.md) — inner, middle, and outer loops operating at different timescales
- [Garbage Collection](explanation/garbage-collection.md) — fighting entropy with periodic checks and scheduled agents
- [Fitness Functions](explanation/fitness-functions.md) — testing architectural properties continuously
- [Regression Detection](explanation/regression-detection.md) — patterns that surface from the reflection log
- [The Harness Tuning Loop](explanation/the-harness-tuning-loop.md) — one surprise traced end to end through reflection, GC, HARNESS.md, AGENTS.md, hooks, and CI
- [The Harness Lifecycle](explanation/the-harness-lifecycle.md) — one harness traced through six stages over months and years; the temporal axis of harness operation
- [Governance as Meaning Alignment](explanation/governance-as-meaning-alignment.md) — the three-frame check
- [A Curated Video Library for Agentic Engineering](explanation/agentic-engineering-videos.md) — authoritative talks mapped to the plugin's capabilities and lineage
