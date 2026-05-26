---
component: carpaccio
component_type: agent
tier: behavioural
fixture: empty-repo
---

# Scenario: carpaccio slices a multi-decision task

## Given

An empty repository with:

- No `docs/superpowers/slices/` directory
- A minimal `CLAUDE.md`
- A minimal `AGENTS.md`

The agent is invoked with a task description that contains three
clearly distinct decision points:

> *"Add a search feature to the docs site. It needs to (1) index
> the existing pages, (2) expose a search UI in the top nav, and
> (3) ship a relevance ranking that handles synonyms."*

## When

The carpaccio agent runs to completion.

## Then

The agent returns slicing-record content (the orchestrator writes
the file). The returned content must:

- Have frontmatter with `inseparable: false`
- Have `slices` array length ≥ 2 and ≤ 9
- Have at least one slice with `lens_used: decision-boundary`
- Have every slice's `disposition: pending`
- Have every slice's `disposition_rationale: null`
- Have every slice's `file_as_issue: pending`
- Have every slice's `issue_url: null`
- Contain a `## Explicitly not slicing on` prose section with
  ≥ 3 entries

## Rubric

For LLM-as-judge on the assertions that resist exact matching:

- *Do the slices each address a distinguishable decision?* Each
  slice's `decision_focus` should be a concrete decision the
  human will engage with, not a paraphrase of the task.
- *Is each slice's `scope` end-to-end?* The scope should
  describe something a user (or downstream consumer) could
  observe, not an internal step.
- *Is the slicing defensible?* The `## Explicitly not slicing
  on` section should name dimensions actually considered.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

The runner that fulfils this scenario should:

1. Copy the empty-repo fixture to a temp directory
2. Use `claude_agent_sdk.ClaudeSDKClient` to run a
   single-agent session with the carpaccio agent's
   frontmatter as the system prompt and tools list
3. Send the task description above as the user message
4. After the run, parse the returned content as YAML +
   markdown and apply the assertions above
5. For rubric assertions, dispatch a separate "judge"
   model call with the slicing record and the rubric
   criteria
