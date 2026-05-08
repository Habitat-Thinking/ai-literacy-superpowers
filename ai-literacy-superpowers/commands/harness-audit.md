---
name: harness-audit
description: Run a full meta-verification of the harness — check whether HARNESS.md matches reality and update the status
---

# /harness-audit

Full meta-verification of the harness itself.

Read the `harness-audit-engine` skill from this plugin before
proceeding. The engine defines the shared drift-detection logic and
the drift-report shape. This command is the read-only inspection
caller; `/harness-sync` is the read-then-fix caller.

## Process

### 1. Check HARNESS.md Exists

If no HARNESS.md exists, tell the user to run `/harness-init` first.

### 2. Discover Current State

Dispatch the `harness-discoverer` agent to scan the project's current
state — what tools are installed, what CI exists, what hooks are
configured.

### 3. Verify All Constraints

Dispatch the `harness-enforcer` agent to run every declared constraint
(all scopes) against the current codebase.

### 4. Audit Harness Health

Dispatch the `harness-auditor` agent with the discovery report and
enforcer results. The auditor will:

- Compare declared enforcement with actual project state
- Detect drift (declared but missing tools, undeclared but present
  enforcement)
- Update HARNESS.md's Status section
- Update the README badge

### 5. Present Results

Show the user:

- Enforcement ratio and breakdown
- Any drift detected (with specific details)
- Constraint pass/fail results
- Badge update summary

### 6. Recommend Actions

Based on audit findings, suggest next steps:

- Unverified constraints that could be promoted
- Drift that needs resolution
- Undeclared enforcement that should be added to HARNESS.md
- Tools that could be installed for deterministic enforcement

## Reflection log + archive coverage

The audit report now includes a `Reflection-log archival` subsection
covering:

- Active-log entry count vs archive entry count
- Curation debt: count of entries dated >180 days that lack a `Promoted` line
- Whether `Reflection log archival of promoted entries` (Path 1) GC rule
  is declared in HARNESS.md and operating
- Whether `Reflection log aged-out review` (Path 2) GC rule is declared
  (opt-in)

If Path 1 is undeclared but `Promoted` lines exist in the active log,
flag as drift — promotions are happening but archival isn't.
