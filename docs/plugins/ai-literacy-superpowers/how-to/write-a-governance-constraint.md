---
title: Write a Governance Constraint
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 29
redirect_from:
  - /how-to/write-a-governance-constraint/
  - /how-to/write-a-governance-constraint.html
---

# Write a Governance Constraint

Translate a governance requirement into a falsifiable HARNESS.md
constraint with three-frame alignment.

---

## Prerequisites

- `HARNESS.md` exists in your project root
- The ai-literacy-superpowers plugin is installed

---

## 1. Start the guided workflow

```text
/governance-constrain
```

The command walks through six prompts. Answer each one before
proceeding.

---

## 2. Identify the governance requirement

The first prompt asks: **What governance requirement are you
encoding?**

State the institutional language — the regulation, policy, or internal
standard. For example:

> Internal AI governance policy Section 4.2 — meaningful human review
> of AI-assisted work

---

## 3. Translate to operational meaning

The second prompt asks: **What does this mean operationally?**

Describe what must actually happen in engineering terms. Be specific.
"Ensure quality" is not operational. "Every PR must have a review
comment addressing design intent" is operational.

---

## 4. Define verification, evidence, and failure

The next prompts ask:

- **How do you verify compliance?** — choose deterministic (tool),
  agent (LLM review), or manual
- **What counts as evidence?** — test reports, audit logs, review
  records
- **What happens on failure?** — block merge, file incident, alert
  team

---

## 5. Complete the three-frame check

The command presents the constraint from three perspectives:

- **Engineering frame**: what the team must technically do
- **Compliance frame**: what the audit trail must show
- **AI system frame**: what the automated gate checks

Confirm the three frames align. If they diverge, resolve the
divergence before proceeding — the command helps you work through it.

---

## 6. Review the written constraint

The command writes the constraint to `HARNESS.md` using the
governance template with all fields: Rule, Enforcement, Tool, Scope,
Governance requirement, Operational meaning, Verification method,
Evidence, Failure action, and Frame check.

Review the result in `HARNESS.md` to confirm it reads correctly.

---

## What you have now

A governance constraint in `HARNESS.md` that encodes operational
meaning, has defined verification criteria, and has been checked for
three-frame alignment.

## Next steps

- [Run a governance audit](run-a-governance-audit) to assess all your
  governance constraints
- [Detect semantic drift](detect-semantic-drift) to catch constraints
  that have diverged from reality
