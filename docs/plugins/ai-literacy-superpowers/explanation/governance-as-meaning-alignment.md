---
title: Governance as meaning-alignment
---
# Governance as Meaning-Alignment

Governance failures are not primarily technical failures. They are
reference frame translation failures. When the meaning encoded in
governance language diverges from operational reality, the result is
compliance theatre — governance that looks correct but governs nothing.

This page explains why governance language drifts, how to detect it,
and what the plugin provides to prevent it.

---

## The Core Problem

Governance language carries different meanings in different reference
frames. Consider "ensure human oversight of AI-generated code":

| Frame | Interpretation |
| ----- | -------------- |
| Regulatory | A qualified human evaluates whether the AI decision is appropriate before it takes effect |
| Engineering | A human clicks "approve" on a pull request that contains AI-generated code |
| AI system | A boolean gate prevents merge without at least one approval |

All three frames can be satisfied simultaneously while governance
fails semantically. The approval happens, but the oversight is absent.
The PR was approved, the audit trail exists, the gate passed — and
nobody checked whether the code was correct.

This is not a hypothetical. It is the default state of most governance
constraints. The language sounds precise. The implementations diverge.
The audits confirm the divergence. The risk persists.

---

## Semantic Drift

Governance language drifts through five predictable stages:

| Stage | What happens | Example |
| ----- | ------------ | ------- |
| 1. Coinage | A term is introduced with specific meaning | "Meaningful human oversight" means active evaluation by a qualified human |
| 2. Adoption without frame | The term enters governance documents without its original context | Policy says "require meaningful human oversight" without defining "meaningful" |
| 3. Implementation from a different frame | Engineers implement from their own reference frame | Team adds a PR approval gate — technically "human oversight" |
| 4. Audit from yet another frame | Compliance verifies from the institutional frame | Audit confirms approval records exist — "oversight requirement met" |
| 5. Crisis | The gap becomes visible through real-world harm | AI-generated code introduces a vulnerability despite "oversight" passing at every stage |

Most governance constraints in the wild are at Stage 2 or 3. The
language has been adopted, the implementation has diverged, and nobody
has noticed because the audits check the wrong frame.

The plugin's `/governance-audit` command detects which stage each
constraint is in. Constraints at Stage 3 or higher need immediate
attention.

---

## Governance Debt

Governance debt is the accumulation of governance mechanisms whose
language no longer corresponds to the risks they address. It is the
fourth form of debt, alongside technical, cognitive, and intent debt.

The four debts reinforce each other in a vicious cycle:

1. **Governance debt** → intent debt: governance language obscures the
   purpose of controls
2. **Intent debt** → cognitive debt: teams cannot form accurate mental
   models of what the governance actually requires
3. **Cognitive debt** → technical debt: developers implement controls
   they do not understand
4. **Technical debt** → governance debt: the gap between governance
   language and operational reality widens further

Unlike technical debt, which becomes visible in hours or days,
governance debt manifests over months or years — but when it does, it
manifests as institutional crisis, not a failed build.

---

## The Three-Frame Translation Problem

Every governance constraint operates at the intersection of three
reference frames:

| Interface | Failure mode | Detection |
| --------- | ------------ | --------- |
| Human ↔ AI | "It did what I said, not what I meant" | Tests, verification, falsification |
| Human ↔ Institution | "The regulation does not match how we actually work" | Governance specification exercises |
| AI ↔ Institution | "The system is compliant but not safe" | Adversarial compliance testing |

The most dangerous failures occur when all three frames are misaligned
simultaneously: the human understands the risk, the governance language
does not capture it, and the AI system can demonstrate compliance while
the risk persists.

The plugin's `/governance-constrain` command includes a three-frame
alignment check that surfaces these divergences before a constraint is
written to `HARNESS.md`.

---

## Falsifiable Governance

A governance constraint must answer three questions to be falsifiable:

1. **What do you verify?** — the specific observable condition
2. **What counts as evidence?** — what artefacts demonstrate compliance
3. **What happens on failure?** — the response when verification fails

If a constraint cannot answer all three, it is governance language
pretending to be a constraint. It belongs in a policy document, not in
`HARNESS.md`.

**Before (governance language):**

> Human oversight is required for all AI-generated code.

**After (falsifiable governance constraint):**

> Every PR containing AI-generated code must have at least one review
> that includes a substantive comment on design intent and confirmation
> that tests cover the changed behaviour. Verified by agent review of
> PR comments. Evidence: PR review record. Failure action: PR cannot
> merge until substantive review is added.

The difference is not length. The difference is that the second version
can be checked, can fail, and specifies what happens when it does.

---

## How the Plugin Helps

The plugin provides three governance commands that address different
stages of the governance lifecycle:

| Command | Purpose | When to use |
| ------- | ------- | ----------- |
| `/governance-constrain` | Translate governance language into a falsifiable constraint with three-frame alignment | When encoding a new governance requirement |
| `/governance-audit` | Detect semantic drift, inventory governance debt, check frame alignment | Quarterly, or when governance feels stale |
| `/governance-health` | Quick pulse check on governance metrics and trends | Between quarterly audits |

The governance-auditor agent owns the deep investigation work.
Existing agents (harness-enforcer, harness-gc, assessor) gain
lightweight governance awareness through the governance skills.

A Stop hook nudges `/governance-audit` when governance-related files
change during a session and the last audit is stale.

For a hands-on walkthrough, start with the
[Governance for Your Harness](../tutorials/governance-for-your-harness.md)
tutorial. For specific tasks, see the how-to guides:

- [Write a governance constraint](../how-to/write-a-governance-constraint.md)
- [Run a governance audit](../how-to/run-a-governance-audit.md)
- [Check governance health](../how-to/check-governance-health.md)
- [Detect semantic drift](../how-to/detect-semantic-drift.md)
- [Build a governance dashboard](../how-to/build-a-governance-dashboard.md)
