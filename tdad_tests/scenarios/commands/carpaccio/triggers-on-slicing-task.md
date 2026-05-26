---
component: carpaccio
component_type: command
tier: trigger
---

# Scenario: /carpaccio command triggers on slicing-related task framing

## Given

A Claude session with the ai-literacy-superpowers plugin loaded — so
all slash-command descriptions, including `/carpaccio`, are available
for matching against user intent.

## When

Each of the following user statements is sent to the model in isolation:

- "I want to slice this task before any spec ceremony begins"
- "Run the cadence governor on this issue body"
- "Carpaccio-slice this work item before spec-writer"
- "Cut this multi-decision task into thin pieces for human review"
- "Apply Elephant Carpaccio to this issue"

## Then

For each statement, the model should identify `/carpaccio` as the
appropriate command to invoke. At minimum: the command should appear
in the list of slash commands the model says it would suggest or run.

The fourth query (paraphrasing the discipline without naming the
command) is the hardest — it tests whether the command's `description:`
carries the concept rather than only the literal token.

## Rubric

A single inference suffices: hand the model the plugin's command
descriptions and the query, ask "which slash command would you run
for this task?", and parse the response. No fixture state needed.

## Implementation note

The runner that fulfils this scenario should:

1. Load every command's frontmatter into a description list
2. For each query above, send a structured prompt asking the model
   to identify the matching command
3. Assert that `/carpaccio` appears in the response

This is the cheapest signal that the command's description has not
drifted away from its purpose. If the description is later edited to
narrow the framing (e.g., only mentioning "orchestrator step 0" and
dropping the cadence-governor language), this scenario will fail and
surface the regression.
