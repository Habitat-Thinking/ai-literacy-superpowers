---
component: spec-writer
component_type: agent
tier: behavioural
fixture: empty-repo
---

# Scenario: spec-writer creates a spec with acceptance scenarios

## Given

An empty repository with:

- No `specs/` directory
- A minimal `CLAUDE.md` declaring spec-first discipline
- A minimal `AGENTS.md` (so the agent's "read AGENTS.md first" step
  succeeds without erroring)

The agent is invoked with:

- A feature description: *"Add user authentication with email and
  password, with rate-limited login attempts."*
- A target spec path: `specs/auth/spec.md`

## When

The spec-writer agent runs to completion.

## Then

After the agent finishes:

- File `specs/auth/spec.md` exists
- The file contains a section named "User Story" or "User Stories"
- The user story follows the form: *As a [role], I want [capability]
  so that [value]*
- The file contains acceptance scenarios in Given/When/Then format
- At least one scenario covers the rate-limiting behaviour
- The file contains numbered functional requirements (FR-001, FR-002,
  ...) that flow from the scenarios

## Rubric

For LLM-as-judge on the assertions that resist exact matching:

- *Are the acceptance scenarios testable in principle?* Each Then
  clause should be checkable mechanically (a specific HTTP status, a
  specific log entry, a specific database state) — not an opinion
  ("the user should feel safe").
- *Do the functional requirements trace to the scenarios?* Each FR
  should be visible in at least one scenario's Then clause.
- *Is the rate-limiting behaviour both in a scenario and in an FR?*
  This is the single most likely thing the agent will partially miss.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

The runner that fulfils this scenario should:

1. Copy the empty-repo fixture to a temp directory
2. Use `claude_agent_sdk.ClaudeSDKClient` to run a single-agent
   session with the spec-writer agent's frontmatter as the system
   prompt and tools list
3. Send the feature description as the user message
4. After the run, read the produced `spec.md` and apply the
   assertions above
5. For rubric assertions, dispatch a separate "judge" model call
   with the spec contents and the rubric criteria, expecting a
   structured pass/fail per criterion
