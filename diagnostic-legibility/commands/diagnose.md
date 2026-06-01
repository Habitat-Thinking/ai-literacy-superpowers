---
name: diagnose
description: Surface the mutually-corrected legibility models for a codebase scope on demand. /diagnose <scope> drives the full diagnostic-legibility pipeline (build, self-challenge, cross-check) and renders the corrected architectural and domain models as a readable markdown report.
---

# /diagnose \<scope\> [--out \<dir\>]

`/diagnose` is the human-facing surface for the `diagnostic-legibility`
agent. A human types `/diagnose <scope>`; the command dispatches the
agent in `mode: full` (the build → self-challenge → cross-check
pipeline), renders the returned `LegibilityModel` as a readable report,
and — after the human accepts — writes the report to disk.

The command chooses `mode: full` on the human's behalf: a human asking
to diagnose a scope wants the whole pipeline, not a partial pass. The
agent's `cross-check-only` mode is **not** exposed here; it remains a
bare-`Task`-tool affordance.

## Usage

```text
/diagnose <scope> [--out <dir>]
```

- `<scope>` — **required** positional. A directory path, a list of
  files, or a free-text description of the area to diagnose. Passed
  through to the agent verbatim.
- `--out <dir>` — **optional** directory override for where the report
  is written. The filename convention still applies beneath it.

There are no subcommands — `/diagnose` is a single verb (unlike
`/model-card create | seed`). A future re-render or comparison mode can
be added as a subcommand without breaking this signature.

## Flow

### 1. Parse args

1. **`<scope>`** — required positional. If absent, surface the usage
   error `/diagnose requires a <scope> argument` and abort: no agent
   dispatch, no file written.
2. **`--out <dir>`** — optional directory override.

### 2. Resolve scope

The command does **no** scope validation and **no** filesystem stat. It
forwards `<scope>` to the agent's `scope:` line verbatim. The agent
inspects the scope with `Glob`/`Grep`/`Read` and owns the three scope
forms and the empty-scope contract; an unresolvable scope is not a
command-level error (the agent emits the `(empty scope)` sentinel). The
scope contract lives in one place — the agent — so the command does not
duplicate it.

### 3. Resolve output path

Default output path:

```text
diagnostic-legibility/output/<scope-slug>-legibility-<YYYY-MM-DD>.md
```

- **Directory** — default `diagnostic-legibility/output/`, overridden by
  `--out <dir>` (highest priority). Created with `mkdir -p` at write
  time (step 9), only on accept. A missing `--out` directory is not an
  error. The default directory is gitignored — reports are derived,
  regenerable artefacts, never committed source.
- **`<scope-slug>`** — a filesystem-safe slug from `<scope>`: lowercase,
  non-alphanumeric runs collapsed to single hyphens, leading/trailing
  hyphens trimmed (`./src/auth/` → `src-auth`). If the slug is empty
  after trimming, fall back to the literal `scope`.
- **`<YYYY-MM-DD>`** — the date the command resolved when substituting
  the `generated_at` placeholder (step 6). The command supplies the
  date; the agent never does. The report body's `generated_at` ISO 8601
  timestamp and the filename's `<YYYY-MM-DD>` derive from the same
  resolved instant.
- **Extension** — `.md`. The report is human-readable markdown; the raw
  YAML is **not** embedded.

### 4. Dispatch the agent in `mode: full`

Dispatch the `diagnostic-legibility` agent via the `Task` tool:

- `subagent_type`: `diagnostic-legibility`
- `description`: a short imperative, e.g. `"Diagnose ./src/auth/"`
- `prompt`: first line `mode: full`, second line `scope: <scope>`
  (passed through verbatim).

The agent returns **one of**:

- a markdown response containing a `LegibilityModel` YAML block, or
- a single structured refusal line `diagnostic-legibility refusal:
  <reason>.` with **no** YAML block.

### 5. Handle a refusal

If the response contains a line matching `diagnostic-legibility
refusal:` and **no** YAML code block:

1. Surface the refusal line **verbatim** to the conversation.
2. **Abort** — render nothing, write nothing, perform no `mkdir`.

(In `mode: full` the agent's documented precondition violations are not
reachable through `/diagnose`, since the command always sends a valid
`mode: full` prompt with no supplied payload. The refusal path is
retained as a defensive contract so the command degrades safely rather
than writing a malformed report.)

### 6. Render the report

Parse the `LegibilityModel` YAML and substitute the `<DISPATCHER: ...>`
placeholders before rendering, so the report body carries concrete
`generated_at` and `generated_by` values. Render per the report
structure below.

### 7. Validation checkpoint

Before the confirm-before-write gate, read the rendered report back and
check its structure (per CLAUDE.md "Output Validation Checkpoints"). The
checkpoint's scope is deliberately **narrow** — it verifies only what it
can genuinely check against the parsed agent YAML, and is **not** an
independent oracle for renderer correctness. The genuine last line of
defence is the human accept gate (step 8), not this checkpoint. Checks:

1. **Header present and complete** — the `# Diagnostic Legibility report
   —` title and all six metadata rows.
2. **No unsubstituted placeholders** — the report contains no literal
   `<DISPATCHER:` substring. This is the load-bearing check: a report
   that leaks `<DISPATCHER: ...>` to a human has failed the surfacing
   contract.
3. **Cross-check summary present** — the `## Cross-check summary`
   section exists, states one of `completed | skipped_asymmetric |
   not_run`, and reports both A→D and D→A counts, each consistent with
   the parsed YAML under the elements-revised definition.
4. **Both collections rendered** — every `architectural[]` and
   `domain[]` element from the YAML appears (matched by `name`); counts
   match.
5. **Q/CC ordering present** — for every element, `CC<N>` entries render
   after `Q<N>` entries.
6. **Counts consistent** — header counts match the rendered blocks and
   the parsed YAML.

Deviations are fixed in place; the agent is **not** re-dispatched. If
the YAML cannot be parsed at all (malformed, not a refusal), surface the
parse failure and abort without writing a partial report.

### 8. Print the summary and confirm before write

Before any file is written:

1. Print the conversation summary (below), naming the **resolved**
   target path, the per-collection element counts, the
   `cross_check_status`, and the A→D / D→A correction counts.
2. **Flag an overwrite.** If a file already exists at the resolved path,
   state explicitly that writing will **overwrite** it (named path
   shown), so a slug-collision or same-day re-run cannot silently
   destroy an earlier report.
3. **Prompt the human to accept or abort.** The report is a
   human-facing artefact; the human sees the rendered result and
   disposes of it before it lands on disk. This accept/abort step — not
   the validation checkpoint — is the last line of defence before write.

On **abort**: write nothing, perform no `mkdir`, exit. On **accept**:
proceed to step 9.

### 9. Write the file (on accept only)

1. `mkdir -p` the resolved output directory.
2. Write the rendered report to the resolved path, and confirm the
   written path.

This runs only after the human accepts at step 8 — a real pre-write
disposition (agent-emit + dispatcher-persist + human-disposes), not a
post-hoc read of an already-written file.

## Report structure

### Header

```markdown
# Diagnostic Legibility report — <scope>

| Field | Value |
| --- | --- |
| Scope | <scope> |
| Generated at | <resolved ISO 8601 timestamp> |
| Generated by | diagnostic-legibility / <resolved model identifier> |
| Cross-check status | <completed | skipped_asymmetric | not_run> |
| Architectural elements | <N> |
| Domain elements | <M> |
```

### Cross-check summary

A `## Cross-check summary` section immediately after the header:

- A one-line statement of `cross_check_status` in human terms
  (`completed` → "Cross-check ran on both collections.";
  `skipped_asymmetric` → "Cross-check was skipped: only one collection
  was populated."; `not_run` → "Cross-check did not run.").
- **Correction counts by direction.** A direction's count is the
  **number of elements in that collection carrying at least one `CC<N>`
  entry** ("elements revised") — *not* the raw number of `CC<N>`
  entries. An element that fired two cross-check questions counts once.
  - **A→D corrections** — architectural elements carrying ≥1 `CC<N>`
    entry.
  - **D→A corrections** — domain elements carrying ≥1 `CC<N>` entry.
  - The CC-applied sentinel (`Cross-check applied; no questions surfaced
    changes`) is not a `CC<N>` entry and does not make an element count
    as revised.

```markdown
## Cross-check summary

Cross-check ran on both collections.

- A→D corrections (architectural elements revised by the domain frame): <count>
- D→A corrections (domain elements revised by the architectural frame): <count>
```

### Side-by-side summary table and stacked model bodies

The geometry is **pinned**:

1. **A compact two-column cross-check summary table** near the top — the
   genuine at-a-glance **side-by-side**. One column per collection
   (Architectural | Domain), summarising each side's element count and
   elements revised by cross-check. This table is the only part of the
   report the word "side-by-side" refers to.

   ```markdown
   | | Architectural | Domain |
   | --- | --- | --- |
   | Elements | <N> | <M> |
   | Elements revised (cross-check) | <A→D count> | <D→A count> |
   ```

2. **The model bodies as two stacked subsections** under a `## Models`
   section: `### Architectural model` first, then `### Domain model`.
   The bodies are stacked, not side-by-side — wide free-text element
   blocks render poorly in a two-column table.

Each element renders as a sub-block:

- `### <name>` heading
- `confidence: <low | medium | high>`
- the `description` (multi-paragraph preserved)
- `evidence` — a bullet list of `path` (and `excerpt` when present)
- **`challenge_notes` grouped by prefix**, self-challenge first then
  cross-check:
  - a **Self-challenge** group — the `Q<N>` entries (and the `Challenge
    applied; no questions surfaced changes` sentinel when present)
  - a **Cross-check** group — the `CC<N>` entries (and the `Cross-check
    applied; no questions surfaced changes` sentinel when present)
  - empty `challenge_notes[]` renders as `_(challenge not run)_` so the
    human can distinguish "ran cleanly" from "never ran".

The raw `LegibilityModel` YAML is **not** embedded in the report.

### Conversation summary

```text
Diagnose report ready to write: <resolved target path>
  (this path already exists and will be overwritten)   # only if it exists
Scope: <scope>
Architectural elements: <N>   Domain elements: <M>
Cross-check status: <status>
Corrections: <A→D count> A→D, <D→A count> D→A
Write this report? (accept / abort)
```

## See also

- The agent: `diagnostic-legibility/agents/diagnostic-legibility.agent.md`
- How-to: `docs/plugins/diagnostic-legibility/how-to/run-the-diagnose-command.md`
- Reference: `docs/plugins/diagnostic-legibility/reference/diagnose-command.md`
- Design spec: `docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md`
