---
title: Set Up Garbage Collection
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 16
redirect_from:
  - /how-to/set-up-garbage-collection/
  - /how-to/set-up-garbage-collection.html
---

# Set Up Garbage Collection

This guide walks you through designing and adding garbage collection (GC) rules to your `HARNESS.md` — periodic checks that fight the entropy that real-time hooks and PR gates cannot catch.

---

## 1. Understand what GC rules catch

GC rules target slow drift: documentation going stale, conventions eroding, dead code accumulating, dependencies falling behind. They complement your deterministic constraints — where constraints fire at commit or PR time, GC rules run on a schedule.

Each GC rule has five fields:

| Field | Description |
| --- | --- |
| What it checks | The specific entropy being detected |
| Frequency | `daily`, `weekly`, or `manual` |
| Enforcement | `deterministic` (tool) or `agent` (reasoning required) |
| Tool | What runs the check |
| Auto-fix | `true` (agent fixes and commits) or `false` (creates an issue) |

---

## 2. Identify the entropy in your codebase

Before writing rules, answer these questions:

- What goes stale fastest in this codebase? (Documentation? Dependency versions? API references?)
- What conventions drift in code review? (Naming? File structure? Error handling?)
- What accumulates silently? (Unused exports? Orphaned test fixtures? Stale TODO comments?)
- What slows down teams when it drifts? (Prioritise by impact.)

List your answers. Each answer is a candidate GC rule.

---

## 3. Choose frequency for each rule

| Frequency | Use for |
| --- | --- |
| `daily` | Fast-moving codebases with high entropy rate |
| `weekly` | Most rules — documentation, dependencies, dead code |
| `manual` | Checks not yet calibrated for automation |

Start with `weekly` for everything. Only move to `daily` if the entropy rate justifies the cost.

---

## 4. Apply the auto-fix decision

Auto-fix is safe when the fix is **deterministic, local, verifiable, and reversible**. It is not safe when the fix requires judgement, has ripple effects, or is destructive.

| Condition | Auto-fix |
| --- | --- |
| Running `go mod tidy` to clean unused dependencies | `true` — deterministic and reversible |
| Removing a dead function used nowhere | `false` — needs human judgement about intent |
| Updating a version number in a docs file | `true` — local and verifiable |
| Refactoring a naming violation across many files | `false` — ripple effects |

When auto-fix is `false`, the `harness-gc` agent creates a GitHub issue with file and line references and a suggested fix.

---

## 5. Add GC rules to HARNESS.md

Open `HARNESS.md` and find or create the Garbage Collection section. Add one row per rule:

```markdown
## Garbage Collection

| What it checks | Frequency | Enforcement | Tool | Auto-fix |
| --- | --- | --- | --- | --- |
| Stale doc references to deleted files | weekly | agent | harness-gc | false |
| Unused Go exports | weekly | deterministic | deadcode ./... | false |
| Dependency CVEs | weekly | deterministic | govulncheck ./... | false |
| Convention drift — error wrapping | weekly | deterministic | custom lint rule | false |
| go.mod tidiness | weekly | deterministic | go mod tidy | true |
```

---

## 6. Run the GC agent

```bash
/harness-gc
```

The `harness-gc` agent reads your GC rules, runs each check, and either applies auto-fixes (with your confirmation in interactive mode) or creates GitHub issues for findings that require human attention.

To run a single rule by name:

```bash
/harness-gc --rule "Unused Go exports"
```

---

## 7. Add common GC rules by category

Use these as a starting point and adapt to your codebase:

**Documentation entropy:**

```markdown
| HARNESS.md references non-existent files | weekly | agent | harness-gc | false |
| Stack declaration version mismatch | weekly | agent | harness-gc | false |
```

**Convention drift:**

```markdown
| Naming convention violations | weekly | deterministic | custom linter | false |
| Error wrapping missing context | weekly | deterministic | errcheck | false |
```

**Dead code:**

```markdown
| Unused exported functions | weekly | deterministic | deadcode ./... | false |
| Orphaned test fixtures | weekly | agent | harness-gc | false |
```

**Dependency entropy:**

```markdown
| Known CVEs in dependencies | weekly | deterministic | govulncheck ./... | false |
| Dependencies > 2 major versions behind | weekly | agent | harness-gc | false |
```

---

## 8. Schedule GC in CI

Run the deterministic GC checks on a weekly schedule in GitHub Actions:

```yaml
name: Harness GC

on:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday at 09:00 UTC

jobs:
  gc:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run dependency CVE check
        run: |
          go install golang.org/x/vuln/cmd/govulncheck@latest
          govulncheck ./...
```

---

## Summary

After completing these steps you have:

- GC rules that target the entropy specific to your codebase
- Frequency and auto-fix decisions applied using the safety rubric
- A Garbage Collection section in `HARNESS.md` with structured rule entries
- The `harness-gc` agent wired up to run checks and create issues
- Deterministic GC checks scheduled in CI to run weekly
