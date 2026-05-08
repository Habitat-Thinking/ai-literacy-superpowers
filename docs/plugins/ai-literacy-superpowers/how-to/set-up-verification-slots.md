---
title: Set Up Verification Slots
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 18
redirect_from:
  - /how-to/set-up-verification-slots/
  - /how-to/set-up-verification-slots.html
---

# Set Up Verification Slots

Integrate a deterministic tool into a harness constraint so the enforcer
can run it automatically at commit time and in CI.

---

## 1. Understand the slot contract

Every constraint in HARNESS.md is backed by a verification slot. The
enforcer reads each constraint and dispatches verification based on its
`enforcement` field:

| Enforcement | What happens |
| --- | --- |
| `deterministic` | Execute the `tool` command; interpret exit code |
| `agent` | Read the rule text; review files; produce findings |
| `deterministic + agent` | Run both; merge findings |
| `unverified` | Skip — log as unchecked |

The slot contract is always the same regardless of what backs it:

- **Input:** constraint definition, scope, and file set
- **Output:** `pass` or `fail` with a list of `{file, line, message}` findings

---

## 2. Choose a tool for the slot

Identify a tool that checks your constraint — a linter, formatter,
scanner, or custom script. Confirm it runs locally and exits non-zero on
violations:

```bash
# Example: run ESLint on staged files
npx eslint --max-warnings 0 src/

# Example: run Prettier in check mode
npx prettier --check "src/**/*.ts"

# Example: run a custom script
./scripts/check-no-console.sh
```

The tool must:

- Accept a file path or directory as an argument, or scan by default
- Exit `0` on pass, non-zero on failure
- Produce output that helps a developer understand what to fix

---

## 3. Update the constraint in HARNESS.md

Open `HARNESS.md` and find the constraint row to harden. Change the
`enforcement` field to `deterministic` and set the `tool` field to the
exact command the enforcer will run:

```markdown
<!-- Before: agent or unverified -->
| No console.log in production code | AGENT | prose rule | none |

<!-- After: deterministic -->
| No console.log in production code | DETERMINISTIC | ESLint no-console | npx eslint --max-warnings 0 src/ |
```

If the constraint does not yet exist, run `/harness-constrain` to add it
through the guided flow, then edit the enforcement details by hand.

---

## 4. Run `/harness-audit` to confirm the slot works

```bash
/harness-audit
```

The audit agent reads every constraint, executes deterministic tools, and
reports whether each slot produces a usable result. Look for your
constraint in the output:

```text
Constraint: No console.log in production code
  Enforcement: deterministic
  Tool: npx eslint --max-warnings 0 src/
  Result: PASS (exit 0)
```

If the tool fails to run, the audit reports the error. Fix the command
and re-run the audit until the slot reports cleanly.

---

## 5. Set up mixed enforcement (optional)

Some constraints benefit from both a deterministic check and an agent
review. For example, a linter can verify that doc comments exist while an
agent reviews whether those comments explain the reasoning rather than
restating the signature.

Set the `enforcement` field to `deterministic + agent` and list both tools:

```markdown
| Doc comments explain reasoning | DETERMINISTIC + AGENT | ESLint + agent review | npx eslint --rule 'valid-jsdoc: error' src/ |
```

The enforcer runs both, merges the findings, and reports a combined
result.

---

## 6. Verify enforcement timing

Slots run at three timescales. Check that your constraint appears at the
right level:

| Loop | Trigger | Strictness |
| --- | --- | --- |
| Inner | PreToolUse hook | Advisory |
| Middle | CI on PR | Strict |
| Outer | Scheduled GC + audit | Investigative |

Run `/harness-status` to confirm the constraint is active in the correct
enforcement tier:

```bash
/harness-status
```

The output shows each constraint with its enforcement type and last
verification result.

---

## Summary

After completing these steps you have:

- A deterministic tool wired into a constraint's verification slot
- Confirmation via `/harness-audit` that the slot runs and produces results
- The constraint enforced at the appropriate timing tiers
- A clear path to mixed enforcement if the constraint also benefits from
  agent-based review
