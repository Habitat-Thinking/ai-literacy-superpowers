---
component: cost-estimation
component_type: skill
tier: trigger
---

# Scenario: cost-estimation fires on prospective-cost queries and not on retrospective-capture queries

## Given

A Claude session with the ai-literacy-superpowers plugin loaded — so all
skill descriptions, including `cost-estimation` and its retrospective
sibling `cost-tracking`, are available for matching.

The `cost-estimation` skill is the **prospective** counterpart to the
**retrospective** `cost-tracking` skill / `/cost-capture` command (spec
§6.5, §10.6; `FR-10`). The two reuse the same `observability/costs/`
data: `cost-tracking` *writes* the snapshots, `cost-estimation` *reads*
them as its $/token ground. The pair must be discoverable from either
half — a reader who finds one should find the other — but a
**prospective** query ("how much will this cost") must route to
`cost-estimation`, and a **retrospective** query ("record what we spent")
must route to `cost-tracking`.

## When

Each of the following user queries is sent to the model in isolation.

Prospective queries that SHOULD fire `cost-estimation`:

- "How much will this feature cost to build?"
- "Estimate the tokens for this spec before we start."
- "What will this slice cost to build?"
- "Predict the agent-compute time for this task before I commit."

Retrospective queries that should fire `cost-tracking` and NOT
`cost-estimation`:

- "Record our Anthropic spend for the quarter."
- "Capture the quarterly cost snapshot from the provider dashboard."

## Then

For each **prospective** query, the model should identify
`cost-estimation` as the skill to invoke — at minimum, `cost-estimation`
appears in the list of skills the model says it would load.

For each **retrospective** query, the model should identify
`cost-tracking` (not `cost-estimation`) as the skill to invoke —
`cost-estimation` must NOT appear, because recording observed spend is
the sibling's job.

The fourth prospective query ("predict the agent-compute time…")
paraphrases the prospective intent without using the word "cost"; it
tests whether the description carries the broader prospective-estimate
concept (tokens, time, before-the-work) rather than only the literal
token "cost".

## Rubric

A single inference suffices per query: hand the model the plugin's skill
descriptions and the query, ask "which skills would you invoke for this
query?", and parse the response. No fixture state needed.

The discriminating signal this scenario protects is the
**prospective-vs-retrospective** boundary in the `cost-estimation`
`description:` line. If a future edit waters the description down until
it no longer distinguishes "estimate before" from "record after", the
retrospective queries will begin to match `cost-estimation` and this
scenario will fail — surfacing the regression before it ships.

## Implementation note

The runner should:

1. Load every skill's frontmatter `description` into a list.
2. For each query, ask the model to identify the matching skills.
3. Assert `cost-estimation` appears for the prospective queries and is
   absent for the retrospective queries (where `cost-tracking` should
   appear instead).
