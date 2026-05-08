---
title: Governance for Your Harness
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 8
redirect_from:
  - /tutorials/governance-for-your-harness/
  - /tutorials/governance-for-your-harness.html
---

# Governance for Your Harness

Take your harness from "governance language without operational meaning"
to "falsifiable governance constraints with drift detection and a health
dashboard." This tutorial walks through auditing what you have, writing
a proper governance constraint, and monitoring governance health.

It takes about twenty minutes.

---

## Prerequisites

You need:

- Claude Code installed with the ai-literacy-superpowers plugin
  (see [Getting Started](getting-started))
- A project with a `HARNESS.md` — if you do not have one yet, run
  through [Harness from Scratch](harness-from-scratch) first

The tutorial works best if your `HARNESS.md` already has a few
constraints. Most teams have at least one constraint that uses
governance language without operationalising it — that is what we will
find and fix.

---

## Step 1: Spot Governance Language in Your Constraints

Open your `HARNESS.md` and look at the Constraints section. Scan for
terms like:

- "human review required"
- "ensure compliance"
- "maintain transparency"
- "follow best practices"
- "responsible use"

These are governance language — they sound precise but carry different
meanings depending on who reads them. A constraint that says "human
review required" does not specify what the human must verify, what
counts as evidence of review, or what happens when review is
inadequate.

If you find one, note it. We will come back to it in Step 3.

If your constraints do not contain governance language, you can still
continue — Step 2 will confirm whether the plugin's governance-auditor
agrees with your assessment.

---

## Step 2: Run Your First Governance Audit

Run the governance audit command:

```text
/governance-audit
```

The governance-auditor agent scans your `HARNESS.md` and produces a
report covering:

- **Falsifiability scores** — each governance constraint scored as
  falsifiable, partially operationalised, or vague
- **Drift stages** — which of the five semantic drift stages each
  constraint is in (1 = healthy, 5 = crisis)
- **Governance debt inventory** — constraints whose language no longer
  matches the reality they govern, scored by severity and blast radius
- **Three-frame alignment** — whether the engineering, compliance, and
  AI system interpretations of each constraint agree

The report is saved to `observability/governance/audit-YYYY-MM-DD.md`.

Read through the constraint assessment table. If any constraint shows
"vague" for falsifiability or Stage 3+ for drift, that is where to
focus first.

---

## Step 3: Write Your First Governance Constraint

Pick the vaguest governance constraint from the audit (or the one you
spotted in Step 1) and rewrite it as a falsifiable governance
constraint:

```text
/governance-constrain
```

The command walks you through a guided workflow:

1. **Governance requirement** — what institutional language are you
   encoding? For example: "Internal AI policy Section 4 — human review
   of AI-generated code"

2. **Operational meaning** — what does this actually mean in
   engineering terms? For example: "Every PR with AI-generated code
   must have a review comment addressing design intent and test
   coverage"

3. **Verification** — how do you check compliance? Choose
   deterministic (tool), agent (LLM review), or manual

4. **Evidence and failure** — what proves compliance? What happens
   when it fails?

5. **Three-frame alignment check** — the command presents the
   constraint from engineering, compliance, and AI system perspectives
   and asks you to confirm they align

After completing the workflow, the constraint is written to
`HARNESS.md` with the full governance template:

```markdown
### AI-generated code review quality

- **Rule**: Every PR containing AI-generated code must have at least
  one review with a substantive comment on design intent and
  confirmation that tests cover changed behaviour
- **Enforcement**: agent
- **Tool**: harness-enforcer
- **Scope**: pr
- **Governance requirement**: Internal AI policy Section 4.2
- **Operational meaning**: reviewers must demonstrate cognitive
  engagement, not just approval-click
- **Verification method**: agent reviews PR comments for evidence of
  design reasoning and test coverage confirmation
- **Evidence**: PR review record with design and test comments
- **Failure action**: PR flagged for additional review
- **Frame check**: confirmed aligned
```

Compare this with the original vague version. The difference is that
this constraint can be checked, can fail, and specifies what happens
when it does.

---

## Step 4: Check Governance Health

Run the health check to see your governance metrics:

```text
/governance-health
```

You will see a summary table:

```text
Governance Health
─────────────────────────────────────────
Constraints:          4
Falsifiability:       0.75 (3/4 falsifiable)
Drift score:          low
Debt items:           1
Frame alignment:      0.75 (3/4 aligned)
Last audit:           2026-04-13 (0 days ago)
Drift velocity:       stable
─────────────────────────────────────────
```

Each metric has a colour threshold:

| Metric | Green | Amber | Red |
| ------ | ----- | ----- | --- |
| Falsifiability | > 0.75 | 0.50–0.75 | < 0.50 |
| Drift score | low | medium | high |
| Debt items | 0–2 | 3–5 | > 5 |
| Last audit | < 90 days | 90–180 days | > 180 days |

If anything is amber or red, the health check recommends specific
actions — usually running `/governance-constrain` to rewrite vague
constraints or `/governance-audit` for a deeper investigation.

---

## Step 5: Generate the Dashboard

For a visual overview, generate the governance dashboard:

```text
/governance-health --dashboard
```

This creates a self-contained HTML file at
`observability/governance/governance-dashboard.html`. Open it in a
browser to see:

1. **Health summary cards** — overall score, constraint quality
   distribution, last audit date
2. **Constraint quality table** — each constraint with falsifiability,
   drift risk, frame alignment, and promotion level
3. **Governance debt inventory** — debt items sorted by score
4. **Drift timeline** — how drift has changed across quarterly audits
5. **Three-frame alignment heatmap** — visual showing where
   engineering, compliance, and AI system frames agree or diverge
6. **Trend comparison** — sparkline charts for key metrics over time

The dashboard works offline — it is a single HTML file with no
external dependencies.

---

## What You Have Now

After completing this tutorial:

- A governance audit baseline in `observability/governance/`
- At least one falsifiable governance constraint in `HARNESS.md` with
  three-frame alignment confirmed
- A governance health snapshot showing your current metrics
- A visual dashboard for tracking governance trends

---

## Next Steps

- **Add governance to your quarterly cadence** — run `/governance-audit`
  alongside `/assess` and `/harness-audit` each quarter
- **Write more governance constraints** — use `/governance-constrain`
  for each governance requirement your team operates under
- **Watch for the drift nudge** — the governance drift check Stop hook
  will alert you when governance-related files change and the audit
  is stale
- **Explore the how-to guides** for specific tasks:
  [write a constraint](write-a-governance-constraint.md),
  [detect drift](detect-semantic-drift.md),
  [build a dashboard](build-a-governance-dashboard.md)
