---
title: Review Code with CUPID
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 12
redirect_from:
  - /how-to/review-code-with-cupid/
  - /how-to/review-code-with-cupid.html
---

# Review Code with CUPID

This guide walks you through reviewing code using the five CUPID properties — Composable, Unix philosophy, Predictable, Idiomatic, Domain-based — as a structured lens for surfacing improvement opportunities.

---

## 1. Invoke the skill

Open the file or function you want to review and run:

```bash
/cupid-code-review
```

The skill applies each of the five CUPID properties in turn to the code you provide. You can also invoke it on a specific file or a PR diff.

---

## 2. Work through each property in order

For each of the five properties, ask the review questions and note findings before moving to the next. Do not try to evaluate all five simultaneously.

### C — Composable: can I use this anywhere without baggage?

Key questions:

- Can this function or module be used independently, without pulling in unrelated state?
- Are dependencies explicit (passed in) rather than implicit (global or ambient)?
- Is the API surface the minimum needed?

Signals of weak composability: hidden global state, "god object" arguments, functions that only make sense when called in a specific order.

### U — Unix philosophy: does it do one thing completely?

Key questions:

- Can I describe what this does in one short sentence without using "and"?
- Does the name match what it actually does?
- Are multiple abstraction levels mixed together?

Signals of weak Unix philosophy: "and" or "or" in function names, section comments inside a function body, functions that compute, persist, and notify.

### P — Predictable: does it behave as its name suggests?

Key questions:

- Given only the name, would a reader expect the observed behaviour?
- Are there hidden side effects beyond what the signature suggests?
- Does it fail loudly or silently?

Signals of weak predictability: boolean parameters that change behaviour significantly, swallowed exceptions, names that understate what the function does (a "get" that also writes).

### I — Idiomatic: does it feel natural here?

Key questions:

- Would an experienced developer in this language find this familiar?
- Are language features used as intended, not fought against?
- Is anything reimplementing what the standard library provides?

Signals of weak idiom: manual iteration where a higher-order function is conventional, inconsistent style compared to surrounding code.

### D — Domain-based: does it speak the domain's language?

Key questions:

- Do the names appear in conversations with domain experts?
- Are there technical names where domain names exist?
- Does the structure mirror the structure of the domain?

Signals of weak domain language: generic names (`data`, `manager`, `handler`, `util`), technical names for business concepts (`UserRecord` instead of `Customer`).

---

## 3. Rate each property

After working through the questions, give each property a loose rating:

| Property | Strength | Top opportunity |
| --- | --- | --- |
| Composable | Strong / Weak / Absent | One concrete improvement |
| Unix philosophy | Strong / Weak / Absent | One concrete improvement |
| Predictable | Strong / Weak / Absent | One concrete improvement |
| Idiomatic | Strong / Weak / Absent | One concrete improvement |
| Domain-based | Strong / Weak / Absent | One concrete improvement |

Do not frame this as pass/fail. The goal is to identify where the code sits on each dimension and what a move in the right direction looks like.

---

## 4. Prioritise and act

When deciding where to start:

1. Identify the weakest one or two properties.
2. Check whether improving the weakest property makes the others easier — improving Domain-based often makes the right structure obvious; improving Composable makes the code testable and movable.
3. Describe one concrete change per weak property. Keep it specific enough to be actionable.

Avoid trying to improve all five at once. That leads to over-engineering.

---

## 5. Optionally add a CUPID Status section to the README

After a full five-property assessment, the skill will offer to add a CUPID Status section to the project README. Accept this if you want to track quality state over time. The section uses this format:

```markdown
## CUPID Status

Last assessed: YYYY-MM-DD

| Property | Strength | Top opportunity |
| --- | --- | --- |
| Composable | ★★★★☆ | Brief description |
| Unix philosophy | ★★★☆☆ | Brief description |
| Predictable | ★★★★★ | — |
| Idiomatic | ★★★☆☆ | Brief description |
| Domain-based | ★★★★☆ | Brief description |
```

---

## Summary

After completing these steps you have:

- A structured assessment of the code across all five CUPID properties
- A prioritised list of improvement opportunities
- A concrete action for each weak property
- Optionally, a documented CUPID Status in the README for tracking over time
