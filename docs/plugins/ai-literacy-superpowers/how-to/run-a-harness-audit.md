---
title: Run a Harness Audit
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 4
redirect_from:
  - /how-to/run-a-harness-audit/
  - /how-to/run-a-harness-audit.html
---

# Run a Harness Audit

Run `/harness-audit` to produce a full meta-verification of the harness and generate
a health snapshot with trend data.

---

## 1. Run the audit command

```text
/harness-audit
```

The audit agent checks four things:

1. Every `deterministic` constraint has a working enforcement mechanism
2. No constraint has silently drifted to advisory in practice
3. The GC rules are configured and have run within their declared cadence
4. The snapshot currency is within 30 days

---

## 2. Review the snapshot output

The audit writes a timestamped snapshot to your project. It includes:

- **Constraint inventory**: each constraint with its current enforcement status
- **Cadence compliance**: whether audit, GC, and reflection reviews are on schedule
- **Trend section**: deltas from the previous snapshot (if one exists)
- **Meta-health checks**: five signals that indicate whether the harness itself is working

The five meta-health checks are:

| Check | What it means if stale or failing |
| ----- | ---------------------------------- |
| Snapshot currency | The outer loop is not running |
| Cadence compliance | Declared practices are not being followed |
| Learning flow | Compound learning from sessions is broken |
| GC effectiveness | GC rules may be misconfigured or never firing |
| Trend direction | Architectural drift is going unnoticed |

---

## 3. Check the README health badge

After the audit, `/harness-audit` updates the README health badge. Confirm the badge
colour reflects the current state:

| Colour | Condition |
| ------ | --------- |
| Green | All layers operating, no overdue cadences |
| Amber | One layer degraded or outer loop overdue |
| Red | Multiple layers degraded or no snapshot in 30+ days |

If the badge is amber or red, address the flagged items before the next session.

---

## 4. Resolve flagged constraints

If the audit flags constraints as unverified in practice:

1. Open `HARNESS.md` and locate the constraint
2. Run its `Tool` command manually to confirm it works:

   ```bash
   # Run whatever tool command is declared in the Tool field
   gitleaks detect --source . --no-banner
   ```

3. If the tool is missing or broken, either fix the tool or demote the enforcement
   field from `deterministic` to `unverified` until the tool is restored
4. Re-run `/harness-audit` to confirm the constraint passes

---

## 5. Set up a recurring cadence

The audit is most useful on a regular schedule. Add the cadence to `CLAUDE.md`:

```markdown
## Operating Cadence

- Monthly: run `/harness-health` to generate a health snapshot
- Quarterly: run `/harness-audit` for full meta-verification
- Quarterly: run `/assess` to re-assess AI literacy level
```

A Stop hook in the plugin nudges you when the last snapshot is older than 30 days.

---

## 6. Run a deep check when the harness feels stale

For a more thorough investigation than the standard audit:

```text
/harness-health --deep
```

For a multi-period trend view across all stored snapshots:

```text
/harness-health --trends
```

Use `--trends` at the start of quarterly reviews to see whether constraint coverage
and enforcement ratios have improved or declined over time.
