---
name: cost-tracking
description: Use when the user wants to capture AI tool costs, review spending trends, set cost budgets, or integrate cost data into health snapshots — guides quarterly cost capture, records data in a structured format, and updates MODEL_ROUTING.md with observed cost patterns
---

# Cost Tracking

Capture, record, and track AI tool costs over time. Cost data feeds
into health snapshots and informs model routing decisions.

This skill does not access billing APIs directly — it guides the user
through checking their provider dashboards and recording the data in
a structured format that the plugin can read.

## Why Track Costs

Without cost data:

- MODEL_ROUTING.md routing rules are theoretical
- The break-even calculation for self-hosting is impossible
- Cost per PR/feature is unknown — no way to optimise
- Budget conversations happen without evidence

With cost data:

- Routing rules are validated against actual spend
- Self-hosting decisions are grounded in real numbers
- Cost trends reveal whether AI adoption is efficient
- Budget conversations have receipts

## Two actuals records: the quarterly snapshot and the per-PR record

This skill owns **two** actuals formats under `observability/costs/`:

- **The quarterly snapshot** (below) — a **provider-level aggregate** of spend and
  tokens across all work for a billing period, captured by `/cost-capture`.
- **The per-PR actuals record** — a **single-task** structural footprint (which
  stages ran, review cycles, files) plus human-supplied token/cost figures when
  available, written by the integration-agent at merge time and read by the
  `cost-estimator` as a `kind: calibration` source. It lives under
  `observability/costs/per-pr/` and is defined in
  [`references/per-pr-actuals-format.md`](references/per-pr-actuals-format.md).
  The two never share a file or directory.

## The Cost Snapshot

Cost data is captured in `observability/costs/YYYY-MM-DD-costs.md`.
Each file records one capture session (typically quarterly).

### Format

```markdown
# Cost Snapshot — YYYY-MM-DD

## Provider Spend

| Provider | Period | Spend | Tokens (input) | Tokens (output) |
| --- | --- | --- | --- | --- |
| Anthropic | YYYY-MM to YYYY-MM | $X,XXX | XXM | XXM |
| OpenAI | YYYY-MM to YYYY-MM | $X,XXX | XXM | XXM |

## Model Breakdown (if available)

| Model | Tokens (input) | Tokens (output) | Estimated cost |
| --- | --- | --- | --- |
| claude-sonnet-4 | XXM | XXM | $XXX |
| claude-opus-4 | XXM | XXM | $XXX |
| claude-haiku-4 | XXM | XXM | $XXX |

## Per-Project Estimate

| Project/Repo | Estimated share | Rationale |
| --- | --- | --- |
| ai-literacy-superpowers | XX% | Primary development repo |
| ai-literacy-exemplar | XX% | Secondary, used for testing |

## Observations

- [Any patterns noticed — cost spikes, model tier shifts, etc.]
- Cost-estimate grounding: grounds | proxied (<absent tier(s)>) | omitted (no estimating-tier family) | omitted (no per-model breakdown)

## Budget Status

- Monthly budget: $X,XXX (or "not set")
- Current monthly average: $X,XXX
- Trend: increasing / stable / decreasing
- Action needed: yes / no
```

### Estimating-tier coverage and the `cost-estimation` sibling

A captured snapshot's **Model Breakdown coverage** determines whether the
prospective `cost-estimation` sibling can ground a dollar figure. The
estimator binds its routing tiers to **model families** by stem
(`claude-opus-4` → Most capable, `claude-sonnet-4` → Standard; see the
`cost-estimation` binding table). So:

- a breakdown containing an opus-4 **and** a sonnet-4 family row grounds
  estimates directly;
- a breakdown with only one of them grounds, but **proxies** the absent
  tier (a disclosed over-estimate);
- a breakdown with **neither** (e.g. only a `claude-haiku-4` row — a valid
  breakdown entry, but Haiku is **not** an estimating tier) means estimates
  **omit** cost; and a snapshot with no Model Breakdown at all omits for a
  structural reason.

`/cost-capture` reports which of these applies at capture time and records
it in the `Cost-estimate grounding:` Observations line above, so the gap is
visible when a human can act on it — not discovered estimate-by-estimate.

## Process

### Step 1: Check Provider Dashboards

Guide the user to their billing pages:

**Anthropic:**

```text
Check your usage at: https://console.anthropic.com/settings/billing
Look for: monthly spend, token usage by model, usage over time
```

**OpenAI:**

```text
Check your usage at: https://platform.openai.com/usage
Look for: monthly spend, model breakdown, daily usage chart
```

**Other providers:** Ask the user where to find their billing data.

### Step 2: Record the Data

Create `observability/costs/YYYY-MM-DD-costs.md` using the format
above. Ask the user for each field:

1. Which providers are in use?
2. What was the spend for the period?
3. Can they break it down by model? (Not always available)
4. Which projects consumed the most? (Estimate if not precise)

### Step 3: Compare to Previous Snapshot

If a previous cost snapshot exists in `observability/costs/`, read it
and compute:

- Spend delta ($ and %)
- Token volume delta
- Model mix changes
- Cost per token trend

### Step 4: Update MODEL_ROUTING.md

If the cost data reveals patterns that should change routing:

- High spend on frontier models for tasks that could use standard →
  suggest updating the Agent Routing table
- Consistent use below the self-hosting break-even → note that
  cloud is still optimal
- Spend above budget → flag which model tier is the driver

Update the Sovereignty Considerations section with observed data.

### Step 5: Update Health Snapshot

The next `/harness-health` run will read the latest cost snapshot
and populate the Cost Indicators section. The skill does not update
the snapshot directly — it produces the cost data file that the
snapshot reads.

### Step 6: Commit

```bash
mkdir -p observability/costs
git add observability/costs/YYYY-MM-DD-costs.md MODEL_ROUTING.md
git commit -m "Cost snapshot: YYYY-MM-DD ($X,XXX monthly average)"
```

## Cadence

Quarterly, aligned with the assessment cadence. The recommended
workflow:

1. Run `/assess` (quarterly)
2. Run `/cost-capture` (same session or same week)
3. Run `/harness-health` (reads both)
4. Review the portfolio dashboard (shows cost trends if available)

## What This Skill Does NOT Do

- Access billing APIs directly (the user reads their dashboard)
- Make routing changes without user approval
- Require exact per-project attribution (estimates are fine)
- Replace financial tooling (this is engineering visibility, not
  accounting)
