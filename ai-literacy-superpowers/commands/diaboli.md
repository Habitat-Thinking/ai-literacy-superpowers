---
name: diaboli
description: Run the adversarial reviewer on a spec or implementation — produces the objection record at docs/superpowers/objections/<slug>.md (spec mode) or <slug>-code.md (code mode); use after spec-writer completes or after the final code-reviewer PASS
---

# /diaboli \<spec-path\> [--mode spec|code]

Run the advocatus-diaboli agent against a spec file (spec mode) or implementation
(code mode) and write the structured objection record.

`--mode` defaults to `spec`. Pass `--mode code` after the final code-reviewer PASS,
before integration-agent.

## When to use

- **Spec mode** (default): manually after `/spec-writer` completes, before presenting
  the plan; when a spec is substantively edited after an objection record already exists
  (regenerates the record — old dispositions are lost; this is intentional); when the
  orchestrator is not in use and you want adversarial review on demand
- **Code mode**: after the final code-reviewer PASS, before integration-agent; when
  running outside the orchestrator and you want adversarial review of the implementation

## Process

### 1. Validate input

Confirm the spec file exists at the given path. If not, abort with:

```text
Error: spec file not found at <path>. Pass a valid path under docs/superpowers/specs/.
```

### 2. Derive the slug

Strip the date prefix and `.md` extension from the filename.

Example: `docs/superpowers/specs/2026-04-19-advocatus-diaboli.md` → `advocatus-diaboli`

Output path:

- Spec mode: `docs/superpowers/objections/<slug>.md`
- Code mode: `docs/superpowers/objections/<slug>-code.md`

### 3. Dispatch the advocatus-diaboli agent

Pass the spec file path and mode. The agent reads the spec (and implementation
files in code mode) and returns the full objection record content. Do not pass
any prior objection record — the agent reviews fresh.

### 4. Write the objection record

Write the agent's output to `docs/superpowers/objections/<slug>.md`.

If a file already exists at that path, overwrite it. Warn the user that any
prior dispositions are replaced and they will need to re-adjudicate.

### 5. Validation checkpoint

Read back the written file and verify:

1. YAML frontmatter is present and parseable (opens with `---`)
2. Required frontmatter fields present for all modes: `spec`, `date`, `mode`,
   `diaboli_model`, `objections`
3. `mode` value is `spec` or `code` matching the flag passed
4. Each objection entry has: `id`, `category`, `severity`, `claim`, `evidence`,
   `disposition`, `disposition_rationale`
5. `disposition` value is `pending` for all entries (not pre-filled)
6. `disposition_rationale` value is `null` for all entries (not pre-filled)
7. Category values are one of: `premise`, `scope`, `implementation`, `risk`,
   `alternatives`, `specification quality`
8. Severity values are one of: `critical`, `high`, `medium`, `low`
9. Objection count is between 1 and 12 inclusive
10. Prose body contains one `## O<N>` section per objection
11. File ends with an `## Explicitly not objecting to` section containing
    at least three entries

If any check fails, fix the deviation in place. Do not re-dispatch the agent.

### 6. Present the record to the user

Show:

- Output path and mode
- Number of objections (by severity)
- Category distribution
- A reminder:
  - Spec mode: "Fill in `disposition` and `disposition_rationale` for each
    objection before proceeding. The plan-approval gate will not advance while
    any disposition is `pending`."
  - Code mode: "Fill in `disposition` and `disposition_rationale` for each
    objection before proceeding. The integration-approval gate will not advance
    while any disposition is `pending`."

### 7. Suggest next steps

If this was invoked manually (not via orchestrator):

- Spec mode: once all dispositions are filled, present the plan for approval;
  proceed to tdd-agent only after plan approval
- Code mode: once all dispositions are filled, proceed to integration-agent
