---
name: carpaccio
description: Run the carpaccio agent (cadence governor) on a task description — produces a slicing record at docs/superpowers/slices/<task-slug>.md; use at orchestrator step 0 or before spec-writer when running manually
---

# /carpaccio \<task-description-or-issue-ref\>

Run the carpaccio agent against a task description and write the
structured slicing record. Use at orchestrator step 0 (the
orchestrator invokes this automatically) or stand-alone before
spec-writer when running the pipeline manually.

## When to use

- Automatically via the orchestrator at step 0
- Manually before `/spec-writer` when running the pipeline by hand
- When a task description is substantively edited after a prior
  slicing record exists (regenerates the record — old dispositions
  are lost; this is intentional, matching the diaboli/cartographer
  patterns)
- When you want a slicing check on a task before committing to the
  full pipeline

## Process

### 1. Validate input

Confirm a task description was supplied. If the argument is a
GitHub issue reference (e.g., `#326`), fetch the issue body via
`gh issue view <N> --json body --jq .body`. Otherwise treat the
argument as the task description directly.

If neither is supplied, abort with:

```text
Error: no task description supplied. Pass an issue reference (#NN) or a task description string.
```

### 2. Derive the slug

For an issue reference, use the issue's branch name when available,
otherwise kebab-case the issue title. For a free-text task, kebab-
case a short summary derived from the first sentence.

Output path: `docs/superpowers/slices/<task-slug>.md`

### 3. Dispatch the carpaccio agent

Pass the task description (and the prior slicing record, if any, on
re-dispatch). The agent reads the task, applies the lenses, and
returns the full slicing-record content. Do not pass any prior
non-revised state — the agent reviews fresh.

### 4. Write the slicing record

Write the agent's output to `docs/superpowers/slices/<task-slug>.md`.

If a file already exists at that path, overwrite it. Warn the user
that any prior dispositions are replaced and they will need to
re-adjudicate.

### 5. Validation checkpoint

Read back the written file and apply the validation checks defined
in:

```text
ai-literacy-superpowers/skills/carpaccio/references/validation-checks.md
```

That file is the single source of truth for the checkpoint. Apply
the checks in order and apply the fix-recipe in place when a check
fails. Do not inline check definitions here.

### 6. Present the record to the user

Show:

- Output path
- Slice count and lens distribution
- `inseparable: true|false`
- Each slice's title and one-line scope
- A reminder: "Edit `docs/superpowers/slices/<task-slug>.md` to
  set each slice's `disposition` (`accepted | merged | dropped |
  revised`) and write a `disposition_rationale`. For each
  `accepted` slice that you are not progressing now, set
  `file_as_issue: true|false`. Set `progressed_slice:` at the top
  of the frontmatter to the slice id you will work on this
  iteration. The orchestrator's step-0 gate will not advance while
  any `disposition` or required `file_as_issue` is `pending`."

### 7. Suggest next steps

If invoked manually (not via orchestrator):

- Once dispositions are filled, proceed to `/spec-writer` against
  the progressed slice's scope.
- Accepted slices marked `file_as_issue: true` can be filed by
  running `gh issue create` manually (the orchestrator does this
  automatically when running the full pipeline).
