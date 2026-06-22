---
component: dynamic-workflows
component_type: skill
tier: trigger
---

# Scenario: dynamic-workflows triggers on workflow-election queries (AC-6)

## Given

A Claude session with the ai-literacy-superpowers plugin loaded — so all
skill descriptions, including `dynamic-workflows`, are available for matching.

## When

Each of the following user queries is sent to the model in isolation:

- "Should I use a workflow or a multi-agent harness for this task?"
- "This task would benefit from running several isolated subagents in
  parallel — how should I structure that?"
- "What dynamic-workflow pattern fits a fan-out-and-synthesize problem?"
- "Set up adversarial verification with a separate reviewer context for this
  change"
- "When is it worth spawning ephemeral subagents instead of doing this in one
  pass?"
- "How does the `ultracode` trigger relate to self-authored multi-agent
  harnesses?"

## Then

For each query, the model should identify `dynamic-workflows` as a skill to
invoke. At minimum the skill should appear in the list of skills the model
says it would load to handle the request.

The second and fifth queries are the hardest: they paraphrase the trigger
condition ("parallel, isolated subagents", "when is it worth spawning
ephemeral subagents") without using the skill name or the literal word
"workflow" — testing whether the `description` carries the *concept* (the
ephemeral multi-agent substrate and the election decision) rather than only
literal tokens.

## Rubric

A single inference suffices: hand the model the plugin's skill descriptions
and the query, ask "which skills would you invoke for this query?", and parse
the response. No fixture state needed. This is AC-6 / FR-1's trigger surface.

This catches description-drift early: if a future edit waters down the
`description:` line until the multi-agent-substrate / election framing
disappears, this scenario fails and surfaces the regression before it ships.

## Distinction from sibling knowledge skills

`harness-engineering` and `context-engineering` are also knowledge skills,
and their descriptions overlap on the word "harness". The distinction the
`dynamic-workflows` description must make discoverable:

- `harness-engineering` answers "what is a harness / the conceptual
  foundation of the plugin" — the *static* harness as a whole.
- `context-engineering` answers "how do I write conventions / the Context
  section of HARNESS.md" — curating the knowledge an LLM reads.
- `dynamic-workflows` is specifically about the **ephemeral multi-agent
  substrate** beneath the static agents and the **election rubric** for *when*
  to spend compute on a workflow versus the static pipeline.

A query about "should I spin up parallel subagents / which workflow pattern /
when is a workflow warranted" must resolve to `dynamic-workflows`, not to its
two siblings.
