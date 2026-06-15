---
name: cost-capture
description: Capture AI tool cost data — guide through provider dashboards, record spend and token usage, compare to previous snapshot, update MODEL_ROUTING.md
---

# /cost-capture

Capture a cost snapshot for this project's AI tool usage.

Read the `cost-tracking` skill before proceeding — it contains the
snapshot format, provider dashboard URLs, and the comparison logic.

## Process

### 1. Find Previous Snapshot

Check for existing cost snapshots:

```bash
ls observability/costs/*-costs.md 2>/dev/null | sort | tail -1
```

If a previous snapshot exists, read it for comparison. If none exist,
this is the first capture.

### 2. Ask About Providers

```text
Which AI providers are you using?

1. Anthropic only
2. OpenAI only
3. Both Anthropic and OpenAI
4. Other (specify)
```

### 3. Guide to Dashboard

For each provider, give the dashboard URL and tell the user what to
look for:

- Monthly spend for the reporting period
- Token usage (input and output) if available
- Model-level breakdown if available

Ask the user to read off the numbers. One provider at a time.

### 4. Record Model Breakdown

If the user can see per-model data:

```text
Can you see a breakdown by model? If so, list each model with
its token usage or cost.
```

If not available, skip this section.

### 5. Estimate Project Share

If the user has multiple projects on the same account:

```text
Roughly what percentage of the total spend is this project?
An estimate is fine — we're looking for order of magnitude,
not precision.
```

### 6. Compare to Previous

If a previous snapshot exists, compute and present:

- Spend change ($ and %)
- Token volume change
- Model mix changes
- Any concerning trends

### 7. Budget Check

```text
Do you have a monthly budget for AI tools?

1. Yes — what is it?
2. No — would you like to set one based on current spend?
3. Not applicable
```

If spend exceeds budget, flag it.

### 8. Update MODEL_ROUTING.md

If the cost data suggests routing changes (e.g. heavy frontier use
for tasks that could use standard models), propose updates to
MODEL_ROUTING.md. Present each change and ask for approval.

### 9. Write the Snapshot

Create `observability/costs/YYYY-MM-DD-costs.md` using the format
from the cost-tracking skill.

### 10. Validate Cost Snapshot

**This step is mandatory.** After writing the cost snapshot, read
`observability/costs/YYYY-MM-DD-costs.md` and verify it contains the
fields that `/harness-health` needs to parse for the Cost Indicators
section.

**Structural checks:**

1. File exists at the expected path
2. Period field present (date range for the snapshot)
3. Total spend field present (even if estimated)
4. Model routing reference present (whether MODEL_ROUTING.md was
   updated)

Reference the `cost-tracking` skill for the full field definitions.

If any check fails, fix the snapshot in place:

- Add missing fields with "not tracked" as the value

Do not re-run the capture conversation. Fix the output directly.

### 10b. Cost-estimate grounding advisory (informational — never gates)

Tell the human whether the prospective `cost-estimation` sibling will be
able to ground a dollar figure against the snapshot just written, and
record the outcome in the snapshot's `## Observations`.

**This advisory is informational, not a gate.** It emits **no** pass/fail
token, **never** modifies the snapshot's cost data, and **runs and prints
regardless** of the step-10 validation result — a thin snapshot is a
perfectly valid cost snapshot (it grounds spend trends regardless of
estimating-tier coverage). The only write it makes is appending the one
`Cost-estimate grounding:` line to `## Observations`.

**The check is a family-PRESENCE test, not a pricing computation.** Apply
the `cost-estimation` binding table's **family-stem + delimiter rule**
(`skills/cost-estimation/references/estimate-record-format.md`) — a
Model Breakdown key matches a stem iff it starts with the stem and the next
character is `-` or end-of-string — to detect **which estimating-tier
families are present**: is there a key matching `claude-opus-4`? a key
matching `claude-sonnet-4`? Do **not** compute rates, aggregate families,
or pick a proxy source — that is the estimator's job, kept there to avoid a
second copy of the pricing logic.

Classify into exactly one outcome, write the matching
`Cost-estimate grounding:` line to `## Observations`, and echo it:

- **both** `claude-opus-4` and `claude-sonnet-4` families present →
  `Cost-estimate grounding: grounds`. No warning.
- **one** estimating-tier family present, not both →
  `Cost-estimate grounding: proxied (<absent tier(s)>)`. INFO: "estimates
  that **exercise** the absent tier — `<Standard / Most capable>` (the
  `<claude-sonnet-4 / claude-opus-4>` family) — will be **proxied** (a
  disclosed over-estimate); estimates exercising only the present family
  ground directly. If that tier had spend the dashboard can break out,
  capturing its row would ground it directly."
- a Model Breakdown exists but **neither** estimating-tier family is
  present (e.g. only a `claude-haiku-4` row — a valid breakdown entry, but
  Haiku is **not** an estimating tier) →
  `Cost-estimate grounding: omitted (no estimating-tier family)`. WARN:
  "prospective `/cost-estimate` will **omit cost** — no opus-4 or sonnet-4
  family present. If these are a newer model generation, the binding stem
  table needs updating for it."
- **no Model Breakdown** was recorded (step 4 skipped) →
  `Cost-estimate grounding: omitted (no per-model breakdown)`. INFO: "no
  per-model breakdown recorded, so prospective `/cost-estimate` cannot
  ground cost — a **structural** gap, not a family mismatch. Record
  per-model rows **if your dashboard exposes them**."

**Honesty: do not nudge fabricated rows.** Distinguish *thin because
per-model data was not recorded/available* (actionable — record it) from
*thin because the period's work genuinely used only some tiers* (**not** a
defect — say "no `<tier>` spend this period; nothing to do"). **Never**
suggest adding a model row for spend that did not occur. Do **not** put a
GitHub issue number in the advisory text.

### 11. Commit

```bash
mkdir -p observability/costs
git add observability/costs/ MODEL_ROUTING.md
git commit -m "Cost snapshot: YYYY-MM-DD"
```

### 12. Summary

```text
Cost snapshot captured: observability/costs/YYYY-MM-DD-costs.md

  Period: YYYY-MM to YYYY-MM
  Total spend: $X,XXX
  Monthly average: $X,XXX
  Trend: [increasing/stable/decreasing vs previous]
  Budget status: [within/over/not set]
  MODEL_ROUTING.md: [updated/unchanged]
  Cost-estimate grounding: [grounds / proxied (<absent tiers>) / omitted (no estimating-tier family) / omitted (no per-model breakdown)]
```
