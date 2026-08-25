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

### 5. Validation Checkpoint

**This step is mandatory.** The auditor writes the `## Status` block, which
is structured output with downstream parsers — `/harness-status`,
`harness-auditor` itself on its next run, and `harness-gc`. Before #575 this
command had no read-back step, and the Status block sat claiming
`Drift detected: no` against a tree with four failing constraints for twelve
days.

Read `HARNESS.md`'s `## Status` section back and verify:

1. **The four fields are present and in order** — `Last audit`,
   `Constraints enforced`, `Garbage collection active`, `Drift detected`.
2. **`Last audit` is today's date**, not the previous run's.
3. **`Constraints enforced: N/M`** — `M` equals the number of `### ` headings
   under `## Constraints` with HTML-commented blocks excluded, and `N` equals
   `M` minus the count of constraints whose `- **Enforcement**:` is
   `unverified`. Count them; do not carry the previous run's figure forward.
4. **`Drift detected`** is `yes` whenever the enforcer reported any constraint
   failing, or discovery reported a declared tool missing. A `no` beside a
   non-empty findings list is the specific failure this checkpoint exists to
   catch.
5. **The enforcement figure is qualified** wherever agent-enforced constraints
   have no dispatch path. `N/M` counts *declared* enforcement; if no CI
   workflow dispatches `harness-enforcer`, say so beside the number rather
   than leaving a reader to infer that every counted constraint can fail a
   build.

Fix deviations in place. Do not re-dispatch the auditor — a second opinion on
a number you can count yourself is slower and no more reliable.

If the Status block disagrees with the enforcer results you were given, the
enforcer results win: they were observed, and the Status block is a summary.

### 6. Present Results

Show the user:

- Enforcement ratio and breakdown
- Any drift detected (with specific details)
- Constraint pass/fail results
- Badge update summary

### 7. Recommend Actions

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

## Large-repository workflow path (Claude Code only)

On a repository above the deep-research threshold — **file count `> 300`**
— the `harness-auditor` elects its **workflow mode**: a deep-research
dynamic workflow that fans out by area, verifies each finding in a
separate context, and includes a verifier adversarial to the framework's
own assumptions (the self-audit guard; see the harness-auditor agent
doc). This path requires the **Claude Code** runtime; where the workflow
runtime is absent the auditor **falls back** to its single-context audit
and the report proceeds unchanged. The HARNESS.md Status section and badge
updates are identical on either path.
