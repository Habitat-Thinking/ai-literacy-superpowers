---
title: Set Up Context Engineering
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 11
redirect_from:
  - /how-to/set-up-context-engineering/
  - /how-to/set-up-context-engineering.html
---

# Set Up Context Engineering

This guide walks you through writing enforceable conventions for the Context section of your `HARNESS.md` so that LLMs and new team members work from the same shared understanding of your codebase.

---

## 1. Open the Context section of HARNESS.md

The Context section has two parts: a Stack Declaration and a Conventions block. If your `HARNESS.md` was created by `/harness-init`, the Stack Declaration should already be populated. If not, add a factual summary of your languages, build system, test framework, and container strategy:

```markdown
## Context

### Stack

- Language: Go 1.22
- Build: `make build`
- Tests: `go test ./...`
- Containers: Docker multi-stage builds, Alpine runtime
```

Keep this section factual — describe what is true today, not aspirations.

---

## 2. Identify your conventions

Before writing anything, gather what the team actually values. Ask:

- What do code reviewers comment on most often?
- What patterns does the codebase already follow consistently?
- What rules exist informally ("we always do X") but are not written down?

List them as rough aspirations first. You will make them enforceable in the next step.

---

## 3. Apply the enforceability test to each convention

For each aspiration, ask three questions:

1. Can I describe what code that **follows** this convention looks like?
2. Can I describe what code that **violates** it looks like?
3. Could a tool or agent check this without ambiguity?

If any answer is no, rewrite the convention until all three are yes.

Use this table as a guide:

| Aspiration | Not enforceable | Enforceable convention |
| --- | --- | --- |
| Write clean code | Too broad | Decompose into specific rules below |
| Keep functions short | Vague | Functions must not exceed 40 lines |
| Use meaningful names | Subjective | Variables must be 3+ characters except `i`, `j`, `k`, `err` |
| Handle errors properly | Unverifiable | Every returned error must be wrapped with context |

---

## 4. Organise conventions by category

Group your conventions under these headings in the Context section:

```markdown
### Conventions

#### Naming
- Variables must be 3+ characters except loop indices (`i`, `j`, `k`) and `err`
- Exported types use PascalCase; unexported identifiers use camelCase

#### File structure
- One type per file; file name matches the primary type name
- Tests co-located with source: `foo.go` + `foo_test.go`

#### Error handling
- Every returned error must be wrapped with `fmt.Errorf("context: %w", err)`
- No `panic` outside of `main` or init functions

#### Testing
- Test function names follow `Test<Function>_<scenario>` pattern
- Table-driven tests for functions with more than two distinct input cases
```

Adjust categories to match your stack. Omit empty categories rather than leaving placeholder headings.

---

## 5. Remove convention anti-patterns

Before saving, check each entry against these anti-patterns and rewrite or remove anything that matches:

- **Implementation instructions** — "use dependency injection" is an instruction. Replace with the observable outcome: "dependencies are passed as constructor parameters, not retrieved from globals."
- **Tool configuration** — linter rules belong in the linter config file, not in `HARNESS.md`.
- **Aspirational quality statements** — "write readable code" cannot be checked. Decompose it.
- **Temporary rules** — if a rule will expire, add it as a constraint with a scope, not a convention.

---

## 6. Verify conventions against the existing codebase

A convention that the codebase already violates in many places is worse than no convention — it creates noise for LLM agents and erodes trust. Before committing each convention:

```bash
# Example: check whether error wrapping is already in use
grep -r "fmt.Errorf" . --include="*.go" | wc -l
grep -r 'errors.New' . --include="*.go" | wc -l
```

If the convention is not yet followed consistently, note it as a target state and create a constraint to enforce it going forward rather than pretending it is already the case.

---

## 7. Run `/harness-audit` to detect stale context

After adding or updating conventions, run the harness audit to cross-reference your context against the project's actual state:

```bash
/harness-audit
```

The audit flags conventions that reference functions, files, or patterns that no longer exist. Address each finding before declaring the context section complete.

---

## Summary

After completing these steps you have:

- A Stack Declaration that reflects the actual project configuration
- A Conventions section where every entry passes the enforceability test
- Conventions grouped by category with no anti-patterns
- A verified baseline — conventions that match the codebase as it stands
- A living context section maintained by `/harness-audit` on an ongoing basis
