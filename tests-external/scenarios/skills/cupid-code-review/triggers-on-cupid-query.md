---
component: cupid-code-review
component_type: skill
tier: trigger
---

# Scenario: cupid-code-review triggers on CUPID-related queries

## Given

A Claude session with the ai-literacy-superpowers plugin loaded — so
all skill descriptions, including `cupid-code-review`, are available
for matching.

## When

Each of the following user queries is sent to the model in isolation:

- "Review my code against CUPID"
- "Can you do a CUPID-style code review on this module?"
- "What CUPID violations do you see in this class?"
- "Apply the CUPID lens to this file"
- "Refactor this for better composability and predictability"

## Then

For each query, the model should identify `cupid-code-review` as the
skill to invoke. At minimum: the skill should appear in the list of
skills the model says it would load to handle the request.

The fifth query (which mentions two CUPID properties by name without
saying "CUPID") is the hardest. It should still match — but if it does
not, the failure is informative: it tells us the description over-relies
on the literal token "CUPID" rather than the underlying concepts. Either
outcome is useful; the test asserts the easier majority.

## Rubric

A single inference suffices: hand the model the plugin's skill
descriptions and the query, ask "which skills would you invoke for
this query?", and parse the response. No fixture state needed.

## Implementation note

The runner that fulfils this scenario should:

1. Load every skill's frontmatter into a description list
2. For each query above, send a structured prompt asking the model
   to identify the matching skills
3. Assert that `cupid-code-review` appears in the response

This is one of the cheapest tests in the suite (single inference, no
multi-turn, no fixture) and one of the most informative — description
drift is the failure mode that hides best.
