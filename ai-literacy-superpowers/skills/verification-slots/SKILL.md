---
name: verification-slots
description: This skill should be used when the user asks about "verification slots", "integrating a linter", "adding a deterministic tool", "harness-enforcer", "constraint enforcement interface", "wrapping a tool", or needs the technical reference for how deterministic and agent-based checks work in the harness framework.
---

# Verification Slots

The verification slot is the harness framework's core technical
abstraction. Every constraint — whether backed by a linter, a formatter,
a structural test, or an LLM agent — is checked through the same
interface. This uniformity means the rest of the system (hooks, CI,
commands) does not care how a constraint is verified.

## The Contract

**Input:**

- Constraint definition (rule, enforcement type, tool)
- Scope (commit, pr, weekly, manual)
- File set (changed files, or all files)

**Output:**

- Result: `pass` or `fail`
- Findings: list of `{file, line, message}` (empty on pass)

## How the Enforcer Decides

The `harness-enforcer` agent reads each constraint from HARNESS.md and
dispatches verification based on the `enforcement` field:

| Enforcement | What happens |
| --- | --- |
| `deterministic` | Execute the `tool` command, interpret exit code |
| `agent` | Read the `rule` text, review files, produce findings |
| `deterministic + agent` | Run both, merge findings |
| `unverified` | Skip — log as unchecked |

## Deterministic Tool Integration

To fill a verification slot with a deterministic tool:

1. Identify a tool that checks the constraint (linter, formatter,
   scanner, custom script)
2. Verify it runs locally and produces usable output
3. Update the constraint in HARNESS.md: set `enforcement` to
   `deterministic` and `tool` to the exact command
4. Run `/harness-audit` to confirm the tool works in the harness
   context

For detailed integration patterns for common tools (ESLint, Prettier,
gitleaks, ArchUnit, custom scripts), consult
`references/tool-integration.md`.

## Agent-Based Verification

When no deterministic tool exists, the enforcer reads the constraint's
prose rule and reviews code against it. The output format is identical
to deterministic verification — pass/fail with file:line findings.

Agent-based checks are:

- **Flexible** — work with any constraint that can be described in prose
- **Non-deterministic** — may give different results on identical input
- **Token-intensive** — each check costs LLM inference
- **Nuance-aware** — can evaluate intent and context, not just syntax

## Mixed Enforcement

Some constraints benefit from both levels. For example, a linter checks
that doc comments exist (deterministic presence check) while the agent
reviews that comments explain reasoning rather than restating signatures
(quality check).

Use `deterministic + agent` in the enforcement field and list both tools.

## The Fan-out Slot

The **fan-out slot** is a first-class agent-backed verification slot for
large harnesses (Claude Code runtime only). Instead of one context
checking every constraint — where the enforcer tends to tire and report
"all constraints checked" after checking only some — the fan-out slot
spawns **one verifier subagent per rule**, each with a single constraint
and a clean context window, then passes every candidate violation through
a **skeptic** persona that tries to refute it before it reaches the
report.

A **synthesis barrier** waits for all N verifiers to return and reconciles
their results into the same uniform contract every slot produces:
**pass/fail with `{file, line, message}` findings**. Because the report
cannot form until every verifier has returned, the count of results
equals the count of enforceable constraints — no rule is silently
dropped. The slot is read-only and propose-only (INV-1): it reports
findings and never writes a durable artefact.

The `harness-enforcer` agent elects this slot automatically when the
enforceable-constraint count exceeds its threshold (default 8); below it,
the single-context path is used unchanged. The slot adapts the shipped
`enforcer-fanout.workflow.js` template from the `dynamic-workflows` skill.

## Additional Resources

### Reference Files

- **`references/tool-integration.md`** — Step-by-step integration
  patterns for linters, formatters, type checkers, secret scanners,
  structural test frameworks, and custom scripts
