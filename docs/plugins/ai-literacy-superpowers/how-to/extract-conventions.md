---
title: Extract Conventions
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 10
redirect_from:
  - /how-to/extract-conventions/
  - /how-to/extract-conventions.html
---

# Extract Conventions

Run a guided convention extraction session to surface tacit team knowledge and encode
it as enforceable artefacts in CLAUDE.md and HARNESS.md.

---

## When to do this

| Situation | Signal |
| --------- | ------ |
| New project setup | CLAUDE.md and HARNESS.md are empty or boilerplate |
| AI output quality varies | Same codebase, different developers get different results |
| After team changes | A key engineer joined or left |
| Post-incident | A production incident revealed a convention that was never written down |
| Quarterly cadence | Review whether encoded conventions still match practice |

Teams of five often do not need formal extraction — conversations happen naturally.
Teams of fifteen almost certainly do — tacit knowledge diverges without intervention.

---

## 1. Start the session

```text
/extract-conventions
```

The agent walks through five structured questions conversationally. Run this in a
mob session with senior engineers, or use the transcript as an interview guide for
one-on-one conversations.

---

## 2. Answer the five questions

The session covers these questions in order:

1. **What architectural decisions should never be left to individual judgment?**
   Surfaces non-negotiable patterns — dependency direction, module boundaries,
   API design rules.

2. **Which conventions are corrected most often in AI-generated code?**
   Surfaces the gap between what AI produces by default and what the team expects.
   These are your highest-value conventions to encode.

3. **Which security checks are applied instinctively?**
   Surfaces embodied security knowledge — input validation, auth patterns,
   secrets handling.

4. **What triggers an immediate rejection in code review?**
   Surfaces hard boundaries — things that are never acceptable regardless of context.

5. **What separates a clean refactoring from an over-engineered one?**
   Surfaces judgment about abstraction thresholds and YAGNI boundaries.

If the answer to a question is always "it depends on context," that convention needs
decomposition into specific, observable cases before it can be encoded. "It depends"
is a signal to keep digging, not a failure.

---

## 3. Review the artefact mapping

The agent maps each answer to the appropriate artefact:

| Answer category | Artefact type | Where it lives |
| --------------- | ------------- | -------------- |
| Non-negotiable patterns | Constraint | HARNESS.md |
| Frequent corrections | Convention | CLAUDE.md |
| Security instincts | Constraint or threat-model item | HARNESS.md |
| Review rejections | Critical check | HARNESS.md or reviewer agent |
| Refactoring philosophy | Style preference | CLAUDE.md |
| "It depends" answers | Not encodable yet | Backlog for decomposition |

Review the mapping before the agent writes anything. Correct any misclassifications.

---

## 4. Confirm the written artefacts

The agent updates CLAUDE.md with new conventions and runs `/harness-constrain` to add
constraints to HARNESS.md. After each update, verify:

- The rule is precise enough to check without ambiguity
- The enforcement type matches what tooling you have available
- The scope matches when you need the check to run

---

## 5. Avoid common mistakes

| Anti-pattern | Fix |
| ------------ | --- |
| Over-prescriptive instructions | Test each instruction against real code before committing |
| Encoding aspirations ("write clean code") | Decompose into observable properties |
| Starting with ten conventions | Adopt one, then expand |
| Skipping disagreement between seniors | The disagreement is the point — resolve it before encoding |

---

## 6. Schedule a re-extraction

Add a re-extraction cadence to `CLAUDE.md`:

```markdown
## Operating Cadence

- Quarterly: review CLAUDE.md conventions against current practice
- After team composition changes: run `/extract-conventions`
```

Conventions drift. What the team encoded six months ago may not match what they do today.
