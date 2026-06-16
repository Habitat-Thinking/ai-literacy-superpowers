---
name: harness-status
description: Show the current health of the project's harness — enforcement ratio, drift, and garbage collection state
---

# /harness-status

Quick read of harness health. No agents dispatched — this reads
HARNESS.md and cross-references against what exists in the project.

## Process

### 1. Check HARNESS.md Exists

If no HARNESS.md exists at the project root, tell the user:
"No HARNESS.md found. Run `/harness-init` to set up a harness."

### 2. Read Status Section

Parse HARNESS.md's Status section for:

- Last audit date
- Constraints enforced ratio
- Garbage collection active ratio
- Drift status

### 3. Read Constraints

Count constraints by enforcement type:

- Deterministic
- Agent
- Unverified

### 4. Read Garbage Collection

Count GC rules by status:

- Active (deterministic or agent enforcement)
- Inactive (no enforcement configured)

### 4a. Count Affordances

If a `## Affordances` section exists, count its declared affordances by
counting `### ` headings within the section (each heading is one
affordance, per the one-affordance-per-permission-pattern rule). Ignore the
section's HTML comments. If the section is absent, skip this — affordances
are an opt-in feature.

### 5. Present Summary

```text
## Harness Status

Last audit: YYYY-MM-DD (N days ago)

### Constraints: N/M enforced
- Deterministic: X (tool-backed)
- Agent: Y (LLM-reviewed)
- Unverified: Z (declared only)

### Garbage Collection: N/M active
- Auto-fix enabled: X rules
- Report-only: Y rules

### Affordances: N declared
[Omit this whole line when there is no ## Affordances section]

### Drift: [none detected / warning]
[Details if drift was detected in last audit]

### Next Steps
- Run /harness-constrain to add or promote constraints
- Run /harness-audit for a full verification
- Run /harness-gc to run garbage collection checks
```
