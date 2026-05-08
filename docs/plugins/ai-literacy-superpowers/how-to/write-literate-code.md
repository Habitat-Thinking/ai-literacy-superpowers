---
title: Write Literate Code
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 17
redirect_from:
  - /how-to/write-literate-code/
  - /how-to/write-literate-code.html
---

# Write Literate Code

This guide walks you through applying the literate programming discipline to your code — writing files whose structure and documentation make the reasoning visible to the next reader.

---

## 1. Invoke the skill

When creating a new file, writing a new function or type, or significantly rewriting existing code, invoke the skill:

```bash
/literate-programming
```

The skill applies five rules to every file it produces or reviews.

---

## 2. Open every file with a narrative preamble

The preamble goes in the package or module comment block, before any imports. It answers three questions:

1. Why does this file exist? What problem does it solve?
2. What are the key design decisions? Not a list of functions — the choices that shaped the structure.
3. What does this file deliberately NOT do? Explicit scope exclusions are as informative as inclusions.

**Before (no preamble):**

```go
package cache

import (
    "sync"
    "time"
)

type Cache struct { ... }
```

**After (with preamble):**

```go
// Package cache provides a short-lived, in-process store for rendered page
// fragments. Its only job is to reduce redundant template execution on
// repeated requests for the same URL within a single deploy.
//
// We deliberately avoid distributed caching here. The fragments are cheap
// to recompute, the deploy cadence is high, and the operational burden of
// a networked cache is not justified at current traffic.
//
// We do not attempt cache invalidation on content change — that problem
// belongs to the deployment pipeline, not the request path.
package cache
```

If you cannot state the file's single concern in the preamble's first sentence, the file has too many concerns and should be split.

---

## 3. Write documentation that explains reasoning, not signatures

A comment that restates the function name or its parameter types adds no value. The code already shows WHAT. Documentation's job is to explain WHY.

**Before (restates the signature):**

```go
// getUserByID returns the user with the given ID from the database.
func getUserByID(id string) (*User, error) {
```

**After (explains reasoning):**

```go
// getUserByID loads from the read replica, not the primary. For the auth
// hot-path this is acceptable because user records change rarely and a
// replication lag of a few seconds is not observable by a human login flow.
// Write operations that need immediate consistency call the primary directly.
func getUserByID(id string) (*User, error) {
```

Apply the same standard to type definitions: explain why the type exists and what invariants it maintains.

---

## 4. Order presentation for understanding, not compiler convention

Arrange code so that a reader encounters concepts in the order needed to build understanding:

- High-level orchestration before low-level detail — the function that calls helpers should appear before the helpers.
- Domain model before mechanics — the type that represents the problem before the functions that manipulate it.
- Purpose before implementation — what something is for before how it works.

In Go and Kotlin this sometimes means forward references. That is fine. Readability for the human outweighs compiler convention.

---

## 5. Write inline comments that explain WHY, not WHAT

| Describes WHAT (avoid) | Explains WHY (use) |
| --- | --- |
| `// increment counter` | `// counter is used by the rate limiter, not just for metrics` |
| `// check if user is nil` | `// nil user is valid here — unauthenticated requests are allowed` |
| `// loop over items` | `// process in reverse so removals don't shift the indices we haven't visited` |
| `// return error` | `// surface the parse error; callers need the line number to show a useful message` |

---

## 6. Check for red flags before committing

Before every commit, scan for these signs that literate programming discipline has slipped:

- File opens with `import` or a type declaration — no preamble
- Any function comment that could be auto-generated from its signature
- Helper functions defined before the code that calls them
- A preamble that lists what the file contains rather than why it exists
- An inline comment that starts with "this" and restates the next line

If you find any of these, stop and rewrite before continuing.

---

## 7. Add a convention to HARNESS.md

To make literate programming enforceable across the team, add a convention to the Context section of `HARNESS.md`:

```markdown
#### Documentation
- Every new file must open with a narrative preamble answering: why this file exists,
  key design decisions, and what it deliberately does not do
- Function comments must explain the reasoning behind the approach, not restate the signature
- Inline comments explain WHY, not WHAT — comments that restate the next line are prohibited
```

Then add it as a constraint to enforce it in code review:

```markdown
| Literate preamble on new files | PROBABILISTIC | code review | manual |
```

---

## Summary

After completing these steps you have:

- Every new file opening with a preamble that states its purpose and key decisions
- Function and type comments that explain reasoning rather than restating signatures
- Code ordered for human understanding rather than compiler convention
- Inline comments that explain why, not what
- Red flag checks embedded in your commit workflow
- A HARNESS.md convention that makes the discipline visible to the whole team
