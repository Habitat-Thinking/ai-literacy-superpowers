---
title: Track AI Costs
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 25
redirect_from:
  - /how-to/track-ai-costs/
  - /how-to/track-ai-costs.html
---

# Track AI Costs

Capture AI tool spending data and integrate it into your health
snapshots and model routing decisions.

---

## Prerequisites

- A MODEL_ROUTING.md file (run `/harness-init` or copy from
  `templates/MODEL_ROUTING.md` if you don't have one)
- Access to your AI provider's billing dashboard

---

## 1. Run the cost capture command

```text
/cost-capture
```

The command guides you through checking your provider dashboards and
recording the data. It asks for:

- Which providers you use (Anthropic, OpenAI, others)
- Monthly spend for the reporting period
- Token usage by model (if available)
- Project share estimate (if multiple projects on one account)

---

## 2. Check your provider dashboard

The command gives you the URL for each provider:

- **Anthropic**: `https://console.anthropic.com/settings/billing`
- **OpenAI**: `https://platform.openai.com/usage`

Look for monthly spend, token usage breakdown, and any model-level
detail. Read the numbers to the command when prompted.

---

## 3. Review the comparison

If you have a previous cost snapshot, the command computes:

- Spend change (dollar amount and percentage)
- Token volume change
- Model mix shifts
- Whether you're within budget

If this is your first capture, there's nothing to compare yet — the
next quarterly capture will show the trend.

---

## 4. Set a budget (optional)

The command asks whether you have a monthly AI budget. If not, it
offers to suggest one based on current spend. A budget turns cost
tracking from observation into a guardrail — the health snapshot will
flag when spend exceeds it.

---

## 5. Review MODEL_ROUTING.md updates

If the cost data suggests routing changes — for example, heavy
frontier model use on tasks that could use standard models — the
command proposes updates to MODEL_ROUTING.md. Each change is
presented for your approval before being applied.

---

## 6. Find the output

The cost snapshot is saved to:

```text
observability/costs/YYYY-MM-DD-costs.md
```

The next `/harness-health` run reads this file and populates the
Cost Indicators section of the health snapshot.

---

## 7. Keep it current

Run `/cost-capture` quarterly, aligned with `/assess`:

1. Run `/assess` (quarterly)
2. Run `/cost-capture` (same session)
3. Run `/harness-health` (reads both)

Over time, the cost snapshots build a spending trend that informs
model routing decisions and budget conversations.
