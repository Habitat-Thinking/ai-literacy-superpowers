---
title: Configure Observability
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 35
redirect_from:
  - /how-to/configure-observability/
  - /how-to/configure-observability.html
---

# Configure Observability

Set snapshot cadence, operating targets, health thresholds, and regression detection in HARNESS.md.

---

## 1. Open the Observability section

Locate `## Observability` in your HARNESS.md file. The section contains three subsections:

- Operating cadence
- Health thresholds
- Regression detection

---

## 2. Set snapshot cadence

Choose how often snapshots are collected. Edit this line under the Observability section:

```yaml
- Snapshot cadence: monthly
```

Options:

- **Weekly**: 10-day staleness threshold. Recommended for Observatory corpus projects.
- **Fortnightly**: 21-day staleness threshold.
- **Monthly**: 30-day staleness threshold. Default.

---

## 3. Configure operating cadence targets

Set target frequencies for each harness activity. Update these four lines:

```yaml
- Harness audit (/harness-audit): quarterly (90 days)
- AI literacy assessment (/assess): quarterly (90 days)
- Reflection review and promotion: monthly (30 days)
- Cost capture (/cost-capture): quarterly (90 days)
```

Adjust the frequency (daily, weekly, monthly, quarterly) and the number of days to match your team's workflow.

---

## 4. Tune health thresholds

Adjust these four thresholds to determine when the health status moves from Healthy to Attention to Degraded:

```yaml
- Minimum enforcement ratio for Healthy: 70%
- Consecutive zero-finding GC snapshots before alert: 3
- Unpromoted reflection age before learning flow is stalled: 60 days
- Consecutive declining trend snapshots before alert: 3
```

Lower the thresholds to alert earlier; raise them to reduce noise.

---

## 5. Set regression detection thresholds

Configure when the regression flag fires:

```yaml
- Cadence non-compliance threshold: 2 or more activities overdue
- Reflection drought threshold: 4 consecutive weeks with zero reflections
```

---

## 6. Verify

Run the health check command to generate a snapshot using the new settings:

```bash
/harness-health
```

Check the Meta section of the output to confirm the thresholds are applied correctly.

---

## Prerequisites

HARNESS.md must exist with an Observability section. If not, create it with:

```bash
/harness-init
```

---

## What you have now

Customized observability settings that match your team's cadence and risk tolerance.

---

## Next steps

- Run `/harness-health` regularly to monitor snapshot health
- Explore the harness-observability skill for deeper configuration
- Adjust thresholds based on team feedback
