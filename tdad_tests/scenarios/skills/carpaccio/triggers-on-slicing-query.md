---
component: carpaccio
component_type: skill
tier: trigger
---

# Scenario: carpaccio skill triggers on slicing-related queries

## Given

A Claude session with the ai-literacy-superpowers plugin loaded — so
all skill descriptions, including `carpaccio`, are available for
matching.

## When

Each of the following user queries is sent to the model in isolation:

- "Slice this task into smaller pieces before I commit to spec-writing"
- "Apply the cadence governor to this issue before we start work"
- "Can you carpaccio-slice this proposal?"
- "I need to break this multi-decision task into thin, end-to-end pieces"
- "Use the Elephant Carpaccio discipline on this work item"

## Then

For each query, the model should identify `carpaccio` as the skill
to invoke. At minimum: the skill should appear in the list of skills
the model says it would load to handle the request.

The fourth query (which paraphrases the discipline without using the
agent name) is the hardest — it tests whether the description carries
the concept ("multi-decision", "thin", "end-to-end") rather than only
the literal token "carpaccio". The fifth query references the
intellectual lineage (Cockburn) and tests whether the description
makes that connection discoverable.

## Rubric

A single inference suffices: hand the model the plugin's skill
descriptions and the query, ask "which skills would you invoke for
this query?", and parse the response. No fixture state needed.

## Implementation note

The runner that fulfils this scenario should:

1. Load every skill's frontmatter into a description list
2. For each query above, send a structured prompt asking the model
   to identify the matching skills
3. Assert that `carpaccio` appears in the response

This catches description-drift early: if a future edit waters down the
skill's `description:` line until the cadence-governor framing
disappears, this scenario will fail and surface the regression before
it ships.
