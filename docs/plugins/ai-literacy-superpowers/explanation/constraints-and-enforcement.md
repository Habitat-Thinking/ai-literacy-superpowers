---
title: Constraints and Enforcement
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 3
redirect_from:
  - /explanation/constraints-and-enforcement/
  - /explanation/constraints-and-enforcement.html
---

# Constraints and Enforcement

This page introduces the concepts of constraint maturity and enforcement timing. For detailed mechanics, see [Progressive Hardening](progressive-hardening.md) and [The Three Enforcement Loops](three-enforcement-loops.md).

---

## The distinction that matters

A convention is something you hope people follow. A constraint prevents them from not following it. One lives in a document. The other lives in your workflow.

If you are working with AI coding assistants, this distinction is existential. Not important. Existential.

Consider a typical team meeting outcome: "Going forward, all functions should have proper error handling." Everyone nods. Someone writes it in the team wiki. Three weeks later, a production incident traces back to an unhandled exception in code written *after* the meeting. The team had a convention. What they needed was a constraint.

---

## The enforcement gap

Look at your team's coding guidelines and ask: how many of those rules are actually enforced by anything other than human memory and good intentions?

Most teams have a well-intentioned document full of statements like:

- "Use meaningful variable names"
- "All API endpoints must validate input"
- "Security-sensitive operations require logging"

These are wishes. Wishes do not ship.

> **The Sceptic:** "But our team is disciplined. We follow our guidelines."
>
> **The Veteran:** "Your team is disciplined *most of the time*. Then it's Friday at 4pm, the sprint ends Monday, and someone pushes a 200-line function with a comment that says 'TODO: refactor.' I've seen your git log."

The enforcement gap is the distance between what your team *says* should be true about your codebase and what *is* true. Every team has one. The question is whether you are managing it or pretending it does not exist.

AI coding assistants make this urgent. They are prolific — generating more code in an hour than a human writes in a day. Your enforcement gap was a slow leak. Now it is a burst pipe. Prolific generation without enforcement does not give you prolific quality. It gives you **prolific mediocrity**.

---

## Three levels of constraint maturity

You need constraints, not conventions. But most teams hear "enforcement" and immediately jump to the heaviest possible solution — full CI pipelines, strict linting rules, mandatory type coverage — on day one. That is counterproductive.

### Level 1: Declared (Unverified)

You write the rule down. No automation. No checking. Just a clear, specific statement:

#### "All public API functions must return structured error types, not raw strings."

This sounds weak. It is not. Writing a rule precisely forces you to think about what you actually want. Most teams skip this and jump straight to tooling, which is how you end up with linter rules that nobody understands the purpose of.

### Level 2: Agent-Backed (Verified by AI)

You give the written rule to an AI reviewer. Every PR gets checked against it. The AI reads the rule, reads the code, flags violations.

Is this deterministic? No. Will it catch everything? No. But it catches most things before they merge. Think of it as a colleague who has actually read the style guide reviewing every single pull request.

The speed matters. You go from "we decided this rule matters" to "something is checking for it" in minutes, not weeks. No custom linter rules. Just a clearly stated expectation and an AI that reads it.

### Level 3: Deterministic (Tool-Enforced)

A linter. A type checker. A security scanner. Something that runs the same way every time, with no false negatives.

At this level, the constraint is a law of physics in your codebase. The CI pipeline will not let you violate it.

This is the strongest level. It is also the most expensive and the most dangerous. A bad deterministic rule does not just annoy people — it blocks them. And a team that has been blocked by a bad rule stops trusting the constraint system entirely. One too-strict lint rule and suddenly everyone is adding `// nolint` comments without reading what they are suppressing.

---

## Progressive hardening: the promotion ladder

Every constraint should start soft and earn its way up. This is progressive hardening: start flexible, observe what works, increase enforcement as confidence grows.

```text
    +---------------------------+
    |  DETERMINISTIC            |  <-- Tool enforces it. No exceptions.
    |  (Linter / type checker)  |
    +---------------------------+
    |  AGENT-BACKED             |  <-- AI reviewer checks for it.
    |  (AI review on every PR)  |
    +---------------------------+
    |  DECLARED                 |  <-- Written down. Humans follow it (maybe).
    |  (Documented intention)   |
    +---------------------------+
```

A new rule starts at Declared. You write it clearly. You notice where it is ambiguous, where the edge cases are, where people reasonably disagree.

Once you trust the wording, promote it to Agent-Backed. Watch the results. Does it flag the right things? Does it miss obvious violations? Does it flag things that are fine?

Once the false positives and false negatives are resolved — once the edge cases are truly handled — promote it to Deterministic. Write the linter rule, the type constraint, the automated check.

Some rules should never be promoted. "Functions should be small enough to understand in one pass" is a judgment call. It belongs at Level 2 permanently. Trying to make it deterministic (a 50-line hard limit) produces a worse codebase, not a better one. Not every constraint wants to grow up.

> **The Pragmatist:** "OK but what do I actually do on Monday?"
>
> Start with three rules. Just three. Write them precisely. Make them specific enough to be checkable. Run them past your team. That is your declared layer. Next week, pick the one you are most confident about and add it to your AI review step. That is your first promotion. The deterministic layer can wait.

{: .warning }
> **The over-constraining trap.** It is tempting to look at the promotion ladder and think "let's just make everything deterministic from day one." Do not do this. Rules you have not battle-tested will have edge cases you have not imagined. A deterministic rule with bad edge cases blocks your team, generates workarounds, and erodes trust in the entire constraint system. Start soft. Harden with evidence.

---

## Three enforcement loops

When a constraint fires matters as much as how strict it is.

**Edit time (advisory).** The constraint nudges you while you are working. Red squiggles under a function that is getting too long. It does not block you. It makes sure you know. Most constraints should start here.

**Merge time (strict).** The constraint blocks the pull request until satisfied. CI gates. Required reviews. Automated checks. This is where battle-tested constraints live. If something is important enough to block a merge, you had better be sure about it.

**Scheduled (investigative).** Some constraints are not about individual changes — they are about drift. "Test coverage should not drop below 80%." "No file should go unmodified for more than six months without a staleness review." These run nightly or weekly and flag trends before they become crises.

A common mistake: putting a new, untested constraint directly into the merge loop. Your team hits it on a Friday afternoon deploy, cannot figure out why it is failing, and overrides it. Now the override is the convention. You have made enforcement *weaker* by making it too strict too soon.

{: .note }
> **Try this:** Think about one rule your team has right now. What level is it? What loop is it in? Could it be in a different one?

---

## Exercise: classify the constraints

Classify each of these rules by maturity level (Declared, Agent-Backed, or Deterministic) and enforcement loop (Edit, Merge, or Scheduled):

1. "The TypeScript compiler rejects any code with type errors."
2. "We wrote in our wiki that all React components should have PropTypes."
3. "An AI reviewer checks each PR for functions longer than 50 lines and leaves a comment."
4. "A weekly script scans for dependencies with known CVEs."
5. "Our ESLint config forbids `console.log` in production code."

### Answers

1. Deterministic / Merge.
2. Declared / None (no loop — it is unenforced).
3. Agent-Backed / Merge.
4. Deterministic / Scheduled.
5. Deterministic / Edit and Merge.

---

## The constraint design problem

A good constraint has two properties in tension: it must be **specific enough to enforce** and **general enough to be useful**.

"Code must be clean" is unenforceable. You cannot write a linter rule for vibes.

"No function exceeds 50 lines of executable code" is perfectly enforceable. A script can count lines. But is it right? What about the function that legitimately needs 60 lines because splitting it would make it less readable?

The 50-line rule is not about line count. It is about "functions should be small enough to understand in one pass." Can you enforce that deeper intent deterministically? No. But an AI reviewer can get surprisingly close — and it will not get tired at 4pm on a Friday.

This is the real argument for Agent-Backed constraints: **they can enforce intent, not just metrics.** A linter counts lines. An AI reviewer can read a 60-line function and say "this is actually fine — it's a single clear sequence" or "this 30-line function is doing four unrelated things." That is a category of enforcement that did not exist two years ago.

---

### FAQ

**If AI reviewers are not deterministic, why use them at all?**

Because "catches 90% of violations immediately" beats "catches 0% until a human notices during review." Perfect is the enemy of good, and good is the enemy of nothing at all.

**What if my team disagrees about a constraint?**

Good. That is the conversation you should be having before you automate it. This is why the Declared level exists — it is a space to argue about intent before anyone writes a linter rule.

**Can I have too many constraints?**

Every constraint has a cost: cognitive load, CI time, false positive fatigue. If your developers spend more time satisfying constraints than writing features, you have over-constrained. Start with the constraints that encode your most important architectural decisions. Add more only when you feel the pain of not having them.

---

## Fireside Chat: Convention meets Constraint

> **Convention:** I don't understand why everyone's so down on me. I was here first. I'm the reason the team has any standards at all.
>
> **Constraint:** Nobody's down on you. You're just... aspirational.
>
> **Convention:** Aspirational! I'm a *commitment*. The team *agreed* to follow me.
>
> **Constraint:** The team agreed to follow you on a Tuesday. By Thursday, someone was in a rush and I wasn't there to stop them. You were in the wiki. I was in the pipeline.
>
> **Convention:** But you're so *rigid*. You can't handle nuance. You can't understand *context*.
>
> **Constraint:** That's fair. That's why the smart teams use both of us. You articulate the intent. I enforce the boundary. You're the soul. I'm the skeleton.
>
> **Convention:** ...that's actually kind of nice.
>
> **Constraint:** Don't get sentimental. We have a codebase to protect.

---

## Why this matters now

A human developer writes maybe 50-100 lines of production code on a productive day. The enforcement gap grows slowly. You can almost keep up with manual review.

An AI assistant generates that much in minutes. The enforcement gap does not creep anymore. It sprints.

Constraints are what turn AI speed into AI value. Without them, you are generating technical debt faster. With them, you are generating quality code at a pace that was previously impossible.

But only if the constraints actually bite.

---

## Key takeaways

- **Conventions without enforcement are wishes.** AI makes the enforcement gap wider, faster.
- **Three levels of maturity:** Declared, Agent-Backed, Deterministic. Every constraint starts at the bottom and earns its way up. Some should never reach the top.
- **Progressive hardening** means starting flexible and increasing enforcement with evidence. Skipping steps breaks trust.
- **Three enforcement loops:** Edit (advisory), Merge (strict), Scheduled (investigative). A constraint in the wrong loop does more damage than no constraint at all.
- **Good constraints encode architectural intent**, not arbitrary metrics. AI reviewers can enforce intent in ways linters cannot.

---

## Further reading

- [Progressive Hardening](progressive-hardening.md) — detailed promotion ladder mechanics
- [The Three Enforcement Loops](three-enforcement-loops.md) — inner, middle, and outer loop details
- [Context Engineering](context-engineering.md) — what context declares before constraints enforce
- [Codebase Entropy](codebase-entropy.md) — fighting the drift that constraints miss
