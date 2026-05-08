---
title: Detect Semantic Drift
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 32
redirect_from:
  - /how-to/detect-semantic-drift/
  - /how-to/detect-semantic-drift.html
---

# Detect Semantic Drift in Your Constraints

Find governance constraints whose meaning has diverged from the
reality they govern, and fix them before they reach crisis.

---

## Prerequisites

- Governance constraints in `HARNESS.md`
- The ai-literacy-superpowers plugin is installed

---

## 1. Recognise drift signals

Semantic drift is likely when:

- **Implementation changed** — the code files a governance constraint
  references have changed substantially, but the constraint language
  has not
- **Process changed** — your team adopted a new CI pipeline, review
  process, or toolchain, but governance constraints still reference
  the old process
- **Regulatory environment changed** — the regulation or standard
  cited by a constraint has been updated
- **Term meaning shifted** — your team now uses a governance term
  differently than when the constraint was written

---

## 2. Confirm with a governance audit

```text
/governance-audit
```

The audit scores each constraint's drift risk and identifies which
of the five drift stages it is in. Focus on constraints at Stage 3
or higher — these are constraints where the implementation checks
form (action exists) rather than substance (action is meaningful).

---

## 3. Rewrite drifted constraints

For each drifted constraint, run:

```text
/governance-constrain
```

The guided workflow helps you re-translate the governance requirement
into current operational meaning. Pay particular attention to the
three-frame check — drift often occurs because the frames have moved
apart since the constraint was written.

---

## 4. Verify the fix

After rewriting, run `/governance-health` to confirm the drift score
has improved. Over multiple audits, the drift velocity metric will
show whether your governance constraints are converging with reality
or diverging from it.

---

## What you have now

A method for detecting governance drift before it reaches crisis, and
a workflow for fixing drifted constraints.

## Next steps

- [Run a governance audit](run-a-governance-audit) quarterly to catch
  drift early
- [Check governance health](check-governance-health) between audits
  for a quick pulse
